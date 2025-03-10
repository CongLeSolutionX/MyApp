//
//  SingleSceneCaptureScreen.swift
//  MyApp
//
//  Created by Cong Le on 3/10/25.
//

import SwiftUI
import AVFoundation

// MARK: - Camera Preview (UIViewRepresentable)
// This wrapper allows us to embed an AVCaptureVideoPreviewLayer into SwiftUI.
struct CameraPreview: UIViewRepresentable {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    var session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        // Update view if needed
    }
}

// MARK: - Single Scene Capture Screen
struct SingleSceneCaptureScreen_Full_Implementation: View {
    // Manage the capture session
    @StateObject private var cameraManager = CameraManager()
    // States to transition between capture, preview, and retry the capture if needed
    @State private var captureSuccessful = false
    @State private var showPreview = false
    
    var body: some View {
        ZStack {
            // Live camera feed
            CameraPreview(session: cameraManager.captureSession)
                .ignoresSafeArea()
                .onAppear {
                    cameraManager.startSession()
                }
                .onDisappear {
                    cameraManager.stopSession()
                }
            
            // Guidance overlay for the user.
            VStack {
                Spacer()
                Text("Move Slowly")
                    .font(.title2)
                    .padding(8)
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.bottom, 100)
            }
            
            // A capture button overlayed on the camera feed.
            VStack {
                Spacer()
                Button(action: {
                    // Trigger the capture logic (simulate capture success)
                    cameraManager.captureScene { success in
                        if success {
                            captureSuccessful = true
                            showPreview = true
                        }
                    }
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle().stroke(Color.gray, lineWidth: 2)
                        )
                        .shadow(radius: 4)
                }
                .padding(.bottom, 40)
            }
        }
        // When capture is successful, navigate to preview screen
        .fullScreenCover(isPresented: $showPreview) {
            CapturePreviewScreen(captureSuccessful: $captureSuccessful, onDismiss: {
                // Reset state after preview if needed
                showPreview = false
                captureSuccessful = false
            })
        }
    }
}

// MARK: - Capture Preview Screen
struct CapturePreviewScreen: View {
    // Binding to allow for saving or discarding the capture
    @Binding var captureSuccessful: Bool
    // Callback for dismissing the preview screen
    var onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                // In a real app, the preview of the captured scene (an image or 3D render) would be shown here.
                Rectangle()
                    .fill(Color.black.opacity(0.8))
                    .overlay(Text("Preview of Captured Scene")
                                .foregroundColor(.white))
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding()
                
                // Options for the user
                HStack(spacing: 50) {
                    Button(action: {
                        // Discard the capture and go back
                        captureSuccessful = false
                        onDismiss()
                    }) {
                        Text("Discard")
                            .fontWeight(.semibold)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // Save the capture and proceed to a processing screen (not implemented here)
                        // For demo, simply dismiss the preview
                        onDismiss()
                    }) {
                        Text("Save")
                            .fontWeight(.semibold)
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .navigationBarTitle("Scene Preview", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done", action: onDismiss))
        }
    }
}

// MARK: - Camera Manager
// This class manages the AVCaptureSession and scene capture logic.
class CameraManager: ObservableObject {
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private var photoOutput = AVCapturePhotoOutput()
    
    init() {
        configureSession()
    }
    
    // Setup the session and add input and output
    private func configureSession() {
        sessionQueue.async {
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .photo
            
            // Set up the camera device (back camera)
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: .back),
                  let deviceInput = try? AVCaptureDeviceInput(device: camera),
                  self.captureSession.canAddInput(deviceInput)
            else {
                print("Error: Could not access the back camera.")
                return
            }
            self.captureSession.addInput(deviceInput)
            
            // Configure photo output if available
            if self.captureSession.canAddOutput(self.photoOutput) {
                self.captureSession.addOutput(self.photoOutput)
            }
            
            self.captureSession.commitConfiguration()
        }
    }
    
    // Start the camera session
    func startSession() {
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    // Stop the camera session
    func stopSession() {
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    // Simulated scene capture function.
    // In a production app, implement proper capture and process the frame.
    func captureScene(completion: @escaping (Bool) -> Void) {
        // This sample simply delays for a short period to simulate processing.
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
}

// MARK: - Preview Provider
struct SingleSceneCaptureScreen_Previews: PreviewProvider {
    static var previews: some View {
        SingleSceneCaptureScreen_Full_Implementation()
    }
}
