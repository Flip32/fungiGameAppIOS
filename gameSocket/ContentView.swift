import SwiftUI
import SocketIO


struct ContentView: View {
    @State private var message = ""
    @State private var messages: [ChatMessage] = []
    @State private var mesa: Mesa?
    @State private var showMesaView = false
    
    let socket: SocketManager
    let socketIOClient: SocketIOClient
    
    init() {
        // Inicialize o socket e o socketIOClient dentro do inicializador
        socket = SocketManager(socketURL: URL(string: SERVIDOR_URL)!, config: [.log(true), .compress])
        socketIOClient = socket.defaultSocket
    }
    
    var body: some View {
        ZStack {
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
            
            if showMesaView {
                mesaView
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(20)
            }
        }
    }
    
    var mesaView: some View {
        VStack {
            HStack {
                Button(action: getFromFlorestDeck) {
                    Text("Deck Floresta")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                Button(action: getFromMoonDeck) {
                    Text("Deck da Lua")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                }
                Button(action: getFromStickDeck) {
                    Text("Deck de Gravetos")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                }
            }
            VStack {
                Text("Floresta")
                ScrollView(.horizontal) {
                        HStack {
                            ForEach(mesa?.florest ?? [], id: \.id) { florestCard in
                                Text(florestCard.name)
                                    .padding()
                            }
                        }
                    }
                .padding()
                .background(Color.brown)
            }
        }
    }
    
    func sendMessage() {
        messages.append(ChatMessage(text: message, sender: "Player 1"))
        socketIOClient.emit("chat message", message)
        message = ""
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
        
        socketIOClient.on("initial game") { data, _ in
            if let mesaData = data[0] as? [String: Any] {
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
                        mesa = mesaL
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
        print(mesa)
        if (mesa != nil) {
            print("===== Tem mesa porra ====")
            print("mesa.florest => ", mesa?.florest)
            showMesaView.toggle()
        }
    }
    
    func getFromFlorestDeck() {
        // TODO: Mostrar na tela quantas cartas faltam nesse deck
    }
    func getFromMoonDeck() {
        // TODO: Pegar uma carta e colocar na mao
        // TODO: Atualizar mesa
    }
    func getFromStickDeck() {
        // TODO: Pegar uma carta e colocar na mao
        // TODO: Atualizar mesa
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let sender: String
}

struct Mesa: Codable {
    let player: Player
    let deckFlorest: [Card]
    let deckNight: [Card]
    let corruption: [Card]
    let trash: [Card]
    let florest: [Card]
}

struct Player: Codable {
    let name: String
    let hand: [Card]
    let stickSpots: [Card]?
    let basketSpots: [Card]?
    let cookingSpots: [Card]?
    let totalPoints: Int
    let id: String
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
