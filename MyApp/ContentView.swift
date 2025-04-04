////
////  ContentView.swift
////  MyApp
////
////  Created by Cong Le on 8/19/24.
////
////
////import SwiftUI
////
////// Step 2: Use in SwiftUI view
////struct ContentView: View {
////    var body: some View {
////        UIKitViewControllerWrapper()
////            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
////    }
////}
////
////// Before iOS 17, use this syntax for preview UIKit view controller
////struct UIKitViewControllerWrapper_Previews: PreviewProvider {
////    static var previews: some View {
////        UIKitViewControllerWrapper()
////    }
////}
////
////// After iOS 17, we can use this syntax for preview:
////#Preview {
////    ContentView()
////}
//
//import SwiftUI
//import Combine // Required for ObservableObject
//
//// MARK: - Data Models (Phase 1)
//
//struct User: Identifiable, Codable, Hashable {
//    let id: UUID
//    var username: String
//    var bio: String?
//    var profileImageURL: URL? // Use optional URL for profile images
//    var following: [UUID] = [] // IDs of users this user follows
//    var followers: [UUID] = [] // IDs of users following this user
//    
//    // Sample Data (Replace with actual data fetching)
//    static var sampleUser1 = User(id: UUID(), username: "BuildMasterPro", bio: "Crafting dream homes since 2005. Quality & Precision.", profileImageURL: URL(string: "https://via.placeholder.com/150/FFA07A/000000?text=BMP"))
//    static var sampleUser2 = User(id: UUID(), username: "DesignBuildInspire", bio: "Innovative designs meet expert construction.", profileImageURL: URL(string: "https://via.placeholder.com/150/ADD8E6/000000?text=DBI"))
//    static var sampleUser3 = User(id: UUID(), username: "HomeownerHub", bio: "Planning my next big renovation!", profileImageURL: URL(string: "https://via.placeholder.com/150/90EE90/000000?text=HH"))
//    
//    static var loggedInUser = sampleUser1 // Simulate logged-in user for MVP
//}
//
//struct Post: Identifiable, Codable, Hashable {
//    let id: UUID
//    let authorID: UUID // Link to the User who created the post
//    let text: String
//    let imageURLs: [URL]? // Array of optional URLs for post images
//    let timestamp: Date
//    var locationTag: String? // Optional location name
//    
//    // Sample Data
//    static var samplePosts: [Post] = [
//        Post(id: UUID(), authorID: User.sampleUser1.id, text: "Just finished framing this beauty! Solid structure coming along nicely. #framing #construction #newbuild", imageURLs: [URL(string:"https://via.placeholder.com/600/FFA07A/FFFFFF?text=Frame+1")!], timestamp: Date().addingTimeInterval(-3600), locationTag: "Sunnyvale Project"),
//        Post(id: UUID(), authorID: User.sampleUser2.id, text: "Kitchen transformation complete! Loving these custom cabinets and quartz countertops. What do you think?", imageURLs: [URL(string:"https://via.placeholder.com/600/ADD8E6/FFFFFF?text=Kitchen+1")!, URL(string:"https://via.placeholder.com/600/ADD8E6/FFFFFF?text=Kitchen+2")!], timestamp: Date().addingTimeInterval(-7200), locationTag: "Downtown Loft Reno"),
//        Post(id: UUID(), authorID: User.sampleUser1.id, text: "Pouring the foundation today. Solid groundwork is key! #foundation #concrete #buildconnect", imageURLs: nil, timestamp: Date().addingTimeInterval(-10800)),
//        Post(id: UUID(), authorID: User.sampleUser3.id, text: "Looking for recommendations for a good roofing contractor in the Bay Area! Any suggestions?", imageURLs: nil, timestamp: Date().addingTimeInterval(-14400))
//    ]
//}
//
//// MARK: - Networking Stub (Simulates API calls)
//
//class NetworkService {
//    // Simulates fetching user data
//    func fetchUser(userID: UUID) async throws -> User {
//        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
//        // In a real app, fetch from your backend API
//        let users = [User.sampleUser1, User.sampleUser2, User.sampleUser3]
//        if let user = users.first(where: { $0.id == userID }) {
//            return user
//        } else {
//            throw NSError(domain: "NetworkService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
//        }
//    }
//    
//    // Simulates fetching the main feed
//    func fetchFeed() async throws -> [Post] {
//        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
//        // In a real app, fetch posts from users the logged-in user follows, or a general feed
//        return Post.samplePosts.sorted { $0.timestamp > $1.timestamp }
//    }
//    
//    // Simulates creating a post
//    func createPost(authorID: UUID, text: String, imageURLs: [URL]?, locationTag: String?) async throws -> Post {
//        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 second delay
//        // In a real app, send data to backend and get the created post back
//        let newPost = Post(id: UUID(), authorID: authorID, text: text, imageURLs: imageURLs, timestamp: Date(), locationTag: locationTag)
//        // Add to the local sample data for demonstration purposes
//        Post.samplePosts.insert(newPost, at: 0)
//        return newPost
//    }
//    
//    // Simulates following a user
//    func followUser(userIDToFollow: UUID, currentUserID: UUID) async throws -> Bool {
//        try await Task.sleep(nanoseconds: 300_000_000)
//        print("Simulating: User \(currentUserID) follows \(userIDToFollow)")
//        // Update local state for demo - normally handle this server-side
//        if var currentUser = [User.sampleUser1, User.sampleUser2, User.sampleUser3].first(where: {$0.id == currentUserID}) {
//            if !currentUser.following.contains(userIDToFollow) {
//                currentUser.following.append(userIDToFollow)
//                // Update the static sample (hacky for demo)
//                if currentUserID == User.loggedInUser.id { User.loggedInUser.following = currentUser.following }
//                print("User \(currentUserID) now follows \(currentUser.following.count) users.")
//                return true
//            }
//        }
//        return false // Indicate success/failure
//    }
//    
//    // Simulates unfollowing a user
//    func unfollowUser(userIDToUnfollow: UUID, currentUserID: UUID) async throws -> Bool {
//        try await Task.sleep(nanoseconds: 300_000_000)
//        print("Simulating: User \(currentUserID) unfollows \(userIDToUnfollow)")
//        // Update local state for demo
//        if var currentUser = [User.sampleUser1, User.sampleUser2, User.sampleUser3].first(where: {$0.id == currentUserID}) {
//            if let index = currentUser.following.firstIndex(of: userIDToUnfollow) {
//                currentUser.following.remove(at: index)
//                // Update the static sample (hacky for demo)
//                if currentUserID == User.loggedInUser.id { User.loggedInUser.following = currentUser.following }
//                print("User \(currentUserID) now follows \(currentUser.following.count) users.")
//                return true
//            }
//        }
//        return false
//    }
//    
//    // Simulates Authentication (Highly Simplified)
//    func login(username: String, password: String) async throws -> User {
//        try await Task.sleep(nanoseconds: 600_000_000)
//        // WARNING: NEVER do auth like this in a real app! This is just a stub.
//        if username.lowercased() == "builder" && password == "password" {
//            return User.loggedInUser // Return our simulated logged-in user
//        } else {
//            throw NSError(domain: "NetworkService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
//        }
//    }
//    
//    func signup(username: String, password: String) async throws -> User {
//        try await Task.sleep(nanoseconds: 900_000_000)
//        // WARNING: Super simplified stub. Real signup needs validation, secure storage etc.
//        print("Simulating user signup for \(username)")
//        // Return the logged-in user instance for convenience in this MVP demo
//        return User.loggedInUser
//    }
//    
//    // Simulate updating profile
//    func updateProfile(user: User) async throws -> User {
//        try await Task.sleep(nanoseconds: 500_000_000)
//        print("Simulating profile update for \(user.username)")
//        // In real app, send data to backend, get updated user back
//        // For demo, update the static loggedInUser if it matches
//        if user.id == User.loggedInUser.id {
//            User.loggedInUser = user // Hacky update for demo state
//        }
//        return user // Return the user passed in (or updated from server)
//    }
//}
//
//// MARK: - View Models (State Management)
//
//@MainActor // Ensure UI updates happen on the main thread
//class AuthViewModel: ObservableObject {
//    @Published var isAuthenticated: Bool = false
//    @Published var currentUser: User? = nil
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//    
//    private let networkService = NetworkService()
//    
//    func login(username: String, password: String) async {
//        isLoading = true
//        errorMessage = nil
//        do {
//            let user = try await networkService.login(username: username, password: password)
//            self.currentUser = user
//            self.isAuthenticated = true
//            print("Login successful for \(user.username)")
//        } catch {
//            errorMessage = error.localizedDescription
//            print("Login failed: \(error)")
//        }
//        isLoading = false
//    }
//    
//    func signup(username: String, password: String) async {
//        isLoading = true
//        errorMessage = nil
//        do {
//            // In a real app, you'd likely get a different user object back
//            let user = try await networkService.signup(username: username, password: password)
//            self.currentUser = user
//            self.isAuthenticated = true // Auto-login after signup for demo
//            print("Signup successful for \(user.username)")
//        } catch {
//            errorMessage = error.localizedDescription
//            print("Signup failed: \(error)")
//        }
//        isLoading = false
//    }
//    
//    func updateProfile(user: User) async {
//        guard currentUser != nil else { return }
//        isLoading = true
//        errorMessage = nil
//        do {
//            let updatedUser = try await networkService.updateProfile(user: user)
//            self.currentUser = updatedUser // Update the local state
//            print("Profile updated successfully for \(updatedUser.username)")
//        } catch {
//            errorMessage = error.localizedDescription
//            print("Profile update failed: \(error)")
//        }
//        isLoading = false
//    }
//    
//    func logout() {
//        isAuthenticated = false
//        currentUser = nil
//        print("User logged out")
//        // In a real app, clear tokens, session data etc.
//    }
//}
//
//@MainActor
//class FeedViewModel: ObservableObject {
//    @Published var posts: [Post] = []
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var authors: [UUID: User] = [:] // Cache author details
//    
//    private let networkService = NetworkService()
//    
//    func fetchFeed() async {
//        isLoading = true
//        errorMessage = nil
//        do {
//            let fetchedPosts = try await networkService.fetchFeed()
//            self.posts = fetchedPosts
//            await fetchAuthors(for: fetchedPosts)
//            print("Feed fetched successfully: \(posts.count) posts")
//        } catch {
//            errorMessage = error.localizedDescription
//            print("Feed fetch failed: \(error)")
//        }
//        isLoading = false
//    }
//    
//    // Helper to fetch author details for posts if not already cached
//    private func fetchAuthors(for posts: [Post]) async {
//        let authorIDs = Set(posts.map { $0.authorID })
//        for id in authorIDs where authors[id] == nil {
//            do {
//                let user = try await networkService.fetchUser(userID: id)
//                authors[id] = user
//            } catch {
//                print("Failed to fetch author \(id): \(error)")
//                // Optionally handle missing authors (e.g., display "Unknown User")
//            }
//        }
//    }
//}
//
//@MainActor
//class CreatePostViewModel: ObservableObject {
//    @Published var postText: String = ""
//    // In MVP, we'll simplify and assume image URLs are added later or externally
//    // @Published var selectedImages: [UIImage] = []
//    @Published var locationTag: String = ""
//    @Published var isPosting: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var didPostSuccessfully: Bool = false
//    
//    private let networkService = NetworkService()
//    
//    func createPost(authorID: UUID) async {
//        guard !postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//            errorMessage = "Post text cannot be empty."
//            return
//        }
//        
//        isPosting = true
//        errorMessage = nil
//        didPostSuccessfully = false
//        
//        // Simulate adding image URLs for now
//        let sampleImageURLs: [URL]? = postText.contains("kitchen") ? [URL(string:"https://via.placeholder.com/600/FFFF00/000000?text=New+Post")!] : nil
//        
//        do {
//            _ = try await networkService.createPost(
//                authorID: authorID,
//                text: postText,
//                imageURLs: sampleImageURLs, // Using simulated URLs
//                locationTag: locationTag.isEmpty ? nil : locationTag
//            )
//            print("Post created successfully!")
//            didPostSuccessfully = true
//            // Reset fields after successful post
//            postText = ""
//            locationTag = ""
//        } catch {
//            errorMessage = "Failed to create post: \(error.localizedDescription)"
//            print("Post creation failed: \(error)")
//        }
//        isPosting = false
//    }
//}
//
//
//@MainActor
//class ProfileViewModel: ObservableObject {
//    @Published var user: User?
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var isFollowing: Bool = false // Specific to viewing ANOTHER user's profile
//    
//    private let networkService = NetworkService()
//    private let viewingUserID: UUID
//    private let currentUserID: UUID? // ID of the logged-in user
//    
//    init(viewingUserID: UUID, currentUserID: UUID?) {
//        self.viewingUserID = viewingUserID
//        self.currentUserID = currentUserID
//    }
//    
//    func fetchProfile() async {
//        isLoading = true
//        errorMessage = nil
//        do {
//            let fetchedUser = try await networkService.fetchUser(userID: viewingUserID)
//            self.user = fetchedUser
//            checkFollowingStatus() // Check if logged-in user follows this profile
//            print("Profile fetched for \(fetchedUser.username)")
//        } catch {
//            errorMessage = error.localizedDescription
//            print("Profile fetch failed for \(viewingUserID): \(error)")
//        }
//        isLoading = false
//    }
//    
//    private func checkFollowingStatus() {
//        // 1. Assign currentUser directly because User.loggedInUser is non-optional here.
//        //    In a real app, you might get the logged-in user from an optional source (e.g., authViewModel.currentUser),
//        //    in which case optional binding *would* be appropriate here too.
//        let currentUser = User.loggedInUser // Use the static var directly for the demo
//        
//        // 2. Use guard let ONLY for the optional part: self.user?.id
//        //    This safely unwraps the ID of the user whose profile is being viewed (`self.user`).
//        guard let viewedUserId = self.user?.id else {
//            // This else block executes if self.user is nil (meaning the profile data hasn't loaded yet or failed to load)
//            self.isFollowing = false
//            // Added a print statement for clarity during debugging
//            print("Cannot check following status: Profile being viewed (self.user) is nil.")
//            return
//        }
//        
//        // 3. If the guard passes, both currentUser and viewedUserId are non-optional and available.
//        //    Now you can safely check the following status.
//        self.isFollowing = currentUser.following.contains(viewedUserId)
//        // Added print statement for clarity
//        // print("Checked following status for user \(viewedUserId): \(self.isFollowing)")
//    }
//    
//    func follow() async {
//        guard let viewedUserId = user?.id, let currentUserId = currentUserID else { return }
//        isLoading = true // Indicate activity
//        do {
//            let success = try await networkService.followUser(userIDToFollow: viewedUserId, currentUserID: currentUserId)
//            if success {
//                isFollowing = true
//                // In real app, refresh profile or update follower count
//                print("Follow successful")
//            } else {
//                errorMessage = "Failed to follow user."
//                print("Follow failed (API returned false)")
//            }
//        } catch {
//            errorMessage = "Error following user: \(error.localizedDescription)"
//            print("Follow error: \(error)")
//        }
//        isLoading = false
//    }
//    
//    func unfollow() async {
//        guard let viewedUserId = user?.id, let currentUserId = currentUserID else { return }
//        isLoading = true
//        do {
//            let success = try await networkService.unfollowUser(userIDToUnfollow: viewedUserId, currentUserID: currentUserId)
//            if success {
//                isFollowing = false
//                // In real app, refresh profile or update follower count
//                print("Unfollow successful")
//            } else {
//                errorMessage = "Failed to unfollow user."
//                print("Unfollow failed (API returned false)")
//            }
//        } catch {
//            errorMessage = "Error unfollowing user: \(error.localizedDescription)"
//            print("Unfollow error: \(error)")
//        }
//        isLoading = false
//    }
//}
//
//
//// MARK: - UI Views (SwiftUI)
//
//// --- Authentication Views ---
//
//struct LoginView: View {
//    @State private var username = ""
//    @State private var password = ""
//    @EnvironmentObject var authViewModel: AuthViewModel // Get from environment
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("BuildConnect").font(.largeTitle).bold()
//            Image(systemName: "hammer.fill") // Placeholder logo
//                .resizable()
//                .scaledToFit()
//                .frame(width: 80, height: 80)
//                .foregroundColor(.orange)
//            
//            TextField("Username (try 'builder')", text: $username)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .autocapitalization(.none)
//                .disableAutocorrection(true)
//            SecureField("Password (try 'password')", text: $password)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//            
//            if authViewModel.isLoading {
//                ProgressView()
//            } else {
//                Button("Login") {
//                    Task {
//                        await authViewModel.login(username: username, password: password)
//                    }
//                }
//                .buttonStyle(.borderedProminent)
//                
//                // Simple Signup Navigation (replace with better flow later)
//                Button("Don't have an account? Sign Up") {
//                    // In a real app, navigate to a separate SignupView
//                    Task {
//                        await authViewModel.signup(username: "newuser", password: "newpassword") // Simulate signup
//                    }
//                }
//                .font(.footnote)
//            }
//            
//            if let errorMessage = authViewModel.errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .font(.caption)
//            }
//        }
//        .padding()
//    }
//}
//
//// SignupView - Could be built similarly to LoginView if needed for a separate screen
//
//// --- Main App Structure ---
//
//struct ContentView: View {
//    @StateObject private var authViewModel = AuthViewModel() // Creates and owns the AuthViewModel
//    
//    var body: some View {
//        // If authenticated, show the main app tabs, otherwise show Login
//        if authViewModel.isAuthenticated && authViewModel.currentUser != nil {
//            MainTabView()
//                .environmentObject(authViewModel) // Pass down to child views if needed
//        } else {
//            LoginView()
//                .environmentObject(authViewModel) // Pass down to LoginView
//        }
//    }
//}
//
//struct MainTabView: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//    
//    var body: some View {
//        TabView {
//            NavigationView { // Embed Feed in NavigationView for potential navigation
//                FeedView()
//            }
//            .tabItem {
//                Label("Feed", systemImage: "list.bullet")
//            }
//            
//            NavigationView { // Embed Create Post in NavigationView
//                CreatePostView()
//            }
//            .tabItem {
//                Label("Post", systemImage: "plus.square.fill")
//            }
//            
//            NavigationView { // Embed Profile in NavigationView
//                // Pass the currently logged-in user's ID
//                ProfileViewWrapper(viewingUserID: authViewModel.currentUser!.id)
//            }
//            .tabItem {
//                Label("Profile", systemImage: "person.fill")
//            }
//        }
//    }
//}
//
//
//// --- Feed Views ---
//
//struct FeedView: View {
//    @StateObject private var viewModel = FeedViewModel() // View owns its VM
//    
//    var body: some View {
//        List {
//            if viewModel.isLoading && viewModel.posts.isEmpty {
//                ProgressView() // Show loading indicator only when fetching initially
//                    .frame(maxWidth: .infinity, alignment: .center)
//            } else if let errorMessage = viewModel.errorMessage {
//                Text("Error: \(errorMessage)")
//                    .foregroundColor(.red)
//            } else {
//                ForEach(viewModel.posts) { post in
//                    // NavigationLink to view Post Detail (Future Phase) or User Profile
//                    NavigationLink(destination: ProfileViewWrapper(viewingUserID: post.authorID)) {
//                        PostRowView(post: post, author: viewModel.authors[post.authorID])
//                    }
//                }
//            }
//        }
//        .navigationTitle("Feed")
//        .refreshable { // Pull-to-refresh
//            await viewModel.fetchFeed()
//        }
//        .task { // Fetch data when the view appears
//            if viewModel.posts.isEmpty { // Only fetch if empty initially
//                await viewModel.fetchFeed()
//            }
//        }
//    }
//}
//
//struct PostRowView: View {
//    let post: Post
//    let author: User? // Pass author details if available
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            // Author Info Header
//            HStack {
//                AsyncImage(url: author?.profileImageURL) { image in
//                    image.resizable().scaledToFill()
//                } placeholder: {
//                    Image(systemName: "person.circle.fill").resizable()
//                        .foregroundColor(.gray)
//                }
//                .frame(width: 40, height: 40)
//                .clipShape(Circle())
//                
//                VStack(alignment: .leading) {
//                    Text(author?.username ?? "Loading...") // Display fetched username
//                        .font(.headline)
//                    Text(post.timestamp, style: .relative) // Show relative time
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
//                Spacer()
//                // Add options menu (...) later
//            }
//            
//            // Post Content
//            Text(post.text)
//                .bodyText() // Apply consistent styling
//            
//            // Display Images (Simple Horizontal Scroll for MVP)
//            if let imageURLs = post.imageURLs, !imageURLs.isEmpty {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack {
//                        ForEach(imageURLs, id: \.self) { url in
//                            AsyncImage(url: url) { image in
//                                image.resizable().scaledToFit()
//                            } placeholder: {
//                                Rectangle().fill(.gray.opacity(0.3)).overlay(ProgressView()) // Placeholder with loading
//                            }
//                            // Limit image height in the row for better layout
//                            .frame(height: 200)
//                            .cornerRadius(8)
//                        }
//                    }
//                }
//            }
//            
//            // Location Tag
//            if let location = post.locationTag {
//                HStack {
//                    Image(systemName: "mappin.and.ellipse")
//                    Text(location)
//                }
//                .font(.caption)
//                .foregroundColor(.gray)
//            }
//            
//            
//            // Action Buttons (Placeholder functionality for MVP)
//            HStack {
//                Button { /* Like Action */ } label: { Label("Like", systemImage: "heart") }
//                Spacer()
//                Button { /* Comment Action */ } label: { Label("Comment", systemImage: "bubble.left") }
//                Spacer()
//                Button { /* Share Action */ } label: { Label("Share", systemImage: "square.and.arrow.up") }
//            }
//            .buttonStyle(PlainButtonStyle()) // Use plain style for subtle buttons in a list
//            .foregroundColor(.secondary)
//            .padding(.top, 5)
//        }
//        .padding(.vertical, 5) // Add padding inside the row
//    }
//}
//
//// Custom View Modifier for body text styling
//struct BodyTextStyle: ViewModifier {
//    func body(content: Content) -> some View {
//        content
//            .font(.body)
//            .lineSpacing(4) // Improve readability
//    }
//}
//
//extension View {
//    func bodyText() -> some View {
//        self.modifier(BodyTextStyle())
//    }
//}
//
//// --- Post Creation View ---
//
//struct CreatePostView: View {
//    @StateObject private var viewModel = CreatePostViewModel()
//    @EnvironmentObject var authViewModel: AuthViewModel // Need author ID
//    @Environment(\.presentationMode) var presentationMode // To dismiss the view
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Create New Post")
//                .font(.title2).bold()
//                .padding(.bottom)
//            
//            TextEditor(text: $viewModel.postText)
//                .frame(height: 150)
//                .border(Color.gray.opacity(0.5), width: 1)
//                .cornerRadius(5)
//                .accessibilityLabel("Post content text editor")
//            
//            TextField("Location Tag (Optional)", text: $viewModel.locationTag)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding(.vertical)
//            
//            // Image Selection Placeholder for MVP
//            Text("Add Images (Feature coming soon!)")
//                .font(.caption)
//                .foregroundColor(.gray)
//                .padding(.bottom)
//            
//            
//            if viewModel.isPosting {
//                ProgressView("Posting...")
//                    .frame(maxWidth: .infinity, alignment: .center)
//            } else {
//                Button("Post to Feed") {
//                    Task {
//                        guard let authorID = authViewModel.currentUser?.id else {
//                            viewModel.errorMessage = "Error: Not logged in."
//                            return
//                        }
//                        await viewModel.createPost(authorID: authorID)
//                    }
//                }
//                .buttonStyle(.borderedProminent)
//                .frame(maxWidth: .infinity, alignment: .center)
//                .disabled(viewModel.postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
//            }
//            
//            if let errorMessage = viewModel.errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .font(.caption)
//                    .padding(.top)
//            }
//            
//            Spacer() // Push content to top
//        }
//        .padding()
//        .navigationTitle("New Post")
//        .navigationBarTitleDisplayMode(.inline)
//        // Dismiss view automatically on successful post
//        .onChange(of: viewModel.didPostSuccessfully) { success in
//            if success {
//                presentationMode.wrappedValue.dismiss()
//                // Optionally trigger a feed refresh in the background
//            }
//        }
//    }
//}
//
//
//// --- Profile Views ---
//
//// Wrapper to handle ProfileViewModel initialization correctly in NavigationLink/TabView
//struct ProfileViewWrapper: View {
//    let viewingUserID: UUID
//    @EnvironmentObject var authViewModel: AuthViewModel
//    
//    var body: some View {
//        // Create the viewModel here, passing the necessary IDs
//        ProfileView(viewModel: ProfileViewModel(viewingUserID: viewingUserID, currentUserID: authViewModel.currentUser?.id))
//    }
//}
//
//
//struct ProfileView: View {
//    @StateObject var viewModel: ProfileViewModel // Receive the initialized VM
//    @EnvironmentObject var authViewModel: AuthViewModel // To check if viewing self profile
//    @State private var showingEditProfile = false
//    
//    var isViewingOwnProfile: Bool {
//        viewModel.user?.id == authViewModel.currentUser?.id
//    }
//    
//    var body: some View {
//        ScrollView {
//            if viewModel.isLoading {
//                ProgressView()
//            } else if let user = viewModel.user {
//                VStack(alignment: .leading, spacing: 15) {
//                    // Profile Header
//                    HStack(alignment: .top) {
//                        AsyncImage(url: user.profileImageURL) { image in
//                            image.resizable().scaledToFill()
//                        } placeholder: {
//                            Image(systemName: "person.circle.fill").resizable()
//                                .foregroundColor(.gray)
//                        }
//                        .frame(width: 80, height: 80)
//                        .clipShape(Circle())
//                        
//                        VStack(alignment: .leading) {
//                            Text(user.username).font(.title).bold()
//                            // Follower/Following Counts (Static for MVP)
//                            HStack {
//                                Text("**\(user.followers.count)** followers") // Show count from model
//                                Text("**\(user.following.count)** following")
//                            }
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                        }
//                        Spacer()
//                    }
//                    
//                    // Bio
//                    if let bio = user.bio, !bio.isEmpty {
//                        Text(bio)
//                            .bodyText()
//                    }
//                    
//                    // Action Buttons (Edit Profile / Follow / Unfollow)
//                    if isViewingOwnProfile {
//                        Button {
//                            showingEditProfile = true
//                        } label: {
//                            Text("Edit Profile")
//                                .frame(maxWidth: .infinity)
//                        }
//                        .buttonStyle(.bordered)
//                        
//                        Button("Logout", role: .destructive) {
//                            authViewModel.logout()
//                        }
//                        .buttonStyle(.bordered)
//                        .frame(maxWidth: .infinity)
//                        
//                    } else {
//                        // Follow/Unfollow Button
//                        Button {
//                            Task {
//                                if viewModel.isFollowing {
//                                    await viewModel.unfollow()
//                                } else {
//                                    await viewModel.follow()
//                                }
//                            }
//                        } label: {
//                            Text(viewModel.isFollowing ? "Unfollow" : "Follow")
//                                .frame(maxWidth: .infinity)
//                        }
//                        //                         .buttonStyle(viewModel.isFollowing ? .bordered : .borderedProminent)
//                        .disabled(viewModel.isLoading) // Disable during action
//                    }
//                    
//                    
//                    // Display User's Posts (Placeholder/Simplified for MVP)
//                    Divider().padding(.vertical)
//                    Text("Posts")
//                        .font(.title2).bold()
//                    // In real app, fetch user-specific posts here
//                    Text("User posts will appear here (Feature coming soon!)")
//                        .foregroundColor(.gray)
//                        .frame(maxWidth: .infinity, alignment: .center)
//                        .padding()
//                    
//                    if let errorMessage = viewModel.errorMessage {
//                        Text("Error: \(errorMessage)")
//                            .foregroundColor(.red)
//                            .font(.caption)
//                            .padding(.top)
//                    }
//                    
//                }
//                .padding()
//            } else if let errorMessage = viewModel.errorMessage {
//                Text("Error loading profile: \(errorMessage)")
//                    .foregroundColor(.red)
//                    .padding()
//            } else {
//                Text("User not found.") // Handle case where user couldn't be loaded
//                    .padding()
//            }
//        }
//        .navigationTitle(viewModel.user?.username ?? "Profile")
//        .navigationBarTitleDisplayMode(.inline)
//        .task { // Fetch profile when view appears
//            if viewModel.user == nil { // Only fetch if not already loaded
//                await viewModel.fetchProfile()
//            }
//        }
//        // Sheet presentation for editing profile
//        .sheet(isPresented: $showingEditProfile) {
//            // Ensure we pass the correct user data to the edit view
//            if let currentUser = authViewModel.currentUser {
//                NavigationView { // Embed in NavigationView for title/buttons
//                    EditProfileView(userToEdit: currentUser)
//                        .environmentObject(authViewModel) // Pass auth VM down
//                }
//            }
//        }
//        // Update profile view if the underlying user model changes in AuthViewModel
//        .onReceive(authViewModel.$currentUser) { updatedUser in
//            if updatedUser?.id == viewModel.user?.id {
//                viewModel.user = updatedUser // Reflect changes made via EditProfileView
//            }
//        }
//    }
//}
//
//
//struct EditProfileView: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//    @Environment(\.presentationMode) var presentationMode
//    @State private var editedUser: User // Local state for editing
//    
//    // To prevent direct modification before saving
//    init(userToEdit: User) {
//        _editedUser = State(initialValue: userToEdit)
//    }
//    
//    var body: some View {
//        Form {
//            Section("Public Profile") {
//                TextField("Username", text: $editedUser.username)
//                    .autocapitalization(.none)
//                    .disableAutocorrection(true)
//                
//                // Use TextEditor for multi-line bio
//                VStack(alignment: .leading) {
//                    Text("Bio").font(.caption).foregroundColor(.gray)
//                    TextEditor(text: Binding( // Handle optional bio
//                        get: { editedUser.bio ?? "" },
//                        set: { editedUser.bio = $0.isEmpty ? nil : $0 }
//                                            ))
//                    .frame(height: 100) // Adjust height as needed
//                }
//                
//                // Profile Image URL (Display only for MVP - editing is complex)
//                HStack {
//                    Text("Profile Image URL")
//                    Spacer()
//                    Text(editedUser.profileImageURL?.absoluteString ?? "Not Set")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .lineLimit(1)
//                        .truncationMode(.middle)
//                }
//                Button("Change Profile Picture (Coming Soon)") {
//                    // Placeholder for image picker integration
//                }
//                .disabled(true)
//            }
//            
//            Section {
//                Button("Save Changes") {
//                    Task {
//                        await authViewModel.updateProfile(user: editedUser)
//                        // Optional: Check for errors before dismissing
//                        if authViewModel.errorMessage == nil {
//                            presentationMode.wrappedValue.dismiss()
//                        }
//                    }
//                }
//                .disabled(authViewModel.isLoading) // Disable while loading
//                
//                Button("Cancel", role: .cancel) {
//                    presentationMode.wrappedValue.dismiss()
//                }
//            }
//            
//            if authViewModel.isLoading {
//                HStack {
//                    Spacer()
//                    ProgressView()
//                    Spacer()
//                }
//            }
//            if let errorMessage = authViewModel.errorMessage {
//                Text("Error: \(errorMessage)")
//                    .foregroundColor(.red)
//                    .font(.caption)
//            }
//        }
//        .navigationTitle("Edit Profile")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// MARK: - App Entry Point
////
////@main
////struct BuildConnectApp: App {
////    var body: some Scene {
////        WindowGroup {
////            ContentView()
////        }
////    }
////}
//
//#Preview {
//    ContentView()
//}
