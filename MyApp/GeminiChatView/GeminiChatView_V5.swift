//
//  GeminiChatView_V5.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//


// MARK: - GeminiChatApp.swift (Example Main App Structure)
// import SwiftUI
//
// @main
// struct GeminiChatApp: App {
//     var body: some Scene {
//         WindowGroup {
//             NavigationView { // Add NavigationView here if OptimizedGeminiChatView doesn't have one
//                 OptimizedGeminiChatView()
//             }
//         }
//     }
// }


// MARK: - Complete Code (Single File)

import SwiftUI
import Combine
import Security // Required for KeychainHelper

// MARK: - Constants & Configuration

// !!! --- VERY IMPORTANT: Secure API Key Handling --- !!!
// Preferred Method: Set Environment Variable 'GEMINI_API_KEY' in Xcode Scheme (Run -> Arguments -> Environment Variables)
// Fallback (Testing ONLY - DO NOT COMMIT REAL KEY): Replace "YOUR_API_KEY_HERE" directly.
let geminiApiKeyPlaceholder: String = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? "YOUR_API_KEY_HERE"

struct ServiceConstants {
    static let apiKeyInstructions = """
    Gemini API Key is missing or invalid.
    Please obtain a key from Google AI Studio and configure it securely.
    Recommended Method: Set the 'GEMINI_API_KEY' environment variable in your Xcode Scheme.
    Alternatively, enter it in the app's Settings screen.
    DO NOT commit your API key directly into the code.
    """
}

struct StyleConstants {
    static let horizontalPadding: CGFloat = 15
    static let verticalPadding: CGFloat = 10
    static let bubbleCornerRadius: CGFloat = 18
    static let timestampFontSize: CGFloat = 10
}

// MARK: - Keychain Helper (for Secure API Key Storage)

struct KeychainHelper {
    static let service = Bundle.main.bundleIdentifier ?? "com.example.geminichat"
    static let account = "geminiAPIKey" // Identifier for the key

    static func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ] as [String: Any]

        SecItemDelete(query as CFDictionary) // Delete existing before saving new
        return SecItemAdd(query as CFDictionary, nil)
    }

    static func load(key: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne
        ] as [String: Any]

        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as? Data
        } else {
            if status != errSecItemNotFound {
                print("Keychain load error: \(status)")
            }
            return nil
        }
    }

    static func delete(key: String) -> OSStatus {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as [String: Any]
        return SecItemDelete(query as CFDictionary)
    }

    static func saveString(_ value: String, forKey key: String) -> Bool {
        if let data = value.data(using: .utf8) {
            return save(key: key, data: data) == noErr
        }
        return false
    }

    static func loadString(forKey key: String) -> String? {
        if let data = load(key: key) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}


// MARK: - Data Models

enum MessageRole: String, Codable {
    case user
    case model
}

struct ChatMessage: Identifiable, Equatable, Codable {
    let id: UUID
    var role: MessageRole
    var text: String
    var timestamp: Date
    var isLoading: Bool = false
    var isErrorPlaceholder: Bool = false

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

enum GeminiModel: String, CaseIterable, Identifiable {
    case flash = "gemini-1.5-flash-latest"
    case pro = "gemini-1.5-pro-latest"
    // Add other models here if available/needed

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .flash: return "Gemini 1.5 Flash"
        case .pro: return "Gemini 1.5 Pro"
        }
    }

    // The specific API endpoint path segment for the model
    var endpointPath: String {
        "v1beta/models/\(self.rawValue):generateContent"
    }

    // Base URL - adjust if Google changes this
    static let baseApiUrl = "https://generativelanguage.googleapis.com/"

    // Full endpoint URL
    var endpointUrlString: String {
        return GeminiModel.baseApiUrl + endpointPath
    }
}

// MARK: --- Gemini API Request/Response Models ---

// Request body structure for Gemini generateContent
struct APIRequestBody: Codable {
    let contents: [Content]
    let generationConfig: GenerationConfig? // Optional config
    // let safetySettings: [SafetySetting]? // Optional safety settings

