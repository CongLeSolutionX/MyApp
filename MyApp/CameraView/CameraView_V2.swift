//
//  CameraView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//


import SwiftUI
import AVFoundation
import PhotosUI

// MARK: - CameraView: Functional SwiftUI interface for live camera preview, switching cameras, flash toggle, and photo capture.

struct CameraView: View {
    @StateObject private var cameraModel = CameraViewModel()
    
    var body: some View {
        ZStack {
            // Live camera preview
            CameraPreview(session: cameraModel.session)
                .ignoresSafeArea()
            
            // Top controls for switching camera and toggling flash mode
            VStack {
                HStack {
                    Button(action: {
                        cameraModel.switchCamera()
                    }) {
                        Image(systemName: "camera.rotate")
                            .font(.title2)
                            .padding()
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: {
                        cameraModel.toggleFlashMode()
                    }) {
                        Image(systemName: cameraModel.flashIconName)
                            .font(.title2)
                            .padding()
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                
                Spacer()
                
                // Capture button
                HStack {
                    Spacer()
                    Button(action: {
                        cameraModel.capturePhoto()
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .shadow(radius: 4)
                    }
                    Spacer()
                }
                .padding(.bottom, 30)
            }
            
            // Photo preview overlay with Retake and Save buttons
            if let image = cameraModel.capturedImage {
                ZStack(alignment: .bottom) {
                    Color.black.opacity(0.85)
                        .ignoresSafeArea()
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                // Dismiss captured image overlay
                                cameraModel.capturedImage = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        }
                        Spacer()
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding()
                        Spacer()
                        HStack(spacing: 40) {
                            Button(action: {
                                // Retake photo: simply dismiss the overlay
                                cameraModel.capturedImage = nil
                            }) {
                                Text("Retake")
                                    .fontWeight(.semibold)
                                    .frame(width: 120, height: 50)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            Button(action: {
                                // Save photo: for demonstration, print to console.
                                cameraModel.savePhoto()
                            }) {
                                Text("Save Photo")
                                    .fontWeight(.semibold)
                                    .frame(width: 120, height: 50)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            cameraModel.configure()
        }
        .onDisappear {
            cameraModel.stopSession()
        }
    }
}

// MARK: - Camera Preview UIViewRepresentable

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.session = session
            previewLayer.frame = uiView.bounds
        }
    }
}

// MARK: - Camera ViewModel: Manages AVCaptureSession, switching cameras, flash, and photo capturing.

final class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var capturedImage: UIImage?
    
    let session = AVCaptureSession()
    private var currentInput: AVCaptureDeviceInput?
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    // Default flash mode is auto
    @Published var flashMode: AVCaptureDevice.FlashMode = .auto
    // Computed icon based on current flash mode
    var flashIconName: String {
        switch flashMode {
        case .auto: return "bolt.badge.a"
        case .on: return "bolt.fill"
        case .off: return "bolt.slash.fill"
        @unknown default: return "bolt"
        }
    }
    
    // Default camera position is back
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    
    // Configure the camera session
    func configure() {
        sessionQueue.async {
            self.session.beginConfiguration()
            self.setupCameraInput(position: self.currentCameraPosition)
            // Add photo output
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
            }
            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }
    
    // Helper to setup camera input for the given device position
    private func setupCameraInput(position: AVCaptureDevice.Position) {
        // Remove existing input, if any
        if let currentInput = self.currentInput {
            self.session.removeInput(currentInput)
        }
        
        // Get device for specified position
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("Error: Could not create input for camera at position \(position.rawValue)")
            return
        }
        if self.session.canAddInput(input) {
            self.session.addInput(input)
            self.currentInput = input
        }
    }
    
    // Switch between front and back camera
    func switchCamera() {
        sessionQueue.async {
            self.currentCameraPosition = (self.currentCameraPosition == .back) ? .front : .back
            self.session.beginConfiguration()
            self.setupCameraInput(position: self.currentCameraPosition)
            self.session.commitConfiguration()
        }
    }
    
    // Toggle flash mode: cycles through auto, on, off
    func toggleFlashMode() {
        switch flashMode {
        case .auto:
            flashMode = .on
        case .on:
            flashMode = .off
        case .off:
            flashMode = .auto
        @unknown default:
            flashMode = .auto
        }
        print("Flash mode updated to: \(flashMode)")
    }
    
    // Capture photo with current settings (flash mode is applied in settings)
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        // Apply flash mode if available and if the active device supports it
        if let device = currentInput?.device, device.hasFlash {
            settings.flashMode = flashMode
        }
        settings.isHighResolutionPhotoEnabled = true
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // Stop running the session
    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    // Save captured photo (Mock implementation)
    func savePhoto() {
        guard let image = capturedImage else {
            print("No captured image to save.")
            return
        }
        // In a real app, you might save to Photo Library or local storage.
        // Here, we simply print to the console to simulate saving.
        print("Photo saved! (Image size: \(image.size.width)x\(image.size.height))")
        
        // For example, using UIImageWriteToSavedPhotosAlbum:
        // UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        // Dismiss the preview overlay after saving.
        DispatchQueue.main.async {
            self.capturedImage = nil
        }
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        guard let imageData = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: imageData) else {
            print("Error: Unable to get image data.")
            return
        }
        DispatchQueue.main.async {
            self.capturedImage = uiImage
        }
    }
}

//
// MARK: - Preview for SwiftUI
//
struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
            .preferredColorScheme(.dark)
    }
}
