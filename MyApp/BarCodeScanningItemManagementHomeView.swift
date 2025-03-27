//
//  BarCodeScanningItemManagementHomeVie.swift
//  MyApp
//
//  Created by Cong Le on 3/27/25.
//

//
//import SwiftUI
//
//// Main container view with the TabView
//struct BarCodeScanningItemManagementHomeView: View {
//    @State private var selectedTab = 0 // State to track the selected tab
//
//    var body: some View {
//        // Use TabView for the bottom navigation bar
//        TabView(selection: $selectedTab) {
//            // --- Scan Tab ---
//            ScanView()
//                .tabItem {
//                    Label("Scan", systemImage: "barcode.viewfinder")
//                }
//                .tag(0)
//
//            // --- Inventory Tab (Placeholder) ---
//            PlaceholderView(text: "Inventory Screen")
//                .tabItem {
//                    Label("Inventory", systemImage: "house.fill")
//                }
//                .tag(1)
//
//            // --- IO Tab (Placeholder) ---
//            PlaceholderView(text: "IO Screen")
//                .tabItem {
//                    Label("IO", systemImage: "arrow.left.arrow.right")
//                }
//                .tag(2)
//
//            // --- Admin Tab (Placeholder) ---
//            PlaceholderView(text: "Admin Screen")
//                .tabItem {
//                    Label("Admin", systemImage: "crown.fill")
//                }
//                .tag(3)
//
//            // --- Settings Tab (Placeholder) ---
//            PlaceholderView(text: "Settings Screen")
//                .tabItem {
//                    Label("Settings", systemImage: "gearshape.fill")
//                }
//                .tag(4)
//        }
//        // Optional: Set accent color for the selected tab item
//        .accentColor(.blue)
//    }
//}
//
//// View for the main scanning screen content
//struct ScanView: View {
//    @State private var isFlashlightOn = false // State for flashlight toggle
//
//    var body: some View {
//        NavigationView { // Embed in NavigationView for potential title/bar
//            ZStack {
//                // 1. Camera Preview Placeholder
//                CameraPreviewPlaceholder()
//                    .edgesIgnoringSafeArea(.all) // Make it fill the entire background
//                
//                // 2. Focus Zone Overlay
//                FocusZoneOverlay()
//
//                // 3. Bottom Controls Overlay
//                VStack {
//                    Spacer() // Pushes the controls to the bottom
//                    BottomControlsOverlay(isFlashlightOn: $isFlashlightOn)
//                        .padding(.horizontal)
//                        .padding(.bottom, 10) // Add padding above the tab bar area
//                }
//            }
//             // Use inline display mode for a cleaner look if desired
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar { // Add a Toolbar for the header text conceptually
//                ToolbarItem(placement: .principal) {
//                    Text("Scan Barcode / QRCode")
//                        .font(.largeTitle).bold()
//                        .foregroundColor(.white) // Assuming blue header background applied elsewhere or part of nav bar style
//                }
//            }
//            // If you want a blue Navigation Bar background:
//            // This requires custom appearance setup usually done in AppDelegate/SceneDelegate
//            // or using libraries/custom modifiers for SwiftUI.
//            // For simplicity, we'll omit the blue background here, focusing on view structure.
//        }
//        // Hide the default navigation bar if the blue header is managed differently
//        // .navigationBarHidden(true)
//        
//        // Prevent NavView from adding extra space if not needed
//        .navigationViewStyle(StackNavigationViewStyle())
//    }
//}
//
//// Placeholder for the Camera Preview
//struct CameraPreviewPlaceholder: View {
//    var body: some View {
//        // In a real app, this would be replaced by a UIViewRepresentable
//        // hosting an AVCaptureVideoPreviewLayer.
//        Color.black // Simple black background to represent the camera feed
//            .overlay(
//                 // Add a subtle texture or image if desired for visual representation
//                 Image(systemName: "camera") // Example placeholder icon
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 100, height: 100)
//                    .foregroundColor(.gray.opacity(0.5))
//            )
//    }
//}
//
//// Overlay for the Focus Zone indicator
//struct FocusZoneOverlay: View {
//    let focusZoneSize: CGFloat = 280 // Approximate size from screenshot
//
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 16)
//                .stroke(Color.white, lineWidth: 2)
//                .frame(width: focusZoneSize, height: focusZoneSize * 0.6) // Adjust aspect ratio
//
//            Text("focus zone")
//                .font(.caption)
//                .foregroundColor(.white)
//                .padding(4)
//                .background(Color.black.opacity(0.4))
//                .cornerRadius(4)
//                .frame(maxWidth: focusZoneSize, maxHeight: focusZoneSize * 0.6, alignment: .bottomTrailing)
//                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 10))
//
//        }
//        // Add a slight shadow for depth if needed
//         .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
//    }
//}
//
//// Overlay containing the bottom control buttons
//struct BottomControlsOverlay: View {
//    @Binding var isFlashlightOn: Bool
//
//    var body: some View {
//        HStack(alignment: .center) {
//            // Standard Mode Button
//            Button("Standard mode") {
//                // Action for standard mode
//                print("Standard mode tapped")
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 10)
//            .background(Color.blue.opacity(0.9))
//            .foregroundColor(.white)
//            .font(.system(size: 14, weight: .medium))
//            .cornerRadius(20)
//            .shadow(radius: 3)
//
//            Spacer() // Pushes buttons apart
//
//            // Flashlight and Scan Trigger Buttons
//            HStack(spacing: 15) {
//                // Flashlight Toggle Button
//                Button {
//                    isFlashlightOn.toggle()
//                    print("Flashlight toggled: \(isFlashlightOn)")
//                    // Add flashlight control logic here
//                } label: {
//                    Image(systemName: isFlashlightOn ? "bolt.fill" : "bolt.slash.fill")
//                        .font(.system(size: 20))
//                        .frame(width: 44, height: 44)
//                        .background(isFlashlightOn ? Color.yellow.opacity(0.8) : Color.gray.opacity(0.7))
//                        .foregroundColor(isFlashlightOn ? .black : .white)
//                        .clipShape(Circle())
//                         .shadow(radius: 3)
//                }
//
//                // Scan Trigger/Action Button (Visually highlighted)
//                Button {
//                    // Action for scan trigger
//                    print("Scan trigger tapped")
//                } label: {
//                    Image(systemName: "barcode.viewfinder") // Using barcode icon
//                        .font(.system(size: 24))
//                         .frame(width: 44, height: 44)
//                        .background(Color.blue.opacity(0.9))
//                        .foregroundColor(.white)
//                        .clipShape(Circle())
//                        .shadow(radius: 3)
//                }
//            }
//        }
//    }
//}
//
//// Generic Placeholder View for other tabs
//struct PlaceholderView: View {
//    let text: String
//
//    var body: some View {
//        NavigationView { // Give each tab its own Nav context if needed
//            VStack{
//                 Text(text)
//                    .font(.title)
//                    .foregroundColor(.gray)
//            }
//            .navigationTitle(text) // Set title for the placeholder
//             // Use inline display mode for consistency
//            .navigationBarTitleDisplayMode(.inline)
//        }
//         // Prevent NavView from adding extra space if not needed
//        .navigationViewStyle(StackNavigationViewStyle())
//    }
//}
//
//// --- Preview Provider ---
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        BarCodeScanningItemManagementHomeView()
//    }
//}

