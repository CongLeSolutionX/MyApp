//
//  OpenAIModelsCardView_V5.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI
import Foundation // Needed for URLSession, URLRequest, etc.

// MARK: - Enums

// Enum for Sorting Options
enum SortOption: String, CaseIterable, Identifiable {
    case idAscending = "ID (A-Z)"
    case idDescending = "ID (Z-A)"
    case dateNewest = "Date (Newest)"
    case dateOldest = "Date (Oldest)"

    var id: String { self.rawValue } // For Identifiable conformance
}

// Optional: Define mock errors if needed
enum MockError: Error, LocalizedError {
     case simulatedFetchError
     var errorDescription: String? {
         switch self {
         case .simulatedFetchError:
             return "Simulated network error: Could not fetch models."
         }
     }
}

// Errors specific to the Live API Service
enum LiveAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int)
    case networkError(Error)
    case decodingError(Error)
    case missingAPIKey

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The API endpoint URL is invalid."
        case .requestFailed(let statusCode): return "API request failed with status code \(statusCode)."
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .decodingError(let error): return "Failed to decode API response: \(error.localizedDescription)"
        case .missingAPIKey: return "OpenAI API Key is missing or invalid. Please provide a valid key."
        }
    }
}

// MARK: - API Service Protocol

protocol APIServiceProtocol {
    func fetchModels() async throws -> [OpenAIModel]
}

// MARK: - Data Models

struct ModelListResponse: Codable {
    let data: [OpenAIModel]
}

struct OpenAIModel: Codable, Identifiable, Hashable {
    let id: String
    let object: String
    let created: Int // Unix timestamp
    let ownedBy: String

    // Keep these for detail view consistency; they won't be decoded from live /v1/models
    // They will retain their default values when decoding live data if not present in JSON.
    var description: String = "No description available."
    var capabilities: [String] = ["general"]
    var contextWindow: String = "N/A"
    var typicalUseCases: [String] = ["Various tasks"]

    // Conform to Codable (custom key mapping for 'owned_by')
    // NOTE: description, capabilities, contextWindow, typicalUseCases
    // are NOT listed here, so Codable ignores them when decoding JSON.
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case ownedBy = "owned_by" // Map JSON key 'owned_by' to Swift 'ownedBy'
    }

    // Computed property for easy date access
    var createdDate: Date {
        Date(timeIntervalSince1970: TimeInterval(created))
    }

    // Hashable conformance (based on unique ID)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: OpenAIModel, rhs: OpenAIModel) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Model Extension for UI

extension OpenAIModel {
    // Determine the SF Symbol name based on the owner
    var profileSymbolName: String {
        let lowerOwner = ownedBy.lowercased()
        if lowerOwner.contains("openai") { return "building.columns.fill" }
        if lowerOwner == "system" { return "gearshape.fill" }
        if lowerOwner.contains("user") || lowerOwner.contains("org") { return "person.crop.circle.fill" }
        return "questionmark.circle.fill" // Default/fallback
    }

    // Determine the background color for the profile image view
    var profileBackgroundColor: Color {
        let lowerOwner = ownedBy.lowercased()
        if lowerOwner.contains("openai") { return .blue }
        if lowerOwner == "system" { return .orange }
        if lowerOwner.contains("user") || lowerOwner.contains("org") { return .purple }
        return .gray // Default/fallback
    }
}

// MARK: - API Service Implementations

// --- Mock Data Service ---
class MockAPIService: APIServiceProtocol { // Conform to the protocol
    // Simulate network delay
    private let mockNetworkDelaySeconds: Double = 0.8

