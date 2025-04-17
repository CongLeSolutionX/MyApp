////
////  default.metal
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//#include <metal_stdlib>
//#include <simd/simd.h> // Include for matrix/vector types
//
//using namespace metal;
//
//// Uniforms passed from CPU
//struct Uniforms {
//    float4x4 projectionMatrix;
//    float4x4 viewMatrix;
//    float2 viewportSize;
//    float currentTime;
//};
//
//// Data structure for vertex input FROM buffer 0
//// Using float4 to keep it simple for multiple object types
//// Sky: xy=position, zw=UV
//// Horizon: xyz=position, w=1
//// Grid: xyz=position, w=1
//// Stars: xy=position, z=pointSize, w=1
//struct VertexIn {
//    float4 data [[attribute(0)]];
//};
//
//// Data interpolated from vertex to fragment shader
//struct VertexOut {
//    float4 position [[position]]; // Clip space position (Mandatory)
//    float2 uv; // Screen space UV or Texture UV for sky/scanlines
//    float pointSize [[point_size]]; // For stars
//    float4 worldPos; // World/View position for effects if needed
//    float vertexY;   // Pass original Y for horizon glow calculation
//};
//
//// --- Vertex Shader ---
//vertex VertexOut vertexShader(VertexIn vertexIn [[stage_in]],
//                               constant Uniforms &uniforms [[buffer(1)]], // Uniforms at buffer index 1
//                               uint vertexID [[vertex_id]],
//                               // Explicitly get draw mode - passed separately for clarity
//                               constant int &drawMode [[buffer(2)]]) // Draw Mode at buffer index 2
//{
//    VertexOut out;
//    float4 pos = vertexIn.data; // Generic input data
//
//    // Screen UV for effects like scanlines
//    out.uv = float2(pos.x * 0.5 + 0.5, pos.y * 0.5 + 0.5);
//    out.worldPos = pos; // Store original for fragment use if needed
//    out.vertexY = pos.y; // Store original Y
//
//    if (drawMode == 0) { // Sky
//        // Simple pass-through for sky quad in clip space essentially
//        // Position is already -1 to 1, map Z to be in front
//        out.position = float4(pos.x, pos.y, 0.9, 1.0);
//        out.uv = pos.zw; // Use baked-in UVs for sky gradient
//        out.pointSize = 0.0;
//    }
//    else if (drawMode == 1) { // Horizon Line
//        // Horizon line drawn in view space, simple projection (no view matrix needed if simple)
//         out.position = uniforms.projectionMatrix * float4(pos.xyz, 1.0);
//         // Ensure horizon is slightly in front of sky/grid for depth testing if enabled
//         out.position.z = mix(out.position.z, 0.5, 0.1); // Adjust Z slightly forward
//         out.uv = float2(pos.x * 0.5 + 0.5, pos.y * 0.5 + 0.5); // Use screen UV
//         out.pointSize = 0.0;
//    }
//    else if (drawMode == 2) { // Grid
//        // Grid points are in world space (Y=0 plane)
//        // Apply View and Projection matrices
//        float4 worldPos = float4(pos.xyz, 1.0);
//        float4 viewPos = uniforms.viewMatrix * worldPos;
//        out.position = uniforms.projectionMatrix * viewPos;
//        out.uv = float2(0.0); // Grid doesn't use UVs typically
//        out.pointSize = 0.0;
//        out.worldPos = worldPos; // Pass world position if needed
//    }
//    else { // Stars (drawMode == 3)
//        // Stars are in clip space XY, Z is size
//        out.position = float4(pos.x, pos.y, 0.95, 1.0); // Place stars in front of sky
//        out.uv = float2(0.0);
//        out.pointSize = pos.z; // Use baked-in size
//    }
//
//    return out;
//}
//
//// --- Fragment Shader ---
//fragment float4 fragmentShader(VertexOut interpolated [[stage_in]],
//                               constant Uniforms &uniforms [[buffer(0)]], // Uniforms bound to fragment buffer 0
//                               constant int &drawMode [[buffer(1)]]       // Draw Mode bound to fragment buffer 1
//                              )
//{
//    float2 fragCoord = interpolated.position.xy;
//    float2 uv = interpolated.uv; //interpolated screen or texture coordinates
//
//    // --- Sky ---
//    if (drawMode == 0) {
//        // More accurate gradient colors based on image
//        float4 topColor     = float4(0.01, 0.0, 0.05, 1.0); // Deep dark purple/black
//        float4 midColor     = float4(0.4, 0.05, 0.5, 1.0); // Rich Purple
//        float4 horizonColor = float4(0.8, 0.15, 0.6, 1.0); // Pinkish-Purple
//
//        // Gradient based on texture V coord (0=top, 1=bottom)
//        float gradientFactor = smoothstep(0.0, 0.85, uv.y); // Make transition sharper near horizon
//        float4 skyColor = mix(topColor, midColor, gradientFactor * gradientFactor); // Bias towards darker top
//               skyColor = mix(skyColor, horizonColor, smoothstep(0.7, 0.95, uv.y));
//
//        // Subtle Scanlines based on screen position Y
//        // Use fragment position Y for consistent lines regardless of geometry
//        float scanline = fmod(fragCoord.y, 3.0); // Every 3 pixels
//        float scanIntensity = smoothstep(0.0, 0.5, scanline) * (1.0 - smoothstep(0.5, 1.0, scanline)); // Thin line
//        skyColor.rgb *= (1.0 - scanIntensity * 0.1); // Dim slightly for scanline
//
//        return skyColor;
//    }
//    // --- Horizon Glow ---
//    else if (drawMode == 1) {
//         // Simulate a wider, brighter, slightly blurred line centered on the vertex Y
//         float horizonY_ndc = interpolated.position.y / uniforms.viewportSize.y * 2.0 - 1.0; // Approx NDC Y
//         float glowCenterY = interpolated.vertexY; // The actual geometric line Y passed from vertex
//        
//        float distanceToCenter = abs(horizonY_ndc - glowCenterY) * uniforms.viewportSize.y; //Distance in pixels
//        float glowFactor = smoothstep(10.0, 0.0, distanceToCenter); // Adjust 10.0 for thickness/blurriness
//        
//        float4 glowColor = float4(0.5, 0.9, 1.0, 1.0); // Bright Cyan/White glow
//        
//        // Additive blending might be better here if enabled, otherwise just return color
//        return glowColor * glowFactor; // Fade out based on distance
//    }
//    // --- Grid ---
//    else if (drawMode == 2) {
//        float4 gridColor = float4(0.0, 0.9, 1.0, 1.0); // Bright Cyan
//        // Optional: Fade lines in the distance (using worldPos.z or clipPos.w)
//         float fade = smoothstep(40.0, 15.0, interpolated.worldPos.z); // Fade lines further than 15 units
//         return gridColor * fade;
//         //return gridColor;
//    }
//    // --- Stars ---
//    else if (drawMode == 3) {
//         // Could use pointCoord to draw shapes other than squares if desired
//         // float dist = distance(pointCoord, float2(0.5)); // For circular points
//         // if (dist > 0.5) { discard_fragment(); }
//
//        // Simple twinkle effect
//        float twinkle = 0.6 + 0.4 * abs(sin(uniforms.currentTime * 2.5 + interpolated.position.x * 10.0));
//        return float4(1.0, 1.0, 1.0, 1.0) * twinkle; // White twinkling star
//    }
//
//    // Fallback
//    return float4(0.0, 0.0, 0.0, 1.0); // Black
//}
