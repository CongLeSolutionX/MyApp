////
////  BotView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/23/25.
////
//
//import SwiftUI
//import Foundation
//import Combine // For ObservableObject
//
//// Attempt to import the real library
//#if canImport(LLM)
//import LLM
//#endif
//
//// MARK: - Protocol Definition
//// Defines the interface required by the UI (BotView)
//
//protocol ChatBot: ObservableObject {
//    // Use LLM.Role if the library defines it and is imported, otherwise use a placeholder type
//#if canImport(LLM)
//    typealias ChatRole = Role
//#else
//    enum ChatRole { case user, bot, system } // Placeholder role
//#endif
//    
//    var output: String { get }
//    var isAvailable: Bool { get }
//    var history: [(role: ChatRole, content: String)] { get set }
//    
//    func respond(to input: String) async
//    func stop()
//}
//
//// MARK: - Error Handling
//
//enum ModelLoadingError: LocalizedError {
//    case directoryCreationFailed(Error)
//    case downloadError(Error)
//    case fileMoveError(Error)
//    case invalidURL
//    case filenameGenerationFailed
//    case initializationFailed(Error?) // Can wrap underlying LLM init errors
//    
//    var errorDescription: String? {
//        switch self {
//        case .directoryCreationFailed(let error):
//            return "Failed to create model storage directory: \(error.localizedDescription)"
//        case .downloadError(let error):
//            return "Failed to download model: \(error.localizedDescription)"
//        case .fileMoveError(let error):
//            return "Failed to save model file: \(error.localizedDescription)"
//        case .invalidURL:
//            return "Could not construct a valid URL for downloading."
//        case .filenameGenerationFailed:
//            return "Could not determine a valid filename for the model."
//        case .initializationFailed(let error):
//            return "Failed to initialize LLM engine: \(error?.localizedDescription ?? "Unknown reason")"
//        }
//    }
//}
//
//// MARK: - HuggingFaceModel Helpers (Add/Adapt based on LLM library)
//
//// Use real types if available, otherwise use placeholders
//#if canImport(LLM)
//typealias HFQuantization = Quantization
//typealias LlmTemplate = Template
//#else
//// Placeholders if LLM library not imported
//enum HFQuantization: String, CaseIterable {
//    case Q2_K = "Q2_K", Q3_K_S = "Q3_K_S", Q3_K_M = "Q3_K_M", Q3_K_L = "Q3_K_L"
//    case Q4_0 = "Q4_0", Q4_1 = "Q4_1", Q4_K_S = "Q4_K_S", Q4_K_M = "Q4_K_M"
//    case Q5_0 = "Q5_0", Q5_1 = "Q5_1", Q5_K_S = "Q5_K_S", Q5_K_M = "Q5_K_M"
//    case Q6_K = "Q6_K"
//    case Q8_0 = "Q8_0"
//    case F16 = "F16" // Common notation for float16
//    case Unknown = "Unknown" // Add a fallback if needed
//}
//
//struct LlmTemplate {
//    static func chatML(_ prompt: String?) -> LlmTemplate { return LlmTemplate() }
//    // Add other templates if needed by Bot init
//}
//#endif
//
//struct HuggingFaceModelHelper {
//    /// Constructs the filename based on repo ID and quantization.
//    static func filename(from repoId: String, quantization: HFQuantization) -> String? {
//        guard let modelName = repoId.split(separator: "/").last else { return nil }
//        // Use the rawValue of the enum case if it's a String enum
//        return "\(modelName).\(quantization.rawValue).gguf"
//    }
//    
//    /// Constructs the download URL for a specific model file.
//    static func constructDownloadURL(repoId: String, quantization: HFQuantization) -> URL? {
//        guard let filename = self.filename(from: repoId, quantization: quantization) else {
//            return nil
//        }
//        return URL(string: "https://huggingface.co/\(repoId)/resolve/main/\(filename)")
//    }
//}
//
//// MARK: - URLSession Downloader Helper
//
//class ModelDownloader: NSObject, URLSessionDownloadDelegate {
//    private var progressUpdate: (Double) -> Void
//    private var downloadContinuation: CheckedContinuation<URL, Error>?
//    private var observation: NSKeyValueObservation?
//    
//    init(progressUpdate: @escaping (Double) -> Void) {
//        self.progressUpdate = progressUpdate
//    }
//    
//    func download(from url: URL) async throws -> URL {
//        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue()) // Use dedicated queue for delegate methods
//        
//        return try await withCheckedThrowingContinuation { continuation in
//            self.downloadContinuation = continuation
//            let downloadTask = session.downloadTask(with: url)
//            
//            // Observe progress using KVO
//            self.observation = downloadTask.progress.observe(\.fractionCompleted, options: [.new]) { progress, change in
//                if let fractionCompleted = change.newValue {
//                    DispatchQueue.main.async {
//                        self.progressUpdate(fractionCompleted)
//                    }
//                }
//            }
//            
//            if self.observation == nil {
//                print("Warning: Could not observe download progress.")
//                // Optionally report 0 progress initially if observer fails
//                DispatchQueue.main.async { self.progressUpdate(0.0) }
//            }
//            
//            downloadTask.resume()
//        }
//    }
//    
//    // MARK: Delegate Methods
//    
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        // Successfully downloaded to temporary location
//        observation?.invalidate()
//        observation = nil
//        downloadContinuation?.resume(returning: location)
//        downloadContinuation = nil
//    }
//    
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        observation?.invalidate()
//        observation = nil
//        if let error = error {
//            // Resume continuation with error if it hasn't been resumed already (by success)
//            downloadContinuation?.resume(throwing: error)
//            downloadContinuation = nil
//        } else if downloadContinuation != nil {
//            // Should not happen if didFinishDownloadingTo was called, but handle as potential error
//            let unknownError = NSError(domain: "ModelDownloader", code: -2, userInfo: [NSLocalizedDescriptionKey: "Task completed without error but didFinishDownloadingTo was not called."])
//            downloadContinuation?.resume(throwing: unknownError)
//            downloadContinuation = nil
//        }
//    }
//}
//
//// MARK: - Real Bot Implementation
//
//// Check if we can import and use the real LLM class
//#if canImport(LLM)
//class Bot: LLM, ChatBot { // Inherit from LLM, Conform to ChatBot
//    
//    // Ensure designated initializer is callable (may require overriding if LLM changes it)
//    // Assuming LLM's designated init is `init(from: URL, template: Template)`
//    override init(from url: URL, template: LlmTemplate) throws {
//        try super.init(from: url, template: template)
//    }
//    
//    // Async convenience initializer with download logic
//    convenience init(
//        repoId: String,
//        quantization: HFQuantization,
//        template: LlmTemplate,
//        progressUpdate: @escaping (Double) -> Void
//    ) async throws {
//        
//        guard let localModelURL = try Self.getLocalModelURL(repoId: repoId, quantization: quantization) else {
//            throw ModelLoadingError.filenameGenerationFailed
//        }
//        let fileManager = FileManager.default
//        
//        if fileManager.fileExists(atPath: localModelURL.path) {
//            print("Model found locally: \(localModelURL.path)")
//            progressUpdate(1.0) // Indicate complete loading
//            try self.init(from: localModelURL, template: template) // Call designated init
//            print("LLM initialized successfully from local file.")
//            return
//        }
//        
//        print("Model not found locally. Starting download...")
//        progressUpdate(0.0)
//        
//        do {
//            try Self.ensureModelDirectoryExists()
//        } catch {
//            throw ModelLoadingError.directoryCreationFailed(error)
//        }
//        
//        guard let downloadURL = HuggingFaceModelHelper.constructDownloadURL(repoId: repoId, quantization: quantization) else {
//            print("Could not construct valid download URL.")
//            throw ModelLoadingError.invalidURL
//        }
//        
//        let downloader = ModelDownloader(progressUpdate: progressUpdate)
//        let temporaryURL: URL
//        do {
//            temporaryURL = try await downloader.download(from: downloadURL)
//            print("Download complete. Temp file: \(temporaryURL.path)")
//        } catch {
//            print("Download failed: \(error)")
//            throw ModelLoadingError.downloadError(error)
//        }
//        
//        do {
//            if fileManager.fileExists(atPath: localModelURL.path) {
//                try fileManager.removeItem(at: localModelURL)
//            }
//            try fileManager.moveItem(at: temporaryURL, to: localModelURL)
//            print("Model successfully saved to: \(localModelURL.path)")
//        } catch {
//            print("Failed to move downloaded file: \(error)")
//            try? fileManager.removeItem(at: temporaryURL) // Clean up tmp file
//            throw ModelLoadingError.fileMoveError(error)
//        }
//        
//        // Initialize LLM after successful download
//        do {
//            try self.init(from: localModelURL, template: template) // Call designated init
//            print("LLM initialized successfully after download.")
//        } catch {
//            print("LLM initialization failed after download: \(error)")
//            // Optionally remove the downloaded file if init fails?
//            // try? fileManager.removeItem(at: localModelURL)
//            throw ModelLoadingError.initializationFailed(error)
//        }
//    }
//    
//    // --- File Management Helpers ---
//    private static func getModelsDirectoryURL() throws -> URL {
//        return try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//            .appendingPathComponent("LLM_Models", isDirectory: true)
//    }
//    
//    private static func ensureModelDirectoryExists() throws {
//        let modelsDirURL = try getModelsDirectoryURL()
//        if !FileManager.default.fileExists(atPath: modelsDirURL.path) {
//            try FileManager.default.createDirectory(at: modelsDirURL, withIntermediateDirectories: true, attributes: nil)
//            print("Created models directory at: \(modelsDirURL.path)")
//        }
//    }
//    
//    private static func getLocalModelURL(repoId: String, quantization: HFQuantization) throws -> URL? {
//        guard let filename = HuggingFaceModelHelper.filename(from: repoId, quantization: quantization) else {
//            return nil
//        }
//        let modelsDirURL = try getModelsDirectoryURL()
//        return modelsDirURL.appendingPathComponent(filename)
//    }
//}
//
//// Use the real Bot if LLM library is available
//typealias RuntimeBotType = Bot
//
//#else
//// MARK: - Placeholder Bot Implementation (if LLM not available)
//
//// Use a placeholder if LLM library is not available
//class PlaceholderBot: ObservableObject, ChatBot {
//    @Published var output: String = "LLM library not found. This is placeholder output."
//    @Published var isAvailable: Bool = true
//    @Published var history: [(role: ChatRole, content: String)] = []
//    
//    init() {
//        history.append((role: .bot, content: "Placeholder Bot Initialized."))
//    }
//    
//    // Mock the async initializer signature (won't actually download)
//    convenience init(
//        repoId: String,
//        quantization: HFQuantization,
//        template: LlmTemplate,
//        progressUpdate: @escaping (Double) -> Void
//    ) async throws {
//        self.init() // Call the designated initializer
//        print("PlaceholderBot initializer called (no download)")
//        // Simulate completion
//        progressUpdate(1.0)
//        try? await Task.sleep(nanoseconds: 100_000_000) // Small delay
//    }
//    
//    func respond(to input: String) async {
//        print("PlaceholderBot responding to: \(input)")
//        await MainActor.run { isAvailable = false }
//        try? await Task.sleep(nanoseconds: 500_000_000)
//        let response = "Placeholder response to '\(input)'."
//        await MainActor.run {
//            history.append((role: .user, content: input))
//            history.append((role: .bot, content: response))
//            output += "\nUser: \(input)\nBot: \(response)"
//            isAvailable = true
//        }
//    }
//    
//    func stop() {
//        print("PlaceholderBot stop called.")
//        Task { @MainActor in self.isAvailable = true }
//    }
//}
//
//// Use the PlaceholderBot if LLM library is not available
//typealias RuntimeBotType = PlaceholderBot
//
//#endif
//
//// MARK: - Chat UI View (BotView)
//
//// Generic BotView works with any ChatBot conforming object
//struct BotView<T: ChatBot>: View {
//    @ObservedObject var bot: T
//    @State private var inputText: String = "Give me seven national flag emojis people use the most; You must include South Korea."
//    @Namespace var bottomID
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            ScrollViewReader { scrollViewProxy in
//                ScrollView {
//                    Text(bot.output)
//                        .font(.system(.body, design: .monospaced))
//                        .textSelection(.enabled)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.horizontal)
//                        .padding(.top, 8) // Add padding top
//                        .padding(.bottom, 8)
//                        .id(bottomID) // ID for scrolling
//                }
//                .onChange(of: bot.output) {
//                    // Use DispatchQueue to ensure scrolling happens after the view update
//                    DispatchQueue.main.async {
//                        withAnimation(.smooth(duration: 0.3)) { // Smoother animation
//                            scrollViewProxy.scrollTo(bottomID, anchor: .bottom)
//                        }
//                    }
//                }
//                // Scroll to bottom initially if needed
//                .onAppear {
//                    DispatchQueue.main.async {
//                        scrollViewProxy.scrollTo(bottomID, anchor: .bottom)
//                    }
//                }
//            }
//            
//            // Input Area
//            HStack(spacing: 10) {
//                TextField("Enter message...", text: $inputText, axis: .vertical)
//                    .padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)) // Adjusted padding
//                    .lineLimit(1...5)
//                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16) ) // Use background modifier
//                    .overlay( // Add subtle border
//                        RoundedRectangle(cornerRadius: 16)
//                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//                    )
//                
//                Button(action: sendMessage) {
//                    Image(systemName: "arrow.up.circle.fill") // Changed icon
//                        .font(.system(size: 24)) // Slightly larger icon
//                }
//                .buttonStyle(.plain) // Remove default button background/border
//                .clipShape(Circle())
//                .disabled(!bot.isAvailable || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
//                .tint(.accentColor) // Use accent color for tint
//                
//                Button(action: stopGeneration) {
//                    Image(systemName: "stop.circle.fill")
//                        .font(.system(size: 24))
//                }
//                .buttonStyle(.plain)
//                .clipShape(Circle())
//                .tint(.red)
//                .disabled(bot.isAvailable)
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 8)
//            .background(.bar) // Use system bar background
//        }
//    }
//    
//    private func sendMessage() {
//        let textToSend = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
//        if !textToSend.isEmpty {
//            inputText = ""
//            Task { await bot.respond(to: textToSend) }
//        }
//    }
//    
//    private func stopGeneration() {
//        bot.stop()
//    }
//}
//
//// MARK: - Main Content View
//
//struct ContentView: View {
//    // Use the protocol type in the LoadingState
//    enum LoadingState {
//        case idle
//        case downloading(progress: Double)
//        case loaded(any ChatBot) // Holds any object conforming to ChatBot
//        case failed(Error)
//    }
//    
//    @State private var loadingState: LoadingState
//    @State private var loadingTask: Task<Void, Never>? = nil
//    
//    // --- Model Configuration ---
//    let modelRepoId = "TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF"
//    let modelQuantization = HFQuantization.Q2_K // Use type defined above
//    let modelTemplate = LlmTemplate.chatML("You are a helpful AI assistant.") // Use type defined above
//    // --------------------------
//    
//    // Initializer for general use
//    init() {
//        _loadingState = State(initialValue: .idle)
//    }
//    
//    // Initializer for previews
//    init(initialLoadingState: LoadingState) {
//        _loadingState = State(initialValue: initialLoadingState)
//    }
//    
//    var body: some View {
//        NavigationView {
//            Group { // Group allows easy switching of content
//                switch loadingState {
//                case .idle:
//                    VStack(spacing: 20) {
//                        Image(systemName: "brain.head.profile") // Icon suggestion
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 80, height: 80)
//                            .foregroundColor(.secondary)
//                        Text("LLM Chat Bot")
//                            .font(.title2)
//                        Text("Tap below to load the AI model.")
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                        Button {
//                            startLoadingModel()
//                        } label: {
//                            Label("Load Model", systemImage: "arrow.down.circle.fill")
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .controlSize(.large) // Make button larger
//                    }
//                    .padding()
//                    
//                case .downloading(let progress):
//                    VStack(spacing: 15) { // Add spacing
//                        ProgressView(value: progress) {
//                            Text("Loading Model...")
//                                .font(.headline)
//                        } currentValueLabel: {
//                            Text(String(format: "%.1f%%", progress * 100))
//                                .font(.caption.monospacedDigit()) // Monospaced digits for stability
//                        }
//                        .progressViewStyle(.circular)
//                        .padding(.bottom, 5) // Space below progress view
//                        
//                        Text("Downloading required files...")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    }
//                    .padding(40) // Add more padding around the progress view
//                    
//                case .loaded(let bot):
//                    // RuntimeBotType is either Bot or PlaceholderBot
//                    // Since BotView is generic, we pass the concrete type Swift knows 'bot' holds
//                    // Note: Direct use of 'any ChatBot' with @ObservedObject is problematic.
//                    // This approach relies on Swift inferring the concrete type being passed.
//                    if let concreteBot = bot as? RuntimeBotType {
//                        BotView(bot: concreteBot)
//                    } else {
//                        // Fallback/Error handling if type casting fails (shouldn't normally happen here)
//                        Text("Error: Could not display chat view for the loaded bot type.")
//                    }
//                    
//                case .failed(let error):
//                    VStack(spacing: 15) {
//                        Image(systemName: "exclamationmark.octagon.fill") // Different error icon
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 50, height: 50)
//                            .foregroundColor(.red)
//                        Text("Failed to Load Model")
//                            .font(.headline)
//                        Text(error.localizedDescription)
//                            .font(.footnote) // Smaller font for error details
//                            .multilineTextAlignment(.center)
//                            .foregroundColor(.secondary)
//                            .padding(.horizontal)
//                        Button {
//                            loadingState = .idle // Reset to allow retry
//                            startLoadingModel()
//                        } label: {
//                            Label("Retry", systemImage: "arrow.clockwise.circle")
//                        }
//                        .buttonStyle(.bordered)
//                        .controlSize(.regular)
//                    }
//                    .padding()
//                }
//            }
//            .navigationTitle("LLM Chat")
//            .navigationBarTitleDisplayMode(.inline)
//            .onDisappear {
//                // Cancel the loading task if the view disappears
//                loadingTask?.cancel()
//                print("ContentView disappeared, cancelling loading task.")
//            }
//        }
//    }
//    
//    // Function to start the model loading process
//    private func startLoadingModel() {
//        // Prevent starting multiple tasks
//        guard loadingTask == nil || loadingTask?.isCancelled == true else {
//            print("Loading task already in progress or finishing.")
//            return
//        }
//        
//        print("Starting model loading process...")
//        loadingState = .downloading(progress: 0.0)
//        
//        loadingTask = Task {
//            do {
//                // Define the progress update closure
//                let progressCallback: (Double) -> Void = { progressValue in
//                    // Update the state on the main thread
//                    Task { @MainActor in
//                        // Only update if still in downloading state
//                        if case .downloading = self.loadingState {
//                            self.loadingState = .downloading(progress: progressValue)
//                        }
//                    }
//                }
//                
//                // Initialize the correct bot type (real or placeholder)
//                // Assign result to the protocol type 'ChatBot'
//                let loadedBot: any ChatBot = try await RuntimeBotType(
//                    repoId: modelRepoId,
//                    quantization: modelQuantization,
//                    template: modelTemplate,
//                    progressUpdate: progressCallback
//                )
//                
//                // Check if the task was cancelled during await
//                try Task.checkCancellation()
//                
//                // Task completed successfully, update state on main thread
//                print("Model loading task completed successfully.")
//                await MainActor.run {
//                    self.loadingState = .loaded(loadedBot) // Store the protocol type
//                }
//                
//            } catch is CancellationError {
//                print("Model loading task was cancelled.")
//                // Reset state or handle cancellation appropriately
//                await MainActor.run {
//                    if case .downloading = self.loadingState {
//                        self.loadingState = .idle // Go back to idle if cancelled during download
//                    }
//                }
//            } catch {
//                print("Error during model loading or initialization: \(error)")
//                // Update state to failed on the main thread
//                await MainActor.run {
//                    self.loadingState = .failed(error)
//                }
//            }
//            // Clean up the task reference once it's done (success, failure, or cancel)
//            loadingTask = nil
//        }
//    }
//}
//
//// MARK: - Mock Bot for Previews and Testing
//
//#if DEBUG // MockBot only needed for Debug builds (Previews, Tests)
//
//class MockBot: ObservableObject, ChatBot { // Conform to protocol, not inherit from Bot
//    @Published var output: String
//    @Published var isAvailable: Bool
//    @Published var history: [(role: ChatRole, content: String)] // Use ChatRole
//    
//    init(
//        mockOutput: String = "Hello from MockBot! Ask me anything.",
//        history: [(role: ChatRole, content: String)] = [],
//        isAvailable: Bool = true
//    ) {
//        self.output = mockOutput
//        self.history = history
//        self.isAvailable = isAvailable
//        // Ensure history isn't empty if needed for UI testing
//        if self.history.isEmpty {
//            self.history.append((role: .assistant, content: mockOutput))
//        }
//    }
//    
//    // Implement protocol methods with mock behavior
//    func respond(to input: String) async {
//        print("MockBot received input: \(input)")
//        await MainActor.run { self.isAvailable = false }
//        let response = "This is a mock response to your query: '\(input.prefix(30))...'"
//        
//        // Simulate network/processing delay
//        try? await Task.sleep(nanoseconds: UInt64.random(in: 300_000_000...1_000_000_000))
//        
//        await MainActor.run {
//            let userTurn: (role: ChatRole, content: String) = (.user, input)
//            let botTurn: (role: ChatRole, content: String) = (.assistant, response)
//            self.history.append(userTurn)
//            self.history.append(botTurn)
//            // Append turns to output string for display
//            self.output += "\n\nUser: \(input)\n\nBot: \(response)"
//            self.isAvailable = true
//            print("MockBot finished responding.")
//        }
//    }
//    
//    // Implement protocol method - NO 'override' keyword
//    func stop() {
//        print("MockBot stop requested.")
//        // Simulate stopping generation
//        Task { @MainActor in self.isAvailable = true }
//    }
//}
//
//// MARK: - SwiftUI Previews
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            // 1. Idle State Preview
//            ContentView(initialLoadingState: .idle)
//                .previewDisplayName("Idle")
//                .preferredColorScheme(.light) // Test light mode
//            
//            // 2. Downloading State Preview
//            ContentView(initialLoadingState: .downloading(progress: 0.72))
//                .previewDisplayName("Downloading (72%)")
//                .preferredColorScheme(.dark) // Test dark mode
//            
//            // 3. Loaded State Preview (using MockBot)
//            ContentView(initialLoadingState: .loaded(MockBot()))
//                .previewDisplayName("Loaded (Mock)")
//            
//            // 4. Failed State Preview
//            let sampleError = ModelLoadingError.downloadError(
//                NSError(domain: "NetworkError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Model file not found on server (404)."])
//            )
//            ContentView(initialLoadingState: .failed(sampleError))
//                .previewDisplayName("Failed Loading")
//        }
//    }
//}
//
//// MARK: - Minimal Placeholder Definitions (Only if LLM library isn't available)
//// These allow the code to compile when the actual LLM package is missing.
//
//#if !canImport(LLM)
//
//// Basic ObservableObject to mimic LLM (if Bot inherits from it directly)
//class LLM_Placeholder: ObservableObject {
//    // Mimic properties Bot might expect from LLM if needed
//    @Published var output: String = ""
//    @Published var isAvailable: Bool = true
//    var history: [(role: ChatBot.ChatRole, content: String)] = [] // Use ChatRole from protocol
//    
//    // Placeholder designated initializer signature
//    init(from url: URL, template: LlmTemplate) throws {
//        print("Placeholder LLM initialized with URL: \(url.lastPathComponent)")
//    }
//    
//    // Placeholder methods matching Bot's expected superclass methods
//    func respond(to input: String) async { /* Placeholder behavior */ }
//    func stop() { /* Placeholder behavior */ }
//}
//
//// Alias LLM to the placeholder ONLY if the real one isn't imported
//typealias LLM = LLM_Placeholder
//
//#endif // !canImport(LLM)
//
//#endif // DEBUG (End of MockBot and Preview specific code)
