//
//  Item.swift
//  Meal Planner
//
//  Created by eric ho on 3/8/2025.
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
