////
////  EnhancedChatView.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
////
////  EnhancedChatView.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
////  Description: SwiftUI view implementing a chat interface with support
////               for a local CoreML model and simulated API models.
////               Includes stubs for CoreML tokenization and decoding.
////
//
//import SwiftUI
//import CoreML // Import CoreML
//
//// MARK: - Data Models
//
//// Represents a single message in the chat.
//struct Message: Identifiable, Equatable {
//    let id = UUID()
//    var text: String // Use 'var' to allow modification for streaming simulation (API only)
//    let isUser: Bool
//    let timestamp: Date = Date()
//    var sourceModel: AIModel? = nil // Which AI model generated the message (nil for user)
//    var isLoading: Bool = false // Placeholder for potential future use
//    var error: String? = nil // Optional error message associated with the message
//
//    // Enum defining the available AI models.
//    enum AIModel: String, CaseIterable, Identifiable, Equatable {
//        case localCoreML = "CoreML (Local)"
//        case chatGPT_3_5 = "ChatGPT 3.5"
//        case chatGPT_4 = "ChatGPT 4 (Advanced)"
//
//        var id: String { self.rawValue } // Conformance to Identifiable for Picker
//
//        // Provides an icon for each model type.
//        var systemImageName: String {
//            switch self {
//            case .localCoreML: return "cpu" // Icon representing local processing
//            case .chatGPT_3_5: return "cloud" // Icon representing network/API
//            case .chatGPT_4: return "sparkles" // Icon for the more advanced API model
//            }
//        }
//    }
//
//    // Equatable conformance needed for observing changes in LazyVStack with bindings
//    static func == (lhs: Message, rhs: Message) -> Bool {
//        lhs.id == rhs.id &&
//        lhs.text == rhs.text &&
//        lhs.isUser == rhs.isUser &&
//        lhs.timestamp == rhs.timestamp && // Consider tolerance if needed
//        lhs.sourceModel == rhs.sourceModel &&
//        lhs.isLoading == rhs.isLoading &&
//        lhs.error == rhs.error
//    }
//}
//
//// MARK: - Enhanced Chat View with Specific CoreML Integration
//
//struct EnhancedChatView: View {
//    // MARK: State Variables
//
//    // Chat messages array
//    @State private var messages: [Message] = [
//        Message(text: "Hello! Choose a model and start chatting. Note: The local CoreML model uses placeholder logic for processing.", isUser: false, sourceModel: .localCoreML),
//    ]
//    // Text currently typed by the user
//    @State private var newMessageText: String = ""
//    // Flag indicating if the app is waiting for an AI response (global indicator)
//    @State private var isWaitingForResponse: Bool = false
//    // Currently selected AI model
//    @State private var selectedModel: Message.AIModel = .localCoreML
//    // Holds the current error message to display
//    @State private var currentError: String? = nil
//
//    // --- CoreML Specific State ---
//    // Instance of the loaded CoreML model (replace 'SimpleChatResponder' with your actual model class)
//    @State private var coreMLModel: SimpleChatResponder? = nil
//    // Stores any error encountered during CoreML model loading
//    @State private var coreMLModelLoadError: String? = nil
//    // Defines the expected input sequence length for the CoreML model
//    // NOTE: This should match the input shape defined in your CoreML model.
//    private let coreMLInputLength = 64 // Example: Adjust based on your model
//
//    // --- API Streaming Simulation State (Only for API Paths) ---
//    @State private var streamTimer: Timer? // Timer for character-by-character streaming
//    @State private var currentlyStreamingMessageId: UUID? // ID of the message being streamed
//    @State private var fullStreamingResponse: String = "" // The complete response text to be streamed
//    @State private var streamIndex: Int = 0 // Current character index in the stream
//
//    // MARK: Body
//    var body: some View {
//        EmptyView()
//    }
//
////    var body: some View {
////        VStack(spacing: 0) { // Use spacing 0 for tighter control
////            // Model Selection UI
////            ModelSelectorView(selectedModel: $selectedModel)
////                .padding(.bottom, 5) // Add slight padding below selector
////
////            Divider() // Visual separator
////
////            // Scrollable Chat Area
////            ScrollViewReader { scrollViewProxy in
////                ScrollView {
////                    // Use LazyVStack for performance with many messages
////                    LazyVStack(spacing: 12) {
////                        ForEach($messages) { $message in // Use Binding ForEach for streaming updates
////                            MessageBubble(message: $message)
////                                .id(message.id) // Make each message identifiable for scrolling
////                                .equatable() // Ensure redraws only happen on actual changes
////                        }
////                        // Show typing indicator only when actively waiting (not during streaming)
////                        if isWaitingForResponse {
////                            TypingIndicatorBubble()
////                                .id("typingIndicator") // Identifiable ID for typing indicator
////                                .transition(.opacity) // Fade in/out
////                        }
////                    }
////                    .padding(.horizontal) // Padding on the sides of messages
////                    .padding(.top) // Padding above the first message
////                }
////                // Auto-scroll logic
////                .onChange(of: messages.count) { _, _ in scrollToBottom(proxy: scrollViewProxy) } // Scroll on new message
////                .onChange(of: isWaitingForResponse) { _, newValue in // Scroll when indicator appears/disappears
////                    if newValue { // If indicator just appeared
////                        scrollToBottom(proxy: scrollViewProxy, id: "typingIndicator")
////                    } else if !messages.isEmpty { // If indicator just disappeared, scroll to last message
////                         scrollToBottom(proxy: scrollViewProxy)
////                    }
////                }
////                 .onChange(of: currentlyStreamingMessageId) { _, _ in // Scroll as streaming happens if needed
////                     guard currentlyStreamingMessageId != nil else { return }
////                     scrollToBottom(proxy: scrollViewProxy) // Scroll to keep latest streamed content visible
////                 }
////            }
////
////            // Error Display Area
////            // Shows CoreML load errors OR general runtime errors
////            if let error = currentError ?? coreMLModelLoadError {
////                ErrorDisplayView(errorMessage: error) {
////                    // Dismiss action: clear runtime errors, but keep persistent load errors
////                    if currentError != nil {
////                        currentError = nil
////                    }
////                }
////                .animation(.easeInOut, value: currentError ?? coreMLModelLoadError) // Animate error appearance
////            }
////
////            // Input Area
////            HStack(alignment: .bottom) { // Align items to the bottom for better multi-line textfield behavior
////                // Text Field for user input
////                TextField("Ask \(selectedModel.rawValue)...", text: $newMessageText, axis: .vertical) // Allow vertical expansion
////                    .textFieldStyle(.plain) // Simple style without default border/background
////                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)) // Custom padding
////                    .background(Color(uiColor: .systemGray6)) // Subtle background
////                    .clipShape(Capsule()) // Rounded capsule shape
////                    .lineLimit(1...5) // Allow up to 5 lines of text
////                    // Disable input if waiting for any response OR if CoreML is selected but failed to load
////                    .disabled(isWaitingForResponse || (selectedModel == .localCoreML && coreMLModelLoadError != nil))
////                    .opacity(isWaitingForResponse || (selectedModel == .localCoreML && coreMLModelLoadError != nil) ? 0.6 : 1.0) // Dim if disabled
////
////                // Send / Stop Button
////                Button {
////                    if isWaitingForResponse && (selectedModel == .chatGPT_3_5 || selectedModel == .chatGPT_4) {
////                        stopStreaming() // Stop API streaming if in progress
////                        isWaitingForResponse = false // Manually reset global flag if needed
////                    } else {
////                        sendMessage() // Send message if not waiting or if it's CoreML
////                    }
////                } label: {
////                    // Icon changes based on state: arrow up to send, stop for cancel API stream
////                    Image(systemName: isWaitingForResponse && (selectedModel == .chatGPT_3_5 || selectedModel == .chatGPT_4) ? "stop.circle.fill" : "arrow.up.circle.fill")
////                        .resizable()
////                        .scaledToFit()
////                        .frame(width: 30, height: 30)
////                        // Color indicates state: Red to stop, Yellow to send, Gray if disabled
////                        .foregroundColor(
////                            isWaitingForResponse && (selectedModel == .chatGPT_3_5 || selectedModel == .chatGPT_4) ? .red :
////                            (newMessageText.isEmpty ? .gray : .blue) // Use blue for send
////                        )
////                }
////                // Disable send button if text is empty OR if waiting for CoreML OR if CoreML failed loading
////                .disabled(newMessageText.isEmpty || (isWaitingForResponse && selectedModel == .localCoreML) || (selectedModel == .localCoreML && coreMLModelLoadError != nil))
////                .animation(.easeInOut, value: isWaitingForResponse) // Animate button state changes
////                .animation(.easeInOut, value: newMessageText.isEmpty)
////            }
////            .padding(.horizontal)
////            .padding(.vertical, 8) // Vertical padding for the input bar
////            .background(.thinMaterial) // Use material background for subtle effect
////        }
////        .background(Color(uiColor: .systemBackground).ignoresSafeArea()) // Use system background
////        .tint(.blue) // Global tint color for interactive elements
////        .onAppear(perform: loadCoreMLModel) // Attempt to load the CoreML model when the view appears
////        .onDisappear {
////            stopStreaming() // Clean up the API stream timer if the view disappears
////        }
////    }
//
//    // MARK: - CoreML Logic
//
//    // Loads the CoreML model instance asynchronously.
//    func loadCoreMLModel() {
//        // Prevent reloading if already loaded or if load already failed
//        guard coreMLModel == nil && coreMLModelLoadError == nil else { return }
//
//        print("Attempting to load CoreML model 'SimpleChatResponder'...")
//        // Perform loading in a background task to avoid blocking UI
//        Task(priority: .utility) {
//            do {
//                // Replace 'SimpleChatResponder' with the actual class generated by Xcode from your model
//                let loadedModel = try SimpleChatResponder(configuration: MLModelConfiguration())
//                // Update state on the main thread
//                await MainActor.run {
//                    self.coreMLModel = loadedModel
//                    print("✅ CoreML Model 'SimpleChatResponder' loaded successfully.")
//                    self.coreMLModelLoadError = nil // Clear any previous error state on success
//                }
//            } catch {
//                print("❌ Error L0ADING CoreML model 'SimpleChatResponder': \(error)")
//                // Update state on the main thread
//                await MainActor.run {
//                    self.coreMLModelLoadError = "Failed to load the local AI model. Please check logs or restart. (\(error.localizedDescription))"
//                    self.coreMLModel = nil // Ensure model is nil on failure
//                }
//            }
//        }
//    }
//
//    // --- STUB FUNCTION: Tokenization ---
//    // Converts input text into MLMultiArrays for 'input_ids' and 'position_ids'.
//    // Needs to be replaced with actual tokenizer logic matching your model.
//    func tokenizeAndPad(text: String, maxLength: Int) -> (inputIds: MLMultiArray?, positionIds: MLMultiArray?, error: String?) {
//        print("⚠️ [STUB] Tokenizing '\(text)' to maxLength \(maxLength). **REAL IMPLEMENTATION REQUIRED.**")
//
//        // --- Placeholder Implementation ---
//        // This creates zero-filled arrays. A real implementation would use a tokenizer
//        // (e.g., SentencePiece, Hugging Face Tokenizers) to get actual token IDs and attention mask/position IDs.
//        let shape: [NSNumber] = [1, NSNumber(value: maxLength)] // Shape [BatchSize, SequenceLength]
//
//        do {
//            // Create MLMultiArray for input_ids (token IDs)
//            let inputIdsArray = try MLMultiArray(shape: shape, dataType: .int32) // Use Int32 if model expects integers
//            // Create MLMultiArray for position_ids (indices 0 to maxLength-1)
//            let positionIdsArray = try MLMultiArray(shape: shape, dataType: .int32)
//
//            // --- Fill with PLACEHOLDER data ---
//            // Real implementation: Use tokenizer.encode(text) -> get IDs, pad/truncate to maxLength
//            for i in 0..<maxLength {
//                inputIdsArray[i] = 0 // Placeholder: Pad token ID often 0. Real IDs depend on text & vocab.
//                positionIdsArray[i] = NSNumber(value: i) // Position ID is typically the index
//            }
//            // ----------------------------------
//
//            print("⚠️ [STUB] Returning placeholder zero-filled MLMultiArrays.")
//            return (inputIdsArray, positionIdsArray, nil)
//        } catch {
//            let errorMsg = "Failed to create placeholder MLMultiArray inputs: \(error.localizedDescription)"
//            print("❌ \(errorMsg)")
//            return (nil, nil, errorMsg)
//        }
//    }
//
//    // --- STUB FUNCTION: Decoding ---
//    // Converts the model's output logits (MLMultiArray) back into text.
//    // Needs to be replaced with actual decoding logic using the model's vocabulary.
//    func decodeLogits(logits: MLMultiArray) -> String {
//        print("⚠️ [STUB] Decoding output logits. **REAL IMPLEMENTATION REQUIRED.**")
//
//        // --- Placeholder Implementation ---
//        // A real implementation would find the index with the highest probability
//        // for each position in the sequence (argmax) and map these indices back to
//        // tokens/words using the model's vocabulary file.
//
//        let shapeDescription = logits.shape.map { $0.stringValue }.joined(separator: "x")
//        let dataTypeDescription = logits.dataType.description // e.g., MLMultiArrayDataType.float32
//
//        // Example: Accessing a specific logit (e.g., first logit of first item in batch/sequence)
//        // let firstLogitValue = logits[[0, 0, 0] as [NSNumber]] // Requires knowing the exact shape
//
//        return "[CoreML Responded - Logits Shape: \(shapeDescription), DataType: \(dataTypeDescription). STUB Decoding.]"
//        // --------------------------------
//    }
//
//    // Performs prediction using the loaded CoreML model.
//    func performCoreMLPrediction(text: String) {
//        print("🤖 Starting CoreML prediction for text: '\(text)'")
//        guard let model = coreMLModel else {
//            let errorMsg = "Local AI model is not loaded. Cannot perform prediction."
//            print("❌ \(errorMsg)")
//            // Update UI on main thread immediately
//            DispatchQueue.main.async {
//                self.currentError = errorMsg
//                self.isWaitingForResponse = false
//            }
//            return
//        }
//
//        // 1. Tokenize and Pad Input (using STUB function)
//        // This happens synchronously before the background task.
//        let tokenizationResult = tokenizeAndPad(text: text, maxLength: coreMLInputLength)
//
//        guard let inputIds = tokenizationResult.inputIds,
//              let positionIds = tokenizationResult.positionIds,
//              tokenizationResult.error == nil else {
//            let errorMsg = "CoreML Input Error: \(tokenizationResult.error ?? "Tokenization failed.")"
//            print("❌ \(errorMsg)")
//            // Update UI on main thread immediately
//            DispatchQueue.main.async {
//                self.currentError = errorMsg
//                self.isWaitingForResponse = false
//            }
//            return
//        }
//
//        // 2. Perform Prediction Asynchronously
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                 // Create the specific input object required by the CoreML model's generated class
//                 // Replace 'SimpleChatResponderInput' if your model generated a different input class name.
//                 let input = SimpleChatResponderInput(input_ids: inputIds, position_ids: positionIds)
//
//                 print("🤖 Performing CoreML model.prediction(input:)...")
//                 let predictionStartTime = Date()
//                 let predictionOutput = try model.prediction(input: input)
//                 let predictionDuration = Date().timeIntervalSince(predictionStartTime)
//                 print("🤖 CoreML prediction successful (took \(String(format: "%.3f", predictionDuration))s).")
//
//                 // 3. Decode Output Logits (using STUB function)
//                 // Replace 'output_logits' if your model's output has a different name.
//                 let responseText = decodeLogits(logits: predictionOutput.output_logits)
//
//                // 4. Update UI on Main Thread with the result
//                DispatchQueue.main.async {
//                    print("🤖 CoreML Response (decoded stub): \(responseText)")
//                    addMessage(text: responseText, isUser: false, model: .localCoreML)
//                    self.isWaitingForResponse = false // Mark as done
//                    self.currentError = nil // Clear any previous error on success
//                }
//            } catch {
//                let errorMsg = "Local AI failed to respond. Details: \(error.localizedDescription)"
//                print("❌ CoreML Prediction Error: \(error)")
//                // Update UI on Main Thread with the error
//                DispatchQueue.main.async {
//                    self.currentError = errorMsg
//                    // Optionally add an error message bubble
//                    // addMessage(text: "Error processing request.", isUser: false, model: .localCoreML, error: errorMsg)
//                    self.isWaitingForResponse = false // Mark as done even on error
//                }
//            }
//        }
//    }
//
//    // MARK: - Message Handling
//
//    // Adds a new message to the chat history array.
//    func addMessage(text: String, isUser: Bool, model: Message.AIModel? = nil, error: String? = nil) {
//        let newMessage = Message(text: text, isUser: isUser, sourceModel: model, error: error)
//        messages.append(newMessage)
//        print("Message added: \(isUser ? "User" : "AI (\(model?.rawValue ?? "N/A"))") - '\(text)'")
//    }
//
//    // Handles sending the user's message and triggering the appropriate AI response.
//    func sendMessage() {
//        let trimmedText = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedText.isEmpty else { return } // Don't send empty messages
//
//        print("Sending message as \(selectedModel.rawValue)...")
//
//        stopStreaming() // Stop any ongoing API streams before sending new message
//        currentError = nil // Clear previous errors
//
//        addMessage(text: trimmedText, isUser: true)
//        let userTextForAI = trimmedText // Keep original for AI processing
//        newMessageText = "" // Clear input field immediately
//
//        // Branch logic based on selected model
//        switch selectedModel {
//        case .localCoreML:
//            // Check CoreML pre-requisites
//            guard coreMLModelLoadError == nil else {
//                 currentError = "Local AI model failed to load earlier. Cannot send message."
//                 print("❌ \(currentError!)")
//                 return
//            }
//            guard coreMLModel != nil else {
//                  currentError = "Local AI model isn't ready yet. Retrying load..."
//                  print("⚠️ \(currentError!)")
//                  loadCoreMLModel() // Attempt to load again if it wasn't ready
//                  // Don't proceed immediately, wait for load attempt
//                  return
//            }
//            // Set loading indicator and perform prediction
//            isWaitingForResponse = true
//            performCoreMLPrediction(text: userTextForAI)
//
//        case .chatGPT_3_5, .chatGPT_4:
//            // --- Simulate API Call ---
//            isWaitingForResponse = true // Show global typing indicator
//            let responseDelay = Double.random(in: 0.5...1.5) // Simulate network latency
//            print("Simulating API call to \(selectedModel.rawValue) with delay: \(responseDelay)s")
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + responseDelay) {
//                // Re-check if the model selection changed while waiting
//                 guard self.selectedModel == .chatGPT_3_5 || self.selectedModel == .chatGPT_4 else {
//                     print("Model changed during API wait. Cancelling response.")
//                     self.isWaitingForResponse = false // Stop indicator if model changed
//                     return
//                 }
//
//                 // Simulate potential API Error
//                 if userTextForAI.lowercased().contains("trigger error") { // Example trigger phrase
//                     let errorMsg = "Simulated Error: Could not connect to \(selectedModel.rawValue)."
//                     print("❌ \(errorMsg)")
//                     self.currentError = errorMsg
//                     self.isWaitingForResponse = false // Stop indicator on error
//                     // Optionally add an error message bubble
//                     // addMessage(text: "Failed to get response.", isUser: false, model: self.selectedModel, error: errorMsg)
//                     return
//                 }
//
//                 // Generate and Stream Mock Response
//                 let responseText = generateMockResponse(to: userTextForAI, model: selectedModel)
//                 let aiMessageId = UUID() // Generate ID for the new AI message
//                 // Add an *empty* message placeholder first
//                 addMessage(text: "", isUser: false, model: selectedModel)
//
//                 // Stop the *global* waiting indicator *before* starting stream
//                 self.isWaitingForResponse = false
//
//                 // Find the index of the newly added empty message and start streaming into it
//                if let index = self.messages.firstIndex(where: { $0.id == aiMessageId }) {
//                     startStreamingResponse(for: messages[index].id, fullText: responseText)
//                 } else {
//                     print("Error: Could not find placeholder message to start streaming.")
//                 }
//            }
//        }
//    }
//
//    // MARK: - API Streaming Simulation (Only for non-CoreML models)
//
//    // Starts the timer to simulate streaming text character by character.
//    func startStreamingResponse(for messageId: UUID, fullText: String) {
//        stopStreaming() // Ensure any previous timer is stopped
//
//        print("Starting stream for message ID: \(messageId)")
//        guard let messageIndex = messages.firstIndex(where: { $0.id == messageId }) else {
//            print("Error: Cannot find message \(messageId) to stream into.")
//            return
//        }
//
//        // Ensure the target message text is empty before starting
//        messages[messageIndex].text = ""
//
//        currentlyStreamingMessageId = messageId
//        fullStreamingResponse = fullText
//        streamIndex = 0
//
//        // Timer fires frequently to append characters
//        streamTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
////            guard let self = self else { timer.invalidate(); return }
//
//            // Ensure we are still supposed to be streaming this message
//            guard let currentId = self.currentlyStreamingMessageId, currentId == messageId else {
//                print("Streaming stopped or message ID changed.")
//                self.stopStreaming()
//                return
//            }
//
//            // Find message index again, as array might change
//            guard let msgIdx = self.messages.firstIndex(where: { $0.id == currentId }) else {
//                print("Error: Lost track of message \(currentId) during stream.")
//                self.stopStreaming()
//                return
//            }
//
//             // Check if stream is complete
//            guard self.streamIndex < self.fullStreamingResponse.count else {
//                print("Stream finished for message ID: \(messageId)")
//                self.stopStreaming()
//                return
//            }
//
//            // Append next character
//            let nextCharIndex = self.fullStreamingResponse.index(self.fullStreamingResponse.startIndex, offsetBy: self.streamIndex)
//            self.messages[msgIdx].text.append(self.fullStreamingResponse[nextCharIndex])
//            self.streamIndex += 1
//        }
//    }
//
//    // Stops the streaming timer and resets streaming state.
//    func stopStreaming() {
//        if streamTimer != nil {
//             print("Stopping stream. Last ID: \(currentlyStreamingMessageId?.uuidString ?? "None")")
//            streamTimer?.invalidate()
//            streamTimer = nil
//            currentlyStreamingMessageId = nil
//            fullStreamingResponse = ""
//            streamIndex = 0
//        }
//    }
//
//    // Generates a placeholder response based on input (for API simulation).
//    func generateMockResponse(to input: String, model: Message.AIModel) -> String {
//         let modelPrefix = "[\(model.rawValue)]:"
//         let lowercasedInput = input.lowercased()
//
//         if lowercasedInput.contains("hello") || lowercasedInput.contains("hi") {
//             return """
//             \(modelPrefix) Hello there! 👋 As a simulated \(model.rawValue), I can generate text like this. How can I assist you today? I can talk about CoreML, APIs, or even simulate streaming text back to you, character by character.
//             """
//         } else if lowercasedInput.contains("coreml") {
//             return "\(modelPrefix) You mentioned CoreML! While I'm just simulating \(model.rawValue), a real CoreML model would run directly on your device for fast, private inference. It requires specific input formatting (like token IDs) and decoding logic (using a vocabulary) which aren't fully implemented in this simulation's CoreML path, but the structure is there!"
//         } else if lowercasedInput.contains("chatgpt") && (model == .chatGPT_3_5 || model == .chatGPT_4) {
//             return "\(modelPrefix) Yes, I'm currently simulating the \(model.rawValue) API. In a real scenario, this would involve sending your prompt (\(input)) over the network and receiving a response, potentially streamed back. The advantage is leveraging powerful, large models hosted elsewhere."
//         } else if lowercasedInput.contains("stream") && model != .localCoreML {
//             return "\(modelPrefix) Streaming is a neat feature often used in APIs! Watch as this text appears gradually... It improves the perceived responsiveness, rather than waiting for the entire block of text to be generated before showing anything. This simulation uses a simple Timer."
//         } else if lowercasedInput.contains("whisper") {
//             return "\(modelPrefix) Whisper is fascinating! It's primarily known for highly accurate speech-to-text. While this chat app focuses on text-to-text, integrating WhisperKit could allow for voice input, transcribing it locally or via an API, and then feeding that text into a model like me or the local CoreML one."
//         }
//         else {
//             return "\(modelPrefix) I've processed your input: '\(input)'. Since this is a simulation based on \(model.rawValue), here's a generic reply acknowledging your message. Ask about 'CoreML', 'ChatGPT', 'streaming', or 'Whisper' for more specific simulated info!"
//         }
//    }
//
//    // MARK: - Utilities
//
//    // Scrolls the chat view to the specified message ID or the bottom.
//    func scrollToBottom(proxy: ScrollViewProxy, id: AnyHashable? = nil) {
//        let targetId = id ?? messages.last?.id // Use provided ID or default to last message
//         guard let targetId = targetId else { return } // Ensure we have a target
//
//         // Use DispatchQueue to slightly delay scroll, allows UI to update first sometimes
//         DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//              withAnimation(.spring(duration: 0.4)) { // Use spring animation for smooth scroll
//                 proxy.scrollTo(targetId, anchor: .bottom)
//             }
//         }
//    }
//}
//
//// MARK: - Helper UI Components (Mostly Unchanged, minor style tweaks)
//
//// View for selecting the AI model using a Picker.
//struct ModelSelectorView: View {
//    @Binding var selectedModel: Message.AIModel
//
//    var body: some View {
//        HStack {
//            Text("AI Engine:")
//                .font(.caption)
//                .foregroundColor(.secondary) // Use secondary color for label
//
//            Picker("Select Model", selection: $selectedModel) {
//                ForEach(Message.AIModel.allCases) { model in
//                    Label {
//                         Text(model.rawValue).font(.caption2) // Smaller font in picker
//                    } icon: {
//                        Image(systemName: model.systemImageName)
//                    }
//                    .tag(model)
//                }
//            }
//            .pickerStyle(.menu) // Dropdown menu style
//            // .accentColor(.blue) // Removed, use global tint
//            .frame(maxWidth: .infinity, alignment: .trailing) // Push picker to the right
//            .labelsHidden() // Hide the "Select Model" label in the button itself
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 5)
//        // Optional: Add a subtle background or border
//        // .background(Color(uiColor: .secondarySystemBackground))
//        // .cornerRadius(8)
//    }
//}
//
//// View for displaying a single chat message bubble.
//struct MessageBubble: View {
//    @Binding var message: Message // Use Binding to allow external updates (e.g., streaming)
//
//    // Computed property for accessibility label
//    private var accessibilityLabelText: String {
//        let prefix = message.isUser ? "Your message" : "\(message.sourceModel?.rawValue ?? "AI") message"
//        let errorSuffix = message.error != nil ? ". Error occurred." : ""
//        return "\(prefix): \(message.text)\(errorSuffix)"
//    }
//
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 6) { // Reduced spacing
//            // Push user messages to the right
//            if message.isUser { Spacer(minLength: 50) } // Ensure minimum spacing for user
//
//            // AI Model Icon (if applicable)
//            if !message.isUser, let model = message.sourceModel {
//                Image(systemName: model.systemImageName)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                    .padding(.bottom, 5) // Align near bottom of bubble
//                    .accessibilityHidden(true) // Icon is decorative, info is in bubble label
//                    .frame(width: 15, height: 15) // Give icon explicit frame
//            }
//
//            // Message Text Content
//            // Use a placeholder for empty streaming messages
//            Text(message.text.isEmpty && !message.isUser && message.error == nil ? "..." : message.text)
//                .font(.body)
//                .padding(message.isUser ? 10 : 12) // Slightly different padding
//                .background(messageContentBackground())
//                .foregroundColor(messageForegroundColor()) // Dynamic text color
//                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)) // Smoother corners
//                .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading) // Allow bubble to expand
//                .overlay( // Error indicator border
//                    message.error != nil ?
//                    RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.red, lineWidth: 1.5)
//                    : nil
//                )
//                .contextMenu { // Allow copying text
//                    Button {
//                        UIPasteboard.general.string = message.text
//                    } label: {
//                        Label("Copy Text", systemImage: "doc.on.doc")
//                    }
//                }
//                .accessibilityElement(children: .ignore) // Treat bubble as single elem
//                .accessibilityLabel(accessibilityLabelText)
//
//            // Push AI messages to the left
//            if !message.isUser { Spacer(minLength: 50) } // Ensure minimum spacing for AI
//        }
//        .animation(.easeOut(duration: 0.15), value: message.text) // Faster animation for streaming
//    }
//
//    // Helper for background color
//    @ViewBuilder
//    private func messageContentBackground() -> some View {
//        if message.isUser {
//            Color.blue.opacity(0.9) // User message background
//        } else if message.error != nil {
//            Color.red.opacity(0.3) // AI error background
//        } else {
//            Color(uiColor: .secondarySystemBackground) // Standard AI message background
//        }
//    }
//
//    // Helper for text color for contrast
//    private func messageForegroundColor() -> Color {
//        if message.isUser {
//            return .white // Text on blue background
//        } else if message.error != nil {
//            return .primary.opacity(0.8) // Text on red background
//        } else {
//            return .primary // Text on secondary system background
//        }
//    }
//}
//
//// View for the "..." typing indicator.
//struct TypingIndicatorBubble: View {
//    @State private var scale: CGFloat = 0.6 // Start smaller
//    private let animation = Animation.easeInOut(duration: 0.45).repeatForever(autoreverses: true)
//
//    var body: some View {
//         HStack(alignment: .center, spacing: 5) { // Center dots vertically
//            // AI Model Icon (Consistent with AI messages)
//            Image(systemName: "ellipsis") // Generic thinking icon
//                .font(.caption)
//                .foregroundColor(.secondary)
//                .frame(width: 15, height: 15)
//
//            // Animated dots
//            HStack(spacing: 4) {
//                 ForEach(0..<3) { i in
//                     Circle()
//                         .fill(Color.secondary) // Use secondary color for dots
//                         .frame(width: 7, height: 7) // Slightly smaller dots
//                         .scaleEffect(scale)
//                         .animation(animation.delay(Double(i) * 0.2), value: scale) // Slightly slower delay
//                }
//            }
//        }
//        .padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)) // Custom padding
//        .background(Color(uiColor: .secondarySystemBackground)) // Match AI bubble background
//        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//        .onAppear { scale = 1.0 } // Animate scale on appear
//        .frame(maxWidth: 100, alignment: .leading) // Fixed small width, aligned left
//        .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .bottomLeading))) // Transition effect
//        .accessibilityLabel("Assistant is typing")
//    }
//}
//
//// View for displaying error messages in a banner.
//struct ErrorDisplayView: View {
//    let errorMessage: String
//    let dismissAction: () -> Void
//
//    var body: some View {
//        HStack(alignment: .top) { // Align icon/text to top
//            Image(systemName: "exclamationmark.triangle.fill")
//                .foregroundColor(.red)
//                .padding(.top, 2) // Align icon slightly better
//
//            Text(errorMessage)
//                .font(.footnote) // Slightly smaller font
//                .lineLimit(3) // Allow more lines for longer errors
//                .foregroundColor(.red.opacity(0.9))
//                .frame(maxWidth: .infinity, alignment: .leading) // Take available space
//
//            Button {
//                withAnimation(.easeInOut(duration: 0.2)) { dismissAction() }
//            } label: {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.gray)
//            }
//            .padding(.leading, 4)
//        }
//        .padding(10)
//        .background(Color.red.opacity(0.1)) // Very faint red background
//        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
//        .padding(.horizontal) // Padding from screen edges
//        .padding(.bottom, 5) // Spacing from input bar
//        .transition(.move(edge: .bottom).combined(with: .opacity)) // Animate in/out from bottom
//    }
//}
//
//
//// MARK: - Preview
//
//#Preview {
//    // Wrap in NavigationView for better preview context if needed
//     EnhancedChatView()
//        .preferredColorScheme(.dark) // Preview in dark mode
//}
//
//// MARK: - CoreML Model Stub Class (Replace with generated code)
//// !! IMPORTANT !!
//// Replace this entire class with the Swift class generated by Xcode
//// when you compile your .mlmodel file. The names of the input/output
//// properties (`input_ids`, `position_ids`, `output_logits`) MUST match
//// the names defined in your CoreML model specification.
//
//class SimpleChatResponder { // Replace with your actual model class name
//    // Placeholder configuration initializer
//    init(configuration: MLModelConfiguration) throws {
//        print("⚠️ Initializing STUB 'SimpleChatResponder'. Replace with generated code.")
//        // Real generated code would load the actual model here.
//    }
//
//    // Placeholder prediction function signature
//    func prediction(input: SimpleChatResponderInput) throws -> SimpleChatResponderOutput {
//        print("⚠️ Performing STUB prediction in 'SimpleChatResponder'. Replace with generated code.")
//
//        // --- STUB Output ---
//        // Create a placeholder MLMultiArray for the output logits.
//        // The shape and dataType MUST match your model's actual output specification.
//        // Example shape: [BatchSize, SequenceLength, VocabularySize]
//        let outputShape: [NSNumber] = [1, 64, 1024] // Example shape only!
//        let outputLogits = try MLMultiArray(shape: outputShape, dataType: .float32)
//        // Fill with zeros or dummy data if needed for testing downstream stubs
//        for i in 0..<outputLogits.count { outputLogits[i] = 0.0 }
//
//        // Return the stub output object
//        return SimpleChatResponderOutput(output_logits: outputLogits) // Use correct output property name
//        // -------------------
//    }
//}
//
//// Placeholder Input Class (Replace with generated code)
//class SimpleChatResponderInput { // Replace with your actual model input class name
//    var input_ids: MLMultiArray // Property name MUST match model spec
//    var position_ids: MLMultiArray // Property name MUST match model spec
//
//    init(input_ids: MLMultiArray, position_ids: MLMultiArray) {
//         print("⚠️ Initializing STUB 'SimpleChatResponderInput'. Replace with generated code.")
//        self.input_ids = input_ids
//        self.position_ids = position_ids
//    }
//}
//
//// Placeholder Output Class (Replace with generated code)
//class SimpleChatResponderOutput { // Replace with your actual model output class name
//    var output_logits: MLMultiArray // Property name MUST match model spec
//
//    init(output_logits: MLMultiArray) {
//        print("⚠️ Initializing STUB 'SimpleChatResponderOutput'. Replace with generated code.")
//        self.output_logits = output_logits
//    }
//}
//
//// Helper extension for MLMultiArray dataType description (Optional)
//extension MLMultiArrayDataType: @retroactive CustomStringConvertible {
//    public var description: String {
//        switch self {
//        case .double: return "Double"
//        case .float32: return "Float32"
//        case .int32: return "Int32"
//        case .float16:
//            return "Float16"
//        @unknown default: return "Unknown"
//        }
//    }
//}
