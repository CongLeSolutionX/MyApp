//
//  WebSearchWorkflowDemoView_V4.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//
import SwiftUI

// MARK: - Data Models

// Represents a single message in the chat interface
struct ChatItem: Identifiable, Hashable {
    let id = UUID()
    let sender: Sender
    var text: String
    let timestamp: Date = Date()
    var state: MessageState = .sent // Tracks the state of agent messages
}

// Indicates who sent the message
enum Sender {
    case user
    case agent
}

// Represents the state of an agent's message during fetch
enum MessageState {
    case sending // Waiting for API response
    case sent   // Normal successful message
    case error  // An error occurred fetching this message
}

// --- Models for API Interaction ---
struct OpenAIRequest: Codable {
    let model: String
    let tools: [Tool]
    let input: String
    struct Tool: Codable { let type: String }
}

struct OpenAIResponse: Codable {
    let output: [OutputItem]?
    let error: OpenAIError?
}

struct OutputItem: Codable {
    let id: String?, type: String, status: String?, content: [ContentItem]?, role: String?
}

struct ContentItem: Codable {
    let type: String, text: String?
}

struct OpenAIError: Codable {
    let code: String?, message: String, param: String?, type: String?
}
// --- End API Interaction Models ---

// MARK: - API Service (Actual Live Implementation Detail)

class OpenAIService {
    // --- IMPORTANT: API KEY HANDLING ---
    private var apiKey: String {
        // Ensure you have added "OPENAI_API_KEY" = "YOUR_API_KEY_HERE" to your Info.plist
        // and replaced "YOUR_API_KEY_HERE" with your actual key.
        guard let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String,
              !key.isEmpty, key != "YOUR_API_KEY_HERE" else {
            fatalError("""
            --------------------------------------------------------------------
            ERROR: OpenAI API Key Not Found or Not Set!

            Please add your API key to your project's Info.plist file:
            1. Open Info.plist
            2. Add a new row (Key: 'OPENAI_API_KEY', Type: String, Value: 'YOUR_ACTUAL_API_KEY')
            3. Replace 'YOUR_ACTUAL_API_KEY' with your key from OpenAI.
            --------------------------------------------------------------------
            """)
        }
        return key
    }

    private let apiURL = URL(string: "https://api.openai.com/v1/responses")!

    func fetchPositiveNews(prompt: String) async throws -> String {
        print("🤖 OpenAIService: Starting live fetch for prompt: \(prompt)")
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("OpenAI-Beta", forHTTPHeaderField: "OpenAI-Beta")
        request.setValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")

        let requestBody = OpenAIRequest(
            model: "gpt-4o",
            tools: [OpenAIRequest.Tool(type: "web_search_preview")],
            input: prompt
        )

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            // Optional: Log request body for debugging (remove in production)
            // if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
            //      print("📬 Request Body JSON: \(bodyString)")
            // }
        } catch {
            print("❌ [OpenAIService] Failed to encode request body: \(error)")
            throw URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: "Encoding failed: \(error.localizedDescription)"])
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [OpenAIService] Invalid response type.")
            throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server."])
        }

        print("🚦 [OpenAIService] HTTP Status Code: \(httpResponse.statusCode)")
        // Optional: Log raw response data for debugging (remove in production)
        // if let responseString = String(data: data, encoding: .utf8) {
        //      print("📄 Raw Response Data:\n\(responseString)")
        // }

        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ [OpenAIService] Server error: \(httpResponse.statusCode)")
            // Try to decode API error message
            if let apiError = try? JSONDecoder().decode(OpenAIResponse.self, from: data).error {
                print("💀 [OpenAIService] API Error Details: \(apiError.message)")
                throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: apiError.message])
            } else {
                 throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Server error \(httpResponse.statusCode). Unable to parse error details."])
            }
        }

        do {
            let decodedResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            print("✅ [OpenAIService] Successfully decoded response.")

            // Find the first message output and its text content
            guard let messageOutput = decodedResponse.output?.first(where: { $0.type == "message" || $0.type == "text" }),
                  let content = messageOutput.content?.first(where: { $0.type == "output_text" || $0.type == "text" }),
                  let text = content.text else {
                print("❌ [OpenAIService] Could not find expected text content structure.")
                // Optional: Log output structure for debugging
                 if let outputDump = decodedResponse.output { print("🔍 Output structure dump: \(outputDump)") }
                throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Could not find text content in response."])
            }

            print("📰 [OpenAIService] Fetched Text: \(text.prefix(80))...") // Log truncated text
            return text

        } catch let decodingError as DecodingError {
            print("❌ [OpenAIService] Failed to decode response: \(decodingError)")
             var errorDesc = "Decoding failed: "
             switch decodingError {
                case .typeMismatch(_, let context): errorDesc += "Type mismatch at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)"
                case .valueNotFound(_, let context): errorDesc += "Value not found at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)"
                case .keyNotFound(let key, let context): errorDesc += "Key '\(key.stringValue)' not found at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)"
                case .dataCorrupted(let context): errorDesc += "Data corrupted at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)"
                @unknown default:  errorDesc += "Unknown decoding error."
            }
             print("🔍 Decoding Error Details: \(errorDesc)")
             throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: errorDesc])
        } catch {
            print("❌ [OpenAIService] Unexpected error during decoding or processing: \(error)")
            throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Response processing failed: \(error.localizedDescription)."])
        }
    }
}

