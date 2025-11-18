//
//  Card.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import Foundation
import UIKit

struct Card: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String

    // Optional UIImage to hold decoded base64 images when available
    var uiImage: UIImage?

    // Equatable conformance based on id
    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.id == rhs.id
    }
}