import SwiftUI

// MARK: - Data Model

struct InventoryItem: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var barcode: String
    var scanDate: Date
    var quantity: Int
    var imageName: String? // Placeholder for image name/URL

    // Sample data generator
    static func generateSampleData(count: Int) -> [InventoryItem] {
        let sampleNames = ["Organic Facial Cleanser", "Repairing Hand Cream", "Hydrating Serum", "Exfoliating Scrub", "Vitamin C Brightener", "Sunscreen SPF 50", "Night Renewal Cream"]
        let sampleImages = ["skincare.tube.fill", "hand.raised.fill", "eyedropper.halffull", "bubbles.and.sparkles", "sun.max.fill", "moon.stars.fill"] // Example system icons
        
        return (1...count).map { i in
            InventoryItem(
                name: "\(sampleNames.randomElement() ?? "Product") \(i)",
                barcode: "1234567890\(i)",
                scanDate: Calendar.current.date(byAdding: .day, value: -Int.random(in: 1...30), to: Date()) ?? Date(),
                quantity: Int.random(in: 1...5),
                imageName: i % 3 == 0 ? nil : sampleImages.randomElement() // Some items without images
            )
        }
    }
}

// MARK: - Main TabView Container

struct ContentView: View {
    @State private var selectedTab = 1 // Start on Inventory tab for demonstration

