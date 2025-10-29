//
//  User.swift
//  DealMate
//
//  Created by Jhon Ericsson on 10/29/25.
//

import Foundation

struct User: Codable {
    let id: String
    let username: String
    let email: String
    let pfp: String
    let location: String
    let radius: Int
    let notifications: Bool
    let createdAt: Date
}
