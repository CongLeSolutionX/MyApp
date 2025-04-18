////
////  ChatView_V5.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//import SwiftUI
//import Combine // Needed for AnyCancellable if Tasks are stored for cancellation
//
//// MARK: - Data Models & API Structures
//
//// Enhanced Message Struct (from previous example)
//struct Message: Identifiable {
//    let id = UUID()
//    var text: String // Can change during streaming
//    let isUser: Bool
//    let timestamp: Date = Date()
//    var sourceModel: AIModel? = nil
//    var isLoading: Bool = false
//    var error: String? = nil // Store errors specific to *generating* this message
//
//    enum AIModel: String, CaseIterable, Codable { // Add Codable for potential saving
//        case gpt_3_5_turbo = "gpt-3.5-turbo"
//        case gpt_4 = "gpt-4"
//        case gpt_4_turbo = "gpt-4-turbo" // Example of another model
//
//        var displayName: String {
//            switch self {
//            case .gpt_3_5_turbo: return "GPT-3.5 Turbo"
//            case .gpt_4: return "GPT-4"
//            case .gpt_4_turbo: return "GPT-4 Turbo"
//            }
//        }
//
//        var systemImageName: String {
//            switch self {
//            case .gpt_3_5_turbo: return "bolt.horizontal.icloud"
//            case .gpt_4: return "sparkles"
//            case .gpt_4_turbo: return "airplane" // Just an example icon
//            }
//        }
//    }
//}
//
//// --- OpenAI API Request Structures ---
//struct OpenAIRequestMessage: Codable {
//    let role: String // "user", "assistant", or "system"
//    let content: String
//}
//
//struct ChatCompletionRequest: Codable {
//    let model: String
//    let messages: [OpenAIRequestMessage]
//    let stream: Bool // MUST be true for streaming
//    // Add other parameters like temperature, max_tokens as needed
//    // let temperature: Double? = 0.7
//}
//
//// --- OpenAI API Response Structures (for Streaming) ---
//struct ChatStreamResponse: Decodable {
//    let choices: [StreamChoice]
//}
//
//struct StreamChoice: Decodable {
//    let delta: StreamDelta
//    let finish_reason: String? // e.g., "stop", "length"
//}
//
//struct StreamDelta: Decodable {
//    let role: String? // Will be "assistant" for first delta usually
//    let content: String? // The actual text fragment
//}
//
//// --- OpenAI API Error Structures ---
//struct OpenAIErrorResponse: Decodable, Error {
//    let error: OpenAIErrorDetail
//}
//
//struct OpenAIErrorDetail: Decodable {
//    let message: String
//    let type: String?
//    // let param: String? // Parameter causing the error
//    // let code: String? // Specific error code
//}
//
//// MARK: - OpenAI Service Logic
//
//class OpenAIService {
//
//    // !!! --- SECURITY WARNING --- !!!
//    // NEVER hardcode your API key directly in the app like this in production.
//    // Use environment variables, a secure backend proxy, or other secure methods.
//    private let apiKey = "YOUR_OPENAI_API_KEY_HERE" // <-- Replace with your actual key FOR TESTING ONLY
//    private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!
//
//    enum APIError: Error {
//        case invalidURL
//        case requestFailed(Error)
//        case invalidResponse(URLResponse?)
//        case apiError(String) // Error message from OpenAI
//        case decodingError(Error)
//        case missingApiKey
//        case dataParsingError
//    }
//
//    // Function to handle streaming chat completions
//    func streamChatCompletion(messages: [OpenAIRequestMessage], model: Message.AIModel) -> AsyncThrowingStream<String, Error> {
//        
//        guard apiKey != "YOUR_OPENAI_API_KEY_HERE" && !apiKey.isEmpty else {
//             // Return a stream that immediately throws an error if the key is missing/default
//            return AsyncThrowingStream { continuation in
//                continuation.finish(throwing: APIError.missingApiKey)
//            }
//        }
//
//        return AsyncThrowingStream { continuation in
//            Task {
//                do {
//                    var request = URLRequest(url: apiURL)
//                    request.httpMethod = "POST"
//                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//
//                    let requestBody = ChatCompletionRequest(
//                        model: model.rawValue, // Use the rawValue which matches OpenAI model names
//                        messages: messages,
//                        stream: true // Ensure streaming is enabled
//                    )
//
//                    request.httpBody = try JSONEncoder().encode(requestBody)
//
//                    // Use URLSession bytes(for:) to handle the SSE stream
//                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
//
//                    guard let httpResponse = response as? HTTPURLResponse else {
//                        continuation.finish(throwing: APIError.invalidResponse(response))
//                        return
//                    }
//                    
//                    // Check for non-200 status codes *before* trying to stream
//                    // OpenAI might return errors immediately without streaming
//                    guard httpResponse.statusCode == 200 else {
//                        // Attempt to decode OpenAI's specific error format if possible
//                        var errorData = Data()
//                        for try await byte in bytes { // Consume bytes to get error body
//                            errorData.append(byte)
//                        }
//                        if let decodedError = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: errorData) {
//                            continuation.finish(throwing: APIError.apiError(decodedError.error.message))
//                        } else {
//                            let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown API Error"
//                             continuation.finish(throwing: APIError.apiError("Server returned status \(httpResponse.statusCode). \(errorString)"))
//                        }
//                        return
//                    }
//
//                    // Process the stream line by line
//                    for try await line in bytes.lines {
//                        // SSE format: "data: {...}"
//                        guard line.hasPrefix("data: ") else { continue }
//                        let dataString = String(line.dropFirst(6).trimmingCharacters(in: .whitespacesAndNewlines))
//
//                        // Check for the stream termination signal
//                        if dataString == "[DONE]" {
//                            continuation.finish() // Successfully finished stream
//                            return
//                        }
//
//                        // Decode the JSON chunk
//                        guard let data = dataString.data(using: .utf8) else { continue }
//
//                        do {
//                            let streamResponse = try JSONDecoder().decode(ChatStreamResponse.self, from: data)
//                            if let content = streamResponse.choices.first?.delta.content {
//                                continuation.yield(content) // Yield the text fragment
//                            }
//                        } catch {
//                            // Handle potential JSON decoding errors within the stream
//                             print("Stream decoding error: \(error) for line: \(dataString)")
//                             // Decide whether to continue or fail the stream based on error severity
//                             // For now, we'll just print and continue, but you might want to throw.
//                            // continuation.finish(throwing: APIError.decodingError(error))
//                            // return
//                        }
//                    }
//                    // If the loop finishes without [DONE], it might indicate an issue.
//                    // Depending on API behavior, you might want to finish successfully or throw here.
//                     continuation.finish() // Assume successful completion if loop ends cleanly
//
//                } catch let error as APIError {
//                     continuation.finish(throwing: error)
//                } catch URLError.cancelled {
//                    // Handle task cancellation gracefully
//                    print("API request cancelled.")
//                    continuation.finish() // Finish cleanly on cancellation
//                }
//                catch {
//                    continuation.finish(throwing: APIError.requestFailed(error))
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Enhanced Chat View with Real API Integration
//
//struct ChatView: View { // Renamed back to ChatView for consistency if used elsewhere
//    @State private var messages: [Message] = [] // Start empty
//    @State private var newMessageText: String = ""
//    @State private var isWaitingForResponse: Bool = false
//    @State private var selectedModel: Message.AIModel = .gpt_3_5_turbo // Default model
//    @State private var currentError: String? = nil
//    
//    // Store the Task handle for potential cancellation
//    @State private var currentApiTask: Task<Void, Never>? = nil
//
//    private let openAIService = OpenAIService()
//
//    var body: some View {
//        VStack(spacing: 0) {
//            ModelSelectorView(selectedModel: $selectedModel)
//                 .disabled(isWaitingForResponse) // Disable model change while waiting
//                 .padding(.bottom, 5)
//
//            Divider()
//
//            ScrollViewReader { scrollViewProxy in
//                ScrollView {
//                    LazyVStack(spacing: 12) {
//                        // Initial prompt if messages are empty
//                         if messages.isEmpty && !isWaitingForResponse && currentError == nil {
//                             Text("Select a model and start chatting!")
//                                 .font(.caption)
//                                 .foregroundColor(.gray)
//                                 .padding()
//                         }
//                        
//                        ForEach($messages) { $message in // Binding ForEach
//                            MessageBubble(message: $message)
//                                .id(message.id)
//                        }
//                        if isWaitingForResponse {
//                            TypingIndicatorBubble()
//                                .id("typingIndicator")
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top)
//                }
//                .onChange(of: messages.count) { // Scroll when message count changes
//                    scrollToBottom(proxy: scrollViewProxy, targetId: messages.last?.id)
//                }
//                 .onChange(of: messages.last?.text) { // Scroll as text streams
//                       // Only scroll if the text change is for the *last* message
//                      if let lastMsgId = messages.last?.id, messages.last?.isUser == false {
//                         scrollToBottom(proxy: scrollViewProxy, targetId: lastMsgId)
//                      }
//                 }
//                .onChange(of: isWaitingForResponse) { // Scroll when typing indicator appears/disappears
//                    if isWaitingForResponse {
//                        // Scroll to the indicator when it appears
//                       scrollToBottom(proxy: scrollViewProxy, targetId: "typingIndicator")
//                    } else {
//                         // Scroll to the last message when indicator disappears
//                        scrollToBottom(proxy: scrollViewProxy, targetId: messages.last?.id)
//                    }
//                }
//            }
//
//            // --- Error Display Area ---
//            if let error = currentError {
//                 ErrorDisplayView(errorMessage: error) {
//                     currentError = nil // Action to dismiss error
//                 }
//                 .transition(.move(edge: .bottom).combined(with: .opacity))
//            }
//
//            // --- Input Area ---
//            HStack {
//                TextField("Ask \(selectedModel.displayName)...", text: $newMessageText, axis: .vertical)
//                    .textFieldStyle(.plain)
//                    .padding(10)
//                    .background(Color(white: 0.15))
//                    .cornerRadius(18)
//                    .lineLimit(1...5)
//                    .disabled(isWaitingForResponse)
//
//                Button {
//                    if isWaitingForResponse {
//                         cancelCurrentRequest()
//                    } else {
//                         initiateApiCall()
//                    }
//                } label: {
//                    Image(systemName: isWaitingForResponse ? "stop.circle.fill" : "arrow.up.circle.fill")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .foregroundColor(isWaitingForResponse ? .red : (newMessageText.isEmpty ? .gray : .yellow))
//                }
//                .disabled(newMessageText.isEmpty && !isWaitingForResponse) // Can always stop
//            }
//            .padding()
//            .background(Color(white: 0.1)) // Input area background
//        }
//        .background(Color.black.ignoresSafeArea())
//        .foregroundColor(.white)
//        .onDisappear {
//            cancelCurrentRequest() // Cancel request if view disappears
//        }
//    }
//
//    // --- Helper Functions ---
//    
//    func scrollToBottom<ID: Hashable>(proxy: ScrollViewProxy, targetId: ID?) {
//         guard let targetId = targetId else { return }
//         withAnimation(.spring(duration: 0.3)) { // Smoother animation
//             proxy.scrollTo(targetId, anchor: .bottom)
//         }
//     }
//
//    func initiateApiCall() {
//        guard !newMessageText.isEmpty else { return }
//        
//        cancelCurrentRequest() // Cancel any existing request first
//        currentError = nil // Clear previous errors
//        
//        // 1. Add User Message
//        let userMessage = Message(text: newMessageText, isUser: true)
//        messages.append(userMessage)
//        newMessageText = ""
//
//        // 2. Prepare for AI Response (Add Placeholder)
//        let aiPlaceholderMessageId = UUID()
//        let aiPlaceholderMessage = Message(
//             text: "", // Start empty
//             isUser: false,
//             sourceModel: selectedModel,
//             isLoading: true // Indicate this is being loaded
//         )
//        messages.append(aiPlaceholderMessage)
//        isWaitingForResponse = true
//        
//        // 3. Prepare messages for API
//        let apiMessages = messages.filter{ !$0.isLoading }.map { msg in // Don't send loading placeholders
//             OpenAIRequestMessage(role: msg.isUser ? "user" : "assistant", content: msg.text)
//         }
//
//        // 4. Start API Call Task
//        currentApiTask = Task {
//            do {
//                let stream = openAIService.streamChatCompletion(messages: apiMessages, model: selectedModel)
//                
//                 // Find the index of our placeholder message *before* the loop
//                 guard let placeholderIndex = messages.firstIndex(where: { $0.id == aiPlaceholderMessageId }) else {
//                     // This should ideally not happen if added correctly
//                     print("Error: Placeholder message not found.")
//                     currentError = "Internal error: Could not find message placeholder."
//                     isWaitingForResponse = false // Stop loading state
//                     // Remove the failed placeholder? Or mark with error?
//                    if let index = messages.firstIndex(where: { $0.id == aiPlaceholderMessageId }) {
//                         messages[index].error = "Internal error"
//                         messages[index].isLoading = false
//                    }
//                     return
//                 }
//                
//                // Ensure UI updates happen on the main thread
//                @MainActor func updateMessageText(fragment: String) {
//                  messages[placeholderIndex].text += fragment
//                  messages[placeholderIndex].isLoading = false // Mark as not loading once first fragment arrives
//                }
//
//                for try await fragment in stream {
//                     // Check if task was cancelled *during* streaming
//                    if Task.isCancelled {
//                           print("Streaming cancelled.")
//                        // Update the partly streamed message state if needed
//                         messages[placeholderIndex].isLoading = false
//                         messages[placeholderIndex].error = "Cancelled" // Optional: Mark as cancelled
//                           break // Exit the loop
//                    }
//                     await updateMessageText(fragment: fragment)
//                }
//
//                // Stream finished successfully (or cancellation handled)
//                if !Task.isCancelled {
//                     messages[placeholderIndex].isLoading = false // Ensure loading is false on successful completion
//                }
//
//            } catch let error as OpenAIService.APIError {
//                // Handle specific API errors
//                await MainActor.run { // Ensure UI updates on main thread
//                     currentError = formatError(error)
//                     // Mark the placeholder message with an error
//                     if let index = messages.firstIndex(where: { $0.id == aiPlaceholderMessageId }) {
//                          messages[index].isLoading = false
//                          messages[index].error = currentError
//                         messages[index].text = "" // Clear any potentially streamed fragments on error
//                     } else {
//                         // If placeholder not found, maybe add a general error message?
//                         print("Error occurred but placeholder message was lost.")
//                     }
//                }
//            } catch {
//                // Handle other unexpected errors
//                await MainActor.run {
//                    currentError = "An unexpected error occurred: \(error.localizedDescription)"
//                    if let index = messages.firstIndex(where: { $0.id == aiPlaceholderMessageId }) {
//                         messages[index].isLoading = false
//                         messages[index].error = "Unexpected Error"
//                        messages[index].text = ""
//                    }
//                }
//            }
//
//            // Ensure loading state is reset *after* the task finishes or throws
//             await MainActor.run {
//                isWaitingForResponse = false
//            }
//        }
//    }
//    
//    func cancelCurrentRequest() {
//         currentApiTask?.cancel() // Request cancellation
//         currentApiTask = nil
//         // Update UI immediately
//         isWaitingForResponse = false
//         // Find any message that was loading and mark it as cancelled or remove it
//          if let loadingIndex = messages.firstIndex(where: { $0.isLoading }) {
//              messages[loadingIndex].isLoading = false
//              messages[loadingIndex].error = "Cancelled by user"
//              // Optional: Remove the cancelled placeholder if it has no text
//              if messages[loadingIndex].text.isEmpty {
//                   messages.remove(at: loadingIndex)
//              }
//          }
//     }
//
//    // Helper to format errors nicely
//    func formatError(_ error: OpenAIService.APIError) -> String {
//        switch error {
//        case .missingApiKey:
//            return "API Key Missing: Please configure your API key in the code (OpenAIService.swift)."
//        case .requestFailed(let underlyingError):
//            return "Network Request Failed: \(underlyingError.localizedDescription)"
//        case .invalidResponse:
//            return "Invalid Response: Received an unexpected response from the server."
//        case .apiError(let message):
//            return "API Error: \(message)"
//        case .decodingError:
//            return "Data Error: Failed to decode the server response."
//        case .dataParsingError:
//            return "Stream Error: Failed to parse data from the stream."
//        case .invalidURL:
//             return "Configuration Error: Invalid API URL." // Should not happen normally
//        }
//    }
//}
//
//// MARK: - Helper UI Components (Mostly Unchanged)
//
//struct ModelSelectorView: View {
//    @Binding var selectedModel: Message.AIModel
//
//    var body: some View {
//        HStack {
//            Text("AI Model:")
//                .font(.caption)
//                .foregroundColor(.gray)
//            Picker("Select Model", selection: $selectedModel) {
//                ForEach(Message.AIModel.allCases, id: \.self) { model in
//                    // Use displayName for user-facing text
//                    Text(model.displayName).tag(model)
//                }
//            }
//            .pickerStyle(.menu)
//            .tint(.yellow) // Use tint instead of accentColor for modern pickers
//            .padding(.horizontal, -10)
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 5)
//        .background(Color(white: 0.05))
//    }
//}
//
//struct MessageBubble: View {
//    @Binding var message: Message // Needs binding to update text during stream
//
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 8) {
//            if message.isUser { Spacer() }
//
//            if !message.isUser, let model = message.sourceModel {
//                Image(systemName: model.systemImageName)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .padding(.bottom, 5)
//                    .help("Model: \(model.rawValue)") // Accessibility hint
//            }
//
//            // Display text or a placeholder if loading/error and text is empty
//            Text(messageTextToShow())
//                .padding(12)
//                .background(messageContentBackground())
//                .foregroundColor(messageTextColor())
//                .cornerRadius(15)
//                .frame(maxWidth: 300, alignment: message.isUser ? .trailing : .leading)
//                 .overlay( // Add overlay for error border if needed
//                     message.error != nil ?
//                     RoundedRectangle(cornerRadius: 15)
//                         .stroke(Color.red.opacity(0.7), lineWidth: 1.5) // Make error more visible
//                     : nil
//                 )
//              .contextMenu { // Add context menu for copying
//                 Button {
//                     UIPasteboard.general.string = message.text
//                 } label: {
//                     Label("Copy", systemImage: "doc.on.doc")
//                 }
//              }
//
//            if !message.isUser { Spacer() }
//        }
//        .transition(.scale(scale: 0.9, anchor: message.isUser ? .topTrailing : .topLeading).combined(with: .opacity)) // Add transition
//    }
//
//     // Decide what text to show based on state
//    private func messageTextToShow() -> String {
//        if message.error != nil && message.text.isEmpty {
//            return "Error: \(message.error!)" // Show error text directly if message text is empty
//        } else if message.isLoading && message.text.isEmpty {
//             return "..." // Simple placeholder while loading first fragment
//        }
//        return message.text
//    }
//
//    @ViewBuilder
//    private func messageContentBackground() -> some View {
//        if message.isUser {
//            Color.yellow.opacity(0.9)
//        } else if message.error != nil {
//            Color.red.opacity(0.3) // Less intense error background
//        } else {
//            Color(white: 0.25)
//        }
//    }
//    
//    private func messageTextColor() -> Color {
//        if message.isUser {
//            return .black
//        } else if message.error != nil {
//             return .white.opacity(0.9) // Ensure error text is readable
//        } else {
//            return .white
//        }
//    }
//}
//
//struct TypingIndicatorBubble: View {
//    @State private var scale: CGFloat = 0.5
//    let animation = Animation.easeInOut(duration: 0.4).repeatForever(autoreverses: true)
//
//    var body: some View {
//         HStack(spacing: 4) {
//            ForEach(0..<3) { i in
//                Circle()
//                    .fill(Color.gray.opacity(0.7)) // Slightly transparent
//                    .frame(width: 8, height: 8)
//                    .scaleEffect(scale)
//                    .animation(animation.delay(Double(i) * 0.15), value: scale)
//            }
//        }
//        .padding(12)
//        .background(Color(white: 0.25))
//        .cornerRadius(15)
//        .onAppear { scale = 1.0 }
//        .frame(maxWidth: 300, alignment: .leading)
//         .transition(.scale(scale: 0.5, anchor: .bottomLeading).combined(with: .opacity)) // Add transition
//    }
//}
//
//struct ErrorDisplayView: View {
//    let errorMessage: String
//    let dismissAction: () -> Void
//
//    var body: some View {
//        HStack(spacing: 8) {
//            Image(systemName: "exclamationmark.triangle.fill")
//                .foregroundColor(.red)
//            Text(errorMessage)
//                .font(.caption)
//                .lineLimit(2)
//                .foregroundColor(.red.opacity(0.9)) // Make error text clearer
//            Spacer()
//            Button(action: dismissAction) {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.gray.opacity(0.8))
//            }
//        }
//        .padding(10)
//        .background(Color.red.opacity(0.15).blur(radius: 30)) // Soft background
//        .cornerRadius(8)
//        .overlay(
//          RoundedRectangle(cornerRadius: 8)
//             .stroke(Color.red.opacity(0.3), lineWidth: 1)
//        )
//        .padding(.horizontal)
//        .padding(.bottom, 5)
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    // It's hard to fully preview API calls, but we can set up the initial state
//    NavigationView {
//        ChatView() // Use the final ChatView name
//            .navigationTitle("Real AI Chat")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbarColorScheme(.dark, for: .navigationBar)
//            .toolbarBackground(.visible, for: .navigationBar)
//            .toolbarBackground(Color.black, for: .navigationBar) // Explicit background color
//    }
//    .preferredColorScheme(.dark)
//    .tint(.yellow) // Apply tint globally for previews
//}
