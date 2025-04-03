//
//  EarlyTerminationNoticeModels.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//

import Foundation

// MARK: - Resource Object (Early Termination Notice)

/// Represents the main data object for an Early Termination Notice.
struct EarlyTerminationNotice: Codable, Identifiable, Hashable { // Added Hashable
    let type: String
    let id: String // Using String for ID as per JSON
    let links: ResourceLinks
    let attributes: NoticeAttributes
    let relationships: NoticeRelationships

    // Conform to Hashable
    static func == (lhs: EarlyTerminationNotice, rhs: EarlyTerminationNotice) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    enum CodingKeys: String, CodingKey {
        case type, id, links, attributes, relationships
    }
}

// MARK: - Resource Links

/// Represents the links specific to a resource object.
struct ResourceLinks: Codable, Hashable { // Added Hashable
    let selfLink: Link // Renamed from 'self'

    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
    }
}

// MARK: - Notice Attributes

/// Represents the attributes of an Early Termination Notice.
struct NoticeAttributes: Codable, Hashable { // Added Hashable
    let title: String
    let created: String // Keep as String, parse later if needed
    let updated: String // Keep as String, parse later if needed
    let acquiredParty: String
    let acquiringParty: String
    let date: String // Keep as String (YYYY-MM-DD), parse later if needed
    let acquiredEntities: [String]
    let transactionNumber: String

    enum CodingKeys: String, CodingKey {
        case title, created, updated
        case acquiredParty = "acquired-party"
        case acquiringParty = "acquiring-party"
        case date
        case acquiredEntities = "acquired-entities"
        case transactionNumber = "transaction-number"
    }
}

// MARK: - Notice Relationships

/// Represents the relationships object for an Early Termination Notice.
struct NoticeRelationships: Codable, Hashable { // Added Hashable
    let nodeType: Relationship? // Optional based on potential variability
    let feedsItem: Relationship? // Optional based on potential variability

    enum CodingKeys: String, CodingKey {
        case nodeType = "node_type"
        case feedsItem = "feeds_item"
    }
}
