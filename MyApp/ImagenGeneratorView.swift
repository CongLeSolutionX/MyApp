//
//  ImagenGeneratorView.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI

// MARK: - 1. Data Models (Codable)

struct ImagenGenerateRequest: Codable {
    let prompt: String
    // Add any other required parameters here based on actual API docs
    // e.g., numberOfImages, outputFormat, etc.
    var model: String = "imagen-3.0-generate-002" // Specify the model
}

struct ImagenGenerateResponse: Codable {
    // Assuming the API returns an array of URLs for the generated images
    let images: [ImageURL]? // Array of image result objects
    let error: APIErrorDetail? // Optional error details from the API

    struct ImageURL: Codable, Identifiable {
        var id = UUID() // Make identifiable for ForEach
        let url: String // The URL of the generated image

        // Provide a URL object for easier use with AsyncImage
        var imageURL: URL? {
            URL(string: url)
        }
    }

    struct APIErrorDetail: Codable {
        let code: Int?
        let message: String
    }
}

// MARK: - 2. API Service

// Define potential API errors
enum ImagenAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse(statusCode: Int)
    case decodingError(Error)
    case apiError(message: String)
    case apiKeyMissing

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The API endpoint URL is invalid."
        case .requestFailed(let error): return "Network request failed: \(error.localizedDescription)"
        case .invalidResponse(let statusCode): return "Received invalid response from server (Status Code: \(statusCode))."
        case .decodingError(let error): return "Failed to decode API response: \(error.localizedDescription)"
        case .apiError(let message): return "API returned an error: \(message)"
        case .apiKeyMissing: return "API Key is missing. Please configure it."
        }
    }
}

class ImagenAPIService {
    // !!! REPLACE WITH YOUR ACTUAL API ENDPOINT !!!
    private let apiEndpoint = "https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-002:generateImage" // Example - Check Google Docs for correct path

    // !!! REPLACE WITH YOUR ACTUAL API KEY !!!
    // IMPORTANT: Store API keys securely (e.g., in environment variables, config files, Keychain),
    //            DO NOT hardcode them directly in your source code for production apps.
    private let apiKey = "YOUR_GEMINI_API_KEY" // Placeholder

    func generateImage(prompt: String) async throws -> ImagenGenerateResponse {
        guard !apiKey.isEmpty && apiKey != "YOUR_GEMINI_API_KEY" else {
            throw ImagenAPIError.apiKeyMissing
        }

        guard let url = URL(string: apiEndpoint + "?key=\(apiKey)") else { // Key often goes in query for Google APIs
            throw ImagenAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Add other necessary headers if required by the API documentation
        // request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization") // Alternative auth method

        let requestBody = ImagenGenerateRequest(prompt: prompt)
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw ImagenAPIError.decodingError(error) // Technically encoding error here
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ImagenAPIError.invalidResponse(statusCode: 0)
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                 // Try decoding potential error message from API body
                if let apiErrorResponse = try? JSONDecoder().decode(ImagenGenerateResponse.self, from: data),
                   let errorDetail = apiErrorResponse.error {
                     throw ImagenAPIError.apiError(message: errorDetail.message)
                }
                // Otherwise throw generic status code error
                 throw ImagenAPIError.invalidResponse(statusCode: httpResponse.statusCode)
            }

            // Decode the successful response
            let decodedResponse = try JSONDecoder().decode(ImagenGenerateResponse.self, from: data)
            if let errorDetail = decodedResponse.error { // Check for error structure even in 2xx
                 throw ImagenAPIError.apiError(message: errorDetail.message)
            }
            return decodedResponse

        } catch let error as ImagenAPIError {
            throw error // Re-throw our specific API errors
        } catch {
            // Handle potential URLSession or other errors
             if let urlError = error as? URLError {
                throw ImagenAPIError.requestFailed(urlError)
            } else if error is DecodingError {
                throw ImagenAPIError.decodingError(error)
            } else {
                 throw ImagenAPIError.requestFailed(error) // General request failed
            }
        }
    }
}

// MARK: - 3. ViewModel

