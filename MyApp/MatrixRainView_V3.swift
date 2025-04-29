//
//  MatrixRainView.swift
//  MyApp
//
//  Created by Cong Le on 4/29/25.
//

import SwiftUI
// MetalKit might be needed if you were doing more advanced Metal setup,
// but for ShaderLibrary.dynamic with simple shaders, it's often not required.
// import MetalKit

// MARK: - Matrix Rain View

struct MatrixRainView: View {
    // State for tracking animation time
    @State private var elapsedTime: Double = 0.0
    private let updateInterval: Double = 0.05 // Update rate (can adjust)
    
    // --- Configuration ---
    private let glyphSize: CGSize = CGSize(width: 16, height: 22) // Adjust size of characters/grid
    private let minSpeed: Float = 50.0      // Min falling speed (pixels/sec)
    private let maxSpeed: Float = 150.0     // Max falling speed (pixels/sec)
    private let tailLength: Float = 15.0    // Length of the fading tail (in characters)
    private let baseGreen: SIMD3<Float> = SIMD3<Float>(0.1, 0.9, 0.2) // Base green color #19E633
    private let highlightColor: SIMD3<Float> = SIMD3<Float>(0.8, 1.0, 0.85) // Near-white green for head
    
    // Metal shader code embedded as a string
    private var matrixRainShaderSource: String {
        """
        #include <metal_stdlib>
        #include <SwiftUI/SwiftUI_Metal.h>
        
        using namespace metal;
        
        // Simple pseudo-random function (Hash without Sine)
        // Adapted from various sources online - good enough for visual randomness
        float pseudoRandom(float2 co) {
            float a = 12.9898;
            float b = 78.233;
            float c = 43758.5453;
            float dt = dot(co, float2(a, b));
            float sn = fmod(dt, 3.14159); // Use fmod instead of sin
            return fract(sin(sn) * c); // Still use sin here for mixing
        }
        
        // Overload for seeding with a single float (e.g., column index)
        float pseudoRandom(float c) {
             return pseudoRandom(float2(c * 0.123, c * 0.456 + 0.789));
        }
        
        [[ stitchable ]]
        half4 matrixRainShader(
            float2 pos,         // Pixel position
            half4 color,        // Original color (unused)
            float4 bounds,      // View bounds (x, y, width, height)
            float currentTime,  // Animation time
            float2 glyphSize,   // Size of each character cell
            float minSpeed,
            float maxSpeed,
            float tailLength,
            float3 baseGreen,
            float3 highlightColor
        ) {
            // --- Grid Calculation ---
            // Calculate column and row index for this pixel
            float col = floor(pos.x / glyphSize.x);
            float row = floor(pos.y / glyphSize.y);
            float2 cellCoord = float2(col, row); // Grid coordinates
        
            // Calculate total number of rows/cols (approximate)
            float screenRows = floor(bounds.w / glyphSize.y);
        
            // --- Column Parameters ---
            // Get unique, stable random value for this column
            float colRandSeed = pseudoRandom(col);
            float colSpeed = mix(minSpeed, maxSpeed, pseudoRandom(col + 0.1)); // Vary speed
            float colTimeOffset = pseudoRandom(col + 0.2) * 100.0; // Start time offset
            float effectiveTime = currentTime + colTimeOffset;
        
            // --- Vertical Position & Wrapping ---
            // Calculate continuous virtual Y position of the stream head for this column
            float yPosVirtual = effectiveTime * colSpeed;
        
            // Calculate the row index where the head of the stream currently is
            float headRowContinuous = yPosVirtual / glyphSize.y;
            float headRow = floor(headRowContinuous);
        
            // --- Tail Check & Brightness ---
            // Calculate how many rows this pixel is behind the head (with wrapping)
            // Difference considering wrap-around
            float rowDiff = fmod(headRow - row + screenRows, screenRows);
        
            // Check if the pixel is within the tail length
            if (rowDiff >= tailLength || rowDiff < 0.0) { // rowDiff should always be positive with fmod above
                return half4(0.0, 0.0, 0.0, 1.0); // Outside tail -> Black
            }
        
            // Calculate brightness based on position in the tail
            // Max brightness (1.0) at the head, fading to 0 at the end of the tail
            float brightness = max(0.0h, 1.0h - half(rowDiff / tailLength));
        
            // Sharpen brightness curve slightly (optional)
            brightness = pow(brightness, 1.5h);
        
             // --- Character Simulation ---
            // Get a stable random value for the character at the head of this column's stream segment
            // We use floor(headRowContinuous) so the character stays the same while the head passes a cell
            float charSeedBase = floor(headRow - rowDiff); // Seed based on the row this character *originated* from
            float charRandVal = pseudoRandom(float2(col, charSeedBase)); // Stable ID for the character
        
            // Use another random check based on character ID and *pixel sub-position*
            // to make characters appear sparse/fragmented rather than solid blocks
            float pixelSubPosSeed = pseudoRandom(pos * 0.01 + charRandVal); // Add variation within cell
             if (pixelSubPosSeed < 0.2) { // Adjust threshold for density
                  return half4(0.0, 0.0, 0.0, 1.0); // Skip drawing some pixels within char cell
             }
        
            // --- Color Calculation ---
             half3 outputColor = half3(baseGreen) * brightness;
        
            // --- Head Highlight ---
            // If this row is the *exact* head of the stream, make it brighter/whiter
             if (rowDiff < 1.0) { // Use rowDiff < 1 check instead of direct equality for robustness
                 // Mix towards highlight color based on how close to the exact head
                 float headProximity = 1.0 - fmod(headRowContinuous, 1.0); // 1.0 when exactly at row start, 0.0 when just leaving
                 outputColor = mix(outputColor, half3(highlightColor), half(pow(headProximity, 4.0) * 0.8 + 0.2)); // Mix strongly towards highlight when head is near
        
                 // Boost brightness significantly for the absolute head
                 // outputColor = mix(outputColor, half3(highlightColor), headProximity * 0.8h + 0.2h); // Optional alternative mixing
                 outputColor = clamp(outputColor * 1.5h, 0.0h, 1.0h); // Boost and clamp
             }
        
            // Return final color (ensure alpha is 1)
            return half4(outputColor, 1.0h);
        }
        """
    }
    
