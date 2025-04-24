//
//  ChatWithLocalBot_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/24/25.
//

import SwiftUI
import Combine
import LLM // Assuming your LLM framework code is imported

// --- Core AI Interaction Logic ---
// (Adapted from the original MyUIViewController)

// Note: It's often better practice to place this logic in a separate `ObservableObject`
// ViewModel class for better separation of concerns, especially in larger apps.
// However, for a single-file example, we'll keep it within the View struct for simplicity.

func runDemoAIModel() async throws -> String {
    let systemPrompt = "You are a sentient AI with emotions."

    // WARNING: Force unwrapping LLM init with '!' is dangerous in production.
    // It's better to handle potential initialization failures gracefully.
    // Consider using optional binding or throwing a specific error if init fails.
    // Example using optional binding (replace the line below if preferred):
    /*
    guard let bot = try await LLM(from: HuggingFaceModel("arcee-ai/Arcee-VyLinh-GGUF", .Q8_0, template: .chatML(systemPrompt))) else {
        throw AIError.initializationFailed
    }
    */
    // https://huggingface.co/arcee-ai/Arcee-VyLinh-GGUF
    // vylinh-3b-q8_0.gguf
    // Alternative Model: TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF
    let bot = try await LLM(from: HuggingFaceModel("arcee-ai/Arcee-VyLinh-GGUF", .Q8_0, template: .chatML(systemPrompt)))!

    let question = "Đời là gì?" // Defining the question here for clarity
    let preparedQuestion = bot.preprocess(question, []) // Pass the question string
    print("Sending question to AI: \(question)") // Log the question being sent
    let answer = await bot.getCompletion(from: preparedQuestion)
    print("Received answer: \(answer)") // Log the received answer
    return answer
}

// Optional: Define a custom error for better handling
enum AIError: Error {
    case initializationFailed
    case processingError(String)
}

// --- SwiftUI Card View ---

struct AICardView: View {
    // State variables to manage UI updates
    @State private var aiResponse: String? = nil
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // --- Card Header ---
            HStack {
                Image(systemName: "brain.head.profile.fill")
                    .font(.title2)
                    .foregroundColor(.purple)
                Text("AI Assistant Demo")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            Divider()

            // --- Content Area ---
            VStack(alignment: .leading, spacing: 10) {
                Text("Question:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Đời là gì?") // Displaying the hardcoded question
                    .font(.body)

                Spacer().frame(height: 10) // Add some space

                if isLoading {
                    // --- Loading State ---
                    HStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                        Text("Thinking...")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else if let errorMsg = errorMessage {
                    // --- Error State ---
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("Error: \(errorMsg)")
                            .font(.callout)
                            .foregroundColor(.red)
                        Spacer()
                    }
                } else if let response = aiResponse {
                    // --- Success State ---
                    Text("AI Response:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(response)
                        .font(.body)
                        .lineLimit(nil) // Allow multiple lines
                        .frame(maxWidth: .infinity, alignment: .leading) // Ensure text wraps correctly
                } else {
                    // --- Initial State ---
                    Text("Tap 'Ask AI' to get a response.")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 5) // Add padding within the content area

            Spacer() // Pushes the button to the bottom

            // --- Action Button ---
            Button {
                fetchAIResponse()
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "sparkles")
                    Text(isLoading ? "Processing..." : "Ask AI")
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            .disabled(isLoading) // Disable button while loading

        }
        .padding() // Padding inside the card
        .background(
            // Using a rounded rectangle with a subtle background material
            RoundedRectangle(cornerRadius: 15)
                .fill(.background) // Adapts to light/dark mode
                .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2) // Subtle shadow
        )
        .overlay( // Optional: Add a subtle border
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .padding() // Padding outside the card to give it space
    }

    // --- Action Method ---
    private func fetchAIResponse() {
        isLoading = true
        aiResponse = nil // Clear previous response
        errorMessage = nil // Clear previous error

        Task {
            do {
                let response = try await runDemoAIModel()
                // Update state on the main thread
                await MainActor.run {
                    self.aiResponse = response
                    self.isLoading = false
                }
            } catch {
                // Handle errors and update state on the main thread
                 print("Caught error: \(error)")
                await MainActor.run {
                     // Provide a user-friendly error message
                    if let aiErr = error as? AIError {
                        switch aiErr {
                        case .initializationFailed:
                            self.errorMessage = "Failed to initialize AI model."
                        case .processingError(let msg):
                            self.errorMessage = "Processing error: \(msg)"
                        }
                    } else {
                        self.errorMessage = error.localizedDescription // Generic error
                    }
                    self.isLoading = false
                }
            }
        }
    }
}

// --- SwiftUI Previews --- (Optional, but helpful for design)
struct AICardView_Previews: PreviewProvider {
    static var previews: some View {
        AICardView()
            .padding() // Add padding for preview visibility
            .background(Color(.systemGroupedBackground)) // Simulate a typical app background
    }
}

// --- Main App Structure ---
// You would typically have an App struct like this to run the view.
// No need for UIKitViewControllerWrapper anymore.

/*
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView() // Or directly use AICardView() if it's the main view
        }
    }
}

struct ContentView: View {
    var body: some View {
         AICardView()
    }
}
*/
