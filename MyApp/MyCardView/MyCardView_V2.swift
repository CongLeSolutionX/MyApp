//
//  MyCardView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/5/25.
//

import SwiftUI
import CoreData // Added for PersistenceController example

// Custom Color definition for Starbucks Green
extension Color {
//    static let starbucksGreen = Color(red: 0.0, green: 112/255, blue: 74/255) // Official RGB approximation
//    static let starbucksDarkGreen = Color(red: 0.0, green: 98/255, blue: 61/255) // Darker shade for pressed states or accents
    static let appBackground = Color(.systemGroupedBackground) // Standard background
    static let sheetBackground = Color(.secondarySystemGroupedBackground) // Slightly different for sheet maybe
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

// MARK: - Add Funds Sheet View

struct AddFundsSheetView: View {
    @Environment(\.dismiss) var dismiss // To close the sheet

    // State for selections within the sheet
    @State private var selectedCardBalance = "$15.11" // Example data
    @State private var selectedAmount = 25.00
    @State private var selectedPaymentMethod = "PayPal"
    @State private var isAutoReloadOn = false

    let amounts = [10.00, 15.00, 20.00, 25.00, 50.00, 75.00, 100.00] // Example reload amounts

    var formattedAmount: String {
        String(format: "$%.2f", selectedAmount)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Sheet Title Area
            Text("Add money to Starbucks Card")
                .font(.headline)
                .padding(.top, 20) // Add padding from the top edge
                 .padding(.bottom, 10)

            Divider()

            // Selection Rows
            VStack(spacing: 0) {
                // Select Card Row
                SelectionRow(
                    label: "Starbucks Card",
                    value: selectedCardBalance,
                    iconName: "starbucks-card-art-small" // Use a smaller version of card art
                ) {
                    // Action to change card (e.g., navigate or show picker)
                    print("Change Card Tapped")
                }

                Divider().padding(.leading, 16) // Indent divider

                // Select Amount Row
                AmountSelectionRow(
                    label: "Amount",
                    selectedValue: $selectedAmount, // Pass binding
                    options: amounts
                ) {
                    // Action handled by Picker within AmountSelectionRow
                    print("Amount Changed")
                }

                Divider().padding(.leading, 16)

                // Select Payment Row
                SelectionRow(
                    label: "Payment",
                    value: selectedPaymentMethod,
                    iconName: "paypal-logo" // Use PayPal logo asset
                ) {
                    // Action to change payment method
                    print("Change Payment Tapped")
                }

            }
            .padding(.vertical) // Add some vertical padding around the rows

             Divider() // Divider before Auto Reload

            // Auto Reload Toggle
            HStack {
                Text("Auto reload")
                    .font(.body)
                Spacer()
                Toggle("", isOn: $isAutoReloadOn)
                    .labelsHidden()
                    .tint(.starbucksGreen) // Standard green for toggle doesn't match screenshot exactly
                                           // May need custom toggle or use system default gray
            }
            .padding()

            Spacer() // Push button to bottom

            // Add Amount Button
            Button("Add \(formattedAmount)") {
                // Action to perform the reload
                print("Adding \(formattedAmount) using \(selectedPaymentMethod)")
                dismiss() // Close the sheet after action
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
            .padding(.bottom, 20) // Padding from bottom safe area
        }
         // .background(Color.sheetBackground.ignoresSafeArea()) // Background for the sheet
         // Standard sheet background usually works well. Use this if needed.
    }
}

// MARK: - Reusable Row Components for Sheet

// Generic Row for Card and Payment Selection
struct SelectionRow: View {
    let label: String
    let value: String
    let iconName: String // Asset name for the icon/image
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 25) // Adjust size as needed
                    .cornerRadius(4)
                    .background(Color.gray.opacity(0.1)) // Placeholder bg

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(value)
                        .font(.body.weight(.medium)) // Make value slightly bolder
                        .foregroundColor(.primary)
                }

                Spacer()

                Image(systemName: "chevron.down")
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
             .padding(.vertical, 8) // Adjust vertical padding
            .contentShape(Rectangle()) // Ensure whole HStack is tappable
        }
        .buttonStyle(.plain) // Use plain style to avoid default button visuals
    }
}

// Specific Row for Amount Selection using a Picker
struct AmountSelectionRow: View {
    let label: String
    @Binding var selectedValue: Double
    let options: [Double]
    let action: () -> Void

