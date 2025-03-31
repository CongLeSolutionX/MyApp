//
//  NewsSource.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI

// --- Data Models (Placeholders) ---

struct NewsSource: Identifiable {
    let id = UUID()
    let name: String
    let logoName: String // Placeholder for image asset name
}

struct NewsArticle: Identifiable {
    let id = UUID()
    let source: NewsSource
    let headline: String
    let imageName: String // Placeholder for image asset name
    let timeAgo: String
    let isLargeCard: Bool // Differentiate card types
    let smallImageName: String? // Optional smaller image for list view
}

// --- Reusable Views ---
