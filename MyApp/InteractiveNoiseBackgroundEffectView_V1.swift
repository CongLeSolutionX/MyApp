//// MIT License
////
//// Copyright (c) 2025 Cong Le
////
//// Permission is hereby granted, free of charge, to any person obtaining a copy
//// of this software and associated documentation files (the "Software"), to deal
//// in the Software without restriction, including without limitation the rights
//// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//// copies of the Software, and to permit persons to whom the Software is
//// furnished to do so, subject to the following conditions:
////
//// The above copyright notice and this permission notice shall be included in all
//// copies or substantial portions of the Software.
////
//// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//// SOFTWARE.
////
//
////  InteractiveNoiseBackgroundEffectView.swift
////  MyApp
////
////  Created by Cong Le on 4/29/25.
////
//
//import SwiftUI
//import MetalKit // Not strictly needed for ShaderLibrary, but good practice
//
//// MARK: - ContentView
//
//struct ContentView: View {
//    // MARK: - State Variables
//
//    // Animation time tracking
//    @State private var elapsedTime: Double = 0.0
//    private let updateInterval: Double = 0.016 // Approx 60 FPS
//
//    // Interaction tracking
//    @State private var isInteracting: Bool = false
//    // Store interaction point in View coordinates (nil when not interacting)
//    @State private var interactionPoint: CGPoint? = nil
//
//    // Access the compiled shader
//    private let interactiveNoiseShader: Shader
//
//    // MARK: - Initializer
//    init() {
//        // Compile the Metal shader code from the inline string
//        do {
//            // Note: Using force unwrap for simplicity in this example.
//            // In production, handle potential compilation errors gracefully.
//            self.interactiveNoiseShader = try Shader(
//                library: .inline(Self.metalShaderSource),
//                functionName: "interactiveNoiseEffect"
//            )
//        } catch {
//            fatalError("Failed to compile Metal shader: \(error)")
//        }
//    }
//
//    // MARK: - Body
//    var body: some View {
//        // Use GeometryReader to get the view size for coordinate conversion
//        GeometryReader { geometry in
//            // TimelineView drives the animation updates
//            TimelineView(.periodic(from: .now, by: updateInterval)) { context in
//                ZStack {
//                    // 1. Invisible Background Layer for Shader & Gesture
//                    Color.clear
//                        .ignoresSafeArea() // Cover the entire screen
//                        .background {
//                            // Apply the shader to the background
//                            Rectangle()
//                                .ignoresSafeArea()
//                                .colorEffect(
//                                    interactiveNoiseShader, // The compiled shader
//                                    userInfo: [
//                                        // Pass necessary uniforms to the shader
//                                        "time": Shader.Argument.float(Float(elapsedTime)),
//                                        "resolution": Shader.Argument.float2(
//                                            Float(geometry.size.width * geometry.scale), // Pass resolution in physical pixels
//                                            Float(geometry.size.height * geometry.scale)
//                                        ),
//                                        // Pass interaction point converted to shader coordinates
//                                        // (Normalized [0,1], origin usually bottom-left in shaders)
//                                        "interaction_pos": .float2(
//                                            interactionShaderCoordinate(
//                                                point: interactionPoint,
//                                                viewSize: geometry.size
//                                            )
//                                        ),
//                                        // Pass interaction strength (0.0 or 1.0)
//                                        "interaction_strength": .float(isInteracting ? 1.0 : 0.0)
//                                    ]
//                                )
//                        }
//                        // Use DragGesture to track continuous touch
//                        .gesture(
//                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
//                                .onChanged { value in
//                                    // Drag started or moved
//                                    if !isInteracting {
//                                        isInteracting = true
//                                        // Optional: Add haptic feedback on touch down
//                                        // UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                                    }
//                                    interactionPoint = value.location // Update touch location
//                                }
//                                .onEnded { _ in
//                                    // Drag ended
//                                    isInteracting = false
//                                    interactionPoint = nil // Reset touch location
//                                }
//                        )
//                        // Update elapsed time on each frame
//                        .onChange(of: context.date) { _, _ in
//                            elapsedTime += updateInterval
//                        }
//
//                    // 2. Your Actual UI Content (Example)
//                    VStack {
//                        Text("Interactive Noise")
//                            .font(.largeTitle.bold())
//                            .foregroundStyle(.white)
//
//                        Text(isInteracting ? "Touching" : "Touch and Drag")
//                            .font(.headline)
//                            .foregroundStyle(.white.opacity(0.8))
//                    }
//                    .shadow(color: .black.opacity(0.5), radius: 5)
//                    .allowsHitTesting(false) // Prevent UI from blocking gesture
//
//                } // End ZStack
//            } // End TimelineView
//        } // End GeometryReader
//    } // End body
//
//    // MARK: - Helper Functions
//
//    /// Converts a SwiftUI CGPoint (top-left origin) to a normalized
//    /// shader coordinate (bottom-left origin [0,1]).
//    /// Returns (-1, -1) if the input point is nil, signaling no interaction.
//    private func interactionShaderCoordinate(point: CGPoint?, viewSize: CGSize) -> SIMD2<Float> {
//        guard let point = point, viewSize.width > 0, viewSize.height > 0 else {
//            return SIMD2<Float>(-1.0, -1.0) // Indicate no valid interaction point
//        }
//
//        // Normalize x: (point.x / viewSize.width)
//        let normalizedX = Float(point.x / viewSize.width)
//        // Normalize y and invert: (1.0 - (point.y / viewSize.height))
//        let normalizedY = 1.0 - Float(point.y / viewSize.height)
//
//        return SIMD2<Float>(normalizedX, normalizedY)
//    }
//
//    // MARK: - Embedded Metal Shader Source Code
//    // Note: Embedding long strings works, but for complex shaders, separate .metal files are better.
//
//    static let metalShaderSource = """
//    #include <metal_stdlib>
//    #include <SwiftUI/SwiftUI_Metal.h> // For stitchable
//
//    using namespace metal;
//
//    // --- Utility Functions ---
//
//    // Simple pseudo-random number generator (hash)
//    float random(float2 st) {
//        // distance() provides a simple way to mix x and y non-linearly
//        // fract(sin(...)) is a common way to get pseudo-randomness
//        return fract(sin(distance(st, float2(12.9898, 78.233))) * 43758.5453123);
//    }
//
//    // Basic Value Noise - interpolates random values at integer grid points
//    float valueNoise(float2 st) {
//        float2 i = floor(st); // Integer part
//        float2 f = fract(st); // Fractional part
//
//        // Get random values at the four corners of the grid cell
//        float a = random(i);
//        float b = random(i + float2(1.0, 0.0));
//        float c = random(i + float2(0.0, 1.0));
//        float d = random(i + float2(1.0, 1.0));
//
//        // Smoothly interpolate between the corner values (using smoothstep)
//        float2 u = f * f * (3.0 - 2.0 * f); // smoothstep variant: 3x^2 - 2x^3
//        return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
//    }
//
//    // Fractional Brownian Motion (FBM) - layers multiple octaves of noise
//    float fbm(float2 st, int octaves, float persistence) {
//        float value = 0.0;
//        float amplitude = 0.5; // Start with half amplitude
//        float frequency = 1.0;
//
//        for (int i = 0; i < octaves; ++i) {
//            value += amplitude * valueNoise(st * frequency);
//            frequency *= 2.0; // Double frequency for next octave
//            amplitude *= persistence; // Reduce amplitude based on persistence
//        }
//        return value;
//    }
//
//    // Function to map noise value to color (example: Blue/Purple gradient)
//    float3 colorMap(float noiseValue) {
//        // Clamp noiseValue to approx [0, 1] range if FBM produces wider results
//        noiseValue = saturate(noiseValue);
//
//        float3 colorA = float3(0.1, 0.0, 0.4); // Dark Blue/Purple
//        float3 colorB = float3(0.8, 0.5, 1.0); // Light Lavender
//        return mix(colorA, colorB, noiseValue * noiseValue); // Square noise for more contrast
//    }
//
//    // --- Main Shader Function ---
//
//    [[ stitchable ]] // Make usable by SwiftUI
//    half4 interactiveNoiseEffect(
//        float2 pos,          // Pixel position in view physical pixel coordinates
//         SwiftUI::ShaderContext context, // Access userInfo & environment
//         // --- Custom inputs from userInfo ---
//         float time,           // Animation time
//         float2 resolution,     // View resolution (physical pixels)
//         float2 interaction_pos,// Normalized interaction coord [0,1] (bottom-left origin), or (-1,-1) if no interaction
//         float interaction_strength // 0.0 (no interaction) to 1.0 (interacting)
//    ) {
//        // --- Calculate Normalized UV Coordinates [0, 1] (bottom-left origin) ---
//        float2 uv = pos / resolution;
//
//        // --- Interaction Variables ---
//        float warp_strength = interaction_strength * 0.5; // How much interaction warps coordinates
//        float distance_to_interaction = 1.0; // Default to max distance
//
//        // If interaction_pos is valid (not (-1, -1))
//        if (interaction_pos.x >= 0.0) {
//            distance_to_interaction = distance(uv, interaction_pos);
//            // Reduce warp strength further away from the interaction point
//            warp_strength *= smoothstep(0.3, 0.0, distance_to_interaction); // Effect radius ~0.3
//        }
//
//        // --- Noise Calculation ---
//        float2 noise_uv = uv;
//
//        // 1. Time-based evolution: Offset uv by time
//        noise_uv += float2(time * 0.1, time * 0.05); // Slow movement
//
//        // 2. Interaction-based warping: Offset uv based on direction from interaction point
//        if (warp_strength > 0.0) {
//             float2 direction_from_touch = normalize(uv - interaction_pos);
//             noise_uv += direction_from_touch * warp_strength;
//        }
//
//        // 3. Calculate FBM noise (adjust scale, octaves, persistence)
//        float noise_scale = 4.0; // Zoom level for noise
//        int octaves = 4;
//        float persistence = 0.5;
//        float noiseValue = fbm(noise_uv * noise_scale, octaves, persistence);
//
//        // --- Coloring ---
//        float3 finalColor = colorMap(noiseValue);
//
//        // Optional: Add a highlight near interaction point
//        if (warp_strength > 0.0) {
//             float highlight = smoothstep(0.05, 0.0, distance_to_interaction) * 0.5; // Small bright circle
//             finalColor += float3(highlight);
//        }
//
//        // --- Output ---
//        return half4(half3(saturate(finalColor)), 1.0h); // Ensure color is in [0,1] and set alpha
//    }
//
//    """ // End of Metal shader string
//}
//
//// MARK: - Preview
//
//#Preview {
//    ContentView()
//}
