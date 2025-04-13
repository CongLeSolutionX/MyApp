//
//  OpenAIModelsCardView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI

// Enum for Sorting Options
enum SortOption: String, CaseIterable, Identifiable {
    case idAscending = "ID (A-Z)"
    case idDescending = "ID (Z-A)"
    case dateNewest = "Date (Newest)"
    case dateOldest = "Date (Oldest)"

    var id: String { self.rawValue } // For Identifiable conformance
}

// --- Phase 1 & 2: Enhanced Data Modeling (with Mock Details) ---

struct ModelListResponse: Codable { // Still useful if eventually switching back to network
    let data: [OpenAIModel]
}

struct OpenAIModel: Codable, Identifiable, Hashable { // Added Hashable for NavigationLink value
    let id: String
    let object: String
    let created: Int // Unix timestamp
    let ownedBy: String

    // --- Mock Data for Detail View ---
    var description: String = "No description available."
    var capabilities: [String] = ["general"]
    var contextWindow: String = "N/A"
    var typicalUseCases: [String] = ["Various tasks"]
    // ----------------------------------

    // Conform to Codable (custom key mapping for 'owned_by')
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case ownedBy = "owned_by" // Map JSON key 'owned_by' to Swift 'ownedBy'
        // Mock data fields are not decoded from JSON in this setup
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

// --- Phase 4: Mock Data Service ---

class MockAPIService {
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

         // ---- To simulate an error ----
         // throw MockError.simulatedFetchError
         // -----------------------------
    }
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

// --- Phase 3 & 4: Reusable SwiftUI Card View (Minor Refinements) ---

struct ModelCardView: View {
    let model: OpenAIModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.id)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.tail)

            HStack(spacing: 5) {
                Image(systemName: ownerIconName(owner: model.ownedBy))
                    .foregroundColor(ownerIconColor(owner: model.ownedBy))
                    .imageScale(.small) // Slightly smaller icon
                Text(model.ownedBy) // Just the owner name for brevity
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Text("Created: \(model.createdDate, style: .date)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(12) // Consistent padding
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        // Shadow applied outside if needed (e.g., in the List)
    }

    // Helper function for owner icon
      private func ownerIconName(owner: String) -> String {
          if owner.lowercased().contains("openai") { return "building.columns.fill" }
          if owner.lowercased() == "system" { return "gearshape.fill" }
          return "person.circle.fill" // Default for user-owned/other
      }

      // Helper function for owner icon color
      private func ownerIconColor(owner: String) -> Color {
           if owner.lowercased().contains("openai") { return .blue }
           if owner.lowercased() == "system" { return .orange }
           return .purple // Default for user-owned/other
      }
}

// --- Phase 3 & 4: New Detail View ---

struct ModelDetailView: View {
    let model: OpenAIModel

    var body: some View {
        // Use List for better structure and potential grouping/styling
        List {
            Section("Overview") {
                DetailRow(label: "Model ID", value: model.id)
                DetailRow(label: "Type", value: model.object)

                HStack {
                    Text("Owner").foregroundColor(.secondary)
                    Spacer()
                     Image(systemName: ownerIconName(owner: model.ownedBy))
                         .foregroundColor(ownerIconColor(owner: model.ownedBy))
                     Text(model.ownedBy)
                }

                DetailRow(label: "Created", value: model.createdDate.formatted(date: .long, time: .shortened))
            }

            Section("Details") {
                 VStack(alignment: .leading, spacing: 5) {
                     Text("Description").font(.caption).foregroundColor(.secondary)
                     Text(model.description)
                 }

                 VStack(alignment: .leading, spacing: 5) {
                     Text("Context Window").font(.caption).foregroundColor(.secondary)
                     Text(model.contextWindow)
                 }
            }

            if !model.capabilities.isEmpty {
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

            if !model.typicalUseCases.isEmpty {
                 Section("Typical Use Cases") {
                     ForEach(model.typicalUseCases, id: \.self) { useCase in
                         HStack {
                              Image(systemName: "checkmark.circle") // Example icon
                                   .foregroundColor(.green)
                              Text(useCase)
                         }
                     }
                 }
            }

            Section("Actions") {
                 Button {
                      print("Simulate: Trying model \(model.id)")
                      // In a real app, this might open a chat interface, code editor, etc.
                 } label: {
                      Label("Try this Model (Simulated)", systemImage: "play.circle.fill")
                 }
                 .buttonStyle(.borderedProminent)
                 .frame(maxWidth: .infinity) // Make button wider
                 .listRowBackground(Color.clear) // Remove default list row styling for button
            }

        }
        .navigationTitle(model.id) // Set title dynamically
        .navigationBarTitleDisplayMode(.inline) // Keep title smaller
    }

    // Helper for consistent label/value rows
    private func DetailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }

