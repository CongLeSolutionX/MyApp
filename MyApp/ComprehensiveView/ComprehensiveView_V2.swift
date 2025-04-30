////
////  ComprehensiveView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/29/25.
////
//
//import SwiftUI
//import MetalKit
//
//// MARK: - Constants (Keep from previous enhancement)
//struct Constants {
//    static let updateInterval: Double = 0.016
//    static let initialAmplitude: Float = 0.5
//    static let activeAmplitude: Float = 2.0
//    static let initialSpeedMultiplier: Double = 1.0
//    static let activeSpeedMultiplier: Double = 2.0
//    static let animationDuration: Double = 0.3
//    static let rippleDuration: TimeInterval = 1.5 // Adjusted ripple duration
//    static let micImageName: String = "My-meme-orange-microphone"
//}
//
//// MARK: - Main Content View (Mostly unchanged structure)
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
//    @State private var rippleCounter: Int = 0 // Trigger for the ripple animation
//    @State private var rippleOrigin: CGPoint = .zero // Location where ripple starts
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
//                elapsedTime += Constants.updateInterval * shaderSpeedMultiplier
//            }
//            // Haptic for background interaction
//            .sensoryFeedback(.impact(intensity: 0.7), trigger: isInteractingWithBackground) { _, newValue in
//                !isInteractingWithBackground && newValue
//            }
//        }
//    }
//
//    // MARK: Background View (Unchanged from previous enhancement)
//    private var backgroundLayerView: some View {
//        Color.clear
//            .ignoresSafeArea()
//            .background {
//                Rectangle()
//                    .ignoresSafeArea()
//                    .colorEffect(ShaderLibrary.default.harmonicColorEffect(
//                        .boundingRect,
//                        .float(6),
//                        .float(elapsedTime),
//                        .float(shaderAmplitude),
//                        .float(isInteractingWithBackground ? 1.0 : 0.0)
//                    ))
//            }
//            .gesture(
//                DragGesture(minimumDistance: 0)
//                    .onChanged { _ in
//                        if !isInteractingWithBackground {
//                            isInteractingWithBackground = true
//                            withAnimation(.spring(duration: Constants.animationDuration)) {
//                                shaderAmplitude = Constants.activeAmplitude
//                                shaderSpeedMultiplier = Constants.activeSpeedMultiplier
//                            }
//                        }
//                    }
//                    .onEnded { _ in
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
//    // MARK: Foreground UI View (Unchanged structure)
//    private var foregroundUiView: some View {
//        VStack {
//            Spacer()
//            statusTextView
//                .padding(.bottom, 30)
//            microphoneImageView // The view we are modifying interaction for
//                .padding(.bottom, 50)
//        }
//        .padding()
//        .allowsHitTesting(false)
//    }
//
//    // MARK: Subviews for Foreground UI
//
//     // Status Text (Unchanged)
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
//    // MARK: Microphone Image View (MODIFIED INTERACTION)
//    private var microphoneImageView: some View {
//        Image(Constants.micImageName)
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: 150, height: 150)
//            .overlay { // Recording state overlay (Unchanged)
//                 if isRecording {
//                     RoundedRectangle(cornerRadius: 24)
//                         .fill(.black.opacity(0.3))
//                     Image(systemName: "mic.fill")
//                         .font(.system(size: 50))
//                         .foregroundStyle(.red.opacity(0.8))
//                 }
//             }
//            .clipShape(RoundedRectangle(cornerRadius: 24))
//             // Make the image itself tappable even if parent isn't
//            .allowsHitTesting(true)
//
//             // *** MODIFICATION START ***
//             // 1. Use onPressingChanged *only* to capture the origin location on initial press down.
//             //    Do NOT trigger the ripple animation (increment counter) here.
//            .onPressingChanged { point in
//                if let point {
//                    rippleOrigin = point // Capture the location where the press started
//                }
//                // We don't increment rippleCounter here anymore.
//            }
//             // 2. Use onTapGesture to trigger the ripple animation and the recording toggle
//             //    This ensures the ripple happens only after a complete tap (press up).
//            .onTapGesture {
//                 rippleCounter += 1 // Trigger the ripple animation
//                 toggleRecording() // Perform the recording action
//             }
//             // *** MODIFICATION END ***
//
//            .modifier(
//                // Apply the ripple effect, triggered by rippleCounter, starting at rippleOrigin
//                RippleEffect(
//                    at: rippleOrigin,
//                    trigger: rippleCounter,
//                    duration: Constants.rippleDuration
//                )
//            )
//             // Animate the recording overlay (Unchanged)
//            .animation(.bouncy(duration: 0.3) , value: isRecording)
//    }
//
//    // MARK: Computed Properties (Unchanged)
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
//    // MARK: Actions (Unchanged)
//    private func toggleRecording() {
//        isRecording.toggle()
//        UIImpactFeedbackGenerator(style: isRecording ? .medium : .light).impactOccurred()
//        if isRecording {
//            print("START Recording (Mock)")
//        } else {
//            print("STOP Recording (Mock)")
//        }
//    }
//}
//
//// MARK: - Previews (Unchanged)
//#Preview("ContentView") {
//    ContentView()
//        .background(Color.black)
//}
//
//// MARK: - Ripple Effect Modifiers (Keep the version enhanced with duration)
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
//        let effectOrigin = origin
//        let effectDuration = duration
//
//        content.keyframeAnimator(
//            initialValue: 0, // Represents elapsedTime
//            trigger: trigger
//        ) { view, elapsedTime in
//            view.modifier(RippleModifier(
//                origin: effectOrigin,
//                elapsedTime: elapsedTime,
//                duration: effectDuration
//            ))
//        } keyframes: { _ in
//            MoveKeyframe(0)
//            LinearKeyframe(effectDuration, duration: effectDuration)
//        }
//    }
//}
//
//struct RippleModifier: ViewModifier {
//    var origin: CGPoint
//    var elapsedTime: TimeInterval
//    var duration: TimeInterval
//
//    // Ripple Shader Parameters
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
//        let maxSampleOffset = self.maxSampleOffset
//        let effectElapsedTime = elapsedTime
//        let effectDuration = duration
//
//        content.visualEffect { view, _ in
//            view.layerEffect(
//                shader,
//                maxSampleOffset: maxSampleOffset,
//                isEnabled: 0 < effectElapsedTime && effectElapsedTime < effectDuration
//            )
//        }
//    }
//
//    var maxSampleOffset: CGSize {
//        CGSize(width: amplitude, height: amplitude)
//    }
//}
//
//// MARK: - Spatial Pressing Gesture Helpers (Keep the version without iOS 18 check)
//extension View {
//    func onPressingChanged(_ action: @escaping (CGPoint?) -> Void) -> some View {
//        modifier(SpatialPressingGestureModifier(onPressingChanged: action))
//    }
//}
//
//struct SpatialPressingGestureModifier: ViewModifier {
//    var onPressingChanged: (CGPoint?) -> Void
//    @State private var currentLocation: CGPoint?
//
//    func body(content: Content) -> some View {
//        let gesture = SpatialPressingGesture(location: $currentLocation)
//
//        content
//            .gesture(gesture)
//            .onChange(of: currentLocation) { _, newLocation in
//                onPressingChanged(newLocation)
//            }
//    }
//}
//
//struct SpatialPressingGesture: UIGestureRecognizerRepresentable {
//    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
//        @objc
//        func gestureRecognizer(
//            _ gestureRecognizer: UIGestureRecognizer,
//            shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
//        ) -> Bool {
//            true
//        }
//    }
//
//    @Binding var location: CGPoint?
//
//    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
//        Coordinator()
//    }
//
//    func makeUIGestureRecognizer(context: Context) -> UILongPressGestureRecognizer {
//        let recognizer = UILongPressGestureRecognizer()
//        recognizer.minimumPressDuration = 0
//        recognizer.delegate = context.coordinator
//        return recognizer
//    }
//
//    func handleUIGestureRecognizerAction(
//        _ recognizer: UIGestureRecognizerType, context: Context) {
//            switch recognizer.state {
//            case .began:
//                location = context.converter.localLocation
//            case .ended, .cancelled, .failed:
//                location = nil
//            default:
//                break
//            }
//        }
//}
//
//// MARK: - Shader Library Placeholder (Assume shaders are present)
