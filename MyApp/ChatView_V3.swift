//
//  ChatView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

import SwiftUI
import CoreML // Import CoreML

// MARK: - Data Models (No changes needed from previous ML-aware version)

struct Message: Identifiable {
    let id = UUID()
    var text: String // var for streaming simulation (API only)
    let isUser: Bool
    let timestamp: Date = Date()
    var sourceModel: AIModel? = nil
    var isLoading: Bool = false
    var error: String? = nil

    enum AIModel: String, CaseIterable, Identifiable { // Add Identifiable
        case localCoreML = "CoreML (Local)"
        case chatGPT_3_5 = "ChatGPT 3.5"
        case chatGPT_4 = "ChatGPT 4 (Advanced)"

        var id: String { self.rawValue } // Conformance to Identifiable

        var systemImageName: String {
            switch self {
            case .localCoreML: return "cpu"
            case .chatGPT_3_5: return "cloud"
            case .chatGPT_4: return "sparkles"
            }
        }
    }
}

// MARK: - Enhanced Chat View with REAL CoreML Integration

struct EnhancedChatView: View {
    @State private var messages: [Message] = [
        Message(text: "Hello! Choose a model and ask something.", isUser: false, sourceModel: .localCoreML), // Default to CoreML maybe?
    ]
    @State private var newMessageText: String = ""
    @State private var isWaitingForResponse: Bool = false
    @State private var selectedModel: Message.AIModel = .localCoreML
    @State private var currentError: String? = nil

    // CoreML Model state - Lazily loaded
    @State private var coreMLModel: SimpleChatResponder? = nil // Replace 'SimpleChatResponder' with your generated class name
    @State private var coreMLModelLoadError: String? = nil

    // --- API Streaming Simulation State (Only for API Paths) ---
    @State private var streamTimer: Timer?
    @State private var currentlyStreamingMessageId: UUID?
    @State private var fullStreamingResponse: String = ""
    @State private var streamIndex: Int = 0
    // -----------------------------------------------------------

