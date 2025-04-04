//
//  V3.swift
//  MyApp
//
//  Created by Cong Le on 4/4/25.
//

import SwiftUI
import Combine // Required for ObservableObject
import UserNotifications // For Notifications

// MARK: - Data Models (Phase 1 & 2)

// --- User Model (Extended for Phase 2) ---
struct User: Identifiable, Codable, Hashable {
    let id: UUID
    var username: String
    var bio: String?
    var profileImageURL: URL?
    var following: [UUID] = []
    var followers: [UUID] = []

    // --- Phase 2 Additions ---
    var servicesOffered: [String]? // e.g., ["General Contracting", "Kitchen Remodeling"]
    var serviceAreaDescription: String? // e.g., "San Francisco Bay Area" (Text for MVP)
    var certifications: [String]? // e.g., ["Licensed General Contractor #12345"]
    var contactEmail: String?
    var contactPhone: String?
    // -------------------------

    // Sample Data (Updates for Phase 2 fields)
    static var sampleUser1 = User(id: UUID(), username: "BuildMasterPro", bio: "Crafting dream homes since 2005. Quality & Precision.", profileImageURL: URL(string: "https://via.placeholder.com/150/FFA07A/000000?text=BMP"), servicesOffered: ["General Contracting", "New Construction", "ADUs"], serviceAreaDescription: "South Bay & Peninsula", certifications: ["Licensed GC #123456"], contactEmail: "contact@buildmaster.pro", contactPhone: "555-111-2222")
    static var sampleUser2 = User(id: UUID(), username: "DesignBuildInspire", bio: "Innovative designs meet expert construction.", profileImageURL: URL(string: "https://via.placeholder.com/150/ADD8E6/000000?text=DBI"), servicesOffered: ["Interior Design", "Kitchen & Bath Remodel"], serviceAreaDescription: "San Francisco City", contactEmail: "hello@dbi.design")
    static var sampleUser3 = User(id: UUID(), username: "HomeownerHub", bio: "Planning my next big renovation!", profileImageURL: URL(string: "https://via.placeholder.com/150/90EE90/000000?text=HH"))

    static var loggedInUser = sampleUser1 // Simulate logged-in user
}

// --- Post Model (Phase 1) ---
struct Post: Identifiable, Codable, Hashable {
    let id: UUID
    let authorID: UUID
    let text: String
    let imageURLs: [URL]?
    let timestamp: Date
    var locationTag: String?

    // Phase 2 additions (for engagement tracking)
    var likes: [UUID] = [] // User IDs who liked the post
    var commentCount: Int = 0 // Keep track locally for display

    // Sample Data (Updates for Phase 2)
    static var samplePosts: [Post] = [
        Post(id: UUID(), authorID: User.sampleUser1.id, text: "Just finished framing this beauty! Solid structure coming along nicely. #framing #construction #newbuild", imageURLs: [URL(string:"https://via.placeholder.com/600/FFA07A/FFFFFF?text=Frame+1")!], timestamp: Date().addingTimeInterval(-3600), locationTag: "Sunnyvale Project", likes: [User.sampleUser2.id, User.sampleUser3.id], commentCount: 2),
        Post(id: UUID(), authorID: User.sampleUser2.id, text: "Kitchen transformation complete! Loving these custom cabinets and quartz countertops. What do you think?", imageURLs: [URL(string:"https://via.placeholder.com/600/ADD8E6/FFFFFF?text=Kitchen+1")!, URL(string:"https://via.placeholder.com/600/ADD8E6/FFFFFF?text=Kitchen+2")!], timestamp: Date().addingTimeInterval(-7200), locationTag: "Downtown Loft Reno", likes: [User.sampleUser1.id], commentCount: 1),
        Post(id: UUID(), authorID: User.sampleUser1.id, text: "Pouring the foundation today. Solid groundwork is key! #foundation #concrete #buildconnect", imageURLs: nil, timestamp: Date().addingTimeInterval(-10800), commentCount: 0),
        Post(id: UUID(), authorID: User.sampleUser3.id, text: "Looking for recommendations for a good roofing contractor in the Bay Area! Any suggestions?", imageURLs: nil, timestamp: Date().addingTimeInterval(-14400), commentCount: 0)
    ]
}

// --- Project Model (New for Phase 2) ---
struct Project: Identifiable, Codable, Hashable {
    let id: UUID
    let contractorID: UUID // User ID of the contractor
    var projectName: String
    var description: String
    var location: String? // e.g., "Palo Alto, CA"
    var budgetRange: String? // e.g., "$100k - $150k"
    var styleTags: [String]? // e.g., ["Modern", "Farmhouse"]
    var photoURLs: [URL]?
    var videoURL: URL? // Simplified: one video URL
    let timestamp: Date = Date() // Date project was added/updated

    // Sample Data
    static var sampleProjects: [Project] = [
        Project(id: UUID(), contractorID: User.sampleUser1.id, projectName: "Modern Eichler Renovation", description: "Complete overhaul of a classic Eichler home, focusing on open spaces and natural light.", location: "Palo Alto, CA", budgetRange: "$400k+", styleTags: ["Modern", "Mid-Century", "Open Concept"], photoURLs: [URL(string:"https://via.placeholder.com/800/FFA07A/FFFFFF?text=Eichler+Living")!, URL(string:"https://via.placeholder.com/800/FFA07A/FFFFFF?text=Eichler+Kitchen")!]),
        Project(id: UUID(), contractorID: User.sampleUser1.id, projectName: "Luxury ADU Build", description: "Custom-designed Accessory Dwelling Unit with high-end finishes.", location: "Los Altos Hills, CA", budgetRange: "$250k - $300k", styleTags: ["Luxury", "Compact", "ADU"], photoURLs: [URL(string:"https://via.placeholder.com/800/FFA07A/FFFFFF?text=ADU+Exterior")!]),
        Project(id: UUID(), contractorID: User.sampleUser2.id, projectName: "Downtown Loft Kitchen", description: "Sleek and functional kitchen design for a modern loft space.", location: "San Francisco, CA", styleTags: ["Modern", "Industrial", "Minimalist"], photoURLs: [URL(string:"https://via.placeholder.com/800/ADD8E6/FFFFFF?text=Loft+Kitchen+Main")!]),
    ]
}

// --- Comment Model (New for Phase 2) ---
struct Comment: Identifiable, Codable, Hashable {
    let id: UUID
    let postID: UUID // Which post this comment belongs to
    let authorID: UUID
    let text: String
    let timestamp: Date

    // Sample Data
    static var sampleComments: [Comment] = [
        Comment(id: UUID(), postID: Post.samplePosts[0].id, authorID: User.sampleUser2.id, text: "Looks amazing! Clean work.", timestamp: Date().addingTimeInterval(-3500)),
        Comment(id: UUID(), postID: Post.samplePosts[0].id, authorID: User.sampleUser3.id, text: "Wow, that's going to be a solid house!", timestamp: Date().addingTimeInterval(-3400)),
        Comment(id: UUID(), postID: Post.samplePosts[1].id, authorID: User.sampleUser1.id, text: "Incredible transformation!", timestamp: Date().addingTimeInterval(-7000)),
    ]
}

// --- Like Model (Implicit - Tracked by user IDs in Post) ---
// No separate struct needed if we just store user IDs.
// Could have a Like struct `{ id, userID, postID, timestamp }` if more detail needed.

// --- AppNotification Model (New for Phase 2) ---
struct AppNotification: Identifiable, Codable, Hashable {
    enum NotificationType: String, Codable {
        case newFollower, postLike, postComment, newProject // Add more as needed
    }

    let id: UUID
    let type: NotificationType
    let actorUserID: UUID // User who triggered the notification (e.g., liked the post)
    let targetPostID: UUID? // Optional: Relevant post
    let targetProjectID: UUID? // Optional: Relevant project
    let message: String // Pre-formatted message for display
    let timestamp: Date
    var isRead: Bool = false

    // Sample Data
    static let sampleNotifications: [AppNotification] = [
        AppNotification(id: UUID(), type: .postLike, actorUserID: User.sampleUser2.id, targetPostID: Post.samplePosts[0].id, targetProjectID: nil, message: "DesignBuildInspire liked your post.", timestamp: Date().addingTimeInterval(-500)),
        AppNotification(id: UUID(), type: .postComment, actorUserID: User.sampleUser3.id, targetPostID: Post.samplePosts[0].id, targetProjectID: nil, message: "HomeownerHub commented on your post.", timestamp: Date().addingTimeInterval(-400))
//        AppNotification(id: UUID(), type: .newFollower, actorUserID: User.sampleUser3.id, message: "HomeownerHub started following you.", timestamp: Date().addingTimeInterval(-6000))
    ]
}


// MARK: - Networking Stub (Extended for Phase 2)

class NetworkService {

