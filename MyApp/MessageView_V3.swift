//
//  MessageView_V3.swift
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

// MARK: - AI Service Layer (for Smart Replies)

struct AIService {
    // Model specifically for potentially quick, stateless tasks like replies
    static let replyModel = GenerativeModel(
        name: "gemini-1.5-flash", // Or another suitable model like gemini-pro
        apiKey: AIConfig.geminiApiKey
    )

    // Fetches smart replies for a given message context
    static func fetchSmartReplies(for messageContext: String) async throws -> [String] {
        let prompt = """
        You are an assistant helping draft replies for messages on a platform like Airbnb.
        Generate exactly 3 concise, relevant smart replies (under 7 words each) for the following message context.
        Assume the user wants to reply positively or pragmatically.
        The message context is: "\(messageContext)"

        Respond ONLY with the 3 replies, separated by commas (e.g., Reply 1,Reply 2,Reply 3). Do not include numbering or quotes.
        """
        print("--- Sending Reply Prompt to Gemini ---")
        print(prompt)
        print("------------------------------------")

        do {
            let response = try await replyModel.generateContent(prompt) // Use the specific replyModel

            guard let text = response.text else {
                print("Gemini reply response text was nil.")
                throw AIError.responseParsingFailed("Gemini response text was nil.")
            }
            print("--- Received Raw Reply Response ---")
            print(text)
            print("---------------------------------")

            let replies = text.split(separator: ",")
                              .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                              .filter { !$0.isEmpty }

            guard !replies.isEmpty else {
                 print("Gemini reply response parsed into an empty array.")
                throw AIError.responseParsingFailed("Parsed empty replies.")
            }
            print("--- Parsed Replies ---")
            print(replies)
            print("----------------------")
            return replies

        } catch let error as GenerateContentError {
             print("Error generating replies: \(error)")
             throw AIError.apiError("Reply generation failed: \(error.localizedDescription)")
        } catch {
            print("An unexpected error occurred fetching replies: \(error)")
            throw AIError.apiError("Unexpected error fetching replies: \(error.localizedDescription)")
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

// MARK: - Data Models

// For Message List
struct FilterCategory: Identifiable {
    let id = UUID()
    let name: String
}

struct MessageThread: Identifiable, Hashable {
    let id = UUID()
    let senderName: String
    let previewText: String
    let timestamp: String
    let imageName: String
    let isSystemImage: Bool
    let secondaryImageName: String?
    let additionalInfo: String?
    let colorGradient: LinearGradient?

     func hash(into hasher: inout Hasher) { hasher.combine(id) }
     static func == (lhs: MessageThread, rhs: MessageThread) -> Bool { lhs.id == rhs.id }
     var gradientHashValue: Int { return colorGradient != nil ? 1 : 0 }
}

// Make LinearGradient Hashable (simplified)
extension LinearGradient: @retroactive Equatable {}

extension LinearGradient: @retroactive Hashable {
    public static func == (lhs: LinearGradient, rhs: LinearGradient) -> Bool {
        return true
    }
    
    public func hash(into hasher: inout Hasher) { hasher.combine(String(describing: self)) }
}

// For Chat View
enum SenderRole {
    case user
    case model
}

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    var role: SenderRole
    var text: String
    var isError: Bool = false
}

// MARK: - Sample Data (Use the same as before)

let filterCategories = [ /* ... same data ... */ FilterCategory(name: "All"), FilterCategory(name: "Hosting"), FilterCategory(name: "Traveling"), FilterCategory(name: "Superhost Ambassador") ]
let messageThreads = [ /* ... same data ... */
    MessageThread(senderName: "Javier", previewText: "Airbnb update: Reminder - Leave a review for your stay.", timestamp: "1/21/24", imageName: "building.2", isSystemImage: true, secondaryImageName: "person.crop.circle.fill", additionalInfo: "Jan 7 – 21, 2024 · Marietta", colorGradient: nil),
    MessageThread(senderName: "Airbnb Support", previewText: "Welcome to Airbnb! Let us know if you have questions.", timestamp: "1/7/24", imageName: "airbnb.logo", isSystemImage: false, secondaryImageName: nil, additionalInfo: "Welcome", colorGradient: nil),
    MessageThread(senderName: "Airbnb Support", previewText: "This conversation closed because it was inactive.", timestamp: "1/5/24", imageName: "airbnb.logo", isSystemImage: false, secondaryImageName: nil, additionalInfo: "Closed", colorGradient: nil),
    MessageThread(senderName: "Nizar", previewText: "Checking in went smoothly! The place is great.", timestamp: "7/17/22", imageName: "house.fill", isSystemImage: true, secondaryImageName: "person.crop.circle.fill", additionalInfo: "Jul 15 – 16, 2022 · San Diego", colorGradient: nil),
    MessageThread(senderName: "Sunshine Property Management", previewText: "Hi! Just checking in to see if you need any additional amenities during your stay?", timestamp: "5/24/22", imageName: "", isSystemImage: false, secondaryImageName: nil, additionalInfo: "Superhost Ambassador", colorGradient: LinearGradient(gradient: Gradient(colors: [.orange, .pink]), startPoint: .topLeading, endPoint: .bottomTrailing))
]

// MARK: - Reusable UI Helper Views

struct AvatarView: View { /* ... same code ... */
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
struct FilterChipView: View { /* ... same code ... */
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
struct MessageRowView: View { /* ... same code ... */
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
struct ChatMessageRow: View { /* ... same code ... */
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top) {
            if message.role == .user {
                Spacer()
                Text(message.text)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .frame(maxWidth: 300, alignment: .trailing)
                     .textSelection(.enabled)

            } else {
                Text(message.text)
                    .padding(10)
                    .background(message.isError ? Color.red.opacity(0.8) : Color(.systemGray5))
                    .foregroundColor(message.isError ? .white : Color(.label))
                    .cornerRadius(12)
                    .frame(maxWidth: 300, alignment: .leading)
                    .textSelection(.enabled)
                Spacer()
            }
        }
         .padding(.vertical, 2)
    }
}

// MARK: - Gemini Chat View (Real-time Interaction)

struct GeminiChatView: View {
    @Environment(\.dismiss) var dismiss // To close the sheet

    // --- State ---
    @State private var messages: [ChatMessage] = []
    @State private var userInput: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var geminiChat: Chat? = nil // Holds the stateful chat session

    // --- Initialization ---
    init() {
        if AIConfig.geminiApiKey == "YOUR_API_KEY" || AIConfig.geminiApiKey.isEmpty {
             _errorMessage = State(initialValue: AIError.apiKeyMissing.localizedDescription)
        } else {
            let model = GenerativeModel(
                name: "gemini-1.5-flash", // Ensure this is a chat-capable model
                apiKey: AIConfig.geminiApiKey
            )
            // Start a new chat session
             let chatSession = model.startChat() // No history initially needed here
            _geminiChat = State(initialValue: chatSession)
             // Add initial greeting
             _messages = State(initialValue: [ChatMessage(role: .model, text: "Hello! Ask me anything.")])
        }
    }

    // --- Body ---
    var body: some View {
        // NOTICE: No NavigationView here as it's presented in a sheet
        // which usually gets one from the presenting view.
        // If presented differently, you might need NavigationView.
         VStack(spacing: 0) {
              // Error Display
             if let errorMsg = errorMessage {
                 Text(errorMsg)
                     .foregroundColor(.red).padding(.vertical, 5).padding(.horizontal)
                     .frame(maxWidth: .infinity).background(Color.red.opacity(0.1))
             }

             // Chat Messages
              ScrollViewReader { scrollViewProxy in
                  ScrollView {
                       VStack(alignment: .leading, spacing: 10) {
                           ForEach(messages) { message in
                               ChatMessageRow(message: message).id(message.id)
                           }
                       }
                       .padding(.horizontal).padding(.top, 10)
                  }
                  .onChange(of: messages) { _, newMessages in scrollMessages(proxy: scrollViewProxy, messages: newMessages) }
                  .onAppear { scrollMessages(proxy: scrollViewProxy, messages: messages) } // Scroll on appear
              }

             Divider()

             // Input Area
             inputArea
         }
         .navigationTitle("Gemini Chat") // Title for the sheet's nav bar
         .navigationBarTitleDisplayMode(.inline)
         .toolbar { // Add a dismiss button
             ToolbarItem(placement: .navigationBarTrailing) {
                 Button("Done") {
                     dismiss()
                 }
             }
         }
          .onTapGesture { hideKeyboard() } // Dismiss keyboard
    }

    // --- Computed View for Input Area ---
    private var inputArea: some View {
        HStack(spacing: 10) {
            TextField("Type your message...", text: $userInput, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...5)
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(Color(.systemGray6)).cornerRadius(18)

            if isLoading {
                ProgressView().padding(.horizontal, 10)
            } else {
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable().frame(width: 30, height: 30)
                        .foregroundColor(isSendButtonDisabled ? .gray : .accentColor) // Use AccentColor
                }
                .disabled(isSendButtonDisabled)
                .transition(.scale)
            }
        }
        .padding(.horizontal).padding(.vertical, 8)
        .background(.thinMaterial)
    }

    // --- Computed Property ---
    private var isSendButtonDisabled: Bool {
        userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading || geminiChat == nil // Disable if chat not init
    }

    // --- Methods ---
    func sendMessage() {
         guard !isSendButtonDisabled else { return }
         guard let chat = geminiChat else {
             errorMessage = "Chat session not initialized. Check API Key."
             return
         }

         let userMsgText = userInput
         messages.append(ChatMessage(role: .user, text: userMsgText))
         userInput = ""
         isLoading = true
         errorMessage = nil

         Task {
             do {
                 print("--- Sending to Gemini Chat ---")
                 print("User: \(userMsgText)")
                 let response = try await chat.sendMessage(userMsgText)
                 print("--- Received from Gemini Chat ---")

                 await MainActor.run {
                    isLoading = false
                    if let modelText = response.text {
                        print("Model: \(modelText)")
                        messages.append(ChatMessage(role: .model, text: modelText))
                    } else {
                        let errorMsg = "Gemini response empty/blocked."
                        print(errorMsg)
                        messages.append(ChatMessage(role: .model, text: errorMsg, isError: true))
                        errorMessage = errorMsg
                     }
                 }
             } catch {
                 print("Error sending chat message: \(error)")
                 await MainActor.run {
                     isLoading = false
                     let errorText = "Error: \(error.localizedDescription)"
                     errorMessage = errorText
                     messages.append(ChatMessage(role: .model, text: errorText, isError: true))
                 }
             }
         }
    }

       // Helper to scroll to the bottom
     private func scrollMessages(proxy: ScrollViewProxy, messages: [ChatMessage]) {
         if let lastMessage = messages.last {
             withAnimation(.easeOut(duration: 0.3)) { // Add smooth animation
                 proxy.scrollTo(lastMessage.id, anchor: .bottom)
             }
         }
     }

    private func hideKeyboard() {
         UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
     }
}

// MARK: - Main Messages View with Smart Replies & Chat Button

struct AirbnbMessagesView: View {
    // --- State ---
    @State private var selectedFilter: String = "All"
    @State private var selectedThread: MessageThread? = nil // For Smart Replies
    @State private var smartReplies: [String] = []          // For Smart Replies
    @State private var isLoadingReplies: Bool = false       // For Smart Replies
    @State private var replyErrorMessage: String? = nil     // For Smart Replies
    @State private var isShowingChatSheet = false          // To present GeminiChatView

    // --- Smart Reply Fetch Logic ---
    private func fetchReplies(for thread: MessageThread) {
        guard AIConfig.geminiApiKey != "YOUR_API_KEY" else {
            replyErrorMessage = AIError.apiKeyMissing.localizedDescription
            return
        }
        isLoadingReplies = true
        selectedThread = thread
        replyErrorMessage = nil
        smartReplies = []

        Task {
            do {
                let replies = try await AIService.fetchSmartReplies(for: thread.previewText)
                await MainActor.run { self.smartReplies = replies; self.isLoadingReplies = false }
            } catch {
                await MainActor.run {
                    self.replyErrorMessage = error.localizedDescription
                    print("Error fetching replies: \(error)")
                    self.isLoadingReplies = false
                }
            }
        }
    }

    // --- Body ---
    var body: some View {
        NavigationStack {
             ZStack(alignment: .bottomTrailing) { // ZStack for floating button
                VStack(alignment: .leading, spacing: 0) {
                     // Title
                     Text("Messages")
                         .font(.largeTitle).fontWeight(.bold)
                         .padding(.horizontal).padding(.bottom, 8)

                     // Filter Chips
                     filterChipsScrollView

                    // Message List
                    messageList

                     // Smart Replies Section (conditionally shown)
                     smartRepliesSection
                         .padding(.bottom, 60) // Add padding so FAB doesn't overlap replies too much
                 } // End Main VStack

                 // Floating Action Button (FAB) to open Chat
                 floatingChatButton
             } // End ZStack
             .toolbar { standardToolbar } // Reuse toolbar definition
             .navigationBarTitleDisplayMode(.inline)
             .animation(.default, value: selectedThread) // Animate smart reply section appearance
             // --- Modal Sheet Presentation ---
             .sheet(isPresented: $isShowingChatSheet) {
                 GeminiChatView()
                    // Add presentation detents if desired (iOS 16+)
                     // .presentationDetents([.medium, .large])
             }
        } // End NavigationStack
    }

    // --- Computed View Components for AirbnbMessagesView Body ---

    private var filterChipsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filterCategories) { category in
                    FilterChipView(category: category, isSelected: selectedFilter == category.name) {
                        selectedFilter = category.name
                        // Deselect thread when filter changes
                        selectedThread = nil
                        smartReplies = []
                        replyErrorMessage = nil
                    }
                }
            }
            .padding(.horizontal).padding(.bottom, 12)
        }
    }

    private var messageList: some View {
        List {
            ForEach(messageThreads) { thread in
                MessageRowView(thread: thread)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowSeparator(.hidden)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedThread == thread {
                            selectedThread = nil; smartReplies = []; replyErrorMessage = nil // Deselect
                        } else {
                            fetchReplies(for: thread) // Select and Fetch
                        }
                    }
                    .listRowBackground(selectedThread == thread ? Color.gray.opacity(0.1) : Color.clear)
                    .animation(.easeInOut(duration: 0.2), value: selectedThread)
            }
        }
        .listStyle(.plain)
        .padding(.top, -8)
    }

    @ViewBuilder // Use @ViewBuilder if logic gets complex
    private var smartRepliesSection: some View {
         if selectedThread != nil {
             VStack(alignment: .leading) {
                 Divider().padding(.bottom, 8)

                 if isLoadingReplies {
                     HStack { Spacer(); ProgressView().padding(.vertical, 10); Spacer() }
                 } else if let errorMsg = replyErrorMessage {
                     Text("Error: \(errorMsg)")
                         .foregroundColor(.red).font(.caption).padding(.horizontal).padding(.bottom, 5)
                 } else if !smartReplies.isEmpty {
                     Text("Smart Replies:").font(.caption).foregroundColor(.gray).padding(.bottom, 2)
                     ScrollView(.horizontal, showsIndicators: false) {
                         HStack {
                             ForEach(smartReplies, id: \.self) { reply in
                                 Button { print("Selected reply: \(reply)") /* TODO: Use reply */ } label: {
                                     Text(reply).font(.caption)
                                         .padding(.horizontal, 12).padding(.vertical, 6)
                                         .background(Color(.systemGray5)).foregroundColor(.primary)
                                         .clipShape(Capsule())
                                 }
                             }
                         }
                     }
                     .padding(.bottom, 10)
                 }
             }
             .padding(.horizontal)
             .transition(.move(edge: .bottom).combined(with: .opacity))
             .animation(.easeInOut, value: isLoadingReplies)
             .animation(.easeInOut, value: smartReplies)
         }
    }

    private var floatingChatButton: some View {
        Button {
            isShowingChatSheet = true // Open the chat sheet
        } label: {
            Image(systemName: "bubble.left.and.bubble.right.fill") // Chat icon
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .padding(15)
                .background(Color.blue) // Choose a suitable color
                .foregroundColor(.white)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
        .padding(20) // Padding from the edge
    }

    private var standardToolbar: some ToolbarContent {
         ToolbarItemGroup(placement: .navigationBarTrailing) {
             Button { } label: {
                 Image(systemName: "magnifyingglass")
                     .padding(8).background(Color(.systemGray5)).clipShape(Circle()).foregroundColor(.black)
             }
             Button { } label: {
                  Image(systemName: "line.3.horizontal.decrease.circle")
                    .padding(8).background(Color(.systemGray5)).clipShape(Circle()).foregroundColor(.black)
             }
         }
    }
}

