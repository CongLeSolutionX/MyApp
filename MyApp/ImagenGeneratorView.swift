//
//  ImagenGeneratorView.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//
import SwiftUI
import Combine // Needed for DispatchQueue

// MARK: - 0. Model Selection Enum
enum GenerationModel: String, CaseIterable, Identifiable {
    case gemini_2_flash = "gemini-2.0-flash-exp-image-generation"
    case imagen_3 = "imagen-3.0-generate-002"

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .gemini_2_flash: return "Gemini 2.0 Flash (Exp)"
        case .imagen_3: return "Imagen 3"
        }
    }

    var endpointPath: String {
        switch self {
        case .gemini_2_flash: return "/v1beta/models/\(self.rawValue):generateContent"
        case .imagen_3: return "/v1beta/models/\(self.rawValue):predict" // Changed from generateImage
        }
    }
}

// MARK: - 1. Data Models (Codable)

// --- Gemini 2.0 Request ---
struct GeminiGenerateContentRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig? // Optional, but needed for modalities

    // Convenience initializer for simple text prompt
    init(prompt: String) {
        self.contents = [GeminiContent(parts: [GeminiPart(text: prompt)])]
        self.generationConfig = GeminiGenerationConfig(responseModalities: ["Text", "Image"]) // Request both
    }
}

struct GeminiContent: Codable {
    let parts: [GeminiPart]
    // Add 'role' if needed for multi-turn chat
}

struct GeminiPart: Codable {
    let text: String?
    // Add inlineData for image input if implementing editing later
    // let inlineData: GeminiInlineData?

    // Initializer for text part
    init(text: String) {
        self.text = text
    }
}

// struct GeminiInlineData: Codable {
//     let mimeType: String
//     let data: String // base64 encoded string
// }

struct GeminiGenerationConfig: Codable {
    let responseModalities: [String]?
}

// --- Gemini 2.0 Response ---
struct GeminiGenerateContentResponse: Codable {
    let candidates: [GeminiCandidate]?
    // Add promptFeedback if needed
}

struct GeminiCandidate: Codable {
    let content: GeminiContentResponse?
    // Add finishReason, index, safetyRatings etc. if needed
}

struct GeminiContentResponse: Codable {
    let parts: [GeminiPartResponse]?
    let role: String?
}

struct GeminiPartResponse: Codable {
    let text: String?
    let inlineData: GeminiInlineDataResponse?

    // Computed property to easily get image data
    var image: UIImage? {
        guard let base64String = inlineData?.data else { return nil }
        guard let data = Data(base64Encoded: base64String) else { return nil }
        return UIImage(data: data)
    }
}

struct GeminiInlineDataResponse: Codable {
    let mimeType: String
    let data: String // base64 encoded image string
}

// --- Imagen 3 Request ---
struct ImagenPredictRequest: Codable {
    let instances: [ImagenInstance]
    let parameters: ImagenParameters?

     // Convenience initializer
    init(prompt: String, sampleCount: Int = 1, aspectRatio: String = "1:1") { // Default to 1 image
        self.instances = [ImagenInstance(prompt: prompt)]
        self.parameters = ImagenParameters(sampleCount: sampleCount, aspectRatio: aspectRatio)
    }
}

struct ImagenInstance: Codable {
    let prompt: String
}

struct ImagenParameters: Codable {
    let sampleCount: Int? // Number of images (1-4)
    let aspectRatio: String? // "1:1", "3:4", "4:3", "9:16", "16:9"
    // Add personGeneration if needed: "DONT_ALLOW", "ALLOW_ADULT" (default)

     init(sampleCount: Int, aspectRatio: String) {
        self.sampleCount = max(1, min(sampleCount, 4)) // Ensure count is between 1 and 4
        self.aspectRatio = aspectRatio
    }
}

// --- Imagen 3 Response ---
// Structure inferred from curl example and common Google predict APIs
struct ImagenPredictResponse: Codable {
    let predictions: [ImagenPrediction]?
    // Might also include metadata like deployedModelId
     let error: APIErrorDetail? // Handle potential errors returned in JSON
}

struct ImagenPrediction: Codable {
    let bytesBase64Encoded: String? // Assuming the key name based on typical AI Platform Prediction
    // Other potential fields: mimeType

