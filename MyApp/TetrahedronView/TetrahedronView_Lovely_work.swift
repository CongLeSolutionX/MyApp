////
////  TetrahedronView.swift
////  MyApp
////
////  Created by Cong Le on 5/3/25.
////
//
////  Description:
////  This file defines a SwiftUI view hierarchy that displays a 3D rotating
////  wireframe tetrahedron rendered using Apple's Metal framework. It adapts the
////  Octahedron example, demonstrating:
////  - Embedding MTKView in SwiftUI via UIViewRepresentable.
////  - Basic Metal pipeline setup (shaders, buffers, states).
////  - Defining geometry (vertices, indices) for a TETRAHEDRON.
////  - SIMD matrix transformations (Model-View-Projection).
////  - Animation via per-frame rotation.
////  - Depth testing.
////  - Wireframe rendering.
////
//import SwiftUI
//import MetalKit // Provides MTKView and Metal integration helpers
//import simd    // Provides efficient vector and matrix types/operations
//
//// MARK: - Metal Shaders (Embedded String)
//
///// Contains the source code for the Metal vertex and fragment shaders.
///// These shaders run on the GPU to process vertices and determine pixel colors.
//let tetrahedronMetalShaderSource = """
//#include <metal_stdlib> // Import the Metal Standard Library
//
//using namespace metal; // Use the Metal namespace
//
//// Structure defining vertex input data received from the CPU (Swift code).
//// Must match 'TetrahedronVertex' struct in Swift and the MTLVertexDescriptor.
//struct VertexIn {
//    float3 position [[attribute(0)]]; // Vertex position in model space
//    float4 color    [[attribute(1)]]; // Vertex color (RGBA)
//};
//
//// Structure defining data passed from the vertex shader to the fragment shader.
//// Values are interpolated across the primitive surface.
//struct VertexOut {
//    float4 position [[position]]; // Final position in clip space (REQUIRED)
//    float4 color;               // Interpolated color for fragment shader
//};
//
//// Structure for uniform data (constants for a draw call) passed from the CPU.
//// Must match the 'Uniforms' struct layout in Swift.
//struct Uniforms {
//    float4x4 modelViewProjectionMatrix; // Combined transformation matrix
//};
//
//// --- Vertex Shader ---
//// Executed for each vertex. Transforms position and passes color.
//vertex VertexOut tetrahedron_vertex_shader(
//    const device VertexIn *vertices [[buffer(0)]], // From vertex buffer
//    const device Uniforms &uniforms [[buffer(1)]], // From uniform buffer
//    unsigned int vid [[vertex_id]]                 // System-provided vertex index
//) {
//    VertexOut out;
//    VertexIn currentVertex = vertices[vid];
//    
//    // Transform position to clip space using the MVP matrix
//    out.position = uniforms.modelViewProjectionMatrix * float4(currentVertex.position, 1.0);
//    
//    // Pass color through (to be interpolated)
//    out.color = currentVertex.color;
//    
//    return out;
//}
//
//// --- Fragment Shader ---
//// Executed for each pixel fragment. Determines the final pixel color.
//fragment half4 tetrahedron_fragment_shader(
//    VertexOut in [[stage_in]] // Interpolated data from vertex shader
//) {
//    // Simply return the interpolated color.
//    return half4(in.color);
//}
//"""
//
//// MARK: - Swift Data Structures (Matching Shaders)
//
///// Swift structure mirroring the 'Uniforms' struct in the Metal shader code.
//struct Uniforms {
//    var modelViewProjectionMatrix: matrix_float4x4
//}
//
///// Structure defining the layout of vertex data in Swift.
///// Must match the `VertexIn` struct in the shader and the `MTLVertexDescriptor`.
//struct TetrahedronVertex {
//    var position: SIMD3<Float> // (x, y, z)
//    var color: SIMD4<Float>    // (r, g, b, a)
//}
//
//// MARK: - Renderer Class (Handles Metal Logic)
//
///// Manages Metal setup, resources, and rendering for the Tetrahedron.
///// Conforms to `MTKViewDelegate`.
//class TetrahedronRenderer: NSObject, MTKViewDelegate {
//
//    let device: MTLDevice
//    let commandQueue: MTLCommandQueue
//    var pipelineState: MTLRenderPipelineState!
//    var depthState: MTLDepthStencilState!
//
//    var vertexBuffer: MTLBuffer!
//    var indexBuffer: MTLBuffer!
//    var uniformBuffer: MTLBuffer!
//
//    var rotationAngle: Float = 0.0
//    var aspectRatio: Float = 1.0
//
//    // --- TETRAHEDRON Geometry Data ---
//    
//    /// Array defining the 4 vertices of the tetrahedron.
//    let vertices: [TetrahedronVertex] = [
//        // Using coordinates that form a regular tetrahedron centered loosely around origin.
//        // Vertex Format: TetrahedronVertex(position: SIMD3<Float>(x, y, z), color: SIMD4<Float>(r, g, b, a))
//        
//        // Tip Vertex (adjust Y for desired height)
//        TetrahedronVertex(position: SIMD3<Float>( 0.0,    0.707,  0.0   ), color: SIMD4<Float>(1, 0, 0, 1)), // Index 0: Top (Red)
//        
//        // Base Vertices (forming an equilateral triangle in a lower plane)
//        TetrahedronVertex(position: SIMD3<Float>( 0.0,   -0.353,  0.816), color: SIMD4<Float>(0, 1, 0, 1)), // Index 1: Base Front (Green)
//        TetrahedronVertex(position: SIMD3<Float>( 0.943, -0.353, -0.408), color: SIMD4<Float>(0, 0, 1, 1)), // Index 2: Base Right (Blue)
//        TetrahedronVertex(position: SIMD3<Float>(-0.943, -0.353, -0.408), color: SIMD4<Float>(1, 1, 0, 1)), // Index 3: Base Left (Yellow)
//    ]
//
//    /// Array of indices defining the 4 triangular faces of the tetrahedron.
//    /// Each sequence of 3 indices references `vertices` to form a triangle.
//    /// Winding Order: Counter-clockwise when viewed from the outside.
//    let indices: [UInt16] = [
//        // Face 1: Side (connecting Top '0' to Base '1'-'2')
//        0, 1, 2,
//        
//        // Face 2: Side (connecting Top '0' to Base '2'-'3')
//        0, 2, 3,
//        
//        // Face 3: Side (connecting Top '0' to Base '3'-'1')
//        0, 3, 1,
//        
//        // Face 4: Bottom (connecting Base vertices '1'-'2'-'3')
//        // Ensure CCW winding when viewed from *below* (or reverse if needed)
//        1, 3, 2 // Viewing from below, 1 -> 3 -> 2 should be CCW
//    ]
//    // --- End Geometry Data ---
//    
//    /// Initializes the renderer, command queue, buffers, and depth state.
//    init?(device: MTLDevice) {
//        self.device = device
//        guard let queue = device.makeCommandQueue() else {
//            print("Could not create command queue")
//            return nil
//        }
//        self.commandQueue = queue
//        super.init()
//        
//        setupBuffers()        // Create geometry and uniform buffers
//        setupDepthStencil()   // Configure depth testing
//    }
//
//    /// Configures the Metal render pipeline state (called after MTKView setup).
//    func configure(metalKitView: MTKView) {
//        setupPipeline(metalKitView: metalKitView)
//    }
//
//    // --- Setup Functions ---
//
//    /// Compiles shaders and creates the `MTLRenderPipelineState`.
//    func setupPipeline(metalKitView: MTKView) {
//        do {
//            let library = try device.makeLibrary(source: tetrahedronMetalShaderSource, options: nil)
//            guard let vertexFunction = library.makeFunction(name: "tetrahedron_vertex_shader"),
//                  let fragmentFunction = library.makeFunction(name: "tetrahedron_fragment_shader") else {
//                fatalError("Could not load shader functions from library. Check names.")
//            }
//
//            let pipelineDescriptor = MTLRenderPipelineDescriptor()
//            pipelineDescriptor.label = "Wireframe Tetrahedron Pipeline"
//            pipelineDescriptor.vertexFunction = vertexFunction
//            pipelineDescriptor.fragmentFunction = fragmentFunction
//            pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
//            pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
//
//            // Vertex Descriptor: Describes the memory layout of `TetrahedronVertex`.
//            // This remains the same structure as OctahedronVertex (pos, color).
//            let vertexDescriptor = MTLVertexDescriptor()
//            // Position (float3)
//            vertexDescriptor.attributes[0].format = .float3
//            vertexDescriptor.attributes[0].offset = 0
//            vertexDescriptor.attributes[0].bufferIndex = 0
//            // Color (float4)
//            vertexDescriptor.attributes[1].format = .float4
//            vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
//            vertexDescriptor.attributes[1].bufferIndex = 0
//            // Overall layout stride
//            vertexDescriptor.layouts[0].stride = MemoryLayout<TetrahedronVertex>.stride
//            vertexDescriptor.layouts[0].stepRate = 1
//            vertexDescriptor.layouts[0].stepFunction = .perVertex
//
//            pipelineDescriptor.vertexDescriptor = vertexDescriptor
//
//            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//
//        } catch {
//            fatalError("Failed to create Metal Render Pipeline State: \(error)")
//        }
//    }
//
//    /// Creates and populates GPU buffers for vertices, indices, and uniforms.
//    /// Size calculations adapt automatically to the `vertices` and `indices` counts.
//    func setupBuffers() {
//        // Vertex Buffer
//        let vertexDataSize = vertices.count * MemoryLayout<TetrahedronVertex>.stride
//        guard let vBuffer = device.makeBuffer(bytes: vertices, length: vertexDataSize, options: []) else {
//            fatalError("Could not create vertex buffer for Tetrahedron")
//        }
//        vertexBuffer = vBuffer
//        vertexBuffer.label = "Tetrahedron Vertices"
//
//        // Index Buffer
//        let indexDataSize = indices.count * MemoryLayout<UInt16>.stride
//        guard let iBuffer = device.makeBuffer(bytes: indices, length: indexDataSize, options: []) else {
//            fatalError("Could not create index buffer for Tetrahedron")
//        }
//        indexBuffer = iBuffer
//        indexBuffer.label = "Tetrahedron Indices"
//
//        // Uniform Buffer (for MVP matrix)
//        let uniformBufferSize = MemoryLayout<Uniforms>.stride // Use stride for alignment safety
//        guard let uBuffer = device.makeBuffer(length: uniformBufferSize, options: .storageModeShared) else {
//            fatalError("Could not create uniform buffer")
//        }
//        uniformBuffer = uBuffer
//        uniformBuffer.label = "Uniforms Buffer (MVP - Tetrahedron)"
//    }
//
//    /// Creates the depth testing state.
//    func setupDepthStencil() {
//        let depthDescriptor = MTLDepthStencilDescriptor()
//        depthDescriptor.depthCompareFunction = .less
//        depthDescriptor.isDepthWriteEnabled = true
//        guard let state = device.makeDepthStencilState(descriptor: depthDescriptor) else {
//            fatalError("Failed to create depth stencil state")
//        }
//        depthState = state
//    }
//
//    // --- Update State Per Frame ---
//    
//    /// Calculates the MVP matrix and updates the uniform buffer each frame.
//    func updateUniforms() {
//        let projectionMatrix = matrix_perspective_left_hand(
//            fovyRadians: .pi / 3.0,
//            aspectRatio: aspectRatio,
//            nearZ: 0.1,
//            farZ: 100.0
//        )
//
//        let viewMatrix = matrix_look_at_left_hand(
//            eye: SIMD3<Float>(0, 0.5, -4), // Camera position
//            center: SIMD3<Float>(0, 0, 0), // Look at origin
//            up: SIMD3<Float>(0, 1, 0)      // Up direction
//        )
//
//        // Apply rotation for animation
//        let rotationY = matrix_rotation_y(radians: rotationAngle)
//        let rotationX = matrix_rotation_x(radians: rotationAngle * 0.5) // Slightly different rotation on X
//        let modelMatrix = matrix_multiply(rotationY, rotationX)
//
//        // Combine: P * V * M
//        let modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix)
//        let mvpMatrix = matrix_multiply(projectionMatrix, modelViewMatrix)
//        
//        // Upload to buffer
//        var uniforms = Uniforms(modelViewProjectionMatrix: mvpMatrix)
//        uniformBuffer.contents().copyMemory(from: &uniforms, byteCount: MemoryLayout<Uniforms>.stride)
//        
//        // Increment angle for next frame
//        rotationAngle += 0.01
//    }
//
//    // MARK: - MTKViewDelegate Methods
//
//    /// Updates the aspect ratio when the view size changes.
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        aspectRatio = Float(size.width / max(1, size.height))
//        print("TetrahedronView Resized - New Aspect Ratio: \(aspectRatio)")
//    }
//
//    /// Encodes rendering commands for the current frame.
//    func draw(in view: MTKView) {
//        guard let drawable = view.currentDrawable,
//              let renderPassDescriptor = view.currentRenderPassDescriptor,
//              let commandBuffer = commandQueue.makeCommandBuffer(),
//              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
//            print("Metal setup failed in tetrahedron draw(in:). Skipping frame.")
//            return
//        }
//
//        // Update dynamic data (MVP matrix)
//        updateUniforms()
//
//        // --- Configure Encoder ---
//        renderEncoder.label = "Tetrahedron Render Encoder"
//        renderEncoder.setRenderPipelineState(pipelineState) // Use the pre-compiled pipeline
//        renderEncoder.setDepthStencilState(depthState)     // Enable depth testing
//
//        // *** Set Render Mode to Wireframe ***
//        renderEncoder.setTriangleFillMode(.lines)
//
//        // --- Bind Buffers ---
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0) // VertexIn at [[buffer(0)]]
//        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1) // Uniforms at [[buffer(1)]]
//
//        // --- Issue Draw Call ---
//        // Uses the current 'indices' count automatically.
//        renderEncoder.drawIndexedPrimitives(type: .triangle,
//                                            indexCount: indices.count, // Will be 12 for the tetrahedron
//                                            indexType: .uint16,
//                                            indexBuffer: indexBuffer,
//                                            indexBufferOffset: 0)
//
//        // --- Finalize ---
//        renderEncoder.endEncoding() // Finish encoding commands for this pass
//        commandBuffer.present(drawable) // Schedule presentation
//        commandBuffer.commit() // Send commands to GPU
//    }
//}
//
//// MARK: - SwiftUI UIViewRepresentable
//
///// Bridges `MTKView` into the SwiftUI view hierarchy for Tetrahedron rendering.
//struct MetalTetrahedronViewRepresentable: UIViewRepresentable {
//    typealias UIViewType = MTKView
//
//    /// Creates the `TetrahedronRenderer` (Coordinator).
//    func makeCoordinator() -> TetrahedronRenderer {
//        guard let device = MTLCreateSystemDefaultDevice() else {
//            fatalError("Metal is not supported on this device.")
//        }
//        guard let coordinator = TetrahedronRenderer(device: device) else {
//            fatalError("TetrahedronRenderer failed to initialize.")
//        }
//        print("Coordinator (TetrahedronRenderer) created.")
//        return coordinator
//    }
//
//    /// Creates and configures the underlying `MTKView`.
//    func makeUIView(context: Context) -> MTKView {
//        let mtkView = MTKView()
//        mtkView.device = context.coordinator.device
//        mtkView.preferredFramesPerSecond = 60
//        mtkView.enableSetNeedsDisplay = false // Use delegate draw method
//        mtkView.depthStencilPixelFormat = .depth32Float // Request depth buffer
//        mtkView.clearDepth = 1.0
//        mtkView.clearColor = MTLClearColor(red: 0.1, green: 0.15, blue: 0.1, alpha: 1.0) // Slightly different BG color
//        mtkView.colorPixelFormat = .bgra8Unorm_srgb // Standard color format
//
//        // Let renderer setup pipeline based on view's formats
//        context.coordinator.configure(metalKitView: mtkView)
//        
//        // Set delegate AFTER configuration
//        mtkView.delegate = context.coordinator
//
//        // Trigger initial size update
//        context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
//        
//        print("MTKView created and configured for Tetrahedron.")
//        return mtkView
//    }
//
//    /// Updates the `MTKView` based on SwiftUI state changes (not used here).
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // No-op for this example
//    }
//}
//
//// MARK: - Main SwiftUI View
//
///// The SwiftUI view containing the title and the Metal view container.
//struct TetrahedronView: View {
//    var body: some View {
//        VStack(spacing: 0) {
//            Text("Rotating Wireframe Tetrahedron (Metal)")
//                .font(.headline)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color(red: 0.1, green: 0.15, blue: 0.1)) // Match MTKView clear color
//                .foregroundColor(.white)
//
//            // Embed the Metal view
//            MetalTetrahedronViewRepresentable()
//                // .ignoresSafeArea() // Optional: Extend into safe areas
//        }
//        .background(Color(red: 0.1, green: 0.15, blue: 0.1))
//        .ignoresSafeArea(.keyboard)
//    }
//}
//
//// MARK: - Preview Provider
//
//#Preview {
//    // Option 1: Use a Placeholder View (Safer for Previews)
//    struct PreviewPlaceholder: View {
//        var body: some View {
//            VStack {
//                Text("Rotating Wireframe Tetrahedron (Metal)")
//                    .font(.headline).padding().foregroundColor(.white)
//                Spacer()
//                Text("Metal View Placeholder\n(Run on Simulator or Device)")
//                    .foregroundColor(.gray).italic().multilineTextAlignment(.center).padding()
//                Spacer()
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color(red: 0.1, green: 0.15, blue: 0.1)) // Match expected BG
//            .edgesIgnoringSafeArea(.all)
//        }
//    }
//    //return PreviewPlaceholder() // Default to placeholder
//
//    // Option 2: Attempt to Render the Actual Metal View (May Fail in Preview)
//    return TetrahedronView() // Uncomment this line and comment placeholder to try
//}
//
//// MARK: - Matrix Math Helper Functions (using SIMD - Left-Handed)
//// (Copied verbatim from Octahedron example, as they are generic)
//
///// Creates a perspective projection matrix (Left-Handed).
//func matrix_perspective_left_hand(fovyRadians: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
//    let y = 1.0 / tan(fovyRadians * 0.5)
//    let x = y / aspectRatio
//    let z = farZ / (farZ - nearZ)
//    let w = -nearZ * z
//    return matrix_float4x4(
//        SIMD4<Float>(x, 0, 0, 0), SIMD4<Float>(0, y, 0, 0), SIMD4<Float>(0, 0, z, 1), SIMD4<Float>(0, 0, w, 0)
//    )
//}
//
///// Creates a view matrix (Left-Handed) to position and orient the camera.
//func matrix_look_at_left_hand(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> matrix_float4x4 {
//    let zAxis = normalize(center - eye)
//    let xAxis = normalize(cross(up, zAxis))
//    let yAxis = cross(zAxis, xAxis)
//    let translateX = -dot(xAxis, eye)
//    let translateY = -dot(yAxis, eye)
//    let translateZ = -dot(zAxis, eye)
//    return matrix_float4x4(
//        SIMD4<Float>( xAxis.x,  yAxis.x,  zAxis.x, 0),
//        SIMD4<Float>( xAxis.y,  yAxis.y,  zAxis.y, 0),
//        SIMD4<Float>( xAxis.z,  yAxis.z,  zAxis.z, 0),
//        SIMD4<Float>(translateX, translateY, translateZ, 1)
//    )
//}
//
///// Creates a rotation matrix for rotation around the Y-axis.
//func matrix_rotation_y(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians); let s = sin(radians)
//    return matrix_float4x4(
//        SIMD4<Float>( c, 0, s, 0), SIMD4<Float>( 0, 1, 0, 0), SIMD4<Float>(-s, 0, c, 0), SIMD4<Float>( 0, 0, 0, 1)
//    )
//}
//
///// Creates a rotation matrix for rotation around the X-axis.
//func matrix_rotation_x(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians); let s = sin(radians)
//    return matrix_float4x4(
//        SIMD4<Float>(1,  0, 0, 0), SIMD4<Float>(0,  c, s, 0), SIMD4<Float>(0, -s, c, 0), SIMD4<Float>(0,  0, 0, 1)
//    )
//}
//
///// Multiplies two 4x4 matrices using SIMD's overloaded operator.
//func matrix_multiply(_ matrix1: matrix_float4x4, _ matrix2: matrix_float4x4) -> matrix_float4x4 {
//    return matrix1 * matrix2
//}