// MARK: - Main App Structure with TabView (Entry Point)

struct MainTabView: View {
    @State private var selectedTab: Int = 3

    init() {
        // Optional: Customize Tab Bar appearance
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        // UITabBar.appearance().backgroundColor = UIColor.systemGray6 // Example background
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Explore Screen").tabItem { Label("Explore", systemImage: "magnifyingglass") }.tag(0)
            Text("Wishlists Screen").tabItem { Label("Wishlists", systemImage: "heart") }.tag(1)
            Text("Trips Screen").tabItem { Label("Trips", systemImage: "airplane") }.tag(2)

            // Embed the enhanced AirbnbMessagesView
            AirbnbMessagesView()
                .tabItem {
                    Label { Text("Messages") } icon: {
                        ZStack {
                            Image(systemName: "message")
                            // Simple notification dot example
                            Circle().fill(Color.red).frame(width: 6, height: 6).offset(x: 8, y: -8)
                        }
                    }
                }
                .tag(3)

            Text("Profile Screen").tabItem { Label("Profile", systemImage: "person.crop.circle") }.tag(4)
        }
        .tint(.pink) // Set accent color for selected tab item
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
    // Previewing AirbnbMessagesView directly can be useful during development:
    // AirbnbMessagesView()
    // Previewing GeminiChatView directly:
    // GeminiChatView()
}
