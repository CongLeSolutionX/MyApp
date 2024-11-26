//
//  TikTokCameraView.swift
//  MyApp
//
//  Created by Cong Le on 11/13/24.
//
import SwiftUI
import AVFoundation
import Combine

class CameraModel: NSObject, ObservableObject {
    // Published properties to update the UI based on camera status
    @Published var isCameraAuthorized: Bool = false
    @Published var session: AVCaptureSession = AVCaptureSession()
    
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let videoOutput = AVCaptureVideoDataOutput()
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    // Check and request camera permissions
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async {
                self.isCameraAuthorized = true
                self.setupSession()
            }
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isCameraAuthorized = granted
                    self.sessionQueue.resume()
                    if granted {
                        self.setupSession()
                    }
                }
            }
        default:
            DispatchQueue.main.async {
                self.isCameraAuthorized = false
            }
        }
    }

    
    // Setup the camera session
    func setupSession() {
        sessionQueue.async {
            self.configureSession()
            self.session.startRunning()
        }
    }
    
    // Configure the AVCaptureSession
    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video,
                                                        position: .back) else {
            print("Default video device is unavailable.")
            session.commitConfiguration()
            return
        }
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if self.session.canAddInput(videoDeviceInput) {
                self.session.addInput(videoDeviceInput)
            } else {
                print("Couldn't add video device input to the session.")
                session.commitConfiguration()
                return
            }
        } catch {
            print("Couldn't create video device input: \(error)")
            session.commitConfiguration()
            return
        }
        
        // Add video output
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:
                                            kCVPixelFormatType_32BGRA]
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video.frame.processing.queue"))
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    // Function to handle session start
    func startSession() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    // Function to handle session stop
    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
}

extension CameraModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    // Implement delegate methods if needed
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Handle each frame if necessary
    }
}


// MARK: - Camera Wrapper


struct CameraPreview: UIViewRepresentable {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    @ObservedObject var cameraModel: CameraModel
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.session = cameraModel.session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        // Update the preview layer if needed
        if cameraModel.session.isRunning {
            uiView.videoPreviewLayer.session = cameraModel.session
        }
    }
}


// MARK: - VIEWS


struct CameraView: View {
    @StateObject private var cameraModel = CameraModel()
    
    var body: some View {
        ZStack {
            // Camera Feed or Placeholder based on authorization
            if cameraModel.isCameraAuthorized {
                CameraPreview(cameraModel: cameraModel)
                    .edgesIgnoringSafeArea(.all)
            } else {
                // Placeholder if camera access is denied
                Color.green
                    .edgesIgnoringSafeArea(.all)
                Text("Camera access is denied. Please enable it in Settings.")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red.opacity(0.5))
                    .cornerRadius(10)
            }
            
            
            
            // Top Bar
            VStack {
                HStack {
                    Text("9:41")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Text("Sounds")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                .padding(.top, 60) // Adjust top padding for status bar
                Spacer()
            }

            VStack {
                Spacer()

                // Main Control Panel
                HStack {
                    Spacer()

                    // Recording Button
                    Button(action: {
                        // Action for recording
                    }) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 80, height: 80)
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    }
                    
                    Spacer()

                    Button(action: {
                        // Action for Upload
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding()

                // Timer and Templates
                HStack {
                    Text("60s")
                        .foregroundColor(.white)
                    Spacer()
                    Text("15s")
                        .foregroundColor(.white)
                    Spacer()
                    Text("Templates")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }

            // Effects Button Panel
            VStack {
                HStack {
                    VStack(spacing: 20) {
                        EffectButton(icon: "sparkles", title: "Sparkle") {
                            // Action for Sparkle effect
                        }
                        EffectButton(icon: "star.fill", title: "Star") {
                            // Action for Star effect
                        }
                        EffectButton(icon: "moon.fill", title: "Moon") {
                            // Action for Moon effect
                        }
                        EffectButton(icon: "flame.fill", title: "Flame") {
                            // Action for Flame effect
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
}

struct EffectButton: View {
    var icon: String
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(20)
            .shadow(radius: 5)
        }
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text("Activates the \(title) effect"))
    }
}

// MARK: - Previews
#Preview {
    CameraView()
}

#Preview {
    EffectButton(icon: "camera", title: "Camera", action: {})
}
