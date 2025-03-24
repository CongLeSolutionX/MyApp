//
//  WidgetView.swift
//  MyApp
//
//  Created by Cong Le on 3/24/25.
//

import WidgetKit
import SwiftUI
import Combine

// MARK: - Data Model (In both the app and widget targets)

struct Movie: Codable, Identifiable {
    let id: String
    let title: String
    let year: String?
    let imageURL: String
    let plot: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case year = "year"
        case imageURL = "image"
        case plot = "plot"
    }
}

// MARK: - API Constants (In the main app target - for a real app, manage API keys securely)

struct APIConstants {
    static let apiKey = "YOUR_IMDB_API_KEY" // Replace in a real app!
    static let baseURL = "https://imdb-api.com/en/API/" //  Replace with actual base URL
    
    enum Endpoint {
        case top250Movies
        case fanFavorites
        case movieDetails(id: String)
        
        var path: String {
            switch self {
            case .top250Movies:
                return "Top250Movies"
            case .fanFavorites:
                return "MostPopularMovies"
            case .movieDetails(let id):
                return "Title/\(APIConstants.apiKey)/\(id)"
            }
        }
    }
}
//Create a struct based on the Json response, IMDb for example returns an array of "items" and errorMessage
struct IMDbResponse: Codable {
    let items: [Movie]?
    let errorMessage: String?
}

// MARK: - Network Manager (In both targets, but primarily used by the widget)
//With Mock functionalities
//
//class NetworkManager: ObservableObject {
//    @Published var movies: [Movie] = []
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//
//    private var cancellables: Set<AnyCancellable> = []
//    private let isMock: Bool
//
//    init(isMock: Bool = false) {
//        self.isMock = isMock
//    }
//
//    func fetchMovies(from endpoint: APIConstants.Endpoint) {
//        if isMock {
//            // Simulate network latency for the mock data.
//            isLoading = true
//            errorMessage = nil
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
//                self?.movies = self?.createMockMovies() ?? []
//                self?.isLoading = false
//            }
//            return //Important to prevent from calling real API call with the mock mode
//        }
//
//        //Real API call
//        let fullURLString = APIConstants.baseURL + endpoint.path + "/" + APIConstants.apiKey
//
//        guard let url = constructURL(from: fullURLString) else {
//            self.errorMessage = "Invalid URL"
//            return
//        }
//
//        isLoading = true
//        errorMessage = nil
//
//        URLSession.shared.dataTaskPublisher(for: url)
//            .tryMap { output -> Data in
//                guard let httpResponse = output.response as? HTTPURLResponse,
//                      (200...299).contains(httpResponse.statusCode) else {
//                    let statusCode = (output.response as? HTTPURLResponse)?.statusCode ?? -1
//                    throw URLError(.badServerResponse, userInfo: ["statusCode": statusCode])
//                }
//                return output.data
//            }
//            .decode(type: IMDbResponse.self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] completion in
//                self?.isLoading = false
//                switch completion {
//                case .failure(let error):
//                    self?.errorMessage = self?.parseError(error)
//                case .finished:
//                    break
//                }
//            } receiveValue: { [weak self] response in
//                self?.movies = response.items ?? []
//            }
//            .store(in: &cancellables)
//    }
//
//    private func constructURL(from string: String) -> URL? {
//        guard var components = URLComponents(string: string) else {
//            return nil
//        }
//        components.queryItems = [] //Add parameters
//
//        return components.url
//    }
//    private func parseError(_ error: Error) -> String {
//        if let urlError = error as? URLError {
//            // ... (rest of your error parsing logic) ...
//            switch urlError.code{
//            case .notConnectedToInternet:
//                return "No Internet Connection"
//            case .timedOut:
//                return "Request Timed Out"
//            case .cannotFindHost, .cannotConnectToHost:
//                return "Server Unreachable"
//            case .badServerResponse:
//                if let statusCode = urlError.userInfo["statusCode"] as? Int{
//                    return "Server Error: \(statusCode)"
//                }
//                return "Server Error"
//
//            default:
//                return "Network Error: \(urlError.localizedDescription)"
//            }
//        } else  {
//            return "An unexpected error occurred: \(error.localizedDescription)"
//        }
//    }
//
//
//        // Mock Data Generation
//    private func createMockMovies() -> [Movie] {
//        return [
//            Movie(id: "tt0111161", title: "The Shawshank Redemption", year: "1994", imageURL: "https://m.media-amazon.com/images/M/MV5BNDE3ODcxYzMtY2YzZC00NmNlLWJiNDMtZDViZWM2MzIxZDYwXkEyXkFqcGdeQXVyNjAwNDUxODI@._V1_FMjpg_UX1000_.jpg", plot: "Over the course of several years, two convicts form a friendship, seeking consolation and, eventually, redemption through basic compassion."),
//            Movie(id: "tt0068646", title: "The Godfather", year: "1972", imageURL: "https://m.media-amazon.com/images/M/MV5BM2MyNjYxNmUtYTAwNi00MTYxLWJmNWYtYzZlODY3ZTk3OTFlXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_FMjpg_UX1000_.jpg",plot: "The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son."),
//            Movie(id: "tt0468569", title: "The Dark Knight", year: "2008", imageURL: "https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_FMjpg_UX1000_.jpg", plot: "When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.")
//        ]
//    }
//}


