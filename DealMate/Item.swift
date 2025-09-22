//
//  Item.swift
//  DealMate
//
//  Created by Jhon Ericsson Ytac on 9/22/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
