//
//  ChatView.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

import SwiftUI

// MARK: - Data Models (Enhanced Message)

// Added optional fields to indicate ML processing state and source
struct Message: Identifiable {
    let id = UUID()
    var text: String // Changed to var for streaming simulation
    let isUser: Bool
    let timestamp: Date = Date()
    var sourceModel: AIModel? = nil // Optional: Track which AI model responded
    var isLoading: Bool = false     // Optional: Indicate if this is a placeholder for loading
    var error: String? = nil        // Optional: Store error message related to this response attempt
    
    // Enum to differentiate AI models (Example)
    enum AIModel: String, CaseIterable {
        case localCoreML = "CoreML (Local)"
        case chatGPT_3_5 = "ChatGPT 3.5"
        case chatGPT_4 = "ChatGPT 4 (Advanced)"
        
        var systemImageName: String {
            switch self {
            case .localCoreML: return "cpu" // Simple representation for local processing
            case .chatGPT_3_5: return "cloud"
            case .chatGPT_4: return "sparkles" // Representing advanced capability
            }
        }
    }
}

// MARK: - Enhanced Chat View with ML Indicators

struct EnhancedChatView: View {
    @State private var messages: [Message] = [
        Message(text: "Hello! Choose a model and ask something.", isUser: false, sourceModel: .chatGPT_3_5),
    ]
    @State private var newMessageText: String = ""
    @State private var isWaitingForResponse: Bool = false // Global loading indicator state
    @State private var selectedModel: Message.AIModel = .chatGPT_3_5 // Allow model selection
    @State private var currentError: String? = nil // Display API/Model errors
    
    // For Streaming Simulation
    @State private var streamTimer: Timer?
    @State private var currentlyStreamingMessageId: UUID?
    @State private var fullStreamingResponse: String = ""
    @State private var streamIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 0) { // Reduced spacing
            // --- Header with Model Selector ---
            ModelSelectorView(selectedModel: $selectedModel)
                .padding(.bottom, 5)
            
            Divider() // Separator
            
            // --- Message Display Area ---
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach($messages) { $message in // Use Binding ForEach for streaming
                            MessageBubble(message: $message) // Pass binding
                                .id(message.id)
                        }
                        // Show Typing Indicator if waiting
                        if isWaitingForResponse {
                            TypingIndicatorBubble()
                                .id("typingIndicator") // Give it an ID
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                // Scroll logic remains sensitive to message count and loading state changes
                .onChange(of: messages.count) { scrollToBottom(proxy: scrollViewProxy) }
                .onChange(of: isWaitingForResponse) { if isWaitingForResponse { scrollToBottom(proxy: scrollViewProxy, anchor: .bottom, id: UUID()) } }
            }
            
            // --- Error Display Area ---
            if let error = currentError {
                ErrorDisplayView(errorMessage: error) {
                    currentError = nil // Action to dismiss error
                }
            }
            
            // --- Input Area ---
            HStack {
                TextField("Ask \(selectedModel.rawValue)...", text: $newMessageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Color(white: 0.15))
                    .cornerRadius(18)
                    .lineLimit(1...5)
                    .disabled(isWaitingForResponse) // Disable input while waiting
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: isWaitingForResponse ? "stop.circle.fill" : "arrow.up.circle.fill") // Change icon based on state
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(newMessageText.isEmpty && !isWaitingForResponse ? .gray : .yellow)
                    //  .foregroundColor(isWaitingForResponse ? .red : (newMessageText.isEmpty ? .gray : .yellow))
                }
                .disabled(newMessageText.isEmpty && !isWaitingForResponse) // Can always stop if waiting
            }
            .padding()
            .background(Color(white: 0.1)) // Input area background
        }
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
        .onDisappear {
            stopStreaming() // Clean up timer if view disappears
        }
    }
    
    // --- Helper Functions ---
    
    func scrollToBottom(proxy: ScrollViewProxy, anchor: UnitPoint = .bottom, id: UUID? = nil) {
        let targetId = id ?? messages.last?.id
        guard let targetId = targetId else { return }
        withAnimation {
            proxy.scrollTo(targetId, anchor: anchor)
        }
    }
    
    func sendMessage() {
        guard !newMessageText.isEmpty else { return }
        
        // Stop current streaming if a new message is sent
        stopStreaming()
        
        // 1. Add User Message
        let userMessage = Message(text: newMessageText, isUser: true)
        messages.append(userMessage)
        let messageToSend = newMessageText // Capture text before clearing
        newMessageText = "" // Clear input field
        
        // 2. Set Loading State
        isWaitingForResponse = true
        currentError = nil // Clear previous errors
        
        // 3. Simulate Network/ML Delay & Response
        // In a real app, this would be an async call to your MLService
        let responseDelay = Double.random(in: 0.5...2.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + responseDelay) {
            isWaitingForResponse = false // Stop global loading indicator
            
            // Simulate potential error
            if messageToSend.lowercased().contains("error") {
                currentError = "Simulated Error: Could not connect to \(selectedModel.rawValue) service."
                return // Don't add a message if there's an error
            }
            
            // Simulate Response
            let responseText = generateMockResponse(to: messageToSend, model: selectedModel)
            let responseMessageId = UUID()
            let aiMessage = Message(
                text: "", // Start with empty text for streaming
                isUser: false,
                sourceModel: selectedModel
            )
            
            messages.append(aiMessage)
            
            // Simulate streaming for API models
            if selectedModel != .localCoreML {
                startStreamingResponse(for: responseMessageId, fullText: responseText)
            } else {
                // For CoreML, update text directly (no streaming)
                if let index = messages.firstIndex(where: { $0.id == responseMessageId }) {
                    messages[index].text = responseText
                }
            }
        }
    }
    
    // --- Streaming Simulation ---
    func startStreamingResponse(for messageId: UUID, fullText: String) {
        stopStreaming() // Ensure only one stream runs
        
        currentlyStreamingMessageId = messageId
        fullStreamingResponse = fullText
        streamIndex = 0
        
        // Use a Timer to append characters gradually
        streamTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            guard streamIndex < fullStreamingResponse.count else {
                stopStreaming()
                return
            }
            
            if let messageIndex = messages.firstIndex(where: { $0.id == currentlyStreamingMessageId }) {
                let nextCharIndex = fullStreamingResponse.index(fullStreamingResponse.startIndex, offsetBy: streamIndex)
                messages[messageIndex].text.append(fullStreamingResponse[nextCharIndex])
                streamIndex += 1
            } else {
                stopStreaming() // Stop if message disappears
            }
        }
    }
    
    func stopStreaming() {
        streamTimer?.invalidate()
        streamTimer = nil
        currentlyStreamingMessageId = nil
        fullStreamingResponse = ""
        streamIndex = 0
    }
    
    // Simple mock response generator (now aware of model)
    func generateMockResponse(to input: String, model: Message.AIModel) -> String {
        let modelPrefix = "[\(model.rawValue)]:"
        let lowercasedInput = input.lowercased()
        
        if lowercasedInput.contains("hello") || lowercasedInput.contains("hi") {
            return "\(modelPrefix) Hi there! 👋 How can I help you with the power of \(model.rawValue.split(separator: " ")[0])?"
        } else if lowercasedInput.contains("coreml") && model == .localCoreML {
            return "\(modelPrefix) Yes, I am running locally using CoreML. My responses are fast but might be simpler."
        } else if lowercasedInput.contains("chatgpt") && (model == .chatGPT_3_5 || model == .chatGPT_4) {
            return "\(modelPrefix) Indeed! I'm accessing the \(model.rawValue) API. My responses can be more detailed and context-aware, but require network access."
        } else if lowercasedInput.contains("stream") && model != .localCoreML {
            return "\(modelPrefix) Absolutely! I can stream this response back to you character by character, making it feel more interactive, just like this explanation is appearing right now."
        } else {
            return "\(modelPrefix) Simulating a response for '\(input)' using \(model.rawValue). This is a generic reply."
        }
    }
}

