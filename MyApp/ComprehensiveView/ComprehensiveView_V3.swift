////
////  ComprehensiveView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/29/25.
////
//
//import SwiftUI
//import MetalKit
//
////MARK: Metal code is compiled at runtime, not seeing in simulator on canvas yet.
//// MARK: - Constants (Keep from previous enhancement)
//struct Constants {
//    static let updateInterval: Double = 0.016
//    static let initialAmplitude: Float = 0.5
//    static let activeAmplitude: Float = 2.0
//    static let initialSpeedMultiplier: Double = 1.0
//    static let activeSpeedMultiplier: Double = 2.0
//    static let animationDuration: Double = 0.3
//    static let rippleDuration: TimeInterval = 1.5 // Adjusted ripple duration
//    static let longPressDuration: Double = 0.2 // Duration to qualify as long press
//    static let micImageName: String = "My-meme-orange-microphone"
//}
//
//// MARK: - Main Content View
//struct ContentView: View {
//    // MARK: State Variables
//
//    // Background Shader Animation (Controlled by Long Press)
//    @State private var shaderAmplitude: Float = Constants.initialAmplitude
//    @State private var shaderSpeedMultiplier: Double = Constants.initialSpeedMultiplier
//    @State private var elapsedTime: Double = 0.0
//    @State private var isLongPressing: Bool = false // *** NEW: Tracks long press state
//
//    // Microphone Recording State (Optional, can be toggled by tap)
//    @State private var isRecording: Bool = false
//
//    // Ripple Effect State (Controlled by Tap)
//    @State private var rippleCounter: Int = 0
//    @State private var rippleOrigin: CGPoint = .zero
//
//    // MARK: Body
//    var body: some View {
//        TimelineView(.periodic(from: .now, by: Constants.updateInterval / shaderSpeedMultiplier)) { context in
//            ZStack {
//                // 1. Background Layer with Long Press Gesture for Shader
//                backgroundLayerView
//
//                // 2. Foreground UI Content (Image has Tap Gesture)
//                foregroundUiView
//            }
//            .onChange(of: context.date) { _, newDate in
//                // Continuous time update for shader animation regardless of interaction
//                elapsedTime += Constants.updateInterval * shaderSpeedMultiplier
//            }
//            // Haptic feedback for long press start/end
//            .sensoryFeedback(.impact(intensity: 0.7), trigger: isLongPressing) { oldValue, newValue in
//                 // Trigger only on state change (start: false->true, end: true->false)
//                 oldValue != newValue
//            }
//        }
//    }
//
//    // MARK: Background View with Long Press
//    private var backgroundLayerView: some View {
//        // Apply the long press gesture to the entire background area
//        Color.clear // Takes up space and catches gestures
//            .ignoresSafeArea()
//            .background {
//                // The shader itself
//                Rectangle()
//                    .ignoresSafeArea()
//                    .colorEffect(ShaderLibrary.default.harmonicColorEffect(
//                        .boundingRect,
//                        .float(6),
//                        .float(elapsedTime),
//                        .float(shaderAmplitude),
//                        // Mix coefficient based on LONG PRESS state
//                        .float(isLongPressing ? 1.0 : 0.0)
//                    ))
//            }
//            .contentShape(Rectangle()) // Ensure the clear color receives gestures
//            .gesture(
//                LongPressGesture(minimumDuration: Constants.longPressDuration)
//                    .onChanged { pressing in
//                        // This closure is called when the minimum duration is met (`pressing` is true)
//                        // and potentially again if the finger moves (we ignore that here).
//                        // We only care about the transition *to* the long-press state.
//                        if pressing && !isLongPressing {
//                            isLongPressing = true
//                            withAnimation(.spring(duration: Constants.animationDuration)) {
//                                shaderAmplitude = Constants.activeAmplitude
//                                shaderSpeedMultiplier = Constants.activeSpeedMultiplier
//                            }
//                             print("Long Press Started") // Debug
//                        }
//                    }
//                    .onEnded { _ in
//                        // This closure is called when the press ends (finger lifted)
//                        // *after* the minimum duration was met.
//                        if isLongPressing {
//                            isLongPressing = false
//                            withAnimation(.spring(duration: Constants.animationDuration)) {
//                                shaderAmplitude = Constants.initialAmplitude
//                                shaderSpeedMultiplier = Constants.initialSpeedMultiplier
//                            }
//                             print("Long Press Ended") // Debug
//                        }
//                    }
//            )
//    }
//
//    // MARK: Foreground UI View (Structure Unchanged)
//    private var foregroundUiView: some View {
//        VStack {
//            Spacer()
//            statusTextView
//                .padding(.bottom, 30)
//            microphoneImageView // Contains the tap gesture for ripple
//                .padding(.bottom, 50)
//        }
//        .padding()
//         // Let background gestures pass through the VStack container
//        .allowsHitTesting(false)
//    }
//
//    // MARK: Subviews for Foreground UI
//
//    // Status Text (Updated to reflect long press)
//    private var statusTextView: some View {
//         Text(statusText)
//             .font(.title2)
//             .fontWeight(.semibold)
//             .foregroundStyle(.white)
//             .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 1)
//             .multilineTextAlignment(.center)
//             .frame(minHeight: 50)
//             .animation(.easeInOut(duration: 0.2), value: statusText)
//     }
//
//    // Microphone Image View (with Tap Gesture for Ripple)
//    private var microphoneImageView: some View {
//        Image(Constants.micImageName)
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: 150, height: 150)
//            .overlay { // Recording overlay (unchanged)
//                 if isRecording {
//                     RoundedRectangle(cornerRadius: 24).fill(.black.opacity(0.3))
//                     Image(systemName: "mic.fill").font(.system(size: 50)).foregroundStyle(.red.opacity(0.8))
//                 }
//             }
//            .clipShape(RoundedRectangle(cornerRadius: 24))
//            // *** Make the image tappable ***
//            .allowsHitTesting(true)
//            // *** Use onTapGesture for the RIPPLE effect ***
//            .onTapGesture { location in // `location` is the tap point within the image's bounds
//                 // Trigger the ripple
//                 rippleOrigin = location // Set ripple start point
//                 rippleCounter += 1     // Increment trigger
//
//                 // Optionally, toggle recording or perform other tap action
//                 toggleRecording()
//
//                 // Haptic feedback specifically for the tap
//                 UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                 print("Image Tapped at \(location)") // Debug
//            }
//            // Apply the RippleEffect modifier, triggered by the tap
//            .modifier(
//                RippleEffect(
//                    at: rippleOrigin,
//                    trigger: rippleCounter,
//                    duration: Constants.rippleDuration
//                )
//            )
//            // Animate recording overlay (unchanged)
//            .animation(.bouncy(duration: 0.3), value: isRecording)
//
//            // REMOVED: .onPressingChanged modifier is no longer needed here
//    }
//
//    // MARK: Computed Properties (Updated statusText)
//    private var statusText: String {
//        if isRecording {
//            return "Recording Active...\n(Tap Mic to Stop)"
//        // *** Check long press state for background animation status ***
//        } else if isLongPressing {
//            return "Hold Engaged...\n(Release to Idle)"
//        } else {
//            return "Long Press Background for Wave\nTap Mic for Ripple & Record"
//        }
//    }
//
//    // MARK: Actions (toggleRecording - Unchanged)
//     private func toggleRecording() {
//         isRecording.toggle()
//         // Keep haptic separate for tap action if desired, or remove if tap haptic above is enough
//         // UIImpactFeedbackGenerator(style: isRecording ? .medium : .light).impactOccurred()
//         if isRecording {
//             print("START Recording (Mock)")
//         } else {
//             print("STOP Recording (Mock)")
//         }
//     }
//}
//
//// MARK: - Previews
//#Preview("ContentView") {
//    ContentView()
//        .background(Color.black)
//}
//
//// MARK: - Ripple Effect Modifiers (Keep version with duration - Unchanged)
//struct RippleEffect<T: Equatable>: ViewModifier {
//    var origin: CGPoint
//    var trigger: T
//    var duration: TimeInterval
//
//    init(at origin: CGPoint, trigger: T, duration: TimeInterval = 1.5) { // Default duration adjusted
//        self.origin = origin
//        self.trigger = trigger
//        self.duration = duration
//    }
//
//     func body(content: Content) -> some View {
//         let effectOrigin = origin
//         let effectDuration = duration
//
//         content.keyframeAnimator(
//             initialValue: 0,
//             trigger: trigger
//         ) { view, elapsedTime in
//             view.modifier(RippleModifier(
//                 origin: effectOrigin,
//                 elapsedTime: elapsedTime,
//                 duration: effectDuration
//             ))
//         } keyframes: { _ in
//             MoveKeyframe(0)
//             LinearKeyframe(effectDuration, duration: effectDuration)
//         }
//     }
//}
//
//struct RippleModifier: ViewModifier {
//    var origin: CGPoint
//    var elapsedTime: TimeInterval
//    var duration: TimeInterval
//
//    var amplitude: Double = 12
//    var frequency: Double = 15
//    var decay: Double = 8
//    var speed: Double = 1200
//
//    func body(content: Content) -> some View {
//        let shader = ShaderLibrary.Ripple(
//            .float2(origin), .float(elapsedTime), .float(amplitude),
//            .float(frequency), .float(decay), .float(speed)
//        )
//        let maxSampleOffset = self.maxSampleOffset
//        let effectElapsedTime = elapsedTime
//        let effectDuration = duration
//
//        content.visualEffect { view, _ in
//            view.layerEffect(
//                shader, maxSampleOffset: maxSampleOffset,
//                isEnabled: 0 < effectElapsedTime && effectElapsedTime < effectDuration
//            )
//        }
//    }
//
//    var maxSampleOffset: CGSize { CGSize(width: amplitude, height: amplitude) }
//}
//
//// MARK: - Spatial Pressing Gesture Helpers (No longer directly used by Image, but keep if needed elsewhere)
//// Although not used for the image ripple anymore, these might be useful
//// for other interactions, so they can be kept. If definitely not needed,
//// they can be removed.
// extension View {
//     func onPressingChanged(_ action: @escaping (CGPoint?) -> Void) -> some View {
//         modifier(SpatialPressingGestureModifier(onPressingChanged: action))
//     }
// }
//
// struct SpatialPressingGestureModifier: ViewModifier {
//     var onPressingChanged: (CGPoint?) -> Void
//     @State private var currentLocation: CGPoint?
//
//     func body(content: Content) -> some View {
//         let gesture = SpatialPressingGesture(location: $currentLocation)
//
//         content
//             .gesture(gesture)
//             .onChange(of: currentLocation) { _, newLocation in
//                 onPressingChanged(newLocation)
//             }
//     }
// }
//
// struct SpatialPressingGesture: UIGestureRecognizerRepresentable {
//     final class Coordinator: NSObject, UIGestureRecognizerDelegate {
//         @objc func gestureRecognizer(_ g: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith o: UIGestureRecognizer) -> Bool { true }
//     }
//     @Binding var location: CGPoint?
//     func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator { Coordinator() }
//     func makeUIGestureRecognizer(context: Context) -> UILongPressGestureRecognizer {
//         let r = UILongPressGestureRecognizer()
//         r.minimumPressDuration = 0
//         r.delegate = context.coordinator
//         return r
//     }
//     func handleUIGestureRecognizerAction(_ r: UIGestureRecognizerType, context: Context) {
//         switch r.state {
//         case .began: location = context.converter.localLocation
//         case .ended, .cancelled, .failed: location = nil
//         default: break
//         }
//     }
// }
//
//// MARK: - Shader Library Placeholder
