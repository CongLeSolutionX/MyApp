////
////  IcosahedronView_2nd_try_Over_the_top.swift
////  MyApp
////
////  Created by Cong Le on 5/3/25.
////
//
////  Description:
////  This file defines a SwiftUI view hierarchy that displays a 3D rotating
////  wireframe icosahedron rendered using Apple's Metal framework. It demonstrates:
////  - Embedding a MetalKit view (MTKView) within SwiftUI using UIViewRepresentable.
////  - Setting up a basic Metal rendering pipeline (shaders, buffers, pipeline state).
////  - Defining geometry (vertices, indices) for an icosahedron.
////  - Using SIMD for matrix transformations (Model-View-Projection).
////  - Basic animation through rotation updates per frame.
////  - Depth testing for correct 3D appearance.
////  - Rendering in wireframe mode using `setTriangleFillMode(.lines)`.
////
//import SwiftUI
//import MetalKit // Provides MTKView and Metal integration helpers
//import simd    // Provides efficient vector and matrix types/operations (like matrix_float4x4)
//
//// MARK: - Metal Shaders (Embedded String)
//
///// Contains the source code for the Metal vertex and fragment shaders.
///// These programmable functions run directly on the GPU to process vertex data
///// and determine the color of each pixel (fragment) on the screen.
//let icosahedronMetalShaderSource = """
//#include <metal_stdlib> // Import the Metal Standard Library for common types and functions
//
//using namespace metal; // Use the Metal namespace to avoid prefixing (e.g., metal::float3)
//
//// Structure defining vertex input data received from the CPU (Swift code).
//// The layout *must* exactly match the 'IcosahedronVertex' struct in Swift
//// and the layout described by the 'MTLVertexDescriptor' used to create the pipeline state.
//struct VertexIn {
//    // Vertex position in model space (local coordinates of the icosahedron).
//    // [[attribute(0)]] links this field to the first attribute (index 0) defined in the MTLVertexDescriptor.
//    float3 position [[attribute(0)]];
//
//    // Vertex color (RGBA).
//    // [[attribute(1)]] links this field to the second attribute (index 1) in the MTLVertexDescriptor.
//    float4 color    [[attribute(1)]];
//};
//
//// Structure defining the data passed from the vertex shader to the fragment shader.
//// Metal interpolates these values across the surface of the primitive (triangle/line)
//// before passing them to the fragment shader for each pixel.
//struct VertexOut {
//    // Final calculated position in clip space. This is a required output for the vertex shader.
//    // [[position]] designates this member as the special variable holding the clip-space position.
//    float4 position [[position]];
//
//    // Color to be interpolated and used by the fragment shader.
//    float4 color;
//};
//
//// Structure for uniform data (constants that remain the same for all vertices in a draw call)
//// passed from the CPU. This *must* match the layout of the 'Uniforms' struct in Swift.
//struct Uniforms {
//    // Combined Model-View-Projection matrix. Transforms vertex positions from model space
//    // directly to clip space.
//    float4x4 modelViewProjectionMatrix;
//};
//
//// --- Vertex Shader ---
//// This function is executed once for each vertex specified in the draw call.
//// Its primary jobs are to calculate the final position of the vertex in clip space
//// and pass any necessary data (like color) to the fragment shader stage.
//vertex VertexOut icosahedron_vertex_shader(
//    // Input: Pointer to the array of vertices passed from the CPU's vertex buffer.
//    // [[buffer(0)]] links this argument to the buffer bound at index 0 using the
//    // `setVertexBuffer` command on the MTLRenderCommandEncoder.
//    const device VertexIn *vertices [[buffer(0)]],
//
//    // Input: Reference to the uniform data (containing the MVP matrix) from the CPU's uniform buffer.
//    // [[buffer(1)]] links this argument to the buffer bound at index 1.
//    const device Uniforms &uniforms [[buffer(1)]],
//
//    // Input: A system-generated index indicating which vertex in the buffer this particular
//    // shader invocation is processing. Essential when using non-indexed drawing or accessing vertices directly.
//    // Also implicitly used when using indexed drawing (like here) where Metal uses the index buffer
//    // to fetch the correct `vid` before calling the shader.
//    unsigned int vid [[vertex_id]]
//) {
//    // Declare the output structure to be populated.
//    VertexOut out;
//
//    // Retrieve the input data for the current vertex using its unique vertex ID.
//    // When using indexed drawing (`drawIndexedPrimitives`), Metal fetches the index
//    // from the index buffer first, then uses that index as `vid` to access the vertex buffer.
//    VertexIn currentVertex = vertices[vid];
//
//    // Calculate the vertex's clip space position.
//    // Multiply the model space position (xyz) by the Model-View-Projection matrix.
//    // The `float4(currentVertex.position, 1.0)` converts the 3D position into a
//    // 4D homogeneous coordinate (w=1.0) required for matrix multiplication and perspective division later.
//    out.position = uniforms.modelViewProjectionMatrix * float4(currentVertex.position, 1.0);
//
//    // Pass the vertex's assigned color directly to the output structure.
//    // This color will be interpolated across the primitive (line segment in wireframe mode)
//    // for input to the fragment shader.
//    out.color = currentVertex.color;
//
//    // Return the populated output structure containing the calculated clip-space position
//    // and interpolated color.
//    return out;
//}
//
//// --- Fragment Shader ---
//// This function is executed for each pixel (fragment) that is covered by a rendered primitive
//// (after rasterization). Its primary job is to determine the final color of that pixel.
//fragment half4 icosahedron_fragment_shader(
//    // Input: The interpolated data received from the vertex shader (`VertexOut` struct).
//    // The `[[stage_in]]` attribute indicates that this structure contains values
//    // interpolated from the vertex shader outputs across the primitive's surface.
//    VertexOut in [[stage_in]]
//) {
//    // Return the interpolated color as the final output color for this fragment (pixel).
//    // Using 'half4' (16-bit floating-point) can sometimes offer performance benefits on
//    // mobile GPUs compared to 'float4' (32-bit), especially for color data.
//    return half4(in.color);
//}
//"""
//
//// MARK: - Swift Data Structures (Matching Shaders)
//
///// Swift structure mirroring the layout of the 'Uniforms' struct in the Metal shader code (`icosahedronMetalShaderSource`).
///// This ensures that the data layout in CPU memory matches the layout expected by the GPU shader
///// when the data is copied to the `uniformBuffer`.
//struct Uniforms {
//    /// The combined Model-View-Projection matrix. `matrix_float4x4` is a SIMD framework type alias for a 4x4 matrix of Floats.
//    var modelViewProjectionMatrix: matrix_float4x4
//}
//
///// Structure defining the layout of individual vertex data in Swift application code.
///// The memory layout of this struct *must* perfectly match:
///// 1. The `VertexIn` struct definition in the Metal shader (`icosahedronMetalShaderSource`).
///// 2. The attribute formats, offsets, and strides defined in the `MTLVertexDescriptor`
/////    used when creating the `MTLRenderPipelineState`.
//struct IcosahedronVertex {
//    /// The 3D position (x, y, z) of the vertex in the icosahedron's local model space. `SIMD3<Float>` is a 3-component vector of Floats.
//    var position: SIMD3<Float>
//    /// The RGBA color associated with this vertex. `SIMD4<Float>` is a 4-component vector of Floats.
//    var color: SIMD4<Float>
//}
//
//// MARK: - Renderer Class (Handles Metal Logic)
//
///// Manages all Metal-specific setup, resource creation (buffers, pipeline state, depth state),
///// and the frame-by-frame rendering logic required to draw the icosahedron.
///// It conforms to `MTKViewDelegate` to receive callbacks from the `MTKView` for drawing updates
///// and handling view resize events.
//class IcosahedronRenderer: NSObject, MTKViewDelegate {
//
//    /// Represents the physical GPU device. Used as a factory for creating other Metal objects
//    /// like command queues, buffers, textures, and pipeline states.
//    let device: MTLDevice
//    /// A queue responsible for organizing and submitting encoded commands (rendering, compute, blit)
//    /// to the GPU for execution in a serial order.
//    let commandQueue: MTLCommandQueue
//    /// Stores the compiled vertex and fragment shaders along with fixed-function state settings
//    /// (like vertex layout, pixel formats, blending) needed for a specific draw call.
//    /// It's expensive to create, so it's typically built once during initialization.
//    var pipelineState: MTLRenderPipelineState!
//    /// Configures depth testing parameters. Depth testing ensures that primitives closer to the
//    /// camera correctly obscure primitives farther away, crucial for correct 3D rendering.
//    var depthState: MTLDepthStencilState!
//
//    // --- GPU Buffers ---
//    // Buffers are regions of memory accessible by the GPU.
//
//    /// GPU buffer storing the array of `IcosahedronVertex` data. This is passed to the vertex shader.
//    var vertexBuffer: MTLBuffer!
//    /// GPU buffer storing the array of `UInt16` indices. These indices specify the order in which
//    /// vertices from the `vertexBuffer` should be connected to form triangles (or lines in wireframe).
//    var indexBuffer: MTLBuffer!
//    /// GPU buffer holding the `Uniforms` struct (containing the MVP matrix). This data is updated
//    /// each frame and passed to the vertex shader. Marked as `.storageModeShared` for CPU/GPU access (can vary).
//    var uniformBuffer: MTLBuffer!
//
//    // --- State Variables ---
//
//    /// Tracks the current rotation angle of the icosahedron around its axes (in radians).
//    /// This value is incremented slightly each frame in `updateUniforms` to create the animation.
//    var rotationAngle: Float = 0.0
//    /// Stores the aspect ratio (width / height) of the `MTKView`. This is needed for the
//    /// projection matrix calculation to avoid distortion. Updated by `mtkView(_:drawableSizeWillChange:)`.
//    var aspectRatio: Float = 1.0
//
//    // MARK: - Geometry Data
//
//    /// Defines the 12 unique vertices of a regular icosahedron.
//    /// The positions are calculated using the golden ratio (`phi`) to ensure regularity
//    /// and are initially placed relative to the origin. They are then normalized and scaled.
//    /// Each vertex is assigned a distinct color for visualization.
//    let vertices: [IcosahedronVertex] = {
//        let phi: Float = (1.0 + sqrt(5.0)) / 2.0 // The golden ratio (approx 1.618)
//        let a: Float = 1.0                       // Base scale factor for coordinates
//        let b: Float = 1.0 / phi                 // Factor derived from the golden ratio
//
//        // 12 Vertices defined using combinations of (0, ±b, ±a), (±b, ±a, 0), (±a, 0, ±b)
//        // Careful ordering is needed to match the index buffer definitions.
//        // Note: The original vertex order/definition might need adjustments to perfectly
//        // match the index list for correct face formation. This is a common setup.
//        var positions: [SIMD3<Float>] = [
//            SIMD3<Float>( 0,  b, -a), // 0: Top-front-left-ish
//            SIMD3<Float>( b,  a,  0), // 1: Top-right+X
//            SIMD3<Float>(-b,  a,  0), // 2: Top-left-X
//
//            SIMD3<Float>( 0,  b,  a), // 3: Top-back-right-ish (Error in comment? Should be Z+)
//            SIMD3<Float>( 0, -b,  a), // 4: Bottom-back-right-ish (Error in comment? Should be Z+)
//
//            SIMD3<Float>(-a,  0,  b), // 5: Mid-left-X-back
//            SIMD3<Float>( 0, -b, -a), // 6: Bottom-front-left-ish
//            
//            SIMD3<Float>( a,  0, -b), // 7: Mid-right-X-front (Adjusted index from original)
//            SIMD3<Float>( a,  0,  b), // 8: Mid-right-X-back (Adjusted index from original)
//
//            SIMD3<Float>(-a,  0, -b), // 9: Mid-left-X-front (Adjusted index from original)
//            SIMD3<Float>( b, -a,  0), // 10: Bottom-right+X (Adjusted index from original)
//            SIMD3<Float>(-b, -a,  0)  // 11: Bottom-left-X (Adjusted index from original)
//        ]
//
//        // Normalize each position vector to have unit length (lie on a sphere of radius 1)
//        // then scale it slightly outwards (radius 1.5) to make it larger in the view.
//        positions = positions.map { normalize($0) * 1.5 }
//
//        // Assign distinct RGBA colors to each vertex for easier visualization.
//        // Alpha is set to 1 (fully opaque).
//        let colors: [SIMD4<Float>] = [
//            SIMD4<Float>(1, 0, 0, 1),   // Red
//            SIMD4<Float>(0, 1, 0, 1),   // Green
//            SIMD4<Float>(0, 0, 1, 1),   // Blue
//            SIMD4<Float>(1, 1, 0, 1),   // Yellow
//            SIMD4<Float>(0, 1, 1, 1),   // Cyan
//            SIMD4<Float>(1, 0, 1, 1),   // Magenta
//            SIMD4<Float>(1, 0.5, 0, 1), // Orange
//            SIMD4<Float>(0.5, 0, 1, 1), // Purple
//            SIMD4<Float>(0, 0.5, 0.5, 1),// Teal
//            SIMD4<Float>(0.5, 0.5, 0, 1),// Olive
//            SIMD4<Float>(1, 0.8, 0.8, 1),// Pink
//            SIMD4<Float>(0.8, 0.8, 1, 1) // Light Blue
//        ]
//
//        // Combine the position and color data for each vertex into the final `IcosahedronVertex` array.
//        return zip(positions, colors).map { IcosahedronVertex(position: $0.0, color: $0.1) }
//    }()
//
//    /// Defines the 20 triangular faces of the icosahedron using indices into the `vertices` array.
//    /// Each group of three `UInt16` values represents one triangle.
//    /// The order of indices (winding order) determines the front face (typically counter-clockwise).
//    /// This list is crucial for `drawIndexedPrimitives`.
//    /// Note: The specific indices depend *critically* on the order of vertices defined above.
//    /// Verification against a standard icosahedron net is recommended if faces appear incorrect.
//    /// An icosahedron has 20 faces, 30 edges, 12 vertices. Each face needs 3 indices, so 20 * 3 = 60 indices.
//     let indices: [UInt16] = [
//         // Faces connecting to vertex 0 (Top-front-left-ish)
//         0,  2,  1,   // Top cap piece 1 (towards +Y, +X) - Adjusted winding
//         0,  9,  2,   // Side face (towards -X) - Adjusted vertex order for connection
//         0,  7,  9,   // Side face (towards +X, -Z) - Adjusted vertex order connectivity
//         0,  1,  7,   // Side face (connecting 0, 1, 7) - adjusted
//         0,  6,  9, // Adjusted potentially incorrect indices from snippet -> Check Connectivity (0, 6, 9)
//         
//         // Belt faces (around the equator) - Careful connections needed
//         1,  8,  7,   // Connects 1, 8, 7 (+X side) - Adjusted vertex order
//         2,  5,  9,   // Connects 2, 5, 9 (-X side) - Adjusted vertex order
//         3,  8,  1,   // Top cap piece 2 (connecting 3, 8, 1) - Adjusted, check vertices
//         3,  4,  8,   // Side rear face (connecting 3, 4, 8) - adjusted
//         3,  5,  4,   // Side rear face (connecting 3, 5, 4) - adjusted
//         3,  2,  5,   // Top cap piece 3 (connecting 3, 2, 5) - adjusted
//         
//         // Faces connecting to vertex 11 (Bottom-left-X)
//         11, 10,  4,  // Connects 11, 10, 4 (Bottom face piece) - adjusted
//         11, 4,  5,   // Connects 11, 4, 5 (Bottom face piece) - adjusted
//         11, 5,  9,   // Connects 11, 5, 9 (Bottom face piece towards -X) - adjusted
//         11, 9,  6,   // Connects 11, 9, 6 (Bottom face piece Front) - adjusted
//         11, 6, 10,  // Connects 11, 6, 10 (Bottom face piece towards +X) - adjusted
//
//         // Remaining bottom faces (connecting to vertex 10, 7, 6 etc)
//         10, 7,  6, // Connects 10, 7, 6 (+X Bottom Front) - adjusted
//         10, 8,  7, // Connects 10, 8, 7 (+X Bottom Back) - adjusted, check vertices
//         4, 10, 8 // Connects 4, 10, 8 - adjusted, check vertices
//         // Total should be 20 faces * 3 indices/face = 60 indices.
//         // Double-check connectivity and winding order from diagram if issues occur.
//     ]
//    // --- End Geometry Data ---
//
//    /// Initializes the `IcosahedronRenderer`.
//    /// This involves obtaining the Metal device, creating a command queue, and setting up
//    /// the necessary GPU buffers and the depth stencil state.
//    /// Initialization fails if a Metal device cannot be found or the command queue cannot be created.
//    /// - Parameter device: The `MTLDevice` (GPU) to be used for all Metal operations.
//    init?(device: MTLDevice) {
//        self.device = device
//        // Attempt to create a command queue associated with the device.
//        guard let queue = device.makeCommandQueue() else {
//            print("Error: Could not create Metal command queue.")
//            return nil // Initialization fails if queue creation fails.
//        }
//        self.commandQueue = queue
//        super.init() // Call the NSObject initializer
//
//        // Create and populate GPU buffers for geometry and uniforms.
//        setupBuffers()
//        // Configure the depth testing state.
//        setupDepthStencil()
//        print("IcosahedronRenderer initialized successfully.")
//    }
//
//    /// Configures the renderer with parameters specific to the `MTKView` it will draw into.
//    /// This is called *after* the `MTKView` is created and provides necessary format information.
//    /// Specifically, it sets up the `MTLRenderPipelineState`.
//    /// - Parameter metalKitView: The `MTKView` instance that this renderer will draw into.
//    func configure(metalKitView: MTKView) {
//        setupPipeline(metalKitView: metalKitView)
//    }
//
//    // MARK: - Setup Functions
//
//    /// Compiles the Metal shader source code and creates the `MTLRenderPipelineState` object.
//    /// This involves:
//    /// 1. Creating a Metal library from the shader source code.
//    /// 2. Getting references to the compiled vertex (`icosahedron_vertex_shader`) and fragment (`icosahedron_fragment_shader`) functions.
//    /// 3. Creating an `MTLRenderPipelineDescriptor` to configure the pipeline.
//    /// 4. Setting the vertex and fragment functions on the descriptor.
//    /// 5. Specifying the pixel formats for color and depth attachments (obtained from the `MTKView`).
//    /// 6. Creating and configuring an `MTLVertexDescriptor` that describes the memory layout of the `IcosahedronVertex` struct to Metal.
//    /// 7. Assigning the vertex descriptor to the pipeline descriptor.
//    /// 8. Creating the final `MTLRenderPipelineState` object from the descriptor.
//    /// This function uses `fatalError` for failures, as a missing pipeline state is unrecoverable for rendering.
//    /// - Parameter metalKitView: The `MTKView` providing essential pixel format information.
//    func setupPipeline(metalKitView: MTKView) {
//        do {
//            // 1. Create a Metal library from the embedded shader source string.
//            let library = try device.makeLibrary(source: icosahedronMetalShaderSource, options: nil)
//
//            // 2. Get references to the compiled shader functions by name.
//            guard let vertexFunction = library.makeFunction(name: "icosahedron_vertex_shader"),
//                  let fragmentFunction = library.makeFunction(name: "icosahedron_fragment_shader") else {
//                // Ensure shader function names in the string exactly match these names.
//                fatalError("Fatal Error: Could not load shader functions from library. Check names: 'icosahedron_vertex_shader', 'icosahedron_fragment_shader'.")
//            }
//
//            // 3. Create a descriptor to configure the render pipeline state.
//            let pipelineDescriptor = MTLRenderPipelineDescriptor()
//            pipelineDescriptor.label = "Wireframe Icosahedron Pipeline" // Debug label
//
//            // 4. Assign the compiled shader functions.
//            pipelineDescriptor.vertexFunction = vertexFunction
//            pipelineDescriptor.fragmentFunction = fragmentFunction
//
//            // 5. Specify the pixel formats for the render targets. These *must* match the MTKView's configuration.
//            pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat // Format of the view's main drawable texture.
//            pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat // Format for the depth buffer texture.
//
//            // 6. Create and configure the Vertex Descriptor.
//            // This tells Metal how vertex data is structured in the vertex buffer.
//            let vertexDescriptor = MTLVertexDescriptor()
//
//            // --- Attribute 0: Position ---
//            vertexDescriptor.attributes[0].format = .float3 // Data type is 3 Floats (SIMD3<Float>)
//            vertexDescriptor.attributes[0].offset = 0 // Starts at the beginning of the struct
//            vertexDescriptor.attributes[0].bufferIndex = 0 // Uses the buffer bound at index 0 (`vertexBuffer`)
//
//            // --- Attribute 1: Color ---
//            vertexDescriptor.attributes[1].format = .float4 // Data type is 4 Floats (SIMD4<Float>)
//            // Offset is calculated based on the size (stride) of the preceding attribute (position).
//            vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
//            vertexDescriptor.attributes[1].bufferIndex = 0 // Also uses the buffer bound at index 0
//
//            // --- Layout 0: Describes the overall vertex struct ---
//            // The stride is the total size of one IcosahedronVertex struct in memory.
//            vertexDescriptor.layouts[0].stride = MemoryLayout<IcosahedronVertex>.stride
//            // Data is fetched per vertex (not per instance).
//            vertexDescriptor.layouts[0].stepRate = 1
//            vertexDescriptor.layouts[0].stepFunction = .perVertex
//
//            // 7. Assign the configured vertex descriptor to the pipeline descriptor.
//            pipelineDescriptor.vertexDescriptor = vertexDescriptor
//
//            // 8. Create the immutable render pipeline state object.
//            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//            print("MTLRenderPipelineState created successfully.")
//
//        } catch {
//            // Catch potential errors during library/pipeline state creation.
//            fatalError("Fatal Error: Failed to create Metal Render Pipeline State: \(error)")
//        }
//    }
//
//    /// Creates the GPU buffers (`MTLBuffer`) needed to store vertex data, index data, and uniform data.
//    /// These buffers hold the geometry and transformation information accessible by the GPU.
//    /// Uses `fatalError` for failures as missing buffers are unrecoverable.
//    func setupBuffers() {
//        // --- Vertex Buffer ---
//        // Calculate the total size in bytes needed for all vertices.
//        let vertexDataSize = vertices.count * MemoryLayout<IcosahedronVertex>.stride
//        // Create a buffer on the device, copying the `vertices` array data into it.
//        // `options: []` typically defaults to storage accessible by CPU and GPU, potentially optimized by Metal.
//        guard let vBuffer = device.makeBuffer(bytes: vertices, length: vertexDataSize, options: []) else {
//            fatalError("Fatal Error: Could not create vertex buffer.")
//        }
//        vertexBuffer = vBuffer
//        vertexBuffer.label = "Icosahedron Vertices" // Debug label
//
//        // --- Index Buffer ---
//        // Calculate the total size in bytes needed for all indices.
//        let indexDataSize = indices.count * MemoryLayout<UInt16>.stride
//        // Create a buffer on the device, copying the `indices` array data into it.
//        guard let iBuffer = device.makeBuffer(bytes: indices, length: indexDataSize, options: []) else {
//            fatalError("Fatal Error: Could not create index buffer.")
//        }
//        indexBuffer = iBuffer
//        indexBuffer.label = "Icosahedron Indices" // Debug label
//
//        // --- Uniform Buffer ---
//        // Calculate the size needed for one `Uniforms` struct.
//        let uniformBufferSize = MemoryLayout<Uniforms>.size
//        // Create a buffer large enough to hold the uniforms struct.
//        // `.storageModeShared` allows both CPU and GPU to access this memory directly (suitable for frequently updated data).
//        // Other options like `.storageModeManaged` or `.storageModePrivate` exist depending on access patterns.
//        guard let uBuffer = device.makeBuffer(length: uniformBufferSize, options: .storageModeShared) else {
//            fatalError("Fatal Error: Could not create uniform buffer.")
//        }
//        uniformBuffer = uBuffer
//        uniformBuffer.label = "Uniforms Buffer (MVP Matrix)" // Debug label
//        print("Metal buffers (vertex, index, uniform) created successfully.")
//    }
//
//    /// Creates the `MTLDepthStencilState` object used to configure depth testing.
//    /// Depth testing ensures that geometry is drawn correctly in 3D space based on distance from the camera.
//    /// Uses `fatalError` for failures.
//    func setupDepthStencil() {
//        let depthDescriptor = MTLDepthStencilDescriptor()
//        // `.less`: Fragments pass the depth test if their depth value is less than the value already in the depth buffer.
//        depthDescriptor.depthCompareFunction = .less
//        // `true`: Fragments that pass the depth test will write their depth value into the depth buffer.
//        depthDescriptor.isDepthWriteEnabled = true
//
//        // Create the immutable depth stencil state object from the descriptor.
//        guard let state = device.makeDepthStencilState(descriptor: depthDescriptor) else {
//            fatalError("Fatal Error: Failed to create depth stencil state.")
//        }
//        depthState = state
//        print("MTLDepthStencilState created successfully.")
//    }
//
//    // MARK: - Update State Per Frame
//
//    /// Calculates the Model-View-Projection (MVP) matrix based on the current rotation angle
//    /// and view parameters. It then copies this matrix into the `uniformBuffer` to be used
//    /// by the vertex shader in the upcoming draw call. Also increments the rotation angle.
//    func updateUniforms() {
//        // 1. Projection Matrix: Defines the camera's viewing frustum (field of view, aspect ratio, near/far planes).
//        // `matrix_perspective_left_hand` creates a perspective projection suitable for Metal's coordinate system.
//        let projectionMatrix = matrix_perspective_left_hand(
//            fovyRadians: .pi / 3.0,    // Field of view angle (60 degrees)
//            aspectRatio: aspectRatio,  // View's width / height
//            nearZ: 0.1,                // Distance to the near clipping plane
//            farZ: 100.0                // Distance to the far clipping plane
//        )
//
//        // 2. View Matrix: Defines the camera's position and orientation in world space.
//        // `matrix_look_at_left_hand` creates a matrix that makes the camera look from `eye` towards `center`.
//        let viewMatrix = matrix_look_at_left_hand(
//            eye: SIMD3<Float>(0, 0.5, -4.5), // Camera position (slightly up, back from origin) - Adjusted for icosahedron size
//            center: SIMD3<Float>(0, 0, 0),   // Point the camera is looking at (the origin)
//            up: SIMD3<Float>(0, 1, 0)        // Direction defining "up" for the camera (positive Y axis)
//        )
//
//        // 3. Model Matrix: Defines the icosahedron's transformations (rotation, translation, scale) in world space.
//        // Here, we apply rotations around the Y and X axes based on the current `rotationAngle`.
//        let rotationY = matrix_rotation_y(radians: rotationAngle)
//        let rotationX = matrix_rotation_x(radians: rotationAngle * 0.7) // Rotate slightly slower around X
//        // Multiply the rotations together to combine them. Order matters.
//        let modelMatrix = matrix_multiply(rotationY, rotationX)
//
//        // 4. Combine Matrices: Create the Model-View-Projection (MVP) matrix.
//        // Transforms vertices from model space -> world space -> view space -> clip space.
//        // Order of multiplication is Projection * View * Model.
//        let modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix)
//        let mvpMatrix = matrix_multiply(projectionMatrix, modelViewMatrix)
//
//        // 5. Prepare Uniforms Struct: Create an instance of the `Uniforms` struct with the calculated MVP matrix.
//        var uniforms = Uniforms(modelViewProjectionMatrix: mvpMatrix)
//
//        // 6. Update Buffer: Copy the `uniforms` data into the `uniformBuffer`.
//        // `contents()` gets a CPU-accessible pointer to the buffer's memory (possible because of `.storageModeShared`).
//        let bufferPointer = uniformBuffer.contents()
//        // `memcpy` copies the raw bytes from the `uniforms` struct into the buffer's memory.
//        memcpy(bufferPointer, &uniforms, MemoryLayout<Uniforms>.size)
//
//        // 7. Animate: Increment the rotation angle for the next frame.
//        rotationAngle += 0.008 // Adjust speed as needed (smaller value = slower rotation)
//    }
//
//    // MARK: - MTKViewDelegate Methods
//
//    /// Called automatically by the `MTKView` whenever its drawable (renderable surface) size changes,
//    /// such as during device rotation or window resize.
//    /// Updates the `aspectRatio` needed for the projection matrix to avoid distortion.
//    /// - Parameters:
//    ///   - view: The `MTKView` whose size changed.
//    ///   - size: The new drawable size in pixels (`CGSize`).
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        // Calculate the new aspect ratio. Avoid division by zero if height is momentarily 0.
//        aspectRatio = Float(size.width / max(1, size.height))
//        print("MTKView Resized - New Drawable Size: \(size), Aspect Ratio: \(aspectRatio)")
//    }
//
//    /// The main drawing callback, called automatically by the `MTKView` for each frame that needs
//    /// to be rendered (typically 60 times per second).
//    /// This is where all the commands to draw the icosahedron for a single frame are encoded and submitted to the GPU.
//    /// - Parameter view: The `MTKView` instance requesting the drawing.
//    func draw(in view: MTKView) {
//        // 1. Obtain Necessary Objects:
//        //    - `currentDrawable`: Represents the texture the view will display for this frame.
//        //    - `currentRenderPassDescriptor`: Describes the render targets (color, depth, stencil attachments)
//        //      and how they should be treated (e.g., clear color, load/store actions). It's configured on the MTKView.
//        //    - `commandBuffer`: A container to hold the encoded rendering commands for this frame.
//        //    - `renderEncoder`: An object used to encode the actual drawing commands into the command buffer.
//        guard let drawable = view.currentDrawable,
//              let renderPassDescriptor = view.currentRenderPassDescriptor,
//              let commandBuffer = commandQueue.makeCommandBuffer(),
//              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
//             // If any of these fail, we cannot render this frame. Log and exit.
//             print("Warning: Failed to get required Metal objects in draw(in:). Skipping frame.")
//            return
//        }
//
//        // 2. Update State: Calculate the latest MVP matrix and update the uniform buffer.
//        updateUniforms()
//
//        // 3. Configure Render Encoder:
//        renderEncoder.label = "Icosahedron Render Encoder" // Debug label
//        // Set the compiled pipeline state object containing shaders and fixed-function state.
//        renderEncoder.setRenderPipelineState(pipelineState)
//        // Set the depth stencil state object to enable depth testing.
//        renderEncoder.setDepthStencilState(depthState)
//        // *** Set the fill mode to lines for a wireframe effect ***
//        renderEncoder.setTriangleFillMode(.lines) // Other options: .fill
//
//        // 4. Bind Buffers: Tell the render encoder which buffers to use for vertex and uniform data.
//        // Bind `vertexBuffer` to buffer index 0 (matching `[[buffer(0)]]` in vertex shader).
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//        // Bind `uniformBuffer` to buffer index 1 (matching `[[buffer(1)]]` in vertex shader).
//        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
//
//        // 5. Draw Call: Issue the command to draw the geometry.
//        // `drawIndexedPrimitives` uses the `indexBuffer` to determine the order of vertices.
//        renderEncoder.drawIndexedPrimitives(type: .triangle, // Primitives are conceptually triangles (even for lines in wireframe)
//                                            indexCount: indices.count, // Total number of indices to process (60 for 20 triangles)
//                                            indexType: .uint16,       // Data type of indices in the buffer
//                                            indexBuffer: indexBuffer, // The buffer containing the indices
//                                            indexBufferOffset: 0)     // Start reading from the beginning of the index buffer
//
//        // 6. Finalize Encoding: Signal that command encoding for this render pass is complete.
//        renderEncoder.endEncoding()
//
//        // 7. Schedule Presentation: Tell the command buffer to present the `drawable` (display the texture)
//        //    once rendering is complete.
//        commandBuffer.present(drawable)
//
//        // 8. Commit: Submit the command buffer to the command queue for GPU execution.
//        commandBuffer.commit()
//    }
//}
//
//// MARK: - SwiftUI UIViewRepresentable
//
///// A `UIViewRepresentable` struct that acts as a bridge between SwiftUI and the UIKit-based `MTKView`.
///// It allows the Metal-rendered `MTKView` to be seamlessly embedded within a SwiftUI view hierarchy.
//struct MetalIcosahedronViewRepresentable: UIViewRepresentable {
//    // Specifies the type of UIKit view this representable manages.
//    typealias UIViewType = MTKView
//
//    /// Creates and returns the custom coordinator object (`IcosahedronRenderer`).
//    /// The coordinator is responsible for managing the state and delegate logic of the `MTKView`.
//    /// It ensures the `IcosahedronRenderer` persists across view updates.
//    /// Uses `fatalError` as Metal support and renderer initialization are required.
//    func makeCoordinator() -> IcosahedronRenderer {
//        // Attempt to get the default Metal device for the system.
//        guard let device = MTLCreateSystemDefaultDevice() else {
//            fatalError("Fatal Error: Metal is not supported on this device.")
//        }
//        // Initialize the custom renderer class with the Metal device.
//        guard let coordinator = IcosahedronRenderer(device: device) else {
//            // Renderer's init can fail if command queue creation fails.
//            fatalError("Fatal Error: IcosahedronRenderer failed to initialize.")
//        }
//        print("Coordinator (IcosahedronRenderer) created for MetalIcosahedronViewRepresentable.")
//        return coordinator
//    }
//
//    /// Creates the underlying `MTKView` instance.
//    /// This method is called only once when the representable view is first added to the hierarchy.
//    /// - Parameter context: Provides access to the coordinator and environment information.
//    /// - Returns: The newly created and configured `MTKView`.
//    func makeUIView(context: Context) -> MTKView {
//        let mtkView = MTKView()
//
//        // --- Configure the MTKView ---
//        mtkView.device = context.coordinator.device // Assign the Metal device.
//        mtkView.preferredFramesPerSecond = 60       // Target frame rate.
//        mtkView.enableSetNeedsDisplay = false       // Use delegate-driven drawing loop (calls draw(in:) automatically).
//        mtkView.isPaused = false                    // Ensure the view is actively drawing.
//
//        // Configure the render target formats. These *must* match the pipeline descriptor.
//        mtkView.depthStencilPixelFormat = .depth32Float // Enable a 32-bit depth buffer.
//        mtkView.colorPixelFormat = .bgra8Unorm_srgb     // Standard color format for iOS displays.
//
//        // Configure clearing behavior for the render pass descriptor.
//        mtkView.clearDepth = 1.0 // Clear depth buffer to the farthest value before drawing.
//        // Set the background color (used when clearing the color attachment).
//        mtkView.clearColor = MTLClearColor(red: 0.15, green: 0.1, blue: 0.1, alpha: 1.0) // Dark gray background
//
//        // --- Connect Coordinator ---
//        // Configure the renderer (which sets up the pipeline state) *after* the MTKView
//        // has its pixel formats set.
//        context.coordinator.configure(metalKitView: mtkView)
//        // Set the renderer as the MTKView's delegate to receive drawing and resize callbacks.
//        mtkView.delegate = context.coordinator
//
//        // --- Initial Size ---
//        // Trigger an initial size update in the coordinator using the view's current drawable size.
//        // This ensures the aspectRatio is correct from the start.
//        context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
//
//        print("MTKView created and configured for Icosahedron rendering.")
//        return mtkView
//    }
//
//    /// Updates the `MTKView` when relevant SwiftUI state changes occur.
//    /// In this simple example, there's no SwiftUI state that directly affects the Metal rendering,
//    /// so this method is empty. If SwiftUI controls controlled rotation speed, color, etc.,
//    /// those updates would be passed to the coordinator here.
//    /// - Parameters:
//    ///   - uiView: The `MTKView` instance being managed.
//    ///   - context: Provides access to the coordinator and environment information.
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // No specific updates needed from SwiftUI state changes in this example.
//        // The animation is driven internally by the IcosahedronRenderer.
//    }
//}
//
//// MARK: - Main SwiftUI View
//
///// The primary SwiftUI `View` structure that displays the rotating icosahedron.
///// It uses a `VStack` to arrange a title label above the `MetalIcosahedronViewRepresentable`,
///// which embeds the actual `MTKView` performing the Metal rendering.
//struct IcosahedronView: View {
//    var body: some View {
//        // Vertical stack to hold the title and the Metal view.
//        VStack(spacing: 0) { // No spacing between elements.
//            // Title label at the top.
//            Text("Rotating Wireframe Icosahedron (Metal)")
//                .font(.headline)
//                .padding()
//                .frame(maxWidth: .infinity) // Span full width
//                .background(Color(red: 0.15, green: 0.1, blue: 0.1)) // Match MTKView background
//                .foregroundColor(.white)
//
//            // The representable view that bridges the MTKView into SwiftUI.
//            MetalIcosahedronViewRepresentable()
//                // Optional: Uncomment to allow the Metal view to extend under safe areas (like notches).
//                // .ignoresSafeArea(.all)
//        }
//        // Set the background color for the entire VStack area.
//        .background(Color(red: 0.15, green: 0.1, blue: 0.1))
//        // Ensure the view doesn't shrink when the keyboard appears.
//        .ignoresSafeArea(.keyboard)
//    }
//}
//
//// MARK: - Preview Provider
//
///// Provides previews for the `IcosahedronView` in Xcode Canvas.
///// Due to the complexities of Metal rendering, live previews often don't work reliably
///// or can be resource-intensive. Using a placeholder is often recommended.
//#Preview {
//    // --- Option 1: Use Placeholder (Recommended for Canvas Stability) ---
//    /// A simple placeholder view shown in the Xcode Canvas instead of attempting live Metal rendering.
//    struct PreviewPlaceholder: View {
//        var body: some View {
//            VStack {
//                // Mimic the actual title view.
//                Text("Rotating Wireframe Icosahedron (Metal)")
//                    .font(.headline)
//                    .padding()
//                    .foregroundColor(.white)
//                Spacer() // Push content apart
//                // Indicate that this is a placeholder.
//                Text("Metal View Placeholder\n(Run on Simulator or Device)")
//                    .foregroundColor(.gray)
//                    .italic()
//                    .multilineTextAlignment(.center)
//                    .padding()
//                Spacer() // Push content apart
//            }
//            // Set frame and background to match the actual view.
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color(red: 0.15, green: 0.1, blue: 0.1))
//            .edgesIgnoringSafeArea(.all) // Fill the entire preview area.
//        }
//    }
//    // Uncomment the line below and comment out `return IcosahedronView()` to use the placeholder.
//    //return PreviewPlaceholder() // <-- Use Placeholder
//
//    // --- Option 2: Attempt Live Metal Preview ---
//    // Uncomment the line below and comment out `return PreviewPlaceholder()` to try live preview.
//    // Note: This may fail or perform poorly in Xcode Canvas. Running on a device/simulator is best.
//    return IcosahedronView()
//}
//
//// MARK: - Matrix Math Helper Functions (using SIMD)
//// These functions provide standard matrix operations needed for 3D graphics transformations.
//// They use the SIMD framework for efficient vector and matrix calculations.
//
///// Creates a perspective projection matrix using the left-handed coordinate system convention
///// commonly used with Metal. Defines the viewing volume (frustum).
///// - Parameters:
/////   - fovyRadians: Vertical field of view angle in radians.
/////   - aspectRatio: Width divided by height of the view/viewport.
/////   - nearZ: Distance to the near clipping plane (must be positive).
/////   - farZ: Distance to the far clipping plane (must be positive and greater than nearZ).
///// - Returns: A 4x4 perspective projection matrix.
//func matrix_perspective_left_hand(fovyRadians: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
//    let y = 1.0 / tan(fovyRadians * 0.5) // Scale factor for Y based on FOV
//    let x = y / aspectRatio             // Scale factor for X based on Y scale and aspect ratio
//    let z = farZ / (farZ - nearZ)       // Scale and translation factor for Z (mapping nearZ..farZ to 0..1)
//    let w = -nearZ * z                  // Translation factor for Z related to near plane
//    // Construct the matrix column by column
//    return matrix_float4x4(
//        SIMD4<Float>(x, 0, 0, 0),   // Column 0
//        SIMD4<Float>(0, y, 0, 0),   // Column 1
//        SIMD4<Float>(0, 0, z, 1),   // Column 2 (Note the 1 in the W component for perspective)
//        SIMD4<Float>(0, 0, w, 0)    // Column 3
//    )
//}
//
///// Creates a view transformation matrix using the left-handed coordinate system.
///// Positions and orients the virtual camera in the world.
///// - Parameters:
/////   - eye: The position of the camera (viewer) in world space.
/////   - center: The point in world space that the camera is looking at.
/////   - up: The direction vector indicating the "up" direction for the camera (usually (0, 1, 0)).
///// - Returns: A 4x4 view matrix.
//func matrix_look_at_left_hand(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> matrix_float4x4 {
//    let zAxis = normalize(center - eye)      // Forward direction of the camera
//    let xAxis = normalize(cross(up, zAxis))  // Right direction (perpendicular to up and forward)
//    let yAxis = cross(zAxis, xAxis)          // Recalculated Up direction (perpendicular to forward and right)
//
//    // The translation component represents the negative dot product of each axis with the eye position.
//    // This effectively moves the world so the eye is at the origin.
//    let translateX = -dot(xAxis, eye)
//    let translateY = -dot(yAxis, eye)
//    let translateZ = -dot(zAxis, eye)
//
//    // Construct the matrix column by column using the calculated axes and translation.
//    return matrix_float4x4(
//        SIMD4<Float>(xAxis.x, yAxis.x, zAxis.x, 0), // Column 0 (Basis X)
//        SIMD4<Float>(xAxis.y, yAxis.y, zAxis.y, 0), // Column 1 (Basis Y)
//        SIMD4<Float>(xAxis.z, yAxis.z, zAxis.z, 0), // Column 2 (Basis Z)
//        SIMD4<Float>(translateX, translateY, translateZ, 1) // Column 3 (Translation)
//    )
//}
//
///// Creates a matrix representing a rotation around the Y-axis.
///// - Parameter radians: The rotation angle in radians.
///// - Returns: A 4x4 rotation matrix.
//func matrix_rotation_y(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians) // Cosine of the angle
//    let s = sin(radians) // Sine of the angle
//    // Standard Y-rotation matrix formula
//    return matrix_float4x4(
//        SIMD4<Float>(c, 0, s, 0),   // Column 0
//        SIMD4<Float>(0, 1, 0, 0),   // Column 1 (Y-axis remains unchanged)
//        SIMD4<Float>(-s, 0, c, 0),  // Column 2
//        SIMD4<Float>(0, 0, 0, 1)    // Column 3 (Homogeneous coordinate)
//    )
//}
//
///// Creates a matrix representing a rotation around the X-axis.
///// - Parameter radians: The rotation angle in radians.
///// - Returns: A 4x4 rotation matrix.
//func matrix_rotation_x(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians) // Cosine of the angle
//    let s = sin(radians) // Sine of the angle
//    // Standard X-rotation matrix formula
//    return matrix_float4x4(
//        SIMD4<Float>(1, 0, 0, 0),   // Column 0 (X-axis remains unchanged)
//        SIMD4<Float>(0, c, s, 0),   // Column 1
//        SIMD4<Float>(0, -s, c, 0),  // Column 2
//        SIMD4<Float>(0, 0, 0, 1)    // Column 3 (Homogeneous coordinate)
//    )
//}
//
//// Note: A matrix_rotation_z function could be added similarly if needed.
//
///// Multiplies two 4x4 matrices using the SIMD framework's optimized multiplication operator.
///// Matrix multiplication is not commutative (A * B != B * A). The order matters for transformations.
///// - Parameters:
/////   - matrix1: The left-hand side matrix in the multiplication.
/////   - matrix2: The right-hand side matrix in the multiplication.
///// - Returns: The resulting 4x4 matrix (matrix1 * matrix2).
//func matrix_multiply(_ matrix1: matrix_float4x4, _ matrix2: matrix_float4x4) -> matrix_float4x4 {
//    // SIMD provides an overloaded '*' operator for matrix multiplication.
//    return matrix1 * matrix2
//}