    // Compiled shader instance
    private var matrixShader: Shader {
        // Using .dynamic allows embedding shader source directly. Requires iOS 17+ / macOS 14+
        // Ensure the function name here matches the one in the shader string exactly.
        ShaderLibrary.dynamic(name: "matrixRainShader", source: matrixRainShaderSource)!
    }
    
    var body: some View {
        // TimelineView drives the animation updates
        TimelineView(.animation(minimumInterval: updateInterval, paused: false)) { context in
            Rectangle() // The view area where the shader will draw
                .ignoresSafeArea() // Fill the entire screen
                .colorEffect( // Apply the shader effect
                    matrixShader, // The compiled shader object
                    // === Corrected Argument Passing ===
                    // Pass arguments directly after the shader.
                    // Use Shader.Argument wrappers.
                    // The ORDER must EXACTLY match the shader function's parameters
                    // (after the implicit 'pos', 'color', 'bounds').
                    Shader.Argument.float(Float(context.date.timeIntervalSinceReferenceDate)), // -> currentTime (param 4)
                    Shader.Argument.float2(glyphSize),       // -> glyphSize (param 5)
                    Shader.Argument.float(minSpeed),         // -> minSpeed (param 6)
                    Shader.Argument.float(maxSpeed),         // -> maxSpeed (param 7)
                    Shader.Argument.float(tailLength),       // -> tailLength (param 8)
                    Shader.Argument.float3(baseGreen),       // -> baseGreen (param 9)
                    Shader.Argument.float3(highlightColor)   // -> highlightColor (param 10)
                    // === End of Arguments ===
                )
            // Update state on each frame (alternative to context.date if needed)
            // .onChange(of: context.date) { _, newDate in
            //     elapsedTime = newDate.timeIntervalSinceReferenceDate
            // }
        }
        // Use a dark background behind the effect if needed (e.g., if shader sometimes returns alpha < 1)
        // .background(Color.black)
    }
}

// MARK: - Hosting Content View

struct ContentView: View {
    var body: some View {
        MatrixRainView()
        // Optional: Add a slight blur for a softer look
        //.blur(radius: 0.5)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .preferredColorScheme(.dark) // Ensure preview uses dark mode
}
