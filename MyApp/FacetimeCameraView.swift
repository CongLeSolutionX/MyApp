//
//  FacetimeCameraView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @State private var session = AVCaptureSession()
    @State private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    @State private var isFrontCamera = false // Track camera position

    var body: some View {
        ZStack {
            // Camera Preview
            if let layer = videoPreviewLayer {
                VideoPreview(layer: layer)
                    .edgesIgnoringSafeArea(.all)
            } else {
                // Show a loading indicator or error message if the camera isn't available.
                Color.black.edgesIgnoringSafeArea(.all)
                ProgressView().tint(.white)
            }

            // Top Overlay (Contact Info and Status Bar)
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("6:37") // Replace with dynamic time
                            .font(.system(size: 15, weight: .semibold))
                        HStack {
                            Circle()
                                .fill(.gray)
                                .frame(width: 30, height: 30)
                                .overlay(Text("M").foregroundColor(.white))
                            VStack(alignment: .leading) {
                                Text("Mom")
                                    .font(.headline)
                                Text("FaceTime Video")
                                    .font(.subheadline)
                            }
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        HStack {
                            Image(systemName: "cellularbars")  // Replace with dynamic cellular signal
                            Text("5G+")            // Replace with dynamic network
                            Image(systemName: "battery.100")
                                .foregroundColor(.green) // Replace with dynamic battery level
                        }
                        .font(.system(size: 15))

                        Button(action: {
                            // Handle info button tap (if needed)
                        }) {
                            Image(systemName: "info.circle")
                                .font(.title2)
                        }
                    }
                }
                .padding()
                .foregroundColor(.white)

                Spacer() // Push controls to the top and bottom

                // Bottom Overlay (Control Buttons)
                HStack {
                    ControlButton(imageName: "speaker.wave.2.fill", title: "Speaker")
                    ControlButton(imageName: "camera.fill", title: "Camera")
                    ControlButton(imageName: "mic.slash.fill", title: "Mute")
                    ControlButton(imageName: "person.2.crop.square.stack.fill", title: "Share")
                    ControlButton(imageName: "xmark.circle.fill", title: "End", isDestructive: true)
                }
                .padding(.bottom, 20) // Add padding

                // Capture and Flash
                HStack(spacing: 40){
                   ControlButton(imageName: "star", title: "")
                    ControlButton(imageName: "f.cursive", title: "")
                    Button(action: {
                        toggleCamera()
                    }){
                        Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(.gray.opacity(0.5)))
                    }

                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            setupCaptureSession()
        }
        .onDisappear {
            session.stopRunning() // Stop the session when the view disappears
        }
    }
    func toggleCamera() {
        isFrontCamera.toggle()
        setupCaptureSession()  // Re-setup the session with the new camera
    }

    private func setupCaptureSession() {
           session.stopRunning() // Stop previous session before reconfiguring
           session = AVCaptureSession() // Create a new session
        
            // Request camera access
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    // Select camera (front or back).
                    let discoverySession = AVCaptureDevice.DiscoverySession(
                        deviceTypes: [.builtInWideAngleCamera],
                        mediaType: .video,
                        position: isFrontCamera ? .front : .back
                    )
                    guard let camera = discoverySession.devices.first else {
                        print("No camera found")
                        return
                    }

                    do {
                        // Input
                        let input = try AVCaptureDeviceInput(device: camera)
                        if session.canAddInput(input) {
                            session.addInput(input)
                        }

                        // Output (for preview)
                        let output = AVCaptureVideoDataOutput() // Use data output for more control
                        if session.canAddOutput(output) {
                            session.addOutput(output)
                        }

                        // Configure preview layer
                        DispatchQueue.main.async { // UI updates on main thread
                            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                            videoPreviewLayer?.videoGravity = .resizeAspectFill // Preserve aspect ratio

                        }
                        
                        // Start the session on a background thread
                        DispatchQueue.global(qos: .userInitiated).async {
                                session.startRunning()
                            }

                    } catch {
                        print("Error setting up camera: \(error)")
                        // Handle the error appropriately in your UI.
                    }
                } else {
                    print("Camera access denied")
                    // Handle access denial in your UI (e.g., show an alert).
                }
            }
        }
}

// Custom View for Control Buttons
struct ControlButton: View {
    let imageName: String
    let title: String
    var isDestructive = false

    var body: some View {
        Button(action: {
            // Handle button tap (implement actions)
        }) {
            VStack {
                Image(systemName: imageName)
                    .font(.system(size: 24))
                    .foregroundColor(isDestructive ? .red : .white) // Change color for destructive actions
                    .padding()
                    .background(Circle().fill(isDestructive ? .white.opacity(0.2) : .gray.opacity(0.5))) // Add background
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
    }
}

// Custom View for Video Preview
struct VideoPreview: UIViewRepresentable {
    let layer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.layer.addSublayer(layer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        layer.frame = uiView.bounds // Update layer frame on resize
    }
}

#Preview {
    CameraView()
}
