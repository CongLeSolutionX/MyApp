//
//  AccessibilityInSwiftUIView.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//


import SwiftUI
// Import AppIntents if you were creating a real widget with intent actions
// import AppIntents

// --- Data Models (Simplified) ---

struct Message: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var author: String
    var isRead: Bool = false
    var isFavorite: Bool = false
    var isSuperFavorite: Bool = false
}

struct Trip: Identifiable {
    let id = UUID()
    var description: String
    var imageName: String
    var rating: String? // e.g., "Half Star", "Full Star"
    var hasLocation: Bool = true
    var hasRecording: Bool = false
}

// For Drag & Drop Demo
//struct Sound: Identifiable, Transferable {
//    let id = UUID()
//    var name: String
//    var systemImageName: String
//
//    static var transferRepresentation: some TransferRepresentation {
//        CodableRepresentation(contentType: .audio) // Example content type
//    }
//}

struct Contact: Identifiable {
    let id = UUID()
    var name: String
    var alertSound1: String?
    var alertSound2: String?
    var alertSound3: String?
}

// For Widget Simulation
struct Beach: Identifiable {
    let id = UUID()
    var name: String
    var isFavorite: Bool = false
    // Add image, etc. if needed
}

// Placeholder for Widget App Intents (Full implementation requires more setup)
struct ToggleRatingIntent { //}: AppIntent { // Conformance needed for real widget
    var beach: Beach
    var rating: String // Simplified

    // init(beach: Beach, rating: String) { ... }
    // static var title: LocalizedStringResource = "Toggle Beach Rating"
    // func perform() async throws -> some IntentResult { ... }
}

struct ComposeIntent { //}: AppIntent { // Conformance needed for real widget
    enum ComposeType { case photo, message }
    var type: ComposeType

    // init(type: ComposeType) { ... }
    // static var title: LocalizedStringResource = "Compose"
    // func perform() async throws -> some IntentResult { ... }
}

// --- SwiftUI Views ---

struct ContentView: View {
    // State for interactivity
    @State private var isCommentsEnabled = false
    @State private var messages: [Message] = [
        Message(text: "Looks like a wonderful time!", author: "Nick", isRead: false, isFavorite: true),
        Message(text: "Absolutely beautiful", author: "Jack", isRead: true, isFavorite: false),
        Message(text: "Hope you wore sunscreen!", author: "Beth", isRead: false, isFavorite: true, isSuperFavorite: true)
    ]
    @State private var trips: [Trip] = [
        Trip(description: "It was a beautiful weekend! The waves were calm...", imageName: "beach_photo_1", rating: "Half Star", hasRecording: true),
        Trip(description: "Another sunny day at the coast.", imageName: "beach_photo_2", rating: nil)
    ]
    @State private var showAttachmentsTripId: UUID? = nil

    // Drag & Drop State
//    @State private var availableSounds: [Sound] = [
//        Sound(name: "Synth", systemImageName: "waveform.path.ecg"),
//        Sound(name: "Cheers", systemImageName: "music.mic"),
//        Sound(name: "Bells", systemImageName: "bell.fill")
//    ]
    @State private var contact = Contact(name: "Friend Name", alertSound1: "Bells", alertSound2: "Birds")

    // Widget Simulation State
    @State private var beaches: [Beach] = [
        Beach(name: "Funston Beach"),
        Beach(name: "Baker Beach", isFavorite: true),
        Beach(name: "Ocean Beach")
    ]

