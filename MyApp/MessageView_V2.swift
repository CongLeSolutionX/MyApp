//
//  MessageView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//

import SwiftUI
// Import the Google Generative AI SDK
import GoogleGenerativeAI

// MARK: - Configuration (API Key - DO NOT HARDCODE IN PRODUCTION)
struct AIConfig {
    // --- IMPORTANT ---
    // Replace "YOUR_API_KEY" with your actual Google Gemini API Key.
    // For production apps, use environment variables, a configuration file,
    // or a secure vault service instead of hardcoding the key.
    // --- IMPORTANT ---
    static let geminiApiKey = "YOUR_API_KEY"
}

// MARK: - AI Service Layer

struct AIService {
    // Configure the Gemini Model
    // Ensure you are using a model version suitable for your task (e.g., 'gemini-1.5-flash')
    static let generativeModel = GenerativeModel(
        name: "gemini-1.5-flash", // Or another suitable model
        apiKey: AIConfig.geminiApiKey
    )

    // Fetches smart replies for a given message context
    static func fetchSmartReplies(for messageContext: String) async throws -> [String] {
        // --- Enhanced Prompt Construction ---
        // Provide clear instructions and context to the AI.
        // Asking for comma-separated output simplifies parsing.
        let prompt = """
        You are an assistant helping draft replies for messages on a platform like Airbnb.
        Generate exactly 3 concise, relevant smart replies (under 7 words each) for the following message context.
        Assume the user wants to reply positively or pragmatically.
        The message context is: "\(messageContext)"

        Respond ONLY with the 3 replies, separated by commas (e.g., Reply 1,Reply 2,Reply 3). Do not include numbering or quotes.
        """

        print("--- Sending Prompt to Gemini ---")
        print(prompt)
        print("------------------------------")

        do {
            // Generate content asynchronously
            let response = try await generativeModel.generateContent(prompt)

            // Extract the text response
            guard let text = response.text else {
                print("Gemini response text was nil.")
                throw AIError.responseParsingFailed("Gemini response text was nil.")
            }

            print("--- Received Raw Response from Gemini ---")
            print(text)
            print("---------------------------------------")

            // Parse the comma-separated string into an array
            let replies = text.split(separator: ",")
                              .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } // Trim whitespace
                              .filter { !$0.isEmpty } // Remove empty strings

            // Basic validation
            guard !replies.isEmpty else {
                 print("Gemini response parsed into an empty array.")
                throw AIError.responseParsingFailed("Parsed empty replies.")
            }

             print("--- Parsed Replies ---")
             print(replies)
             print("----------------------")

            return replies

        } catch let error as GenerateContentError {
             // Handle SDK specific errors more granularly if needed
             print("Error generating content: \(error)")
             throw AIError.apiError("Content generation failed: \(error.localizedDescription)")
        } catch {
            print("An unexpected error occurred: \(error)")
            throw AIError.apiError("An unexpected error occurred: \(error.localizedDescription)")
        }
    }
}

// Custom Error Type for AI Service
enum AIError: Error, LocalizedError {
    case apiKeyMissing
    case apiError(String)
    case responseParsingFailed(String)

    var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            return "Gemini API Key is missing. Please configure it in AIConfig."
        case .apiError(let message):
            return "Gemini API Error: \(message)"
        case .responseParsingFailed(let reason):
            return "Failed to parse Gemini response: \(reason)"
        }
    }
}

// MARK: - Data Models (Unchanged from previous version)

struct FilterCategory: Identifiable {
    let id = UUID()
    let name: String
}

struct MessageThread: Identifiable, Hashable { // Make Hashable for selection
    let id = UUID()
    let senderName: String
    let previewText: String
    let timestamp: String
    let imageName: String
    let isSystemImage: Bool
    let secondaryImageName: String?
    let additionalInfo: String?
    let colorGradient: LinearGradient?

    // Implement Hashable
     func hash(into hasher: inout Hasher) {
         hasher.combine(id)
     }

     static func == (lhs: MessageThread, rhs: MessageThread) -> Bool {
         lhs.id == rhs.id
     }

     // Make LinearGradient conform to Hashable (simplified version)
     // NOTE: For production, you might need a more robust way if gradients are complex
     var gradientHashValue: Int {
         // Simple hash based on color presence - adjust if needed
         return colorGradient != nil ? 1 : 0
     }
}

// Make LinearGradient Hashable (simplified approach)
extension LinearGradient: @retroactive Equatable {}

extension LinearGradient: @retroactive Hashable {
    public static func == (lhs: LinearGradient, rhs: LinearGradient) -> Bool {
        return true
    }
    
    public func hash(into hasher: inout Hasher) {
        // This is a basic hash implementation. For complex gradients,
        // you might need to hash based on colors, start/end points.
        // For this example, just hashing description might suffice if unique.
        hasher.combine(String(describing: self))
    }
}

// MARK: - Sample Data (Unchanged from previous version)

