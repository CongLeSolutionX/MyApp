////
////  DiscoverView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//import SwiftUI
//
//// MARK: - Data Models
//
//struct Assistant: Identifiable, Hashable { // Ensure Hashable for NavigationStack value
//    let id = UUID()
//    let title: String
//    let authorIconName: String // System icon names for simplicity
//    let authorName: String
//    let date: String
//    let description: String
//    let tagIconName: String // System icon names
//    let tagText: String
//    let bannerGradient: Gradient
//    let bannerIconName: String // Assume these are custom image names in Assets
//
//    // Expanded Sample Data
//    static let sampleData: [Assistant] = [
//        Assistant(
//           title: "学术论文综述专家", authorIconName: "person.crop.circle", authorName: "Le", date: "2025-03-11",
//           description: "擅长高质量文献检索与分析的学术研究助手", tagIconName: "graduationcap.fill", tagText: "Academic",
//           bannerGradient: Gradient(colors: [Color.green.opacity(0.8), Color.cyan.opacity(0.6)]), bannerIconName: "My-meme-heineken" // Needs Asset
//       ),
//       Assistant(
//           title: "Cron Expression Assistant", authorIconName: "person.crop.circle.badge.moon", authorName: "Nguyen", date: "2025-02-17",
//           description: "Crontab Expression Generator for scheduling tasks.", tagIconName: "terminal.fill", tagText: "Programming",
//           bannerGradient: Gradient(colors: [Color.pink.opacity(0.7), Color.purple.opacity(0.8)]), bannerIconName: "My-meme-microphone" // Needs Asset
//       ),
//       Assistant(
//           title: "Xiao Zhi French Translation", authorIconName: "person.crop.circle.fill.badge.checkmark", authorName: "Khoa", date: "2025-02-10",
//           description: "A friendly guide for translation & exploration.", tagIconName: "character.bubble.fill", tagText: "Language",
//           bannerGradient: Gradient(colors: [Color.blue.opacity(0.8), Color.red.opacity(0.7)]), bannerIconName: "My-meme-red-wine-glass" // Needs Asset
//       ),
//       Assistant(
//            title: "Recipe Recommender", authorIconName: "figure.cook", authorName: "ChefAI", date: "2025-04-01",
//            description: "Find recipes based on ingredients you have.", tagIconName: "fork.knife", tagText: "Cooking",
//            bannerGradient: Gradient(colors: [Color.orange.opacity(0.8), Color.yellow.opacity(0.6)]), bannerIconName: "My-meme-with-cap-2" // Placeholder name
//        ),
//        Assistant(
//            title: "Workout Planner", authorIconName: "figure.strengthtraining.traditional", authorName: "FitBot", date: "2025-03-20",
//            description: "Generates personalized workout routines.", tagIconName: "figure.run", tagText: "Fitness",
//            bannerGradient: Gradient(colors: [Color.teal.opacity(0.7), Color.blue.opacity(0.7)]), bannerIconName: "My-meme-orange_2" // Placeholder name
//        ),
//        Assistant(
//            title: "Story Generator", authorIconName: "pencil.and.scribble", authorName: "Narrator", date: "2025-04-15",
//            description: "Create unique short stories based on prompts.", tagIconName: "book.closed.fill", tagText: "Creative",
//            bannerGradient: Gradient(colors: [Color.indigo.opacity(0.8), Color.purple.opacity(0.6)]), bannerIconName: "My-meme-original" // Placeholder name
//        )
//    ]
//}
//
//struct Message: Identifiable {
//    let id = UUID()
//    let text: String
//    let isUser: Bool
//    let timestamp: Date = Date()
//}
//
//// MARK: - Main Content View (Using NavigationStack)
//
//struct ContentView: View {
//    @State private var selectedTab: Int = 1 // Default to Discover
//    @State private var isShowingSideMenu = false
//    // Removed isShowingSearchView, search is now integrated
//
//    // Hold the canonical data source here
//    @State private var allAssistants = Assistant.sampleData
//
//    init() {
//        // Appearance Setup (Keep as is)
//         let tabBarAppearance = UITabBarAppearance()
//         tabBarAppearance.configureWithOpaqueBackground()
//         tabBarAppearance.backgroundColor = UIColor(Color(white: 0.1))
//         UITabBar.appearance().standardAppearance = tabBarAppearance
//         UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
//         UITabBar.appearance().unselectedItemTintColor = UIColor.gray
//
//         let navBarAppearance = UINavigationBarAppearance()
//         navBarAppearance.configureWithOpaqueBackground()
//         navBarAppearance.backgroundColor = UIColor.black
//         navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
//         navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//         UINavigationBar.appearance().standardAppearance = navBarAppearance
//         UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
//         UINavigationBar.appearance().compactAppearance = navBarAppearance
//         UINavigationBar.appearance().tintColor = .yellow // Global tint for bar buttons if not overridden
//    }
//
//    var body: some View {
//        // Use NavigationStack for modern navigation
//        NavigationStack {
//            TabView(selection: $selectedTab) {
//                // --- Chat Tab ---
//                ChatView()
//                    .tabItem { Label("Chat", systemImage: "message") }
//                    .tag(0)
//
//                // --- Discover Tab ---
//                DiscoverView(assistants: allAssistants) // Pass full list
//                    .tabItem { Label("Discover", systemImage: "safari") }
//                    .tag(1)
//
//                // --- Me Tab ---
//                ProfileView()
//                    .tabItem { Label("Me", systemImage: "person") }
//                    .tag(2)
//            }
//            // Toolbar applies to the content *inside* the NavigationStack
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                     Button { isShowingSideMenu = true } label: {
//                         Image(systemName: "line.3.horizontal")
//                     }
//                 }
//                 // Removed Search Toolbar Item
//            }
//            .navigationTitle(navigationTitle) // Dynamic title based on tab
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbarBackground(.black, for: .navigationBar)
//            .toolbarBackground(.visible, for: .navigationBar)
//            .toolbarColorScheme(.dark, for: .navigationBar)
//            // --- Navigation Destinations (for NavigationStack) ---
//            .navigationDestination(for: Assistant.self) { assistant in
//                AssistantDetailView(assistant: assistant)
//            }
//            .navigationDestination(for: String.self) { destination in
//                // Handle string-based navigation from Side Menu etc.
//                switch destination {
//                case "AllAssistants": AllAssistantsView(assistants: allAssistants)
//                case "Settings": SettingsView()
//                // Add other destinations as needed
//                default: Text("Unknown Destination: \(destination)")
//                }
//            }
//            // --- Modal Sheet ---
//            .sheet(isPresented: $isShowingSideMenu) {
//                SideMenuView()
//            }
//        }
//        .accentColor(.yellow) // Tint for selected tab item, links, buttons
//    }
//
//    // Helper to determine navigation title based on selected tab
//    private var navigationTitle: String {
//        switch selectedTab {
//        case 0: return "Chat"
//        case 1: return "Home"
//        case 2: return "Profile"
//        default: return "App"
//        }
//    }
//}
//
//// MARK: - Enhanced Tab Views
//
//// --- CHAT VIEW ---
//struct ChatView: View {
//    @State private var messages: [Message] = [
//        Message(text: "Hello! How can I help you today?", isUser: false),
//        Message(text: "What's the weather like?", isUser: true),
//        Message(text: "Fetching weather... It looks sunny! ☀️", isUser: false)
//    ]
//    @State private var newMessageText: String = ""
//
//    var body: some View {
//        VStack {
//            // --- Message Display Area ---
//            ScrollViewReader { scrollViewProxy in // To scroll to bottom
//                 ScrollView {
//                     LazyVStack(spacing: 12) { // LazyVStack for performance
//                         ForEach(messages) { message in
//                             MessageBubble(message: message)
//                                 .id(message.id) // Needed for scrolling
//                         }
//                     }
//                     .padding(.horizontal)
//                     .padding(.top)
//                 }
//                 .onChange(of: messages.count) { // Scroll when message count changes
//                       withAnimation {
//                           scrollViewProxy.scrollTo(messages.last?.id, anchor: .bottom)
//                       }
//                 }
//            }
//
//            // --- Input Area ---
//            HStack {
//                TextField("Type your message...", text: $newMessageText, axis: .vertical) // Allow vertical expansion
//                    .textFieldStyle(.plain)
//                    .padding(10)
//                    .background(Color(white: 0.15))
//                    .cornerRadius(18)
//                    .lineLimit(1...5) // Limit lines
//
//                Button {
//                    sendMessage()
//                } label: {
//                    Image(systemName: "arrow.up.circle.fill")
//                         .resizable()
//                         .frame(width: 30, height: 30)
//                         .foregroundColor(newMessageText.isEmpty ? .gray : .yellow)
//                }
//                .disabled(newMessageText.isEmpty)
//            }
//            .padding()
//            .background(Color(white: 0.1)) // Input area background
//        }
//        .background(Color.black.ignoresSafeArea()) // Main background
//        .foregroundColor(.white)
//        .onAppear {
//            // Optional: Load initial messages or setup
//        }
//    }
//
//    func sendMessage() {
//        guard !newMessageText.isEmpty else { return }
//        let userMessage = Message(text: newMessageText, isUser: true)
//        messages.append(userMessage)
//        let responseText = generateMockResponse(to: newMessageText)
//        let responseMessage = Message(text: responseText, isUser: false)
//
//        // Simulate network delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
//             messages.append(responseMessage)
//        }
//        newMessageText = "" // Clear input field
//    }
//
//    // Simple mock response generator
//     func generateMockResponse(to input: String) -> String {
//         let lowercasedInput = input.lowercased()
//         if lowercasedInput.contains("hello") || lowercasedInput.contains("hi") {
//             return "Hi there! 👋"
//         } else if lowercasedInput.contains("how are you") {
//             return "I'm doing great, thanks for asking! Ready to help."
//         } else if lowercasedInput.contains("weather") {
//             return "The forecast shows clear skies and a gentle breeze. Perfect day! 🌤️"
//         } else if lowercasedInput.contains("help") {
//             return "Sure, what do you need assistance with?"
//         } else {
//             return "Interesting point! Tell me more. (Simulated)"
//         }
//     }
//}
//
//// Helper View for Chat Bubbles
//struct MessageBubble: View {
//    let message: Message
//
//    var body: some View {
//        HStack {
//            if message.isUser { Spacer() } // Push user messages right
//
//            Text(message.text)
//                .padding(12)
//                .background(message.isUser ? Color.yellow.opacity(0.9) : Color(white: 0.25))
//                .foregroundColor(message.isUser ? .black : .white)
//                .cornerRadius(15)
//                .frame(maxWidth: 300, alignment: message.isUser ? .trailing : .leading) // Limit bubble width
//
//            if !message.isUser { Spacer() } // Push assistant messages left
//        }
//    }
//}
//
//// --- DISCOVER VIEW ---
//struct DiscoverView: View {
//    let assistants: [Assistant] // Full list passed in
//    @State private var searchText = ""
//
//    // Computed property for filtering based on search text
//    var filteredAssistants: [Assistant] {
//        if searchText.isEmpty {
//            // Show only featured (e.g., first 3) when not searching
//            // Or return all if you want Discover to show all initially
//             return Array(assistants.prefix(3)) // Example: Show first 3 as featured
//            // return assistants // Uncomment to show all initially
//        } else {
//            // Filter the entire list when searching
//            return assistants.filter {
//                $0.title.localizedCaseInsensitiveContains(searchText) ||
//                $0.description.localizedCaseInsensitiveContains(searchText) ||
//                $0.tagText.localizedCaseInsensitiveContains(searchText)
//            }
//        }
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 15) {
//                // --- Header ---
//                HStack {
//                    Text(searchText.isEmpty ? "Featured Assistants" : "Search Results")
//                         .font(.title2)
//                         .fontWeight(.bold)
//                         .padding(.leading)
//                         .id("Header") // Add ID for potential future use
//
//                    Spacer()
//
//                    // Conditionally show "Discover More" only if not searching
//                    if searchText.isEmpty {
//                        // Use NavigationLink with value for NavigationStack
//                        NavigationLink(value: "AllAssistants") {
//                             HStack(spacing: 4) {
//                                 Text("Discover More")
//                                     .font(.subheadline)
//                                 Image(systemName: "chevron.right")
//                                     .font(.caption.weight(.bold))
//                             }
//                             .foregroundColor(.gray)
//                             .padding(.trailing)
//                        }
//                    }
//                }
//                .padding(.top)
//
//                // --- Assistant Cards ---
//                // Display filtered assistants
//                ForEach(filteredAssistants) { assistant in
//                     // NavigationLink with value for NavigationStack
//                     NavigationLink(value: assistant) {
//                         AssistantCardView(assistant: assistant)
//                     }
//                     .buttonStyle(.plain)
//                     .padding(.horizontal)
//                 }
//                 .padding(.bottom) // Padding at the end of the list
//                 .animation(.default, value: filteredAssistants) // Animate changes
//            }
//         }
//         .background(Color.black.ignoresSafeArea())
//         .foregroundColor(.white)
//         .searchable(text: $searchText, prompt: "Search Assistants...") // Integrated search bar
//         .refreshable {
//            // Optional: Add logic to refresh assistant data
//            print("Refreshing assistants...")
//            // await viewModel.fetchAssistants() // Example if using a ViewModel
//         }
//    }
//}
//
//// --- PROFILE VIEW ---
//struct ProfileView: View {
//    @State private var isNotificationsEnabled = true
//    @State private var isDarkModeEnabled = true // Assuming UI reflects this
//    @State private var username = "iOSDev_AI_User"
//    @State private var email = "developer@example.ai"
//
//    var body: some View {
//        Form { // Use Form for standard settings layout
//             Section("Account Info") {
//                HStack {
//                   Image(systemName: "person.crop.circle.fill")
//                       .resizable()
//                       .frame(width: 60, height: 60)
//                       .foregroundColor(.yellow)
//                   VStack(alignment: .leading) {
//                       Text(username).font(.title2)
//                       Text(email).font(.callout).foregroundColor(.gray)
//                   }
//                }
//                Button("Edit Profile") { /* Add action */ }
//             }
//
//             Section("Settings") {
//                 Toggle(isOn: $isNotificationsEnabled) {
//                     Label("Enable Notifications", systemImage: "bell.badge.fill")
//                 }
//                 .tint(.yellow) // Toggle color
//
//                 Toggle(isOn: $isDarkModeEnabled) {
//                     Label("Dark Mode", systemImage: "moon.fill")
//                 }
//                 .tint(.yellow)
//                 .disabled(true) // Example: Disabled as it's likely Theme-based
//
//                 NavigationLink(value: "Settings") { // Use value for NavigationStack
//                    Label("Advanced Settings", systemImage: "gearshape.2.fill")
//                 }
//             }
//
//             Section { // Separate section for logout
//                 Button("Logout", role: .destructive) {
//                     // Add actual logout logic here
//                     print("Logout action triggered")
//                 }
//             }
//        }
//        .background(Color.black.ignoresSafeArea()) // Try to force black background
//        .scrollContentBackground(.hidden) // Make Form background transparent
//        .foregroundColor(.white) // Default text color for Form content
//    }
//}
//
//// MARK: - Destination & Modal Views (Enhanced)
//
//// --- ALL ASSISTANTS VIEW ---
//struct AllAssistantsView: View {
//    let assistants: [Assistant]
//    @State private var searchText = ""
//
//    var filteredAssistants: [Assistant] {
//         if searchText.isEmpty {
//             return assistants
//         } else {
//             return assistants.filter {
//                 $0.title.localizedCaseInsensitiveContains(searchText) ||
//                 $0.description.localizedCaseInsensitiveContains(searchText) ||
//                 $0.tagText.localizedCaseInsensitiveContains(searchText)
//             }
//         }
//     }
//
//    var body: some View {
//        // Use List for better performance with large datasets & standard row separators
//        List {
//            ForEach(filteredAssistants) { assistant in
//                // Use value-based NavigationLink
//                NavigationLink(value: assistant) {
//                    // Use AssistantCardView directly for consistency, remove list row background
//                    AssistantCardView(assistant: assistant)
//                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 16)) // Adjust padding
//                        .padding(.vertical, 4) // Add vertical padding between cards in list
//                }
//                 .listRowBackground(Color.black) // Make row background black
//            }
//        }
//        .listStyle(.plain) // Use plain style to remove default List styling
//        .background(Color.black.ignoresSafeArea())
//        .navigationTitle("All Assistants")
//        .navigationBarTitleDisplayMode(.inline)
//        .searchable(text: $searchText, prompt: "Search All Assistants...")
//    }
//}
//
//// --- ASSISTANT DETAIL VIEW ---
//struct AssistantDetailView: View {
//    let assistant: Assistant
//    @State private var showingStartChatAlert = false
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 0) { // Reduce spacing for banner merge
//                 // Top Banner Area
//                 LinearGradient(gradient: assistant.bannerGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
//                     .frame(height: 180)
//                     .overlay(
//                         Image(assistant.bannerIconName) // Ensure this asset exists
//                             .resizable()
//                             .aspectRatio(contentMode: .fit)
//                             .frame(height: 110)
//                             .shadow(color: .black.opacity(0.4), radius: 6, y: 4)
//                             .padding(.bottom, 20) // Add padding to lift icon visually
//                         , alignment: .center
//                     )
//                     .clipped() // Clip the overlay image to the banner bounds
//
//                 // Content Area
//                 VStack(alignment: .leading, spacing: 15) {
//                     Text(assistant.title)
//                         .font(.largeTitle)
//                         .fontWeight(.bold)
//                         .padding(.top) // Space below banner
//
//                     HStack {
//                         Image(systemName: assistant.authorIconName)
//                             .foregroundColor(.gray).clipShape(Circle())
//                         Text("By \(assistant.authorName)").font(.subheadline)
//                         Spacer()
//                         Text(assistant.date).font(.subheadline)
//                     }.foregroundColor(.gray)
//
//                     Divider().padding(.vertical, 5)
//
//                     Text("Description").font(.title2).fontWeight(.semibold)
//                     Text(assistant.description).font(.body)
//
//                     HStack {
//                         Text("Category:")
//                         Image(systemName: assistant.tagIconName)
//                         Text(assistant.tagText)
//                     }
//                     .font(.caption)
//                     .padding(8)
//                     .background(Color.white.opacity(0.15))
//                     .cornerRadius(8)
//                     .foregroundColor(Color.white.opacity(0.8))
//
//                     Spacer(minLength: 20) // Push button down
//
//                     // --- Action Button ---
//                      Button {
//                          showingStartChatAlert = true
//                          // TBD: Implement actual navigation or action to start chat
//                          print("Start Chat with \(assistant.title) Tapped")
//                      } label: {
//                          Text("Start Chat")
//                              .font(.headline)
//                              .fontWeight(.semibold)
//                              .frame(maxWidth: .infinity)
//                              .padding()
//                              .background(Color.yellow)
//                              .foregroundColor(.black)
//                              .cornerRadius(12)
//                      }
//                     .padding(.bottom)
//
//                 }
//                 .padding(.horizontal) // Padding for the text content
//
//             }
//        }
//        .background(Color.black.ignoresSafeArea())
//        .foregroundColor(.white)
//        .navigationTitle(assistant.title)
//        .navigationBarTitleDisplayMode(.inline)
//        .ignoresSafeArea(edges: .top) // Allow banner to go under status bar
//        .alert("Start Chatting", isPresented: $showingStartChatAlert) {
//             Button("OK", role: .cancel) { }
//         } message: {
//             Text("You tapped 'Start Chat' for \(assistant.title). This feature is not yet implemented.")
//         }
//    }
//}
//
//// --- SIDE MENU VIEW ---
//struct SideMenuView: View {
//    @Environment(\.dismiss) var dismiss
//
//    var body: some View {
//        // NavigationStack inside the sheet for its own navigation
//        NavigationStack {
//             List {
//                Section("Main") {
//                   // Use NavigationLink(value:) for NavigationStack
//                   NavigationLink(value: "ProfileViewLink") { // Use unique string value
//                      Label("Profile", systemImage: "person.crop.circle")
//                   }
//                   NavigationLink(value: "AllAssistants") { // Route to All Assistants
//                      Label("All Assistants", systemImage: "square.grid.2x2.fill")
//                   }
//                }
//
//                Section("More") {
//                     NavigationLink(value: "Settings") {
//                         Label("Settings", systemImage: "gear")
//                     }
//                     Button { /* About action */ dismiss() } label: {
//                         Label("About", systemImage: "info.circle")
//                     }
//                     Button(role: .destructive) { /* Logout action */ dismiss() } label: {
//                         Label("Logout", systemImage: "arrow.backward.square")
//                     }
//                }
//             }
//             .listStyle(.insetGrouped) // Style that looks good in sheets
//             .background(Color(white: 0.08).ignoresSafeArea())
//             .scrollContentBackground(.hidden)
//             .navigationTitle("Menu")
//             .navigationBarTitleDisplayMode(.inline)
//             .toolbar {
//                 ToolbarItem(placement: .navigationBarTrailing) {
//                     Button("Done") { dismiss() }
//                 }
//             }
//             // Handle navigation destinations *specific* to the side menu sheet
//             .navigationDestination(for: String.self) { destination in
//                 // Note: Navigation to ProfileView doesn't work directly here easily
//                 // because it's a main Tab. Typically you'd change the selectedTab.
//                 // For now, link to a placeholder or settings.
//                  switch destination {
//                  case "ProfileViewLink": ProfileView() // Or link to settings if profile is complex
//                  case "Settings": SettingsView()
//                  case "AllAssistants": AllAssistantsView(assistants: Assistant.sampleData) // Show all here too
//                  default: Text("Unknown Side Menu Destination")
//                  }
//             }
//             .toolbarBackground(Color(white: 0.15), for: .navigationBar)
//             .toolbarBackground(.visible, for: .navigationBar)
//             .toolbarColorScheme(.dark, for: .navigationBar) // Ensure bar items are light
//        }
//        .accentColor(.yellow) // Consistent accent color
//    }
//}
//
//// --- SETTINGS VIEW (Placeholder Destination) ---
//struct SettingsView: View {
//     var body: some View {
//         ZStack {
//             Color.black.ignoresSafeArea()
//             VStack {
//                  Text("Advanced Settings")
//                      .font(.title)
//                      .padding(.bottom)
//                  Text("More configuration options would go here.")
//                      .foregroundColor(.gray)
//                  Spacer()
//             }
//             .padding()
//             .foregroundColor(.white)
//         }
//         .navigationTitle("Settings")
//         .navigationBarTitleDisplayMode(.inline)
//     }
//}
//
//// MARK: - Assistant Card View (No Changes Needed)
//
//struct AssistantCardView: View {
//     let assistant: Assistant
//     let cardCornerRadius: CGFloat = 15
//     let bannerHeight: CGFloat = 85
//
//     var body: some View {
//          ZStack(alignment: .topTrailing) {
//              // Banner (Behind)
//              LinearGradient(gradient: assistant.bannerGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
//                  .frame(height: bannerHeight)
//                  .clipShape(UnevenRoundedRectangle(topLeadingRadius: cardCornerRadius, topTrailingRadius: cardCornerRadius)) // Use Uneven for top corners only
//
//              // Content (Above Banner)
//              VStack(alignment: .leading, spacing: 8) {
//                   Spacer().frame(height: bannerHeight * 0.65) // Push content below banner gradient peak
//
//                  Text(assistant.title)
//                       .font(.headline)
//                       .fontWeight(.semibold)
//                       .lineLimit(1)
//
//                  HStack(spacing: 6) {
//                       Image(systemName: assistant.authorIconName) // Use system icons
//                           .resizable().scaledToFit().frame(width: 18, height: 18)
//                           .foregroundColor(.gray).clipShape(Circle())
//                           .padding(1) // Add tiny padding if icon looks cramped
//                           .background(Circle().fill(Color.white.opacity(0.1))) // Subtle background
//                       Text(assistant.authorName)
//                       Text("• \(assistant.date)").lineLimit(1) // Add separator, ensure date fits
//                   }
//                   .font(.caption).foregroundColor(.gray)
//
//                  Text(assistant.description)
//                       .font(.subheadline)
//                       .lineLimit(2)
//                       .fixedSize(horizontal: false, vertical: true) // Allow text wrap
//                       .foregroundColor(.secondary) // Slightly dimmer than primary text
//
//                  HStack(spacing: 5) {
//                       Image(systemName: assistant.tagIconName) // Use system icons
//                           .font(.caption2)
//                       Text(assistant.tagText)
//                  }
//                  .font(.caption)
//                  .padding(.horizontal, 8)
//                 // .padding(.vectorial(4)
//                  .background(Color.white.opacity(0.15))
//                  .cornerRadius(5)
//              //    .foregroundColor(Color.white.opacity(0.8))
//
//                 //  Spacer() // Use remaining space
//               }
//               .padding(EdgeInsets(top: 10, leading: 15, bottom: 15, trailing: 15))
//               .frame(maxWidth: .infinity, alignment: .leading)
//               // Main card background AFTER content elements are defined
//               .background(.ultraThinMaterial) // Apply frosted glass effect over banner
//               .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius)) // Clip the whole vstack
//               .overlay( // Add border for definition
//                    RoundedRectangle(cornerRadius: cardCornerRadius)
//                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
//               )
//
//              // Banner Icon (Topmost Layer)
//              Image(assistant.bannerIconName) // Make sure these images exist in Assets.xcassets
//                   .resizable()
//                   .aspectRatio(contentMode: .fit)
//                   .frame(width: 55, height: 55)
//                   .shadow(color: .black.opacity(0.3) ,radius: 4, x: 0, y: 2)
//                   .offset(x: -15, y: bannerHeight - 27.5) // Position relative to banner bottom-right
//
//          }
//          .fixedSize(horizontal: false, vertical: true) // Ensure card sizes correctly
//     }
//}
//
//// MARK: - Preview
//
//#Preview { // Use modern #Preview macro
//    ContentView()
//        .preferredColorScheme(.dark)
//}
