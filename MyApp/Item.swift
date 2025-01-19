//
//  Item.swift
//  MyApp
//
//  Created by Cong Le on 1/19/25.
//

import SwiftUI

struct Item: Identifiable {
    var id: String = UUID().uuidString
    /// Item's Location
    var location: CGRect = .zero
    /// Your Model Properties
    var color: Color
    
}
