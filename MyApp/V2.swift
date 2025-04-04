////
////  V2.swift
////  MyApp
////
////  Created by Cong Le on 4/4/25.
////
//
//import SwiftUI
//import Combine // Required for ObservableObject
//import MapKit // Required for Phase 2 Map Views
//
//// MARK: - Data Models (Phase 1 & 2)
//
//// --- Core Models ---
//
//struct User: Identifiable, Codable, Hashable {
//    let id: UUID
//    var username: String
//    var bio: String?
//    var profileImageURL: URL? // Use optional URL for profile images
//    var following: [UUID] = [] // IDs of users this user follows
//    var followers: [UUID] = [] // IDs of users following this user
//
//    // Phase 2: Advanced Profile Fields
//    var isContractor: Bool = false // Simple flag to differentiate user types
//    var servicesOffered: [String]?
//    var serviceAreaDescription: String? // e.g., "Serving the Greater Bay Area"
//    // For simplicity in stub, represent service area as coordinates for map display
//    var serviceAreaCoordinates: [CLLocationCoordinate2D]?
//    var certifications: [String]?
//    var contactPhone: String?
//    var contactEmail: String?
//    var projects: [UUID] = [] // IDs of projects created by this user (contractor)
//
//    // Sample Data
//    static var sampleUser1 = User(id: UUID(), username: "BuildMasterPro", bio: "Crafting dream homes since 2005. Quality & Precision.", profileImageURL: URL(string: "https://via.placeholder.com/150/FFA07A/000000?text=BMP"), isContractor: true, servicesOffered: ["New Construction", "Remodeling", "Framing"], serviceAreaDescription: "South Bay & Peninsula", serviceAreaCoordinates: [CLLocationCoordinate2D(latitude: 37.3541, longitude: -121.9552), CLLocationCoordinate2D(latitude: 37.4419, longitude: -122.1430)], certifications: ["Licensed General Contractor #12345", "EPA Lead-Safe Certified"], contactPhone: "555-123-4567", contactEmail: "contact@buildmaster.pro", projects: [Project.sampleProject1.id, Project.sampleProject2.id])
//    static var sampleUser2 = User(id: UUID(), username: "DesignBuildInspire", bio: "Innovative designs meet expert construction.", profileImageURL: URL(string: "https://via.placeholder.com/150/ADD8E6/000000?text=DBI"), isContractor: true, servicesOffered: ["Interior Design", "Kitchen & Bath Remodeling"], serviceAreaDescription: "San Francisco & Marin County", serviceAreaCoordinates: [CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)], contactEmail: "info@designbuild.co")
//    static var sampleUser3 = User(id: UUID(), username: "HomeownerHub", bio: "Planning my next big renovation!", profileImageURL: URL(string: "https://via.placeholder.com/150/90EE90/000000?text=HH"), isContractor: false)
//
//    // Mutable state for logged-in user simulation
//    static var loggedInUser = sampleUser1 // Simulate logged-in user for MVP
//}
//
//// Conform CLLocationCoordinate2D to Codable and Hashable for use in User/Project models
//extension CLLocationCoordinate2D: Codable, Hashable {
//    enum CodingKeys: String, CodingKey {
//        case latitude
//        case longitude
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(latitude, forKey: .latitude)
//        try container.encode(longitude, forKey: .longitude)
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
//        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
//        self.init(latitude: latitude, longitude: longitude)
//    }
//     
//     // Basic Hashable conformance
//     public func hash(into hasher: inout Hasher) {
//         hasher.combine(latitude)
//         hasher.combine(longitude)
//     }
//
//     // Basic Equatable conformance needed for Hashable
//     public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
//         return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
//     }
//}
//
//struct Post: Identifiable, Codable, Hashable {
//    let id: UUID
//    let authorID: UUID
//    let text: String
//    let imageURLs: [URL]?
//    let timestamp: Date
//    var locationTag: String?
//
//    // Phase 2: Engagement Fields
//    var likes: [UUID] = [] // Store User IDs who liked the post
//    var comments: [Comment] = [] // Store actual Comment objects
//
//    // Sample Data (updated)
//    static var samplePosts: [Post] = [
//        Post(id: UUID(), authorID: User.sampleUser1.id, text: "Just finished framing this beauty! Solid structure coming along nicely. #framing #construction #newbuild", imageURLs: [URL(string:"https://via.placeholder.com/600/FFA07A/FFFFFF?text=Frame+1")!], timestamp: Date().addingTimeInterval(-3600), locationTag: "Sunnyvale Project", likes: [User.sampleUser3.id], comments: [Comment(id: UUID(), postID: UUID(), authorID: User.sampleUser3.id, text: "Looks amazing! Can't wait to see the final results.", timestamp: Date().addingTimeInterval(-3000))]),
//        Post(id: UUID(), authorID: User.sampleUser2.id, text: "Kitchen transformation complete! Loving these custom cabinets and quartz countertops. What do you think?", imageURLs: [URL(string:"https://via.placeholder.com/600/ADD8E6/FFFFFF?text=Kitchen+1")!, URL(string:"https://via.placeholder.com/600/ADD8E6/FFFFFF?text=Kitchen+2")!], timestamp: Date().addingTimeInterval(-7200), locationTag: "Downtown Loft Reno", likes: [User.sampleUser1.id, User.sampleUser3.id], comments: []),
//        Post(id: UUID(), authorID: User.sampleUser1.id, text: "Pouring the foundation today. Solid groundwork is key! #foundation #concrete #buildconnect", imageURLs: nil, timestamp: Date().addingTimeInterval(-10800), likes: [], comments: []),
//         Post(id: UUID(), authorID: User.sampleUser3.id, text: "Looking for recommendations for a good roofing contractor in the Bay Area! Any suggestions?", imageURLs: nil, timestamp: Date().addingTimeInterval(-14400), likes: [User.sampleUser2.id], comments: [Comment(id: UUID(), postID: UUID(), authorID: User.sampleUser1.id, text: "Sent you a DM with a referral.", timestamp: Date().addingTimeInterval(-14000))])
//    ]
//}
//
//// --- Phase 2 Models ---
//enum BudgetRange: String, Codable, CaseIterable, Identifiable {
//     case unspecified = "Unspecified"
//     case under10k = "$ (<$10k)"
//     case tenTo50k = "$$ ($10k-$50k)"
//     case fiftyTo100k = "$$$ ($50k-$100k)"
//     case over100k = "$$$$ ($100k+)"
//
//     var id: String { self.rawValue }
//}
//
//struct Project: Identifiable, Codable, Hashable {
//    let id: UUID
//    let contractorID: UUID // Link to the User (contractor)
//    var projectName: String
//    var description: String
//    var locationString: String? // e.g., "Palo Alto, CA"
//    var coordinates: CLLocationCoordinate2D? // Optional precise location
//    var budgetRange: BudgetRange?
//    var styleTags: [String]? // e.g., ["Modern", "Farmhouse", "Minimalist"]
//    var mediaURLs: [URL]? // High-Res Photos/Videos
//
//    // Sample Data
//    static var sampleProject1 = Project(id: UUID(), contractorID: User.sampleUser1.id, projectName: "Sunnyvale Modern Rebuild", description: "Complete teardown and rebuild of a modern 4-bedroom home. Focused on energy efficiency and open-plan living.", locationString: "Sunnyvale, CA", coordinates: CLLocationCoordinate2D(latitude: 37.3688, longitude: -122.0363), budgetRange: .over100k, styleTags: ["Modern", "Energy Efficient", "Open Concept"], mediaURLs: [URL(string:"https://via.placeholder.com/800/FFA07A/FFFFFF?text=Project1+Pic1")!, URL(string:"https://via.placeholder.com/800/FFA07A/FFFFFF?text=Project1+Pic2")!])
//    static var sampleProject2 = Project(id: UUID(), contractorID: User.sampleUser1.id, projectName: "Los Altos Kitchen Remodel", description: "High-end kitchen renovation featuring custom cabinetry, professional-grade appliances, and a large island.", locationString: "Los Altos, CA", budgetRange: .fiftyTo100k, styleTags: ["Transitional", "Luxury", "Gourmet Kitchen"], mediaURLs: [URL(string:"https://via.placeholder.com/800/FFA07A/FFFFFF?text=Project2+Pic1")!])
//     static var sampleProject3 = Project(id: UUID(), contractorID: User.sampleUser2.id, projectName: "Pacific Heights Condo Refresh", description: "Interior design and furnishing update for a stunning condo overlooking the bay.", locationString: "San Francisco, CA", coordinates: CLLocationCoordinate2D(latitude: 37.7919, longitude: -122.4427), budgetRange: .tenTo50k, styleTags: ["Contemporary", "Interior Design"], mediaURLs: [URL(string:"https://via.placeholder.com/800/ADD8E6/FFFFFF?text=Project3+Pic1")!])
//
//     // Add projects to User sample data (done above in User definition)
//      static var allSampleProjects = [sampleProject1, sampleProject2, sampleProject3]
//}
//
//struct Comment: Identifiable, Codable, Hashable {
//    let id: UUID
//    let postID: UUID // Link to the Post
//    let authorID: UUID // Link to the User who commented
//    var text: String
//    let timestamp: Date
//}
//
//enum NotificationType: String, Codable {
//    case newFollower
//    case postLike
//    case postComment
//    case projectInquiry // Example for future
//}
//
//struct Notification: Identifiable, Codable, Hashable {
//    let id: UUID
//    let recipientID: UUID
//    let type: NotificationType
//    let message: String
//    let referenceID: UUID? // Optional ID of the related Post, User, Project etc.
//    let timestamp: Date
//    var isRead: Bool = false
//
//    // Sample Data
//     static var sampleNotifications: [Notification] = [
//        Notification(id: UUID(), recipientID: User.sampleUser1.id, type: .newFollower, message: "\(User.sampleUser3.username) started following you.", referenceID: User.sampleUser3.id, timestamp: Date().addingTimeInterval(-500)),
//        Notification(id: UUID(), recipientID: User.sampleUser2.id, type: .postLike, message: "\(User.sampleUser1.username) liked your post.", referenceID: Post.samplePosts[1].id, timestamp: Date().addingTimeInterval(-1500)),
//        Notification(id: UUID(), recipientID: User.sampleUser1.id, type: .postComment, message: "\(User.sampleUser3.username) commented on your post: \"Looks amazing!...\"", referenceID: Post.samplePosts[0].id, timestamp: Date().addingTimeInterval(-3000), isRead: true)
//    ]
//}
//
//struct ServiceAreaAnnotation: Identifiable {
//     let id = UUID()
//     let coordinate: CLLocationCoordinate2D
//     let title: String?
//}
//
//// MARK: - Networking Stub (Simulates API calls - Expanded for Phase 2)
//
//class NetworkService {
//
//    // --- User/Auth Related ---
//    func fetchUser(userID: UUID) async throws -> User {
//        try await Task.sleep(nanoseconds: 300_000_000) // Faster fetch
//        let users = [User.sampleUser1, User.sampleUser2, User.sampleUser3, User.loggedInUser]
//        if let user = users.first(where: { $0.id == userID }) {
//            return user
//        } else {
//            throw NSError(domain: "NetworkService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
//        }
//    }
//
//    func login(username: String, password: String) async throws -> User {
//        try await Task.sleep(nanoseconds: 600_000_000)
//        if username.lowercased() == "builder" && password == "password" {
//             // Ensure the loggedInUser static var is updated before returning
//              User.loggedInUser = User.sampleUser1 // Reset to sample on login
//            return User.loggedInUser
//        } else if username.lowercased() == "homeowner" && password == "password" {
//             User.loggedInUser = User.sampleUser3
//             return User.loggedInUser
//        }
//         else {
//            throw NSError(domain: "NetworkService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
//        }
//    }
//
//    func signup(username: String, password: String) async throws -> User {
//        try await Task.sleep(nanoseconds: 900_000_000)
//        print("Simulating user signup for \(username)")
//        // Return a generic new user or the main one for demo simplicity
//        User.loggedInUser = User.sampleUser1 // Assign default for demo
//        return User.loggedInUser
//    }
//
//    func updateProfile(user: User) async throws -> User {
//        try await Task.sleep(nanoseconds: 500_000_000)
//        print("Simulating profile update for \(user.username)")
//        // Update the static loggedInUser if it matches
//        if user.id == User.loggedInUser.id {
//            User.loggedInUser = user // Update the global state for demo
//        }
//        // Also update the sample arrays if needed (makes stub more complex)
//        if let index = [User.sampleUser1, User.sampleUser2, User.sampleUser3].firstIndex(where: {$0.id == user.id}) {
//             // This part is tricky without a proper database, only update the loggedInUser for demo
//        }
//
//        // Simulate notification generation - if bio changed for example
//         if user.id == User.loggedInUser.id && user.bio != User.loggedInUser.bio {
//              // await generateNotification(recipientID: user.id, type: .profileUpdate ...) // Not defined yet
//          }
//        return user
//    }
//
//     func followUser(userIDToFollow: UUID, currentUserID: UUID) async throws -> Bool {
//         try await Task.sleep(nanoseconds: 300_000_000)
//        print("Simulating: User \(currentUserID) follows \(userIDToFollow)")
//        let success = true // Assume success
//        if success && currentUserID == User.loggedInUser.id {
//             if !User.loggedInUser.following.contains(userIDToFollow) {
//                User.loggedInUser.following.append(userIDToFollow)
//                 // Simulate notification
//                  await generateNotification(recipientID: userIDToFollow, type: .newFollower, message: "\(User.loggedInUser.username) started following you.", referenceID: currentUserID)
//            }
//        }
//        return success
//    }
//
//    func unfollowUser(userIDToUnfollow: UUID, currentUserID: UUID) async throws -> Bool {
//         try await Task.sleep(nanoseconds: 300_000_000)
//         print("Simulating: User \(currentUserID) unfollows \(userIDToUnfollow)")
//        let success = true
//          if success && currentUserID == User.loggedInUser.id {
//             User.loggedInUser.following.removeAll { $0 == userIDToUnfollow }
//         }
//         return success
//    }
//
//    // --- Post Related ---
//    func fetchFeed() async throws -> [Post] {
//        try await Task.sleep(nanoseconds: 800_000_000) // Slightly faster feed
//        return Post.samplePosts.sorted { $0.timestamp > $1.timestamp }
//    }
//
//    func createPost(authorID: UUID, text: String, imageURLs: [URL]?, locationTag: String?) async throws -> Post {
//        try await Task.sleep(nanoseconds: 800_000_000)
//        let newPost = Post(id: UUID(), authorID: authorID, text: text, imageURLs: imageURLs, timestamp: Date(), locationTag: locationTag, likes: [], comments: [])
//        // Add to the local sample data (mutable)
//        Post.samplePosts.insert(newPost, at: 0)
//        return newPost
//    }
//
//    // Phase 2: Engagement Stubs
//    func likePost(postID: UUID, userID: UUID) async throws -> Bool {
//        try await Task.sleep(nanoseconds: 200_000_000)
//        if let index = Post.samplePosts.firstIndex(where: { $0.id == postID }) {
//             if !Post.samplePosts[index].likes.contains(userID) {
//                  Post.samplePosts[index].likes.append(userID)
//                   // Simulate notification
//                    if Post.samplePosts[index].authorID != userID { // Don't notify self
//                         await generateNotification(recipientID: Post.samplePosts[index].authorID, type: .postLike, message: "\(User.loggedInUser.username) liked your post.", referenceID: postID)
//                     }
//                  return true
//             }
//        }
//        return false
//    }
//
//    func unlikePost(postID: UUID, userID: UUID) async throws -> Bool {
//        try await Task.sleep(nanoseconds: 200_000_000)
//         if let index = Post.samplePosts.firstIndex(where: { $0.id == postID }) {
//            if Post.samplePosts[index].likes.contains(userID) {
//                  Post.samplePosts[index].likes.removeAll { $0 == userID }
//                 return true
//             }
//        }
//        return false
//    }
//
//    func fetchComments(postID: UUID) async throws -> [Comment] {
//         try await Task.sleep(nanoseconds: 400_000_000)
//         if let post = Post.samplePosts.first(where: { $0.id == postID }) {
//             return post.comments.sorted { $0.timestamp < $1.timestamp } // Oldest first
//         }
//         return []
//    }
//
//    func postComment(postID: UUID, authorID: UUID, text: String) async throws -> Comment {
//        try await Task.sleep(nanoseconds: 500_000_000)
//        if let index = Post.samplePosts.firstIndex(where: { $0.id == postID }) {
//            let newComment = Comment(id: UUID(), postID: postID, authorID: authorID, text: text, timestamp: Date())
//            Post.samplePosts[index].comments.append(newComment)
//              // Simulate notification
//               if Post.samplePosts[index].authorID != authorID {
//                    await generateNotification(recipientID: Post.samplePosts[index].authorID, type: .postComment, message: "\(User.loggedInUser.username) commented: \(text.prefix(30))...", referenceID: postID)
//                }
//            return newComment
//        } else {
//             throw NSError(domain: "NetworkService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Post not found"])
//        }
//    }
//
//    // --- Project Related ---
//    func fetchProjectsForUser(userID: UUID) async throws -> [Project] {
//        try await Task.sleep(nanoseconds: 600_000_000)
//        // Filter the global sample projects based on contractorID
//        return Project.allSampleProjects.filter { $0.contractorID == userID }
//                                        .sorted { $0.projectName < $1.projectName } // Basic sort
//    }
//
//    func createProject(contractorID: UUID, project: Project) async throws -> Project {
//         try await Task.sleep(nanoseconds: 1_000_000_000)
//        var newProject = project // Assume project object passed in has most data
//        newProject.contractorID = contractorID // Ensure contractor ID is set
//         // Assign a new ID if needed, or assume the passed object is ready
//          if newProject.id == UUID() { newProject.id = UUID() } // Ensure unique ID if placeholder used
//
//         Project.allSampleProjects.append(newProject)
//         // Add project ID to the user's list in the stub
//         if contractorID == User.loggedInUser.id {
//              User.loggedInUser.projects.append(newProject.id)
//          }
//          print("Simulating project creation: \(newProject.projectName)")
//         return newProject
//    }
//
//    // --- Notification Related ---
//    func fetchNotifications(userID: UUID) async throws -> [Notification] {
//        try await Task.sleep(nanoseconds: 450_000_000)
//        // Filter sample notifications for the recipient
//        return Notification.sampleNotifications.filter { $0.recipientID == userID }
//                                            .sorted { $0.timestamp > $1.timestamp } // Newest first
//    }
//    
//    // Helper to simulate generating a notification and adding it to the sample list
//    func generateNotification(recipientID: UUID, type: NotificationType, message: String, referenceID: UUID?) async {
//          let newNotif = Notification(id: UUID(), recipientID: recipientID, type: type, message: message, referenceID: referenceID, timestamp: Date())
//           Notification.sampleNotifications.insert(newNotif, at: 0) // Add to top
//          print("--- Generated Notification for \(recipientID): \(message)")
//           // In a real app, this would trigger a push notification to the recipient's device
//       }
//
//     func markNotificationAsRead(notificationID: UUID) async throws -> Bool {
//          try await Task.sleep(nanoseconds: 100_000_000) // Very fast
//          if let index = Notification.sampleNotifications.firstIndex(where: { $0.id == notificationID }) {
//               Notification.sampleNotifications[index].isRead = true
//              return true
//           }
//          return false
//      }
//}
//
//// MARK: - View Models (State Management - Expanded for Phase 2)
//
//// --- Auth & Profile ViewModels (Updated) ---
//@MainActor
//class AuthViewModel: ObservableObject {
//    // Published vars from Phase 1...
//    @Published var isAuthenticated: Bool = false
//    @Published var currentUser: User? = User.loggedInUser // Init with sample for faster preview/testing
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//
//    private let networkService = NetworkService()
//
//     init() {
//         // Basic check if loggedInUser is set initially (simulates prior login)
//          if currentUser != nil {
//             isAuthenticated = true
//         }
//     }
//
//    func login(username: String, password: String) async {
//        isLoading = true
//        errorMessage = nil
//        do {
//            let user = try await networkService.login(username: username, password: password)
//            self.currentUser = user // Update the current user state
//            User.loggedInUser = user // IMPORTANT: Update the static var for the stub!
//            self.isAuthenticated = true
//            print("Login successful for \(user.username)")
//        } catch {
//            errorMessage = error.localizedDescription
//            print("Login failed: \(error)")
//            self.currentUser = nil
//             self.isAuthenticated = false
//        }
//        isLoading = false
//    }
//
//    func signup(username: String, password: String) async {
//        // ... (Signup logic - assigns currentUser and isAuthenticated)
//         isLoading = true
//         errorMessage = nil
//         do {
//             let user = try await networkService.signup(username: username, password: password)
//             self.currentUser = user
//             User.loggedInUser = user // Update static var
//             self.isAuthenticated = true
//              print("Signup successful for \(user.username)")
//         } catch {
//             errorMessage = error.localizedDescription
//             print("Signup failed: \(error)")
//         }
//         isLoading = false
//    }
//
//    func updateProfile(user: User) async {
//         guard currentUser != nil else { return }
//        isLoading = true
//        errorMessage = nil
//        do {
//            let updatedUser = try await networkService.updateProfile(user: user)
//            self.currentUser = updatedUser // Update the local state
//             User.loggedInUser = updatedUser // Update static var
//            print("Profile updated successfully for \(updatedUser.username)")
//        } catch {
//            errorMessage = error.localizedDescription
//             print("Profile update failed: \(error)")
//        }
//        isLoading = false
//    }
//
//    func logout() {
//        isAuthenticated = false
//        currentUser = nil
//         // User.loggedInUser = ? // Decide how to handle logged out state for the stub
//         print("User logged out")
//    }
//}
//
//@MainActor
//class ProfileViewModel: ObservableObject {
//    // Published vars from Phase 1...
//    @Published var user: User?
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var isFollowing: Bool = false
//
//    // Phase 2: Projects
//    @Published var projects: [Project] = []
//    @Published var isLoadingProjects: Bool = false
//
//    private let networkService = NetworkService()
//    private let viewingUserID: UUID
//    private let currentUserID: UUID?
//
//    init(viewingUserID: UUID, currentUserID: UUID?) {
//        self.viewingUserID = viewingUserID
//        self.currentUserID = currentUserID
//         // Preload loggedInUser's profile for faster own profile view
//         if viewingUserID == User.loggedInUser.id {
//              self.user = User.loggedInUser
//              checkFollowingStatus() // Should be false for own profile
//         }
//    }
//
//    func fetchProfileAndProjects() async {
//        isLoading = true // Overall loading state
//        isLoadingProjects = true
//        errorMessage = nil
//        
//        // Fetch profile first (unless already preloaded)
//        if self.user == nil {
//             do {
//                 let fetchedUser = try await networkService.fetchUser(userID: viewingUserID)
//                 self.user = fetchedUser
//                 checkFollowingStatus()
//                 print("Profile fetched for \(fetchedUser.username)")
//             } catch {
//                 errorMessage = error.localizedDescription
//                 print("Profile fetch failed for \(viewingUserID): \(error)")
//                  isLoading = false // Stop loading if profile fails
//                  isLoadingProjects = false
//                 return // Don't proceed to fetch projects if user fetch failed
//             }
//        } else {
//              // If profile was preloaded, just ensure following status is checked
//              checkFollowingStatus()
//          }
//        
//         isLoading = false // Profile part finished
//
//        // Fetch projects only if the user is a contractor
//        if user?.isContractor == true {
//            do {
//                self.projects = try await networkService.fetchProjectsForUser(userID: viewingUserID)
//                print("Fetched \(projects.count) projects for \(user?.username ?? "...")")
//            } catch {
//                print("Failed to fetch projects: \(error)")
//                // Optionally set a specific project error message
//            }
//        } else {
//             self.projects = [] // Not a contractor, no projects
//         }
//        isLoadingProjects = false
//    }
//
//    private func checkFollowingStatus() {
//        guard let currentUserId = currentUserID, viewingUserID != currentUserId else {
//            isFollowing = false
//            return
//        }
//        // Use the global loggedInUser state for follow status in demo
//        isFollowing = User.loggedInUser.following.contains(viewingUserID)
//    }
//
//    func follow() async {
//        // ... (Follow logic from Phase 1, calls networkService.followUser)
//         guard let viewedUserId = user?.id, let currentUserId = currentUserID else { return }
//         isLoading = true // Can use this for button disabling
//         do {
//             let success = try await networkService.followUser(userIDToFollow: viewedUserId, currentUserID: currentUserId)
//             if success {
//                 isFollowing = true
//                 // Maybe increment follower count locally for immediate feedback (careful with stub)
//                  print("Follow successful")
//             } else {
//                 errorMessage = "Failed to follow user."
//                  print("Follow failed (API returned false)")
//             }
//         } catch {
//             errorMessage = "Error following user: \(error.localizedDescription)"
//             print("Follow error: \(error)")
//         }
//         isLoading = false
//    }
//
//    func unfollow() async {
//        // ... (Unfollow logic from Phase 1, calls networkService.unfollowUser)
//         guard let viewedUserId = user?.id, let currentUserId = currentUserID else { return }
//          isLoading = true
//         do {
//             let success = try await networkService.unfollowUser(userIDToUnfollow: viewedUserId, currentUserID: currentUserId)
//             if success {
//                 isFollowing = false
//                 print("Unfollow successful")
//             } else {
//                 errorMessage = "Failed to unfollow user."
//                 print("Unfollow failed (API returned false)")
//             }
//         } catch {
//             errorMessage = "Error unfollowing user: \(error.localizedDescription)"
//             print("Unfollow error: \(error)")
//         }
//          isLoading = false
//    }
//}
//
//// --- Feed & Post ViewModels (Updated) ---
//
//@MainActor
//class FeedViewModel: ObservableObject {
//    // Published vars from Phase 1...
//    @Published var posts: [Post] = []
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var authors: [UUID: User] = [:]
//
//    // Phase 2: Track likes/comments locally for immediate UI updates
//    @Published var likedPostIDs: Set<UUID> = [] // Posts liked by the current user
//    @Published var postComments: [UUID: [Comment]] = [:] // Cache comments per post ID
//     @Published var commentAuthors: [UUID: User] = [:] // Cache comment author details
//
//    private let networkService = NetworkService()
//     private var currentUserID: UUID? // Needed for like/comment actions
//
//     init(currentUserID: UUID?) {
//         self.currentUserID = currentUserID
//     }
//
//    func fetchFeed() async {
//        isLoading = true
//        errorMessage = nil
//        authors = [:] // Clear author cache on refresh
//         likedPostIDs = [] // Clear likes on refresh
//         postComments = [:] // Clear comments on refresh
//         commentAuthors = [:] // Clear comment authors
//
//        do {
//            let fetchedPosts = try await networkService.fetchFeed()
//            self.posts = fetchedPosts
//            await fetchAuthors(for: fetchedPosts)
//             updateLikedPosts(for: fetchedPosts) // Initialize liked status
//            print("Feed fetched successfully: \(posts.count) posts")
//        } catch {
//            errorMessage = error.localizedDescription
//             print("Feed fetch failed: \(error)")
//        }
//        isLoading = false
//    }
//
//    private func fetchAuthors(for postsOrComments: [Any]) async {
//         var authorIDs = Set<UUID>()
//
//         if let posts = postsOrComments as? [Post] {
//             authorIDs = Set(posts.map { $0.authorID })
//          } else if let comments = postsOrComments as? [Comment] {
//              authorIDs = Set(comments.map { $0.authorID })
//          }
//
//         if authorIDs.isEmpty { return }
//        
//         for id in authorIDs {
//            // Fetch only if not already in the respective cache
//             if self.authors[id] == nil && self.commentAuthors[id] == nil {
//                do {
//                     let user = try await networkService.fetchUser(userID: id)
//                     // Determine where to cache it (can be both post author and comment author)
//                     if posts.contains(where: { ($0 as? Post)?.authorID == id}) {
//                          self.authors[id] = user
//                      }
//                      if posts.contains(where: { ($0 as? Comment)?.authorID == id}) {
//                           self.commentAuthors[id] = user
//                       }
//                        // If fetched for comments specifically, ensure it's in commentAuthors
//                      if let _ = postsOrComments as? [Comment] {
//                           self.commentAuthors[id] = user
//                       }
//
//                 } catch {
//                     print("Failed to fetch author \(id): \(error)")
//                 }
//            } else if self.commentAuthors[id] == nil, let existingAuthor = self.authors[id] {
//                 // If fetched for comments but already in post authors cache, copy it
//                  if let _ = postsOrComments as? [Comment] {
//                     self.commentAuthors[id] = existingAuthor
//                  }
//             }
//        }
//    }
//    
//     // Initialize the likedPostIDs set based on fetched posts
//     private func updateLikedPosts(for posts: [Post]) {
//         guard let userId = currentUserID else { return }
//         likedPostIDs = Set(posts.filter { $0.likes.contains(userId) }.map { $0.id })
//     }
//
//    // --- Phase 2: Engagement Actions ---
//
//    func toggleLike(postID: UUID) async {
//        guard let userId = currentUserID else {
//             errorMessage = "You must be logged in to like posts."
//             return
//         }
//
//        let wasLiked = likedPostIDs.contains(postID)
//
//        // Optimistic UI Update
//        if wasLiked {
//            likedPostIDs.remove(postID)
//             // Decrement count locally if needed (more complex state)
//        } else {
//            likedPostIDs.insert(postID)
//             // Increment count locally
//        }
//
//        // Find the post index to update its like count directly (for display)
//         if let index = posts.firstIndex(where: { $0.id == postID }) {
//             let currentLikes = posts[index].likes // Original likes
//             if wasLiked {
//                  posts[index].likes.removeAll { $0 == userId }
//              } else {
//                  posts[index].likes.append(userId) // Add optimistically
//              }
//         }
//
//        // Network Call
//        do {
//            let success: Bool
//            if wasLiked {
//                success = try await networkService.unlikePost(postID: postID, userID: userId)
//                print("Unliked post \(postID)")
//            } else {
//                success = try await networkService.likePost(postID: postID, userID: userId)
//                print("Liked post \(postID)")
//            }
//            // If network call failed, revert optimistic update (more robust error handling needed)
//            if !success {
//                 print("Network call failed, reverting like state for \(postID)")
//                 if wasLiked {
//                     likedPostIDs.insert(postID)
//                      // Re-add user ID if tracking locally
//                      if let index = posts.firstIndex(where: { $0.id == postID }) {
//                          posts[index].likes.append(userId)
//                       }
//                 } else {
//                     likedPostIDs.remove(postID)
//                      // Re-remove user ID if tracking locally
//                      if let index = posts.firstIndex(where: { $0.id == postID }) {
//                           posts[index].likes.removeAll { $0 == userId }
//                        }
//                 }
//             }
//
//        } catch {
//            errorMessage = "Error liking/unliking post: \(error.localizedDescription)"
//             print("Like/Unlike Error: \(error)")
//             // Revert optimistic update on error
//             if wasLiked { likedPostIDs.insert(postID) /* ... also update local post model */ }
//             else { likedPostIDs.remove(postID) /* ... also update local post model */ }
//         }
//    }
//    
//    // Fetch comments for a specific post (to be called when needed, e.g., opening detail view)
//     func fetchComments(for postID: UUID) async {
//         // Avoid re-fetching if already cached? Or always refresh? Let's refresh.
//         do {
//             let fetchedComments = try await networkService.fetchComments(postID: postID)
//             postComments[postID] = fetchedComments
//              print("Fetched \(fetchedComments.count) comments for post \(postID)")
//              await fetchAuthors(for: fetchedComments) // Fetch authors for these comments
//         } catch {
//              print("Failed to fetch comments for \(postID): \(error)")
//              // Optionally set an error message per post
//         }
//     }
//
//     // Post a new comment
//     func postComment(postID: UUID, text: String) async {
//         guard let authorId = currentUserID, !text.isEmpty else {
//              errorMessage = "Cannot post empty comment or not logged in."
//              return
//          }
//         
//          // Maybe show a temporary loading state for comments?
//
//         do {
//             let newComment = try await networkService.postComment(postID: postID, authorID: authorId, text: text)
//             // Add comment to local cache for immediate display
//             var existingComments = postComments[postID] ?? []
//             existingComments.append(newComment)
//             postComments[postID] = existingComments
//              print("Posted comment successfully to post \(postID)")
//              // Fetch the author if needed (unlikely for self, but good practice)
//               await fetchAuthors(for: [newComment])
//              // Update the comment count on the main post object too?
//               if let index = posts.firstIndex(where: {$0.id == postID }) {
//                    posts[index].comments.append(newComment) // Add to the post's own list
//                }
//
//          } catch {
//              errorMessage = "Failed to post comment: \(error.localizedDescription)"
//              print("Comment post error: \(error)")
//          }
//      }
//
//}
//
//// --- Phase 2: New View Models ---
//
//@MainActor
//class CreateProjectViewModel: ObservableObject {
//    @Published var projectName: String = ""
//    @Published var description: String = ""
//    @Published var locationString: String = ""
//    // Coordinates might be set via map selection later, skip for now
//    @Published var selectedBudget: BudgetRange = .unspecified
//    @Published var styleTagsString: String = "" // Comma-separated input
//    // Media Uploads simulation
//    @Published var mediaURLs: [URL] = []
//
//    @Published var isPosting: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var didPostSuccessfully: Bool = false
//
//    private let networkService = NetworkService()
//
//    func createProject(contractorID: UUID) async {
//         guard !projectName.isEmpty, !description.isEmpty else {
//             errorMessage = "Project Name and Description are required."
//             return
//         }
//
//        isPosting = true
//        errorMessage = nil
//        didPostSuccessfully = false
//
//         // Process style tags string
//         let tags = styleTagsString.split(separator: ",")
//                                  .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//                                  .filter { !$0.isEmpty }
//
//         // Create Project object
//          // Assign a placeholder ID, backend/NetworkService stub should generate real one
//         let newProject = Project(
//             id: UUID(), // Stub will replace if needed, or use backend generated
//              contractorID: contractorID, // Passed in
//              projectName: projectName,
//             description: description,
//             locationString: locationString.isEmpty ? nil : locationString,
//              coordinates: nil, // Add later via MapKit selection if needed
//              budgetRange: selectedBudget == .unspecified ? nil : selectedBudget,
//             styleTags: tags.isEmpty ? nil : tags,
//              mediaURLs: mediaURLs.isEmpty ? nil : mediaURLs // Simulate adding some if empty
//          )
//
//        do {
//            let createdProject = try await networkService.createProject(contractorID: contractorID, project: newProject)
//            print("Project created successfully: \(createdProject.projectName)")
//            didPostSuccessfully = true
//            resetFields()
//        } catch {
//            errorMessage = "Failed to create project: \(error.localizedDescription)"
//             print("Project creation failed: \(error)")
//        }
//
//        isPosting = false
//    }
//
//     private func resetFields() {
//          projectName = ""
//          description = ""
//          locationString = ""
//          selectedBudget = .unspecified
//          styleTagsString = ""
//          mediaURLs = []
//      }
//     
//      // Simulate adding a media URL (replace with actual picker later)
//      func addSimulatedMedia() {
//           let count = mediaURLs.count + 1
//           if let url = URL(string: "https://via.placeholder.com/800/cccccc/000000?text=Project+Media+\(count)") {
//                mediaURLs.append(url)
//            }
//        }
//}
//
//@MainActor
//class ProjectDetailViewModel: ObservableObject {
//    @Published var project: Project?
//    @Published var contractor: User?
//     @Published var isLoading: Bool = false
//     @Published var errorMessage: String? = nil
//
//    private let networkService = NetworkService()
//     let projectID: UUID // Store the ID to fetch
//
//     // Allow passing the project if already available (e.g., from list)
//     init(project: Project? = nil, projectID: UUID) {
//         self.project = project
//         self.projectID = projectID
//     }
//
//     func fetchProjectDetails() async {
//         guard project == nil else { // Don't refetch if project was passed in
//              // Still fetch contractor if needed
//               if contractor == nil, let contractorId = self.project?.contractorID {
//                   await fetchContractor(userID: contractorId)
//               }
//              return
//          }
//         
//         isLoading = true
//         errorMessage = nil
//         
//          // Need a way to fetch a single project by ID in NetworkService
//          // For now, filter the sample data (inefficient but works for stub)
//          do {
//              try await Task.sleep(nanoseconds: 300_000_000) // Simulate fetch delay
//              if let foundProject = Project.allSampleProjects.first(where: { $0.id == projectID }) {
//                  self.project = foundProject
//                   print("Fetched project detail: \(foundProject.projectName)")
//                  // Fetch contractor details after getting project
//                   await fetchContractor(userID: foundProject.contractorID)
//              } else {
//                   errorMessage = "Project not found."
//                  print("Project with ID \(projectID) not found in sample data.")
//               }
//          } // Add catch block if NetworkService had a real fetch method
//
//         isLoading = false
//     }
//
//     private func fetchContractor(userID: UUID) async {
//          do {
//              self.contractor = try await networkService.fetchUser(userID: userID)
//              print("Fetched contractor: \(contractor?.username ?? "...")")
//          } catch {
//               print("Failed to fetch contractor \(userID): \(error)")
//               // Set specific error for contractor fetch?
//          }
//      }
//}
//
//@MainActor
// class NotificationsViewModel: ObservableObject {
//     @Published var notifications: [Notification] = []
//     @Published var isLoading: Bool = false
//     @Published var errorMessage: String? = nil
//     @Published var unreadCount: Int = 0
//
//     private let networkService = NetworkService()
//     private let currentUserID: UUID?
//
//     init(currentUserID: UUID?) {
//         self.currentUserID = currentUserID
//          // Calculate initial unread count from sample data (for demo)
//          self.unreadCount = Notification.sampleNotifications.filter { $0.recipientID == currentUserID && !$0.isRead }.count
//      }
//
//     func fetchNotifications() async {
//         guard let userId = currentUserID else { return }
//         isLoading = true
//         errorMessage = nil
//         do {
//             let fetched = try await networkService.fetchNotifications(userID: userId)
//             self.notifications = fetched
//              updateUnreadCount()
//              print("Fetched \(fetched.count) notifications")
//         } catch {
//             errorMessage = "Failed to load notifications: \(error.localizedDescription)"
//              print("Notification fetch error: \(error)")
//         }
//         isLoading = false
//     }
//
//     func markAsRead(notificationID: UUID) async {
//          guard let index = notifications.firstIndex(where: { $0.id == notificationID }) else { return }
//          // Optimistic UI update
//         notifications[index].isRead = true
//         updateUnreadCount()
//         
//         do {
//             let success = try await networkService.markNotificationAsRead(notificationID: notificationID)
//              if !success {
//                  // Revert optimistic update if API call fails
//                   notifications[index].isRead = false
//                   updateUnreadCount()
//                  print("Failed to mark notification \(notificationID) as read (API)")
//              } else {
//                   print("Marked notification \(notificationID) as read")
//               }
//          } catch {
//              print("Error marking notification as read: \(error)")
//              // Revert optimistic update
//               notifications[index].isRead = false
//               updateUnreadCount()
//          }
//     }
//
//     private func updateUnreadCount() {
//          unreadCount = notifications.filter { !$0.isRead }.count
//      }
// }
//
//// MARK: - UI Views (SwiftUI - Expanded for Phase 2)
//
//// --- Authentication Views (Unchanged from Phase 1) ---
//// LoginView
//// SignupView (If implemented separately)
//
//// --- Main App Structure (Updated with Notifications Tab) ---
//
//struct ContentView: View {
//    @StateObject private var authViewModel = AuthViewModel()
//
//    var body: some View {
//        // Use currentUser from authViewModel to check authentication
//         if authViewModel.isAuthenticated && authViewModel.currentUser != nil {
//            MainTabView()
//                .environmentObject(authViewModel)
//        } else {
//            LoginView()
//                .environmentObject(authViewModel)
//        }
//    }
//}
//
//struct MainTabView: View {
//     @EnvironmentObject var authViewModel: AuthViewModel
//     @StateObject private var notificationsViewModel: NotificationsViewModel // Initialize here
//
//     // Need to initialize NotificationsViewModel with the current user ID
//     init() {
//        // Access the authViewModel indirectly via a temporary variable or ensure it's available
//         // This is a common challenge; passing the authViewModel down might be cleaner.
//          // Let's assume we can access the loggedInUser static var for the stub's ID.
//         _notificationsViewModel = StateObject(wrappedValue: NotificationsViewModel(currentUserID: AuthViewModel().currentUser?.id ?? User.loggedInUser.id)) // Use loggedInUser from static for init
//     }
//
//    var body: some View {
//        TabView {
//            NavigationView {
//                 // Pass current user ID for like/comment functionality
//                 FeedView(viewModel: FeedViewModel(currentUserID: authViewModel.currentUser?.id))
//            }
//            .tabItem {
//                Label("Feed", systemImage: "list.bullet")
//            }
//
//            NavigationView {
//                 CreatePostView() // Needs authViewModel from environment
//             }
//            .tabItem {
//                Label("Post", systemImage: "plus.square.fill")
//            }
//
//              // Phase 2: Notifications Tab
//             NavigationView {
//                 NotificationsView(viewModel: notificationsViewModel) // Pass the viewModel
//             }
//             .tabItem {
//                  Label("Notifications", systemImage: "bell.fill")
//                       .overlay(NotificationBadge(count: notificationsViewModel.unreadCount), alignment: .topTrailing) // Add badge
//              }
//             .task {
//                  // Fetch notifications when the tab might become visible
//                  await notificationsViewModel.fetchNotifications()
//              }
//
//             NavigationView {
//                 if let userId = authViewModel.currentUser?.id {
//                       ProfileViewWrapper(viewingUserID: userId)
//                   } else {
//                        Text("Error: No logged in user.") // Fallback
//                    }
//             }
//            .tabItem {
//                Label("Profile", systemImage: "person.fill")
//            }
//        }
//         // Inject notifications VM into environment if needed lower down? Not necessary for this structure.
//    }
//}
//
//// Simple Badge View for Tab Item
//struct NotificationBadge: View {
//     let count: Int
//
//     var body: some View {
//          if count > 0 {
//              Text("\(count)")
//                 .font(.caption2).bold()
//                  .foregroundColor(.white)
//                  .padding(5)
//                  .background(Color.red)
//                  .clipShape(Circle())
//                  // Offset to position it correctly relative to the tab icon
//                  .offset(x: 12, y: -8)
//          } else {
//               EmptyView() // Don't show anything if count is 0
//           }
//       }
//}
//
//// --- Feed Views (Updated for Likes/Comments) ---
//
//struct FeedView: View {
//    @StateObject var viewModel: FeedViewModel // Receive initialized VM
//    @State private var showingCommentsForPost: Post? = nil // State to trigger sheet
//
//    var body: some View {
//        List {
//            if viewModel.isLoading && viewModel.posts.isEmpty {
//                 ProgressView()
//                     .frame(maxWidth: .infinity, alignment: .center)
//            } else if let errorMessage = viewModel.errorMessage {
//                Text("Error: \(errorMessage)")
//                    .foregroundColor(.red)
//            } else {
//                ForEach($viewModel.posts) { $post in // Use Binding to allow updates
//                    PostRowView(
//                         post: $post, // Pass binding
//                          author: viewModel.authors[post.authorID],
//                         isLiked: viewModel.likedPostIDs.contains(post.id), // Pass like status
//                          likeAction: {
//                              Task { await viewModel.toggleLike(postID: post.id) }
//                          },
//                         commentAction: {
//                              showingCommentsForPost = post // Set the post to show comments for
//                          },
//                          profileAction: { // Provide action to navigate to profile
//                               // Navigation handled by NavigationLink wrapper below
//                          }
//                      )
//                      .listRowInsets(EdgeInsets()) // Remove default padding for custom look
//                      .padding(.vertical, 8)
//                      .padding(.horizontal)
//                      // Use NavigationLink here for the whole row
//                       .background(
//                           NavigationLink(destination: ProfileViewWrapper(viewingUserID: post.authorID)) {
//                                EmptyView()
//                            }.opacity(0) // Make the NavigationLink itself invisible
//                        )
//                       .buttonStyle(PlainButtonStyle()) // Prevent list row selection style interference
//
//                }
//            }
//        }
//        .listStyle(PlainListStyle()) // Use plain style for less visual clutter
//        .navigationTitle("Feed")
//        .refreshable {
//             await viewModel.fetchFeed()
//        }
//        .task {
//            if viewModel.posts.isEmpty {
//                 await viewModel.fetchFeed()
//            }
//        }
//         // Sheet for displaying comments
//         .sheet(item: $showingCommentsForPost) { post in
//              // Pass necessary data/viewModels to the Comments view
//              CommentsSheetView(
//                  post: post,
//                  feedViewModel: viewModel // Pass the feed VM to handle posting/fetching comments
//               )
//          }
//    }
//}
//
//struct PostRowView: View {
//    @Binding var post: Post // Use Binding to reflect like/comment count changes
//    let author: User?
//     let isLiked: Bool // Directly receive liked status
//     let likeAction: () -> Void
//     let commentAction: () -> Void
//     let profileAction: () -> Void // Action for tapping profile info
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            // Author Info Header - Make tappable
//            Button(action: profileAction) { // Trigger profile navigation
//                 HStack {
//                      AsyncImage(url: author?.profileImageURL) { image in
//                         image.resizable().scaledToFill()
//                     } placeholder: {
//                         Image(systemName: "person.circle.fill").resizable()
//                            .foregroundColor(.gray)
//                     }
//                     .frame(width: 40, height: 40)
//                     .clipShape(Circle())
//
//                 VStack(alignment: .leading) {
//                     Text(author?.username ?? "Loading...")
//                         .font(.headline)
//                         .foregroundColor(.primary) // Ensure text color is standard
//                     Text(post.timestamp, style: .relative)
//                         .font(.caption)
//                         .foregroundColor(.gray)
//                 }
//                 Spacer()
//                      // Add options menu (...) later
//                 }
//            }
//             .buttonStyle(PlainButtonStyle()) // Remove button default styling
//
//            Text(post.text)
//                .bodyText() // Consistent styling
//
//             // Display Images (Unchanged)
//             if let imageURLs = post.imageURLs, !imageURLs.isEmpty {
//                  // ... (Image ScrollView)
//                     ScrollView(.horizontal, showsIndicators: false) {
//                          HStack {
//                               ForEach(imageURLs, id: \.self) { url in
//                                    AsyncImage(url: url) { image in
//                                         image.resizable().scaledToFit()
//                                     } placeholder: {
//                                          Rectangle().fill(.gray.opacity(0.3)).overlay(ProgressView())
//                                     }
//                                     .frame(height: 200)
//                                     .cornerRadius(8)
//                                }
//                            } // HStack
//                     } // ScrollView
//             }
//
//            // Location Tag (Unchanged)
//            if let location = post.locationTag {
//                 // ... (Location HStack)
//                  HStack {
//                       Image(systemName: "mappin.and.ellipse")
//                       Text(location)
//                     }
//                     .font(.caption)
//                     .foregroundColor(.gray)
//            }
//
//            // Action Buttons (Updated with counts and actions)
//            HStack {
//                Button { likeAction() } label: {
//                     Label("\(post.likes.count)", systemImage: isLiked ? "heart.fill" : "heart")
//                          .foregroundColor(isLiked ? .red : .secondary)
//                     }
//                Spacer()
//                 Button { commentAction() } label: {
//                      Label("\(post.comments.count)", systemImage: "bubble.left")
//                          .foregroundColor(.secondary)
//                  }
//                Spacer()
//                Button { /* Share Action */ } label: { Label("Share", systemImage: "square.and.arrow.up") }
//                 .foregroundColor(.secondary)
//
//            }
//            .buttonStyle(PlainButtonStyle())
//             .padding(.top, 5)
//        }
//          // Removed padding here, add it in FeedView's listRowInsets/padding instead
//    }
//}
//
//// --- Comments View (New for Phase 2) ---
//struct CommentsSheetView: View {
//    let post: Post
//    @ObservedObject var feedViewModel: FeedViewModel // Use FeedVM for comments logic
//    @State private var newCommentText: String = ""
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        NavigationView { // Add NavigationView for title and potentially close button
//            VStack {
//                // List of Comments
//                List {
//                   // Optionally show the original post snippet at the top
//                   // PostRowView(...)
//                    
//                   if let comments = feedViewModel.postComments[post.id], !comments.isEmpty {
//                        ForEach(comments) { comment in
//                           CommentRowView(comment: comment, author: feedViewModel.commentAuthors[comment.authorID])
//                        }
//                    } else {
//                        Text("No comments yet.")
//                            .foregroundColor(.gray)
//                            .frame(maxWidth: .infinity, alignment: .center)
//                            .padding()
//                    }
//                }
//                 .listStyle(PlainListStyle())
//                 .task { // Fetch comments when the sheet appears
//                      await feedViewModel.fetchComments(for: post.id)
//                  }
//                 .refreshable { // Allow refresh
//                      await feedViewModel.fetchComments(for: post.id)
//                  }
//
//                // Comment Input Area
//                HStack {
//                    TextField("Add a comment...", text: $newCommentText)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                     
//                     Button {
//                         Task {
//                             await feedViewModel.postComment(postID: post.id, text: newCommentText)
//                             newCommentText = "" // Clear field after posting
//                             // Optionally dismiss keyboard
//                         }
//                     } label: {
//                         Image(systemName: "paperplane.fill")
//                     }
//                     .disabled(newCommentText.isEmpty || feedViewModel.currentUserID == nil) // Disable if no text or not logged in
//                 }
//                .padding()
//                .background(.thinMaterial) // Add slight background separation
//            }
//            .navigationTitle("Comments")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                 ToolbarItem(placement: .navigationBarLeading) {
//                      Button("Close") {
//                          presentationMode.wrappedValue.dismiss()
//                      }
//                  }
//             }
//        }
//    }
//}
//
//struct CommentRowView: View {
//     let comment: Comment
//     let author: User?
//
//     var body: some View {
//          HStack(alignment: .top, spacing: 10) {
//                AsyncImage(url: author?.profileImageURL) { $0.resizable().scaledToFill() }
//                    placeholder: { Image(systemName: "person.circle.fill").resizable().foregroundColor(.gray) }
//                   .frame(width: 30, height: 30)
//                   .clipShape(Circle())
//
//               VStack(alignment: .leading, spacing: 3) {
//                   HStack {
//                       Text(author?.username ?? "User").font(.caption).bold()
//                        Text(comment.timestamp, style: .relative).font(.caption2).foregroundColor(.gray)
//                    }
//                    Text(comment.text).font(.caption)
//                }
//               Spacer() // Push content to leading edge
//           }
//          .padding(.vertical, 4)
//      }
//}
//
//// --- Post Creation View (Unchanged from Phase 1) ---
//// CreatePostView
//
//// --- Profile Views (Updated for Phase 2) ---
//
//struct ProfileViewWrapper: View {
//    let viewingUserID: UUID
//    @EnvironmentObject var authViewModel: AuthViewModel
//
//     // Initialize the VM here within the wrapper
//     @StateObject private var profileViewModel: ProfileViewModel
//    
//     init(viewingUserID: UUID) {
//         self.viewingUserID = viewingUserID
//         // Initialize the StateObject correctly using the parameter
//         _profileViewModel = StateObject(wrappedValue: ProfileViewModel(viewingUserID: viewingUserID, currentUserID: AuthViewModel().currentUser?.id ?? User.loggedInUser.id)) // Use loggedInUser ID for init if needed
//     }
//
//    var body: some View {
//         // Pass the already initialized viewModel down
//          ProfileView(viewModel: profileViewModel)
//              .environmentObject(authViewModel) // Ensure AuthViewModel is passed down too
//              .task {
//                   // Trigger fetch when the wrapper appears if VM hasn't loaded data
//                    if profileViewModel.user == nil {
//                       await profileViewModel.fetchProfileAndProjects()
//                   }
//              }
//      }
//}
//
//struct ProfileView: View {
//    @ObservedObject var viewModel: ProfileViewModel // Use ObservedObject here
//     @EnvironmentObject var authViewModel: AuthViewModel
//     @State private var showingEditProfile = false
//
//    // Map state variable for the service area map
//     @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion(.world) // Default region
//     @State private var serviceAreaAnnotations: [ServiceAreaAnnotation] = []
//
//    var isViewingOwnProfile: Bool {
//        viewModel.user?.id == authViewModel.currentUser?.id
//    }
//
//    var body: some View {
//        ScrollView {
//            if viewModel.isLoading && viewModel.user == nil { // Check if initial profile is loading
//                ProgressView("Loading Profile...")
//                    .frame(maxWidth: .infinity).padding()
//            } else if let user = viewModel.user {
//                VStack(alignment: .leading, spacing: 15) {
//                    // Profile Header (Unchanged)
//                    HStack(alignment: .top) {
//                         // ... (AsyncImage, Username, Follower counts)
//                          AsyncImage(url: user.profileImageURL) { image in
//                              image.resizable().scaledToFill()
//                          } placeholder: {
//                              Image(systemName: "person.circle.fill").resizable()
//                                  .foregroundColor(.gray)
//                          }
//                          .frame(width: 80, height: 80)
//                          .clipShape(Circle())
//
//                        VStack(alignment: .leading) {
//                             Text(user.username).font(.title).bold()
//                             HStack {
//                                 Text("**\(user.followers.count)** followers")
//                                 Text("**\(user.following.count)** following")
//                             }
//                             .font(.subheadline)
//                             .foregroundColor(.gray)
//                         }
//                        Spacer()
//                      }
//
//                    // Bio (Unchanged)
//                    if let bio = user.bio, !bio.isEmpty { Text(bio).bodyText() }
//
//                     // Action Buttons (Edit/Follow/Unfollow - Unchanged)
//                    if isViewingOwnProfile {
//                         // ... (Edit Profile, Logout Buttons)
//                          Button { showingEditProfile = true } label: {
//                               Text("Edit Profile").frame(maxWidth: .infinity)
//                          }
//                          .buttonStyle(.bordered)
//                          Button("Logout", role: .destructive) { authViewModel.logout() }
//                           .buttonStyle(.bordered).frame(maxWidth: .infinity)
//
//                    } else {
//                         // ... (Follow/Unfollow Button)
//                           Button {
//                               Task { viewModel.isFollowing ? await viewModel.unfollow() : await viewModel.follow() }
//                           } label: {
//                               Text(viewModel.isFollowing ? "Unfollow" : "Follow").frame(maxWidth: .infinity)
//                           }
//                           .buttonStyle(viewModel.isFollowing ? .bordered : .borderedProminent)
//                           .disabled(viewModel.isLoading)
//                    }
//
//                     // --- Phase 2: Enhanced Profile Sections ---
//                     if user.isContractor {
//                         ProfileSection(title: "Services Offered") {
//                             TagCloudView(tags: user.servicesOffered ?? [])
//                          }
//
//                          ProfileSection(title: "Service Area") {
//                              if let description = user.serviceAreaDescription {
//                                    Text(description).font(.subheadline)
//                                }
//                               // Display Map if coordinates exist
//                               if let coords = user.serviceAreaCoordinates, !coords.isEmpty {
//                                   Map(coordinateRegion: $mapRegion, annotationItems: serviceAreaAnnotations) { annotation in
//                                        MapPin(coordinate: annotation.coordinate, tint: .orange) // Simple pin
//                                    }
//                                    .frame(height: 150)
//                                    .cornerRadius(8)
//                                    .disabled(true) // Make map non-interactive for display
//                                    .onAppear { // Update map region when coordinates are available
//                                        updateMapRegion(coordinates: coords)
//                                     }
//                                     .onChange(of: user.serviceAreaCoordinates) { newCoords in // Update if coords change
//                                         updateMapRegion(coordinates: newCoords ?? [])
//                                     }
//                               } else {
//                                   Text("Service area map not available.").font(.caption).foregroundColor(.gray)
//                               }
//                          }
//
//                          ProfileSection(title: "Certifications") {
//                              if let certs = user.certifications, !certs.isEmpty {
//                                   ForEach(certs, id: \.self) { cert in
//                                       Label(cert, systemImage: "checkmark.seal.fill")
//                                          .font(.subheadline)
//                                          .padding(.bottom, 2)
//                                   }
//                               } else {
//                                   Text("No certifications listed.").font(.caption).foregroundColor(.gray)
//                               }
//                          }
//
//                           // --- Contact Buttons ---
//                          if user.contactPhone != nil || user.contactEmail != nil {
//                               Divider()
//                               HStack {
//                                   if let phone = user.contactPhone, let url = URL(string: "tel:\(phone)") {
//                                        Link(destination: url) {
//                                            Label("Call", systemImage: "phone.fill")
//                                        }
//                                        .buttonStyle(.bordered)
//                                    }
//                                   Spacer()
//                                   if let email = user.contactEmail, let url = URL(string: "mailto:\(email)") {
//                                        Link(destination: url) {
//                                             Label("Email", systemImage: "envelope.fill")
//                                         }
//                                         .buttonStyle(.bordered)
//                                     }
//                               }
//                               .padding(.top, 5)
//                           }
//                     } // End if user.isContractor
//
//                    // --- Phase 2: Project Portfolio Section ---
//                    if user.isContractor {
//                        Divider().padding(.vertical)
//                        Text("Portfolio")
//                            .font(.title2).bold()
//
//                        if viewModel.isLoadingProjects {
//                             ProgressView("Loading Projects...")
//                                 .frame(maxWidth:.infinity).padding()
//                         } else if viewModel.projects.isEmpty {
//                             Text(isViewingOwnProfile ? "You haven't added any projects yet." : "\(user.username) hasn't added any projects yet.")
//                                 .foregroundColor(.gray)
//                                 .frame(maxWidth: .infinity, alignment: .center)
//                                 .padding()
//                             // Optionally add a button for own profile to create first project
//                             if isViewingOwnProfile {
//                                  NavigationLink("Create Your First Project", destination: CreateProjectView())
//                                       .buttonStyle(.borderedProminent)
//                                       .padding(.top)
//                             }
//                         } else {
//                              // List Projects (using horizontal scroll for brevity)
//                              ScrollView(.horizontal, showsIndicators: false) {
//                                   HStack(spacing: 15) {
//                                       ForEach(viewModel.projects) { project in
//                                           NavigationLink(destination: ProjectDetailViewWrapper(projectID: project.id)) {
//                                               ProjectCardView(project: project)
//                                           }
//                                           .buttonStyle(PlainButtonStyle()) // Prevent card from looking like a standard button
//                                        }
//                                   }
//                                   .padding(.horizontal) // Add padding to the HStack content
//                              }
//                               .padding(.horizontal, -15) // Counteract ScrollView's default inset? Or remove padding() on HStack above
//                          }
//                        // Button for own profile to add more projects
//                        if isViewingOwnProfile && !viewModel.projects.isEmpty {
//                           NavigationLink("Add Another Project", destination: CreateProjectView())
//                                .buttonStyle(.bordered)
//                                .frame(maxWidth: .infinity)
//                                .padding(.top)
//                        }
//                    }
//
//                    // User's Posts (No change needed from profile perspective, feed handles display)
//                    // Divider().padding(.vertical)
//                    // Text("Posts") ...
//
//                     if let errorMessage = viewModel.errorMessage {
//                         Text("Error: \(errorMessage)")
//                             .foregroundColor(.red)
//                             .font(.caption)
//                             .padding(.top)
//                     }
//
//                } // End Main VStack
//                .padding()
//            } else if let errorMessage = viewModel.errorMessage {
//                 Text("Error loading profile: \(errorMessage)")
//                     .foregroundColor(.red)
//                     .padding()
//            } else {
//                Text("User not found.") // Fallback
//                    .padding()
//            }
//        } // End ScrollView
//        .navigationTitle(viewModel.user?.username ?? "Profile")
//         .navigationBarTitleDisplayMode(.inline)
//          // Task moved to ProfileViewWrapper for better control
//         .sheet(isPresented: $showingEditProfile) {
//              if let currentUser = authViewModel.currentUser {
//                  NavigationView {
//                      EditProfileView(userToEdit: currentUser)
//                          .environmentObject(authViewModel)
//                  }
//              }
//         }
//          .onReceive(authViewModel.$currentUser) { updatedUser in
//               if updatedUser?.id == viewModel.user?.id {
//                    // Update the local view model's user state if the auth user changes
//                    viewModel.user = updatedUser
//                    // Also update map if service area changed
//                     updateMapRegion(coordinates: updatedUser?.serviceAreaCoordinates ?? [])
//                }
//           }
//          // Initial map setup if profile loaded immediately
//          .onAppear {
//                if let coords = viewModel.user?.serviceAreaCoordinates, !coords.isEmpty {
//                     updateMapRegion(coordinates: coords)
//                 }
//           }
//    } // End body
//
//     // Helper function to update map region and annotations
//     private func updateMapRegion(coordinates: [CLLocationCoordinate2D]) {
//         guard !coordinates.isEmpty else {
//             // Maybe reset to world view or a default region?
//              mapRegion = MKCoordinateRegion(.world)
//              serviceAreaAnnotations = []
//             return
//         }
//
//          // Create annotations
//          serviceAreaAnnotations = coordinates.map { ServiceAreaAnnotation(coordinate: $0, title: nil) }
//
//          // Calculate bounding region (simple average for center, fixed span for demo)
//          var avgLat: CLLocationDegrees = 0
//          var avgLon: CLLocationDegrees = 0
//          coordinates.forEach {
//              avgLat += $0.latitude
//              avgLon += $0.longitude
//          }
//          let center = CLLocationCoordinate2D(latitude: avgLat / Double(coordinates.count),
//                                             longitude: avgLon / Double(coordinates.count))
//
//            // Adjust span based on coordinate spread later if needed
//           let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5) // Adjust span as needed
//           mapRegion = MKCoordinateRegion(center: center, span: span)
//     }
//}
//
//// Helper View for Profile Sections
//struct ProfileSection<Content: View>: View {
//     let title: String
//     @ViewBuilder let content: Content
//
//     var body: some View {
//          VStack(alignment: .leading, spacing: 8) {
//              Text(title)
//                 .font(.headline)
//              content // Embed the provided content view
//          }
//          .padding(.vertical, 5)
//      }
//}
//
//// Reusable Tag Cloud View
//struct TagCloudView: View {
//     let tags: [String]
//
//     var body: some View {
//          // Use FlexibleView or similar layout if tags need to wrap
//          // Simple HStack for MVP
//          ScrollView(.horizontal, showsIndicators: false) {
//              HStack {
//                   ForEach(tags, id: \.self) { tag in
//                       Text(tag)
//                          .font(.caption)
//                          .padding(.horizontal, 8)
//                          .padding(.vertical, 4)
//                          .background(Color.blue.opacity(0.1))
//                          .foregroundColor(.blue)
//                          .cornerRadius(10)
//                   }
//              }
//          }
//      }
//}
//
//struct EditProfileView: View {
//     @EnvironmentObject var authViewModel: AuthViewModel
//     @Environment(\.presentationMode) var presentationMode
//     @State private var editedUser: User
//
//     init(userToEdit: User) {
//         _editedUser = State(initialValue: userToEdit)
//     }
//
//    var body: some View {
//        Form {
//             Section("Public Profile") {
//                  TextField("Username", text: $editedUser.username)
//                      .autocapitalization(.none)
//                      .disableAutocorrection(true)
//                  VStack(alignment: .leading) {
//                     Text("Bio").font(.caption).foregroundColor(.gray)
//                      TextEditor(text: Binding($editedUser.bio, replacingNilWith: ""))
//                         .frame(height: 100)
//                 }
//                  // Profile Image URL (Display Only) - unchanged
//                   HStack { Text("Profile Image URL"); Spacer(); Text(editedUser.profileImageURL?.absoluteString ?? "Not Set").font(.caption).foregroundColor(.gray).lineLimit(1) }
//                   Button("Change Profile Picture (Coming Soon)") {}.disabled(true)
//             }
//
//              // --- Phase 2: Additional Editable Fields ---
//              Section("Contact Info") {
//                  TextField("Contact Phone", text: Binding($editedUser.contactPhone, replacingNilWith: ""))
//                      .keyboardType(.phonePad)
//                  TextField("Contact Email", text: Binding($editedUser.contactEmail, replacingNilWith: ""))
//                      .keyboardType(.emailAddress)
//                      .autocapitalization(.none)
//              }
//
//              if editedUser.isContractor { // Show contractor fields only if applicable
//                  Section("Contractor Details") {
//                       // Editable Services Offered (Simple comma separated for MVP)
//                       VStack(alignment: .leading) {
//                           Text("Services Offered (comma-separated)").font(.caption).foregroundColor(.gray)
//                            TextEditor(text: Binding( // Convert array to string and back
//                                get: { editedUser.servicesOffered?.joined(separator: ", ") ?? "" },
//                                set: { newValue in
//                                     editedUser.servicesOffered = newValue.split(separator: ",")
//                                         .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//                                         .filter { !$0.isEmpty }
//                                 }
//                            ))
//                            .frame(height: 80)
//                        }
//
//                       TextField("Service Area Description", text: Binding($editedUser.serviceAreaDescription, replacingNilWith: ""))
//
//                       // Certifications (comma separated)
//                       VStack(alignment: .leading) {
//                            Text("Certifications (comma-separated)").font(.caption).foregroundColor(.gray)
//                             TextEditor(text: Binding( // Convert array to string and back
//                                 get: { editedUser.certifications?.joined(separator: ", ") ?? "" },
//                                 set: { newValue in
//                                      editedUser.certifications = newValue.split(separator: ",")
//                                          .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//                                          .filter { !$0.isEmpty }
//                                  }
//                             ))
//                             .frame(height: 80)
//                         }
//                       
//                       // Service Area Coordinates (Not easily editable via text, skip for now)
//                       Text("Service Area Map Points (Not editable here)")
//                           .font(.caption).foregroundColor(.gray)
//                   }
//              }
//            
//             Section {
//                 Button("Save Changes") {
//                     Task {
//                          // Ensure isContractor flag is preserved if needed
//                          // editedUser.isContractor = authViewModel.currentUser?.isContractor ?? false
//                          await authViewModel.updateProfile(user: editedUser)
//                           if authViewModel.errorMessage == nil {
//                               presentationMode.wrappedValue.dismiss()
//                           }
//                     }
//                 }.disabled(authViewModel.isLoading)
//                 Button("Cancel", role: .cancel) { presentationMode.wrappedValue.dismiss() }
//             }
//            
//             // Loading/Error display
//             if authViewModel.isLoading { ProgressView().frame(maxWidth: .infinity) }
//             if let errorMessage = authViewModel.errorMessage { Text("Error: \(errorMessage)").foregroundColor(.red) }
//        }
//        .navigationTitle("Edit Profile")
//         .navigationBarTitleDisplayMode(.inline)
//    }
//}
//#Preview("EditProfileView") {
//    EditProfileView()
//}
//// Helper Binding extension to work with Optionals in TextFields/TextEditors
//extension Binding where Value == String? {
//     func replacingNilWith(_ defaultValue: String) -> Binding<String> {
//         Binding<String>(
//             get: {
//                 self.wrappedValue ?? defaultValue
//             },
//             set: {
//                 self.wrappedValue = $0.isEmpty ? nil : $0 // Set back to nil if empty
//             }
//         )
//     }
//}
////
////// --- Project Views (New for Phase 2) ---
////
////struct ProjectCardView: View {
////     let project: Project
////
////     var body: some View {
////          VStack(alignment: .leading) {
////               // Display first media item as thumbnail
////                AsyncImage(url: project.mediaURLs?.first) { image in
////                     image.resizable().