    // Sample inventory data (replace with ViewModel/Data Persistence later)
    @State private var inventoryItems: [InventoryItem] = InventoryItem.generateSampleData(count: 15)

    var body: some View {
        TabView(selection: $selectedTab) {
            // --- Scan Tab ---
            ScanView() // Using the previously defined ScanView
                .tabItem {
                    Label("Scan", systemImage: "barcode.viewfinder")
                }
                .tag(0)

            // --- Inventory Tab ---
            InventoryView(inventoryItems: $inventoryItems) // Pass the data binding
                .tabItem {
                    Label("Inventory", systemImage: "house.fill")
                }
                .tag(1)

            // --- IO Tab (Placeholder) ---
             PlaceholderView(text: "IO Screen")
                 .tabItem {
                     Label("IO", systemImage: "arrow.left.arrow.right")
                 }
                 .tag(2)

            // --- Admin Tab (Placeholder) ---
             PlaceholderView(text: "Admin Screen")
                 .tabItem {
                     Label("Admin", systemImage: "crown.fill")
                 }
                 .tag(3)

            // --- Settings Tab (Placeholder) ---
             PlaceholderView(text: "Settings Screen")
                 .tabItem {
                     Label("Settings", systemImage: "gearshape.fill")
                 }
                 .tag(4)
        }
        .accentColor(.blue) // Consistent accent color
    }
}

// MARK: - Scan View (From Previous Response - Abbreviated)

struct ScanView: View {
    @State private var isFlashlightOn = false