    // --- Existing User/Post Functions (May need slight modification if return types change) ---
    func fetchUser(userID: UUID) async throws -> User {
        try await Task.sleep(nanoseconds: 500_000_000)
        let users = [User.sampleUser1, User.sampleUser2, User.sampleUser3]
        if let user = users.first(where: { $0.id == userID }) {
            return user
        } else {
            throw NSError(domain: "NetworkService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
    }

    func fetchFeed() async throws -> [Post] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        // Return copies to avoid direct mutation issues in demo
        return Post.samplePosts.map { $0 }.sorted { $0.timestamp > $1.timestamp }
    }

    func createPost(authorID: UUID, text: String, imageURLs: [URL]?, locationTag: String?) async throws -> Post {
        try await Task.sleep(nanoseconds: 800_000_000)
        let newPost = Post(id: UUID(), authorID: authorID, text: text, imageURLs: imageURLs, timestamp: Date(), locationTag: locationTag)
        // Add to the static sample data for demo
        Post.samplePosts.insert(newPost, at: 0)
        return newPost
    }

    func followUser(userIDToFollow: UUID, currentUserID: UUID) async throws -> Bool {
         try await Task.sleep(nanoseconds: 300_000_000)
        print("Simulating: User \(currentUserID) follows \(userIDToFollow)")
        // Update local state for demo - normally handle this server-side
        if var currentUser = [User.sampleUser1, User.sampleUser2, User.sampleUser3].first(where: {$0.id == currentUserID}) {
           if !currentUser.following.contains(userIDToFollow) {
               currentUser.following.append(userIDToFollow)
               if currentUserID == User.loggedInUser.id { User.loggedInUser.following = currentUser.following }
               print("User \(currentUserID) now follows \(currentUser.following.count) users.")
               return true
           }
        }
        return false
    }

    func unfollowUser(userIDToUnfollow: UUID, currentUserID: UUID) async throws -> Bool {
         try await Task.sleep(nanoseconds: 300_000_000)
         print("Simulating: User \(currentUserID) unfollows \(userIDToUnfollow)")
            // Update local state for demo
         if var currentUser = [User.sampleUser1, User.sampleUser2, User.sampleUser3].first(where: {$0.id == currentUserID}) {
            if let index = currentUser.following.firstIndex(of: userIDToUnfollow) {
                currentUser.following.remove(at: index)
                 // Update the static sample (hacky for demo)
               if currentUserID == User.loggedInUser.id { User.loggedInUser.following = currentUser.following }
                 print("User \(currentUserID) now follows \(currentUser.following.count) users.")
                return true
            }
         }
         return false
    }

    func login(username: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 600_000_000)
        if username.lowercased() == "builder" && password == "password" {
             // Return a copy to avoid shared mutable state issues in demo context
             var loggedInCopy = User.loggedInUser
             return loggedInCopy
        } else {
            throw NSError(domain: "NetworkService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
        }
    }

    func signup(username: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 900_000_000)
        print("Simulating user signup for \(username)")
         // Return a copy
        var loggedInCopy = User.loggedInUser
        return loggedInCopy
    }

    func updateProfile(user: User) async throws -> User {
        try await Task.sleep(nanoseconds: 500_000_000)
        print("Simulating profile update for \(user.username)")
        if user.id == User.loggedInUser.id {
            User.loggedInUser = user // Update the static master copy
        }
         // Find the user in potential lists and update (very hacky demo state management)
         if let index = [User.sampleUser1, User.sampleUser2, User.sampleUser3].firstIndex(where: { $0.id == user.id}) {
             // Need a way to update the original samples if needed, becomes complex
         }
        
        return user // Return the updated user (or what server would return)
    }

    // --- Phase 2 Network Stubs ---

    // --- Project Stubs ---
    func fetchProjects(for contractorID: UUID) async throws -> [Project] {
        try await Task.sleep(nanoseconds: 700_000_000)
        print("Fetching projects for user \(contractorID)")
        // Filter sample projects for the given contractor
        let userProjects = Project.sampleProjects.filter { $0.contractorID == contractorID }
        return userProjects.sorted { $0.timestamp > $1.timestamp }
    }

    func createProject(project: Project) async throws -> Project {
        try await Task.sleep(nanoseconds: 1_200_000_000) // Longer delay for project creation
        print("Simulating creation of project: \(project.projectName)")
        // In real app, send data to backend, get created project back (with ID)
        let newProject = Project(
            id: UUID(), // Server assigns ID
            contractorID: project.contractorID,
            projectName: project.projectName,
            description: project.description,
            location: project.location,
            budgetRange: project.budgetRange,
            styleTags: project.styleTags,
            photoURLs: project.photoURLs,
            videoURL: project.videoURL
            // timestamp is auto-set
        )
        Project.sampleProjects.insert(newProject, at: 0) // Add to local sample data for demo
        return newProject
    }

    // --- Engagement Stubs (Likes/Comments) ---
    func likePost(postID: UUID, userID: UUID) async throws -> Bool {
        try await Task.sleep(nanoseconds: 200_000_000)
        print("Simulating User \(userID) liking Post \(postID)")
        if let index = Post.samplePosts.firstIndex(where: { $0.id == postID }) {
            if !Post.samplePosts[index].likes.contains(userID) {
                Post.samplePosts[index].likes.append(userID)
                return true
            }
        }
        return false // Post not found or already liked
    }

    func unlikePost(postID: UUID, userID: UUID) async throws -> Bool {
        try await Task.sleep(nanoseconds: 200_000_000)
         print("Simulating User \(userID) unliking Post \(postID)")
        if let index = Post.samplePosts.firstIndex(where: { $0.id == postID }) {
            if let likeIndex = Post.samplePosts[index].likes.firstIndex(of: userID) {
                Post.samplePosts[index].likes.remove(at: likeIndex)
                return true
            }
        }
        return false // Post not found or not liked by user
    }

    func fetchComments(for postID: UUID) async throws -> [Comment] {
        try await Task.sleep(nanoseconds: 400_000_000)
         print("Fetching comments for Post \(postID)")
        // Filter sample comments
        let postComments = Comment.sampleComments.filter { $0.postID == postID }
        return postComments.sorted { $0.timestamp < $1.timestamp } // Oldest first
    }

    func postComment(postID: UUID, authorID: UUID, text: String) async throws -> Comment {
        try await Task.sleep(nanoseconds: 500_000_000)
         print("Simulating User \(authorID) commenting on Post \(postID)")
        let newComment = Comment(id: UUID(), postID: postID, authorID: authorID, text: text, timestamp: Date())
        Comment.sampleComments.append(newComment) // Add to local sample data

        // Update comment count on the post (for demo)
        if let index = Post.samplePosts.firstIndex(where: { $0.id == postID }) {
             Post.samplePosts[index].commentCount += 1
        }
        return newComment
    }

    // --- Notification Stubs ---
    func registerDeviceToken(userID: UUID, token: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        // In real app, send this token to your backend mapped to the userID
        print("Simulating registration of token \(token) for User \(userID)")
    }

    func fetchNotifications(for userID: UUID) async throws -> [AppNotification] {
        try await Task.sleep(nanoseconds: 600_000_000)
         print("Fetching notifications for User \(userID)")
        // In real app, fetch notifications targeted at the logged-in user
        // For demo, return all sample notifications (not realistic)
        return AppNotification.sampleNotifications.sorted { $0.timestamp > $1.timestamp }
    }

    func markNotificationAsRead(notificationID: UUID) async throws -> Bool {
        try await Task.sleep(nanoseconds: 100_000_000)
         print("Simulating marking notification \(notificationID) as read")
        // In real app, update status on the backend
        // For demo, find and modify in sample data (if needed, maybe not for this demo)
        return true // Assume success
    }
}

// MARK: - View Models (State Management - Extended for Phase 2)

// --- AuthViewModel (Slightly Updated for Profile) ---
@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let networkService = NetworkService()
    private var cancellables = Set<AnyCancellable>()

     // Simple flag to trigger notification registration
     @Published var shouldRegisterForNotifications = false

    init() {
         // React to authentication state changes
         $isAuthenticated
             .filter { $0 == true } // Only when becoming authenticated
             .sink { [weak self] _ in
                 self?.shouldRegisterForNotifications = true // Trigger registration attempt
             }
             .store(in: &cancellables)
     }


    func login(username: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let user = try await networkService.login(username: username, password: password)
            self.currentUser = user
            self.isAuthenticated = true
            print("Login successful for \(user.username)")
        } catch {
            errorMessage = error.localizedDescription
            print("Login failed: \(error)")
        }
        isLoading = false
    }

    func signup(username: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let user = try await networkService.signup(username: username, password: password)
            self.currentUser = user
            self.isAuthenticated = true // Auto-login after signup
             print("Signup successful for \(user.username)")
        } catch {
            errorMessage = error.localizedDescription
            print("Signup failed: \(error)")
        }
        isLoading = false
    }

    func updateProfile(user: User) async {
        guard currentUser != nil else { return }
        isLoading = true
        errorMessage = nil
        do {
            let updatedUser = try await networkService.updateProfile(user: user)
            // **IMPORTANT**: Update the currentUser published property
            self.currentUser = updatedUser
            print("Profile updated successfully for \(updatedUser.username)")
        } catch {
            errorMessage = error.localizedDescription
             print("Profile update failed: \(error)")
        }
        isLoading = false
    }

    func logout() {
        isAuthenticated = false
        currentUser = nil
         print("User logged out")
         // Clear tokens etc.
    }
    
     // --- Phase 2 Notification Registration Trigger ---
     func registerDeviceTokenIfNeeded() {
         guard shouldRegisterForNotifications, let user = currentUser else { return }
         
         shouldRegisterForNotifications = false // Reset the trigger
         
         NotificationHelper.shared.requestPermission { granted in
             guard granted else {
                 print("Push notification permission denied.")
                 return
             }
             print("Push notification permission granted. Attempting to register...")
             // Registration happens via AppDelegate or SceneDelegate usually.
             // We simulate getting the token here for demo purposes.
             let simulatedToken = "DEMO_DEVICE_TOKEN_\(UUID().uuidString.prefix(8))"
             print("Simulated device token received: \(simulatedToken)")
             
             // Send token to backend (async task)
             Task { @MainActor in // Ensure UI updates happen on main if needed later
                 do {
                     try await self.networkService.registerDeviceToken(userID: user.id, token: simulatedToken)
                     print("Successfully sent simulated token to backend.")
                 } catch {
                     print("Error sending simulated token to backend: \(error)")
                     // Handle error appropriately (e.g., retry mechanism)
                 }
             }
         }
     }
}

