////
////  OctahedronShaders.metal
////  MyApp
////
////  Created by Cong Le on 5/3/25.
////
//
////
////  OctahedronShaders.metal
////  YourAppName // Replace with your actual App Name
////
////  Created by [Your Name] on [Date]
////
//
//#include <metal_stdlib>
//
//using namespace metal;
//
//// Structure defining vertex input data from the CPU (Swift)
//struct VertexIn {
//    float3 position [[attribute(0)]]; // Match layout in Swift
//    float4 color    [[attribute(1)]]; // Match layout in Swift
//};
//
//// Structure defining data passed from vertex shader to fragment shader
//struct VertexOut {
//    float4 position [[position]];    // Clip space position (required)
//    float4 color;                    // Interpolated color
//};
//
//// Structure for uniform data (like transformation matrices)
//struct Uniforms {
//    float4x4 modelViewProjectionMatrix;
//};
//
//// --- Vertex Shader ---
//// Processes each vertex
//vertex VertexOut octahedron_vertex_shader(
//    const device VertexIn *vertices [[buffer(0)]], // Array of vertices
//    const device Uniforms &uniforms [[buffer(1)]], // Uniform data
//    unsigned int vid [[vertex_id]]                 // Index of the current vertex
//) {
//    VertexIn vertex = vertices[vid]; // Get the current vertex data
//
//    VertexOut out;
//    // Transform vertex position from model space to clip space
//    out.position = uniforms.modelViewProjectionMatrix * float4(vertex.position, 1.0);
//    // Pass the vertex color to the fragment shader
//    out.color = vertex.color;
//
//    return out;
//}
//
//// --- Fragment Shader ---
//// Processes each pixel fragment within the rendered triangles/lines
//fragment half4 octahedron_fragment_shader(
//    VertexOut in [[stage_in]] // Data received from vertex shader (interpolated)
//) {
//    // Return the interpolated color as the final pixel color
//    // Using half4 for potentially better performance on some GPUs
//    return half4(in.color);
//}
