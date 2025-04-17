//
//  default.metal
//  MyApp
//
//  Created by Cong Le on 4/17/25.
//

#include <metal_stdlib>
using namespace metal;

// Data structure for vertex input
struct VertexIn {
    float4 position [[attribute(0)]]; // Position (or texture coord for sky)
    // Add more attributes if needed (e.g., color, normal)
     // If using separate buffers, define structs for each (SkyVertex, GridVertex, StarVertex)
};

struct VertexOut {
    float4 position [[position]]; // Clip space position (Mandatory)
    float2 texCoord;              // Texture coordinates for sky gradient/scanlines
    float4 worldPos;              // Pass world/view position for calculations
    float pointSize [[point_size]]; // For drawing stars as points
};

// Uniforms structure (example)
struct Uniforms {
    matrix_float4x4 perspectiveMatrix;
    vector_float2 viewportSize;
     float currentTime; // For animations
};

// --- Vertex Shader ---
vertex VertexOut vertexShader(VertexIn vertexIn [[stage_in]],
                               constant Uniforms &uniforms [[buffer(1)]], // Assuming uniforms at index 1
                                   // Use different buffer indices if sky/grid use different vertices/uniforms
                                   constant vector_float3* starData [[buffer(0)]], // Example if stars use buffer 0
                                   uint vertexID [[vertex_id]]) // Access vertex ID
{
    VertexOut out;

    // --- Logic depends on what's being drawn (determined by which buffer/draw call) ---
    // This example assumes a unified shader; separate shaders might be cleaner.

    // If Drawing Sky Quad (based on vertexID for simple quad)
    if (vertexID < 4) { // Simplified check assuming sky is first draw
        float4 pos = vertexIn.position; // These are already clip space coords for the simple quad
        pos.y = pos.y * 0.66 + 0.33; // Scale/Shift Y to fit top 2/3
        out.position = float4(pos.x, pos.y, 0.5, 1.0); // Z=0.5 for depth
        // Example: Assuming vertexIn.position contains xy=pos, zw=texcoord for sky
        out.worldPos = vertexIn.position; // Pass original data for potentially other uses
        out.texCoord = float2(vertexIn.position.z, vertexIn.position.w);
    }
    // If Drawing Grid (Needs proper 3D points and projection)
    // else if (drawing grid) {
    //      float4 gridPos3D = ... // Get 3D grid point (X, 0, Z) from buffer
    //      out.position = uniforms.perspectiveMatrix * gridPos3D;
    //      out.worldPos = gridPos3D;
    //        out.texCoord = float2(0.0, 0.0); // Not used for grid lines usually
    // }
    // If Drawing Stars
    else {
        // Assume starData buffer contains (x,y,size) where x,y are clip space
        out.position = float4(starData[vertexID].x, starData[vertexID].y, 0.9, 1.0); // Z=close to camera
        out.pointSize = starData[vertexID].z; // Pass size for point rendering
        out.worldPos = float4(starData[vertexID].x, starData[vertexID].y, starData[vertexID].z, 0.0); // Pass star data
        out.texCoord = float2(0.0);
    }

    return out;
}

// --- Fragment Shader ---
fragment float4 fragmentShader(VertexOut interpolated [[stage_in]],
                                constant vector_float2 &viewportSize [[buffer(0)]],
                                constant float &currentTime [[buffer(1)]],
                                constant int &drawMode [[buffer(2)]] // 0=Sky, 1=Grid, 2=Stars
                                )
{
    float2 fragCoord = interpolated.position.xy; // Screen coordinates
    float2 uv = interpolated.texCoord; // Use this for sky

    // Sky Color Gradient
    float4 skyColor = float4(0.0); // Default black
    float horizonIntensity = 0.0;

    if (drawMode == 0) { // Drawing Sky
        float gradientFactor = smoothstep(0.0, 0.9, uv.y);  // Gradient stops before the bottom edge
        float4 topColor = float4(0.0, 0.0, 0.0, 1.0); // Black
        float4 midColor = float4(0.3, 0.0, 0.5, 1.0); // Dark Purple
        float4 horizonColor = float4(0.8, 0.2, 1.0, 1.0); // Magenta/Pinkish

        skyColor = mix(topColor, midColor, gradientFactor * gradientFactor); // Non-linear mix
        skyColor = mix(skyColor, horizonColor, smoothstep(0.7, 0.9, uv.y));

        // Scanlines
        float scanlineFactor = fmod(fragCoord.y + currentTime * 10.0, 4.0) < 1.0 ? 0.85 : 1.0; // Every 4 pixels, dimmed
        skyColor.rgb *= scanlineFactor;

        // Horizon Glow (add near the bottom edge of the sky quad)
        horizonIntensity = smoothstep(1.0, 0.9, uv.y) * 0.8; // Glow intensity at the very bottom
        skyColor.rgb += float3(0.8, 0.8, 1.0) * horizonIntensity; // Add cyan/white glow

    } else if (drawMode == 1) { // Drawing Grid (Simplified: Assume single color)
        // The color of the grid lines themselves. Glow is harder.
        // For a simple glow: render lines thicker with less alpha first?
        return float4(0.0, 0.8, 1.0, 1.0); // Bright Cyan

    } else if (drawMode == 2) { // Drawing Stars
        // Basic white star. Could add twinkle using currentTime.
        float twinkle = 0.7 + 0.3 * sin(currentTime * 5.0 + interpolated.worldPos.x * 10.0); // Simple twinkle
        return float4(1.0, 1.0, 1.0, 1.0) * twinkle;
    }

    // Final Color Composition (if logic was integrated, otherwise return early)
    // This simplified example returns sky color mainly
    return saturate(skyColor);

}
