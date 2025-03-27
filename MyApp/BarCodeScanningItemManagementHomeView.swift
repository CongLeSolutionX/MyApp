//
//  BarCodeScanningItemManagementHomeVie.swift
//  MyApp
//
//  Created by Cong Le on 3/27/25.
//


import SwiftUI

// Main container view with the TabView
struct BarCodeScanningItemManagementHomeView: View {
    @State private var selectedTab = 0 // State to track the selected tab

    var body: some View {
        // Use TabView for the bottom navigation bar
        TabView(selection: $selectedTab) {
            // --- Scan Tab ---
            ScanView()
                .tabItem {
                    Label("Scan", systemImage: "barcode.viewfinder")
                }
                .tag(0)

            // --- Inventory Tab (Placeholder) ---
            PlaceholderView(text: "Inventory Screen")
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
        // Optional: Set accent color for the selected tab item
        .accentColor(.blue)
    }
}

// View for the main scanning screen content
struct ScanView: View {
    @State private var isFlashlightOn = false // State for flashlight toggle

    var body: some View {
        NavigationView { // Embed in NavigationView for potential title/bar
            ZStack {
                // 1. Camera Preview Placeholder
                CameraPreviewPlaceholder()
                    .edgesIgnoringSafeArea(.all) // Make it fill the entire background
                
                // 2. Focus Zone Overlay
                FocusZoneOverlay()

                // 3. Bottom Controls Overlay
                VStack {
                    Spacer() // Pushes the controls to the bottom
                    BottomControlsOverlay(isFlashlightOn: $isFlashlightOn)
                        .padding(.horizontal)
                        .padding(.bottom, 10) // Add padding above the tab bar area
                }
            }
             // Use inline display mode for a cleaner look if desired
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { // Add a Toolbar for the header text conceptually
                ToolbarItem(placement: .principal) {
                    Text("Scan Barcode / QRCode")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white) // Assuming blue header background applied elsewhere or part of nav bar style
                }
            }
            // If you want a blue Navigation Bar background:
            // This requires custom appearance setup usually done in AppDelegate/SceneDelegate
            // or using libraries/custom modifiers for SwiftUI.
            // For simplicity, we'll omit the blue background here, focusing on view structure.
        }
        // Hide the default navigation bar if the blue header is managed differently
        // .navigationBarHidden(true)
        
        // Prevent NavView from adding extra space if not needed
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// Placeholder for the Camera Preview
struct CameraPreviewPlaceholder: View {
    var body: some View {
        // In a real app, this would be replaced by a UIViewRepresentable
        // hosting an AVCaptureVideoPreviewLayer.
        Color.black // Simple black background to represent the camera feed
            .overlay(
                 // Add a subtle texture or image if desired for visual representation
                 Image(systemName: "camera") // Example placeholder icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray.opacity(0.5))
            )
    }
}

// Overlay for the Focus Zone indicator
struct FocusZoneOverlay: View {
    let focusZoneSize: CGFloat = 280 // Approximate size from screenshot

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white, lineWidth: 2)
                .frame(width: focusZoneSize, height: focusZoneSize * 0.6) // Adjust aspect ratio

            Text("focus zone")
                .font(.caption)
                .foregroundColor(.white)
                .padding(4)
                .background(Color.black.opacity(0.4))
                .cornerRadius(4)
                .frame(maxWidth: focusZoneSize, maxHeight: focusZoneSize * 0.6, alignment: .bottomTrailing)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 10))

        }
        // Add a slight shadow for depth if needed
         .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
    }
}

// Overlay containing the bottom control buttons
struct BottomControlsOverlay: View {
    @Binding var isFlashlightOn: Bool

    var body: some View {
        HStack(alignment: .center) {
            // Standard Mode Button
            Button("Standard mode") {
                // Action for standard mode
                print("Standard mode tapped")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.blue.opacity(0.9))
            .foregroundColor(.white)
            .font(.system(size: 14, weight: .medium))
            .cornerRadius(20)
            .shadow(radius: 3)

            Spacer() // Pushes buttons apart

            // Flashlight and Scan Trigger Buttons
            HStack(spacing: 15) {
                // Flashlight Toggle Button
                Button {
                    isFlashlightOn.toggle()
                    print("Flashlight toggled: \(isFlashlightOn)")
                    // Add flashlight control logic here
                } label: {
                    Image(systemName: isFlashlightOn ? "bolt.fill" : "bolt.slash.fill")
                        .font(.system(size: 20))
                        .frame(width: 44, height: 44)
                        .background(isFlashlightOn ? Color.yellow.opacity(0.8) : Color.gray.opacity(0.7))
                        .foregroundColor(isFlashlightOn ? .black : .white)
                        .clipShape(Circle())
                         .shadow(radius: 3)
                }

                // Scan Trigger/Action Button (Visually highlighted)
                Button {
                    // Action for scan trigger
                    print("Scan trigger tapped")
                } label: {
                    Image(systemName: "barcode.viewfinder") // Using barcode icon
                        .font(.system(size: 24))
                         .frame(width: 44, height: 44)
                        .background(Color.blue.opacity(0.9))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
            }
        }
    }
}

// Generic Placeholder View for other tabs
struct PlaceholderView: View {
    let text: String

    var body: some View {
        NavigationView { // Give each tab its own Nav context if needed
            VStack{
                 Text(text)
                    .font(.title)
                    .foregroundColor(.gray)
            }
            .navigationTitle(text) // Set title for the placeholder
             // Use inline display mode for consistency
            .navigationBarTitleDisplayMode(.inline)
        }
         // Prevent NavView from adding extra space if not needed
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// --- Preview Provider ---
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BarCodeScanningItemManagementHomeView()
    }
}
