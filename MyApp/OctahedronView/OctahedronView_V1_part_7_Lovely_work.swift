////
////  OctahedronView_V1_part_7.swift
////  MyApp
////
////  Created by Cong Le on 5/3/25.
////
//
////  Description:
////  This file defines a SwiftUI view hierarchy that displays a 3D rotating
////  wireframe octahedron rendered using Apple's Metal framework. It demonstrates:
////  - Embedding a MetalKit view (MTKView) within SwiftUI using UIViewRepresentable.
////  - Setting up a basic Metal rendering pipeline (shaders, buffers, pipeline state).
////  - Defining geometry (vertices, indices) for an octahedron.
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
//let octahedronMetalShaderSource = """
//#include <metal_stdlib> // Import the Metal Standard Library
//
//using namespace metal; // Use the Metal namespace
//
//// Structure defining vertex input data received from the CPU (Swift code).
//// The layout *must* match the 'OctahedronVertex' struct in Swift and the MTLVertexDescriptor.
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
//vertex VertexOut octahedron_vertex_shader(
//    // Input: Array of vertices passed from the CPU's vertex buffer.
//    // [[buffer(0)]] links this to the buffer bound at index 0 by the Render Encoder.
//    const device VertexIn *vertices [[buffer(0)]],
//    // Input: Uniform data (MVP matrix) from the CPU's uniform buffer.
//    // [[buffer(1)]] links this to the buffer bound at index 1.
//    const device Uniforms &uniforms [[buffer(1)]],
//    // Input: System-generated index of the current vertex being processed.
//    unsigned int vid [[vertex_id]]
//) {
//    // Prepare the output structure
//    VertexOut out;
//    
//    // Get the current vertex data using the vertex ID
//    VertexIn currentVertex = vertices[vid]; // Access the vertex data for this specific vertex index
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
//fragment half4 octahedron_fragment_shader(
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
//struct OctahedronVertex {
//    /// The 3D position (x, y, z) of the vertex in model space.
//    var position: SIMD3<Float>
//    /// The RGBA color associated with the vertex.
//    var color: SIMD4<Float>
//}
//
//// MARK: - Renderer Class (Handles Metal Logic)
//
///// Manages all Metal-specific setup, resource creation, and rendering logic.
///// Conforms to `MTKViewDelegate` to respond to view size changes and draw calls.
//class OctahedronRenderer: NSObject, MTKViewDelegate {
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
//    /// GPU buffer holding the octahedron's vertex data (`OctahedronVertex` array).
//    var vertexBuffer: MTLBuffer!
//    /// GPU buffer holding the indices that define the octahedron's triangles (`UInt16` array).
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
//    /// Array defining the 6 vertices of the octahedron. Each vertex has a position and a color.
//    let vertices: [OctahedronVertex] = [
//        // Vertex Format: OctahedronVertex(position: SIMD3<Float>(x, y, z), color: SIMD4<Float>(r, g, b, a))
//        
//        // Top Apex (at +Y) - Green
//        OctahedronVertex(position: SIMD3<Float>(0, 1, 0), color: SIMD4<Float>(0, 1, 0, 1)), // Index 0
//        
//        // Vertices in the XZ plane (Y=0) - Forming the "equator"
//        OctahedronVertex(position: SIMD3<Float>(1, 0, 0), color: SIMD4<Float>(1, 0, 0, 1)), // Index 1: +X direction (Red)
//        OctahedronVertex(position: SIMD3<Float>(0, 0, 1), color: SIMD4<Float>(0, 0, 1, 1)), // Index 2: +Z direction (Blue)
//        OctahedronVertex(position: SIMD3<Float>(-1, 0, 0), color: SIMD4<Float>(1, 1, 0, 1)),// Index 3: -X direction (Yellow)
//        OctahedronVertex(position: SIMD3<Float>(0, 0, -1), color: SIMD4<Float>(0, 1, 1, 1)),// Index 4: -Z direction (Cyan)
//        
//        // Bottom Apex (at -Y) - Magenta
//        OctahedronVertex(position: SIMD3<Float>(0, -1, 0), color: SIMD4<Float>(1, 0, 1, 1)) // Index 5
//    ]
//
//    /// Array of indices defining the 8 triangular faces of the octahedron.
//    /// Each sequence of 3 indices references vertices from the `vertices` array to form a triangle.
//    /// The order (winding) determines the front face (counter-clockwise is typical).
//    let indices: [UInt16] = [
//        // Top pyramid faces (connecting top apex '0' to the equator vertices '1,2,3,4')
//        0, 1, 2,   // Top-Front-Right Triangle
//        0, 2, 3,   // Top-Back-Right Triangle
//        0, 3, 4,   // Top-Back-Left Triangle
//        0, 4, 1,   // Top-Front-Left Triangle
//        
//        // Bottom pyramid faces (connecting bottom apex '5' to the equator vertices '1,2,3,4')
//        // Note: Order adjusted to maintain counter-clockwise winding from outside view
//        5, 2, 1,   // Bottom-Front-Right Triangle
//        5, 3, 2,   // Bottom-Back-Right Triangle
//        5, 4, 3,   // Bottom-Back-Left Triangle
//        5, 1, 4    // Bottom-Front-Left Triangle
//    ]
//    // --- End Geometry Data ---
//    
//    /// Initializes the renderer with a Metal device.
//    /// Sets up essential Metal objects like the command queue and buffers.
//    /// Fails if Metal device or command queue creation fails.
//    /// - Parameter device: The `MTLDevice` (GPU connection) to use for rendering.
//    init?(device: MTLDevice) {
//        self.device = device
//        // Create a command queue for submitting work to the GPU
//        guard let queue = device.makeCommandQueue() else {
//            print("Could not create command queue")
//            return nil // Initialization failed
//        }
//        self.commandQueue = queue
//        super.init()
//        
//        // Setup resources that don't depend on the MTKView's drawable format yet
//        setupBuffers()        // Create vertex, index, and uniform buffers
//        setupDepthStencil()   // Configure depth testing state
//    }
//
//    /// Configures the Metal pipeline state. This is called *after* the `MTKView` is created,
//    /// as the pipeline needs to know the view's pixel formats (color, depth/stencil).
//    /// - Parameter metalKitView: The `MTKView` instance this renderer will draw into.
//    func configure(metalKitView: MTKView) {
//        setupPipeline(metalKitView: metalKitView)
//    }
//
//    // --- Setup Functions ---
//
//    /// Compiles shaders and creates the `MTLRenderPipelineState`.
//    /// This object encapsulates the compiled shaders and fixed-function states (like blending, vertex layout).
//    /// - Parameter metalKitView: The view providing the necessary pixel format information.
//    func setupPipeline(metalKitView: MTKView) {
//        do {
//            // Create a Metal library from the embedded shader source code string.
//            let library = try device.makeLibrary(source: octahedronMetalShaderSource, options: nil)
//            
//            // Get references to the compiled vertex and fragment shader functions.
//            guard let vertexFunction = library.makeFunction(name: "octahedron_vertex_shader"),
//                  let fragmentFunction = library.makeFunction(name: "octahedron_fragment_shader") else {
//                fatalError("Could not load shader functions from library. Check function names.")
//            }
//
//            // Create a descriptor to configure the render pipeline state.
//            let pipelineDescriptor = MTLRenderPipelineDescriptor()
//            pipelineDescriptor.label = "Wireframe Octahedron Pipeline"
//            pipelineDescriptor.vertexFunction = vertexFunction     // Assign the compiled vertex shader
//            pipelineDescriptor.fragmentFunction = fragmentFunction // Assign the compiled fragment shader
//            
//            // Set the pixel formats for the render targets (attachments).
//            // These *must* match the MTKView's configured formats.
//            pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
//            pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat // For depth testing
//
//            // --- Configure Vertex Descriptor ---
//            // Describes how vertex data (`OctahedronVertex`) is organized in the vertex buffer.
//            // This *must* match the `VertexIn` struct in the shader.
//            let vertexDescriptor = MTLVertexDescriptor()
//
//            // Attribute 0: Position (float3)
//            vertexDescriptor.attributes[0].format = .float3       // Data type is 3 floats
//            vertexDescriptor.attributes[0].offset = 0             // Starts at the beginning of the struct
//            vertexDescriptor.attributes[0].bufferIndex = 0        // Data comes from buffer bound at index 0
//
//            // Attribute 1: Color (float4)
//            vertexDescriptor.attributes[1].format = .float4       // Data type is 4 floats
//            // Offset: Starts after the position data. `stride` gives the size including padding.
//            vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
//            vertexDescriptor.attributes[1].bufferIndex = 0        // Data comes from the *same* buffer (index 0)
//            
//            // Layout 0: Describes the overall vertex structure stride (size).
//            // Specifies how the GPU should step through the buffer to find the next vertex.
//            vertexDescriptor.layouts[0].stride = MemoryLayout<OctahedronVertex>.stride
//            vertexDescriptor.layouts[0].stepRate = 1              // Advance once per vertex
//            vertexDescriptor.layouts[0].stepFunction = .perVertex // Standard vertex stepping
//
//            pipelineDescriptor.vertexDescriptor = vertexDescriptor // Assign the configured descriptor
//
//            // Create the immutable render pipeline state object from the descriptor.
//            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//
//        } catch {
//            // If pipeline creation fails, it's usually due to shader compilation errors,
//            // mismatched struct layouts, or incorrect format settings.
//            fatalError("Failed to create Metal Render Pipeline State: \(error)")
//        }
//    }
//
//    /// Creates and populates the GPU buffers for vertices, indices, and uniforms.
//    func setupBuffers() {
//        // --- Vertex Buffer ---
//        let vertexDataSize = vertices.count * MemoryLayout<OctahedronVertex>.stride
//        guard let vBuffer = device.makeBuffer(bytes: vertices, length: vertexDataSize, options: []) else {
//            fatalError("Could not create vertex buffer")
//        }
//        vertexBuffer = vBuffer
//        vertexBuffer.label = "Octahedron Vertices" // Debug label
//
//        // --- Index Buffer ---
//        let indexDataSize = indices.count * MemoryLayout<UInt16>.stride // Indices are UInt16
//        guard let iBuffer = device.makeBuffer(bytes: indices, length: indexDataSize, options: []) else {
//            fatalError("Could not create index buffer")
//        }
//        indexBuffer = iBuffer
//        indexBuffer.label = "Octahedron Indices" // Debug label
//
//        // --- Uniform Buffer ---
//        // Size based on the Swift 'Uniforms' struct, ensuring enough space for the MVP matrix.
//        let uniformBufferSize = MemoryLayout<Uniforms>.size
//        // Use .storageModeShared for buffers frequently updated by the CPU and read by the GPU.
//        guard let uBuffer = device.makeBuffer(length: uniformBufferSize, options: .storageModeShared) else {
//            fatalError("Could not create uniform buffer")
//        }
//        uniformBuffer = uBuffer
//        uniformBuffer.label = "Uniforms Buffer (MVP Matrix)" // Debug label
//    }
//
//    /// Creates the `MTLDepthStencilState` object to configure depth testing.
//    func setupDepthStencil() {
//        let depthDescriptor = MTLDepthStencilDescriptor()
//        // Compare incoming fragment depth with existing depth buffer value.
//        // If the new fragment is closer (depth is less), it passes.
//        depthDescriptor.depthCompareFunction = .less
//        // Allow writing the depth of passed fragments to the depth buffer.
//        depthDescriptor.isDepthWriteEnabled = true
//        
//        guard let state = device.makeDepthStencilState(descriptor: depthDescriptor) else {
//            fatalError("Failed to create depth stencil state")
//        }
//        depthState = state
//    }
//
//    // --- Update State Per Frame ---
//    
//    /// Calculates the Model-View-Projection (MVP) matrix and updates the uniform buffer.
//    /// This is called each frame before drawing to position and orient the octahedron.
//    func updateUniforms() {
//        // 1. Projection Matrix: Defines the viewing frustum (how 3D space maps to 2D screen).
//        //    Uses a left-handed perspective projection.
//        let projectionMatrix = matrix_perspective_left_hand(
//            fovyRadians: Float.pi / 3.0, // Vertical field of view (60 degrees)
//            aspectRatio: aspectRatio,    // View's width-to-height ratio
//            nearZ: 0.1,                  // Near clipping plane distance
//            farZ: 100.0                  // Far clipping plane distance
//        )
//
//        // 2. View Matrix: Defines the camera's position and orientation in world space.
//        //    Uses a left-handed look-at matrix.
//        let viewMatrix = matrix_look_at_left_hand(
//            eye: SIMD3<Float>(0, 0.5, -4), // Camera positioned slightly up and back from origin
//            center: SIMD3<Float>(0, 0, 0),  // Looking directly at the origin (where the octahedron is)
//            up: SIMD3<Float>(0, 1, 0)       // Defines the 'up' direction (positive Y axis)
//        )
//
//        // 3. Model Matrix: Defines the object's position, rotation, and scale in world space.
//        //    Applies rotations around Y and X axes based on the current rotationAngle.
//        let rotationY = matrix_rotation_y(radians: rotationAngle)
//        let rotationX = matrix_rotation_x(radians: rotationAngle * 0.5) // Rotate slower on X
//        let modelMatrix = matrix_multiply(rotationY, rotationX) // Combine rotations (order matters)
//
//        // 4. Combine Matrices: MVP = Projection * View * Model
//        //    Order is important! Transforms model space -> world space -> view space -> clip space.
//        let modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix)
//        let mvpMatrix = matrix_multiply(projectionMatrix, modelViewMatrix)
//
//        // 5. Update Uniform Buffer: Copy the final MVP matrix into the GPU buffer.
//        var uniforms = Uniforms(modelViewProjectionMatrix: mvpMatrix)
//        // Get a mutable pointer to the buffer's memory content.
//        let bufferPointer = uniformBuffer.contents()
//        // Copy the data from the Swift 'uniforms' struct into the buffer memory.
//        memcpy(bufferPointer, &uniforms, MemoryLayout<Uniforms>.size)
//        
//        // 6. Animate: Increment the rotation angle for the next frame.
//        rotationAngle += 0.01 // Adjust this value to change rotation speed.
//    }
//
//    // MARK: - MTKViewDelegate Methods
//
//    /// Called automatically whenever the `MTKView`'s drawable size (resolution) changes.
//    /// Essential for updating the projection matrix's aspect ratio.
//    /// - Parameters:
//    ///   - view: The `MTKView` whose size changed.
//    ///   - size: The new drawable size in pixels.
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        // Calculate the new aspect ratio. Avoid division by zero if height is 0.
//        aspectRatio = Float(size.width / max(1, size.height))
//        print("MTKView Resized - New Aspect Ratio: \(aspectRatio)") // Debug output
//    }
//
//    /// Called automatically for each frame, responsible for encoding rendering commands.
//    /// - Parameter view: The `MTKView` requesting the drawing update.
//    func draw(in view: MTKView) {
//        // 1. Obtain necessary objects for rendering this frame.
//        guard let drawable = view.currentDrawable, // The texture to draw into
//              let renderPassDescriptor = view.currentRenderPassDescriptor, // Describes render targets, clear colors, depth settings
//              let commandBuffer = commandQueue.makeCommandBuffer(), // Buffer to hold encoded commands
//              // Encoder for rendering commands within this pass
//              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
//             print("Failed to get required Metal objects in draw(in:). Skipping frame.")
//            return
//        }
//
//        // --- Per-Frame Updates ---
//        updateUniforms() // Calculate and upload the latest MVP matrix
//
//        // --- Configure Render Encoder ---
//        renderEncoder.label = "Octahedron Render Encoder" // Debug label
//        renderEncoder.setRenderPipelineState(pipelineState) // Use the compiled pipeline state
//        renderEncoder.setDepthStencilState(depthState) // Enable depth testing per fragment
//
//        // *** Set Render Mode to Wireframe ***
//        // This tells the GPU to render the edges of triangles instead of filling them.
//        renderEncoder.setTriangleFillMode(.lines)
//
//        // --- Bind Buffers ---
//        // Make buffers accessible to the shaders. Indices match [[buffer(n)]] in shader code.
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0) // Vertex data at buffer index 0
//        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1) // Uniform data (MVP) at buffer index 1
//
//        // --- Issue Draw Call ---
//        // Instruct the GPU to draw the octahedron using the vertices and indices provided.
//        renderEncoder.drawIndexedPrimitives(type: .triangle,           // Draw primitives composed of triangles
//                                            indexCount: indices.count,   // Number of indices to process (determines triangles)
//                                            indexType: .uint16,         // Data type of indices in the index buffer
//                                            indexBuffer: indexBuffer,     // Buffer containing the indices
//                                            indexBufferOffset: 0)      // Start reading indices from the beginning
//
//        // --- Finalize ---
//        renderEncoder.endEncoding() // Signal that command encoding for this pass is complete
//
//        // Schedule the drawable to be presented on screen after the command buffer completes execution.
//        commandBuffer.present(drawable)
//
//        // Commit the command buffer to the GPU for execution.
//        commandBuffer.commit()
//        // Optional: Wait for completion for debugging synchronous issues (rarely needed)
//        // commandBuffer.waitUntilCompleted()
//    }
//}
//
//// MARK: - SwiftUI UIViewRepresentable
//
///// A `UIViewRepresentable` struct that bridges the `MTKView` (from UIKit/MetalKit) into the SwiftUI view hierarchy.
//struct MetalOctahedronViewRepresentable: UIViewRepresentable {
//    /// The type of UIKit view this representable manages.
//    typealias UIViewType = MTKView
//
//    /// Creates the custom `Coordinator` object.
//    /// The coordinator acts as the delegate for the `MTKView` and holds the `OctahedronRenderer`.
//    func makeCoordinator() -> OctahedronRenderer {
//        // Get the default system GPU device.
//        guard let device = MTLCreateSystemDefaultDevice() else {
//            fatalError("Metal is not supported on this device.")
//        }
//        // Initialize our custom renderer class.
//        guard let coordinator = OctahedronRenderer(device: device) else {
//            fatalError("OctahedronRenderer failed to initialize.")
//        }
//        print("Coordinator (OctahedronRenderer) created.")
//        return coordinator
//    }
//
//    /// Creates and configures the underlying `MTKView` instance.
//    /// This is called only once when the view is first added to the SwiftUI hierarchy.
//    /// - Parameter context: Provides access to the `Coordinator` and other contextual information.
//    /// - Returns: The configured `MTKView`.
//    func makeUIView(context: Context) -> MTKView {
//        let mtkView = MTKView()
//        
//        // --- Configuration ---
//        // Assign the Metal device from the coordinator (Renderer) to the view.
//        mtkView.device = context.coordinator.device
//        
//        // Performance settings
//        mtkView.preferredFramesPerSecond = 60 // Target frame rate
//        // Use the delegate's draw method automatically instead of needing explicit calls.
//        mtkView.enableSetNeedsDisplay = false
//        
//        // *** Essential for 3D: Configure Depth Buffer ***
//        mtkView.depthStencilPixelFormat = .depth32Float // Request a 32-bit float depth buffer
//        mtkView.clearDepth = 1.0 // Default clear value for depth (farthest)
//
//        // Standard view appearance
//        // Set the background color (cleared each frame)
//        mtkView.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
//        // Set the format for the color texture the view draws into.
//        mtkView.colorPixelFormat = .bgra8Unorm_srgb // Common format, sRGB for correct color display
//
//        // --- Linking Renderer and View ---
//        // Allow the renderer to configure its pipeline based on the view's pixel formats now.
//        context.coordinator.configure(metalKitView: mtkView)
//        
//        // Set the renderer (Coordinator) as the view's delegate AFTER the view is configured.
//        mtkView.delegate = context.coordinator
//
//        // Manually trigger the initial size update call in the delegate.
//        // This ensures the aspect ratio is correct before the very first draw call might occur.
//        context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
//        
//        print("MTKView created and configured.")
//        return mtkView
//    }
//
//    /// Updates the `MTKView` when relevant SwiftUI state changes.
//    /// Not needed in this example as there's no SwiftUI state driving the Metal view's appearance directly.
//    /// - Parameters:
//    ///   - uiView: The `MTKView` instance being managed.
//    ///   - context: Provides access to the `Coordinator` and environment.
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // No external state updates are handled here in this version.
//        // If SwiftUI controls (like sliders for rotation speed) were added,
//        // they would update properties on the coordinator (renderer) here.
//    }
//}
//
//// MARK: - Main SwiftUI View
//
///// The primary SwiftUI view that structures the UI, including the title and the Metal view.
//struct OctahedronView: View {
//    var body: some View {
//        // Use a VStack to place the title above the Metal view.
//        // `spacing: 0` prevents unwanted gaps between elements.
//        VStack(spacing: 0) {
//            // Title Text
//            Text("Rotating Wireframe Octahedron (Metal)")
//                .font(.headline)
//                .padding() // Add some space around the text itself
//                .frame(maxWidth: .infinity) // Ensure background spans the full width
//                .background(Color(red: 0.1, green: 0.1, blue: 0.15)) // Match Metal clear color
//                .foregroundColor(.white) // Make text visible against dark background
//
//            // Embed the Metal View using the UIViewRepresentable
//            MetalOctahedronViewRepresentable()
//            // The representable will automatically take up the available space
//            // in the VStack below the Text.
//            
//            // Consider `.ignoresSafeArea()` if you want the Metal view
//            // to extend into safe areas (like under the home indicator).
//            // .ignoresSafeArea(.all)
//        }
//        // Apply background color to the entire VStack container to avoid white flashes during transitions.
//        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
//        // Good practice, especially if text fields could appear elsewhere.
//        .ignoresSafeArea(.keyboard)
//    }
//}
//
//// MARK: - Preview Provider
//
//#Preview {
//    // Option 1: Use a Placeholder View (Safer for Previews)
//    // Metal views often don't render correctly or can crash SwiftUI previews.
//    // This placeholder provides visual feedback in the canvas without running Metal.
//    struct PreviewPlaceholder: View {
//        var body: some View {
//            VStack {
//                Text("Rotating Wireframe Octahedron (Metal)")
//                    .font(.headline)
//                    .padding()
//                    .foregroundColor(.white)
//                
//                Spacer() // Use Spacers to center the placeholder text
//                
//                Text("Metal View Placeholder\n(Run on Simulator or Device)")
//                    .foregroundColor(.gray)
//                    .italic()
//                    .multilineTextAlignment(.center)
//                    .padding()
//                
//                Spacer()
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill preview area
//            .background(Color(red: 0.1, green: 0.1, blue: 0.15)) // Match expected BG
//            .edgesIgnoringSafeArea(.all)
//        }
//    }
//    // return PreviewPlaceholder() // <-- Uncomment this line to use the safe placeholder
//
//    // Option 2: Attempt to Render the Actual Metal View (May Fail)
//    // Uncomment the line below AND comment out `return PreviewPlaceholder()` above
//    // if you want to try rendering the real view in the preview canvas.
//    return OctahedronView()
//}
//
//// MARK: - Matrix Math Helper Functions (using SIMD)
//// These functions create standard transformation matrices used in 3D graphics.
//// They are defined for a LEFT-HANDED coordinate system, which is common in Metal.
//
///// Creates a perspective projection matrix (Left-Handed).
///// Maps 3D view space coordinates into 3D clip space coordinates (-1 to 1 range).
///// - Parameters:
/////   - fovyRadians: Vertical field of view angle in radians.
/////   - aspectRatio: Width / Height of the viewport.
/////   - nearZ: Distance to the near clipping plane (must be > 0).
/////   - farZ: Distance to the far clipping plane.
///// - Returns: A 4x4 perspective projection matrix.
//func matrix_perspective_left_hand(fovyRadians: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
//    let y = 1.0 / tan(fovyRadians * 0.5) // Scale factor based on field of view
//    let x = y / aspectRatio            // Scale factor adjusted for aspect ratio
//    let z = farZ / (farZ - nearZ)      // Maps Z depth to [0, 1] range before W division
//    let w = -nearZ * z                 // Term for Z mapping
//
//    // Remember simd matrices are column-major
//    return matrix_float4x4(
//        // Column 0       Column 1       Column 2       Column 3
//        SIMD4<Float>(x, 0, 0, 0), SIMD4<Float>(0, y, 0, 0), SIMD4<Float>(0, 0, z, 1), SIMD4<Float>(0, 0, w, 0)
//    )
//}
//
///// Creates a view matrix (Left-Handed) to position and orient the camera.
///// Transforms world space coordinates into view space coordinates (relative to the camera).
///// - Parameters:
/////   - eye: The position of the camera (viewer) in world space.
/////   - center: The point in world space the camera is looking at.
/////   - up: The direction vector indicating 'up' relative to the camera (usually (0, 1, 0)).
///// - Returns: A 4x4 view matrix.
//func matrix_look_at_left_hand(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> matrix_float4x4 {
//    // Calculate the camera's coordinate system axes
//    let zAxis = normalize(center - eye) // Forward direction (vector from eye to center)
//    let xAxis = normalize(cross(up, zAxis)) // Right direction (perpendicular to up and forward)
//    let yAxis = cross(zAxis, xAxis)      // Recalculated Up direction (perpendicular to forward and right)
//    
//    // Calculate the translation part of the view matrix
//    let translateX = -dot(xAxis, eye)
//    let translateY = -dot(yAxis, eye)
//    let translateZ = -dot(zAxis, eye)
//
//    // Construct the column-major matrix
//    return matrix_float4x4(
//        // Column 0 (Right) Column 1 (Up)   Column 2 (Fwd) Column 3 (Translation)
//        SIMD4<Float>( xAxis.x,  yAxis.x,  zAxis.x, 0),
//        SIMD4<Float>( xAxis.y,  yAxis.y,  zAxis.y, 0),
//        SIMD4<Float>( xAxis.z,  yAxis.z,  zAxis.z, 0),
//        SIMD4<Float>(translateX, translateY, translateZ, 1)
//    )
//}
//
///// Creates a rotation matrix for rotation around the Y-axis.
///// - Parameter radians: The angle of rotation in radians.
///// - Returns: A 4x4 rotation matrix.
//func matrix_rotation_y(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians)
//    let s = sin(radians)
//    // Remember: Column Major!
//    return matrix_float4x4(
//        // Col 0        Col 1       Col 2        Col 3
//        SIMD4<Float>( c, 0, s, 0), SIMD4<Float>( 0, 1, 0, 0), SIMD4<Float>(-s, 0, c, 0), SIMD4<Float>( 0, 0, 0, 1)
//    )
//}
//
///// Creates a rotation matrix for rotation around the X-axis.
///// - Parameter radians: The angle of rotation in radians.
///// - Returns: A 4x4 rotation matrix.
//func matrix_rotation_x(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians)
//    let s = sin(radians)
//    // Remember: Column Major!
//    return matrix_float4x4(
//        // Col 0        Col 1       Col 2        Col 3
//        SIMD4<Float>(1,  0, 0, 0), SIMD4<Float>(0,  c, s, 0), SIMD4<Float>(0, -s, c, 0), SIMD4<Float>(0,  0, 0, 1)
//    )
//}
//
///// Multiplies two 4x4 matrices.
///// The `simd` library overloads the `*` operator for matrix multiplication.
///// - Parameters:
/////   - matrix1: The first matrix (left side of multiplication).
/////   - matrix2: The second matrix (right side of multiplication).
///// - Returns: The resulting 4x4 matrix.
//func matrix_multiply(_ matrix1: matrix_float4x4, _ matrix2: matrix_float4x4) -> matrix_float4x4 {
//    // Matrix multiplication order matters: matrix1 * matrix2 is generally not matrix2 * matrix1
//    return matrix1 * matrix2
//}
