//
//  ChatWithLocalBot_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/24/25.
//

import SwiftUI
import Combine
import LLM // Assuming your LLM framework code is imported

// --- 1. Data Model (Optional but good practice) ---
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    enum Role { case user, ai }
    let role: Role
    let content: String
}

// --- 2. AI Service Layer ---
// Encapsulates the actual LLM interaction logic
class LLMService {
    private var llmInstance: LLM? // Store the initialized instance

    // More robust initialization
    func initializeModel() async throws {
        guard llmInstance == nil else { return } // Initialize only once

        let systemPrompt = "You are a helpful AI assistant." // More standard prompt
        let modelIdentifier = HuggingFaceModel("arcee-ai/Arcee-VyLinh-GGUF", .Q8_0, template: .chatML(systemPrompt))
        // Alternative Model: TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF
        // let modelIdentifier = HuggingFaceModel("TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF", .Q4_0, template: .chatML(systemPrompt))

        do {
            llmInstance = try await LLM(from: modelIdentifier)
            print("LLM Model Initialized Successfully.")
        } catch {
            print("Error initializing LLM Model: \(error)")
            llmInstance = nil // Ensure it's nil if init fails
            throw AIError.initializationFailed(error.localizedDescription)
        }
    }

    // Function to get a response for a given prompt
    func getResponse(for prompt: String) async throws -> String {
        guard let bot = llmInstance else {
            throw AIError.modelNotInitialized
        }

        print("Sending prompt to AI: \(prompt)")
        // Note: The original code passed `[]` for history. Real chat would pass previous messages.
        let preparedPrompt = bot.preprocess(prompt, [])
        
        do {
            let answer = await bot.getCompletion(from: preparedPrompt)
            print("Received answer: \(answer)")
            return answer
        } catch {
            print("Error getting completion: \(error)")
            throw AIError.processingError(error.localizedDescription)
        }
    }
}

// --- 3. Custom Errors ---
enum AIError: Error, LocalizedError {
    case initializationFailed(String)
    case modelNotInitialized
    case processingError(String)
    case inputError(String) // Added for validation

    var errorDescription: String? {
        switch self {
        case .initializationFailed(let details):
            return "AI Model failed to initialize: \(details)"
        case .modelNotInitialized:
            return "AI Model is not ready. Please try again shortly."
        case .processingError(let details):
            return "AI failed to process the request: \(details)"
        case .inputError(let details):
            return "Invalid input: \(details)"
        }
    }
}

// --- 4. ViewModel (MVVM Pattern) ---
@MainActor // Ensure updates happen on the main thread
class AICardViewModel: ObservableObject {
    // --- Published Properties for UI Binding ---
    @Published var userQuestion: String = ""
    @Published var lastMessages: (user: ChatMessage?, ai: ChatMessage?) = (nil, nil) // Store last interaction
    @Published var isLoading: Bool = false
    @Published var loadingStatus: String = "" // More specific loading text
    @Published var errorMessage: String? = nil
    @Published var canAskQuestion: Bool = false // Control button state based on model init

    // --- Dependencies ---
    private let llmService = LLMService()

    // --- Focus State Control ---
    @Published var isTextFieldFocused: Bool = false // To dismiss keyboard

    init() {
        // Initialize the model asynchronously when the ViewModel is created
        Task {
            await initializeModel()
        }
    }

    // --- Initialization ---
    private func initializeModel() async {
        isLoading = true
        loadingStatus = "Initializing AI Model..."
        errorMessage = nil
        canAskQuestion = false
        do {
            try await llmService.initializeModel()
            // Successfully initialized
            isLoading = false
            loadingStatus = ""
            errorMessage = nil
            canAskQuestion = true // Enable asking questions
        } catch {
            // Failed to initialize
             print("Initialization failed in ViewModel: \(error)")
            isLoading = false
            loadingStatus = ""
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Unknown initialization error."
             canAskQuestion = false
        }
    }

