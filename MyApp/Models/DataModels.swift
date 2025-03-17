//
//  DataModels.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

// MARK: - Models

struct Topic: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String // SF Symbol name
    var isSelected: Bool = false
}

struct Author: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

struct Article: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let author: Author
    let url: String
    let imageName: String
    let topics: [Topic]
    let isBookmarked: Bool
    let updatesSinceLastViewed: Int
}