    struct Content: Codable {
        let parts: [Part]
        // Role can be included if constructing conversation history
         // let role: String? // "user" or "model"
    }

    struct Part: Codable {
        let text: String
    }

    struct GenerationConfig: Codable {
        let temperature: Double?
        // Add other config params like topP, topK, maxOutputTokens if needed
    }

    // Example SafetySetting structure (if needed)
    // struct SafetySetting: Codable {
    //     let category: String // e.g., "HARM_CATEGORY_SEXUALLY_EXPLICIT"
    //     let threshold: String // e.g., "BLOCK_MEDIUM_AND_ABOVE"
    // }
}

// Response body structure for Gemini generateContent
struct APIResponseBody: Codable {
    let candidates: [Candidate]?
    let promptFeedback: PromptFeedback?
    let error: APIErrorDetail? // Catches errors within the JSON response

    struct Candidate: Codable {
        let content: Content?
        let finishReason: String?
        let index: Int?
        let safetyRatings: [SafetyRating]?
    }

    struct Content: Codable {
        let parts: [Part]?
        let role: String? // "model"
    }

    struct Part: Codable {
        let text: String?
    }

    struct PromptFeedback: Codable {
        let safetyRatings: [SafetyRating]?
    }

    struct SafetyRating: Codable {
        let category: String?
        let probability: String?
    }

    struct APIErrorDetail: Codable {
        let code: Int?
        let message: String?
        let status: String?
    }

    func extractText() -> String? {
        guard let candidates = candidates, !candidates.isEmpty,
              let firstCandidate = candidates.first,
              let content = firstCandidate.content,
              let parts = content.parts, !parts.isEmpty,
              let text = parts.first?.text else {
            if let apiError = self.error {
                return "API Error: \(apiError.message ?? "Unknown Gemini error") (\(apiError.status ?? "Status N/A"))"
            }
            return nil
        }
        return text
    }
}


// MARK: - API Service Layer

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse(statusCode: Int)
    case decodingError(Error)
    case noData
    case missingApiKey
    case apiErrorResponse(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The Gemini API endpoint URL is invalid."
        case .requestFailed(let error): return "Network request failed: \(error.localizedDescription)"
        case .invalidResponse(let statusCode): return "Invalid server response (Status Code: \(statusCode)). Check API Key and endpoint."
        case .decodingError(let error): return "Failed to decode API response: \(error.localizedDescription)"
        case .noData: return "No data received from API."
        case .missingApiKey: return ServiceConstants.apiKeyInstructions
        case .apiErrorResponse(let message): return message
        }
    }
}

protocol ChatAPIService {
    // Accepts endpoint and optional temperature
    func generateResponse(for prompt: String, apiKey: String, endpoint: String, temperature: Double?) async throws -> String
}

class GeminiAPIService: ChatAPIService {

    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func generateResponse(for prompt: String, apiKey: String, endpoint: String, temperature: Double?) async throws -> String {

        // 1. Validate API Key Presence (ViewModel layer should ideally handle this check first)
        guard !apiKey.isEmpty, apiKey != "YOUR_API_KEY_HERE" else {
            throw APIError.missingApiKey
        }

        // 2. Construct URL with API Key Query Parameter using the provided endpoint
        guard var components = URLComponents(string: endpoint) else {
            throw APIError.invalidURL
        }
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        guard let finalUrl = components.url else {
            throw APIError.invalidURL
        }

        // 3. Prepare Request
        var request = URLRequest(url: finalUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // 4. Prepare Request Body with optional GenerationConfig
         let generationConfig = temperature != nil ? APIRequestBody.GenerationConfig(temperature: temperature) : nil
         // Construct message history if needed (more complex)
         // For simple prompt:
         let requestBody = APIRequestBody(
             contents: [.init(parts: [.init(text: prompt)])],
             generationConfig: generationConfig
         )

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw APIError.requestFailed(error) // Error encoding request body
        }

        // 5. Perform Network Request
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            throw APIError.requestFailed(error)
        }

