//
//  ResultScreenView.swift
//  MyApp
//
//  Created by Cong Le on 3/10/25.
//

import SwiftUI
import SceneKit

// MARK: - Result Screen View

struct ResultScreenView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // The 3D Model Viewer using SceneKit
                SceneKitContainer()
                    .edgesIgnoringSafeArea(.all)
                
                // Overlay Options Menu on top of the 3D view
                VStack {
                    HStack {
                        Spacer()
                        Menu {
                            Button(action: exportModel) {
                                Label("Export", systemImage: "square.and.arrow.up")
                            }
                            Button(action: shareModel) {
                                Label("Share", systemImage: "square.and.arrow.up.on.square")
                            }
                            Button(action: editModel) {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(action: saveModel) {
                                Label("Save to Project", systemImage: "tray.and.arrow.down")
                            }
                            Button(action: deleteModel) {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
            .navigationBarTitle("Scene Reconstruction Result", displayMode: .inline)
        }
    }
    
    // MARK: - Action Stubs
    
    func exportModel() {
        // Implement exporting model functionality (e.g., using USDZ export APIs)
        print("Export model")
    }
    
    func shareModel() {
        // Implement sharing functionality (e.g., using UIActivityViewController)
        print("Share model")
    }
    
    func editModel() {
        // Implement editing functionality if applicable.
        print("Edit model")
    }
    
    func saveModel() {
        // Implement saving to the project (locally or to cloud storage).
        print("Save model to project")
    }
    
    func deleteModel() {
        // Implement delete functionality with proper confirmation dialogs.
        print("Delete model")
    }
}

// MARK: - SceneKit Container View

struct SceneKitContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        
        // Create a new scene
        let scene = SCNScene()
        
        // Add a sample 3D model (a box) for demonstration purposes
        let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(0, 0, -3)
        scene.rootNode.addChildNode(boxNode)
        
        // Set up a camera to view the scene
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 5)
        scene.rootNode.addChildNode(cameraNode)
        
        // Add lighting to the scene for better visualization
        let light = SCNLight()
        light.type = .omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0, 10, 10)
        scene.rootNode.addChildNode(lightNode)
        
        // Configure the SCNView
        scnView.scene = scene
        scnView.allowsCameraControl = true  // Enables rotate, zoom, and pan interactions
        scnView.backgroundColor = UIColor.black
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update the view if needed during state changes.
    }
}

// MARK: - SwiftUI Preview

struct ResultScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ResultScreenView()
    }
}
