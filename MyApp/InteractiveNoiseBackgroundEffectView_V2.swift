// MIT License
//
// Copyright (c) 2025 Cong Le
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

//  InteractiveNoiseBackgroundEffectView.swift
//  MyApp
//
//  Created by Cong Le on 4/29/25.
//
import SwiftUI
// Ensure MetalKit is imported if you use MTKView later,
// but ShaderLibrary itself doesn't strictly require it here.
// import MetalKit

struct ContentView: View { // Renamed for clarity if this is your root view
    // MARK: - State Variables
    
    @State private var elapsedTime: Double = 0.0
    private let updateInterval: Double = 0.016 // Approx 60 FPS
    
    @State private var isInteracting: Bool = false
    @State private var interactionPoint: CGPoint? = nil
    
    // Get display scale from environment
    @Environment(\.displayScale) private var displayScale
    
    // Store the compiled shader ready for use
    private let interactiveNoiseShader: Shader
    
    // MARK: - Initializer
    init() {
        // Compile the Metal shader code from the inline string
        do {
            // 1. Create a ShaderLibrary from the inline source
            let library = ShaderLibrary.inline(Self.metalShaderSource)
            
            // 2. Get the specific shader function from the library
            //    Arguments are defined here if you want named access in the shader via context.
            //    However, if the shader defines parameters directly (like yours does),
            //    you often don't *need* to define args here, SwiftUI maps them positionally.
            self.interactiveNoiseShader = try library.shader(
                functionName: "interactiveNoiseEffect"
                // arguments: [] // <-- Usually empty if shader defines explicit params
            )
        } catch {
            // Consider more robust error handling in production
            fatalError("Failed to compile Metal shader: \(error)")
        }
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            TimelineView(.periodic(from: .now, by: updateInterval)) { context in
                ZStack {
                    Color.clear
                        .ignoresSafeArea()
                        .background {
                            Rectangle()
                                .ignoresSafeArea()
                            // 3. Apply .colorEffect, passing Shader.Argument values directly
                                .colorEffect(
                                    interactiveNoiseShader,
                                    // --- Pass arguments matching the shader function signature (after pos & context) ---
                                    // Argument 1: float time
                                    arguments: [
                                        .float(Float(elapsedTime)),
                                        
                                        // Argument 2: float2 resolution
                                        .float2(
                                            // Create SIMD2<Float> for resolution
                                            SIMD2<Float>(
                                                Float(geometry.size.width * displayScale), // Use displayScale
                                                Float(geometry.size.height * displayScale) // Use displayScale
                                            )
                                        ),
                                        
                                        // Argument 3: float2 interaction_pos
                                        .float2(
                                            // Value comes from helper function (already SIMD2<Float>)
                                            interactionShaderCoordinate(
                                                point: interactionPoint,
                                                viewSize: geometry.size
                                            )
                                        ),
                                        
                                        // Argument 4: float interaction_strength
                                        .float(isInteracting ? 1.0 : 0.0) // Pass interaction strength
                                    ]
                                )
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .onChanged { value in
                                    if !isInteracting { isInteracting = true }
                                    interactionPoint = value.location
                                }
                                .onEnded { _ in
                                    isInteracting = false
                                    interactionPoint = nil
                                }
                        )
                        .onChange(of: context.date) { _, _ in
                            elapsedTime += updateInterval
                        }
                    
                    // Your Actual UI Content Layer
                    VStack {
                        Text("Interactive Noise")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                        
                        Text(isInteracting ? "Touching" : "Touch and Drag")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .shadow(color: .black.opacity(0.5), radius: 5)
                    .allowsHitTesting(false)
                    
                } // End ZStack
            } // End TimelineView
        } // End GeometryReader
    } // End body
    
    // MARK: - Helper Functions
    
    private func interactionShaderCoordinate(point: CGPoint?, viewSize: CGSize) -> SIMD2<Float> {
        guard let point = point, viewSize.width > 0, viewSize.height > 0 else {
            return SIMD2<Float>(-1.0, -1.0)
        }
        let normalizedX = Float(point.x / viewSize.width)
        let normalizedY = 1.0 - Float(point.y / viewSize.height)
        return SIMD2<Float>(normalizedX, normalizedY)
    }
    
