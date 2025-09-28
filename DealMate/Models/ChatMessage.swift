//
//  ChatMessage.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/28/25.
//

import Foundation

struct ChatMessage: Equatable {
    let text: String
    let time: String
    let isUser: Bool
    let isSeen: Bool
}