        // 6. Validate HTTP Response Status
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(statusCode: -1) // Should not happen
        }

        // 7. Handle Non-Successful Status Codes (Attempt to parse error from body)
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorBody = try? JSONDecoder().decode(APIResponseBody.self, from: data),
               let apiErrorMsg = errorBody.error?.message {
                 let statusDesc = errorBody.error?.status ?? "Status N/A"
                 throw APIError.apiErrorResponse(message: "API Error: \(apiErrorMsg) (Status: \(statusDesc), Code: \(httpResponse.statusCode))")
            }
            // Fallback standard HTTP error
            throw APIError.invalidResponse(statusCode: httpResponse.statusCode)
        }

        // 8. Check for Empty Data
        guard !data.isEmpty else {
            throw APIError.noData
        }

        // 9. Decode Successful Response
        do {
            let decodedResponse = try JSONDecoder().decode(APIResponseBody.self, from: data)
            if let textResponse = decodedResponse.extractText() {
                // Check if the extracted text is actually an inline error
                if let apiError = decodedResponse.error {
                     throw APIError.apiErrorResponse(message: "API Error: \(apiError.message ?? "Unknown Gemini error") (\(apiError.status ?? "N/A"))")
                }
                return textResponse // Success
            } else {
                throw APIError.decodingError(NSError(domain: "GeminiAPIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not extract text from the Gemini response."]))
            }
        } catch let error as APIError {
             throw error // Re-throw known API errors
        } catch {
             // Catch JSON decoding errors
            throw APIError.decodingError(error)
        }
    }
}


// MARK: - ViewModel

@MainActor
class ChatViewModel: ObservableObject {
    @Published var chatMessages: [ChatMessage] = []
    @Published var userInput: String = ""
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isShowingErrorAlert: Bool = false
    @Published var isShowingSettings: Bool = false // Controls settings sheet

    // --- Settings Properties ---
    @Published var useMockData: Bool = true // Default to Mock
    @Published var apiKeyStatusMessage: String = "Not Set" // UI indicator
    @Published private(set) var storedApiKey: String = "" // Loaded from Keychain

    // Persisted Settings (non-sensitive)
    @AppStorage("geminiModelSelection") var selectedModel: GeminiModel = .flash
    @AppStorage("geminiTemperature") var temperature: Double = 0.7

    private var cancellables = Set<AnyCancellable>()
    private let apiService: ChatAPIService
    private let apiKeyKeychainKey = KeychainHelper.account // Consistent key

    init(apiService: ChatAPIService = GeminiAPIService()) {
        self.apiService = apiService
        loadInitialMessages()
        setupBindings()
        loadApiKeyFromKeychain() // Load on init
    }

    private func setupBindings() {
        // Alert Trigger
        $errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.isShowingErrorAlert = true }
            .store(in: &cancellables)

        // API Key Status Message Updater
        $storedApiKey
            .map { $0.isEmpty ? "Not Set" : "Saved" }
            .receive(on: DispatchQueue.main)
            .assign(to: &$apiKeyStatusMessage)