    var body: some View {
        VStack(spacing: 0) {
            ModelSelectorView(selectedModel: $selectedModel)
                .padding(.bottom, 5)

            Divider()

            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach($messages) { $message in
                            MessageBubble(message: $message)
                                .id(message.id)
                        }
                        if isWaitingForResponse {
                            TypingIndicatorBubble()
                                .id("typingIndicator")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                .onChange(of: messages.count) { scrollToBottom(proxy: scrollViewProxy) }
                .onChange(of: isWaitingForResponse) { if isWaitingForResponse { scrollToBottom(proxy: scrollViewProxy, id: UUID()) } }
            }

            // Display CoreML load error or regular errors
            if let error = currentError ?? coreMLModelLoadError {
                ErrorDisplayView(errorMessage: error) {
                    currentError = nil
                    coreMLModelLoadError = nil
                }
                .animation(.default, value: currentError ?? coreMLModelLoadError)
            }

            HStack {
                TextField("Ask \(selectedModel.rawValue)...", text: $newMessageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Color(white: 0.15))
                    .cornerRadius(18)
                    .lineLimit(1...5)
                    .disabled(isWaitingForResponse || coreMLModelLoadError != nil) // Disable if loading or model failed to load

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: isWaitingForResponse ? "stop.circle.fill" : "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(isWaitingForResponse ? .red : (newMessageText.isEmpty ? .gray : .yellow))
                }
                .disabled(newMessageText.isEmpty && !isWaitingForResponse)
            }
            .padding()
            .background(Color(white: 0.1))
        }
        .background(Color.black.ignoresSafeArea())
        .foregroundColor(.white)
        .onAppear(perform: loadCoreMLModel) // Attempt to load model on appear
        .onDisappear {
            stopStreaming() // Clean up API stream timer if view disappears
        }
    }

    // MARK: - CoreML Logic

    // Function to load the CoreML model instance
    func loadCoreMLModel() {
        guard coreMLModel == nil && coreMLModelLoadError == nil else { return } // Load only once or if previous attempt failed

        do {
            // --- Replace 'SimpleChatResponder' with your actual generated class name ---
            coreMLModel = try SimpleChatResponder(configuration: MLModelConfiguration())
            print("CoreML Model loaded successfully.")
        } catch {
            print("Error loading CoreML model: \(error)")
            coreMLModelLoadError = "Failed to load the local AI model. Please restart the app. Details: \(error.localizedDescription)"
            coreMLModel = nil // Ensure it's nil if loading fails
        }
    }

    // Function to handle CoreML prediction
    func performCoreMLPrediction(text: String) {
        guard let model = coreMLModel else {
            currentError = "Local AI model is not loaded."
            isWaitingForResponse = false
            return
        }

        // Dispatch prediction to background thread
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // --- Replace 'SimpleChatResponderInput' and input/output names ---
                let input = SimpleChatResponderInput(inputText: text) // Prepare input object
                let prediction = try model.prediction(input: input)
                let responseText = prediction.outputText // Extract output text

                // Dispatch UI update back to main thread
                DispatchQueue.main.async {
                    addMessage(text: responseText, isUser: false, model: .localCoreML)
                    isWaitingForResponse = false
                }
            } catch {
                print("CoreML Prediction Error: \(error)")
                // Dispatch error update back to main thread
                DispatchQueue.main.async {
                    currentError = "Local AI failed to respond. Details: \(error.localizedDescription)"
                    isWaitingForResponse = false
                }
            }
        }
    }

    // MARK: - Message Handling

    // Central function to add messages to the state
    func addMessage(text: String, isUser: Bool, model: Message.AIModel? = nil, error: String? = nil) {
        let newMessage = Message(text: text, isUser: isUser, sourceModel: model, error: error)
        messages.append(newMessage)
    }

    func sendMessage() {
        guard !newMessageText.isEmpty else { return }
        stopStreaming() // Stop any ongoing API streams

        let userText = newMessageText
        addMessage(text: userText, isUser: true)
        newMessageText = ""
        currentError = nil // Clear previous errors

        // --- Conditional Logic Based on Selected Model ---
        switch selectedModel {
        case .localCoreML:
             guard coreMLModelLoadError == nil else {
                 currentError = "Local AI model failed to load earlier. Cannot send message."
                 return
             }
             guard coreMLModel != nil else {
                  currentError = "Local AI model hasn't loaded yet. Please try again."
                  return // Or trigger loading again?
             }
            isWaitingForResponse = true
            performCoreMLPrediction(text: userText)

        case .chatGPT_3_5, .chatGPT_4:
            isWaitingForResponse = true
            // Simulate API Call (Keep simulation for API paths for this example)
            let responseDelay = Double.random(in: 0.5...2.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + responseDelay) {
                 isWaitingForResponse = false // Stop global loading indicator

                 if userText.lowercased().contains("error") {
                     currentError = "Simulated Error: Could not connect to \(selectedModel.rawValue) service."
                     return
                 }

                 let responseText = generateMockResponse(to: userText, model: selectedModel)
                 let responseMessageId = UUID()
                 // Create the initial empty message for streaming
                let aiMessage = Message(id: responseMessageId, text: "", isUser: false, sourceModel: selectedModel)
                 messages.append(aiMessage)

                 startStreamingResponse(for: responseMessageId, fullText: responseText)
            }
        }
    }

    // MARK: - API Streaming Simulation (Unchanged from previous)

    func startStreamingResponse(for messageId: UUID, fullText: String) {
        // Reset just in case
        stopStreaming()

        guard let messageIndex = messages.firstIndex(where: { $0.id == messageId }) else { return }

        currentlyStreamingMessageId = messageId
        fullStreamingResponse = fullText
        streamIndex = 0
        messages[messageIndex].text = "" // Explicitly clear text before starting stream

        streamTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            guard streamIndex < fullStreamingResponse.count,
                  let currentId = currentlyStreamingMessageId, // Ensure we are still streaming
                  let msgIdx = messages.firstIndex(where: { $0.id == currentId }) // Find message index again
            else {
                stopStreaming()
                return
            }

            let nextCharIndex = fullStreamingResponse.index(fullStreamingResponse.startIndex, offsetBy: streamIndex)
            messages[msgIdx].text.append(fullStreamingResponse[nextCharIndex])
            streamIndex += 1

            // Optional: Auto-scroll während des Streamings, kann aber ruckelig wirken
            // if streamIndex % 5 == 0 { // Scroll every 5 characters perhaps
            //     scrollToBottom(proxy: /* Need ScrollViewProxy here */, id: currentId)
            // }
        }
    }

    func stopStreaming() {
        streamTimer?.invalidate()
        streamTimer = nil
        currentlyStreamingMessageId = nil
        fullStreamingResponse = ""
        streamIndex = 0
    }

    // Mock response generator (unchanged)
    func generateMockResponse(to input: String, model: Message.AIModel) -> String {
        // ... (same implementation as before) ...
         let modelPrefix = "[\(model.rawValue)]:"
         let lowercasedInput = input.lowercased()

         if lowercasedInput.contains("hello") || lowercasedInput.contains("hi") {
             return "\(modelPrefix) Hi there! 👋 How can I help you with the power of \(model.rawValue.split(separator: " ")[0])?"
         } else if lowercasedInput.contains("coreml") && model == .localCoreML {
             // This won't be hit via this function anymore if CoreML path works
             return "\(modelPrefix) (Mocked If CoreML Failed) Yes, I should be running locally using CoreML."
         } else if lowercasedInput.contains("chatgpt") && (model == .chatGPT_3_5 || model == .chatGPT_4) {
             return "\(modelPrefix) Indeed! I'm accessing the \(model.rawValue) API. My responses can be more detailed and context-aware, but require network access."
         } else if lowercasedInput.contains("stream") && model != .localCoreML {
             return "\(modelPrefix) Absolutely! I can stream this response back to you character by character, making it feel more interactive, just like this explanation is appearing right now."
         } else {
             return "\(modelPrefix) Simulating a response for '\(input)' using \(model.rawValue). This is a generic reply."
         }
    }

    // MARK: - Utilities (Unchanged)

    func scrollToBottom(proxy: ScrollViewProxy, id: UUID? = nil) {
         // ... (same implementation as before) ...
        let targetId = id ?? messages.last?.id
         guard let targetId = targetId else { return }
         withAnimation(.spring()) {
             proxy.scrollTo(targetId, anchor: .bottom)
         }
    }
}

