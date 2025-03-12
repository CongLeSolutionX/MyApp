//
//  SingleScanView.swift
//  MyApp
//
//  Created by Cong Le on 3/11/25.
//

import SwiftUI
import AVFoundation

// A simple model for an inventory item.
struct InventoryItem: Identifiable {
    var id: String { barcode }
    let barcode: String
    var name: String
    var quantity: Int
}

// The main home screen showing existing items and a scan button.
struct HomeView: View {
    @State private var isShowingScanner = false
    @State private var inventoryItems: [InventoryItem] = []
    
    var body: some View {
        NavigationView {
            VStack {
                if inventoryItems.isEmpty {
                    Text("No items in inventory.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(inventoryItems) { item in
                            HStack {
                                Text(item.name)
                                    .font(.body)
                                Spacer()
                                Text("Qty: \(item.quantity)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                Spacer()
                // Scan button to initiate barcode scanning.
                Button(action: {
                    isShowingScanner = true
                }) {
                    Text("Scan Barcode")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Inventory")
            // Present the single scan view as a sheet.
            .sheet(isPresented: $isShowingScanner) {
                SingleScanView { scannedBarcode in
                    // Example lookup and update logic:
                    if let index = inventoryItems.firstIndex(where: { $0.barcode == scannedBarcode }) {
                        inventoryItems[index].quantity += 1
                    } else {
                        let newItem = InventoryItem(barcode: scannedBarcode,
                                                    name: "Item \(scannedBarcode)",
                                                    quantity: 1)
                        inventoryItems.append(newItem)
                    }
                    isShowingScanner = false
                }
            }
        }
    }
}

// A view that simulates the single-scan mode.
// In practice, this view would contain a camera preview and barcode processing.
struct SingleScanView: View {
    // Callback to return the scanned barcode.
    var onScanCompleted: (String) -> Void
    @State private var hasCameraAccess = false
    
    var body: some View {
        VStack(spacing: 20) {
            if hasCameraAccess {
                // Placeholder for Camera Preview.
                Text("Camera Preview (Simulation)")
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                    .padding()
                
                // A button to simulate barcode detection.
                Button(action: {
                    let simulatedBarcode = "1234567890" // Simulated code value.
                    onScanCompleted(simulatedBarcode)
                }) {
                    Text("Simulate Scan")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            } else {
                // Request camera access with a brief message.
                Text("Requesting Camera Permissions...")
                    .onAppear {
                        requestCameraPermission()
                    }
            }
        }
    }
    
    // Dummy permission request for simulation purposes.
    private func requestCameraPermission() {
        // In a full implementation, you would use AVCaptureDevice.requestAccess(for: .video)
        // Here we simulate a successful permission grant after a short delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            hasCameraAccess = true
        }
    }
}

// Preview providers for testing within Xcode.
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

