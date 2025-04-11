////
////  SnapchatMapsDetailView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/11/25.
////
//
//import SwiftUI
//
//// MARK: - Data Model (Remains the same)
//
//struct PlaceInfo: Identifiable { // Conforms to Identifiable for .sheet
//    let id = UUID() // Required for Identifiable
//    let imageName: String
//    let name: String
//    let type: String
//    let status: String
//    let distance: String
//    let location: String
//    var initialLikeCount: Int // Renamed for clarity
//    let driveTime: String
//    let galleryImageNames: [String]
//}
//
//// MARK: - Main Application View (Entry Point)
//
//// If using the App protocol (iOS 14+)
//// @main
//// struct SnapchatMapsApp: App {
////     var body: some Scene {
////         WindowGroup {
////             MainContentView()
////         }
////     }
//// }
//
//// For demonstration, we'll use this as the root view.
//struct MainContentView: View {
//    @State private var selectedTab: Tab = .map // Default tab
//
//    // Mock data for the place - can be loaded from a ViewModel in a real app
//    let mockPlace = PlaceInfo(
//        imageName: "My-meme-original",
//        name: "DD Cafe",
//        type: "Coffee Shop",
//        status: "Closed",
//        distance: "2.6 miles",
//        location: "Garden Grove, CA",
//        initialLikeCount: 17,
//        driveTime: "9 min",
//        galleryImageNames: ["My-meme-orange_2", "My-meme-heineken", "My-meme-red-wine-glass", "My-meme-original"]
//    )
//
//    // State to control sheet presentation
//    @State private var presentingPlace: PlaceInfo? = nil
//
//    var body: some View {
//        TabView(selection: $selectedTab) {
//            MapTabView(presentingPlace: $presentingPlace, placeToShow: mockPlace)
//                .tabItem {
//                    Label("Map", systemImage: "location.fill")
//                }
//                .tag(Tab.map)
//
//            PlaceholderTabView(title: "Chat", iconName: "message.fill")
//                .tabItem {
//                    Label("Chat", systemImage: "message.fill")
//                }
//                .tag(Tab.chat)
//                // Example Badge (count would come from a data source)
//                .badge(3)
//
//           PlaceholderTabView(title: "Camera", iconName: "camera.fill")
//                .tabItem {
//                     Label("Camera", systemImage: "camera.fill")
//                     // Note: TabItems usually don't have complex views,
//                     // the actual camera UI would be presented modally.
//                }
//                .tag(Tab.camera)
//
//            PlaceholderTabView(title: "Friends", iconName: "person.2.fill")
//                .tabItem {
//                    Label("Friends", systemImage: "person.2.fill")
//                }
//                .tag(Tab.friends)
//
//            PlaceholderTabView(title: "Stories", iconName: "play.rectangle.fill")
//                .tabItem {
//                     Label("Stories", systemImage: "play.rectangle.fill")
//                     // For notification dots, you often need custom tab bar views
//                     // or overlay techniques, as native badges are numeric/text.
//                     // Simulating with standard Label here.
//                }
//                .tag(Tab.stories)
//                .badge("!") // Simulate update with a character
//        }
//        // Use the item identifier version of .sheet
//        .sheet(item: $presentingPlace) { place in
//            // Pass a binding to control presentation from within the sheet
//            PlaceDetailSheetView(place: place, isPresented: $presentingPlace)
//             // Optional: Customize sheet presentation detents (iOS 15+)
//              .presentationDetents([.medium, .large])
//        }
//         .onAppear {// Optional: Customize Tab Bar appearance if needed
//             let appearance = UITabBarAppearance()
//             appearance.configureWithOpaqueBackground()
//             appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9) // Example material-like effect
//             UITabBar.appearance().standardAppearance = appearance
//             UITabBar.appearance().scrollEdgeAppearance = appearance
//         }
//    }
//}
//
//// Enum for Tab Identification
//enum Tab {
//    case map, chat, camera, friends, stories
//}
//
//// MARK: - Tab Content Views
//
//struct MapTabView: View {
//    @Binding var presentingPlace: PlaceInfo?
//    let placeToShow: PlaceInfo // The specific place this map view can show
//
//    var body: some View {
//        ZStack {
//            // Map Placeholder remains visual background
//            MapViewPlaceholder()
//                .ignoresSafeArea()
////            RealMapView()
////                .ignoresSafeArea()
//            // Example Button on the map to trigger the detail sheet
//            VStack {
//                Spacer() // Push button down
//                Button {
//                    presentingPlace = placeToShow // Trigger the sheet
//                } label: {
//                    Text("Show \(placeToShow.name) Details")
//                        .padding()
//                        .background(.blue)
//                        .foregroundColor(.white)
//                        .clipShape(Capsule())
//                        .shadow(radius: 5)
//                }
//                .padding(.bottom, 80) // Ensure it's above the tab bar area
//            }
//        }
//    }
//}
//
//struct PlaceholderTabView: View {
//    let title: String
//    let iconName: String
//
//    var body: some View {
//        ZStack {
//            Color(.systemGray6).ignoresSafeArea() // Different background for clarity
//            VStack {
//                 Image(systemName: iconName)
//                    .font(.system(size: 50, weight: .light))
//                    .foregroundColor(.gray)
//                 Text(title)
//                    .font(.largeTitle)
//                    .foregroundColor(.gray)
//            }
//        }
//    }
//}
//
////// Map View Placeholder (remains simple)
////struct MapViewPlaceholder: View {
////    var body: some View {
////        Color.gray.opacity(0.3)
////            .overlay(
////                Text("Interactive Map Area Placeholder")
////                    .foregroundColor(.white)
////                    .padding(5)
////                    .background(.black.opacity(0.5))
////                    .cornerRadius(5)
////            )
////    }
////}
//
//// MARK: - Place Detail Sheet (Enhanced with State & Actions)
//
//struct PlaceDetailSheetView: View {
//    let place: PlaceInfo
//    @Binding var isPresented: PlaceInfo? // Use the bound PlaceInfo? to dismiss
//
//    // Internal state for the sheet's content
//    @State private var isLiked: Bool = false // Initial like state (could be loaded)
//    @State private var currentLikeCount: Int
//    @State private var showingTagAlert = false
//    @State private var showingDirectionsAlert = false
//    @State private var showingGalleryAlert = false
//    @State private var selectedGalleryItemName: String? = nil
//
//    // Initialize internal state from the passed place data
//    init(place: PlaceInfo, isPresented: Binding<PlaceInfo?>) {
//        self.place = place
//        self._isPresented = isPresented // Connect binding
//        self._currentLikeCount = State(initialValue: place.initialLikeCount)
//        // In a real app, `isLiked` might also be part of `PlaceInfo` or fetched
//    }
//
//    var body: some View {
//        NavigationView { // Wrap in NavigationView for potential future navigation inside sheet
//            VStack(spacing: 0) {
//                // Handle is purely visual, sheet dragging is handled by the system
//                HandleIndicator()
//                    .padding(.vertical, 5)
//
//                ScrollView { // Make content scrollable if it exceeds screen height
//                     VStack(alignment: .leading, spacing: 15) {
//                        HeaderSection(place: place) {
//                            // Dismiss action for the close button
//                            isPresented = nil
//                        }
//                        TagButton {
//                            // Action for Tag button
//                            showingTagAlert = true
//                        }
//                        ActionsRow(
//                            isLiked: $isLiked,
//                            likeCount: $currentLikeCount,
//                            driveTime: place.driveTime,
//                            likeAction: {
//                                // Toggle like state and update count
//                                isLiked.toggle()
//                                currentLikeCount += isLiked ? 1 : -1
//                                print("Like button toggled. Liked: \(isLiked), Count: \(currentLikeCount)")
//                            },
//                            directionsAction: {
//                                showingDirectionsAlert = true
//                            }
//                        )
//                        GalleryScrollView(imageNames: place.galleryImageNames) { imageName in
//                             // Action when gallery item is tapped
//                             selectedGalleryItemName = imageName
//                             showingGalleryAlert = true
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.bottom)
//                }
//            }
//            .background(Color(.systemBackground)) // Use system background
//            .cornerRadius(20) // Rounded corners still look good, sheet handles edges
//            .navigationBarHidden(true) // Hide the default NavigationView bar
//            // Alerts triggered by button actions
//            .alert("Tag Place", isPresented: $showingTagAlert, actions: {
//                Button("OK", role: .cancel) { }
//            }, message: {
//                Text("You tapped the tag button for \(place.name). In a real app, this would open a tagging interface.")
//            })
//            .alert("Get Directions", isPresented: $showingDirectionsAlert, actions: {
//                 Button("Open Maps", role: .destructive) { print("Opening Maps for \(place.name)...") }
//                 Button("Cancel", role: .cancel) { }
//            }, message: {
//                 Text("Get directions to \(place.name)?")
//            })
//            .alert("View Image", isPresented: $showingGalleryAlert, actions: {
//                  Button("OK", role: .cancel) { }
//            }, message: {
//                  Text("You tapped on gallery image: \(selectedGalleryItemName ?? "Unknown"). A detail view or image viewer would open here.")
//            })
//            // Optional: Add swipe down to dismiss gesture if needed manually (usually automatic with .sheet)
//        }
//         // Prevent NavigationView from adding extra space at top if content isn't scrollable initially
//         .edgesIgnoringSafeArea(.top) // Use with caution, might conflict with Handle area
//    }
//}
//
//// Handle Indicator (unchanged)
//struct HandleIndicator: View {
//    var body: some View {
//        RoundedRectangle(cornerRadius: 2.5)
//            .fill(Color.gray.opacity(0.5))
//            .frame(width: 40, height: 5)
//    }
//}
//
//// MARK: - Detail Sheet Components (with Actions/Bindings)
//
//struct HeaderSection: View {
//    let place: PlaceInfo
//    let closeAction: () -> Void // Closure to dismiss the sheet
//
//    var body: some View {
//        HStack(alignment: .center, spacing: 12) {
//            Image(place.imageName)
//                .resizable()
//                .scaledToFill()
//                .frame(width: 60, height: 60)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.blue.opacity(0.5), lineWidth: 3))
//                .overlay(Circle().stroke(Color.white, lineWidth: 1))
//                .accessibilityLabel("\(place.name) profile picture")
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text(place.name)
//                    .font(.title2)
//                    .fontWeight(.bold)
//                Text(place.type)
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                Text("\(place.status) • \(place.distance) • \(place.location)")
//                    .font(.caption)
//                    .foregroundColor(place.status == "Closed" ? .red : .gray)
//            }
//
//            Spacer()
//
//            CloseButton(action: closeAction)
//        }
//    }
//}
//
//struct CloseButton: View {
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            Image(systemName: "xmark")
//                .font(.system(size: 14, weight: .bold))
//                .foregroundColor(.primary)
//                .padding(8)
//                .background(Color(.systemGray5))
//                .clipShape(Circle())
//        }
//        .accessibilityLabel("Close details")
//    }
//}
//
//struct TagButton: View {
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack {
//                Image(systemName: "plus")
//                Text("Tag this place")
//            }
//            .font(.footnote)
//            .fontWeight(.medium)
//            .foregroundColor(.primary)
//            .padding(.horizontal, 12)
//            .padding(.vertical, 8)
//            .background(Color(.systemGray6))
//            .clipShape(Capsule())
//        }
//        .buttonStyle(.plain)
//        .accessibilityHint("Opens interface to add tags")
//    }
//}
//
//struct ActionsRow: View {
//    @Binding var isLiked: Bool
//    @Binding var likeCount: Int
//    let driveTime: String
//
//    let likeAction: () -> Void
//    let directionsAction: () -> Void
//    // Add action for drive time if needed
//
//    var body: some View {
//        HStack(spacing: 10) {
//            // Like Button
//            Button(action: likeAction) {
//                HStack(spacing: 5) {
//                    Image(systemName: isLiked ? "heart.fill" : "heart")
//                        .foregroundColor(isLiked ? .red : .primary) // Change color when liked
//                    Text("\(likeCount)") // Display dynamic count
//                }
//                .font(.subheadline)
//                .fontWeight(.medium)
//                .foregroundColor(.primary)
//                .padding(.horizontal, 15)
//                .padding(.vertical, 10)
//                .background(Color(.systemGray5))
//                .clipShape(Capsule())
//            }
//            .buttonStyle(.plain)
//            .accessibilityLabel(isLiked ? "Unlike place" : "Like place")
//            .accessibilityValue("\(likeCount) likes")
//
//            // Drive Time Button (Simulates tapping for more info/route)
//            Button {
//                 print("Drive time tapped - potentially show traffic or details")
//                 // Could trigger another alert or action
//            } label: {
//                HStack(spacing: 5) {
//                    Image(systemName: "car.fill")
//                    Text(driveTime)
//                 }
//                 .font(.subheadline)
//                 .fontWeight(.medium)
//                 .foregroundColor(.primary)
//                 .padding(.horizontal, 15)
//                 .padding(.vertical, 10)
//                 .background(Color(.systemGray5))
//                 .clipShape(Capsule())
//            }
//             .buttonStyle(.plain)
//             .accessibilityLabel("Estimated drive time")
//             .accessibilityValue(driveTime)
//
//            Spacer() // Push directions button to the right
//
//            DirectionsButton(action: directionsAction)
//        }
//    }
//}
//
//struct DirectionsButton: View {
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill") // More representative SFSymbol
//                .font(.title3)
//                 .foregroundColor(.white)
//                 .padding(.horizontal, 25)
//                 .padding(.vertical, 10)
//                 .background(Color.blue)
//                .clipShape(Capsule())
//         }
//        .buttonStyle(.plain)
//        .accessibilityLabel("Get directions")
//    }
//}
//
//struct GalleryScrollView: View {
//    let imageNames: [String]
//    let itemAction: (String) -> Void // Closure when an item is tapped
//
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 10) {
//                ForEach(imageNames, id: \.self) { imageName in
//                    GalleryItem(imageName: imageName)
//                        .onTapGesture {
//                            itemAction(imageName) // Call the action closure
//                        }
//                }
//            }
//        }
//        .frame(height: 200) // Maintain fixed height
//    }
//}
//
//struct GalleryItem: View {
//    let imageName: String
//
//    var body: some View {
//        ZStack(alignment: .bottomLeading) { // Align text to bottom leading
//             Image(imageName) // Use placeholder name
//                .resizable()
//                .scaledToFill() // Changed to fill for potentially different aspect ratios
//                .frame(width: 120, height: 200)
//                .cornerRadius(10)
//                .clipped()
//                .accessibilityLabel("Gallery image") // Generic label
//
//            // Dark gradient for better text visibility
//            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
//                           startPoint: .center, endPoint: .bottom)
//                 .cornerRadius(10) // Match image corner radius
//
//            // Placeholder for tags/info overlay
//             Text("garden") // Example tag
//                .font(.caption)
//                .fontWeight(.bold)
//                .foregroundColor(.white)
//                .padding(.vertical, 4)
//                .padding(.horizontal, 8)
//                .background(Color.black.opacity(0.0)) // Transparent background now, relies on gradient
//                .clipShape(Capsule())
//                .padding(8) // Padding from the edges
//                .accessibilityHidden(true) // Hide decorative text from accessibility if needed
//        }
//    }
//}
//
//// MARK: - Preview Provider
//
//struct MainContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainContentView()
//    }
//}
//
//// MARK: - Placeholder Images (Add to Assets.xcassets)
///*
// Create placeholder images in your Assets.xcassets named:
// - "dd-cafe-profile" (ideally circular or square)
// - "gallery1"
// - "gallery2"
// - "gallery3"
// - "gallery4"
// (Or use system images / Color rectangles if you don't want to add assets)
//
// Example using system image if assets aren't available:
// Image(systemName: "photo.fill") // Replace Image(place.imageName) / Image(imageName)
//     .resizable()
//     .scaledToFit()
//     .frame(width: 60, height: 60) // Adjust frame as needed
//     .foregroundColor(.secondary)
//     .padding()
//     .background(Color.gray.opacity(0.2))
// */