// --- FeedViewModel (Updated for Likes/Navigation) ---
@MainActor
class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var authors: [UUID: User] = [:] // Cache author details

    private let networkService = NetworkService()

    func fetchFeed() async {
        isLoading = true
        errorMessage = nil
        // Clear authors cache before fetching new feed
        authors = [:]
        do {
            let fetchedPosts = try await networkService.fetchFeed()
             // Fetch authors immediately after getting posts
             await fetchAuthors(for: fetchedPosts)
            // Assign fetched posts AFTER authors are potentially loaded
             self.posts = fetchedPosts
             print("Feed fetched successfully: \(posts.count) posts")
        } catch {
            errorMessage = error.localizedDescription
             print("Feed fetch failed: \(error)")
        }
        isLoading = false
    }

    private func fetchAuthors(for posts: [Post]) async {
        let authorIDs = Set(posts.map { $0.authorID })
        // Use a TaskGroup for concurrent fetching
        await withTaskGroup(of: (UUID, User?).self) { group in
            for id in authorIDs where authors[id] == nil { // Only fetch if not cached
                group.addTask {
                    do {
                        let user = try await self.networkService.fetchUser(userID: id)
                        return (id, user)
                    } catch {
                        print("Failed to fetch author \(id): \(error)")
                        return (id, nil) // Return nil on failure
                    }
                }
            }

            // Collect results from the group
            for await (id, user) in group {
                if let fetchedUser = user {
                    self.authors[id] = fetchedUser
                } else {
                    // Optionally mark as failed or use a placeholder
                }
            }
        }
    }

    // --- Phase 2 Like Handling ---
    func toggleLike(postID: UUID, currentUserID: UUID) async {
        // 1. Find the post locally
        guard let index = posts.firstIndex(where: { $0.id == postID }) else {
             print("Error: Post \(postID) not found in local feed data.")
             return
        }

        let post = posts[index]
        let isLiked = post.likes.contains(currentUserID)

        // 2. Optimistic UI Update
        if isLiked {
             posts[index].likes.removeAll { $0 == currentUserID }
        } else {
            posts[index].likes.append(currentUserID)
        }

        // 3. Call Network Service
        do {
            let success: Bool
            if isLiked {
                success = try await networkService.unlikePost(postID: postID, userID: currentUserID)
            } else {
                success = try await networkService.likePost(postID: postID, userID: currentUserID)
            }

            // 4. Revert UI if network call failed
            if !success {
                 print("Network call to \(isLiked ? "unlike" : "like") failed. Reverting UI.")
                 // Revert the optimistic update
                 if isLiked {
                     posts[index].likes.append(currentUserID) // Add it back
                 } else {
                     posts[index].likes.removeAll { $0 == currentUserID } // Remove it again
                 }
            } else {
                 print("Successfully \(isLiked ? "unliked" : "liked") post \(postID)")
            }
        } catch {
            print("Error toggling like for post \(postID): \(error). Reverting UI.")
             // Revert the optimistic update on error
             if isLiked {
                 posts[index].likes.append(currentUserID)
             } else {
                 posts[index].likes.removeAll { $0 == currentUserID }
             }
        }
    }
}


// --- CreatePostViewModel (No changes needed for Phase 2 structure) ---
@MainActor
class CreatePostViewModel: ObservableObject {
    @Published var postText: String = ""
    @Published var locationTag: String = ""
    @Published var isPosting: Bool = false
    @Published var errorMessage: String? = nil
    @Published var didPostSuccessfully: Bool = false

    private let networkService = NetworkService()

    func createPost(authorID: UUID) async {
        guard !postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Post text cannot be empty."
            return
        }

        isPosting = true
        errorMessage = nil
        didPostSuccessfully = false
        let sampleImageURLs: [URL]? = postText.contains("kitchen") ? [URL(string:"https://via.placeholder.com/600/FFFF00/000000?text=New+Post")!] : nil

        do {
            let newPost = try await networkService.createPost(
                authorID: authorID,
                text: postText,
                imageURLs: sampleImageURLs,
                locationTag: locationTag.isEmpty ? nil : locationTag
            )
            print("Post created successfully!")
            didPostSuccessfully = true
             // Add the new post to the local sample data (for demo purposes)
             // Note: This won't automatically refresh other views unless they refetch
             // Post.samplePosts.insert(newPost, at: 0)
            
            postText = ""
            locationTag = ""
        } catch {
            errorMessage = "Failed to create post: \(error.localizedDescription)"
             print("Post creation failed: \(error)")
        }
        isPosting = false
    }
}

// --- ProfileViewModel (Extended for Phase 2) ---
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isFollowing: Bool = false

    // Phase 2 Additions
    @Published var projects: [Project] = []
    @Published var isLoadingProjects: Bool = false

    private let networkService = NetworkService()
    private let viewingUserID: UUID
    private let currentUserID: UUID?

    init(viewingUserID: UUID, currentUserID: UUID?) {
        self.viewingUserID = viewingUserID
        self.currentUserID = currentUserID
    }

    func fetchProfileAndProjects() async {
          // Use TaskGroup to fetch profile and projects concurrently
          isLoading = true // Overall loading state
         isLoadingProjects = true
          errorMessage = nil
          
         await withTaskGroup(of: Void.self) { group in
             group.addTask { await self.fetchProfileData() }
            // Only fetch projects if viewing a contractor profile (heuristically, if servicesOffered exists)
            // A better approach would be an explicit user role/type
             group.addTask { await self.fetchProjectsDataIfNeeded() }
         }
        
         isLoading = false // Reset main loading state after group finishes
         isLoadingProjects = false // Reset project loading state
    }


    private func fetchProfileData() async {
         do {
            let fetchedUser = try await networkService.fetchUser(userID: viewingUserID)
            self.user = fetchedUser
             //checkFollowingStatus()
             print("Profile fetched for \(fetchedUser.username)")
         } catch {
             // Capture error but don't overwrite project errors maybe
             if self.errorMessage == nil { // Only set if no other error occurred yet
                 self.errorMessage = "Profile fetch failed: \(error.localizedDescription)"
             }
            print("Profile fetch failed for \(viewingUserID): \(error)")
        }
    }
    
    private func fetchProjectsDataIfNeeded() async {
        // We need the user data first to decide if we should fetch projects.
        // This sequential dependency makes TaskGroup tricky here.
        // Alternative: Fetch profile first, *then* decide to fetch projects.
        // Let's stick to fetching projects regardless for simplicity in demo.
        
        do {
            let fetchedProjects = try await networkService.fetchProjects(for: viewingUserID)
            self.projects = fetchedProjects
            print("Fetched \(fetchedProjects.count) projects for user \(viewingUserID)")
        } catch {
             if self.errorMessage == nil {
                 self.errorMessage = "Projects fetch failed: \(error.localizedDescription)"
             }
            print("Projects fetch failed for \(viewingUserID): \(error)")
        }
    }

//    private func checkFollowingStatus() {
//        guard let currentUser = User.loggedInUser, let viewedUserId = user?.id else {
//            isFollowing = false
//            return
//        }
//        isFollowing = currentUser.following.contains(viewedUserId)
//    }

    func follow() async {
        guard let viewedUserId = user?.id, let currentUserId = currentUserID else { return }
        // Consider disabling button while loading
        do {
            let success = try await networkService.followUser(userIDToFollow: viewedUserId, currentUserID: currentUserId)
            if success { isFollowing = true }
             else { errorMessage = "Failed to follow." }
        } catch { errorMessage = "Error following: \(error.localizedDescription)" }
    }

    func unfollow() async {
        guard let viewedUserId = user?.id, let currentUserId = currentUserID else { return }
        do {
            let success = try await networkService.unfollowUser(userIDToUnfollow: viewedUserId, currentUserID: currentUserId)
            if success { isFollowing = false }
            else { errorMessage = "Failed to unfollow." }
        } catch { errorMessage = "Error unfollowing: \(error.localizedDescription)" }
    }
}


// --- CreateProjectViewModel (New for Phase 2) ---
@MainActor
class CreateProjectViewModel: ObservableObject {
    @Published var projectName: String = ""
    @Published var description: String = ""
    @Published var location: String = ""
    @Published var budgetRange: String = ""
    @Published var styleTagsString: String = "" // Input as comma-separated
    // Image/Video handling simplified for MVP
    @Published var isPosting: Bool = false
    @Published var errorMessage: String? = nil
    @Published var didPostSuccessfully: Bool = false

