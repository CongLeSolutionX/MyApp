////
////  ComprehensiveView_V5.swift
////  MyApp
////
////  Created by Cong Le on 4/29/25.
////
//
//import SwiftUI
//import MetalKit // Required for runtime compilation and Metal types
//import Combine // Required for MetalLibraryManager if using Combine for async (though not strictly needed here)
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
//// SDFs return the shortest distance to a surface; positive outside, negative inside.
//// Here, we use abs(), so it's more like an unsigned distance field (distance magnitude).
//float harmonicSDF(float2 uv, float amplitude, float verticalOffset, float frequency, float phase) {
//    // uv.y: vertical position
//    // verticalOffset: base vertical shift
//    // cos(uv.x * frequency + phase) * amplitude: the cosine wave itself
//    // The difference gives the vertical distance from the point uv to the wave.
//    return abs((uv.y - verticalOffset) + cos(uv.x * frequency + phase) * amplitude);
//}
//
//// Creates a simple glow effect based on the inverse power of the distance.
//// Smaller distances (closer to the line) result in higher intensity.
//float glow(float distance, float strength, float intensityScale) {
//    // pow(abs(distance), strength): Controls how quickly the glow falls off. Higher strength = sharper falloff.
//    // intensityScale / ... : Scales the overall brightness.
//    // Adding a small epsilon prevents division by zero if distance is exactly 0.
//    return intensityScale / (pow(abs(distance), strength) + 1e-6);
//}
//
//// Returns a color from a predefined palette based on index 't'.
//// This allows different waves in the loop to have distinct colors.
//float3 getColor(float t) {
//    int index = int(round(t)); // Convert float index (e.g., 0.0, 1.0, ...) to integer
//
//    // Hardcoded color palette
//    // Represented as float3(Red, Green, Blue) with values between 0.0 and 1.0
//    if (index == 0) return float3(0.4823529412, 0.831372549, 0.8549019608); // Teal-ish
//    if (index == 1) return float3(0.4117647059, 0.4117647059, 0.8470588235); // Purple-ish
//    if (index == 2) return float3(0.9411764706, 0.3137254902, 0.4117647059); // Red-pink
//    if (index == 3) return float3(0.2745098039, 0.4901960784, 0.9411764706); // Blue
//    if (index == 4) return float3(0.0784313725, 0.862745098, 0.862745098); // Cyan
//    if (index == 5) return float3(0.7843137255, 0.6274509804, 0.5490196078); // Brown-ish / Dusty Rose
//
//    return float3(1.0); // Default to white if index is out of range
//}
//
//// MARK: - Main Harmonic Shader Function (`colorEffect`)
//
//// 'stitchable' allows this function to be dynamically linked if needed by SwiftUI.
//[[ stitchable ]]
//half4 harmonicColorEffect(
//    float2 pos,         // Current pixel's position in the view's coordinate space.
//    half4 color,        // Original color of the pixel (often ignored when generating effects).
//    float4 bounds,      // The bounding rectangle of the view (x, y, width, height).
//    float wavesCount,   // The number of overlapping waves to draw.
//    float time,         // A float representing elapsed time for animation.
//    float baseAmplitude,// Base amplitude for the waves (controlled by SwiftUI state).
//    float mixCoeff      // Interpolation coefficient (0.0 to 1.0) for press state.
//) {
//    // 1. Normalize Coordinates: Convert pixel position to a normalized space,
//    //    usually [-0.5, 0.5] or [0, 1], centered at (0,0). Makes math independent of view size.
//    float2 uv = (pos - float2(bounds.x, bounds.y)) / float2(bounds.z, bounds.w); // Scale to [0, 1] range
//    uv -= float2(0.5, 0.5); // Shift origin to center [-0.5, 0.5]
//
//    // 2. Base Parameters Calculation: Define base characteristics of the wave pattern.
//    // Modulate amplitude based on horizontal position for visual interest.
//    float a = cos(uv.x * 3.0) * baseAmplitude * 0.2;
//    // Modulate the vertical offset slightly based on horizontal position and time for a flowing effect.
//    float offset = sin(uv.x * 12.0 + time) * a * 0.1;
//
//    // 3. Interpolate Parameters based on Press State (`mixCoeff`):
//    //    Smoothly transition shader parameters when the user presses/releases.
//    //    `mix(start, end, coefficient)` performs linear interpolation.
//    float frequency = mix(3.0, 12.0, mixCoeff);    // Lower frequency when idle, higher when pressed
//    float glowWidth = mix(0.6, 0.9, mixCoeff);     // Sharper glow when idle, softer when pressed
//    float glowIntensity = mix(0.02, 0.01, mixCoeff); // Brighter glow when idle, dimmer when pressed
//
//    // 4. Wave Loop: Calculate the contribution of each wave layer.
//    float3 finalColor = float3(0.0); // Accumulator for the final color
//    for (float i = 0.0; i < wavesCount; i++) {
//        // Calculate a unique phase for each wave based on time and its index (i).
//        // This makes the waves move relative to each other.
//        float phase = time + i * M_PI_F / wavesCount;
//
//        // Calculate the distance from the current pixel (uv) to this specific wave.
//        float sdfDist = harmonicSDF(uv, a, offset, frequency, phase);
//
//        // Calculate the glow intensity based on the distance.
//        float glowDist = glow(sdfDist, glowWidth, glowIntensity);
//
//        // Determine the color for this wave. Interpolate between white (idle) and a palette color (pressed).
//        float3 waveColor = mix(float3(1.0), getColor(i), mixCoeff);
//
//        // Add the colored glow of this wave to the final color.
//        finalColor += waveColor * glowDist;
//    }
//
//    // 5. Final Output: Clamp the accumulated color to the valid [0, 1] range
//    //    and return it as a half4 (RGBA format for SwiftUI).
//    finalColor = clamp(finalColor, 0.0, 1.0);
//    return half4(half3(finalColor), 1.0h); // Use 'h' suffix for half-precision constants
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
//half4 Ripple( // Function name must match the reference when creating the Shader instance
//    float2 position,    // Current pixel's position in the layer's coordinate space.
//    SwiftUI::Layer layer, // Represents the layer content to be sampled.
//    float2 origin,      // The center point of the ripple effect in layer coordinates.
//    float time,         // Elapsed time since the ripple was triggered.
//    // --- Input Parameters ---
//    float amplitude,    // Maximum displacement distance of the ripple.
//    float frequency,    // How many wave cycles appear over time.
//    float decay,        // How quickly the ripple fades out (exponential decay).
//    float speed         // How fast the ripple propagates outwards.
//) {
//    // 1. Calculate Distance: Find the distance from the current pixel to the ripple origin.
//    float distance = length(position - origin);
//
//    // 2. Calculate Time Delay: Ripples further away should start later.
//    //    delay = distance / speed
//    float delay = distance / speed;
//
//    // Adjust the effective time for this pixel based on the delay.
//    // Ensure time is non-negative (effect doesn't start before time = delay).
//    float effectiveTime = max(0.0, time - delay);
//
//    // 3. Calculate Ripple Amount: Determine how much to displace the pixel sampling.
//    //    This uses a sine wave multiplied by an exponential decay function.
//    //    sin(frequency * effectiveTime): Creates the oscillating wave.
//    //    exp(-decay * effectiveTime): Makes the wave amplitude decrease over time.
//    float rippleAmount = amplitude * sin(frequency * effectiveTime) * exp(-decay * effectiveTime);
//
//    // 4. Calculate Displacement Direction: Find the vector pointing from the origin to the pixel.
//    float2 direction = position - origin;
//    // Normalize the direction vector to get a unit vector.
//    // Includes a check to prevent normalizing a zero vector (division by zero).
//    float dirLength = length(direction);
//    float2 normalizedDirection = (dirLength > 1e-6) ? direction / dirLength : float2(0.0, 0.0);
//
//    // 5. Calculate New Sampling Position: Displace the current pixel's position
//    //    along the normalized direction by the calculated ripple amount.
//    float2 displacedPosition = position + rippleAmount * normalizedDirection;
//
//    // 6. Sample Original Layer: Read the color from the original layer content
//    //    at the *displaced* position. This creates the distortion effect.
//    half4 originalColor = layer.sample(displacedPosition);
//
//    /* // Optional: Additive lighting/darkening based on ripple (can look artificial)
//    float intensityFactor = clamp(0.3 * (rippleAmount / (amplitude + 1e-6)), -0.3, 0.3);
//    // Apply factor only to RGB, scaled by alpha, and clamp result
//    originalColor.rgb = clamp(originalColor.rgb + intensityFactor * originalColor.a, 0.0, 1.0);
//    */
//
//    // 7. Return Final Color: Return the sampled (and optionally modified) color.
//    return originalColor;
//}
//"""
//
//// MARK: - Metal Library Manager (Handles Runtime Compilation)
//
//class MetalLibraryManager {
//    // Singleton instance for easy access
//    static let shared = MetalLibraryManager()
//
//    let device: MTLDevice // The GPU device
//    private(set) var library: MTLLibrary? // The compiled Metal library
//    private(set) var error: Error? // Stores any compilation error
//
//    // Private initializer ensures singleton pattern
//    private init() {
//        // Attempt to get the default Metal device for the system
//        guard let metalDevice = MTLCreateSystemDefaultDevice() else {
//            // Fatal error if Metal is not supported at all
//            fatalError("Metal is not supported on this device")
//        }
//        self.device = metalDevice
//        print("Metal device found: \(device.name)")
//        // Compile the shaders when the manager is initialized
//        compileLibraries()
//    }
//
//    private func compileLibraries() {
//        // Combine the source code of both shaders into one string
//        let combinedSource = harmonicShaderSource + "\n\n" + rippleShaderSource
//
//        // Configure compilation options
//        let options = MTLCompileOptions()
//        // Stitchable functions needed by SwiftUI require a dynamic library type
//        options.libraryType = .dynamic
//        // `installName` is necessary for dynamic libraries, used for linking.
//        // The specific name doesn't usually matter unless linking multiple dynamic libs.
//        options.installName = "@SwiftUIMetalShaders" // Example name
//
//        do {
//            // Attempt to compile the combined source code into a Metal library
//            print("Compiling Metal library...")
//            library = try device.makeLibrary(source: combinedSource, options: options)
//            error = nil // Clear any previous error
//            print("Metal library compiled successfully.")
//        } catch let compileError {
//            // Store the error if compilation fails
//            error = compileError
//            library = nil // Ensure library is nil on error
//            // Log detailed error information
//            print("❌ Error compiling Metal library: \(compileError.localizedDescription)")
//            if let nsError = compileError as NSError?,
//               let log = nsError.userInfo[MTLLibraryErrorFunctionErrorKey] {
//                 print("--- Metal Compiler Log ---")
//                 print(log)
//                 print("-------------------------")
//             }
//        }
//    }
//
//    // Helper function (optional) to get a specific function from the library by name
//     func getFunction(name: String) -> MTLFunction? {
//         guard let lib = library else {
//             print("Error: Metal library not available (compilation likely failed).")
//             return nil
//         }
//         guard error == nil else {
//             print("Error: Metal library compilation failed previously.")
//             return nil
//         }
//         guard let function = lib.makeFunction(name: name) else {
//              print("Error: Could not find Metal function named '\(name)' in the compiled library.")
//              return nil
//          }
//         return function
//     }
//}
//
//// MARK: - MTLLibrary Extension (Convenience Accessor)
//
//// Provides easy access to the runtime-compiled library.
//extension MTLLibrary {
//    static var runtimeCompiled: MTLLibrary? {
//        // Access the singleton manager
//        let manager = MetalLibraryManager.shared
//        // Return the library only if it exists AND no error occurred
//        if let lib = manager.library, manager.error == nil {
//            return lib
//        } else {
//            // Log if accessed when library isn't ready
//            if manager.library == nil {
//                print("Warning: Accessing runtime Metal library before successful compilation or because compilation failed.")
//            }
//            if let e = manager.error {
//                print("Detailed Error: \(e.localizedDescription)")
//            }
//            return nil // Indicate library is not ready/valid
//        }
//    }
//}
//
//// MARK: - Constants
//
//struct Constants {
//    // Timing
//    static let updateInterval: Double = 0.016 // Approx 60 FPS for TimelineView updates
//    static let animationDuration: Double = 0.3 // Duration for spring animations
//    static let rippleDuration: TimeInterval = 1.5 // How long the ripple effect lasts
//    static let longPressDuration: Double = 0.2 // Min duration to trigger long press
//
//    // Shader Parameters
//    static let initialAmplitude: Float = 0.5 // Background wave amplitude when idle
//    static let activeAmplitude: Float = 2.0  // Background wave amplitude when pressed
//    static let initialSpeedMultiplier: Double = 1.0 // Animation speed multiplier when idle
//    static let activeSpeedMultiplier: Double = 2.0 // Animation speed multiplier when pressed
//    static let harmonicWavesCount: Float = 6.0 // Number of waves in background effect
//
//    // Ripple Shader Parameters (Adjust these for different ripple looks)
//    static let rippleAmplitude: Float = 15.0
//    static let rippleFrequency: Float = 18.0
//    static let rippleDecay: Float = 8.0
//    static let rippleSpeed: Float = 1200.0
//
//    // UI Elements
//    static let micImageName: String = "My-meme-orange-microphone" // Ensure this image is in Assets.xcassets
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
//    @State private var elapsedTime: Double = 0.0 // Accumulates time for animations
//    @State private var isLongPressing: Bool = false // Tracks background long press state
//    @State private var isRecording: Bool = false // Tracks recording state (mic tapped)
//    @State private var rippleCounter: Int = 0 // Increments to trigger ripple animation
//    @State private var rippleOrigin: CGPoint = .zero // Stores tap location for ripple center
//
//    // Access the compiled library object directly via the extension
//    private var runtimeMetalLibrary: MTLLibrary? {
//        MTLLibrary.runtimeCompiled
//    }
//
//    // MARK: Body
//    var body: some View {
//        // Conditional rendering: Show main UI only if Metal library compiled successfully
//        if let metalLib = runtimeMetalLibrary {
//             timelineViewContent(metalLibrary: metalLib) // Pass the valid library
//         } else {
//             // Show an informative error view if compilation failed
//             errorHandlingView
//         }
//     }
//
//    // Extracted TimelineView content to keep body clean
//    // Accepts the compiled Metal library as a parameter.
//     private func timelineViewContent(metalLibrary: MTLLibrary) -> some View {
//         TimelineView(.periodic(from: .now, by: Constants.updateInterval / shaderSpeedMultiplier)) { context in
//             // ZStack layers the background effect and the foreground UI
//            ZStack {
//                 // Background view handles the long press and displays the harmonic wave shader
//                 backgroundLayerView(metalLibrary: metalLibrary)
//
//                 // Foreground view contains the status text and the interactive microphone image
//                 foregroundUiView(metalLibrary: metalLibrary)
//             }
//             // Update elapsed time on each TimelineView tick
//             .onChange(of: context.date) { _, _ in
//                 elapsedTime += Constants.updateInterval * shaderSpeedMultiplier
//             }
//             // Add subtle haptic feedback when long press state changes
//             .sensoryFeedback(.impact(weight: .light, intensity: 0.7), trigger: isLongPressing)
//         }
//         // Ensure the view ignores safe area to fill the screen if desired
//         .ignoresSafeArea()
//         // Optional: Set a base background color if needed
//         .background(Color.black)
//     }
//
//    // Extracted view for displaying an error message if Metal fails
//    private var errorHandlingView: some View {
//        VStack(spacing: 15) {
//            Image(systemName: "exclamationmark.triangle.fill")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 60, height: 60)
//                .foregroundColor(.orange)
//
//            Text("Shader Compilation Error")
//                .font(.title2)
//                .fontWeight(.bold)
//
//            Text("Could not initialize visual effects. Metal shader compilation failed.")
//                .font(.body)
//                .foregroundColor(.gray)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//
//            // Display detailed error if available from the manager
//            if let error = MetalLibraryManager.shared.error {
//                 ScrollView {
//                    Text("Details:\n\(error.localizedDescription)")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                        .padding()
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .background(Color(uiColor: .secondarySystemBackground))
//                        .cornerRadius(8)
//                 }
//                 .frame(maxHeight: 200)
//                 .padding(.horizontal)
//             }
//        }
//        .padding()
//    }
//
//    // MARK: Background View Construction
//    private func backgroundLayerView(metalLibrary: MTLLibrary) -> some View {
//        Color.clear // Start with a clear color, the effect will draw onto it
//            .background { // Apply the effect to the background of the clear color
//                Rectangle() // The actual drawable area for the effect
//                    .colorEffect( // Apply the Metal shader as a color effect
//                         // Create the Shader instance directly using the library and function name
//                        Shader(
//                            function: ShaderFunction(library: metalLibrary, name: "harmonicColorEffect"),
//                            arguments: [
//                                // Map SwiftUI state/constants to shader arguments IN ORDER
//                                .boundingRect, // Provides pos and bounds automatically
//                                .float(Constants.harmonicWavesCount), // wavesCount
//                                .float(elapsedTime), // time
//                                .float(shaderAmplitude), // baseAmplitude
//                                .float(isLongPressing ? 1.0 : 0.0) // mixCoeff (0.0 or 1.0)
//                            ]
//                        )
//                    )
//            }
//             // Important: Ensure the background fills the available space and is tappable
//            .contentShape(Rectangle()) // Make the whole area respond to gestures
//            .gesture(longPressGesture) // Attach the long press gesture
//            .ignoresSafeArea() // Allow effect to go edge-to-edge
//    }
//
//    // MARK: Foreground UI Construction
//    private func foregroundUiView(metalLibrary: MTLLibrary) -> some View {
//          VStack { // Arrange status text and mic vertically
//              Spacer() // Push content towards the bottom
//
//              statusTextView
//                 .padding(.bottom, 30) // Spacing below text
//
//              // Microphone image, passing the Metal library for the ripple effect
//              microphoneImageView(metalLibrary: metalLibrary)
//                 .padding(.bottom, 50) // Spacing below mic
//          }
//          .padding() // Padding around the VStack content
//          .allowsHitTesting(false) // IMPORTANT: Let gestures pass through the VStack to the background
//      }
//
//    // MARK: UI Sub-Components
//
//    // Displays the current status text
//    private var statusTextView: some View {
//         Text(statusText) // Dynamic text based on state
//             .font(.title3)
//             .fontWeight(.medium)
//             .foregroundStyle(.white)
//             .shadow(color: .black.opacity(0.7), radius: 5, x: 0, y: 2) // Text shadow for legibility
//             .multilineTextAlignment(.center)
//             .frame(minHeight: 50) // Ensure consistent height to avoid layout jumps
//             .animation(.easeInOut(duration: 0.25), value: statusText) // Animate text changes
//     }
//
//    // Displays the microphone image and handles tap interaction
//    private func microphoneImageView(metalLibrary: MTLLibrary) -> some View {
//        Image(Constants.micImageName)
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: Constants.micImageSize, height: Constants.micImageSize)
//            .overlay(recordingOverlay) // Add recording indicator conditionally
//            .clipShape(RoundedRectangle(cornerRadius: Constants.micCornerRadius))
//             .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5) // Mic shadow
//            .allowsHitTesting(true) // Explicitly allow taps on the image itself
//            .onTapGesture { location in // Capture tap location
//                 handleMicTap(at: location)
//             }
//             // Apply the custom ripple effect modifier, passing theMetal library
//            .modifier(
//                RippleEffect(
//                    at: rippleOrigin, // Center the ripple at the tap location
//                    trigger: rippleCounter, // Trigger animation when counter changes
//                    duration: Constants.rippleDuration,
//                    metalLibrary: metalLibrary // Pass the compiled library
//                )
//            )
//             // Add a subtle bounce animation when recording state changes
//            .animation(.bouncy(duration: 0.35), value: isRecording)
//    }
//
//    // Conditional overlay view shown when recording is active
//    @ViewBuilder
//    private var recordingOverlay: some View {
//         if isRecording {
//             ZStack { // Layer the background and icon
//                 // Semi-transparent overlay
//                 RoundedRectangle(cornerRadius: Constants.micCornerRadius)
//                    .fill(.black.opacity(0.4))
//
//                 // Pulsating red mic icon
//                 Image(systemName: "mic.fill")
//                    .font(.system(size: 50))
//                    .foregroundStyle(.red.opacity(0.8))
//                    .symbolEffect(.pulse, options: .repeating, value: isRecording) // Added pulsating effect
//             }
//             .transition(.opacity.animation(.easeInOut)) // Fade in/out
//         }
//     }
//
//    // MARK: Computed Properties
//
//    // Generates user-facing status text based on current state
//    private var statusText: String {
//        if isRecording {
//            return "Recording Active...\n(Tap Mic to Stop)"
//        } else if isLongPressing {
//            return "Hold Engaged...\n(Release to Relax Waves)"
//        } else {
//             return "Long Press Background for Waves\nTap Mic for Ripple & Record Toggle"
//         }
//    }
//
//    // Defines the long press gesture for the background
//    private var longPressGesture: some Gesture {
//        LongPressGesture(minimumDuration: Constants.longPressDuration)
//            .onChanged { pressing in
//                 // Trigger state change only when starting the press
//                 if pressing && !isLongPressing {
//                     isLongPressing = true
//                     // Animate shader parameters to "active" state
//                     withAnimation(.spring(duration: Constants.animationDuration)) {
//                         shaderAmplitude = Constants.activeAmplitude
//                         shaderSpeedMultiplier = Constants.activeSpeedMultiplier
//                     }
//                 }
//             }
//             .onEnded { _ in
//                 // Trigger state change only if it was actually long pressing
//                 if isLongPressing {
//                     isLongPressing = false
//                      // Animate shader parameters back to "idle" state
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
//    // Handles the logic when the microphone image is tapped
//    private func handleMicTap(at location: CGPoint) {
//        rippleOrigin = location // Set ripple center to tap location
//        rippleCounter += 1 // Increment counter to trigger the RippleEffect animation
//        toggleRecording() // Toggle the recording state
//        // Provide immediate haptic feedback for the tap
//        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//    }
//
//     // Toggles the recording state and prints mock logs
//     private func toggleRecording() {
//         isRecording.toggle()
//         if isRecording { print("🎤 START Recording (Mock Action)") }
//         else { print("🎤 STOP Recording (Mock Action)") }
//     }
//}
//
//// MARK: - Ripple Effect Modifier Implementation
//
//// Attaches the keyframe animator and the core RippleModifier.
//// Needs the compiled Metal library.
//struct RippleEffect<T: Equatable>: ViewModifier {
//    var origin: CGPoint
//    var trigger: T // Value change triggers the animation
//    var duration: TimeInterval
//    var metalLibrary: MTLLibrary // Accepts the compiled library
//
//     init(at origin: CGPoint, trigger: T, duration: TimeInterval, metalLibrary: MTLLibrary) {
//         self.origin = origin
//         self.trigger = trigger
//         self.duration = duration
//         self.metalLibrary = metalLibrary
//     }
//
//     func body(content: Content) -> some View {
//         // Use a keyframe animator to drive the ripple's elapsed time from 0 to `duration`
//         // whenever the `trigger` value changes.
//         content.keyframeAnimator(
//             initialValue: RippleAnimationState.idle, // Start state
//             trigger: trigger // Re-run animation when trigger changes
//         ) { view, animationState in
//             // Apply the actual shader modifier, passing the current elapsed time
//             view.modifier(RippleModifier(
//                 origin: origin,
//                 elapsedTime: animationState.elapsedTime, // Get time from state
//                 duration: duration, // Pass total duration
//                 metalLibrary: metalLibrary // Pass the library
//             ))
//         } keyframes: { _ in // Define the animation progression
//             // Start at time 0
//             KeyframeTrack(\.elapsedTime) {
//                 LinearKeyframe(0.0, duration: 0) // Initial state
//                 LinearKeyframe(duration, duration: duration) // Animate linearly to full duration
//             }
//         }
//     }
//
//    // Helper struct to manage animation state within KeyframeAnimator
//    struct RippleAnimationState: Hashable {
//        var elapsedTime: TimeInterval = 0
//        static let idle = RippleAnimationState()
//    }
//}
//
//// Applies the actual Metal ripple shader using layerEffect.
//// Needs the compiled Metal library.
//struct RippleModifier: ViewModifier {
//    var origin: CGPoint
//    var elapsedTime: TimeInterval
//    var duration: TimeInterval // Total duration of the effect
//    var metalLibrary: MTLLibrary // Accepts the compiled library
//
//    // Ripple Shader Parameters (using global Constants)
//    let amplitude: Float = Constants.rippleAmplitude
//    let frequency: Float = Constants.rippleFrequency
//    let decay: Float = Constants.rippleDecay
//    let speed: Float = Constants.rippleSpeed
//
//    func body(content: Content) -> some View {
//        // Create the Shader instance for the ripple effect
//        let shader = Shader(
//            function: ShaderFunction(library: metalLibrary, name: "Ripple"), // Specify function and library
//            arguments: [
//                // Pass arguments in the correct order matching the MSL function
//                .float2(origin),
//                .float(elapsedTime),
//                .float(amplitude),
//                .float(frequency),
//                .float(decay),
//                .float(speed)
//            ]
//        )
//
//        // Calculate the maximum potential displacement for maxSampleOffset
//        // This helps SwiftUI optimize rendering. Should be slightly larger than max amplitude.
//        let maxSampleOffset = CGSize(width: CGFloat(amplitude * 1.1), height: CGFloat(amplitude * 1.1))
//
//        // Apply the shader as a layer effect using visualEffect
//        content.visualEffect { view, geometryProxy in // `view` is the content being modified
//            view.layerEffect(
//                shader, // The compiled shader instance
//                maxSampleOffset: maxSampleOffset, // Inform SwiftUI about max displacement
//                 // Enable the effect only during its active duration (0 < time < total duration)
//                 // This prevents the shader from running unnecessarily before/after the animation.
//                isEnabled: 0 < elapsedTime && elapsedTime < duration
//            )
//        }
//    }
//}
//
//// MARK: - Preview Provider
//
//#Preview {
//    // Ensure preview runs correctly
//    ContentView()
//        // Provide a background for better visibility in the preview canvas
//       .preferredColorScheme(.dark) // Set a preferred scheme if desired
//}
