//
//  PhotoService.swift
//  MyApp
//
//  Created by Cong Le on 12/4/24.
//

import Foundation

class PhotoService: PhotoServiceProtocol {
    func fetchPhoto() async throws -> Photo {
        guard let url = URL(string: "https://picsum.photos/200/300") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.invalidResponse
        }
        
        return Photo(imageData: data)
    }
}

enum NetworkError: Error, LocalizedError, Identifiable {
    var id: String { localizedDescription }
    
    case invalidURL
    case invalidResponse
    case apiError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .apiError(let error):
            return error.localizedDescription
        }
    }
}
