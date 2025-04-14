//
//  ArticleView_V5.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import SwiftUI
import AVFoundation // <-- Add this import

// Helper for Text-to-Speech
class SpeechSynthesizer: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking: Bool = false
    private var contentToSpeak: String = ""

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(text: String) {
        guard !text.isEmpty else { return }
        contentToSpeak = text // Store the text
        
        // Set up audio session for playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
           // Optionally handle the error, e.g., show an alert
           // Don't proceed if the audio session fails
           return
        }
        
        let utterance = AVSpeechUtterance(string: contentToSpeak)
        // Configure utterance properties if needed (e.g., voice, rate, pitch)
        // utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        // utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        
        if synthesizer.isSpeaking {
             synthesizer.stopSpeaking(at: .immediate) // Stop current speech if any
        }
        
        synthesizer.speak(utterance)
        isSpeaking = true
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        // Deactivate audio session when done
         do {
             try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
         } catch {
             print("Failed to deactivate audio session: \(error)")
         }
    }

    // MARK: - AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
             // Deactivate audio session safely
            do {
                 try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                 print("Failed to deactivate audio session after speech finished: \(error)")
            }
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
         DispatchQueue.main.async {
            self.isSpeaking = false
            // Deactivate audio session safely
            do {
                 try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                 print("Failed to deactivate audio session after speech cancelled: \(error)")
            }
        }
    }
}

// Helper for Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

