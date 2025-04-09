//
//  DeveloperAccesTokenView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI
import MusicKit

struct DeveloperAccesTokenView: View {
    @State private var albumName: String? = nil
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
            if let albumName = albumName {
                Text("Fetched Album: \(albumName)")
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                Text("Fetching...")
            }
        }
        .onAppear(perform: fetchAlbum)
    }

    func fetchAlbum() {
        Task {
            do {
                // 1. Define the API endpoint URL
                // Example: Fetching details for a specific album
                guard let url = URL(string: "https://api.music.apple.com/v1/catalog/us/albums/1440751866") else {
                    errorMessage = "Invalid URL"
                    return
                }

                // 2. Create a MusicDataRequest
                let request = MusicDataRequest(urlRequest: URLRequest(url: url))

                // 3. Fetch the response - MusicKit handles the developer token automatically! ✨
                let response = try await request.response()

                // 4. Decode the response (Example assumes a specific structure)
                let decoder = JSONDecoder()
                // You'd typically define a Codable struct matching the API response
                // For simplicity, let's try decoding a generic structure
                if let json = try? JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any],
                   let dataArray = json["data"] as? [[String: Any]],
                   let firstAlbum = dataArray.first,
                   let attributes = firstAlbum["attributes"] as? [String: Any],
                   let name = attributes["name"] as? String {
                    self.albumName = name
                } else {
                     errorMessage = "Failed to parse album name from response"
                     print("Raw Response Data: \(String(data: response.data, encoding: .utf8) ?? "Undecodable")")
                }

            } catch {
                // Handle errors - This could include auth errors if setup is wrong,
                // network errors, or API errors (like 404 Not Found).
                 if let musicError = error as? MusicDataRequest.Error {
                     // More specific MusicKit errors
                     errorMessage = "MusicKit Error: \(musicError.localizedDescription). Code: \(musicError.description)"
                 } else {
                    errorMessage = "Failed to fetch album: \(error.localizedDescription)"
                 }
            }
        }
    }
}

// Note: For accessing user-specific data (library, playlists),
// you also need to request user authorization first:
//
// Task {
//     let status = await MusicAuthorization.request()
//     switch status {
//     case .authorized:
//         // User authorized, you can now make requests for their data.
//         // MusicKit will automatically include BOTH developer and user tokens.
//         break
//     default:
//         // Handle other statuses (denied, restricted, notDetermined)
//         break
//     }
// }

#Preview("DeveloperAccesTokenView") {
    DeveloperAccesTokenView()
}
