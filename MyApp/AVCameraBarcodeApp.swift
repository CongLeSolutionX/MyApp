//
//  AVCameraBarcodeApp.swift
//  MyApp
//
//  Created by Cong Le on 3/14/25.
//

import SwiftUI
import AVFoundation

// MARK: - CameraPreviewView
// A SwiftUI wrapper for displaying the camera’s video using AVCaptureVideoPreviewLayer.
struct CameraPreviewView: UIViewRepresentable {
    
    // Internal UIView subclass backed by AVCaptureVideoPreviewLayer.
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        var previewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    let session: AVCaptureSession

    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        // No dynamic updates currently.
    }
}

// MARK: - CameraManager
// An observable object that configures and manages the AVCaptureSession and camera settings.
class CameraManager: ObservableObject {
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    @Published var error: String? = nil

    init() {
        configureSession()
    }
    
    private func configureSession() {
        sessionQueue.async {
            self.session.beginConfiguration()
            
            // Configure the camera input.
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                            for: .video,
                                                            position: .back) else {
                DispatchQueue.main.async { self.error = "Unable to access the camera device." }
                self.session.commitConfiguration()
                return
            }
            
            do {
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = "Error configuring camera input: \(error.localizedDescription)"
                }
                self.session.commitConfiguration()
                return
            }
            
            // Configure metadata output (for barcode scanning, etc.).
            let metadataOutput = AVCaptureMetadataOutput()
            if self.session.canAddOutput(metadataOutput) {
                self.session.addOutput(metadataOutput)
                // Set delegate and dispatch queue if needed:
                metadataOutput.setMetadataObjectsDelegate(nil, queue: DispatchQueue.main)
                // Optionally, set supported metadata types:
                // metadataOutput.metadataObjectTypes = [.qr, .ean13, ...]
            }
            
            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }
    
    // A stub for switching cameras.
    func switchCamera() {
        // Real implementation would safely reconfigure the session;
        // for demo purposes, this is a placeholder.
    }
    
    // A stub for zooming the camera.
    func zoomCamera(to factor: CGFloat) {
        // Implement zoom logic (e.g., updating the active AVCaptureDevice’s videoZoomFactor).
    }
    
    deinit {
        session.stopRunning()
    }
}

// MARK: - Item Model
// A simple model representing an item in the selection view.
struct Item: Identifiable {
    let id = UUID()
    let name: String
}

// MARK: - ItemSelectionView
// A SwiftUI view that mimics a UITableViewController for selecting items.
struct ItemSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    let allItems: [Item] = [
        Item(name: "Item A"),
        Item(name: "Item B"),
        Item(name: "Item C")
    ]
    @State private var selectedItems: Set<UUID> = []
    var allowsMultipleSelection: Bool = true
    
    var body: some View {
        NavigationView {
            List(allItems, selection: $selectedItems) { item in
                Text(item.name)
            }
            .navigationTitle("Select Items")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                }
            }
            // Enable editing mode to allow selections.
            .environment(\.editMode, .constant(.active))
        }
    }
}

// MARK: - ContentView
// The main view that displays the camera preview, overlay controls, and navigation to the item selection screen.
struct ContentView: View {
    @StateObject var cameraManager = CameraManager()
    @State private var showItemSelection = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // The camera preview fills the entire background.
                CameraPreviewView(session: cameraManager.session)
                    .edgesIgnoringSafeArea(.all)
                
                // Overlay with control buttons.
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            cameraManager.switchCamera()
                        }, label: {
                            Image(systemName: "camera.rotate")
                                .font(.largeTitle)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        })
                        Spacer()
                        Button(action: { showItemSelection.toggle() }, label: {
                            Image(systemName: "list.bullet")
                                .font(.largeTitle)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        })
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Camera")
            // Present the item selection view as a sheet.
            .sheet(isPresented: $showItemSelection) {
                ItemSelectionView()
            }
            // Show an alert if an error occurs.
            .alert(item: Binding(
                get: { cameraManager.error.map { ErrorWrapper(message: $0) } },
                set: { _ in cameraManager.error = nil }
            )) { errorWrapper in
                Alert(title: Text("Error"),
                      message: Text(errorWrapper.message),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
}

// A simple wrapper to conform error messages to Identifiable for alerts.
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}
//
//// MARK: - Main App Entry
//@main
//struct MyCameraApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

//
// End of file
//
// This single Swift file uses SwiftUI to implement core components of a mobile app based
// on the design workflow. It wraps an AVCaptureSession preview in a SwiftUI view, manages
// camera configuration and session in a dedicated CameraManager class, and offers an item
// selection interface modeled after a table view controller using SwiftUI’s List component.
// The code also includes basic error handling and placeholders for additional functionality
// such as switching cameras and zooming, aligned with current best practices in mobile app
// development.
