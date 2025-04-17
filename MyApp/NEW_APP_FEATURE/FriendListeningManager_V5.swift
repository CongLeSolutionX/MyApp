////
////  FriendListeningManager_V5.swift
////  MyApp
////
////  Created by Cong Le on 4/16/25.
////
//
//import SwiftUI
//
//// MARK: - Data Models (Conceptual)
//
//// Represents a friend's listening status for the current track
//struct FriendListeningInfo: Identifiable, Hashable {
//    let id: String // Friend's User ID
//    let friendName: String
//    let friendAvatarUrl: URL?
//    let status: ListeningStatus
//    let timestamp: Date? // Relevant for 'recently listened'
//
//    enum ListeningStatus: Hashable {
//        case listeningNow
//        case listenedRecently
//    }
//}
//
//// MARK: - ViewModel (Conceptual Outline)
//
//// In a real app, this would handle API calls, WebSocket connections, etc.
//@MainActor // Ensure UI updates happen on the main thread
//class NowPlayingViewModel: ObservableObject {
//    @Published var currentTrackId: String? // Set when track changes
//    @Published var friendActivity: [FriendListeningInfo] = [] // Friends related to the current track
//    @Published var isLoadingActivity: Bool = false
//
//    // TODO: Add methods to:
//    // - Connect/disconnect real-time updates (WebSockets?)
//    // - Fetch initial historical data when track changes
//    // - Handle consent checks
//    // - Process incoming real-time events or fetched data
//    // - Update friendActivity array
//
//    func trackDidChange(newTrackId: String) {
//        currentTrackId = newTrackId
//        fetchFriendActivity(trackId: newTrackId)
//    }
//
//    private func fetchFriendActivity(trackId: String) {
//        isLoadingActivity = true
//        friendActivity = [] // Clear previous activity
//
//        // --- !!! This is where the API call/Backend interaction happens !!! ---
//        // --- !!! This part is HYPOTHETICAL due to public API limits !!! ---
//        Task {
//            // Simulate network call and data processing
//            try? await Task.sleep(nanoseconds: 1_000_000_000) // Simulate delay
//
//            // --- Example Data (Replace with actual logic) ---
//            let fetchedInfo: [FriendListeningInfo] = [
//                // Sample friend listening now
//                FriendListeningInfo(id: "friend123", friendName: "Alex", friendAvatarUrl: URL(string: "https://via.placeholder.com/50/AABBCC/FFFFFF?text=A"), status: .listeningNow, timestamp: Date()),
//                // Sample friend listened recently
//                FriendListeningInfo(id: "friend456", friendName: "Brenda", friendAvatarUrl: URL(string: "https://via.placeholder.com/50/CCBBAA/FFFFFF?text=B"), status: .listenedRecently, timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date())),
//                 FriendListeningInfo(id: "friend789", friendName: "Casey", friendAvatarUrl: URL(string: "https://via.placeholder.com/50/AACCBB/FFFFFF?text=C"), status: .listenedRecently, timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()))
//            ]
//            // --- End Example Data ---
//
//            self.friendActivity = fetchedInfo // Update the published property
//            self.isLoadingActivity = false
//        }
//        // --- End Hypothetical Backend Interaction ---
//    }
//}
//
//// MARK: - Friend Activity UI Component
//
//struct FriendActivityIndicatorView: View {
//    // ObservedObject connects this view to the ViewModel's updates
//    @ObservedObject var viewModel: NowPlayingViewModel
//    let maxAvatarsToShow = 3 // Max avatars before showing "+N"
//
//    var body: some View {
//        // Only show if not loading and there's activity
//        if !viewModel.isLoadingActivity && !viewModel.friendActivity.isEmpty {
//            HStack(spacing: -10) { // Negative spacing for overlap
//                // Show avatars up to the limit
//                ForEach(viewModel.friendActivity.prefix(maxAvatarsToShow)) { info in
//                    AvatarView(info: info)
//                }
//
//                // Show "+N" indicator if more friends exist
//                if viewModel.friendActivity.count > maxAvatarsToShow {
//                    MoreIndicator(count: viewModel.friendActivity.count - maxAvatarsToShow)
//                }
//            }
//            .padding(.leading, 10) // Add padding so the first avatar isn't cut off by spacing
//            .transition(.opacity.combined(with: .scale(scale: 0.8))) // Add animation
//            .animation(.spring(), value: viewModel.friendActivity) // Animate changes
//            .onTapGesture {
//                // TODO: Action on tap (e.g., show bottom sheet with full list)
//                print("Friend indicator tapped!")
//            }
//        } else if viewModel.isLoadingActivity {
//             ProgressView()
//                .scaleEffect(0.7) // Make the loader small
//                .frame(height: 30) // Match approximate height of avatars
//                 .transition(.opacity)
//        } else {
//            EmptyView() // Don't show anything if no activity and not loading
//                 .frame(height: 30) // Reserve space to prevent layout jumps
//        }
//    }
//}
//
//// MARK: - Individual Avatar View Component
//
//struct AvatarView: View {
//    let info: FriendListeningInfo
//
//    var body: some View {
//        AsyncImage(url: info.friendAvatarUrl) { phase in
//            if let image = phase.image {
//                image.resizable()
//            } else if phase.error != nil {
//                // Error or empty placeholder
//                Image(systemName: "person.fill")
//                     .resizable()
//                     .scaledToFit()
//                     .padding(5) // Padding within the circle
//                     .background(Color.gray.opacity(0.3))
//                     .foregroundColor(.white)
//            } else {
//                 // Placeholder while loading
//                 Color.gray.opacity(0.1) // Simple placeholder color
//            }
//        }
//        .scaledToFill() // Fill the frame
//        .frame(width: 30, height: 30)
//        .clipShape(Circle())
//        .background( // Background circle for border/live effect
//            Circle()
//                 // Show green border only if listening now
//                .stroke(info.status == .listeningNow ? Color.green : Color.clear, lineWidth: 2)
//               // .background(Circle().fill(.background))// Opaque background behind avatar
//        )
//        .overlay( // Optional: Small icon for "listening now"
//            Group {
//                if info.status == .listeningNow {
//                    Image(systemName: "waveform")
//                        .font(.system(size: 8))
//                        .padding(2)
//                        .background(Color.green)
//                        .foregroundColor(.white)
//                        .clipShape(Circle())
//                        .offset(x: 10, y: 10) // Position at bottom-right
//                }
//            }
//        )
//        .shadow(radius: 1) // Add subtle shadow
//    }
//}
//
//// MARK: - "+N" More Indicator
//
//struct MoreIndicator: View {
//    let count: Int
//
//    var body: some View {
//        Text("+\(count)")
//            .font(.system(size: 10, weight: .bold))
//            .foregroundColor(.white)
//            .frame(width: 30, height: 30)
//            .background(Color.gray)
//            .clipShape(Circle())
//            .shadow(radius: 1)
//    }
//}
//
//// MARK: - Example Usage in a Now Playing Screen (Conceptual)
//
//struct ConceptualNowPlayingView: View {
//    @StateObject private var viewModel = NowPlayingViewModel()
//    // Assume some state for the current track ID
//    @State private var currentTrack: String = "track_id_123"
//
//    var body: some View {
//        VStack {
//            // --- Other Now Playing UI Elements ---
//            Spacer()
//            Text("Track: \(currentTrack)")
//                .font(.title)
//            Text("Artist Name")
//                .font(.title2)
//                .foregroundColor(.secondary)
//            Spacer()
//            // --- End Other UI Elements ---
//
//            // --- Friend Activity Indicator ---
//            FriendActivityIndicatorView(viewModel: viewModel)
//                .padding(.bottom) // Add some padding below it
//
//            // --- Playback Controls etc. ---
//            HStack {
//                Button("Play Steamin'") {
//                    currentTrack = "6KJgxZYve2dbchVjw3MxBQ" // Example track ID from your data
//                    viewModel.trackDidChange(newTrackId: currentTrack)
//                }
//                Button("Play Kind Of Blue") {
//                      currentTrack = "4sb0eMpDn3upAFfyi4q2rw" // Different track ID
//                     viewModel.trackDidChange(newTrackId: currentTrack)
//                }
//            }
//            .padding()
//            Spacer()
//        }
//        .onAppear {
//            // Fetch initial data when the view appears
//            viewModel.trackDidChange(newTrackId: currentTrack)
//        }
//    }
//}
//
//// MARK: - Preview
//struct ConceptualNowPlayingView_Previews: PreviewProvider {
//    static var previews: some View {
//        ConceptualNowPlayingView()
//    }
//}
//
//struct FriendActivityIndicatorView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Create a view model instance for preview
//        let vm = NowPlayingViewModel()
//        // Add sample data directly for preview
//        vm.friendActivity = [
//             FriendListeningInfo(id: "friend123", friendName: "Alex", friendAvatarUrl: URL(string: "https://via.placeholder.com/50/AABBCC/FFFFFF?text=A"), status: .listeningNow, timestamp: Date()),
//             FriendListeningInfo(id: "friend456", friendName: "Brenda", friendAvatarUrl: URL(string: "https://via.placeholder.com/50/CCBBAA/FFFFFF?text=B"), status: .listenedRecently, timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date())),
//             FriendListeningInfo(id: "friend789", friendName: "Casey", friendAvatarUrl: URL(string: "https://via.placeholder.com/50/AACCBB/FFFFFF?text=C"), status: .listenedRecently, timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())),
//            FriendListeningInfo(id: "friend101", friendName: "Dana", friendAvatarUrl: URL(string: "https://via.placeholder.com/50/BBAACC/FFFFFF?text=D"), status: .listenedRecently, timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()))
//        ]
//
//        return Group {
//            FriendActivityIndicatorView(viewModel: vm)
//                .previewLayout(.sizeThatFits)
//                .padding()
//                 .previewDisplayName("With 4 Friends")
//
//             // Simulate loading state
//            let loadingVM = NowPlayingViewModel()
//            // loadingVM.isLoadingActivity = true
//             FriendActivityIndicatorView(viewModel: loadingVM)
//                 .previewLayout(.sizeThatFits)
//                 .padding()
//                 .previewDisplayName("Loading State")
//
//             // Simulate no friends state
//             let emptyVM = NowPlayingViewModel()
//              FriendActivityIndicatorView(viewModel: emptyVM)
//                  .previewLayout(.sizeThatFits)
//                  .padding()
//                  .previewDisplayName("No Friends State")
//        }
//    }
//}
