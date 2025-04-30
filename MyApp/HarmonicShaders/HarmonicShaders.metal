//
//  HarmonicShaders.metal
//  MyApp
//
//  Created by Cong Le on 4/29/25.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h> // Required for SwiftUI integration

using namespace metal;

// Constant for Pi (adjust precision if needed)
// #define M_PI_F 3.141592653589793f

// MARK: - Helper Functions

// Calculates the distance to the harmonic wave
// uv: Normalized coordinates
// a: Modulated amplitude for this point
// offset: Modulated vertical offset for this point
// f: Frequency of the wave
// phi: Phase shift of the wave
float harmonicSDF(float2 uv, float a, float offset, float f, float phi) {
    // Equation: |(y - offset) + A * cos(x*frequency + phase)|
    return abs((uv.y - offset) + cos(uv.x * f + phi) * a);
}

// Simple glow effect based on distance
// x: Input distance (from SDF)
// str: Strength/falloff exponent
// dist: Intensity multiplier / base brightness
float glow(float x, float str, float dist){
    // Intensity diminishes rapidly as distance (x) increases
    return dist / pow(abs(x), str); // Use abs(x) to handle potential slight negatives robustly
}

// Returns a color from a predefined palette based on index 't'
float3 getColor(float t) {
    // Using the hardcoded palette from the article
    int index = int(round(t)); // Use rounding for safety if t isn't exactly integer

    if (index == 0) {
        return float3(0.4823529412, 0.831372549, 0.8549019608); // Teal-ish
    }
    if (index == 1) {
        return float3(0.4117647059, 0.4117647059, 0.8470588235); // Purple-ish
    }
    if (index == 2) {
        return float3(0.9411764706, 0.3137254902, 0.4117647059); // Red-pink
    }
    if (index == 3) {
        return float3(0.2745098039, 0.4901960784, 0.9411764706); // Blue
    }
    if (index == 4) {
        return float3(0.0784313725, 0.862745098, 0.862745098); // Cyan
    }
    if (index == 5) {
        return float3(0.7843137255, 0.6274509804, 0.5490196078); // Brown-ish / Dusty Rose
    }
    // Default fallback color (or handle potential out-of-bounds index)
    return float3(1.0); // White
}

/* Alternatively, use the per-channel calculation:
float3 getColor(float t) {
  // Normalize t to be within [0, 1] if it represents iteration index
  // Assuming t is already the index here, scaling it might be needed depending on wavesCount
  float adjusted_t = t / 6.0; // Example if wavesCount is 6

  float r = 0.5 + 0.5 * cos(2.0 * M_PI_F * adjusted_t);
  float g = 0.5 + 0.5 * cos(2.0 * M_PI_F * adjusted_t + 2.0 * M_PI_F / 3.0);
  float b = 0.5 + 0.5 * cos(2.0 * M_PI_F * adjusted_t + 4.0 * M_PI_F / 3.0);
  return clamp(float3(r, g, b), 0.0, 1.0);
}
*/


// MARK: - Main Shader Function

[[ stitchable ]] // Makes the function available to SwiftUI's ShaderLibrary
half4 harmonicColorEffect(
    float2 pos,         // Pixel position in view coordinates
    half4 color,        // Original pixel color (not used here)
    float4 bounds,      // Bounding rect (x, y, width, height) of the view
    float wavesCount,   // Number of harmonic waves to layer
    float time,         // Animation time elapsed
    float amplitude,    // Base amplitude (controlled by SwiftUI state)
    float mixCoeff      // 0.0 (released) to 1.0 (pressed) interpolation coefficient
) {
    // --- Preparatory Work ---
    // Normalize pixel coordinates to [-0.5, 0.5] range
    float2 uv = pos / float2(bounds.z, bounds.w);
    uv -= float2(0.5, 0.5);

    // --- Calculate Modulated Oscillator Parameters ---
    // Base amplitude modulation based on horizontal position (creates bulging effect)
    float a = cos(uv.x * 3.0) * amplitude * 0.2; // Using the passed amplitude
    // Base offset modulation (creates vertical wave motion)
    float offset = sin(uv.x * 12.0 + time) * a * 0.1;

    // --- Interpolate Parameters Based on Press State (mixCoeff) ---
    float frequency = mix(3.0, 12.0, mixCoeff);    // Wave frequency changes on press
    float glowWidth = mix(0.6, 0.9, mixCoeff);     // Glow falloff changes on press
    float glowIntensity = mix(0.02, 0.01, mixCoeff); // Glow brightness changes on press

    // --- Loop Through Waves ---
    float3 finalColor = float3(0.0); // Initialize final color accumulator

    for (float i = 0.0; i < wavesCount; i++) {
        // Calculate phase for this specific wave layer
        float phase = time + i * M_PI_F / wavesCount;

        // Calculate distance to this wave using SDF
        float sdfDist = harmonicSDF(uv, a, offset, frequency, phase);

        // Apply glow effect based on the distance
        float glowDist = glow(sdfDist, glowWidth, glowIntensity);

        // Determine wave color: white when released, palette color when pressed
        float3 waveColor = mix(float3(1.0), getColor(i), mixCoeff);

        // Accumulate color contributions from this wave
        finalColor += waveColor * glowDist;
    }

    // --- Return Final Color ---
    // Clamp final color to avoid exceeding 1.0 (optional but good practice)
    finalColor = clamp(finalColor, 0.0, 1.0);

    // Return as half4 (RGBA), converting float3 color and adding full alpha
    return half4(half3(finalColor), 1.0h);
}
