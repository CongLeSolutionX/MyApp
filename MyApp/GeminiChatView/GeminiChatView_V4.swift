////
////  GeminiChatView_V4.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//import SwiftUI
//import Combine
//
//// MARK: - Constants & Configuration
//
//// !!! --- VERY IMPORTANT: Secure API Key Handling --- !!!
//// Load from Environment Variable (preferred) or a non-committed config file.
//// DO NOT HARDCODE YOUR REAL KEY HERE AND COMMIT TO VERSION CONTROL.
//let geminiApiKeyPlaceholder: String = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? "YOUR_API_KEY_HERE" // Placeholder!
//
//// --- API Endpoint Configuration ---
//// Replace with the specific Gemini model endpoint you want to use
//let geminiApiEndpoint: String = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent"
//
//struct StyleConstants {
//    static let horizontalPadding: CGFloat = 15
//    static let verticalPadding: CGFloat = 10
//    static let bubbleCornerRadius: CGFloat = 18
//    static let timestampFontSize: CGFloat = 10
//}
//
//// MARK: - Data Models
//
//enum MessageRole: String, Codable {
//    case user
//    case model // Gemini API uses 'model' for its responses
//}
//
//struct ChatMessage: Identifiable, Equatable, Codable {
//    let id: UUID
//    var role: MessageRole
//    var text: String
//    var timestamp: Date
//    var isLoading: Bool = false
//    var isErrorPlaceholder: Bool = false // Used to style error messages differently
//
//    var formattedTimestamp: String {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .short
//        return formatter.string(from: timestamp)
//    }
//}
//
//// MARK: --- Gemini API Request/Response Models ---
//
//// Request body structure for Gemini generateContent
//struct APIRequestBody: Codable {
//    let contents: [Content]
//    // Add generationConfig, safetySettings etc. here if needed
//
//    struct Content: Codable {
//        // Role is not directly needed in the request 'content' for simple prompts,
//        // but parts are.
//        let parts: [Part]
//    }
//
//    struct Part: Codable {
//        let text: String
//    }
//}
//
//// Response body structure for Gemini generateContent
//struct APIResponseBody: Codable {
//    let candidates: [Candidate]?
//    let promptFeedback: PromptFeedback? // Optional feedback info
//    let error: APIErrorDetail?  // Catches errors returned within the JSON response body
//
//    struct Candidate: Codable {
//        let content: Content?
//        let finishReason: String?
//        let index: Int?
//        let safetyRatings: [SafetyRating]?
//    }
//
//    struct Content: Codable {
//        let parts: [Part]?
//        let role: String? // Should be "model"
//    }
//
//    struct Part: Codable {
//        let text: String?
//    }
//
//    struct PromptFeedback: Codable {
//        let safetyRatings: [SafetyRating]?
//    }
//
//    struct SafetyRating: Codable {
//        let category: String?
//        let probability: String?
//    }
//
//    // Structure for errors returned within the API response body itself
//    struct APIErrorDetail: Codable {
//         let code: Int?
//         let message: String?
//         let status: String? // e.g., "INVALID_ARGUMENT"
//    }
//
//    // Helper to extract the primary text response or an API error message
//    func extractText() -> String? {
//         guard let candidates = candidates,
//               !candidates.isEmpty,
//               let firstCandidate = candidates.first,
//               let content = firstCandidate.content,
//               let parts = content.parts,
//               !parts.isEmpty,
//               let text = parts.first?.text
//         else {
//              // If no text, check for an API error within the response
//              if let apiError = self.error {
//                   return "API Error: \(apiError.message ?? "Unknown Gemini error") (\(apiError.status ?? "Status N/A"))"
//              }
//              return nil // Could not extract text or error
//         }
//         return text
//    }
//}
//
//// MARK: - API Service Layer
//
//enum APIError: Error, LocalizedError {
//    case invalidURL
//    case requestFailed(Error) // Underlying network error
//    case invalidResponse(statusCode: Int) // Non-2xx HTTP status
//    case decodingError(Error) // JSON parsing failed
//    case noData
//    case missingApiKey
//    case apiErrorResponse(message: String) // Specific error message from API JSON body
//
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL: return "The Gemini API endpoint URL is invalid."
//        case .requestFailed(let error): return "Network request failed: \(error.localizedDescription)"
//        case .invalidResponse(let statusCode): return "Received an invalid server response (Status Code: \(statusCode)). Check API Key and endpoint."
//        case .decodingError(let error): return "Failed to decode the Gemini API response: \(error.localizedDescription)"
//        case .noData: return "No data received from the Gemini API."
//        case .missingApiKey: return ServiceConstants.apiKeyInstructions // Provide guidance
//        case .apiErrorResponse(let message): return message // Display the API's specific error
//        }
//    }
//}
//
//// Added for better API Key instructions
//struct ServiceConstants {
//    static let apiKeyInstructions = """
//    Gemini API Key is missing or invalid.
//    Please obtain a key from Google AI Studio and configure it securely.
//    Recommended Method: Set the 'GEMINI_API_KEY' environment variable in your Xcode Scheme (Run -> Arguments -> Environment Variables).
//    DO NOT commit your API key directly into the code.
//    """
//}
//
//protocol ChatAPIService {
//    func generateResponse(for prompt: String, apiKey: String) async throws -> String
//}
//
//class GeminiAPIService: ChatAPIService {
//
//    private let urlSession: URLSession
//    private let apiEndpointUrlString: String
//
//    init(urlSession: URLSession = .shared, endpoint: String = geminiApiEndpoint) {
//        self.urlSession = urlSession
//        self.apiEndpointUrlString = endpoint
//    }
//
//    func generateResponse(for prompt: String, apiKey: String) async throws -> String {
//        // 1. Validate API Key Presence
//        guard !apiKey.isEmpty, apiKey != "YOUR_API_KEY_HERE" else {
//            throw APIError.missingApiKey
//        }
//
//        // 2. Construct URL with API Key Query Parameter
//        guard var components = URLComponents(string: apiEndpointUrlString) else {
//             throw APIError.invalidURL
//        }
//        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
//        guard let finalUrl = components.url else {
//              throw APIError.invalidURL
//        }
//
//        // 3. Prepare Request
//        var request = URLRequest(url: finalUrl)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // 4. Prepare Request Body specific to Gemini API
//        let requestBody = APIRequestBody(
//            contents: [
//                .init(parts: [.init(text: prompt)])
//                // Future: Could add chat history here in 'contents' array
//            ]
//        )
//
//        do {
//            request.httpBody = try JSONEncoder().encode(requestBody)
//        } catch {
//            // More specific error could be thrown here if needed
//            throw APIError.requestFailed(error) // Error encoding request body
//        }
//
//        // 5. Perform Network Request
//        let data: Data
//        let response: URLResponse
//        do {
//            (data, response) = try await urlSession.data(for: request)
//        } catch {
//            // Handle network-level errors (connectivity etc.)
//            throw APIError.requestFailed(error)
//        }
//
//        // 6. Validate HTTP Response Status
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw APIError.invalidResponse(statusCode: -1) // Non-HTTP response (unlikely)
//        }
//
//        // 7. Handle Non-Successful Status Codes (Attempt to parse error from body)
//        guard (200...299).contains(httpResponse.statusCode) else {
//            // Try to decode Gemini's specific error structure from the body
//            if let errorBody = try? JSONDecoder().decode(APIResponseBody.self, from: data),
//               let apiErrorMsg = errorBody.error?.message {
//                 let statusDescription = errorBody.error?.status ?? "Status N/A"
//                throw APIError.apiErrorResponse(message: "API Error: \(apiErrorMsg) (Status: \(statusDescription), Code: \(httpResponse.statusCode))")
//            }
//            // Fallback to general HTTP status code error if body doesn't contain Gemini error
//            throw APIError.invalidResponse(statusCode: httpResponse.statusCode)
//        }
//
//        // 8. Check for Empty Data (though unlikely for 2xx if API is correct)
//        guard !data.isEmpty else {
//            throw APIError.noData
//        }
//
//        // 9. Decode Successful Response
//        do {
//            let decodedResponse = try JSONDecoder().decode(APIResponseBody.self, from: data)
//
//            // Use the helper to extract text OR an inline error message
//            if let textResponse = decodedResponse.extractText() {
//                 // Check if the extracted text is actually an error message structured by the API
//                 if let apiError = decodedResponse.error {
//                      throw APIError.apiErrorResponse(message: "API Error: \(apiError.message ?? "Unknown Gemini error") (\(apiError.status ?? "N/A"))")
//                 }
//                return textResponse // Success!
//            } else {
//                // This case means extractText() failed even without an explicit 'error' object in the root
//                throw APIError.decodingError(NSError(domain: "GeminiAPIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not extract text from the Gemini response structure."]))
//            }
//        } catch let error as APIError {
//             throw error // Re-throw APIError types directly
//        } catch {
//            // Catch JSON decoding errors or other unexpected issues during parsing
//            throw APIError.decodingError(error)
//        }
//    }
//}
//
//// MARK: - ViewModel
//
//@MainActor
//class ChatViewModel: ObservableObject {
//    @Published var chatMessages: [ChatMessage] = []
//    @Published var userInput: String = ""
//    @Published var isProcessing: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var isShowingErrorAlert: Bool = false
//    @Published var useMockData: Bool = true // Start with Mock by default
//
//    private var cancellables = Set<AnyCancellable>()
//    private let apiService: ChatAPIService
//
//    init(apiService: ChatAPIService = GeminiAPIService()) {
//        self.apiService = apiService
//        loadInitialMessages()
//
//        // Trigger alert when errorMessage is set
//        $errorMessage
//            .compactMap { $0 } // Only trigger if errorMessage is not nil
//            .receive(on: DispatchQueue.main) // Ensure alert presentation is on main thread
//            .sink { [weak self] _ in
//                self?.isShowingErrorAlert = true
//            }
//            .store(in: &cancellables)
//    }
//
//    func loadInitialMessages() {
//        if chatMessages.isEmpty { // Only load if empty
//            chatMessages = [
//                ChatMessage(id: UUID(), role: .user, text: "Hello Gemini!", timestamp: Date().addingTimeInterval(-120)),
//                ChatMessage(id: UUID(), role: .model, text: "Hi there! I'm ready. Use the toggle for real/mock responses.", timestamp: Date().addingTimeInterval(-110))
//            ]
//        }
//    }
//
//    func sendMessage() {
//        let textToSend = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !textToSend.isEmpty, !isProcessing else { return }
//
//        // --- Append User Message ---
//        let userMessage = ChatMessage(id: UUID(), role: .user, text: textToSend, timestamp: Date())
//        chatMessages.append(userMessage)
//
//        // --- Add Loading Indicator ---
//        let loadingMessageId = UUID()
//        let loadingMessage = ChatMessage(id: loadingMessageId, role: .model, text: "...", timestamp: Date(), isLoading: true)
//        chatMessages.append(loadingMessage)
//
//        userInput = ""
//        isProcessing = true
//        errorMessage = nil // Clear previous errors
//
//        // --- Start Background Task ---
//        Task {
//            var modelResponseText: String = ""
//            var isError = false
//            var errorToShow: String? = nil
//
//            do {
//                if useMockData {
//                    // --- Mock Logic ---
//                    try await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_500_000_000))
//                    if textToSend.lowercased().contains("mock error") {
//                        throw APIError.requestFailed(NSError(domain: "MockError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Simulated mock network failure."]))
//                    }
//                    modelResponseText = "[MOCK] You asked about: \(textToSend). Try asking about the Gemini API!"
//                } else {
//                    // --- Real API Call ---
//                    let realResponse = try await apiService.generateResponse(for: textToSend, apiKey: geminiApiKeyPlaceholder)
//                    modelResponseText = "[REAL] \(realResponse)" // Add prefix for clarity
//                }
//            } catch let error as APIError {
//                modelResponseText = "Error: \(error.localizedDescription)"
//                isError = true
//                errorToShow = error.localizedDescription
//            } catch { // Catch any other unexpected errors
//                modelResponseText = "An unexpected error occurred: \(error.localizedDescription)"
//                isError = true
//                errorToShow = modelResponseText
//            }
//
//            // --- Update UI on Main Thread ---
//            await MainActor.run {
//                updateOrReplaceMessage(
//                    id: loadingMessageId,
//                    newText: modelResponseText,
//                    isError: isError
//                )
//                isProcessing = false
//                // Setting errorMessage will trigger the alert via the publisher sink
//                self.errorMessage = errorToShow
//            }
//        }
//    }
//
//    private func updateOrReplaceMessage(id: UUID, newText: String, isError: Bool) {
//        if let index = chatMessages.firstIndex(where: { $0.id == id }) {
//             let updatedMessage = ChatMessage(
//                 id: id, // Reuse ID for stability
//                 role: .model,
//                 text: newText,
//                 timestamp: Date(),
//                 isLoading: false,
//                 isErrorPlaceholder: isError // Mark if it's an error message
//             )
//             // Replace the item to trigger UI update correctly
//             chatMessages[index] = updatedMessage
//        }
//    }
//}
//
//// Rest of the Views (OptimizedGeminiChatView, EmptyStateView, ChatScrollView, MessageBubbleView, TypingIndicatorView, InputAreaView) remain the same as in the previous response.
//
//// MARK: - SwiftUI Views (Keep the same as before)
//
//struct OptimizedGeminiChatView: View {
//     @StateObject private var viewModel = ChatViewModel() // Default ViewModel
//
//     var body: some View {
//          VStack(spacing: 0) {
//               if viewModel.chatMessages.isEmpty {
//                    EmptyStateView()
//               } else {
//                    ChatScrollView(viewModel: viewModel)
//               }
//
//               Divider()
//
//               InputAreaView(
//                    userInput: $viewModel.userInput,
//                    isProcessing: viewModel.isProcessing,
//                    placeholder: "Ask Gemini (\(viewModel.useMockData ? "Mock" : "Real"))...",
//                    sendMessageAction: viewModel.sendMessage
//               )
//          }
//          .navigationTitle("Gemini Chat")
//          .navigationBarTitleDisplayMode(.inline)
//          .toolbar {
//               ToolbarItem(placement: .navigationBarTrailing) {
//                    Toggle(isOn: $viewModel.useMockData) {
//                         Text("Mock") // Keep label short
//                    }
//                    .toggleStyle(.switch)
//               }
//          }
//          .ignoresSafeArea(.keyboard, edges: .bottom)
//          .alert("API Error", isPresented: $viewModel.isShowingErrorAlert, presenting: viewModel.errorMessage) { _ in
//               // Automatic OK button
//          } message: { errorText in
//               Text(errorText) // Display the specific error message
//          }
//          // .background(Color(.systemGroupedBackground).ignoresSafeArea()) // Optional background
//     }
//}
//
//struct EmptyStateView: View {
//    var body: some View {
//        VStack {
//            Spacer()
//            Image(systemName: "sparkles") // Gemini icon suggestion
//                .font(.system(size: 50))
//                .padding(.bottom, 10)
//                .foregroundColor(.purple) // Gemini color suggestion
//            Text("Chat with Gemini")
//                .font(.title2)
//                .foregroundColor(.secondary)
//            Text("Send a message to begin. Use the toggle to switch between the Real Gemini API and Mock Data.")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//            Spacer()
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//    }
//}
//
//struct ChatScrollView: View {
//    @ObservedObject var viewModel: ChatViewModel
//
//    var body: some View {
//        ScrollViewReader { scrollViewProxy in
//            ScrollView {
//                LazyVStack(alignment: .leading, spacing: StyleConstants.verticalPadding) {
//                    ForEach(viewModel.chatMessages) { message in
//                        MessageBubbleView(message: message)
//                            .id(message.id)
//                    }
//                }
//                .padding(.horizontal, StyleConstants.horizontalPadding)
//                .padding(.top, StyleConstants.verticalPadding)
//                // Padding at bottom to ensure last message isn't hidden by input bar
//                .padding(.bottom, StyleConstants.verticalPadding)
//            }
//            .onChange(of: viewModel.chatMessages.last?.id) { _, newValue in
//                 // Scroll when the actual last message ID changes (covers send & receive)
//                  if let lastId = newValue {
//                      scrollToBottom(proxy: scrollViewProxy, targetId: lastId)
//                  }
//             }
//             .onAppear {
//                  // Scroll on initial appear if there are messages
//                  if let lastId = viewModel.chatMessages.last?.id {
//                      scrollToBottom(proxy: scrollViewProxy, targetId: lastId, animated: false)
//                  }
//             }
//        }
//    }
//
//    private func scrollToBottom(proxy: ScrollViewProxy, targetId: UUID, animated: Bool = true) {
//        if animated {
//            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { // Smoother animation
//                proxy.scrollTo(targetId, anchor: .bottom)
//            }
//        } else {
//            proxy.scrollTo(targetId, anchor: .bottom)
//        }
//    }
//}
//
//struct MessageBubbleView: View {
//    let message: ChatMessage
//
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 5) {
//            if message.role == .user { Spacer(minLength: 50) } // Push user bubble right
//
//            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) { // Add spacing
//                messageContent
//                    .padding(.vertical, 10)
//                    .padding(.horizontal, 14)
//                    .background(bubbleBackground)
//                    .foregroundColor(foregroundColor)
//                    .clipShape(RoundedRectangle(cornerRadius: StyleConstants.bubbleCornerRadius, style: .continuous))
//                    .shadow(color: Color.black.opacity(message.role == .user ? 0.1 : 0.05), radius: 2, x: 1, y: 1) // Subtle shadow
//                    .contextMenu {
//                        if !message.isLoading && !message.text.isEmpty && !message.isErrorPlaceholder { // Only allow copying non-error messages
//                            Button {
//                                UIPasteboard.general.string = message.text.replacingOccurrences(of: "[REAL] ", with: "").replacingOccurrences(of: "[MOCK] ", with: "") // Copy without prefix
//                            } label: {
//                                Label("Copy Text", systemImage: "doc.on.doc")
//                            }
//                        }
//                    }
//                    .transition(.scale(scale: 0.95, anchor: message.role == .user ? .bottomTrailing : .bottomLeading).combined(with: .opacity))
//
//                Text(message.formattedTimestamp)
//                    .font(.system(size: StyleConstants.timestampFontSize))
//                    .foregroundColor(.gray)
//                    .padding(.horizontal, 5) // Indent timestamp slightly
//            }
//             // Allow bubble to take reasonable width, but not full screen
//            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.role == .user ? .trailing : .leading)
//
//            if message.role == .model { Spacer(minLength: 50) } // Push model bubble left
//        }
//        // Animate the entire HStack appearing/changing
//        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: message.id)
//    }
//
//    @ViewBuilder
//    private var messageContent: some View {
//        if message.isLoading {
//            TypingIndicatorView()
//                 .padding(.vertical, 5) // Give indicator some space
//                .transition(.opacity)
//        } else {
//            // Use LocalizedStringKey for potential future Markdown support in Text
//             // Apply specific styling for errors
//            Text(LocalizedStringKey(message.text))
//                 .font(message.isErrorPlaceholder ? .system(.body, design: .monospaced) : .body)
//                 .foregroundColor(message.isErrorPlaceholder ? .red : foregroundColor) // Red text for errors
//                .textSelection(.enabled)
//        }
//    }
//
//    private var bubbleBackground: Color {
//        // Error messages get a distinct background too
//        if message.isErrorPlaceholder {
//             return Color.red.opacity(0.15)
//        }
//
//        switch message.role {
//        case .user:
//            return .blue
//        case .model:
//              // Use slightly off-white for model bubbles
//            return Color(.systemGray6)
//        }
//    }
//
//    private var foregroundColor: Color {
//         // Let error text color be handled in messageContent view
//         if message.isErrorPlaceholder { return .primary } // Use primary to let .red modifier take effect
//
//         switch message.role {
//         case .user:
//             return .white
//         case .model:
//            return .primary // Standard text color on gray background
//         }
//    }
//}
//
//struct TypingIndicatorView: View {
//     @State private var scale: CGFloat = 0.5 // State to drive animation
//     let dotCount = 3
//     let animationDuration = 0.6
//
//     var body: some View {
//          HStack(spacing: 5) {
//               ForEach(0..<dotCount, id: \.self) { i in
//                    Circle()
//                         .frame(width: 7, height: 7)
//                          // Calculate delay based on index
//                         .scaleEffect(scale)
//                          // Apply animation with delay
//                         .animation(
//                              Animation.easeInOut(duration: animationDuration)
//                                   .repeatForever(autoreverses: true)
//                                   // Stagger the start of each dot's animation
//                                   .delay(animationDuration / Double(dotCount) * Double(i)),
//                              value: scale // Animate when scale changes
//                         )
//               }
//          }
//          .onAppear {
//               scale = 1.0 // Trigger the animation on appear
//          }
//           // Ensure the indicator takes up some space while loading
//          .padding(.horizontal, 5)
//     }
//}
//
//struct InputAreaView: View {
//     @Binding var userInput: String
//     let isProcessing: Bool
//     let placeholder: String
//     let sendMessageAction: () -> Void
//
//     @FocusState private var isTextFieldFocused: Bool
//
//     var body: some View {
//          HStack(spacing: 10) { // Adjusted spacing
//               // Use a ZStack for the clear button overlay
//               ZStack(alignment: .trailing) {
//                   TextField(placeholder, text: $userInput, axis: .vertical)
//                       .focused($isTextFieldFocused)
//                       .lineLimit(1...5) // Allow multi-line input
//                       .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 35)) // More padding, space for button
//                       .background(
//                           RoundedRectangle(cornerRadius: 22, style: .continuous)// Slightly larger radius
//                               .fill(Color(.systemGray6)) // Use a solid color for consistency
//                       )
//
//                    // Clear button appears only when text is present
//                    if !userInput.isEmpty {
//                        Button {
//                            userInput = ""
//                            isTextFieldFocused = true // Keep focus after clearing
//                        } label: {
//                            Image(systemName: "xmark.circle.fill")
//                                .foregroundColor(.secondary.opacity(0.8))
//                        }
//                        .padding(.trailing, 8)
//                         // Fade in/out animation for the clear button
//                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
//                    }
//               }
//                // Animate the ZStack (including button) based on userInput emptiness
//               .animation(.easeInOut(duration: 0.2), value: userInput.isEmpty)
//
//               Button {
//                    sendMessageAction()
//                    isTextFieldFocused = false
//               } label: {
//                    Group { // Group for smooth transition between ProgressView and Image
//                         if isProcessing {
//                              ProgressView()
//                                   .tint(.white) // Make spinner white on blue background
//                                    // Apply same frame size as the icon for consistent layout
//                                   .frame(width: 30, height: 30)
//                                    // Use a background shape matching the button
//                                   .background(
//                                        Circle().fill(Color.gray.opacity(0.5)) // Disabled look for bg
//                                   )
//
//                         } else {
//                              Image(systemName: "arrow.up")
//                                   .font(.system(size: 16, weight: .semibold)) // Slightly bolder icon
//                                   .foregroundColor(.white)
//                                   .frame(width: 30, height: 30)
//                                    // Change background color based on enabled state
//                                   .background(
//                                        Circle().fill(isSendButtonEnabled ? Color.blue : Color.gray.opacity(0.5))
//                                   )
//                         }
//                    }
//               }
//               .disabled(!isSendButtonEnabled || isProcessing)
//                // Animate the button state changes (enabled/disabled/processing)
//               .animation(.easeInOut(duration: 0.25), value: isProcessing)
//               .animation(.easeInOut(duration: 0.25), value: isSendButtonEnabled)
//                // Default action (Enter on hardware keyboard)
//               .keyboardShortcut(.defaultAction)
//                // Cmd+Enter shortcut
//               .keyboardShortcut(.return, modifiers: .command)
//                // Haptic feedback when send is tapped
//               .sensoryFeedback(.impact(weight: .medium), trigger: isProcessing && isSendButtonEnabled)
//
//          }
//           // Consistent padding for the input bar
//          .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
//           // Use a background material for adaptive appearance
//          .background(.thinMaterial)
//     }
//
//     private var isSendButtonEnabled: Bool {
//          !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//     }
//}
//
//// MARK: - Preview
//
//#Preview("Live Chat") {
//    NavigationView {
//        OptimizedGeminiChatView()
//            // Optionally inject a ViewModel configured for mock data for preview
//             // .environmentObject(ChatViewModel(apiService: MockChatService()))
//    }
//}
//
//// MARK: - Helper Extensions
//
//// Convenience initializer for ViewModel (useful for previews or specific states)
//extension ChatViewModel {
//    convenience init(messages: [ChatMessage], apiService: ChatAPIService = GeminiAPIService()) {
//        self.init(apiService: apiService)
//        self.chatMessages = messages
//    }
//}
