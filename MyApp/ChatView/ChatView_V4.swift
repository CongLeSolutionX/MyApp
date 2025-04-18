////
////  ChatView_V4.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//import SwiftUI
//// 1. Import the GoogleGenerativeAI package
//import GoogleGenerativeAI
//
//// MARK: - API Key Placeholder
//// !!! IMPORTANT: Replace "YOUR_API_KEY" with your actual Google Gemini API key.
//// Consider using a more secure method like environment variables or a secrets manager
//// for production apps instead of hardcoding.
//let GEMINI_API_KEY = "YOUR_API_KEY"
//
//// MARK: - Data Models (Keep as is from previous version)
//
//struct Message: Identifiable {
//    let id = UUID()
//    var text: String
//    let isUser: Bool
//    let timestamp: Date = Date()
//    var sourceModel: AIModel? = nil
//    var isLoading: Bool = false
//    var error: String? = nil
//    // Track if streaming is finished for a message
//    var isStreamingComplete: Bool = false
//
//    enum AIModel: String, CaseIterable {
//        // Simplified for Gemini - you might have different Gemini model names
//        case geminiPro = "Gemini Pro"
//        // You could add other models like Gemini Ultra if available/needed
//
//        var systemImageName: String {
//            switch self {
//            case .geminiPro: return "sparkles.square.filled.on.square" // Example Icon
//            }
//        }
//    }
//}
//
//// MARK: - Chat View with Real Gemini API Integration
//
//struct ChatView: View {
//    @State private var messages: [Message] = [
//        Message(text: "Hello! I'm powered by Gemini. Ask me anything.", isUser: false, sourceModel: .geminiPro, isStreamingComplete: true),
//    ]
//    @State private var newMessageText: String = ""
//    @State private var isWaitingForResponse: Bool = false // Indicates active API call
//    @State private var currentError: String? = nil        // Stores API/Network errors
//
//    // 2. Configure the Gemini Model
//    // Use the specific model name you intend to query
//    private var geminiModel: GenerativeModel {
//        // Ensure API key provided
//        guard GEMINI_API_KEY != "YOUR_API_KEY" else {
//            // Return a dummy model or handle error appropriately if key is missing
//            // This basic setup just uses a default model, handle error in sendMessage
//            return GenerativeModel(name: "gemini-pro", apiKey: "INVALID_KEY_PLACEHOLDER")
//        }
//        
//        // Configure the model with safety settings and configurations if needed
//        // See GoogleGenerativeAI documentation for options
//        let config = GenerationConfig(
//            // Example: temperature: 0.7, // Adjust creativity
//            // Example: topK: 40,         // Adjust sampling
//            // Example: maxOutputTokens: 1024 // Limit response length
//        )
//        
//        // Add safety settings if desired (example: block harmful content)
//        // let safetySettings = [
//        //     SafetySetting(harmCategory: .harassment, threshold: .blockMediumAndAbove),
//        //     SafetySetting(harmCategory: .hateSpeech, threshold: .blockMediumAndAbove)
//        // ]
//
//        return GenerativeModel(
//            name: "gemini-pro", // Or other models like "gemini-pro-vision"
//            apiKey: GEMINI_API_KEY,
//            generationConfig: config
//            // safetySettings: safetySettings // Uncomment to add safety settings
//        )
//    }
//    
//    // Store the current chat context for Gemini
//    // Initialize with system instructions if desired
//     @State private var geminiChat: Chat? = nil // Use the Chat object from the SDK
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // --- Header (Model display - simplified as we only have Gemini here) ---
//            HStack {
//                Text("Using: \(Message.AIModel.geminiPro.rawValue)")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                Image(systemName: Message.AIModel.geminiPro.systemImageName)
//                    .font(.caption)
//                    .foregroundColor(.yellow)
//                Spacer()
//            }   .padding(.horizontal)
//                .padding(.vertical, 5)
//                .background(Color(white: 0.05))
//
//            Divider()
//
//            // --- Message Display Area ---
//            ScrollViewReader { scrollViewProxy in
//                ScrollView {
//                    LazyVStack(spacing: 12) {
//                        ForEach($messages) { $message in
//                            MessageBubble(message: $message)
//                                .id(message.id)
//                        }
//                        // Show Typing Indicator if actively waiting for API
//                        if isWaitingForResponse {
//                            TypingIndicatorBubble()
//                                .id("typingIndicator")
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top)
//                }
//                // Scroll logic
//                .onChange(of: messages.count) {
//                    scrollToBottom(proxy: scrollViewProxy)
//                }
//                .onChange(of: isWaitingForResponse) { // Scroll when loading starts
//                    if isWaitingForResponse {
//                        // Ensure scroll happens after UI update
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                             scrollToBottom(proxy: scrollViewProxy, id: "typingIndicator")
//                         }
//                    }
//                }
//                // Scroll during streaming (optional, can be jumpy)
//                .onChange(of: messages.last?.text) { // Crude check for text change
//                    if !isWaitingForResponse && messages.last?.isUser == false {
//                         scrollToBottom(proxy: scrollViewProxy)
//                    }
//                }
//            }
//
//            // --- Error Display ---
//             if let error = currentError {
//                 ErrorDisplayView(errorMessage: error) {
//                     currentError = nil // Action to dismiss
//                 }
//                 .transition(.move(edge: .bottom).combined(with: .opacity))
//             }
//
//            // --- Input Area ---
//            HStack {
//                TextField("Ask Gemini...", text: $newMessageText, axis: .vertical)
//                    .textFieldStyle(.plain)
//                    .padding(10)
//                    .background(Color(white: 0.15))
//                    .cornerRadius(18)
//                    .lineLimit(1...5)
//                    .disabled(isWaitingForResponse) // Disable while waiting
//
//                Button {
//                    // 3. Call the async function to send message
//                     Task {
//                          await sendMessageToGemini()
//                      }
//                } label: {
//                    Image(systemName: isWaitingForResponse ? "stop.circle.fill" : "arrow.up.circle.fill") // Allow stopping? (Needs Task cancellation)
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .foregroundColor(isWaitingForResponse ? .red : (newMessageText.isEmpty ? .gray : .yellow))
//                }
//                 // For now, disable sending if empty OR waiting. Stop requires Task cancellation.
//                 .disabled(newMessageText.isEmpty || isWaitingForResponse)
//            }
//            .padding()
//            .background(Color(white: 0.1))
//        }
//        .background(Color.black.ignoresSafeArea())
//        .foregroundColor(.white)
//        .onAppear {
//            // Initialize the chat session when the view appears
//             if geminiChat == nil && GEMINI_API_KEY != "YOUR_API_KEY" {
//                 geminiChat = geminiModel.startChat() // Or startChat(history: [previousMessages])
//             }
//        }
//    }
//
//    // MARK: - Helper Functions
//
//    func scrollToBottom(
//        proxy: ScrollViewProxy,
//        anchor: UnitPoint = .bottom,
//        id: AnyHashable? = nil // Allow specifying typing indicator ID
//    ) {
//        let targetId = id ?? messages.last?.id
//        guard let targetId = targetId else { return }
//       // DispatchQueue.main.async { //Ensure scroll happens on main thread after state change
//         withAnimation(.smooth(duration: 0.3)) {             //withAnimation(.spring()) {
//                proxy.scrollTo(targetId, anchor: anchor)
//            }
//      //  }
//    }
//
//    // 4. Async function to interact with Gemini API
//    @MainActor // Ensure UI updates happen on the main thread
//    func sendMessageToGemini() async {
//        // Check for API Key
//         guard GEMINI_API_KEY != "YOUR_API_KEY" else {
//             currentError = "API Key not configured. Please set GEMINI_API_KEY."
//             return
//         }
//                // Initialize chat if needed (e.g., if API key was added after launch)
//        if geminiChat == nil {
//             geminiChat = geminiModel.startChat()
//         }
//         guard let chat = geminiChat else { // Ensure chat is initialized
//             currentError = "Chat session could not be initialized."
//             return
//         }
//                 guard !newMessageText.isEmpty else { return }
//
//        isWaitingForResponse = true
//        currentError = nil
//        let userPrompt = newMessageText
//        newMessageText = "" // Clear input
//
//        // Add user message immediately to UI
//        messages.append(Message(text: userPrompt, isUser: true, isStreamingComplete: true))
//
//        // Prepare placeholder for AI response
//        let aiResponsePlaceholderId = UUID()
//        messages.append(Message(id: aiResponsePlaceholderId, text: "", isUser: false, sourceModel: .geminiPro, isLoading: true, isStreamingComplete: false))
//        
//        // Find the index of the placeholder message AFTER appending it
//         guard let aiMessageIndex = messages.firstIndex(where: { $0.id == aiResponsePlaceholderId }) else {
//             currentError = "Internal error: Could not find placeholder message."
//             isWaitingForResponse = false
//             return
//         }
//
//        do {
//            // 5. Use the streamGenerateContent method from the SDK's Chat
//            let stream = chat.sendMessageStream(userPrompt)
//
//            // Iterate over the stream asynchronously
//            for try await chunk in stream {
//                if let text = chunk.text {
//                    // Append chunk to the placeholder message text
//                    messages[aiMessageIndex].text += text
//                }
//             }
//             
//             // Mark streaming as complete once the loop finishes successfully
//              messages[aiMessageIndex].isStreamingComplete = true
//
//        } catch {
//            // 6. Handle API or network errors
//            print("Gemini API Error: \(error)")
//            messages[aiMessageIndex].error = "Error: \(error.localizedDescription)" // Add error to the specific message
//            currentError = "Failed to get response from Gemini. \(error.localizedDescription)" // Show global error
//             messages[aiMessageIndex].text = "" // Clear any partial text on error
//             messages[aiMessageIndex].isStreamingComplete = true // Mark complete even on error
//
//        }
//        
//        // 7. Update loading state regardless of success or failure
//        messages[aiMessageIndex].isLoading = false
//        isWaitingForResponse = false
//    }
//}
//
//// MARK: - Helper UI Components (Keep as is from previous version)
//
//// Message Bubble - Minor tweak to maybe show a subtle difference for incomplete streams
//struct MessageBubble: View {
//    @Binding var message: Message
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
//            }
//
//            Text(message.text.isEmpty && !message.isUser && !message.isStreamingComplete ? "..." : message.text) // Show ellipsis if empty and not complete
//                .padding(12)
//                .background(messageContentBackground())
//                .foregroundColor(message.isUser ? .black : .white)
//                .cornerRadius(15)
//                .opacity(message.isStreamingComplete || message.isUser ? 1.0 : 0.8) // Slightly dim if streaming?
//                .frame(maxWidth: 300, alignment: message.isUser ? .trailing : .leading)
//                .overlay( // Error border
//                    message.error != nil ?
//                    RoundedRectangle(cornerRadius: 15)
//                        .stroke(Color.red, lineWidth: 1)
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
//// Simple Typing Indicator Bubble (Keep as is)
//struct TypingIndicatorBubble: View {
//    @State private var scale: CGFloat = 0.5
//    let animation = Animation.easeInOut(duration: 0.4).repeatForever(autoreverses: true)
//
//    var body: some View {
//        HStack(spacing: 4) {
//            ForEach(0..<3) { i in
//                Circle()
//                    .fill(Color.gray)
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
//    }
//}
//
//// Error Display View (Keep as is)
//struct ErrorDisplayView: View {
//    let errorMessage: String
//    let dismissAction: () -> Void
//
//    var body: some View {
//        HStack {
//            Image(systemName: "exclamationmark.triangle.fill")
//                .foregroundColor(.red)
//            Text(errorMessage)
//                .font(.caption)
//                .lineLimit(2)
//                .foregroundColor(.red.opacity(0.8))
//            Spacer()
//            Button { dismissAction() } label: {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.gray)
//            }
//        }
//        .padding(10)
//        .background(Color.red.opacity(0.15))
//        .cornerRadius(8)
//        .padding(.horizontal)
//        .padding(.bottom, 5)
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    // Note: Preview will show the initial state.
//    // API calls won't work in preview unless you configure API key access differently.
//    NavigationView {
//        ChatView()
//            .navigationTitle("Gemini Chat")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbarColorScheme(.dark, for: .navigationBar)
//             .toolbarBackground(.visible, for: .navigationBar)              .toolbarBackground(Color.black,for: .navigationBar) // Explicitly set background
//
//    }
//    .preferredColorScheme(.dark)
//    .tint(.yellow)
//}