// MARK: - Helper UI Components (Unchanged from previous)

struct ModelSelectorView: View {
    @Binding var selectedModel: Message.AIModel

    var body: some View {
        HStack {
            Text("AI Model:")
                .font(.caption)
                .foregroundColor(.gray)
            // Use explicit ID with ForEach for Picker stability
            Picker("Select Model", selection: $selectedModel) {
                ForEach(Message.AIModel.allCases) { model in // Removed id: \.self
                    Text(model.rawValue).tag(model)
                }
            }
            .pickerStyle(.menu)
            .accentColor(.yellow)
            .padding(.horizontal, -10)
            .id(UUID()) // Force redraw if cases change? Sometimes needed.
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(Color(white: 0.05))
    }
}

struct MessageBubble: View {
    @Binding var message: Message

    var body: some View {
         HStack(alignment: .bottom, spacing: 8) {
             if message.isUser { Spacer() }

             if !message.isUser, let model = message.sourceModel {
                 Image(systemName: model.systemImageName)
                     .font(.caption)
                     .foregroundColor(.gray)
                     .padding(.bottom, 5)
                     .accessibilityLabel("Model: \(model.rawValue)")
             }

             // Use TextEditor for selectable text, potentially, but simpler with Text
             Text(message.text.isEmpty && !message.isUser && message.error == nil ? "..." : message.text) // Show ellipsis if empty AI message
                 .padding(12)
                 .background(messageContentBackground())
                 .foregroundColor(message.isUser ? .black : .white)
                 .cornerRadius(15)
                 .frame(maxWidth: 300, alignment: message.isUser ? .trailing : .leading)
                 .overlay(
                     message.error != nil ?
                     RoundedRectangle(cornerRadius: 15).stroke(Color.red, lineWidth: 1)
                     : nil
                 )
                 .contextMenu { // Allow copying
                     Button {
                         UIPasteboard.general.string = message.text
                     } label: {
                         Label("Copy", systemImage: "doc.on.doc")
                     }
                 }

             if !message.isUser { Spacer() }
         }
         .animation(.easeOut(duration: 0.2), value: message.text) // Animate text changes smoothly
    }

    @ViewBuilder
    private func messageContentBackground() -> some View {
        if message.isUser {
            Color.yellow.opacity(0.9)
        } else if message.error != nil {
            Color.red.opacity(0.4)
        } else {
            Color(white: 0.25)
        }
    }
}

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
         .onAppear { scale = 1.0 }
         .frame(maxWidth: 300, alignment: .leading)
         .transition(.opacity.combined(with: .scale(scale: 0.5, anchor: .bottomLeading)))
         .accessibilityLabel("Assistant is typing")
    }
}

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
                 withAnimation { dismissAction() } // Animate dismissal
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
         .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        EnhancedChatView()
            .navigationTitle("AI Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
    .preferredColorScheme(.dark)
    .tint(.yellow)
}
