////
////  MusicAdView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/8/25.
////
//
//import SwiftUI
//import Combine // Needed for Timer
//
//// Enum for Like State
//enum LikeState {
//    case none, liked, disliked
//}
//
//// Main Functional View Structure
//struct FunctionalMusicAdView: View {
//
//    // --- State Variables ---
//    @State private var isPlaying: Bool = true // Ad usually starts playing
//    @State private var currentTime: Double = 0.0 // Elapsed time in seconds
//    @State private var likeState: LikeState = .none
//    @State private var showAdOptionsSheet: Bool = false
//    @State private var showLearnMoreSheet: Bool = false
//
//    // --- Constants & Mock Data ---
//    let totalDuration: Double = 17.0 // Total ad duration in seconds (based on 0:02 + 0:15)
//    let adURL = URL(string: "https://www.example-advertiser.com/waggery-promo") // Mock URL
//
//    // --- Timer ---
//    // Publisher that fires every second on the main run loop
//    @State private var timerSubscription: Cancellable?
//
//    // Computed Properties
//    private var adProgress: Double {
//        // Ensure progress is between 0.0 and 1.0
//        min(max(currentTime / totalDuration, 0.0), 1.0)
//    }
//    private var remainingTime: Double {
//        totalDuration - currentTime
//    }
//
//    var body: some View {
//        ZStack {
//            // 1. Background Image/Video (Blurred) - Remains the same
//            Image("backgroundImage") // Placeholder - Use your actual background
//                .resizable()
//                .scaledToFill()
//                .blur(radius: 15)
//                .edgesIgnoringSafeArea(.all)
//                .accessibilityHidden(true) // Hide decorative background from accessibility
//
//            // 2. Foreground Content Layer
//            VStack(spacing: 15) {
//                // 2a. Top Bar (Info Text & More Options)
//                HStack {
//                    Text("Your music will continue after the break")
//                        .font(.caption)
//                        .foregroundColor(.white.opacity(0.8))
//                    Spacer()
//                    Button {
//                        showAdOptionsSheet = true // Action: Show options
//                        print("Ad options button tapped")
//                    } label: {
//                        Image(systemName: "ellipsis")
//                            .foregroundColor(.white.opacity(0.8))
//                    }
//                    .accessibilityLabel("More ad options")
//                }
//                .padding(.horizontal)
//                .padding(.top, 5)
//
//                Spacer() // Pushes content down
//
//                // 2b. Advertisement Info Section - Remains mostly visual
//                HStack(spacing: 12) {
//                    Image(systemName: "dog.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 45, height: 45)
//                        .padding(5)
//                        .background(Color.orange.opacity(0.8))
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                        .accessibilityLabel("Waggery logo")
//
//                    VStack(alignment: .leading, spacing: 2) {
//                        Text("Waggery")
//                            .font(.headline)
//                            .fontWeight(.medium)
//                            .foregroundColor(.white)
//                        Text("Advertisement")
//                            .font(.caption)
//                            .foregroundColor(.white.opacity(0.7))
//                    }
//                    Spacer()
//                }
//                .padding(.horizontal)
//
//                // 2c. Progress Bar & Timers (Now Dynamic)
//                VStack(spacing: 4) {
//                    ProgressView(value: adProgress) // Bound to computed property
//                        .progressViewStyle(LinearProgressViewStyle(tint: .white.opacity(0.8)))
//                        .frame(height: 3)
//                        .padding(.horizontal)
//                        .accessibilityValue("\(Int(adProgress * 100)) percent complete")
//
//                    HStack {
//                        Text(formatTime(currentTime)) // Dynamic current time
//                            .font(.caption2)
//                            .foregroundColor(.white.opacity(0.7))
//                            .frame(width: 40, alignment: .leading) // Fixed width for stability
//                        Spacer()
//                        Text("-\(formatTime(remainingTime))") // Dynamic remaining time
//                            .font(.caption2)
//                            .foregroundColor(.white.opacity(0.7))
//                            .frame(width: 40, alignment: .trailing) // Fixed width for stability
//                    }
//                    .padding(.horizontal)
//                }
//
//                // 2d. Playback Controls (Now Functional)
//                HStack(spacing: 30) {
//                    // Thumbs Up Button
//                    Button { handleLikeDislike(.liked) } label: {
//                        Image(systemName: likeState == .liked ? "hand.thumbsup.fill" : "hand.thumbsup")
//                            .font(.title2)
//                            .foregroundColor(likeState == .liked ? .accentColor : .white.opacity(0.9))
//                    }
//                    .accessibilityLabel(likeState == .liked ? "Liked" : "Like this ad")
//
//                    // Backward Button (Placeholder action)
//                    Button { print("Backward tapped (no action)") } label: {
//                        Image(systemName: "backward.fill")
//                            .font(.title2)
//                    }
//                    .accessibilityLabel("Previous ad segment (disabled)")
//                     .opacity(0.5) // Indicate disabled visually (optional)
//
//                    // Play/Pause Button
//                    Button { togglePlayPause() } label: {
//                        Image(systemName: isPlaying ? "pause.fill" : "play.fill") // Dynamic icon
//                            .font(.system(size: 30))
//                            .frame(width: 60, height: 60)
//                            .background(Color.white)
//                            .foregroundColor(.black)
//                            .clipShape(Circle())
//                    }
//                    .accessibilityLabel(isPlaying ? "Pause ad" : "Play ad")
//
//                    // Forward Button (Placeholder action)
//                    Button { print("Forward tapped (no action)") } label: {
//                        Image(systemName: "forward.fill")
//                            .font(.title2)
//                    }
//                     .accessibilityLabel("Next ad segment (disabled)")
//                     .opacity(0.5) // Indicate disabled visually (optional)
//
//                    // Thumbs Down Button
//                    Button { handleLikeDislike(.disliked) } label: {
//                        Image(systemName: likeState == .disliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
//                            .font(.title2)
//                             .foregroundColor(likeState == .disliked ? .accentColor : .white.opacity(0.9))
//                    }
//                    .accessibilityLabel(likeState == .disliked ? "Disliked" : "Dislike this ad")
//                }
//                .foregroundColor(.white.opacity(0.9)) // Default color for icons without specific state
//                .padding(.vertical, 10)
//
//                 Spacer().frame(height: 20)
//
//                // 2e. Bottom Call-to-Action Banner (Now Functional)
//                HStack {
//                    Text("Shop Waggery's wag-worthy toys and healthy dog food.")
//                        .font(.footnote)
//                        .fontWeight(.medium)
//                        .foregroundColor(.white)
//                        .lineLimit(2)
//                        .minimumScaleFactor(0.8)
//
//                    Spacer()
//
//                    Button {
//                        showLearnMoreSheet = true // Action: Show "Learn More"
//                        print("Learn More tapped")
//                    } label: {
//                         Text("Learn more")
//                            .font(.footnote)
//                            .fontWeight(.bold)
//                            .foregroundColor(Color(red: 0.6, green: 0.2, blue: 0.1))
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 8)
//                            .background(Color.white)
//                            .clipShape(Capsule())
//                    }
//                    .accessibilityHint("Opens advertiser website or details")
//                }
//                .padding()
//                .background(Color(red: 0.7, green: 0.25, blue: 0.15))
//                .cornerRadius(12)
//                .padding(.horizontal)
//                .padding(.bottom)
//
//            } // End Main VStack
////            .padding(.top, SafeAreaInsetsKey.defaultValue.top) // Use Safe Area helper
////            .padding(.bottom, SafeAreaInsetsKey.defaultValue.bottom)
//
//        } // End ZStack
//        .preferredColorScheme(.dark)
//        .onAppear(perform: startTimer) // Start timer when view appears
//        .onDisappear(perform: stopTimer) // Stop timer when view disappears
//        // --- Sheets ---
//        .sheet(isPresented: $showAdOptionsSheet) {
//            AdOptionsView() // Present the options sheet
//        }
//        .sheet(isPresented: $showLearnMoreSheet) {
//            LearnMoreView(url: adURL) // Present the learn more sheet
//                // Add presentation detents if you only want a partial sheet
//                // .presentationDetents([.medium, .large])
//        }
//    }
//
//    // --- Action Handlers ---
//
//    func togglePlayPause() {
//        isPlaying.toggle()
//        if isPlaying {
//            startTimer() // Resume timer if needed (or ensure it starts if paused at 0)
//             print("Ad playing")
//        } else {
//            // Timer pausing is handled within the timer's receive block
//             print("Ad paused")
//        }
//    }
//
//    func handleLikeDislike(_ newStatus: LikeState) {
//        if likeState == newStatus {
//            likeState = .none // Toggle off if tapped again
//            print("Ad like status reset")
//        } else {
//            likeState = newStatus
//            print("Ad status set to: \(newStatus)")
//            // --- Simulate sending feedback ---
//            // In a real app, you'd make a network call here
//            // sendFeedbackToServer(status: newStatus)
//            // ---                           ---
//        }
//    }
//
//    // --- Timer Management ---
//
//    func startTimer() {
//        // Ensure only one timer runs
//        stopTimer()
//        // Start timer only if not finished
//        guard currentTime < totalDuration else { return }
//
//        // Re-create the timer subscription
//        timerSubscription = Timer.publish(every: 1.0, tolerance: 0.1, on: .main, in: .common)
//            .autoconnect()
//            .sink { _ in // The underscore ignores the timestamp value
//                guard isPlaying else { return } // Only advance time if playing
//
//                if currentTime < totalDuration {
//                    currentTime += 1.0
//                } else {
//                    // Ad finished
//                    isPlaying = false
//                    stopTimer()
//                    print("Ad finished playback.")
//                    // --- Trigger next action ---
//                    // In a real app: notify music player to resume, dismiss ad view, etc.
//                    // triggerMusicResume()
//                    // ---                     ---
//                }
//            }
//        // Initially start playing if needed
//         if isPlaying && currentTime == 0 {
//             print("Ad starting playback.")
//         }
//    }
//
//    func stopTimer() {
//        timerSubscription?.cancel()
//        timerSubscription = nil // Release the subscription
//        // No print statement here as it's called frequently
//    }
//
//    // --- Helper Functions ---
//    func formatTime(_ time: Double) -> String {
//        let minutes = Int(time) / 60
//        let seconds = Int(time) % 60
//        // "%02d" pads with a leading zero if needed (e.g., 0:05)
//        return String(format: "%d:%02d", minutes, seconds)
//    }
//}
//
//// --- Supporting Views for Sheets ---
//
//struct AdOptionsView: View {
//    @Environment(\.dismiss) var dismiss // Environment value to dismiss the sheet
//
//    var body: some View {
//        NavigationView { // Add NavigationView for title and close button
//            List {
//                Button("Why am I seeing this ad?") {
//                    print("Tapped: Why this ad?")
//                    // Add navigation or further action here
//                    dismiss()
//                }
//                 Button("Report this ad") {
//                    print("Tapped: Report ad")
//                    // Add reporting logic here
//                    dismiss()
//                }
//                 Button("Advertiser settings") {
//                    print("Tapped: Ad settings")
//                    // Navigate to ad settings if applicable
//                    dismiss()
//                }
//            }
//            .navigationTitle("Ad Options")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") {
//                        dismiss()
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct LearnMoreView: View {
//    @Environment(\.dismiss) var dismiss
//    @Environment(\.openURL) var openURL // Environment action to open URLs
//
//    let url: URL?
//
//    var body: some View {
//         NavigationView {
//             VStack(spacing: 20) {
//                 Image(systemName: "dog.fill") // Use the advertiser icon
//                    .font(.system(size: 60))
//                    .foregroundColor(.orange)
//                    .padding()
//
//                 Text("Visit Waggery")
//                    .font(.title)
//
//                 Text("Learn more about Waggery's products on their website.")
//                    .font(.body)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//
//                 if let validURL = url {
//                     Button {
//                         print("Opening URL: \(validURL)")
//                         openURL(validURL) // Action: Open the URL
//                         dismiss() // Dismiss sheet after opening link
//                     } label: {
//                         Label("Visit Website", systemImage: "safari")
//                     }
//                     .buttonStyle(.borderedProminent)
//                     .tint(.orange) // Match brand color
//                 } else {
//                     Text("No valid link available.")
//                         .foregroundColor(.secondary)
//                 }
//                 Spacer()
//             }
//             .padding()
//             .navigationTitle("Learn More")
//             .navigationBarTitleDisplayMode(.inline)
//              .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") {
//                        dismiss()
//                    }
//                }
//            }
//         }
//    }
//}
//
//// --- Safe Area Helper (Optional but good practice) ---
//
////struct SafeAreaInsetsKey: EnvironmentKey {
////    static var defaultValue: EdgeInsets {
////        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
////            .keyWindow?
////            .safeAreaInsets ?? EdgeInsets()
////    }
////}
//
////extension EnvironmentValues {
////    var safeAreaInsets: EdgeInsets {
////        self[SafeAreaInsetsKey.self]
////    }
////}
//
//// --- Preview Provider ---
//#if DEBUG
//struct FunctionalMusicAdView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Preview needs placeholder image and environment setup if using Core Data
//         FunctionalMusicAdView()
//             // Add a placeholder background for the preview
//            .background(Image(systemName: "photo").resizable().scaledToFill().blur(radius: 15))
//            // Add environment setup if your app uses it elsewhere
//            // .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
////
////// Dummy Persistence Controller for Preview (if needed for environment)
////struct PersistenceController {
////    static let preview = PersistenceController(inMemory: true)
////    let container: NSPersistentContainer
////
////    init(inMemory: Bool = false) {
////        container = NSPersistentContainer(name: "DummyModel") // Use a non-existent model name
////        if inMemory {
////            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
////        }
////        container.loadPersistentStores { _, _ in }
////        container.viewContext.automaticallyMergesChangesFromParent = true
////    }
////}
//#endif
