////
////  SettingView.swift
////  MyApp
////
////  Created by Cong Le on 3/27/25.
////
//
//import SwiftUI
//
//// MARK: - Data Model (From previous response - Unchanged)
//struct InventoryItem: Identifiable, Hashable { /* ... Same as before ... */
//    let id = UUID()
//    var name: String
//    var barcode: String
//    var scanDate: Date
//    var quantity: Int
//    var imageName: String?
//
//    static func generateSampleData(count: Int) -> [InventoryItem] {
//        // ... Same sample data generation ...
//        let sampleNames = ["Organic Facial Cleanser", "Repairing Hand Cream", "Hydrating Serum", "Exfoliating Scrub", "Vitamin C Brightener", "Sunscreen SPF 50", "Night Renewal Cream"]
//        let sampleImages = ["skincare.tube.fill", "hand.raised.fill", "eyedropper.halffull", "bubbles.and.sparkles", "sun.max.fill", "moon.stars.fill"]
//        
//        return (1...count).map { i in
//            InventoryItem(
//                name: "\(sampleNames.randomElement() ?? "Product") \(i)",
//                barcode: "1234567890\(i)",
//                scanDate: Calendar.current.date(byAdding: .day, value: -Int.random(in: 1...30), to: Date()) ?? Date(),
//                quantity: Int.random(in: 1...5),
//                imageName: i % 3 == 0 ? nil : sampleImages.randomElement()
//            )
//        }
//    }
//}
//
//// MARK: - Main TabView Container (Updated Settings Tab)
//
//struct ContentView: View {
//    @State private var selectedTab = 4 // Start on Settings tab for demonstration
//
//    // Sample inventory data (replace with ViewModel/Data Persistence later)
//    @State private var inventoryItems: [InventoryItem] = InventoryItem.generateSampleData(count: 15)
//
//    var body: some View {
//        TabView(selection: $selectedTab) {
//            // --- Scan Tab ---
//            ScanView()
//                .tabItem { Label("Scan", systemImage: "barcode.viewfinder") }
//                .tag(0)
//
//            // --- Inventory Tab ---
//            InventoryView(inventoryItems: $inventoryItems)
//                .tabItem { Label("Inventory", systemImage: "house.fill") }
//                .tag(1)
//
//            // --- IO Tab (Placeholder) ---
//             PlaceholderView(text: "IO Screen")
//                 .tabItem { Label("IO", systemImage: "arrow.left.arrow.right") }
//                 .tag(2)
//
//            // --- Admin Tab (Placeholder) ---
//             PlaceholderView(text: "Admin Screen")
//                 .tabItem { Label("Admin", systemImage: "crown.fill") }
//                 .tag(3)
//
//            // --- Settings Tab ---
//            // **** Replace PlaceholderView with SettingsView ****
//            SettingsView(inventoryItems: $inventoryItems) // Pass binding if needed (e.g., for clear data)
//                 .tabItem { Label("Settings", systemImage: "gearshape.fill") }
//                 .tag(4)
//        }
//        .accentColor(.blue)
//    }
//}
//
//// MARK: - Settings View Implementation
//
//struct SettingsView: View {
//    // Persistent settings using AppStorage
//    @AppStorage("playSoundOnScan") private var playSoundOnScan: Bool = true
//    @AppStorage("vibrateOnScan") private var vibrateOnScan: Bool = true
//    // Add more @AppStorage properties as needed
//
//    // State for confirmation dialog
//    @State private var showingClearDataAlert = false
//    
//    // Binding to the inventory data from ContentView to allow clearing it
//    @Binding var inventoryItems: [InventoryItem]
//    
//    // Access app version
//    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
//    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
//
//    var body: some View {
//        NavigationView {
//            Form { // Use Form for standard settings appearance
//                // MARK: - Scanning Section
//                Section(header: Text("Scanning Preferences"), footer: Text("Feedback when a barcode is successfully scanned.")) {
//                    Toggle(isOn: $playSoundOnScan) {
//                        Label("Play Sound", systemImage: "speaker.wave.2.fill")
//                    }
//                    
//                    Toggle(isOn: $vibrateOnScan) {
//                        Label("Vibrate", systemImage: "iphone.gen1.radiowaves.left.and.right")
//                    }
//                    
//                    // Example Picker (if needed later)
//                    /*
//                    Picker("Scan Mode", selection: .constant("Single")) {
//                        Text("Single Scan").tag("Single")
//                        Text("Continuous Scan").tag("Continuous")
//                    }
//                    .pickerStyle(.menu) // Or other styles like .inline
//                    */
//                }
//
//                // MARK: - Data Management Section
//                Section("Data Management") {
//                    Button {
//                        // Action for exporting data
//                        print("Export Data Tapped")
//                        // Implement export logic (e.g., generate CSV and show share sheet)
//                    } label: {
//                         Label("Export Inventory (CSV)", systemImage: "square.and.arrow.up")
//                            .foregroundColor(.primary) // Ensure text color is standard
//                    }
//                    
//                    Button {
//                        // Action for importing data
//                         print("Import Data Tapped")
//                         // Implement import logic (e.g., show document picker)
//                    } label: {
//                        Label("Import Inventory (CSV)", systemImage: "square.and.arrow.down")
//                            .foregroundColor(.primary)
//                    }
//
//                    Button(role: .destructive) { // Use destructive role for caution
//                        showingClearDataAlert = true // Show confirmation alert
//                    } label: {
//                        Label("Clear All Inventory Data", systemImage: "trash")
//                    }
//                }
//
//                // MARK: - Support Section
//                Section("Support & Feedback") {
//                   Link(destination: URL(string: "https://www.example.com/help")!) { // Replace with actual URL
//                       Label("Help & FAQ", systemImage: "questionmark.circle")
//                   }
//                   
//                    Link(destination: URL(string: "https://www.example.com/feedback")!) { // Replace with actual URL
//                        Label("Send Feedback", systemImage: "envelope")
//                    }
//                    
//                     Link(destination: URL(string: "mailto:support@example.com")!) { // Replace with actual email
//                         Label("Contact Support", systemImage: "lifepreserver")
//                     }
//                }
//                
//                // MARK: - About Section
//                Section("About") {
//                   HStack {
//                       Text("App Version")
//                       Spacer()
//                       Text("\(appVersion) (\(buildNumber))") // Display version and build
//                            .foregroundColor(.secondary)
//                   }
//                   
//                   Link(destination: URL(string: "https://www.example.com/privacy")!) { // Replace with actual URL
//                        Label("Privacy Policy", systemImage: "lock.shield")
//                   }
//                   
//                   Link(destination: URL(string: "https://www.example.com/terms")!) { // Replace with actual URL
//                        Label("Terms of Service", systemImage: "doc.text")
//                   }
//                }
//            }
//            .navigationTitle("Settings") // Set the title for the screen
//            .navigationBarTitleDisplayMode(.inline) // Use inline title
//            .alert("Clear All Data?", isPresented: $showingClearDataAlert) { // Confirmation Dialog
//                 Button("Cancel", role: .cancel) { }
//                 Button("Clear Data", role: .destructive) {
//                     // Action to clear the data
//                     print("Clearing all inventory data.")
//                     inventoryItems.removeAll() // Clear the bound data
//                 }
//             } message: {
//                 Text("This action cannot be undone. All scanned items will be permanently deleted.")
//             }
//        }
//        .navigationViewStyle(StackNavigationViewStyle()) // Consistent style
//    }
//}
//
//// MARK: - Placeholder and Supporting Views (From previous responses - Unchanged / Abbreviated)
//
//// ScanView, InventoryView, InventoryRowView, EmptyInventoryView, InventoryItemDetailView placeholders...
//// Use the full implementations from previous responses here.
//struct ScanView: View { /* ... */ var body: some View { Text("Scan Screen Placeholder") } }
//struct InventoryView: View { @Binding var inventoryItems: [InventoryItem]; /* ... */ var body: some View { Text("Inventory Screen Placeholder - Items: \(inventoryItems.count)") } }
//struct PlaceholderView: View { let text: String; var body: some View { NavigationView{ VStack{ Text(text).font(.title).foregroundColor(.gray) }.navigationTitle(text).navigationBarTitleDisplayMode(.inline) }.navigationViewStyle(StackNavigationViewStyle()) } }
//
//// Abbreviated versions of ScanView components for brevity in this snippet
//struct CameraPreviewPlaceholder: View { var body: some View { Color.black.overlay(Image(systemName: "camera").foregroundColor(.gray)) } }
//struct FocusZoneOverlay: View { var body: some View { Text("Focus Zone").foregroundColor(.white).padding(5).border(Color.white) } }
//struct BottomControlsOverlay: View { @Binding var isFlashlightOn: Bool; var body: some View { HStack { Text("Controls Placeholder"); Spacer(); Image(systemName:"flashlight.on.fill") }.padding().background(.ultraThinMaterial) } }
//
//// MARK: - Preview Provider
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Preview ContentView (will show Settings tab selected)
//        ContentView()
//
//        // Preview SettingsView directly
//        SettingsView(inventoryItems: .constant(InventoryItem.generateSampleData(count: 5)))
//            .previewDisplayName("Settings View")
//            
//        // Preview SettingsView with empty data
//         SettingsView(inventoryItems: .constant([]))
//             .previewDisplayName("Settings View (Empty Data)")
//    }
//}
