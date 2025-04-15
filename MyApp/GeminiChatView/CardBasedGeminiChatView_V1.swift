////
////  CardBasedGeminiChatView.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//// MARK: - GeminiChatApp.swift (Example Main App Structure - Updated Name)
//// import SwiftUI
////
//// @main
//// struct CardBasedGeminiChatApp: App { // Renamed App struct for clarity
////     var body: some Scene {
////         WindowGroup {
////             NavigationView { // Keep NavigationView for title/toolbar
////                 CardBasedGeminiChatView() // Use the new card-based view
////             }
////         }
////     }
//// }
//
//// MARK: - Complete Code (Single File - Card Design Refactor)
//
//import SwiftUI
//import Combine
//import Security // Required for KeychainHelper
//
//// MARK: - Constants & Configuration (Unchanged)
//
//let geminiApiKeyPlaceholder: String = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? "YOUR_API_KEY_HERE"
//
//struct ServiceConstants {
//    static let apiKeyInstructions = """
//    Gemini API Key is missing or invalid.
//    Please obtain a key from Google AI Studio and configure it securely.
//    Recommended Method: Set the 'GEMINI_API_KEY' environment variable in your Xcode Scheme.
//    Alternatively, enter it in the app's Settings screen.
//    DO NOT commit your API key directly into the code.
//    """
//}
//
//struct StyleConstants {
//    static let horizontalPadding: CGFloat = 15
//    static let verticalPadding: CGFloat = 10
//    static let bubbleCornerRadius: CGFloat = 18
//    static let timestampFontSize: CGFloat = 10
//    // Card specific styles
//    static let cardCornerRadius: CGFloat = 12
//    static let cardShadowRadius: CGFloat = 4
//    static let cardInternalPadding: CGFloat = 15
//    static let cardExternalVPadding: CGFloat = 8
//}
//
//// MARK: - Keychain Helper (Unchanged)
//
//struct KeychainHelper {
//    static let service = Bundle.main.bundleIdentifier ?? "com.example.geminichat"
//    static let account = "geminiAPIKey"
//
//    static func save(key: String, data: Data) -> OSStatus {
//        let query = [
//            kSecClass: kSecClassGenericPassword,
//            kSecAttrService: service,
//            kSecAttrAccount: account,
//            kSecValueData: data,
//            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
//        ] as [String: Any]
//        SecItemDelete(query as CFDictionary)
//        return SecItemAdd(query as CFDictionary, nil)
//    }
//
//    static func load(key: String) -> Data? {
//        let query = [
//            kSecClass: kSecClassGenericPassword,
//            kSecAttrService: service,
//            kSecAttrAccount: account,
//            kSecReturnData: kCFBooleanTrue!,
//            kSecMatchLimit: kSecMatchLimitOne ] as [String: Any]
//        var dataTypeRef: AnyObject? = nil
//        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
//        if status == noErr { return dataTypeRef as? Data }
//        else { if status != errSecItemNotFound { print("Keychain load error: \(status)") }; return nil }
//    }
//
//    static func delete(key: String) -> OSStatus {
//        let query = [ kSecClass: kSecClassGenericPassword, kSecAttrService: service, kSecAttrAccount: account ] as [String: Any]
//        return SecItemDelete(query as CFDictionary)
//    }
//
//    static func saveString(_ value: String, forKey key: String) -> Bool {
//        if let data = value.data(using: .utf8) { return save(key: key, data: data) == noErr }
//        return false
//    }
//
//    static func loadString(forKey key: String) -> String? {
//        if let data = load(key: key) { return String(data: data, encoding: .utf8) }
//        return nil
//    }
//}
//
//// MARK: - Data Models (Unchanged)
//
//enum MessageRole: String, Codable { case user, model }
//
//struct ChatMessage: Identifiable, Equatable, Codable {
//    let id: UUID
//    var role: MessageRole
//    var text: String
//    var timestamp: Date
//    var isLoading: Bool = false
//    var isErrorPlaceholder: Bool = false
//    var formattedTimestamp: String {
//        let formatter = DateFormatter(); formatter.timeStyle = .short; return formatter.string(from: timestamp)
//    }
//}
//
//enum GeminiModel: String, CaseIterable, Identifiable {
//    case flash = "gemini-1.5-flash-latest"; case pro = "gemini-1.5-pro-latest" // Add more if needed
//    var id: String { self.rawValue }
//    var displayName: String { switch self { case .flash: return "Gemini 1.5 Flash"; case .pro: return "Gemini 1.5 Pro"} }
//    var endpointPath: String { "v1beta/models/\(self.rawValue):generateContent" }
//    static let baseApiUrl = "https://generativelanguage.googleapis.com/"
//    var endpointUrlString: String { GeminiModel.baseApiUrl + endpointPath }
//}
//
//// MARK: --- Gemini API Request/Response Models (Unchanged) ---
//
//struct APIRequestBody: Codable {
//    let contents: [Content]; let generationConfig: GenerationConfig?
//    struct Content: Codable { let parts: [Part] }
//    struct Part: Codable { let text: String }
//    struct GenerationConfig: Codable { let temperature: Double? }
//}
//
//struct APIResponseBody: Codable {
//    let candidates: [Candidate]?; let promptFeedback: PromptFeedback?; let error: APIErrorDetail?
//    struct Candidate: Codable { let content: Content?; let finishReason: String?; let index: Int?; let safetyRatings: [SafetyRating]? }
//    struct Content: Codable { let parts: [Part]?; let role: String? }
//    struct Part: Codable { let text: String? }
//    struct PromptFeedback: Codable { let safetyRatings: [SafetyRating]? }
//    struct SafetyRating: Codable { let category: String?; let probability: String? }
//    struct APIErrorDetail: Codable { let code: Int?; let message: String?; let status: String? }
//    func extractText() -> String? {
//        guard let firstCandidate = candidates?.first, let firstPart = firstCandidate.content?.parts?.first, let text = firstPart.text else {
//            return self.error.map { "API Error: \($0.message ?? "Unknown") (\($0.status ?? "N/A"))" }
//        }
//        return self.error == nil ? text : "API Error: \(self.error!.message ?? "Unknown") (\(self.error!.status ?? "N/A"))" // Prioritize error if present
//    }
//}
//
//// MARK: - API Service Layer (Unchanged)
//
//enum APIError: Error, LocalizedError {
//    case invalidURL; case requestFailed(Error); case invalidResponse(statusCode: Int); case decodingError(Error); case noData; case missingApiKey; case apiErrorResponse(message: String)
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL: return "Invalid Gemini API endpoint URL."
//        case .requestFailed(let error): return "Network request failed: \(error.localizedDescription)"
//        case .invalidResponse(let statusCode): return "Invalid server response (Code: \(statusCode)). Check API Key/Endpoint."
//        case .decodingError(let error): return "Failed to decode API response: \(error.localizedDescription)"
//        case .noData: return "No data from API."
//        case .missingApiKey: return ServiceConstants.apiKeyInstructions
//        case .apiErrorResponse(let message): return message
//        }
//    }
//}
//
//protocol ChatAPIService {
//    func generateResponse(for prompt: String, apiKey: String, endpoint: String, temperature: Double?) async throws -> String
//}
//
//class GeminiAPIService: ChatAPIService {
//    private let urlSession: URLSession
//    init(urlSession: URLSession = .shared) { self.urlSession = urlSession }
//
//    func generateResponse(for prompt: String, apiKey: String, endpoint: String, temperature: Double?) async throws -> String {
//        guard !apiKey.isEmpty, apiKey != geminiApiKeyPlaceholder else { throw APIError.missingApiKey }
//        guard var components = URLComponents(string: endpoint) else { throw APIError.invalidURL }
//        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
//        guard let finalUrl = components.url else { throw APIError.invalidURL }
//
//        var request = URLRequest(url: finalUrl); request.httpMethod = "POST"; request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        let generationConfig = temperature.map { APIRequestBody.GenerationConfig(temperature: $0) }
//        let requestBody = APIRequestBody(contents: [.init(parts: [.init(text: prompt)])], generationConfig: generationConfig)
//
//        do { request.httpBody = try JSONEncoder().encode(requestBody) }
//        catch { throw APIError.requestFailed(error) }
//
//        let data: Data; let response: URLResponse
//        do { (data, response) = try await urlSession.data(for: request) }
//        catch { throw APIError.requestFailed(error) }
//
//        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse(statusCode: -1) }
//        guard (200...299).contains(httpResponse.statusCode) else {
//             let errorBody = try? JSONDecoder().decode(APIResponseBody.self, from: data)
//             let apiErrorMsg = errorBody?.error?.message ?? "Unknown error"
//             let statusDesc = errorBody?.error?.status ?? "Status N/A"
//             throw APIError.apiErrorResponse(message: "API Error: \(apiErrorMsg) (Status: \(statusDesc), Code: \(httpResponse.statusCode))")
//        }
//        guard !data.isEmpty else { throw APIError.noData }
//
//        do {
//            let decodedResponse = try JSONDecoder().decode(APIResponseBody.self, from: data)
//             if let errorDetail = decodedResponse.error {
//                 throw APIError.apiErrorResponse(message: "API Error: \(errorDetail.message ?? "Unknown") (\(errorDetail.status ?? "N/A"))")
//             }
//             guard let textResponse = decodedResponse.extractText() else {
//                throw APIError.decodingError(NSError(domain: "GeminiService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not extract text."]))
//             }
//            return textResponse
//        } catch let error as APIError { throw error }
//        catch { throw APIError.decodingError(error) }
//    }
//}
//
//// MARK: - ViewModel (Unchanged)
//
//@MainActor
//class ChatViewModel: ObservableObject {
//    @Published var chatMessages: [ChatMessage] = []; @Published var userInput: String = ""
//    @Published var isProcessing: Bool = false; @Published var errorMessage: String? = nil
//    @Published var isShowingErrorAlert: Bool = false; @Published var isShowingSettings: Bool = false
//    @Published var useMockData: Bool = true; @Published var apiKeyStatusMessage: String = "Not Set"
//    @Published private(set) var storedApiKey: String = ""
//    @AppStorage("geminiModelSelection") var selectedModel: GeminiModel = .flash
//    @AppStorage("geminiTemperature") var temperature: Double = 0.7
//
//    private var cancellables = Set<AnyCancellable>(); private let apiService: ChatAPIService
//    private let apiKeyKeychainKey = KeychainHelper.account
//
//    init(apiService: ChatAPIService = GeminiAPIService()) {
//        self.apiService = apiService; loadInitialMessages(); setupBindings(); loadApiKeyFromKeychain()
//    }
//
//    private func setupBindings() {
//        $errorMessage.compactMap { $0 }.receive(on: DispatchQueue.main).sink { [weak self] _ in self?.isShowingErrorAlert = true }.store(in: &cancellables)
//        $storedApiKey.map { $0.isEmpty ? "Not Set" : "Saved" }.receive(on: DispatchQueue.main).assign(to: &$apiKeyStatusMessage)
//    }
//
//    func loadInitialMessages() {
//        if chatMessages.isEmpty { chatMessages = [ /* Initial messages as before */
//             ChatMessage(id: UUID(), role: .user, text: "Hello Gemini!", timestamp: Date().addingTimeInterval(-120)),
//             ChatMessage(id: UUID(), role: .model, text: "Hi! Toggle Mock/Real. Configure in Settings (⚙️ - Card Style).", timestamp: Date().addingTimeInterval(-110))
//        ]}
//    }
//
//     func sendMessage() {
//         let textToSend = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
//         guard !textToSend.isEmpty, !isProcessing else { return }
//
//         chatMessages.append(ChatMessage(id: UUID(), role: .user, text: textToSend, timestamp: Date()))
//         let loadingMessageId = UUID()
//         chatMessages.append(ChatMessage(id: loadingMessageId, role: .model, text: "...", timestamp: Date(), isLoading: true))
//         userInput = ""; isProcessing = true; errorMessage = nil
//
//         Task {
//             var modelResponseText: String = ""; var isError = false; var errorToShow: String? = nil
//             let currentApiKey = self.storedApiKey; let currentEndpoint = self.selectedModel.endpointUrlString; let currentTemperature = self.temperature
//
//             do {
//                 if useMockData {
//                     try await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_500_000_000))
//                     if textToSend.lowercased().contains("mock error") { throw APIError.requestFailed(NSError(domain: "MockError", code: 500)) }
//                     modelResponseText = "[MOCK] You asked: \(textToSend). Temp ≈ \(String(format:"%.1f", currentTemperature)). Model: \(selectedModel.displayName)"
//                 } else {
//                     guard !currentApiKey.isEmpty else { throw APIError.missingApiKey }
//                     let realResponse = try await apiService.generateResponse(for: textToSend, apiKey: currentApiKey, endpoint: currentEndpoint, temperature: currentTemperature)
//                     modelResponseText = "[REAL] \(realResponse)"
//                 }
//             } catch let error as APIError {
//                 modelResponseText = "Error: \(error.localizedDescription)"; isError = true; errorToShow = error.localizedDescription
//                 if case .missingApiKey = error { errorToShow = ServiceConstants.apiKeyInstructions + "\n\nPlease set it in the Settings." }
//             } catch {
//                 modelResponseText = "Unexpected error: \(error.localizedDescription)"; isError = true; errorToShow = modelResponseText
//             }
//
//             await MainActor.run {
//                 updateOrReplaceMessage(id: loadingMessageId, newText: modelResponseText, isError: isError)
//                 isProcessing = false; self.errorMessage = errorToShow
//             }
//         }
//     }
//
//    private func updateOrReplaceMessage(id: UUID, newText: String, isError: Bool) {
//        if let index = chatMessages.firstIndex(where: { $0.id == id }) {
//            chatMessages[index] = ChatMessage(id: id, role: .model, text: newText, timestamp: Date(), isLoading: false, isErrorPlaceholder: isError)
//        }
//    }
//
//    func saveApiKey(_ key: String) {
//        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
//        if KeychainHelper.saveString(trimmedKey, forKey: apiKeyKeychainKey) { storedApiKey = trimmedKey }
//        else { errorMessage = "Failed to save API Key securely." }
//    }
//
//    func loadApiKeyFromKeychain() { storedApiKey = KeychainHelper.loadString(forKey: apiKeyKeychainKey) ?? "" }
//    func clearApiKey() {
//        if KeychainHelper.delete(key: apiKeyKeychainKey) == noErr { storedApiKey = "" }
//        else { errorMessage = "Failed to clear API Key." }
//    }
//    func clearChatHistory() {
//        chatMessages.removeAll(); chatMessages.append(ChatMessage(id: UUID(), role: .model, text: "Chat history cleared.", timestamp: Date()))
//    }
//    var appVersion: String {
//        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
//        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"; return "\(v) (\(b))"
//    }
//}
//
//// MARK: - SwiftUI Views (Card Design Refactor)
//
//// MARK: -- Main Chat View (Card Design)
//
//struct CardBasedGeminiChatView: View {
//    @StateObject private var viewModel = ChatViewModel()
//
//    var body: some View {
//        ZStack(alignment: .bottom) { // Use ZStack for layering
//            // Background for the whole view
//            Color(.systemGroupedBackground)
//                .ignoresSafeArea()
//
//            // Chat content area
//            VStack(spacing: 0) {
//                if viewModel.chatMessages.isEmpty {
//                    EmptyStateView() // Keep empty state as is, it sits on the background
//                } else {
//                    ChatScrollView(viewModel: viewModel) // Scroll view sits above background
//                }
//                // Add spacing at the bottom to avoid overlap with the input card
//                Spacer(minLength: 100) // Adjust height based on InputAreaView's estimated height
//            }
//
//            // Input Area Card - Floating at the bottom
//            InputAreaView(
//                userInput: $viewModel.userInput,
//                isProcessing: viewModel.isProcessing,
//                placeholder: "Ask Gemini (\(viewModel.useMockData ? "Mock" : "Real"))...",
//                sendMessageAction: viewModel.sendMessage
//            )
//            .padding(.horizontal) // Padding around the card
//            .padding(.bottom, 8) // Padding from the absolute bottom edge
//            .background(.regularMaterial) // Card background (blur material)
//            .clipShape(RoundedRectangle(cornerRadius: StyleConstants.cardCornerRadius * 1.5, style: .continuous)) // Card shape
//            .shadow(color: .black.opacity(0.15), radius: StyleConstants.cardShadowRadius, x: 0, y: 2) // Card shadow
//            .padding(.bottom) // Additional padding to lift above safe area / keyboard avoidance space
//
//        }
//        .navigationTitle("Gemini Chat")
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Toggle(isOn: $viewModel.useMockData) { Text("Mock") }.toggleStyle(.switch).tint(.orange)
//            }
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button { viewModel.isShowingSettings = true } label: { Image(systemName: "gearshape.fill") }
//            }
//        }
//        .sheet(isPresented: $viewModel.isShowingSettings) {
//             // Present Card-Based Settings modally
//             CardBasedSettingsView(viewModel: viewModel)
//        }
//        .alert("Error", isPresented: $viewModel.isShowingErrorAlert, presenting: viewModel.errorMessage) { _ in }
//            message: { errorText in Text(errorText) }
//        .ignoresSafeArea(.keyboard, edges: .bottom) // Allow ZStack content (including input card) to move with keyboard
//        .animation(.default, value: viewModel.chatMessages.count) // Animate overall layout changes slightly
//    }
//}
//
//// MARK: -- Settings View (Card Design)
//
//struct CardBasedSettingsView: View {
//    @ObservedObject var viewModel: ChatViewModel
//    @Environment(\.dismiss) var dismiss
//    @State private var apiKeyInput: String = ""
//    @State private var showClearHistoryAlert = false
//
//    var body: some View {
//        NavigationView {
//            ScrollView { // Use ScrollView instead of Form
//                VStack(alignment: .leading, spacing: StyleConstants.cardExternalVPadding * 2) { // Spacing between cards
//
//                    // --- API Configuration Card ---
//                    CardSection {
//                        VStack(alignment: .leading, spacing: StyleConstants.cardInternalPadding) {
//                            Text("API Configuration").font(.headline).padding(.bottom, 5) // Card Title
//                            HStack {
//                                SecureField("Enter Gemini API Key", text: $apiKeyInput)
//                                    .textContentType(.password)
//                                    .onAppear { apiKeyInput = viewModel.storedApiKey }
//                                Spacer()
//                                Text(viewModel.apiKeyStatusMessage).font(.caption).foregroundColor(.secondary)
//                            }
//                            Button("Save API Key") { viewModel.saveApiKey(apiKeyInput); hideKeyboard() }
//                                .disabled(apiKeyInput.trimmingCharacters(in: .whitespaces).isEmpty)
//                            if !viewModel.storedApiKey.isEmpty {
//                                Button("Clear Saved API Key", role: .destructive) { viewModel.clearApiKey(); apiKeyInput = "" }
//                            }
//                             Divider() // Separate within the card
//                            Picker("Model", selection: $viewModel.selectedModel) {
//                                ForEach(GeminiModel.allCases) { Text($0.displayName).tag($0) }
//                            }
//                            .pickerStyle(.menu)
//                             Divider()
//                            VStack(alignment: .leading, spacing: 5) {
//                                HStack { Text("Temperature"); Spacer(); Text(String(format: "%.2f", viewModel.temperature)).foregroundColor(.secondary) }
//                                Slider(value: $viewModel.temperature, in: 0.0...1.0, step: 0.05)
//                                Text("Lower = predictable, Higher = creative.").font(.caption2).foregroundColor(.gray)
//                            }
//                        }
//                    }
//
//                    // --- Chat Management Card ---
//                    CardSection {
//                        VStack(alignment: .leading, spacing: StyleConstants.cardInternalPadding) {
//                            Text("Chat Management").font(.headline).padding(.bottom, 5)
//                            Button("Clear Chat History", role: .destructive) { showClearHistoryAlert = true }
//                        }
//                    }
//
//                    // --- Information Card ---
//                    CardSection {
//                        VStack(alignment: .leading, spacing: StyleConstants.cardInternalPadding) {
//                             Text("Information").font(.headline).padding(.bottom, 5)
//                             Link("Gemini API Documentation", destination: URL(string: "https://ai.google.dev/docs")!).foregroundColor(.blue)
//                             Link("Privacy Policy (Example)", destination: URL(string: "https://www.example.com/privacy")!).foregroundColor(.blue)
//                             Divider()
//                             HStack { Text("App Version"); Spacer(); Text(viewModel.appVersion).foregroundColor(.secondary) }
//                        }
//                    }
//
//                }
//                .padding() // Padding around the VStack containing all cards
//            }
//            .background(Color(.systemGroupedBackground).ignoresSafeArea()) // Background for the ScrollView
//            .navigationTitle("Settings")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() } } }
//            .alert("Clear History?", isPresented: $showClearHistoryAlert) {
//                 Button("Cancel", role: .cancel) { }; Button("Clear", role: .destructive) { viewModel.clearChatHistory() }
//            } message: { Text("Are you sure you want to permanently delete all messages?") }
//        }
//    }
//
//     private func hideKeyboard() {
//         UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//     }
//}
//
//// Helper View for Card Styling in Settings
//struct CardSection<Content: View>: View {
//     let content: Content
//
//     init(@ViewBuilder content: () -> Content) {
//         self.content = content()
//     }
//
//     var body: some View {
//         VStack(alignment: .leading) { // Ensure content aligns left
//             content
//                 .padding(StyleConstants.cardInternalPadding) // Padding inside the card
//          }
//          .frame(maxWidth: .infinity, alignment: .leading) // Make card take full width
//          .background(Color(.secondarySystemGroupedBackground)) // Card background
//          .cornerRadius(StyleConstants.cardCornerRadius)
//          // Optional: Add a subtle border
//          // .overlay(
//          //     RoundedRectangle(cornerRadius: StyleConstants.cardCornerRadius)
//          //         .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//          // )
//     }
//}
//
//
//// MARK: -- Other UI Views (Empty State, ScrollView, Bubble, Indicator, Input - InputAreaView modified for card context)
//
//struct EmptyStateView: View { // Unchanged - sits on main background
//    var body: some View {
//        VStack(spacing: 15) {
//            Spacer()
//            Image(systemName: "sparkles.message.fill").font(.system(size: 60)).foregroundColor(.purple.opacity(0.8))
//            Text("Gemini Chat Ready").font(.title2.weight(.medium))
//            Text("Enter your prompt below.\nToggle Mock/Real or visit Settings (⚙️).").font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center).padding(.horizontal, 40)
//            Spacer(); Spacer()
//        }.frame(maxWidth: .infinity, maxHeight: .infinity)
//    }
//}
//
//struct ChatScrollView: View { // Largely unchanged, bubbles are the content
//    @ObservedObject var viewModel: ChatViewModel
//
//    var body: some View {
//        ScrollViewReader { scrollViewProxy in
//            ScrollView {
//                LazyVStack(alignment: .leading, spacing: StyleConstants.verticalPadding) {
//                    ForEach(viewModel.chatMessages) { message in MessageBubbleView(message: message).id(message.id) }
//                }
//                .padding(.horizontal, StyleConstants.horizontalPadding)
//                .padding(.vertical, StyleConstants.verticalPadding) // Padding inside scroll content
//            }
//             // Give scroll view a transparent background so the main view's background shows through
//             .background(Color.clear)
//             .onChange(of: viewModel.chatMessages.count) { _,_ in if let lastId = viewModel.chatMessages.last?.id { scrollToBottom(proxy: scrollViewProxy, targetId: lastId) } }
//             .onAppear { if let lastId = viewModel.chatMessages.last?.id { scrollToBottom(proxy: scrollViewProxy, targetId: lastId, animated: false) } }
//        }
//    }
//
//    private func scrollToBottom(proxy: ScrollViewProxy, targetId: UUID, animated: Bool = true) {
//        DispatchQueue.main.async {
//            if animated { withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { proxy.scrollTo(targetId, anchor: .bottom) } }
//            else { proxy.scrollTo(targetId, anchor: .bottom) }
//        }
//    }
//}
//
//struct MessageBubbleView: View { // Unchanged - Standard bubble style
//    let message: ChatMessage
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 5) {
//            if message.role == .user { Spacer(minLength: 50) }
//            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
//                messageContent
//                    .padding(.vertical, 10).padding(.horizontal, 14)
//                    .background(bubbleBackground)
//                    .foregroundColor(foregroundColor)
//                    .clipShape(RoundedRectangle(cornerRadius: StyleConstants.bubbleCornerRadius, style: .continuous))
//                    .shadow(color: .black.opacity(message.role == .user ? 0.1 : 0.05), radius: 2, x: 1, y: 1)
//                    .contextMenu { copyAction }
//                    .transition(.scale(scale: 0.9, anchor: message.role == .user ? .bottomTrailing : .bottomLeading).combined(with: .opacity))
//
//                Text(message.formattedTimestamp).font(.system(size: StyleConstants.timestampFontSize)).foregroundColor(.gray).padding(.horizontal, 5)
//            }
//            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.role == .user ? .trailing : .leading)
//            if message.role == .model { Spacer(minLength: 50) }
//        }
//         .animation(.spring(response: 0.35, dampingFraction: 0.75), value: message.id)
//         .padding(.bottom, 3)
//    }
//
//    @ViewBuilder private var messageContent: some View { /* ... unchanged ... */
//        if message.isLoading { TypingIndicatorView().padding(.vertical, 5).transition(.opacity) }
//        else { Text(LocalizedStringKey(message.text))
//                .font(message.isErrorPlaceholder ? .system(.body, design: .monospaced) : .body)
//                .foregroundColor(message.isErrorPlaceholder ? .red : foregroundColor)
//                .multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true).textSelection(.enabled)
//        }
//    }
//    @ViewBuilder private var copyAction: some View { /* ... unchanged ... */
//        if !message.isLoading && !message.text.isEmpty && !message.isErrorPlaceholder { Button {
//                let textToCopy = message.text.replacingOccurrences(of: "[REAL] ", with: "").replacingOccurrences(of: "[MOCK] ", with: "")
//                UIPasteboard.general.string = textToCopy
//            } label: { Label("Copy Text", systemImage: "doc.on.doc") }
//        }
//    }
//    private var bubbleBackground: Color { /* ... unchanged ... */
//         if message.isErrorPlaceholder { return Color.red.opacity(0.15) }
//         return message.role == .user ? .blue : Color(.systemGray5)
//    }
//    private var foregroundColor: Color { /* ... unchanged ... */
//         if message.isErrorPlaceholder { return .primary } // Let error handling dictate color
//         return message.role == .user ? .white : .primary
//    }
//}
//
//struct TypingIndicatorView: View { // Unchanged
//    @State private var scale: CGFloat = 0.5; let dotCount = 3; let animationDuration = 0.6
//    var body: some View {
//        HStack(spacing: 5) { ForEach(0..<dotCount, id: \.self) { i in
//                Circle().frame(width: 7, height: 7).scaleEffect(scale)
//                    .animation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)
//                           .delay(animationDuration / Double(dotCount + 1) * Double(i)), value: scale)
//        } }.onAppear { scale = 1.0 }.padding(.horizontal, 5)
//    }
//}
//
//struct InputAreaView: View { // Modified slightly for Card Context
//    @Binding var userInput: String
//    let isProcessing: Bool
//    let placeholder: String
//    let sendMessageAction: () -> Void
//    @FocusState private var isTextFieldFocused: Bool
//
//    var body: some View {
//        // This HStack is now the *content* of the card,
//        // padding/background/shadow are applied in CardBasedGeminiChatView
//        HStack(spacing: 10) {
//            ZStack(alignment: .trailing) {
//                 TextEditor(text: $userInput)
//                     .focused($isTextFieldFocused)
//                     .frame(minHeight: 36, maxHeight: 120)
//                     .padding(.leading, 10).padding(.trailing, 35) // Inner padding
//                     .background(Color(.systemBackground)) // Input field background contrast
//                     .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//                     .overlay( userInput.isEmpty ? Text(placeholder).foregroundColor(Color(.placeholderText))
//                         .padding(.leading, 14).padding(.top, 8) : nil, alignment: .topLeading )
//
//                if !userInput.isEmpty { // Clear button
//                    Button { userInput = "" } label: { Image(systemName: "xmark.circle.fill").foregroundColor(.secondary.opacity(0.7)) }
//                    .padding(.trailing, 8).padding(.top, 8).transition(.opacity.combined(with: .scale(scale: 0.8)))
//                }
//            }
//            .animation(.easeInOut(duration: 0.15), value: userInput.isEmpty)
//
//            Button { // Send button
//                sendMessageAction(); isTextFieldFocused = false
//            } label: {
//                Group { if isProcessing { ProgressView().tint(.white).frame(width: 30, height: 30) } else { Image(systemName: "arrow.up").font(.system(size: 16, weight: .semibold)).foregroundColor(.white).frame(width: 30, height: 30).background(Circle().fill(isSendButtonEnabled ? Color.blue : Color.gray.opacity(0.5))) } }
//            }
//            .disabled(!isSendButtonEnabled || isProcessing)
//            .animation(.easeInOut(duration: 0.2), value: isProcessing)
//            .animation(.easeInOut(duration: 0.2), value: isSendButtonEnabled)
//            .keyboardShortcut(.defaultAction).keyboardShortcut(.return, modifiers: .command)
//            .sensoryFeedback(.impact(weight: .medium), trigger: isProcessing && isSendButtonEnabled)
//
//        }
//        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)) // Padding *inside* the card material background
//         // Note: Background/Radius/Shadow applied externally where this view is used for the card effect
//    }
//    private var isSendButtonEnabled: Bool { !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
//}
//
//// MARK: - Preview Providers (Updated for Card View Names)
//
//#Preview("Chat View - Card Design") {
//    NavigationView { CardBasedGeminiChatView() }
//}
//
////#Preview("Chat View - Empty Card Design") {
////     NavigationView {
////         CardBasedGeminiChatView(viewModel: ChatViewModel(messages: [], apiService: GeminiAPIService()))
////     }
////}
//
//#Preview("Settings View - Card Design") {
//    CardBasedSettingsView(viewModel: ChatViewModel()) // Use a fresh ViewModel for preview
//}
//
//// MARK: - Helper Extensions (Unchanged)
//
//extension ChatViewModel {
//    convenience init(messages: [ChatMessage], apiService: ChatAPIService = GeminiAPIService()) {
//        self.init(apiService: apiService); self.chatMessages = messages
//    }
//}
