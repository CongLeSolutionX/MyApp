//
//  GatewayServicesPublicView.swift
//  MyApp
//
//  Created by Cong Le on 3/23/25.
//
import SwiftUI
import Combine

// MARK: - Data Models

struct User: Codable, Identifiable {
    let id: Int // Assuming an 'id' field exists
    let firstName: String?
    let lastName: String?
    let email: String?
}

struct TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let scope: String
}

// MARK: - API Endpoints

enum APIEndpoint {
    case getAllUsers
    case getUserByName(lastName: String)

    var path: String {
        switch self {
        case .getAllUsers:
            return "/users"
        case .getUserByName(let lastName):
            return "/user?lastName=\(lastName)"
        }
    }
}

// MARK: - API Errors

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(String)
    case decodingFailed
    case noData
    case authenticationFailed
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .requestFailed(let message):
            return "API request failed: \(message)"
        case .decodingFailed:
            return "Failed to decode the response."
        case .noData:
            return "No data was returned."
        case .authenticationFailed:
            return "Authentication failed. Please check your credentials."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - Authentication

// IMPORTANT: Replace with secure storage in a real app!
struct AuthCredentials {
    static let clientID = "YOUR_CLIENT_ID" // Replace
    static let clientSecret = "YOUR_CLIENT_SECRET" // Replace
}

// MARK: - Data Service

final class GatewayService: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURLString = "https://api-devl.fanniemae.com/enterprise/gateway/gwservices-public" // Correct Base URL
    private let tokenURL = "YOUR_AUTH_TOKEN_ENDPOINT" // Replace with actual endpoint
    private var accessToken: String?
    private var tokenExpiration: Date?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Token Management

    private func getAccessToken(completion: @escaping (Result<String, APIError>) -> Void) {
        // Return token if still valid.
        if let token = accessToken, let expiration = tokenExpiration, Date() < expiration {
            completion(.success(token))
            return
        }

        guard let url = URL(string: tokenURL) else {
            completion(.failure(.invalidURL))
            return
        }

        let credentials = "\(AuthCredentials.clientID):\(AuthCredentials.clientSecret)"
        guard let base64Credentials = credentials.data(using: .utf8)?.base64EncodedString() else {
            completion(.failure(.authenticationFailed))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8) // Assuming client_credentials

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let responseString = String(data: data, encoding: .utf8) ?? ""
                    throw APIError.requestFailed("Invalid response. Response: \(responseString)")
                }
                return data
            }
            .decode(type: TokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    let apiError = (error as? APIError) ?? APIError.unknown(error)
                    self?.handleError(apiError)
                    completion(.failure(apiError))
                }
            } receiveValue: { [weak self] tokenResponse in
                self?.accessToken = tokenResponse.access_token
                self?.tokenExpiration = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
                completion(.success(tokenResponse.access_token))
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API

    func getAllUsers() {
        fetchData(for: .getAllUsers)
    }

    func getUserByName(lastName: String) {
        fetchData(for: .getUserByName(lastName: lastName))
    }

    func fetchData(for endpoint: APIEndpoint) {
        isLoading = true
        errorMessage = nil

        getAccessToken { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.makeDataRequest(endpoint: endpoint, accessToken: token)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.handleError(error)
                }
            }
        }
    }

    private func makeDataRequest(endpoint: APIEndpoint, accessToken: String) {
        guard let url = URL(string: baseURLString + endpoint.path) else {
            handleError(.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization") // Use Bearer token

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let responseString = String(data: data, encoding: .utf8) ?? "No Response Body"
                    throw APIError.requestFailed("HTTP Status Code error. Response: \(responseString)")
                }
                return data
            }
            .decode(type: [User].self, decoder: JSONDecoder()) // Decode directly to [User]
            .catch { [weak self] error -> AnyPublisher<[User], Never> in
                if let apiError = error as? APIError {
                    self?.handleError(apiError)
                } else {
                    self?.handleError(.unknown(error)) // For non-API errors
                }
                return Just([]).eraseToAnyPublisher() // Return empty array on error
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                self?.isLoading = false
                self?.users = users
            }
            .store(in: &cancellables)
    }


    private func handleError(_ error: APIError) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            print("API Error: \(error.localizedDescription)")
        }
    }
    /// Clears any locally stored data.
    func clearLocalData() {
        users.removeAll()
    }
}

// MARK: - SwiftUI Views

struct GatewayServicesPublicView: View {
    @StateObject private var service = GatewayService()
    @State private var searchLastName: String = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter Last Name", text: $searchLastName, onCommit: {
                    if !searchLastName.isEmpty{
                        service.getUserByName(lastName: searchLastName)
                    }
                })
                    .padding()
                    .textFieldStyle(.roundedBorder)

                HStack{
                    Button("Search by Last Name") {
                        if !searchLastName.isEmpty {
                            service.getUserByName(lastName: searchLastName)
                        }
                    }
                    .buttonStyle(.bordered)

                    Button("Get All Users") {
                        service.getAllUsers()
                    }
                    .buttonStyle(.borderedProminent)
                }

                if service.isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = service.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else {
                    List(service.users) { user in
                        UserView(user: user)
                    }
                }
                Button("Clear Data", role: .destructive) {
                    service.clearLocalData()
                }
            }
            .navigationTitle("Gateway Services")
            .padding() // Add some padding around the VStack
        }
    }
}

struct UserView: View {
    let user: User

    var body: some View {
        VStack(alignment: .leading) {
            Text("ID: \(user.id)")
            if let firstName = user.firstName {
                Text("First Name: \(firstName)")
            }
            if let lastName = user.lastName {
                Text("Last Name: \(lastName)")
            }
            if let email = user.email {
                Text("Email: \(email)")
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Preview

struct GatewayServicesPublicView_Previews: PreviewProvider {
    static var previews: some View {
        GatewayServicesPublicView()
    }
}
