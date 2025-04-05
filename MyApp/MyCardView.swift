//
//  MyCardView.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI

// Custom Color definition for Starbucks Green
extension Color {
//    static let starbucksGreen = Color(red: 0.0, green: 112/255, blue: 74/255) // Official RGB approximation
//    static let starbucksDarkGreen = Color(red: 0.0, green: 98/255, blue: 61/255) // Darker shade for pressed states or accents
    static let appBackground = Color(.systemGroupedBackground) // Standard background
}

// Reusable Button Style for the main action buttons
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? Color.starbucksDarkGreen : Color.starbucksGreen)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .shadow(radius: 3, y: 2)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// View representing the content of the "My Card" screen
struct MyCardViewContent: View {
    @State private var isDefaultStoreCard = true
    @State private var showAutoReloadSheet = false // Placeholder state

    var body: some View {
        VStack(spacing: 0) {
            // Card Info Section
            HStack(alignment: .center, spacing: 16) {
                Image("My-meme-original") // Replace with your actual card image asset
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .background(Color.gray.opacity(0.3)) // Placeholder background
                     .overlay(
                        Image("My-meme-original") // Replace with logo asset if needed separately
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(5)
                            .background(.white.opacity(0.8))
                            .clipShape(Circle())
                            .offset(x: 40, y: -25), // Approximate positioning
                        alignment: .topTrailing
                     )
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text("$15.11")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)

                    HStack(spacing: 8) {
                        Text("as of 1d ago")
                             .font(.caption)
                             .foregroundColor(.secondary)
                        Button {
                            // Action to refresh balance
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Spacer() // Push content to the left
            }
            .padding()
            .background(Color.appBackground) // Background for this section

            Divider()

            // Actions List
            List {
                // Make in store default
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.secondary)
                    Text("Make in store default")
                        .foregroundColor(.primary)
                    Spacer()
                    Toggle("", isOn: $isDefaultStoreCard)
                        .labelsHidden()
                        .tint(.starbucksGreen) // Color the toggle when 'on'
                }

                // Auto reload
                HStack {
                    Image(systemName: "arrow.clockwise.circle")
                         .foregroundColor(.secondary)
                    Text("Auto reload")
                        .foregroundColor(.primary)
                    Spacer()
                    Button("Turn on") {
                        showAutoReloadSheet = true // Example action
                    }
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundColor(.starbucksGreen)
                    .overlay(
                        Capsule().stroke(Color.starbucksGreen, lineWidth: 1.5)
                    )
                }

                // Transfer balance
                HStack {
                    Image(systemName: "arrow.left.arrow.right")
                        .foregroundColor(.secondary)
                    Text("Transfer balance")
                        .foregroundColor(.primary)
                    Spacer()
                    // Potentially add chevron or navigation link if it goes somewhere
                }

                // Add to Apple Wallet
                HStack {
                    Image(systemName: "wallet.pass") // Or a custom wallet icon
                        .foregroundColor(.secondary)
                    Text("Add to Apple Wallet")
                        .foregroundColor(.primary)
                    Spacer()
                     // Potentially add chevron or navigation link if it goes somewhere
                }

                // Remove card
                HStack {
                    Image(systemName: "minus.circle")
                        .foregroundColor(.red) // Indicate destructive action
                    Text("Remove card")
                        .foregroundColor(.red) // Indicate destructive action
                    Spacer()
                    // Potentially add chevron or navigation link if it goes somewhere
                }
            }
            .listStyle(.plain) // Use plain style for tighter layout, closer to screenshot

            Spacer() // Pushes the button to the bottom

            // Add Funds Button
            Button("Add funds") {
                // Action for adding funds
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
            .padding(.bottom, 8) // Adjust padding as needed near safe area

        }
        .background(Color.appBackground.ignoresSafeArea()) // Extend background
        .navigationTitle("My Card 7668") // Set the title
        .navigationBarTitleDisplayMode(.large) // Match the large title style
         .sheet(isPresented: $showAutoReloadSheet) {
             // Placeholder: View for Auto Reload settings
             Text("Auto Reload Settings Screen")
         }
    }
}

// Helper view to embed the content in a NavigationView for use within TabView
struct MyCardViewEmbedded: View {
    var body: some View {
        NavigationView {
            MyCardViewContent()
        }
        // Consider adding .navigationViewStyle(.stack) if needed for specific behaviors
    }
}

// Main ContentView hosting the TabView
struct MyCardView: View {
    @State private var selectedTab = 1 // Scan tab is initially selected

    // Initialize appearance settings once
    init() {
       let appearance = UITabBarAppearance()
       appearance.configureWithOpaqueBackground()
       appearance.backgroundColor = UIColor.systemBackground // Or a custom color

       // Apply colors for selected/unselected states
       appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.starbucksGreen)
       appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.starbucksGreen)]
       appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
       appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]

       UITabBar.appearance().standardAppearance = appearance
       UITabBar.appearance().scrollEdgeAppearance = appearance // Needed for iOS 15+ large titles
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Home Tab") // Placeholder
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            MyCardViewEmbedded() // Embed the actual card view here
                .tabItem {
                    Label("Scan", systemImage: "qrcode.viewfinder")
                }
                .tag(1)

            Text("Order Tab") // Placeholder
                .tabItem {
                    Label("Order", systemImage: "cup.and.saucer.fill") // SF Symbol for cup
                }
                .tag(2)

            Text("Gift Tab") // Placeholder
                .tabItem {
                    Label("Gift", systemImage: "gift.fill")
                }
                .tag(3)

            Text("Offers Tab") // Placeholder
                .tabItem {
                    Label("Offers", systemImage: "star.fill")
                }
                .tag(4)
        }
        // .accentColor(.starbucksGreen) // Can be used, but TabBarAppearance offers more control now
    }
}

// Preview Provider
struct MyCardViewContent_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview the main content screen directly
            MyCardViewContent()
                .previewDisplayName("Card Content Only")

            // Preview the full app structure with TabView
            MyCardView()
                .previewDisplayName("Full App with TabView")
        }
        // Add placeholder assets for preview if needed
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext) // Example for CoreData
    }
}

// Placeholder for Asset names (replace these with your actual asset names in your project)
// Image("starbucks-card-art")
// Image("starbucks-logo-small")
//
//// Placeholder for PersistenceController if using CoreData
//struct PersistenceController {
//    static let preview = PersistenceController(inMemory: true)
//    let container: NSPersistentCloudKitContainer // Example type
//
//    init(inMemory: Bool = false) {
//        container = NSPersistentCloudKitContainer(name: "YourAppName") // Replace with your model name
//        if inMemory {
//            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
//        }
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        container.viewContext.automaticallyMergesChangesFromParent = true
//    }
//}
