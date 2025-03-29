////
////  CardDisplayView.swift
////  MyApp
////
////  Created by Cong Le on 3/28/25.
////
//
//import SwiftUI
//
//// MARK: - Data Model & Codable Color Helper
//
//// Helper struct to make SwiftUI.Color Codable
//struct ColorCodable: Codable, Hashable {
//    let red: Double
//    let green: Double
//    let blue: Double
//    let opacity: Double
//
//    // Initialize from SwiftUI Color
//    init(_ color: Color) {
//        // Use UIColor to reliably extract RGBA components
//        let uiColor = UIColor(color)
//        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
//        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
//
//        self.red = Double(r)
//        self.green = Double(g)
//        self.blue = Double(b)
//        self.opacity = Double(a)
//    }
//
//    // Convert back to SwiftUI Color
//    var color: Color {
//        Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
//    }
//}
//
//// Data structure for a single card
//struct CardData: Identifiable, Codable, Hashable {
//    let id: UUID // Conformance to Identifiable
//    var title: String
//    var subtitle: String
//    var tagText: String
//    var tagIconSystemName: String // Use SF Symbols system name
//    var gradientColors: [ColorCodable] // Array of codable colors
//    var isBookmarked: Bool = false
//
//    // Default initializer for convenience
//    init(id: UUID = UUID(), title: String, subtitle: String, tagText: String, tagIconSystemName: String, gradientUIColors: [UIColor], isBookmarked: Bool = false) {
//        self.id = id
//        self.title = title
//        self.subtitle = subtitle
//        self.tagText = tagText
//        self.tagIconSystemName = tagIconSystemName
//        // Convert UIColors to ColorCodable array
//        self.gradientColors = gradientUIColors.map { ColorCodable(Color($0)) }
//        self.isBookmarked = isBookmarked
//    }
//
//    // Note: Swift synthesizes Codable conformance here because all properties
//    // (including ColorCodable and UUID) are Codable.
//}
//
//// MARK: - Card View
//
//struct CardView: View {
//    // Use @Binding to allow modifications (like bookmark toggle) from this view
//    // that reflect back to the source of truth (the @State array in ContentView)
//    @Binding var cardData: CardData
//    var onBookmarkToggle: () -> Void // Action to perform when bookmark is toggled (e.g., save)
//
//    // Define colors based on CSS hex codes
//    let tagBackgroundColor = Color(red: 227/255, green: 255/255, blue: 249/255) // #e3fff9
//    let tagForegroundColor = Color(red: 145/255, green: 152/255, blue: 229/255) // #9198e5
//    let shadowBeige = Color(red: 190/255, green: 190/255, blue: 190/255) // #bebebe approximation
//    let shadowWhite = Color.white
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            // --- Top Gradient Area with Bookmark ---
//            ZStack(alignment: .topTrailing) {
//                // Gradient Background
//                LinearGradient(
//                    gradient: Gradient(colors: cardData.gradientColors.map { $0.color }),
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                // Height approx 50% of total 265px card height
//                .frame(height: 132)
//
//                // Bookmark Button
//                Button {
//                    // Toggle the bookmark state directly on the binding
//                    cardData.isBookmarked.toggle()
//                    // Call the provided action (likely saves data)
//                    onBookmarkToggle()
//                } label: {
//                    Image(systemName: cardData.isBookmarked ? "bookmark.fill" : "bookmark")
//                        .font(.system(size: 15)) // Size matches CSS svg roughly
//                        .foregroundColor(.white)
//                        .padding(8) // Make tappable area larger
//                        // Using background slightly different from CSS to fit standard shapes
//                        .background(Color.black.opacity(0.2))
//                        .clipShape(RoundedRectangle(cornerRadius: 8)) // Rounded rectangle like CSS
//                 }
//                .padding([.top, .trailing], 16) // Adjust padding to match visual placement
//            }
//            // Clip only the top corners for the gradient section
//            .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
//
//            // --- Bottom Text Content Area ---
//            VStack(alignment: .leading, spacing: 8) {
//                // Title Text (matches CSS h3)
//                Text(cardData.title)
//                    .font(.system(size: 16, weight: .semibold)) // Closer to CSS spec
//                    .foregroundColor(.primary) // Adapts to light/dark mode
//
//                // Subtitle Text (matches CSS p)
//                Text(cardData.subtitle)
//                    .font(.system(size: 13)) // Closer to CSS spec
//                    .foregroundColor(.secondary) // Standard secondary color
//
//                // Tag (matches CSS icon-box)
//                HStack(spacing: 8) {
//                    Image(systemName: cardData.tagIconSystemName)
//                         .font(.system(size: 15)) // Size matches CSS svg roughly
//
//                    Text(cardData.tagText)
//                        .font(.system(size: 13, weight: .medium)) // Closer to CSS span
//                }
//                .padding(.horizontal, 12)
//                .padding(.vertical, 8)
//                .background(tagBackgroundColor)
//                .foregroundColor(tagForegroundColor)
//                .clipShape(Capsule()) // Pill shape
//                .padding(.top, 10) // Space above the tag
//
//            }
//            .padding(20) // Consistent margin like CSS
//            // Ensure the VStack expands to fill remaining space
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//        }
//        .frame(width: 252, height: 265) // Fixed size like CSS
//        .background(Color(.systemBackground)) // Adapts to light/dark
//        .cornerRadius(30) // Overall card corner radius
//        // --- Neumorphic Shadow Approximation ---
//        // Outer darker shadow (bottom-right)
//        .shadow(color: shadowBeige.opacity(0.6), radius: 15, x: 15, y: 15)
//        // Outer lighter shadow (top-left)
//        .shadow(color: shadowWhite.opacity(0.9), radius: 15, x: -15, y: -15)
//    }
//}
//
//// Helper for rounding specific corners
//struct RoundedCorner: Shape {
//    var radius: CGFloat = .infinity
//    var corners: UIRectCorner = .allCorners
//
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        return Path(path.cgPath)
//    }
//}
//
//// MARK: - Content View (Main Screen & Data Management)
//
//struct ContentView: View {
//    // Source of truth for card data
//    @State private var cardItems: [CardData] = []
//    private let userDefaultsKey = "CardAppItems" // Key for UserDefaults
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                LazyVStack(spacing: 25) { // Use LazyVStack for efficiency if list grows
//                    // Loop through the indices to get access to the binding ($)
//                    ForEach($cardItems) { $itemData in
//                         CardView(cardData: $itemData, onBookmarkToggle: saveData)
//                    }
//                }
//                .padding() // Padding around the scrollable content
//            }
//            .navigationTitle("Learn") // Example title for the screen
//            .onAppear(perform: loadData) // Load data when the view appears
//            // Optional: Add a button to add new cards or refresh
//            // .navigationBarItems(trailing: Button("Add") { /* Add new card logic */ })
//        }
//        // Use light background for the ScrollView for better shadow visibility
//        .background(Color(.secondarySystemBackground).ignoresSafeArea())
//    }
//
//    // MARK: Data Persistence Functions
//
//    func loadData() {
//        // Try to load existing data from UserDefaults
//        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
//            let decoder = JSONDecoder()
//            // Attempt to decode the saved data
//            if let decoded = try? decoder.decode([CardData].self, from: data) {
//                self.cardItems = decoded
//                print("✅ Successfully loaded \(decoded.count) items from UserDefaults.")
//                return // Exit if loading was successful
//            } else {
//                 print("⚠️ Failed to decode data from UserDefaults. Loading defaults.")
//             }
//        } else {
//             print("ℹ️ No data found in UserDefaults. Loading defaults.")
//         }
//
//        // --- Load Default Data if loading failed or no data exists ---
//        self.cardItems = [
//            CardData(
//                title: "Meeting your Colleagues",
//                subtitle: "6 Video - 40 min",
//                tagText: "Business Trip",
//                tagIconSystemName: "airplane.departure", // Example SF Symbol
//                gradientUIColors: [
//                    // CSS: #e66465
//                    UIColor(red: 230/255, green: 100/255, blue: 101/255, alpha: 1.0),
//                    // CSS: #9198e5
//                    UIColor(red: 145/255, green: 152/255, blue: 229/255, alpha: 1.0)
//                ],
//                isBookmarked: false
//            ),
//              CardData(
//                title: "Onboarding Process",
//                subtitle: "3 Sections - 25 min",
//                tagText: "New Hire",
//                tagIconSystemName: "person.badge.plus",
//                 gradientUIColors: [
//                    UIColor.systemBlue,
//                    UIColor.systemPurple
//                ],
//                isBookmarked: true // Example bookmarked item
//            ),
//             CardData(
//                title: "Design Principles",
//                subtitle: "10 Articles - 1 hr",
//                tagText: "Creative",
//                tagIconSystemName: "paintpalette",
//                 gradientUIColors: [
//                    UIColor.systemOrange,
//                    UIColor.systemYellow
//                ],
//                isBookmarked: false
//            )
//            // Add more default CardData items here if needed
//        ]
//        print("Loaded default card data.")
//        // Save the default data immediately so it persists
//       saveData()
//    }
//
//    func saveData() {
//        let encoder = JSONEncoder()
//        // Attempt to encode the current cardItems array
//        if let encoded = try? encoder.encode(cardItems) {
//            // Save the encoded data to UserDefaults
//            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
//            print("✅ Successfully saved \(cardItems.count) items to UserDefaults.")
//        } else {
//             print("⚠️ Failed to encode card data for saving.")
//         }
//    }
//}
////
////// MARK: - App Entry Point
////
////@main
////struct CardDisplayApp: App {
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
