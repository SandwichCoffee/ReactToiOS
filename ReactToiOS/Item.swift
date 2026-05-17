//
//  Item.swift
//  ReactToiOS
//
//  Created by 샌드위치커피 on 5/15/26.
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