    // --- Actions ---
    func askAI() {
        guard canAskQuestion else {
            errorMessage = "AI Model is not ready. Please wait for initialization."
            return
        }
        guard !userQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = AIError.inputError("Question cannot be empty.").localizedDescription
            return
        }

        let currentQuestion = userQuestion // Capture the question
        lastMessages = (user: ChatMessage(role: .user, content: currentQuestion), ai: nil)
        isLoading = true
        loadingStatus = "AI is thinking..."
        errorMessage = nil
        isTextFieldFocused = false // Dismiss keyboard

        Task {
            do {
                let response = try await llmService.getResponse(for: currentQuestion)
                // Success - Update on Main Thread
                handleSuccess(question: currentQuestion, response: response)
            } catch {
                // Failure - Update on Main Thread
                 print("Error during 'askAI': \(error)")
                handleFailure(error: error)
            }
        }
        userQuestion = "" // Clear field immediately for better UX
    }

    private func handleSuccess(question: String, response: String) {
         // Already on MainActor due to class annotation
         lastMessages = (user: ChatMessage(role: .user, content: question),
                         ai: ChatMessage(role: .ai, content: response))
         isLoading = false
         loadingStatus = ""
         errorMessage = nil
     }

     private func handleFailure(error: Error) {
         // Already on MainActor
         // Keep the user's question visible in case of error
         // lastMessages.ai = nil // Ensure AI part is nil
         isLoading = false
         loadingStatus = ""
         errorMessage = (error as? LocalizedError)?.errorDescription ?? "An unknown error occurred."
     }

    func clearInput() {
        userQuestion = ""
        errorMessage = nil // Clear error when user starts typing again
    }
    
    func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
        // Optionally show transient feedback like "Copied!"
    }
}

// --- 5. SwiftUI View (Refactored) ---
struct AICardView: View {
    // Use @StateObject for the ViewModel's lifecycle
    @StateObject private var viewModel = AICardViewModel()
    // Focus state synchronization
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) { // Adjusted spacing
            // --- Card Header ---
            HeaderView()

            Divider()

            // --- Content Area ---
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    // --- User Input Section ---
                    InputFieldView(userQuestion: $viewModel.userQuestion,
                                   isTextFieldFocused: $isTextFieldFocused,
                                   clearAction: viewModel.clearInput,
                                   submitAction: viewModel.askAI)
                                   .disabled(viewModel.isLoading || !viewModel.canAskQuestion) // Disable while busy or not ready
                     
                    // --- Conversation Display ---
                     ConversationView(messages: viewModel.lastMessages,
                                      copyAction: viewModel.copyToClipboard)

                    // --- Loading/Error Display ---
                     StatusDisplayView(isLoading: viewModel.isLoading,
                                       loadingStatus: viewModel.loadingStatus,
                                       errorMessage: viewModel.errorMessage)
                }
                .padding(.vertical, 5)
            }
            // Ensure ScrollView doesn't take infinite height
            .frame(maxHeight: .infinity, alignment: .top)

             Spacer() // Pushes the button to the bottom if content is short

             // --- Action Button ---
             SubmitButtonView(isLoading: viewModel.isLoading || !viewModel.canAskQuestion, // Reflect model readiness
                                   canAskQuestion: viewModel.canAskQuestion,
                                   action: viewModel.askAI)
                  .disabled(viewModel.userQuestion.isEmpty || viewModel.isLoading || !viewModel.canAskQuestion)

        }
        .padding()
        .background(CardBackground())
        .onChange(of: viewModel.isTextFieldFocused) {
             // Sync ViewModel's state with View's FocusState
             isTextFieldFocused = viewModel.isTextFieldFocused
         }
         .onChange(of: isTextFieldFocused) {
             // Sync View's FocusState with ViewModel (if needed, mostly View -> VM)
             if isTextFieldFocused {
                 viewModel.errorMessage = nil // Clear error when user starts typing
             }
         }
