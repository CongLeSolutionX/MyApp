//
//  BotView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/23/25.
//

import SwiftUI
import LLM // Import the library
// Foundation is needed for FileManager and URLSession
import Foundation

// MARK: - Error Handling
enum ModelLoadingError: LocalizedError {
    case directoryCreationFailed(Error)
    case downloadError(Error)
    case fileMoveError(Error)
    case invalidURL
    case initializationFailed(Error?) // Can wrap underlying LLM init errors
    
    var errorDescription: String? {
        switch self {
        case .directoryCreationFailed(let error):
            return "Failed to create model storage directory: \(error.localizedDescription)"
        case .downloadError(let error):
            return "Failed to download model: \(error.localizedDescription)"
        case .fileMoveError(let error):
            return "Failed to save model file: \(error.localizedDescription)"
        case .invalidURL:
            return "Could not construct a valid URL for downloading."
        case .initializationFailed(let error):
            return "Failed to initialize LLM engine: \(error?.localizedDescription ?? "Unknown reason")"
        }
    }
}

// MARK: - Bot Class Definition with Download Logic

/// A wrapper around the LLM class that handles local caching and downloading.
class Bot: LLM {
    
    /// Asynchronous initializer that checks local cache first, then downloads if necessary.
    /// - Parameters:
    ///   - repoId: The Hugging Face repository ID (e.g., "TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF").
    ///   - quantization: The desired quantization level (e.g., .Q2_K). Determines the filename.
    ///   - template: The chat template to use (e.g., .chatML).
    ///   - progressUpdate: Closure to report download progress (0.0 to 1.0). Called with 1.0 if file exists locally.
    convenience init?(
        repoId: String,
        quantization: Quantization, // Use the Quantization enum from LLM.swift
        template: Template,
        progressUpdate: @escaping (Double) -> Void
    ) async throws {
        
        // 1. Determine Local File Path
        guard let localModelURL = try Self.getLocalModelURL(repoId: repoId, quantization: quantization) else {
            throw ModelLoadingError.invalidURL // Or handle filename generation error
        }
        let fileManager = FileManager.default
        
        // 2. Check if Model Exists Locally
        if fileManager.fileExists(atPath: localModelURL.path) {
            print("Model found locally at: \(localModelURL.path)")
            // Initialize directly from local file
            do {
                // Need to call the designated initializer of the superclass
                try self.init(from: localModelURL, template: template)
                progressUpdate(1.0) // Indicate loading complete
                print("LLM initialized successfully from local file.")
            } catch {
                print("Error initializing LLM from existing local file: \(error)")
                // Optionally: try deleting the corrupt file and attempt download?
                throw ModelLoadingError.initializationFailed(error)
            }
            return // Initialization complete
        }
        
        // 3. Model Not Found - Download Required
        print("Model not found locally. Starting download...")
        progressUpdate(0.0) // Start progress at 0
        
        // Ensure the directory exists
        do {
            try Self.ensureModelDirectoryExists()
        } catch {
            throw ModelLoadingError.directoryCreationFailed(error)
        }
        
        // Construct Hugging Face download URL
        guard let downloadURL = HuggingFaceModel.constructDownloadURL(repoId: repoId, quantization: quantization) else {
            print("Could not construct valid download URL.")
            throw ModelLoadingError.invalidURL
        }
        
        // Perform Download using URLSession
        let downloader = ModelDownloader(progressUpdate: progressUpdate)
        let temporaryURL: URL
        do {
            temporaryURL = try await downloader.download(from: downloadURL)
            print("Download complete. Temporary file at: \(temporaryURL.path)")
        } catch {
            print("Download failed: \(error)")
            throw ModelLoadingError.downloadError(error)
        }
        
        // Move downloaded file from temporary location to final destination
        do {
            // Attempt to remove item if it exists at destination (e.g., from a partial prior download)
            if fileManager.fileExists(atPath: localModelURL.path) {
                try fileManager.removeItem(at: localModelURL)
            }
            try fileManager.moveItem(at: temporaryURL, to: localModelURL)
            print("Model successfully saved to: \(localModelURL.path)")
        } catch {
            print("Failed to move downloaded file: \(error)")
            // Clean up temporary file if move fails
            try? fileManager.removeItem(at: temporaryURL)
            throw ModelLoadingError.fileMoveError(error)
        }
        
        // 4. Initialize LLM After Successful Download
        do {
            // Call the designated initializer of the superclass
            try self.init(from: localModelURL, template: template)
            print("LLM initialized successfully after download.")
        } catch {
            print("Error initializing LLM after download: \(error)")
            // Optionally: Clean up the downloaded file if init fails?
            // try? fileManager.removeItem(at: localModelURL)
            throw ModelLoadingError.initializationFailed(error)
        }
    }
    
