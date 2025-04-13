////
////  WebSearchWorkflowDemoView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/13/25.
////
//
//import Foundation
//
//// MARK: - Request Body Model
//struct OpenAIRequest: Codable {
//    let model: String
//    let tools: [Tool]
//    let input: String
//
//    struct Tool: Codable {
//        let type: String
//    }
//}
//
//// MARK: - Response Body Models (Partial)
//struct OpenAIResponse: Codable {
//    let output: [OutputItem]?
//    let error: OpenAIError?
//}
//
//struct OutputItem: Codable {
//    let id: String
//    let type: String
//    let status: String
//    let content: [ContentItem]?
//    let role: String?
//}
//
//struct ContentItem: Codable {
//    let type: String
//    let text: String?
//    // Ignoring annotations for simplicity
//}
//
//struct OpenAIError: Codable {
//    let code: String?
//    let message: String
//    let param: String?
//    let type: String?
//}
//
//// MARK: - History Item Model
//struct HistoryItem: Identifiable, Hashable { // Identifiable for Lists, Hashable for potential future use
//    let id = UUID()
//    let prompt: String
//    let timestamp: Date = Date() // Record when the prompt was run
//
//    // Formatter for display
//    static let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        formatter.timeStyle = .short
//        return formatter
//    }()
//
//    var displayTimestamp: String {
//        HistoryItem.dateFormatter.string(from: timestamp)
//    }
//}
//
//// MARK: - Fetch State Enum
//// To manage UI states more cleanly
//enum FetchState {
//    case idle // Nothing fetched yet, or after clearing
//    case loading // Currently fetching data
//    case success(response: String) // Got a successful response
//    case error(message: String) // An error occurred
//}
//
//
//
//import Foundation
//
//class OpenAIService {
//
//    // --- IMPORTANT: API KEY HANDLING ---
//    // NEVER embed your API key directly in code for production apps.
//    // Use secure methods like:
//    // 1. Reading from Info.plist (add a key like OPENAI_API_KEY)
//    // 2. Using .xcconfig files
//    // 3. Fetching from a secure backend/keychain
//    // For this example, we'll read from Info.plist (You MUST add the key there)
//    private var apiKey: String {
//        guard let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String, !key.isEmpty else {
//            fatalError("Add your OPENAI_API_KEY to Info.plist") // Crash if not set
//        }
//        // Basic check - replace "YOUR_API_KEY_HERE" if using a placeholder in Info.plist
//        if key == "YOUR_API_KEY_HERE" {
//             fatalError("Replace 'YOUR_API_KEY_HERE' in Info.plist with your actual OpenAI API Key")
//        }
//        return key
//    }
//
//    private let apiURL = URL(string: "https://api.openai.com/v1/responses")! // Corrected endpoint if needed
//
//    func fetchPositiveNews(prompt: String) async throws -> String {
//
//        var request = URLRequest(url: apiURL)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization") // Use fetched API Key
//        request.setValue("OpenAI-Beta", forHTTPHeaderField: "OpenAI-Beta") // May be required for some features
//        request.setValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta") // Example header, adjust if needed
//
//        // Prepare the request body (Ensure model and tools are correct for your API version/access)
//        let requestBody = OpenAIRequest(
//            model: "gpt-4o", // Or the desired model
//            tools: [OpenAIRequest.Tool(type: "web_search_preview")], // Or other tools like "code_interpreter"
//            input: prompt
//        )
//
//        do {
//            let encoder = JSONEncoder()
//            request.httpBody = try encoder.encode(requestBody)
//        } catch {
//            print("❌ Failed to encode request body: \(error)")
//            throw URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request body: \(error.localizedDescription)"])
//        }
//
//        // Perform the network request
//        print("🚀 Sending Request: \(request)")
//        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
//             print("📬 Request Body: \(bodyString)")
//        }
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//
//        // Check HTTP status code
//        guard let httpResponse = response as? HTTPURLResponse else {
//            print("❌ Invalid response type.")
//            throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server."])
//        }
//
//        print("🚦 HTTP Status Code: \(httpResponse.statusCode)")
//        if let responseString = String(data: data, encoding: .utf8) {
//            print("📄 Raw Response Data:\n\(responseString)") // Log raw response always
//        }
//
//        guard (200...299).contains(httpResponse.statusCode) else {
//            print("❌ Server returned status code \(httpResponse.statusCode).")
//            // Try to decode OpenAI's error structure if status code is bad
//             if let apiError = try? JSONDecoder().decode(OpenAIResponse.self, from: data).error {
//                  print("💀 API Error: \(apiError.message)")
//                  throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "API Error: \(apiError.message) (Code: \(apiError.code ?? "N/A"))"])
//             } else {
//                  // Generic error if decoding fails
//                  throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Server returned status code \(httpResponse.statusCode). Unable to decode specific error."])
//             }
//        }
//
//        // Decode the successful response
//        do {
//            let decoder = JSONDecoder()
//            let decodedResponse = try decoder.decode(OpenAIResponse.self, from: data)
//            print("✅ Successfully decoded response.")
//
//            // Find the message output - Adjust logic based on actual API response structure
//            guard let messageOutput = decodedResponse.output?.first(where: { $0.type == "message" || $0.type == "text" /* Check multiple types if needed */ }),
//                  let content = messageOutput.content?.first(where: { $0.type == "output_text" || $0.type == "text" }),
//                  let text = content.text else {
//                print("❌ Could not find expected text content structure in the response.")
//                // If text is missing, check for other content types or log the entire output for debugging
//                if let outputDump = decodedResponse.output {
//                    print("🔍 Output structure dump: \(outputDump)")
//                }
//                throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Could not find expected text content in the API response structure."])
//            }
//            print("📰 Fetched Text: \(text)")
//            return text
//
//        } catch let decodingError as DecodingError {
//            // Provide detailed decoding error information
//            print("❌ Failed to decode response: \(decodingError)")
//            switch decodingError {
//            case .typeMismatch(let type, let context):
//                print("   Type mismatch for type \(type) in context: \(context.codingPath) - \(context.debugDescription)")
//            case .valueNotFound(let type, let context):
//                print("   Value not found for type \(type) in context: \(context.codingPath) - \(context.debugDescription)")
//            case .keyNotFound(let key, let context):
//                print("   Key not found: \(key) in context: \(context.codingPath) - \(context.debugDescription)")
//            case .dataCorrupted(let context):
//                print("   Data corrupted in context: \(context.codingPath) - \(context.debugDescription)")
//            @unknown default:
//                print("   Unknown decoding error.")
//            }
//             throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(decodingError.localizedDescription)."])
//        } catch {
//            print("❌ An unexpected error occurred during decoding: \(error)")
//            throw URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response: \(error.localizedDescription)."])
//        }
//    }
//}
//
//
//import SwiftUI
//
//struct ContentView: View {
//    // MARK: - State Variables
//    @State private var currentPrompt: String = "Tell me a positive news story from this week."
//    @State private var fetchState: FetchState = .idle
//    @State private var history: [HistoryItem] = [ // Add some mock history for demo
//        HistoryItem(prompt: "Any good news about space exploration lately?"),
//        HistoryItem(prompt: "Positive developments in renewable energy?")
//    ]
//    @State private var showingShareSheet = false
//    @State private var sharedText: String = ""
//
//    // Use FocusState for keyboard management
//    @FocusState private var promptFieldIsFocused: Bool
//
//    private let apiService = OpenAIService()
//
//    // MARK: - Body
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) { // Use zero spacing for tighter control with dividers/padding
//                // Input Area
//                inputSection
//                    .padding(.horizontal)
//                    .padding(.top) // Add padding only at the top
//
//                Divider() // Visually separate input from content
//
//                // Content Area (Response or History/Placeholder)
//                contentSection
//            }
//            .navigationTitle("Good News Bot")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar { // Add a Clear History button to the toolbar
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    if !history.isEmpty {
//                        Button {
//                           clearHistory()
//                        } label: {
//                           Label("Clear History", systemImage: "trash")
//                        }
//                        .tint(.red) // Make the clear button red
//                    }
//                }
//            }
//            .contentShape(Rectangle()) // Makes the whole background tappable
//            .onTapGesture {
//                dismissKeyboard() // Dismiss keyboard when tapping background
//            }
//            // Share Sheet Presentation
//            .sheet(isPresented: $showingShareSheet) {
//                ShareSheet(activityItems: [sharedText])
//            }
//        }
//        // Use .id with NavigationStack for more robust state management if needed later
//        // But NavigationView is fine for this level of complexity
//    }
//
//    // MARK: - UI Sections
//
//    /// Input field and send/clear buttons
//    private var inputSection: some View {
//        HStack(alignment: .bottom, spacing: 8) {
//            // Use a taller TextField for potentially longer prompts
//            TextField("Enter your prompt", text: $currentPrompt, axis: .vertical)
//                .textFieldStyle(.plain) // Use plain style for better embedding
//                .padding(8) // Internal padding
//                .background(Color(.systemGray6)) // Subtle background
//                .clipShape(RoundedRectangle(cornerRadius: 8))
//                .focused($promptFieldIsFocused) // Bind focus state
//                .lineLimit(1...5) // Allow moderate expansion
//                .accessibilityLabel("Prompt Input Field")
//
//            // Clear Button - Appears only if text exists
//            if !currentPrompt.isEmpty {
//                Button {
//                    clearPrompt()
//                } label: {
//                    Image(systemName: "xmark.circle.fill")
//                        .font(.title2)
//                        .foregroundColor(.gray)
//                }
//                .accessibilityLabel("Clear Prompt Button")
//            }
//
//            // Send Button
//            Button {
//                initiateFetch()
//            } label: {
//                Image(systemName: "paperplane.fill")
//                    .font(.title2) // Slightly larger icon
//            }
//            .buttonStyle(.borderedProminent)
//            .disabled(isFetchButtonDisabled) // Disable based on state/prompt
//            .animation(.easeInOut, value: isFetchButtonDisabled) // Animate disabled state
//            .accessibilityLabel("Send Prompt Button")
//        }
//    }
//
//    /// Dynamic content area showing History, Placeholder, Loading, Error, or Success views
//    private var contentSection: some View {
//        Group { // Use Group to switch content easily
//            switch fetchState {
//            case .idle:
//                 // Show History if available, otherwise a placeholder
//                 if history.isEmpty {
//                      placeholderView(text: "Enter a prompt and tap send to get positive news!\n\nOr try a previous prompt from your history.")
//                 } else {
//                      historyListView
//                 }
//            case .loading:
//                loadingView
//            case .success(let response):
//                successView(response: response)
//            case .error(let message):
//                errorView(message: message)
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity) // Allow content to expand
//    }
//
//    // MARK: - State-Specific Views
//
//    /// View to display when loading data
//    private var loadingView: some View {
//        VStack(spacing: 10) {
//            ProgressView()
//                .scaleEffect(1.5) // Make spinner larger
//                .padding(.bottom, 10)
//            Text("Fetching good news...")
//                .font(.headline)
//                .foregroundColor(.secondary)
//        }
//    }
//
//    /// View to display a successful response
//    private func successView(response: String) -> some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 15) {
//                 // Displayed Prompt
//                 VStack(alignment: .leading) {
//                      Text("Your Prompt:")
//                          .font(.caption)
//                          .foregroundStyle(.secondary)
//                      Text(currentPrompt)
//                          .font(.body)
//                          .italic()
//                          .padding(.leading, 5) // Indent prompt slightly
//                 }
//
//                 Divider()
//
//                // Response Text Card (Similar to previous version but enhanced)
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("Positive News")
//                        .font(.title3)
//                        .fontWeight(.semibold)
//
//                    // Use AttributedString for potential Markdown
//                    Text(.init(response)) // .init() attempts Markdown parsing
//                        .font(.body)
//                        .lineSpacing(5)
//                        .frame(maxWidth: .infinity, alignment: .leading) // Ensure text fills width
//                        // Enable text selection
//                        .textSelection(.enabled)
//
//                    // Simulated source attribution (Optional)
//                    HStack {
//                         Spacer()
//                         Text("Source: AI Interpretation (Simulated)")
//                               .font(.caption2)
//                               .foregroundColor(.gray)
//                               .italic()
//                    }
//                }
//                .padding()
//                .background(Color(.secondarySystemBackground))
//                .cornerRadius(12)
//                .shadow(color: .gray.opacity(0.2), radius: 3, x: 0, y: 1)
//
//                // Action Buttons
//                HStack {
//                    Spacer()
//                    Button {
//                        sharedText = response // Set text to share
//                        showingShareSheet = true
//                    } label: {
//                        Label("Share", systemImage: "square.and.arrow.up")
//                    }
//                    .buttonStyle(.bordered)
//                    .accessibilityLabel("Share News Button")
//                }
//                .padding(.top, 5)
//
//            }
//            .padding() // Outer padding for the ScrollView content
//        }
//    }
//
//    /// View to display when an error occurs
//    private func errorView(message: String) -> some View {
//        VStack(spacing: 15) {
//            Image(systemName: "exclamationmark.triangle.fill")
//                .font(.largeTitle)
//                .foregroundColor(.red)
//            Text("An Error Occurred")
//                .font(.title2)
//                .fontWeight(.semibold)
//            Text(message)
//                .font(.callout)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//
//            Button {
//                initiateFetch() // Retry with the same prompt
//            } label: {
//                Label("Retry", systemImage: "arrow.clockwise")
//            }
//            .buttonStyle(.borderedProminent)
//            .padding(.top, 10)
//            .accessibilityLabel("Retry Fetch Button")
//        }
//        .padding()
//    }
//
//    /// View for the initial state or when history is empty
//    private func placeholderView(text: String) -> some View {
//        VStack(spacing: 10) {
//            Image(systemName: "sparkles.square.filled.on.square")
//                .font(.system(size: 60))
//                .foregroundColor(.secondary.opacity(0.7))
//            Text(text)
//                .font(.headline)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 40)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity) // Center vertically
//    }
//
//    // MARK: - History List View
//    private var historyListView: some View {
//        List {
//            Section("History") { // Use Section for clearer grouping
//                // Display history in reverse chronological order
//                ForEach(history.sorted(by: { $0.timestamp > $1.timestamp })) { item in
//                    HStack {
//                        VStack(alignment: .leading) {
//                            Text(item.prompt)
//                                 .lineLimit(2) // Limit prompt lines shown in list
//                            Text(item.displayTimestamp)
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                        Spacer() // Push arrow to the right
//                        Image(systemName: "chevron.right")
//                           .foregroundColor(.secondary)
//                    }
//                    .contentShape(Rectangle()) // Make entire row tappable
//                    .onTapGesture {
//                        // Load prompt from history and fetch again
//                        currentPrompt = item.prompt
//                        initiateFetch()
//                    }
//                    .accessibilityElement(children: .combine) // Combine elements for VoiceOver
//                    .accessibilityLabel("History Item: \(item.prompt), \(item.displayTimestamp)")
//                    .accessibilityHint("Tap to re-run this prompt")
//                }
//                .onDelete(perform: deleteHistoryItem) // Allow swiping to delete
//            }
//        }
//        .listStyle(.plain) // Use plain style for seamless integration
//    }
//
//    // MARK: - Computed Properties
//
//    /// Determines if the send button should be disabled
//    private var isFetchButtonDisabled: Bool {
//        if case .loading = fetchState { return true } // Disable when loading
//        return currentPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty // Disable if prompt is empty
//    }
//
//    // MARK: - Functions
//
//    /// Dismisses the keyboard
//    private func dismissKeyboard() {
//        promptFieldIsFocused = false
//    }
//
//    /// Clears the current prompt input
//    private func clearPrompt() {
//        currentPrompt = ""
//        fetchState = .idle // Reset state when prompt is cleared
//        promptFieldIsFocused = true // Keep focus for easy typing
//    }
//
//    /// Starts the API fetch process
//    private func initiateFetch() {
//        dismissKeyboard() // Dismiss keyboard before fetching
//
//        let trimmedPrompt = currentPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedPrompt.isEmpty else { return } // Don't fetch if empty
//
//        fetchState = .loading // Set state to loading
//
//        Task {
//            do {
//                let result = try await apiService.fetchPositiveNews(prompt: trimmedPrompt)
//                fetchState = .success(response: result)
//                // Add to history ONLY on success
//                addHistoryItem(prompt: trimmedPrompt)
//            } catch {
//                 fetchState = .error(message: error.localizedDescription)
//            }
//        }
//    }
//
//    /// Adds a new item to the history (non-persistent)
//    private func addHistoryItem(prompt: String) {
//        // Avoid adding exact duplicates consecutively
//        if let lastItem = history.last, lastItem.prompt == prompt {
//            return
//        }
//        let newItem = HistoryItem(prompt: prompt)
//        history.append(newItem)
//
//        // Optional: Limit history size (e.g., keep last 20 items)
//         if history.count > 20 {
//            history.removeFirst(history.count - 20)
//         }
//    }
//
//     /// Clears the history list
//    private func clearHistory() {
//        history.removeAll()
//        // Optionally, reset the fetch state if clearing history should clear the main view
//        if case .idle = fetchState {
//             // Don't change if loading/error/success is showing
//        } else {
//            fetchState = .idle
//        }
//
//    }
//
//    /// Deletes a specific history item (used by swipe-to-delete)
//    private func deleteHistoryItem(at offsets: IndexSet) {
//         // Must map offsets to the sorted array used in ForEach
//         let sortedHistory = history.sorted(by: { $0.timestamp > $1.timestamp })
//         let originalIndicesToDelete = offsets.map { offset in
//             // Find the corresponding item in the original unsorted history array
//             history.firstIndex(of: sortedHistory[offset])!
//         }
//         // Perform deletion on the original array using the found indices
//         history.remove(atOffsets: IndexSet(originalIndicesToDelete))
//    }
//}
//
//// MARK: - Share Sheet Helper
//// Simple wrapper for UIActivityViewController
//struct ShareSheet: UIViewControllerRepresentable {
//    var activityItems: [Any]
//    var applicationActivities: [UIActivity]? = nil
//
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
//        // No update needed
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    ContentView()
//}
//
//
