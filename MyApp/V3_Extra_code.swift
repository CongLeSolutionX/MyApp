////
////  V4.swift
////  MyApp
////
////  Created by Cong Le on 4/4/25.
////
//
//
//import SwiftUI
//import Combine // Required for ObservableObject
//import UserNotifications // For Notifications
//
//// MARK: - Data Models (Phase 1 & 2)
//
//// --- User Model (Extended for Phase 2) ---
//struct User: Identifiable, Codable, Hashable {
//    let id: UUID
//    var username: String
//    var bio: String?
//    var profileImageURL: URL?
//    var following: [UUID] = []
//    var followers: [UUID] = []
//
//    // --- Phase 2 Additions ---
//    var servicesOffered: [String]? // e.g., ["General Contracting", "Kitchen Remodeling"]
//    var serviceAreaDescription: String? // e.g., "San Francisco Bay Area" (Text for MVP)
//    var certifications: [String]? // e.g., ["Licensed General Contractor #12345"]
//    var contactEmail: String?
//    var contactPhone: String?
//    // -------------------------
//
//    // Sample Data (Updates for Phase 2 fields)
//    static var sampleUser1 = User(id: UUID(), username: "BuildMasterPro", bio: "Crafting dream homes since 2005. Quality & Precision.", profileImageURL: URL(string: "https://via.placeholder.com/150/FFA07A/000000?text=BMP"), servicesOffered: ["General Contracting", "New Construction", "ADUs"], serviceAreaDescription: "South Bay & Peninsula", certifications: ["Licensed GC #123456"], contactEmail: "contact@buildmaster.pro", contactPhone: "555-111-2222")
//    static var sampleUser2 = User(id: UUID(), username: "DesignBuildInspire", bio: "Innovative designs meet expert construction.", profileImageURL: URL(string: "https://via.placeholder.com/150/ADD8E6/000000?text=DBI"), servicesOffered: ["Interior Design", "Kitchen & Bath Remodel"], serviceAreaDescription: "San Francisco City", contactEmail: "hello@dbi.design")
//    static var sampleUser3 = User(id: UUID(), username: "HomeownerHub", bio: "Planning my next big renovation!", profileImageURL: URL(string: "https://via.placeholder.com/150/90EE90/000000?text=HH"))
//
//    static var loggedInUser = sampleUser1 // Simulate logged-in user
//}
//
//// --- Post Model (Phase 1) ---
//struct Post: Identifiable, Codable, Hashable {
//    let id: UUID
//    let authorID: UUID
//    let text: String
//    let imageURLs: [URL]?
//    let timestamp: Date
//    var locationTag: String?
//
//    // Phase 2 additions (for engagement tracking)
//    var likes: [UUID] = [] // User IDs who liked the post
//    var commentCount: Int = 0 // Keep track locally for display
//
//    // Sample Data (Updates for Phase 2)
//    static var samplePosts: [Post] = [
//        Post(id: UUID(), authorID: User.sampleUser1.id, text: "Just finished framing this beauty! Solid structure coming along nicely. #framing #construction #newbuild", imageURLs: [URL(string:"https://via.placeholder.com/600/FFA07A/FFFFFF?text=Frame+1")!], timestamp: Date().addingTimeInterval(-3600), locationTag: "Sunnyvale Project", likes: [User.sampleUser2.id, User.sampleUser3.id], commentCount: 2),
//        Post(id: UUID(), authorID: User.sampleUser2.id, text: "Kitchen transformation complete! Loving these custom cabinets and quartz countertops. What do you think?", imageURLs: [URL(string:"https://via.placeholder.com/600/ADD8E6/FFFFFF?text=Kitchen+1")!, URL(string:"https://via.placeholder.com/600/ADD8E6/FFFFFF?text=Kitchen+2")!], timestamp: Date().addingTimeInterval(-7200), locationTag: "Downtown Loft Reno", likes: [User.sampleUser1.id], commentCount: 1),
//        Post(id: UUID(), authorID: User.sampleUser1.id, text: "Pouring the foundation today. Solid groundwork is key! #foundation #concrete #buildconnect", imageURLs: nil, timestamp: Date().addingTimeInterval(-10800), commentCount: 0),
//        Post(id: UUID(), authorID: User.sampleUser3.id, text: "Looking for recommendations for a good roofing contractor in the Bay Area! Any suggestions?", imageURLs: nil, timestamp: Date().addingTimeInterval(-14400), commentCount: 0)
//    ]
//}
//
//// --- Project Model (New for Phase 2) ---
//struct Project: Identifiable, Codable, Hashable {
//    let id: UUID
//    let contractorID: UUID // User ID of the contractor
//    var projectName: String
//    var description: String
//    var location: String? // e.g., "Palo Alto, CA"
//    var budgetRange: String? // e.g., "$100k - $150k"
//    var styleTags: [String]? // e.g., ["Modern", "Farmhouse"]
//    var photoURLs: [URL]?
//    var videoURL: URL? // Simplified: one video URL
//    let timestamp: Date = Date() // Date project was added/updated
//
//    // Sample Data
//    static var sampleProjects: [Project] = [
//        Project(id: UUID(), contractorID: User.sampleUser1.id, projectName: "Modern Eichler Renovation", description: "Complete overhaul of a classic Eichler home, focusing on open spaces and natural light.", location: "Palo Alto, CA", budgetRange: "$400k+", styleTags: ["Modern", "Mid-Century", "Open Concept"], photoURLs: [URL(string:"https://via.placeholder.com/800/FFA07A/FFFFFF?text=Eichler+Living")!, URL(string:"https://via.placeholder.com/800/FFA07A/FFFFFF?text=Eichler+Kitchen")!]),
//        Project(id: UUID(), contractorID: User.sampleUser1.id, projectName: "Luxury ADU Build", description: "Custom-designed Accessory Dwelling Unit with high-end finishes.", location: "Los Altos Hills, CA", budgetRange: "$250k - $300k", styleTags: ["Luxury", "Compact", "ADU"], photoURLs: [URL(string:"https://via.placeholder.com/800/FFA07A/FFFFFF?text=ADU+Exterior")!]),
//        Project(id: UUID(), contractorID: User.sampleUser2.id, projectName: "Downtown Loft Kitchen", description: "Sleek and functional kitchen design for a modern loft space.", location: "San Francisco, CA", styleTags: ["Modern", "Industrial", "Minimalist"], photoURLs: [URL(string:"https://via.placeholder.com/800/ADD8E6/FFFFFF?text=Loft+Kitchen+Main")!]),
//    ]
//}
//
//// --- Comment Model (New for Phase 2) ---
//struct Comment: Identifiable, Codable, Hashable {
//    let id: UUID
//    let postID: UUID // Which post this comment belongs to
//    let authorID: UUID
//    let text: String
//    let timestamp: Date
//
//    // Sample Data
//    static var sampleComments: [Comment] = [
//        Comment(id: UUID(), postID: Post.samplePosts[0].id, authorID: User.sampleUser2.id, text: "Looks amazing! Clean work.", timestamp: Date().addingTimeInterval(-3500)),
//        Comment(id: UUID(), postID: Post.samplePosts[0].id, authorID: User.sampleUser3.id, text: "Wow, that's going to be a solid house!", timestamp: Date().addingTimeInterval(-3400)),
//        Comment(id: UUID(), postID: Post.samplePosts[1].id, authorID: User.sampleUser1.id, text: "Incredible transformation!", timestamp: Date().addingTimeInterval(-7000)),
//    ]
//}
//
//// --- Like Model (Implicit - Tracked by user IDs in Post) ---
//// No separate struct needed if we just store user IDs.
//
//// --- AppNotification Model (New for Phase 2) ---
//struct AppNotification: Identifiable, Codable, Hashable {
//    enum NotificationType: String, Codable {
//        case newFollower, postLike, postComment, newProject // Add more as needed
//    }
//
//    let id: UUID
//    let type: NotificationType
//    let actorUserID: UUID // User who triggered the notification (e.g., liked the post)
//    let targetPostID: UUID? // Optional: Relevant post
//    let targetProjectID: UUID? // Optional: Relevant project
//    let message: String // Pre-formatted message for display
//    let timestamp: Date
//    var isRead: Bool = false
//
//    // Sample Data
//    static let sampleNotifications: [AppNotification] = [
//        AppNotification(id: UUID(), type: .postLike, actorUserID: User.sampleUser2.id, targetPostID: Post.samplePosts[0].id, message: "DesignBuildInspire liked your post.", timestamp: Date().addingTimeInterval(-500)),
//        AppNotification(id: UUID(), type: .postComment, actorUserID: User.sampleUser3.id, targetPostID: Post.samplePosts[0].id, message: "HomeownerHub commented on your post.", timestamp: Date().addingTimeInterval(-400)),
//        AppNotification(id: UUID(), type: .newFollower, actorUserID: User.sampleUser3.id, message: "HomeownerHub started following you.", timestamp: Date().addingTimeInterval(-6000)),
//    ]
//}
//
//// MARK: - Networking Stub (Extended for Phase 2)
//
//class NetworkService {
//
//    // --- Existing User/Post Functions ---
//    func fetchUser(userID: UUID) async throws -> User {
//        try await Task.sleep(nanoseconds: 500_000_000)
//        let users = [User.sampleUser1, User.sampleUser2, User.sampleUser3]
//        if let user = users.first(where: { $0.id == userID }) {
//            // Return a copy to prevent unintended shared state modification in demo
//            var userCopy = user
//            return userCopy
//        } else {
//            throw NSError(domain: "NetworkService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
//        }
//    }
//
//    func fetchFeed() async throws -> [Post] {
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        // Return copies to avoid direct mutation issues in demo
//        return Post.samplePosts.map { $0 }.sorted { $0.timestamp > $1.timestamp }
//    }
//
//    func createPost(authorID: UUID, text: String, imageURLs: [URL]?, locationTag: String?) async throws -> Post {
//        try await Task.sleep(nanoseconds: 800_000_000)
//        let newPost = Post(id: UUID(), authorID: authorID, text: text, imageURLs: imageURLs, timestamp: Date(), locationTag: locationTag)
//        // Add to the static sample data for demo
//        Post.samplePosts.insert(newPost, at: 0)
//        return newPost
//    }
//
//    func followUser(userIDToFollow: UUID, currentUserID: UUID) async throws -> Bool {
//         try await Task.sleep(nanoseconds: 300_000_000)
//        print("Simulating: User \(currentUserID) follows \(userIDToFollow)")
//        // Update local state for demo - normally handle this server-side
//        // This direct modification of static data is ONLY for demo purposes
//        if currentUserID == User.loggedInUser.id {
//            if !User.loggedInUser.following.contains(userIDToFollow) {
//                User.loggedInUser.following.append(userIDToFollow)
//                // Also update follower count on the target user (demo only)
//                if var targetUser = [User.sampleUser1, User.sampleUser2, User.sampleUser3].first(where: {$0.id == userIDToFollow}) {
//                    if !targetUser.followers.contains(currentUserID) {
//                        // Need a mechanism to update the static samples array if required
//                    }
//                }
//                 print("User \(currentUserID) now follows \(User.loggedInUser.following.count) users.")
//                return true
//            }
//        }
//        return false
//    }
//
//    func unfollowUser(userIDToUnfollow: UUID, currentUserID: UUID) async throws -> Bool {
//         try await Task.sleep(nanoseconds: 300_000_000)
//         print("Simulating: User \(currentUserID) unfollows \(userIDToUnfollow)")
//            // Update local state for demo
//         if currentUserID == User.loggedInUser.id {
//             if let index = User.loggedInUser.following.firstIndex(of: userIDToUnfollow) {
//                 User.loggedInUser.following.remove(at: index)
//                 // Also update target user's followers (demo only)
//                  if var targetUser = [User.sampleUser1, User.sampleUser2, User.sampleUser3].first(where: {$0.id == userIDToUnfollow}) {
//                     // Need mechanism to update static samples
//                 }
//                 print("User \(currentUserID) now follows \(User.loggedInUser.following.count) users.")
//                 return true
//             }
//         }
//         return false
//    }
//
//    func login(username: String, password: String) async throws -> User {
//        try await Task.sleep(nanoseconds: 600_000_000)
//        if username.lowercased() == "builder" && password == "password" {
//             // Return a copy to avoid shared mutable state issues in demo context
//             let loggedInCopy = User.loggedInUser
//             return loggedInCopy
//        } else {
//            throw NSError(domain: "NetworkService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
//        }
//    }
//
//    func signup(username: String, password: String) async throws -> User {
//        try await Task.sleep(nanoseconds: 900_000_000)
//        print("Simulating user signup for \(username)")
//         // Return a copy
//        let loggedInCopy = User.loggedInUser
//        return loggedInCopy
//    }
//
//    func updateProfile(user: User) async throws -> User {
//        try await Task.sleep(nanoseconds: 500_000_000)
//        print("Simulating profile update for \(user.username)")
//        // Update the static master copy if it's the logged-in user
//        // This is highly simplified for demo; real backends handle this.
//        if user.id == User.loggedInUser.id {
//            User.loggedInUser = user
//            print("Updated static loggedInUser instance.")
//        }
//        // Also try to update the user in the sample lists if they exist there
//        // (This is brittle and only for demonstrating changes in the app)
//        if let index = User.samplePosts.indices.filter({ User.samplePosts[$0].id == user.id }).first {
//            // Need to update relevant properties if User object is stored elsewhere
//        }
//
//        // Return the user object passed in (or what the server returns)
//        return user
//    }
//
//    // --- Phase 2 Network Stubs ---
//
//    // --- Project Stubs ---
//    func fetchProjects(for contractorID: UUID) async throws -> [Project] {
//        try await Task.sleep(nanoseconds: 700_000_000)
//        print("Fetching projects for user \(contractorID)")
//        // Filter sample projects for the given contractor
//        let userProjects = Project.sampleProjects.filter { $0.contractorID == contractorID }
//        return userProjects.sorted { $0.timestamp > $1.timestamp }
//    }
//
//    func createProject(project: Project) async throws -> Project {
//        try await Task.sleep(nanoseconds: 1_200_000_000) // Longer delay for project creation
//        print("Simulating creation of project: \(project.projectName)")
//        let newProject = Project(
//            id: UUID(), // Server assigns ID
//            contractorID: project.contractorID,
//            projectName: project.projectName,
//            description: project.description,
//            location: project.location,
//            budgetRange: project.budgetRange,
//            styleTags: project.styleTags,
//            photoURLs: project.photoURLs,
//            videoURL: project.videoURL
//        )
//        Project.sampleProjects.insert(newProject, at: 0) // Add to local sample data for demo
//        return newProject
//    }
//
//    // --- Engagement Stubs (Likes/Comments) ---
//    func likePost(postID: UUID, userID: UUID) async throws -> Bool {
//        try await Task.sleep(nanoseconds: 200_000_000)
//        print("Simulating User \(userID) liking Post \(postID)")
//        if let index = Post.samplePosts.firstIndex(where: { $0.id == postID }) {
//            if !Post.samplePosts[index].likes.contains(userID) {
//                Post.samplePosts[index].likes.append(userID)
//                print("Post \(postID) like count: \(Post.samplePosts[index].likes.count)")
//                return true
//            }
//        }
//        return false // Post not found or already liked
//    }
//
//    func unlikePost(postID: UUID, userID: UUID) async throws -> Bool {
//        try await Task.sleep(nanoseconds: 200_000_000)
//         print("Simulating User \(userID) unliking Post \(postID)")
//        if let index = Post.samplePosts.firstIndex(where: { $0.id == postID }) {
//            if let likeIndex = Post.samplePosts[index].likes.firstIndex(of: userID) {
//                Post.samplePosts[index].likes.remove(at: likeIndex)
//                 print("Post \(postID) like count: \(Post.samplePosts[index].likes.count)")
//                return true
//            }
//        }
//        return false // Post not found or not liked by user
//    }
//
//    func fetchComments(for postID: UUID) async throws -> [Comment] {
//        try await Task.sleep(nanoseconds: 400_000_000)
//         print("Fetching comments for Post \(postID)")
//        // Filter sample comments
//        let postComments = Comment.sampleComments.filter { $0.postID == postID }
//        return postComments.sorted { $0.timestamp < $1.timestamp } // Oldest first
//    }
//
//    func postComment(postID: UUID, authorID: UUID, text: String) async throws -> Comment {
//        try await Task.sleep(nanoseconds: 500_000_000)
//         print("Simulating User \(authorID) commenting on Post \(postID)")
//        let newComment = Comment(id: UUID(), postID: postID, authorID: authorID, text: text, timestamp: Date())
//        Comment.sampleComments.append(newComment) // Add to local sample data
//
//        // Update comment count on the post (for demo)
//        if let index = Post.samplePosts.firstIndex(where: { $0.id == postID }) {
//             Post.samplePosts[index].commentCount += 1
//        }
//        return newComment
//    }
//
//    // --- Notification Stubs ---
//    func registerDeviceToken(userID: UUID, token: String) async throws {
//        try await Task.sleep(nanoseconds: 300_000_000)
//        print("Simulating registration of token \(token) for User \(userID)")
//    }
//
//    func fetchNotifications(for userID: UUID) async throws -> [AppNotification] {
//        try await Task.sleep(nanoseconds: 600_000_000)
//         print("Fetching notifications for User \(userID)")
//         // Filter sample notifications for the target user (more realistic demo)
//         let userNotifications = AppNotification.sampleNotifications.filter { notification in
//             // Simple logic: notify post author for likes/comments, notify followed user for new followers
//             switch notification.type {
//             case .postLike, .postComment:
//                 // Find the post and check its author
//                 if let targetPostID = notification.targetPostID,
//                    let post = Post.samplePosts.first(where: { $0.id == targetPostID }) {
//                     return post.authorID == userID
//                 }
//                 return false
//             case .newFollower:
//                 // The notification is FOR the user being followed
//                 // In this sample data, user 3 follows user 1. So fetch for user 1 would show this.
//                 // This requires a way to know who is being followed within the notification itself,
//                 // or fetching based on "notifications FOR me". Let's assume the latter for the demo fetch.
//                 // We'll return all for simplicity here, but real backend logic is needed.
//                 return true // Simplification: return all for demo fetch
//             case .newProject:
//                 // Notify followers of the contractor who posted the project
//                 // Complex logic needed on backend based on follower graph
//                 return false // Simplification for demo
//             }
//         }
//        return userNotifications.sorted { $0.timestamp > $1.timestamp }
//    }
//
//    func markNotificationAsRead(notificationID: UUID) async throws -> Bool {
//        try await Task.sleep(nanoseconds: 100_000_000)
//         print("Simulating marking notification \(notificationID) as read")
//        // Find and modify in sample data (brittle demo state)
//        if let index = AppNotification.sampleNotifications.firstIndex(where: { $0.id == notificationID }) {
//           // Need a mutable sampleNotifications array to update isRead
//           // AppNotification.sampleNotifications[index].isRead = true // Requires sampleNotifications to be var
//           print("Marked locally (if sampleNotifications was var)")
//        }
//        return true
//    }
//}
//
//// MARK: - View Models (State Management - Extended for Phase 2)
//
//// --- AuthViewModel (Slightly Updated for Profile) ---
//@MainActor
//class AuthViewModel: ObservableObject {
//    @Published var isAuthenticated: Bool = false
//    @Published var currentUser: User? = nil
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//
//    private let networkService = NetworkService()
//    private var cancellables = Set<AnyCancellable>()
//    @Published var shouldRegisterForNotifications = false
//
//    init() {
//         $isAuthenticated
//             .filter { $0 == true }
//             .sink { [weak self] _ in self?.shouldRegisterForNotifications = true }
//             .store(in: &cancellables)
//     }
//
//    func login(username: String, password: String) async { /* ... existing ... */
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
//    func signup(username: String, password: String) async { /* ... existing ... */
//        isLoading = true
//        errorMessage = nil
//        do {
//            let user = try await networkService.signup(username: username, password: password)
//            self.currentUser = user
//            self.isAuthenticated = true // Auto-login after signup
//             print("Signup successful for \(user.username)")
//        } catch {
//            errorMessage = error.localizedDescription
//            print("Signup failed: \(error)")
//        }
//        isLoading = false
//    }
//    func updateProfile(user: User) async { /* ... existing ... */
//        guard currentUser != nil else { return }
//        isLoading = true
//        errorMessage = nil
//        do {
//            let updatedUser = try await networkService.updateProfile(user: user)
//            self.currentUser = updatedUser
//            print("Profile updated successfully for \(updatedUser.username)")
//        } catch {
//            errorMessage = error.localizedDescription
//             print("Profile update failed: \(error)")
//        }
//        isLoading = false
//    }
//    func logout() { /* ... existing ... */
//        isAuthenticated = false
//        currentUser = nil
//         print("User logged out")
//    }
//    func registerDeviceTokenIfNeeded() { /* ... existing ... */
//         guard shouldRegisterForNotifications, let user = currentUser else { return }
//         shouldRegisterForNotifications = false
//         NotificationHelper.shared.requestPermission { granted in
//             guard granted else { print("Push notification permission denied."); return }
//             print("Push notification permission granted. Attempting to register...")
//             // Trigger system registration - token handled by AppDelegate/SceneDelegate
//             DispatchQueue.main.async { // Ensure UI thread for registration call
//                  UIApplication.shared.registerForRemoteNotifications()
//             }
//             // Simulation of getting token and sending (for when AppDelegate isn't used/fully wired)
//             let simulatedToken = "DEMO_DEVICE_TOKEN_\(UUID().uuidString.prefix(8))"
//             print("Simulated device token received: \(simulatedToken)")
//             Task { @MainActor in
//                 do {
//                     try await self.networkService.registerDeviceToken(userID: user.id, token: simulatedToken)
//                     print("Successfully sent simulated token to backend.")
//                 } catch { print("Error sending simulated token to backend: \(error)") }
//             }
//         }
//     }
//}
//
//// --- FeedViewModel (Updated for Likes/Navigation) ---
//@MainActor
//class FeedViewModel: ObservableObject {
//    @Published var posts: [Post] = []
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var authors: [UUID: User] = [:]
//
//    private let networkService = NetworkService()
//
//    func fetchFeed() async { /* ... existing ... */
//        isLoading = true
//        errorMessage = nil
//        authors = [:]
//        do {
//            let fetchedPosts = try await networkService.fetchFeed()
//             await fetchAuthors(for: fetchedPosts)
//            self.posts = fetchedPosts
//             print("Feed fetched successfully: \(posts.count) posts")
//        } catch {
//            errorMessage = error.localizedDescription
//             print("Feed fetch failed: \(error)")
//        }
//        isLoading = false
//    }
//    private func fetchAuthors(for posts: [Post]) async { /* ... existing ... */
//         let authorIDs = Set(posts.map { $0.authorID })
//        await withTaskGroup(of: (UUID, User?).self) { group in
//            for id in authorIDs where authors[id] == nil {
//                group.addTask {
//                    do { let user = try await self.networkService.fetchUser(userID: id); return (id, user) }
//                    catch { print("Failed to fetch author \(id): \(error)"); return (id, nil) }
//                }
//            }
//            for await (id, user) in group { if let fetchedUser = user { self.authors[id] = fetchedUser } }
//        }
//    }
//    func toggleLike(postID: UUID, currentUserID: UUID) async { /* ... existing ... */
//         guard let index = posts.firstIndex(where: { $0.id == postID }) else { print("Error: Post \(postID) not found in local feed data."); return }
//        let post = posts[index]
//        let isLiked = post.likes.contains(currentUserID)
//        // Optimistic UI
//        if isLiked { posts[index].likes.removeAll { $0 == currentUserID } }
//        else { posts[index].likes.append(currentUserID) }
//        // Network Call
//        do {
//            let success = try await isLiked ? networkService.unlikePost(postID: postID, userID: currentUserID) : networkService.likePost(postID: postID, userID: currentUserID)
//            if !success { print("Network call to \(isLiked ? "unlike" : "like") failed. Reverting UI."); /* Revert UI */ if isLiked { posts[index].likes.append(currentUserID) } else { posts[index].likes.removeAll { $0 == currentUserID } } }
//            else { print("Successfully \(isLiked ? "unliked" : "liked") post \(postID)") }
//        } catch { print("Error toggling like for post \(postID): \(error). Reverting UI."); /* Revert UI */ if isLiked { posts[index].likes.append(currentUserID) } else { posts[index].likes.removeAll { $0 == currentUserID } } }
//    }
//}
//
//// --- CreatePostViewModel ---
//@MainActor
//class CreatePostViewModel: ObservableObject { /* ... existing ... */
//    @Published var postText: String = ""
//    @Published var locationTag: String = ""
//    @Published var isPosting: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var didPostSuccessfully: Bool = false
//
//    private let networkService = NetworkService()
//
//    func createPost(authorID: UUID) async {
//        guard !postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { errorMessage = "Post text cannot be empty."; return }
//        isPosting = true; errorMessage = nil; didPostSuccessfully = false
//        let sampleImageURLs: [URL]? = postText.contains("kitchen") ? [URL(string:"https://via.placeholder.com/600/FFFF00/000000?text=New+Post")!] : nil
//        do {
//            _ = try await networkService.createPost(authorID: authorID, text: postText, imageURLs: sampleImageURLs, locationTag: locationTag.isEmpty ? nil : locationTag)
//            print("Post created successfully!"); didPostSuccessfully = true
//            postText = ""; locationTag = ""
//        } catch { errorMessage = "Failed to create post: \(error.localizedDescription)"; print("Post creation failed: \(error)") }
//        isPosting = false
//    }
//}
//
//// --- ProfileViewModel (Extended for Phase 2) ---
//@MainActor
//class ProfileViewModel: ObservableObject { /* ... existing ... */
//    @Published var user: User?
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var isFollowing: Bool = false
//    @Published var projects: [Project] = []
//    @Published var isLoadingProjects: Bool = false
//
//    private let networkService = NetworkService()
//    private let viewingUserID: UUID
//    private let currentUserID: UUID?
//
//    init(viewingUserID: UUID, currentUserID: UUID?) { self.viewingUserID = viewingUserID; self.currentUserID = currentUserID }
//    func fetchProfileAndProjects() async { /* ... existing ... */
//          isLoading = true; isLoadingProjects = true; errorMessage = nil
//         await withTaskGroup(of: Void.self) { group in
//             group.addTask { await self.fetchProfileData() }
//             group.addTask { await self.fetchProjectsDataIfNeeded() } // Fetches projects regardless for demo
//         }
//         isLoading = false; isLoadingProjects = false
//    }
//    private func fetchProfileData() async { /* ... existing ... */
//         do { let fetchedUser = try await networkService.fetchUser(userID: viewingUserID); self.user = fetchedUser; checkFollowingStatus(); print("Profile fetched for \(fetchedUser.username)") }
//         catch { if self.errorMessage == nil { self.errorMessage = "Profile fetch failed: \(error.localizedDescription)" }; print("Profile fetch failed for \(viewingUserID): \(error)")}
//    }
//    private func fetchProjectsDataIfNeeded() async { /* ... existing ... */
//         do { let fetchedProjects = try await networkService.fetchProjects(for: viewingUserID); self.projects = fetchedProjects; print("Fetched \(fetchedProjects.count) projects for user \(viewingUserID)") }
//         catch { if self.errorMessage == nil { self.errorMessage = "Projects fetch failed: \(error.localizedDescription)" }; print("Projects fetch failed for \(viewingUserID): \(error)") }
//    }
//    private func checkFollowingStatus() { /* ... existing ... */
//         guard let currentUser = User.loggedInUser, let viewedUserId = user?.id else { isFollowing = false; return }; isFollowing = currentUser.following.contains(viewedUserId) }
//    func follow() async { /* ... existing ... */
//        guard let viewedUserId = user?.id, let currentUserId = currentUserID else { return }; do { let success = try await networkService.followUser(userIDToFollow: viewedUserId, currentUserID: currentUserId); if success { isFollowing = true } else { errorMessage = "Failed to follow." } } catch { errorMessage = "Error following: \(error.localizedDescription)" } }
//    func unfollow() async { /* ... existing ... */
//        guard let viewedUserId = user?.id, let currentUserId = currentUserID else { return }; do { let success = try await networkService.unfollowUser(userIDToUnfollow: viewedUserId, currentUserID: currentUserId); if success { isFollowing = false } else { errorMessage = "Failed to unfollow." } } catch { errorMessage = "Error unfollowing: \(error.localizedDescription)" } }
//}
//
//// --- CreateProjectViewModel (New for Phase 2) ---
//@MainActor
//class CreateProjectViewModel: ObservableObject { /* ... existing ... */
//    @Published var projectName: String = ""
//    @Published var description: String = ""
//    @Published var location: String = ""
//    @Published var budgetRange: String = ""
//    @Published var styleTagsString: String = ""
//    @Published var isPosting: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var didPostSuccessfully: Bool = false
//    private let networkService = NetworkService()
//    func createProject(contractorID: UUID) async {
//        guard !projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { errorMessage = "Project Name and Description cannot be empty."; return }
//        isPosting = true; errorMessage = nil; didPostSuccessfully = false
//        let tags = styleTagsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
//        let samplePhotoURLs: [URL]? = [URL(string:"https://via.placeholder.com/800/CCCCCC/FFFFFF?text=New+Project")!]
//        let projectData = Project(id: UUID(), contractorID: contractorID, projectName: projectName, description: description, location: location.isEmpty ? nil : location, budgetRange: budgetRange.isEmpty ? nil : budgetRange, styleTags: tags.isEmpty ? nil : tags, photoURLs: samplePhotoURLs)
//        do { _ = try await networkService.createProject(project: projectData); print("Project created successfully!"); didPostSuccessfully = true; projectName = ""; description = ""; location = ""; budgetRange = ""; styleTagsString = "" }
//        catch { errorMessage = "Failed to create project: \(error.localizedDescription)"; print("Project creation failed: \(error)") }
//        isPosting = false
//    }
//}
//
//// --- PostDetailViewModel (FIXED - Phase 2) ---
//@MainActor
//class PostDetailViewModel: ObservableObject {
//    @Published var post: Post?
//    @Published var author: User?
//    @Published var comments: [Comment] = []
//    @Published var commentAuthors: [UUID: User] = [:] // Cache comment author details
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var newCommentText: String = ""
//    @Published var isPostingComment: Bool = false
//
//    private let networkService = NetworkService()
//    private let postID: UUID
//    // REMOVED the redundant stored property: private let initialPostData: Post?
//
//    init(postID: UUID, initialPostData: Post? = nil, initialAuthorData: User? = nil) {
//        self.postID = postID
//        // Initialize @Published properties directly from parameters
//        self.post = initialPostData
//        self.author = initialAuthorData
//        // All required stored properties (postID, networkService) are now initialized.
//    }
//
//    func fetchPostDetailsAndComments() async { /* ... existing ... */
//        isLoading = true; errorMessage = nil; commentAuthors = [:]
//        await withTaskGroup(of: Void.self) { group in
//            group.addTask { await self.fetchPostData() }
//            group.addTask { await self.fetchCommentData() }
//        }
//        isLoading = false
//    }
//    private func fetchPostData() async { /* ... existing ... */
//        print("Simulating fetch for Post \(postID)")
//        // Use the up-to-date samplePosts array
//        if let foundPostIndex = Post.samplePosts.firstIndex(where: { $0.id == postID }) {
//           let foundPost = Post.samplePosts[foundPostIndex] // Get the potentially updated post
//            self.post = foundPost
//            if self.author == nil { await fetchAuthorData(authorID: foundPost.authorID) }
//        } else { if errorMessage == nil { errorMessage = "Post not found." }; print("Post \(postID) not found in sample data during fetch.") }
//    }
//    private func fetchAuthorData(authorID: UUID) async { /* ... existing ... */
//       guard self.author == nil else { return }; do { self.author = try await networkService.fetchUser(userID: authorID) } catch { print("Failed to fetch author \(authorID) for post detail: \(error)"); if errorMessage == nil { errorMessage = "Could not load author details." } } }
//    private func fetchCommentData() async { /* ... existing ... */
//        do { let fetchedComments = try await networkService.fetchComments(for: postID); self.comments = fetchedComments; await fetchCommentAuthorDetails(for: fetchedComments); print("Fetched \(fetchedComments.count) comments for post \(postID)") }
//        catch { if errorMessage == nil { errorMessage = "Failed to fetch comments: \(error.localizedDescription)" }; print("Comment fetch failed for post \(postID): \(error)") }
//    }
//    private func fetchCommentAuthorDetails(for comments: [Comment]) async { /* ... existing ... */
//       let authorIDs = Set(comments.map { $0.authorID }); await withTaskGroup(of: (UUID, User?).self) { group in for id in authorIDs where commentAuthors[id] == nil { group.addTask { do { let user = try await self.networkService.fetchUser(userID: id); return (id, user) } catch { print("Failed to fetch comment author \(id): \(error)"); return (id, nil) } } }; for await (id, user) in group { if let fetchedUser = user { self.commentAuthors[id] = fetchedUser } } } }
//    func postComment(authorID: UUID) async { /* ... existing ... */
//        guard let currentPostID = self.post?.id, !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { errorMessage = "Comment text cannot be empty."; return }
//        isPostingComment = true; errorMessage = nil
//        do { let createdComment = try await networkService.postComment(postID: currentPostID, authorID: authorID, text: newCommentText); comments.append(createdComment); if commentAuthors[authorID] == nil { await fetchCommentAuthorDetails(for: [createdComment]) }; post?.commentCount += 1; newCommentText = ""; print("Comment posted successfully") }
//        catch { errorMessage = "Failed to post comment: \(error.localizedDescription)"; print("Comment posting failed: \(error)") }
//        isPostingComment = false
//    }
//    func toggleLike(currentUserID: UUID) async { /* ... existing ... */
//         guard var currentPost = post else { return } // Make mutable copy
//         let currentPostID = currentPost.id
//         let isLiked = currentPost.likes.contains(currentUserID)
//        // Optimistic UI
//        if isLiked { currentPost.likes.removeAll { $0 == currentUserID } }
//        else { currentPost.likes.append(currentUserID) }
//        self.post = currentPost // Update the published property
//        // Network
//        do { let success = try await isLiked ? networkService.unlikePost(postID: currentPostID, userID: currentUserID) : networkService.likePost(postID: currentPostID, userID: currentUserID); if !success { print("Network call to \(isLiked ? "unlike":"like") fail. Reverting."); /* Revert */ if isLiked { currentPost.likes.append(currentUserID) } else { currentPost.likes.removeAll { $0 == currentUserID } }; self.post = currentPost } else { print("Success \(isLiked ? "unlike":"like")") } }
//        catch { print("Error toggle like: \(error). Reverting."); /* Revert */ if isLiked { currentPost.likes.append(currentUserID) } else { currentPost.likes.removeAll { $0 == currentUserID } }; self.post = currentPost }
//    }
//}
//
//// --- NotificationsViewModel (New for Phase 2) ---
//@MainActor
//class NotificationsViewModel: ObservableObject { /* ... existing ... */
//    @Published var notifications: [AppNotification] = []
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var actors: [UUID: User] = [:] // Cache notification actor details
//    private let networkService = NetworkService()
//    func fetchNotifications(for userID: UUID) async { /* ... existing ... */
//        isLoading = true; errorMessage = nil; actors = [:]
//        do { let fetchedNotifications = try await networkService.fetchNotifications(for: userID); self.notifications = fetchedNotifications; await fetchActorDetails(for: fetchedNotifications); print("Fetched \(fetchedNotifications.count) notifications") }
//        catch { errorMessage = "Failed to fetch notifications: \(error.localizedDescription)"; print("Notification fetch failed: \(error)") }
//        isLoading = false
//    }
//    private func fetchActorDetails(for notifications: [AppNotification]) async { /* ... existing ... */
//        let actorIDs = Set(notifications.map { $0.actorUserID }); await withTaskGroup(of: (UUID, User?).self) { group in for id in actorIDs where actors[id] == nil { group.addTask { do { let user = try await self.networkService.fetchUser(userID: id); return (id, user) } catch { print("Failed to fetch notification actor \(id): \(error)"); return (id, nil) } } }; for await (id, user) in group { if let fetchedUser = user { self.actors[id] = fetchedUser } } } }
//    func markAsRead(notificationID: UUID) async { /* ... existing ... */
//        if let index = notifications.firstIndex(where: { $0.id == notificationID }) { notifications[index].isRead = true } // Optimistic
//        do { let success = try await networkService.markNotificationAsRead(notificationID: notificationID); if !success { print("Failed backend mark read."); /* Revert */ if let index = notifications.firstIndex(where: { $0.id == notificationID }) { notifications[index].isRead = false } } else { print("Success mark read.") } }
//        catch { print("Error mark read: \(error)"); /* Revert */ if let index = notifications.firstIndex(where: { $0.id == notificationID }) { notifications[index].isRead = false } } }
//}
//
//// MARK: - UI Views (SwiftUI - Extended for Phase 2)
//
//// --- Helper for Requesting Notification Permissions ---
//class NotificationHelper { /* ... existing ... */
//    static let shared = NotificationHelper()
//    private init() {}
//    func requestPermission(completion: @escaping (Bool) -> Void) { UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in DispatchQueue.main.async { if let error = error { print("Error requesting permission: \(error)"); completion(false) } else { completion(granted) } } } }
//    func handleTokenRegistration(deviceToken: Data) { let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }; let tokenString = tokenParts.joined(); print("Device Token: \(tokenString)") /* Send to backend */ }
//}
//
//// --- Authentication Views (Unchanged from Phase 1) ---
//struct LoginView: View { /* ... existing ... */
//    @State private var username = ""
//    @State private var password = ""
//    @EnvironmentObject var authViewModel: AuthViewModel
//    var body: some View { VStack(spacing: 20) { Text("BuildConnect").font(.largeTitle).bold(); Image(systemName: "hammer.fill").resizable().scaledToFit().frame(width: 80, height: 80).foregroundColor(.orange); TextField("Username (try 'builder')", text: $username).textFieldStyle(RoundedBorderTextFieldStyle()).autocapitalization(.none).disableAutocorrection(true); SecureField("Password (try 'password')", text: $password).textFieldStyle(RoundedBorderTextFieldStyle()); if authViewModel.isLoading { ProgressView() } else { Button("Login") { Task { await authViewModel.login(username: username, password: password) } }.buttonStyle(.borderedProminent); Button("Don't have an account? Sign Up") { Task { await authViewModel.signup(username: "newuser", password: "newpassword") } }.font(.footnote) }; if let errorMessage = authViewModel.errorMessage { Text(errorMessage).foregroundColor(.red).font(.caption) } }.padding() }
//}
//
//// --- Main App Structure (Extended for Phase 2) ---
//struct ContentView: View { /* ... existing ... */
//    @StateObject private var authViewModel = AuthViewModel()
//    var body: some View { Group { if authViewModel.isAuthenticated && authViewModel.currentUser != nil { MainTabView().onAppear { authViewModel.registerDeviceTokenIfNeeded() } } else { LoginView() } }.environmentObject(authViewModel) }
//}
//struct MainTabView: View { /* ... existing ... */
//     @EnvironmentObject var authViewModel: AuthViewModel
//    var body: some View { TabView { NavigationView { FeedView() }.tabItem { Label("Feed", systemImage: "list.bullet") }; NavigationView { CreatePostView() }.tabItem { Label("Create", systemImage: "plus.square.fill") }; NavigationView { NotificationsView() }.tabItem { Label("Activity", systemImage: "bell.fill") }; NavigationView { if let userID = authViewModel.currentUser?.id { ProfileViewWrapper(viewingUserID: userID) } else { Text("Error: Not logged in.") } }.tabItem { Label("Profile", systemImage: "person.fill") } } }
//}
//
//// --- Feed Views (PostRowView updated for Phase 2 Engagement) ---
//struct FeedView: View { /* ... existing ... */
//    @StateObject private var viewModel = FeedViewModel()
//    @EnvironmentObject var authViewModel: AuthViewModel
//    var body: some View { List { if viewModel.isLoading && viewModel.posts.isEmpty { ProgressView().frame(maxWidth: .infinity, alignment: .center) } else if let errorMessage = viewModel.errorMessage { Text("Error: \(errorMessage)").foregroundColor(.red) } else { ForEach($viewModel.posts) { $post in NavigationLink(destination: PostDetailViewWrapper(postID: post.id, initialPostData: post, initialAuthorData: viewModel.authors[post.authorID])) { PostRowView(post: $post, author: viewModel.authors[post.authorID], feedViewModel: viewModel) }.buttonStyle(PlainButtonStyle()) } } }.listStyle(PlainListStyle()).navigationTitle("Feed").refreshable { await viewModel.fetchFeed() }.task { if viewModel.posts.isEmpty { await viewModel.fetchFeed() } } }
//}
//struct PostRowView: View { /* ... existing ... */
//    @Binding var post: Post; let author: User?; @ObservedObject var feedViewModel: FeedViewModel; @EnvironmentObject var authViewModel: AuthViewModel; var isLikedByCurrentUser: Bool { guard let currentUserID = authViewModel.currentUser?.id else { return false }; return post.likes.contains(currentUserID) }
//    var body: some View { VStack(alignment: .leading, spacing: 10) { NavigationLink(destination: ProfileViewWrapper(viewingUserID: post.authorID)) { HStack { AsyncImage(url: author?.profileImageURL) { $0.resizable().scaledToFill() } placeholder: { Image(systemName: "person.circle.fill").resizable().foregroundColor(.gray) }.frame(width: 40, height: 40).clipShape(Circle()); VStack(alignment: .leading) { Text(author?.username ?? "Loading...").font(.headline); Text(post.timestamp, style: .relative).font(.caption).foregroundColor(.gray) }; Spacer() } }.buttonStyle(PlainButtonStyle()); Text(post.text).bodyText(); if let imageURLs = post.imageURLs, !imageURLs.isEmpty { ScrollView(.horizontal, showsIndicators: false) { HStack { ForEach(imageURLs, id: \.self) { url in AsyncImage(url: url) { $0.resizable().scaledToFit() } placeholder: { Rectangle().fill(.gray.opacity(0.3)).overlay(ProgressView()) }.frame(height: 200).cornerRadius(8) } } } }; if let location = post.locationTag { HStack { Image(systemName: "mappin.and.ellipse"); Text(location) }.font(.caption).foregroundColor(.gray) }; HStack(spacing: 20) { Button { guard let currentUserID = authViewModel.currentUser?.id else { return }; Task { await feedViewModel.toggleLike(postID: post.id, currentUserID: currentUserID) } } label: { Label("\(post.likes.count)", systemImage: isLikedByCurrentUser ? "heart.fill" : "heart").foregroundColor(isLikedByCurrentUser ? .red : .secondary) }; Label("\(post.commentCount)", systemImage: "bubble.left").foregroundColor(.secondary); Spacer(); Button { /* Share Action */ } label: { Label("Share", systemImage: "square.and.arrow.up") }.foregroundColor(.secondary) }.buttonStyle(PlainButtonStyle()).padding(.top, 8) }.padding(.vertical, 8) }
//}
//
//// --- Post Detail & Comments Views (New for Phase 2) ---
//struct PostDetailViewWrapper: View { /* ... existing ... */
//    let postID: UUID; let initialPostData: Post?; let initialAuthorData: User?; @EnvironmentObject var authViewModel: AuthViewModel
//    var body: some View { PostDetailView(viewModel: PostDetailViewModel(postID: postID, initialPostData: initialPostData, initialAuthorData: initialAuthorData)).environmentObject(authViewModel) }
//}
//struct PostDetailView: View { /* ... existing ... */
//    @StateObject var viewModel: PostDetailViewModel; @EnvironmentObject var authViewModel: AuthViewModel; @FocusState private var isCommentFieldFocused: Bool; var isLikedByCurrentUser: Bool { guard let currentUserID = authViewModel.currentUser?.id else { return false }; return viewModel.post?.likes.contains(currentUserID) ?? false }
//    var body: some View { ScrollView { VStack(alignment: .leading) { if viewModel.isLoading && viewModel.post == nil { ProgressView() } else if let post = viewModel.post { PostContentView(post: post, author: viewModel.author); HStack(spacing: 20) { Button { guard let currentUserID = authViewModel.currentUser?.id else { return }; Task { await viewModel.toggleLike(currentUserID: currentUserID) } } label: { Label("\(post.likes.count)", systemImage: isLikedByCurrentUser ? "heart.fill" : "heart").foregroundColor(isLikedByCurrentUser ? .red : .secondary) }; Button { isCommentFieldFocused = true } label: { Label("\(post.commentCount)", systemImage: "bubble.left").foregroundColor(.secondary) }; Spacer(); Button { /* Share Action */ } label: { Label("Share", systemImage: "square.and.arrow.up") }.foregroundColor(.secondary) }.buttonStyle(PlainButtonStyle()).padding(.horizontal).padding(.top, 5); Divider().padding(.vertical); Text("Comments (\(post.commentCount))").font(.headline).padding(.horizontal); if viewModel.isLoading { ProgressView().padding() } else if viewModel.comments.isEmpty { Text("No comments yet.").foregroundColor(.gray).padding() } else { LazyVStack(alignment: .leading, spacing: 15) { ForEach(viewModel.comments) { comment in CommentRowView(comment: comment, author: viewModel.commentAuthors[comment.authorID]) } }.padding(.horizontal) }; } else if let errorMessage = viewModel.errorMessage { Text("Error: \(errorMessage)").foregroundColor(.red).padding() } else { Text("Post not found.").padding() }; Spacer(minLength: 80) } }.navigationTitle("Post").navigationBarTitleDisplayMode(.inline).task { if viewModel.post == nil || viewModel.comments.isEmpty { await viewModel.fetchPostDetailsAndComments() } }.overlay(alignment: .bottom) { CommentInputView(viewModel: viewModel).focused($isCommentFieldFocused) }.onTapGesture { isCommentFieldFocused = false } }
//}
//struct PostContentView: View { /* ... existing ... */
//    let post: Post; let author: User?;
//    var body: some View { VStack(alignment: .leading, spacing: 10) { NavigationLink(destination: ProfileViewWrapper(viewingUserID: post.authorID)) { HStack { AsyncImage(url: author?.profileImageURL) { $0.resizable().scaledToFill() } placeholder: { Image(systemName: "person.circle.fill").resizable().foregroundColor(.gray) }.frame(width: 40, height: 40).clipShape(Circle()); VStack(alignment: .leading) { Text(author?.username ?? "Loading...").font(.headline); Text(post.timestamp, style: .relative).font(.caption).foregroundColor(.gray) }; Spacer() } }.buttonStyle(PlainButtonStyle()); Text(post.text).bodyText(); if let imageURLs = post.imageURLs, !imageURLs.isEmpty { ScrollView(.horizontal, showsIndicators: false) { HStack { ForEach(imageURLs, id: \.self) { url in AsyncImage(url: url) { $0.resizable().scaledToFit() } placeholder: { Rectangle().fill(.gray.opacity(0.3)).overlay(ProgressView()) }.frame(height: 300).cornerRadius(8) } } } }; if let location = post.locationTag { HStack { Image(systemName: "mappin.and.ellipse"); Text(location) }.font(.caption).foregroundColor(.gray) } }.padding() }
//}
//struct CommentRowView: View { /* ... existing ... */
//    let comment: Comment; let author: User?
//    var body: some View { HStack(alignment: .top, spacing: 10) { NavigationLink(destination: ProfileViewWrapper(viewingUserID: comment.authorID)) { AsyncImage(url: author?.profileImageURL) { $0.resizable().scaledToFill() } placeholder: { Image(systemName: "person.circle.fill").resizable().foregroundColor(.gray) }.frame(width: 30, height: 30).clipShape(Circle()) }; VStack(alignment: .leading, spacing: 3) { HStack(alignment: .firstTextBaseline) { Text(author?.username ?? "User").font(.subheadline).bold(); Text(comment.timestamp, style: .relative).font(.caption2).foregroundColor(.gray) }; Text(comment.text).font(.subheadline) }; Spacer() } }
//}
//struct CommentInputView: View { /* ... existing ... */
//    @ObservedObject var viewModel: PostDetailViewModel; @EnvironmentObject var authViewModel: AuthViewModel
//    var body: some View { HStack(alignment: .bottom) { AsyncImage(url: authViewModel.currentUser?.profileImageURL) { $0.resizable().scaledToFill() } placeholder: { Image(systemName: "person.circle.fill").resizable().foregroundColor(.gray) }.frame(width: 35, height: 35).clipShape(Circle()); TextEditor(text: $viewModel.newCommentText).frame(minHeight: 35, maxHeight: 100).padding(.horizontal, 8).background(Color(uiColor: .systemGray6)).cornerRadius(18).overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(uiColor: .systemGray4), lineWidth: 1)); Button { guard let authorID = authViewModel.currentUser?.id else { return }; UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil); Task { await viewModel.postComment(authorID: authorID) } } label: { Image(systemName: "arrow.up.circle.fill").resizable().frame(width: 30, height: 30).foregroundColor(viewModel.newCommentText.isEmpty ? .gray : .blue) }.disabled(viewModel.newCommentText.isEmpty || viewModel.isPostingComment).opacity(viewModel.isPostingComment ? 0.5 : 1.0) }.padding(.horizontal).padding(.vertical, 8).background(.thinMaterial) }
//}
//
//// --- Post Creation View (Unchanged from Phase 1) ---
//struct CreatePostView: View { /* ... existing ... */
//    @StateObject private var viewModel = CreatePostViewModel(); @EnvironmentObject var authViewModel: AuthViewModel; @Environment(\.presentationMode) var presentationMode
//    var body: some View { VStack(alignment: .leading) { Text("Create New Post").font(.title2).bold().padding(.bottom); TextEditor(text: $viewModel.postText).frame(height: 150).border(Color.gray.opacity(0.5), width: 1).cornerRadius(5).accessibilityLabel("Post content text editor"); TextField("Location Tag (Optional)", text: $viewModel.locationTag).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.vertical); Text("Add Images (Feature coming soon!)").font(.caption).foregroundColor(.gray).padding(.bottom); if viewModel.isPosting { ProgressView("Posting...").frame(maxWidth: .infinity, alignment: .center) } else { Button("Post to Feed") { Task { guard let authorID = authViewModel.currentUser?.id else { viewModel.errorMessage = "Error: Not logged in."; return }; await viewModel.createPost(authorID: authorID) } }.buttonStyle(.borderedProminent).frame(maxWidth: .infinity, alignment: .center).disabled(viewModel.postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) }; if let errorMessage = viewModel.errorMessage { Text(errorMessage).foregroundColor(.red).font(.caption).padding(.top) }; Spacer() }.padding().navigationTitle("New Post").navigationBarTitleDisplayMode(.inline).onChange(of: viewModel.didPostSuccessfully) { success in if success { presentationMode.wrappedValue.dismiss() } } }
//}
//
//// --- Profile Views (Extended for Phase 2) ---
//struct ProfileViewWrapper: View { /* ... existing ... */
//    let viewingUserID: UUID; @EnvironmentObject var authViewModel: AuthViewModel
//    var body: some View { ProfileView(viewModel: ProfileViewModel(viewingUserID: viewingUserID, currentUserID: authViewModel.currentUser?.id)).environmentObject(authViewModel) }
//}
//struct ProfileView: View { /* ... existing ... */
//    @StateObject var viewModel: ProfileViewModel; @EnvironmentObject var authViewModel: AuthViewModel; @State private var showingEditProfile = false; @State private var showingCreateProject = false; var isViewingOwnProfile: Bool { viewModel.user?.id == authViewModel.currentUser?.id }
//    var body: some View { ScrollView { if viewModel.isLoading && viewModel.user == nil { ProgressView("Loading Profile...").padding() } else if let user = viewModel.user { VStack(alignment: .leading, spacing: 15) { ProfileHeaderView(user: user, isFollowing: viewModel.isFollowing, isViewingOwnProfile: isViewingOwnProfile) { action in handleHeaderAction(action) }; ProfileDetailSectionView(user: user); ProfileActionsView(isViewingOwnProfile: isViewingOwnProfile, isFollowing: viewModel.isFollowing, isLoading: viewModel.isLoading) { action in handleHeaderAction(action) }; PortfolioSectionView(projects: viewModel.projects, isLoading: viewModel.isLoadingProjects, isOwnProfile: isViewingOwnProfile, onCreateProject: { showingCreateProject = true }); PostsSectionPlaceholderView(); if let errorMessage = viewModel.errorMessage { Text("Error: \(errorMessage)").foregroundColor(.red).font(.caption).padding(.top) } }.padding(.horizontal).padding(.bottom) } else if let errorMessage = viewModel.errorMessage { Text("Error loading profile: \(errorMessage)").foregroundColor(.red).padding() } else { Text("User not found.").padding() } }.navigationTitle(viewModel.user?.username ?? "Profile").navigationBarTitleDisplayMode(.inline).task { await viewModel.fetchProfileAndProjects() }.sheet(isPresented: $showingEditProfile) { if let currentUser = authViewModel.currentUser { NavigationView { EditProfileView(userToEdit: currentUser).environmentObject(authViewModel) } } }.sheet(isPresented: $showingCreateProject) { if let currentUser = authViewModel.currentUser { NavigationView { CreateProjectView().environmentObject(authViewModel) } } }.onReceive(authViewModel.$currentUser) { updatedUser in if updatedUser?.id == viewModel.user?.id { viewModel.user = updatedUser } } }
//    private func handleHeaderAction(_ action: ProfileAction) { /* ... existing ... */
//         switch action { case .edit: showingEditProfile = true; case .follow: Task { await viewModel.follow() }; case .unfollow: Task { await viewModel.unfollow() }; case .message: print("Nav message NYI"); case .call: if let phone = viewModel.user?.contactPhone, let url = URL(string: "tel:\(phone.filter("0123456789".contains))") { if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) } else { print("Cannot call") } }; case .email: if let email = viewModel.user?.contactEmail, let url = URL(string: "mailto:\(email)") { if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) } else { print("Cannot email") } } } }
//}
//enum ProfileAction { case edit, follow, unfollow, message, call, email }
//struct ProfileHeaderView: View { /* ... existing ... */
//    let user: User; let isFollowing: Bool; let isViewingOwnProfile: Bool; let onAction: (ProfileAction) -> Void
//    var body: some View { VStack(alignment: .leading, spacing: 5) { HStack(alignment: .top) { AsyncImage(url: user.profileImageURL) { $0.resizable().scaledToFill() } placeholder: { Image(systemName: "person.circle.fill").resizable().foregroundColor(.gray) }.frame(width: 80, height: 80).clipShape(Circle()); VStack(alignment: .leading) { Text(user.username).font(.title2).bold(); HStack { Text("**\(user.followers.count)** followers"); Text("**\(user.following.count)** following") }.font(.subheadline).foregroundColor(.gray) }; Spacer(); if !isViewingOwnProfile { HStack { if user.contactEmail != nil { Button { onAction(.email) } label: { Image(systemName: "envelope.fill") }.tint(.secondary) }; if user.contactPhone != nil { Button { onAction(.call) } label: { Image(systemName: "phone.fill") }.tint(.secondary) } }.font(.title3) } }.padding(.top) ; if let bio = user.bio, !bio.isEmpty { Text(bio).bodyText().padding(.top, 5) } } }
//struct ProfileDetailSectionView: View { /* ... existing ... */
//    let user: User; var body: some View { VStack(alignment: .leading, spacing: 10) { Divider(); if let services = user.servicesOffered, !services.isEmpty { InfoRow(label: "Services", value: services.joined(separator: ", ")) }; if let area = user.serviceAreaDescription, !area.isEmpty { InfoRow(label: "Service Area", value: area) }; if let certs = user.certifications, !certs.isEmpty { InfoRow(label: "Certifications", value: certs.joined(separator: "\n")) }; Divider() }.padding(.vertical, 5) } }
//struct InfoRow: View { /* ... existing ... */
//    let label: String; let value: String; var body: some View { VStack(alignment: .leading) { Text(label).font(.caption).foregroundColor(.gray); Text(value).font(.subheadline) } } }
//struct ProfileActionsView: View { /* ... existing ... */
//    let isViewingOwnProfile: Bool; let isFollowing: Bool; let isLoading: Bool; let onAction: (ProfileAction) -> Void
//    var body: some View { HStack(spacing: 10) { if isViewingOwnProfile { Button { onAction(.edit) } label: { Text("Edit Profile").frame(maxWidth: .infinity) }.buttonStyle(.bordered) } else { Button { onAction(isFollowing ? .unfollow : .follow) } label: { Text(isFollowing ? "Following" : "Follow").frame(maxWidth: .infinity) }.buttonStyle(isFollowing ? .bordered : .borderedProminent).disabled(isLoading); Button { onAction(.message) } label: { Text("Message").frame(maxWidth: .infinity) }.buttonStyle(.bordered).disabled(isLoading) } }.padding(.bottom, 5) } }
//struct PortfolioSectionView: View { /* ... existing ... */
//    let projects: [Project]; let isLoading: Bool; let isOwnProfile: Bool; let onCreateProject: () -> Void
//    var body: some View { VStack(alignment: .leading) { HStack { Text("Portfolio").font(.title2).bold(); Spacer(); if isOwnProfile { Button { onCreateProject() } label: { Image(systemName: "plus.circle.fill") }.font(.title2) } }
