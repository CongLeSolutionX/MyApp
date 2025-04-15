////
////  GeminiChatView.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//import SwiftUI
//
//// Represents a single message in the chat
//struct ChatMessage: Identifiable, Equatable {
//    let id = UUID()
//    let role: String // "user" or "model"
//    let text: String
//}
//
//// The main Chat View
//struct GeminiChatView: View {
//
//    // State for the chat messages, initialized with history like the snippet
//    @State private var chatMessages: [ChatMessage] = [
//        ChatMessage(role: "user", text: "Hello, I have 2 dogs in my house."),
//        ChatMessage(role: "model", text: "Great to meet you. What would you like to know?")
//    ]
//
//    // State for the user's current input
//    @State private var userInput: String = ""
//
//    // State to track if the "model" is processing
//    @State private var isProcessing: Bool = false
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // Scrollable area for messages
//            ScrollViewReader { scrollViewProxy in
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 12) {
//                        ForEach(chatMessages) { message in
//                            MessageBubbleView(message: message)
//                                .id(message.id) // Assign ID for scrolling
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 10)
//                }
//                // Automatically scroll down when messages change
//                .onChange(of: chatMessages.count) { _, newCount in
//                    if let lastMessage = chatMessages.last {
//                        withAnimation {
//                            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
//                        }
//                    }
//                }
//                .onAppear {
//                     // Scroll to bottom on initial appearance
//                     if let lastMessage = chatMessages.last {
//                         scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
//                     }
//                }
//            }
//
//            Divider()
//
//            // Input area
//            InputAreaView(
//                userInput: $userInput,
//                isProcessing: $isProcessing,
//                sendMessageAction: sendMessage
//            )
//        }
//        .navigationTitle("Gemini Chat") // Example Title
//        .navigationBarTitleDisplayMode(.inline)
//        // Add background if desired, e.g., .background(Color(.systemGroupedBackground))
//    }
//
//    // --- Action ---
//
//    private func sendMessage() {
//        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !isProcessing else {
//            return
//        }
//
//        // 1. Add user message immediately
//        let userMessageText = userInput
//        let userMessage = ChatMessage(role: "user", text: userMessageText)
//        chatMessages.append(userMessage)
//
//        // 2. Clear input and set processing state
//        userInput = ""
//        isProcessing = true
//
//        // 3. Simulate async call and response (Replace with actual API call)
//        Task {
//            // Simulate network delay
//            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds delay
//
//            // Simulate response based on the example
//            // In a real app, this comes from the GenerativeModel API call
//            var modelResponseText = "Okay, I'll try to figure that out!"
//            if userMessageText.lowercased().contains("how many paws") {
//                 modelResponseText = "Assuming 2 dogs with 4 paws each, that would be 8 paws!"
//            } else if userMessageText.lowercased().contains("hello") {
//                 modelResponseText = "Hello there! How can I help?"
//            }
//
//            let modelMessage = ChatMessage(role: "model", text: modelResponseText)
//
//            // Ensure UI updates on the main thread
//            await MainActor.run {
//                chatMessages.append(modelMessage)
//                isProcessing = false // Done processing
//            }
//        }
//    }
//}
//
//// --- Subviews ---
//
//// View for displaying a single message bubble
//struct MessageBubbleView: View {
//    let message: ChatMessage
//
//    var body: some View {
//        HStack {
//            if message.role == "user" {
//                Spacer() // Push user messages to the right
//            }
//
//            Text(message.text)
//                .padding(12)
//                .background(message.role == "user" ? Color.blue : Color(UIColor.secondarySystemBackground))
//                .foregroundColor(message.role == "user" ? Color.white : Color.primary)
//                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous)) // Ensure tappable area is correct
//
//            if message.role == "model" {
//                Spacer() // Push model messages to the left
//            }
//        }
//    }
//}
//
//// View for the text input field and send button
//struct InputAreaView: View {
//    @Binding var userInput: String
//    @Binding var isProcessing: Bool
//    let sendMessageAction: () -> Void
//
//    var body: some View {
//        HStack(spacing: 12) {
//            TextField("Ask something...", text: $userInput, axis: .vertical)
//                .textFieldStyle(.plain)
//                .lineLimit(1...5) // Allow multi-line input
//                .padding(8)
//                .background(Color(UIColor.systemGray6))
//                .clipShape(RoundedRectangle(cornerRadius: 8))
//                .disabled(isProcessing) // Disable input while processing
//
//            if isProcessing {
//                ProgressView() // Show activity indicator
//                    .padding(.horizontal, 5) // Adjust padding as needed
//            } else {
//                Button {
//                    sendMessageAction()
//                } label: {
//                    Image(systemName: "arrow.up.circle.fill")
//                        .resizable()
//                        .frame(width: 28, height: 28)
//                        .foregroundColor(userInput.isEmpty ? .gray : .blue)
//                }
//                .disabled(userInput.isEmpty || isProcessing) // Disable btn if no text or processing
//            }
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 8)
//        .background(.regularMaterial) // Subtle background for the input bar
//    }
//}
//
//// --- Preview ---
//
//#Preview {
//    NavigationView { // Wrap in NavigationView for title display
//        GeminiChatView()
//    }
//}