// MARK: - Fetching Service Protocol
protocol ChatFetchingService {
    /// Fetches a response for a given user prompt.
    /// - Parameter prompt: The user's input text.
    /// - Returns: The agent's response text.
    /// - Throws: An error if fetching fails.
    func fetchResponse(for prompt: String) async throws -> String
}

// MARK: - Live API Chat Service
class LiveChatService: ChatFetchingService {
    // Uses the existing OpenAI service implementation
    private let apiService = OpenAIService()

    func fetchResponse(for prompt: String) async throws -> String {
        print("📡 LiveChatService: Fetching real response for prompt: \(prompt)")
        // Directly call the actual API fetch method
        return try await apiService.fetchPositiveNews(prompt: prompt)
    }
}

// MARK: - Mock Chat Service
class MockChatService: ChatFetchingService {
    // Custom error type for mock scenarios
    enum MockError: Error, LocalizedError {
        case simulatedError(String)
        var errorDescription: String? {
            switch self {
            case .simulatedError(let message): return message
            }
        }
    }

    // Pool of mock responses triggered by keywords in the prompt
    private let mockResponses: [String: Result<String, MockError>] = [
        "hello": .success("Hi there from Mock! How can I provide some positive news?"),
        "tech": .success("Mock Data: Advancements in battery recycling methods show promising environmental benefits!"),
        "science": .success("Mock Data: Researchers discovered a new species of bioluminescent fungi in the Amazon."),
        "space": .success("Mock Data: The James Webb Space Telescope captured stunning new images of a distant galaxy cluster."),
        "error": .failure(.simulatedError("Oops! Simulated connection error. Please try again.")),
        "long": .success("Mock Data: This is a deliberately longer mock response designed to test the UI's ability to handle multi-line text bubbles effectively. It simulates a scenario where the AI provides a more detailed explanation or narrative, ensuring that text wrapping, layout constraints, and scrolling behave as expected within the chat interface.")
    ]

    // Default response if no keyword matches
    private let defaultMockResponse = "Mock Data: I couldn't find a specific mock for that. Try prompts with 'tech', 'science', 'space', or 'error'."
    // Simulate network latency with a random delay between 0.5 and 1.5 seconds
    private let simulatedDelay: Duration = .seconds(Int.random(in: 500...1500)) / 1000.0

    func fetchResponse(for prompt: String) async throws -> String {
        print("🎭 MockChatService: Generating mock response for prompt: \(prompt)")

        // Introduce simulated network delay
        try await Task.sleep(for: simulatedDelay)

        // Prepare the prompt for keyword matching
        let lowercasedPrompt = prompt.lowercased()
        var foundResult: Result<String, MockError>? = nil

        // Iterate through mock responses to find the first keyword match
        for (key, result) in mockResponses {
            if lowercasedPrompt.contains(key) {
                foundResult = result
                break // Use the first match found
            }
        }

        // Use the found result or the default response if no match
        let resultToUse = foundResult ?? .success(defaultMockResponse)

        print("🎭 MockChatService: Returning result: \(resultToUse)")

        // Handle the Result: return the text on success, throw the error on failure
        switch resultToUse {
        case .success(let text):
            return text
        case .failure(let error):
            // Propagate the simulated error to the calling code
            throw error
        }
    }
}

// MARK: - SwiftUI View (ContentView)
struct ContentView: View {
    // MARK: - State Variables
    @State private var currentPrompt: String = ""
    @State private var chatItems: [ChatItem]
    @State private var isFetching: Bool = false
    @FocusState private var promptFieldIsFocused: Bool

