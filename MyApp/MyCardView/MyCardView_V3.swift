////
////  MyCardView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/5/25.
////
//
//import SwiftUI
//import CoreData
//
//// MARK: - Data Model for Card
//struct StarbucksCard: Identifiable, Equatable { // Added Equatable
//    let id = UUID()
//    let imageName: String
//    var balance: Double // Made variable in case it needs updating
//    // Add other relevant details like last 4 digits if needed
//    // let lastFour: String?
//
//    // Helper for display
//    var formattedBalance: String {
//        String(format: "$%.2f", balance)
//    }
//}
//
//// Custom Color definition for Starbucks Green (Unchanged)
//extension Color {
////    static let starbucksGreen = Color(red: 0.0, green: 112/255, blue: 74/255)
////    static let starbucksDarkGreen = Color(red: 0.0, green: 98/255, blue: 61/255)
//    static let appBackground = Color(.systemGroupedBackground)
//    static let sheetBackground = Color(.secondarySystemGroupedBackground)
//    static let popoverBackground = Color(.systemGray6) // Background for popover
//}
//
//// Reusable Button Style (Unchanged)
//struct PrimaryButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.headline.weight(.semibold))
//            .padding(.vertical, 15)
//            .frame(maxWidth: .infinity)
//            .background(configuration.isPressed ? Color.starbucksDarkGreen : Color.starbucksGreen)
//            .foregroundColor(.white)
//            .clipShape(Capsule())
//            .shadow(radius: 3, y: 2)
//            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
//            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
//    }
//}
//
//// MARK: - Card Picker Popover View
//struct CardPickerPopoverView: View {
//    let cards: [StarbucksCard]
//    @Binding var selectedCard: StarbucksCard
//    let onAddCard: () -> Void
//    @Environment(\.dismiss) var dismiss // To close the popover implicitly
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            ForEach(cards) { card in
//                Button {
//                    selectedCard = card
//                    dismiss() // Close popover on selection
//                } label: {
//                    HStack {
//                        Image(card.imageName)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 40, height: 25)
//                            .cornerRadius(4)
//                            .background(Color.gray.opacity(0.1)) // Placeholder bg
//
//                        Text(card.formattedBalance)
//                            .font(.system(size: 15, weight: .medium))
//                            .foregroundColor(.primary)
//
//                        Spacer()
//
//                        // Show checkmark if this card is the selected one
//                        if card.id == selectedCard.id {
//                            Image(systemName: "checkmark")
//                                .foregroundColor(.starbucksGreen)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.vertical, 10)
//                }
//                .buttonStyle(.plain) // Use plain style
//
//                // Don't add divider after the last card
//                if card.id != cards.last?.id {
//                     Divider().padding(.leading, 60) // Indent divider
//                }
//            }
//
//            Divider() // Divider before Add Card
//
//            Button {
//                onAddCard()
//                dismiss() // Close popover after tapping Add Card
//            } label: {
//                HStack {
//                    Image(systemName: "plus.circle")
//                         .foregroundColor(.secondary)
//                         .imageScale(.large) // Make icon a bit bigger
//                         .frame(width: 40, height: 25, alignment: .center) // Align with card images
//
//                    Text("Add Card")
//                        .font(.system(size: 15, weight: .medium))
//                        .foregroundColor(.primary)
//                    Spacer()
//                }
//                .padding(.horizontal)
//                .padding(.vertical, 10)
//            }
//            .buttonStyle(.plain)
//        }
//        .padding(.vertical, 5) // Add padding top/bottom of the VStack
//        .background(Color.popoverBackground) // Set background for popover
//        .frame(width: 250) // Set a reasonable width for the popover
//        .cornerRadius(10)
//        .shadow(radius: 5)
//
//    }
//}
//
//// MARK: - Add Funds Sheet View (Updated)
//
//struct AddFundsSheetView: View {
//    @Environment(\.dismiss) var dismiss // To close the sheet
//
//    // --- Sample Data ---
//    // In a real app, this data would come from a ViewModel or data source
//    @State var availableCards: [StarbucksCard] = [
//        StarbucksCard(imageName: "starbucks-card-art-small", balance: 15.11),
//        StarbucksCard(imageName: "starbucks-card-holiday-cup", balance: 0.00),
//        StarbucksCard(imageName: "starbucks-card-pride", balance: 0.00)
//    ]
//    @State private var selectedCard: StarbucksCard // Will be initialized
//
//    // State for other selections
//    @State private var selectedAmount = 25.00
//    @State private var selectedPaymentMethod = "PayPal"
//    @State private var isAutoReloadOn = false
//
//    // State for popover visibility
//    @State private var showCardPicker = false
//    @State private var showAmountPicker = false // Add state for amount picker if needed
//    @State private var showPaymentPicker = false // Add state for payment picker if needed
//
//    let amounts = [10.00, 15.00, 20.00, 25.00, 50.00, 75.00, 100.00] // Example reload amounts
//
//    // Initialize selectedCard with the first available card
////    init() {
////        // This initialization happens *before* the view body is computed
////        // _selectedCard is the underlying State<StarbucksCard> wrapper
////        _selectedCard = State(initialValue: availableCards.first ?? StarbucksCard(imageName: "default-card", balance: 0.0))
////    }
//
//    var formattedAmount: String {
//        String(format: "$%.2f", selectedAmount)
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // Sheet Title Area (Unchanged)
//            Text("Add money to Starbucks Card")
//                .font(.headline)
//                .padding(.top, 20)
//                 .padding(.bottom, 10)
//
//            Divider()
//
//            // Selection Rows (Updated Card Row)
//            VStack(spacing: 0) {
//                // --- Select Card Row ---
//                cardSelectionRow // Extracted for clarity and popover attachment
//
//                Divider().padding(.leading, 16) // Indent divider
//
//                // Select Amount Row (Unchanged logic, maybe add popover later)
//                AmountSelectionRow(
//                    label: "Amount",
//                    selectedValue: $selectedAmount,
//                    options: amounts
//                ) {
//                    print("Amount Changed")
//                }
//
//                Divider().padding(.leading, 16)
//
//                // Select Payment Row (Unchanged logic, maybe add popover later)
//                SelectionRow(
//                    label: "Payment",
//                    value: selectedPaymentMethod,
//                    iconName: "paypal-logo"
//                ) {
//                    print("Change Payment Tapped")
//                    // Potentially set showPaymentPicker = true here later
//                }
//
//            }
//            .padding(.vertical)
//
//             Divider()
//
//            // Auto Reload Toggle (Unchanged)
//            HStack {
//                Text("Auto reload")
//                    .font(.body)
//                Spacer()
//                Toggle("", isOn: $isAutoReloadOn)
//                    .labelsHidden()
//                    .tint(.starbucksGreen)
//            }
//            .padding()
//
//            Spacer()
//
//            // Add Amount Button (Unchanged)
//            Button("Add \(formattedAmount)") {
//                print("Adding \(formattedAmount) to card \(selectedCard.id) using \(selectedPaymentMethod)")
//                dismiss()
//            }
//            .buttonStyle(PrimaryButtonStyle())
//            .padding(.horizontal)
//            .padding(.bottom, 20)
//        }
//    }
//
//    // --- Extracted Card Selection Row ---
//    private var cardSelectionRow: some View {
//        Button {
//            showCardPicker = true // Toggle popover visibility
//        } label: {
//            HStack(spacing: 12) {
//                Image(selectedCard.imageName) // Display selected card image
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 45, height: 28) // Slightly larger? Adjust as needed
//                    .cornerRadius(4)
//                    .background(Color.gray.opacity(0.1))
//
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("Starbucks Card") // Static label
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    Text(selectedCard.formattedBalance) // Display selected card balance
//                        .font(.body.weight(.medium))
//                        .foregroundColor(.primary)
//                }
//
//                Spacer()
//
//                Image(systemName: "chevron.down")
//                    .foregroundColor(.secondary)
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 8)
//            .contentShape(Rectangle())
//        }
//        .buttonStyle(.plain)
//        .popover(isPresented: $showCardPicker,
//                 attachmentAnchor: .point(.bottomLeading), // Attach slightly below the button
//                 arrowEdge: .top) {
//            CardPickerPopoverView(
//                cards: availableCards,
//                selectedCard: $selectedCard, // Pass binding
//                onAddCard: {
//                    print("Add Card Action Triggered")
//                    // Implement navigation or sheet presentation for adding a card
//                }
//            )
//            // Apply presentation compact adaptation if needed for iOS 16.4+
//             // .presentationCompactAdaptation(.popover)
//        }
//    }
//}
//
//// MARK: - Reusable Row Components for Sheet (Unchanged)
//
//// Generic Row for Payment Selection (or others later)
//struct SelectionRow: View {
//    let label: String
//    let value: String
//    let iconName: String // Asset name for the icon/image
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack(spacing: 12) {
//                Image(iconName)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 40, height: 25) // Adjust size as needed
//                    .cornerRadius(4)
//                    .background(Color.gray.opacity(0.1))
//
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(label)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    Text(value)
//                        .font(.body.weight(.medium))
//                        .foregroundColor(.primary)
//                }
//
//                Spacer()
//
//                Image(systemName: "chevron.down")
//                    .foregroundColor(.secondary)
//            }
//            .padding(.horizontal)
//             .padding(.vertical, 8)
//            .contentShape(Rectangle())
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//// Specific Row for Amount Selection using a Picker
//struct AmountSelectionRow: View {
//    let label: String
//    @Binding var selectedValue: Double
//    let options: [Double]
//    let action: () -> Void
//
//    var body: some View {
//         HStack(spacing: 12) {
//             // No icon for amount row
//             VStack(alignment: .leading, spacing: 2) {
//                 Text(label)
//                     .font(.caption)
//                     .foregroundColor(.secondary)
//
//                 Picker(label, selection: $selectedValue) {
//                     ForEach(options, id: \.self) { amount in
//                         Text(String(format: "$%.2f", amount)).tag(amount)
//                     }
//                 }
//                 .pickerStyle(.menu)
//                 .labelsHidden()
//                 .accentColor(.primary)
//                 .onChange(of: selectedValue) { _ in action() }
//                 .frame(maxWidth: .infinity, alignment: .leading)
//                 .padding(.leading, -6)
//             }
//
//             Spacer()
//             // Chevron is part of the menu picker style
//         }
//        .padding(.horizontal)
//         .padding(.vertical, 8)
//    }
//}
//
//// MARK: - My Card View Content (Unchanged)
//struct MyCardViewContent: View {
//    @State private var isDefaultStoreCard = true
//    @State private var showAutoReloadSheet = false
//    @State private var showAddFundsSheet = false
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // --- Card Info Section (Unchanged) ---
//            HStack(alignment: .center, spacing: 16) {
//                Image("starbucks-card-art")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 100)
//                    .background(Color.gray.opacity(0.3))
//                     .overlay(
//                        Image("starbucks-logo-small")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 20, height: 20)
//                            .padding(5)
//                            .background(.white.opacity(0.8))
//                            .clipShape(Circle())
//                            .offset(x: 40, y: -25),
//                        alignment: .topTrailing
//                     )
//                    .cornerRadius(8)
//
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("$15.11") // Maybe link this to the default card actual balance
//                        .font(.system(size: 28, weight: .bold))
//                        .foregroundColor(.primary)
//
//                    HStack(spacing: 8) {
//                        Text("as of 1d ago")
//                             .font(.caption)
//                             .foregroundColor(.secondary)
//                        Button { } label: {
//                            Image(systemName: "arrow.clockwise")
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                }
//                Spacer()
//            }
//            .padding()
//            .background(Color.appBackground)
//
//            Divider()
//
//            // --- Actions List (Unchanged) ---
//             List {
//                 HStack {
//                    Image(systemName: "checkmark.circle")
//                         .foregroundColor(.secondary)
//                    Text("Make in store default")
//                         .foregroundColor(.primary)
//                    Spacer()
//                    Toggle("", isOn: $isDefaultStoreCard)
//                         .labelsHidden()
//                         .tint(.starbucksGreen)
//                }
//                HStack {
//                    Image(systemName: "arrow.clockwise.circle")
//                         .foregroundColor(.secondary)
//                    Text("Auto reload")
//                        .foregroundColor(.primary)
//                    Spacer()
//                    Button("Turn on") { showAutoReloadSheet = true }
//                    .font(.caption.weight(.semibold))
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 6)
//                    .foregroundColor(.starbucksGreen)
//                    .overlay( Capsule().stroke(Color.starbucksGreen, lineWidth: 1.5) )
//                }
//                HStack {
//                    Image(systemName: "arrow.left.arrow.right")
//                        .foregroundColor(.secondary)
//                    Text("Transfer balance")
//                        .foregroundColor(.primary)
//                    Spacer()
//                }
//                HStack {
//                    Image(systemName: "wallet.pass")
//                        .foregroundColor(.secondary)
//                    Text("Add to Apple Wallet")
//                        .foregroundColor(.primary)
//                    Spacer()
//                }
//                HStack {
//                    Image(systemName: "minus.circle")
//                        .foregroundColor(.red)
//                    Text("Remove card")
//                        .foregroundColor(.red)
//                    Spacer()
//                }
//            }
//            .listStyle(.plain)
//
//            Spacer()
//
//            // --- Add Funds Button (Unchanged) ---
//            Button("Add funds") { showAddFundsSheet = true }
//            .buttonStyle(PrimaryButtonStyle())
//            .padding(.horizontal)
//            .padding(.bottom, 8)
//
//        }
//        .background(Color.appBackground.ignoresSafeArea())
//        .navigationTitle("My Card 7668")
//        .navigationBarTitleDisplayMode(.large)
//        .sheet(isPresented: $showAutoReloadSheet) {
//             Text("Auto Reload Settings Screen")
//         }
//        .sheet(isPresented: $showAddFundsSheet) {
//            // Pass the sample data from here if it originated here,
//            // otherwise AddFundsSheetView handles its own sample data for now
//            AddFundsSheetView()
//                .presentationDetents([.height(420)]) // Adjust height as needed
//        }
//    }
//}
//
//// MARK: - Helper view to embed (Unchanged)
//struct MyCardViewEmbedded: View {
//    var body: some View {
//        NavigationView {
//            MyCardViewContent()
//        }
//    }
//}
//
//// MARK: - Main ContentView hosting the TabView (Unchanged)
//struct MyCardView: View {
//    @State private var selectedTab = 1
//
//    init() {
//       let appearance = UITabBarAppearance()
//       appearance.configureWithOpaqueBackground()
//       appearance.backgroundColor = UIColor.systemBackground
//       appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.starbucksGreen)
//       appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.starbucksGreen)]
//       appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
//       appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
//       UITabBar.appearance().standardAppearance = appearance
//       UITabBar.appearance().scrollEdgeAppearance = appearance
//    }
//
//    var body: some View {
//        TabView(selection: $selectedTab) {
//            Text("Home Tab").tabItem { Label("Home", systemImage: "house.fill") }.tag(0)
//            MyCardViewEmbedded().tabItem { Label("Scan", systemImage: "qrcode.viewfinder") }.tag(1)
//            Text("Order Tab").tabItem { Label("Order", systemImage: "cup.and.saucer.fill") }.tag(2)
//            Text("Gift Tab").tabItem { Label("Gift", systemImage: "gift.fill") }.tag(3)
//            Text("Offers Tab").tabItem { Label("Offers", systemImage: "star.fill") }.tag(4)
//        }
//    }
//}
//
//// MARK: - Preview Provider (Updated)
//struct MyCardViewContent_Previews: PreviewProvider {
//    static var previews: some View {
//   
//          
//            MyCardViewContent()
//                .previewDisplayName("Card Content Only")
//
//            // Preview the sheet directly to test its layout
//            AddFundsSheetView()
//                .previewDisplayName("Add Funds Sheet")
//                .frame(height: 420)
//                .previewLayout(.sizeThatFits)
//
//            // Preview the popover content directly
//            CardPickerPopoverView(
//                cards: [
//                    StarbucksCard(imageName: "starbucks-card-art-small", balance: 15.11),
//                    StarbucksCard(imageName: "starbucks-card-holiday-cup", balance: 0.00),
//                    StarbucksCard(imageName: "starbucks-card-pride", balance: 0.00)
//                ],
//                selectedCard: .constant(StarbucksCard(imageName: "starbucks-card-art-small", balance: 15.11)), // Provide a binding constant
//                onAddCard: {}
//            )
//            .previewLayout(.sizeThatFits)
//            .padding()
//            .background(Color.blue.opacity(0.2)) // Add background to see popover bounds
//            .previewDisplayName("Card Picker Popover")
//
//        
//        // Add placeholder assets for preview if needed
////        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
//
//// MARK: - Placeholders (Add these assets)
//// Image("starbucks-card-art")
//// Image("starbucks-logo-small")
//// Image("starbucks-card-art-small")
//// Image("paypal-logo")
//// Image("starbucks-card-holiday-cup") // New asset
//// Image("starbucks-card-pride")       // New asset
//// Image("default-card")             // Fallback asset
//
//// MARK: - Placeholder for PersistenceController (Unchanged)
////struct PersistenceController {
////    static let preview = PersistenceController(inMemory: true)
////    let container: NSPersistentCloudKitContainer
////    init(inMemory: Bool = false) {
////        container = NSPersistentCloudKitContainer(name: "YourAppName")
////        if inMemory { container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null") }
////        container.loadPersistentStores { (storeDescription, error) in
////             if let error = error as NSError? { fatalError("Unresolved error \(error), \(error.userInfo)") }
////         }
////        container.viewContext.automaticallyMergesChangesFromParent = true
////    }
////}