    var body: some View {
        NavigationView {
            ZStack {
                CameraPreviewPlaceholder().edgesIgnoringSafeArea(.all)
                FocusZoneOverlay()
                VStack {
                    Spacer()
                    BottomControlsOverlay(isFlashlightOn: $isFlashlightOn)
                        .padding(.horizontal).padding(.bottom, 10)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Scan Barcode / QRCode")
                        .font(.headline).bold() // Adjusted size slightly
                        .foregroundColor(.primary) // Standard color adapts
                }
            }
            // If using standard nav bar look:
            // .navigationTitle("Scan Barcode / QRCode")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Inventory View Implementation

struct InventoryView: View {
    @Binding var inventoryItems: [InventoryItem]
    @State private var searchText: String = ""
    @State private var sortOrder: [KeyPathComparator<InventoryItem>] = [
        .init(\.scanDate, order: .reverse) // Default sort: newest first
    ] // For sorting if needed

    // Computed property for filtering based on search text
    var filteredItems: [InventoryItem] {
        if searchText.isEmpty {
            // Return sorted items when no search text
             return inventoryItems.sorted(using: sortOrder)
        } else {
            // Filter and sort based on search text (name or barcode)
            return inventoryItems.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.barcode.localizedCaseInsensitiveContains(searchText)
            }
             .sorted(using: sortOrder)
        }
    }

    var body: some View {
        NavigationView {
            List {
                // Check if the filtered list is empty *after* applying search
                if filteredItems.isEmpty && !inventoryItems.isEmpty {
                     Text("No items match your search.")
                         .foregroundColor(.secondary)
                         .frame(maxWidth: .infinity, alignment: .center)
                         .padding(.vertical)
                 }

                // Iterate over the filtered and sorted items
                ForEach(filteredItems) { item in
                    // NavigationLink to a potential detail view
                    NavigationLink(destination: InventoryItemDetailView(item: item)) {
                         InventoryRowView(item: item)
                    }
                }
                .onDelete(perform: deleteItems) // Enable swipe-to-delete
            }
            .navigationTitle("Inventory")
            .searchable(text: $searchText, prompt: "Search by name or barcode") // Add search bar
            .overlay {
                 // Show empty state if the *original* list is empty
                 if inventoryItems.isEmpty {
                     EmptyInventoryView()
                 }
            }
            .toolbar {
                // Example Toolbar Items
                 ToolbarItem(placement: .navigationBarLeading) {
                      EditButton() // Toggles multi-select mode / delete mode
                 }
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Menu {
                          Picker("Sort By", selection: $sortOrder) {
                             Text("Newest First").tag([KeyPathComparator(\InventoryItem.scanDate, order: .reverse)])
                             Text("Oldest First").tag([KeyPathComparator(\InventoryItem.scanDate, order: .forward)])
                             Text("Name (A-Z)").tag([KeyPathComparator(\InventoryItem.name, order: .forward)])
                             Text("Name (Z-A)").tag([KeyPathComparator(\InventoryItem.name, order: .reverse)])
                             Text("Quantity (Low-High)").tag([KeyPathComparator(\InventoryItem.quantity, order: .forward)])
                             Text("Quantity (High-Low)").tag([KeyPathComparator(\InventoryItem.quantity, order: .reverse)])
                         }
                     } label: {
                         Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                     }
                 }
                // Optional: Add a button to manually add items
                // ToolbarItem(placement: .navigationBarTrailing) {
                //     Button {
                //         // Add manual item action
                //     } label: {
                //         Label("Add Item", systemImage: "plus.circle.fill")
                //     }
                // }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Consistent style
    }

    // Function to handle deleting items from the list
    private func deleteItems(at offsets: IndexSet) {
        // Get the IDs of the items to be deleted based on the *currently displayed* filtered list
        let idsToDelete = offsets.map { filteredItems[$0].id }
        
        // Remove items from the original source array based on their IDs
        inventoryItems.removeAll { idsToDelete.contains($0.id) }
    }
}

// MARK: - Row View for Inventory List

struct InventoryRowView: View {
    let item: InventoryItem

    var body: some View {
        HStack(spacing: 15) {
            // Item Image (using AsyncImage for URLs or Placeholder)
             Image(systemName: item.imageName ?? "photo.on.rectangle.angled") // Use placeholder if no image
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(width: 50, height: 50)
                 .padding(5) // Padding inside the frame
                 .background(Color.gray.opacity(0.1)) // Subtle background for frame
                 .cornerRadius(8)
                 .foregroundColor(item.imageName == nil ? .secondary : .blue) // Color placeholder differently

            // Item Details (Name and Subtitle)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(2) // Allow up to 2 lines for name

                Text("Scanned: \(item.scanDate, style: .date)") // Formatted date
                    .font(.caption)
                    .foregroundColor(.secondary)
                // Optionally show barcode:
                // Text("Barcode: \(item.barcode)")
                //     .font(.caption2)
                //     .foregroundColor(.gray)
            }

            Spacer() // Push quantity to the right

            // Quantity Display
            Text("Qty: \(item.quantity)")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(6)
        }
        .padding(.vertical, 8) // Add padding to the entire row
    }
}

// MARK: - Empty State View

struct EmptyInventoryView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "archivebox") // Relevant icon
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("Inventory is Empty")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Scan items using the 'Scan' tab to add them here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Center it
    }
}

