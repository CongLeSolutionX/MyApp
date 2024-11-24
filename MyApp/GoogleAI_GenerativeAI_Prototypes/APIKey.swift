//
//  APIKey.swift
//  MyApp
//
//  Created by Cong Le on 11/23/24.
//


import Foundation
import Foundation

enum APIKey {
    /// Fetch the API key from `GenerativeAI-Info.plist`
    static var `default`: String {
        guard let url = Bundle.main.url(forResource: "GenerativeAI-Info", withExtension: "plist") else {
            fatalError("Couldn't find 'GenerativeAI-Info.plist' in the main bundle.")
        }

        do {
            let data = try Data(contentsOf: url)
            if let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
               let value = plist["API_KEY"] as? String,
               !value.isEmpty,
               !value.starts(with: "_") {
                return value
            } else {
                fatalError("Invalid or missing 'API_KEY' in 'GenerativeAI-Info.plist'. Follow the instructions at https://ai.google.dev/tutorials/setup to get an API key.")
            }
        } catch {
            fatalError("Error reading 'GenerativeAI-Info.plist': \(error.localizedDescription)")
        }
    }
}