// MARK: - Helper UI Components

// View for Selecting the AI Model
struct ModelSelectorView: View {
    @Binding var selectedModel: Message.AIModel
    
    var body: some View {
        HStack {
            Text("AI Model:")
                .font(.caption)
                .foregroundColor(.gray)
            Picker("Select Model", selection: $selectedModel) {
                ForEach(Message.AIModel.allCases, id: \.self) { model in
                    Text(model.rawValue).tag(model)
                }
            }
            .pickerStyle(.menu) // Use a dropdown menu style
            .accentColor(.yellow)
            .padding(.horizontal, -10) // Adjust padding for tighter fit
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(Color(white: 0.05)) // Subtle background for the selector area
    }
}

// Enhanced Message Bubble to show model icon and handle streaming/errors
struct MessageBubble: View {
    @Binding var message: Message // Use binding to reflect streaming text updates
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) { // Align items to bottom
            if message.isUser { Spacer() } // Push user messages right
            
            // Model Icon for AI messages
            if !message.isUser, let model = message.sourceModel {
                Image(systemName: model.systemImageName)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 5) // Align roughly with text bottom
            }
            
            // Main text content
            Text(message.text)
                .padding(12)
                .background(messageContentBackground())
                .foregroundColor(message.isUser ? .black : .white)
                .cornerRadius(15)
                .frame(maxWidth: 300, alignment: message.isUser ? .trailing : .leading)
                .overlay( // Add overlay for error border if needed
                    message.error != nil ?
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.red, lineWidth: 1)
                    : nil
                )
            
            if !message.isUser { Spacer() } // Push assistant messages left
        }
    }
    
    // Determine background color based on user/AI and error state
    @ViewBuilder
    private func messageContentBackground() -> some View {
        if message.isUser {
            Color.yellow.opacity(0.9)
        } else if message.error != nil {
            Color.red.opacity(0.4) // Indicate error background
        } else {
            Color(white: 0.25)
        }
    }
}

// Simple Typing Indicator Bubble
struct TypingIndicatorBubble: View {
    @State private var scale: CGFloat = 0.5
    let animation = Animation.easeInOut(duration: 0.4).repeatForever(autoreverses: true)
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
                    .scaleEffect(scale)
                    .animation(animation.delay(Double(i) * 0.15), value: scale)
            }
        }
        .padding(12)
        .background(Color(white: 0.25))
        .cornerRadius(15)
        .onAppear { scale = 1.0 } // Start animation
        .frame(maxWidth: 300, alignment: .leading) // Align left like AI messages
    }
}

// View to display errors prominently
struct ErrorDisplayView: View {
    let errorMessage: String
    let dismissAction: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(errorMessage)
                .font(.caption)
                .lineLimit(2)
                .foregroundColor(.red.opacity(0.8))
            Spacer()
            Button {
                dismissAction()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(10)
        .background(Color.red.opacity(0.15))
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.bottom, 5)
        .transition(.move(edge: .bottom).combined(with: .opacity)) // Add transition
    }
}

// MARK: - Preview

// Use EnhancedChatView in Preview
#Preview {
    // Embed in a navigation view simulate the context where it might appear
    NavigationView {
        EnhancedChatView()
            .navigationTitle("AI Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar) // Keep nav bar dark
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        
    }
    .preferredColorScheme(.dark) // Ensure preview uses dark mode
    .tint(.yellow)// Global tint
}