    // --- File Management Helpers ---
    
    /// Gets the URL for the Models directory within Application Support.
    private static func getModelsDirectoryURL() throws -> URL {
        return try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("LLM_Models", isDirectory: true)
    }
    
    /// Ensures the Models directory exists.
    private static func ensureModelDirectoryExists() throws {
        let modelsDirURL = try getModelsDirectoryURL()
        if !FileManager.default.fileExists(atPath: modelsDirURL.path) {
            try FileManager.default.createDirectory(at: modelsDirURL, withIntermediateDirectories: true, attributes: nil)
            print("Created models directory at: \(modelsDirURL.path)")
        }
    }
    
    /// Constructs the expected local file URL for a given model.
    private static func getLocalModelURL(repoId: String, quantization: Quantization) throws -> URL? {
        guard let filename = HuggingFaceModel.filename(from: repoId, quantization: quantization) else {
            return nil // Could not determine filename
        }
        let modelsDirURL = try getModelsDirectoryURL()
        return modelsDirURL.appendingPathComponent(filename)
    }
}

// MARK: - HuggingFaceModel Helpers (Assuming structure from LLM.swift)

/// Add helper static functions to HuggingFaceModel if they don't exist in LLM.swift
extension HuggingFaceModel {
    /// Constructs the filename based on repo ID and quantization.
    /// Logic might vary based on actual HuggingFaceModel implementation.
    static func filename(from repoId: String, quantization: Quantization) -> String? {
        // Example logic: Extract model name from repoId and append quantization string
        guard let modelName = repoId.split(separator: "/").last else { return nil }
        // Use the rawValue of the enum case (assuming it matches HF naming, e.g., "Q2_K")
        return "\(modelName).\(quantization.rawValue).gguf"
        // Or, if Quantization doesn't have a matching string rawValue:
        // let qString = quantizationToString(quantization) // Implement this helper
        // return "\(modelName).\(qString).gguf"
    }
    
    /// Constructs the download URL for a specific model file.
    static func constructDownloadURL(repoId: String, quantization: Quantization) -> URL? {
        guard let filename = self.filename(from: repoId, quantization: quantization) else {
            return nil
        }
        // Standard Hugging Face URL format for downloading files
        return URL(string: "https://huggingface.co/\(repoId)/resolve/main/\(filename)")
    }
    
    // Helper if Quantization enum doesn't have a string rawValue directly suitable for filenames
    //    private static func quantizationToString(_ q: Quantization) -> String {
    //        switch q {
    //        case .Q2_K: return "Q2_K"
    //        case .Q4_K_M: return "Q4_K_M"
    //        case .Q5_K_M: return "Q5_K_M"
    //            // Add cases for all quantization levels defined in LLM.swift's HuggingFaceModel
    //        }
    //    }
}

// MARK: - URLSession Downloader Helper

/// Simple class to handle URLSession download and progress reporting.
class ModelDownloader: NSObject, URLSessionDownloadDelegate {
    private var progressUpdate: (Double) -> Void
    private var downloadCompletion: ((Result<URL, Error>) -> Void)?
    private var observation: NSKeyValueObservation?
    
    init(progressUpdate: @escaping (Double) -> Void) {
        self.progressUpdate = progressUpdate
    }
    
    func download(from url: URL) async throws -> URL {
        // Create a URLSession configured to use this class as the delegate
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil) // Use nil queue for async/await handling
        
        // Use async/await version of downloadTask which returns the location URL
        // Note: Built-in progress reporting with async/await download is less direct than delegate method.
        // We'll use the delegate primarily for progress updates.
        return try await withCheckedThrowingContinuation { continuation in
            // Store the continuation to resume it when the download finishes (or fails)
            self.downloadCompletion = { result in
                continuation.resume(with: result)
                self.observation?.invalidate() // Clean up observer
                self.observation = nil
                self.downloadCompletion = nil // Avoid retaining continuation
            }
            
            // Start the download task
            let downloadTask = session.downloadTask(with: url)
            
            // Observe the task's progress (this uses KVO)
            self.observation = downloadTask.progress.observe(\.fractionCompleted) { progress, _ in
                DispatchQueue.main.async { // Ensure UI updates on main thread
                    self.progressUpdate(progress.fractionCompleted)
                }
            }
            downloadTask.resume()
        }
    }
    
    // MARK: - URLSessionDownloadDelegate Methods
    
    // Called when the download finishes successfully.
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // Successfully downloaded to a temporary location.
        // The completion handler stored in `download` will move this file.
        downloadCompletion?(.success(location))
    }
    
    // Called when the download fails or an error occurs.
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            // Handle potential cancellation errors specifically if needed
            let nsError = error as NSError
            if !(nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled) {
                print("URLSession Task Error: \(error.localizedDescription)")
                downloadCompletion?(.failure(error))
            } else {
                print("Download task cancelled.")
                // Consider if cancellation should be treated as a specific error or ignored
                // For now, let's treat it like other errors
                downloadCompletion?(.failure(error))
            }
        } else if downloadCompletion != nil {
            // If there's no error, but didFinishDownloadingTo wasn't called (unexpected state),
            // treat it as a failure.
            let unknownError = NSError(domain: "ModelDownloader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Download completed without error but temporary file location not provided."])
            downloadCompletion?(.failure(unknownError))
        }
        // If downloadCompletion is nil, it means the continuation was already resumed (e.g., by success).
    }
}

