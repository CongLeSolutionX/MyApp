////
////  GeminiChatView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//import SwiftUI
//import Combine // Needed for ObservableObject
//
//// MARK: - Constants & Configuration
//
//// !!! --- VERY IMPORTANT: API Key Handling --- !!!
//// Replace this with a secure method in a real app (Environment Variable, Config File)
//// DO NOT HARDCODE YOUR REAL KEY HERE AND COMMIT IT.
//let geminiApiKeyPlaceholder: String = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? "YOUR_API_KEY_HERE" // Placeholder!
//
//// --- API Endpoint Configuration ---
//// Replace with the actual Gemini API endpoint URL
//let geminiApiEndpoint: String = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent" // Example endpoint
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
//    case model
//}
//
//struct ChatMessage: Identifiable, Equatable, Codable {
//    let id: UUID
//    var role: MessageRole
//    var text: String
//    var timestamp: Date
//    var isLoading: Bool = false
//    var isErrorPlaceholder: Bool = false
//
//    var formattedTimestamp: String {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .short
//        return formatter.string(from: timestamp)
//    }
//
//    static let userExample = ChatMessage(id: UUID(), role: .user, text: "Tell me a fun fact about Swift.", timestamp: Date().addingTimeInterval(-60))
//    static let modelExample = ChatMessage(id: UUID(), role: .model, text: "Swift was created by Chris Lattner!", timestamp: Date())
//    static let modelLoadingExample = ChatMessage(id: UUID(), role: .model, text: "...", timestamp: Date(), isLoading: true)
//}
//
//// --- API Request/Response Models (Adapt to actual Gemini API spec) ---
//
//struct APIRequestBody: Codable {
//    let contents: [Content]
//
//    struct Content: Codable {
//        let parts: [Part]
//    }
//
//    struct Part: Codable {
//        let text: String
//    }
//}
//
//struct APIResponseBody: Codable {
//    let candidates: [Candidate]?
//    let error: APIErrorDetail? // Check if Gemini uses this structure for errors
//
//    struct Candidate: Codable {
//        let content: Content?
//        // Add other fields like finishReason, safetyRatings if needed
//    }
//
//    struct Content: Codable {
//        let parts: [Part]?
//        // Add role if needed
//    }
//
//    struct Part: Codable {
//        let text: String?
//    }
//
//     // Structure for potential inline errors from the API response body
//     struct APIErrorDetail: Codable {
//          let code: Int?
//          let message: String?
//          let status: String?
//     }
//
//     // Helper to extract the primary text response
//     func extractText() -> String? {
//          guard let candidates = candidates,
//                !candidates.isEmpty,
//                let content = candidates.first?.content,
//                let parts = content.parts,
//                !parts.isEmpty,
//                let text = parts.first?.text
//          else {
//               // Check for an API-level error message within the response body
//               if let apiError = self.error {
//                    return "API Error: \(apiError.message ?? "Unknown error") (Status: \(apiError.status ?? "N/A"))"
//               }
//               return nil // Or return a default error message
//          }
//          return text
//     }
//}
//
//// MARK: - API Service Layer
//
//enum APIError: Error, LocalizedError {
//    case invalidURL
//    case requestFailed(Error)
//    case invalidResponse(statusCode: Int)
//    case decodingError(Error)
//    case noData
//    case missingApiKey
//    case apiErrorResponse(message: String) // For errors returned in the response body
//
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL: return "The API endpoint URL is invalid."
//        case .requestFailed(let error): return "Network request failed: \(error.localizedDescription)"
//        case .invalidResponse(let statusCode): return "Received an invalid response from the server (Status Code: \(statusCode))."
//        case .decodingError(let error): return "Failed to decode the server response: \(error.localizedDescription)"
//        case .noData: return "No data received from the server."
//        case .missingApiKey: return "API Key is missing. Please configure it securely."
//        case .apiErrorResponse(let message): return "API Error: \(message)"
//        }
//    }
//}
//
//protocol ChatAPIService {
//    func generateResponse(for prompt: String, apiKey: String) async throws -> String
//}
//
//class GeminiAPIService: ChatAPIService {
//
//    private let urlSession: URLSession
//    private let apiEndpointUrl: URL?
//
//    init(urlSession: URLSession = .shared, endpoint: String = geminiApiEndpoint) {
//        self.urlSession = urlSession
//        self.apiEndpointUrl = URL(string: endpoint)
//    }
//
//    func generateResponse(for prompt: String, apiKey: String) async throws -> String {
//        guard let url = apiEndpointUrl else {
//            throw APIError.invalidURL
//        }
//
//        guard !apiKey.isEmpty, apiKey != "YOUR_API_KEY_HERE" else {
//            throw APIError.missingApiKey
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        // Construct the Key Query Parameter - Adjust if Header is needed instead
//        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
//             throw APIError.invalidURL
//        }
//        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
//        guard let finalUrl = components.url else {
//              throw APIError.invalidURL
//        }
//        request.url = finalUrl // Use the URL with the key parameter
//
//        // --- Prepare Request Body ---
//        let requestBody = APIRequestBody(
//            contents: [
//                .init(parts: [.init(text: prompt)])
//            ]
//        )
//
//        do {
//            request.httpBody = try JSONEncoder().encode(requestBody)
//        } catch {
//            throw APIError.requestFailed(error) // Or a specific encoding error
//        }
//
//        // --- Perform Network Request ---
//        let data: Data
//        let response: URLResponse
//        do {
//            (data, response) = try await urlSession.data(for: request)
//        } catch {
//            throw APIError.requestFailed(error)
//        }
//
//        // --- Validate Response ---
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw APIError.invalidResponse(statusCode: -1) // Indicate non-HTTP response
//        }
//
//       guard (200...299).contains(httpResponse.statusCode) else {
//            // Try to decode potential error structure from the body even on non-2xx
//            if let errorBody = try? JSONDecoder().decode(APIResponseBody.self, from: data),
//               let apiErrorMsg = errorBody.error?.message {
//                throw APIError.apiErrorResponse(message: "\(apiErrorMsg) (Status Code: \(httpResponse.statusCode))")
//            }
//            // Fallback to general status code error
//            throw APIError.invalidResponse(statusCode: httpResponse.statusCode)
//        }
//
//        guard !data.isEmpty else {
//            throw APIError.noData
//        }
//
//        // --- Decode Success Response ---
//        do {
//            let decodedResponse = try JSONDecoder().decode(APIResponseBody.self, from: data)
//            if let text = decodedResponse.extractText() {
//                 // Check again if the extracted text is actually an error message reported by the API
//                  if let apiError = decodedResponse.error {
//                      throw APIError.apiErrorResponse(message: apiError.message ?? "Unknown API Error")
//                  }
//                return text
//            } else if let apiError = decodedResponse.error {
//                 // Handle case where candidates might be missing but error is present
//                 throw APIError.apiErrorResponse(message: apiError.message ?? "Unknown API Error")
//            } else {
//                throw APIError.decodingError(NSError(domain: "GeminiAPIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not extract text from response."]))
//            }
//        } catch {
//            // If decoding fails, throw a specific decoding error
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
//    @Published var useMockData: Bool = true // Toggle state
//
//    private var cancellables = Set<AnyCancellable>()
//    private let apiService: ChatAPIService // Use the protocol
//
//    init(apiService: ChatAPIService = GeminiAPIService()) {
//        self.apiService = apiService
//        loadInitialMessages() // Or load from persistence
//
//        // Trigger alert when errorMessage is set
//        $errorMessage
//            .compactMap { $0 }
//            .sink { [weak self] _ in
//                self?.isShowingErrorAlert = true
//            }
//            .store(in: &cancellables)
//    }
//
//    func loadInitialMessages() {
//        // Mock data for initial view
//        chatMessages = [
//            ChatMessage(id: UUID(), role: .user, text: "Hello!", timestamp: Date().addingTimeInterval(-120)),
//            ChatMessage(id: UUID(), role: .model, text: "Hi there! Use the toggle for real/mock responses.", timestamp: Date().addingTimeInterval(-110))
//        ]
//    }
//
//    func sendMessage() {
//        let textToSend = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !textToSend.isEmpty, !isProcessing else { return }
//
//        // 1. Add user message
//        let userMessage = ChatMessage(id: UUID(), role: .user, text: textToSend, timestamp: Date())
//        chatMessages.append(userMessage)
//
//        // 2. Add temporary "typing" indicator
//        let loadingMessageId = UUID()
//        let loadingMessage = ChatMessage(id: loadingMessageId, role: .model, text: "...", timestamp: Date(), isLoading: true)
//        chatMessages.append(loadingMessage)
//
//        // 3. Clear input & set processing state
//        userInput = ""
//        isProcessing = true
//
//        // 4. Perform Mock or Real API Call
//        Task {
//            var modelResponseText: String = ""
//            var isError = false
//
//            do {
//                if useMockData {
//                    // --- MOCK LOGIC ---
//                    try await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_500_000_000)) // Shorter delay for mock
//                    if textToSend.lowercased().contains("error") { // Simulate error in mock
//                        throw APIError.requestFailed(NSError(domain: "MockError", code: 500))
//                    }
//                    modelResponseText = "[MOCK] You said: \(textToSend). Try asking about *SwiftUI* or `dogs`!"
//                } else {
//                    // --- REAL API LOGIC ---
//                    modelResponseText = try await apiService.generateResponse(for: textToSend, apiKey: geminiApiKeyPlaceholder)
//                     // Add marker for clarity
//                     modelResponseText = "[REAL] \(modelResponseText)"
//                }
//            } catch let error as APIError {
//                modelResponseText = error.localizedDescription
//                isError = true
//                self.errorMessage = error.localizedDescription // Prepare alert message
//            } catch { // Catch any other unexpected errors
//                modelResponseText = "An unexpected error occurred: \(error.localizedDescription)"
//                isError = true
//                self.errorMessage = modelResponseText
//            }
//
//            // 5. Update UI on Main Thread
//            await MainActor.run {
//                updateOrReplaceMessage(
//                    id: loadingMessageId,
//                    newText: modelResponseText,
//                    isError: isError
//                )
//                isProcessing = false
//                // Error alert is triggered by the $errorMessage publisher sink
//            }
//        }
//    }
//
//    private func updateOrReplaceMessage(id: UUID, newText: String, isError: Bool) {
//        if let index = chatMessages.firstIndex(where: { $0.id == id }) {
//            chatMessages[index] = ChatMessage(
//                id: id, // Keep ID for stability
//                role: .model,
//                text: newText,
//                timestamp: Date(),
//                isLoading: false,
//                isErrorPlaceholder: isError
//            )
//        }
//    }
//}
//
//// MARK: - Views
//
//struct OptimizedGeminiChatView: View {
//    @StateObject private var viewModel = ChatViewModel() // Default ViewModel initialization
//
//    var body: some View {
//        VStack(spacing: 0) {
//            if viewModel.chatMessages.isEmpty {
//                EmptyStateView()
//            } else {
//                ChatScrollView(viewModel: viewModel)
//            }
//
//            Divider()
//
//            InputAreaView(
//                userInput: $viewModel.userInput,
//                isProcessing: viewModel.isProcessing,
//                placeholder: "Ask Gemini (\(viewModel.useMockData ? "Mock" : "Real"))...",
//                sendMessageAction: viewModel.sendMessage
//            )
//        }
//        .navigationTitle("Gemini Chat")
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar { // Add the toggle to the toolbar
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Toggle(isOn: $viewModel.useMockData) {
//                    Text("Mock") // Simple label for the toggle
//                }
//                .toggleStyle(.switch) // Or .button for a different look
//            }
//        }
//        .ignoresSafeArea(.keyboard, edges: .bottom)
//        .alert("Error", isPresented: $viewModel.isShowingErrorAlert, presenting: viewModel.errorMessage) { _ in
//            // Default OK button
//        } message: { errorText in
//            Text(errorText)
//        }
//         // Optional background
//          .background(Color(.systemGroupedBackground).ignoresSafeArea())
//    }
//}
//
//// Extracted Empty State View
//struct EmptyStateView: View {
//    var body: some View {
//        VStack {
//            Spacer()
//            Image(systemName: "bubble.left.and.bubble.right")
//                .font(.system(size: 50))
//                .padding(.bottom, 10)
//                .foregroundColor(.secondary)
//            Text("Start Chatting!")
//                .font(.title2)
//                .foregroundColor(.secondary)
//            Text("Send a message to begin. Use the toggle to switch between Real API and Mock Data.")
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
//// Extracted Scroll View for Chat Messages
//struct ChatScrollView: View {
//    @ObservedObject var viewModel: ChatViewModel // Use ObservedObject for passed view models
//
//    var body: some View {
//        ScrollViewReader { scrollViewProxy in
//            ScrollView {
//                LazyVStack(alignment: .leading, spacing: StyleConstants.verticalPadding) {
//                    ForEach(viewModel.chatMessages) { message in
//                        MessageBubbleView(message: message)
//                            .id(message.id) // Important for ScrollViewReader
//                    }
//                }
//                .padding(.horizontal, StyleConstants.horizontalPadding)
//                .padding(.top, StyleConstants.verticalPadding)
//            }
//            .onChange(of: viewModel.chatMessages.count) { _, _ in
//                scrollToBottom(proxy: scrollViewProxy)
//            }
//            .onAppear {
//                scrollToBottom(proxy: scrollViewProxy, animated: false)
//            }
//        }
//    }
//
//    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
//        guard let lastMessageId = viewModel.chatMessages.last?.id else { return }
//        if animated {
//            withAnimation(.spring()) {
//                proxy.scrollTo(lastMessageId, anchor: .bottom)
//            }
//        } else {
//            proxy.scrollTo(lastMessageId, anchor: .bottom)
//        }
//    }
//}
//
//struct MessageBubbleView: View {
//    let message: ChatMessage
//
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 5) {
//            if message.role == .user {
//                Spacer()
//            }
//
//            VStack(alignment: message.role == .user ? .trailing : .leading) {
//                messageContent
//                    .padding(.vertical, 10)
//                    .padding(.horizontal, 14)
//                    .background(bubbleBackground)
//                    .foregroundColor(foregroundColor)
//                    .clipShape(RoundedRectangle(cornerRadius: StyleConstants.bubbleCornerRadius, style: .continuous))
//                    .contextMenu { // Context menu for copying
//                        if !message.isLoading && !message.text.isEmpty {
//                            Button {
//                                UIPasteboard.general.string = message.text
//                            } label: {
//                                Label("Copy Text", systemImage: "doc.on.doc")
//                            }
//                        }
//                    }
//                    // Add basic animation for bubbles appearing
//                    .transition(.scale(scale: 0.9, anchor: message.role == .user ? .bottomTrailing : .bottomLeading).combined(with: .opacity))
//
//                Text(message.formattedTimestamp)
//                    .font(.system(size: StyleConstants.timestampFontSize))
//                    .foregroundColor(.gray)
//            }
//            .frame(maxWidth: 300, alignment: message.role == .user ? .trailing : .leading)
//
//            if message.role == .model {
//                Spacer()
//            }
//        }
//        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: message.id) // Animate bubbles individually
//    }
//
//    @ViewBuilder
//    private var messageContent: some View {
//        if message.isLoading {
//            TypingIndicatorView()
//                .transition(.opacity) // Fade in/out typing indicator
//        } else {
//            // Use LocalizedStringKey for potential Markdown parsing
//            Text(LocalizedStringKey(message.text))
//                .textSelection(.enabled) // Allow text selection
//        }
//    }
//
//    private var bubbleBackground: Color {
//        switch message.role {
//        case .user:
//            return .blue
//        case .model:
//            // Slightly different color for error messages for accessibility
//            return message.isErrorPlaceholder ? Color.orange.opacity(0.7) : Color(.systemGray5)
//       }
//    }
//
//    private var foregroundColor: Color {
//         switch message.role {
//         case .user:
//             return .white
//         case .model:
//              // Ensure contrast, especially for errors
//              return message.isErrorPlaceholder ? Color.white : Color.primary
//         }
//    }
//}
//
//// Extracted Typing Indicator View
//struct TypingIndicatorView: View {
//     @State private var opacity: Double = 0.3 // State to drive animation
//
//     var body: some View {
//          HStack(spacing: 4) {
//                ForEach(0..<3) { i in
//                     Circle()
//                          .opacity(calculateOpacity(index: i))
//                          .frame(width: 6, height: 6)
//                }
//           }
//          .onAppear {
//               withAnimation(Animation.easeInOut(duration: 0.7).repeatForever()) {
//                    opacity = 1.0 // Trigger continuous animation via opacity change
//               }
//          }
//     }
//
//     // Calculate opacity based on index and the animated state
//     private func calculateOpacity(index: Int) -> Double {
//          let phaseShift = Double(index) * 0.2 // Delay each dot slightly
//          // Use a sine wave or similar function based on the animated opacity state
//          // This simple example just varies base opacity - a better approach would use `TimelineView` or phase animation if targeting iOS 15+
//          let baseOpacity = (opacity - 0.3) / 0.7 // Normalize 0.3-1.0 to 0-1
//          let dotPhase = (baseOpacity + phaseShift).truncatingRemainder(dividingBy: 1.0)
//          return max(0.3, dotPhase * 0.7 + 0.3) // Map back to 0.3 - 1.0 range
//
//          // Simpler fixed opacity version if animation above is complex:
//          // return [0.4, 0.7, 1.0][i]
//     }
//}
//
//struct InputAreaView: View {
//    @Binding var userInput: String
//    let isProcessing: Bool
//    let placeholder: String
//    let sendMessageAction: () -> Void
//
//    @FocusState private var isTextFieldFocused: Bool
//
//    var body: some View {
//        HStack(spacing: 12) {
//            TextField(placeholder, text: $userInput, axis: .vertical)
//                .focused($isTextFieldFocused)
//                .lineLimit(1...5)
//                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 30)) // Make space for clear button
//                .background(
//                    RoundedRectangle(cornerRadius: 20, style: .continuous)
//                              .fill(.regularMaterial) // Use material for adaptive background
//                )
//                .overlay( // Clear button
//                    HStack {
//                        Spacer()
//                        if !userInput.isEmpty {
//                            Button {
//                                userInput = ""
//                            } label: {
//                                Image(systemName: "xmark.circle.fill")
//                                    .foregroundColor(.secondary)
//                            }
//                            .padding(.trailing, 8)
//                            // Add animation for clear button appearing/disappearing
//                            .transition(.opacity.combined(with: .scale(scale: 0.8)))
//                        }
//                    }
//                    .animation(.easeInOut(duration: 0.2), value: userInput.isEmpty)
//                )
//
//            Button {
//                sendMessageAction()
//                isTextFieldFocused = false // Dismiss keyboard on send
//            } label: {
//                Group { // Use Group for animated transition
//                    if isProcessing {
//                        ProgressView()
//                             .tint(.blue) // Match button color
//                    } else {
//                        Image(systemName: "arrow.up.circle.fill")
//                            .resizable()
//                            .foregroundColor(isSendButtonEnabled ? .blue : Color.gray.opacity(0.5))
//                    }
//                }
//                .frame(width: 28, height: 28)
//            }
//            .disabled(!isSendButtonEnabled || isProcessing)
//            .animation(.easeInOut, value: isProcessing) // Animate progress/send icon
//            .keyboardShortcut(.return, modifiers: .command) // Cmd+Enter
//            .keyboardShortcut(.defaultAction) // Enter on external keyboard
//            .sensoryFeedback(.impact(weight: .medium), trigger: isProcessing && !userInput.isEmpty) // Haptic feedback
//
//        }
//        .padding(EdgeInsets(top: 8, leading: StyleConstants.horizontalPadding, bottom: 8, trailing: StyleConstants.horizontalPadding))
//        .background(.thinMaterial) // Background for the whole input area
//    }
//
//     // Computed property for button enable state
//     private var isSendButtonEnabled: Bool {
//          !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//     }
//}
//
//// MARK: - Preview
//
//#Preview("Live Chat") {
//    NavigationView { // Wrap in NavigationView for Title and Toolbar
//        OptimizedGeminiChatView()
//    }
//}
//
//#Preview("Empty Chat") {
//     NavigationView {
//          //OptimizedGeminiChatView(viewModel: ChatViewModel(messages: [])) // Explicit empty state
//         OptimizedGeminiChatView()
//     }
//}
//
//// MARK: - Helper Extensions
//
//// Allow initializing ViewModel with specific initial messages for previews
//extension ChatViewModel {
//    convenience init(messages: [ChatMessage]) {
//        self.init() // Use default API service
//        self.chatMessages = messages
//    }
//}