    private let networkService = NetworkService()

    func createProject(contractorID: UUID) async {
        guard !projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Project Name and Description cannot be empty."
            return
        }

        isPosting = true
        errorMessage = nil
        didPostSuccessfully = false

        let tags = styleTagsString.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // Simulate adding image URLs
         let samplePhotoURLs: [URL]? = [URL(string:"https://via.placeholder.com/800/CCCCCC/FFFFFF?text=New+Project")!]

        let projectData = Project(
            id: UUID(), // Temp ID, server assigns final
            contractorID: contractorID,
            projectName: projectName,
            description: description,
            location: location.isEmpty ? nil : location,
            budgetRange: budgetRange.isEmpty ? nil : budgetRange,
            styleTags: tags.isEmpty ? nil : tags,
            photoURLs: samplePhotoURLs
            // videoURL left nil for now
        )

        do {
            _ = try await networkService.createProject(project: projectData)
            print("Project created successfully!")
            didPostSuccessfully = true
            // Reset fields
            projectName = ""
            description = ""
            location = ""
            budgetRange = ""
            styleTagsString = ""
        } catch {
            errorMessage = "Failed to create project: \(error.localizedDescription)"
            print("Project creation failed: \(error)")
        }
        isPosting = false
    }
}

// --- PostDetailViewModel (New for Phase 2) ---
@MainActor
class PostDetailViewModel: ObservableObject {
    @Published var post: Post?
    @Published var author: User?
    @Published var comments: [Comment] = []
    @Published var commentAuthors: [UUID: User] = [:] // Cache comment author details
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var newCommentText: String = ""
    @Published var isPostingComment: Bool = false

    private let networkService = NetworkService()
    private let postID: UUID
    private let initialPostData: Post? // Can pass initial data to show immediately

    init(postID: UUID, initialPostData: Post? = nil, initialAuthorData: User? = nil) {
        self.postID = postID
        self.post = initialPostData // Show passed data right away
        self.author = initialAuthorData
         // If initial data provided, update state
        // Note: Likes might be stale if passed from feed, fetch ensures latest.
        
    }

    func fetchPostDetailsAndComments() async {
        isLoading = true
        errorMessage = nil
        commentAuthors = [:] // Clear cache

        // Fetch Post detail (to get latest likes/comment counts) and Comments concurrently
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchPostData() }
            group.addTask { await self.fetchCommentData() }
            // We already have the main post author from the feed usually,
            // but could re-fetch if needed: group.addTask { await self.fetchAuthorData() }
        }

        isLoading = false
    }

    private func fetchPostData() async {
        // In a real app, you'd have a `fetchPost(postID:)` endpoint
        // For demo, we find it in the sample data
        print("Simulating fetch for Post \(postID)")
        if let foundPost = Post.samplePosts.first(where: { $0.id == postID }) {
            self.post = foundPost
             // If author wasn't passed initially, fetch now
             if self.author == nil {
                 await fetchAuthorData(authorID: foundPost.authorID)
             }
        } else {
             if errorMessage == nil { errorMessage = "Post not found." }
             print("Post \(postID) not found in sample data during fetch.")
        }
    }
    
    private func fetchAuthorData(authorID: UUID) async {
       guard self.author == nil else { return } // Only fetch if missing
        do {
           self.author = try await networkService.fetchUser(userID: authorID)
       } catch {
           print("Failed to fetch author \(authorID) for post detail: \(error)")
           // Set error message or handle display of unknown author
           if errorMessage == nil { errorMessage = "Could not load author details." }
       }
   }


    private func fetchCommentData() async {
        do {
            let fetchedComments = try await networkService.fetchComments(for: postID)
            self.comments = fetchedComments
            await fetchCommentAuthorDetails(for: fetchedComments) // Fetch details for comment authors
            print("Fetched \(fetchedComments.count) comments for post \(postID)")
        } catch {
            if errorMessage == nil { errorMessage = "Failed to fetch comments: \(error.localizedDescription)" }
            print("Comment fetch failed for post \(postID): \(error)")
        }
    }
    
    // Similar to FeedViewModel's author fetching, but for comment authors
    private func fetchCommentAuthorDetails(for comments: [Comment]) async {
       let authorIDs = Set(comments.map { $0.authorID })
       await withTaskGroup(of: (UUID, User?).self) { group in
           for id in authorIDs where commentAuthors[id] == nil { // Only fetch if not cached
               group.addTask {
                   do {
                       let user = try await self.networkService.fetchUser(userID: id)
                       return (id, user)
                   } catch {
                       print("Failed to fetch comment author \(id): \(error)")
                       return (id, nil)
                   }
               }
           }
           for await (id, user) in group {
               if let fetchedUser = user {
                   self.commentAuthors[id] = fetchedUser
               }
           }
       }
   }


    func postComment(authorID: UUID) async {
        guard let currentPostID = self.post?.id, !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
             errorMessage = "Comment text cannot be empty."
            return
        }

        isPostingComment = true
        errorMessage = nil

        do {
            let createdComment = try await networkService.postComment(postID: currentPostID, authorID: authorID, text: newCommentText)
            // Add comment locally for immediate display
            comments.append(createdComment)
             // Fetch author details if not already cached (might happen if user just commented)
             if commentAuthors[authorID] == nil {
                 await fetchCommentAuthorDetails(for: [createdComment])
             }
            // Update local post's comment count
            post?.commentCount += 1
            newCommentText = "" // Clear input field
            print("Comment posted successfully")
        } catch {
            errorMessage = "Failed to post comment: \(error.localizedDescription)"
            print("Comment posting failed: \(error)")
        }
        isPostingComment = false
    }

    // Reuse FeedViewModel's like logic - maybe extract to a helper/protocol later
     func toggleLike(currentUserID: UUID) async {
         guard let currentPostID = post?.id else { return }
         
         // 1. Check current state
         let isLiked = post?.likes.contains(currentUserID) ?? false

         // 2. Optimistic UI Update
         if isLiked {
             post?.likes.removeAll { $0 == currentUserID }
         } else {
             post?.likes.append(currentUserID)
         }

         // 3. Call Network Service
         do {
             let success: Bool
             if isLiked {
                 success = try await networkService.unlikePost(postID: currentPostID, userID: currentUserID)
             } else {
                 success = try await networkService.likePost(postID: currentPostID, userID: currentUserID)
             }

             // 4. Revert UI if network call failed
             if !success {
                  print("Network call to \(isLiked ? "unlike" : "like") failed. Reverting UI.")
                 if isLiked {
                      post?.likes.append(currentUserID) // Add it back
                 } else {
                      post?.likes.removeAll { $0 == currentUserID } // Remove it again
                 }
             } else {
                  print("Successfully \(isLiked ? "unliked" : "liked") post \(currentPostID)")
             }
         } catch {
             print("Error toggling like for post \(currentPostID): \(error). Reverting UI.")
              if isLiked {
                   post?.likes.append(currentUserID)
              } else {
                   post?.likes.removeAll { $0 == currentUserID }
              }
         }
     }
}

// --- NotificationsViewModel (New for Phase 2) ---
@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var actors: [UUID: User] = [:] // Cache notification actor details

    private let networkService = NetworkService()

    func fetchNotifications(for userID: UUID) async {
        isLoading = true
        errorMessage = nil
        actors = [:] // Clear cache
        do {
            let fetchedNotifications = try await networkService.fetchNotifications(for: userID)
            self.notifications = fetchedNotifications
            await fetchActorDetails(for: fetchedNotifications)
            print("Fetched \(fetchedNotifications.count) notifications")
        } catch {
            errorMessage = "Failed to fetch notifications: \(error.localizedDescription)"
            print("Notification fetch failed: \(error)")
        }
        isLoading = false
    }

    // Fetch details for users who triggered notifications
     private func fetchActorDetails(for notifications: [AppNotification]) async {
        let actorIDs = Set(notifications.map { $0.actorUserID })
        await withTaskGroup(of: (UUID, User?).self) { group in
            for id in actorIDs where actors[id] == nil {
                group.addTask {
                    do {
                        let user = try await self.networkService.fetchUser(userID: id)
                        return (id, user)
                    } catch {
                        print("Failed to fetch notification actor \(id): \(error)")
                        return (id, nil)
                    }
                }
            }
            for await (id, user) in group {
                if let fetchedUser = user {
                    self.actors[id] = fetchedUser
                }
            }
        }
    }

    func markAsRead(notificationID: UUID) async {
        // Optional: Update UI immediately (e.g., dim the notification)
        if let index = notifications.firstIndex(where: { $0.id == notificationID }) {
            notifications[index].isRead = true // Optimistic update
        }

        do {
            let success = try await networkService.markNotificationAsRead(notificationID: notificationID)
            if !success {
                print("Failed to mark notification \(notificationID) as read on backend.")
                // Revert optimistic UI update if needed
                 if let index = notifications.firstIndex(where: { $0.id == notificationID }) {
                     notifications[index].isRead = false
                 }
            } else {
                print("Successfully marked notification \(notificationID) as read.")
            }
        } catch {
             print("Error marking notification \(notificationID) as read: \(error)")
             // Revert optimistic UI update
              if let index = notifications.firstIndex(where: { $0.id == notificationID }) {
                 notifications[index].isRead = false
             }
        }
    }
}