// Placeholder Comments View
struct CommentsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView { // Add NavigationView for title and close button
            VStack {
                Text("Comments")
                    .font(.largeTitle)
                    .padding()
                Text("This is where comments would be displayed.")
                Spacer()
            }
            .navigationBarTitle("Comments", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

import SwiftUI
import AVFoundation

struct ArticleView: View {
    // --- State Variables ---
    @State private var clapCount: Int = 48 // Mock starting count
    @State private var isBookmarked: Bool = false
    @State private var showCommentsSheet: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var showMoreOptionsSheet: Bool = false

    // Speech Synthesizer State Object
    @StateObject private var speechSynthesizer = SpeechSynthesizer()

    // Environment Variable for Dismiss Action
    @Environment(\.dismiss) var dismiss

    // --- Mock Content --- (Combine paragraphs for easier speech handling)
    let subtitle = "Charting a clear path: From disruption to smooth skies — an illustration created by the author using DALL·E 3 and GPT-4o assistance."
    let title = "The SwiftUI Navigation Airspace: Calm or Chaos?"
    let fullArticleText: String = """
    Building a new feature in your app often feels like scheduling a flight at a small regional airport. With only a handful of runways and a few planes to manage, everything runs like clockwork.
    
    Navigation in SwiftUI mirrors this simplicity when building lightweight apps: just a few `NavigationDestination` closures, and all the "flights" (views) land safely where they're supposed to.
    
    But as your app expands, so does your "air traffic control" complexity. Suddenly, you have multiple entry points, conditional destinations, deep linking requirements, and the need to manage navigation state across different tabs or modal presentations. Your once serene regional airport transforms into a bustling international hub. How do you prevent navigational collisions and ensure every user "flight" reaches its intended gate smoothly? This is where robust navigation architecture becomes paramount. Let's explore the patterns and pitfalls within the SwiftUI navigation airspace.
    """ // Combined paragraphs

    // Article URL for sharing (replace with actual if available)
    let articleURL = URL(string: "https://example.com/swiftui-navigation")! // Replace with a real URL if possible

    var body: some View {
        NavigationStack {
            ScrollViewReader { scrollProxy in // Added ScrollViewReader
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Placeholder for the top image
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "airplane.departure") // Changed icon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray)
                            )
                            .id("top") // ID for scrolling

                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)

                        Text(title)
                            .font(.system(.largeTitle, design: .serif, weight: .bold)) // Using Serif for title
                            .padding(.horizontal)

                        // Display the full article text using the helper
                        Text(makeAttributedString(from: fullArticleText))
                            .font(.system(.body, design: .serif)) // Using Serif Design
                            .lineSpacing(6)
                            .padding(.horizontal)

                        Spacer(minLength: 20) // Add space before interaction bar

                        // --- Bottom Interaction Bar (Functional) ---
                        HStack(spacing: 20) {
                            Spacer()

                            // Clap Button
                            Button {
                                clapAction()
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: "hands.clap.fill") // Use filled icon for interaction
                                        .foregroundStyle(clapCount > 48 ? Color.orange : Color.gray) // Highlight if clapped
                                    Text("\(clapCount)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .contentTransition(.numericText(countsDown: false)) // Nice number animation
                                }
                            }
                            .buttonStyle(.plain) // Remove default button styling if needed

                            // Comments Button
                            Button {
                                showCommentsSheet = true
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: "bubble.left.fill") // Use filled icon
                                        .foregroundColor(.gray)
                                    Text("2") // Mock comment count
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .buttonStyle(.plain)

                            // Bookmark Button
                            Button {
                                toggleBookmark()
                            } label: {
                                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                    .foregroundColor(isBookmarked ? .blue : .gray) // Highlight if bookmarked
                            }
                            .buttonStyle(.plain)

                            // Share Button
                            Button {
                                showShareSheet = true
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.gray)
                            }
                            .buttonStyle(.plain)

                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                        .padding(.horizontal)
                        .padding(.bottom)

                    } // End VStack
                } // End ScrollView
                .sheet(isPresented: $showCommentsSheet) {
                    CommentsView()
                }
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(activityItems: [title, articleURL])
                }
                .actionSheet(isPresented: $showMoreOptionsSheet) {
                    ActionSheet(title: Text("More Options"), message: Text("Select an action for this article"), buttons: [
                        .default(Text("Copy Link")) { copyLink() },
                        .default(Text("View Author Profile")) { viewAuthorProfile() }, // Placeholder action
                        // .destructive(Text("Report Article")) { reportArticle() }, // Placeholder action
                        .cancel()
                    ])
                }
                 .onDisappear {
                    // Stop speech synthesizer if the view disappears
                    speechSynthesizer.stop()
                 }
            } // End ScrollViewReader
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Leading Button (Back Arrow)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // Use the environment dismiss action
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }

                // Trailing Buttons (Play/Stop and Ellipsis)
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        // Play/Stop Button
                        Button {
                            toggleSpeech()
                        } label: {
                            Image(systemName: speechSynthesizer.isSpeaking ? "stop.circle.fill" : "play.circle.fill") // Dynamic icon
                                .foregroundColor(speechSynthesizer.isSpeaking ? .red : .white) // Dynamic color
                        }

                        // Ellipsis Button
                        Button {
                            showMoreOptionsSheet = true // Trigger action sheet
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.bottom)) // Extend black background slightly
        }
    }

    // --- Action Functions ---

    func clapAction() {
        withAnimation(.spring()) { // Add animation
            clapCount += 1
        }
        // Provide haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func toggleBookmark() {
        isBookmarked.toggle()
        // Optionally add haptic feedback here too
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        // In a real app, you'd save this state (UserDefaults, CoreData, API call)
        print("Bookmark toggled: \(isBookmarked)")
    }

    func toggleSpeech() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stop()
        } else {
            // Speak the main content (title + body)
            let textToSpeak = "\(title). \(subtitle). \(fullArticleText)"
            speechSynthesizer.speak(text: textToSpeak)
        }
    }

    func copyLink() {
        UIPasteboard.general.string = articleURL.absoluteString
        print("Link copied: \(articleURL.absoluteString)")
        // Could add a small temporary confirmation message overlay
    }
    
    func viewAuthorProfile() {
        // Placeholder: In a real app, navigate to the author's profile view
        print("Navigate to author profile view")
    }
    
    func reportArticle() {
         // Placeholder: Present a reporting flow/interface
        print("Present report article flow")
    }

    // Helper Function for AttributedString (Minor update for clarity)
     func makeAttributedString(from string: String) -> AttributedString {
         var attributedString = AttributedString(string)
         let substringToFormat = "`NavigationDestination`"

         if let range = attributedString.range(of: substringToFormat) {
             attributedString[range].foregroundColor = .yellow // Or another distinguishing color
             attributedString[range].font = .system(.body, design: .monospaced).weight(.medium)
             attributedString[range].backgroundColor = .white.opacity(0.15) // Subtle background
             
             // Optional: Consider removing backticks visually if desired, but keep for matching.
             // This is more complex if multiple instances exist. For simplicity, we leave them.
         }
         
         return attributedString
     }
}

// --- Main App Body (No Change Needed) ---
struct Article_ContentView: View {
    var body: some View {
        TabView {
            ArticleView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            Text("Search Placeholder")
                 .preferredColorScheme(.dark) // Ensure dark mode for placeholders too
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            Text("Bookmarks Placeholder")
                 .preferredColorScheme(.dark)
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark.fill")
                }

            Text("Profile Placeholder")
                  .preferredColorScheme(.dark)
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
        }
        .preferredColorScheme(.dark) // Enforce dark mode for the whole TabView
    }
}

#Preview {
    Article_ContentView()
}