//         .animation(.easeInOut, value: viewModel.isLoading) // Animate loading changes
//         .animation(.easeInOut, value: viewModel.errorMessage) // Animate error appearance
//         .animation(.easeInOut, value: viewModel.lastMessages) // Animates message appearance
    }
}

// --- 6. Subviews for Readability ---

struct HeaderView: View {
     var body: some View {
         HStack {
             Image(systemName: "brain.head.profile.fill")
                 .font(.title2)
                 .foregroundColor(.purple)
             Text("AI Assistant Chat")
                 .font(.headline)
                 .fontWeight(.semibold)
             Spacer()
             // Could add a 'clear chat' or 'settings' button here later
         }
     }
 }

struct InputFieldView: View {
    @Binding var userQuestion: String
    var isTextFieldFocused: FocusState<Bool>.Binding // Use FocusState Binding
    let clearAction: () -> Void
    let submitAction: () -> Void

    var body: some View {
        HStack {
            TextField("Ask the AI anything...", text: $userQuestion, axis: .vertical) // Allow vertical expansion
                .textFieldStyle(.plain)
                .focused(isTextFieldFocused) // Bind focus state
                .lineLimit(1...5) // Limit lines for TextField
                .onSubmit(submitAction) // Allow submission via return key
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                 .background(
                     RoundedRectangle(cornerRadius: 8)
                         .fill(Color(.secondarySystemBackground)) // Subtle background
                 )

            // Clear Button
            if !userQuestion.isEmpty {
                Button {
                    clearAction()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .padding(.leading, -30) // Position inside the text field
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: userQuestion.isEmpty)
    }
}

struct ConversationView: View {
    let messages: (user: ChatMessage?, ai: ChatMessage?)
    let copyAction: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
           if let userMsg = messages.user {
               MessageBubble(message: userMsg)
           }
            if let aiMsg = messages.ai {
                MessageBubble(message: aiMsg, copyAction: copyAction)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    var copyAction: ((String) -> Void)? = nil // Action for AI messages

    var alignment: HorizontalAlignment {
        message.role == .user ? .trailing : .leading
    }

    var backgroundColor: Color {
        message.role == .user ? .blue.opacity(0.8) : Color(.systemGray4)
    }

     var foregroundColor: Color {
         message.role == .user ? .white : .primary
     }

    var body: some View {
        HStack {
            if message.role == .ai { Spacer(minLength: 40) } // Push user bubble right

            VStack(alignment: .leading, spacing: 4) {
                 Text(message.content)
                     .textSelection(.enabled) // Allow text selection
                      .padding(.horizontal, 12)
                      .padding(.vertical, 8)
                      .background(backgroundColor)
                      .foregroundColor(foregroundColor)
                      .cornerRadius(15)
                      .lineLimit(nil) // Ensure text wraps
                      .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .trailing) // Correct alignment inside HStack

                 // Add copy button only for AI messages
                 if message.role == .ai, let action = copyAction {
                     Button {
                         action(message.content)
                     } label: {
                         HStack(spacing: 4) {
                             Image(systemName: "doc.on.doc")
                             Text("Copy")
                         }
                         .font(.caption)
                         .foregroundColor(.secondary)
                     }
                      .buttonStyle(.plain) // Remove default button styling
                      .frame(maxWidth: .infinity, alignment: .trailing) // Align button right
                      .padding(.trailing, 5)
                 }
             }
//             .frame(maxWidth: .infinity, alignment: alignment) // Align bubble

             if message.role == .user { Spacer(minLength: 40) } // Push AI bubble left
        }
    }
}

struct StatusDisplayView: View {
    let isLoading: Bool
    let loadingStatus: String
    let errorMessage: String?

    var body: some View {
        if isLoading {
             HStack {
                 ProgressView()
                     .progressViewStyle(.circular)
                     .scaleEffect(0.8) // Make spinner slightly smaller
                 Text(loadingStatus)
                     .font(.callout)
                     .foregroundColor(.secondary)
                 Spacer()
             }
             .transition(.opacity.combined(with: .scale(scale: 0.9)))
         } else if let errorMsg = errorMessage {
             HStack {
                 Image(systemName: "exclamationmark.triangle.fill")
                     .foregroundColor(.red)
                 Text(errorMsg)
                     .font(.callout)
                     .foregroundColor(.red)
                     .lineLimit(nil)
                 Spacer()
             }
             .padding(.vertical, 5)
             .transition(.opacity)
        }
    }
}

struct SubmitButtonView: View {
    let isLoading: Bool
    let canAskQuestion: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                if !isLoading {
                    Image(systemName: "sparkles")
                     Text(canAskQuestion ? "Ask AI" : "Initializing...")
                } else {
                    ProgressView() // Show spinner inside button when loading
                        .tint(.white) // Make spinner visible on colored background
                        .padding(.horizontal, 5)
                    Text("Processing...")
                }
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
        .tint(.purple)
        // .disabled is handled outside in the main view based on more conditions
    }
}

struct CardBackground: View {
     var body: some View {
         RoundedRectangle(cornerRadius: 15)
             .fill(.background) // Adapts to light/dark mode Material effect
             .shadow(color: .gray.opacity(0.3), radius: 6, x: 0, y: 3)
             .overlay(
                 RoundedRectangle(cornerRadius: 15)
                     .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
             )
     }
 }

// --- SwiftUI Previews ---
struct AICardView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with initial state
        AICardView()
            .previewDisplayName("Initial State")
            .padding()
            .background(Color(.systemGroupedBackground))

