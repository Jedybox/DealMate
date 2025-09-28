//
//  Chats.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import SwiftUI

struct Chats: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top bar
                TopBar(page_name: "Chats")
                
                // Chat list
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // Example chat preview
                        NavigationLink(destination: PrivateChat(pm: "Guitar - Manong raider")) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Image("item")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 65, height: 65)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    Image("pfp")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .clipShape(.circle)
                                        .offset(x:25, y:25)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Guitar")
                                        .font(.custom("Poppins-Bold", size: 16))
                                        .foregroundStyle(.primary)
                                    
                                    Text("Last message preview here...")
                                        .font(.custom("Poppins-Regular", size: 13))
                                        .foregroundStyle(.gray)
                                }
                                
                                Spacer()
                                
                                // Timestamp
                                Text("2:00pm")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundStyle(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain) // Removes default NavigationLink styling
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    Chats()
}