class NetworkManager: ObservableObject {
    // Using @Published for automatic UI updates when movies change.
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables: Set<AnyCancellable> = []
    
    //Robust method for handling different endpoints
    func fetchMovies(from endpoint: APIConstants.Endpoint) {
        
        let fullURLString = APIConstants.baseURL + endpoint.path + "/" + APIConstants.apiKey
        
        //Use helper method to generate a valid URL
        guard let url = constructURL(from: fullURLString) else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        errorMessage = nil // Clear any previous errors
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output -> Data in
                guard let httpResponse = output.response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    //Detailed error handling and messages
                    let statusCode = (output.response as? HTTPURLResponse)?.statusCode ?? -1
                    throw URLError(.badServerResponse, userInfo: ["statusCode": statusCode])
                }
                return output.data
            }
            .decode(type: IMDbResponse.self, decoder: JSONDecoder()) // Assumed response structure
            .receive(on: DispatchQueue.main) // Update UI on the main thread
        
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    //More specific error identification
                    self?.errorMessage = self?.parseError(error)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] response in
                //IMDb returns an items array, so use the array to decode it.
                self?.movies = response.items ?? [] // Handle situations where no data will be returned
            }
            .store(in: &cancellables) // Manage the subscription
    }
    
    //Helper function to construct an encoded URL
    private func constructURL(from string: String) -> URL? {
        guard var components = URLComponents(string: string) else {
            return nil
        }
        //URLQueryItem for API keys and parameters
        components.queryItems = [] //Add any parameters the API need
        
        return components.url
    }
    
    //Improve the error parsing
    private func parseError(_ error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "No Internet Connection"
            case .timedOut:
                return "Request Timed Out"
            case .cannotFindHost, .cannotConnectToHost:
                return "Server Unreachable"
            case .badServerResponse:
                if let statusCode = urlError.userInfo["statusCode"] as? Int {
                    return "Server Error: \(statusCode)"
                }
                return "Server Error"
            default:
                return "Network Error: \(urlError.localizedDescription)"
            }
        } else {
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    // Mock Data Generation
    private func createMockMovies() -> [Movie] {
        return [
            Movie(id: "tt0111161", title: "The Shawshank Redemption", year: "1994", imageURL: "https://m.media-amazon.com/images/M/MV5BNDE3ODcxYzMtY2YzZC00NmNlLWJiNDMtZDViZWM2MzIxZDYwXkEyXkFqcGdeQXVyNjAwNDUxODI@._V1_FMjpg_UX1000_.jpg", plot: "Over the course of several years, two convicts form a friendship, seeking consolation and, eventually, redemption through basic compassion."),
            Movie(id: "tt0068646", title: "The Godfather", year: "1972", imageURL: "https://m.media-amazon.com/images/M/MV5BM2MyNjYxNmUtYTAwNi00MTYxLWJmNWYtYzZlODY3ZTk3OTFlXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_FMjpg_UX1000_.jpg",plot: "The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son."),
            Movie(id: "tt0468569", title: "The Dark Knight", year: "2008", imageURL: "https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_FMjpg_UX1000_.jpg", plot: "When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.")
        ]
    }
}
