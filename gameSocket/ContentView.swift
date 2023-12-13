import SwiftUI
import SocketIO


struct ContentView: View {
    @StateObject private var mesaViewModel = MesaViewModel()
    @StateObject private var infoRulesViewModel = InfoRulesViewModel()
    @State private var message = ""
    @State private var messages: [ChatMessage] = []
    @State private var showMesaView = false
//    @State private var infoRules = "nota do inicio"
    
    let socket: SocketManager
    let socketIOClient: SocketIOClient
    
    
    init() {
        // Inicialize o socket e o socketIOClient dentro do inicializador
        socket = SocketManager(socketURL: URL(string: SERVIDOR_URL)!, config: [.log(true), .compress])
        socketIOClient = socket.defaultSocket
    }
    
    var body: some View {
        ZStack {
            if(!showMesaView) {
                VStack {
    //                List(messages) { chat in
    //                    Text(chat.sender == "Player 1" ? "Player 1: \(chat.text)" : "Player 2: \(chat.text)")
    //                }
    //
    //                HStack {
    //                    TextField("Digite sua mensagem", text: $message)
    //                    Button(action: sendMessage) {
    //                        Text("Enviar")
    //                    }
    //                }
                    
                    Button(action: printMesa) {
                        Text("Imprimir Mesa")
                    }
                }
                .padding()
                .onAppear(perform: connectToServer)
            }
            
            if showMesaView {
                ZStack {
                    MesaView(contentView: self, mesaViewModel: mesaViewModel, infoRulesViewModel: infoRulesViewModel)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(20)
                    Button(action: resolveFirstHand) {
                        Text("Iniciar jogo")
                            .background(Color.pink)
                    }
                }
            }
        }
    }
    
   
    
    func sendMessage() {
        messages.append(ChatMessage(text: message, sender: "Player 1"))
        socketIOClient.emit("chat message", message)
        message = ""
    }
    
    func resolveFirstHand() {
        socketIOClient.emit("RESOLVE_FIRST_HAND")
    }
    
    
    func connectToServer() {
        socketIOClient.on("chat message") { data, _ in
            if let messageData = data[0] as? [String: Any],
               let text = messageData["text"] as? String {
                DispatchQueue.main.async {
                    let newMessage = ChatMessage(text: text, sender: "Player 2")
                    messages.append(newMessage)
                }
            }
        }
        
        socketIOClient.on("INITIAL_GAME") { data, _ in
            if let mesaData = data[0] as? [String: Any] {
                print("Dados recebidos:", mesaData)
                
                // Substitua as ocorrências de "<null>" por nil
                let sanitizedMesaData = mesaData.mapValues { value in
                    if let strValue = value as? String, strValue == "<null>" {
                        return nil as Any?
                    } else {
                        return value
                    }
                }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: sanitizedMesaData)
                    print("JSON serializado:", String(data: jsonData, encoding: .utf8) ?? "")
                    
                    let mesaL = try JSONDecoder().decode(Mesa.self, from: jsonData)
                    DispatchQueue.main.async {
                        print("=========================================")
                        print("=========================================")
                        print("mesaL => \(mesaL)")
                        print("=========================================")
                        print("=========================================")
                        mesaViewModel.mesa = mesaL
                    }
                } catch {
                    // Trate o caso em que a decodificação falhou
                    print("Erro: Falha na decodificação dos dados. Detalhes do erro:", error)
                }
            } else {
                print("=========================================")
                print("=========================================")
                // Trate o caso em que os dados não são válidos (mesaData é nulo ou não é do tipo dicionário)
                print("Erro: Os dados recebidos não são válidos.")
            }
        }

        
        socketIOClient.on("RESOLVE_TURN") { data, _ in
            if let mesaData = data[0] as? [String: Any] {
                print("Caiu no resolve turn")
                print("Caiu no resolve turn")
                print("Caiu no resolve turn")
                print("Caiu no resolve turn")
                print("Caiu no resolve turn")
                print("Caiu no resolve turn")
                // Substitua as ocorrências de "<null>" por nil
                let sanitizedMesaData = mesaData.mapValues { value in
                    if let strValue = value as? String, strValue == "<null>" {
                        return nil as Any?
                    } else {
                        return value
                    }
                }
                
                if let jsonData = try? JSONSerialization.data(withJSONObject: sanitizedMesaData),
                   let mesaL = try? JSONDecoder().decode(Mesa.self, from: jsonData) {
                    DispatchQueue.main.async {
                        mesaViewModel.mesa = mesaL
                    }
                } else {
                    // Trate o caso em que a decodificação falhou
                    print("Erro: Falha na decodificação dos dados.")
                }
            } else {
                // Trate o caso em que os dados não são válidos (mesaData é nulo ou não é do tipo dicionário)
                print("Erro: Os dados recebidos não são válidos.")
            }
        }
        
        socketIOClient.connect()
    }
    
    func printMesa() {
        print(mesaViewModel.mesa)
        if (mesaViewModel.mesa != nil) {
            print("===== Tem mesa porra ====")
            print("mesa.florest => ", mesaViewModel.mesa?.florest)
            fetchRules()
            showMesaView.toggle()
        }
    }
    
    func getFromFlorest(cardId: String) {
        socketIOClient.emit("GET_FLOREST_CARD", cardId)
        // TODO: Mostrar na tela quantas cartas faltam nesse deck
        return
    }
    func getFromMoonDeck() {
        // TODO: Pegar uma carta e colocar na mao
        // TODO: Atualizar mesa
    }
    func getFromStickDeck() {
        // TODO: Pegar uma carta e colocar na mao
        // TODO: Atualizar mesa
    }
    
    func fetchRules() {
        print("chegou no fetch rules")
        print("\(SERVIDOR_URL)/get-rules")
        guard let url = URL(string: "\(SERVIDOR_URL)/get-rules") else {
            print("URL inválida")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                if let rules = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        print("rules")
                        print(rules)
                        infoRulesViewModel.infoRules = rules
                    }
                }
            } else if let error = error {
                print("Erro ao obter as regras:", error.localizedDescription)
            }
        }.resume()
    }

}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let sender: String
}

struct Mesa: Codable {
    let player: Player
    let deckNight: [Card]
    let corruption: [Card]
    let trash: [Card]
    let florest: [Card]
    let currentPlayerId: String
}

struct Player: Codable {
    let name: String
    let hand: [Card]
    let stickSpots: [Card]?
    let basketSpots: [Card]?
    let cookingSpots: [Card]?
    let totalPoints: Int
    let id: String
    let cardsDiscarted: [Card]?
}

struct Card: Codable, Identifiable {
    let id: Int
    let type: String
    let name: String
    let cooking: Int?
    let sticks: Int?
    let cardsTotal: Int
    let img: String?
    let initial: Bool?
}

struct Arena: Codable {
}
