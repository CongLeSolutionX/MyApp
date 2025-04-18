////
////  ChatView_V10.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//import SwiftUI
//// 1. Import the GoogleGenerativeAI package
////import GoogleGenerativeAI
//
//
//// MARK: - API Key Placeholder
//// !!! IMPORTANT: Replace "YOUR_API_KEY" with your actual Google Gemini API key.
//let GEMINI_API_KEY = "YOUR_API_KEY"
//
//// MARK: - Data Models (No changes needed from previous version)
//
//struct Message: Identifiable {
//    let id = UUID()
//    var text: String
//    let isUser: Bool
//    let timestamp: Date = Date()
//    var sourceModel: AIModel? = nil
//    var isLoading: Bool = false
//    var error: String? = nil
//    // Renamed for clarity in non-streaming context
//    var isResponseComplete: Bool = false
//    
//    enum AIModel: String, CaseIterable {
//        case geminiPro = "Gemini Pro" // Matches SDK model name often used
//        
//        var systemImageName: String {
//            switch self {
//            case .geminiPro: return "sparkles.square.filled.on.square"
//            }
//        }
//    }
//}
//struct GenerativeModel {
//    
//}
//// MARK: - Chat View with Non-Streaming Gemini API Integration
//
//struct ChatView: View {
//    @State private var messages: [Message] = [
//        Message(text: "Hello! I'm using Gemini Pro (non-streaming). Ask me anything.", isUser: false, sourceModel: .geminiPro, isResponseComplete: true),
//    ]
//    @State private var newMessageText: String = ""
//    @State private var isWaitingForResponse: Bool = false // Indicates active API call
//    @State private var currentError: String? = nil        // Stores API/Network errors
//    
//    // Configure the Gemini Model (same as before)
//    private var geminiModel: GenerativeModel {
//        guard GEMINI_API_KEY != "YOUR_API_KEY" else {
//            // Handle missing key - returning a dummy won't work well here.
//            // The sendMessage function will handle the error display.
//            // For safety, still return a configured model but expect errors later.
//            return GenerativeModel(name: "gemini-pro", apiKey: "INVALID_KEY_PLACEHOLDER")
//        }
//        let config = GenerationConfig() // Add specific config if needed
//        return GenerativeModel
//    }
//    
//    // Maintain chat history using the SDK's Chat object
//    @State private var geminiChat: Chat? = nil
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            // Header (Model display - simplified)
//            HStack {
//                Text("Using: \(Message.AIModel.geminiPro.rawValue)")
//                    .font(.caption).foregroundColor(.gray)
//                Image(systemName: Message.AIModel.geminiPro.systemImageName)
//                    .font(.caption).foregroundColor(.yellow)
//                Spacer()
//            }   .padding(.horizontal)
//                .padding(.vertical, 5)
//                .background(Color(white: 0.05))
//            
//            Divider()
//            
//            // Message Display Area
//            ScrollViewReader { scrollViewProxy in
//                ScrollView {
//                    LazyVStack(spacing: 12) {
//                        // *** Use plain ForEach here, binding not strictly needed for non-streaming text update ***
//                        // *** But keep Binding ForEach for consistency if modifying error/loading state later ***
//                        ForEach($messages) { $message in
//                            MessageBubble(message: $message)
//                                .id(message.id)
//                        }
//                        if isWaitingForResponse {
//                            TypingIndicatorBubble().id("typingIndicator")
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top)
//                }
//                // Scroll logic (remains largely the same)
//                .onChange(of: messages.count) {
//                    scrollToBottom(proxy: scrollViewProxy)
//                }
//                .onChange(of: isWaitingForResponse) { // Scroll when indicator appears/disappears
//                    // Ensure scroll happens after UI update for indicator
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        scrollToBottom(proxy: scrollViewProxy, id: isWaitingForResponse ? "typingIndicator" : messages.last?.id)
//                    }
//                }
//            }
//            
//            // Error Display
//            if let error = currentError {
//                ErrorDisplayView(errorMessage: error) {
//                    currentError = nil
//                }
//                .transition(.move(edge: .bottom).combined(with: .opacity))
//            }
//            
//            // Input Area
//            HStack {
//                TextField("Ask Gemini...", text: $newMessageText, axis: .vertical)
//                    .textFieldStyle(.plain)
//                    .padding(10)
//                    .background(Color(white: 0.15)).cornerRadius(18)
//                    .lineLimit(1...5)
//                    .disabled(isWaitingForResponse)
//                
//                Button {
//                    Task {
//                        // Call the updated async function
//                        await sendMessageToGeminiNonStreaming()
//                    }
//                } label: {
//                    Image(systemName: isWaitingForResponse ? "hourglass" : "arrow.up.circle.fill") // Changed loading icon
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .foregroundColor(isWaitingForResponse ? .gray : (newMessageText.isEmpty ? .gray : .yellow))
//                }
//                .disabled(newMessageText.isEmpty || isWaitingForResponse)
//            }
//            .padding()
//            .background(Color(white: 0.1))
//        }
//        .background(Color.black.ignoresSafeArea())
//        .foregroundColor(.white)
//        .onAppear {
//            // Initialize chat session
//            if geminiChat == nil && GEMINI_API_KEY != "YOUR_API_KEY" {
//                // Include history if desired:
//                // let history = messages.compactMap { $0.toModelContent() }
//                // geminiChat = geminiModel.startChat(history: history)
//                geminiChat = geminiModel.startChat() // Start fresh chat
//            }
//        }
//    }
//    
//    // MARK: - Helper Functions
//    
//    func scrollToBottom(
//        proxy: ScrollViewProxy,
//        anchor: UnitPoint = .bottom,
//        id: AnyHashable? = nil
//    ) {
//        let targetId = id ?? messages.last?.id
//        guard let targetId = targetId else { return }
//        // DispatchQueue.main.async {
//        withAnimation(.smooth(duration: 0.3)) {
//            proxy.scrollTo(targetId, anchor: anchor)
//        }
//        // }
//    }
//    
//    // MARK: - Gemini Interaction (Non-Streaming)
//    
//    @MainActor // Ensure UI updates happen on the main thread
//    func sendMessageToGeminiNonStreaming() async {
//        // Check for API Key validity
//        guard GEMINI_API_KEY != "YOUR_API_KEY", !GEMINI_API_KEY.isEmpty else {
//            currentError = "API Key not configured."
//            isWaitingForResponse = false // Ensure loading stops
//            return
//        }
//        // Ensure chat session is ready
//        if geminiChat == nil {
//            geminiChat = geminiModel.startChat()
//        }
//        guard let chat = geminiChat else {
//            currentError = "Chat session could not be initialized."
//            isWaitingForResponse = false // Ensure loading stops
//            return
//        }
//        guard !newMessageText.isEmpty else { return }
//        
//        isWaitingForResponse = true
//        currentError = nil
//        let userPrompt = newMessageText
//        newMessageText = ""
//        
//        // Add user message to UI
//        messages.append(Message(text: userPrompt, isUser: true, isResponseComplete: true))
//        
//        // Add placeholder for AI response (will be updated at once)
//        let aiResponsePlaceholderId = UUID()
//        messages.append(Message(id: aiResponsePlaceholderId, text: "", isUser: false, sourceModel: .geminiPro, isLoading: true, isResponseComplete: false))
//        
//        // Find index W *after* adding the placeholder
//        guard let aiMessageIndex = messages.firstIndex(where: { $0.id == aiResponsePlaceholderId }) else {
//            currentError = "Internal error: Could not find placeholder message."
//            isWaitingForResponse = false
//            return
//        }
//        
//        do {
//            // *** Use sendMessage instead of sendMessageStream ***
//            let response = try await chat.sendMessage(userPrompt)
//            
//            // Process the full response
//            // The response.text helper concatenates parts for you
//            if let fullText = response.text {
//                messages[aiMessageIndex].text = fullText
//                messages[aiMessageIndex].isResponseComplete = true // Mark complete
//                // Log citation metadata if present (optional)
//                if let metadata = response.candidates.first?.citationMetadata {
//                    print("Citation Metadata received: \(metadata.citationSources.count) sources")
//                }
//            } else {
//                // Handle case where response has no text (e.g., safety block)
//                messages[aiMessageIndex].text = "[No text content received]"
//                messages[aiMessageIndex].error = response.candidates.first?.finishReason?.rawValue ?? "Blocked or Empty" // Use finishReason if available
//                messages[aiMessageIndex].isResponseComplete = true // Still complete
//            }
//            
//        } catch {
//            // Handle API or network errors
//            print("Gemini API Error (sendMessage): \(error)")
//            messages[aiMessageIndex].text = "" // Clear placeholder
//            messages[aiMessageIndex].error = "Error: \(error.localizedDescription)"
//            messages[aiMessageIndex].isResponseComplete = true // Complete (with error)
//            currentError = "Failed to get response from Gemini. \(error.localizedDescription)"
//        }
//        
//        // Update loading state
//        messages[aiMessageIndex].isLoading = false
//        isWaitingForResponse = false
//    }
//}
//
//// MARK: - Helper UI Components (No changes needed from previous version)
//
//struct MessageBubble: View {
//    @Binding var message: Message
//    
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 8) {
//            if message.isUser { Spacer() }
//            
//            if !message.isUser, let model = message.sourceModel {
//                Image(systemName: model.systemImageName)
//                    .font(.caption).foregroundColor(.gray).padding(.bottom, 5)
//            }
//            
//            // Display text - no need for special streaming handling visually here
//            Text(message.text)
//                .padding(12)
//                .background(messageContentBackground())
//                .foregroundColor(message.isUser ? .black : .white)
//                .cornerRadius(15)
//                .frame(maxWidth: 300, alignment: message.isUser ? .trailing : .leading)
//                .overlay( // Error border
//                    message.error != nil ?
//                    RoundedRectangle(cornerRadius: 15).stroke(Color.red, lineWidth: 1)
//                    : nil
//                )
//            
//            if !message.isUser { Spacer() }
//        }
//    }
//    
//    @ViewBuilder
//    private func messageContentBackground() -> some View {
//        if message.isUser {
//            Color.yellow.opacity(0.9)
//        } else if message.error != nil {
//            Color.red.opacity(0.4)
//        } else {
//            Color(white: 0.25)
//        }
//    }
//}
//
//struct TypingIndicatorBubble: View { // No changes needed
//    @State private var scale: CGFloat = 0.5
//    let animation = Animation.easeInOut(duration: 0.4).repeatForever(autoreverses: true)
//    var body: some View {
//        HStack(spacing: 4) {
//            ForEach(0..<3) { i in Circle().fill(Color.gray).frame(width: 8, height: 8).scaleEffect(scale).animation(animation.delay(Double(i) * 0.15), value: scale) }
//        }.padding(12).background(Color(white: 0.25)).cornerRadius(15).onAppear { scale = 1.0 }.frame(maxWidth: 300, alignment: .leading)
//    }
//}
//
//struct ErrorDisplayView: View { // No changes needed
//    let errorMessage: String
//    let dismissAction: () -> Void
//    var body: some View {
//        HStack {
//            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
//            Text(errorMessage).font(.caption).lineLimit(2).foregroundColor(.red.opacity(0.8))
//            Spacer()
//            Button { dismissAction() } label: { Image(systemName: "xmark.circle.fill").foregroundColor(.gray) }
//        }.padding(10).background(Color.red.opacity(0.15)).cornerRadius(8).padding(.horizontal).padding(.bottom, 5)
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    NavigationView {
//        ChatView()
//            .navigationTitle("Gemini Chat (Non-Stream)")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbarColorScheme(.dark, for: .navigationBar)
//            .toolbarBackground(.visible, for: .navigationBar)
//            .toolbarBackground(Color.black,for: .navigationBar) // Explicitly set background
//        
//    }
//    .preferredColorScheme(.dark)
//    .tint(.yellow)
//}
//
//// Optional: Helper to convert Message back to ModelContent for history
//// extension Message {
////     func toModelContent() -> ModelContent? {
////         let role = isUser ? "user" : "model"
////         // Only include completed, non-error messages in history
////         guard !text.isEmpty, error == nil, isResponseComplete else { return nil }
////         return ModelContent(role: role, parts: [.text(text)])
////     }
//// }
