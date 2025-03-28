////
////  AdminView.swift
////  MyApp
////
////  Created by Cong Le on 3/27/25.
////
////import SwiftUI
////
////// MARK: - Data Model (From previous responses - Unchanged)
////struct InventoryItem: Identifiable, Hashable {
////    let id = UUID()
////    var name: String
////    var barcode: String
////    var scanDate: Date
////    var quantity: Int
////    var imageName: String?
////
////    static func generateSampleData(count: Int) -> [InventoryItem] {
////          let sampleNames = ["Organic Facial Cleanser", "Repairing Hand Cream", "Hydrating Serum", "Exfoliating Scrub", "Vitamin C Brightener", "Sunscreen SPF 50", "Night Renewal Cream", "Empty Name Item"] // Added one potentially bad item
////          let sampleImages = ["skincare.tube.fill", "hand.raised.fill", "eyedropper.halffull", "bubbles.and.sparkles", "sun.max.fill", "moon.stars.fill"]
////
////          var items: [InventoryItem] = []
////          for i in 1...count {
////              var name = "\(sampleNames.randomElement() ?? "Product") \(i)"
////              // Simulate an item with an empty name occasionally
////              if i == count / 2 { // Example condition
////                  name = ""
////              }
////              items.append(
////                  InventoryItem(
////                      name: name,
////                      barcode: i == count / 3 ? "DUPLICATE123" : "1234567890\(i)", // Simulate a duplicate barcode
////                      scanDate: Calendar.current.date(byAdding: .day, value: -Int.random(in: 1...90), to: Date()) ?? Date(),
////                      quantity: Int.random(in: 0...5), // Allow zero quantity
////                      imageName: i % 4 == 0 ? nil : sampleImages.randomElement()
////                  )
////              )
////          }
////          // Add another item with the same duplicate barcode
////          items.append(InventoryItem(name: "Another Item", barcode: "DUPLICATE123", scanDate: Date(), quantity: 1, imageName: sampleImages.randomElement()))
////          return items
////      }
////}
////
////// MARK: - Main TabView Container (Updated Admin Tab)
////
////struct ContentView: View {
////    @State private var selectedTab = 3 // Start on Admin tab for demonstration
////
////    // Sample inventory data (replace with ViewModel/Data Persistence later)
////    @State private var inventoryItems: [InventoryItem] = InventoryItem.generateSampleData(count: 20) // Generate more data for checks
////
////    var body: some View {
////        TabView(selection: $selectedTab) {
////            // --- Scan Tab ---
////            ScanView()
////                .tabItem { Label("Scan", systemImage: "barcode.viewfinder") }
////                .tag(0)
////
////            // --- Inventory Tab ---
////            InventoryView(inventoryItems: $inventoryItems)
////                .tabItem { Label("Inventory", systemImage: "house.fill") }
////                .tag(1)
////
////            // --- IO Tab (Placeholder) ---
////             PlaceholderView(text: "IO Screen")
////                 .tabItem { Label("IO", systemImage: "arrow.left.arrow.right") }
////                 .tag(2)
////
////            // --- Admin Tab ---
////             // **** Replace PlaceholderView with AdminView ****
////             AdminView(inventoryItems: $inventoryItems) // Pass the binding
////                 .tabItem { Label("Admin", systemImage: "crown.fill") }
////                 .tag(3)
////
////            // --- Settings Tab ---
////            SettingsView(inventoryItems: $inventoryItems)
////                 .tabItem { Label("Settings", systemImage: "gearshape.fill") }
////                 .tag(4)
////        }
////        .accentColor(.blue)
////    }
////}
////
////// MARK: - Admin View Implementation
////
////struct AdminView: View {
////    @Binding var inventoryItems: [InventoryItem]
////
////    // State for showing results/feedback
////    @State private var dataCheckResult: String? = nil
////    @State private var systemStatus: String = "Tap 'Refresh' to check status."
////    @State private var showingClearLogsAlert = false
////
////    // Computed properties for data checks (examples)
////    private var itemsWithEmptyNames: Int {
////        inventoryItems.filter { $0.name.trimmingCharacters(in: .whitespaces).isEmpty }.count
////    }
////
////    private var potentialDuplicateBarcodes: Int {
////        // Simple check: count barcodes that appear more than once
////        Dictionary(grouping: inventoryItems, by: { $0.barcode }).filter { $1.count > 1 }.count
////    }
////
////    private var itemsWithZeroQuantity: Int {
////        inventoryItems.filter { $0.quantity <= 0 }.count
////    }
////
////    var body: some View {
////        NavigationView {
////            Form {
////                // MARK: - Data Integrity Section
////                Section("Data Integrity Checks") {
////                    HStack {
////                        Text("Items with Empty Names:")
////                        Spacer()
////                        Text("\(itemsWithEmptyNames)")
////                            .foregroundColor(itemsWithEmptyNames > 0 ? .red : .secondary)
////                    }
////
////                    HStack {
////                        Text("Potential Duplicate Barcodes:")
////                        Spacer()
////                        Text("\(potentialDuplicateBarcodes)")
////                               .foregroundColor(potentialDuplicateBarcodes > 0 ? .orange : .secondary)
////                    }
////
////                     HStack {
////                         Text("Items with Zero/Negative Qty:")
////                         Spacer()
////                         Text("\(itemsWithZeroQuantity)")
////                                .foregroundColor(itemsWithZeroQuantity > 0 ? .orange : .secondary)
////                     }
////
////                    Button {
////                        // Perform more complex check if needed
////                        dataCheckResult = """
////                        Items w/ Empty Names: \(itemsWithEmptyNames)
////                        Duplicate Barcodes Groups: \(potentialDuplicateBarcodes)
////                        Items w/ Zero Qty: \(itemsWithZeroQuantity)
////
////                        Check Completed: \(Date(), style: .time)
////                        """
////                        print("Run Data Integrity Check Tapped")
////                    } label: {
////                        Label("Run Full Integrity Check", systemImage: "checkmark.shield")
////                    }
////
////                    if let result = dataCheckResult {
////                        Text(result)
////                            .font(.caption)
////                            .foregroundColor(.gray)
////                    }
////                }
////
////                // MARK: - Bulk Operations Section
////                Section("Bulk Operations") {
////                    Button {
////                        // Placeholder action
////                        print("Archive Old Items Tapped (Simulated)")
////                         // Implement logic: e.g., filter items older than X days and move to an archive or delete
////                    } label: {
////                        Label("Archive Items Older Than 90 Days", systemImage: "archivebox")
////                    }
////
////                    Button(role: .destructive) {
////                        showingClearLogsAlert = true
////                    } label: {
////                        Label("Clear System Logs (Simulated)", systemImage: "doc.text.magnifyingglass")
////                    }
////                }
////
////                // MARK: - System Status Section
////                Section("System Status") {
////                    HStack {
////                        Text("Backend Connection:")
////                        Spacer()
////                        Text("Connected") // Simulated
////                            .foregroundColor(.green)
////                    }
////                     HStack {
////                         Text("Database Size:")
////                         Spacer()
////                         Text("15.2 MB") // Simulated
////                             .foregroundColor(.secondary)
////                     }
////                    HStack {
////                        Text("Last Backup:")
////                        Spacer()
////                        Text("Today, 3:15 AM") // Simulated
////                             .foregroundColor(.secondary)
////                    }
////                    Button {
////                        // Simulate refreshing status
////                        systemStatus = "Status Refreshed: \(Date(), style: .time). All systems nominal."
////                        print("Refresh System Status Tapped")
////                    } label: {
////                        Label("Refresh Status", systemImage: "arrow.clockwise")
////                    }
////                    Text(systemStatus)
////                        .font(.caption)
////                        .foregroundColor(.gray)
////                }
////
////                // MARK: - User Management Section (Conceptual)
////                Section("User Administration") {
////                     NavigationLink(destination: PlaceholderView(text: "User Management")) { // Link to placeholder
////                        Label("Manage Users", systemImage: "person.2.fill")
////                    }
////                     // In a real app, this might list roles or link to specific user settings
////                     Text("Configure user roles and permissions.")
////                         .font(.caption)
////                         .foregroundColor(.gray)
////                }
////            }
////            .navigationTitle("Admin Panel")
////            .navigationBarTitleDisplayMode(.inline)
////             .alert("Clear System Logs?", isPresented: $showingClearLogsAlert) {
////                 Button("Cancel", role: .cancel) { }
////                 Button("Clear Logs", role: .destructive) {
////                     // Action to clear logs (Simulated)
////                     print("Clearing system logs (Simulated).")
////                 }
////             } message: {
////                 Text("This action cannot be undone. Diagnostic logs will be permanently deleted.")
////             }
////        }
////        .navigationViewStyle(StackNavigationViewStyle())
////    }
////}
////
////// MARK: - Placeholder and Supporting Views (From previous responses - Unchanged / Abbreviated)
////
////// ScanView, InventoryView, InventoryRowView, EmptyInventoryView, InventoryItemDetailView, SettingsView placeholders...
////// Use the full implementations from previous responses here.
////struct ScanView: View { /* ... */ var body: some View { Text("Scan Screen Placeholder") } }
////struct InventoryView: View { @Binding var inventoryItems: [InventoryItem]; /* ... */ var body: some View { Text("Inventory Screen Placeholder - Items: \(inventoryItems.count)") } }
////struct SettingsView: View { @Binding var inventoryItems: [InventoryItem]; /* ... */ var body: some View { Text("Settings Screen Placeholder") } }
////struct PlaceholderView: View { let text: String; var body: some View { NavigationView{ VStack{ Text(text).font(.title).foregroundColor(.gray) }.navigationTitle(text).navigationBarTitleDisplayMode(.inline) }.navigationViewStyle(StackNavigationViewStyle()) } }
////
////// Abbreviated versions of ScanView components for brevity
////struct CameraPreviewPlaceholder: View { var body: some View { Color.black.overlay(Image(systemName: "camera").foregroundColor(.gray)) } }
////struct FocusZoneOverlay: View { var body: some View { Text("Focus Zone").foregroundColor(.white).padding(5).border(Color.white) } }
////struct BottomControlsOverlay: View { @Binding var isFlashlightOn: Bool; var body: some View { HStack { Text("Controls Placeholder"); Spacer(); Image(systemName:"flashlight.on.fill") }.padding().background(.ultraThinMaterial) } }
////
////// MARK: - Preview Provider
////
////struct ContentView_Previews: PreviewProvider {
////    static var previews: some View {
////        // Preview ContentView (will show Admin tab selected)
////        ContentView()
////
////        // Preview AdminView directly with sample data
////        AdminView(inventoryItems: .constant(InventoryItem.generateSampleData(count: 25)))
////            .previewDisplayName("Admin View")
////
////        // Preview AdminView with empty data
////         AdminView(inventoryItems: .constant([]))
////             .previewDisplayName("Admin View (Empty Data)")
////    }
////}
//
//import SwiftUI
//
//// MARK: - Data Model
//
//struct InventoryItem: Identifiable, Hashable {
//    let id = UUID()
//    var name: String
//    var barcode: String
//    var scanDate: Date
//    var quantity: Int
//    var imageName: String? // Placeholder for image name/URL
//    
//    // Sample data generator (enhanced for edge cases)
//    static func generateSampleData(count: Int) -> [InventoryItem] {
//        let sampleNames = ["Organic Facial Cleanser", "Repairing Hand Cream", "Hydrating Serum", "Exfoliating Scrub", "Vitamin C Brightener", "Sunscreen SPF 50", "Night Renewal Cream", "Micellar Water", "Clay Mask"]
//        let sampleImages = ["skincare.tube.fill", "hand.raised.fill", "eyedropper.halffull", "bubbles.and.sparkles", "sun.max.fill", "moon.stars.fill", "drop.fill", "face.smiling.inverse"] // Example system icons
//        
//        var items: [InventoryItem] = []
//        let duplicateBarcode = "DUPLICATE999"
//        
//        for i in 1...count {
//            var name = "\(sampleNames.randomElement() ?? "Product") \(i)"
//            var currentBarcode = "1234567890\(i)"
//            var currentQuantity = Int.random(in: 1...5)
//            var currentImageName = i % 4 == 0 ? nil : sampleImages.randomElement() // Some items without images
//            
//            // --- Simulate Edge Cases for Admin View ---
//            // 1. Occasional Empty Name
//            if i == count / 3 {
//                name = "" // Simulate empty name
//            }
//            // 2. Occasional Duplicate Barcode
//            if i == count / 2 || i == count / 2 + 1 {
//                currentBarcode = duplicateBarcode
//            }
//            // 3. Occasional Zero Quantity
//            if i == count / 4 {
//                currentQuantity = 0
//            }
//            // 4. Specific Item for Detail View Preview
//            if i == 1 {
//                name = "Preview Detail Item"
//                currentImageName = "star.fill"
//            }
//            // --- End Edge Cases ---
//            
//            items.append(
//                InventoryItem(
//                    name: name,
//                    barcode: currentBarcode,
//                    scanDate: Calendar.current.date(byAdding: .day, value: -Int.random(in: 1...90), to: Date()) ?? Date(),
//                    quantity: currentQuantity,
//                    imageName: currentImageName
//                )
//            )
//        }
//        // Ensure at least one duplicate pair exists if count is small
//        if count > 2 && !items.contains(where: { $0.barcode == duplicateBarcode }) {
//            items[0].barcode = duplicateBarcode
//            items[1].barcode = duplicateBarcode
//        }
//        
//        return items
//    }
//}
//
//// MARK: - Supporting Views (Rows, Placeholders, Scan Components)
//
//// Placeholder view for tabs or destinations not fully implemented
//struct PlaceholderView: View {
//    let text: String
//    let showNavigationTitle: Bool // Control title visibility
//    
//    init(text: String, showNavigationTitle: Bool = true) {
//        self.text = text
//        self.showNavigationTitle = showNavigationTitle
//    }
//    
//    var body: some View {
//        VStack {
//            Spacer()
//            Image(systemName: "ellipsis.circle")
//                .font(.system(size: 50))
//                .foregroundColor(.secondary.opacity(0.5))
//            Text(text)
//                .font(.title2)
//                .foregroundColor(.secondary)
//                .padding(.top, 5)
//            Spacer()
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure it fills space
//        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.bottom)) // Match form background
//        .navigationTitle(showNavigationTitle ? text : "") // Conditional title
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// View for a single row in the inventory list
//struct InventoryRowView: View {
//    let item: InventoryItem
//    
//    var body: some View {
//        HStack(spacing: 15) {
//            // Item Image
//            Image(systemName: item.imageName ?? "photo.on.rectangle.angled")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 50, height: 50)
//                .padding(5)
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(8)
//                .foregroundColor(item.imageName == nil ? .secondary : .accentColor) // Use AccentColor for actual images
//            
//            // Item Details
//            VStack(alignment: .leading, spacing: 4) {
//                Text(item.name.isEmpty ? "(No Name)" : item.name) // Handle empty name display
//                    .font(.headline)
//                    .foregroundColor(item.name.isEmpty ? .red : .primary) // Highlight empty name issue
//                    .lineLimit(2)
//                
//                Text("Scanned: \(item.scanDate, style: .date)")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//            
//            Spacer()
//            
//            // Quantity Display
//            Text("Qty: \(item.quantity)")
//                .font(.subheadline)
//                .fontWeight(.medium)
//                .padding(.horizontal, 8)
//                .padding(.vertical, 4)
//                .background(item.quantity <= 0 ? Color.orange.opacity(0.15) : Color.blue.opacity(0.1)) // Highlight zero/low qty
//                .foregroundColor(item.quantity <= 0 ? .orange : .blue)
//                .cornerRadius(6)
//        }
//        .padding(.vertical, 6) // Slightly reduce vertical padding for denser list
//    }
//}
//
//// View displayed when the inventory list is empty
//struct EmptyInventoryView: View {
//    var body: some View {
//        VStack(spacing: 15) {
//            Image(systemName: "archivebox")
//                .font(.system(size: 60))
//                .foregroundColor(.secondary.opacity(0.7))
//            Text("Inventory is Empty")
//                .font(.title2)
//                .fontWeight(.semibold)
//            Text("Use the 'Scan' tab to add items.")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        // Removed explicit background setting to allow List background to show
//    }
//}
//
//// Detail view navigated to from an InventoryRowView
//struct InventoryItemDetailView: View {
//    let item: InventoryItem
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                // Image
//                Image(systemName: item.imageName ?? "photo.on.rectangle.angled")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 200)
//                    .padding(.vertical)
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(10)
//                    .foregroundColor(item.imageName == nil ? .secondary : .accentColor)
//                    .padding(.bottom)
//                
//                // Name (handling empty)
//                Text(item.name.isEmpty ? "(No Name)" : item.name)
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .foregroundColor(item.name.isEmpty ? .red : .primary)
//                
//                // Key Info HStack
//                HStack {
//                    VStack(alignment: .leading) {
//                        Text("Quantity")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                        Text("\(item.quantity)")
//                            .font(.title3)
//                            .fontWeight(.medium)
//                    }
//                    Spacer()
//                    VStack(alignment: .trailing) {
//                        Text("Scanned On")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                        Text("\(item.scanDate, style: .date) \(item.scanDate, style: .time)")
//                            .font(.subheadline)
//                    }
//                }
//                .padding(.vertical, 8)
//                
//                Divider()
//                
//                // Barcode Section
//                VStack(alignment: .leading, spacing: 5) {
//                    Text("Barcode")
//                        .font(.headline)
//                    Text(item.barcode)
//                        .font(.body)
//                        .foregroundColor(.secondary)
//                        .textSelection(.enabled) // Allow copying barcode
//                }
//                
//                // Add more fields if needed (e.g., Notes, Category)
//                /*
//                 VStack(alignment: .leading, spacing: 5) {
//                 Text("Notes").font(.headline).padding(.top)
//                 Text(item.notes ?? "No notes added.")
//                 .foregroundColor(item.notes == nil ? .secondary.opacity(0.7) : .secondary)
//                 }
//                 */
//                
//                Spacer() // Pushes content up
//            }
//            .padding()
//        }
//        .navigationTitle("Item Details")
//        .navigationBarTitleDisplayMode(.inline)
//        // Background to match standard form appearance
//        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.bottom))
//    }
//}
//
//// MARK: - Scan View Components (Placeholders/Simulated)
//
//struct CameraPreviewPlaceholder: View {
//    var body: some View {
//        Color.black
//            .overlay(
//                Image(systemName: "camera.viewfinder")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 150)
//                    .foregroundColor(.gray.opacity(0.4))
//            )
//    }
//}
//
//struct FocusZoneOverlay: View {
//    let size: CGFloat = 280
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 16)
//                .stroke(Color.white.opacity(0.8), lineWidth: 3)
//                .frame(width: size, height: size * 0.6)
//                .shadow(color: .black.opacity(0.7), radius: 5, x: 0, y: 2)
//            
//            // Optional: Add corner brackets for visual flair
//            Path { path in
//                let cornerLength: CGFloat = 30
//                let rect = CGRect(x: -size/2, y: -size*0.6/2, width: size, height: size*0.6)
//                
//                // Top Left
//                path.move(to: CGPoint(x: rect.minX + cornerLength, y: rect.minY))
//                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
//                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerLength))
//                // Top Right... etc. (Can be added if desired)
//            }
//            .stroke(Color.blue, lineWidth: 4) // Example color
//            
//            Text("Align Barcode Here")
//                .font(.caption)
//                .foregroundColor(.white)
//                .padding(.horizontal, 8).padding(.vertical, 4)
//                .background(Color.black.opacity(0.5))
//                .cornerRadius(4)
//                .frame(maxWidth: size, maxHeight: size * 0.6, alignment: .bottom)
//                .padding(.bottom, 10)
//            
//        }
//    }
//}
//
//struct BottomControlsOverlay: View {
//    @Binding var isFlashlightOn: Bool
//    // Add actions for buttons if needed
//    var modeAction: () -> Void = {}
//    var manualEntryAction: () -> Void = {}
//    
//    var body: some View {
//        HStack(alignment: .center, spacing: 15) {
//            // Mode Button (Example)
//            Button { modeAction() } label: {
//                Text("Standard Mode")
//                    .font(.system(size: 14, weight: .medium))
//                    .padding(.horizontal, 16).padding(.vertical, 8)
//                    .background(.ultraThinMaterial) // Use material background
//                    .foregroundColor(.primary)
//                    .cornerRadius(20)
//                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
//            }
//            
//            Spacer()
//            
//            // Right Controls (Flashlight, Manual)
//            HStack(spacing: 20) {
//                Button { isFlashlightOn.toggle() } label: {
//                    Image(systemName: isFlashlightOn ? "bolt.fill" : "bolt.slash.fill")
//                        .font(.system(size: 20))
//                        .frame(width: 44, height: 44)
//                        .background(.ultraThinMaterial)
//                        .foregroundColor(isFlashlightOn ? .yellow : .primary)
//                        .clipShape(Circle())
//                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
//                }
//                
//                Button { manualEntryAction() } label: {
//                    Image(systemName: "square.and.pencil") // Manual Entry Icon
//                        .font(.system(size: 20))
//                        .frame(width: 44, height: 44)
//                        .background(.ultraThinMaterial)
//                        .foregroundColor(.primary)
//                        .clipShape(Circle())
//                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
//                }
//            }
//        }
//        .padding(.horizontal)
//        .padding(.bottom, 10) // Padding from bottom edge
//    }
//}
//
//// MARK: - Main Tab Views
//
//// --- Scan View ---
//struct ScanView: View {
//    @State private var isFlashlightOn = false
//    
//    var body: some View {
//        // Use NavigationView for the toolbar
//        NavigationView {
//            ZStack {
//                CameraPreviewPlaceholder().edgesIgnoringSafeArea(.all)
//                FocusZoneOverlay() // Centered focus zone
//                
//                VStack {
//                    Spacer() // Pushes controls to bottom
//                    BottomControlsOverlay(isFlashlightOn: $isFlashlightOn, modeAction: {
//                        print("Mode button tapped")
//                    }, manualEntryAction: {
//                        print("Manual entry tapped")
//                        // Present a sheet or navigate for manual entry
//                    })
//                    .padding(.bottom, 20) // Add safe area padding or manual padding
//                }
//            }
//            // Hide the default navigation bar if the design is full-screen
//            .navigationBarHidden(true)
//            // Or configure toolbar if using a standard nav bar appearance:
//            /*
//             .navigationTitle("Scan Item")
//             .navigationBarTitleDisplayMode(.inline)
//             .toolbar {
//             ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") {} }
//             // Add other toolbar items if needed
//             }
//             */
//        }
//        // Important: Use StackNavigationViewStyle if embedding within TabView to avoid layout issues
//        .navigationViewStyle(StackNavigationViewStyle())
//    }
//}
//
//// --- Inventory View ---
//struct InventoryView: View {
//    @Binding var inventoryItems: [InventoryItem]
//    @State private var searchText: String = ""
//    @State private var sortOrder: [KeyPathComparator<InventoryItem>] = [
//        .init(\.scanDate, order: .reverse) // Default sort: newest first
//    ]
//    
//    // Computed property for filtering/searching
//    var filteredItems: [InventoryItem] {
//        let baseItems: [InventoryItem]
//        if searchText.isEmpty {
//            baseItems = inventoryItems
//        } else {
//            baseItems = inventoryItems.filter {
//                $0.name.localizedCaseInsensitiveContains(searchText) ||
//                $0.barcode.localizedCaseInsensitiveContains(searchText)
//            }
//        }
//        // Return items sorted according to the current sortOrder
//        return baseItems.sorted(using: sortOrder)
//    }
//    
//    var body: some View {
//        NavigationView {
//            List {
//                // Use the computed filteredItems which are already sorted
//                ForEach(filteredItems) { item in
//                    // Ensures the destination is correctly instantiated
//                    NavigationLink(destination: InventoryItemDetailView(item: item)) {
//                        InventoryRowView(item: item)
//                    }
//                }
//                .onDelete(perform: deleteItems)
//                
//                // Message for "No results" during search
//                if filteredItems.isEmpty && !searchText.isEmpty && !inventoryItems.isEmpty {
//                    Text("No items match '\(searchText)'")
//                        .foregroundColor(.secondary)
//                        .frame(maxWidth: .infinity, alignment: .center)
//                        .padding(.vertical)
//                }
//            }
//            .listStyle(.plain) // Use plain style for tighter rows
//            .navigationTitle("Inventory")
//            .searchable(text: $searchText, prompt: "Search by Name or Barcode")
//            .overlay { // Show empty state only if the *original* list is empty
//                if inventoryItems.isEmpty {
//                    EmptyInventoryView()
//                }
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    EditButton() // Standard edit button for delete mode
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    // Sort Menu
//                    Menu {
//                        // Picker bound to the sortOrder state variable
//                        Picker("Sort By", selection: $sortOrder) {
//                            Text("Newest First").tag([KeyPathComparator(\InventoryItem.scanDate, order: .reverse)])
//                            Text("Oldest First").tag([KeyPathComparator(\InventoryItem.scanDate, order: .forward)])
//                            Text("Name (A-Z)").tag([KeyPathComparator(\InventoryItem.name, order: .forward)])
//                            Text("Name (Z-A)").tag([KeyPathComparator(\InventoryItem.name, order: .reverse)])
//                            Text("Quantity (Low-High)").tag([KeyPathComparator(\InventoryItem.quantity, order: .forward)])
//                            Text("Quantity (High-Low)").tag([KeyPathComparator(\InventoryItem.quantity, order: .reverse)])
//                        }.pickerStyle(.inline) // Use inline style within the menu
//                    } label: {
//                        Label("Sort", systemImage: "arrow.up.arrow.down.circle")
//                    }
//                }
//            }
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//    }
//    
//    // Function to handle deleting items
//    private func deleteItems(at offsets: IndexSet) {
//        // 1. Get the IDs of the items to be deleted from the *currently displayed* list (filteredItems)
//        let idsToDelete = offsets.map { filteredItems[$0].id }
//        
//        // 2. Remove items from the *original* source array (`inventoryItems`) based on their IDs
//        inventoryItems.removeAll { item in
//            idsToDelete.contains(item.id)
//        }
//    }
//}
//
//// --- Settings View ---
//struct SettingsView: View {
//    // Persistent settings via UserDefaults
//    @AppStorage("playSoundOnScan") private var playSoundOnScan: Bool = true
//    @AppStorage("vibrateOnScan") private var vibrateOnScan: Bool = true
//    // Add more settings as needed...
//    //@AppStorage("defaultScanMode") private var defaultScanMode: String = "Single"
//    
//    // State for confirmation dialogs
//    @State private var showingClearDataAlert = false
//    
//    // Binding to inventoryItems for the "Clear Data" action
//    @Binding var inventoryItems: [InventoryItem]
//    
//    // App Info
//    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
//    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                // MARK: Scanning Preferences
//                Section(header: Text("Scanning"), footer: Text("Haptic and audio feedback during scans.")) {
//                    Toggle(isOn: $playSoundOnScan) {
//                        Label("Sound Feedback", systemImage: "speaker.wave.2.fill")
//                    }
//                    
//                    Toggle(isOn: $vibrateOnScan) {
//                        Label("Haptic Feedback (Vibrate)", systemImage: "iphone.gen1.radiowaves.left.and.right")
//                    }
//                    /* Example Picker
//                     Picker("Default Scan Mode", selection: $defaultScanMode) {
//                     Text("Single Scan").tag("Single")
//                     Text("Continuous Scan").tag("Continuous")
//                     }
//                     */
//                }
//                
//                // MARK: Data Management
//                Section("Data Management") {
//                    Button {
//                        print("Export Data Tapped")
//                        // TODO: Implement export functionality (e.g., generate CSV, show UIActivityViewController)
//                    } label: {
//                        Label("Export Inventory Data...", systemImage: "square.and.arrow.up")
//                            .foregroundColor(.primary) // Ensure text is interactive looking
//                    }
//                    
//                    Button {
//                        print("Import Data Tapped")
//                        // TODO: Implement import functionality (e.g., UIDocumentPickerViewController)
//                    } label: {
//                        Label("Import Inventory Data...", systemImage: "square.and.arrow.down")
//                            .foregroundColor(.primary)
//                    }
//                    
//                    Button(role: .destructive) {
//                        showingClearDataAlert = true // Trigger confirmation
//                    } label: {
//                        Label("Clear All Inventory Data", systemImage: "trash")
//                    }
//                }
//                
//                // MARK: Support
//                Section("Support") {
//                    Link(destination: URL(string: "https://www.example.com/help")!) { // Replace URL
//                        Label("Help & FAQ", systemImage: "questionmark.circle")
//                    }
//                    Link(destination: URL(string: "mailto:support@example.com")!) { // Replace email
//                        Label("Contact Support", systemImage: "lifepreserver")
//                    }
//                    Link(destination: URL(string: "https://www.example.com/feedback")!) { // Replace URL
//                        Label("Send Feedback", systemImage: "paperplane") // Alternate icon
//                    }
//                }
//                
//                // MARK: About
//                Section("About") {
//                    HStack {
//                        Text("App Version")
//                        Spacer()
//                        Text("\(appVersion) (\(buildNumber))")
//                            .foregroundColor(.secondary)
//                    }
//                    Link(destination: URL(string: "https://www.example.com/privacy")!) { // Replace URL
//                        Label("Privacy Policy", systemImage: "lock.shield")
//                    }
//                    Link(destination: URL(string: "https://www.example.com/terms")!) { // Replace URL
//                        Label("Terms of Service", systemImage: "doc.text")
//                    }
//                }
//            }
//            .navigationTitle("Settings")
//            .navigationBarTitleDisplayMode(.inline)
//            .alert("Clear All Inventory Data?", isPresented: $showingClearDataAlert) {
//                Button("Cancel", role: .cancel) { }
//                Button("Clear Data", role: .destructive) {
//                    print("Clearing all inventory data confirmed.")
//                    inventoryItems.removeAll() // Perform the clear action
//                }
//            } message: {
//                Text("This action is permanent and cannot be undone. All item records will be deleted.")
//            }
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//    }
//}
//
//// --- Admin View ---
//struct AdminView: View {
//    @Binding var inventoryItems: [InventoryItem]
//    
//    // State for feedback/results
//    @State private var dataCheckResult: String? = nil
//    @State private var systemStatus: String = "Status checks not run yet."
//    @State private var showingClearLogsAlert = false
//    @State private var showingArchiveConfirmAlert = false
//    
//    // Computed properties for quick data summaries
//    private var itemsWithEmptyNames: Int { inventoryItems.filter { $0.name.trimmingCharacters(in: .whitespaces).isEmpty }.count }
//    private var potentialDuplicateBarcodeGroups: Int { Dictionary(grouping: inventoryItems, by: { $0.barcode }).filter { $1.count > 1 }.count }
//    private var itemsWithZeroOrLessQuantity: Int { inventoryItems.filter { $0.quantity <= 0 }.count }
//    private var itemsOlderThan90Days: Int {
//        let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
//        return inventoryItems.filter { $0.scanDate < ninetyDaysAgo }.count
//    }
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                // MARK: Data Health Checks
//                Section("Data Health") {
//                    // Wrap ALL content within this VStack
//                    VStack(alignment: .leading, spacing: 10) { // Use leading alignment for the outer stack
//                        
//                        // Original VStack containing StatusRows
//                        VStack(alignment: .leading, spacing: 10) {
//                            StatusRow(label: "Items with Empty Names:", value: "\(itemsWithEmptyNames)", statusColor: itemsWithEmptyNames > 0 ? .red : .green)
//                            StatusRow(label: "Duplicate Barcode Groups:", value: "\(potentialDuplicateBarcodeGroups)", statusColor: potentialDuplicateBarcodeGroups > 0 ? .orange : .green)
//                            // Corrected logic for statusColor here:
//                            StatusRow(label: "Items with <= 0 Quantity:", value: "\(itemsWithZeroOrLessQuantity)", statusColor: itemsWithZeroOrLessQuantity > 0 ? .orange : .green)
//                        }
//                        .padding(.vertical, 5) // Add padding within the section
//                        
//                        // The Button
//                        Button {
//                            // Perform more complex check if needed & update result text
//                            dataCheckResult = """
//                                            Check completed at \(Date()).
//                                            Found \(itemsWithEmptyNames) empty names, \(potentialDuplicateBarcodeGroups) duplicate barcode groups, \(itemsWithZeroOrLessQuantity) items with zero or negative quantity.
//                                            """
//                            print("Run Data Health Check Tapped")
//                        } label: {
//                            Label("Run Full Data Check", systemImage: "heart.text.square") // More relevant icon
//                        }
//                        // Add slight top padding to separate button
//                        .padding(.top, 5)
//                        
//                        // The conditional Text block
//                        if let result = dataCheckResult {
//                            Text(result)
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                                .padding(.top, 5) // Keep padding for separation
//                        }
//                    } // End of the wrapping VStack
//                }
//                
//                // MARK: System Operations
//                Section("System Operations") {
//                    Button {
//                        guard itemsOlderThan90Days > 0 else { return } // Don't show alert if nothing to archive
//                        showingArchiveConfirmAlert = true
//                    } label: {
//                        Label("Archive Items Older Than 90 Days (\(itemsOlderThan90Days))", systemImage: "archivebox")
//                    }
//                    .disabled(itemsOlderThan90Days == 0) // Disable if no items qualify
//                    
//                    Button(role: .destructive) {
//                        showingClearLogsAlert = true
//                    } label: {
//                        Label("Clear Diagnostic Logs (Simulated)", systemImage: "doc.text.magnifyingglass")
//                    }
//                }
//                
//                // MARK: System Status (Simulated)
////                Section("System Status") {
////                    // The VStack containing StatusRows is one view within the Section
////                    VStack(alignment: .leading, spacing: 10) {
////                        StatusRow(label: "Backend Connection:", value: "Connected", statusColor: .green)
////                        StatusRow(label: "Database Size:", value: "15.2 MB", statusColor: .gray)
////                        StatusRow(label: "Last Backup:", value: "Today, 3:15 AM", statusColor: .gray)
////                    }
////                    // .padding(.vertical, 5)  // <-- REMOVE THIS LINE
////
////                    // The Button is the second view within the Section
////                    Button {
////                        // Simulate refreshing status
////                        systemStatus = "Status Refreshed: \(Date(), style: .time). All systems nominal."
////                        print("Refresh System Status Tapped")
////                    } label: {
////                        Label("Refresh Live Status", systemImage: "arrow.clockwise")
////                    }
////
////                    // The Text is the third view within the Section
////                    Text(systemStatus)
////                        .font(.caption)
////                        .foregroundColor(.secondary)
////                        .padding(.top, 5) // Padding applied *here* to the Text is fine
////                }
//                
//                // MARK: User Management (Conceptual/Placeholder)
//                Section("User Administration") {
//                    // Correctly use NavigationLink
//                    NavigationLink(destination: PlaceholderView(text: "User Management", showNavigationTitle: true)) {
//                        Label("Manage Users & Roles", systemImage: "person.2.badge.gearshape.fill") // More specific icon
//                    }
//                }
//            }
//            .navigationTitle("Admin Panel")
//            .navigationBarTitleDisplayMode(.inline)
//            .alert("Clear Diagnostic Logs?", isPresented: $showingClearLogsAlert) { // Alert for logs
//                Button("Cancel", role: .cancel) { }
//                Button("Clear Logs", role: .destructive) {
//                    print("Clearing diagnostic logs (Simulated).")
//                    // TODO: Implement actual log clearing if applicable
//                }
//            } message: {
//                Text("This will remove historical diagnostic data. Current system operation is unaffected.")
//            }
//            .alert("Archive Old Items?", isPresented: $showingArchiveConfirmAlert) { // Alert for archiving
//                Button("Cancel", role: .cancel) {}
//                Button("Archive \(itemsOlderThan90Days) Items", role: .destructive) {
//                    print("Archiving \(itemsOlderThan90Days) items older than 90 days.")
//                    // TODO: Implement actual archiving logic
//                    // Example: remove items from the main list
//                    let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
//                    inventoryItems.removeAll { $0.scanDate < ninetyDaysAgo }
//                }
//            } message: {
//                Text("This will remove \(itemsOlderThan90Days) items scanned more than 90 days ago from the active inventory. This action might be irreversible depending on implementation.")
//            }
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//    }
//}
//
//// Helper View for Status Rows in Admin
//struct StatusRow: View {
//    let label: String
//    let value: String
//    let statusColor: Color
//    
//    var body: some View {
//        HStack {
//            Text(label)
//            Spacer()
//            Text(value)
//                .foregroundColor(statusColor == .gray ? .secondary : statusColor) // Use secondary for neutral status
//                .fontWeight(statusColor != .gray ? .medium : .regular)
//        }
//    }
//}
//
//// MARK: - Main App Container (TabView)
//
//struct ContentView: View {
//    // State for the selected tab. Start on Inventory (index 1) for easy viewing.
//    @State private var selectedTab = 1
//    
//    // Main data source for the app.
//    // In a real app, replace this with @StateObject ViewModel pattern
//    @State private var inventoryItems: [InventoryItem] = InventoryItem.generateSampleData(count: 25)
//    
//    var body: some View {
//        TabView(selection: $selectedTab) {
//            // --- Scan Tab ---
//            ScanView()
//                .tabItem { Label("Scan", systemImage: "barcode.viewfinder") }
//                .tag(0)
//            
//            // --- Inventory Tab ---
//            InventoryView(inventoryItems: $inventoryItems) // Pass binding
//                .tabItem { Label("Inventory", systemImage: "list.bullet.rectangle.portrait") } // Better icon
//                .tag(1)
//            
//            // --- IO Tab (Using Placeholder) ---
//            PlaceholderView(text: "Import / Export", showNavigationTitle: true) // Placeholder for IO
//                .tabItem { Label("I / O", systemImage: "arrow.left.arrow.right.square") } // Better icon
//                .tag(2)
//            
//            // --- Admin Tab ---
//            AdminView(inventoryItems: $inventoryItems) // Pass binding
//                .tabItem { Label("Admin", systemImage: "hammer.fill") } // Alt icon
//                .tag(3)
//            
//            // --- Settings Tab ---
//            SettingsView(inventoryItems: $inventoryItems) // Pass binding
//                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
//                .tag(4)
//        }
//        // Apply accent color globally if desired
//        .accentColor(.blue)
//        // Handle potential persistence loading here if not using ViewModel
//        .onAppear {
//            // Load inventoryItems from storage if necessary
//            // Load AppStorage settings (though @AppStorage handles this automatically)
//        }
//    }
//}
//
//// MARK: - Preview Provider
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Preview the main ContentView
//        ContentView()
//            .previewDisplayName("Full App")
//        
//        // Preview Inventory Screen directly
//        NavigationView { // Wrap for context
//            InventoryView(inventoryItems: .constant(InventoryItem.generateSampleData(count: 10)))
//        }
//        .previewDisplayName("Inventory Screen")
//        
//        // Preview Inventory Row
//        InventoryRowView(item: InventoryItem.generateSampleData(count: 1)[0])
//            .padding()
//            .previewLayout(.sizeThatFits)
//            .previewDisplayName("Inventory Row")
//        
//        // Preview Empty Inventory
//        NavigationView { // Wrap for context
//            InventoryView(inventoryItems: .constant([]))
//        }
//        .previewDisplayName("Empty Inventory")
//        
//        // Preview Detail Screen
//        NavigationView { // Wrap for context
//            InventoryItemDetailView(item: InventoryItem.generateSampleData(count: 1)[0])
//        }
//        .previewDisplayName("Item Detail Screen")
//        
//        // Preview Settings Screen
//        SettingsView(inventoryItems: .constant(InventoryItem.generateSampleData(count: 5)))
//            .previewDisplayName("Settings Screen")
//        
//        // Preview Admin Screen
//        AdminView(inventoryItems: .constant(InventoryItem.generateSampleData(count: 30)))
//            .previewDisplayName("Admin Screen")
//        
//        // Preview Scan Screen
//        ScanView()
//            .previewDisplayName("Scan Screen")
//    }
//}