        // Optional: React to model/temperature changes dynamically if needed
        // $selectedModel.sink { ... }.store(in: &cancellables)
        // $temperature.sink { ... }.store(in: &cancellables)
    }

    func loadInitialMessages() {
        if chatMessages.isEmpty {
            chatMessages = [
                ChatMessage(id: UUID(), role: .user, text: "Hello Gemini!", timestamp: Date().addingTimeInterval(-120)),
                ChatMessage(id: UUID(), role: .model, text: "Hi! Toggle between Mock/Real. Configure in Settings (⚙️).", timestamp: Date().addingTimeInterval(-110))
            ]
        }
    }

    func sendMessage() {
        let textToSend = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textToSend.isEmpty, !isProcessing else { return }

        let userMessage = ChatMessage(id: UUID(), role: .user, text: textToSend, timestamp: Date())
        chatMessages.append(userMessage)

        let loadingMessageId = UUID()
        let loadingMessage = ChatMessage(id: loadingMessageId, role: .model, text: "...", timestamp: Date(), isLoading: true)
        chatMessages.append(loadingMessage)

        userInput = ""
        isProcessing = true
        errorMessage = nil // Clear previous

        Task {
            var modelResponseText: String = ""
            var isError = false
            var errorToShow: String? = nil
            let currentApiKey = self.storedApiKey
            let currentEndpoint = self.selectedModel.endpointUrlString
            let currentTemperature = self.temperature

            do {
                if useMockData {
                    try await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_500_000_000))
                    if textToSend.lowercased().contains("mock error") {
                        throw APIError.requestFailed(NSError(domain: "MockError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Simulated mock network error."]))
                    }
                    modelResponseText = "[MOCK] You asked: \(textToSend). Temp ≈ \(String(format:"%.1f", currentTemperature)). Model: \(selectedModel.displayName)"
                } else {
                    // --- Pre-flight check for API Key ---
                    guard !currentApiKey.isEmpty else {
                         throw APIError.missingApiKey
                    }
                    // --- Real API Call ---
                    let realResponse = try await apiService.generateResponse(
                        for: textToSend,
                        apiKey: currentApiKey,
                        endpoint: currentEndpoint,
                        temperature: currentTemperature // Pass temperature
                    )
                    modelResponseText = "[REAL] \(realResponse)"
                }
            } catch let error as APIError {
                modelResponseText = "Error: \(error.localizedDescription)"
                isError = true
                errorToShow = error.localizedDescription
                 // Provide specific instruction if API key is missing
                 if case .missingApiKey = error {
                      errorToShow = ServiceConstants.apiKeyInstructions + "\n\nPlease set it in the Settings screen."
                 }
            } catch {
                modelResponseText = "An unexpected error occurred: \(error.localizedDescription)"
                isError = true
                errorToShow = modelResponseText
            }

            await MainActor.run {
                updateOrReplaceMessage(
                    id: loadingMessageId,
                    newText: modelResponseText,
                    isError: isError
                )
                isProcessing = false
                self.errorMessage = errorToShow // Triggers alert via binding
            }
        }
    }

    private func updateOrReplaceMessage(id: UUID, newText: String, isError: Bool) {
        if let index = chatMessages.firstIndex(where: { $0.id == id }) {
            let updatedMessage = ChatMessage(
                id: id,
                role: .model,
                text: newText,
                timestamp: Date(),
                isLoading: false,
                isErrorPlaceholder: isError
            )
            chatMessages[index] = updatedMessage
        }
    }

    // --- Settings Actions ---
    func saveApiKey(_ key: String) {
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        if KeychainHelper.saveString(trimmedKey, forKey: apiKeyKeychainKey) {
            self.storedApiKey = trimmedKey // Update published property
            print("API Key saved.")
        } else {
            print("Failed to save API Key.")
            self.errorMessage = "Failed to save API Key securely."
        }
    }

    func loadApiKeyFromKeychain() {
        self.storedApiKey = KeychainHelper.loadString(forKey: apiKeyKeychainKey) ?? ""
        print(self.storedApiKey.isEmpty ? "No API Key in Keychain." : "API Key loaded.")
    }

    func clearApiKey() {
         if KeychainHelper.delete(key: apiKeyKeychainKey) == noErr {
              self.storedApiKey = ""
              print("API Key cleared.")
         } else {
              print("Failed to clear API Key.")
              self.errorMessage = "Failed to clear API Key."
         }
    }

    func clearChatHistory() {
        chatMessages.removeAll()
        chatMessages.append(ChatMessage(id: UUID(), role: .model, text: "Chat history cleared.", timestamp: Date()))
        print("Chat history cleared.")
    }

    // --- Info ---
    var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
        return "\(version) (\(build))"
    }
}

// MARK: - SwiftUI Views

// MARK: -- Main Chat View

struct OptimizedGeminiChatView: View {
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.chatMessages.isEmpty {
                EmptyStateView()
            } else {
                ChatScrollView(viewModel: viewModel)
            }

            Divider()

