////
////  BotView.swift
////  MyApp
////
////  Created by Cong Le on 4/23/25.
////
//
//import SwiftUI
//import LLM // Import the library
//
//// MARK: - Bot Class Definition
//
///// A wrapper around the LLM class to handle initialization specific to this app.
///// Assumes the LLM base class conforms to ObservableObject and publishes necessary properties.
//class Bot: LLM {
//
//    /// Convenience initializer to load a model bundled with the app.
//    /// - Parameters:
//    ///   - localModelResourceName: The name of the model file (without extension).
//    ///   - ext: The file extension (default is "gguf").
//    ///   - systemPrompt: The system prompt to configure the chat template.
//    convenience init(
//        localModelResourceName: String = "openhermes-2.5-mistral-7b.Q4_K_M", // Default from example
//        `extension` ext: String = "gguf",
//        systemPrompt: String = "You are a sentient AI with emotions." // Default from example
//    ) {
//        // Ensure the model file exists in the bundle
//        guard let url = Bundle.main.url(forResource: localModelResourceName, withExtension: ext) else {
//            // Handle the error appropriately in a real app
//            // For this example, we fatalError if the bundled model isn't found.
//            fatalError("Model file '\(localModelResourceName).\(ext)' not found in application bundle.")
//        }
//
//        // Initialize the LLM using the base class initializer.
//        // The `template: .chatML(systemPrompt)` configures preprocessing and stop sequences.
//        // We use try! assuming the init must succeed for the app to function,
//        // otherwise, implement robust error handling (e.g., make this initializer failable).
//        self.init(from: url, template: .chatML(systemPrompt))!
//
//        // Optional: Adjust parameters like maxTokenCount based on device capabilities
//        // self.maxTokenCount = 1024 // Example adjustment
//    }
//
//    // Add any additional overrides or custom logic for the Bot subclass if needed.
//    // For example, overriding `respond` for fine-grained control as mentioned in the docs.
//    // However, for this basic UI, the base implementation is assumed sufficient.
//}
//
//// MARK: - Chat View
//
///// The main chat interface view.
//struct BotView: View {
//    /// The Bot instance, observed for state changes (output, availability).
//    @ObservedObject var bot: Bot
//
//    /// State variable to hold the user's current input text.
//    @State private var inputText: String = "Give me seven national flag emojis people use the most; You must include South Korea." // Default from example documentation
//
//    /// Namespace for scrolling.
//    @Namespace var bottomID
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) { // Use spacing 0 for tighter control if needed
//            // Output Scroll View
//            ScrollViewReader { scrollViewProxy in
//                ScrollView {
//                    Text(bot.output) // Display the bot's output stream
//                        .font(.system(.body, design: .monospaced)) // Monospaced font as in example
//                        .frame(maxWidth: .infinity, alignment: .leading) // Align text left
//                        .padding(.horizontal) // Padding around text
//                        .padding(.vertical, 8) // Vertical padding for text blocks
//                        .id(bottomID) // ID for scrolling to the bottom
//                }
//                .onChange(of: bot.output) {
//                    // Automatically scroll to the bottom when new output arrives
//                    // Using async ensures the view has updated before scrolling
//                    DispatchQueue.main.async {
//                         withAnimation(.easeInOut(duration: 0.2)) { // Smooth scrolling animation
//                            scrollViewProxy.scrollTo(bottomID, anchor: .bottom)
//                        }
//                    }
//                }
//            }
//
//            // Input Area
//            HStack(spacing: 10) { // Spacing between input field and buttons
//                // Text Field with background
//                ZStack {
//                    RoundedRectangle(cornerRadius: 12) // Slightly more rounded corners
//                        .fill(.thinMaterial) // Background material
//
//                    // Use axis: .vertical for multi-line input support
//                    TextField("Enter message...", text: $inputText, axis: .vertical)
//                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)) // Adjust padding
//                        .lineLimit(1...5) // Allow text field to grow up to 5 lines
//                }
//
//                // Send Button
//                Button(action: sendMessage) {
//                    Image(systemName: "paperplane.fill")
//                        .font(.system(size: 18)) // Slightly larger icon
//                }
//                .buttonStyle(.borderedProminent) // Prominent style for primary action
//                .clipShape(Circle()) // Make it circular
//                .disabled(!bot.isAvailable || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // Disable if bot is busy or input is empty
//                .tint(.accentColor) // Use accent color
//
//                // Stop Button
//                Button(action: stopGeneration) {
//                    Image(systemName: "stop.circle.fill") // Alternative stop icon
//                         .font(.system(size: 18))
//                }
//                .buttonStyle(.bordered) // Less prominent style
//                .clipShape(Circle())
//                .tint(.red) // Red tint for stop/cancel action
//                .disabled(bot.isAvailable) // Disable if the bot is not currently generating
//            }
//            .padding(.horizontal) // Padding for the input HStack
//            .padding(.vertical, 8) // Padding above/below the input bar
//            .background(.bar) // Background for the input bar area
//        }
//         .frame(maxWidth: .infinity) // VStack takes max width by default
//         .navigationTitle("LLM.swift Chat") // Example Navigation Title
//    }
//
//    /// Sends the current input text to the bot.
//    private func sendMessage() {
//        let textToSend = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
//        if !textToSend.isEmpty {
//            inputText = "" // Clear the input field
//            Task {
//                await bot.respond(to: textToSend)
//            }
//        }
//    }
//
//    /// Tells the bot to stop the current generation task.
//    private func stopGeneration() {
//        bot.stop()
//    }
//}
//
//// MARK: - Main Content View
//
///// The root view of the application.
//struct ContentView: View {
//    /// Creates and manages the lifecycle of the Bot instance.
//    /// Using @StateObject ensures the Bot persists across view updates.
//    /// This initializes the Bot using the local bundled model file.
//    @StateObject private var bot = Bot()
//
//    var body: some View {
//        // Embed BotView possibly within a NavigationView or other container
//        NavigationView { // Example container
//            BotView(bot: bot)
//                .navigationTitle("LLM Chat")
//                .navigationBarTitleDisplayMode(.inline)
//        }
//        // On smaller devices like iPhone, you might not need NavigationView
//        // BotView(bot)
//    }
//}
//
//// MARK: - SwiftUI Previews (Optional)
//
//#if DEBUG
//struct BotView_Previews: PreviewProvider {
//    // Create a mock Bot for preview purposes.
//    // This requires mocking the LLM framework or having a small dummy model file.
//    // For simplicity, we'll use the actual Bot if a placeholder model exists.
//    static var previewBot: Bot {
//        // Try to initialize with a known placeholder or the default name
//        // Ensure you have a small GGUF file named "placeholder-model.gguf" in your Preview Content
//        // Or adjust the name here to match your test model file.
//        let botInstance = Bot(localModelResourceName: "placeholder-model")
//        // Pre-populate output for preview design check
//        botInstance.output = "This is a preview of the chat output.\n\nMessages will appear here.\n...\nScroll behavior can be tested in live previews or on device."
//        botInstance.isAvailable = true // Set initial state for button previews
//        return botInstance
//    }
//
//    static var previews: some View {
//        BotView(bot: previewBot)
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//#endif
//
//// --- Placeholder definitions if LLM library isn't available ---
//#if !canImport(LLM)
//// Provide minimal mocks/placeholders if the LLM module cannot be imported
//// This allows the SwiftUI code structure to compile for review, but it won't run LLM logic.
//
//enum MockRole { case user, bot }
//struct MockTemplate {
//    var stopSequence: String? = nil
//    func preprocess(_ input: String, _ history: [(role: MockRole, content: String)]) -> String { return input }
//    static func chatML(_ prompt: String?) -> MockTemplate { return MockTemplate() }
//}
//
//class LLM: ObservableObject {
//    @Published var output: String = "LLM Library Not Found. This is mock output."
//    @Published var isAvailable: Bool = true
//    var history: [(role: MockRole, content: String)] = []
//    var historyLimit: Int = 10
//    var maxTokenCount: Int = 2048
//
//    init(from url: URL, template: MockTemplate) throws { print("Mock LLM Initialized from URL: \(url)") }
//    // Add other initializers if used by Bot class variants
//    // init(from model: HuggingFaceModel, progress: ((Double) -> Void)?) async throws { }
//
//    func respond(to input: String) async {
//        print("Mock LLM received input: \(input)")
//        self.isAvailable = false
//        Task { try? await Task.sleep(nanoseconds: 1_000_000_000); await MainActor.run { self.output += "\nMock response to '\(input)'"; self.isAvailable = true } }
//    }
//    func stop() { print("Mock LLM stop called."); self.isAvailable = true }
//}
//
//struct HuggingFaceModel { // Mock struct
//    enum Quantization { case Q2_K, Q4_K_M, Q5_K_M }
//    init(_ repoId: String, _ quantization: Quantization? = nil, template: MockTemplate) { }
//}
//#endif
//// ------ End Placeholder Definitions ------