// MARK: - UI Views (SwiftUI - Extended for Phase 2)

// --- Helper for Requesting Notification Permissions ---
class NotificationHelper {
    static let shared = NotificationHelper()
    private init() {}

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error requesting notification permission: \(error)")
                    completion(false)
                } else {
                    completion(granted)
                }
            }
        }
    }
     
    // This part normally goes in AppDelegate or SceneDelegate's didRegisterForRemoteNotificationsWithDeviceToken
     func handleTokenRegistration(deviceToken: Data) {
         let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
         let tokenString = tokenParts.joined()
         print("Device Token: \(tokenString)")
         // Here you would typically trigger the call to send this token to your backend
         // For demo, we simulate this call within AuthViewModel after login.
     }
}


// --- Authentication Views (Unchanged from Phase 1) ---

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("BuildConnect").font(.largeTitle).bold()
            Image(systemName: "hammer.fill").resizable().scaledToFit().frame(width: 80, height: 80).foregroundColor(.orange)
            TextField("Username (try 'builder')", text: $username).textFieldStyle(RoundedBorderTextFieldStyle()).autocapitalization(.none).disableAutocorrection(true)
            SecureField("Password (try 'password')", text: $password).textFieldStyle(RoundedBorderTextFieldStyle())

            if authViewModel.isLoading { ProgressView() }
            else {
                Button("Login") { Task { await authViewModel.login(username: username, password: password) } }.buttonStyle(.borderedProminent)
                Button("Don't have an account? Sign Up") { Task { await authViewModel.signup(username: "newuser", password: "newpassword") } }.font(.footnote)
            }
            if let errorMessage = authViewModel.errorMessage { Text(errorMessage).foregroundColor(.red).font(.caption) }
        }.padding()
    }
}

// --- Main App Structure (Extended for Phase 2) ---

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group { // Use Group to apply environmentObject once
            if authViewModel.isAuthenticated && authViewModel.currentUser != nil {
                MainTabView()
                   .onAppear { // Attempt registration when main view appears after auth
                         authViewModel.registerDeviceTokenIfNeeded()
                     }
            } else {
                LoginView()
            }
        }.environmentObject(authViewModel)
    }
}

struct MainTabView: View {
     @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            // Feed Tab
            NavigationView { FeedView() }
                .tabItem { Label("Feed", systemImage: "list.bullet") }

            // Post Tab
             NavigationView { CreatePostView() } // Or CreateProjectNavigationView
                .tabItem { Label("Create", systemImage: "plus.square.fill") } // Changed label

            // Notifications Tab (New in Phase 2)
            NavigationView { NotificationsView() }
                .tabItem { Label("Activity", systemImage: "bell.fill") } // ".fill" suggests activity

            // Profile Tab
            NavigationView {
                if let userID = authViewModel.currentUser?.id {
                     ProfileViewWrapper(viewingUserID: userID)
                } else {
                    Text("Error: Not logged in.") // Fallback
                }
            }
            .tabItem { Label("Profile", systemImage: "person.fill") }
        }
    }
}

// Placeholder for Create Options (Post or Project) - Could replace CreatePostView tab
// struct CreateOptionsView: View { ... }


// --- Feed Views (PostRowView updated for Phase 2 Engagement) ---

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel // Needed for liking

    var body: some View {
        List {
            if viewModel.isLoading && viewModel.posts.isEmpty {
                 ProgressView().frame(maxWidth: .infinity, alignment: .center)
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)").foregroundColor(.red)
            } else {
                ForEach($viewModel.posts) { $post in // Use binding for potential direct updates
                     // Navigate to PostDetailView for comments/details
                    NavigationLink(destination: PostDetailViewWrapper(postID: post.id, initialPostData: post, initialAuthorData: viewModel.authors[post.authorID])) {
                         // Pass binding (or update via ViewModel) if PostRowView needs to modify post
                        PostRowView(post: $post, author: viewModel.authors[post.authorID], feedViewModel: viewModel)
                     }
                     .buttonStyle(PlainButtonStyle()) // Make the whole row tappable
                }
            }
        }
        .listStyle(PlainListStyle()) // Use plain style for less inset/chrome
        .navigationTitle("Feed")
        .refreshable { await viewModel.fetchFeed() }
        .task { if viewModel.posts.isEmpty { await viewModel.fetchFeed() } }
    }
}


struct PostRowView: View {
    @Binding var post: Post // Use binding to reflect like changes immediately
    let author: User?
    @ObservedObject var feedViewModel: FeedViewModel // Or pass like closure
    @EnvironmentObject var authViewModel: AuthViewModel

    var isLikedByCurrentUser: Bool {
        guard let currentUserID = authViewModel.currentUser?.id else { return false }
        return post.likes.contains(currentUserID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Author Info Header (Navigate to Profile)
            NavigationLink(destination: ProfileViewWrapper(viewingUserID: post.authorID)) {
                HStack {
                    AsyncImage(url: author?.profileImageURL) { $0.resizable().scaledToFill() }
                    placeholder: { Image(systemName: "person.circle.fill").resizable().foregroundColor(.gray) }
                        .frame(width: 40, height: 40).clipShape(Circle())
                    VStack(alignment: .leading) {
                        Text(author?.username ?? "Loading...").font(.headline)
                        Text(post.timestamp, style: .relative).font(.caption).foregroundColor(.gray)
                    }
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle()) // Allow navigation link within the row

            // Post Content
            Text(post.text).bodyText()

             // Images (no change needed structurally)
             if let imageURLs = post.imageURLs, !imageURLs.isEmpty {
                 ScrollView(.horizontal, showsIndicators: false) {
                     HStack {
                         ForEach(imageURLs, id: \.self) { url in
                             AsyncImage(url: url) { $0.resizable().scaledToFit() }
                             placeholder: { Rectangle().fill(.gray.opacity(0.3)).overlay(ProgressView()) }
                             .frame(height: 200).cornerRadius(8)
                         }
                     }
                 }
             }

            // Location Tag
            if let location = post.locationTag {
                HStack { Image(systemName: "mappin.and.ellipse"); Text(location) }
                    .font(.caption).foregroundColor(.gray)
            }

            // --- Action Buttons (Updated for Phase 2) ---
            HStack(spacing: 20) {
                // Like Button
                 Button {
                     guard let currentUserID = authViewModel.currentUser?.id else { return }
                     Task {
                         // Call the ViewModel function to handle the like toggle
                         await feedViewModel.toggleLike(postID: post.id, currentUserID: currentUserID)
                     }
                 } label: {
                     Label("\(post.likes.count)", systemImage: isLikedByCurrentUser ? "heart.fill" : "heart")
                          .foregroundColor(isLikedByCurrentUser ? .red : .secondary)
                 }

               // Comment Button (Navigates via the main NavigationLink now)
                 Label("\(post.commentCount)", systemImage: "bubble.left") // Display count
                     .foregroundColor(.secondary)
                 // Navigation is handled by tapping the row - this is just display

                 Spacer()

                // Share Button
                Button { /* Share Action */ } label: {
                     Label("Share", systemImage: "square.and.arrow.up")
                 }
                 .foregroundColor(.secondary)

            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 8)
        }
         .padding(.vertical, 8)
    }
}


// --- Post Detail & Comments Views (New for Phase 2) ---

// Wrapper to handle VM initialization for PostDetailView
struct PostDetailViewWrapper: View {
    let postID: UUID
    let initialPostData: Post?
    let initialAuthorData: User?
    @EnvironmentObject var authViewModel: AuthViewModel // Pass down for comment author ID

    var body: some View {
        PostDetailView(
            viewModel: PostDetailViewModel(
                postID: postID,
                initialPostData: initialPostData,
                initialAuthorData: initialAuthorData
            )
        )
        .environmentObject(authViewModel) // Ensure AuthViewModel is available
    }
}


struct PostDetailView: View {
    @StateObject var viewModel: PostDetailViewModel
    @EnvironmentObject var authViewModel: AuthViewModel // For liking/commenting user ID
    @FocusState private var isCommentFieldFocused: Bool

