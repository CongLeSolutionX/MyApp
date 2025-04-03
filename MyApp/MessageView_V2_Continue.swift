//
//  MessageView_V2_Continue.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI
// Import the Google Generative AI SDK
import GoogleGenerativeAI

// MARK: - Configuration (API Key - Reuse from previous code)
// Ensure AIConfig struct with geminiApiKey is available in your project
/*
 struct AIConfig {
     static let geminiApiKey = "YOUR_API_KEY" // REMEMBER TO REPLACE AND SECURE THIS
 }
 */

// MARK: - Chat Data Models

enum SenderRole {
    case user
    case model
}

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    var role: SenderRole
    var text: String
    var isError: Bool = false // Flag for error messages
}

// MARK: - Gemini Chat View

struct GeminiChatView: View {
    // --- State Variables ---
    @State private var messages: [ChatMessage] = [] // Stores the conversation history
    @State private var userInput: String = ""       // Text currently typed by the user
    @State private var isLoading: Bool = false      // Is the AI currently processing?
    @State private var errorMessage: String? = nil  // To display errors
    @State private var geminiChat: Chat? = nil      // Holds the chat session instance

    // --- Computed Properties ---
    private var isSendButtonDisabled: Bool {
        userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading
    }

    // --- Initialization ---
    init() {
        // Attempt to initialize the chat session when the view initializes
        if AIConfig.geminiApiKey == "YOUR_API_KEY" || AIConfig.geminiApiKey.isEmpty {
             // Set initial error state if API key is missing
             // Using _errorMessage.wrappedValue because we are in init
             _errorMessage = State(initialValue: AIError.apiKeyMissing.localizedDescription)
        } else {
            let model = GenerativeModel(
                name: "gemini-1.5-flash", // Or another suitable chat model
                apiKey: AIConfig.geminiApiKey
            )
            // Start a new chat session. You could also add system instructions here.
            _geminiChat = State(initialValue: model.startChat())
             // Add an initial greeting from the model (optional)
             _messages = State(initialValue: [ChatMessage(role: .model, text: "Hello! How can I help you today?")])
        }
    }

    // --- Body ---
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // --- Error Display Area ---
                if let errorMsg = errorMessage {
                    Text(errorMsg)
                        .foregroundColor(.red)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                }

                // --- Chat Message List ---
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(messages) { message in
                                ChatMessageRow(message: message)
                                    .id(message.id) // Make each row identifiable for scroll proxy
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10) // Add padding at the top of the scroll content
                    }
                    .onChange(of: messages) { _, newMessages in
                        // Auto-scroll to the bottom when new messages are added
                        if let lastMessage = newMessages.last {
                            withAnimation {
                                scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                         // Scroll to bottom on initial appearance as well
                         if let lastMessage = messages.last {
                             scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                         }
                    }

                } // End ScrollViewReader

                Divider()

                // --- Input Area ---
                HStack(spacing: 10) {
                    TextField("Type your message...", text: $userInput, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(1...5) // Allow multi-line input up to 5 lines
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(18) // Rounded corners for input field

                    if isLoading {
                        ProgressView()
                            .padding(.horizontal, 10)
                    } else {
                        Button {
                            sendMessage()
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(isSendButtonDisabled ? .gray : .blue)
                        }
                        .disabled(isSendButtonDisabled)
                        .transition(.scale) // Add animation for appearance/disappearance
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.thinMaterial) // Subtle background for the input area

            } // End Main VStack
            .navigationTitle("Gemini Chat")
            .navigationBarTitleDisplayMode(.inline)
            // Dismiss keyboard when tapping outside the TextField
             .onTapGesture {
                 hideKeyboard()
             }
        } // End NavigationView
    }

    // --- Methods ---

    // Function to handle sending messages to Gemini
    func sendMessage() {
        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard let chat = geminiChat else {
             errorMessage = "Chat session not initialized."
             if AIConfig.geminiApiKey == "YOUR_API_KEY" || AIConfig.geminiApiKey.isEmpty {
                 errorMessage = AIError.apiKeyMissing.localizedDescription
             }
             return
        }

        let userMessageText = userInput
        let userMessage = ChatMessage(role: .user, text: userMessageText)

        // Append user message immediately
        messages.append(userMessage)
        userInput = "" // Clear input field
        isLoading = true
        errorMessage = nil // Clear previous errors

        // Start asynchronous task to interact with the API
        Task {
            do {
                 print("--- Sending to Gemini Chat ---")
                 print("User: \(userMessageText)")
                 print("-----------------------------")

                // Send the message content to the chat session
                let response = try await chat.sendMessage(userMessageText)

                // Update UI on the main thread
                await MainActor.run {
                    isLoading = false
                    if let modelResponseText = response.text {
                         print("--- Received from Gemini Chat ---")
                         print("Model: \(modelResponseText)")
                         print("-------------------------------")
                        let modelMessage = ChatMessage(role: .model, text: modelResponseText)
                        messages.append(modelMessage)
                    } else {
                        // Handle cases where the response might be empty or blocked
                         print("--- Gemini Response Empty or Blocked ---")
                        let errorMsg = "Gemini did not provide a text response. It might have been blocked."
                        messages.append(ChatMessage(role: .model, text: errorMsg, isError: true))
                        errorMessage = errorMsg // Optionally show error at the top too
                    }
                }
            } catch let error as GenerateContentError {
                // Handle specific SDK errors
                 await MainActor.run {
                    isLoading = false
                    errorMessage = "Error generating content: \(error.localizedDescription)"
                     print("Gemini GenerateContentError: \(error)")
                    messages.append(ChatMessage(role: .model, text: "Sorry, I encountered an error: \(error.localizedDescription)", isError: true))
                }
            } catch {
                 // Handle other potential errors
                await MainActor.run {
                    isLoading = false
                    errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                    print("Unexpected error: \(error)")
                    messages.append(ChatMessage(role: .model, text: "Sorry, an unexpected error occurred.", isError: true))
                }
            }
        }
    }

    // Helper to dismiss keyboard
    private func hideKeyboard() {
         UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
     }
}

// MARK: - Chat Message Row View

struct ChatMessageRow: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top) { // Align to top for potentially multi-line text
            if message.role == .user {
                Spacer() // Push user message to the right
                Text(message.text)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .frame(maxWidth: 300, alignment: .trailing) // Limit width, align text right
                     .textSelection(.enabled) // Allow text selection

            } else {
                Text(message.text)
                    .padding(10)
                    .background(message.isError ? Color.red.opacity(0.8) : Color(.systemGray5)) // Different background for AI/Error
                    .foregroundColor(message.isError ? .white : Color(.label)) // Contrasting text color
                    .cornerRadius(12)
                    .frame(maxWidth: 300, alignment: .leading) // Limit width, align text left
                    .textSelection(.enabled) // Allow text selection
                Spacer() // Push AI message to the left
            }
        }
         .padding(.vertical, 2) // Small vertical padding between rows

    }
}

// MARK: - Preview

#Preview {
    GeminiChatView()
    // Important: Preview will show an error or initial greeting
    // unless a valid (placeholder or real) API key is set in AIConfig.
}