    // Computed property to easily get image data
    var image: UIImage? {
        guard let base64String = bytesBase64Encoded else { return nil }
        guard let data = Data(base64Encoded: base64String) else { return nil }
        return UIImage(data: data)
    }
}

// Common Error Detail structure (optional)
struct APIErrorDetail: Codable {
    let code: Int?
    let message: String
    let status: String? // Sometimes included
}


// MARK: - 2. API Service

// Define potential API errors (mostly unchanged, added generic API error)
enum ImageGenAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse(statusCode: Int)
    case decodingError(Error)
    case apiError(message: String) // General error from API JSON
    case apiKeyMissing
    case unsupportedModel // Should not happen with Enum, but good practice

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The API endpoint URL is invalid."
        case .requestFailed(let error): return "Network request failed: \(error.localizedDescription)"
        case .invalidResponse(let statusCode): return "Received invalid response from server (Status Code: \(statusCode))."
        case .decodingError(let error): return "Failed to decode API response: \(error.localizedDescription)"
        case .apiError(let message): return "API error: \(message)"
        case .apiKeyMissing: return "API Key is missing. Please configure it."
        case .unsupportedModel: return "Internal error: Unsupported generation model selected."
        }
    }
}

class ImageGenerationAPIService {
    // Base URL for the API
    private let apiBaseURL = "https://generativelanguage.googleapis.com"

    // !!! REPLACE WITH YOUR ACTUAL GEMINI API KEY !!!
    private let apiKey = "AIzaSyDZbDq0R_YQVEGezGn_IogMRyMv5t3IWHA" // Placeholder

    // Generic function to make the API call
    private func makeRequest<Request: Codable, Response: Decodable>(
        model: GenerationModel,
        requestBody: Request) async throws -> Response
    {
        guard !apiKey.isEmpty && apiKey != "YOUR_GEMINI_API_KEY" else {
            throw ImageGenAPIError.apiKeyMissing
        }

        // Construct URL with API Key as query parameter
        let urlString = apiBaseURL + model.endpointPath + "?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw ImageGenAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Encode request body
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            // Handle potential encoding error during development
             print("Encoding Error: \(error)")
             throw ImageGenAPIError.decodingError(error) // Reusing decodingError for simplicity
        }

        // Perform network request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ImageGenAPIError.invalidResponse(statusCode: 0) // Or a more specific error
            }

            // Debug: Print response body for inspection
             // print("----\nResponse Status: \(httpResponse.statusCode)")
             // print("Response Body: \(String(data: data, encoding: .utf8) ?? "Could not decode body")\n----")


            // Check for non-successful status codes
            guard (200...299).contains(httpResponse.statusCode) else {
                // Try to decode a potential error message included in the response body
                if let errorDetail = try? JSONDecoder().decode(APIErrorDetail.self, from: data) {
                     throw ImageGenAPIError.apiError(message: errorDetail.message)
                } else if let imagenError = try? JSONDecoder().decode(ImagenPredictResponse.self, from: data), let errorDetail = imagenError.error {
                    // Specific check for Imagen error structure
                    throw ImageGenAPIError.apiError(message: errorDetail.message)
                }
                 // Otherwise, throw a generic status code error
                throw ImageGenAPIError.invalidResponse(statusCode: httpResponse.statusCode)
            }

            // Decode the successful response
            do {
                let decodedResponse = try JSONDecoder().decode(Response.self, from: data)
                return decodedResponse
            } catch {
                 print("Decoding Error: \(error)")
                 print("Failed to decode: \(String(data: data, encoding: .utf8) ?? "Invalid UTF-8")")
                 throw ImageGenAPIError.decodingError(error)
            }

        } catch let error as ImageGenAPIError {
             throw error // Re-throw our specific API errors
        } catch let error as URLError {
             throw ImageGenAPIError.requestFailed(error) // Handle URLSession specific errors
        } catch {
            // Catch any other unexpected errors during the request
             throw ImageGenAPIError.requestFailed(error)
        }
    }

    // Specific function for Gemini 2.0
    func generateWithGemini(prompt: String) async throws -> GeminiGenerateContentResponse {
        let requestBody = GeminiGenerateContentRequest(prompt: prompt)
        return try await makeRequest(model: .gemini_2_flash, requestBody: requestBody)
    }

    // Specific function for Imagen 3
    func generateWithImagen(prompt: String, count: Int, aspectRatio: String) async throws -> ImagenPredictResponse {
        let requestBody = ImagenPredictRequest(prompt: prompt, sampleCount: count, aspectRatio: aspectRatio)
        return try await makeRequest(model: .imagen_3, requestBody: requestBody)
    }
}


