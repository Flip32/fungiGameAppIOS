//
//  inforulesView.swift
//  gameSocket
//
//  Created by Filipe Lopes on 12/12/23.
//

import SwiftUI


struct InfoRulesModal: View {
    let infoRules: String
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false // Fechar a modal ao pressionar o botão
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.black)
                        .padding()
                }
            }
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Regras:")
                        .font(.title)
                        .padding()
                    
                    Text(infoRules)
                        .padding()
                }
                .padding()
            }
            
            Spacer()
        }
    }
}