let filterCategories = [
    FilterCategory(name: "All"),
    FilterCategory(name: "Hosting"),
    FilterCategory(name: "Traveling"),
    FilterCategory(name: "Superhost Ambassador")
]

let messageThreads = [
    MessageThread(senderName: "Javier", previewText: "Airbnb update: Reminder - Leave a review for your stay.", timestamp: "1/21/24", imageName: "building.2", isSystemImage: true, secondaryImageName: "person.crop.circle.fill", additionalInfo: "Jan 7 – 21, 2024 · Marietta", colorGradient: nil),
    MessageThread(senderName: "Airbnb Support", previewText: "Welcome to Airbnb! Let us know if you have questions.", timestamp: "1/7/24", imageName: "airbnb.logo", isSystemImage: false, secondaryImageName: nil, additionalInfo: "Welcome", colorGradient: nil),
    MessageThread(senderName: "Airbnb Support", previewText: "This conversation closed because it was inactive.", timestamp: "1/5/24", imageName: "airbnb.logo", isSystemImage: false, secondaryImageName: nil, additionalInfo: "Closed", colorGradient: nil),
    MessageThread(senderName: "Nizar", previewText: "Checking in went smoothly! The place is great.", timestamp: "7/17/22", imageName: "house.fill", isSystemImage: true, secondaryImageName: "person.crop.circle.fill", additionalInfo: "Jul 15 – 16, 2022 · San Diego", colorGradient: nil),
    MessageThread(senderName: "Sunshine Property Management", previewText: "Hi! Just checking in to see if you need any additional amenities during your stay?", timestamp: "5/24/22", imageName: "", isSystemImage: false, secondaryImageName: nil, additionalInfo: "Superhost Ambassador", colorGradient: LinearGradient(gradient: Gradient(colors: [.orange, .pink]), startPoint: .topLeading, endPoint: .bottomTrailing))
]

// MARK: - Reusable Views (AvatarView, FilterChipView, MessageRowView - Unchanged from previous version)

struct AvatarView: View {
     let imageName: String
     let isSystemImage: Bool
     let secondaryImageName: String?
     let colorGradient: LinearGradient?
     let size: CGFloat = 50

     var body: some View {
         ZStack {
             if let gradient = colorGradient {
                 Circle()
                     .fill(gradient)
                     .frame(width: size, height: size)
                     .overlay(
                         Image(systemName: "photo.on.rectangle.angled")
                             .foregroundColor(.white.opacity(0.7))
                             .font(.system(size: size * 0.4))
                     )
             } else {
                  Circle()
                     .fill(Color(.systemGray5))
                     .frame(width: size, height: size)

                 if isSystemImage {
                     Image(systemName: imageName)
                         .resizable()
                         .scaledToFit()
                         .frame(width: size * 0.5, height: size * 0.5)
                         .foregroundColor(Color(.darkGray))
                 } else if imageName == "airbnb.logo" {
                      Circle()
                         .fill(Color(.darkGray))
                         .frame(width: size, height: size)
                     Image(systemName: "house.lodge.fill")
                         .resizable()
                         .scaledToFit()
                         .frame(width: size * 0.5, height: size * 0.5)
                         .foregroundColor(.white)

                 } else {
                      Image(systemName: "person.fill")
                          .resizable()
                          .scaledToFit()
                          .frame(width: size * 0.5, height: size * 0.5)
                          .foregroundColor(Color(.darkGray))
                 }

                 if let secondaryName = secondaryImageName {
                     Image(systemName: secondaryName)
                         .resizable()
                         .scaledToFit()
                         .frame(width: size * 0.55, height: size * 0.55)
                         .background(Circle().fill(Color(.systemBackground)))
                         .clipShape(Circle())
                         .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                         .shadow(radius: 1)
                         .offset(x: size * 0.3, y: size * 0.3)
                 }
             }
         }
         .frame(width: size, height: size)
     }
}

struct FilterChipView: View {
    let category: FilterCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(category.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.black : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .black)
                .clipShape(Capsule())
        }
    }
}

struct MessageRowView: View {
    let thread: MessageThread

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarView(
                imageName: thread.imageName,
                isSystemImage: thread.isSystemImage,
                secondaryImageName: thread.secondaryImageName,
                colorGradient: thread.colorGradient
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(thread.senderName)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(thread.previewText)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)

                if let info = thread.additionalInfo {
                    Text(info)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(thread.timestamp)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 2)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Main Messages View with Smart Replies Integration

struct AirbnbMessagesView: View {
    @State private var selectedFilter: String = "All"

    // --- State for Smart Replies ---
    @State private var selectedThread: MessageThread? = nil // Track selected thread
    @State private var smartReplies: [String] = []
    @State private var isLoadingReplies: Bool = false
    @State private var errorMessage: String? = nil
    // -------------------------------

