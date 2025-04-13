////
////  V5.swift
////  MyApp
////
////  Created by Cong Le on 4/13/25.
////
//
//import SwiftUI
//import Combine // Needed for OpenURLAction environment key
//
//// MARK: - Data Models (Updated for API changes)
//
//// Represents a single message in the chat interface
//struct ChatItem: Identifiable, Hashable {
//    let id = UUID()
//    let sender: Sender
//    var text: String
//    let timestamp: Date = Date()
//    var state: MessageState = .sent // Tracks the state of agent messages
//    var annotations: [AnnotationItem]? = nil // Store citation annotations
//}
//
//// Indicates who sent the message
//enum Sender {
//    case user
//    case agent
//}
//
//// Represents the state of an agent's message during fetch
//enum MessageState {
//    case sending // Waiting for API response
//    case sent   // Normal successful message
//    case error  // An error occurred fetching this message
//}
//
//// --- Models for API Interaction (Updated based on Documentation) ---
//
//// Represents the top-level request body sent to the OpenAI API
//struct OpenAIRequest: Codable {
//    let model: String
//    let tools: [Tool]
//    let input: String
//    // Optional: tool_choice can be added here if needed
//}
//
//// Represents a tool configuration within the request
//struct Tool: Codable {
//    let type: String // e.g., "web_search_preview"
//    var user_location: UserLocation? = nil // Optional user location
//    var search_context_size: SearchContextSize? = nil // Optional context size
//
//    // Use CodingKeys to match JSON key names
//    enum CodingKeys: String, CodingKey {
//        case type
//        case user_location // Use snake_case for JSON
//        case search_context_size // Use snake_case for JSON
//    }
//}
//
//// Represents the user location details
//struct UserLocation: Codable {
//    var type: String = "approximate" // Fixed type as per docs
//    var country: String? = nil // ISO country code (e.g., "GB", "US")
//    var city: String? = nil // Free text city name (e.g., "London")
//    var region: String? = nil // Free text region name (e.g., "London", "Minnesota")
//    var timezone: String? = nil // IANA timezone (e.g., "America/Chicago") - Added based on docs text
//}
//
//// Enum for type-safe search context size selection
//enum SearchContextSize: String, Codable {
//    case high, medium, low
//}
//
//// Represents the top-level response received from the OpenAI API
//struct OpenAIResponse: Codable {
//    // API now returns an array of output items
//    let output: [OutputItem]?
//    let error: OpenAIError? // Existing error structure
//}
//
//// Represents a single item within the 'output' array of the response
//struct OutputItem: Codable {
//    let id: String?
//    let type: String // e.g., "web_search_call", "message"
//    let status: String? // e.g., "completed"
//    let content: [ContentItem]? // Only present for "message" type
//    let role: String? // e.g., "assistant" for "message" type
//}
//
//// Represents an item within the 'content' array of a "message" OutputItem
//struct ContentItem: Codable {
//    let type: String // e.g., "output_text"
//    let text: String?
//    let annotations: [AnnotationItem]? // Array of citation annotations
//}
//
//// Represents a single annotation, specifically for URL citations
//struct AnnotationItem: Codable, Identifiable, Hashable {
//    // Use optional for ID as it's not explicitly in the JSON schema but needed for SwiftUI lists
//    var id = UUID()
//    let type: String // e.g., "url_citation"
//    let startIndex: Int // API uses snake_case
//    let endIndex: Int   // API uses snake_case
//    let url: String?
//    let title: String?
//
//    // Map Swift camelCase to JSON snake_case
//    enum CodingKeys: String, CodingKey {
//        case type
//        case startIndex = "start_index"
//        case endIndex = "end_index"
//        case url
//        case title
//        // id is not part of the JSON, so it's excluded here
//    }
//}
//
//// Represents an error object within the API response
//struct OpenAIError: Codable {
//    let code: String?
//    let message: String
//    let param: String?
//    let type: String?
//}
//
//// --- Struct to hold the combined result from the service ---
//struct AgentResponse {
//    let text: String
//    let annotations: [AnnotationItem]?
//}
//// --- End API Interaction Models ---
//
//// MARK: - API Service (Updated for new features)
//
//class OpenAIService {
//    // --- IMPORTANT: API KEY HANDLING (Same as before) ---
//    private var apiKey: String {
//        guard let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String,
//              !key.isEmpty, key != "YOUR_API_KEY_HERE" else {
//            fatalError(/* ... API Key error message ... */) // Keep the detailed message
//        }
//        return key
//    }
//    private let apiURL = URL(string: "https://api.openai.com/v1/responses")!
//
//    /// Fetches a response using the OpenAI Responses API with web search.
//    /// - Parameters:
//    ///   - prompt: The user's input text.
//    ///   - userLocation: Optional user location for refined search results.
//    ///   - contextSize: Optional search context size preference.
//    /// - Returns: An `AgentResponse` containing the text and annotations.
//    /// - Throws: An error if the request or parsing fails.
//    func fetchWebSearchResponse(
//        prompt: String,
//        userLocation: UserLocation? = nil, // Add location parameter
//        contextSize: SearchContextSize? = nil  // Add context size parameter
//    ) async throws -> AgentResponse { // Return the new struct
//        print("🤖 OpenAIService: Starting live fetch for prompt: \(prompt)")
//        print("  - Location: \(userLocation != nil ? "\(userLocation!)" : "Not specified")")
//        print("  - Context Size: \(contextSize != nil ? "\(contextSize!)" : "Default (medium)")")
//
//        var request = URLRequest(url: apiURL)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//        // Docs mention Beta header, keep it for now unless testing shows otherwise
//        request.setValue("OpenAI-Beta", forHTTPHeaderField: "OpenAI-Beta")
//        request.setValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")
//
//        // Construct the tool with optional location and context size
//        let webSearchTool = Tool(
//            type: "web_search_preview", // Use the documented tool type
//            user_location: userLocation,
//            search_context_size: contextSize
//        )
//
//        let requestBody = OpenAIRequest(
//            model: "gpt-4o", // Use the model specified in docs
//            tools: [webSearchTool], // Pass the configured tool
//            input: prompt
//        )
//
//        do {
//            // Encode using JSONEncoder with snake_case strategy for optional keys
//            let encoder = JSONEncoder()
//            encoder.keyEncodingStrategy = .convertToSnakeCase // Correctly encodes optional keys
//            request.httpBody = try encoder.encode(requestBody)
//
//            // Optional: Log request body for debugging
//             if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
//                  print("📬 Request Body JSON: \(bodyString)")
//             }
//        } catch {
//            print("❌ [OpenAIService] Failed to encode request body: \(error)")
//            throw URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: "Encoding failed: \(error.localizedDescription)"])
//        }
//
//        // --- Network Call and Response Handling (Mostly same as before) ---
//        let (data, response) = try await URLSession.shared.data(for: request)
//
//        guard let httpResponse = response as? HTTPURLResponse else {
//            print("❌ [OpenAIService] Invalid response type.")
//            throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server."])
//        }
//
//        print("🚦 [OpenAIService] HTTP Status Code: \(httpResponse.statusCode)")
//        // Optional: Log raw response data for debugging
//         if let responseString = String(data: data, encoding: .utf8) {
//              print("📄 Raw Response Data:\n\(responseString)")
//         }
//
//        guard (200...299).contains(httpResponse.statusCode) else {
//            print("❌ [OpenAIService] Server error: \(httpResponse.statusCode)")
//            // Try to decode API error message using a decoder set for snake_case
//             let decoder = JSONDecoder()
//             decoder.keyDecodingStrategy = .convertFromSnakeCase
//            if let apiError = try? decoder.decode(OpenAIResponse.self, from: data).error {
//                print("💀 [OpenAIService] API Error Details: \(apiError.message)")
//                throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: apiError.message])
//            } else {
//                 throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Server error \(httpResponse.statusCode). Unable to parse error details."])
//            }
//        }
//
//        // --- Decode the Successful Response (Updated Logic) ---
//        do {
//             // Use a decoder set for snake_case to correctly parse API responses
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            let decodedResponse = try decoder.decode(OpenAIResponse.self, from: data)
//            print("✅ [OpenAIService] Successfully decoded response.")
//
//            // Find the 'message' output item containing the assistant's reply
//            guard let messageOutput = decodedResponse.output?.first(where: { $0.type == "message" && $0.role == "assistant" }) else {
//                print("❌ [OpenAIService] Could not find 'message' output item from assistant.")
//                 // Optional log if response structure is unexpected
//                 if let outputDump = decodedResponse.output { print("🔍 Output structure dump: \(outputDump)") }
//                throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Could not find assistant message in response."])
//            }
//
//            // Find the 'output_text' content within the message
//            guard let textContent = messageOutput.content?.first(where: { $0.type == "output_text" }) else {
//                print("❌ [OpenAIService] Could not find 'output_text' within the message content.")
//                 if let contentDump = messageOutput.content { print("🔍 Content structure dump: \(contentDump)") }
//                throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Could not find text content in message."])
//            }
//
//            guard let text = textContent.text else {
//                print("❌ [OpenAIService] Text content is missing in 'output_text'.")
//                throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Text content missing."])
//            }
//
//            // Extract annotations (might be nil or empty)
//            let annotations = textContent.annotations // Directly use the decoded annotations
//            print("📰 [OpenAIService] Fetched Text: \(text.prefix(80))...")
//             if let ann = annotations, !ann.isEmpty {
//                 print("🔗 [OpenAIService] Found \(ann.count) annotations.")
//             } else {
//                 print("🔗 [OpenAIService] No annotations found.")
//             }
//
//            // Return the combined result
//            return AgentResponse(text: text, annotations: annotations)
//
//        } catch let decodingError as DecodingError {
//            print("❌ [OpenAIService] Failed to decode response: \(decodingError)")
//            // Keep the detailed decoding error logging from previous version
//            var errorDesc = "Decoding failed: "
//            switch decodingError {
//            case .typeMismatch(_, let context): errorDesc += "Type mismatch at \(context.codingPathString) - \(context.debugDescription)"
//            case .valueNotFound(_, let context): errorDesc += "Value not found at \(context.codingPathString) - \(context.debugDescription)"
//            case .keyNotFound(let key, let context): errorDesc += "Key '\(key.stringValue)' not found at \(context.codingPathString) - \(context.debugDescription)"
//            case .dataCorrupted(let context): errorDesc += "Data corrupted at \(context.codingPathString) - \(context.debugDescription)"
//            @unknown default: errorDesc += "Unknown decoding error."
//            }
//            print("🔍 Decoding Error Details: \(errorDesc)")
//            throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: errorDesc])
//        } catch {
//            print("❌ [OpenAIService] Unexpected error during decoding or processing: \(error)")
//            throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Response processing failed: \(error.localizedDescription)."])
//        }
//    }
//}
//// Helper to get coding path string for errors
//extension DecodingError.Context {
//    var codingPathString: String {
//        codingPath.map { $0.stringValue }.joined(separator: ".")
//    }
//}
//
//// MARK: - Fetching Service Protocol (Updated Return Type)
//protocol ChatFetchingService {
//    /// Fetches a response for a given user prompt.
//    /// - Parameter prompt: The user's input text.
//    /// - Returns: An `AgentResponse` containing text and optional annotations.
//    /// - Throws: An error if fetching fails.
//    func fetchResponse(for prompt: String) async throws -> AgentResponse
//}
//
//// MARK: - Live API Chat Service (Updated)
//class LiveChatService: ChatFetchingService {
//    private let apiService = OpenAIService()
//
//    // --- Configurable Options ---
//    // These could be exposed via UI settings later
//    var userLocation: UserLocation? = nil // Example: UserLocation(country: "US", city: "New York", region: "NY")
//    var contextSize: SearchContextSize? = .medium // Or .low, .high
//
//    func fetchResponse(for prompt: String) async throws -> AgentResponse {
//        print("📡 LiveChatService: Fetching real response for prompt: \(prompt)")
//        // Pass the prompt and configured options to the API service
//        return try await apiService.fetchWebSearchResponse(
//            prompt: prompt,
//            userLocation: userLocation,
//            contextSize: contextSize
//        )
//    }
//}
//
//// MARK: - Mock Chat Service (Updated)
//class MockChatService: ChatFetchingService {
//    enum MockError: Error, LocalizedError { /* ... Same as before ... */ }
//
//    // Updated mock responses to include optional annotations
//    private let mockResponses: [String: Result<AgentResponse, MockError>] = [
//        "hello": .success(AgentResponse(text: "Hi there from Mock! How can I provide some positive news?", annotations: nil)),
//        "tech": .success(AgentResponse(text: "Mock Data: Advancements [1] in battery recycling methods show promising environmental benefits!",
//                                       annotations: [
//                                          AnnotationItem(type: "url_citation", startIndex: 23, endIndex: 26, url: "https://example.com/battery-news", title: "Battery Tech Advances")
//                                       ])),
//        "science": .success(AgentResponse(text: "Mock Data: Researchers discovered a new species of bioluminescent fungi in the Amazon [1].",
//                                          annotations: [
//                                             AnnotationItem(type: "url_citation", startIndex: 88, endIndex: 91, url: "https://example.com/fungi-discovery", title: "New Fungi Found")
//                                          ])),
//         "no citation": .success(AgentResponse(text: "Mock Data: This is a mock response deliberately without any citations.", annotations: nil)),
//        //"error": .failure(.simulatedError("Oops! Simulated connection error. Please try again.")),
//        "long": .success(AgentResponse(text: "Mock Data: This is a deliberately longer mock response [1] designed to test the UI's ability to handle multi-line text bubbles effectively. It simulates a scenario where the AI provides a more detailed explanation or narrative, ensuring that text wrapping, layout constraints, and scrolling behave as expected within the chat interface [2].",
//                                       annotations: [
//                                            AnnotationItem(type: "url_citation", startIndex: 45, endIndex: 48, url: "https://example.com/long-text-test", title: "UI Testing Article"),
//                                            AnnotationItem(type: "url_citation", startIndex: 298, endIndex: 301, url: "https://example.com/chat-interface-design", title: "Chat Design Principles")
//                                       ]))
//    ]
//
//    private let defaultMockResponse = AgentResponse(text: "Mock Data: I couldn't find a specific mock for that. Try 'tech', 'science', 'no citation', or 'error'.", annotations: nil)
//    private let simulatedDelay: Duration = .seconds(Int.random(in: 500...1500)) / 1000.0
//    //Duration = .milliseconds(500...1500)
//
//    func fetchResponse(for prompt: String) async throws -> AgentResponse {
//        print("🎭 MockChatService: Generating mock response for prompt: \(prompt)")
//        try await Task.sleep(for: simulatedDelay)
//
//        let lowercasedPrompt = prompt.lowercased()
//        var foundResult: Result<AgentResponse, MockError>? = nil
//
//        for (key, result) in mockResponses {
//            if lowercasedPrompt.contains(key) {
//                foundResult = result
//                break
//            }
//        }
//
//        let resultToUse = foundResult ?? .success(defaultMockResponse)
//        print("🎭 MockChatService: Returning result with \(resultToUse.successValue?.annotations?.count ?? 0) annotations.")
//
//        switch resultToUse {
//        case .success(let response):
//            return response
//        case .failure(let error):
//            throw error
//        }
//    }
//}
//// Helper to access success value easily (optional)
//extension Result {
//    var successValue: Success? {
//        guard case .success(let value) = self else { return nil }
//        return value
//    }
//}
//
//// MARK: - SwiftUI View (ContentView - Updated)
//struct WebSearchWorkflowDemoView: View {
//    @State private var currentPrompt: String = ""
//    @State private var chatItems: [ChatItem]
//    @State private var isFetching: Bool = false
//    @FocusState private var promptFieldIsFocused: Bool
//
//    // --- Optional Settings State Variables ---
//    // You could bind these to UI controls (e.g., in a settings sheet)
//    @State private var userCountry: String = "" // Example: "GB"
//    @State private var userCity: String = ""   // Example: "London"
//    @State private var userRegion: String = ""  // Example: "London"
//    @State private var searchContext: SearchContextSize = .medium
//
//    // --- Dependency Injection ---
//    private let chatService: ChatFetchingService
//
//    init(chatService: ChatFetchingService) {
//        self.chatService = chatService
//        let initialMessageText = chatService is MockChatService ?
//            "Hello! (Mock Mode)" :
//            "Hello! Ask me for positive news."
//        _chatItems = State(initialValue: [ChatItem(sender: .agent, text: initialMessageText)])
//        print("✅ ContentView initialized with service: \(type(of: chatService))")
//
//        // If it's LiveChatService, configure its options from initial state
//        if let liveService = chatService as? LiveChatService {
//            configureLiveService(liveService)
//            print("🔧 Configured LiveChatService options.")
//        }
//    }
//    // --- End Dependency Injection ---
//
//    // MARK: - Body
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                chatScrollView
//                Divider()
//                inputArea
//            }
//            .navigationTitle("Good News Agent")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItemGroup(placement: .navigationBarLeading) {
//                    // Mode Indicator
//                    Text(chatService is MockChatService ? "Mock Mode" : "Live Mode")
//                         .font(.caption.weight(.semibold))
//                         .padding(.horizontal, 8)
//                         .padding(.vertical, 4)
//                         .background(chatService is MockChatService ? Color.orange.opacity(0.8) : Color.green.opacity(0.8))
//                        .foregroundColor(.white)
//                        .clipShape(Capsule())
//                        // Add Settings button only for Live Mode (or always if desired)
//                        if chatService is LiveChatService {
//                             settingsButton
//                         }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    clearChatButton
//                }
//            }
//            .onTapGesture { promptFieldIsFocused = false }
//             // Update LiveService options when state changes
//             .onChange(of: userCountry) { configureLiveService() }
//             .onChange(of: userCity) { configureLiveService() }
//             .onChange(of: userRegion) { configureLiveService() }
//             .onChange(of: searchContext) { configureLiveService() }
//        }
//    }
//
//    // MARK: - Subviews (chatScrollView, inputArea remain mostly the same)
//    private var chatScrollView: some View {
//        ScrollViewReader { proxy in /* ... Same structure as before ... */
//             ScrollView {
//                 LazyVStack(spacing: 15) {
//                     ForEach(chatItems) { item in
//                         // Pass the retry action to the view
//                         ChatItemView(chatItem: item) { retryFetch(failedItem: item) }
//                             .id(item.id)
//                     }
//                 }
//                 .padding(.horizontal)
//                 .padding(.top, 10)
//                 .padding(.bottom, 5)
//             }
//             .onChange(of: chatItems) { scrollToBottom(proxy: proxy) }
//             .onAppear { scrollToBottom(proxy: proxy, animated: false) }
//        }
//    }
//
//    private var inputArea: some View { /* ... Same structure as before ... */
//        HStack(alignment: .bottom, spacing: 8) {
//            TextField("Ask about positive news...", text: $currentPrompt, axis: .vertical)
//                .textFieldStyle(.plain)
//                .padding(.horizontal, 12)
//                .padding(.vertical, 10)
//                .background(Color(.systemGray6))
//                .clipShape(Capsule())
//                .focused($promptFieldIsFocused)
//                .lineLimit(1...5)
//                .onSubmit(sendMessage)
//
//            Button { sendMessage() } label: {
//                Image(systemName: "arrow.up.circle.fill")
//                    .font(.title)
//                    .symbolRenderingMode(.multicolor)
//            }
//            .disabled(currentPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isFetching)
//            .animation(.easeInOut, value: isFetching || currentPrompt.isEmpty)
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 8)
//        .background(.thinMaterial)
//    }
//
//     // MARK: - Toolbar Buttons
//     private var clearChatButton: some View {
//         Button { clearChat() } label: {
//             Label("Clear Chat", systemImage: "trash")
//         }
//         .tint(.red)
//         .disabled(chatItems.count <= 1 && currentPrompt.isEmpty)
//     }
//
//     private var settingsButton: some View {
//         // Example: Simple Button - Replace with Sheet/Popover for real settings UI
//         Menu {
//             // --- User Location Settings ---
//             Section("User Location (Optional)") {
//                 TextField("Country Code (e.g., US)", text: $userCountry)
//                 TextField("City (e.g., London)", text: $userCity)
//                 TextField("Region (e.g., MN)", text: $userRegion)
//             }
//             // --- Search Context Size ---
//             Section("Search Context Size") {
//                  Picker("Context Size", selection: $searchContext) {
//                      Text("Low").tag(SearchContextSize.low)
//                      Text("Medium").tag(SearchContextSize.medium)
//                      Text("High").tag(SearchContextSize.high)
//                  }
//                 .pickerStyle(.inline) // Use inline style within the menu
//                 .labelsHidden() // Hide the picker label itself
//             }
//         } label: {
//             Label("Settings", systemImage: "gearshape.fill")
//         }
//        .tint(.secondary) // Make settings distinct
//        .disabled(isFetching) // Disable settings while fetching
//     }
//
//    // MARK: - Functions (Updated)
//
//    private func sendMessage() {
//        /* ... guard !textToSend.isEmpty ... */
//        let textToSend = currentPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !textToSend.isEmpty else { return }
//
//        let userMessage = ChatItem(sender: .user, text: textToSend)
//        chatItems.append(userMessage)
//
//        // Add placeholder with NO annotations initially
//        let agentPlaceholderId = UUID()
//        let agentPlaceholder = ChatItem(sender: .agent, text: "", state: .sending, annotations: nil)
//        chatItems.append(agentPlaceholder)
//
//        currentPrompt = ""
//        isFetching = true
//
//        Task {
//             defer { isFetching = false }
//            do {
//                // *** Service call now returns AgentResponse ***
//                let agentResponse = try await chatService.fetchResponse(for: textToSend)
//                // Update placeholder with text, annotations, and success state
//                updateAgentMessage(id: agentPlaceholderId, response: agentResponse, newState: .sent)
//            } catch {
//                print("🚨 Error fetching response: \(error.localizedDescription)")
//                // Update with error message, nil annotations, and error state
//                 updateAgentMessage(id: agentPlaceholderId, response: AgentResponse(text: error.localizedDescription, annotations: nil), newState: .error)
//            }
//        }
//    }
//
//    /// Updates agent message using AgentResponse struct.
//    private func updateAgentMessage(id: UUID, response: AgentResponse, newState: MessageState) {
//         if let index = chatItems.firstIndex(where: { $0.id == id }) {
//               chatItems[index].text = response.text
//               chatItems[index].annotations = response.annotations // Store annotations
//               chatItems[index].state = newState
//               print("🔄 Updated agent message [\(id)] - State: \(newState), Annotations: \(response.annotations?.count ?? 0)")
//           } else {
//               print("⚠️ Could not find agent message with ID \(id) to update.")
//           }
//    }
//
//    private func retryFetch(failedItem: ChatItem) {
//         /* ... Guards from before ... */
//         guard let failedIndex = chatItems.firstIndex(where: { $0.id == failedItem.id }), failedIndex > 0 else {
//            print("⚠️ Retry failed: Could not find failed item \(failedItem.id) or it was the first item.")
//            return
//         }
//         let previousItem = chatItems[failedIndex - 1]
//         guard previousItem.sender == .user else {
//            print("⚠️ Retry failed: Could not find preceding user prompt for item \(failedItem.id).")
//            return
//         }
//         let originalPrompt = previousItem.text
//         print("🔁 Retrying fetch for prompt: \"\(originalPrompt)\" using \(type(of: chatService))")
//
//         // 1. Update the failed item's state back to "sending", clear text/annotations
//         if let index = chatItems.firstIndex(where: { $0.id == failedItem.id }) {
//            chatItems[index].text = ""
//            chatItems[index].annotations = nil
//            chatItems[index].state = .sending
//         }
//         isFetching = true
//
//         Task {
//              defer { isFetching = false }
//             do {
//                 let agentResponse = try await chatService.fetchResponse(for: originalPrompt)
//                 updateAgentMessage(id: failedItem.id, response: agentResponse, newState: .sent)
//             } catch {
//                 print("🚨 Retry Error fetching response: \(error.localizedDescription)")
//                  updateAgentMessage(id: failedItem.id, response: AgentResponse(text: error.localizedDescription, annotations: nil), newState: .error)
//             }
//         }
//    }
//
//    // Helper to configure LiveChatService based on current state
//     private func configureLiveService(_ service: LiveChatService? = nil) {
//         guard let liveService = (service ?? self.chatService) as? LiveChatService else { return }
//
//         // Construct UserLocation only if at least one field is non-empty
//         let location = UserLocation(
//             country: userCountry.isEmpty ? nil : userCountry,
//             city: userCity.isEmpty ? nil : userCity,
//             region: userRegion.isEmpty ? nil : userRegion
//             // timezone could be added here if needed
//         )
//         // Only set userLocation if it's actually configured (not all nil)
//         liveService.userLocation = (location.country == nil && location.city == nil && location.region == nil) ? nil : location
//
//         // Set context size
//         liveService.contextSize = searchContext
//
//        print("🔧 Live Service Config Updated: Location=\(liveService.userLocation != nil), Context=\(liveService.contextSize ?? .medium)")
//     }
//
//    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) { /* ... Same as before ... */
//         guard let lastId = chatItems.last?.id else { return }
//         if animated {
//             withAnimation(.spring()) { proxy.scrollTo(lastId, anchor: .bottom) }
//         } else {
//             proxy.scrollTo(lastId, anchor: .bottom)
//         }
//    }
//
//    private func clearChat() { /* ... Same as before ... */
//         let initialMessageText = chatService is MockChatService ? "Hello! (Mock Mode)" : "Hello! Ask me for positive news."
//         chatItems = [ChatItem(sender: .agent, text: initialMessageText, state: .sent)]
//         currentPrompt = ""
//         isFetching = false
//         promptFieldIsFocused = false
//         print("🧹 Chat cleared.")
//    }
//}
//
//// MARK: - Chat Item View (Updated for Citations)
//struct ChatItemView: View {
//    let chatItem: ChatItem
//    var onRetry: (() -> Void)? = nil
//
//    // Environment variable to handle link taps
//    @Environment(\.openURL) var openURL
//
//    var body: some View { /* ... Same structure as before ... */
//        HStack(alignment: .bottom, spacing: 8) {
//            if chatItem.sender == .agent {
//                agentProfileImage
//                agentMessageContent
//                Spacer()
//            } else {
//                Spacer()
//                userMessageContent
//            }
//        }
//    }
//
//    // Agent profile image (remains the same)
//    private var agentProfileImage: some View { /* ... Same as before ... */
//         Image(systemName: "brain.head.profile")
//             .resizable().scaledToFit().frame(width: 30, height: 30)
//             .clipShape(Circle()).foregroundColor(.accentColor.opacity(0.8))
//             .padding(.bottom, 5)
//    }
//
//    // User message content (remains the same)
//    private var userMessageContent: some View { /* ... Same as before ... */
//         VStack(alignment: .trailing, spacing: 4) {
//             Text(chatItem.text)
//                 .font(.callout).padding(.horizontal, 12).padding(.vertical, 10)
//                 .background(Color.blue).foregroundColor(.white)
//                 .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//                 .frame(minWidth: 40)
//         }
//    }
//
//    // Updated Agent Message Content View
//    private var agentMessageContent: some View {
//        VStack(alignment: .leading, spacing: 4) {
////            Group {
//                switch chatItem.state {
//                case .sending:
//                    HStack(spacing: 8) { ProgressView().controlSize(.small); Text("Finding news...").font(.caption).italic().foregroundColor(.secondary) }
//                case .error:
//                    HStack(alignment: .center) {
//                        Text("Error: \(chatItem.text)").font(.callout).foregroundColor(.red) // Keep error text short
//                        Spacer()
//                        if onRetry != nil {
//                            Button { onRetry?() } label: { Image(systemName: "arrow.clockwise.circle").foregroundColor(.blue) }
//                            .buttonStyle(.plain)
//                        }
//                    }
//                case .sent:
//                    EmptyView()
//                    // Use the attributed string with citations
////                     Text(createAttributedString())
////                         .textSelection(.enabled)
////                        .font(.callout)
////                        // Environment key handles link taps within the Text view
////                        .environment(\.openURL, OpenURLAction { url in
////                            print("🔗 Tapped citation link: \(url)")
////                             // Let the system handle opening standard web URLs
////                             // Could add custom logic here if needed (e.g., open in-app browser)
////                             return .systemAction // Use system default browser
////                        })
//                }
//            }
//            .padding(.horizontal, 12)
//            .padding(.vertical, 10)
//            .background(Color(.systemGray5))
//            .foregroundColor(.primary)
//            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//            .frame(minWidth: 40)
//            .animation(.easeInOut, value: chatItem.state)
//        }
//    }
//
//     // --- Helper Function to Create AttributedString with Citations ---
////     private func createAttributedString() -> AttributedString {
////         guard !chatItem.text.isEmpty else { return AttributedString("") }
////
////         var attributedString = AttributedString(chatItem.text)
////
////         // Ensure annotations are sorted by start index for correct range application
////         let sortedAnnotations = chatItem.annotations?.sorted { $0.startIndex < $1.startIndex } ?? []
////
////         // Track offset adjustments due to potential multi-byte characters (like emojis)
////         // If the API guarantees indices based on UTF-16, this might be simpler.
////         // For robustness, we'll iterate based on character counts matching indices.
////         var currentIndexInString = chatItem.text.startIndex
////         var charCount = 0
////
////         for annotation in sortedAnnotations where annotation.type == "url_citation" {
////            guard let urlString = annotation.url, let url = URL(string: urlString) else { continue }
////
////             // Find the start index in the AttributedString
////             guard let rangeStartIndex = attributedString.index(
////                 attributedString.startIndex,
////                 offsetByCharacters: annotation.startIndex
//////                 limitedBy: attributedString.endIndex
////             ) else {
////                 print("⚠️ Could not find start index \(annotation.startIndex) for citation.")
////                 continue
////             }
////
////            // Find the end index in the AttributedString
////            guard let rangeEndIndex = attributedString.index(
////                rangeStartIndex,
////                offsetByCharacters: annotation.endIndex - annotation.startIndex
//////                limitedBy: attributedString.endIndex
////             ) else {
////                 print("⚠️ Could not find end index \(annotation.endIndex) for citation.")
////                 continue
////             }
////
////             let range = rangeStartIndex..<rangeEndIndex
////
////              // Apply link attribute
////             attributedString[range].link = url
////             // Apply visual styling for the link
////             attributedString[range].foregroundColor = .blue // Style links
////             attributedString[range].underlineStyle = .single // Add underline
////
////             // Optional: Add tooltip using title (might not be standard in Text)
////              // attributedString[range].accessibilityLabel = annotation.title ?? "Citation Link"
////         }
////
////         return attributedString
////     }
////}
//// Helper extension for AttributedString index finding by character offset
//// Note: This assumes API indices are character-based. Adjust if UTF-16 based.
////extension AttributedString {
////    func index(_ base: AttributedString.Index, offsetByCharacters count: Int, limitedBy limit: AttributedString.Index) -> AttributedString.Index? {
////        var currentIndex = base
////        for _ in 0..<count {
////            guard let nextIndex = self.index(currentIndex, C, afterCharacter: T##Foundation.AttributedString.<>.CharacterView.Index) else { return nil } // Ensure we don't go past the end
////             currentIndex = nextIndex
////             if currentIndex >= limit { return nil } // Check limit
////        }
////        return currentIndex
////    }
////}
//
//// MARK: - Main App Structure (Same as before - controls Mock/Live)
//@main
//struct GoodNewsApp: App {
//    // --- Central Control Point: Switch Between Mock and Live Data ---
//    private let useMockData = true // <--- TOGGLE HERE FOR LIVE/MOCK ---
//
//    private var chatService: ChatFetchingService {
//        if useMockData {
//            print("🚀 Using MockChatService")
//            return MockChatService()
//        } else {
//            print("⚡️ Using LiveChatService (Ensure API Key is valid!)")
//            return LiveChatService()
//        }
//    }
//
//    var body: some Scene {
//        WindowGroup {
//            WebSearchWorkflowDemoView(chatService: chatService)
//        }
//    }
//}
//
//// MARK: - SwiftUI Preview Provider (Uses Mock)
//#Preview {
//    // Preview always uses Mock Service
//    WebSearchWorkflowDemoView(chatService: MockChatService())
//}
