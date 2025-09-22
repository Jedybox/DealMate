//
//  SwipeCard.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import SwiftUI

struct SwipeCard: View {
    let card: Card
    @Binding var offset: CGSize
    var onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // remove gap by setting spacing = 0
            Image(card.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: 350, maxHeight: 450 * 0.8) // take ~80% of space
                .clipped()
                .shadow(radius: 5)

            VStack(alignment: .leading) {
                Text(card.title)
                    .font(.custom("Poppins-Bold", size: 22))
                    .padding(.horizontal)
                Text(card.owner_name)
                    .font(.custom("Poppins", size: 18))
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: 450 * 0.2, alignment: .leading) // fill remaining space
            .foregroundColor(.white)
            .background(Color(red: 28/255, green: 139/255, blue: 150/255)) // ixed typo: 155 → 255
            
        }
        .cornerRadius(20)
        .frame(maxWidth: 350, maxHeight: 450)
        .offset(x: offset.width, y: offset.height * 0.1)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if abs(offset.width) > 150 {
                        // swiped off screen
                        onRemove()
                    } else {
                        // reset
                        offset = .zero
                    }
                }
        )
        .animation(.spring(), value: offset)
    }
}
