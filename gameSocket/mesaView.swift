//
//  mesaView.swift
//  gameSocket
//
//  Created by Filipe Lopes on 12/12/23.
//

import SwiftUI

struct MesaView: View {
    var contentView: ContentView
    @ObservedObject var mesaViewModel: MesaViewModel
    @ObservedObject var infoRulesViewModel: InfoRulesViewModel
    @State private var isInfoRulesModalPresented = false
    
    var body: some View {
        VStack {
            Button(action: handleInfoRules){
                Image(systemName: "info.circle")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            HStack {
                Button(action: contentView.getFromFlorestDeck) {
                    Text("Deck Floresta")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                Button(action: contentView.getFromMoonDeck) {
                    Text("Deck da Lua")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                }
                Button(action: contentView.getFromStickDeck) {
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
                        ForEach(mesaViewModel.mesa?.florest ?? [], id: \.id) { florestCard in
                            Text(florestCard.name)
                                .padding()
                        }
                    }
                }
                .padding()
                .background(Color.brown)
            }
        }.sheet(isPresented: $isInfoRulesModalPresented) {
            InfoRulesModal(infoRules: infoRulesViewModel.infoRules, isPresented: $isInfoRulesModalPresented)
        }
    }
    
    func handleInfoRules() {
        isInfoRulesModalPresented.toggle()
    }
}
