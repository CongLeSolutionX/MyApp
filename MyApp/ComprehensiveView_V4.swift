////
////  ComprehensiveView_V4.swift
////  MyApp
////
////  Created by Cong Le on 4/29/25.
////
//
//import SwiftUI
//import MetalKit // Import MetalKit for runtime compilation
//import Combine // Needed for ShaderLibrary compilation management
//
//// MARK: - Metal Shader Code (Embedded as Strings)
//
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
//// Calculates the distance to the harmonic wave
//float harmonicSDF(float2 uv, float a, float offset, float f, float phi) {
//    return abs((uv.y - offset) + cos(uv.x * f + phi) * a);
//}
//
//// Simple glow effect based on distance
//float glow(float x, float str, float dist){
//    return dist / pow(abs(x), str);
//}
//
//// Returns a color from a predefined palette based on index 't'
//float3 getColor(float t) {
//    int index = int(round(t));
//
//    // Using the hardcoded palette
//    if (index == 0) return float3(0.4823529412, 0.831372549, 0.8549019608); // Teal-ish
//    if (index == 1) return float3(0.4117647059, 0.4117647059, 0.8470588235); // Purple-ish
//    if (index == 2) return float3(0.9411764706, 0.3137254902, 0.4117647059); // Red-pink
//    if (index == 3) return float3(0.2745098039, 0.4901960784, 0.9411764706); // Blue
//    if (index == 4) return float3(0.0784313725, 0.862745098, 0.862745098); // Cyan
//    if (index == 5) return float3(0.7843137255, 0.6274509804, 0.5490196078); // Brown-ish / Dusty Rose
//    return float3(1.0); // White fallback
//}
//
//// MARK: - Main Harmonic Shader Function
//
//[[ stitchable ]]
//half4 harmonicColorEffect(
//    float2 pos,         // Pixel position in view coordinates
//    half4 color,        // Original pixel color (not used here)
//    float4 bounds,      // Bounding rect (x, y, width, height) of the view
//    float wavesCount,   // Number of harmonic waves to layer
//    float time,         // Animation time elapsed
//    float amplitude,    // Base amplitude (controlled by SwiftUI state)
//    float mixCoeff      // 0.0 (released) to 1.0 (pressed) interpolation coefficient
//) {
//    // Normalize pixel coordinates to [-0.5, 0.5] range centered at (0,0)
//    float2 uv = (pos - float2(bounds.x, bounds.y)) / float2(bounds.z, bounds.w);
//    uv -= float2(0.5, 0.5);
//
//    // Base amplitude modulation based on horizontal position
//    float a = cos(uv.x * 3.0) * amplitude * 0.2;
//    // Base offset modulation
//    float offset = sin(uv.x * 12.0 + time) * a * 0.1;
//
//    // Interpolate Parameters Based on Press State (mixCoeff)
//    float frequency = mix(3.0, 12.0, mixCoeff);
//    float glowWidth = mix(0.6, 0.9, mixCoeff);
//    float glowIntensity = mix(0.02, 0.01, mixCoeff);
//
//    // Loop Through Waves
//    float3 finalColor = float3(0.0);
//    for (float i = 0.0; i < wavesCount; i++) {
//        float phase = time + i * M_PI_F / wavesCount;
//        float sdfDist = harmonicSDF(uv, a, offset, frequency, phase);
//        float glowDist = glow(sdfDist, glowWidth, glowIntensity);
//        float3 waveColor = mix(float3(1.0), getColor(i), mixCoeff); // White when released, palette color when pressed
//        finalColor += waveColor * glowDist;
//    }
//
//    // Return Final Color
//    finalColor = clamp(finalColor, 0.0, 1.0);
//    return half4(half3(finalColor), 1.0h);
//}
//"""
//
//let rippleShaderSource = """
//#include <metal_stdlib>
//#include <SwiftUI/SwiftUI_Metal.h> // Use the correct header for layer effects
//
//using namespace metal;
//
//[[ stitchable ]]
//half4 Ripple( // Function name must match the reference in ShaderLibrary
//    float2 position,    // Pixel position in layer coordinates
//    SwiftUI::Layer layer, // The layer to sample from
//    float2 origin,      // Center of the ripple in layer coordinates
//    float time,         // Elapsed time for the animation
//    // Parameters
//    float amplitude,
//    float frequency,
//    float decay,
//    float speed
//) {
//    float distance = length(position - origin);
//    float delay = distance / speed;
//
//    // Adjust time for delay, ensure non-negative
//    time = max(0.0, time - delay);
//
//    // Calculate ripple amount: sine wave scaled by exponential decay
//    float rippleAmount = amplitude * sin(frequency * time) * exp(-decay * time);
//
//    // Vector pointing away from the origin towards the current position
//    // Use safe normalization
//    float2 direction = position - origin;
//    float dirLength = length(direction);
//    float2 n = (dirLength > 1e-6) ? direction / dirLength : float2(0.0, 0.0); // Avoid normalize(0)
//
//    // Displace the sampling position along the normalized direction
//    float2 newPosition = position + rippleAmount * n;
//
//    // Sample the original layer content at the displaced position
//    half4 color = layer.sample(newPosition);
//
//    // Optional: Lighten/darken based on ripple intensity
//    // Be careful with this, it can look unnatural. Ensure color.a is handled.
//    // Ensure rippleAmount/amplitude is clamped or scaled appropriately
//    // float intensityFactor = clamp(0.3 * (rippleAmount / amplitude), -0.3, 0.3); // Example clamping
//    // color.rgb = clamp(color.rgb + intensityFactor * color.a, 0.0, 1.0);
//
//    return color;
//}
//"""
//
//// MARK: - Metal Library Manager (for runtime compilation)
//
//class MetalLibraryManager {
//    static let shared = MetalLibraryManager()
//
//    let device: MTLDevice
//    private(set) var library: MTLLibrary?
//    private(set) var error: Error?
//
//    private init() {
//        guard let metalDevice = MTLCreateSystemDefaultDevice() else {
//            fatalError("Metal is not supported on this device")
//        }
//        self.device = metalDevice
//        compileLibraries()
//    }
//
//    private func compileLibraries() {
//        let combinedSource = harmonicShaderSource + "\n\n" + rippleShaderSource
//        let options = MTLCompileOptions()
//        options.libraryType = .dynamic // Required for stitchable functions
//        options.installName = "@TestLibrary" // Necessary for dynamic libraries
//
//        do {
//            library = try device.makeLibrary(source: combinedSource, options: options)
//            print("Metal library compiled successfully.")
//        } catch let compileError {
//            error = compileError
//            print("Error compiling Metal library: \(compileError.localizedDescription)")
//            // Consider more robust error handling or UI feedback
//        }
//    }
//
//    func getFunction(name: String) -> MTLFunction? {
//        guard let lib = library else {
//            print("Error: Metal library not available.")
//            return nil
//        }
//        guard let function = lib.makeFunction(name: name) else {
//             print("Error: Could not find Metal function named '\(name)'")
//             return nil
//         }
//        return function
//    }
//}
//
//// MARK: - Shader Library Extension (to use runtime compiled library)
//
//extension ShaderLibrary {
//     // Convenience accessor using the singleton manager
//     static var runtimeCompiled: ShaderLibrary {
//         if let lib = MetalLibraryManager.shared.library {
//             return ShaderLibrary(bundle: lib)
//         } else {
//              // Fallback or error handling - perhaps return default or log error
//              print("WARNING: Runtime Metal library failed to compile or is not ready. Using default library if available.")
//              // You might need a placeholder or default shader library here
//              // For simplicity, we'll return default, but this might crash if shaders aren't also in bundle
//              return ShaderLibrary.default // Or handle more gracefully
//         }
//     }
// }
//
//// MARK: - Constants
//struct Constants {
//    static let updateInterval: Double = 0.016
//    static let initialAmplitude: Float = 0.5
//    static let activeAmplitude: Float = 2.0
//    static let initialSpeedMultiplier: Double = 1.0
//    static let activeSpeedMultiplier: Double = 2.0
//    static let animationDuration: Double = 0.3
//    static let rippleDuration: TimeInterval = 1.5
//    static let longPressDuration: Double = 0.2
//    static let micImageName: String = "My-meme-orange-microphone" // Make sure this image is in Assets
//}
//
//// MARK: - Main Content View
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
//    // Access the compiled library (ensure manager is initialized)
//    private let shaderLibrary = ShaderLibrary.runtimeCompiled
//
//    // MARK: Body
//    var body: some View {
//        // Check if Metal compilation succeeded before rendering views using it
//        if MetalLibraryManager.shared.library != nil {
//             timelineViewContent
//         } else {
//             // Display an error message or fallback UI if Metal failed
//             VStack {
//                 Image(systemName: "exclamationmark.triangle.fill")
//                     .resizable()
//                     .scaledToFit()
//                     .frame(width: 50, height: 50)
//                     .foregroundColor(.orange)
//                 Text("Shader Error")
//                     .font(.title)
//                 Text("Could not load visual effects.")
//                     .multilineTextAlignment(.center)
//                     .padding()
//                 if let error = MetalLibraryManager.shared.error {
//                      Text("Details: \(error.localizedDescription)")
//                          .font(.caption)
//                          .foregroundColor(.gray)
//                          .padding()
//                 }
//             }
//         }
//     }
//
//    // Extracted TimelineView content for clarity
//    private var timelineViewContent: some View {
//         TimelineView(.periodic(from: .now, by: Constants.updateInterval / shaderSpeedMultiplier)) { context in
//             ZStack {
//                 backgroundLayerView
//                 foregroundUiView
//             }
//             .onChange(of: context.date) { _, _ in
//                 elapsedTime += Constants.updateInterval * shaderSpeedMultiplier
//             }
//             .sensoryFeedback(.impact(intensity: 0.7), trigger: isLongPressing) { $0 != $1 }
//         }
//     }
//
//    // MARK: Background View with Long Press
//    private var backgroundLayerView: some View {
//        Color.clear
//            .ignoresSafeArea()
//            .background {
//                Rectangle()
//                    .ignoresSafeArea()
//                     // Use the runtime compiled shader library
//                    .colorEffect(shaderLibrary.harmonicColorEffect(
//                        .boundingRect,
//                        .float(6),
//                        .float(elapsedTime),
//                        .float(shaderAmplitude),
//                        .float(isLongPressing ? 1.0 : 0.0)
//                    ))
//            }
//            .contentShape(Rectangle())
//            .gesture(
//                LongPressGesture(minimumDuration: Constants.longPressDuration)
//                    .onChanged { pressing in
//                        if pressing && !isLongPressing {
//                            isLongPressing = true
//                            withAnimation(.spring(duration: Constants.animationDuration)) {
//                                shaderAmplitude = Constants.activeAmplitude
//                                shaderSpeedMultiplier = Constants.activeSpeedMultiplier
//                            }
//                        }
//                    }
//                    .onEnded { _ in
//                        if isLongPressing {
//                            isLongPressing = false
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
//            Spacer()
//            statusTextView.padding(.bottom, 30)
//            microphoneImageView.padding(.bottom, 50) // Contains tap gesture
//        }
//        .padding()
//        .allowsHitTesting(false) // Let background gestures pass through
//    }
//
//    // MARK: Subviews for Foreground UI
//
//    private var statusTextView: some View {
//         Text(statusText)
//             .font(.title2).fontWeight(.semibold).foregroundStyle(.white)
//             .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 1)
//             .multilineTextAlignment(.center).frame(minHeight: 50)
//             .animation(.easeInOut(duration: 0.2), value: statusText)
//     }
//
//    private var microphoneImageView: some View {
//        // Ensure the image exists in your Assets
//        Image(Constants.micImageName)
//            .resizable().aspectRatio(contentMode: .fit).frame(width: 150, height: 150)
//            .overlay { // Recording overlay
//                 if isRecording {
//                     RoundedRectangle(cornerRadius: 24).fill(.black.opacity(0.3))
//                     Image(systemName: "mic.fill").font(.system(size: 50)).foregroundStyle(.red.opacity(0.8))
//                 }
//             }
//            .clipShape(RoundedRectangle(cornerRadius: 24))
//            .allowsHitTesting(true) // Can be tapped
//            .onTapGesture { location in
//                 rippleOrigin = location
//                 rippleCounter += 1
//                 toggleRecording() // Optional action
//                 UIImpactFeedbackGenerator(style: .light).impactOccurred()
//             }
//             // Apply RippleEffect modifier - references runtime compiled shader library indirectly
//             // via RippleModifier which uses the static `shaderLibrary` property.
//            .modifier(
//                RippleEffect(
//                    at: rippleOrigin, trigger: rippleCounter, duration: Constants.rippleDuration,
//                    shaderLibrary: shaderLibrary // Pass the compiled library instance
//                )
//            )
//            .animation(.bouncy(duration: 0.3), value: isRecording)
//    }
//
//    // MARK: Computed Properties
//    private var statusText: String {
//        if isRecording { return "Recording Active...\n(Tap Mic to Stop)" }
//        else if isLongPressing { return "Hold Engaged...\n(Release to Idle)" }
//        else { return "Long Press Background for Wave\nTap Mic for Ripple & Record" }
//    }
//
//    // MARK: Actions
//     private func toggleRecording() {
//         isRecording.toggle()
//         if isRecording { print("START Recording (Mock)") }
//         else { print("STOP Recording (Mock)") }
//     }
//}
//
//// MARK: - Ripple Effect Modifiers (UPDATED to accept ShaderLibrary)
//
//struct RippleEffect<T: Equatable>: ViewModifier {
//    var origin: CGPoint
//    var trigger: T
//    var duration: TimeInterval
//    var shaderLibrary: ShaderLibrary // <<< Pass the library instance
//
//    init(at origin: CGPoint, trigger: T, duration: TimeInterval = 1.5, shaderLibrary: ShaderLibrary) {
//        self.origin = origin
//        self.trigger = trigger
//        self.duration = duration
//        self.shaderLibrary = shaderLibrary
//    }
//
//     func body(content: Content) -> some View {
//         let effectOrigin = origin
//         let effectDuration = duration
//         let lib = shaderLibrary // Capture library instance
//
//         content.keyframeAnimator(
//             initialValue: 0, trigger: trigger
//         ) { view, elapsedTime in
//             view.modifier(RippleModifier(
//                 origin: effectOrigin,
//                 elapsedTime: elapsedTime,
//                 duration: effectDuration,
//                 shaderLibrary: lib // <<< Pass to RippleModifier
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
//    var shaderLibrary: ShaderLibrary // <<< Receive the library instance
//
//    // Ripple Shader Parameters
//    var amplitude: Double = 12
//    var frequency: Double = 15
//    var decay: Double = 8
//    var speed: Double = 1200
//
//    func body(content: Content) -> some View {
//        // Use the passed shader library instance
//        let shader = shaderLibrary.Ripple( // <<< Uses the passed library
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
//    var maxSampleOffset: CGSize { CGSize(width: amplitude, height: amplitude) }
//}
//
//// MARK: - Previews
//#Preview {
//    ContentView()
//        .background(Color.black) // Add background for preview visibility
//}
//
//// NOTE: Spatial Pressing Gesture Helpers are removed as they are no longer needed
//// for the primary interactions described. Add them back if required elsewhere.
