////
////  OpenAIModelsCardView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/13/25.
////
//
//
//import SwiftUI
//
//// Enum for Sorting Options
//enum SortOption: String, CaseIterable, Identifiable {
//    case idAscending = "ID (A-Z)"
//    case idDescending = "ID (Z-A)"
//    case dateNewest = "Date (Newest)"
//    case dateOldest = "Date (Oldest)"
//
//    var id: String { self.rawValue } // For Identifiable conformance
//}
//
//// --- Enhanced Data Modeling (with Mock Details & Image Logic) ---
//
//struct ModelListResponse: Codable { // Still useful if eventually switching back to network
//    let data: [OpenAIModel]
//}
//
//struct OpenAIModel: Codable, Identifiable, Hashable { // Added Hashable for NavigationLink value
//    let id: String
//    let object: String
//    let created: Int // Unix timestamp
//    let ownedBy: String
//
//    // --- Mock Data for Detail View ---
//    var description: String = "No description available."
//    var capabilities: [String] = ["general"]
//    var contextWindow: String = "N/A"
//    var typicalUseCases: [String] = ["Various tasks"]
//    // ----------------------------------
//
//    // Conform to Codable (custom key mapping for 'owned_by')
//    enum CodingKeys: String, CodingKey {
//        case id
//        case object
//        case created
//        case ownedBy = "owned_by" // Map JSON key 'owned_by' to Swift 'ownedBy'
//        // Mock data fields are not decoded from JSON in this setup
//    }
//
//    // Computed property for easy date access
//    var createdDate: Date {
//        Date(timeIntervalSince1970: TimeInterval(created))
//    }
//
//    // Hashable conformance (based on unique ID)
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//    static func == (lhs: OpenAIModel, rhs: OpenAIModel) -> Bool {
//        lhs.id == rhs.id
//    }
//}
//
//// --- Extension for Profile Image Logic ---
//extension OpenAIModel {
//    // Determine the SF Symbol name based on the owner
//    var profileSymbolName: String {
//        let lowerOwner = ownedBy.lowercased()
//        if lowerOwner.contains("openai") { return "building.columns.fill" }
//        if lowerOwner == "system" { return "gearshape.fill" }
//        if lowerOwner.contains("user") || lowerOwner.contains("org") { return "person.crop.circle.fill" }
//        return "questionmark.circle.fill" // Default/fallback
//    }
//
//    // Determine the background color for the profile image view
//    var profileBackgroundColor: Color {
//        let lowerOwner = ownedBy.lowercased()
//        if lowerOwner.contains("openai") { return .blue }
//        if lowerOwner == "system" { return .orange }
//        if lowerOwner.contains("user") || lowerOwner.contains("org") { return .purple }
//        return .gray // Default/fallback
//    }
//}
//
//// --- Mock Data Service (No Changes needed here) ---
//
//class MockAPIService {
//    // Simulate network delay
//    private let mockNetworkDelaySeconds: Double = 0.8
//
//    // Predefined mock models
//    private func generateMockModels() -> [OpenAIModel] {
//        return [
//            OpenAIModel(id: "gpt-4-turbo", object: "model", created: 1712602800, ownedBy: "openai", description: "Our most capable and recent GPT-4 model.", capabilities: ["text generation", "code completion", "reasoning"], contextWindow: "128k", typicalUseCases: ["Complex chat", "Content generation", "Code assistance"]),
//            OpenAIModel(id: "gpt-3.5-turbo-instruct", object: "model", created: 1694022000, ownedBy: "openai", description: "Instruct-tuned version of GPT-3.5.", capabilities: ["text generation", "instruction following"], contextWindow: "4k", typicalUseCases: ["Direct instruction tasks", "Simple Q&A"]),
//            OpenAIModel(id: "dall-e-3", object: "model", created: 1700000000, ownedBy: "openai", description: "Advanced image generation model.", capabilities: ["image generation", "text-to-image"], contextWindow: "N/A", typicalUseCases: ["Art creation", "Product visualization"]),
//            OpenAIModel(id: "whisper-1", object: "model", created: 1677600000, ownedBy: "openai", description: "Speech-to-text model.", capabilities: ["audio transcription", "translation"], contextWindow: "N/A", typicalUseCases: ["Meeting transcriptions", "Voice commands"]),
//            OpenAIModel(id: "babbage-002", object: "model", created: 1692902400, ownedBy: "openai", description: "Older generation model, faster but less capable.", capabilities: ["text generation"], contextWindow: "4k", typicalUseCases: ["Simple text classification", "Drafting"]),
//            OpenAIModel(id: "text-embedding-3-large", object: "model", created: 1711300000, ownedBy: "openai", description: "Large text embedding model.", capabilities: ["text embedding", "semantic search"], contextWindow: "8k", typicalUseCases: ["Recommendation systems", "Clustering"]),
//             OpenAIModel(id: "text-moderation-stable", object: "model", created: 1677600000, ownedBy: "openai-internal", description: "Model for content moderation tasks.", capabilities: ["content filtering", "policy enforcement"], contextWindow: "N/A", typicalUseCases: ["Community guideline checking", "Safety filtering"]),
//              OpenAIModel(id: "my-custom-finetune-model-abc", object: "model", created: 1710000000, ownedBy: "user-org-123", description: "A fine-tuned model based on gpt-3.5 for specific tasks.", capabilities: ["text generation", "domain-specific-knowledge"], contextWindow: "4k", typicalUseCases: ["Customer support bot", "Internal knowledge base Q&A"]),
//               OpenAIModel(id: "system-default-v1", object: "model", created: 1660000000, ownedBy: "system", description: "Internal system model.", capabilities: ["internal processing"], contextWindow: "N/A", typicalUseCases: ["System tasks"])
//        ]
//    }
//
//    func fetchModels() async throws -> [OpenAIModel] {
//         // Simulate network delay
//         try? await Task.sleep(for: .seconds(mockNetworkDelaySeconds))
//         // Return the structured mock data
//         return generateMockModels()
//         // ---- To simulate an error ----
//         // throw MockError.simulatedFetchError
//         // -----------------------------
//    }
//}
//
//// Optional: Define mock errors if needed
//enum MockError: Error, LocalizedError {
//     case simulatedFetchError
//     var errorDescription: String? {
//         switch self {
//         case .simulatedFetchError:
//             return "Simulated network error: Could not fetch models."
//         }
//     }
//}
//
//// --- Reusable SwiftUI Card View (with Profile Image) ---
//
//struct ModelCardView: View {
//    let model: OpenAIModel
//
//    var body: some View {
//        HStack(spacing: 15) {
//            // Profile Image View
//            Image(systemName: model.profileSymbolName)
//                .resizable()
//                .scaledToFit()
//                .padding(8) // Padding inside the circle
//                .frame(width: 44, height: 44) // Fixed size for the image container
//                .background(model.profileBackgroundColor.opacity(0.85)) // Use model's color
//                .foregroundStyle(.white) // Symbol color
//                .clipShape(Circle()) // Circular shape
//
//            // Text Content
//            VStack(alignment: .leading, spacing: 5) { // Reduced spacing
//                Text(model.id)
//                    .font(.headline)
//                    .lineLimit(1)
//                    .truncationMode(.tail)
//
//                Text("Owner: \(model.ownedBy)")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .lineLimit(1)
//
//                Text("Created: \(model.createdDate, style: .date)")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//
//            Spacer() // Pushes content to the left
//
//            Image(systemName: "chevron.right") // Indicate navigation
//                 .foregroundColor(.secondary.opacity(0.5))
//
//        }
//        .padding(12) // Padding for the entire HStack content
//        .background(.regularMaterial) // Use material for a modern feel
//        .clipShape(RoundedRectangle(cornerRadius: 12)) // Slightly more rounded corners
//        .overlay( // Subtle border
//             RoundedRectangle(cornerRadius: 12)
//                  .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//        )
//        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3) // Softer shadow
//    }
//}
//
//// --- Detail View (with Profile Image) ---
//
//struct ModelDetailView: View {
//    let model: OpenAIModel
//
//    var body: some View {
//        List {
//            // Section for the prominent Profile Image and basic ID
//            Section {
//                VStack(spacing: 15) {
//                     // Larger Profile Image
//                     Image(systemName: model.profileSymbolName)
//                         .resizable()
//                         .scaledToFit()
//                         .padding(15) // More padding for larger size
//                         .frame(width: 80, height: 80) // Larger frame
//                         .background(model.profileBackgroundColor) // Solid color background
//                         .foregroundStyle(.white)
//                         .clipShape(Circle())
//                         .shadow(color: model.profileBackgroundColor.opacity(0.4), radius: 8, y: 4) // Shadow matching color
//
//                     Text(model.id)
//                         .font(.title2.weight(.semibold)) // Larger font for ID
//                         .multilineTextAlignment(.center)
//                }
//                .frame(maxWidth: .infinity, alignment: .center) // Center the VStack
//                .padding(.vertical, 10) // Add some vertical padding
//            }
//            .listRowBackground(Color.clear) // Make section background transparent
//
//            // --- Original Sections for Details ---
//            Section("Overview") {
//                DetailRow(label: "Type", value: model.object)
//                DetailRow(label: "Owner", value: model.ownedBy) // Simpler owner row
//                DetailRow(label: "Created", value: model.createdDate.formatted(date: .long, time: .shortened))
//            }
//
//            Section("Details") {
//                 VStack(alignment: .leading, spacing: 5) {
//                     Text("Description").font(.caption).foregroundColor(.secondary)
//                     Text(model.description)
//                 }
//
//                 VStack(alignment: .leading, spacing: 5) {
//                     Text("Context Window").font(.caption).foregroundColor(.secondary)
//                     Text(model.contextWindow)
//                 }
//            }
//
//            if !model.capabilities.isEmpty {
//                Section("Capabilities") {
//                    WrappingHStack(items: model.capabilities) { capability in
//                        Text(capability)
//                            .font(.caption)
//                            .padding(.horizontal, 8)
//                            .padding(.vertical, 4)
//                            .background(Color.accentColor.opacity(0.2))
//                            .foregroundColor(.accentColor)
//                            .clipShape(Capsule())
//                    }
//                }
//            }
//
//            if !model.typicalUseCases.isEmpty {
//                 Section("Typical Use Cases") {
//                    // Using Label for icon + text
//                     ForEach(model.typicalUseCases, id: \.self) { useCase in
//                         Label(useCase, systemImage: "play.rectangle") // Example icon
//                             .foregroundColor(.primary) // Use primary for text
//                             .imageScale(.small)
//                     }
//                 }
//            }
//
//             Section("Actions") {
//                  Button {
//                       print("Simulate: Trying model \(model.id)")
//                  } label: {
//                       Label("Use this Model (Simulated)", systemImage: "wand.and.stars")
//                       .frame(maxWidth: .infinity) // Expand label horizontally
//                  }
//                  .buttonStyle(.borderedProminent)
//                  .tint(model.profileBackgroundColor) // Tint button with profile color
//                  .listRowInsets(EdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 10)) // Adjust insets for button
//             }
//
//        }
//        .listStyle(.insetGrouped) // Use insetGrouped for modern grouped appearance
//        .navigationTitle("Model Details") // Generic Title
//        .navigationBarTitleDisplayMode(.inline) // Keep title smaller
//    }
//
//    // Helper for consistent label/value rows
//    private func DetailRow(label: String, value: String) -> some View {
//        HStack {
//            Text(label)
//                .font(.callout) // Slightly larger label
//                .foregroundColor(.secondary)
//            Spacer()
//            Text(value)
//                .font(.body) // Standard body text for value
//                .multilineTextAlignment(.trailing)
//                .foregroundColor(.primary)
//        }
//         .padding(.vertical, 2) // Minimal vertical padding between rows
//    }
//}
//
//// Helper View for wrapping tags/capabilities (Simple implementation - No Changes Needed)
//struct WrappingHStack<Item: Hashable, ItemView: View>: View {
//    let items: [Item]
//    let viewForItem: (Item) -> ItemView
//    let horizontalSpacing: CGFloat = 8
//    let verticalSpacing: CGFloat = 8
//
//    @State private var totalHeight: CGFloat = .zero
//
//    var body: some View {
//        VStack {
//            GeometryReader { geometry in
//                self.generateContent(in: geometry)
//            }
//        }
//        .frame(height: totalHeight)
//    }
//
//    private func generateContent(in g: GeometryProxy) -> some View {
//        var width = CGFloat.zero
//        var height = CGFloat.zero
//
//        return ZStack(alignment: .topLeading) {
//            ForEach(self.items, id: \.self) { item in
//                self.viewForItem(item)
//                    .padding(.horizontal, horizontalSpacing / 2)
//                    .padding(.vertical, verticalSpacing / 2)
//                    .alignmentGuide(.leading, computeValue: { d in
//                        if (abs(width - d.width) > g.size.width) {
//                            width = 0
//                            height -= d.height + verticalSpacing
//                        }
//                        let result = width
//                        if item == self.items.last {
//                            width = 0 // last item
//                        } else {
//                            width -= d.width
//                        }
//                        return result
//                    })
//                    .alignmentGuide(.top, computeValue: { d in
//                        let result = height
//                        if item == self.items.last {
//                            height = 0 // last item
//                        }
//                        return result
//                    })
//            }
//        }
//        .background(viewHeightReader($totalHeight))
//    }
//
//    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
//        GeometryReader { geometry -> Color in
//            let rect = geometry.frame(in: .local)
//            DispatchQueue.main.async {
//                binding.wrappedValue = rect.size.height
//            }
//            return .clear
//        }
//    }
//}
//
//// --- Main View with Search, Sort, Navigation (Minor List appearance adjustments) ---
//
//struct OpenAIModelsCardView: View {
//    @State private var allModels: [OpenAIModel] = []
//    @State private var isLoading = false
//    @State private var errorMessage: String? = nil
//    @State private var searchText = ""
//    @State private var currentSortOrder: SortOption = .idAscending
//
//    private let apiService = MockAPIService()
//
//    var filteredAndSortedModels: [OpenAIModel] {
//        let filtered: [OpenAIModel]
//        if searchText.isEmpty {
//            filtered = allModels
//        } else {
//            filtered = allModels.filter { $0.id.localizedCaseInsensitiveContains(searchText) }
//        }
//
//        switch currentSortOrder {
//        case .idAscending:
//            return filtered.sorted { $0.id.localizedCaseInsensitiveCompare($1.id) == .orderedAscending }
//        case .idDescending:
//            return filtered.sorted { $0.id.localizedCaseInsensitiveCompare($1.id) == .orderedDescending }
//        case .dateNewest:
//            return filtered.sorted { $0.created > $1.created }
//        case .dateOldest:
//            return filtered.sorted { $0.created < $1.created }
//        }
//    }
//
//    var body: some View {
//        NavigationStack {
//            ZStack { // Use ZStack to overlay ProgressView or ErrorView if needed
//                 if isLoading && allModels.isEmpty { // Show full screen loading only initially
//                      ProgressView("Fetching Models...")
//                           .scaleEffect(1.5) // Make it a bit larger
//                 } else if let errorMessage = errorMessage, allModels.isEmpty { // Full screen error only initially
//                      ErrorView(errorMessage: errorMessage) {
//                           loadModels()
//                      }
//                 } else {
//                      // Main Content List
//                     List {
//                         // Display Models or Empty/No Results State within the list
//                         if !filteredAndSortedModels.isEmpty {
//                             ForEach(filteredAndSortedModels) { model in
//                                  // The NavigationLink now styles the card directly
//                                  NavigationLink(value: model) {
//                                       // EmptyView() ensures the NavigationLink doesn't add its own content
//                                       EmptyView()
//                                  }
//                                  .buttonStyle(PlainButtonStyle()) // Remove default link styling
//                                  .listRowInsets(EdgeInsets()) // Remove default padding
//                                  .listRowBackground(Color.clear) // Clear background for custom card
//                                  .listRowSeparator(.hidden) // Hide separator
//                                  .padding(.horizontal, 16) // Add horizontal margin
//                                  .padding(.vertical, 6) // Add vertical margin between cards
//                                  .overlay(ModelCardView(model: model)) // Show our card view
//                             }
//                         } else if !searchText.isEmpty {
//                               ContentUnavailableView.search(text: searchText)
//                                   .listRowBackground(Color.clear)
//                                   .listRowSeparator(.hidden)
//                          } else if !isLoading { // Only show if not loading and truly empty
//                              ContentUnavailableView("No Models Available", systemImage: "rectangle.stack.badge.questionmark")
//                                  .listRowBackground(Color.clear)
//                                  .listRowSeparator(.hidden)
//                          }
//                     }
//                      .listStyle(.plain) // Use plain style for seamless background
//                      .contentMargins(.vertical, 0, for: .scrollContent) // Remove top/bottom padding if any
//                      .background(Color(.systemGroupedBackground)) // Give list a slight background color
//                      // --- Add Search ---
//                      .searchable(text: $searchText, prompt: "Search Models by ID")
//                 }
//            }
//             .navigationTitle("OpenAI Models")
//             // --- Add Sorting Menu ---
//             .toolbar {
//                 ToolbarItem(placement: .navigationBarTrailing) {
//                      Menu {
//                          Picker("Sort Order", selection: $currentSortOrder) {
//                              ForEach(SortOption.allCases) { option in
//                                  Text(option.rawValue).tag(option)
//                              }
//                          }
//                      } label: {
//                           Label("Sort", systemImage: "arrow.up.arrow.down.circle")
//                      }
//                      .disabled(allModels.isEmpty || isLoading) // Disable sort when empty/loading
//                 }
//                 // Optional: Add a refresh button explicitly if needed
//                 ToolbarItem(placement: .navigationBarLeading) {
//                     if isLoading {
//                         ProgressView().controlSize(.small)
//                     } else {
//                         Button {
//                             loadModels()
//                         } label: {
//                             Label("Refresh", systemImage: "arrow.clockwise")
//                         }
//                         .disabled(isLoading)
//                     }
//                 }
//             }
//             // --- Navigation Destination ---
//             .navigationDestination(for: OpenAIModel.self) { model in
//                 ModelDetailView(model: model)
//                 .toolbarBackground(.visible, for: .navigationBar) // Ensure nav bar background is visible on detail
//                 .toolbarBackground(Color(.secondarySystemBackground), for: .navigationBar) // Match typical detail view nav bar color
//             }
//             .task {
//                 if allModels.isEmpty {
//                     loadModels()
//                 }
//             }
//             .refreshable { // Added pull-to-refresh
//                 await loadModelsAsync()
//             }
//        }
//    }
//
//    // Original function for use in non-async contexts like button actions
//    private func loadModels() {
//        isLoading = true
//        errorMessage = nil
//        Task {
//            await loadModelsAsync()
//        }
//    }
//
//    // Async function for use with .task and .refreshable
//    @MainActor // Ensure UI updates happen on main thread
//    private func loadModelsAsync() async {
//        // Don't reset if already loading (prevents flicker during refresh)
//        if !isLoading {
//             isLoading = true
//             errorMessage = nil
//        }
//
//        do {
//            let fetchedModels = try await apiService.fetchModels()
//            self.allModels = fetchedModels
//            self.errorMessage = nil // Clear error on success
//        } catch let error as MockError {
//            self.errorMessage = error.localizedDescription
//            self.allModels = [] // Clear data on error
//        } catch {
//            self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
//            self.allModels = [] // Clear data on error
//        }
//        isLoading = false // Ensure loading is set to false at the end
//    }
//}
//
//// --- Reusable Error View Component (Slightly Updated) ---
//struct ErrorView: View {
//     let errorMessage: String
//     let retryAction: () -> Void
//
//     var body: some View {
//          VStack(alignment: .center, spacing: 15) { // Increased spacing
//               Image(systemName: "wifi.exclamationmark") // More specific icon?
//                   .resizable()
//                   .scaledToFit()
//                   .frame(width: 60, height: 60)
//                   .foregroundColor(.red) // Use red for error
//
//               VStack(spacing: 5) {
//                    Text("Loading Failed")
//                         .font(.title3.weight(.medium))
//                    Text(errorMessage)
//                         .font(.callout)
//                         .foregroundColor(.secondary)
//                         .multilineTextAlignment(.center)
//                         .padding(.horizontal)
//               }
//
//               Button {
//                    retryAction()
//               } label: {
//                    Label("Retry", systemImage: "arrow.clockwise")
//               }
//               .buttonStyle(.borderedProminent)
//               .controlSize(.regular) // Standard size
//               .padding(.top)
//          }
//          .frame(maxWidth: .infinity, maxHeight: .infinity) // Take full space
//          .padding()
//          .background(Color(.systemGroupedBackground)) // Match list background
//     }
//}
//
//// --- Preview ---
//
//#Preview("OpenAIModelsCardViewt") {
//    OpenAIModelsCardView()
//}
//
//#Preview("Detail View (GPT-4)") {
//     // Create a sample model for detail preview
//    let sampleModel = OpenAIModel(id: "gpt-4-turbo-preview", object: "model", created: 1712602800, ownedBy: "openai", description: "Preview version of the highly capable GPT-4 Turbo model, optimized for chat and instruction following.", capabilities: ["advanced reasoning", "code generation", "multilingual", "vision (limited)"], contextWindow: "128k", typicalUseCases: ["Complex problem solving", "Creative writing", "Code review", "Data analysis description"])
//     return NavigationStack { // Wrap in NavStack for title
//          ModelDetailView(model: sampleModel)
//     }
//}
//
//#Preview("Card View (User Model)") {
//    let sampleUserModel = OpenAIModel(id: "my-finetuned-support-bot-v3", object: "model", created: 1710050000, ownedBy: "user-org-456")
//    return ModelCardView(model: sampleUserModel)
//        .padding() // Add padding for preview canvas
//}
//
//#Preview("Error View") {
//    ErrorView(errorMessage: "Could not connect to the server. Please check your internet connection and try again.") {
//        print("Retry tapped in preview")
//    }
//}
