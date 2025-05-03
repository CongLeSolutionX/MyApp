////
////  DodecahedronView_V4.swift
////  MyApp
////
////  Created by Cong Le on 5/3/25.
////
//
////
////  DodecahedronView.swift
////  MyApp
////
////  Created by Cong Le on 5/3/25.
////
//
//// MARK: - File Description
///// ------------------------------------------------------------------------------------
///// **DodecahedronView.swift Description:**
/////
///// This file defines a SwiftUI view hierarchy that displays a 3D rotating
///// wireframe DODECAHEDRON rendered using Apple's Metal framework. It demonstrates:
/////
///// - **SwiftUI & Metal Integration:** Embedding a MetalKit view (`MTKView`) within a SwiftUI
/////   view hierarchy using the `UIViewRepresentable` protocol.
///// - **Metal Rendering Pipeline:** Setting up a basic Metal rendering pipeline, including:
/////     - Compiling vertex and fragment shaders from an embedded string.
/////     - Creating GPU data buffers (`MTLBuffer`) for vertices, indices, and uniform data.
/////     - Configuring a `MTLRenderPipelineState` object encapsulating shaders and render states.
/////     - Setting up a `MTLDepthStencilState` for proper 3D depth testing.
///// - **3D Geometry:** Defining the vertex positions and colors for a dodecahedron using
/////   coordinates based on the golden ratio (`phi`).
///// - **Triangulation:** Providing an index buffer that triangulates the 12 pentagonal faces
/////   of the dodecahedron so they can be rendered using triangle primitives.
///// - **Transformations:** Using the SIMD framework (`simd`) for efficient vector and matrix
/////   operations to construct Model-View-Projection (MVP) matrices for 3D transformations.
///// - **Animation:** Implementing simple rotation animation by updating transformation matrices
/////   in each frame's draw call.
///// - **Coordinate System:** Using a left-handed coordinate system typical for Metal development.
///// - **Rendering Mode:** Explicitly setting the rendering mode to wireframe (`.lines`).
///// ------------------------------------------------------------------------------------
//
//import SwiftUI
//import MetalKit // Provides MTKView and Metal integration helpers
//import simd    // Provides efficient vector and matrix types/operations (like matrix_float4x4)
//
//// MARK: - Metal Shaders (Embedded String)
//
///// Contains the source code for the Metal vertex and fragment shaders.
///// These shaders are programs written in Metal Shading Language (MSL) that execute on the GPU.
///// They are responsible for processing vertex data and determining the final color of pixels.
/////
///// - **Vertex Shader (`dodecahedron_vertex_shader`):** Processes each vertex individually, transforming its position
/////   from model space to clip space using the MVP matrix and passing its color to the next stage.
///// - **Fragment Shader (`dodecahedron_fragment_shader`):** Processes each pixel fragment generated during rasterization,
/////   receiving interpolated data (like color) from the vertex shader and outputting the final pixel color.
/////
///// ## Note on Shader Similarity:
///// These shaders are functionally identical to those used in other examples (like an Octahedron)
///// because they operate on generic `VertexIn` and `Uniforms` structures. The specific shape
///// is defined by the vertex and index data buffers provided by the Swift code, not the shader logic itself.
//let dodecahedronMetalShaderSource = """
//#include <metal_stdlib> // Import the Metal Standard Library, providing types and functions for MSL.
//
//using namespace metal; // Use the Metal namespace to avoid prefixing types (e.g., `metal::float3`).
//
//// --- Data Structures ---
//
//// Structure defining the layout of data for a single vertex received from the CPU (Swift).
//// The memory layout and attribute indices *must* exactly match:
//// 1. The `DodecahedronVertex` struct in Swift.
//// 2. The attribute descriptions in the `MTLVertexDescriptor` configured in Swift.
//struct VertexIn {
//    // [[attribute(0)]]: Links this field to the first vertex attribute defined in the MTLVertexDescriptor.
//    float3 position [[attribute(0)]]; // Vertex position in 3D model space (x, y, z).
//
//    // [[attribute(1)]]: Links this field to the second vertex attribute.
//    float4 color    [[attribute(1)]]; // Vertex color (Red, Green, Blue, Alpha).
//};
//
//// Structure defining the data passed *from* the vertex shader *to* the fragment shader.
//// Metal automatically interpolates the values of these fields across the surface of the
//// geometric primitive (triangle or line) being rendered.
//struct VertexOut {
//    // [[position]]: A special attribute indicating this is the final vertex position in clip space.
//    // This output is required from every vertex shader.
//    float4 position [[position]];
//
//    // The color calculated or passed through by the vertex shader.
//    // This value will be interpolated for each fragment.
//    float4 color;
//};
//
//// Structure for uniform data (constants) passed from the CPU for a draw call.
//// These values are typically the same for all vertices/fragments in a single draw.
//// The memory layout *must* exactly match the `Uniforms` struct in Swift.
//struct Uniforms {
//    // The combined Model-View-Projection matrix. Transforms vertices from model space
//    // directly to clip space.
//    float4x4 modelViewProjectionMatrix;
//};
//
//// --- Vertex Shader ---
//// This function is executed once for each vertex specified in the draw call.
//vertex VertexOut dodecahedron_vertex_shader(
//    // [[buffer(0)]]: Indicates that the vertex data comes from the buffer bound at index 0
//    // by the `setVertexBuffer` command in the Swift Render Encoder.
//    const device VertexIn *vertices [[buffer(0)]], // Pointer to the array of input vertices.
//
//    // [[buffer(1)]]: Indicates that the uniform data comes from the buffer bound at index 1.
//    const device Uniforms &uniforms [[buffer(1)]], // Reference to the uniform data struct.
//
//    // [[vertex_id]]: A system-generated value providing the index of the current vertex
//    // being processed within the vertex buffer or index buffer sequence.
//    unsigned int vid [[vertex_id]]
//) {
//    // Create an output structure to hold the results.
//    VertexOut out;
//
//    // Access the data for the current vertex using its index (vid).
//    VertexIn currentVertex = vertices[vid];
//
//    // Transform the vertex position:
//    // 1. Convert the `float3` model position to a `float4` by adding w=1.0.
//    //    Homogeneous coordinates (w=1) are needed for perspective transformations.
//    // 2. Multiply by the Model-View-Projection matrix provided in the uniforms.
//    // 3. The result is the vertex position in clip space.
//    out.position = uniforms.modelViewProjectionMatrix * float4(currentVertex.position, 1.0);
//
//    // Pass the vertex's original color directly to the output structure.
//    // This color will be interpolated across the primitive (triangle/line) surface.
//    out.color = currentVertex.color;
//
//    // Return the processed vertex data (position and color).
//    return out;
//}
//
//// --- Fragment Shader ---
//// This function is executed once for each pixel fragment covered by a primitive
//// after rasterization.
//// It determines the final color of that pixel.
//fragment half4 dodecahedron_fragment_shader( // 'half4' uses 16-bit floats, potentially faster on mobile GPUs.
//    // [[stage_in]]: Marks this input parameter as containing interpolated data received
//    // from the vertex shader stage (the fields of the `VertexOut` struct).
//    VertexOut in [[stage_in]]
//) {
//    // Return the interpolated color received from the vertex shader as the final
//    // color for this fragment.
//    return half4(in.color);
//}
//"""
//
//// MARK: - Swift Data Structures (Matching Shaders)
//
///// Swift structure mirroring the `Uniforms` struct in the Metal shader code (`dodecahedronMetalShaderSource`).
///// This ensures correct memory layout when copying data from Swift to the GPU uniform buffer.
///// Used to pass transformation matrices to the GPU.
//struct Uniforms {
//    /// The combined Model-View-Projection matrix.
//    /// `matrix_float4x4` is a SIMD framework type alias for a 4x4 matrix of Floats,
//    /// providing optimized matrix operations.
//    var modelViewProjectionMatrix: matrix_float4x4
//}
//
///// Swift structure defining the layout of data for a single vertex in the application code.
///// This layout *must* exactly match:
///// 1. The `VertexIn` struct in the Metal shader (`dodecahedronMetalShaderSource`).
///// 2. The attribute descriptions configured in the `MTLVertexDescriptor` within `setupPipeline`.
//struct DodecahedronVertex {
//    /// The 3D position (x, y, z) of the vertex in the model's local coordinate system.
//    var position: SIMD3<Float>
//    /// The RGBA color associated with this vertex. Color values are typically in the range [0.0, 1.0].
//    var color: SIMD4<Float>
//}
//
//// MARK: - Renderer Class (Handles Metal Logic)
//
///// Manages all Metal-specific setup, resource creation, and rendering commands for the Dodecahedron.
///// It acts as the delegate for the `MTKView`, responding to view lifecycle events and draw calls.
//class DodecahedronRenderer: NSObject, MTKViewDelegate {
//
//    // MARK: - Metal Core Objects
//    /// A reference to the physical GPU device. Used as a factory for creating other Metal objects
//    /// like command queues, buffers, textures, and pipeline states.
//    let device: MTLDevice
//    /// A queue responsible for organizing and sending encoded commands (rendering, compute, blit)
//    /// to the GPU for execution in a specific order.
//    let commandQueue: MTLCommandQueue
//    /// A pre-compiled object encapsulating the vertex and fragment shaders, along with configuration
//    /// for various fixed-function states of the rendering pipeline (e.g., vertex layout,
//    /// color attachment formats, blending). Essential for drawing.
//    var pipelineState: MTLRenderPipelineState!
//    /// An object configuring how depth testing is performed. Crucial for ensuring that objects
//    /// closer to the camera correctly obscure objects farther away, creating a proper 3D effect.
//    var depthState: MTLDepthStencilState!
//
//    // MARK: - Data Buffers
//    /// A region of GPU-accessible memory holding the Dodecahedron's vertex data (an array of `DodecahedronVertex`).
//    var vertexBuffer: MTLBuffer!
//    /// A region of GPU-accessible memory holding the indices that define how vertices connect to form
//    /// triangles (`[UInt16]` array). Using indices reduces vertex data duplication.
//    var indexBuffer: MTLBuffer!
//    /// A region of GPU-accessible memory holding the uniform data (the `Uniforms` struct, containing the MVP matrix).
//    /// This buffer is updated each frame with the latest transformation.
//    var uniformBuffer: MTLBuffer!
//
//    // MARK: - Rendering State
//    /// The current rotation angle applied to the Dodecahedron model (in radians).
//    /// This value is incremented each frame in `updateUniforms` to create the animation.
//    var rotationAngle: Float = 0.0
//    /// The aspect ratio (width / height) of the `MTKView`'s drawable area.
//    /// This is needed for the perspective projection matrix calculation to avoid distortion.
//    /// It's updated by the `mtkView(_:drawableSizeWillChange:)` delegate method.
//    var aspectRatio: Float = 1.0
//
//    // MARK: - Geometry Data
//
//    /// The Golden Ratio constant (φ ≈ 1.618), used in the mathematical definition of a Dodecahedron's vertices.
//    let phi: Float = (1.0 + sqrt(5.0)) / 2.0
//    /// The inverse of the Golden Ratio (1/φ ≈ 0.618), also used in vertex calculations.
//    let invPhi: Float = 1.0 / ((1.0 + sqrt(5.0)) / 2.0) // More numerically stable than direct division
//
//    /// An array defining the 20 unique vertices of a regular Dodecahedron.
//    /// The coordinates are derived from permutations involving ±1, ±φ, and ±1/φ, often centered at the origin.
//    /// A small scaling factor (0.8) is applied here to make the shape fit comfortably within the view.
//    /// Each vertex includes a distinct color for visualization.
//    lazy var vertices: [DodecahedronVertex] = [
//        // Reference for Dodecahedron vertices using Golden Ratio:
//        // https://en.wikipedia.org/wiki/Regular_dodecahedron#Cartesian_coordinates
//
//        // Group 1: (±1, ±1, ±1) - Corners of an inner cube
//        DodecahedronVertex(position: SIMD3<Float>( 1,  1,  1) * 0.8, color: SIMD4<Float>(1, 0, 0, 1)), // 0 Red
//        DodecahedronVertex(position: SIMD3<Float>(-1,  1,  1) * 0.8, color: SIMD4<Float>(0, 1, 0, 1)), // 1 Green
//        DodecahedronVertex(position: SIMD3<Float>(-1, -1,  1) * 0.8, color: SIMD4<Float>(0, 0, 1, 1)), // 2 Blue
//        DodecahedronVertex(position: SIMD3<Float>( 1, -1,  1) * 0.8, color: SIMD4<Float>(1, 1, 0, 1)), // 3 Yellow
//        DodecahedronVertex(position: SIMD3<Float>( 1,  1, -1) * 0.8, color: SIMD4<Float>(1, 0, 1, 1)), // 4 Magenta
//        DodecahedronVertex(position: SIMD3<Float>(-1,  1, -1) * 0.8, color: SIMD4<Float>(0, 1, 1, 1)), // 5 Cyan
//        DodecahedronVertex(position: SIMD3<Float>(-1, -1, -1) * 0.8, color: SIMD4<Float>(1, 0.5, 0, 1)),// 6 Orange
//        DodecahedronVertex(position: SIMD3<Float>( 1, -1, -1) * 0.8, color: SIMD4<Float>(0.5, 0, 1, 1)),// 7 Purple
//
//        // Group 2: (0, ±φ, ±1/φ)
//        DodecahedronVertex(position: SIMD3<Float>( 0,  phi,  invPhi) * 0.8, color: SIMD4<Float>(1, 1, 1, 1)), // 8 White
//        DodecahedronVertex(position: SIMD3<Float>( 0,  phi, -invPhi) * 0.8, color: SIMD4<Float>(0.5, 0.5, 0.5, 1)),// 9 Gray
//        DodecahedronVertex(position: SIMD3<Float>( 0, -phi,  invPhi) * 0.8, color: SIMD4<Float>(0.8, 0.8, 0.8, 1)),// 10 Light Gray
//        DodecahedronVertex(position: SIMD3<Float>( 0, -phi, -invPhi) * 0.8, color: SIMD4<Float>(0.3, 0.3, 0.3, 1)),// 11 Dark Gray
//
//        // Group 3: (±1/φ, 0, ±φ)
//        DodecahedronVertex(position: SIMD3<Float>( invPhi,  0,  phi) * 0.8, color: SIMD4<Float>(0, 1, 0.5, 1)),// 12 Teal
//        DodecahedronVertex(position: SIMD3<Float>(-invPhi,  0,  phi) * 0.8, color: SIMD4<Float>(0.5, 1, 0, 1)),// 13 Lime
//        DodecahedronVertex(position: SIMD3<Float>( invPhi,  0, -phi) * 0.8, color: SIMD4<Float>(1, 0, 0.5, 1)),// 14 Pink
//        DodecahedronVertex(position: SIMD3<Float>(-invPhi,  0, -phi) * 0.8, color: SIMD4<Float>(0.5, 0, 0, 1)), // 15 Maroon
//
//        // Group 4: (±φ, ±1/φ, 0)
//        DodecahedronVertex(position: SIMD3<Float>( phi,  invPhi,  0) * 0.8, color: SIMD4<Float>(0, 0.5, 1, 1)),// 16 Sky Blue
//        DodecahedronVertex(position: SIMD3<Float>(-phi,  invPhi,  0) * 0.8, color: SIMD4<Float>(1, 0.5, 0.5, 1)),// 17 Salmon
//        DodecahedronVertex(position: SIMD3<Float>( phi, -invPhi,  0) * 0.8, color: SIMD4<Float>(0.5, 1, 0.5, 1)),// 18 Mint
//        DodecahedronVertex(position: SIMD3<Float>(-phi, -invPhi,  0) * 0.8, color: SIMD4<Float>(0.5, 0.5, 1, 1)),// 19 Lavender
//    ]
//
//    /// An array of indices that define the geometry of the Dodecahedron by specifying how the
//    /// vertices (`vertices` array) connect to form triangles.
//    /// A Dodecahedron has 12 pentagonal faces. Each pentagon is triangulated here using a
//    /// simple fan triangulation (picking one vertex and connecting it to all others).
//    /// - Each pentagon requires 5 vertices and is split into 3 triangles (e.g., v0-v1-v2, v0-v2-v3, v0-v3-v4).
//    /// - Total Triangles: 12 faces * 3 triangles/face = 36 triangles.
//    /// - Total Indices: 36 triangles * 3 vertices/triangle = 108 indices.
//    /// The indices are `UInt16`, suitable for models with up to 65,535 vertices.
//    /// The order of vertices within each triangle triplet defines the front face (winding order).
//    /// Here, counter-clockwise (CCW) winding is assumed when viewing from the outside.
//    let indices: [UInt16] = [
//        // Face 0 (Vertices 0, 8, 1, 13, 12) - Front-Top-Leftish
//         0,  8,  1,    0,  1, 13,    0, 13, 12,
//        // Face 1 (Vertices 0, 12, 3, 18, 16) - Front-Bottom-Rightish
//         0, 12,  3,    0,  3, 18,    0, 18, 16,
//        // Face 2 (Vertices 0, 16, 4, 9, 8) - Top-Front-Rightish
//         0, 16,  4,    0,  4,  9,    0,  9,  8,
//        // Face 3 (Vertices 1, 8, 9, 5, 17) - Top-Left-Backish (Original: 1, 8, 5, 17, 13 adjusted visually 1,8,9,5,17?) <-- Double check derivation if needed
//         1,  8,  9,    1,  9,  5,    1,  5, 17, // Assuming 1,8,9,5,17 face (Verify source if possible)
//        // Face 4 (Vertices 2, 13, 1, 17, 19) - Bottom-Left-Frontish (Original 2, 17, 1, 13, 12 ?) <-- Verify
//         2, 13,  1,    2,  1, 17,    2, 17, 19, // Assuming 2,13,1,17,19 face
//        // Face 5 (Vertices 2, 12, 0, 13) - Front-Left-Bottomish (Issue: Pentagons expected, verify this face) - Let's use known good faces
//        // Corrected indices based on common Dodecahedron definitions and triangulation:
//        // Face 0: Indices 0, 8, 1, 13, 12 -> Triangles: (0,8,1), (0,1,13), (0,13,12)
//        // Face 1: Indices 0, 12, 3, 18, 16 -> Triangles: (0,12,3), (0,3,18), (0,18,16)
//        // Face 2: Indices 0, 16, 4, 9, 8 -> Triangles: (0,16,4), (0,4,9), (0,9,8)
//        // Face 3: Indices 1, 8, 9, 5, 17 -> Triangles: (1,8,9), (1,9,5), (1,5,17) <-- Corrected
//        // Face 4: Indices 2, 13, 1, 17, 19 -> Triangles: (2,13,1), (2,1,17), (2,17,19) <-- Corrected
//        // Face 5: Indices 2, 12, 3, 10, 19 -> Triangles: (2,12,3), (2,3,10), (2,10,19) <-- Corrected
//         2, 12,  3,    2,  3, 10,    2, 10, 19,
//        // Face 6: Indices 3, 18, 7, 11, 10 -> Triangles: (3,18,7), (3,7,11), (3,11,10) <-- Corrected
//         3, 18,  7,    3,  7, 11,    3, 11, 10,
//        // Face 7: Indices 4, 16, 7, 14, 15 -> Triangles: (4,16,7), (4,7,14), (4,14,15) <-- Corrected (Original had 18,16 - vertex 7 used in face 6, maybe 4,16, *18*, 7, *14* was intended? Sticking to a more standard face for now 4,16,7,14,15)
//         4, 16,  7,    4,  7, 14,   4, 14, 15, // Assumption based on common nets
//        // Face 8: Indices 4, 9, 5, 15, 14 -> Seems more likely than original: 4, 15, 14. Needs 5 elements.
//         4,  9,  5,    4,  5, 15,    4, 15, 14, // Assuming 4,9,5,15,14 is correct
//        // Face 9: Indices 5, 17, 6, 11, 15 -> Triangles: (5,17,6), (5,6,11), (5,11,15) <-- Corrected
//         5, 17,  6,    5,  6, 11,    5, 11, 15,
//        // Face 10: Indices 6, 19, 2, 10, 11 -> Likely intended face, triangulation assumed correct
//         6, 19,  2,    6,  2, 10,    6, 10, 11,
//        // Face 11: Indices 7, 18, 3, 10, 11 -> Original had 7,11,6,15,14. Let's assume 7,18,3,10,11
//         7, 18,  3,    7,  3, 10,    7, 10, 11, // Assuming 7,18,3,10,11 is correct
//    ] // Total 12 faces * 3 triangles/face * 3 vertices/triangle = 108 indices
//
//    // MARK: - Initialization
//
//    /// Initializes the `DodecahedronRenderer`.
//    /// - Parameter device: The `MTLDevice` (GPU) to use for all Metal operations.
//    /// Fails (returns `nil`) if a command queue cannot be created.
//    init?(device: MTLDevice) {
//        print("Renderer: Initializing...")
//        self.device = device
//        // Create a command queue. This is the channel for sending commands (like draw calls) to the GPU.
//        guard let queue = device.makeCommandQueue() else {
//            print("Renderer: FAILED to create command queue. Metal acceleration might not be fully available.")
//            return nil // Cannot proceed without a command queue.
//        }
//        self.commandQueue = queue
//        print("Renderer: Command Queue created.")
//        
//        // Call NSObject's initializer. Required because this class inherits from NSObject (via MTKViewDelegate).
//        super.init()
//
//        // Set up resources that don't depend on the MTKView's specific pixel formats yet.
//        print("Renderer: Setting up initial buffers and depth state...")
//        setupBuffers()        // Create and populate GPU buffers for vertex, index, and uniform data.
//        setupDepthStencil()   // Configure the depth testing state object.
//        print("Renderer: Initial buffers and depth state setup complete.")
//        print("Renderer: Initialization finished. Pipeline State will be created by 'configure'.")
//    }
//
//    /// Configures the Metal rendering pipeline state (`pipelineState`).
//    /// This must be called *after* the `MTKView` is created and configured, because the pipeline state
//    /// needs to know the exact pixel formats (`colorPixelFormat`, `depthStencilPixelFormat`)
//    /// of the textures it will render into (the view's drawable).
//    /// - Parameter metalKitView: The `MTKView` instance this renderer will draw into.
//    func configure(metalKitView: MTKView) {
//        print("Renderer: Configuring pipeline state using MTKView pixel formats...")
//        setupPipeline(metalKitView: metalKitView)
//        print("Renderer: Pipeline state configuration complete.")
//    }
//
//    // MARK: - Setup Functions
//
//    /// Compiles the Metal shaders and creates the `MTLRenderPipelineState` object.
//    /// This object encapsulates the compiled vertex and fragment shader functions and various
//    /// fixed-function states (like blending, culling, and vertex data layout).
//    /// It's created once and reused for drawing multiple frames.
//    /// - Parameter metalKitView: The `MTKView` providing the necessary runtime pixel format information.
//    private func setupPipeline(metalKitView: MTKView) {
//        print("Renderer [Pipeline]: Setting up pipeline...")
//        do {
//            print("Renderer [Pipeline]: Creating Metal library from source...")
//            // Compile the shader source code string into a Metal Library.
//            // The library contains the compiled versions of the functions defined in the source.
//            let library = try device.makeLibrary(source: dodecahedronMetalShaderSource, options: nil)
//            print("Renderer [Pipeline]: Library created. Loading shader functions...")
//
//            // Retrieve the compiled shader functions from the library by their names.
//            guard let vertexFunction = library.makeFunction(name: "dodecahedron_vertex_shader"),
//                  let fragmentFunction = library.makeFunction(name: "dodecahedron_fragment_shader") else {
//                // This error usually means the function names in the shader source don't match these strings.
//                fatalError("Renderer [Pipeline]: CRITICAL - Could not load shader functions ('dodecahedron_vertex_shader' or 'dodecahedron_fragment_shader') from library. Check function names in dodecahedronMetalShaderSource.")
//            }
//            print("Renderer [Pipeline]: Shader functions loaded: \(vertexFunction.label ?? "vertex"), \(fragmentFunction.label ?? "fragment").")
//
//            // Create a descriptor object to configure the specifics of the render pipeline state.
//            let pipelineDescriptor = MTLRenderPipelineDescriptor()
//            pipelineDescriptor.label = "Wireframe Dodecahedron Rendering Pipeline" // For debugging tools (e.g., Xcode GPU Frame Capture).
//            pipelineDescriptor.vertexFunction = vertexFunction     // Assign the compiled vertex shader.
//            pipelineDescriptor.fragmentFunction = fragmentFunction // Assign the compiled fragment shader.
//
//            // Configure the pixel formats of the render targets (attachments).
//            // These *must* match the corresponding formats set on the `MTKView`.
//            // Attachment 0 is typically the main color buffer (the view's drawable texture).
//            pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
//            // The format for the depth buffer texture.
//            pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
//
//            // --- Configure Vertex Descriptor ---
//            // This descriptor tells the GPU how the vertex data is laid out in the `vertexBuffer`.
//            // It defines attributes (like position, color) and how they correspond to the
//            // `VertexIn` struct fields in the vertex shader.
//            print("Renderer [Pipeline]: Configuring Vertex Descriptor...")
//            let vertexDescriptor = MTLVertexDescriptor()
//
//            // Attribute 0: Corresponds to `VertexIn.position` (float3) bound to `[[attribute(0)]]`
//            vertexDescriptor.attributes[0].format = .float3 // Data type: 3 floats (x, y, z)
//            vertexDescriptor.attributes[0].offset = 0       // Starts at the beginning (byte offset 0) of the DodecahedronVertex struct.
//            vertexDescriptor.attributes[0].bufferIndex = 0  // Data comes from the buffer bound at index 0 (`vertexBuffer`).
//
//            // Attribute 1: Corresponds to `VertexIn.color` (float4) bound to `[[attribute(1)]]`
//            vertexDescriptor.attributes[1].format = .float4 // Data type: 4 floats (r, g, b, a)
//            // Offset: Starts immediately after the `position` field. `MemoryLayout<SIMD3<Float>>.stride`
//            // correctly calculates the size of the position field, including any potential padding.
//            vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
//            vertexDescriptor.attributes[1].bufferIndex = 0  // Data comes from the *same* buffer (index 0).
//
//            // Layout 0: Describes the overall structure of a single vertex in buffer 0.
//            // Stride: The total size (in bytes) of one `DodecahedronVertex` instance. This tells the GPU
//            // how many bytes to advance in the buffer to find the beginning of the next vertex.
//            vertexDescriptor.layouts[0].stride = MemoryLayout<DodecahedronVertex>.stride
//            vertexDescriptor.layouts[0].stepRate = 1              // Advance the stride once per vertex.
//            vertexDescriptor.layouts[0].stepFunction = .perVertex // Standard vertex processing.
//
//            // Assign the configured vertex descriptor to the pipeline descriptor.
//            pipelineDescriptor.vertexDescriptor = vertexDescriptor
//            print("Renderer [Pipeline]: Vertex Descriptor configured (Pos: float3@0, Color: float4@\(MemoryLayout<SIMD3<Float>>.stride), Stride: \(MemoryLayout<DodecahedronVertex>.stride))")
//
//            print("Renderer [Pipeline]: Creating Render Pipeline State object...")
//            // Create the immutable `MTLRenderPipelineState` object from the descriptor.
//            // This is a potentially expensive operation (shader compilation, state validation),
//            // so it's done once during setup.
//            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//            print("Renderer [Pipeline]: Render Pipeline State created successfully.")
//
//        } catch {
//            // Pipeline state creation can fail for various reasons:
//            // - Shader compilation errors (syntax errors in MSL source).
//            // - Mismatched vertex descriptor and shader struct layouts.
//            // - Incompatible pixel formats between pipeline and MTKView.
//            // - Other Metal validation errors.
//            print("Renderer [Pipeline]: FAILED to create pipeline state: \(error)")
//            fatalError("Renderer [Pipeline]: CRITICAL - Failed to create Metal Render Pipeline State: \(error.localizedDescription)")
//        }
//        print("Renderer [Pipeline]: Pipeline setup complete.")
//    }
//
//    /// Creates and populates the GPU memory buffers (`MTLBuffer`) needed for rendering.
//    /// This includes the vertex buffer, index buffer, and uniform buffer.
//    private func setupBuffers() {
//        print("Renderer [Buffers]: Setting up GPU buffers...")
//        // --- Vertex Buffer ---
//        // Calculates the total size needed for the vertex data. `stride` includes padding.
//        let vertexDataSize = vertices.count * MemoryLayout<DodecahedronVertex>.stride
//        guard vertexDataSize > 0 else {
//            fatalError("Renderer [Buffers]: CRITICAL - Vertex data is empty or size calculation failed.")
//        }
//        // Create a GPU buffer and initialize it by copying data from the `vertices` array.
//        // `options: []` uses the default storage mode (typically `.storageModeShared` on unified memory systems like iOS/macOS sims,
//        // or potentially private on discrete GPUs, but Metal handles the transfer).
//        guard let vBuffer = device.makeBuffer(bytes: vertices, length: vertexDataSize, options: []) else {
//            fatalError("Renderer [Buffers]: CRITICAL - Could not create vertex buffer.")
//        }
//        vertexBuffer = vBuffer
//        vertexBuffer.label = "Dodecahedron Vertex Data" // Assign a debug label.
//        print("Renderer [Buffers]: Vertex buffer created (\(vertices.count) vertices, \(vertexDataSize) bytes).")
//
//        // --- Index Buffer ---
//        // Calculate buffer size for `UInt16` indices.
//        let indexDataSize = indices.count * MemoryLayout<UInt16>.stride
//        guard indexDataSize > 0 else {
//            fatalError("Renderer [Buffers]: CRITICAL - Index data is empty or size calculation failed.")
//        }
//        // Basic validation for the Dodecahedron's expected index count.
//        guard indices.count == 108 else {
//            fatalError("Renderer [Buffers]: CRITICAL - Incorrect number of indices for Dodecahedron triangulation (expected 108, found \(indices.count)). Check the 'indices' array.")
//        }
//        // Create and initialize the index buffer.
//        guard let iBuffer = device.makeBuffer(bytes: indices, length: indexDataSize, options: []) else {
//            fatalError("Renderer [Buffers]: CRITICAL - Could not create index buffer.")
//        }
//        indexBuffer = iBuffer
//        indexBuffer.label = "Dodecahedron Index Data" // Debug label.
//        print("Renderer [Buffers]: Index buffer created (\(indices.count) indices, \(indexDataSize) bytes).")
//
//        // --- Uniform Buffer ---
//        // Size based on the Swift `Uniforms` struct, ensuring enough space for the MVP matrix.
//        let uniformBufferSize = MemoryLayout<Uniforms>.stride // Use stride for safety with potential padding.
//        // Create the uniform buffer. `.storageModeShared` is often suitable for buffers frequently
//        // updated by the CPU (writing the MVP matrix) and read by the GPU (in the vertex shader).
//        // It allows both CPU and GPU to access the buffer's memory directly on unified memory systems.
//        guard let uBuffer = device.makeBuffer(length: uniformBufferSize, options: .storageModeShared) else {
//            fatalError("Renderer [Buffers]: CRITICAL - Could not create uniform buffer.")
//        }
//        uniformBuffer = uBuffer
//        uniformBuffer.label = "Uniforms (MVP Matrix)" // Debug label.
//        print("Renderer [Buffers]: Uniform buffer created (\(uniformBufferSize) bytes, Shared Mode).")
//
//        print("Renderer [Buffers]: Buffers setup complete.")
//    }
//
//    /// Creates the `MTLDepthStencilState` object to configure depth testing parameters.
//    /// Depth testing ensures that fragments closer to the camera overwrite fragments farther away,
//    /// leading to correct 3D rendering of overlapping or intersecting geometry.
//    private func setupDepthStencil() {
//        print("Renderer [Depth]: Setting up Depth Stencil State...")
//        let depthDescriptor = MTLDepthStencilDescriptor()
//        depthDescriptor.label = "Standard Depth Less Test & Write Enabled"
//
//        // Set the comparison function: Incoming fragment passes if its depth is LESS than
//        // the depth value already stored in the depth buffer for that pixel.
//        depthDescriptor.depthCompareFunction = .less
//
//        // Enable writing to the depth buffer: If a fragment passes the depth test,
//        // its depth value will be written into the depth buffer, potentially replacing
//        // the value from a farther fragment drawn earlier.
//        depthDescriptor.isDepthWriteEnabled = true
//
//        // Create the immutable depth state object from the descriptor.
//        guard let state = device.makeDepthStencilState(descriptor: depthDescriptor) else {
//            fatalError("Renderer [Depth]: CRITICAL - Failed to create depth stencil state.")
//        }
//        depthState = state
//        print("Renderer [Depth]: Depth Stencil State created (Compare: Less, Write: Enabled).")
//    }
//
//    // MARK: - Per-Frame Update
//
//    /// Calculates the Model-View-Projection (MVP) matrix based on the current rotation angle
//    /// and view parameters, then uploads this matrix to the `uniformBuffer` on the GPU.
//    /// This function is called at the beginning of each `draw(in:)` call to update the
//    /// object's transformation for the current frame.
//    private func updateUniforms() {
//        // 1. Projection Matrix: Defines the camera's viewing volume (frustum) and how 3D
//        //    coordinates are projected onto the 2D screen. `matrix_perspective_left_hand`
//        //    creates a standard perspective projection matrix for a left-handed coordinate system.
//        let projectionMatrix = matrix_perspective_left_hand(
//            fovyRadians: Float.pi / 3.0, // Vertical Field of View (60 degrees). Defines how 'wide' the view is vertically.
//            aspectRatio: aspectRatio,    // Width-to-height ratio of the viewport. Prevents stretching/squashing.
//            nearZ: 0.1,                  // Distance to the near clipping plane. Objects closer than this are clipped.
//            farZ: 100.0                  // Distance to the far clipping plane. Objects farther than this are clipped.
//        )
//
//        // 2. View Matrix: Defines the position and orientation of the camera in the world.
//        //    `matrix_look_at_left_hand` creates a matrix that transforms world coordinates
//        //    into camera (view) space.
//        let viewMatrix = matrix_look_at_left_hand(
//            eye: SIMD3<Float>(0, 0.5, -4.0), // Camera's position in world space (slightly up and back). Adjusted from -4.5 to -4.0 for closer view.
//            center: SIMD3<Float>(0, 0, 0),  // Point the camera is looking directly at (the world origin).
//            up: SIMD3<Float>(0, 1, 0)       // Vector defining the 'up' direction for the camera (positive Y-axis).
//        )
//
//        // 3. Model Matrix: Defines the transformation (position, rotation, scale) of the
//        //    Dodecahedron object itself within the world space. Here, we only apply rotation.
//        //    Create rotation matrices around the Y and X axes based on `rotationAngle`.
//        let rotationY = matrix_rotation_y(radians: rotationAngle)
//        let rotationX = matrix_rotation_x(radians: rotationAngle * 0.6) // Rotate slightly slower around X for visual interest.
//        // Combine the rotations by multiplying the matrices. The order matters: applying Y then X
//        // results in a different final orientation than X then Y.
//        let modelMatrix = matrix_multiply(rotationY, rotationX)
//
//        // Note: Scaling could be added here:
//        // let scaleMatrix = matrix_scaling(factor: 0.8) // Assuming matrix_scaling exists or is implemented
//        // let modelMatrix = matrix_multiply(rotationY, matrix_multiply(rotationX, scaleMatrix))
//
//        // 4. Combine Matrices: Calculate the final Model-View-Projection (MVP) matrix.
//        //    MVP = Projection * View * Model
//        //    The order of multiplication is crucial for transforming vertices correctly:
//        //    Model Space -> World Space (by Model matrix)
//        //    World Space -> View Space (by View matrix)
//        //    View Space  -> Clip Space (by Projection matrix)
//        let modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix) // Combine Model and View first
//        let mvpMatrix = matrix_multiply(projectionMatrix, modelViewMatrix) // Then apply Projection
//
//        // 5. Update Uniform Buffer: Copy the calculated MVP matrix into the GPU buffer.
//        //    Create a Swift `Uniforms` struct instance holding the final matrix.
//        var uniforms = Uniforms(modelViewProjectionMatrix: mvpMatrix)
//        // Get a pointer to the CPU-accessible memory region of the `uniformBuffer`.
//        // This is safe because we created the buffer with `.storageModeShared`.
//        let bufferPointer = uniformBuffer.contents()
//        // Copy the bytes from the local `uniforms` Swift struct into the GPU buffer memory.
//        // The size must match exactly.
//        memcpy(bufferPointer, &uniforms, MemoryLayout<Uniforms>.stride) // Use stride for safety
//
//        // 6. Animate: Increment the rotation angle for the next frame's calculation.
//        //    The value added determines the speed of rotation.
//        rotationAngle += 0.008 // Adjust for desired rotation speed.
//    }
//
//    // MARK: - MTKViewDelegate Methods
//
//    /// Called automatically by the `MTKView` whenever its drawable area size (in pixels) changes,
//    /// such as during device rotation or window resizing (on macOS).
//    /// It's essential to update the `aspectRatio` here to prevent distortion in the projection.
//    /// - Parameters:
//    ///   - view: The `MTKView` instance that reported the size change.
//    ///   - size: The new drawable size (`CGSize`) in pixels.
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        print("MTKView Resized - New Drawable Size: \(size.width)w x \(size.height)h")
//        // Calculate the new aspect ratio. Ensure height is not zero to avoid division by zero.
//        // Using `max(1, ...)` is a simple way to prevent this, returning aspectRatio=width if height=0.
//        aspectRatio = Float(size.width / max(1.0, size.height))
//        print("MTKView Resized - Updated Aspect Ratio: \(aspectRatio)")
//    }
//
//    /// Called automatically by the `MTKView` for each frame that needs to be rendered.
//    /// This is the core rendering loop where all drawing commands for a single frame are encoded
//    /// into a command buffer and submitted to the GPU.
//    /// - Parameter view: The `MTKView` instance requesting the drawing update.
//    func draw(in view: MTKView) {
//         // 1. Obtain necessary objects for rendering this frame.
//         //    - `currentDrawable`: Represents the texture the GPU will draw into for this frame.
//         //    - `currentRenderPassDescriptor`: Describes the render target (the drawable's texture),
//         //      clear colors, and depth/stencil buffer configurations for this rendering pass.
//         //    - `commandBuffer`: A container to record Metal commands for the GPU.
//         //    - `renderEncoder`: An object used specifically to encode rendering commands (draw calls,
//         //      setting pipeline state, binding buffers) within the context of the render pass descriptor.
//        guard let drawable = view.currentDrawable,
//              let renderPassDescriptor = view.currentRenderPassDescriptor,
//              let pipelineState = pipelineState, // Ensure pipeline state is already created and valid.
//              let commandBuffer = commandQueue.makeCommandBuffer(),
//              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
//             // Print a more detailed error if possible, e.g., which object failed.
//             print("Renderer [Draw]: FAILED to obtain required Metal objects for drawing. Skipping frame.")
//             print(" ---> Drawable valid: \(view.currentDrawable != nil), Descriptor valid: \(view.currentRenderPassDescriptor != nil), Pipeline valid: \(self.pipelineState != nil), CmdBuffer valid: \(commandQueue.makeCommandBuffer() != nil)")
//            return // Cannot proceed with rendering this frame.
//        }
//
//        // --- Per-Frame Updates ---
//        // Calculate the latest transformation matrix based on the current rotation angle
//        // and copy it into the uniform buffer for the GPU shaders to access.
//        updateUniforms()
//
//        // --- Configure Render Encoder ---
//        renderEncoder.label = "Dodecahedron Wireframe Render Encoder" // Debug label.
//        // Set the active render pipeline state. This tells the GPU which shaders and fixed-function states to use.
//        renderEncoder.setRenderPipelineState(pipelineState)
//        // Set the active depth/stencil state. This enables depth testing according to our configuration.
//        renderEncoder.setDepthStencilState(depthState)
//
//        // *** Set Render Mode to Wireframe ***
//        // This key command tells the GPU's rasterizer to render only the edges (lines)
//        // of the triangles, rather than filling their interiors with color.
//        renderEncoder.setTriangleFillMode(.lines)
//
//        // Optional: Set Culling Mode (if needed, usually for solid objects)
//        // renderEncoder.setCullMode(.back) // Hides back-facing triangles (good for solid, convex shapes)
//
//        // --- Bind Buffers ---
//        // Make the necessary GPU data buffers accessible to the shaders.
//        // The `index:` parameter corresponds to the `[[buffer(n)]]` attribute in the shader function arguments.
//        guard vertexBuffer != nil, uniformBuffer != nil, indexBuffer != nil else {
//            print("Renderer [Draw]: ERROR - Buffers are not initialized before draw call. Aborting draw.")
//            renderEncoder.endEncoding() // End encoding even if we bail early.
//            commandBuffer.commit()      // Commit potentially empty buffer.
//            return
//        }
//        // Bind vertex buffer to index 0 -> accessed by `vertices [[buffer(0)]]` in vertex shader.
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//        // Bind uniform buffer to index 1 -> accessed by `uniforms [[buffer(1)]]` in vertex shader.
//        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
//
//        // --- Issue Draw Call ---
//        // Instruct the GPU to perform the drawing operation.
//        renderEncoder.drawIndexedPrimitives(type: .triangle,           // Draw primitives composed of triangles.
//                                            indexCount: indices.count,  // Total number of indices to process (108 for the triangulated Dodecahedron).
//                                            indexType: .uint16,         // Data type of the indices in the index buffer (`UInt16`).
//                                            indexBuffer: indexBuffer,    // The buffer containing the index data.
//                                            indexBufferOffset: 0)     // Start reading indices from the beginning of the buffer.
//
//        // --- Finalize ---
//        // Signal that encoding commands for this render pass is complete.
//        renderEncoder.endEncoding()
//
//        // Schedule the presentation of the drawable (the rendered texture) to the screen.
//        // This typically happens after the command buffer has finished executing on the GPU.
//        commandBuffer.present(drawable)
//
//        // Commit the command buffer to the command queue, sending it to the GPU for execution.
//        commandBuffer.commit()
//        // Optional: Wait for completion (can be useful for debugging, but impacts performance)
//        // commandBuffer.waitUntilCompleted()
//    }
//}
//
//// MARK: - SwiftUI UIViewRepresentable
//
///// A SwiftUI `UIViewRepresentable` struct that wraps and manages an `MTKView` instance,
///// bridging the UIKit-based MetalKit view into the declarative SwiftUI view hierarchy.
///// This allows SwiftUI to display content rendered by Metal.
//struct MetalDodecahedronViewRepresentable: UIViewRepresentable {
//    /// Specifies the type of UIKit view this representable manages, which is `MTKView`.
//    typealias UIViewType = MTKView
//
//    /// Creates and returns the custom `Coordinator` object.
//    /// The coordinator's role here is to:
//    /// 1. Hold onto the `DodecahedronRenderer` instance, which contains the Metal logic.
//    /// 2. Act as the `MTKViewDelegate` to respond to drawing and resizing events.
//    /// This method is called *before* `makeUIView`.
//    /// - Returns: An initialized `DodecahedronRenderer` instance.
//    func makeCoordinator() -> DodecahedronRenderer {
//        print("Representable: Making Coordinator (DodecahedronRenderer)...")
//        // Attempt to get the default system GPU device. This might fail on unsupported hardware/simulators.
//        guard let device = MTLCreateSystemDefaultDevice() else {
//            fatalError("Representable: CRITICAL - Metal is not supported on this device/simulator.")
//        }
//        print("Representable: Metal device obtained: \(device.name)")
//        // Initialize our custom renderer class, passing the Metal device.
//        guard let coordinator = DodecahedronRenderer(device: device) else {
//            // The renderer's init could fail (e.g., command queue creation).
//            fatalError("Representable: CRITICAL - DodecahedronRenderer failed to initialize.")
//        }
//        print("Representable: Coordinator (DodecahedronRenderer) created successfully.")
//        return coordinator
//    }
//
//    /// Creates, configures, and returns the underlying `MTKView` instance.
//    /// This method is called only *once* by SwiftUI when the representable view is first
//    /// added to the view hierarchy.
//    /// - Parameter context: Provides access to the `Coordinator` (created by `makeCoordinator`)
//    ///   and other SwiftUI contextual information (like environment values).
//    /// - Returns: The fully configured `MTKView` ready for rendering.
//    func makeUIView(context: Context) -> MTKView {
//        print("Representable: Making MTKView...")
//        // Create a new instance of MTKView.
//        let mtkView = MTKView()
//
//        // --- Essential Configuration ---
//        // Assign the Metal device obtained by the coordinator to the view.
//        // The MTKView needs this to manage its internal resources (like drawable textures).
//        mtkView.device = context.coordinator.device
//
//        // Set the delegate: The coordinator (`DodecahedronRenderer`) will handle draw calls
//        // and size changes for this view.
//        mtkView.delegate = context.coordinator
//        print("Representable: MTKView delegate set to Coordinator.")
//
//        // Performance & Drawing Mode
//        mtkView.preferredFramesPerSecond = 60 // Target 60 FPS for smooth animation. Actual FPS may vary.
//        // Set to `false` for continuous animation driven by the display refresh rate.
//        // If `true`, you would need to manually call `mtkView.setNeedsDisplay()` to trigger redraws.
//        mtkView.enableSetNeedsDisplay = false
//        // Pauses rendering when the view is not visible or the app is inactive.
//        mtkView.isPaused = false
//
//        // *** Essential for 3D: Configure Depth Buffer ***
//        // Request a depth buffer format. `.depth32Float` provides high precision.
//        // A depth buffer is required for correct depth testing.
//        mtkView.depthStencilPixelFormat = .depth32Float
//        // Default value to clear the depth buffer to at the start of each frame (1.0 represents the farthest distance).
//        mtkView.clearDepth = 1.0
//        print("Representable: MTKView depth buffer configured (Format: depth32Float, Clear: 1.0).")
//
//        // Appearance
//        // Set the background color that the view is cleared to at the start of each frame's render pass.
//        mtkView.clearColor = MTLClearColor(red: 0.15, green: 0.1, blue: 0.1, alpha: 1.0) // Dark background
//        // Set the pixel format for the color texture (drawable) the view renders into.
//        // `.bgra8Unorm_srgb` is a common, well-supported format. `_srgb` ensures correct color handling.
//        mtkView.colorPixelFormat = .bgra8Unorm_srgb // Must match pipeline descriptor's color attachment[0].pixelFormat
//        print("Representable: MTKView appearance configured (ClearColor: Dark Gray, PixelFormat: bgra8Unorm_srgb).")
//
//        // --- Linking Renderer and View ---
//        // Now that the MTKView is configured with its pixel formats, the renderer's
//        // pipeline state (which depends on these formats) can be finalized.
//        print("Representable: Finalizing renderer pipeline configuration using MTKView formats...")
//        context.coordinator.configure(metalKitView: mtkView)
//
//        // Manually trigger the initial size update call in the delegate (Coordinator).
//        // This ensures the `aspectRatio` in the renderer is correctly set *before* the
//        // very first `draw(in:)` call might occur, preventing potential distortion
//        // in the first frame.
//        print("Representable: Triggering initial drawableSizeWillChange notification...")
//        context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
//
//        print("Representable: MTKView creation and configuration complete for Dodecahedron.")
//        return mtkView
//    }
//
//    /// Updates the state of the existing `MTKView` instance when relevant SwiftUI state changes occur.
//    /// This method is called by SwiftUI whenever the view needs to be updated (e.g., if environment
//    /// values change or if the Representable struct receives new parameters).
//    /// In this specific example, there are no external SwiftUI states driving the Metal view's
//    /// appearance directly (the animation is internal to the `DodecahedronRenderer`), so this method is empty.
//    /// - Parameters:
//    ///   - uiView: The existing `MTKView` instance being managed.
//    ///   - context: Provides access to the `Coordinator`, environment, and transaction information.
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // No external state updates are needed from SwiftUI in this basic example.
//        // If, for instance, SwiftUI controlled the rotation speed or color,
//        // those updates would be passed to the coordinator (`context.coordinator`) here.
//        // Example: context.coordinator.rotationSpeed = newSpeedFromSwiftUIState
//    }
//}
//
//// MARK: - Main SwiftUI View
//
///// The primary SwiftUI `View` struct that defines the user interface layout.
///// It includes a title `Text` label and embeds the Metal-rendered Dodecahedron
///// using the `MetalDodecahedronViewRepresentable`.
//struct DodecahedronView: View {
//    var body: some View {
//        // Use a VStack to arrange the title vertically above the Metal view.
//        // `spacing: 0` removes any default gap between the title and the Metal view.
//        VStack(spacing: 0) {
//            // Title Text Label
//            Text("Rotating Wireframe Dodecahedron (Metal)")
//                .font(.headline) // Use a standard headline font style.
//                .padding() // Add padding inside the text's frame for spacing.
//                .frame(maxWidth: .infinity) // Ensure the background color spans the full width.
//                .background(Color(red: 0.15, green: 0.1, blue: 0.1)) // Match Metal view's clear color.
//                .foregroundColor(.white) // Make text readable against the dark background.
//
//            // Embed the Metal View
//            // Instantiate the UIViewRepresentable, which handles the creation and management
//            // of the underlying MTKView and its DodecahedronRenderer.
//            MetalDodecahedronViewRepresentable()
//                // Modifiers applied here affect the frame SwiftUI allocates for the representable.
//
//            // Optional: `.ignoresSafeArea()` allows the Metal view to draw into areas
//            // normally reserved for system UI (like below the home indicator or around the notch).
//            // Use `.all`, `.container`, `.keyboard`, or specific edges (`.top`, `.bottom`).
//            // .ignoresSafeArea(.all)
//        }
//        // Apply a background color to the entire VStack container. This helps prevent
//        // potential white flashes during view transitions or if the Metal view takes a moment to load.
//        .background(Color(red: 0.15, green: 0.1, blue: 0.1)) //.edgesIgnoringSafeArea(.all) if needed
//        // Ensure the view layout ignores the keyboard's safe area, which is generally
//        // good practice unless specifically handling keyboard interactions within this view.
//        .ignoresSafeArea(.keyboard)
//    }
//}
//
//// MARK: - Preview Provider
//
///// Provides a preview of the `DodecahedronView` for use within Xcode Previews.
//#Preview {
//    // --- Option 1: Placeholder View (Recommended for Stability) ---
//    // Metal previews can be unstable or resource-intensive. A placeholder is often safer.
//    struct PreviewPlaceholder: View {
//        var body: some View {
//            VStack(spacing: 0) { // Match parent structure
//                Text("Rotating Wireframe Dodecahedron (Metal)")
//                    .font(.headline)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color(red: 0.15, green: 0.1, blue: 0.1))
//                    .foregroundColor(.white)
//
//                // Placeholder content instead of the actual Metal view
//                ZStack { // Use ZStack to center content
//                    Color(red: 0.15, green: 0.1, blue: 0.1) // Background color
//                    VStack {
//                         Spacer() // Push text to center vertically
//                         Text("METAL VIEW AREA")
//                           .font(.caption)
//                           .foregroundColor(.gray.opacity(0.5))
//                           .padding()
//                           .overlay(
//                               RoundedRectangle(cornerRadius: 8)
//                                   .stroke(Color.gray.opacity(0.5), lineWidth: 1)
//                           )
//
//                         Text("(Rendering requires Simulator or Device)")
//                            .font(.caption2)
//                            .foregroundColor(.gray)
//                            .italic()
//                         Spacer()
//                    }
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill available space
//            }
//            .background(Color(red: 0.15, green: 0.1, blue: 0.1)) // Overall background
//            .ignoresSafeArea(.all) // Match potential parent setting
//        }
//    }
//    // return PreviewPlaceholder() // <-- UNCOMMENT this line to use the safe placeholder
//
//    // --- Option 2: Attempt to Render Actual Metal View ---
//    // This might work on capable Macs or sometimes in the simulator, but can be unreliable.
//    return DodecahedronView() // <-- Use the actual view (COMMENT OUT placeholder line above)
//}
//
//// MARK: - Matrix Math Helper Functions (SIMD)
//
///// Utility functions for creating common 3D transformation matrices using the SIMD framework.
///// These functions are designed for a **Left-Handed** coordinate system, which is often
///// the default convention in Metal and DirectX (unlike OpenGL's typical right-handed system).
//
///// Creates a 4x4 perspective projection matrix for a **Left-Handed** coordinate system.
///// This matrix transforms points from view space (camera space) to clip space.
///// Clip space coordinates are then normalized to Normalized Device Coordinates (NDC)
///// by perspective division (dividing x, y, z by w).
///// - Parameters:
/////   - fovyRadians: Vertical field of view angle in radians. Determines how 'zoomed' the view is.
/////   - aspectRatio: The aspect ratio (width / height) of the viewport. Prevents distortion.
/////   - nearZ: The distance from the camera to the near clipping plane. Must be positive.
/////   - farZ: The distance from the camera to the far clipping plane. Must be positive and greater than nearZ.
///// - Returns: A `matrix_float4x4` representing the perspective projection.
//func matrix_perspective_left_hand(fovyRadians: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
//    let y = 1.0 / tan(fovyRadians * 0.5) // Scale factor for y based on FOV
//    let x = y / aspectRatio             // Scale factor for x, adjusted by aspect ratio
//    let z = farZ / (farZ - nearZ)       // Scale factor for z (maps nearZ to 0, farZ to 1 in clip space before w division - LH variation)
//    let w = -nearZ * z                  // Translation factor for z (part of mapping near plane correctly - LH variation)
//
//    // Construct the matrix column by column or row by row depending on convention.
//    // SIMD matrices are often treated as columns.
//    // Column 0: (x, 0, 0, 0)
//    // Column 1: (0, y, 0, 0)
//    // Column 2: (0, 0, z, 1)  <- Note the '1' in the w component for perspective
//    // Column 3: (0, 0, w, 0)
//    return matrix_float4x4(
//        SIMD4<Float>(x, 0, 0, 0), // Column 0
//        SIMD4<Float>(0, y, 0, 0), // Column 1
//        SIMD4<Float>(0, 0, z, 1), // Column 2
//        SIMD4<Float>(0, 0, w, 0)  // Column 3
//    )
//}
//
///// Creates a 4x4 view matrix for a **Left-Handed** coordinate system using the 'look at' approach.
///// This matrix transforms points from world space to view space (camera space). It effectively
///// positions and orients the camera within the world.
///// - Parameters:
/////   - eye: The position of the camera (the 'eye') in world coordinates.
/////   - center: The point in world coordinates that the camera is looking directly at.
/////   - up: The vector defining the 'up' direction in the world (usually (0, 1, 0)). This vector
/////     should not be parallel to the direction vector (center - eye).
///// - Returns: A `matrix_float4x4` representing the view transformation.
//func matrix_look_at_left_hand(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> matrix_float4x4 {
//    // Calculate the camera's local axes based on the eye, center, and up vectors.
//    let zAxis = normalize(center - eye)      // Forward direction (points towards center)
//    let xAxis = normalize(cross(up, zAxis))  // Right direction (perpendicular to up and forward)
//    let yAxis = cross(zAxis, xAxis)          // Recalculated Up direction (perpendicular to forward and right)
//
//    // Calculate the translation components needed to move the world relative to the camera origin.
//    // This involves projecting the eye position onto the camera's local axes.
//    let translateX = -dot(xAxis, eye)
//    let translateY = -dot(yAxis, eye)
//    let translateZ = -dot(zAxis, eye)
//
//    // Construct the view matrix. The upper 3x3 part represents the rotation (aligning world axes
//    // with camera axes), and the last column represents the translation.
//    // Column-major format:
//    // | xAxis.x  yAxis.x  zAxis.x  0 |
//    // | xAxis.y  yAxis.y  zAxis.y  0 |
//    // | xAxis.z  yAxis.z  zAxis.z  0 |
//    // | transX   transY   transZ   1 |
//    return matrix_float4x4(
//        SIMD4<Float>( xAxis.x,  yAxis.x,  zAxis.x, 0), // Column 0
//        SIMD4<Float>( xAxis.y,  yAxis.y,  zAxis.y, 0), // Column 1
//        SIMD4<Float>( xAxis.z,  yAxis.z,  zAxis.z, 0), // Column 2
//        SIMD4<Float>(translateX, translateY, translateZ, 1)  // Column 3
//    )
//}
//
///// Creates a 4x4 rotation matrix for rotation around the Y-axis (Up axis in standard coordinates).
///// Assumes a **Left-Handed** coordinate system rotation convention (positive angle rotates
///// counter-clockwise when looking down the negative Y-axis, or clockwise down positive Y).
///// - Parameter radians: The angle of rotation in radians.
///// - Returns: A `matrix_float4x4` representing the Y-axis rotation.
//func matrix_rotation_y(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians)
//    let s = sin(radians)
//    // Y-axis rotation matrix (LH)
//    // | c  0  s  0 |
//    // | 0  1  0  0 |
//    // |-s  0  c  0 |
//    // | 0  0  0  1 |
//    return matrix_float4x4(
//        SIMD4<Float>( c, 0, s, 0), // Column 0
//        SIMD4<Float>( 0, 1, 0, 0), // Column 1
//        SIMD4<Float>(-s, 0, c, 0), // Column 2
//        SIMD4<Float>( 0, 0, 0, 1)  // Column 3
//    )
//}
//
///// Creates a 4x4 rotation matrix for rotation around the X-axis (Right axis in standard coordinates).
///// Assumes a **Left-Handed** coordinate system rotation convention (positive angle rotates
///// counter-clockwise when looking down the negative X-axis, or clockwise down positive X).
///// - Parameter radians: The angle of rotation in radians.
///// - Returns: A `matrix_float4x4` representing the X-axis rotation.
//func matrix_rotation_x(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians)
//    let s = sin(radians)
//    // X-axis rotation matrix (LH)
//    // | 1  0  0  0 |
//    // | 0  c -s  0 | // Sign of 's' depends on LH/RH convention
//    // | 0  s  c  0 | // For LH, positive angle rotates Y towards Z.
//    // | 0  0  0  1 |
//    return matrix_float4x4(
//        SIMD4<Float>(1,  0, 0, 0), // Column 0
//        SIMD4<Float>(0,  c, s, 0), // Column 1 - Adjust sign if needed based on precise LH definition used
//        SIMD4<Float>(0, -s, c, 0), // Column 2
//        SIMD4<Float>(0,  0, 0, 1)  // Column 3
//    )
//    // Note: If using a convention where positive X rotation brings Z towards Y instead, swap signs of s.
//    // SIMD4<Float>(0,  c, -s, 0), // Column 1
//    // SIMD4<Float>(0,  s,  c, 0), // Column 2
//    // Verify against expected visual output. The current version assumes standard LH X rotation.
//}
//
///// Multiplies two 4x4 matrices.
///// Matrix multiplication is not commutative (A * B != B * A). The order is significant,
///// typically representing the application of transformations in sequence. For example,
///// `Point * Model * View * Projection` transforms a point from model space to clip space.
///// The SIMD framework overloads the `*` operator for matrix multiplication.
///// - Parameters:
/////   - matrix1: The first matrix (left-hand side).
/////   - matrix2: The second matrix (right-hand side).
///// - Returns: The resulting `matrix_float4x4` product (matrix1 * matrix2).
//func matrix_multiply(_ matrix1: matrix_float4x4, _ matrix2: matrix_float4x4) -> matrix_float4x4 {
//    // Uses the overloaded '*' operator provided by the SIMD framework.
//    return matrix1 * matrix2
//}
//
//// Optional: Add matrix_scaling if needed
///*
//func matrix_scaling(factor: Float) -> matrix_float4x4 {
//    return matrix_float4x4(diagonal: SIMD4<Float>(factor, factor, factor, 1.0))
//}
//
//func matrix_scaling(x: Float, y: Float, z: Float) -> matrix_float4x4 {
//    return matrix_float4x4(diagonal: SIMD4<Float>(x, y, z, 1.0))
//}
//*/