    var body: some View {
        NavigationView {
            List {

                // --- Section 1: Basic Accessibility & Styling ---
                Section("Basics & Styling") {
                    // SwiftUI provides default accessibility for standard controls
                    Toggle("Allow Comments", isOn: $isCommentsEnabled)
                        .accessibilityHint("Controls whether others can comment on your trips.")

                    Text("Using `.toggleStyle` modifies visuals but preserves the accessibility attributes (label, value, traits, actions) of the Toggle.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Toggle("Allow Comments (Custom Style)", isOn: $isCommentsEnabled)
                        .toggleStyle(PrettyToggleStyle()) // Visual change, accessibility remains
                }

                // --- Section 2: Improving Row Navigation (Combine) ---
                Section("Comment Row Navigation") {
                    Text("Problem: Default row has multiple focus stops.")
                        .font(.caption).foregroundStyle(.secondary)
                    ForEach($messages.indices, id: \.self) { index in
                        // Row BEFORE combination (for comparison - don't actually use this in prod)
                        CommentRowBasic(message: $messages[index])
                    }

                    Text("Solution: Use `.accessibilityElement(children: .combine)`")
                         .font(.caption).foregroundStyle(.secondary)
                         .padding(.top)
                    ForEach($messages.indices, id: \.self) { index in
                        // Row AFTER combination (Preferred approach)
                        CommentRowCombined(message: $messages[index])
                    }
                }

                // --- Section 3: Conditional Labels (Super Favorite) ---
                Section("Conditional Labels (iOS 18+)") {
                     Text("Button label changes conditionally based on `isSuperFavorite`, falling back to default.")
                        .font(.caption).foregroundStyle(.secondary)
                    // Example integrated into the combined row above (CommentRowCombined)
                    // Standalone Example:
                    ConditionalFavoriteButton(isFavorite: true, isSuperFavorite: true)
                    ConditionalFavoriteButton(isFavorite: true, isSuperFavorite: false)
                }

                // --- Section 4: Exposing Hidden Content (Hover Simulation) ---
                Section("Exposing 'Hover' Content") {
                    Text("Make actions normally shown on hover directly available.")
                       .font(.caption).foregroundStyle(.secondary)
                    ForEach(trips) { trip in
                        TripViewWithAccessibleAttachments(trip: trip, showAttachmentsTripId: $showAttachmentsTripId)
                    }
                }

                // --- Section 5: Appending Dynamic Label Info ---
                Section("Appending Dynamic Label Info") {
                    Text("Append optional info (like rating) to the main label.")
                       .font(.caption).foregroundStyle(.secondary)

                    ForEach(trips) { trip in
                        TripViewWithAppendedRating(trip: trip)
                    }
                }

                // --- Section 6: Accessible Drag & Drop Points ---
                Section("Accessible Drag & Drop Points") {
                     Text("Define specific drop zones for VoiceOver.")
                       .font(.caption).foregroundStyle(.secondary)

                    HStack {
//                        ForEach(availableSounds) { sound in
//                            SoundView(sound: sound)
//                        }
                        EmptyView()
                    }
                    AlertDropZoneView(contact: $contact)
                }

                 // --- Section 7: Widget Actions (Simulation) ---
                 Section("Widget Actions (App Intents - Simulated)") {
                    Text("Add custom actions to widget views using App Intents.")
                       .font(.caption).foregroundStyle(.secondary)
                    ForEach($beaches) { beach in
                         BeachListItemView(beach: beach)
                    }
                 }

            } // End List
            .navigationTitle("SwiftUI Accessibility")
        } // End NavigationView
    }
}

// --- Supporting Views & Styles ---

// MARK: - Basic Toggle Style
struct PrettyToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(configuration.isOn ? .green : .gray)
                .font(.title2)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}

// MARK: - Comment Row Views
struct UnreadIndicatorView: View {
    var isUnread: Bool

    var body: some View {
        Circle()
            .frame(width: 10, height: 10)
            .foregroundStyle(isUnread ? .blue : .clear)
            // Add label ONLY for the combined view, otherwise it adds an extra element
    }
}

// Basic Row (Less Accessible)
struct CommentRowBasic: View {
     @Binding var message: Message

     var body: some View {
        // VoiceOver reads: "Blue circle", "Message Text", "Favorite button", "Reply button" (4 stops)
         HStack {
             UnreadIndicatorView(isUnread: !message.isRead) // Visually shows unread
             VStack(alignment: .leading) {
                 Text(message.text)
                 Text(message.author).font(.caption).foregroundStyle(.secondary)
             }
             Spacer()
             Button { message.isFavorite.toggle() } label: { Image(systemName: message.isFavorite ? "star.fill" : "star") }
             Button { /* Reply action */ } label: { Image(systemName: "arrowshape.turn.up.left.fill") }
         }
         .opacity(message.isRead ? 0.5 : 1.0) // Visually dim if read
     }
}

// Combined Row (More Accessible)
@available(iOS 18.0, *)
struct CommentRowCombined: View {
    @Binding var message: Message