    // Predefined mock models
    private func generateMockModels() -> [OpenAIModel] {
        return [
            OpenAIModel(id: "gpt-4-turbo", object: "model", created: 1712602800, ownedBy: "openai", description: "Our most capable and recent GPT-4 model.", capabilities: ["text generation", "code completion", "reasoning"], contextWindow: "128k", typicalUseCases: ["Complex chat", "Content generation", "Code assistance"]),
            OpenAIModel(id: "gpt-3.5-turbo-instruct", object: "model", created: 1694022000, ownedBy: "openai", description: "Instruct-tuned version of GPT-3.5.", capabilities: ["text generation", "instruction following"], contextWindow: "4k", typicalUseCases: ["Direct instruction tasks", "Simple Q&A"]),
            OpenAIModel(id: "dall-e-3", object: "model", created: 1700000000, ownedBy: "openai", description: "Advanced image generation model.", capabilities: ["image generation", "text-to-image"], contextWindow: "N/A", typicalUseCases: ["Art creation", "Product visualization"]),
            OpenAIModel(id: "whisper-1", object: "model", created: 1677600000, ownedBy: "openai", description: "Speech-to-text model.", capabilities: ["audio transcription", "translation"], contextWindow: "N/A", typicalUseCases: ["Meeting transcriptions", "Voice commands"]),
            OpenAIModel(id: "babbage-002", object: "model", created: 1692902400, ownedBy: "openai", description: "Older generation model, faster but less capable.", capabilities: ["text generation"], contextWindow: "4k", typicalUseCases: ["Simple text classification", "Drafting"]),
            OpenAIModel(id: "text-embedding-3-large", object: "model", created: 1711300000, ownedBy: "openai", description: "Large text embedding model.", capabilities: ["text embedding", "semantic search"], contextWindow: "8k", typicalUseCases: ["Recommendation systems", "Clustering"]),
            OpenAIModel(id: "text-moderation-stable", object: "model", created: 1677600000, ownedBy: "openai-internal", description: "Model for content moderation tasks.", capabilities: ["content filtering", "policy enforcement"], contextWindow: "N/A", typicalUseCases: ["Community guideline checking", "Safety filtering"]),
            OpenAIModel(id: "my-custom-finetune-model-abc", object: "model", created: 1710000000, ownedBy: "user-org-123", description: "A fine-tuned model based on gpt-3.5 for specific tasks.", capabilities: ["text generation", "domain-specific-knowledge"], contextWindow: "4k", typicalUseCases: ["Customer support bot", "Internal knowledge base Q&A"]),
            OpenAIModel(id: "system-default-v1", object: "model", created: 1660000000, ownedBy: "system", description: "Internal system model.", capabilities: ["internal processing"], contextWindow: "N/A", typicalUseCases: ["System tasks"])
        ]
    }

    func fetchModels() async throws -> [OpenAIModel] {
         // Simulate network delay
         try? await Task.sleep(for: .seconds(mockNetworkDelaySeconds))
         // Return the structured mock data
         return generateMockModels()
         // ---- To simulate an error uncomment below ----
         // throw MockError.simulatedFetchError
         // -------------------------------------------
    }
}

// --- Live Data Service ---
class LiveAPIService: APIServiceProtocol {

    // !!! IMPORTANT: Replace with your actual OpenAI API Key !!!
    // !!! DO NOT COMMIT THIS KEY TO VERSION CONTROL !!!
    // Consider using Environment Variables, a configuration file,
    // or a secrets management system in a real app.
    private let apiKey = "YOUR_OPENAI_API_KEY_HERE" // <-- Replace or load securely

    private let modelsURL = URL(string: "https://api.openai.com/v1/models")!

    func fetchModels() async throws -> [OpenAIModel] {
        // Basic check for placeholder/empty key
        guard !apiKey.isEmpty, apiKey != "YOUR_OPENAI_API_KEY_HERE" else {
            print("❌ ERROR: OpenAI API Key is missing or is the placeholder.")
            throw LiveAPIError.missingAPIKey
        }

        var request = URLRequest(url: modelsURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        print("🚀 Making live API request to: \(modelsURL)")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                // Should ideally not happen with http requests, but handle defensively
                throw LiveAPIError.requestFailed(statusCode: 0)
            }

            print("✅ Received API response with status code: \(httpResponse.statusCode)")

            guard (200...299).contains(httpResponse.statusCode) else {
                 // Optional: Try to decode error message from OpenAI if available
                 // let errorBody = String(data: data, encoding: .utf8)
                 // print("API Error Body: \(errorBody ?? "N/A")")
                 throw LiveAPIError.requestFailed(statusCode: httpResponse.statusCode)
            }

            do {
                 let decoder = JSONDecoder()
                 // No need for custom date decoding if 'created' stays Int
                 let responseWrapper = try decoder.decode(ModelListResponse.self, from: data)
                 print("✅ Successfully decoded \(responseWrapper.data.count) models.")
                 return responseWrapper.data
            } catch {
                 print("❌ Decoding Error: \(error)")
                 throw LiveAPIError.decodingError(error)
            }
        } catch let error as LiveAPIError {
            print("❌ API Error: \(error.localizedDescription)")
            throw error // Re-throw known API errors
        } catch {
            print("❌ Network/URLSession Error: \(error)")
            throw LiveAPIError.networkError(error) // Wrap other errors
        }
    }
}


