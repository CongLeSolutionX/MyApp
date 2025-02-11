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

let cards: [Card] = [
    .init(image: "Pic 1"),
    .init(image: "Pic 6"),
    .init(image: "Pic 7"),
    .init(image: "Pic 8"),
    .init(image: "Pic 9"),
    .init(image: "Pic 10"),
    .init(image: "Pic 11"),
    .init(image: "Pic 12")
]
