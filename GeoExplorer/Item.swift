//
//  Item.swift
//  GeoExplorer
//
//  Created by Luis Henríquez on 25/03/26.
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