// MARK: - Reusable SwiftUI Helper Views

// --- Card View ---
struct ModelCardView: View {
    let model: OpenAIModel

    var body: some View {
        HStack(spacing: 15) {
            // Profile Image View
            Image(systemName: model.profileSymbolName)
                .resizable()
                .scaledToFit()
                .padding(8) // Padding inside the circle
                .frame(width: 44, height: 44) // Fixed size for the image container
                .background(model.profileBackgroundColor.opacity(0.85)) // Use model's color
                .foregroundStyle(.white) // Symbol color
                .clipShape(Circle()) // Circular shape

            // Text Content
            VStack(alignment: .leading, spacing: 5) { // Reduced spacing
                Text(model.id)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text("Owner: \(model.ownedBy)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text("Created: \(model.createdDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer() // Pushes content to the left

            Image(systemName: "chevron.right") // Indicate navigation
                 .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(12) // Padding for the entire HStack content
        .background(.regularMaterial) // Use material for a modern feel
        .clipShape(RoundedRectangle(cornerRadius: 12)) // Slightly more rounded corners
        .overlay( // Subtle border
             RoundedRectangle(cornerRadius: 12)
                  .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3) // Softer shadow
    }
}

// --- Wrapping HStack for Tags/Capabilities ---
struct WrappingHStack<Item: Hashable, ItemView: View>: View {
    let items: [Item]
    let viewForItem: (Item) -> ItemView
    let horizontalSpacing: CGFloat = 8
    let verticalSpacing: CGFloat = 8

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.items, id: \.self) { item in
                self.viewForItem(item)
                    .padding(.horizontal, horizontalSpacing / 2)
                    .padding(.vertical, verticalSpacing / 2)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height + verticalSpacing
                        }
                        let result = width
                        if item == self.items.last {
                            width = 0 // last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if item == self.items.last {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

// --- Error View ---
struct ErrorView: View {
     let errorMessage: String
     let retryAction: () -> Void

     var body: some View {
          VStack(alignment: .center, spacing: 15) { // Increased spacing
               Image(systemName: "wifi.exclamationmark")
                   .resizable()
                   .scaledToFit()
                   .frame(width: 60, height: 60)
                   .foregroundColor(.red) // Use red for error

               VStack(spacing: 5) {
                    Text("Loading Failed")
                         .font(.title3.weight(.medium))
                    Text(errorMessage)
                         .font(.callout)
                         .foregroundColor(.secondary)
                         .multilineTextAlignment(.center)
                         .padding(.horizontal)
               }

               Button {
                    retryAction()
               } label: {
                    Label("Retry", systemImage: "arrow.clockwise")
               }
               .buttonStyle(.borderedProminent)
               .controlSize(.regular) // Standard size
               .padding(.top)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity) // Take full space
          .padding()
          .background(Color(.systemGroupedBackground)) // Match list background
     }
}

// MARK: - Detail View

struct ModelDetailView: View {
    let model: OpenAIModel

    var body: some View {
        List {
            // Section for the prominent Profile Image and basic ID
            Section {
                VStack(spacing: 15) {
                     // Larger Profile Image
                     Image(systemName: model.profileSymbolName)
                         .resizable()
                         .scaledToFit()
                         .padding(15) // More padding for larger size
                         .frame(width: 80, height: 80) // Larger frame
                         .background(model.profileBackgroundColor) // Solid color background
                         .foregroundStyle(.white)
                         .clipShape(Circle())
                         .shadow(color: model.profileBackgroundColor.opacity(0.4), radius: 8, y: 4) // Shadow matching color

                     Text(model.id)
                         .font(.title2.weight(.semibold)) // Larger font for ID
                         .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .center) // Center the VStack
                .padding(.vertical, 10) // Add some vertical padding
            }
            .listRowBackground(Color.clear) // Make section background transparent

            // --- Sections for Details ---
            Section("Overview") {
                DetailRow(label: "Type", value: model.object)
                DetailRow(label: "Owner", value: model.ownedBy)
                DetailRow(label: "Created", value: model.createdDate.formatted(date: .long, time: .shortened))
            }

            // Use the default values from OpenAIModel struct if API didn't provide them
            Section("Details") {
                 VStack(alignment: .leading, spacing: 5) {
                     Text("Description").font(.caption).foregroundColor(.secondary)
                     Text(model.description) // Uses default if not decoded
                 }
                 .accessibilityElement(children: .combine) // Combine for VO

                 VStack(alignment: .leading, spacing: 5) {
                     Text("Context Window").font(.caption).foregroundColor(.secondary)
                     Text(model.contextWindow) // Uses default if not decoded
                 }
                 .accessibilityElement(children: .combine) // Combine for VO
            }

            if !model.capabilities.isEmpty && model.capabilities != ["general"] { // Check if not empty and not just the default
                Section("Capabilities") {
                    WrappingHStack(items: model.capabilities) { capability in
                        Text(capability)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.2))
                            .foregroundColor(.accentColor)
                            .clipShape(Capsule())
                    }
                }
            }

            if !model.typicalUseCases.isEmpty && model.typicalUseCases != ["Various tasks"] { // Check if not empty and not just the default
                 Section("Typical Use Cases") {
                     ForEach(model.typicalUseCases, id: \.self) { useCase in
                         Label(useCase, systemImage: "play.rectangle") // Example icon
                             .foregroundColor(.primary)
                             .imageScale(.small)
                     }
                 }
            }

            Section("Actions") {
                 Button {
                      // In a real app, you might pass the model ID to another service
                      print("Simulate: Trying model \(model.id)")
                 } label: {
                      Label("Use this Model (Simulated)", systemImage: "wand.and.stars")
                      .frame(maxWidth: .infinity)
                 }
                 .buttonStyle(.borderedProminent)
                 .tint(model.profileBackgroundColor) // Tint button with profile color
                 .listRowInsets(EdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 10))
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Model Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Helper for consistent label/value rows
    private func DetailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.callout)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.primary)
        }
         .padding(.vertical, 2)
         .accessibilityElement(children: .combine) // Improve accessibility
    }
}


// MARK: - Main ContentView

struct OpenAIModelsCardView: View {
    // --- State Variables ---
    @State private var allModels: [OpenAIModel] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var searchText = ""
    @State private var currentSortOrder: SortOption = .idAscending