// MARK: - 3. ViewModel

@MainActor // Ensure UI updates happen on the main thread
class ImageGenerationViewModel: ObservableObject {
    @Published var selectedModel: GenerationModel = .imagen_3 // Default to Imagen 3
    @Published var promptText: String = ""
    @Published var generatedText: String? = nil // For Gemini text output
    @Published var generatedUIImages: [UIImage] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // Imagen 3 Specific Parameters
    @Published var numberOfImages: Int = 1 // Default for Imagen
    @Published var selectedAspectRatio: String = "1:1"
    let aspectRatios = ["1:1", "3:4", "4:3", "9:16", "16:9"]

    private let apiService = ImageGenerationAPIService()

    func generate() {
        guard !promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a prompt."
            return
        }

        isLoading = true
        errorMessage = nil
        generatedUIImages = []
        generatedText = nil

        Task {
            defer { isLoading = false }

            do {
                switch selectedModel {
                case .gemini_2_flash:
                    let response = try await apiService.generateWithGemini(prompt: promptText)
                    processGeminiResponse(response)

                case .imagen_3:
                    let response = try await apiService.generateWithImagen(
                        prompt: promptText,
                        count: numberOfImages,
                        aspectRatio: selectedAspectRatio
                    )
                    processImagenResponse(response)
                }
            } catch let error as ImageGenAPIError {
                errorMessage = error.localizedDescription
                 print("API Error: \(error)")
            } catch {
                errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                 print("Unexpected Error: \(error)")
            }
        }
    }

    private func processGeminiResponse(_ response: GeminiGenerateContentResponse) {
        guard let candidates = response.candidates, let firstCandidate = candidates.first, let content = firstCandidate.content, let parts = content.parts else {
            errorMessage = "Received an empty or invalid response from Gemini."
            return
        }

        var images: [UIImage] = []
        var texts: [String] = []

        for part in parts {
            if let text = part.text {
                texts.append(text)
            }
            if let image = part.image {
                images.append(image)
            }
        }

        generatedUIImages = images
        generatedText = texts.joined(separator: "\n\n") // Join multiple text parts if any
         if images.isEmpty && texts.isEmpty {
              errorMessage = "Gemini did not return text or an image for this prompt."
         }
    }

     private func processImagenResponse(_ response: ImagenPredictResponse) {
        if let error = response.error {
            errorMessage = ImageGenAPIError.apiError(message: error.message).localizedDescription
            return
        }
        
        guard let predictions = response.predictions else {
            errorMessage = "Received an empty or invalid response from Imagen."
            return
        }

        generatedUIImages = predictions.compactMap { $0.image } // Decode base64 to UIImage

        if generatedUIImages.isEmpty && errorMessage == nil {
            errorMessage = "Imagen did not return any images for this prompt."
        }
    }
}

// MARK: - 4. SwiftUI View

struct ImageGeneratorView: View {
    @StateObject private var viewModel = ImageGenerationViewModel()

