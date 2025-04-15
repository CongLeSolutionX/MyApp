////
////  GeminiChatView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//import SwiftUI
//import Combine // Needed for ObservableObject
//
//// --- Constants ---
//struct StyleConstants {
//    static let horizontalPadding: CGFloat = 15
//    static let verticalPadding: CGFloat = 10
//    static let bubbleCornerRadius: CGFloat = 18
//    static let timestampFontSize: CGFloat = 10
//}
//
//// --- Data Models ---
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
//    var isLoading: Bool = false // For the "typing..." indicator message
//    var isErrorPlaceholder: Bool = false // To flag model error messages
//
//    // Helper for display
//    var formattedTimestamp: String {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .short
//        return formatter.string(from: timestamp)
//    }
//
//    // Static examples for preview/mock data
//    static let userExample = ChatMessage(id: UUID(), role: .user, text: "Tell me a fun fact about Swift.", timestamp: Date().addingTimeInterval(-60))
//    static let modelExample = ChatMessage(id: UUID(), role: .model, text: "Swift was originally developed by Chris Lattner and was introduced at Apple's WWDC in 2014!", timestamp: Date())
//    static let modelLoadingExample = ChatMessage(id: UUID(), role: .model, text: "...", timestamp: Date(), isLoading: true)
//}
//
//// --- ViewModel ---
//
//@MainActor // Ensures @Published updates happen on the main thread
//class ChatViewModel: ObservableObject {
//    @Published var chatMessages: [ChatMessage] = []
//    @Published var userInput: String = ""
//    @Published var isProcessing: Bool = false // Tracks if *any* message is being processed
//    @Published var errorMessage: String? = nil
//    @Published var isShowingErrorAlert: Bool = false
//
//    private var cancellables = Set<AnyCancellable>()
//
//    init() {
//        // Load initial mock data or fetch from persistence if implemented
//        loadInitialMessages()
//
//        // Example of reacting to errorMessage changes to trigger the alert
//        $errorMessage
//            .compactMap { $0 } // Only proceed if errorMessage is not nil
//            .sink { [weak self] _ in
//                self?.isShowingErrorAlert = true
//            }
//            .store(in: &cancellables)
//    }
//
//    func loadInitialMessages() {
//        // Replace with actual data loading if needed
//        chatMessages = [
//            ChatMessage(id: UUID(), role: .user, text: "Hello!", timestamp: Date().addingTimeInterval(-120)),
//            ChatMessage(id: UUID(), role: .model, text: "Hi there! How can I assist you today?", timestamp: Date().addingTimeInterval(-110))
//        ]
//    }
//
//    func sendMessage() {
//        let textToSend = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !textToSend.isEmpty, !isProcessing else {
//            return
//        }
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
//        isProcessing = true // Now waiting for the model
//
//        // 4. Simulate async call
//        Task {
//            // Simulate varying network delay (1 to 3 seconds)
//            let delay = UInt64.random(in: 1_000_000_000...3_000_000_000)
//            try? await Task.sleep(nanoseconds: delay)
//
//            // Simulate potential error (e.g., 15% chance)
//            let shouldError = Int.random(in: 1...100) <= 15
//
//            var modelResponseText: String
//            var isError = false
//
//            if shouldError {
//                modelResponseText = "Sorry, I encountered an error. Please try again."
//                isError = true
//                // Optionally set a specific error message for the alert
//                // self.errorMessage = "Network request failed"
//            } else {
//                // Simulate response based on user input
//                if textToSend.lowercased().contains("swiftui") {
//                    modelResponseText = "Ah, *SwiftUI*! It's Apple's **declarative** framework for building UIs across all their platforms. It's quite powerful."
//                } else if textToSend.lowercased().contains("hello") || textToSend.lowercased().contains("hi") {
//                     modelResponseText = "Hello again!"
//                } else if textToSend.lowercased().contains("dogs") {
//                    modelResponseText = "Dogs are great! Did you know the Basenji breed doesn't bark, but makes a yodel-like sound? `woof woof`"
//                } else {
//                    modelResponseText = "That's interesting! Tell me more, or ask something else."
//                }
//            }
//
//            // 5. Replace loading indicator with actual response or error message
//            // Ensure this update happens on the main thread
//            await MainActor.run {
//                if let index = chatMessages.firstIndex(where: { $0.id == loadingMessageId }) {
//                    chatMessages[index] = ChatMessage(
//                        id: loadingMessageId, // Keep the same ID for stability if needed
//                        role: .model,
//                        text: modelResponseText,
//                        timestamp: Date(),
//                        isLoading: false, // Not loading anymore
//                        isErrorPlaceholder: isError // Flag if it's an error
//                    )
//                }
//                isProcessing = false // Finished processing this message
//                if isError {
//                     // Set error message to trigger alert *after* updating the chat
//                     self.errorMessage = modelResponseText
//                }
//            }
//        }
//    }
//}
//
//// --- Views ---
//
//struct OptimizedGeminiChatView: View {
//    @StateObject private var viewModel = ChatViewModel()
//
//    var body: some View {
//        VStack(spacing: 0) {
//            if viewModel.chatMessages.isEmpty {
//                // Empty State View
//                VStack {
//                    Spacer()
//                    Image(systemName: "bubble.left.and.bubble.right")
//                        .font(.system(size: 50))
//                        .padding(.bottom, 10)
//                        .foregroundColor(.secondary)
//                    Text("Start Chatting!")
//                        .font(.title2)
//                        .foregroundColor(.secondary)
//                    Text("Send a message to begin your conversation.")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal)
//                    Spacer()
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity) // Take full space
//
//            } else {
//                // Chat Messages Area
//                ScrollViewReader { scrollViewProxy in
//                    ScrollView {
//                        LazyVStack(alignment: .leading, spacing: StyleConstants.verticalPadding) {
//                            ForEach(viewModel.chatMessages) { message in
//                                MessageBubbleView(message: message)
//                                    .id(message.id)
//                            }
//                        }
//                        .padding(.horizontal, StyleConstants.horizontalPadding)
//                        .padding(.top, StyleConstants.verticalPadding)
//                    }
//                    // Scroll management
//                    .onChange(of: viewModel.chatMessages.count) { _, _ in
//                        scrollToBottom(proxy: scrollViewProxy)
//                    }
//                    .onAppear {
//                        scrollToBottom(proxy: scrollViewProxy, animated: false)
//                    }
//                }
//            }
//
//            Divider()
//
//            // Input Area
//            InputAreaView(
//                userInput: $viewModel.userInput,
//                isProcessing: viewModel.isProcessing, // Pass non-binding for read-only
//                placeholder: "Ask Gemini...",
//                sendMessageAction: viewModel.sendMessage
//            )
//        }
//        .navigationTitle("Enhanced Chat")
//        .navigationBarTitleDisplayMode(.inline)
//        .ignoresSafeArea(.keyboard, edges: .bottom) // Push content up when keyboard appears
//        .alert("Error", isPresented: $viewModel.isShowingErrorAlert, presenting: viewModel.errorMessage) { _ in
//            // Default OK button is fine
//        } message: { messageText in
//            Text(messageText) // Display the error message from the ViewModel
//        }
//        // Optional: Add a background color
//        // .background(Color(.systemGroupedBackground).ignoresSafeArea())
//    }
//
//    // Helper to scroll to bottom
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
//                Spacer() // Push user messages to the right
//            }
//
//            VStack(alignment: message.role == .user ? .trailing : .leading) {
//                // Content Bubble
//                messageContent
//                    .padding(.vertical, 10)
//                    .padding(.horizontal, 14)
//                    .background(bubbleBackground)
//                    .foregroundColor(message.role == .user ? .white : (message.isErrorPlaceholder ? .red : .primary))
//                    .clipShape(RoundedRectangle(cornerRadius: StyleConstants.bubbleCornerRadius, style: .continuous))
//                    // Add context menu for copying
//                    .contextMenu {
//                         if !message.isLoading && !message.text.isEmpty {
//                              Button {
//                                   UIPasteboard.general.string = message.text
//                              } label: {
//                                   Label("Copy Text", systemImage: "doc.on.doc")
//                              }
//                         }
//                    }
//
//                // Timestamp
//                Text(message.formattedTimestamp)
//                    .font(.system(size: StyleConstants.timestampFontSize))
//                    .foregroundColor(.gray)
//            }
//            .frame(maxWidth: 300, alignment: message.role == .user ? .trailing : .leading) // Limit bubble width
//
//            if message.role == .model {
//                Spacer() // Push model messages to the left
//            }
//        }
//    }
//
//    // Extracted message content view for clarity
//    @ViewBuilder
//    private var messageContent: some View {
//        if message.isLoading {
//            // Simple "typing" animation
//            HStack(spacing: 3) {
//                ForEach(0..<3) { i in
//                    Circle()
//                        .opacity(i == 0 ? 0.3 : (i == 1 ? 0.6 : 1.0))
//                        .frame(width: 6, height: 6)
//                        .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.15), value: message.isLoading) // Requires a changing value
//                }
//            }
//            .transition(.opacity) // Fade in/out
//        } else {
//            // Use Text(.init(...)) for basic Markdown rendering (iOS 15+)
//            // Handle potential errors during Markdown parsing gracefully
//            Text(LocalizedStringKey(message.text)) // Attempt to parse markdown
//                .textSelection(.enabled) // Allow selecting text within bubble
//        }
//    }
//
//    // Background color logic
//    private var bubbleBackground: Color {
//        switch message.role {
//        case .user:
//            return .blue
//        case .model:
//            return message.isErrorPlaceholder ? Color(.systemGray5) : Color(.systemGray6)
//        }
//    }
//}
//
//struct InputAreaView: View {
//    @Binding var userInput: String
//    let isProcessing: Bool // Read-only version is sufficient here
//    let placeholder: String
//    let sendMessageAction: () -> Void
//
//    @FocusState private var isTextFieldFocused: Bool
//
//    var body: some View {
//        HStack(spacing: 12) {
//            // Text Field Input
//            TextField(placeholder, text: $userInput, axis: .vertical)
//                .focused($isTextFieldFocused) // Track focus state
//                .lineLimit(1...5)
//                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
//                .background(
//                     RoundedRectangle(cornerRadius: 20, style: .continuous)
//                          .fill(Color(.systemGray6))
//                )
//                .overlay( // Add clear button conditionally
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
//                        }
//                    }
//                )
//
//            // Send Button / Progress Indicator
//            Button {
//                sendMessageAction()
//            } label: {
//                if isProcessing {
//                    ProgressView()
//                        .frame(width: 28, height: 28)
//                } else {
//                    Image(systemName: "arrow.up.circle.fill")
//                        .resizable()
//                        .frame(width: 28, height: 28)
//                        .foregroundColor(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray.opacity(0.5) : .blue)
//                }
//            }
//            .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing)
//            .animation(.easeInOut, value: isProcessing) // Animate transition
//            .keyboardShortcut(.return, modifiers: .command) // Send with Cmd+Enter
//             .keyboardShortcut(.defaultAction) // Send with Enter on external keyboard (if appropriate)
//        }
//        .padding(EdgeInsets(top: 8, leading: StyleConstants.horizontalPadding, bottom: 8, trailing: StyleConstants.horizontalPadding))
//        .background(.thinMaterial) // Use material for a modern look
//    }
//}
//
//// --- Preview ---
//
//#Preview("Chat View") {
//    NavigationView {
//        OptimizedGeminiChatView()
//    }
//}
//
//#Preview("Empty Chat View") {
//    NavigationView {
//         // Create a ViewModel with no initial messages for the empty state preview
//         //OptimizedGeminiChatView(viewModel: ChatViewModel(messages: []))
//        OptimizedGeminiChatView()
//    }
//}
//
//// Helper extension for previewing specific states
//extension ChatViewModel {
//    convenience init(messages: [ChatMessage]) {
//        self.init()
//        self.chatMessages = messages
//    }
//}