    var isLikedByCurrentUser: Bool {
        guard let currentUserID = authViewModel.currentUser?.id else { return false }
        return viewModel.post?.likes.contains(currentUserID) ?? false
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if viewModel.isLoading && viewModel.post == nil {
                    ProgressView()
                } else if let post = viewModel.post {
                    // Post Content (similar to PostRowView but could be richer)
                    PostContentView(post: post, author: viewModel.author) // Extract content part

                    // Action Buttons (Like/Comment counts)
                    HStack(spacing: 20) {
                         Button {
                             guard let currentUserID = authViewModel.currentUser?.id else { return }
                             Task { await viewModel.toggleLike(currentUserID: currentUserID) }
                         } label: {
                              Label("\(post.likes.count)", systemImage: isLikedByCurrentUser ? "heart.fill" : "heart")
                                  .foregroundColor(isLikedByCurrentUser ? .red : .secondary)
                          }
                        
                         // Focus comment field on tap
                         Button {
                             isCommentFieldFocused = true
                         } label: {
                             Label("\(post.commentCount)", systemImage: "bubble.left")
                                 .foregroundColor(.secondary)
                         }

                         Spacer()
                         Button { /* Share Action */ } label: { Label("Share", systemImage: "square.and.arrow.up") }
                                .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    .padding(.top, 5)


                    Divider().padding(.vertical)

                    // Comments Section
                    Text("Comments (\(post.commentCount))").font(.headline).padding(.horizontal)
                    if viewModel.isLoading { // Loading indicator specifically for comments maybe?
                        ProgressView().padding()
                    } else if viewModel.comments.isEmpty {
                        Text("No comments yet.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        LazyVStack(alignment: .leading, spacing: 15) {
                            ForEach(viewModel.comments) { comment in
                                CommentRowView(comment: comment, author: viewModel.commentAuthors[comment.authorID])
                            }
                        }
                         .padding(.horizontal)
                    }

                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)").foregroundColor(.red).padding()
                } else {
                    Text("Post not found.").padding() // Fallback
                }
                
                // Add padding at the bottom to ensure content isn't hidden by input bar
                 Spacer(minLength: 80)
            }
        }
         .navigationTitle("Post")
         .navigationBarTitleDisplayMode(.inline)
         .task { // Fetch details when view appears
             // Only fetch if post data wasn't passed or seems incomplete
             if viewModel.post == nil || viewModel.comments.isEmpty {
                 await viewModel.fetchPostDetailsAndComments()
             }
         }
         .overlay(alignment: .bottom) {
             // Comment Input Bar
             CommentInputView(viewModel: viewModel)
                 .focused($isCommentFieldFocused) // Link focus state
         }
          .onTapGesture { // Dismiss keyboard when tapping outside input
               isCommentFieldFocused = false
           }
    }
}

// Extracted Post Content View (Can be reused/modified)
struct PostContentView: View {
    let post: Post
    let author: User?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
             NavigationLink(destination: ProfileViewWrapper(viewingUserID: post.authorID)) {
                HStack {
                     AsyncImage(url: author?.profileImageURL) { $0.resizable().scaledToFill() }
                     placeholder: { Image(systemName: "person.circle.fill").resizable().foregroundColor(.gray) }
                         .frame(width: 40, height: 40).clipShape(Circle())
                    VStack(alignment: .leading) {
                        Text(author?.username ?? "Loading...").font(.headline)
                        Text(post.timestamp, style: .relative).font(.caption).foregroundColor(.gray)
                    }
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle()) // Allow navigation link

            Text(post.text).bodyText()

             if let imageURLs = post.imageURLs, !imageURLs.isEmpty {
                 // Consider a different layout for detail view (e.g., vertical stack or pager)
                 ScrollView(.horizontal, showsIndicators: false) {
                     HStack {
                         ForEach(imageURLs, id: \.self) { url in
                             AsyncImage(url: url) { $0.resizable().scaledToFit() }
                             placeholder: { Rectangle().fill(.gray.opacity(0.3)).overlay(ProgressView()) }
                              // Allow larger image view in detail
                             .frame(height: 300)
                             .cornerRadius(8)
                         }
                     }
                 }
             }

            if let location = post.locationTag {
                HStack { Image(systemName: "mappin.and.ellipse"); Text(location) }
                .font(.caption).foregroundColor(.gray)
            }
        }
        .padding() // Add padding around content
    }
}


struct CommentRowView: View {
    let comment: Comment
    let author: User?

    var body: some View {
         HStack(alignment: .top, spacing: 10) {
              NavigationLink(destination: ProfileViewWrapper(viewingUserID: comment.authorID)) {
                 AsyncImage(url: author?.profileImageURL) { $0.resizable().scaledToFill() }
                 placeholder: { Image(systemName: "person.circle.fill").resizable().foregroundColor(.gray) }
                     .frame(width: 30, height: 30).clipShape(Circle())
             }

            VStack(alignment: .leading, spacing: 3) {
                 HStack(alignment: .firstTextBaseline) {
                    Text(author?.username ?? "User").font(.subheadline).bold()
                    Text(comment.timestamp, style: .relative).font(.caption2).foregroundColor(.gray)
                 }
                Text(comment.text).font(.subheadline)
            }
             Spacer() // Push content to left
        }
    }
}

struct CommentInputView: View {
    @ObservedObject var viewModel: PostDetailViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        HStack(alignment: .bottom) {
            // Simple profile pic placeholder
             AsyncImage(url: authViewModel.currentUser?.profileImageURL) { $0.resizable().scaledToFill() }
             placeholder: { Image(systemName: "person.circle.fill").resizable().foregroundColor(.gray) }
                 .frame(width: 35, height: 35).clipShape(Circle())

            // Use TextEditor for potentially multi-line input
             TextEditor(text: $viewModel.newCommentText)
                 .frame(minHeight: 35, maxHeight: 100) // Allow resizing
                 .padding(.horizontal, 8)
                 .background(Color(uiColor: .systemGray6))
                 .cornerRadius(18)
                 .overlay(
                     RoundedRectangle(cornerRadius: 18)
                         .stroke(Color(uiColor: .systemGray4), lineWidth: 1)
                 )


            Button {
                guard let authorID = authViewModel.currentUser?.id else { return }
                 // Dismiss keyboard before posting
                 UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                Task {
                    await viewModel.postComment(authorID: authorID)
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                     .frame(width: 30, height: 30)
                     .foregroundColor(viewModel.newCommentText.isEmpty ? .gray : .blue)
            }
            .disabled(viewModel.newCommentText.isEmpty || viewModel.isPostingComment)
             .opacity(viewModel.isPostingComment ? 0.5 : 1.0) // Dim if posting
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
         .background(.thinMaterial) // Nice background effect
    }
}


// --- Post Creation View (Unchanged from Phase 1) ---

struct CreatePostView: View {
    @StateObject private var viewModel = CreatePostViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading) {
            Text("Create New Post").font(.title2).bold().padding(.bottom)
            TextEditor(text: $viewModel.postText).frame(height: 150).border(Color.gray.opacity(0.5), width: 1).cornerRadius(5).accessibilityLabel("Post content text editor")
            TextField("Location Tag (Optional)", text: $viewModel.locationTag).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.vertical)
            Text("Add Images (Feature coming soon!)").font(.caption).foregroundColor(.gray).padding(.bottom)

            if viewModel.isPosting { ProgressView("Posting...").frame(maxWidth: .infinity, alignment: .center) }
            else {
                Button("Post to Feed") { Task { guard let authorID = authViewModel.currentUser?.id else { viewModel.errorMessage = "Error: Not logged in."; return }; await viewModel.createPost(authorID: authorID) } }
                .buttonStyle(.borderedProminent).frame(maxWidth: .infinity, alignment: .center).disabled(viewModel.postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            if let errorMessage = viewModel.errorMessage { Text(errorMessage).foregroundColor(.red).font(.caption).padding(.top) }
            Spacer()
        }
        .padding()
        .navigationTitle("New Post").navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.didPostSuccessfully) { success in if success { presentationMode.wrappedValue.dismiss() } }
    }
}

// --- Profile Views (Extended for Phase 2) ---

// Wrapper remains the same
struct ProfileViewWrapper: View {
    let viewingUserID: UUID
    @EnvironmentObject var authViewModel: AuthViewModel
    var body: some View {
        ProfileView(viewModel: ProfileViewModel(viewingUserID: viewingUserID, currentUserID: authViewModel.currentUser?.id))
            .environmentObject(authViewModel) // Pass down auth view model
    }
}

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingEditProfile = false
    @State private var showingCreateProject = false // For Phase 2

    var isViewingOwnProfile: Bool { viewModel.user?.id == authViewModel.currentUser?.id }

    var body: some View {
        ScrollView {
             // Loading States
             if viewModel.isLoading && viewModel.user == nil {
                 ProgressView("Loading Profile...").padding()
            } else if let user = viewModel.user {
                VStack(alignment: .leading, spacing: 15) {
                    // Profile Header (Add Contact Buttons)
                    ProfileHeaderView(user: user, isFollowing: viewModel.isFollowing, isViewingOwnProfile: isViewingOwnProfile) { action in
                        handleHeaderAction(action)
                    }

                    // --- Phase 2: Additional Sections ---
                    ProfileDetailSectionView(user: user)

                    // Action Buttons (Edit/Follow/Message)
                    ProfileActionsView(isViewingOwnProfile: isViewingOwnProfile, isFollowing: viewModel.isFollowing, isLoading: viewModel.isLoading) { action in
                        handleHeaderAction(action) // Reuse handler
                    }

                    // --- Phase 2: Portfolio Section ---
                    PortfolioSectionView(
                        projects: viewModel.projects,
                         isLoading: viewModel.isLoadingProjects,
                         isOwnProfile: isViewingOwnProfile,
                         onCreateProject: { showingCreateProject = true }
                    )

                     // Display User's Posts (Still Placeholder)
                     PostsSectionPlaceholderView() // Extracted placeholder

                     // Display error message at bottom
                     if let errorMessage = viewModel.errorMessage {
                        Text("Error: \(errorMessage)").foregroundColor(.red).font(.caption).padding(.top)
                    }
                }
                .padding(.horizontal) // Add horizontal padding to the main VStack
                .padding(.bottom) // Padding at the bottom
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error loading profile: \(errorMessage)").foregroundColor(.red).padding()
            } else {
                Text("User not found.").padding()
            }
        }
        .navigationTitle(viewModel.user?.username ?? "Profile")
         .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.fetchProfileAndProjects() } // Fetch both now
        .sheet(isPresented: $showingEditProfile) {
             if let currentUser = authViewModel.currentUser {
                  NavigationView { EditProfileView(userToEdit: currentUser).environmentObject(authViewModel) }
             }
        }
         .sheet(isPresented: $showingCreateProject) {
             if let currentUser = authViewModel.currentUser {
                 NavigationView { CreateProjectView().environmentObject(authViewModel) }
             }
         }
        .onReceive(authViewModel.$currentUser) { updatedUser in
            if updatedUser?.id == viewModel.user?.id { viewModel.user = updatedUser }
        }
    }

    // Action Handler
     private func handleHeaderAction(_ action: ProfileAction) {
         switch action {
         case .edit: showingEditProfile = true
         case .follow: Task { await viewModel.follow() }
         case .unfollow: Task { await viewModel.unfollow() }
         case .message: print("Navigate to Message View (NYI)") // Placeholder
         case .call:
              if let phone = viewModel.user?.contactPhone, let url = URL(string: "tel:\(phone.filter("0123456789".contains))") {
                   // Check if the device can make calls
                   if UIApplication.shared.canOpenURL(url) {
                       UIApplication.shared.open(url)
                   } else {
                       print("Cannot make calls on this device.")
                       // Show an alert or feedback to the user
                   }
              }
         case .email:
              if let email = viewModel.user?.contactEmail, let url = URL(string: "mailto:\(email)") {
                    if UIApplication.shared.canOpenURL(url) {
                       UIApplication.shared.open(url)
                   } else {
                       print("Cannot send email on this device.")
                   }
              }
         }
     }
}