            InputAreaView(
                userInput: $viewModel.userInput,
                isProcessing: viewModel.isProcessing,
                placeholder: "Ask Gemini (\(viewModel.useMockData ? "Mock" : "Real"))...",
                sendMessageAction: viewModel.sendMessage
            )
        }
        .navigationTitle("Gemini Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Place toggles and buttons strategically
            ToolbarItem(placement: .navigationBarLeading) {
                Toggle(isOn: $viewModel.useMockData) {
                    Text("Mock") // Short label is good
                }
                .toggleStyle(.switch)
                .tint(.orange) // Custom tint for visibility
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.isShowingSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingSettings) {
            // Present Settings modally
            ChatSettingsView(viewModel: viewModel) // Pass the same ViewModel instance
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .alert("Error", isPresented: $viewModel.isShowingErrorAlert, presenting: viewModel.errorMessage) { _ in
             // Default OK button
        } message: { errorText in
             Text(errorText) // Display the specific error message
        }
        // Optional background for the whole view
        // .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: -- Settings View

struct ChatSettingsView: View {
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.dismiss) var dismiss

    @State private var apiKeyInput: String = "" // Local state for SecureField
    @State private var showClearHistoryAlert = false

    var body: some View {
        // Embed in NavigationView for title and Done button
        NavigationView {
            Form {
                Section("API Configuration") {
                    HStack {
                        SecureField("Enter Gemini API Key", text: $apiKeyInput)
                            .textContentType(.password) // Hint for password managers
                            .onAppear { apiKeyInput = viewModel.storedApiKey } // Pre-fill on appear
                        Spacer()
                        Text(viewModel.apiKeyStatusMessage) // Show "Saved" or "Not Set"
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Button("Save API Key") {
                        viewModel.saveApiKey(apiKeyInput)
                        hideKeyboard()
                    }
                    // Disable save if input (after trimming) is empty
                    .disabled(apiKeyInput.trimmingCharacters(in: .whitespaces).isEmpty)

                     // Only show clear button if a key IS saved
                    if !viewModel.storedApiKey.isEmpty {
                        Button("Clear Saved API Key", role: .destructive) {
                             viewModel.clearApiKey()
                             apiKeyInput = "" // Clear input field as well
                         }
                    }

                    Picker("Model", selection: $viewModel.selectedModel) {
                        ForEach(GeminiModel.allCases) { model in
                             // Display user-friendly name, tag with the enum case
                            Text(model.displayName).tag(model)
                        }
                    }
                    .pickerStyle(.menu) // Dropdown style

                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Temperature")
                            Spacer()
                            Text(String(format: "%.2f", viewModel.temperature)) // Formatted value
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $viewModel.temperature, in: 0.0...1.0, step: 0.05)
                        Text("Lower = more predictable, Higher = more creative.")
                             .font(.caption2)
                             .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5) // Add some vertical padding around the slider group
                }

                Section("Chat Management") {
                    Button("Clear Chat History", role: .destructive) {
                        showClearHistoryAlert = true
                    }
                }

                Section("Information") {
                    Link("Gemini API Documentation", destination: URL(string: "https://ai.google.dev/docs")!)
                        .foregroundColor(.blue) // Explicitly style links

                    // Replace with your actual privacy policy URL
                    Link("Privacy Policy (Example)", destination: URL(string: "https://www.example.com/privacy")!)
                         .foregroundColor(.blue)

                    HStack {
                        Text("App Version")
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() } // Standard dismiss button
                }
            }
            .alert("Clear History?", isPresented: $showClearHistoryAlert) {
                 // Confirmation dialog buttons
                 Button("Cancel", role: .cancel) { }
                 Button("Clear", role: .destructive) { viewModel.clearChatHistory() }
            } message: {
                 // Confirmation message
                 Text("Are you sure you want to permanently delete all messages in this chat?")
            }
        }
    }

     // Helper to dismiss keyboard programmatically
     private func hideKeyboard() {
         UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
     }
}

