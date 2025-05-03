////
////  OctahedronView.swift
////  MyApp
////
////  Created by Cong Le on 5/3/25.
////
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
//// Matches the Swift 'Uniforms' struct
//struct Uniforms {
//    float4x4 modelViewProjectionMatrix;
//};
//
//// --- Vertex Shader ---
//// Processes each vertex
//vertex VertexOut octahedron_vertex_shader(
//    const device VertexIn *vertices [[buffer(0)]],      // Array of vertices (Buffer 0)
//    const device Uniforms &uniforms [[buffer(1)]],      // Uniform data (Buffer 1)
//    unsigned int vid [[vertex_id]]                      // Index of the current vertex
//) {
//
//    VertexOut out;
//    // Transform vertex position directly from the buffer element
//    out.position = uniforms.modelViewProjectionMatrix * float4(vertices[vid].position, 1.0); // <--- MODIFIED
//    // Pass the vertex color directly from the buffer element
//    out.color = vertices[vid].color; // <--- MODIFIED
//
//    return out;
//}
//
//// --- Fragment Shader ---
//// Processes each pixel fragment within the rendered lines/triangles
//fragment half4 octahedron_fragment_shader(
//    VertexOut in [[stage_in]] // Data received from vertex shader (interpolated)
//) {
//    // Return the interpolated color as the final pixel color
//    // Using half4 for potentially better performance on some GPUs
//    return half4(in.color);
//}
//"""
//
//// MARK: - Swift Data Structures (Matching Shaders)
//
//// Swift struct mirroring the layout of the 'Uniforms' struct in the shader
//struct Uniforms {
//    var modelViewProjectionMatrix: matrix_float4x4 // Use the simd alias matrix_float4x4
//}
//
//// Structure defining vertex data layout in Swift
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
//    var indexBuffer: MTLBuffer! // Indices for triangles
//    var uniformBuffer: MTLBuffer! // For MVP matrix
//    
//    var rotationAngle: Float = 0.0
//    var aspectRatio: Float = 1.0 // Set initially by drawableSizeWillChange
//    
//    // --- Geometry Data ---
//    // Octahedron vertex coordinates (Top/Bottom apex approach)
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
//    // Indices defining the 8 triangular faces
//    // Drawing these triangles in wireframe mode will show the edges
//    let indices: [UInt16] = [
//        // Top pyramid faces (winding: counter-clockwise)
//        0, 1, 2,   0, 2, 3,   0, 3, 4,   0, 4, 1,
//        // Bottom pyramid faces (winding: counter-clockwise)
//        5, 2, 1,   5, 3, 2,   5, 4, 3,   5, 1, 4
//    ]
//    // --- End Geometry Data ---
//    
//    // Initializer: Requires only the Metal device
//    init?(device: MTLDevice) {
//        self.device = device
//        guard let queue = device.makeCommandQueue() else {
//            print("Could not create command queue")
//            return nil
//        }
//        self.commandQueue = queue
//        super.init()
//        // Setup resources that don't depend on the MTKView's format yet
//        setupBuffers()
//        setupDepthStencil()
//    }
//    
//    // Called by UIViewRepresentable after MTKView is created and configured
//    func configure(metalKitView: MTKView) {
//        // Setup pipeline using the view's specific pixel formats
//        setupPipeline(metalKitView: metalKitView)
//    }
//    
//    // --- Setup Functions ---
//    
//    func setupPipeline(metalKitView: MTKView) {
//        do {
//            // Compile shaders from embedded string
//            let library = try device.makeLibrary(source: octahedronMetalShaderSource, options: nil)
//            guard let vertexFunction = library.makeFunction(name: "octahedron_vertex_shader"),
//                  let fragmentFunction = library.makeFunction(name: "octahedron_fragment_shader") else {
//                fatalError("Could not load shader functions from library")
//            }
//            
//            // Configure the render pipeline descriptor
//            let pipelineDescriptor = MTLRenderPipelineDescriptor()
//            pipelineDescriptor.label = "Wireframe Octahedron Pipeline"
//            pipelineDescriptor.vertexFunction = vertexFunction
//            pipelineDescriptor.fragmentFunction = fragmentFunction
//            // Use the pixel formats from the MTKView it will render into
//            pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
//            pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat // Crucial for depth testing
//            
//            // Define vertex data layout matching OctahedronVertex struct
//            let vertexDescriptor = MTLVertexDescriptor()
//            // Position attribute
//            vertexDescriptor.attributes[0].format = .float3
//            vertexDescriptor.attributes[0].offset = 0
//            vertexDescriptor.attributes[0].bufferIndex = 0 // Corresponds to [[buffer(0)]] in shader
//            // Color attribute
//            vertexDescriptor.attributes[1].format = .float4
//            vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride // Start after position
//            vertexDescriptor.attributes[1].bufferIndex = 0 // Same buffer
//            // Define the stride for the entire vertex structure
//            vertexDescriptor.layouts[0].stride = MemoryLayout<OctahedronVertex>.stride
//            vertexDescriptor.layouts[0].stepRate = 1
//            vertexDescriptor.layouts[0].stepFunction = .perVertex
//            pipelineDescriptor.vertexDescriptor = vertexDescriptor
//            
//            // Create the pipeline state
//            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//            
//        } catch {
//            fatalError("Failed to create Metal Render Pipeline State: \(error)")
//        }
//    }
//    
//    func setupBuffers() {
//        // Create vertex buffer
//        let vertexDataSize = vertices.count * MemoryLayout<OctahedronVertex>.stride
//        guard let buffer = device.makeBuffer(bytes: vertices, length: vertexDataSize, options: []) else {
//            fatalError("Could not create vertex buffer")
//        }
//        vertexBuffer = buffer
//        vertexBuffer.label = "Octahedron Vertices"
//        
//        // Create index buffer
//        let indexDataSize = indices.count * MemoryLayout<UInt16>.stride
//        guard let idxBuffer = device.makeBuffer(bytes: indices, length: indexDataSize, options: []) else {
//            fatalError("Could not create index buffer")
//        }
//        indexBuffer = idxBuffer
//        indexBuffer.label = "Octahedron Indices"
//        
//        // Create uniform buffer (sized for one MVP matrix)
//        let uniformBufferSize = MemoryLayout<Uniforms>.size // Use the Swift struct size
//        guard let uniBuffer = device.makeBuffer(length: uniformBufferSize, options: .storageModeShared) else {
//            fatalError("Could not create uniform buffer")
//        }
//        uniformBuffer = uniBuffer
//        uniformBuffer.label = "Uniforms Buffer (MVP Matrix)"
//    }
//    
//    func setupDepthStencil() {
//        let depthDescriptor = MTLDepthStencilDescriptor()
//        depthDescriptor.depthCompareFunction = .less // Fragments behind existing fragments are discarded
//        depthDescriptor.isDepthWriteEnabled = true   // Write depths of drawn fragments
//        guard let state = device.makeDepthStencilState(descriptor: depthDescriptor) else {
//            fatalError("Failed to create depth stencil state")
//        }
//        depthState = state
//    }
//    
//    // --- Update State Per Frame ---
//    func updateUniforms() {
//        // Calculate Model-View-Projection (MVP) matrix
//        let projectionMatrix = matrix_perspective_left_hand(fovyRadians: Float.pi / 3.0, // Field of view
//                                                            aspectRatio: aspectRatio,
//                                                            nearZ: 0.1, // Near clipping plane
//                                                            farZ: 100.0) // Far clipping plane
//        
//        let viewMatrix = matrix_look_at_left_hand(eye: SIMD3<Float>(0, 0.5, -4), // Camera position (slightly above origin)
//                                                  center: SIMD3<Float>(0, 0, 0),  // Look at origin
//                                                  up: SIMD3<Float>(0, 1, 0))     // Y-axis is up
//        
//        // Apply rotations: Rotate around Y axis and slightly around X axis
//        let modelMatrix = matrix_multiply(matrix_rotation_y(radians: rotationAngle),
//                                          matrix_rotation_x(radians: rotationAngle * 0.5))
//        
//        let modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix) // Combine model and view
//        let mvpMatrix = matrix_multiply(projectionMatrix, modelViewMatrix) // Combine P * V * M
//        
//        // Prepare the Uniforms struct with the calculated matrix
//        var uniforms = Uniforms(modelViewProjectionMatrix: mvpMatrix)
//        
//        // Get a pointer to the uniform buffer's memory
//        let bufferPointer = uniformBuffer.contents()
//        // Copy the matrix data into the buffer
//        memcpy(bufferPointer, &uniforms, MemoryLayout<Uniforms>.size) // Use the Swift struct size!
//        
//        // Update rotation angle for the next frame's animation
//        rotationAngle += 0.01 // Adjust speed if desired
//    }
//    
//    // MARK: - MTKViewDelegate Methods
//    
//    // Called when the MTKView's size changes (e.g., device rotation, window resize)
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        // Update the aspect ratio for the projection matrix
//        aspectRatio = Float(size.width / max(1, size.height)) // Avoid division by zero if height is 0
//        // Optional: Add print statement for debugging size changes
//        // print("View size changed, aspect ratio updated to: \(aspectRatio)")
//    }
//    
//    // Called automatically each frame to draw content
//    func draw(in view: MTKView) {
//        // Ensure we have the necessary components for drawing
//        guard let drawable = view.currentDrawable,
//              let renderPassDescriptor = view.currentRenderPassDescriptor, // Gets clear colors/depth from view
//              let commandBuffer = commandQueue.makeCommandBuffer(),
//              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
//            // Add print statement for debugging if needed
//            // print("Failed to get required drawable or command buffer/encoder in draw(in:)")
//            return
//        }
//        
//        // --- Per-Frame Updates ---
//        updateUniforms() // Update the MVP matrix in the uniform buffer
//        
//        // --- Configure Render Encoder ---
//        renderEncoder.label = "Octahedron Render Encoder"
//        renderEncoder.setRenderPipelineState(pipelineState) // Set the compiled shaders and states
//        renderEncoder.setDepthStencilState(depthState) // Enable depth testing
//        
//        // *** Set to Wireframe Rendering ***
//        renderEncoder.setTriangleFillMode(.lines)
//        
//        // --- Bind Buffers ---
//        // Bind the vertex buffer to buffer index 0 (matches shader [[buffer(0)]])
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//        // Bind the uniform buffer to buffer index 1 (matches shader [[buffer(1)]])
//        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
//        
//        // --- Issue Draw Call ---
//        // Draw the octahedron using the index buffer
//        renderEncoder.drawIndexedPrimitives(type: .triangle,     // Base primitive is triangle
//                                            indexCount: indices.count, // Number of indices to draw
//                                            indexType: .uint16,       // Data type of indices
//                                            indexBuffer: indexBuffer, // The buffer containing indices
//                                            indexBufferOffset: 0)    // Start at the beginning of the index buffer
//        
//        // --- Finalize ---
//        renderEncoder.endEncoding() // Finish encoding commands for this pass
//        commandBuffer.present(drawable) // Schedule the drawable to be presented onscreen
//        commandBuffer.commit() // Send the command buffer to the GPU for execution
//    }
//}
//
//// MARK: - SwiftUI UIViewRepresentable
//
//struct MetalOctahedronViewRepresentable: UIViewRepresentable {
//    typealias UIViewType = MTKView
//    
//    // Creates the Coordinator (our Renderer instance)
//    func makeCoordinator() -> OctahedronRenderer {
//        guard let device = MTLCreateSystemDefaultDevice(), // Get default Metal device
//              let coordinator = OctahedronRenderer(device: device) else { // Initialize renderer
//            fatalError("Metal is not supported or OctahedronRenderer failed to initialize")
//        }
//        // Optional: Add print statement for debugging
//        print("Coordinator (OctahedronRenderer) created.")
//        return coordinator
//    }
//    
//    // Creates the underlying MTKView
//    func makeUIView(context: Context) -> MTKView {
//        let mtkView = MTKView()
//        mtkView.device = context.coordinator.device // Assign the device from the coordinator
//        
//        // Configure MTKView properties *before* the delegate might need them
//        mtkView.preferredFramesPerSecond = 60
//        mtkView.enableSetNeedsDisplay = false // Use delegate draw loop, not explicit setNeedsDisplay
//        
//        // *** Essential for 3D Rendering ***
//        mtkView.depthStencilPixelFormat = .depth32Float // Request a depth buffer
//        mtkView.clearDepth = 1.0 // Clear depth buffer to farthest value (1.0)
//        
//        // Standard view setup
//        mtkView.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0) // Dark background
//        mtkView.colorPixelFormat = .bgra8Unorm_srgb // Standard color format
//        
//        // Let the coordinator configure its pipeline based on the view's formats
//        context.coordinator.configure(metalKitView: mtkView)
//        
//        // Set the delegate AFTER the view and coordinator are configured
//        mtkView.delegate = context.coordinator
//        
//        // Manually trigger the initial size update to set the aspect ratio correctly
//        // before the first draw call might happen.
//        context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
//        
//        // Optional: Add print statement for debugging
//        print("MTKView created and configured.")
//        return mtkView
//    }
//    
//    // Updates the MTKView if SwiftUI state changes (not needed for this example)
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // No updates needed from SwiftUI state in this version.
//    }
//}
//
//// MARK: - Main SwiftUI View
//
//struct OctahedronView: View {
//    var body: some View {
//        VStack(spacing: 0) { // Use spacing 0 to prevent gaps
//            Text("Rotating Wireframe Octahedron (Metal)")
//                .font(.headline)
//                .padding() // Add some padding around the text
//                .frame(maxWidth: .infinity) // Make text background span width
//                .background(Color(red: 0.1, green: 0.1, blue: 0.15)) // Match Metal clear color
//                .foregroundColor(.white) // Ensure text is visible
//            
//            // Embed the Metal view
//            MetalOctahedronViewRepresentable()
//            // Let the Metal view take remaining space.
//            // Use .ignoresSafeArea(.all) or specific edges like .bottom
//            // depending on your desired layout within the VStack.
//        }
//        // Apply background color to the whole VStack container as well
//        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
//        .ignoresSafeArea(.keyboard) // Good practice for views that might show keyboard
//    }
//}
//
//// MARK: - Preview Provider (Using Placeholder)
//
//#Preview {
//    // This struct will be displayed ON THE PREVIEW CANVAS ONLY
//    struct PreviewPlaceholder: View {
//        var body: some View {
//            VStack { // Root VStack for the placeholder content
//                Text("Rotating Wireframe Octahedron (Metal)")
//                    .font(.headline)
//                    .padding()
//                    .foregroundColor(.white) // Ensure title is visible
//                
//                Spacer() // Pushes content to top/bottom
//                
//                // Placeholder text explaining what the user should expect
//                Text("Metal View Placeholder\n(Run on Simulator or Device to see the Octahedron)")
//                    .foregroundColor(.gray)
//                    .italic()
//                    .multilineTextAlignment(.center) // Center align if multi-line
//                    .padding() // Add padding to the placeholder text
//                
//                Spacer() // Pushes content to top/bottom
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill available space
//            .background(Color(red: 0.1, green: 0.1, blue: 0.15)) // Match expected background
//            .edgesIgnoringSafeArea(.all) // Ensure background fills entire preview area might need
//        }
//    }
//    
//    // Return the placeholder for the preview canvas
//    //return PreviewPlaceholder()
//    
//    // To ATTEMPT rendering the actual Metal view in preview (MAY CRASH):
//    // Comment out `return PreviewPlaceholder()` and uncomment the line below:
//    return OctahedronView()
//}
//
//// MARK: - Matrix Math Helper Functions (simd)
//
//// Creates a perspective projection matrix (Left-Handed coordinate system)
//func matrix_perspective_left_hand(fovyRadians: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
//    let y = 1.0 / tan(fovyRadians * 0.5)
//    let x = y / aspectRatio
//    let z = farZ / (farZ - nearZ)
//    let w = -nearZ * z
//    
//    return matrix_float4x4(
//        SIMD4<Float>(x, 0, 0, 0), // Column 0
//        SIMD4<Float>(0, y, 0, 0), // Column 1
//        SIMD4<Float>(0, 0, z, 1), // Column 2 (Note the 1 in the W component for Z)
//        SIMD4<Float>(0, 0, w, 0)  // Column 3
//    )
//}
//
//// Creates a view matrix (Left-Handed coordinate system)
//// Positions the camera 'eye' looking towards 'center' with 'up' orientation
//func matrix_look_at_left_hand(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> matrix_float4x4 {
//    let z = normalize(center - eye) // Direction camera is looking (Forward)
//    let x = normalize(cross(up, z)) // Right vector (perpendicular to Up and Forward)
//    let y = cross(z, x)             // Recalculated Up vector (perpendicular to Forward and Right)
//    let t = SIMD3<Float>(-dot(x, eye), -dot(y, eye), -dot(z, eye)) // Translation component
//    
//    // Remember matrix_float4x4 is column-major in simd
//    return matrix_float4x4(
//        SIMD4<Float>(x.x, y.x, z.x, 0), // Column 0 (Right vector)
//        SIMD4<Float>(x.y, y.y, z.y, 0), // Column 1 (Up vector)
//        SIMD4<Float>(x.z, y.z, z.z, 0), // Column 2 (Forward vector)
//        SIMD4<Float>(t.x, t.y, t.z, 1)  // Column 3 (Translation)
//    )
//}
//
//// Creates a Y-axis rotation matrix
//func matrix_rotation_y(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians)
//    let s = sin(radians)
//    // Column Major!
//    return matrix_float4x4(
//        SIMD4<Float>( c, 0, s, 0), // Column 0
//        SIMD4<Float>( 0, 1, 0, 0), // Column 1
//        SIMD4<Float>(-s, 0, c, 0), // Column 2
//        SIMD4<Float>( 0, 0, 0, 1)  // Column 3
//    )
//}
//
//// Creates an X-axis rotation matrix
//func matrix_rotation_x(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians)
//    let s = sin(radians)
//    // Column Major!
//    return matrix_float4x4(
//        SIMD4<Float>(1,  0, 0, 0), // Column 0
//        SIMD4<Float>(0,  c, s, 0), // Column 1
//        SIMD4<Float>(0, -s, c, 0), // Column 2
//        SIMD4<Float>(0,  0, 0, 1)  // Column 3
//    )
//}
//
//// Helper for matrix multiplication (simd provides this via the '*' operator)
//func matrix_multiply(_ matrix1: matrix_float4x4, _ matrix2: matrix_float4x4) -> matrix_float4x4 {
//    return matrix1 * matrix2
//}
