////
////  MetatronCubeView.swift
////  MyApp
////
////  Created by Cong Le on 5/3/25.
////
//
////
////  MetatronCubeView.swift
////  MyApp
////  (Adapted Filename)
////
////  Created by Cong Le on 6/5/25. (Adaptation Date)
////  Based on OctahedronView created on 5/3/25.
////
////  Description:
////  This file defines a SwiftUI view hierarchy that displays a 3D rotating
////  representation of Metatron's Cube's line structure, rendered using Metal.
////  It demonstrates adapting a Metal rendering pipeline for a different geometric shape
////  and drawing lines instead of triangles.
////
////  Specifically, it shows:
////  - The 13 points conceptually representing the centers of the Fruit of Life circles.
////  - Lines connecting every point to every other point, forming the Metatron's Cube pattern.
////  - Using MetalKit within SwiftUI via UIViewRepresentable.
////  - Defining geometry (vertices, line indices).
////  - Using SIMD for MVP transformations.
////  - Rendering lines using the `.line` primitive type.
////
////  Note: The vertex positions are approximations for visual structure and may not
////        reflect perfect mathematical symmetry derived from sphere packing.
////
//import SwiftUI
//import MetalKit // Provides MTKView and Metal integration helpers
//import simd    // Provides efficient vector and matrix types/operations
//
//// MARK: - Metal Shaders (Adapted for Metatron's Cube Lines)
//
///// Contains the source code for the Metal vertex and fragment shaders.
//let metatronMetalShaderSource = """
//#include <metal_stdlib> // Import the Metal Standard Library
//
//using namespace metal; // Use the Metal namespace
//
//// Structure defining vertex input data (just position for Metatron's points).
//// Matches 'MetatronVertex' struct in Swift and the MTLVertexDescriptor.
//struct VertexIn {
//    float3 position [[attribute(0)]];
//    // Optional: could add color here if points should have different colors
//};
//
//// Structure defining data passed from the vertex shader to the fragment shader.
//struct VertexOut {
//    float4 position [[position]]; // Required clip space position
//    float4 color; // Pass a color for the line segment
//};
//
//// Structure for uniform data (constants for a draw call) passed from the CPU.
//// Layout *must* match the 'MetatronUniforms' struct layout in Swift.
//struct Uniforms {
//    float4x4 modelViewProjectionMatrix;
//};
//
//// --- Vertex Shader ---
//// Executed for each of the 13 vertices (or more precisely, each endpoint of a line).
//vertex VertexOut metatron_vertex_shader(
//    const device VertexIn *vertices [[buffer(0)]], // Vertex positions
//    const device Uniforms &uniforms [[buffer(1)]], // MVP matrix
//    unsigned int vid [[vertex_id]]                 // Index of the current vertex endpoint
//) {
//    VertexOut out;
//    VertexIn currentVertex = vertices[vid]; // Get the vertex data for this endpoint
//
//    // Calculate clip space position
//    out.position = uniforms.modelViewProjectionMatrix * float4(currentVertex.position, 1.0);
//
//    // Assign a fixed color for all lines (e.g., white/light gray)
//    out.color = float4(0.9, 0.9, 0.9, 1.0); // Light gray lines
//
//    return out;
//}
//
//// --- Fragment Shader ---
//// Executed for each pixel fragment along the rendered lines.
//fragment half4 metatron_fragment_shader(
//    VertexOut in [[stage_in]] // Interpolated data (color)
//) {
//    // Return the color passed from the vertex shader.
//    // Interpolation isn't very meaningful for a fixed line color, but this structure works.
//    return half4(in.color);
//}
//"""
//
//// MARK: - Swift Data Structures (Matching Shaders)
//
///// Swift structure mirroring the layout of the 'Uniforms' struct in the Metal shader code.
//struct MetatronUniforms { // Renamed for clarity
//    var modelViewProjectionMatrix: matrix_float4x4
//}
//
///// Structure defining the layout of vertex data for the 13 points of Metatron's Cube.
///// Matches `VertexIn` struct in the shader and the `MTLVertexDescriptor`.
//struct MetatronVertex {
//    var position: SIMD3<Float>
//    // Color removed - will be set uniformly in the shader for this example
//}
//
//// MARK: - Renderer Class (Handles Metal Logic for Metatron's Cube)
//
///// Manages Metal setup, resources, and rendering logic for Metatron's Cube lines.
//class MetatronRenderer: NSObject, MTKViewDelegate {
//
//    let device: MTLDevice
//    let commandQueue: MTLCommandQueue
//    var pipelineState: MTLRenderPipelineState!
//    var depthState: MTLDepthStencilState!
//
//    var vertexBuffer: MTLBuffer!
//    var indexBuffer: MTLBuffer! // Will store pairs of indices for lines
//    var uniformBuffer: MTLBuffer!
//
//    var rotationAngle: Float = 0.0
//    var aspectRatio: Float = 1.0
//
//    // --- Geometry Data ---
//
//    /// Array defining the 13 conceptual points (vertices) for Metatron's Cube.
//    /// Positions are approximations for visualization.
//    let vertices: [MetatronVertex] = {
//        var points: [MetatronVertex] = []
//
//        // 1. Center Point
//        points.append(MetatronVertex(position: SIMD3<Float>(0, 0, 0))) // Index 0
//
//        // 2. Inner Ring (6 points) - Assume radius 1 in XZ plane
//        let innerRadius: Float = 1.0
//        for i in 0..<6 {
//            let angle = Float(i) * (2.0 * .pi / 6.0) // 60 degrees apart
//            points.append(MetatronVertex(position: SIMD3<Float>(innerRadius * cos(angle), 0, innerRadius * sin(angle)))) // Indices 1-6
//        }
//
//        // 3. Outer Ring (6 points) - Assume radius 2 in XZ plane
//        // Note: In a 'true' Fruit of Life projection, these might not be perfectly planar
//        // or equally spaced like this, but it serves for visual structure.
//        let outerRadius: Float = 2.0
//         for i in 0..<6 {
//            // Slightly offset angle for visual distinction from inner ring vertices if projected flat
//            let angle = (Float(i) + 0.5) * (2.0 * .pi / 6.0)
//            points.append(MetatronVertex(position: SIMD3<Float>(outerRadius * cos(angle), 0, outerRadius * sin(angle)))) // Indices 7-12
//         }
//         
//         // Correction: A more common 2D representation centers the outer 6 around the inner 6.
//         // Let's try positioning based on the Flower of Life structure idea:
//         // Center, 6 surrounding circles. The next 6 are centers *between* the first 6.
//         // This is still a 2D projection into 3D space.
//         
//         points.removeAll() // Reset points for corrected approach
//         
//         // 1. Center Point
//         points.append(MetatronVertex(position: SIMD3<Float>(0, 0, 0))) // Index 0
//         
//         // 2. First Ring (6 points) - Radius 1
//         let radius1: Float = 1.0
//         for i in 0..<6 {
//            let angle = Float(i) * (2.0 * .pi / 6.0)
//            points.append(MetatronVertex(position: SIMD3<Float>(radius1 * cos(angle), radius1 * sin(angle), 0))) // Indices 1-6 (Placed on XY plane for now)
//         }
//         
//         // 3. Second Ring (points connecting centers of first ring) - Radius sqrt(3) typically
//         // Let's approximate by placing them at a larger Z for some 3D effect.
//         // A simpler visual approach might be two concentric rings in one plane again. Let's revert to that.
//         
//          points.removeAll() // Reset points again for simplicity (two concentric planar rings)
//          
//          // 1. Center Point
//          points.append(MetatronVertex(position: SIMD3<Float>(0, 0, 0))) // Index 0
//          
//          // 2. Inner Ring (6 points) - Radius 1 on XY plane
//          let r_inner: Float = 0.8
//          for i in 0..<6 {
//              let angle = Float(i) * (2.0 * .pi / 6.0)
//              points.append(MetatronVertex(position: SIMD3<Float>(r_inner * cos(angle), r_inner * sin(angle), 0))) // Indices 1-6
//          }
//          
//           // 3. Outer Ring (6 points) - Radius 1.6 on XY plane
//           let r_outer: Float = 1.6
//           for i in 0..<6 {
//               // Align angles with inner ring for structure clarity
//               let angle = Float(i) * (2.0 * .pi / 6.0)
//               points.append(MetatronVertex(position: SIMD3<Float>(r_outer * cos(angle), r_outer * sin(angle), 0))) // Indices 7-12
//           }
//
//        return points
//    }()
//
//    /// Array of indices defining the lines connecting all 13 points.
//    /// Each pair `[a, b]` represents a line segment.
//    let indices: [UInt16] = {
//        var lineIndices: [UInt16] = []
//        let numVertices = 13
//        for i in 0..<numVertices {
//            for j in (i + 1)..<numVertices { // Connect i to all subsequent vertices j
//                lineIndices.append(UInt16(i))
//                lineIndices.append(UInt16(j))
//            }
//        }
//        // Total lines = C(13, 2) = 78. Total indices = 78 * 2 = 156.
//        return lineIndices
//    }()
//    // --- End Geometry Data ---
//
//    /// Initializes the renderer with a Metal device.
//    init?(device: MTLDevice) {
//        self.device = device
//        guard let queue = device.makeCommandQueue() else {
//            print("Could not create command queue")
//            return nil
//        }
//        self.commandQueue = queue
//        super.init()
//
//        // Setup resources that don't depend on the MTKView yet
//        setupBuffers()
//        setupDepthStencil() // Still use depth for potential future elements or if lines overlap themselves
//    }
//
//    /// Configures the Metal pipeline state after the MTKView is created.
//    func configure(metalKitView: MTKView) {
//        setupPipeline(metalKitView: metalKitView)
//    }
//
//    // --- Setup Functions ---
//
//    /// Compiles shaders and creates the `MTLRenderPipelineState`.
//    func setupPipeline(metalKitView: MTKView) {
//        do {
//            let library = try device.makeLibrary(source: metatronMetalShaderSource, options: nil)
//            guard let vertexFunction = library.makeFunction(name: "metatron_vertex_shader"),
//                  let fragmentFunction = library.makeFunction(name: "metatron_fragment_shader") else {
//                fatalError("Could not load shader functions from library.")
//            }
//
//            let pipelineDescriptor = MTLRenderPipelineDescriptor()
//            pipelineDescriptor.label = "Metatron Lines Pipeline"
//            pipelineDescriptor.vertexFunction = vertexFunction
//            pipelineDescriptor.fragmentFunction = fragmentFunction
//            pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
//            pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat // Include depth
//
//            // --- Configure Vertex Descriptor (Simpler - only position) ---
//            let vertexDescriptor = MTLVertexDescriptor()
//            // Attribute 0: Position (float3)
//            vertexDescriptor.attributes[0].format = .float3
//            vertexDescriptor.attributes[0].offset = 0
//            vertexDescriptor.attributes[0].bufferIndex = 0 // Matches [[buffer(0)]] in shader
//
//            // Layout 0: Describes the overall vertex structure stride.
//            vertexDescriptor.layouts[0].stride = MemoryLayout<MetatronVertex>.stride
//            vertexDescriptor.layouts[0].stepRate = 1
//            vertexDescriptor.layouts[0].stepFunction = .perVertex
//
//            pipelineDescriptor.vertexDescriptor = vertexDescriptor // Assign configured descriptor
//
//            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//
//        } catch {
//            fatalError("Failed to create Metal Render Pipeline State: \(error)")
//        }
//    }
//
//    /// Creates and populates the GPU buffers for vertices, indices (lines), and uniforms.
//    func setupBuffers() {
//        // --- Vertex Buffer ---
//        let vertexDataSize = vertices.count * MemoryLayout<MetatronVertex>.stride
//        guard let vBuffer = device.makeBuffer(bytes: vertices, length: vertexDataSize, options: []) else {
//            fatalError("Could not create vertex buffer")
//        }
//        vertexBuffer = vBuffer
//        vertexBuffer.label = "Metatron Vertices (13 points)"
//
//        // --- Index Buffer (for LINES) ---
//        let indexDataSize = indices.count * MemoryLayout<UInt16>.stride // Pairs of UInt16
//        guard let iBuffer = device.makeBuffer(bytes: indices, length: indexDataSize, options: []) else {
//            fatalError("Could not create index buffer")
//        }
//        indexBuffer = iBuffer
//        indexBuffer.label = "Metatron Indices (Lines)"
//
//        // --- Uniform Buffer ---
//        let uniformBufferSize = MemoryLayout<MetatronUniforms>.size // Use renamed struct
//        guard let uBuffer = device.makeBuffer(length: uniformBufferSize, options: .storageModeShared) else {
//            fatalError("Could not create uniform buffer")
//        }
//        uniformBuffer = uBuffer
//        uniformBuffer.label = "Uniforms Buffer (MVP Matrix)"
//    }
//
//    /// Creates the `MTLDepthStencilState` object.
//    func setupDepthStencil() {
//        let depthDescriptor = MTLDepthStencilDescriptor()
//        depthDescriptor.depthCompareFunction = .less
//        depthDescriptor.isDepthWriteEnabled = true // Write depth for lines too
//        guard let state = device.makeDepthStencilState(descriptor: depthDescriptor) else {
//            fatalError("Failed to create depth stencil state")
//        }
//        depthState = state
//    }
//
//    // --- Update State Per Frame ---
//
//    /// Calculates the Model-View-Projection (MVP) matrix and updates the uniform buffer.
//    func updateUniforms() {
//        let projectionMatrix = matrix_perspective_left_hand(
//            fovyRadians: .pi / 3.0, // 60 degrees FOV
//            aspectRatio: aspectRatio,
//            nearZ: 0.1,
//            farZ: 100.0
//        )
//
//        // Adjust camera slightly for better view of the planar structure
//        let viewMatrix = matrix_look_at_left_hand(
//            eye: SIMD3<Float>(0, 0, -5.0),      // Move camera back
//            center: SIMD3<Float>(0, 0, 0),   // Look at origin
//            up: SIMD3<Float>(0, 1, 0)        // Y is up
//        )
//
//        // Model matrix with rotation
//        let rotationY = matrix_rotation_y(radians: rotationAngle)
//         // Add slight X rotation to see the 3D structure better if vertices weren't planar
//        let rotationX = matrix_rotation_x(radians: rotationAngle * 0.2)
//        // Rotate around Z slightly too
//        let rotationZ = matrix_rotation_z(radians: rotationAngle * 0.1)
//        let modelMatrix = matrix_multiply(matrix_multiply(rotationY, rotationX), rotationZ)
//
//        // Combine: MVP = Projection * View * Model
//        let mvpMatrix = matrix_multiply(projectionMatrix, matrix_multiply(viewMatrix, modelMatrix))
//
//        // Update Uniform Buffer
//        var uniforms = MetatronUniforms(modelViewProjectionMatrix: mvpMatrix) // Use renamed struct
//        uniformBuffer.contents().copyMemory(from: &uniforms, byteCount: MemoryLayout<MetatronUniforms>.size)
//
//        // Animate
//        rotationAngle += 0.008 // Slower rotation might be better for complex lines
//    }
//
//    // MARK: - MTKViewDelegate Methods
//
//    /// Called when the MTKView's size changes. Updates the aspect ratio.
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        aspectRatio = Float(size.width / max(1, size.height))
//    }
//
//    /// Called each frame to encode rendering commands.
//    func draw(in view: MTKView) {
//        guard let drawable = view.currentDrawable,
//              let renderPassDescriptor = view.currentRenderPassDescriptor,
//              let commandBuffer = commandQueue.makeCommandBuffer(),
//              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
//            return
//        }
//
//        updateUniforms() // Update MVP matrix
//
//        renderEncoder.label = "Metatron Lines Render Encoder"
//        renderEncoder.setRenderPipelineState(pipelineState)
//        renderEncoder.setDepthStencilState(depthState)
//
//        // Bind Buffers
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0) // Vertex data at [[buffer(0)]]
//        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1) // Uniforms at [[buffer(1)]]
//
//        // *** Issue Draw Call for LINES ***
//        renderEncoder.drawIndexedPrimitives(type: .line,                // Draw LINES
//                                            indexCount: indices.count,   // Total number of indices (156)
//                                            indexType: .uint16,
//                                            indexBuffer: indexBuffer,    // Use the line index buffer
//                                            indexBufferOffset: 0)
//
//        renderEncoder.endEncoding()
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
//}
//
//// MARK: - SwiftUI UIViewRepresentable (Adapted)
//
///// Bridges the MTKView (rendering Metatron's Cube) into SwiftUI.
//struct MetalMetatronViewRepresentable: UIViewRepresentable { // Renamed
//    typealias UIViewType = MTKView
//
//    func makeCoordinator() -> MetatronRenderer { // Return correct renderer type
//        guard let device = MTLCreateSystemDefaultDevice() else {
//            fatalError("Metal is not supported on this device.")
//        }
//        guard let coordinator = MetatronRenderer(device: device) else { // Init correct renderer type
//            fatalError("MetatronRenderer failed to initialize.")
//        }
//        print("Coordinator (MetatronRenderer) created.")
//        return coordinator
//    }
//
//    func makeUIView(context: Context) -> MTKView {
//        let mtkView = MTKView()
//        mtkView.device = context.coordinator.device // Get device from coordinator
//        mtkView.preferredFramesPerSecond = 60
//        mtkView.enableSetNeedsDisplay = false
//        mtkView.depthStencilPixelFormat = .depth32Float // Enable depth buffer
//        mtkView.clearDepth = 1.0
//        mtkView.clearColor = MTLClearColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0) // Dark blue/black background
//        mtkView.colorPixelFormat = .bgra8Unorm_srgb
//
//        // Configure the pipeline *after* view properties are set
//        context.coordinator.configure(metalKitView: mtkView)
//        mtkView.delegate = context.coordinator // Set delegate
//
//        // Trigger initial size update
//        context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
//
//        print("MTKView created and configured for Metatron's Cube.")
//        return mtkView
//    }
//
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // No external state updates needed in this example
//    }
//}
//
//// MARK: - Main SwiftUI View (Adapted)
//
///// The primary SwiftUI view displaying the Metatron's Cube rendering.
//struct MetatronCubeView: View { // Renamed
//    var body: some View {
//        VStack(spacing: 0) {
//            Text("Metatron's Cube Line Structure (Metal)") // Updated title
//                .font(.headline)
//                .padding()
//                .frame(maxWidth: .infinity)
//                 .background(Color(red: 0.05, green: 0.05, blue: 0.1)) // Match Metal clear color
//                .foregroundColor(.white)
//
//            // Embed the Metal View
//            MetalMetatronViewRepresentable() // Use updated representable
//                // .ignoresSafeArea() // Optional: extend into safe areas
//        }
//        .background(Color(red: 0.05, green: 0.05, blue: 0.1)) // Match Metal clear color
//        .ignoresSafeArea(.keyboard)
//    }
//}
//
//// MARK: - Preview Provider
//
//#Preview {
//    // Option 1: Use a Placeholder View (Recommended for Previews)
//    struct PreviewPlaceholder: View {
//        var body: some View {
//            VStack {
//                 Text("Metatron's Cube Line Structure (Metal)") // Match title
//                    .font(.headline)
//                    .padding()
//                    .foregroundColor(.white)
//                Spacer()
//                Text("Metal View Placeholder\n(Run on Simulator or Device)")
//                    .foregroundColor(.gray)
//                    .italic()
//                    .multilineTextAlignment(.center)
//                    .padding()
//                Spacer()
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color(red: 0.05, green: 0.05, blue: 0.1)) // Match expected BG
//            .edgesIgnoringSafeArea(.all)
//        }
//    }
//    //return PreviewPlaceholder() // <-- Use placeholder by default
//
//    // Option 2: Attempt to Render the Actual Metal View (May Fail Preview)
//    return MetatronCubeView() // <-- Uncomment to try live preview
//}
//
//// MARK: - Matrix Math Helper Functions (using SIMD)
//// (Copied from Octahedron example - add rotation Z)
//
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
//func matrix_rotation_y(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians)
//    let s = sin(radians)
//    return matrix_float4x4(
//        SIMD4<Float>( c, 0, s, 0), SIMD4<Float>( 0, 1, 0, 0), SIMD4<Float>(-s, 0, c, 0), SIMD4<Float>( 0, 0, 0, 1)
//    )
//}
//
//func matrix_rotation_x(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians)
//    let s = sin(radians)
//    return matrix_float4x4(
//        SIMD4<Float>(1,  0, 0, 0), SIMD4<Float>(0,  c, s, 0), SIMD4<Float>(0, -s, c, 0), SIMD4<Float>(0,  0, 0, 1)
//    )
//}
//
//// Added rotation around Z axis function
//func matrix_rotation_z(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians)
//    let s = sin(radians)
//    // Remember: Column Major!
//    return matrix_float4x4(
//        // Col 0        Col 1       Col 2        Col 3
//        SIMD4<Float>( c, s, 0, 0), SIMD4<Float>(-s, c, 0, 0), SIMD4<Float>( 0, 0, 1, 0), SIMD4<Float>( 0, 0, 0, 1)
//    )
//}
//
//func matrix_multiply(_ matrix1: matrix_float4x4, _ matrix2: matrix_float4x4) -> matrix_float4x4 {
//    return matrix1 * matrix2
//}