// MARK: Profile View - Subviews (for better organization)


enum ProfileAction { case edit, follow, unfollow, message, call, email }

struct ProfileHeaderView: View {
    let user: User
    let isFollowing: Bool // Needed for context sometimes
    let isViewingOwnProfile: Bool
    let onAction: (ProfileAction) -> Void

    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: user.profileImageURL) { $0.resizable().scaledToFill() }
            placeholder: { Image(systemName: "person.circle.fill").resizable().foregroundColor(.gray) }
                .frame(width: 80, height: 80).clipShape(Circle())

            VStack(alignment: .leading) {
                Text(user.username).font(.title2).bold() // Slightly smaller title
                HStack {
                    Text("**\(user.followers.count)** followers")
                    Text("**\(user.following.count)** following")
                }
                .font(.subheadline).foregroundColor(.gray)
                
                // Bio moved below header details
            }
            Spacer()

            // Contact Buttons (if not own profile and available)
             if !isViewingOwnProfile {
                 HStack {
                     if user.contactEmail != nil {
                         Button { onAction(.email) } label: { Image(systemName: "envelope.fill") }
                             .tint(.secondary) // Use tint for color control
                     }
                     if user.contactPhone != nil {
                          Button { onAction(.call) } label: { Image(systemName: "phone.fill") }
                             .tint(.secondary)
                     }
                 }
                 .font(.title3)
             }

        }
         .padding(.top) // Add padding above header

        // Show Bio below the main header info
        if let bio = user.bio, !bio.isEmpty {
            Text(bio)
                .bodyText()
                .padding(.top, 5) // Add small space before bio
        }
    }
}


struct ProfileDetailSectionView: View {
    let user: User

    var body: some View {
         VStack(alignment: .leading, spacing: 10) {
             Divider()
             if let services = user.servicesOffered, !services.isEmpty {
                 InfoRow(label: "Services", value: services.joined(separator: ", "))
             }
             if let area = user.serviceAreaDescription, !area.isEmpty {
                  InfoRow(label: "Service Area", value: area)
             }
              if let certs = user.certifications, !certs.isEmpty {
                  InfoRow(label: "Certifications", value: certs.joined(separator: "\n")) // Allow newline separation
             }
             Divider()
         }
         .padding(.vertical, 5)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
         VStack(alignment: .leading) {
              Text(label).font(.caption).foregroundColor(.gray)
             Text(value).font(.subheadline)
         }
    }
}

struct ProfileActionsView: View {
    let isViewingOwnProfile: Bool
    let isFollowing: Bool
    let isLoading: Bool // To disable buttons during actions
    let onAction: (ProfileAction) -> Void


    var body: some View {
        HStack(spacing: 10) {
            if isViewingOwnProfile {
                Button { onAction(.edit) } label: { Text("Edit Profile").frame(maxWidth: .infinity) }
                    .buttonStyle(.bordered)
            } else {
                // Follow/Unfollow Button
                 Button {
                     onAction(isFollowing ? .unfollow : .follow)
                 } label: {
                     Text(isFollowing ? "Following" : "Follow").frame(maxWidth: .infinity)
                 }
                // .buttonStyle(isFollowing ? .bordered : .borderedProminent)
                 .disabled(isLoading)

                // Message Button (Placeholder)
                 Button { onAction(.message) } label: { Text("Message").frame(maxWidth: .infinity) }
                    .buttonStyle(.bordered)
                     .disabled(isLoading) // Also disable message during follow action
            }
        }
        .padding(.bottom, 5) // Space below buttons
    }
}

struct PortfolioSectionView: View {
    let projects: [Project]
    let isLoading: Bool
    let isOwnProfile: Bool
    let onCreateProject: () -> Void // Closure for action

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Portfolio").font(.title2).bold()
                Spacer()
                if isOwnProfile {
                     Button { onCreateProject() } label: { Image(systemName: "plus.circle.fill") }
                         .font(.title2)
                }
            }
            .padding(.bottom, 5)


            if isLoading {
                ProgressView("Loading Projects...").padding()
            } else if projects.isEmpty {
                Text(isOwnProfile ? "Showcase your work by adding projects." : "No projects showcased yet.")
                    .foregroundColor(.gray).padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                // Simple Grid or List for projects
                 // Using LazyVStack for demo simplicity, could be LazyVGrid
                 LazyVStack(spacing: 15) {
                     ForEach(projects) { project in
                          // Navigate to Project Detail View
                         NavigationLink(destination: ProjectDetailView(project: project)) {
                             ProjectRowView(project: project)
                         }
                         .buttonStyle(PlainButtonStyle()) // Make tappable
                     }
                 }
            }
        }
        .padding(.top) // Add padding above the portfolio section
    }
}

struct PostsSectionPlaceholderView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Divider().padding(.vertical)
            Text("Posts").font(.title2).bold()
            Text("User posts will appear here (Feature coming soon!)")
                .foregroundColor(.gray).padding()
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var editedUser: User // Local state for editing

    // Phase 2: Add state for new fields
     @State private var servicesString: String
     @State private var certsString: String


    init(userToEdit: User) {
        // Initialize local state from the user object
        _editedUser = State(initialValue: userToEdit)
        _servicesString = State(initialValue: userToEdit.servicesOffered?.joined(separator: ", ") ?? "")
        _certsString = State(initialValue: userToEdit.certifications?.joined(separator: ", ") ?? "")
    }

    var body: some View {
        Form {
            Section("Public Profile") {
                TextField("Username", text: $editedUser.username).autocapitalization(.none).disableAutocorrection(true)
                VStack(alignment: .leading) { Text("Bio").font(.caption).foregroundColor(.gray); TextEditor(text: Binding( get: { editedUser.bio ?? "" }, set: { editedUser.bio = $0.isEmpty ? nil : $0 } )).frame(height: 100) }
                HStack { Text("Profile Image URL"); Spacer(); Text(editedUser.profileImageURL?.absoluteString ?? "Not Set").font(.caption).foregroundColor(.gray).lineLimit(1).truncationMode(.middle) }
                Button("Change Profile Picture (Coming Soon)") {}.disabled(true)
            }

            // --- Phase 2 Edit Fields ---
             Section("Professional Details") {
                 TextField("Services Offered (comma-separated)", text: $servicesString)
                 TextField("Service Area Description", text: Binding( get: { editedUser.serviceAreaDescription ?? "" }, set: { editedUser.serviceAreaDescription = $0.isEmpty ? nil : $0 } ))
                 TextField("Certifications (comma-separated)", text: $certsString)
             }

            Section("Contact Info") {
                TextField("Contact Email", text: Binding( get: { editedUser.contactEmail ?? "" }, set: { editedUser.contactEmail = $0.isEmpty ? nil : $0 } ))
                    .keyboardType(.emailAddress).autocapitalization(.none)
                TextField("Contact Phone", text: Binding( get: { editedUser.contactPhone ?? "" }, set: { editedUser.contactPhone = $0.isEmpty ? nil : $0 } ))
                    .keyboardType(.phonePad)
            }
             // --------------------------

            Section {
                Button("Save Changes") {
                    // Update editedUser from the comma-separated strings
                     editedUser.servicesOffered = servicesString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                     editedUser.certifications = certsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                    
                    Task {
                        await authViewModel.updateProfile(user: editedUser)
                        if authViewModel.errorMessage == nil { presentationMode.wrappedValue.dismiss() }
                    }
                }
                .disabled(authViewModel.isLoading)
                Button("Cancel", role: .cancel) { presentationMode.wrappedValue.dismiss() }
            }

            if authViewModel.isLoading { HStack { Spacer(); ProgressView(); Spacer() } }
            if let errorMessage = authViewModel.errorMessage { Text("Error: \(errorMessage)").foregroundColor(.red).font(.caption) }
        }
        .navigationTitle("Edit Profile")
         .navigationBarTitleDisplayMode(.inline)
    }
}

