//
//  CardStack.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import SwiftUI

struct CardStack: View {
    @State private var cards = [
        Card(imageName: "item", title: "Guitar", owner_name: "Joe Ytac", description: ""),
        Card(imageName: "pfp", title: "Item 2", owner_name: "time", description: ""),
        Card(imageName: "pfp", title: "Item 3", owner_name: "time", description: "")
    ]

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        NavigationStack {
            ZStack {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    let isTop = index == cards.count - 1
                    
                    NavigationLink(destination: CardDetail(card: card)) {
                        SwipeCardView(
                            card: card,
                            isTop: isTop,
                            offset: isTop ? $dragOffset : .constant(.zero),
                            onRemove: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    removeCard()
                                }
                            }
                        )
                        .scaleEffect(isTop ? 1.0 : 0.95)
                        .offset(y: CGFloat(index) * 10)
                        .opacity(isTop ? 1.0 : 0.8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: cards)
                    }
                    .buttonStyle(PlainButtonStyle()) // removes default link styling
                }
            }
            .frame(height: 500)
        }
    }

    private func removeCard() {
        if !cards.isEmpty {
            cards.removeLast()
            dragOffset = .zero
        }
    }
}


