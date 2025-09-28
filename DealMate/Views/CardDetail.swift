//
//  CardDetail.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/28/25.
//

import SwiftUI

struct CardDetail: View {
    let card: Card

    var body: some View {
        VStack(spacing: 0) {
            Image(card.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 300)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Text(card.title)
                    .font(.custom("Poppins-Bold", size: 22))
                    .padding(.top)
                Text(card.owner_name)
                    .font(.custom("Poppins", size: 16))
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 28/255, green: 139/255, blue: 150/255))
            .foregroundStyle(.white)
            .cornerRadius(25, corners: [.topLeft, .topRight])

            
        }
        .ignoresSafeArea(edges: [.top, .bottom])
        .navigationBarTitleDisplayMode(.inline)
    }
}

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

