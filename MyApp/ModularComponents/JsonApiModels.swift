//
//  JsonApiModels.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//

import Foundation

// MARK: - JSON:API Information

/// Represents the top-level JSON:API information object.
struct JsonApiInfo: Codable, Hashable { // Added Hashable
    let version: String
    let meta: JsonApiMeta? // Making optional as it might not always be present

    enum CodingKeys: String, CodingKey {
        case version, meta
    }
}

/// Represents the metadata within the JSON:API information object.
struct JsonApiMeta: Codable, Hashable { // Added Hashable
    let links: JsonApiLinks? // Making optional

    enum CodingKeys: String, CodingKey {
        case links
    }
}

/// Represents the links within the JSON:API metadata.
struct JsonApiLinks: Codable, Hashable { // Added Hashable
    let selfLink: Link? // Renamed from 'self'

    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
    }
}
