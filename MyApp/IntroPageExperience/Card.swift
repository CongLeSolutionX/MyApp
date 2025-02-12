//
//  Card.swift
//  MyApp
//
//  Created by Cong Le on 2/11/25.
//


import Foundation
import SwiftUI

struct Card: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var image: String
}

let numberOfCards = 49 // Or however many cards you need
let cards: [Card] = (0...numberOfCards).map { index in
    Card(image: "Pic \(index)")
}
