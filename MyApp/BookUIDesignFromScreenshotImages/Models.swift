//
//  Models.swift
//  MyApp
//
//  Created by Cong Le on 3/12/25.
//

import SwiftUI

// Unified Book2 model using Identifiable & UUID
struct Book2: Identifiable {
    let id: UUID = UUID()
    let title: String
    let author: String
    let coverImageName: String
    let rating: Double?
    let currentPage: Int
    let totalPages: Int
    let categories: [String]
    var isBookmarked: Bool
}
