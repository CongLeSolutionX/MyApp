//
//  ARKitView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/11/25.
//

import SwiftUI
import RealityKit
import ARKit // ARKit is implicitly used by ARView for session management but good to import
import Combine // For Combine Cancellables

// MARK: - AR View Representable

struct ARViewContainer: UIViewRepresentable {

    let modelName: String // Pass the model name dynamically if needed

    func makeUIView(context: Context) -> ARView {
        // Create the ARView
        let arView = ARView(frame: .zero)

        // Configure the AR session for world tracking with plane detection
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal] // Detect horizontal surfaces
        config.environmentTexturing = .automatic // Use camera feed for realistic lighting
        // Optional: Add LiDAR scene reconstruction if device supports it
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        arView.session.run(config)

        // Assign the coordinator to handle gestures
        context.coordinator.arView = arView // Give coordinator access to the view
        context.coordinator.modelName = modelName // Pass model name to coordinator

        // Setup tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)

        // Optional: Add coaching overlay for better user guidance
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane // Guide user to find a plane
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.addSubview(coachingOverlay)
        coachingOverlay.setActive(true, animated: true)

        // Optional: Enable debug options (useful during development)
        // arView.debugOptions = [.showFeaturePoints, .showWorldOrigin, .showAnchorOrigins]

        return arView
    }

    // Updates from SwiftUI to UIKit (if needed)
    func updateUIView(_ uiView: ARView, context: Context) {
        // Example: If you had a @State var in SwiftUI to change the model,
        // you might trigger a reload or update here via the coordinator.
        // For this example, we don't need updates triggered from SwiftUI state changes.
        print("ARView updateUIView called (typically unused in basic AR setup)")
        context.coordinator.modelName = modelName // Ensure coordinator always has the latest model name if it could change
    }

    // Creates the Coordinator instance
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // MARK: - Coordinator Class
    // Handles interactions between SwiftUI and the ARView (e.g., gestures, delegate methods)
    class Coordinator: NSObject {
        weak var arView: ARView?
        var modelName: String = "toy_drummer.usdz" // Default, will be updated

        // Cancellables to manage async loading
        var loadCancellable: AnyCancellable?

        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let arView = arView else { return }

            // Get tap location
            let tapLocation = recognizer.location(in: arView)

            // Perform a raycast to find a point on a detected horizontal plane
            // Filter results to only 'existingPlaneGeometry' for stable placement
            let results = arView.raycast(from: tapLocation, allowing: .existingPlaneGeometry, alignment: .horizontal)

            // If a suitable surface is found
            if let firstResult = results.first {
                print("Raycast hit a horizontal plane.")

                // --- Load and Place the Model ---
                // Cancel any previous loading operation
                loadCancellable?.cancel()

                print("Attempting to load model: \(modelName)")

                // Asynchronously load the model entity
                loadCancellable = Entity.loadModelAsync(named: modelName)
                    .receive(on: DispatchQueue.main) // Ensure UI updates happen on main thread
                    .sink(receiveCompletion: { loadCompletion in
                        switch loadCompletion {
                        case .finished:
                            print("Model '\(self.modelName)' loaded successfully.")
                            break // Good, loading finished
                        case .failure(let error):
                            print("Failed to load model '\(self.modelName)': \(error)")
                        }
                    }, receiveValue: { [weak self] loadedModelEntity in
                        guard let self = self, let arView = self.arView else { return }

                        print("Model entity received, attempting to place.")

                        // Create an AnchorEntity at the raycast hit location
                        // (anchors the model to a real-world position)
                        let anchor = AnchorEntity(world: firstResult.worldTransform)

                        // Configure the loaded model (optional)
                        // Example: Enable physics or add components
                        loadedModelEntity.generateCollisionShapes(recursive: true) // For interaction later if needed
                        // Optional: Set scale or position relative to anchor if desired
                        // loadedModelEntity.scale = [0.5, 0.5, 0.5]

                        // Add the model to the anchor
                        anchor.addChild(loadedModelEntity)

                        // Add the anchor to the scene
                        arView.scene.addAnchor(anchor)
                        print("Anchor with model added to the scene.")

                    }) // end sink
            } else {
                print("Tap did not hit a detected horizontal plane.")
            }
        } // end handleTap
    } // end Coordinator
} // end ARViewContainer

// MARK: - SwiftUI Content View

struct ContentView: View {
    // Example: You could add state to change the model dynamically
    @State private var selectedModelName: String = "toy_drummer.usdz"

    var body: some View {
        ZStack { // Use ZStack for potential UI overlays
            ARViewContainer(modelName: selectedModelName)
                .ignoresSafeArea() // Make AR view take up the whole screen

            // Example Overlay UI (optional)
            VStack {
                Spacer() // Push controls to bottom
                Text("Tap on a flat surface to place the model!")
                    .padding()
                    .background(.black.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom) // Add padding at the bottom
            }
        }
        // Handle potential errors or provide feedback if needed
    }
}

// MARK: - Preview Provider

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        // Note: AR previews often don't work well in Xcode canvas.
        // Best tested on a physical device.
    }
}

// MARK: - App Entry Point (Uncomment if this is your main App file)
/*
@main
struct AR_SwiftUI_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/
