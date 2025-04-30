////
////  ComprehensiveView.swift
////  MyApp
////
////  Created by Cong Le on 4/29/25.
////
//
//import SwiftUI
//import MetalKit // Ensure MetalKit is imported if not already
//
//// MARK: - Constants
//struct Constants {
//    static let updateInterval: Double = 0.016 // Approx 60 FPS
//    static let initialAmplitude: Float = 0.5
//    static let activeAmplitude: Float = 2.0
//    static let initialSpeedMultiplier: Double = 1.0
//    static let activeSpeedMultiplier: Double = 2.0
//    static let animationDuration: Double = 0.3
//    static let rippleDuration: TimeInterval = 1.5 // Shorter ripple looks better
//    static let micImageName: String = "My-meme-orange-microphone" // Use constant for image name
//}
//
//// MARK: - Main Content View
//struct ContentView: View {
//    // MARK: State Variables
//
//    // Background Shader Animation
//    @State private var shaderAmplitude: Float = Constants.initialAmplitude
//    @State private var shaderSpeedMultiplier: Double = Constants.initialSpeedMultiplier
//    @State private var elapsedTime: Double = 0.0
//    @State private var isInteractingWithBackground: Bool = false
//
//    // Microphone Recording State
//    @State private var isRecording: Bool = false
//
//    // Ripple Effect State
//    @State private var rippleCounter: Int = 0
//    @State private var rippleOrigin: CGPoint = .zero
//
//    // MARK: Body
//    var body: some View {
//        TimelineView(.periodic(from: .now, by: Constants.updateInterval / shaderSpeedMultiplier)) { context in
//            ZStack {
//                // 1. Invisible Background Layer for Shader & Gesture
//                backgroundLayerView
//
//                // 2. Foreground UI Content
//                foregroundUiView
//            }
//            .onChange(of: context.date) { _, newDate in
//                // Update elapsed time for shader, driven by TimelineView
//                elapsedTime += Constants.updateInterval * shaderSpeedMultiplier
//            }
//            // Apply haptic feedback when background interaction starts
//            .sensoryFeedback(.impact(intensity: 0.7), trigger: isInteractingWithBackground) { _, newValue in
//                // Trigger only when changing from false to true
//                !isInteractingWithBackground && newValue
//            }
//        }
//    }
//
//    // MARK: Background View
//    private var backgroundLayerView: some View {
//        Color.clear
//            .ignoresSafeArea()
//            .background {
//                Rectangle()
//                    .ignoresSafeArea()
//                    .colorEffect(ShaderLibrary.default.harmonicColorEffect(
//                        .boundingRect,
//                        .float(6), // waves count
//                        .float(elapsedTime),
//                        .float(shaderAmplitude),
//                        .float(isInteractingWithBackground ? 1.0 : 0.0) // mixCoeff
//                    ))
//            }
//            .gesture(
//                DragGesture(minimumDistance: 0)
//                    .onChanged { _ in
//                        // Trigger only once when interaction starts
//                        if !isInteractingWithBackground {
//                            isInteractingWithBackground = true
//                            withAnimation(.spring(duration: Constants.animationDuration)) {
//                                shaderAmplitude = Constants.activeAmplitude
//                                shaderSpeedMultiplier = Constants.activeSpeedMultiplier
//                            }
//                            // Optional: Different haptic for background hold start?
//                             UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                        }
//                    }
//                    .onEnded { _ in
//                        // Trigger only if currently interacting
//                        if isInteractingWithBackground {
//                            isInteractingWithBackground = false
//                            withAnimation(.spring(duration: Constants.animationDuration)) {
//                                shaderAmplitude = Constants.initialAmplitude
//                                shaderSpeedMultiplier = Constants.initialSpeedMultiplier
//                            }
//                        }
//                    }
//            )
//    }
//
//    // MARK: Foreground UI View
//    private var foregroundUiView: some View {
//        VStack {
//            Spacer() // Push content down
//
//            // Dynamic Status Text
//            statusTextView
//                .padding(.bottom, 30)
//
//            // Microphone Image Button
//            microphoneImageView
//                .padding(.bottom, 50) // Padding from bottom edge
//
//        }
//        .padding()
//        // Prevent VStack from blocking the background gesture
//        .allowsHitTesting(false)
//    }
//
//    // MARK: Subviews for Foreground UI
//    private var statusTextView: some View {
//        Text(statusText)
//            .font(.title2) // Adjusted font size
//            .fontWeight(.semibold) // Adjusted weight
//            .foregroundStyle(.white)
//            .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 1)
//            .multilineTextAlignment(.center)
//            .frame(minHeight: 50) // Ensure consistent height
//            .animation(.easeInOut(duration: 0.2), value: statusText) // Animate text changes
//    }
//
//    private var microphoneImageView: some View {
//        Image(Constants.micImageName)
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: 150, height: 150) // Give it a specific size
//             // Apply visual feedback for recording state
//            .overlay {
//                 if isRecording {
//                     RoundedRectangle(cornerRadius: 24)
//                         .fill(.black.opacity(0.3)) // Dark overlay when recording
//                     Image(systemName: "mic.fill") // System mic icon
//                         .font(.system(size: 50))
//                         .foregroundStyle(.red.opacity(0.8))
//                 }
//             }
//            .clipShape(RoundedRectangle(cornerRadius: 24))
//            // Make the image itself tappable (receives hits despite parent allowsHitTesting(false))
//            .allowsHitTesting(true)
//            // Use onTapGesture for simple toggle, keep onPressingChanged for ripple origin
//            .onTapGesture {
//                toggleRecording()
//            }
//            .onPressingChanged { point in
//                 // Capture origin for ripple effect when pressed
//                if let point {
//                     rippleOrigin = point
//                    // Trigger ripple only if not already triggered by onTapGesture (optional refinement)
//                    // Or simply trigger ripple on any press down
//                    rippleCounter += 1 // Trigger ripple visually
//                }
//            }
//            .modifier(
//                RippleEffect(
//                    at: rippleOrigin,
//                    trigger: rippleCounter,
//                    duration: Constants.rippleDuration // Pass duration
//                )
//            )
//            // Animate the recording overlay
//            .animation(.bouncy(duration: 0.3) , value: isRecording) // Use bouncy animation for mic state change
//
//    }
//
//    // MARK: Computed Properties
//    private var statusText: String {
//        if isRecording {
//            return "Recording Active...\n(Tap Mic to Stop)"
//        } else if isInteractingWithBackground {
//            return "Listening...\n(Release to Idle)"
//        } else {
//            return "Hold Background to Listen\nTap Mic to Record"
//        }
//    }
//
//    // MARK: Actions
//    private func toggleRecording() {
//        isRecording.toggle()
//        // Provide haptic feedback specifically for recording toggle
//        UIImpactFeedbackGenerator(style: isRecording ? .medium : .light).impactOccurred()
//
//        // --- Mock Functionality ---
//        if isRecording {
//            print("START Recording (Mock)")
//            // TODO: Add actual audio recording start logic here
//        } else {
//            print("STOP Recording (Mock)")
//            // TODO: Add actual audio recording stop logic here
//        }
//        // --- End Mock Functionality ---
//
//        // Optional: Trigger ripple on tap as well, even if onPressingChanged handles it
//         rippleCounter += 1 // Uncomment if you want ripple guaranteed on tap
//    }
//}
//
//// MARK: - Previews
//#Preview("ContentView") {
//    ContentView()
//        // Add a dark background for better preview visibility of the shader
//        .background(Color.black)
//}
//
//// MARK: - Ripple Effect Modifier (Updated with Duration)
//struct RippleEffect<T: Equatable>: ViewModifier {
//    var origin: CGPoint
//    var trigger: T
//    var duration: TimeInterval // Add duration parameter
//
//    init(at origin: CGPoint, trigger: T, duration: TimeInterval = 3.0) { // Default duration
//        self.origin = origin
//        self.trigger = trigger
//        self.duration = duration
//    }
//
//    func body(content: Content) -> some View {
//        let effectOrigin = origin // Capture locally
//        let effectDuration = duration // Capture locally
//
//        content.keyframeAnimator(
//            initialValue: 0, // Represents elapsedTime
//            trigger: trigger
//        ) { view, elapsedTime in
//            view.modifier(RippleModifier(
//                origin: effectOrigin,
//                elapsedTime: elapsedTime,
//                duration: effectDuration // Pass duration down
//            ))
//        } keyframes: { _ in
//            // Animate elapsedTime from 0 to duration over the specified duration
//            MoveKeyframe(0) // Start at time 0
//            LinearKeyframe(effectDuration, duration: effectDuration) // End at time `duration`
//        }
//    }
//}
//
//// MARK: - Ripple Modifier (No changes needed, uses passed duration)
//struct RippleModifier: ViewModifier {
//    var origin: CGPoint
//    var elapsedTime: TimeInterval
//    var duration: TimeInterval // Receives duration
//
//    // Ripple Shader Parameters (Consider making these configurable)
//    var amplitude: Double = 12
//    var frequency: Double = 15
//    var decay: Double = 8
//    var speed: Double = 1200
//
//    func body(content: Content) -> some View {
//        let shader = ShaderLibrary.Ripple(
//            .float2(origin),
//            .float(elapsedTime),
//            .float(amplitude),
//            .float(frequency),
//            .float(decay),
//            .float(speed)
//        )
//
//        let maxSampleOffset = self.maxSampleOffset // Calculate based on amplitude
//        let effectElapsedTime = elapsedTime // Capture locally
//        let effectDuration = duration     // Capture locally
//
//        content.visualEffect { view, _ in
//            view.layerEffect(
//                shader,
//                maxSampleOffset: maxSampleOffset,
//                // Enable only while the animation is running
//                isEnabled: 0 < effectElapsedTime && effectElapsedTime < effectDuration
//            )
//        }
//    }
//
//    // The maximum distance a pixel can be shifted by the ripple
//    var maxSampleOffset: CGSize {
//        CGSize(width: amplitude, height: amplitude)
//    }
//}
//
//// MARK: - Spatial Pressing Gesture (Removed unnecessary iOS 18 check)
//extension View {
//    func onPressingChanged(_ action: @escaping (CGPoint?) -> Void) -> some View {
//        modifier(SpatialPressingGestureModifier(onPressingChanged: action))
//    }
//}
//
//struct SpatialPressingGestureModifier: ViewModifier {
//    var onPressingChanged: (CGPoint?) -> Void
//    @State private var currentLocation: CGPoint? // Keep track of press location
//
//    func body(content: Content) -> some View {
//        // UILongPressGestureRecognizer(minimumPressDuration: 0) is used to detect
//        // an immediate press down and its location within the view.
//        let gesture = SpatialPressingGesture(location: $currentLocation)
//
//        content
//            .gesture(gesture)
//            // Use onChange to notify the callback when the location binding changes
//            .onChange(of: currentLocation) { _, newLocation in
//                onPressingChanged(newLocation)
//            }
//    }
//}
//
//struct SpatialPressingGesture: UIGestureRecognizerRepresentable {
//    // Coordinator to act as the gesture recognizer's delegate
//    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
//        // Allows this gesture to cooperate with other gestures if needed
//        @objc
//        func gestureRecognizer(
//            _ gestureRecognizer: UIGestureRecognizer,
//            shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
//        ) -> Bool {
//            true
//        }
//    }
//
//    @Binding var location: CGPoint? // Bind to the state variable holding the location
//
//    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
//        Coordinator()
//    }
//
//    // Create the actual UILongPressGestureRecognizer instance
//    func makeUIGestureRecognizer(context: Context) -> UILongPressGestureRecognizer {
//        let recognizer = UILongPressGestureRecognizer()
//        recognizer.minimumPressDuration = 0 // Trigger immediately on touch down
//        recognizer.delegate = context.coordinator // Use the coordinator for delegation
//        return recognizer
//    }
//
//    // Handle state changes from the UIKit gesture recognizer
//    func handleUIGestureRecognizerAction(
//        _ recognizer: UIGestureRecognizerType, context: Context) {
//            switch recognizer.state {
//            case .began: // Touch down detected
//                location = context.converter.localLocation // Record the location
//            case .ended, .cancelled, .failed: // Touch up or interruption
//                location = nil // Clear the location
//            default:
//                break // Ignore other states like .changed (movement)
//            }
//        }
//}
//
//// MARK: - Shader Library Placeholder (Assumes shaders are compiled)
//// No changes needed to the metal files themselves based on these enhancements.
//// Ensure they are correctly added to your Xcode target and compiled.