    // Separate function to trigger reply fetching
    private func fetchReplies(for thread: MessageThread) {
        guard AIConfig.geminiApiKey != "YOUR_API_KEY" else {
            errorMessage = AIError.apiKeyMissing.localizedDescription
            return
        }

        isLoadingReplies = true
        selectedThread = thread // Keep track of which thread is selected
        errorMessage = nil
        smartReplies = [] // Clear old replies

        Task { // Perform async work in a Task
            do {
                let replies = try await AIService.fetchSmartReplies(for: thread.previewText)
                await MainActor.run { // Update UI state on the main thread
                    self.smartReplies = replies
                    self.isLoadingReplies = false
                }
            } catch {
                await MainActor.run { // Update UI state on the main thread
                    self.errorMessage = error.localizedDescription
                     print("Error fetching replies: \(error)") // Log detailed error
                    self.isLoadingReplies = false
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Title
                Text("Messages")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                // Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filterCategories) { category in
                            FilterChipView(
                                category: category,
                                isSelected: selectedFilter == category.name
                            ) {
                                selectedFilter = category.name
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }

                // Message List
                List {
                    ForEach(messageThreads) { thread in
                        MessageRowView(thread: thread)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowSeparator(.hidden)
                            // --- Make row tappable ---
                            .contentShape(Rectangle()) // Ensure the whole area is tappable
                            .onTapGesture {
                                // Trigger fetch OR clear if same row tapped again
                                if selectedThread == thread {
                                     selectedThread = nil // Deselect
                                     smartReplies = []
                                     errorMessage = nil
                                } else {
                                     fetchReplies(for: thread)
                                }
                            }
                            // --- Highlight selected row (Optional) ---
                            .listRowBackground(selectedThread == thread ? Color.gray.opacity(0.1) : Color.clear)
                            .animation(.easeInOut(duration: 0.2), value: selectedThread) // Animate selection change

                    }
                }
                .listStyle(.plain)
                .padding(.top, -8)

                // --- Smart Replies Section ---
                if selectedThread != nil { // Show only when a thread is selected
                    VStack(alignment: .leading) {
                        Divider().padding(.bottom, 8) // Visual separator

                        // Loading Indicator
                        if isLoadingReplies {
                             HStack {
                                Spacer()
                                ProgressView()
                                    .padding(.vertical, 10)
                                Spacer()
                            }
                        }
                         // Error Message
                         else if let errorMsg = errorMessage {
                            Text("Error: \(errorMsg)")
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal)
                                .padding(.bottom, 5)
                        }
                        // Suggestion Buttons
                        else if !smartReplies.isEmpty {
                            Text("Smart Replies:")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.bottom, 2)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(smartReplies, id: \.self) { reply in
                                        Button {
                                            // Action: Populate compose field (placeholder)
                                            print("Selected reply: \(reply)")
                                            // In a real app: Update a @State var bound to a TextField
                                        } label: {
                                            Text(reply)
                                                .font(.caption)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color(.systemGray5))
                                                .foregroundColor(.primary)
                                                .clipShape(Capsule())
                                        }
                                    }
                                }

                            }
                            .padding(.bottom, 10) // Space below suggestions
                        }
                    }
                    .padding(.horizontal) // Padding for the entire smart reply section
                    .transition(.move(edge: .bottom).combined(with: .opacity)) // Add animation
                    .animation(.easeInOut, value: isLoadingReplies)
                    .animation(.easeInOut, value: smartReplies)
                }
                // --- End Smart Replies Section ---

            } // End Top VStack
            .toolbar {
                // Toolbar remains unchanged
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button { } label: {
                        Image(systemName: "magnifyingglass")
                            .padding(8)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                            .foregroundColor(.black)
                    }
                    Button { } label: {
                         Image(systemName: "line.3.horizontal.decrease.circle")
                           .padding(8)
                           .background(Color(.systemGray5))
                           .clipShape(Circle())
                            .foregroundColor(.black)
                    }
                }
            }
             .navigationBarTitleDisplayMode(.inline)
        } // End NavigationStack
        .animation(.default, value: selectedThread) // Animate overall section appearance
    } // End body
}

// MARK: - Main App Structure with TabView (Unchanged from previous version)

struct MainTabView: View {
    @State private var selectedTab: Int = 3

    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Explore Screen").tabItem { Label("Explore", systemImage: "magnifyingglass") }.tag(0)
            Text("Wishlists Screen").tabItem { Label("Wishlists", systemImage: "heart") }.tag(1)
            Text("Trips Screen").tabItem { Label("Trips", systemImage: "airplane") }.tag(2)

            AirbnbMessagesView()
                .tabItem {
                    Label { Text("Messages") } icon: {
                        ZStack {
                            Image(systemName: "message")
                            Circle().fill(Color.red).frame(width: 6, height: 6).offset(x: 8, y: -8) // Notification dot
                        }
                    }
                }
                .tag(3)

            Text("Profile Screen").tabItem { Label("Profile", systemImage: "person.crop.circle") }.tag(4)
        }
        .tint(.pink)
    }
}

// MARK: - Preview

#Preview("MainTabView") {
    MainTabView()
}

#Preview("Airbnb Messages View") {
    AirbnbMessagesView()
}