    var body: some View {
         HStack(spacing: 12) {
            // No icon for amount row
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Use Picker for selection, styled subtly
                 Picker(label, selection: $selectedValue) {
                     ForEach(options, id: \.self) { amount in
                         Text(String(format: "$%.2f", amount)).tag(amount)
                     }
                 }
                 .pickerStyle(.menu) // Use a menu style picker
                  .labelsHidden() // Hide the default picker label
                 .accentColor(.primary) // Use primary color for the picker text
                 .onChange(of: selectedValue) { _ in // Use specific onChange for iOS 14+
                     action() // Perform action when selection changes
                 }
                 .frame(maxWidth: .infinity, alignment: .leading) // Expand picker text area
                 .padding(.leading, -6) // Adjust picker text alignment

            }

            Spacer()

            // Chevron is part of the Picker(style: .menu) visually
        }
        .padding(.horizontal)
         .padding(.vertical, 8)
    }
}

// MARK: - My Card View Content (Updated)

struct MyCardViewContent: View {
    @State private var isDefaultStoreCard = true
    @State private var showAutoReloadSheet = false
    @State private var showAddFundsSheet = false // Add state for the new sheet

    var body: some View {
        VStack(spacing: 0) {
            // --- Card Info Section (Unchanged) ---
            HStack(alignment: .center, spacing: 16) {
                Image("starbucks-card-art") // Replace with your actual card image asset
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .background(Color.gray.opacity(0.3)) // Placeholder background
                     .overlay(
                        Image("starbucks-logo-small") // Replace with logo asset if needed separately
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

            // --- Actions List (Unchanged) ---
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
            .listStyle(.plain)

            Spacer() // Pushes the button to the bottom

            // --- Add Funds Button (Updated Action) ---
            Button("Add funds") {
                showAddFundsSheet = true // Set state to true to show the sheet
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
            .padding(.bottom, 8)

        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("My Card 7668")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAutoReloadSheet) {
             // Placeholder: View for Auto Reload settings
             Text("Auto Reload Settings Screen")
         }
         // --- Add the new sheet modifier ---
        .sheet(isPresented: $showAddFundsSheet) {
            AddFundsSheetView()
                // PresentationDetents modifier for iOS 16+ to control sheet height
                 // .presentationDetents([.medium, .large]) // Example: Allow medium and large heights
                .presentationDetents([.height(400)]) // Example: Fixed height - adjust as needed
                                                     // Or use .medium() for a default half-screen height
        }
    }
}

// MARK: - Helper view to embed (Unchanged)
struct MyCardViewEmbedded: View {
    var body: some View {
        NavigationView {
            MyCardViewContent()
        }
    }
}

// MARK: - Main ContentView hosting the TabView (Unchanged)
struct MyCardView: View {
    @State private var selectedTab = 1 // Scan tab is initially selected

    init() {
       let appearance = UITabBarAppearance()
       appearance.configureWithOpaqueBackground()
       appearance.backgroundColor = UIColor.systemBackground

       appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.starbucksGreen)
       appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.starbucksGreen)]
       appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
       appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]

       UITabBar.appearance().standardAppearance = appearance
       UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Home Tab") // Placeholder
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            MyCardViewEmbedded() // Embed the actual card view here
                .tabItem { Label("Scan", systemImage: "qrcode.viewfinder") }
                .tag(1)

            Text("Order Tab") // Placeholder
                 .tabItem { Label("Order", systemImage: "cup.and.saucer.fill") }
                .tag(2)

            Text("Gift Tab") // Placeholder
                .tabItem { Label("Gift", systemImage: "gift.fill") }
                .tag(3)

            Text("Offers Tab") // Placeholder
                 .tabItem { Label("Offers", systemImage: "star.fill") }
                .tag(4)
        }
    }
}

// MARK: - Preview Provider (Updated)
struct MyCardViewContent_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview the main content screen directly
            MyCardViewContent()
                .previewDisplayName("Card Content Only")

            // Preview the full app structure with TabView
            MyCardView()
                .previewDisplayName("Full App with TabView")

            // Preview the Add Funds Sheet directly
            AddFundsSheetView()
                .previewDisplayName("Add Funds Sheet")
                .frame(height: 400) // Give it a reasonable height for preview
                .previewLayout(.sizeThatFits)
        }
        // Add placeholder assets for preview if needed
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

// MARK: - Placeholders (Add these assets)
// Image("starbucks-card-art")
// Image("starbucks-logo-small")
// Image("starbucks-card-art-small") // A smaller version for the sheet
// Image("paypal-logo")

// MARK: - Placeholder for PersistenceController (Unchanged)
//struct PersistenceController {
//    static let preview = PersistenceController(inMemory: true)
//    let container: NSPersistentCloudKitContainer
//
//    init(inMemory: Bool = false) {
//        container = NSPersistentCloudKitContainer(name: "YourAppName")
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
