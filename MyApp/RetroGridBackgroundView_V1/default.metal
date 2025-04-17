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
    // FIX 1: Use MSL types
    float4x4 perspectiveMatrix;
    float2 viewportSize;
    float currentTime; // For animations
};

// --- Vertex Shader ---
vertex VertexOut vertexShader(VertexIn vertexIn [[stage_in]],
                               // FIX 2: Use pointer for buffer argument
                               constant Uniforms *uniforms [[buffer(1)]],
                               constant float3* starData [[buffer(0)]], // Assuming buffer 0 for stars if needed
                               uint vertexID [[vertex_id]])
{
    VertexOut out;

    // --- Logic depends on what's being drawn ---

    // If Drawing Sky Quad (based on vertexID for simple quad)
    if (vertexID < 4) { // Simplified check assuming sky is first draw
        float4 pos = vertexIn.position;
        pos.y = pos.y * 0.66 + 0.33;
        out.position = float4(pos.x, pos.y, 0.5, 1.0);
        out.worldPos = vertexIn.position;
        // Assume zw components of position hold tex coords for sky
        out.texCoord = vertexIn.position.zw;
        out.pointSize = 0.0; // Not a point
    }
    // If Drawing Grid (placeholder - needs real implementation)
    // else if (/* drawing grid condition */) {
    //     float4 gridPos3D = ... ; // Get 3D grid point from buffer
    //     // FIX 3: Access uniforms via pointer '->'
    //     out.position = uniforms->perspectiveMatrix * gridPos3D;
    //     out.worldPos = gridPos3D;
    //     out.texCoord = float2(0.0);
    //     out.pointSize = 0.0;
    // }
    // If Drawing Stars
    else {
        // Example: Assuming starData buffer has vertexID mapping correctly
        if (starData != nullptr) { // Safety check
             out.position = float4(starData[vertexID].x, starData[vertexID].y, 0.9, 1.0);
             out.pointSize = starData[vertexID].z;
             out.worldPos = float4(starData[vertexID], 0.0);
             out.texCoord = float2(0.0);
        } else {
            // Handle error or default behavior if starData isn't bound
            out.position = float4(0.0);
            out.pointSize = 0.0;
        }
    }

    // --- IMPORTANT: Access Uniforms using '->' ---
    // Example if you needed perspective matrix for sky/stars too (though unlikely here):
    // float4 transformedPos = uniforms->perspectiveMatrix * out.worldPos;

    return out;
}

// --- Fragment Shader ---
// (No changes needed based on the errors shown,
// but ensure buffer indices match CPU-side binding)
fragment float4 fragmentShader(VertexOut interpolated [[stage_in]],
                                constant float2 *viewportSize_ptr [[buffer(0)]], // Use ptr names to avoid confusion
                                constant float *currentTime_ptr [[buffer(1)]],
                                constant int *drawMode_ptr [[buffer(2)]] // 0=Sky, 1=Grid, 2=Stars
                                )
{
    // Dereference pointers once at the beginning
    float2 viewportSize = *viewportSize_ptr;
    float currentTime = *currentTime_ptr;
    int drawMode = *drawMode_ptr;

    float2 fragCoord = interpolated.position.xy; // Screen coordinates
    float2 uv = interpolated.texCoord; // Use this for sky

    // Sky Color Gradient
    float4 skyColor = float4(0.0); // Default black
    float horizonIntensity = 0.0;

    if (drawMode == 0) { // Drawing Sky
        float gradientFactor = smoothstep(0.0, 0.9, uv.y);
        float4 topColor = float4(0.0, 0.0, 0.0, 1.0);
        float4 midColor = float4(0.3, 0.0, 0.5, 1.0);
        float4 horizonColor = float4(0.8, 0.2, 1.0, 1.0);

        skyColor = mix(topColor, midColor, gradientFactor * gradientFactor);
        skyColor = mix(skyColor, horizonColor, smoothstep(0.7, 0.9, uv.y));

        // Scanlines (adjust speed/thickness)
        float scanlineFactor = fmod(fragCoord.y + currentTime * 30.0, 4.0) < 1.5 ? 0.85 : 1.0;
        skyColor.rgb *= scanlineFactor;

        horizonIntensity = smoothstep(1.0, 0.9, uv.y) * 0.8;
        skyColor.rgb += float3(0.8, 0.8, 1.0) * horizonIntensity;

        return saturate(skyColor); // Return sky color directly

    } else if (drawMode == 1) { // Drawing Grid
        // Return grid line color. Glow needs post-processing or thicker lines.
        return float4(0.0, 0.8, 1.0, 1.0); // Bright Cyan

    } else if (drawMode == 2) { // Drawing Stars
        // Basic white star. Could add twinkle using currentTime.
        float twinkle = 0.7 + 0.3 * sin(currentTime * 5.0 + interpolated.worldPos.x * 20.0 + interpolated.worldPos.y * 10.0); // Simple twinkle based on position and time
        return float4(1.0, 1.0, 1.0, 1.0) * twinkle;
    }

    // Fallback
    return float4(0.0, 0.0, 0.0, 1.0); // Black
}
