////
////  OctahedronView.swift
////  MyApp
////
////  Created by Cong Le on 5/3/25.
////
//
//import SwiftUI
//import MetalKit
//import simd // For matrix math
//
//// MARK: - Metal Shaders (Embedded String)
//
//let octahedronMetalShaderSource = """
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
//"""
//
//// MARK: - Vertex Data Structure (Swift & Metal Compatible)
//// Swift struct mirroring the layout of the 'Uniforms' struct in the shader
//struct Uniforms {
//    var modelViewProjectionMatrix: matrix_float4x4 // Use the simd alias matrix_float4x4
//}
//struct OctahedronVertex {
//    var position: SIMD3<Float>
//    var color: SIMD4<Float> // RGBA
//}
//
//// MARK: - Renderer Class (Handles Metal Logic)
//
//class OctahedronRenderer: NSObject, MTKViewDelegate {
//    let device: MTLDevice
//    let commandQueue: MTLCommandQueue
//    var pipelineState: MTLRenderPipelineState!
//    var depthState: MTLDepthStencilState! // For correct 3D rendering
//
//    var vertexBuffer: MTLBuffer!
//    var indexBuffer: MTLBuffer! // We'll use indices for triangles
//    var uniformBuffer: MTLBuffer!
//
//    var rotationAngle: Float = 0.0
//    var aspectRatio: Float = 1.0
//
//    // Octahedron vertex coordinates (Top/Bottom apex approach)
//    // Top: (0, 1, 0), Bottom: (0, -1, 0)
//    // Mid: (1, 0, 0), (-1, 0, 0), (0, 0, 1), (0, 0, -1)
//    let vertices: [OctahedronVertex] = [
//        // Top Apex (Y=1) - Green
//        OctahedronVertex(position: SIMD3<Float>(0, 1, 0), color: SIMD4<Float>(0, 1, 0, 1)), // 0: Top
//        // Mid Vertices (Y=0 Plane) - Red, Blue, Yellow, Cyan
//        OctahedronVertex(position: SIMD3<Float>(1, 0, 0), color: SIMD4<Float>(1, 0, 0, 1)), // 1: +X
//        OctahedronVertex(position: SIMD3<Float>(0, 0, 1), color: SIMD4<Float>(0, 0, 1, 1)), // 2: +Z
//        OctahedronVertex(position: SIMD3<Float>(-1, 0, 0), color: SIMD4<Float>(1, 1, 0, 1)),// 3: -X
//        OctahedronVertex(position: SIMD3<Float>(0, 0, -1), color: SIMD4<Float>(0, 1, 1, 1)),// 4: -Z
//        // Bottom Apex (Y=-1) - Magenta
//        OctahedronVertex(position: SIMD3<Float>(0, -1, 0), color: SIMD4<Float>(1, 0, 1, 1)) // 5: Bottom
//    ]
//
//    // Indices defining the 8 triangular faces (12 edges are part of these triangles)
//    let indices: [UInt16] = [
//        // Top pyramid faces (winding: counter-clockwise when viewed from outside)
//        0, 1, 2, // Top, +X, +Z
//        0, 2, 3, // Top, +Z, -X
//        0, 3, 4, // Top, -X, -Z
//        0, 4, 1, // Top, -Z, +X
//
//        // Bottom pyramid faces (winding: counter-clockwise when viewed from outside)
//        5, 2, 1, // Bottom, +Z, +X
//        5, 3, 2, // Bottom, -X, +Z
//        5, 4, 3, // Bottom, -Z, -X
//        5, 1, 4  // Bottom, +X, -Z
//    ]
//
//    init?(metalKitView: MTKView) {
//        guard let device = MTLCreateSystemDefaultDevice(),
//              let queue = device.makeCommandQueue() else {
//            print("Metal is not supported on this device")
//            return nil
//        }
//        self.device = device
//        self.commandQueue = queue
//        metalKitView.device = device
//
//        super.init()
//
//        setupPipeline(metalKitView: metalKitView)
//        setupBuffers()
//        setupDepthStencil()
//    }
//
//    // --- Setup Functions ---
//
//    func setupPipeline(metalKitView: MTKView) {
//        do {
//            // Compile shaders from string at runtime
//            let library = try device.makeLibrary(source: octahedronMetalShaderSource, options: nil)
//            guard let vertexFunction = library.makeFunction(name: "octahedron_vertex_shader"),
//                  let fragmentFunction = library.makeFunction(name: "octahedron_fragment_shader") else {
//                fatalError("Could not load shader functions")
//            }
//
//            // Configure pipeline descriptor
//            let pipelineDescriptor = MTLRenderPipelineDescriptor()
//            pipelineDescriptor.label = "Octahedron Pipeline"
//            pipelineDescriptor.vertexFunction = vertexFunction
//            pipelineDescriptor.fragmentFunction = fragmentFunction
//            pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
//            pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat // Important for depth testing
//
//            // Define vertex data layout for the shader
//            let vertexDescriptor = MTLVertexDescriptor()
//            vertexDescriptor.attributes[0].format = .float3 // position
//            vertexDescriptor.attributes[0].offset = 0
//            vertexDescriptor.attributes[0].bufferIndex = 0
//            vertexDescriptor.attributes[1].format = .float4 // color
//            vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
//            vertexDescriptor.attributes[1].bufferIndex = 0
//            vertexDescriptor.layouts[0].stride = MemoryLayout<OctahedronVertex>.stride
//            vertexDescriptor.layouts[0].stepRate = 1
//            vertexDescriptor.layouts[0].stepFunction = .perVertex
//            pipelineDescriptor.vertexDescriptor = vertexDescriptor
//
//            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//
//        } catch {
//            fatalError("Failed to create Metal pipeline state: \(error)")
//        }
//    }
//
//    func setupBuffers() {
//        let vertexDataSize = vertices.count * MemoryLayout<OctahedronVertex>.stride
//        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertexDataSize, options: [])
//
//        let indexDataSize = indices.count * MemoryLayout<UInt16>.stride
//        indexBuffer = device.makeBuffer(bytes: indices, length: indexDataSize, options: [])
//
//        // Buffer for uniform data (MVP matrix)
//        // Use either the Swift Uniforms struct size OR the underlying matrix size
//        // let uniformBufferSize = MemoryLayout<Uniforms>.size // Using the new struct
//        // OR more directly:
//        let uniformBufferSize = MemoryLayout<matrix_float4x4>.size // Size of one 4x4 matrix
//        uniformBuffer = device.makeBuffer(length: uniformBufferSize, options: .storageModeShared)
//    }
//
//     func setupDepthStencil() {
//        let depthDescriptor = MTLDepthStencilDescriptor()
//        depthDescriptor.depthCompareFunction = .less // Standard depth test
//        depthDescriptor.isDepthWriteEnabled = true   // Write depth values
//        guard let state = device.makeDepthStencilState(descriptor: depthDescriptor) else {
//            fatalError("Failed to create depth stencil state")
//        }
//        depthState = state
//    }
//
//    // --- Update Uniforms ---
//     func updateUniforms() {
//        // Calculate Model-View-Projection matrix
//        let projectionMatrix = matrix_perspective_left_hand(fovyRadians: Float.pi / 3.0, // 60 degree field of view
//                                                             aspectRatio: aspectRatio,
//                                                             nearZ: 0.1,
//                                                             farZ: 100.0)
//
//        let viewMatrix = matrix_look_at_left_hand(eye: SIMD3<Float>(0, 0, -4), // Camera position
//                                                  center: SIMD3<Float>(0, 0, 0), // Look at origin
//                                                  up: SIMD3<Float>(0, 1, 0))    // Y-axis is up
//
//        let modelMatrix = matrix_multiply(matrix_rotation_y(radians: rotationAngle),
//                                          matrix_rotation_x(radians: rotationAngle * 0.5)) // Rotate around Y and slightly X
//
//        let modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix)
//        let mvpMatrix = matrix_multiply(projectionMatrix, modelViewMatrix)
//
//         // Copy the MVP matrix into the uniform buffer
//         let bufferPointer = uniformBuffer.contents()
//         // Create an instance of the *Swift* Uniforms struct
//         var uniforms = Uniforms(modelViewProjectionMatrix: mvpMatrix)
//         // Copy the *Swift* struct instance into the buffer
//         memcpy(bufferPointer, &uniforms, MemoryLayout<Uniforms>.size) // Use size of the Swift struct here
//
//        // Update rotation for the next frame
//        rotationAngle += 0.005 // Adjust speed as needed
//    }
//
//    // MARK: - MTKViewDelegate Methods
//
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        // Handle view resize
//        aspectRatio = Float(size.width / max(1, size.height)) // Avoid division by zero
//    }
//
//    func draw(in view: MTKView) {
//        guard let drawable = view.currentDrawable,
//              let renderPassDescriptor = view.currentRenderPassDescriptor,
//              let commandBuffer = commandQueue.makeCommandBuffer(),
//              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
//            return
//        }
//
//        // Update dynamic data (MVP matrix)
//        updateUniforms()
//
//        // Configure Render Encoder
//        renderEncoder.label = "Octahedron Render Encoder"
//        renderEncoder.setRenderPipelineState(pipelineState)
//        renderEncoder.setDepthStencilState(depthState) // Enable depth testing
//
//        // ----- *** Set Fill Mode to Wireframe *** -----
//        renderEncoder.setTriangleFillMode(.lines)
//        // --------------------------------------------
//
//        // Set Buffers
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1) // Bind uniform buffer
//
//        // Draw the indexed triangles (which will render as lines due to fill mode)
//        renderEncoder.drawIndexedPrimitives(type: .triangle, // Base primitive is triangle
//                                            indexCount: indices.count,
//                                            indexType: .uint16, // Matches our index array type
//                                            indexBuffer: indexBuffer,
//                                            indexBufferOffset: 0)
//
//        // Finish encoding and commit
//        renderEncoder.endEncoding()
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
//}
//
//// MARK: - SwiftUI View Representable
//
//struct MetalOctahedronViewRepresentable: UIViewRepresentable {
//    // Non-State properties can be passed via init if needed
//    typealias UIViewType = MTKView
//
//    func makeCoordinator() -> OctahedronRenderer {
//        guard let coordinator = OctahedronRenderer(metalKitView: MTKView()) else {
//            fatalError("Failed to create OctahedronRenderer Coordinator")
//        }
//        return coordinator
//    }
//
//    func makeUIView(context: Context) -> MTKView {
//        let mtkView = MTKView()
//        mtkView.delegate = context.coordinator
//        mtkView.preferredFramesPerSecond = 60
//        mtkView.enableSetNeedsDisplay = false // Use internal timer (delegate draw func)
//
//        // Crucial for 3D: Enable depth buffer
//        mtkView.depthStencilPixelFormat = .depth32Float
//        mtkView.clearDepth = 1.0 // Clear depth buffer to the farthest value
//
//        // Standard setup
//        mtkView.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0) // Dark background
//        mtkView.colorPixelFormat = .bgra8Unorm_srgb // Standard color format
//
//        // Initialize renderer with this view AFTER the view is configured
//        guard let renderer = OctahedronRenderer(metalKitView: mtkView) else {
//             fatalError("Renderer could not be initialized with MTKView")
//        }
//        context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize) // Initial aspect ratio setup
//        mtkView.delegate = renderer // Re-assign delegate after renderer is fully init
//
//        // Store the renderer in the coordinator
//        // (Coordinator already holds the reference implicitly via delegate assignment,
//        // but explicitly ensuring access if needed later)
//        // context.coordinator = renderer  <-- This is done in makeCoordinator
//
//        return mtkView
//    }
//
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // Pass down any state changes from SwiftUI to the Renderer if needed
//        // For constant rotation, we don't need updates here.
//        // Example: context.coordinator.rotationSpeed = self.swiftUIRotationSpeedState
//    }
//}
//
//// MARK: - Main SwiftUI View
//
//struct OctahedronView: View {
//    var body: some View {
//        VStack {
//            Text("Rotating Wireframe Octahedron (Metal)")
//                .font(.headline)
//                .padding(.top)
//
//            MetalOctahedronViewRepresentable()
//                .edgesIgnoringSafeArea(.all) // Let the Metal view fill available space
//        }
//         .background(Color(red: 0.1, green: 0.1, blue: 0.15)) // Match Metal clear color roughly
//         .colorScheme(.dark) // Ensure text is visible if background fails
//    }
//}
//
//// MARK: - Preview Provider
//
//#Preview {
//    OctahedronView()
//}
//
//// MARK: - Matrix Math Helper Functions (simd)
//
//// Creates a perspective projection matrix (Left-Handed coordinate system)
//func matrix_perspective_left_hand(fovyRadians: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
//    let y = 1.0 / tan(fovyRadians * 0.5)
//    let x = y / aspectRatio
//    let z = farZ / (farZ - nearZ) // Corrected for LH
//    let w = -nearZ * z           // Corrected for LH
//
//    return matrix_float4x4(
//        SIMD4<Float>(x, 0, 0, 0),
//        SIMD4<Float>(0, y, 0, 0),
//        SIMD4<Float>(0, 0, z, 1), // Z and W mapping for LH perspective
//        SIMD4<Float>(0, 0, w, 0)
//    )
//}
//
//// Creates a view matrix (Left-Handed coordinate system)
//func matrix_look_at_left_hand(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> matrix_float4x4 {
//    let z = normalize(center - eye)
//    let x = normalize(cross(up, z))
//    let y = cross(z, x)
//    let t = SIMD3<Float>(-dot(x, eye), -dot(y, eye), -dot(z, eye))
//
//    return matrix_float4x4(
//        SIMD4<Float>(x.x, y.x, z.x, 0),
//        SIMD4<Float>(x.y, y.y, z.y, 0),
//        SIMD4<Float>(x.z, y.z, z.z, 0),
//        SIMD4<Float>(t.x, t.y, t.z, 1)
//   )
//}
//
//// Creates a Y-axis rotation matrix
//func matrix_rotation_y(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians)
//    let s = sin(radians)
//    return matrix_float4x4(
//        SIMD4<Float>( c, 0, s, 0),
//        SIMD4<Float>( 0, 1, 0, 0),
//        SIMD4<Float>(-s, 0, c, 0),
//        SIMD4<Float>( 0, 0, 0, 1)
//    )
//}
//
//// Creates an X-axis rotation matrix
//func matrix_rotation_x(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians)
//    let s = sin(radians)
//    return matrix_float4x4(
//        SIMD4<Float>(1,  0, 0, 0),
//        SIMD4<Float>(0,  c, s, 0),
//        SIMD4<Float>(0, -s, c, 0),
//        SIMD4<Float>(0,  0, 0, 1)
//    )
//}
//
//// Helper for matrix multiplication if needed (though simd provides `*`)
//func matrix_multiply(_ matrix1: matrix_float4x4, _ matrix2: matrix_float4x4) -> matrix_float4x4 {
//    return matrix1 * matrix2
//}