    // Grid layout for images
    private var columns: [GridItem] {
        // Adjust grid based on aspect ratio for better display (optional enhancement)
        // For simplicity, using 2 columns for now.
         [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Model Selection
                    Picker("Select Model", selection: $viewModel.selectedModel) {
                         ForEach(GenerationModel.allCases) { model in
                            Text(model.displayName).tag(model)
                        }
                    }
                    .pickerStyle(.segmented) // Common iOS style for few options


                    // Input Section
                    VStack(alignment: .leading) {
                        Text("Enter Prompt").font(.headline)
                        TextEditor(text: $viewModel.promptText)
                            .frame(height: 100)
                            .border(Color.gray.opacity(0.5), width: 1)
                            .cornerRadius(4)
                            .font(.body)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                             .overlay( // Placeholder text
                                HStack {
                                    if viewModel.promptText.isEmpty {
                                        Text(viewModel.selectedModel == .imagen_3 ? "Describe image for Imagen 3..." : "Enter prompt for Gemini...")
                                            .foregroundColor(.gray.opacity(0.6))
                                            .padding(.all, 8)
                                            .allowsHitTesting(false)
                                    }
                                    Spacer()
                                }
                                , alignment: .topLeading
                            )
                    }

                     // Imagen 3 Parameters (Conditional)
                    if viewModel.selectedModel == .imagen_3 {
                        VStack(alignment: .leading, spacing: 15) {
                            Divider()
                            Text("Imagen 3 Options").font(.headline)
                            Stepper("Number of Images: \(viewModel.numberOfImages)", value: $viewModel.numberOfImages, in: 1...4)

                            HStack {
                                Text("Aspect Ratio:")
                                Spacer()
                                Picker("Aspect Ratio", selection: $viewModel.selectedAspectRatio) {
                                    ForEach(viewModel.aspectRatios, id: \.self) { ratio in
                                        Text(ratio).tag(ratio)
                                    }
                                }
                                .pickerStyle(.menu) // Compact style
                            }
                             Divider()
                        }
                         .transition(.opacity.combined(with: .move(edge: .top))) // Add animation
                    }


                    // Action Button
                    Button {
                        hideKeyboard()
                        viewModel.generate()
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "sparkles")
                                Text("Generate")
                            }
                            Spacer()
                        }
                        .padding()
                        .background(viewModel.isLoading ? Color.gray : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: viewModel.isLoading ? 0 : 3)
                    }
                    .disabled(viewModel.isLoading || viewModel.promptText.trimmingCharacters(in: .whitespaces).isEmpty)
                    .animation(.default, value: viewModel.isLoading) // Animate button state change


                    // Error Display
                    if let errorMessage = viewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(errorMessage)
                        }
                        .foregroundColor(.red)
                        .padding(.vertical, 5)
                    }

                     // --- Results Section ---
                    // Display Gemini Text Output (if any)
                    if let textOutput = viewModel.generatedText, !textOutput.isEmpty {
                         VStack(alignment: .leading) {
                             Text("Gemini Text Response:").font(.headline)
                             Text(textOutput)
                                 .font(.body)
                                 .padding(.vertical, 5)
                         }
                         .padding(.bottom, 10) // Space before images
                    }

                    // Display Generated Images
                     if !viewModel.generatedUIImages.isEmpty {
                         Text("Generated Images (\(viewModel.generatedUIImages.count))")
                             .font(.headline)

                        LazyVGrid(columns: columns, spacing: 10) {
                             ForEach(viewModel.generatedUIImages.indices, id: \.self) { index in
                                 Image(uiImage: viewModel.generatedUIImages[index])
                                    .resizable()
                                    .scaledToFit()
                                    .background(Color.gray.opacity(0.1)) // Background for padding
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                                    .contextMenu { // Allow saving image
                                        Button {
                                            saveImage(viewModel.generatedUIImages[index])
                                        } label: {
                                            Label("Save Image", systemImage: "square.and.arrow.down")
                                        }
                                    }

                            }
                        }
                    } else if !viewModel.isLoading && viewModel.errorMessage == nil && viewModel.generatedText == nil {
                         // Initial state or no results
                         Text("Generated content will appear here.")
                             .font(.caption)
                             .foregroundColor(.secondary)
                             .frame(maxWidth: .infinity, alignment: .center)
                             .padding(.top)
                    }

                }
                .padding()
                 .animation(.default, value: viewModel.selectedModel) // Animate layout changes
            }
            .navigationTitle("Image Generator")
            .navigationBarTitleDisplayMode(.inline)
             .onTapGesture { hideKeyboard() }
        }
    }

    // Helper to dismiss keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // Helper to save UIImage to Photo Library
     private func saveImage(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        // Add feedback to user, e.g., a toast message
    }
}


// MARK: - Preview

struct ImageGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        ImageGeneratorView()
    }
}