@MainActor // Ensure UI updates happen on the main thread
class ImagenViewModel: ObservableObject {
    @Published var promptText: String = ""
    @Published var generatedImages: [ImagenGenerateResponse.ImageURL] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let apiService = ImagenAPIService()

    func generate() {
        // Basic validation
        guard !promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a prompt."
            return
        }

        isLoading = true
        errorMessage = nil
        generatedImages = [] // Clear previous results

        Task {
            defer { isLoading = false } // Ensure loading indicator stops

            do {
                let response = try await apiService.generateImage(prompt: promptText)
                if let images = response.images {
                    generatedImages = images
                } else if let apiError = response.error {
                    // Handle cases where API returns 200 but includes an error object
                    errorMessage = ImagenAPIError.apiError(message: apiError.message).localizedDescription
                } else {
                     // No images and no error object? Unexpected success response.
                     errorMessage = "Received an unexpected response from the API."
                }
            } catch let error as ImagenAPIError {
                errorMessage = error.localizedDescription
            } catch {
                errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - 4. SwiftUI View

struct ImagenGeneratorView: View {
    @StateObject private var viewModel = ImagenViewModel()

    // Grid layout for images
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationView { // Add navigation for title
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Input Section
                    VStack(alignment: .leading) {
                        Text("Enter Prompt").font(.headline)
                        TextEditor(text: $viewModel.promptText)
                            .frame(height: 100)
                            .border(Color.gray.opacity(0.5), width: 1)
                            .cornerRadius(4) // Slight rounding
                            .font(.body)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                             .overlay( // Placeholder text
                                HStack { // Align top-left
                                    if viewModel.promptText.isEmpty {
                                        Text("e.g., A photo of an astronaut riding a horse on the moon")
                                            .foregroundColor(.gray.opacity(0.6))
                                            .padding(.all, 8)
                                    }
                                    Spacer()
                                }
                                .allowsHitTesting(false) // Let TextEditor handle taps
                            )
                    }

                    // Action Button
                    Button {
                        hideKeyboard() // Dismiss keyboard before starting request
                        viewModel.generate()
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "sparkles")
                                Text("Generate Images")
                            }
                            Spacer()
                        }
                        .padding()
                        .background(viewModel.isLoading ? Color.gray : Color.blue) // Indicate loading state
                        .foregroundColor(.white)
                        .cornerRadius(8)
                         .shadow(radius: viewModel.isLoading ? 0 : 3)
                    }
                    .disabled(viewModel.isLoading || viewModel.promptText.trimmingCharacters(in: .whitespaces).isEmpty)


                    // Error Display
                    if let errorMessage = viewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(errorMessage)
                        }
                        .foregroundColor(.red)
                        .padding(.vertical, 5)
                    }

                    // Results Section
                    if !viewModel.generatedImages.isEmpty {
                        Text("Results (\(viewModel.generatedImages.count))").font(.headline)
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(viewModel.generatedImages) { imageResult in
                                AsyncImage(url: imageResult.imageURL) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(maxWidth: .infinity, minHeight: 150) // Placeholder size
                                            .background(Color.gray.opacity(0.1))

                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()


                                    case .failure:
                                        VStack {
                                            Image(systemName: "photo") // Placeholder icon
                                                .foregroundColor(.secondary)
                                            Text("Failed")
                                                 .font(.caption)
                                                 .foregroundColor(.secondary)
                                        }
                                         .frame(maxWidth: .infinity, minHeight: 150)
                                         .background(Color.gray.opacity(0.1))


                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .cornerRadius(8)
                                .shadow(radius: 2)

                            }
                        }
                    } else if !viewModel.isLoading && viewModel.errorMessage == nil {
                         // Initial state or after successful generation with no images
                         Text("Generated images will appear here.")
                             .font(.caption)
                             .foregroundColor(.secondary)
                              .frame(maxWidth: .infinity, alignment: .center)
                              .padding(.top)
                    }
                }
                .padding()
            }
            .navigationTitle("Imagen 3 Generator")
             .onTapGesture { hideKeyboard() } // Dismiss keyboard on tap outside
        }
    }

    // Helper to dismiss keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


// MARK: - Preview

struct ImagenGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        ImagenGeneratorView()
    }
}