     // Helper function for owner icon (duplicated for standalone view - could be refactored)
     private func ownerIconName(owner: String) -> String {
         if owner.lowercased().contains("openai") { return "building.columns.fill" }
         if owner.lowercased() == "system" { return "gearshape.fill" }
         return "person.circle.fill" // Default for user-owned/other
     }

     // Helper function for owner icon color (duplicated)
     private func ownerIconColor(owner: String) -> Color {
         if owner.lowercased().contains("openai") { return .blue }
         if owner.lowercased() == "system" { return .orange }
         return .purple // Default for user-owned/other
     }
}

// Helper View for wrapping tags/capabilities (Simple implementation)
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

// --- Phase 3 & 4: Main View with Search, Sort, Navigation ---

struct OpenAIModelsCardView: View {
    @State private var allModels: [OpenAIModel] = [] // Holds all fetched models
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var searchText = ""
    @State private var currentSortOrder: SortOption = .idAscending // Default sort

    private let apiService = MockAPIService() // Use the mock service

    // --- Computed Property for Filtered and Sorted Models ---
    var filteredAndSortedModels: [OpenAIModel] {
        // Apply filtering
        let filtered: [OpenAIModel]
        if searchText.isEmpty {
            filtered = allModels
        } else {
            // Filter by ID containing the search text (case-insensitive)
            filtered = allModels.filter { $0.id.localizedCaseInsensitiveContains(searchText) }
        }

        // Apply sorting
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
    // -----------------------------------------------------

    var body: some View {
        NavigationStack { // Use NavigationStack for modern navigation
            List {
                // Use the computed property here
                ForEach(filteredAndSortedModels) { model in
                     NavigationLink(value: model) { // Navigate using the model object
                          ModelCardView(model: model)
                     }
                     .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                     .listRowSeparator(.hidden)
                     .listRowBackground(Color.clear)
                     // Apply shadow here if desired per card
                     .shadow(color: .gray.opacity(0.15), radius: 3, x: 0, y: 1)

                }
                // Display loading or error state if applicable (covers the list)
                 if isLoading {
                      ProgressView("Loading Models...")
                         .frame(maxWidth: .infinity, alignment: .center)
                         .listRowSeparator(.hidden)
                         .listRowBackground(Color.clear)
                         .padding(.vertical, 50)
                 } else if let errorMessage = errorMessage {
                    ErrorView(errorMessage: errorMessage) {
                        // Retry action
                        loadModels()
                    }
                     .listRowSeparator(.hidden)
                     .listRowBackground(Color.clear)
                 } else if filteredAndSortedModels.isEmpty && !searchText.isEmpty {
                       Text("No models match \"\(searchText)\".")
                           .foregroundColor(.secondary)
                           .frame(maxWidth: .infinity, alignment: .center)
                           .padding(.vertical, 50)
                           .listRowSeparator(.hidden)
                           .listRowBackground(Color.clear)
                 } else if filteredAndSortedModels.isEmpty && allModels.isEmpty && !isLoading {
                       Text("No models available.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 50)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)

                 }
            }
            .listStyle(.plain)
             .navigationTitle("OpenAI Models")
             // --- Add Search Bar ---
             .searchable(text: $searchText, prompt: "Search Models by ID")
             // --- Add Sorting Menu ---
             .toolbar {
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
                 }
             }
             // --- Navigation Destination ---
             .navigationDestination(for: OpenAIModel.self) { model in
                 ModelDetailView(model: model)
             }
             // ------------------------
             .task {
                 if allModels.isEmpty {
                     loadModels()
                 }
             }
             .refreshable {
                 loadModels()
             }
        }
    }

    // Function to encapsulate the loading logic
    private func loadModels() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedModels = try await apiService.fetchModels()
                // Update state on the main thread
                await MainActor.run {
                    self.allModels = fetchedModels // Store all fetched models
                    self.isLoading = false
                }
            } catch let error as MockError { // Catch specific mock errors
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    self.allModels = []
                }
            } catch { // Catch any other generic error
                await MainActor.run {
                    self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                    self.isLoading = false
                    self.allModels = []
                }
            }
        }
    }
}

// Reusable Error View Component
struct ErrorView: View {
     let errorMessage: String
     let retryAction: () -> Void

     var body: some View {
          VStack(alignment: .center, spacing: 10) {
               Image(systemName: "exclamationmark.triangle.fill")
                   .resizable()
                   .scaledToFit()
                   .frame(width: 50, height: 50)
                   .foregroundColor(.orange) // Use orange for warning/retryable error
               Text("Error Loading Models")
                   .font(.headline)
               Text(errorMessage)
                   .font(.body)
                   .foregroundColor(.secondary)
                   .multilineTextAlignment(.center)
                   .padding(.horizontal)
               Button("Retry", action: retryAction) // Use the passed-in action
                   .buttonStyle(.borderedProminent)
                   .padding(.top)
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 40)
     }
}

// --- Preview ---

#Preview {
    OpenAIModelsCardView()
}
