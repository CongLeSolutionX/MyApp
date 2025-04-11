//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
//
//import SwiftUI
//
//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//// After iOS 17, we can use this syntax for preview:
//#Preview {
//    ContentView()
//}


import SwiftUI
import ARKit // Core AR framework
import SceneKit // For 3D content rendering

// MARK: - ARViewRepresentable (Bridges ARSCNView to SwiftUI)

struct ARViewRepresentable: UIViewRepresentable {

    // Create the ARSCNView
    func makeUIView(context: Context) -> ARSCNView {
        // 1. Create the ARSCNView
        let arView = ARSCNView(frame: .zero)

        // 2. Set Delegate (crucial for reacting to AR events)
        // The Coordinator will handle delegate callbacks.
        arView.delegate = context.coordinator

        // 3. Debugging Options (Optional but helpful)
        arView.showsStatistics = true // Shows performance stats like FPS
        arView.debugOptions = [
            .showFeaturePoints,      // Shows detected raw feature points
            // .showWorldOrigin      // Shows the AR world origin marker
        ]

        // 4. Start the AR Session
        startARSession(for: arView)

        // 5. Add Tap Gesture Recognizer
        // The Coordinator will handle the tap action.
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)

        return arView
    }

    // Updates the view if SwiftUI state changes (not used in this basic example)
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Example: If you had @Binding variables in SwiftUI modifying AR behavior,
        // you would update the uiView or session configuration here.
    }

    // Creates the Coordinator instance
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Helper function to configure and run the AR Session
    private func startARSession(for arView: ARSCNView) {
        // 1. Check if ARWorldTrackingConfiguration is supported (most common config)
        guard ARWorldTrackingConfiguration.isSupported else {
            print("AR World Tracking is not supported on this device.")
            // You might want to show an error message to the user here
            return
        }

        // 2. Create a world tracking configuration
        let configuration = ARWorldTrackingConfiguration()

        // 3. Enable Plane Detection (Horizontal in this case)
        configuration.planeDetection = [.horizontal]

        // Optional: Improve lighting based on real-world environment
        configuration.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
             configuration.sceneReconstruction = .mesh // For devices with LiDAR
        }

        // 4. Run the session with the configuration
        //    resetTracking: Clears existing anchors and tracking data
        //    removeExistingAnchors: Removes visual anchors from previous sessions
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        print("AR Session Started with Horizontal Plane Detection")
    }

    // MARK: - Coordinator Class
    // Handles delegate methods and actions for the ARSCNView
    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: ARViewRepresentable // Reference back to the SwiftUI representable view

        // Store nodes associated with detected planes for updating/removal
        var planeNodes: [UUID: SCNNode] = [:]

        init(_ parent: ARViewRepresentable) {
            self.parent = parent
        }

        // --- ARSCNViewDelegate Methods ---

        // Called when a new ARAnchor (like a detected plane) is added to the scene
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            // 1. Check if the added anchor is a plane anchor
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

            print("Detected Plane: \(planeAnchor.identifier)")

            // 2. Create a SceneKit node to visualize the plane (optional, for debugging/feedback)
            let planeNode = createPlaneNode(for: planeAnchor)

            // 3. Add the visualization node as a child of the anchor's node
            //    (ARKit automatically positions the `node` parameter correctly)
            node.addChildNode(planeNode)

            // 4. Store the node for potential updates
            planeNodes[planeAnchor.identifier] = planeNode
        }

        // Called when an existing detected plane anchor is updated (e.g., its size changes)
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            // 1. Check if it's a plane anchor and we have a visualization node for it
            guard let planeAnchor = anchor as? ARPlaneAnchor,
                  let planeNode = planeNodes[planeAnchor.identifier] else { return }

            // 2. Update the geometry of the plane node to match the anchor's new extent
            updatePlaneNode(planeNode, for: planeAnchor)
        }

        // Called when a plane anchor is removed from the scene
        func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
             // 1. Check if it's a plane anchor
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

            print("Removed Plane: \(planeAnchor.identifier)")

            // 2. Remove the corresponding visualization node from our tracking dictionary and the scene
            if let planeNode = planeNodes.removeValue(forKey: planeAnchor.identifier) {
                planeNode.removeFromParentNode()
            }
        }

        // --- Helper Methods for Plane Visualization ---

        func createPlaneNode(for planeAnchor: ARPlaneAnchor) -> SCNNode {
            // Create a SceneKit plane geometry matching the anchor's extent.
            // Use planeAnchor.extent.width and planeAnchor.extent.height in recent iOS versions.
            // Use planeAnchor.extent.x and planeAnchor.extent.z for width/depth in older versions.
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))

            // Give the plane a material (e.g., semi-transparent blue)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.systemBlue.withAlphaComponent(0.5) // Semi-transparent blue
            plane.materials = [material]

            // Create a SceneKit node to hold the geometry
            let planeNode = SCNNode(geometry: plane)

            // Position the node slightly below the detected plane surface (optional visual adjustment)
            planeNode.position = SCNVector3(0, -0.005, 0)

            // Rotate the SCNPlane geometry to lie flat (SCNPlane is vertical by default)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)

            return planeNode
        }

        func updatePlaneNode(_ node: SCNNode, for planeAnchor: ARPlaneAnchor) {
            guard let plane = node.geometry as? SCNPlane else { return }

            // Update the geometry size
            plane.width = CGFloat(planeAnchor.extent.x)
            plane.height = CGFloat(planeAnchor.extent.z)

            // Update the node's position based on the anchor's center (if needed, but ARKit handles the main node transform)
            // node.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z) // Center might be relative
        }

        // --- Gesture Handling ---

        @objc func handleTap(_ gestureRecognize: UITapGestureRecognizer) {
            // 1. Get the ARSCNView from the gesture recognizer
            guard let arView = gestureRecognize.view as? ARSCNView else { return }

            // 2. Get the tap location within the view
            let tapLocation = gestureRecognize.location(in: arView)

            // 3. Perform an ARKit hit test
            //    - Searches for existing plane anchors that the user tapped on.
            //    - .existingPlaneUsingExtent: Considers the estimated size of the plane.
            let hitTestResults = arView.hitTest(tapLocation, types: .existingPlaneUsingExtent)

            // 4. Check if we hit a plane
            guard let hitResult = hitTestResults.first else {
                print("Tap did not hit any detected plane.")
                return
            }
            let identifier = hitResult.anchor?.identifier ?? UUID()
            print("Tap hit plane anchor: \(identifier)")

            // 5. Create a 3D object (a cube in this case)
            let cubeNode = createCubeNode(size: 0.05) // 5cm cube

            // 6. Position the cube at the hit location
            //    - The hitResult's worldTransform gives the 3D position and orientation of the tap.
            //    - We extract the position (x, y, z) from the 4th column of the matrix.
            //    - Add a small vertical offset so the cube sits *on* the plane, not inside it.
            let position = SCNVector3(
                hitResult.worldTransform.columns.3.x,
                hitResult.worldTransform.columns.3.y + Float(cubeNode.boundingBox.max.y / 2) + 0.001, // Offset = half height + tiny gap
                hitResult.worldTransform.columns.3.z
            )
            cubeNode.position = position

            // Optional: Give the cube a physics body for interaction later
            // let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: cubeNode.geometry!, options: nil))
            // cubeNode.physicsBody = physicsBody

            // 7. Add the cube node to the scene's root node
            arView.scene.rootNode.addChildNode(cubeNode)

             print("Added cube at position: \(position)")
        }

        // --- Helper Method for Creating 3D Content ---
        func createCubeNode(size: CGFloat) -> SCNNode {
            let cube = SCNBox(width: size, height: size, length: size, chamferRadius: size * 0.05) // Slightly rounded edges

            // Simple material
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.systemYellow
            material.lightingModel = .physicallyBased // Or .blinn, .phong etc.
            cube.materials = [material]

            let cubeNode = SCNNode(geometry: cube)
            return cubeNode
        }
    }
}

// MARK: - SwiftUI ContentView

struct ContentView: View {
    var body: some View {
        // Embed the ARViewRepresentable in the SwiftUI view hierarchy
        ARViewRepresentable()
            .ignoresSafeArea() // Allow AR view to fill the entire screen, including safe areas
            .navigationTitle("ARKit SwiftUI Demo") // Optional title if embedded in NavigationView
            .navigationBarHidden(true) // Often hide nav bar for immersive AR
    }
}

// MARK: - Preview Provider (AR doesn't work well in previews)

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview will likely show a black screen or basic view,
        // as camera/AR isn't available.
        ContentView()
            .previewDisplayName("AR View (Preview Limitations Apply)")
    }
}

// MARK: - App Entry Point

//@main
//struct ARKitSwiftUIApp: App {
//    var body: some Scene {
//        WindowGroup {
//            // It's good practice to wrap in a NavigationView if you might add other UI later
//            // NavigationView {
//                ContentView()
//            // }
//        }
//    }
//}
