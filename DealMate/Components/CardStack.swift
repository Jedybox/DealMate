//
//  CardStack.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import SwiftUI

struct CardStack: View {
    @State private var cards = [
        Card(imageName: "pfp", title: "Item 1", owner_name: "time"),
        Card(imageName: "pfp", title: "Item 2", owner_name: "time"),
        Card(imageName: "pfp", title: "Item 3", owner_name: "time")
    ]

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            ForEach(cards) { card in
                if card == cards.last {
                    SwipeCard(card: card, offset: $dragOffset) {
                        removeCard()
                    }
                } else {
                    VStack {
                        Image(card.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 300)
                            .clipped()
                            .cornerRadius(20)
                            .shadow(radius: 5)
                        VStack{
                            Text(card.title)
                            Text(card.owner_name)
                        }
                    }
                }
            }
        }
    }

    private func removeCard() {
        if !cards.isEmpty {
            cards.removeLast()
            dragOffset = .zero
        }
    }
}

