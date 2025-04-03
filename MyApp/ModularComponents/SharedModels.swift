//
//  SharedModels.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//

import Foundation

// MARK: - Reusable Link Structure

/// Represents a standard link object found in JSON:API responses.
struct Link: Codable, Hashable { // Added Hashable for potential use in Sets or Dictionaries
    let href: String

    enum CodingKeys: String, CodingKey {
        case href
    }
}

// MARK: - Relationship Structure

/// Represents a relationship link structure common in JSON:API.
struct Relationship: Codable, Hashable { // Added Hashable
    // let data: RelationshipData? // Could model 'data' more precisely if needed
    let links: RelationshipLinks

    enum CodingKeys: String, CodingKey {
        case links //, data
    }
}

/// Contains the links within a Relationship object.
struct RelationshipLinks: Codable, Hashable { // Added Hashable
    let selfLink: Link? // Renamed from 'self', optional
    let related: Link? // Optional

    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case related
    }
}