// --- Project Views (New for Phase 2) ---

struct CreateProjectView: View {
    @StateObject private var viewModel = CreateProjectViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                 TextField("Project Name *", text: $viewModel.projectName)
                 
                 VStack(alignment: .leading) {
                     Text("Description *").font(.caption).foregroundColor(.gray)
                     TextEditor(text: $viewModel.description)
                         .frame(height: 150)
                          .border(Color.gray.opacity(0.5), width: 1)
                          .cornerRadius(5)
                 }

                 TextField("Location (e.g., City, State)", text: $viewModel.location)
                 TextField("Budget Range (Optional)", text: $viewModel.budgetRange)
                 TextField("Style Tags (comma-separated)", text: $viewModel.styleTagsString)
                     .autocapitalization(.words)

                 // Placeholder for Image/Video Upload
                 Text("Add Photos/Videos (Feature coming soon!)")
                     .font(.caption).foregroundColor(.gray)
                     .padding(.vertical)

                 if viewModel.isPosting {
                     ProgressView("Creating Project...")
                         .frame(maxWidth: .infinity, alignment: .center)
                 } else {
                     Button("Create Project") {
                         guard let contractorID = authViewModel.currentUser?.id else {
                             viewModel.errorMessage = "Error: Not logged in."
                             return
                         }
                         Task { await viewModel.createProject(contractorID: contractorID) }
                     }
                     .buttonStyle(.borderedProminent)
                     .frame(maxWidth: .infinity, alignment: .center)
                      .disabled(viewModel.projectName.isEmpty || viewModel.description.isEmpty)
                 }

                 if let errorMessage = viewModel.errorMessage {
                     Text(errorMessage).foregroundColor(.red).font(.caption).padding(.top)
                 }

            }
             .textFieldStyle(RoundedBorderTextFieldStyle()) // Apply style to all text fields
             .padding()
        }
        .navigationTitle("New Project")
        .navigationBarTitleDisplayMode(.inline)
         .background(Color(uiColor: .systemGroupedBackground)) // Match form background
        .onChange(of: viewModel.didPostSuccessfully) { success in
            if success { presentationMode.wrappedValue.dismiss() }
        }
         // Dismiss keyboard on scroll
         .gesture(DragGesture().onChanged({ _ in
             UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
         }))
    }
}


// Row view for displaying a project in the Portfolio list
struct ProjectRowView: View {
    let project: Project

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
             // Thumbnail Image
             AsyncImage(url: project.photoURLs?.first) { $0.resizable().scaledToFill() }
             placeholder: { Rectangle().fill(.gray.opacity(0.3)).overlay(Image(systemName: "photo.on.rectangle.angled")) }
                 .frame(width: 80, height: 80)
                 .cornerRadius(8)


            VStack(alignment: .leading) {
                Text(project.projectName).font(.headline).lineLimit(2)
                if let location = project.location {
                     Text(location).font(.subheadline).foregroundColor(.gray)
                }
                if let tags = project.styleTags, !tags.isEmpty {
                     Text(tags.prefix(3).joined(separator: ", ")) // Show first few tags
                         .font(.caption).foregroundColor(.blue).lineLimit(1)
                 }
            }
             Spacer() // Push details left
        }
    }
}


// Detail view for a single project
struct ProjectDetailView: View {
    let project: Project
    // Could add a ViewModel later if interactions (like saving) are needed

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Project Images (Pager or Stack)
                 if let photos = project.photoURLs, !photos.isEmpty {
                     TabView {
                         ForEach(photos, id: \.self) { url in
                             AsyncImage(url: url) { $0.resizable().scaledToFit() }
                             placeholder: { ProgressView() }
                         }
                     }
                     .tabViewStyle(PageTabViewStyle())
                      .frame(height: 300) // Adjust height as needed
                      .background(Color.black.opacity(0.1)) // Background for pager
                 }

                 // Project Name & Info
                 VStack(alignment: .leading, spacing: 5) {
                     Text(project.projectName).font(.title).bold()
                      if let location = project.location {
                          InfoRow(label: "Location", value: location)
                     }
                     if let budget = project.budgetRange {
                         InfoRow(label: "Budget", value: budget)
                     }
                      if let tags = project.styleTags, !tags.isEmpty {
                          InfoRow(label: "Styles", value: tags.joined(separator: ", "))
                     }
                 }
                 .padding(.horizontal)


                // Description
                 Text("About This Project").font(.title2).bold().padding(.horizontal)
                 Text(project.description)
                     .bodyText()
                     .padding(.horizontal)

                 // Video (Placeholder)
                 if project.videoURL != nil {
                     // Placeholder for video player integration
                      Text("Project Video (Coming Soon)")
                         .font(.headline).padding()
                          .frame(maxWidth: .infinity).background(Color.gray.opacity(0.2)).cornerRadius(8)
                          .padding(.horizontal)
                 }

            }
             .padding(.bottom)
        }
        .navigationTitle(project.projectName)
        .navigationBarTitleDisplayMode(.inline)
    }
}


// --- Notifications View (New for Phase 2) ---

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        List {
            if viewModel.isLoading && viewModel.notifications.isEmpty {
                ProgressView().frame(maxWidth: .infinity, alignment: .center)
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)").foregroundColor(.red)
            } else if viewModel.notifications.isEmpty {
                 Text("No new activity.")
                     .foregroundColor(.gray)
                     .frame(maxWidth: .infinity, alignment: .center)
                     .padding()
            } else {
                 ForEach(viewModel.notifications) { notification in
                     NotificationRowView(notification: notification, actor: viewModel.actors[notification.actorUserID])
                         .listRowInsets(EdgeInsets()) // Use full width
                         .padding(.vertical, 8)
                         .padding(.horizontal)
                         .background(notification.isRead ? Color.clear : Color.blue.opacity(0.1)) // Highlight unread
                         .onTapGesture {
                             // Navigate to relevant content or mark as read
                             print("Tapped notification: \(notification.id)")
                             Task {
                                 // Mark as read optimistically/via network
                                 if !notification.isRead {
                                      await viewModel.markAsRead(notificationID: notification.id)
                                 }
                                 // TODO: Navigation based on type
                                 // e.g., to PostDetailView or ProfileView
                             }
                         }
                 }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Activity")
        .refreshable {
             guard let userID = authViewModel.currentUser?.id else { return }
             await viewModel.fetchNotifications(for: userID)
        }
        .task {
            guard let userID = authViewModel.currentUser?.id, viewModel.notifications.isEmpty else { return }
             await viewModel.fetchNotifications(for: userID)
        }
    }
}


struct NotificationRowView: View {
    let notification: AppNotification
    let actor: User? // User who performed the action

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
             NavigationLink(destination: ProfileViewWrapper(viewingUserID: notification.actorUserID)) {
                 AsyncImage(url: actor?.profileImageURL) { $0.resizable().scaledToFill() }
                 placeholder: { Image(systemName: "person.circle.fill").resizable().foregroundColor(.gray) }
                     .frame(width: 40, height: 40).clipShape(Circle())
             }

            VStack(alignment: .leading) {
                 Text(notification.message) // Use pre-formatted message
                     .font(.subheadline)
                     .lineLimit(3) // Allow multiple lines

                Text(notification.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer() // Push content left
             
             // Little dot for unread status
             if !notification.isRead {
                 Circle()
                     .fill(Color.blue)
                     .frame(width: 8, height: 8)
                     .padding(.leading, 5)
                      .padding(.top, 5) // Align roughly with first line of text
             }
        }
    }
}



// MARK: - App Entry Point (Unchanged)

@main
struct BuildConnectApp: App {
    // This is needed on iOS 14+ if using AppDelegate lifecycle for push notifications
    // @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/*
// MARK: - AppDelegate (Optional - For Push Notification Registration)
// Needed if not using SwiftUI App lifecycle's built-in registration methods

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("App Delegate: Did Finish Launching")
        UNUserNotificationCenter.current().delegate = self
        
        // Request permission happens typically after login now (in AuthViewModel trigger)
        // Register for remote notifications after permission granted
        // UIApplication.shared.registerForRemoteNotifications() // Call this AFTER permission is granted

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("App Delegate: Did Register for Remote Notifications")
        NotificationHelper.shared.handleTokenRegistration(deviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("App Delegate: Failed to Register for Remote Notifications: \(error)")
    }

    // Handle foreground notification presentation
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("App Delegate: Will Present Notification (Foreground)")
        // Show alert, badge, sound even if app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    // Handle user tapping on notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("App Delegate: Did Receive Notification Response (Tapped): \(userInfo)")

        // TODO: Parse userInfo and navigate to the relevant screen
        // e.g., extract postID or userID and navigate programmatically

        completionHandler()
    }
}
*/


// MARK: - Custom View Modifiers (Shared)

struct BodyTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.body).lineSpacing(4)
    }
}

extension View {
    func bodyText() -> some View {
        self.modifier(BodyTextStyle())
    }
}

#Preview() {
    ContentView()
}