    var body: some View {
        HStack {
            // 1. Unread Indicator with Label & Automatic Hiding
            UnreadIndicatorView(isUnread: !message.isRead)
                .accessibilityLabel("Unread")
                // SwiftUI automatically hides element from AT when opacity is 0
                .opacity(message.isRead ? 0 : 1)

            VStack(alignment: .leading) {
                Text(message.text)
                Text(message.author).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            // 2. Buttons become actions on the combined element
            Button {
                // Toggle logic, potentially involving isSuperFavorite
                if message.isFavorite && !message.isSuperFavorite {
                    message.isSuperFavorite = true
                } else {
                    message.isFavorite.toggle()
                    message.isSuperFavorite = false // Reset super if unfavoriting
                }
            } label: {
                Image(systemName: message.isSuperFavorite ? "sparkles" : (message.isFavorite ? "star.fill" : "star"))
                    .foregroundStyle(message.isSuperFavorite ? .yellow : (message.isFavorite ? .orange : .gray))
            }
            // 3. Conditional Accessibility Label (iOS 18+)
            .accessibilityLabel(message.isSuperFavorite ? "Super Favorite" : (message.isFavorite ? "Favorite" : "Add Favorite"),
                                  // The `isEnabled` *could* be used here for more complex logic,
                                  // but a ternary often suffices for simple label text changes.
                                  // Example of conditional application:
                                  // .accessibilityLabel("Super Favorite", isEnabled: message.isSuperFavorite)
                                  // If NOT enabled, it falls back to default label ("Star", "Sparkles") or needs another label.
                                  // Thus, a dynamic label string is often clearer.
                                  isEnabled: true) // Always apply this dynamic label

            Button { /* Reply action */ } label: {
                Image(systemName: "arrowshape.turn.up.left.fill")
            } // Default "Reply" label is usually sufficient here
              // .accessibilityLabel("Reply to \(message.author)") // Could add context

        }
        // 4. Combine Children
        .accessibilityElement(children: .combine)
        // Can add overall hints/values to the combined element
        // .accessibilityHint("Double tap to toggle read status.") // Example hint
        .onTapGesture { // Example: Tap row to mark as read
             message.isRead.toggle()
        }
    }
}

// Standalone button for conditional label demo
struct ConditionalFavoriteButton: View {
    var isFavorite: Bool
    var isSuperFavorite: Bool

    var body: some View {
        if #available(iOS 18.0, *) {
            Button { /* Action */ } label: {
                Image(systemName: isSuperFavorite ? "sparkles" : (isFavorite ? "star.fill" : "star"))
                    .foregroundStyle(isSuperFavorite ? .yellow : (isFavorite ? .orange : .gray))
                    .padding()
            }
            .accessibilityLabel(isSuperFavorite ? "Super Favorite" : (isFavorite ? "Favorite" : "Add Favorite"),
                                isEnabled: true) // Dynamic label string better than relying on isEnabled + default
            .border(.gray)
        } else {
            // Fallback on earlier versions
        } // Just for visual separation
    }
}

// MARK: - Hover Simulation & Actions
struct TripViewBase: View {
    let trip: Trip
    var body: some View {
        HStack {
            Image(systemName: "photo") // Placeholder for trip.imageName
                 .resizable().scaledToFit().frame(width: 50, height: 50)
            Text(trip.description).lineLimit(2)
        }
    }
}

struct AttachmentButtonsView: View {
    let trip: Trip

    var body: some View {
        HStack {
             if trip.hasLocation {
                 Button { /* Show Location */ } label: { Label("Location", systemImage: "location.fill") }
             }
             if trip.hasRecording {
                 Button { /* Play Recording */ } label: { Label("Recording", systemImage: "waveform") }
             }
             // Rating might be shown elsewhere or added via label append
        }
        .buttonStyle(.bordered)
        .padding(5)
        .background(.thinMaterial, in: Capsule())
    }
}

struct TripViewWithAccessibleAttachments: View {
    let trip: Trip
    @Binding var showAttachmentsTripId: UUID? // Simulate hover state