// MARK: -- Other UI Views (Empty State, ScrollView, Bubble, Indicator, Input)

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 15) {
            Spacer()
            Image(systemName: "sparkles.message.fill") // More relevant icon
                .font(.system(size: 60))
                .foregroundColor(.purple.opacity(0.8))
            Text("Gemini Chat Ready")
                .font(.title2.weight(.medium))
            Text("Enter your prompt below.\nToggle Mock/Real or visit Settings (⚙️).")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
             Spacer() // Push content up slightly
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ChatScrollView: View {
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: StyleConstants.verticalPadding) {
                    ForEach(viewModel.chatMessages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id) // Crucial for scrolling
                    }
                }
                .padding(.horizontal, StyleConstants.horizontalPadding)
                .padding(.vertical, StyleConstants.verticalPadding) // Padding top and bottom
            }
            .onChange(of: viewModel.chatMessages.count) { _, _ in // Scroll on new message count
                 if let lastId = viewModel.chatMessages.last?.id {
                      scrollToBottom(proxy: scrollViewProxy, targetId: lastId)
                 }
             }
            .onAppear { // Scroll on initial load
                 if let lastId = viewModel.chatMessages.last?.id {
                     scrollToBottom(proxy: scrollViewProxy, targetId: lastId, animated: false)
                 }
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy, targetId: UUID, animated: Bool = true) {
        DispatchQueue.main.async { // Ensure DOM is updated before scrolling
            if animated {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    proxy.scrollTo(targetId, anchor: .bottom)
                }
            } else {
                proxy.scrollTo(targetId, anchor: .bottom)
            }
        }
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            if message.role == .user { Spacer(minLength: 50) }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                messageContent
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(bubbleBackground)
                    .foregroundColor(foregroundColor) // Set default text color
                    .clipShape(RoundedRectangle(cornerRadius: StyleConstants.bubbleCornerRadius, style: .continuous))
                    .shadow(color: .black.opacity(message.role == .user ? 0.1 : 0.05), radius: 2, x: 1, y: 1)
                    .contextMenu { copyAction } // Context menu for copying
                    // Smooth transitions for incoming bubbles
                    .transition(.scale(scale: 0.9, anchor: message.role == .user ? .bottomTrailing : .bottomLeading).combined(with: .opacity))

                Text(message.formattedTimestamp)
                    .font(.system(size: StyleConstants.timestampFontSize))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 5)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.role == .user ? .trailing : .leading)

            if message.role == .model { Spacer(minLength: 50) }
        }
        // Animate the entire bubble appearing/changing
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: message.id)
         // Add slight padding at the very bottom of each bubble row for breathing room
         .padding(.bottom, 3)
    }

    @ViewBuilder
    private var messageContent: some View {
        if message.isLoading {
            TypingIndicatorView()
                .padding(.vertical, 5)
                .transition(.opacity)
        } else {
             // Use LocalizedStringKey for potential future Markdown support automatically
            Text(LocalizedStringKey(message.text))
                 // Style error text specifically
                 .font(message.isErrorPlaceholder ? .system(.body, design: .monospaced) : .body)
                 .foregroundColor(message.isErrorPlaceholder ? .red : foregroundColor) // Error text in red
                 .multilineTextAlignment(.leading) // Ensure text aligns left within bubble
                 .fixedSize(horizontal: false, vertical: true) // Allow text to wrap vertically
                 .textSelection(.enabled)
        }
    }

    @ViewBuilder
    private var copyAction: some View {
        // Only allow copying non-loading, non-empty, non-error messages
        if !message.isLoading && !message.text.isEmpty && !message.isErrorPlaceholder {
            Button {
                // Remove prefixes before copying
                let textToCopy = message.text
                    .replacingOccurrences(of: "[REAL] ", with: "")
                    .replacingOccurrences(of: "[MOCK] ", with: "")
                UIPasteboard.general.string = textToCopy
            } label: {
                Label("Copy Text", systemImage: "doc.on.doc")
            }
        }
    }

    private var bubbleBackground: Color {
         if message.isErrorPlaceholder { return Color.red.opacity(0.15) } // Distinct error background
        return message.role == .user ? .blue : Color(.systemGray5) // Slightly darker gray for model
    }

    private var foregroundColor: Color {
         // Let error text color be handled in messageContent
         if message.isErrorPlaceholder { return .primary }
        return message.role == .user ? .white : .primary // Black text on gray bubble
    }
}


