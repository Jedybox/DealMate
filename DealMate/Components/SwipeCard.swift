//
//  SwipeCard.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import SwiftUI

struct SwipeCardView: View {
    let card: Card
    let isTop: Bool
    @Binding var offset: CGSize
    var onRemove: () -> Void

    @State private var isDragging = false
    @State private var showDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(card.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: 350, maxHeight: 450 * 0.8)
                .clipped()
                .shadow(radius: 5)

            VStack(alignment: .leading) {
                Text(card.title)
                    .font(.custom("Poppins-Bold", size: 22))
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: 450 * 0.2, alignment: .leading)
            .foregroundStyle(.white)
            .background(Color(red: 28/255, green: 139/255, blue: 150/255))
        }
        .cornerRadius(20)
        .frame(maxWidth: 350, maxHeight: 450)
        .offset(x: offset.width, y: offset.height * 0.1)
        .rotationEffect(.degrees(Double(offset.width / 15)))
        .onTapGesture {
            if !isDragging {
                showDetail = true
            }
        }
        .gesture(
            isTop ?
            DragGesture()
                .onChanged { gesture in
                    isDragging = true
                    withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.7)) {
                        offset = gesture.translation
                    }
                }
                .onEnded { _ in
                    let threshold: CGFloat = 150
                    if abs(offset.width) > threshold {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            offset.width = offset.width > 0 ? 1000 : -1000
                            offset.height += 100
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onRemove()
                        }
                    } else {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            offset = .zero
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isDragging = false
                    }
                }
            : nil
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: offset)
        // ✅ Modern navigation modifier
        .navigationDestination(isPresented: $showDetail) {
            CardDetail(card: card)
        }
    }
}