// MARK: - Chat View (BotView - Mostly Unchanged)

struct BotView: View {
    @ObservedObject var bot: Bot
    @State private var inputText: String = "Give me seven national flag emojis people use the most; You must include South Korea."
    @Namespace var bottomID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    Text(bot.output)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .id(bottomID)
                }
                .onChange(of: bot.output) {
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            scrollViewProxy.scrollTo(bottomID, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input Area
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(.thinMaterial)
                    TextField("Enter message...", text: $inputText, axis: .vertical)
                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                        .lineLimit(1...5)
                }
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill").font(.system(size: 18))
                }
                .buttonStyle(.borderedProminent).clipShape(Circle())
                .disabled(!bot.isAvailable || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .tint(.accentColor)
                
                Button(action: stopGeneration) {
                    Image(systemName: "stop.circle.fill").font(.system(size: 18))
                }
                .buttonStyle(.bordered).clipShape(Circle()).tint(.red)
                .disabled(bot.isAvailable)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.bar)
        }
    }
    
    private func sendMessage() {
        let textToSend = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !textToSend.isEmpty {
            inputText = ""
            Task { await bot.respond(to: textToSend) }
        }
    }
    private func stopGeneration() { bot.stop() }
}

// MARK: - Main Content View with Loading States

struct ContentView: View {
    enum LoadingState {
        case idle
        case downloading(progress: Double)
        case loaded(Bot)
        case failed(Error)
    }
    
    @State private var loadingState: LoadingState = .idle
    @State private var loadingTask: Task<Void, Never>? = nil // To manage the loading task
    
    // --- Model Configuration ---
    // Adjust these parameters for the desired model
    let modelRepoId = "TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF"
    let modelQuantization = Quantization.Q2_K // Use small Q2_K for faster testing/download
    let modelTemplate = Template.chatML("You are a helpful AI assistant.") // Example prompt
    // --------------------------
    
    var body: some View {
        NavigationView {
            Group { // Use Group to easily switch content based on state
                switch loadingState {
                case .idle:
                    VStack(spacing: 20) {
                        Text("Tap to load LLM model.")
                        Button("Load Model") {
                            startLoadingModel()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                case .downloading(let progress):
                    ProgressView(value: progress) {
                        Text("Loading Model...")
                    } currentValueLabel: {
                        Text(String(format: "%.1f%%", progress * 100))
                    }
                    .progressViewStyle(.circular) // Or .linear
                    .padding()
                    
                case .loaded(let bot):
                    BotView(bot: bot) // Show the chat interface
                    
                case .failed(let error):
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.red)
                        Text("Failed to Load Model")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Retry") {
                            loadingState = .idle // Reset state to allow retry
                            startLoadingModel()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }
            }
            .navigationTitle("LLM Chat")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Optional: Automatically start loading when the view appears
                // if case .idle = loadingState {
                //     startLoadingModel()
                // }
            }
            .onDisappear {
                // Cancel the loading task if the view disappears
                loadingTask?.cancel()
            }
        }
    }
    
