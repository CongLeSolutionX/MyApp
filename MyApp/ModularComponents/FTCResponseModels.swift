//
//  FTCResponseModels.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//

import Foundation

// MARK: - Top-Level Response Structure

/// The main structure representing the entire JSON response from the FTC API.
struct FTCResponse: Codable {
    let jsonapi: JsonApiInfo
    let data: [EarlyTerminationNotice]
    let meta: TopLevelMeta
    let links: TopLevelLinks

    enum CodingKeys: String, CodingKey {
        case jsonapi, data, meta, links
    }
}

// MARK: - Top-Level Meta & Links

/// Represents the metadata at the top level of the response.
struct TopLevelMeta: Codable, Hashable { // Added Hashable
    let count: Int

    enum CodingKeys: String, CodingKey {
        case count
    }
}

/// Represents the links at the top level of the response.
struct TopLevelLinks: Codable, Hashable { // Added Hashable
    let selfLink: Link // Renamed from 'self'

    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
    }
}