    // --- UI TOGGLE STATE ---
    // User can now change this via the UI
    @State private var useMockData = true // Default to using Mock data

    // --- Computed Property for API Service ---
    // Determines which service to use based on the 'useMockData' state
    private var currentApiService: APIServiceProtocol {
        if useMockData {
            // Create a fresh instance each time it's needed (simple approach)
            // In more complex apps, you might cache instances.
             print("🔧 Using MockAPIService instance")
            return MockAPIService()
        } else {
             print("☁️ Using LiveAPIService instance")
            return LiveAPIService()
        }
    }

    // No custom init() needed anymore, using default memberwise init.

    // Computed property for filtered and sorted models (remains the same)
    var filteredAndSortedModels: [OpenAIModel] {
        let filtered: [OpenAIModel]
        if searchText.isEmpty {
            filtered = allModels
        } else {
            filtered = allModels.filter { $0.id.localizedCaseInsensitiveContains(searchText) }
        }

        switch currentSortOrder {
        case .idAscending:
            return filtered.sorted { $0.id.localizedCaseInsensitiveCompare($1.id) == .orderedAscending }
        case .idDescending:
            return filtered.sorted { $0.id.localizedCaseInsensitiveCompare($1.id) == .orderedDescending }
        case .dateNewest:
            return filtered.sorted { $0.created > $1.created }
        case .dateOldest:
            return filtered.sorted { $0.created < $1.created }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack { // Use ZStack to overlay ProgressView or ErrorView
                 // --- Conditional Content Display (remains the same) ---
                 if isLoading && allModels.isEmpty {
                      ProgressView("Fetching Models...")
                           .scaleEffect(1.5)
                           .frame(maxWidth: .infinity, maxHeight: .infinity)
                 } else if let errorMessage = errorMessage, allModels.isEmpty {
                      ErrorView(errorMessage: errorMessage) {
                           loadModels() // Retry action
                      }
                 } else {
                      // --- Main Content List (remains the same) ---
                     List {
                         if !filteredAndSortedModels.isEmpty {
                             ForEach(filteredAndSortedModels) { model in
                                 NavigationLink(value: model) {
                                     ModelCardView(model: model)
                                 }
                                 .listRowInsets(EdgeInsets())
                                 .listRowBackground(Color.clear)
                                 .listRowSeparator(.hidden)
                                 .padding(.horizontal, 16)
                                 .padding(.vertical, 6)
                             }
                         } else if !searchText.isEmpty {
                             ContentUnavailableView.search(text: searchText)
                                 .listRowBackground(Color.clear)
                                 .listRowSeparator(.hidden)
                         } else if !isLoading {
                             ContentUnavailableView("No Models Available", systemImage: "rectangle.stack.badge.questionmark")
                                 .listRowBackground(Color.clear)
                                 .listRowSeparator(.hidden)
                         }
                     }
                     .listStyle(.plain)
                     .contentMargins(.vertical, 0, for: .scrollContent)
                     .background(Color(.systemGroupedBackground))
                     .searchable(text: $searchText, prompt: "Search Models by ID")
                 }
            }
             .navigationTitle("OpenAI Models")
             // --- Toolbar Items (Navigation Bar - Refresh and Sort) ---
             .toolbar {
                 // Refresh/Loading Indicator
                 ToolbarItem(placement: .navigationBarLeading) {
                     if isLoading {
                         ProgressView().controlSize(.small)
                     } else {
                         Button {
                             loadModels()
                         } label: {
                             Label("Refresh", systemImage: "arrow.clockwise")
                         }
                         .disabled(isLoading)
                     }
                 }
                 // Sorting Menu
                 ToolbarItem(placement: .navigationBarTrailing) {
                      Menu {
                          Picker("Sort Order", selection: $currentSortOrder) {
                              ForEach(SortOption.allCases) { option in
                                  Text(option.rawValue).tag(option)
                              }
                          }
                      } label: {
                           Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                      }
                      .disabled(allModels.isEmpty || isLoading)
                 }

                 // --- NEW: Bottom Toolbar Item for API Source Toggle ---
                 ToolbarItem(placement: .bottomBar) {
                     Toggle(isOn: $useMockData) {
                         Text(useMockData ? "Using Mock Data" : "Using Live API")
                              .font(.caption)
                     }
                     .toggleStyle(.switch)
                     .padding(.horizontal) // Add some padding
                     .disabled(isLoading) // Disable while loading data
                     .tint(.accentColor) // Optional: Style the switch
                 }
             }
             // --- Navigation Destination (remains the same) ---
             .navigationDestination(for: OpenAIModel.self) { model in
                 ModelDetailView(model: model)
                     .toolbarBackground(.visible, for: .navigationBar) // Ensure background is visible on detail
                     .toolbarBackground(Color(.secondarySystemBackground), for: .navigationBar)
             }
             // --- Initial Load & Refresh (remains the same) ---
             .task {
                 if allModels.isEmpty {
                     loadModels()
                 }
             }
             .refreshable {
                 await loadModelsAsync()
             }
             // Display error as an alert if it occurs after initial load (remains the same)
             .alert("Error", isPresented: .constant(errorMessage != nil && !allModels.isEmpty), actions: {
                 Button("OK") { errorMessage = nil }
             }, message: {
                 Text(errorMessage ?? "An unknown error occurred.")
             })
             // --- NEW: React to Toggle Changes ---
              .onChange(of: useMockData) { oldValue, newValue in // Updated syntax for iOS 17+
                   print("Toggle changed: Switched to \(newValue ? "Mock Data" : "Live API")")
                   // Reset state and reload data with the new service
                   allModels = []
                   errorMessage = nil
                   searchText = "" // Optionally reset search
                   loadModels() // Trigger load with the new service selection
              }

        }
    }

