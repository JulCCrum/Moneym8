//
//  Item.swift
//  Moneym8
//
//  Created by chase Crummedyo on 10/11/24.
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
