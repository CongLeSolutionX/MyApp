////
////  WebSearchWorkflowDemoView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/13/25.
////
//
//import SwiftUI
//
//// MARK: - Data Models
//
//// Represents a single message in the chat interface
//struct ChatItem: Identifiable, Hashable {
//    let id = UUID()
//    let sender: Sender
//    var text: String
//    let timestamp: Date = Date()
//    var state: MessageState = .sent // Tracks the state of agent messages
//
//    // Formatter for display (optional, could add later)
//    // static let timeFormatter: DateFormatter = ...
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
//// --- Models for API Interaction (Keep these from before) ---
//struct OpenAIRequest: Codable {
//    let model: String
//    let tools: [Tool]
//    let input: String
//    struct Tool: Codable { let type: String }
//}
//
//struct OpenAIResponse: Codable {
//    let output: [OutputItem]?
//    let error: OpenAIError?
//}
//
//struct OutputItem: Codable {
//    let id: String?, type: String, status: String?, content: [ContentItem]?, role: String?
//}
//
//struct ContentItem: Codable {
//    let type: String, text: String?
//}
//
//struct OpenAIError: Codable {
//    let code: String?, message: String, param: String?, type: String?
//}
//// --- End API Interaction Models ---
//
//// MARK: - API Service (Unchanged from previous version)
//
//class OpenAIService {
//    // --- IMPORTANT: API KEY HANDLING ---
//    // Remember to handle your API Key securely (Info.plist, xcconfig, etc.)
//    // DO NOT hardcode it here in production.
//    private var apiKey: String {
//        guard let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String, !key.isEmpty, key != "YOUR_API_KEY_HERE" else {
//            fatalError("Add your valid OPENAI_API_KEY to Info.plist or configure securely.")
//        }
//        return key
//    }
//
//    private let apiURL = URL(string: "https://api.openai.com/v1/responses")!
//
//    func fetchPositiveNews(prompt: String) async throws -> String {
//        print("🤖 OpenAIService: Starting fetch for prompt: \(prompt)")
//        var request = URLRequest(url: apiURL)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//        request.setValue("OpenAI-Beta", forHTTPHeaderField: "OpenAI-Beta")
//        request.setValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")
//
//        let requestBody = OpenAIRequest(
//            model: "gpt-4o",
//            tools: [OpenAIRequest.Tool(type: "web_search_preview")],
//            input: prompt
//        )
//
//        do {
//            request.httpBody = try JSONEncoder().encode(requestBody)
//            if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
//                 print("📬 Request Body JSON: \(bodyString)")
//            }
//        } catch {
//            print("❌ Failed to encode request body: \(error)")
//            throw URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: "Encoding failed: \(error.localizedDescription)"])
//        }
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//
//        guard let httpResponse = response as? HTTPURLResponse else {
//            print("❌ Invalid response type.")
//            throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server."])
//        }
//
//        print("🚦 HTTP Status Code: \(httpResponse.statusCode)")
//        if let responseString = String(data: data, encoding: .utf8) {
//             print("📄 Raw Response Data:\n\(responseString)")
//        }
//
//        guard (200...299).contains(httpResponse.statusCode) else {
//            print("❌ Server error: \(httpResponse.statusCode)")
//            if let apiError = try? JSONDecoder().decode(OpenAIResponse.self, from: data).error {
//                print("💀 API Error Details: \(apiError.message)")
//                throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: apiError.message])
//            } else {
//                 throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Server error \(httpResponse.statusCode)."])
//            }
//        }
//
//        do {
//            let decodedResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
//            print("✅ Successfully decoded response.")
//
//            // Updated Logic: Find the first message/text content regardless of specific subtype if necessary
//            guard let messageOutput = decodedResponse.output?.first(where: { $0.type == "message" || $0.type == "text" }), // Prefer 'message' type
//                  let content = messageOutput.content?.first(where: { $0.type == "output_text" || $0.type == "text" }), // Prefer 'output_text'
//                  let text = content.text else {
//                print("❌ Could not find expected text content structure.")
//                 if let outputDump = decodedResponse.output { print("🔍 Output structure dump: \(outputDump)") }
//                throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Could not find text content in response."])
//            }
//
//            print("📰 Fetched Text: \(text)")
//            return text
//
//        } catch let decodingError as DecodingError {
//            print("❌ Failed to decode response: \(decodingError)")
//             // Provide detailed error for debugging
//             var errorDesc = "Decoding failed: "
//             switch decodingError {
//                case .typeMismatch(_, let context): errorDesc += "Type mismatch at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)"
//                case .valueNotFound(_, let context): errorDesc += "Value not found at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)"
//                case .keyNotFound(let key, let context): errorDesc += "Key '\(key.stringValue)' not found at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)"
//                case .dataCorrupted(let context): errorDesc += "Data corrupted at \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)"
//                @unknown default:  errorDesc += "Unknown decoding error."
//            }
//             print("🔍 Decoding Error Details: \(errorDesc)")
//             throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: errorDesc])
//        } catch {
//            print("❌ Unexpected error during decoding or processing: \(error)")
//            throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Response processing failed: \(error.localizedDescription)."])
//        }
//    }
//}
//
//// MARK: - SwiftUI View
//
//struct WebSearchWorkflowDemoView: View {
//    // MARK: - State Variables
//    @State private var currentPrompt: String = ""
//    @State private var chatItems: [ChatItem] = [
//        // Example starting messages
//        ChatItem(sender: .agent, text: "Hello! I'm here to find positive news for you. What topic are you interested in today?"),
//        // ChatItem(sender: .user, text: "Tell me something good about technology this week."), // Example user input
//        // ChatItem(sender: .agent, text: "Okay, let me check...") // Example agent response
//    ]
//    @State private var isFetching: Bool = false // Simple bool to disable input during fetch
//
//    @FocusState private var promptFieldIsFocused: Bool
//
//    private let apiService = OpenAIService()
//
//    // MARK: - Body
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                // Chat History Area
//                chatScrollView
//
//                Divider()
//
//                // Input Area
//                inputArea
//            }
//            .navigationTitle("Good News Agent")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar { // Optional: Clear button
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        clearChat()
//                    } label: {
//                        Label("Clear Chat", systemImage: "trash")
//                    }
//                    .tint(.red)
//                    .disabled(chatItems.count <= 1 && currentPrompt.isEmpty) // Disable if only initial message exists
//                }
//            }
//            .onTapGesture { // Dismiss keyboard on tap outside input
//                promptFieldIsFocused = false
//            }
//        }
//    }
//
//    // MARK: - Chat Scroll View
//    private var chatScrollView: some View {
//        ScrollViewReader { proxy in
//            ScrollView {
//                LazyVStack(spacing: 15) { // Use LazyVStack for potentially long chats
//                    ForEach(chatItems) { item in
//                        ChatItemView(chatItem: item) {
//                            // Retry action for error messages
//                            retryFetch(failedItem: item)
//                        }
//                        .id(item.id) // Assign ID for scrolling
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.top, 10) // Padding at the top of the scroll content
//            }
//            .onChange(of: chatItems) {
//                // Scroll to the bottom when new messages are added
//                scrollToBottom(proxy: proxy)
//            }
//            .onAppear {
//                 // Scroll to bottom initially if needed
//                 scrollToBottom(proxy: proxy, animated: false)
//            }
//        }
//    }
//
//    // MARK: - Input Area
//    private var inputArea: some View {
//        HStack(alignment: .bottom, spacing: 8) {
//            // Use a TextField that adapts to content size
//            TextField("Ask about positive news...", text: $currentPrompt, axis: .vertical)
//                .textFieldStyle(.plain)
//                .padding(.horizontal, 12)
//                .padding(.vertical, 8)
//                .background(Color(.systemGray6))
//                .clipShape(Capsule()) // Use Capsule for a rounded look
//                .focused($promptFieldIsFocused)
//                .lineLimit(1...5) // Limit lines to prevent excessive height
//                .onSubmit(sendMessage) // Send on return key
//
//            Button {
//                sendMessage()
//            } label: {
//                Image(systemName: "arrow.up.circle.fill")
//                    .font(.title) // Make button prominent
//            }
//            .disabled(currentPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isFetching)
//            .tint(currentPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue) // Change color when enabled
//            .animation(.easeInOut, value: isFetching || currentPrompt.isEmpty)
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 8) // Padding around the input bar
//        .background(.regularMaterial) // Subtle background for the input bar
//    }
//
//    // MARK: - Chat Item View (Individual Message Bubble)
//    struct ChatItemView: View {
//        let chatItem: ChatItem
//        var onRetry: (() -> Void)? = nil // Closure for retry action
//
//        var body: some View {
//            HStack(alignment: .bottom, spacing: 8) {
//                if chatItem.sender == .agent {
//                    agentProfileImage // Show profile image for agent
//                    agentMessageContent // Agent message bubble on the left
//                    Spacer() // Push agent bubble left
//                } else {
//                    Spacer() // Push user bubble right
//                    userMessageContent // User message bubble on the right
//                }
//            }
//        }
//
//        // MARK: Subviews for ChatItemView
//
//        private var agentProfileImage: some View {
//            // Use a system icon, replace with Image("agent_avatar") if you have one
//            Image(systemName: "brain.head.profile") // Or "person.crop.circle.fill"
//                .resizable()
//                .scaledToFit()
//                .frame(width: 30, height: 30)
//                .clipShape(Circle())
//                .foregroundColor(.secondary) // Or a specific color
//                .padding(.bottom, 5) // Align with bottom of text bubble
//        }
//
//        private var agentMessageContent: some View {
//            VStack(alignment: .leading, spacing: 4) {
//                 // Agent name (Optional)
//                 // Text("News Agent").font(.caption).foregroundColor(.secondary)
//
//                Group { // Group allows modifier conditional on state
//                    if chatItem.state == .sending {
//                        HStack(spacing: 8) {
//                             ProgressView()
//                                 .tint(.secondary) // Make spinner subtle
//                             Text("Finding news...")
//                                .italic()
//                         }
//                    } else if chatItem.state == .error {
//                        HStack {
//                            Text("Error: \(chatItem.text)")
//                                 .foregroundColor(.red)
//                            Spacer()
//                             // Add retry button if needed
//                             if onRetry != nil {
//                                 Button { onRetry?() } label: {
//                                     Image(systemName: "arrow.clockwise")
//                                 }
//                                 .buttonStyle(.borderless) // simple retry button
//                                 .tint(.blue)
//                             }
//                        }
//                    } else {
//                        // Normal text display with Markdown potential
//                        Text(.init(chatItem.text)) // Use AttributedString initializer
//                            .textSelection(.enabled) // Allow text selection
//                    }
//                }
//                .padding(.horizontal, 12)
//                .padding(.vertical, 8)
//                .background(Color(.systemGray5)) // Agent bubble color
//                .foregroundColor(.primary) // Use primary text color in agent bubble
//                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//                .frame(minWidth: 40) // Ensure bubble has some minimum width
//
//                // Timestamp (optional)
//                 Text(chatItem.timestamp, style: .time).font(.caption2).foregroundColor(.secondary)
//            }
//            .padding(.leading, 0) // No extra padding needed here
//        }
//
//        private var userMessageContent: some View {
//            VStack(alignment: .trailing, spacing: 4) {
//                Text(chatItem.text)
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 8)
//                    .background(Color.blue) // User bubble color
//                    .foregroundColor(.white) // User bubble text color
//                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//                    .frame(minWidth: 40) // Ensure bubble has some minimum width
//
//                 // Timestamp (optional)
//                  Text(chatItem.timestamp, style: .time).font(.caption2).foregroundColor(.secondary)
//            }
//             .padding(.trailing, 0) // No extra padding needed here
//        }
//    }
//
//    // MARK: - Functions
//
//    /// Sends the current prompt and triggers the API fetch
//    private func sendMessage() {
//        let textToSend = currentPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !textToSend.isEmpty else { return }
//
//        // 1. Add user message to chat
//        let userMessage = ChatItem(sender: .user, text: textToSend)
//        chatItems.append(userMessage)
//
//        // 2. Add agent's "thinking" placeholder
//        let agentPlaceholderId = UUID() // Keep track of this placeholder
//        let agentPlaceholder = ChatItem(sender: .agent, text: "", state: .sending)
//        
//        //ChatItem(id: agentPlaceholderId, sender: .agent, text: "", state: .sending)
//        chatItems.append(agentPlaceholder)
//
//        // 3. Clear input field
//        currentPrompt = ""
//        promptFieldIsFocused = false // Dismiss keyboard maybe?
//        isFetching = true // Disable input
//
//        // 4. Start API fetch
//        Task {
//            do {
//                let responseText = try await apiService.fetchPositiveNews(prompt: textToSend)
//                // Update the placeholder with the actual response
//                updateAgentMessage(id: agentPlaceholderId, newText: responseText, newState: .sent)
//            } catch {
//                // Update the placeholder with the error message
//                 print("🚨 Error caught in Task: \(error.localizedDescription)")
//                updateAgentMessage(id: agentPlaceholderId, newText: error.localizedDescription, newState: .error)
//            }
//            isFetching = false // Re-enable input
//        }
//    }
//
//    /// Updates a specific agent message in the chatItems array
//    private func updateAgentMessage(id: UUID, newText: String, newState: MessageState) {
//        if let index = chatItems.firstIndex(where: { $0.id == id }) {
//             print("🔄 Updating agent message [\(id)] - State: \(newState), Text: \(newText.prefix(50))...")
//            chatItems[index].text = newText
//            chatItems[index].state = newState
//        } else {
//             print("⚠️ Could not find agent message with ID \(id) to update.")
//        }
//    }
//
//     /// Retries fetching news for a message that previously failed
//    private func retryFetch(failedItem: ChatItem) {
//        // We need the original prompt that led to this error.
//        // Find the user message *before* the failed agent message.
//        if let failedIndex = chatItems.firstIndex(where: { $0.id == failedItem.id }), failedIndex > 0 {
//             let previousItem = chatItems[failedIndex - 1]
//             if previousItem.sender == .user {
//                let originalPrompt = previousItem.text
//                 print("🔁 Retrying fetch for prompt: \(originalPrompt)")
//
//                 // Update the failed item state to "sending" again
//                 updateAgentMessage(id: failedItem.id, newText: "", newState: .sending) // Reset text and state
//
//                 isFetching = true
//
//                 Task {
//                      do {
//                          let responseText = try await apiService.fetchPositiveNews(prompt: originalPrompt)
//                          updateAgentMessage(id: failedItem.id, newText: responseText, newState: .sent)
//                      } catch {
//                           print("🚨 Retry Error caught in Task: \(error.localizedDescription)")
//                          updateAgentMessage(id: failedItem.id, newText: error.localizedDescription, newState: .error)
//                      }
//                      isFetching = false
//                 }
//             } else {
//                  print("⚠️ Retry failed: Could not find preceding user prompt for item \(failedItem.id).")
//             }
//        } else {
//             print("⚠️ Retry failed: Could not find failed item \(failedItem.id) or it was the first item.")
//        }
//    }
//
//    /// Scrolls the chat view to the bottom
//    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
//        guard let lastId = chatItems.last?.id else { return }
//         print("⏬ Scrolling to bottom item: \(lastId)")
//        if animated {
//            withAnimation(.spring()) {
//                proxy.scrollTo(lastId, anchor: .bottom)
//            }
//        } else {
//            proxy.scrollTo(lastId, anchor: .bottom)
//        }
//    }
//
//    /// Clears the chat history, keeping the initial agent message
//    private func clearChat() {
//        if let firstItem = chatItems.first, firstItem.sender == .agent {
//             chatItems = [firstItem] // Keep only the initial greeting
//             // Optionally reset its text if it was modified by errors etc.
//              chatItems[0].text = "Hello! ..."
//              chatItems[0].state = .sent
//        } else {
//            chatItems = [] // Or clear completely if no standard greeting
//        }
//        currentPrompt = "" // Also clear input
//        isFetching = false // Ensure input is enabled
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    WebSearchWorkflowDemoView()
//}
