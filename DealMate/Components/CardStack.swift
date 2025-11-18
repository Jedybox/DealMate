//
//  CardStack.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import SwiftUI

struct CardStack: View {
    // Accept cards from parent as a binding so swipes can remove them
    @Binding var cards: [Card]

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                let isTop = index == cards.count - 1

                // Let the SwipeCardView handle its own navigation and gestures
                SwipeCardView(
                    card: card,
                    isTop: isTop,
                    offset: isTop ? $dragOffset : .constant(.zero),
                    onRemove: {
                        // Safe removal by id — find the current index for the card
                        if let idx = cards.firstIndex(where: { $0.id == card.id }) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                cards.remove(at: idx)
                            }
                        }
                    }
                )
                .scaleEffect(isTop ? 1.0 : 0.95)
                .offset(y: CGFloat(index) * 10)
                .opacity(isTop ? 1.0 : 0.8)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: cards)
                .buttonStyle(.plain) // ensure no default button style interference
            }
        }
        .frame(height: 500)
    }

    
    private func removeCardAtIndex(_ index: Int) {
        if cards.indices.contains(index) {
            cards.remove(at: index)
        }
    }
}
