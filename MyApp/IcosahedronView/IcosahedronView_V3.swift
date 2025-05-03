////
////  IcosahedronView.swift
////  MetalShapes // Example App Name
////
////  Created by Cong Le on 5/3/25. (Adapted from Octahedron example)
////  Modified by AI Assistant on [Current Date]
////
////  Description:
////  This file defines a SwiftUI view hierarchy that displays a 3D rotating
////  wireframe Icosahedron rendered using Apple's Metal framework. It demonstrates:
////  - Embedding a MetalKit view (MTKView) within SwiftUI using UIViewRepresentable.
////  - Setting up a basic Metal rendering pipeline (shaders, buffers, pipeline state).
////  - Defining geometry (vertices, indices) for an Icosahedron.
////  - Using SIMD for matrix transformations (Model-View-Projection).
////  - Basic animation through rotation updates per frame.
////  - Depth testing for correct 3D appearance.
////  - Rendering in wireframe mode.
////
//import SwiftUI
//import MetalKit // Provides MTKView and Metal integration helpers
//import simd    // Provides efficient vector and matrix types/operations (like matrix_float4x4)
//
//// MARK: - Metal Shaders (Embedded String)
//
///// Contains the source code for the Metal vertex and fragment shaders.
///// These shaders run on the GPU to process vertices and determine pixel colors.
//let icosahedronMetalShaderSource = """
//#include <metal_stdlib> // Import the Metal Standard Library
//
//using namespace metal; // Use the Metal namespace
//
//// Structure defining vertex input data received from the CPU (Swift code).
//// The layout *must* match the 'ShapeVertex' struct in Swift and the MTLVertexDescriptor.
//struct VertexIn {
//    // Vertex position in model space. [[attribute(0)]] links to the first attribute in the vertex descriptor.
//    float3 position [[attribute(0)]];
//    // Vertex color (RGBA). [[attribute(1)]] links to the second attribute.
//    float4 color    [[attribute(1)]];
//};
//
//// Structure defining data passed from the vertex shader to the fragment shader.
//// Metal interpolates these values across the triangle/line surface.
//struct VertexOut {
//    // Final position in clip space (required output). [[position]] designates this special variable.
//    float4 position [[position]];
//    // Color to be interpolated for the fragment shader.
//    float4 color;
//};
//
//// Structure for uniform data (constants for a draw call) passed from the CPU.
//// This *must* match the 'Uniforms' struct layout in Swift.
//struct Uniforms {
//    // Combined Model-View-Projection matrix to transform vertices to clip space.
//    float4x4 modelViewProjectionMatrix;
//};
//
//// --- Vertex Shader ---
//// Function executed for each vertex in the draw call.
//vertex VertexOut icosahedron_vertex_shader(
//    // Input: Array of vertices passed from the CPU's vertex buffer.
//    // [[buffer(0)]] links this to the buffer bound at index 0 by the Render Encoder.
//    const device VertexIn *vertices [[buffer(0)]],
//    // Input: Uniform data (MVP matrix) from the CPU's uniform buffer.
//    // [[buffer(1)]] links this to the buffer bound at index 1.
//    const device Uniforms &uniforms [[buffer(1)]],
//    // Input: System-generated index of the current vertex being processed
//    //        (actually the index value from the index buffer for indexed drawing).
//    unsigned int vid [[vertex_id]]
//) {
//    // Prepare the output structure
//    VertexOut out;
//
//    // Get the current vertex data using the vertex ID provided by the index buffer
//    VertexIn currentVertex = vertices[vid];
//
//    // Calculate the vertex's clip space position by multiplying its model position
//    // by the Model-View-Projection matrix. Add w=1.0 for perspective division.
//    out.position = uniforms.modelViewProjectionMatrix * float4(currentVertex.position, 1.0);
//
//    // Pass the vertex's color directly to the output structure.
//    // This color will be interpolated across the primitive (triangle/line).
//    out.color = currentVertex.color;
//
//    return out; // Return the processed vertex data
//}
//
//// --- Fragment Shader ---
//// Function executed for each pixel fragment within the rendered primitives (triangles/lines).
//fragment half4 icosahedron_fragment_shader(
//    // Input: Interpolated data received from the vertex shader.
//    // [[stage_in]] attribute marks this struct as containing interpolated data.
//    VertexOut in [[stage_in]]
//) {
//    // Return the interpolated color as the final color for this pixel.
//    // 'half4' is used for potentially better performance on some mobile GPUs (uses 16-bit floats).
//    return half4(in.color);
//}
//"""
//
//// MARK: - Swift Data Structures (Matching Shaders)
//
///// Swift structure mirroring the layout of the 'Uniforms' struct in the Metal shader code.
///// Used to organize and copy transformation data to the GPU's uniform buffer.
//struct Uniforms {
//    /// The combined Model-View-Projection matrix. `matrix_float4x4` is a SIMD type alias.
//    var modelViewProjectionMatrix: matrix_float4x4
//}
//
///// Structure defining the layout of vertex data in Swift application code.
///// This layout *must* match the `VertexIn` struct in the shader and the `MTLVertexDescriptor` configuration.
//struct ShapeVertex {
//    /// The 3D position (x, y, z) of the vertex in model space.
//    var position: SIMD3<Float>
//    /// The RGBA color associated with the vertex.
//    var color: SIMD4<Float>
//}
//
//// MARK: - Renderer Class (Handles Metal Logic)
//
///// Manages all Metal-specific setup, resource creation, and rendering logic for an Icosahedron.
///// Conforms to `MTKViewDelegate` to respond to view size changes and draw calls.
//class IcosahedronRenderer: NSObject, MTKViewDelegate {
//
//    /// The logical connection to the GPU. Used to create other Metal objects.
//    let device: MTLDevice
//    /// Queue for sending encoded commands (rendering, compute) to the GPU.
//    let commandQueue: MTLCommandQueue
//    /// Compiled shader functions and rendering configuration (vertex layout, pixel formats, etc.).
//    var pipelineState: MTLRenderPipelineState!
//    /// Configures depth testing behavior (essential for correct 3D rendering).
//    var depthState: MTLDepthStencilState!
//
//    /// GPU buffer holding the icosahedron's vertex data (`ShapeVertex` array).
//    var vertexBuffer: MTLBuffer!
//    /// GPU buffer holding the indices that define the icosahedron's triangles (`UInt16` array).
//    var indexBuffer: MTLBuffer!
//    /// GPU buffer holding the transformation matrix (`Uniforms` struct). Updated each frame.
//    var uniformBuffer: MTLBuffer!
//
//    /// Current rotation angle for the animation (in radians). Incremented each frame.
//    var rotationAngle: Float = 0.0
//    /// Aspect ratio of the view (width / height). Updated when the view size changes.
//    var aspectRatio: Float = 1.0
//
//    // --- Geometry Data ---
//
//    // Calculate phi and radius once as static constants
//    private static let phi: Float = (1.0 + sqrt(5.0)) * 0.5
//    private static let r: Float = 1.0 // Scaling factor
//
//    /// Array defining the 12 vertices of the Icosahedron.
//    /// Uses the golden ratio (phi) and pre-calculated values.
//    static let vertices: [ShapeVertex] = [
//        // Vertex Format: ShapeVertex(position: SIMD3<Float>(x, y, z), color: SIMD4<Float>(r, g, b, a))
//        // Assign distinct colors for visualization
//        ShapeVertex(position: SIMD3<Float>(-1,  Self.phi,    0) * Self.r, color: SIMD4<Float>(1.0, 0.0, 0.0, 1)), // 0 Red
//        ShapeVertex(position: SIMD3<Float>( 1,  Self.phi,    0) * Self.r, color: SIMD4<Float>(0.0, 1.0, 0.0, 1)), // 1 Green
//        ShapeVertex(position: SIMD3<Float>(-1, -Self.phi,    0) * Self.r, color: SIMD4<Float>(0.0, 0.0, 1.0, 1)), // 2 Blue
//        ShapeVertex(position: SIMD3<Float>( 1, -Self.phi,    0) * Self.r, color: SIMD4<Float>(1.0, 1.0, 0.0, 1)), // 3 Yellow
//
//        ShapeVertex(position: SIMD3<Float>( 0, -1,  Self.phi) * Self.r, color: SIMD4<Float>(1.0, 0.0, 1.0, 1)), // 4 Magenta
//        ShapeVertex(position: SIMD3<Float>( 0,  1,  Self.phi) * Self.r, color: SIMD4<Float>(0.0, 1.0, 1.0, 1)), // 5 Cyan
//        ShapeVertex(position: SIMD3<Float>( 0, -1, -Self.phi) * Self.r, color: SIMD4<Float>(1.0, 0.5, 0.0, 1)), // 6 Orange
//        ShapeVertex(position: SIMD3<Float>( 0,  1, -Self.phi) * Self.r, color: SIMD4<Float>(0.5, 0.0, 1.0, 1)), // 7 Purple
//
//        ShapeVertex(position: SIMD3<Float>( Self.phi,  0, -1) * Self.r, color: SIMD4<Float>(0.0, 0.5, 0.5, 1)), // 8 Teal
//        ShapeVertex(position: SIMD3<Float>( Self.phi,  0,  1) * Self.r, color: SIMD4<Float>(0.5, 1.0, 0.5, 1)), // 9 Light Green
//        ShapeVertex(position: SIMD3<Float>(-Self.phi,  0, -1) * Self.r, color: SIMD4<Float>(0.5, 0.5, 0.0, 1)), // 10 Olive
//        ShapeVertex(position: SIMD3<Float>(-Self.phi,  0,  1) * Self.r, color: SIMD4<Float>(0.0, 0.5, 1.0, 1))  // 11 Sky Blue
//    ]
//
//    /// Array of indices defining the 20 triangular faces of the Icosahedron (60 indices total).
//    /// Each sequence of 3 indices references vertices from the `vertices` array.
//    /// Standard counter-clockwise winding order.
//    static let indices: [UInt16] = [
//        0, 11, 5,    0, 5, 1,    0, 1, 7,    0, 7, 10,    0, 10, 11,
//        1, 5, 9,     5, 11, 4,   11, 10, 2,   10, 7, 6,    7, 1, 8,
//        3, 9, 4,     3, 4, 2,    3, 2, 6,    3, 6, 8,     3, 8, 9,
//        4, 9, 5,     2, 4, 11,   6, 2, 10,   8, 6, 7,     9, 8, 1
//    ]
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
//        setupBuffers()        // Create buffers for Icosahedron geometry
//        setupDepthStencil()   // Configure depth testing state
//    }
//
//    /// Configures the Metal pipeline state.
//    func configure(metalKitView: MTKView) {
//        setupPipeline(metalKitView: metalKitView)
//    }
//
//    // --- Setup Functions ---
//
//    /// Compiles shaders and creates the `MTLRenderPipelineState`.
//    func setupPipeline(metalKitView: MTKView) {
//        do {
//            let library = try device.makeLibrary(source: icosahedronMetalShaderSource, options: nil)
//            guard let vertexFunction = library.makeFunction(name: "icosahedron_vertex_shader"),
//                  let fragmentFunction = library.makeFunction(name: "icosahedron_fragment_shader") else {
//                fatalError("Could not load shader functions from library. Check function names.")
//            }
//
//            let pipelineDescriptor = MTLRenderPipelineDescriptor()
//            pipelineDescriptor.label = "Wireframe Icosahedron Pipeline"
//            pipelineDescriptor.vertexFunction = vertexFunction
//            pipelineDescriptor.fragmentFunction = fragmentFunction
//            pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
//            pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat // Enable depth
//
//            // --- Configure Vertex Descriptor ---
//            let vertexDescriptor = MTLVertexDescriptor()
//            vertexDescriptor.attributes[0].format = .float3 // Position
//            vertexDescriptor.attributes[0].offset = 0
//            vertexDescriptor.attributes[0].bufferIndex = 0
//            vertexDescriptor.attributes[1].format = .float4 // Color
//            vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
//            vertexDescriptor.attributes[1].bufferIndex = 0
//            vertexDescriptor.layouts[0].stride = MemoryLayout<ShapeVertex>.stride
//            vertexDescriptor.layouts[0].stepRate = 1
//            vertexDescriptor.layouts[0].stepFunction = .perVertex
//            pipelineDescriptor.vertexDescriptor = vertexDescriptor
//
//            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//
//        } catch {
//            fatalError("Failed to create Metal Render Pipeline State: \(error)")
//        }
//    }
//
//    /// Creates and populates the GPU buffers for vertices, indices, and uniforms.
//    func setupBuffers() {
//        // --- Vertex Buffer ---
//        // Use Self.vertices to access the static property
//        let vertexDataSize = Self.vertices.count * MemoryLayout<ShapeVertex>.stride
//        guard vertexDataSize > 0,
//              // Pass the static vertices array
//              let vBuffer = device.makeBuffer(bytes: Self.vertices, length: vertexDataSize, options: []) else {
//            fatalError("Could not create vertex buffer. Vertex count: \(Self.vertices.count)")
//        }
//        vertexBuffer = vBuffer
//        vertexBuffer.label = "Icosahedron Vertices"
//
//        // --- Index Buffer ---
//        // Use Self.indices to access the static property
//        let indexDataSize = Self.indices.count * MemoryLayout<UInt16>.stride
//        guard indexDataSize > 0,
//              // Pass the static indices array
//              let iBuffer = device.makeBuffer(bytes: Self.indices, length: indexDataSize, options: []) else {
//            fatalError("Could not create index buffer. Index count: \(Self.indices.count)")
//        }
//        indexBuffer = iBuffer
//        indexBuffer.label = "Icosahedron Indices"
//
//        // --- Uniform Buffer (Remains the same) ---
//        let uniformBufferSize = MemoryLayout<Uniforms>.stride // Use stride for alignment
//        guard let uBuffer = device.makeBuffer(length: max(uniformBufferSize, 16), options: .storageModeShared) else {
//            fatalError("Could not create uniform buffer")
//        }
//        uniformBuffer = uBuffer
//        uniformBuffer.label = "Uniforms Buffer (MVP Matrix)"
//    }
//
//    /// Creates the `MTLDepthStencilState` object to configure depth testing.
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
//    /// Calculates the Model-View-Projection (MVP) matrix and updates the uniform buffer.
//    func updateUniforms() {
//        let projectionMatrix = matrix_perspective_left_hand(
//            fovyRadians: Float.pi / 3.0, aspectRatio: aspectRatio, nearZ: 0.1, farZ: 100.0
//        )
//        let viewMatrix = matrix_look_at_left_hand(
//            eye: SIMD3<Float>(0, 0.5, -4.5), // Slightly further back for Icosahedron
//            center: SIMD3<Float>(0, 0, 0),
//            up: SIMD3<Float>(0, 1, 0)
//        )
//        let rotationY = matrix_rotation_y(radians: rotationAngle)
//        let rotationX = matrix_rotation_x(radians: rotationAngle * 0.6) // Different rotation ratio
//        let modelMatrix = matrix_multiply(rotationY, rotationX)
//
//        let modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix)
//        let mvpMatrix = matrix_multiply(projectionMatrix, modelViewMatrix)
//
//        var uniforms = Uniforms(modelViewProjectionMatrix: mvpMatrix)
//        uniformBuffer.contents().copyMemory(from: &uniforms, byteCount: MemoryLayout<Uniforms>.stride)
//
//        rotationAngle += 0.008 // Slightly slower rotation
//    }
//
//    // MARK: - MTKViewDelegate Methods
//
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        aspectRatio = Float(size.width / max(1, size.height))
//        print("Icosahedron MTKView Resized - New Aspect Ratio: \(aspectRatio)")
//    }
//
//    func draw(in view: MTKView) {
//        guard let drawable = view.currentDrawable,
//              let renderPassDescriptor = view.currentRenderPassDescriptor,
//              let commandBuffer = commandQueue.makeCommandBuffer(),
//              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
//             print("Failed to get required Metal objects in draw(in:) for Icosahedron. Skipping frame.")
//            return
//        }
//
//        updateUniforms()
//
//        renderEncoder.label = "Icosahedron Render Encoder"
//        renderEncoder.setRenderPipelineState(pipelineState)
//        renderEncoder.setDepthStencilState(depthState)
//        renderEncoder.setTriangleFillMode(.lines)
//
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
//
//        renderEncoder.drawIndexedPrimitives(type: .triangle,
//                                                // Use Self.indices.count
//                                                indexCount: Self.indices.count,
//                                                indexType: .uint16,
//                                                indexBuffer: indexBuffer,
//                                                indexBufferOffset: 0)
//
//        renderEncoder.endEncoding()
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
//}
//
//// MARK: - SwiftUI UIViewRepresentable
//
///// Bridges the `MTKView` (rendering the Icosahedron) into SwiftUI.
//struct MetalIcosahedronViewRepresentable: UIViewRepresentable {
//    typealias UIViewType = MTKView
//
//    func makeCoordinator() -> IcosahedronRenderer {
//        guard let device = MTLCreateSystemDefaultDevice() else {
//            fatalError("Metal is not supported on this device.")
//        }
//        guard let coordinator = IcosahedronRenderer(device: device) else {
//            fatalError("IcosahedronRenderer failed to initialize.")
//        }
//        print("Coordinator (IcosahedronRenderer) created.")
//        return coordinator
//    }
//
//    func makeUIView(context: Context) -> MTKView {
//        let mtkView = MTKView()
//        mtkView.device = context.coordinator.device
//        mtkView.preferredFramesPerSecond = 60
//        mtkView.enableSetNeedsDisplay = false
//        mtkView.depthStencilPixelFormat = .depth32Float
//        mtkView.clearDepth = 1.0
//        mtkView.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0) // Darker BG
//        mtkView.colorPixelFormat = .bgra8Unorm_srgb
//
//        context.coordinator.configure(metalKitView: mtkView)
//        mtkView.delegate = context.coordinator
//        context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
//
//        print("Icosahedron MTKView created and configured.")
//        return mtkView
//    }
//
//    func updateUIView(_ uiView: MTKView, context: Context) { }
//}
//
//// MARK: - Main SwiftUI View
//
///// The primary SwiftUI view displaying the rotating Icosahedron.
//struct IcosahedronView: View {
//    var body: some View {
//        VStack(spacing: 0) {
//            Text("Rotating Wireframe Icosahedron (Metal)")
//                .font(.headline)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color(red: 0.1, green: 0.1, blue: 0.1)) // Match clear color
//                .foregroundColor(.white)
//
//            MetalIcosahedronViewRepresentable()
//                // .ignoresSafeArea()
//        }
//        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
//        .ignoresSafeArea(.keyboard)
//    }
//}
//
//// MARK: - Preview Provider
//
//#Preview {
//    // Using placeholder for stability
//    struct PreviewPlaceholder: View {
//        var body: some View {
//             VStack(spacing: 0) {
//                Text("Rotating Wireframe Icosahedron (Metal)")
//                    .font(.headline)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color(red: 0.1, green: 0.1, blue: 0.1))
//                    .foregroundColor(.white)
//                Spacer()
//                Text("Metal View Placeholder\n(Run on Simulator or Device)")
//                    .foregroundColor(.gray).italic().multilineTextAlignment(.center).padding()
//                Spacer()
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
//            .edgesIgnoringSafeArea(.all)
//        }
//    }
//    return PreviewPlaceholder()
//
//    // Or uncomment to attempt live preview:
//    // return IcosahedronView()
//}
//
//// MARK: - Matrix Math Helper Functions (using SIMD)
//// (Identical generic functions as before)
//
///// Creates a perspective projection matrix (Left-Handed).
//func matrix_perspective_left_hand(fovyRadians: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
//    let y = 1.0 / tan(fovyRadians * 0.5); let x = y / aspectRatio; let z = farZ / (farZ - nearZ); let w = -nearZ * z
//    return matrix_float4x4(SIMD4<Float>(x, 0, 0, 0), SIMD4<Float>(0, y, 0, 0), SIMD4<Float>(0, 0, z, 1), SIMD4<Float>(0, 0, w, 0))
//}
//
///// Creates a view matrix (Left-Handed) to position and orient the camera.
//func matrix_look_at_left_hand(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> matrix_float4x4 {
//    let zAxis = normalize(center - eye); let xAxis = normalize(cross(up, zAxis)); let yAxis = cross(zAxis, xAxis)
//    let translateX = -dot(xAxis, eye); let translateY = -dot(yAxis, eye); let translateZ = -dot(zAxis, eye)
//    return matrix_float4x4(SIMD4<Float>(xAxis.x, yAxis.x, zAxis.x, 0), SIMD4<Float>(xAxis.y, yAxis.y, zAxis.y, 0), SIMD4<Float>(xAxis.z, yAxis.z, zAxis.z, 0), SIMD4<Float>(translateX, translateY, translateZ, 1))
//}
//
///// Creates a rotation matrix for rotation around the Y-axis.
//func matrix_rotation_y(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians); let s = sin(radians)
//    return matrix_float4x4(SIMD4<Float>(c, 0, s, 0), SIMD4<Float>(0, 1, 0, 0), SIMD4<Float>(-s, 0, c, 0), SIMD4<Float>(0, 0, 0, 1))
//}
//
///// Creates a rotation matrix for rotation around the X-axis.
//func matrix_rotation_x(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians); let s = sin(radians)
//    return matrix_float4x4(SIMD4<Float>(1, 0, 0, 0), SIMD4<Float>(0, c, s, 0), SIMD4<Float>(0, -s, c, 0), SIMD4<Float>(0, 0, 0, 1))
//}
//
///// Multiplies two 4x4 matrices.
//func matrix_multiply(_ matrix1: matrix_float4x4, _ matrix2: matrix_float4x4) -> matrix_float4x4 {
//    return matrix1 * matrix2
//}