// MARK: - Placeholder Detail View

 struct InventoryItemDetailView: View {
     let item: InventoryItem // Item passed from the list

     var body: some View {
         // Build the detail view layout here
         ScrollView {
             VStack(alignment: .leading, spacing: 20) {
                 // Larger Image
                 Image(systemName: item.imageName ?? "photo.on.rectangle.angled")
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(maxWidth: .infinity)
                     .frame(height: 200)
                     .padding(.vertical)
                     .background(Color.gray.opacity(0.1))
                     .cornerRadius(10)
//                     .foregroundColor(item.imageName == norm ? .secondary : .blue)

                 Text(item.name)
                     .font(.largeTitle)
                     .fontWeight(.bold)

                 HStack {
                     Text("Quantity:")
                         .fontWeight(.semibold)
                     Text("\(item.quantity)")
                     Spacer()
                     Text("Scanned:")
                         .fontWeight(.semibold)
                     Text("\(item.scanDate, format: .dateTime)") // More detailed date/time
                 }
                 .font(.subheadline)
                 .foregroundColor(.secondary)

                 Divider()

                 VStack(alignment: .leading, spacing: 5) {
                     Text("Barcode")
                         .font(.headline)
                     Text(item.barcode)
                         .font(.body)
                         .foregroundColor(.secondary)
                 }

                  // Add more fields like notes, category, etc.
                  // Example:
                  // if let notes = item.notes {
                  //    Text("Notes").font(.headline).padding(.top)
                  //    Text(notes).foregroundColor(.secondary)
                  // }

                 Spacer() // Push content to top
             }
             .padding()
         }
         .navigationTitle("Item Details") // Title for the detail screen
         .navigationBarTitleDisplayMode(.inline) // Keep it consistent
     }
 }

// Placeholder view reused from previous response
struct PlaceholderView: View {
    let text: String
    var body: some View {
        NavigationView{
            VStack{
                 Text(text).font(.title).foregroundColor(.gray)
            }
            .navigationTitle(text)
             .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Supporting Scan View Components (From Previous Response - Abbreviated)
struct CameraPreviewPlaceholder: View { var body: some View { Color.black.overlay(Image(systemName: "camera").resizable().scaledToFit().frame(width: 100).foregroundColor(.gray.opacity(0.5)))}}
struct FocusZoneOverlay: View { let size: CGFloat = 280; var body: some View { ZStack { RoundedRectangle(cornerRadius: 16).stroke(Color.white, lineWidth: 2).frame(width: size, height: size * 0.6); Text("focus zone").font(.caption).foregroundColor(.white).padding(4).background(Color.black.opacity(0.4)).cornerRadius(4).frame(maxWidth: size, maxHeight: size * 0.6, alignment: .bottomTrailing).padding([.bottom, .trailing], 10)}.shadow(color: .black.opacity(0.5), radius: 3) } }
struct BottomControlsOverlay: View { @Binding var isFlashlightOn: Bool; var body: some View { HStack(alignment: .center) { Button("Standard mode") {}.padding(.horizontal, 20).padding(.vertical, 10).background(Color.blue.opacity(0.9)).foregroundColor(.white).font(.system(size: 14, weight: .medium)).cornerRadius(20).shadow(radius: 3); Spacer(); HStack(spacing: 15) { Button { isFlashlightOn.toggle() } label: { Image(systemName: isFlashlightOn ? "bolt.fill" : "bolt.slash.fill").font(.system(size: 20)).frame(width: 44, height: 44).background(isFlashlightOn ? Color.yellow.opacity(0.8) : Color.gray.opacity(0.7)).foregroundColor(isFlashlightOn ? .black : .white).clipShape(Circle()).shadow(radius: 3) }; Button { } label: { Image(systemName: "barcode.viewfinder").font(.system(size: 24)).frame(width: 44, height: 44).background(Color.blue.opacity(0.9)).foregroundColor(.white).clipShape(Circle()).shadow(radius: 3) }}}}}

// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview the ContentView with sample data
        ContentView()

        // Preview the InventoryView directly with sample data
        InventoryView(inventoryItems: .constant(InventoryItem.generateSampleData(count: 5)))
            .previewDisplayName("Inventory View")

        // Preview an empty inventory
        InventoryView(inventoryItems: .constant([]))
            .previewDisplayName("Empty Inventory View")

        // Preview a single row
        InventoryRowView(item: InventoryItem.generateSampleData(count: 1).first!)
            .padding() // Add padding for better preview isolation
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Inventory Row")
            
        // Preview Detail View
         NavigationView { // Wrap in NavView for title context
              InventoryItemDetailView(item: InventoryItem.generateSampleData(count: 1).first!)
         }
         .previewDisplayName("Item Detail View")
    }
}
