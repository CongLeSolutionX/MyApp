//
//  IgnoreItem.swift
//  MyApp
//
//  Created by Cong Le on 11/13/24.
//


import Foundation

struct IgnoreItem: Identifiable, Hashable {
    var id: String
    var type: IgnoreItemType
    var item: String
    
    init(type: IgnoreItemType, item: String) {
        self.id = UUID().uuidString
        self.type = type
        self.item = item
    }
}