        // Preview with loading state
        AICardView_PreviewWrapper(configure: { vm in
            vm.isLoading = true
            vm.loadingStatus = "AI is thinking..."
            vm.lastMessages = (user: .init(role: .user, content: "What is SwiftUI?"), ai: nil)
            vm.canAskQuestion = false // Typically can't ask while it's thinking
        })
        .previewDisplayName("Loading State")

        // Preview with response state
        AICardView_PreviewWrapper(configure: { vm in
             vm.lastMessages = (user: .init(role: .user, content: "Explain MVVM."),
                                 ai: .init(role: .ai, content: "MVVM stands for Model-View-ViewModel. It's an architectural pattern..."))
             vm.canAskQuestion = true
        })
        .previewDisplayName("Response State")
        
        // Preview with error state
        AICardView_PreviewWrapper(configure: { vm in
            vm.errorMessage = AIError.processingError("Network connection lost.").localizedDescription
            vm.lastMessages = (user: .init(role: .user, content: "Why did it fail?"), ai: nil)
            vm.canAskQuestion = true // Can still try again
        })
        .previewDisplayName("Error State")

         // Preview model initialization state
         AICardView_PreviewWrapper(configure: { vm in
             vm.isLoading = true
             vm.loadingStatus = "Initializing AI Model..."
             vm.canAskQuestion = false
         })
         .previewDisplayName("Initializing State")

         // Preview model initialization failed state
         AICardView_PreviewWrapper(configure: { vm in
             vm.isLoading = false
             vm.errorMessage = AIError.initializationFailed("Could not download model files.").localizedDescription
             vm.canAskQuestion = false
         })
         .previewDisplayName("Init Failed State")

    }
}

// Helper for Previews with specific ViewModel states
struct AICardView_PreviewWrapper: View {
    @StateObject var viewModel = AICardViewModel()
    let configure: (AICardViewModel) -> Void

    init(configure: @escaping (AICardViewModel) -> Void) {
        self.configure = configure
    }
    
//    var body: some View {
//        AICardView()
//    }

    var body: some View {
        AICardView()
            .padding()
            .background(Color(.systemGroupedBackground))
            .onAppear {
                // Stop the actual initializationChatWithLocalBot_V3 for previews with specific states
                 viewModel.isLoading = false // Override if needed after config
                configure(viewModel)
            }
    }
}
