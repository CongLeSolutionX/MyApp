////
////  WebSearchWorkflowDemoView.swift
////  MyApp
////
////  Created by Cong Le on 4/13/25.
////
//
//import Foundation
//
//// MARK: - Request Body Model
//struct OpenAIRequest: Codable {
//    let model: String
//    let tools: [Tool]
//    let input: String
//
//    struct Tool: Codable {
//        let type: String
//    }
//}
//
//// MARK: - Response Body Models (Partial)
//// We only decode the parts we absolutely need
//struct OpenAIResponse: Codable {
//    let output: [OutputItem]? // Make optional to handle potential variations/errors
//    let error: OpenAIError? // Capture potential API errors
//}
//
//struct OutputItem: Codable {
//    let id: String
//    let type: String
//    let status: String
//    let content: [ContentItem]? // Optional if type isn't "message"
//    let role: String?           // Optional if type isn't "message"
//}
//
//struct ContentItem: Codable {
//    let type: String
//    let text: String? // Make optional, though we expect it for "output_text"
//    // We are ignoring annotations for simplicity in this example
//}
//
//struct OpenAIError: Codable {
//    let code: String?
//    let message: String
//    let param: String?
//    let type: String?
//}
//
//import Foundation
//
//class OpenAIService {
//
//    // --- IMPORTANT: API KEY HANDLING ---
//    // NEVER embed your API key directly in code for production apps.
//    // Use secure methods like:
//    // 1. Reading from Info.plist (add a key like OPENAI_API_KEY)
//    // 2. Using .xcconfig files
//    // 3. Fetching from a secure backend/keychain
//    // For this example, we'll read from Info.plist (You MUST add the key there)
//    private var apiKey: String {
//        guard let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String, !key.isEmpty else {
//            fatalError("Add your OPENAI_API_KEY to Info.plist") // Crash if not set
//        }
//        // Basic check - replace "YOUR_API_KEY_HERE" if using a placeholder in Info.plist
//        if key == "YOUR_API_KEY_HERE" {
//             fatalError("Replace 'YOUR_API_KEY_HERE' in Info.plist with your actual OpenAI API Key")
//        }
//        return key
//    }
//
//    private let apiURL = URL(string: "https://api.openai.com/v1/responses")!
//
//    func fetchPositiveNews(prompt: String) async throws -> String {
//
//        var request = URLRequest(url: apiURL)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization") // Use fetched API Key
//
//        // Prepare the request body
//        let requestBody = OpenAIRequest(
//            model: "gpt-4o", // Or the desired model
//            tools: [OpenAIRequest.Tool(type: "web_search_preview")],
//            input: prompt
//        )
//
//        do {
//            request.httpBody = try JSONEncoder().encode(requestBody)
//        } catch {
//            throw URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request body: \(error.localizedDescription)"])
//        }
//
//        // Perform the network request
//        let (data, response) = try await URLSession.shared.data(for: request)
//
//        // Check HTTP status code
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server."])
//        }
//
//        guard (200...299).contains(httpResponse.statusCode) else {
//            // Try to decode OpenAI's error structure if status code is bad
//            if let apiError = try? JSONDecoder().decode(OpenAIResponse.self, from: data).error {
//                 throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "API Error: \(apiError.message) (Code: \(apiError.code ?? "N/A"))"])
//            } else {
//                 throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Server returned status code \(httpResponse.statusCode)."])
//            }
//        }
//
//        // Decode the successful response
//        do {
//            let decodedResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
//
//            // Find the message output
//            guard let messageOutput = decodedResponse.output?.first(where: { $0.type == "message" }),
//                  let content = messageOutput.content?.first(where: { $0.type == "output_text" }),
//                  let text = content.text else {
//                throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Could not find expected text content in the API response."])
//            }
//            return text
//
//        } catch {
//            // More specific decoding error
//             throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(error.localizedDescription). Raw data: \(String(data: data, encoding: .utf8) ?? "Invalid UTF-8 Data")"])
//        }
//    }
//}
//
//
//import SwiftUI
//
//struct WebSearchWorkflowDemoView: View {
//    @State private var prompt: String = "what was a positive news story from today?" // Default prompt
//    @State private var responseText: String? = nil
//    @State private var isLoading: Bool = false
//    @State private var errorMessage: String? = nil
//
//    private let apiService = OpenAIService()
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 15) {
//                // Input Area
//                HStack {
//                    TextField("Enter your prompt", text: $prompt, axis: .vertical)
//                        .textFieldStyle(.roundedBorder)
//                        .lineLimit(1...5) // Allow multi-line input
//
//                    Button {
//                        fetchResponse()
//                    } label: {
//                        Image(systemName: "paperplane.fill")
//                            .font(.headline)
//                            .frame(maxHeight: .infinity) // Make button height match TextField
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .disabled(isLoading || prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
//                }
//                .fixedSize(horizontal: false, vertical: true) // Prevent HStack from expanding vertically too much
//
//                Spacer() // Push content to top and response area up
//
//                // Response Area
//                if isLoading {
//                    ProgressView("Fetching news...")
//                        .padding()
//                    Spacer() // Keep loading indicator centered
//                } else if let error = errorMessage {
//                    VStack {
//                         Image(systemName: "exclamationmark.triangle.fill")
//                             .foregroundColor(.red)
//                             .font(.largeTitle)
//                             .padding(.bottom, 5)
//                         Text("Error")
//                            .font(.headline)
//                         Text(error)
//                             .font(.callout)
//                             .foregroundColor(.secondary)
//                             .multilineTextAlignment(.center)
//                             .padding(.horizontal)
//                    }
//                    Spacer() // Keep error centered
//                } else if let text = responseText {
//                     // Results Card
//                     ScrollView { // Make card scrollable if content is long
//                           VStack(alignment: .leading, spacing: 10) {
//                               Text("Positive News") // Card Title
//                                   .font(.title2)
//                                   .fontWeight(.semibold)
//
//                               Divider()
//
//                               // Display the response text. SwiftUI has basic Markdown support.
//                               Text(.init(text)) // Use AttributedString init for Markdown
//                                      .font(.body)
//                                      .lineSpacing(5) // Improve readability
//
//                           }
//                           .padding() // Inner padding for card content
//                     }
//                     .background(Color(.secondarySystemBackground)) // Card background color
//                     .cornerRadius(12) // Rounded corners for the card
//                     .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2) // Subtle shadow
//                     .padding(.horizontal) // Outer padding for the card
//                } else {
//                    // Placeholder when nothing is loaded yet
//                    VStack {
//                        Image(systemName: "sparkles")
//                            .font(.largeTitle)
//                            .foregroundColor(.secondary)
//                        Text("Enter a prompt and tap send to get positive news!")
//                            .foregroundColor(.secondary)
//                            .multilineTextAlignment(.center)
//                    }
//                    Spacer()
//                }
//
//                 Spacer()// Push response area up if content is short
//
//            }
//            .padding() // Overall padding for the VStack content
//            .navigationTitle("Good News Bot")
//            .animation(.easeInOut, value: isLoading) // Animate transitions
//            .animation(.easeInOut, value: responseText)
//            .animation(.easeInOut, value: errorMessage)
//        }
//    }
//
//    // Function to trigger the API call
//    private func fetchResponse() {
//        isLoading = true
//        errorMessage = nil
//        responseText = nil // Clear previous response
//
//        Task { // Perform async work in a Task
//            do {
//                let result = try await apiService.fetchPositiveNews(prompt: prompt)
//                responseText = result
//            } catch {
//                // Update error message on the main thread
//                errorMessage = error.localizedDescription
//             }
//            // Ensure loading is set to false regardless of success/failure
//             isLoading = false
//        }
//    }
//}
//
//// MARK: - Preview
//// Add a preview provider for easy testing in Xcode
//#Preview {
//    WebSearchWorkflowDemoView()
//}