    // --- Data Loading Functions ---

    private func loadModels() {
        guard !isLoading else { return }
        isLoading = true
        // Don't clear the error message *here* if keeping stale data visible
        // errorMessage = nil

        Task {
            await loadModelsAsync()
        }
    }

    @MainActor // Ensure UI updates happen on main thread
    private func loadModelsAsync() async {
        // Do not reset isLoading to true here if called from refreshable or loadModels
        // It's already set by the caller. Ensure isLoading is true *before* calling.
        if !isLoading { isLoading = true } // Should generally be true already

        // **Use the computed property to get the current service**
        let serviceToUse = currentApiService
        print("🔄 Loading models using \(useMockData ? "MockAPIService" : "LiveAPIService")...")

        do {
            // Fetch using the dynamically determined service
            let fetchedModels = try await serviceToUse.fetchModels()
            self.allModels = fetchedModels
            self.errorMessage = nil // Clear error on success
            print("✅ Successfully loaded \(fetchedModels.count) models.")
        } catch let error as LocalizedError {
            print("❌ Error loading models: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
            // If the toggle caused the load, we already cleared models.
            // If refresh caused it, clearing here would remove stale data.
            // Decide based on desired UX. For now, leave stale data on refresh error.
              if allModels.isEmpty { // Only force empty if it was already empty (e.g., initial load failure)
                 self.allModels = []
              }
        } catch {
            print("❌ Unexpected error loading models: \(error)")
             self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
             if allModels.isEmpty {
                 self.allModels = []
              }
        }
        isLoading = false
    }
}

// MARK: - Previews

#Preview("Content List (Defaults to Mock)") {
    OpenAIModelsCardView()
}

// Other previews (ModelDetailView, ModelCardView, ErrorView, etc.) remain unchanged.
// Add previews for specific toggle states if needed, although interacting
// with the main preview is usually sufficient to test the toggle.
#Preview("Content List - Forced Live (Preview)") {
     // Note: This only sets the initial state for the preview instance.
     // The LiveAPIService might still fail if API key is missing.
     let contentView = OpenAIModelsCardView()
     // To set state in preview, you need to manage it differently,
     // perhaps by wrapping ContentView or using a PreviewProvider.
     // A simple approach for forcing the look:
     // return ContentView(useMockData: false) // This requires modifying ContentView init again
     // Easier to just run the app and toggle manually or use the default preview.
    OpenAIModelsCardView() // Run default, you can toggle in interactive preview
}


