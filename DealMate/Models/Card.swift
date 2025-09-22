//
//  Card.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import Foundation

struct Card: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    let title: String
    let owner_name: String
}

