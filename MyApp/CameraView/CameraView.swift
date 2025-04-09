////
////  CameraView.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import SwiftUI
//import AVFoundation
//
//// MARK: - Camera View: SwiftUI interface for live camera preview and photo capture
//
//struct CameraView: View {
//    // Observed view model holding the camera session and output image
//    @StateObject private var cameraModel = CameraViewModel()
//    
//    var body: some View {
//        ZStack {
//            // Display live camera preview
//            CameraPreview(session: cameraModel.session)
//                .ignoresSafeArea()
//            
//            // Capture button positioned at the bottom overlaying the preview
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        cameraModel.capturePhoto()
//                    }) {
//                        Circle()
//                            .fill(Color.white)
//                            .frame(width: 70, height: 70)
//                            .overlay(
//                                Circle()
//                                    .stroke(Color.black, lineWidth: 2)
//                            )
//                            .shadow(radius: 4)
//                    }
//                    Spacer()
//                }
//                .padding(.bottom, 20)
//            }
//            
//            // When a photo is captured, display it fullscreen as an overlay.
//            if let image = cameraModel.capturedImage {
//                ZStack(alignment: .topTrailing) {
//                    Color.black.opacity(0.8)
//                        .ignoresSafeArea()
//                    Image(uiImage: image)
//                        .resizable()
//                        .scaledToFit()
//                        .padding()
//                    
//                    // Button to dismiss the captured image preview
//                    Button(action: {
//                        cameraModel.capturedImage = nil
//                    }) {
//                        Image(systemName: "xmark.circle.fill")
//                            .font(.largeTitle)
//                            .foregroundColor(.white)
//                            .padding()
//                    }
//                }
//            }
//        }
//        .onAppear {
//            cameraModel.configure()
//        }
//        .onDisappear {
//            cameraModel.stopSession()
//        }
//    }
//}
//
//// MARK: - Camera Preview UIViewRepresentable
//// Wraps the AVCaptureVideoPreviewLayer into SwiftUI view
//
//struct CameraPreview: UIViewRepresentable {
//    let session: AVCaptureSession
//    
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView(frame: UIScreen.main.bounds)
//        
//        // Create the preview layer using the session, set its properties...
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.frame = view.bounds
//        
//        // Insert the preview layer into the view’s layer hierarchy.
//        view.layer.addSublayer(previewLayer)
//        return view
//    }
//    
//    func updateUIView(_ uiView: UIView, context: Context) {
//        // Update the preview layer's frame (if needed)
//        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
//            previewLayer.session = session
//            previewLayer.frame = uiView.bounds
//        }
//    }
//}
//
//// MARK: - Camera ViewModel: AVCapture Session and Photo Capture Handling
//
//final class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
//    /// Published property to hold the captured UIImage.
//    @Published var capturedImage: UIImage?
//    
//    /// The camera session used to stream live video.
//    let session = AVCaptureSession()
//    
//    /// Photo output for capturing still images.
//    private let photoOutput = AVCapturePhotoOutput()
//    
//    /// The dispatch queue for configuring and running the session.
//    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
//    
//    // Call this method to set up the camera session.
//    func configure() {
//        sessionQueue.async {
//            self.session.beginConfiguration()
//            
//            // Set up the camera device (back camera)
//            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
//                                                       for: .video,
//                                                       position: .back),
//                  let input = try? AVCaptureDeviceInput(device: device) else {
//                print("Camera input not available.")
//                return
//            }
//            
//            // Add input to the session if possible
//            if self.session.canAddInput(input) {
//                self.session.addInput(input)
//            }
//            
//            // Add photo output to the session if possible
//            if self.session.canAddOutput(self.photoOutput) {
//                self.session.addOutput(self.photoOutput)
//            }
//            
//            self.session.commitConfiguration()
//            
//            // Start the session
//            self.session.startRunning()
//        }
//    }
//    
//    // Method to capture a photo.
//    func capturePhoto() {
//        let settings = AVCapturePhotoSettings()
//        // You may choose to adjust settings as needed, such as flash mode.
//        self.photoOutput.capturePhoto(with: settings, delegate: self)
//    }
//    
//    // Stop the capture session when not needed.
//    func stopSession() {
//        sessionQueue.async {
//            if self.session.isRunning {
//                self.session.stopRunning()
//            }
//        }
//    }
//    
//    // MARK: - AVCapturePhotoCaptureDelegate
//    
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        if let error = error {
//            print("Error capturing photo: \(error.localizedDescription)")
//            return
//        }
//        
//        guard let imageData = photo.fileDataRepresentation(),
//              let uiImage = UIImage(data: imageData) else {
//            print("Unable to capture image data.")
//            return
//        }
//        
//        DispatchQueue.main.async {
//            self.capturedImage = uiImage
//        }
//    }
//}
//
////
//// MARK: - Preview for SwiftUI
////
//struct CameraView_Previews: PreviewProvider {
//    static var previews: some View {
//        CameraView()
//            .preferredColorScheme(.dark)
//    }
//}