// MARK: - Previews

#Preview("Content List (Check Toggle)") {
    OpenAIModelsCardView() // Uses the 'useMockData' setting inside ContentView
}

#Preview("Detail View (GPT-4 Turbo Mock)") {
    let sampleModel = OpenAIModel(id: "gpt-4-turbo-preview", object: "model", created: 1712602800, ownedBy: "openai", description: "Preview version of the highly capable GPT-4 Turbo model, optimized for chat and instruction following.", capabilities: ["advanced reasoning", "code generation", "multilingual", "vision (limited)"], contextWindow: "128k", typicalUseCases: ["Complex problem solving", "Creative writing", "Code review", "Data analysis description"])
     return NavigationStack { // Wrap in NavStack for title display
          ModelDetailView(model: sampleModel)
     }
}

#Preview("Card View (Custom User Model)") {
    let sampleUserModel = OpenAIModel(id: "my-finetuned-support-bot-v3", object: "model", created: 1710050000, ownedBy: "user-org-456")
    return ModelCardView(model: sampleUserModel)
        .padding() // Add padding for preview canvas visibility
}

#Preview("Error View Example") {
    ErrorView(errorMessage: "Could not connect to the server. Please check your internet connection and try again.") {
        print("Retry tapped in preview")
    }
}

#Preview("Content List - Empty State") {
    // Simulate empty state by providing an empty service
    class EmptyService: APIServiceProtocol {
        func fetchModels() async throws -> [OpenAIModel] {
            return []
        }
    }
    // Need a way to inject this service or modify the preview struct
    // For simplicity, manually showing the content unavailable view
    return ContentUnavailableView("No Models Available", systemImage: "rectangle.stack.badge.questionmark")
}

#Preview("Content List - Initial Loading") {
    // Simulate loading state
    let view = OpenAIModelsCardView()
    // You might need more complex preview setup to force the isLoading state
    return ProgressView("Fetching Models...")
        .scaleEffect(1.5)
        .frame(width: 200, height: 200) // Give it some size in preview
}