    /// Initiates the asynchronous model loading process.
    private func startLoadingModel() {
        // Ensure we don't start multiple loading tasks
        guard loadingTask == nil || loadingTask?.isCancelled == true else { return }
        
        loadingState = .downloading(progress: 0.0) // Set initial downloading state
        
        loadingTask = Task {
            do {
                // Define the progress update closure
                let progressCallback: (Double) -> Void = { progressValue in
                    // Update the state on the main thread
                    Task { @MainActor in
                        // Only update if still in downloading state
                        if case .downloading = self.loadingState {
                            self.loadingState = .downloading(progress: progressValue)
                        }
                    }
                }
                
                // Call the asynchronous initializer
                let loadedBot = try await Bot(
                    repoId: modelRepoId,
                    quantization: modelQuantization,
                    template: modelTemplate,
                    progressUpdate: progressCallback
                )
                
                // Check if the task was cancelled during await
                try Task.checkCancellation()
                
                // Update state to loaded on the main thread
                await MainActor.run {
                    self.loadingState = .loaded(loadedBot ?? <#default value#>)
                }
                
            } catch is CancellationError {
                print("Model loading task cancelled.")
                // Reset state if needed, or leave as downloading if appropriate
                await MainActor.run {
                    if case .downloading = self.loadingState {
                        self.loadingState = .idle // Or a specific cancelled state
                    }
                }
            } catch {
                // Update state to failed on the main thread
                await MainActor.run {
                    self.loadingState = .failed(error)
                }
                print("Error during model loading: \(error)")
            }
            // Clean up the task reference once done
            loadingTask = nil
        }
    }
}

// MARK: - SwiftUI Previews (Optional)

#if DEBUG
// Previews might be harder to set up accurately with async loading.
// You might explicitly set the state for previewing different UI states.

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
// Preview Idle State
//        ContentView(loadingState: .idle)
//            .previewDisplayName("Idle State")

// Preview Downloading State
//        ContentView(loadingState: .downloading(progress: 0.65))
//            .previewDisplayName("Downloading State")

// Preview Failed State
//        ContentView(loadingState: .failed(ModelLoadingError.downloadError(NSError(domain: "Preview", code: -1, userInfo: [NSLocalizedDescriptionKey: "Simulated network error during download."]))))
//            .previewDisplayName("Failed State")

// Preview Loaded State (Requires a Mock Bot or a readily available small model)
//        ContentView(loadingState: .loaded(createMockBot()))
//            .previewDisplayName("Loaded State")
//    }

//    // Helper to create a mock bot for preview if needed
//    static func createMockBot() -> Bot {
//        // This is tricky because Bot's designated initializer might be internal or complex.
//        // You might need to adjust Bot or LLM for better testability/mocking.
//        // For now, this part is commented out.
//        fatalError("Mock Bot creation for SwiftUI preview needs implementation.")
//    }
//}
#endif

// --- Placeholder definitions if LLM library isn't available ---
#if !canImport(LLM)

import Combine // Needed for ObservableObject publish changes

enum MockRole { case user, bot }
struct MockTemplate {
    var stopSequence: String? = nil
    func preprocess(_ input: String, _ history: [(role: MockRole, content: String)]) -> String { return input }
    static func chatML(_ prompt: String?) -> MockTemplate { return MockTemplate() }
}

class LLM: ObservableObject {
    @Published var output: String = "LLM Library Not Found. This is mock output."
    @Published var isAvailable: Bool = true
    var history: [(role: MockRole, content: String)] = []
    var historyLimit: Int = 10
    var maxTokenCount: Int = 2048
    
    // Designated initializer expected by the Bot subclass
    init(from url: URL, template: MockTemplate) throws { print("Mock LLM Initialized from URL: \(url)") }
    
    func respond(to input: String) async {
        print("Mock LLM received input: \(input)")
        await MainActor.run { self.isAvailable = false }
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                self.output += "\nMock response to '\(input)'"
                self.isAvailable = true
            }
        }
    }
    func stop() { print("Mock LLM stop called."); Task { @MainActor in self.isAvailable = true } }
}

struct HuggingFaceModel { // Mock struct
    enum Quantization: String, CaseIterable { // Make rawValue String for filename usage
        case Q2_K = "Q2_K"
        case Q4_K_M = "Q4_K_M"
        case Q5_K_M = "Q5_K_M"
        // Add other quantizations used
    }
    init(_ repoId: String, _ quantization: Quantization? = nil, template: MockTemplate) { }
}

// Minimal implementation for Template if needed by initializer signature
struct Template {
    var system: (String, String)? = nil
    var user: (String, String)? = nil
    var bot: (String, String)? = nil
    var stopSequence: String? = nil
    var systemPrompt: String? = nil
    
    var preprocess: (String, [(role: LLM.Role, content: String)]) -> String = { input, _ in input }
    
    static func chatML(_ systemPrompt: String?) -> Template {
        // Provide a basic mock implementation
        var t = Template()
        t.systemPrompt = systemPrompt
        // Define default preprocess logic for chatML if needed for testing
        t.preprocess = { input, history in
            var processed = "<|im_start|>system\n\(systemPrompt ?? "")<|im_end|>\n"
            for chat in history {
                processed += "<|im_start|>\(chat.role == .user ? "user" : "assistant")\n\(chat.content)<|im_end|>\n"
            }
            processed += "<|im_start|>user\n\(input)<|im_end|>\n"
            processed += "<|im_start|>assistant\n"
            return processed
        }
        t.stopSequence = "<|im_end|>"
        return t
    }
}

// Extend LLM with Role enum if needed by Template.chatML mock
extension LLM {
    enum Role { case user, bot }
}

#endif
// ------ End Placeholder Definitions ------