    // --- Dependency Injection ---
    private let chatService: ChatFetchingService // Use the protocol type

    // Initializer to inject the service and set initial state
    init(chatService: ChatFetchingService) {
        self.chatService = chatService

        // Set initial message based on service type (cosmetic difference)
        let initialMessageText = chatService is MockChatService ?
            "Hello! (Mock Mode)" :
            "Hello! Ask me for positive news."
        _chatItems = State(initialValue: [ChatItem(sender: .agent, text: initialMessageText)])

        print("✅ ContentView initialized with service: \(type(of: chatService))")
    }
    // --- End Dependency Injection ---

    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) { // No spacing between chat and input areas
                chatScrollView
                Divider() // Subtle separator
                inputArea
            }
            .navigationTitle("Good News Agent")
            .navigationBarTitleDisplayMode(.inline)
             .toolbar {
                 // Service Mode Indicator (Left side)
                 ToolbarItem(placement: .navigationBarLeading) {
                     Text(chatService is MockChatService ? "Mock Mode" : "Live Mode")
                         .font(.caption.weight(.semibold))
                         .padding(.horizontal, 8)
                         .padding(.vertical, 4)
                         .background(chatService is MockChatService ? Color.orange.opacity(0.8) : Color.green.opacity(0.8))
                         .foregroundColor(.white)
                         .clipShape(Capsule())
                         .animation(.easeInOut, value: chatService is MockChatService) // Animate change if needed
                 }
                 // Clear Chat Button (Right side)
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button { clearChat() } label: {
                         Label("Clear Chat", systemImage: "trash")
                     }
                    .tint(.red)
                    // Disable clear button if only the initial message exists and prompt is empty
                    .disabled(chatItems.count <= 1 && currentPrompt.isEmpty)
                }
            }
            // Dismiss keyboard when tapping outside the input area
            .onTapGesture { promptFieldIsFocused = false }
        }
        // Ensure NavigationView style is appropriate for the device (optional)
        // .navigationViewStyle(.stack) // Use stack style on iPad if desired
    }

    // MARK: - Chat Scroll View
    private var chatScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 15) { // Spacing between chat bubbles
                    ForEach(chatItems) { item in
                        ChatItemView(chatItem: item) {
                            // Pass the retry action to the view
                            retryFetch(failedItem: item)
                        }
                        .id(item.id) // Needed for ScrollViewReader
                    }
                }
                .padding(.horizontal) // Horizontal padding for all bubbles
                .padding(.top, 10)    // Padding above the first bubble
                .padding(.bottom, 5)  // Padding below the last bubble (so it's not flush with input)
            }
            // Automatically scroll down when chat items change
            .onChange(of: chatItems) { _ in scrollToBottom(proxy: proxy) }
            // Scroll down on initial appearance if needed
            .onAppear { scrollToBottom(proxy: proxy, animated: false) }
        }
    }

    // MARK: - Input Area
    private var inputArea: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // Textfield that grows vertically
            TextField("Ask about positive news...", text: $currentPrompt, axis: .vertical)
                .textFieldStyle(.plain) // Removes default border/background
                .padding(.horizontal, 12)
                .padding(.vertical, 10) // Slightly more vertical padding
                .background(Color(.systemGray6)) // Background color for the textfield area
                .clipShape(Capsule()) // Rounded corners
                .focused($promptFieldIsFocused)
                .lineLimit(1...5) // Allow up to 5 lines before scrolling internally
                .onSubmit(sendMessage) // Send message on return key

            // Send Button
            Button { sendMessage() } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title) // Make button large and easily tappable
                    .symbolRenderingMode(.multicolor) // Use SF Symbol colors if available
            }
            // Disable button if prompt is empty or fetching is in progress
            .disabled(currentPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isFetching)
            // Dynamically change tint based on disabled state
            // .tint(currentPrompt...isEmpty ? .gray : .blue) // Alternative tinting
            .animation(.easeInOut, value: isFetching || currentPrompt.isEmpty) // Animate enable/disable state
        }
        .padding(.horizontal) // Padding on the sides of the input bar
        .padding(.vertical, 8) // Padding above/below the input bar
        .background(.thinMaterial) // Visual separation for the input bar area
    }

    // MARK: - Functions (Interacting with Chat Service and State)

    /// Sends the user's message and triggers the fetch process.
    private func sendMessage() {
        let textToSend = currentPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textToSend.isEmpty else { return } // Don't send empty messages

        // 1. Add the user's message to the chat display
        let userMessage = ChatItem(sender: .user, text: textToSend)
        chatItems.append(userMessage)

        // 2. Add a placeholder for the agent's response (shows loading state)
        let agentPlaceholderId = UUID() // Unique ID to track this specific response
        let agentPlaceholder = ChatItem(sender: .agent, text: "", state: .sending)
        chatItems.append(agentPlaceholder)

        // 3. Clear the input field and update fetching state
        currentPrompt = ""
        // promptFieldIsFocused = false // Optional: Keep focus for faster typing or dismiss
        isFetching = true // Disable input fields while fetching

        // 4. Start asynchronous task to fetch the response
        Task {
            defer { isFetching = false } // Ensure fetching state is reset when task finishes
            do {
                // *** Use the injected chatService (could be Mock or Live) ***
                let responseText = try await chatService.fetchResponse(for: textToSend)
                // Update the placeholder message with the received text and success state
                updateAgentMessage(id: agentPlaceholderId, newText: responseText, newState: .sent)
            } catch {
                // Log the error and update the placeholder message with the error details
                print("🚨 Error fetching response: \(error.localizedDescription)")
                updateAgentMessage(id: agentPlaceholderId, newText: error.localizedDescription, newState: .error)
            }
        }
    }

    /// Updates a specific agent message in the `chatItems` array, identified by its ID.
    private func updateAgentMessage(id: UUID, newText: String, newState: MessageState) {
        // Find the index of the message to update
        if let index = chatItems.firstIndex(where: { $0.id == id }) {
            // Update the message properties in place
            chatItems[index].text = newText
            chatItems[index].state = newState
            print("🔄 Updated agent message [\(id)] - State: \(newState)")
        } else {
            // This shouldn't normally happen if IDs are managed correctly
            print("⚠️ Could not find agent message with ID \(id) to update.")
        }
    }

    /// Retries fetching the response for a message that previously resulted in an error.
    private func retryFetch(failedItem: ChatItem) {
        // Ensure the item exists and has a preceding user message
        guard let failedIndex = chatItems.firstIndex(where: { $0.id == failedItem.id }), failedIndex > 0 else {
             print("⚠️ Retry failed: Could not find failed item \(failedItem.id) or it was the first item.")
             return
        }

        let previousItem = chatItems[failedIndex - 1]
        guard previousItem.sender == .user else {
            print("⚠️ Retry failed: Could not find preceding user prompt for item \(failedItem.id).")
            return
        }

        let originalPrompt = previousItem.text
        print("🔁 Retrying fetch for prompt: \"\(originalPrompt)\" using \(type(of: chatService))")

        // 1. Update the failed item's state back to "sending"
        updateAgentMessage(id: failedItem.id, newText: "", newState: .sending)
        isFetching = true

        // 2. Start asynchronous task to fetch the response again
        Task {
             defer { isFetching = false } // Ensure fetching state is reset
            do {
                // *** Use the injected chatService again ***
                let responseText = try await chatService.fetchResponse(for: originalPrompt)
                updateAgentMessage(id: failedItem.id, newText: responseText, newState: .sent)
            } catch {
                print("🚨 Retry Error fetching response: \(error.localizedDescription)")
                updateAgentMessage(id: failedItem.id, newText: error.localizedDescription, newState: .error)
            }
        }
    }

    /// Scrolls the chat view to the bottom, optionally animated.
    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
        // Get the ID of the last item in the chat
        guard let lastId = chatItems.last?.id else { return }
        // print("⏬ Scrolling to bottom item: \(lastId)") // Can be noisy, disable if needed
        if animated {
            withAnimation(.spring()) { // Use a spring animation for a nice effect
                proxy.scrollTo(lastId, anchor: .bottom)
            }
        } else {
            // Scroll instantly without animation
            proxy.scrollTo(lastId, anchor: .bottom)
        }
    }

    /// Clears the chat history, resetting to the initial agent greeting.
    private func clearChat() {
        // Determine the initial message based on the current service type
          let initialMessageText = chatService is MockChatService ?
             "Hello! (Mock Mode)" :
             "Hello! Ask me for positive news."
        // Reset chatItems to just the initial message
        chatItems = [ChatItem(sender: .agent, text: initialMessageText, state: .sent)]
        currentPrompt = "" // Clear input field
        isFetching = false // Ensure fetching state is reset
        promptFieldIsFocused = false // Dismiss keyboard
        print("🧹 Chat cleared.")
    }
}

