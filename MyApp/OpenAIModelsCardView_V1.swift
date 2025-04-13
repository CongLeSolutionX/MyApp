//
//  OpenAIModelsCardView_V1.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import SwiftUI

// --- Phase 1 & 2: Data Modeling (Matching JSON Response) ---

// Represents the overall JSON response structure
struct ModelListResponse: Codable {
    let data: [OpenAIModel]
}

// Represents a single model object from the 'data' array
struct OpenAIModel: Codable, Identifiable {
    let id: String
    let object: String
    let created: Int // Unix timestamp
    let ownedBy: String

    // Conform to Codable (custom key mapping for 'owned_by')
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case ownedBy = "owned_by" // Map JSON key 'owned_by' to Swift 'ownedBy'
    }

    // Computed property for easy date access
    var createdDate: Date {
        Date(timeIntervalSince1970: TimeInterval(created))
    }
}

// --- Phase 4: Network Service (Simplified Example) ---

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
    case missingCredentials
}

class OpenAPIService {
    // !!! --- SECURITY WARNING --- !!!
    // NEVER hardcode API keys directly in your app like this for production.
    // Use secure storage (like Keychain) or a configuration file
    // that is not checked into source control.
    // For demonstration purposes ONLY:
    private let apiKey = "YOUR_OPENAI_API_KEY" // Replace with your actual key safely
    private let orgId = "YOUR_ORG_ID"         // Optional: Replace safely if needed
    private let projectId = "YOUR_PROJECT_ID" // Optional: Replace safely if needed

    func fetchModels() async throws -> [OpenAIModel] {

        // Basic check if placeholder key is still present
        if apiKey.contains("YOUR_") {
             print("⚠️ Error: API Key not set. Please replace placeholder.")
             throw NetworkError.missingCredentials
        }

        guard let url = URL(string: "https://api.openai.com/v1/models") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        // --- Optional Headers ---
        if !orgId.contains("YOUR_") { // Add only if properly set
             request.setValue(orgId, forHTTPHeaderField: "OpenAI-Organization")
        }
        if !projectId.contains("YOUR_") { // Add only if properly set
             request.setValue(projectId, forHTTPHeaderField: "OpenAI-Project")
        }
        // -----------------------

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                // You could add more specific error handling based on status code here
                print("HTTP Status Code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Error Response Body: \(dataString)") // Log error body
                }
                throw NetworkError.invalidResponse
            }

            do {
                let decodedResponse = try JSONDecoder().decode(ModelListResponse.self, from: data)
                return decodedResponse.data
            } catch {
                print("Decoding Error: \(error)")
                throw NetworkError.decodingError(error)
            }
        } catch {
             // Handle potential URLSession errors (network connection, timeouts, etc.)
             print("URLSession Request Failed: \(error)")
             // Don't re-throw decodingError if it was already caught above
             if !(error is NetworkError) {
                 throw NetworkError.requestFailed(error)
             } else {
                 throw error // Re-throw NetworkError.decodingError or other NetworkErrors
             }
        }
    }
}

// --- Phase 3 & 4: SwiftUI Card View ---

struct ModelCardView: View {
    let model: OpenAIModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.id)
                .font(.headline)
                .lineLimit(1) // Ensure ID doesn't wrap excessively
                .truncationMode(.tail)

            HStack {
                 Image(systemName: ownerIconName(owner: model.ownedBy)) // Icon based on owner
                     .foregroundColor(ownerIconColor(owner: model.ownedBy))
                 Text("Owned by: \(model.ownedBy)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text("Created: \(model.createdDate, style: .date)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading) // Take full width, align left
        .background(.regularMaterial) // Use a material background for a modern look
        .clipShape(RoundedRectangle(cornerRadius: 10)) // Use clipShape for cornerRadius with materials
        // .background(Color(.systemGray6)) // Alternative solid background
        // .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 2) // Subtle shadow
    }

     // Helper function for owner icon
     private func ownerIconName(owner: String) -> String {
         switch owner.lowercased() {
         case "openai": return "building.columns.fill"
         case "system": return "gearshape.fill"
         case "openai-internal": return "lock.shield.fill"
         default: return "questionmark.circle.fill"
         }
     }

     // Helper function for owner icon color
     private func ownerIconColor(owner: String) -> Color {
         switch owner.lowercased() {
         case "openai": return .blue
         case "system": return .orange
         case "openai-internal": return .purple
         default: return .gray
         }
     }
}

// --- Phase 3 & 4: Main SwiftUI View ---

struct OpenAIModelsCardView: View {
    @State private var models: [OpenAIModel] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    private let apiService = OpenAPIService()

    var body: some View {
        NavigationStack { // Use NavigationStack for modern iOS
            List {
                if isLoading {
                    ProgressView("Loading Models...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                } else if let errorMessage = errorMessage {
                    VStack(alignment: .center, spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.red)
                        Text("Error Loading Models")
                             .font(.headline)
                        Text(errorMessage)
                           .font(.body)
                           .foregroundColor(.secondary)
                           .multilineTextAlignment(.center)
                           .padding(.horizontal)
                        Button("Retry") {
                            // Clear error and trigger fetch again
                            //errorMessage = "No error"
                            loadModels()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                      .frame(maxWidth: .infinity)
                      .padding(.vertical, 40)
                      .listRowSeparator(.hidden)

                } else if models.isEmpty && !isLoading {
                     Text("No models found.")
                          .foregroundColor(.secondary)
                          .frame(maxWidth: .infinity, alignment: .center)
                          .padding(.vertical)
                          .listRowSeparator(.hidden)
                }
                else {
                    ForEach(models) { model in
                        ModelCardView(model: model)
                            // Remove default list row background/insets for edge-to-edge card feel
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear) // Make row background transparent
                    }
                }
            }
            .listStyle(.plain) // Use plain style to remove default list styling
            .navigationTitle("OpenAI Models")
            .task { // Use .task for async operations tied to view lifecycle
                if models.isEmpty { // Only load if models aren't already loaded
                   loadModels()
                }
            }
            .refreshable { // Add pull-to-refresh
                 loadModels()
            }
        }
    }

    // Function to encapsulate the loading logic
    private func loadModels() {
        isLoading = true
        errorMessage = nil // Clear previous errors

        Task { // Create a new Task for the async call
            do {
                let fetchedModels = try await apiService.fetchModels()
                // Sort models alphabetically by ID for consistent order
                let sortedModels = fetchedModels.sorted { $0.id < $1.id }
                // Update state on the main thread
                await MainActor.run {
                     self.models = sortedModels
                     self.isLoading = false
                }
            } catch let error as NetworkError {
                // Handle specific network errors
                await MainActor.run {
                    switch error {
                        case .invalidURL: self.errorMessage = "Internal error: Invalid API URL."
                        case .requestFailed(let underlyingError): self.errorMessage = "Network request failed: \(underlyingError.localizedDescription)"
                        case .invalidResponse: self.errorMessage = "Received an invalid response from the server."
                        case .decodingError(let underlyingError): self.errorMessage = "Failed to decode server response: \(underlyingError.localizedDescription)"
                         case .missingCredentials: self.errorMessage = "API credentials are not configured correctly. Please check your settings."
                    }
                    self.isLoading = false
                    self.models = [] // Clear models on error
                }
            } catch {
                // Handle any other unexpected errors
                await MainActor.run {
                    self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                    self.isLoading = false
                     self.models = [] // Clear models on error
                }
            }
        }
    }
}

// --- Preview ---

#Preview {
    OpenAIModelsCardView()
}
