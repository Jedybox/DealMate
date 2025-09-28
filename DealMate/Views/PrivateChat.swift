//
//  PrivateChat.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/28/25.
//

import SwiftUI

struct PrivateChat: View {
    
    var pm: String
    
    @State private var message: String = ""
    @State private var conversation: [ChatMessage] = [
        ChatMessage(text: "okay bang around 2pm tomorrow? i have things to do eh", time: "2:00pm", isUser: true, isSeen: true),
        ChatMessage(text: "Sure! See you then.", time: "2:01pm", isUser: false, isSeen: true)
    ]
    
    var body: some View {
        VStack {
            TopBar(page_name: pm)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(conversation.indices, id: \.self) { index in
                        let msg = conversation[index]
                        HStack {
                            if msg.isUser { Spacer() }
                            MessageBubble(message: msg)
                            if !msg.isUser { Spacer() }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .rotationEffect(.degrees(180))
                .padding(.horizontal, 12)
            }
            .rotationEffect(.degrees(180))

                        
            
            HStack(spacing: 0) {
                TextField("Type a message", text: $message)
                    .font(.custom("Inter-Regular_Bold", size: 16))
                    .padding(12)
                    .background(Color(.systemGray5))
                    .cornerRadius(20)
                
                Button(action: sendMessage) {
                    Image("send")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .padding(.horizontal)
                }
            }
            .padding(.horizontal)
        }.navigationBarBackButtonHidden(true)
    }
    
    private func sendMessage() {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        conversation.append(ChatMessage(text: trimmed, time: currentTime(), isUser: true, isSeen: false))
        message = ""
    }
        
    private func currentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        return formatter.string(from: Date()).lowercased()
    }
}

#Preview {
    PrivateChat(pm: "Guitar - Manong raider")
}
