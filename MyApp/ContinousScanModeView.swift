//
//  ContinousScanModeView.swift
//  MyApp
//
//  Created by Cong Le on 3/11/25.
//

import SwiftUI
import Combine
import AVFoundation

// MARK: - Home Screen (ContentView)
// This view shows the main screen with a button to launch the continuous scan mode.
struct ContinousScanModeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Barcode Inventory App")
                    .font(.largeTitle)
                    .padding()
                
                // Navigation link to Continuous Scan Mode
                NavigationLink(destination: ContinuousScanView()) {
                    Text("Continuous Scan Mode")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Other buttons (e.g., Manual Entry, Single Scan Mode) would be added here.
            }
            .navigationTitle("Home")
        }
    }
}


// MARK: - Continuous Scan View
// This view simulates an active camera preview and continuously scans for barcodes.
// In a real implementation, AVFoundation would be used for a live camera preview and barcode detection.
struct ContinuousScanView: View {
    // Timer published to simulate scan activity and updating a counter (number of scanned items)
    @State private var scanCount: Int = 0
    @State private var isScanning: Bool = true
    @State private var timerCancellable: AnyCancellable?
    
    // Simulated error message in case of scan/update failure
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with simulated camera preview area
            ZStack {
                // Placeholder for Camera Preview with Barcode Detection Overlay
                Rectangle()
                    .fill(Color.black.opacity(0.8))
                    .cornerRadius(12)
                    .overlay(
                        Text("Camera Preview\n(Barcode Detection Overlay)")
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    )
                
                // Overlay counter to show number of scanned items
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(scanCount)")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
                            .accessibilityLabel("Scanned Items Counter")
                        Spacer()
                    }
                }
            }
            .frame(height: 300)
            .padding()
            
            // Display an error message if any error occurs
            if let errorMsg = errorMessage {
                Text(errorMsg)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            // Stop Scan Button that stops scanning and simulates a summary display
            Button(action: stopScanning) {
                Text("Stop Scan")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("Continuous Scan")
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: startScanning)
        .onDisappear(perform: stopTimer)
    }
    
    // Start the simulated continuous scan by starting a timer
    func startScanning() {
        isScanning = true
        // Request camera permission if needed (Note: In production, call AVCaptureDevice.authorizationStatus(for:))
        checkCameraPermission { granted in
            if granted {
                // Start a timer that simulates barcode detection every 2 seconds
                timerCancellable = Timer.publish(every: 2, on: .main, in: .common)
                    .autoconnect()
                    .sink { _ in
                        simulateScan()
                    }
            } else {
                errorMessage = "Camera permission is required. Please enable it in Settings."
                isScanning = false
            }
        }
    }
    
    // Stop scanning and cancel the timer
    func stopScanning() {
        isScanning = false
        stopTimer()
        // In a real app, you would navigate to a summary screen showing the scanned items.
        // For this demo we simply print the summary.
        print("Scan Summary: \(scanCount) items scanned.")
    }
    
    // Cancel the timer subscription
    func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    // Simulated barcode scan function
    func simulateScan() {
        // In a real implementation, this function would be invoked after a valid barcode is detected.
        // Here we simulate a random failure or a valid scan.
        let success = Bool.random()
        if success {
            // Simulate a successful lookup and update (with haptic feedback, async operations, etc.)
            scanCount += 1
            // Haptic feedback for success could be triggered here:
            // UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            // Show an error message with vibration and sound feedback simulated
            errorMessage = "Invalid Barcode. Try Again."
            // Here, you might trigger haptic error feedback:
            // UINotificationFeedbackGenerator().notificationOccurred(.error)
            // Reset error message after a short delay to keep the view clean.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                errorMessage = nil
            }
        }
    }
    
    // Simplified camera permission check. In practice, handle AVAuthorizationStatus appropriately.
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
}


// MARK: - Preview Provider
struct ContinousScanModeView_Previews: PreviewProvider {
    static var previews: some View {
        ContinousScanModeView()
    }
}