struct TypingIndicatorView: View {
    @State private var scale: CGFloat = 0.5
    let dotCount = 3
    let animationDuration = 0.6

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<dotCount, id: \.self) { i in
                Circle()
                    .frame(width: 7, height: 7)
                    .scaleEffect(scale)
                    .animation(
                        Animation.easeInOut(duration: animationDuration)
                            .repeatForever(autoreverses: true)
                            .delay(animationDuration / Double(dotCount + 1) * Double(i)), // Stagger delay
                        value: scale
                    )
            }
        }
        .onAppear { scale = 1.0 }
        .padding(.horizontal, 5) // Ensure it takes some space
    }
}

struct InputAreaView: View {
    @Binding var userInput: String
    let isProcessing: Bool
    let placeholder: String
    let sendMessageAction: () -> Void

    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            ZStack(alignment: .trailing) {
                // TextEditor for better multi-line handling than TextField axis: .vertical
                 TextEditor(text: $userInput)
                     .focused($isTextFieldFocused)
                     .frame(minHeight: 36, maxHeight: 120) // Control height range
                     .padding(.leading, 10) // Inner padding left
                      .padding(.trailing, 35) // Inner padding right (for clear button)
                     .background(Color(.systemGray6)) // Background for TextEditor
                     .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                     .overlay( // Placeholder implementation for TextEditor
                     userInput.isEmpty ?
                         Text(placeholder)
                         .foregroundColor(Color(.placeholderText))
                         .padding(.leading, 14).padding(.top, 8) // Align placeholder
                           : nil,
                     alignment: .topLeading
                 )


                if !userInput.isEmpty {
                    Button {
                        userInput = ""
                        // isTextFieldFocused = true // Keep focus optional on clear
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    .padding(.trailing, 8)
                    .padding(.top, 8) // Adjust clear button position for TextEditor
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }
            .animation(.easeInOut(duration: 0.15), value: userInput.isEmpty) // Animate clear button

            Button {
                sendMessageAction()
                isTextFieldFocused = false // Dismiss keyboard on send
            } label: {
                Group { // Group for smooth transition
                    if isProcessing {
                        ProgressView()
                            .tint(.white)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(Color.gray.opacity(0.5)))
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(isSendButtonEnabled ? Color.blue : Color.gray.opacity(0.5)))
                    }
                }
            }
            .disabled(!isSendButtonEnabled || isProcessing)
            .animation(.easeInOut(duration: 0.2), value: isProcessing)
            .animation(.easeInOut(duration: 0.2), value: isSendButtonEnabled)
            .keyboardShortcut(.defaultAction) // Enter key
            .keyboardShortcut(.return, modifiers: .command) // Cmd+Enter
            .sensoryFeedback(.impact(weight: .medium), trigger: isProcessing && isSendButtonEnabled) // Haptic feedback

        }
        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        .background(.thinMaterial) // Use blur effect background
    }

    private var isSendButtonEnabled: Bool {
        !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}


// MARK: - Preview Providers

#Preview("Chat View - Live") {
    // Embed in NavigationView for Toolbar items to show correctly in preview
    NavigationView {
        OptimizedGeminiChatView()
    }
}

//#Preview("Chat View - Empty") {
//     NavigationView {
//          OptimizedGeminiChatView(viewModel: ChatViewModel(messages: [], apiService: GeminiAPIService()))
//     }
//}

#Preview("Settings View") {
    // Preview the Settings View directly
    ChatSettingsView(viewModel: ChatViewModel()) // Use a fresh ViewModel for preview
}

// MARK: - Helper Extensions

// Convenience initializer for ViewModel (useful for previews or specific states)
extension ChatViewModel {
    convenience init(messages: [ChatMessage], apiService: ChatAPIService = GeminiAPIService()) {
        self.init(apiService: apiService)
        self.chatMessages = messages
    }
}

