//
//  LoungeView.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//
//
//import SwiftUI
//import RealityKit // Needed for Rotation3D, Model3D potentially
//
//// --- Main Application Structure ---
//
//@main
//struct KaraokeVisionApp: App {
//    // State to manage the immersion level
//    @State private var immersionStyle: ImmersionStyle = .mixed // Start in mixed
//    
//    // Define the allowed and initial immersion levels
//    let allowedImmersionRange: ClosedRange<Double> = 0.4...1.0
//    let initialImmersionAmount: Double = 0.5
//
//    var body: some Scene {
//        // Main window for initial controls
//        WindowGroup(id: "mainControls") {
//            ContentView()
//        }
//        .windowResizability(.contentSize) // Keep the control window small
//
//        // --- Immersive Space Definition ---
//        ImmersiveSpace(id: "KaraokeLounge") {
//            LoungeView() // Content view for the immersive space
//        }
//        // Control allowed immersion levels and set initial state
//        .immersionStyle(
//            selection: $immersionStyle, // Bind to state
//            in: .progressive(allowedImmersionRange, initialAmount: initialImmersionAmount)
//        )
//
//        // --- Volume Definition ---
//        // Define a separate WindowGroup for the Volume content
//        WindowGroup(id: "MicrophoneVolume") {
//            MicrophoneView() // Content view for the volume
//        }
//        .windowStyle(.volumetric) // Set the style to volumetric
//        .defaultWorldScaling(.sceneUnits(meters: 0.5)) // Example scaling
//        // Hide the system-provided baseplate for the volume
//        .volumeBaseplateVisibility(.hidden)
//    }
//}
//
//// --- ContentView (Main Window Controls) ---
//
//struct ContentView: View {
//    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
//    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
//    @Environment(\.openWindow) private var openWindow
//    @Environment(\.dismissWindow) private var dismissWindow
//
//    @State private var isImmersiveSpaceOpen = false
//    @State private var isVolumeOpen = false
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Karaoke Setup")
//                .font(.largeTitle)
//
//            Toggle(isImmersiveSpaceOpen ? "Exit Lounge" : "Enter Lounge", isOn: $isImmersiveSpaceOpen)
//                .onChange(of: isImmersiveSpaceOpen) { _, newValue in
//                    Task {
//                        if newValue {
//                            // Open the immersive space
//                            switch await openImmersiveSpace(id: "KaraokeLounge") {
//                            case .opened:
//                                isImmersiveSpaceOpen = true
//                            case .error, .userCancelled:
//                                fallthrough
//                            @unknown default:
//                                isImmersiveSpaceOpen = false
//                            }
//                        } else {
//                            // Dismiss the immersive space
//                            await dismissImmersiveSpace()
//                            isImmersiveSpaceOpen = false
//                        }
//                    }
//                }
//                .toggleStyle(.button)
//
//             Toggle(isVolumeOpen ? "Hide Microphone" : "Show Microphone", isOn: $isVolumeOpen)
//                .onChange(of: isVolumeOpen) { _, newValue in
//                     Task {
//                         if newValue {
//                             // Open the volume window
//                             await openWindow(id: "MicrophoneVolume")
//                             isVolumeOpen = true // Assume it opened, better handling needed for errors
//                         } else {
//                             // Dismiss the volume window
//                            await dismissWindow(id: "MicrophoneVolume")
//                            isVolumeOpen = false
//                         }
//                     }
//                 }
//                .toggleStyle(.button)
//
//        }
//        .padding(40)
//    }
//}
//
//// --- LoungeView (Immersive Space Content) ---
//
//struct LoungeView: View {
//    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            // Placeholder for the lounge environment
//            RealityView { content in
//                // Load your 3D Karaoke Lounge model here
//                // For example:
//                // if let scene = try? await Entity(named: "KaraokeLoungeScene", in: realityKitContentBundle) {
//                //     content.add(scene)
//                // }
//            }
//            .background(.regularMaterial) // Background if no model is loaded
//
//            Text("🎤 Karaoke Stage Area 🎶")
//                .font(.extraLargeTitle)
//                .padding(.bottom, 100) // Position text slightly up
//
//            Button("Exit Lounge") {
//                Task {
//                    await dismissImmersiveSpace()
//                }
//            }
//            .padding()
//        }
//        // Apply preferred surroundings effect (passthrough effect)
//        .preferredSurroundingsEffect(.colorMultiply(.purple.opacity(0.6)))
//        // Could also use .systemDark, .systemLight, etc.
//    }
//}
//
//// --- MicrophoneView (Volume Content) ---
//
//struct MicrophoneView: View {
//    // State to manage the microphone's rotation based on viewpoint
//    @State private var micRotation: Angle = .zero
//
//    var body: some View {
//        // Placeholder 3D model or View
//        VStack {
//            Text("🎤")
//                .font(.system(size: 100))
//                .padding()
//                .glassBackgroundEffect()
//
//            Text("Look around!")
//                .font(.headline)
//        }
//        // Apply rotation based on state
//        .rotation3DEffect(micRotation, axis: .y)
//        // Apply the modifier to react to volume viewpoint changes
//        .onVolumeViewpointChange { oldViewpoint, newViewpoint in
//            print("Viewpoint changed from \(oldViewpoint.anchor.position) to \(newViewpoint.anchor.position)")
//            // Example: Rotate slightly each time the viewpoint changes sides.
//            // A real implementation would calculate the angle needed to face 'newViewpoint'.
//            withAnimation(.easeInOut(duration: 0.5)) {
//                 micRotation += .degrees(30) // Simple rotation increment for demo
//                 // Replace with actual angle calculation to face the user:
//                 // micRotation = calculateRotationToFace(viewpoint: newViewpoint)
//            }
//        }
//    }
//
//    // Placeholder for a function that would calculate the real rotation
//    // func calculateRotationToFace(viewpoint: VolumetricViewpoint) -> Rotation3D {
//    //    // Complex geometry calculation needed here based on viewpoint.vector
//    //    // relative to the volume's content coordinate space.
//    //    return .identity // Placeholder
//    // }
//}
//
//// --- Previews (Optional, may require visionOS target) ---
//
//#Preview(windowStyle: .volumetric) {
//    MicrophoneView()
//        .frame(depth: 50) // Give it some depth for preview
//        .padding(50)
//}
//
//#Preview {
//    ContentView()
//}
//
//#Preview(immersionStyle: .progressive) {
//    LoungeView()
//}
