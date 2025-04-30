////
////  ComprehensiveView_V6.swift
////  MyApp
////
////  Created by Cong Le on 4/29/25.
////
//
//import SwiftUI
//import MetalKit // Required for runtime compilation, error keys, and Metal types
//import Combine // Can be used for more complex async operations if needed
//
//// MARK: - Metal Shader Code (Embedded as Strings)
//
//// Shader source for the background harmonic wave effect
//let harmonicShaderSource = """
//#include <metal_stdlib>
//#include <SwiftUI/SwiftUI_Metal.h> // Required for SwiftUI integration
//
//using namespace metal;
//
//// Constant for Pi
//#define M_PI_F 3.141592653589793f
//
//// MARK: - Helper Functions (Harmonic)
//
//// Calculates the Signed Distance Function (SDF) to the harmonic wave.
//// Returns the shortest distance to the surface (unsigned due to abs).
//float harmonicSDF(float2 uv, float amplitude, float verticalOffset, float frequency, float phase) {
//    // uv.y: vertical position
//    // verticalOffset: base vertical shift
//    // cos(uv.x * frequency + phase) * amplitude: the cosine wave itself
//    // The difference gives the vertical distance from the point uv to the wave.
//    return abs((uv.y - verticalOffset) + cos(uv.x * frequency + phase) * amplitude);
//}
//
//// Creates a simple glow effect based on the inverse power of the distance.
//float glow(float distance, float strength, float intensityScale) {
//    // pow(abs(distance), strength): Controls glow falloff. Higher strength = sharper falloff.
//    // intensityScale / ... : Scales overall brightness.
//    // Adding epsilon prevents division by zero.
//    return intensityScale / (pow(abs(distance), strength) + 1e-6);
//}
//
//// Returns a color from a predefined palette based on index 't'.
//float3 getColor(float t) {
//    int index = int(round(t)); // Convert float index to integer
//
//    // Hardcoded color palette (RGB float values 0.0-1.0)
//    if (index == 0) return float3(0.482, 0.831, 0.855); // Teal-ish
//    if (index == 1) return float3(0.412, 0.412, 0.847); // Purple-ish
//    if (index == 2) return float3(0.941, 0.314, 0.412); // Red-pink
//    if (index == 3) return float3(0.275, 0.490, 0.941); // Blue
//    if (index == 4) return float3(0.078, 0.863, 0.863); // Cyan
//    if (index == 5) return float3(0.784, 0.627, 0.549); // Brown-ish / Dusty Rose
//
//    return float3(1.0); // Default to white
//}
//
//// MARK: - Main Harmonic Shader Function (`colorEffect`)
//
//// 'stitchable' allows dynamic linking by SwiftUI.
//[[ stitchable ]]
//half4 harmonicColorEffect(
//    float2 pos,         // Current pixel's position (view coordinates).
//    half4 color,        // Original color (ignored here).
//    float4 bounds,      // View bounds (x, y, width, height).
//    float wavesCount,   // Number of waves.
//    float time,         // Elapsed time for animation.
//    float baseAmplitude,// Base amplitude from SwiftUI.
//    float mixCoeff      // Press state interpolation (0=idle, 1=pressed).
//) {
//    // 1. Normalize Coordinates: [-0.5, 0.5], origin at center.
//    float2 uv = (pos - float2(bounds.x, bounds.y)) / float2(bounds.z, bounds.w); // [0, 1]
//    uv -= float2(0.5, 0.5); // [-0.5, 0.5]
//
//    // 2. Base Parameters: Modulate based on position/time.
//    float a = cos(uv.x * 3.0) * baseAmplitude * 0.2;
//    float offset = sin(uv.x * 12.0 + time) * a * 0.1;
//
//    // 3. Interpolate Parameters based on Press State (`mixCoeff`).
//    float frequency = mix(3.0, 12.0, mixCoeff);    // Freq increases on press.
//    float glowWidth = mix(0.6, 0.9, mixCoeff);     // Glow spreads on press.
//    float glowIntensity = mix(0.02, 0.01, mixCoeff); // Glow dims slightly on press.
//
//    // 4. Wave Loop: Accumulate color from each wave layer.
//    float3 finalColor = float3(0.0);
//    for (float i = 0.0; i < wavesCount; i++) {
//        float phase = time + i * M_PI_F / wavesCount; // Unique phase per wave.
//        float sdfDist = harmonicSDF(uv, a, offset, frequency, phase); // Distance to this wave.
//        float glowDist = glow(sdfDist, glowWidth, glowIntensity); // Glow amount.
//
//        // Interpolate color between white (idle) and palette color (pressed).
//        float3 waveColor = mix(float3(1.0), getColor(i), mixCoeff);
//
//        finalColor += waveColor * glowDist; // Add this wave's contribution.
//    }
//
//    // 5. Final Output: Clamp and return as half4 (RGBA).
//    finalColor = clamp(finalColor, 0.0, 1.0);
//    return half4(half3(finalColor), 1.0h); // 'h' suffix for half constants.
//}
//"""
//
//// Shader source for the ripple effect applied as a layer effect
//let rippleShaderSource = """
//#include <metal_stdlib>
//#include <SwiftUI/SwiftUI_Metal.h> // Use the correct header for layer effects
//
//using namespace metal;
//
//// MARK: - Main Ripple Shader Function (`layerEffect`)
//
//[[ stitchable ]]
//half4 Ripple( // Function name matches Shader instance creation in Swift
//    float2 position,    // Pixel position (layer coordinates).
//    SwiftUI::Layer layer, // Layer content sampler.
//    float2 origin,      // Ripple center (layer coordinates).
//    float time,         // Elapsed time since ripple trigger.
//    // --- Input Parameters ---
//    float amplitude,    // Max displacement.
//    float frequency,    // Wave cycles.
//    float decay,        // Fade out speed.
//    float speed         // Propagation speed.
//) {
//    // 1. Calculate Distance from origin.
//    float distance = length(position - origin);
//
//    // 2. Calculate Time Delay based on distance and speed.
//    float delay = distance / speed;
//    float effectiveTime = max(0.0, time - delay); // Time since wave reached this pixel.
//
//    // 3. Calculate Ripple Amount (displacement magnitude): Sine wave * Exponential Decay.
//    float rippleAmount = amplitude * sin(frequency * effectiveTime) * exp(-decay * effectiveTime);
//
//    // 4. Calculate Displacement Direction (vector from origin to pixel).
//    float2 direction = position - origin;
//    float dirLength = length(direction);
//    // Normalize, handle zero vector case.
//    float2 normalizedDirection = (dirLength > 1e-6) ? direction / dirLength : float2(0.0, 0.0);
//
//    // 5. Calculate New Sampling Position: Displace along direction by ripple amount.
//    float2 displacedPosition = position + rippleAmount * normalizedDirection;
//
//    // 6. Sample Original Layer at the distorted position.
//    half4 originalColor = layer.sample(displacedPosition);
//
//    // 7. Return Final Color.
//    return originalColor;
//}
//"""
//
//// MARK: - Metal Library Manager (Handles Runtime Compilation)
//
//class MetalLibraryManager {
//    // Singleton instance
//    static let shared = MetalLibraryManager()
//
//    let device: MTLDevice // The GPU
//    private(set) var library: MTLLibrary? // Compiled library
//    private(set) var error: Error? // Compilation error, if any
//
//    // Private init for singleton
//    private init() {
//        guard let metalDevice = MTLCreateSystemDefaultDevice() else {
//            fatalError("Metal is not supported on this device")
//        }
//        self.device = metalDevice
//        print("Metal device found: \(device.name)")
//        compileLibraries() // Compile shaders on initialization
//    }
//
//    private func compileLibraries() {
//        // Combine both shader sources
//        let combinedSource = harmonicShaderSource + "\n\n" + rippleShaderSource
//
//        let options = MTLCompileOptions()
//        options.libraryType = .dynamic // Required for stitchable functions
//        options.installName = "@SwiftUIMetalShaders_Runtime" // Unique name, needed for dynamic libs
//
//        do {
//            print("Compiling Metal library...")
//            library = try device.makeLibrary(source: combinedSource, options: options)
//            error = nil // Success, clear any previous error
//            print("Metal library compiled successfully.")
//        } catch let compileError {
//            error = compileError // Store error
//            library = nil // Ensure library is nil on error
//            print("❌ Error compiling Metal library: \(compileError.localizedDescription)")
//
//            // Attempt to log detailed compiler errors using the correct key
//            if let nsError = compileError as NSError?,
//               // **FIX**: Use MTLLibraryErrorDomain and the correct key string directly
//               nsError.domain == MTLLibraryErrorDomain,
//               let log = nsError.userInfo[MTLFunctionErrorKeyUserInfoKeyCompilationLog] as? String {
//                print("--- Metal Compiler Log ---")
//                print(log)
//                print("-------------------------")
//            } else if let nsError = compileError as NSError? {
//                 // Print generic error info if specific log key not found
//                 print("--- Error UserInfo ---")
//                 print(nsError.userInfo)
//                 print("----------------------")
//            }
//        }
//    }
//}
//
//// MARK: - Constants
//
//struct Constants {
//    // Timing
//    static let updateInterval: Double = 0.016 // Target ~60 FPS updates
//    static let animationDuration: Double = 0.3 // Spring animation speed
//    static let rippleDuration: TimeInterval = 1.5 // Visual ripple effect duration
//    static let longPressDuration: Double = 0.2 // Min duration for long press trigger
//
//    // Shader Parameters
//    static let initialAmplitude: Float = 0.5 // Background wave amplitude (idle)
//    static let activeAmplitude: Float = 2.0  // Background wave amplitude (pressed)
//    static let initialSpeedMultiplier: Double = 1.0 // Animation speed (idle)
//    static let activeSpeedMultiplier: Double = 2.0 // Animation speed (pressed)
//    static let harmonicWavesCount: Float = 6.0 // Number of layers in background
//
//    // Ripple Shader Parameters
//    static let rippleAmplitude: Float = 15.0 // Max ripple displacement
//    static let rippleFrequency: Float = 18.0 // Ripple wave frequency
//    static let rippleDecay: Float = 8.0  // Ripple fade out rate
//    static let rippleSpeed: Float = 1200.0 // Ripple outward speed
//
//    // UI Elements
//    static let micImageName: String = "My-meme-orange-microphone" // Ensure this is in Assets.xcassets
//    static let micImageSize: CGFloat = 150.0
//    static let micCornerRadius: CGFloat = 24.0
//}
//
//// MARK: - Main Content View
//
//struct ContentView: View {
//    // MARK: State Variables
//    @State private var shaderAmplitude: Float = Constants.initialAmplitude
//    @State private var shaderSpeedMultiplier: Double = Constants.initialSpeedMultiplier
//    @State private var elapsedTime: Double = 0.0
//    @State private var isLongPressing: Bool = false
//    @State private var isRecording: Bool = false
//    @State private var rippleCounter: Int = 0
//    @State private var rippleOrigin: CGPoint = .zero
//
//    // **FIX**: Access the compiled library object via the singleton manager directly
//    private var runtimeMetalLibrary: MTLLibrary? {
//        let manager = MetalLibraryManager.shared
//        // Return library only if no compilation error occurred AND library exists
//        if manager.error == nil, let lib = manager.library {
//            return lib
//        } else {
//            // Log details if library isn't available
//            if let e = manager.error {
//                print("ContentView: Accessing Metal library failed due to compilation error: \(e.localizedDescription)")
//            } else if manager.library == nil {
//                 print("ContentView: Accessing Metal library failed because manager.library is nil.")
//            }
//            return nil
//        }
//    }
//
//    // MARK: Body
//    var body: some View {
//        // Conditional rendering based on successful Metal library compilation
//        if let metalLib = runtimeMetalLibrary {
//            timelineViewContent(metalLibrary: metalLib) // Pass the valid library
//        } else {
//            // Show an informative error view
//            errorHandlingView
//        }
//    }
//
//    // Extracted content view using TimelineView
//    private func timelineViewContent(metalLibrary: MTLLibrary) -> some View {
//        TimelineView(.periodic(from: .now, by: Constants.updateInterval / shaderSpeedMultiplier)) { context in
//            ZStack {
//                // Background effect layer + gesture handling
//                backgroundLayerView(metalLibrary: metalLibrary)
//
//                // Foreground UI elements (text, mic)
//                foregroundUiView(metalLibrary: metalLibrary)
//            }
//            .onChange(of: context.date) { _, _ in // Update time based on timeline
//                elapsedTime += Constants.updateInterval * shaderSpeedMultiplier
//            }
//            .sensoryFeedback(.impact(weight: .light, intensity: 0.7), trigger: isLongPressing) // Haptic feedback
//        }
//        .ignoresSafeArea()
//        .background(Color.black) // Base background
//    }
//
//    // View shown if Metal compilation fails
//    private var errorHandlingView: some View {
//        VStack(spacing: 15) {
//            Image(systemName: "exclamationmark.triangle.fill")
//                .resizable().scaledToFit().frame(width: 60, height: 60).foregroundColor(.orange)
//            Text("Shader Compilation Error").font(.title2).fontWeight(.bold)
//            Text("Could not initialize visual effects. Metal shader compilation failed.").font(.body).foregroundColor(.gray).multilineTextAlignment(.center).padding(.horizontal)
//
//            // Display detailed error from the manager if available
//            if let error = MetalLibraryManager.shared.error {
//                 ScrollView {
//                    Text("Details:\n\(error.localizedDescription)")
//                        .font(.caption).foregroundColor(.secondary).padding()
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .background(Color(uiColor: .secondarySystemBackground)).cornerRadius(8)
//                 }
//                 .frame(maxHeight: 200).padding(.horizontal)
//             }
//        }
//        .padding()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.black.ignoresSafeArea()) // Match background
//    }
//
//    // MARK: Background View Construction
//    private func backgroundLayerView(metalLibrary: MTLLibrary) -> some View {
//        Color.clear // Base transparent color
//            .background { // Apply effect to the background
//                Rectangle() // Drawable area
//                    .colorEffect( // Apply harmonic wave shader
//                        Shader( // Create shader instance using runtime library
//                            function: ShaderFunction(library: metalLibrary, name: "harmonicColorEffect"),
//                            arguments: [ // Arguments MUST match MSL function order
//                                .boundingRect, // Provides pos & bounds
//                                .float(Constants.harmonicWavesCount), // wavesCount
//                                .float(elapsedTime), // time
//                                .float(shaderAmplitude), // baseAmplitude
//                                .float(isLongPressing ? 1.0 : 0.0) // mixCoeff (passed as float)
//                            ]
//                        )
//                    )
//            }
//            .contentShape(Rectangle()) // Ensure entirearea is tappable for gesture
//            .gesture(longPressGesture)
//            .ignoresSafeArea()
//    }
//
//    // MARK: Foreground UI Construction
//    private func foregroundUiView(metalLibrary: MTLLibrary) -> some View {
//        VStack {
//            Spacer() // Push to bottom
//
//            statusTextView
//               .padding(.bottom, 30)
//
//            microphoneImageView(metalLibrary: metalLibrary) // Pass library for ripple
//               .padding(.bottom, 50)
//        }
//        .padding()
//        .allowsHitTesting(false) // Let taps/gestures pass through to the background
//    }
//
//    // MARK: UI Sub-Components
//
//    // Dynamic status text view
//    private var statusTextView: some View {
//         Text(statusText)
//             .font(.title3).fontWeight(.medium).foregroundStyle(.white)
//             .shadow(color: .black.opacity(0.7), radius: 5, x: 0, y: 2)
//             .multilineTextAlignment(.center)
//             .frame(minHeight: 50) // Prevent layout jumps
//             .animation(.easeInOut(duration: 0.25), value: statusText) // Animate text change
//     }
//
//    // Microphone image view with tap handling and ripple effect
//    private func microphoneImageView(metalLibrary: MTLLibrary) -> some View {
//        Image(Constants.micImageName)
//            .resizable().aspectRatio(contentMode: .fit)
//            .frame(width: Constants.micImageSize, height: Constants.micImageSize)
//            .overlay(recordingOverlay) // Conditional recording indicator
//            .clipShape(RoundedRectangle(cornerRadius: Constants.micCornerRadius))
//            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
//            .allowsHitTesting(true) // Allow taps specifically on the mic image
//            .onTapGesture { location in // Capture tap location relative to image
//                 handleMicTap(at: location)
//             }
//            .modifier( // Apply custom ripple effect
//                RippleEffect(
//                    origin: rippleOrigin, // Ripple center in image coordinates
//                    trigger: rippleCounter, // Animation trigger
//                    duration: Constants.rippleDuration,
//                    metalLibrary: metalLibrary // Pass the library
//                )
//            )
//            .animation(.bouncy(duration: 0.35), value: isRecording) // Bounce on record toggle
//    }
//
//    // Pulsating overlay shown during recording
//    @ViewBuilder
//    private var recordingOverlay: some View {
//         if isRecording {
//             ZStack {
//                 RoundedRectangle(cornerRadius: Constants.micCornerRadius).fill(.black.opacity(0.4))
//                 Image(systemName: "mic.fill")
//                    .font(.system(size: 50)).foregroundStyle(.red.opacity(0.8))
//                    .symbolEffect(.pulse, options: .repeating, value: isRecording) // iOS 17+ pulse effect
//             }
//             .transition(.opacity.animation(.easeInOut))
//         }
//     }
//
//    // MARK: Computed Properties
//
//    // Generates status text based on current app state
//    private var statusText: String {
//        if isRecording { return "Recording Active...\n(Tap Mic to Stop)"}
//        else if isLongPressing { return "Hold Engaged...\n(Release to Relax Waves)" }
//        else { return "Long Press Background for Waves\nTap Mic for Ripple & Record Toggle" }
//    }
//
//    // Defines the long press gesture for the background view
//    private var longPressGesture: some Gesture {
//        LongPressGesture(minimumDuration: Constants.longPressDuration)
//            .onChanged { pressing in // Called when finger down & duration met
//                 if pressing && !isLongPressing { // Trigger only on press start
//                     isLongPressing = true
//                     withAnimation(.spring(duration: Constants.animationDuration)) {
//                         shaderAmplitude = Constants.activeAmplitude
//                         shaderSpeedMultiplier = Constants.activeSpeedMultiplier
//                     }
//                 }
//             }
//             .onEnded { _ in // Called when finger lifts or gesture cancelled
//                 if isLongPressing { // Trigger only if it was actually long pressing
//                     isLongPressing = false
//                     withAnimation(.spring(duration: Constants.animationDuration)) {
//                         shaderAmplitude = Constants.initialAmplitude
//                         shaderSpeedMultiplier = Constants.initialSpeedMultiplier
//                     }
//                 }
//             }
//    }
//
//    // MARK: Actions
//
//    // Handles tap on the microphone image
//    private func handleMicTap(at location: CGPoint) {
//        rippleOrigin = location // Store tap location for ripple center
//        rippleCounter += 1 // Increment to trigger ripple animation
//        toggleRecording() // Toggle mock recording state
//        UIImpactFeedbackGenerator(style: .medium).impactOccurred() // Immediate haptic
//    }
//
//     // Toggles recording state and logs action
//     private func toggleRecording() {
//         isRecording.toggle()
//         print(isRecording ? "🎤 START Recording (Mock Action)" : "🎤 STOP Recording (Mock Action)")
//     }
//}
//
//// MARK: - Ripple Effect Modifier Implementation
//
//// Helper struct for KeyframeAnimator state management
//struct RippleAnimationState: Hashable {
//    var elapsedTime: TimeInterval = 0
//    static let idle = RippleAnimationState() // Represents the animation start state
//}
//
//// Attaches KeyframeAnimator and the core RippleModifier.
//// Requires the compiled Metal library instance.
//struct RippleEffect<T: Equatable>: ViewModifier {
//    var origin: CGPoint // Ripple center (in the modified view's coordinate space)
//    var trigger: T // Value change triggers the animation
//    var duration: TimeInterval
//    var metalLibrary: MTLLibrary // Accepts the compiled library
//
//    func body(content: Content) -> some View {
//        // Keyframe animator drives the ripple's elapsed time from 0 to `duration`
//        content.keyframeAnimator(
//            initialValue: RippleAnimationState.idle, // Start animation state
//            trigger: trigger // Re-run animation when trigger changes
//        ) { view, animationState in
//            // Apply the actual shader modifier, passing necessary parameters
//            view.modifier(RippleModifier(
//                origin: origin,
//                elapsedTime: animationState.elapsedTime, // Time from animator state
//                duration: duration,
//                metalLibrary: metalLibrary // Pass library to the inner modifier
//            ))
//        } keyframes: { _ in // Define animation progression (linear time increase)
//            KeyframeTrack(\.elapsedTime) {
//                LinearKeyframe(0.0, duration: 0) // Start at time 0
//                LinearKeyframe(duration, duration: duration) // End at full duration
//            }
//        }
//    }
//}
//
//// Applies the Metal ripple shader using layerEffect.
//struct RippleModifier: ViewModifier {
//    var origin: CGPoint
//    var elapsedTime: TimeInterval
//    var duration: TimeInterval
//    var metalLibrary: MTLLibrary // Accepts the compiled library
//
//    // Ripple parameters from Constants
//    let amplitude: Float = Constants.rippleAmplitude
//    let frequency: Float = Constants.rippleFrequency
//    let decay: Float = Constants.rippleDecay
//    let speed: Float = Constants.rippleSpeed
//
//    func body(content: Content) -> some View {
//        // Create the Shader instance for the ripple effect
//        let shader = Shader(
//            function: ShaderFunction(library: metalLibrary, name: "Ripple"),
//            arguments: [
//                // Arguments MUST match the MSL function 'Ripple'
//                .float2(origin),          // origin
//                .float(elapsedTime),      // time
//                .float(amplitude),        // amplitude
//                .float(frequency),        // frequency
//                .float(decay),            // decay
//                .float(speed)             // speed
//            ]
//        )
//
//        // Calculate max potential displacement for optimization hint
//        let maxSampleOffset = CGSize(width: CGFloat(amplitude * 1.1), height: CGFloat(amplitude * 1.1))
//
//        // Apply shader as a layer effect
//        content.visualEffect { view, geometryProxy in
//            view.layerEffect(
//                shader,
//                maxSampleOffset: maxSampleOffset, // Hint for SwiftUI renderer
//                // Only enable effect during its active duration for performance
//                isEnabled: 0 < elapsedTime // && elapsedTime < duration // Optional: disable after duration
//            )
//        }
//    }
//}
//
//// MARK: - Preview Provider
//
//#Preview {
//    // Ensure MetalLibraryManager compiles shaders before preview renders ContentView
//    // (Technically, the singleton compiles on first access, which happens in ContentView)
//    ContentView()
//       .preferredColorScheme(.dark) // Set dark mode for preview consistency
//}
