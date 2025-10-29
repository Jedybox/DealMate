//
//  NetworkManager.swift
//  DealMate
//
//  Created by STUDENT on 10/29/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let username: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username
    }
}