    var body: some View {
        TripViewBase(trip: trip)
            .padding(.vertical, 4)
            // Simulate hover - tap to show/hide for iOS demo
            .onTapGesture {
                showAttachmentsTripId = (showAttachmentsTripId == trip.id) ? nil : trip.id
            }
            .overlay(alignment: .bottomTrailing) {
                if showAttachmentsTripId == trip.id {
                    AttachmentButtonsView(trip: trip)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .animation(.easeInOut, value: showAttachmentsTripId)
            // Crucial part: Make actions accessible directly
            .accessibilityActions {
                 // SwiftUI finds the Buttons inside this ViewBuilder
                 // and exposes their actions as custom actions on the TripViewBase element.
                 AttachmentButtonsView(trip: trip)
            }
            // Optional: Add a hint about available actions
            .accessibilityHint(trip.hasLocation || trip.hasRecording ? "Actions available: Location, Recording." : "")
    }
}

// MARK: - Appending Label Info
@available(iOS 18.0, *)
struct TripViewWithAppendedRating: View {
    let trip: Trip

    var body: some View {
        TripViewBase(trip: trip)
            .padding(.vertical, 4)
            // Append the rating string IF it exists
            .accessibilityLabel { existingLabel in // existingLabel is the label derived from TripViewBase
                if let rating = trip.rating {
                     Text(rating) // This text gets prepended
                     existingLabel // The original label content follows
                } else {
                     existingLabel // No rating, just use the original
                }
            }
    }
}

// MARK: - Drag & Drop Views
//struct SoundView: View {
////    let sound: Sound
//
//    var body: some View {
//        VStack {
//            Image(systemName: sound.systemImageName)
//                .font(.title)
//            Text(sound.name).font(.caption)
//        }
//        .padding()
//        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
//        // Make it draggable
//        .draggable(sound)
//        // Standard accessibility is often okay for the source
//        .accessibilityLabel(sound.name)
//        .accessibilityHint("Draggable sound")
//    }
//}

struct AlertDropZoneView: View {
     @Binding var contact: Contact
     // In a real app, you'd have a custom DropDelegate or use .dropDestination modifiers
     // This is simplified to just show the accessibility points

     var body: some View {
        Text("Drop Sounds for \(contact.name)")
            .font(.headline)
            .padding(.top)

        HStack(spacing: 20) {
            SoundDropTarget(label: "Sound 1", currentSound: contact.alertSound1)
            SoundDropTarget(label: "Sound 2", currentSound: contact.alertSound2)
            SoundDropTarget(label: "Sound 3", currentSound: contact.alertSound3)
        }
         .frame(maxWidth: .infinity)
         .padding()
         .background(.secondary, in: RoundedRectangle(cornerRadius: 10))
         // Here's the key: Defining specific points for AT
         // Points correspond roughly to the HStack elements visually
         .accessibilityElement(children: .contain) // Treat the whole area as one element initially
         .accessibilityLabel("Alert sounds for \(contact.name)")
         // Define specific logical drop points VoiceOver users can target
         .accessibilityDropPoint(.leading, description: "Set Alert Sound 1")
         .accessibilityDropPoint(.center, description: "Set Alert Sound 2")
         .accessibilityDropPoint(.trailing, description: "Set Alert Sound 3")
         // Add .dropDestination logic here to handle the actual drop
//         .dropDestination(for: Sound.self) { droppedSounds, location in
//             guard let sound = droppedSounds.first else { return false }
//             // Basic logic to determine which slot based on location (example only)
//             if location.x < 100 { contact.alertSound1 = sound.name }
//             else if location.x < 200 { contact.alertSound2 = sound.name }
//             else { contact.alertSound3 = sound.name }
//             return true // Indicate success
//         }
     }
}

struct SoundDropTarget: View {
    var label: String
    var currentSound: String?

    var body: some View {
        VStack {
             Text(label).font(.caption)
             Image(systemName: currentSound != nil ? "speaker.wave.2.fill" : "speaker.slash.fill")
                 .font(.title2)
                 .frame(height: 30)
             Text(currentSound ?? "Empty").font(.caption2).lineLimit(1)
        }
        .padding(10)
        .background(.background, in: RoundedRectangle(cornerRadius: 5))
        // Individual drop targets shouldn't be accessibility elements themselves
        // if the parent container defines drop points.
        .accessibilityHidden(true)
    }
}

// MARK: - Widget Simulation Views
struct BeachListItemView: View {
     @Binding var beach: Beach

     // Placeholders for intents
     var favoriteIntent: ToggleRatingIntent { ToggleRatingIntent(beach: beach, rating: "Favorite") }
     var composeIntent: ComposeIntent { ComposeIntent(type: .photo) }

     var body: some View {
        HStack {
             Text(beach.name)
             Spacer()
             if beach.isFavorite {
                 Image(systemName: "heart.fill").foregroundStyle(.red)
             }
             // Example interactive button (using AppIntent in real widget)
             Button {
                 // Action simulate toggling favorite - in real widget, intent handles this
                 beach.isFavorite.toggle()
             } label: {
                 Image(systemName: beach.isFavorite ? "star.slash.fill" : "star.fill")
             }
             // .buttonStyle(.plain) // Standard widget button style
             // .labelStyle(.iconOnly) // Standard widget button style
             // .widgetAction(FavoriteIntent(beach: beach)) // Real widget action
        }
        // Add custom accessibility actions using Intents
//        .accessibilityAction(
//             named: beach.isFavorite ? "Unfavorite" : "Favorite", // Dynamic name
//             favoriteIntent // Provide the *intent instance*
//        )
//        .accessibilityAction(
//             .magicTap, // Standard system action type
//             composeIntent // Provide the *intent instance*
//        )
//        .accessibilityHint("Double tap with two fingers to compose.") // Hint for magic tap
     }
}

// MARK: - Preview
#Preview {
    ContentView()
}
