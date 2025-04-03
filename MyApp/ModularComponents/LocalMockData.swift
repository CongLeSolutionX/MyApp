//
//  LocalMockData.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//

import Foundation

struct LocalMockData {
    /// Loads the raw JSON string from the local JSON file in the app bundle.
    static func loadMockFTCData() throws -> String {
        guard let url = Bundle.main.url(forResource: "MockFTCData", withExtension: "json") else {
            throw NSError(domain: "LocalMockDataError",
                          code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to find MockFTCData.json in bundle"])
        }

        // Read the contents of the file
        let data = try Data(contentsOf: url)
        // Convert data to string
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "LocalMockDataError",
                          code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to encode JSON data to String"])
        }
        return jsonString
    }
}