// MARK: - Chat Item View (Individual Message Bubble UI)
struct ChatItemView: View {
    let chatItem: ChatItem
    var onRetry: (() -> Void)? = nil // Callback action for the retry button

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) { // Align bubble and image at the bottom
            if chatItem.sender == .agent {
                agentProfileImage // Agent image on the left
                agentMessageContent // Agent bubble content
                Spacer() // Push agent content left
            } else {
                Spacer() // Push user content right
                userMessageContent // User bubble content
            }
        }
    }

    // Subview for Agent's profile image
    private var agentProfileImage: some View {
        Image(systemName: "brain.head.profile") // System icon as placeholder
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .clipShape(Circle())
            .foregroundColor(.accentColor.opacity(0.8)) // Use theme color
            .padding(.bottom, 5) // Align vertically with the bottom of the text bubble
    }

    // Subview for Agent's message bubble content
    private var agentMessageContent: some View {
        VStack(alignment: .leading, spacing: 4) { // Stack content vertically
            // Display content based on the message state
            Group {
                switch chatItem.state {
                case .sending:
                    HStack(spacing: 8) { // Loading indicator
                        ProgressView().controlSize(.small) // Small spinner
                        Text("Finding news...")
                           .font(.caption).italic().foregroundColor(.secondary)
                    }
                case .error:
                    HStack(alignment: .center) { // Error message and retry button
                        Text("Error: \(chatItem.text)")
                            .font(.callout).foregroundColor(.red)
                        Spacer() // Push retry button to the right
                        // Show retry button only if an action is provided
                        if onRetry != nil {
                            Button { onRetry?() } label: {
                                Image(systemName: "arrow.clockwise.circle") // Use circle variant
                                   .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain) // Remove default button styling
                        }
                    }
                case .sent:
                    // Display the actual message text (supports basic Markdown)
                    Text(.init(chatItem.text)) // Use AttributedString initializer for Markdown
                        .textSelection(.enabled) // Allow users to select/copy text
                        .font(.callout)
                        .environment(\.openURL, OpenURLAction { url in
                             print("Attempting to open URL: \(url)") // Handle link taps if needed
                            // Implement actual URL opening logic here
                             return .handled // or .systemAction
                        })
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray5)) // Agent bubble background color
            .foregroundColor(.primary) // Standard text color
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous)) // Rounded corners
            .frame(minWidth: 40) // Ensure a minimum visual width for the bubble
            .animation(.easeInOut, value: chatItem.state) // Animate state changes
        }
    }

    // Subview for User's message bubble content
    private var userMessageContent: some View {
         VStack(alignment: .trailing, spacing: 4) { // Stack content vertically (for potential timestamp later)
             Text(chatItem.text)
                .font(.callout)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.blue) // User bubble background color
                .foregroundColor(.white) // User bubble text color
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous)) // Rounded corners
                .frame(minWidth: 40) // Ensure a minimum visual width
         }
    }
}

// MARK: - Main App Structure
@main
struct GoodNewsApp: App {
    // --- Central Control Point: Switch Between Mock and Live Data ---
    // Set this to 'true' to use MockChatService (no API key needed, uses mock data)
    // Set this to 'false' to use LiveChatService (requires valid API key in Info.plist)
    private let useMockData = true // <--- TOGGLE HERE FOR LIVE/MOCK ---

    // Computed property to instantiate the correct service based on the toggle
    private var chatService: ChatFetchingService {
        if useMockData {
            print("🚀 Using MockChatService")
            return MockChatService()
        } else {
            print("⚡️ Using LiveChatService (Ensure API Key is valid!)")
            // IMPORTANT: LiveChatService relies on OpenAIService, which checks
            // for the API key in Info.plist during initialization.
            // If the key is missing or invalid, the app will crash with a fatalError.
            return LiveChatService()
        }
    }

    var body: some Scene {
        WindowGroup {
            // Inject the chosen service into the main ContentView
            ContentView(chatService: chatService)
        }
    }
}

// MARK: - SwiftUI Preview Provider
#Preview {
    // *** IMPORTANT: Previews ALWAYS use MockChatService ***
    // This ensures previews work reliably without network or API keys.
    ContentView(chatService: MockChatService())
}
