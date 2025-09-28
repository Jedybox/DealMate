//
//  MessageBubble.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/28/25.
//

import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading , spacing: 4) {
            Text(message.text)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .padding(12)
                .background(
                    ZStack(alignment: .bottomTrailing) {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(message.isUser ? Color(red: 0.85, green: 1.0, blue: 0.85) : Color(.systemGray5))
                        
                        if message.isUser {
                            // Tail
                            Triangle()
                                .fill(Color(red: 0.85, green: 1.0, blue: 0.85))
                                .frame(width: 10, height: 10)
                                .rotationEffect(.degrees(45))
                                .offset(x: 6, y: 6)
                        }
                    }
                )
            
            HStack(spacing: 4) {
                Text(message.time)
                    .font(.system(size: 12))
                    .foregroundColor(message.isUser ? .green : Color(.systemGray))
                
                if message.isUser {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10))
                        .foregroundColor(.green)
                    Image(systemName: "checkmark")
                        .font(.system(size: 10))
                        .foregroundColor(.green)
                }
            }
            .padding(.trailing, 8)
        }
        .frame(maxWidth: 250, alignment: message.isUser ? .trailing : .leading )
    }
}


struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