    // MARK: - Embedded Metal Shader Source Code
    static let metalShaderSource = """
    #include <metal_stdlib>
    #include <SwiftUI/SwiftUI_Metal.h> // For stitchable
    
    using namespace metal;
    
    // --- Utility Functions ---
    
    // Simple pseudo-random number generator (hash)
    float random(float2 st) {
        // distance() provides a simple way to mix x and y non-linearly
        // fract(sin(...)) is a common way to get pseudo-randomness
        return fract(sin(distance(st, float2(12.9898, 78.233))) * 43758.5453123);
    }
    
    // Basic Value Noise - interpolates random values at integer grid points
    float valueNoise(float2 st) {
        float2 i = floor(st); // Integer part
        float2 f = fract(st); // Fractional part
    
        // Get random values at the four corners of the grid cell
        float a = random(i);
        float b = random(i + float2(1.0, 0.0));
        float c = random(i + float2(0.0, 1.0));
        float d = random(i + float2(1.0, 1.0));
    
        // Smoothly interpolate between the corner values (using smoothstep)
        float2 u = f * f * (3.0 - 2.0 * f); // smoothstep variant: 3x^2 - 2x^3
        return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
    }
    
    // Fractional Brownian Motion (FBM) - layers multiple octaves of noise
    float fbm(float2 st, int octaves, float persistence) {
        float value = 0.0;
        float amplitude = 0.5; // Start with half amplitude
        float frequency = 1.0;
    
        for (int i = 0; i < octaves; ++i) {
            value += amplitude * valueNoise(st * frequency);
            frequency *= 2.0; // Double frequency for next octave
            amplitude *= persistence; // Reduce amplitude based on persistence
        }
        return value;
    }
    
    // Function to map noise value to color (example: Blue/Purple gradient)
    float3 colorMap(float noiseValue) {
        // Clamp noiseValue to approx [0, 1] range if FBM produces wider results
        noiseValue = saturate(noiseValue);
    
        float3 colorA = float3(0.1, 0.0, 0.4); // Dark Blue/Purple
        float3 colorB = float3(0.8, 0.5, 1.0); // Light Lavender
        return mix(colorA, colorB, noiseValue * noiseValue); // Square noise for more contrast
    }
    
    // --- Main Shader Function ---
    
    [[ stitchable ]] // Make usable by SwiftUI
    half4 interactiveNoiseEffect(
        float2 pos,          // Pixel position in view physical pixel coordinates
         SwiftUI::ShaderContext context, // Context (not used for arguments here)
         // --- Custom inputs mapped positionally from .colorEffect arguments ---
         float time,           // Mapped from 1st Shader.Argument
         float2 resolution,     // Mapped from 2nd Shader.Argument
         float2 interaction_pos,// Mapped from 3rd Shader.Argument
         float interaction_strength // Mapped from 4th Shader.Argument
    ) {
        // --- Calculate Normalized UV Coordinates [0, 1] (bottom-left origin) ---
        float2 uv = pos / resolution;
    
        // --- Interaction Variables ---
        float warp_strength = interaction_strength * 0.5; // How much interaction warps coordinates
        float distance_to_interaction = 1.0; // Default to max distance
    
        // If interaction_pos is valid (not (-1, -1))
        if (interaction_pos.x >= 0.0) {
            distance_to_interaction = distance(uv, interaction_pos);
            // Reduce warp strength further away from the interaction point
            warp_strength *= smoothstep(0.3, 0.0, distance_to_interaction); // Effect radius ~0.3
        }
    
        // --- Noise Calculation ---
        float2 noise_uv = uv;
    
        // 1. Time-based evolution: Offset uv by time
        noise_uv += float2(time * 0.1, time * 0.05); // Slow movement
    
        // 2. Interaction-based warping: Offset uv based on direction from interaction point
        if (warp_strength > 0.0) {
             // Avoid division by zero if touch is exactly at pixel
             float2 direction_from_touch = (distance_to_interaction > 0.0001) ? normalize(uv - interaction_pos) : float2(0.0);
             noise_uv += direction_from_touch * warp_strength;
        }
    
        // 3. Calculate FBM noise (adjust scale, octaves, persistence)
        float noise_scale = 4.0; // Zoom level for noise
        int octaves = 4;
        float persistence = 0.5;
        float noiseValue = fbm(noise_uv * noise_scale, octaves, persistence);
    
        // --- Coloring ---
        float3 finalColor = colorMap(noiseValue);
    
        // Optional: Add a highlight near interaction point
        if (warp_strength > 0.0) {
             float highlight = smoothstep(0.05, 0.0, distance_to_interaction) * 0.5; // Small bright circle
             finalColor += float3(highlight);
        }
    
        // --- Output ---
        return half4(half3(saturate(finalColor)), 1.0h); // Ensure color is in [0,1] and set alpha
    }
    
    """ // End of Metal shader string
}

#Preview {
    ContentView()
}
