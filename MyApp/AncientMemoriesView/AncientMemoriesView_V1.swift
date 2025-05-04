////
////  AncientMemoriesView.swift
////  MyApp
////
////  Created by Cong Le on 5/4/25.
////
//
////
////  GeometricPatternView.swift
////  MetalGeometricPattern
////
////  Created by Your Name on 2024-05-16. // Replace with actual info if desired
////
////  Description:
////  This file defines a SwiftUI view hierarchy that displays a 2D geometric
////  pattern, inspired by the provided screenshot. It uses Apple's Metal framework
////  to render the pattern as line strips.
////  It demonstrates:
////  - Embedding a MetalKit view (MTKView) within SwiftUI using UIViewRepresentable.
////  - Setting up a basic Metal rendering pipeline for 2D lines.
////  - Generating 2D geometry (vertices) for circles/arcs on the CPU.
////  - Using SIMD for data structures.
////  - Sending view size as a uniform to the shader for aspect ratio mapping.
////  - Rendering using line strips.
////
////  NOTE: This implementation focuses on drawing the line structure of the
////        core "Flower of Life" pattern elements visible in the image
////        using Metal line primitives. It does not procedurally generate
////        the fill colors, intricate internal shapes, background grid,
////        or animation as present in the full image.
////
//
//import SwiftUI
//import MetalKit
//import simd // Provides efficient vector types (like SIMD2<Float>, SIMD4<Float>)
//
//// MARK: - Metal Shaders (Embedded String)
//
///// Contains the source code for the Metal vertex and fragment shaders for 2D rendering.
//let patternMetalShaderSource = """
//#include <metal_stdlib>
//
//using namespace metal;
//
//// Structure defining vertex input data from the CPU.
//struct VertexIn {
//    // Position in 0-1 normalized pattern space (XY plane).
//    float2 position [[attribute(0)]];
//    // Vertex color (RGBA).
//    float4 color    [[attribute(1)]];
//};
//
//// Structure passed from vertex shader to fragment shader.
//struct VertexOut {
//    // Final position in clip space.
//    float4 position [[position]];
//    // Color to be interpolated.
//    float4 color;
//};
//
//// Structure for uniform data from the CPU.
//struct Uniforms {
//    // Current drawable size of the MTKView in pixels (width, height).
//    float2 viewSize;
//};
//
//// --- Vertex Shader ---
//// Transforms 0-1 pattern space coordinates to Metal's -1 to +1 clip space,
//// preserving aspect ratio and centering the pattern.
//vertex VertexOut pattern_vertex_shader(
//    const device VertexIn *vertices [[buffer(0)]],
//    const device Uniforms &uniforms [[buffer(1)]],
//    unsigned int vid [[vertex_id]]
//) {
//    VertexOut out;
//    
//    // Get the vertex position (0-1 pattern space)
//    float2 pattern_pos = vertices[vid].position;
//    
//    // Calculate scaling factor based on the minimum dimension to maintain aspect ratio
//    float pattern_scale = min(uniforms.viewSize.x, uniforms.viewSize.y);
//    
//    // Calculate offsets to center the scaled pattern within the view
//    float x_offset = (uniforms.viewSize.x - pattern_scale) * 0.5;
//    float y_offset = (uniforms.viewSize.y - pattern_scale) * 0.5;
//    
//    // Map 0-1 pattern position to screen coordinates scaled by pattern_scale and offset
//    // Note: This maps pattern_pos (0,0) to (x_offset, y_offset) in screen pixels,
//    // and pattern_pos (1,1) to (x_offset + pattern_scale, y_offset + pattern_scale) in screen pixels.
//    float2 screen_pos = pattern_pos * pattern_scale + float2(x_offset, y_offset);
//    
//    // Map screen coordinates (in pixels) to Metal's Normalized Device Coordinates (-1 to +1)
//    float ndc_x = screen_pos.x / uniforms.viewSize.x * 2.0 - 1.0;
//    float ndc_y = screen_pos.y / uniforms.viewSize.y * 2.0 - 1.0;
//    // Invert Y for standard graphics convention where +Y is up in NDC (screen typically measures Y down)
//    ndc_y = -ndc_y;
//    
//    // Output position in clip space (XY for NDC, Z=0 for 2D, W=1)
//    out.position = float4(ndc_x, ndc_y, 0.0, 1.0);
//    
//    // Pass the vertex color to the fragment shader
//    out.color = vertices[vid].color;
//    
//    return out;
//}
//
//// --- Fragment Shader ---
//// Simply outputs the interpolated color received from the vertex shader.
//fragment half4 pattern_fragment_shader(
//    VertexOut in [[stage_in]]
//) {
//    // Return the interpolated color
//    return half4(in.color);
//}
//"""
//
//// MARK: - Swift Data Structures
//
///// Swift structure matching the layout of the 'Uniforms' struct in the Metal shader.
//struct Uniforms {
//    var viewSize: SIMD2<Float> // Viewport width and height in pixels
//}
//
///// Structure defining the layout of vertex data in Swift.
//struct Vertex {
//    // Position (x, y) in a normalized pattern space (0 to 1 range).
//    var position: SIMD2<Float>
//    // RGBA color of the vertex.
//    var color: SIMD4<Float>
//}
//
//// Structure to hold info for drawing each circle segment as a line strip.
//struct CircleDrawInfo {
//    var startIndex: Int // Starting index in the vertex buffer
//    var vertexCount: Int // Number of vertices in this line strip
//}
//
//// MARK: - Renderer Class (Handles Metal Logic)
//
///// Manages Metal setup, geometry, and rendering commands for the pattern.
//class PatternRenderer: NSObject, MTKViewDelegate {
//
//    let device: MTLDevice
//    let commandQueue: MTLCommandQueue
//    var pipelineState: MTLRenderPipelineState!
//    // Depth state is less critical for Z=0 2D drawing, but kept for potential future use or 3D projection.
//    // It ensures consistent behavior when Z coordinates are used.
//    var depthState: MTLDepthStencilState!
//
//    var vertexBuffer: MTLBuffer!
//    var uniformBuffer: MTLBuffer!
//
//    // Data structure to hold vertex data generated on the CPU.
//    private var vertices: [Vertex] = []
//    // Data structure to store drawing information for each circle/line strip.
//    private var circleDrawInfo: [CircleDrawInfo] = []
//    
//    // --- Geometry Generation Parameters ---
//    private let patternSquareSize: Float = 1.0 // The pattern is defined within a 1x1 unit space
//    // The core circle radius within the 1x1 pattern space. Adjust to match image proportions.
//    // The image seems to fit the main structure within a circle slightly smaller than the view edge.
//    // Relating this to the 0-1 space, a radius of 0.25 centered at 0.5,0.5 creates a diameter of 0.5,
//    // scaled by min(W,H), giving half the view's smaller dimension. This looks about right.
//    private let centralRadius: Float = 0.25 * 1.0
//    private let patternCenter: SIMD2<Float> = SIMD2<Float>(0.5, 0.5) // Center of the 0-1 pattern square
//    private let segmentsPerCircle = 80 // Number of line segments approximating each circle
//
//    // Color matching the bright green lines in the screenshot (e.g., #00FF99)
//    private let lineColor: SIMD4<Float> = SIMD4<Float>(0/255.0, 255/255.0, 153/255.0, 1.0)
//
//    /// Initializes the renderer with a Metal device and sets up resources.
//    /// - Parameter device: The `MTLDevice` (GPU connection) to use for rendering.
//    init?(device: MTLDevice) {
//        // Ensure a Metal device is available.
//        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
//             // Log error and return nil if Metal is not supported.
//            print("Error: Metal is not supported on this device.")
//            return nil
//        }
//        self.device = defaultDevice
//        
//        // Create a command queue for submitting work to the GPU.
//        guard let queue = device.makeCommandQueue() else {
//            print("Error: Could not create command queue.")
//            return nil // Initialization failed
//        }
//        self.commandQueue = queue
//        
//        super.init()
//        
//        // Generate the 2D vertex data for the pattern geometry on the CPU.
//        setupGeometry()
//        // Create Metal buffers on the GPU accessible memory from the generated CPU data.
//        setupBuffers()
//        // Setup basic depth/stencil state. This is configured once.
//        setupDepthStencil()
//        
//        print("PatternRenderer initialized successfully.")
//    }
//
//    /// Configures the Metal pipeline state, including compiling shaders and setting
//    /// the vertex descriptor and pixel formats. This is called *after* the `MTKView`
//    /// is created and its drawable formats are known.
//    /// - Parameter metalKitView: The `MTKView` instance this renderer will draw into.
//    func configure(metalKitView: MTKView) {
//        setupPipeline(metalKitView: metalKitView)
//    }
//
//    // --- Setup Functions ---
//
//    /// Generates the vertex data for the core geometric pattern (7 interlocking circles) on the CPU.
//    /// The positions are generated in a 0-1 normalized space.
//    private func setupGeometry() {
//        vertices = []
//        circleDrawInfo = []
//
//        // Helper closure to generate vertices for a single circle approximated by line segments.
//        // Uses a "+1" vertex count to ensure a closed loop when drawing with `.lineStrip`.
//        let generateCircleVertices = { (center: SIMD2<Float>, radius: Float, color: SIMD4<Float>, segments: Int) -> [Vertex] in
//            var circleVerts: [Vertex] = []
//            for i in 0...segments { // Include endpoint for closed line strip
//                let angle = Float.pi * 2 * Float(i) / Float(segments)
//                let x = center.x + radius * cos(angle)
//                let y = center.y + radius * sin(angle)
//                circleVerts.append(Vertex(position: SIMD2<Float>(x, y), color: color))
//            }
//            return circleVerts
//        }
//        
//        // 1. Generate vertices for the Central Circle.
//        let centralCircleVerts = generateCircleVertices(patternCenter, centralRadius, lineColor, segmentsPerCircle)
//        // Store drawing info: starting index in the combined vertex buffer and the number of vertices.
//        circleDrawInfo.append((startIndex: vertices.count, vertexCount: centralCircleVerts.count))
//        // Append the generated vertices to the main vertices array.
//        vertices.append(contentsOf: centralCircleVerts)
//
//        // 2. Generate vertices for the Six Outer Circles.
//        // Their centers are located on the circumference of the Central Circle.
//        for i in 0..<6 {
//            let angle = Float.pi * 2 * Float(i) / 6.0 // Angles for the 6 centers around the central point
//            let centerX = patternCenter.x + centralRadius * cos(angle)
//            let centerY = patternCenter.y + centralRadius * sin(angle)
//            let outerCircleCenter = SIMD2<Float>(centerX, centerY)
//            
//            let outerCircleVerts = generateCircleVertices(outerCircleCenter, centralRadius, lineColor, segmentsPerCircle)
//            circleDrawInfo.append((startIndex: vertices.count, vertexCount: outerCircleVerts.count))
//            vertices.append(contentsOf: outerCircleVerts)
//        }
//        
//        // NOTE: To draw the full pattern from the screenshot, you would add more geometry
//        // generation here for additional layers of circles, intersecting curves, and lines.
//        // This example provides the core structure of the 7 primary circles.
//        
//        print("Geometry generation complete: \(vertices.count) vertices total for \(circleDrawInfo.count) primary circles.")
//    }
//
//    /// Compiles shaders and creates the `MTLRenderPipelineState`.
//    /// This object contains the compiled shader code and render configuration.
//    /// - Parameter metalKitView: The view providing the necessary pixel format information.
//    private func setupPipeline(metalKitView: MTKView) {
//        do {
//            // Create a Metal library from the embedded shader source string.
//            let library = try device.makeLibrary(source: patternMetalShaderSource, options: nil)
//            
//            // Get references to the compiled vertex and fragment shader functions by name.
//            guard let vertexFunction = library.makeFunction(name: "pattern_vertex_shader"),
//                  let fragmentFunction = library.makeFunction(name: "pattern_fragment_shader") else {
//                fatalError("Error: Could not load shader functions from library. Check function names in code and shader string.")
//            }
//
//            // Create a descriptor object to define the pipeline configuration.
//            let pipelineDescriptor = MTLRenderPipelineDescriptor()
//            pipelineDescriptor.label = "Geometric Pattern Pipeline" // Debug label
//            pipelineDescriptor.vertexFunction = vertexFunction      // Assign the vertex shader
//            pipelineDescriptor.fragmentFunction = fragmentFunction  // Assign the fragment shader
//            
//            // Set the pixel formats for the color and depth attachments.
//            // These must match the formats configured for the MTKView.
//            pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
//            pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat // For depth testing
//
//            // --- Configure Vertex Descriptor ---
//            // Describes how the vertex data (`Vertex` struct) is laid out in the vertex buffer.
//            // This must match the `VertexIn` struct in the shader code.
//            let vertexDescriptor = MTLVertexDescriptor()
//
//            // Attribute 0: Position (SIMD2<Float> -> float2 in shader)
//            vertexDescriptor.attributes[0].format = .float2       // Data type is 2 floats
//            vertexDescriptor.attributes[0].offset = 0             // Offset 0 from the start of the struct
//            vertexDescriptor.attributes[0].bufferIndex = 0        // Data comes from the buffer bound at index 0
//
//            // Attribute 1: Color (SIMD4<Float> -> float4 in shader)
//            vertexDescriptor.attributes[1].format = .float4       // Data type is 4 floats
//            // Offset: Starts immediately after the position data. Use MemoryLayout's stride for safety/padding.
//            vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD2<Float>>.stride
//            vertexDescriptor.attributes[1].bufferIndex = 0        // Data comes from the *same* buffer (index 0)
//            
//            // Layout 0: Describes the overall structure of each vertex in the buffer.
//            vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride // Total size of one Vertex struct
//            vertexDescriptor.layouts[0].stepRate = 1              // Read one vertex for each vertex processed by the shader
//            vertexDescriptor.layouts[0].stepFunction = .perVertex // Standard vertex stepping
//
//            pipelineDescriptor.vertexDescriptor = vertexDescriptor // Assign the configured descriptor
//
//             // Specify that this pipeline is intended primarily for drawing lines.
//             // Although the draw call primitive type is the most important factor,
//             // setting this on the descriptor can sometimes help Metal optimize.
//             pipelineDescriptor.primitiveTopology = .line
//
//            // Create the immutable render pipeline state object from the descriptor.
//            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//
//        } catch {
//            // If pipeline creation fails, it's often due to shader compilation errors,
//            // mismatched struct layouts, or incorrect format settings.
//            fatalError("Failed to create Metal Render Pipeline State: \(error)")
//        }
//    }
//
//    /// Creates and populates the GPU buffers for vertex data and uniform data.
//    private func setupBuffers() {
//        // --- Vertex Buffer ---
//        // Ensure we have vertex data before trying to create the buffer.
//        guard !vertices.isEmpty else {
//            fatalError("Error: Vertex data is empty after geometry setup. Cannot create vertex buffer.")
//        }
//        // Calculate the total size required for the vertex buffer in bytes.
//        let vertexDataSize = vertices.count * MemoryLayout<Vertex>.stride
//        // Create the buffer on the GPU, copying the CPU data to it.
//        // `.storageModeShared` allows direct access by both CPU and GPU (common for simple data).
//        guard let vBuffer = device.makeBuffer(bytes: vertices, length: vertexDataSize, options: []) else {
//            fatalError("Error: Could not create vertex buffer for pattern.")
//        }
//        vertexBuffer = vBuffer
//        vertexBuffer.label = "Pattern Vertices" // Debug label
//
//        // --- Uniform Buffer ---
//        // Needs space for the `Uniforms` struct (which currently just holds `viewSize`).
//        let uniformBufferSize = MemoryLayout<Uniforms>.size
//        // Create the buffer. We'll copy data into it later each frame (or when size changes).
//        guard let uBuffer = device.makeBuffer(length: uniformBufferSize, options: .storageModeShared) else {
//            fatalError("Error: Could not create uniform buffer.")
//        }
//        uniformBuffer = uBuffer
//        uniformBuffer.label = "Uniforms Buffer (View Size)" // Debug label
//    }
//
//    /// Creates the `MTLDepthStencilState` object to configure depth testing.
//    /// Although drawing a flat 2D pattern at Z=0 doesn't strictly require complex depth,
//    /// using a basic depth state is good practice for 3D rendering or future extensions.
//    private func setupDepthStencil() {
//         let depthDescriptor = MTLDepthStencilDescriptor()
//        // Fragments with a depth value *less than* the value in the depth buffer will pass.
//        depthDescriptor.depthCompareFunction = .less
//        // Write the depth value of fragments that pass the test to the depth buffer.
//        depthDescriptor.isDepthWriteEnabled = true
//        
//        // Create the immutable state object.
//        guard let state = device.makeDepthStencilState(descriptor: depthDescriptor) else {
//            fatalError("Failed to create depth stencil state")
//        }
//        depthState = state
//    }
//
//    // --- Update State Per Frame ---
//    
//    /// Updates the uniform buffer with the current drawable size of the view.
//    /// This is done to provide the vertex shader with the necessary viewport dimensions
//    /// for correctly mapping the 0-1 pattern coordinates to clip space while
//    /// maintaining aspect ratio.
//    /// - Parameter drawableSize: The current size of the `MTKView`'s drawable texture in pixels.
//    private func updateUniforms(drawableSize: CGSize) {
//        // Ensure the uniform buffer exists.
//        guard let uniformBuffer = uniformBuffer else { return }
//        
//        // Create the uniforms struct with the current view size as SIMD2<Float>.
//        var uniforms = Uniforms(viewSize: SIMD2<Float>(Float(drawableSize.width), Float(drawableSize.height)))
//        
//        // Get a pointer to the start of the uniform buffer's CPU-accessible memory.
//        let bufferPointer = uniformBuffer.contents()
//        // Copy the data from the Swift `uniforms` struct into the buffer's memory.
//        memcpy(bufferPointer, &uniforms, MemoryLayout<Uniforms>.size)
//        
//        // print("Uniforms updated with view size: \(drawableSize.width)x\(drawableSize.height)") // Debug
//    }
//
//    // MARK: - MTKViewDelegate Methods
//
//    /// Called automatically by the `MTKView` whenever its drawable size (resolution) changes.
//    /// This happens when the view is initially displayed and when the device is rotated or the window is resized.
//    /// This method is crucial for updating uniforms or parameters that depend on the view's dimensions.
//    /// - Parameters:
//    ///   - view: The `MTKView` whose size changed.
//    ///   - size: The new drawable size in pixels.
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//         // Update the uniforms buffer with the new drawable size so the vertex shader can use it.
//         updateUniforms(drawableSize: size)
//         print("MTKView drawable size changed to: \(size)")
//    }
//
//    /// Called automatically by the `MTKView` when it's time to draw a new frame.
//    /// This is the main rendering loop entry point.
//    /// - Parameter view: The `MTKView` requesting the drawing update.
//    func draw(in view: MTKView) {
//        // Ensure we have all the necessary Metal objects for this frame.
//        guard let drawable = view.currentDrawable, // The render target texture provided by the view
//              let renderPassDescriptor = view.currentRenderPassDescriptor, // Describes the render targets & actions
//              let commandBuffer = commandQueue.makeCommandBuffer(),      // Buffer to hold our GPU commands
//              // Encoder for rendering commands (like setting pipeline state, binding buffers, drawing)
//              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
//             print("Error: Failed to get essential Metal objects in draw(in:). Skipping frame.")
//            return
//        }
//
//        // --- Configure the Render Pass Actions ---
//        // Specify what to do with the color attachment (the view's texture) at the start/end of the pass.
//        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.05, green: 0.05, blue: 0.08, alpha: 1.0) // Define the background clear color
//        renderPassDescriptor.colorAttachments[0].loadAction = .clear  // Clear the color buffer with the clearColor at the start
//        renderPassDescriptor.colorAttachments[0].storeAction = .store // Store the results to the texture so it can be presented
//
//        // Configure the depth attachment actions.
//        renderPassDescriptor.depthAttachment.clearDepth = 1.0 // Set the default depth value for clearing (farthest)
//        renderPassDescriptor.depthAttachment.loadAction = .clear // Clear the depth buffer at the start
//        renderPassDescriptor.depthAttachment.storeAction = .store // Store the depth results
//
//        // --- Begin Encoding Commands ---
//        renderEncoder.label = "Geometric Pattern Render Encoder" // Debug label
//        renderEncoder.setRenderPipelineState(pipelineState)     // Set the compiled render pipeline state
//        renderEncoder.setDepthStencilState(depthState)           // Set the depth testing state (even if simple Z=0)
//
//        // --- Bind Resources to the Pipeline ---
//        // Make vertex data available to the vertex shader at buffer index 0.
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//        // Make uniform data (view size) available to the vertex shader at buffer index 1.
//        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
//
//        // --- Issue Draw Calls ---
//        // Draw each generated circle/line strip.
//        // We use the `.lineStrip` primitive type, which draws a connected sequence of lines
//        // using the vertices starting from `vertexStart` for `vertexCount`.
//        // No index buffer is needed for `.lineStrip`.
//        guard !circleDrawInfo.isEmpty else {
//             print("Warning: No circle draw info available. Nothing to draw.")
//            renderEncoder.endEncoding() // Still need to end encoding if no draws occurred
//            // commandBuffer.present(drawable) // No need to present if nothing was drawn? Or commit anyway?
//            // commandBuffer.commit()
//            return // Skip the rest if nothing to draw
//        }
//        
//        for drawInfo in circleDrawInfo {
//             renderEncoder.drawPrimitives(type: .lineStrip,
//                                          vertexStart: drawInfo.startIndex, // Start reading vertices from this index
//                                          vertexCount: drawInfo.vertexCount) // Read this many vertices for the line strip
//        }
//
//        // --- End Encoding and Commit ---
//        renderEncoder.endEncoding() // Signal that command encoding for this pass is complete
//
//        // Schedule the drawable texture to be shown on screen after the GPU finishes executing the commands.
//        commandBuffer.present(drawable)
//
//        // Commit the command buffer to the GPU for execution.
//        // Commands are processed asynchronously after this call returns.
//        commandBuffer.commit()
//        
//        // Optional: Wait for completion for debugging synchronous issues (rarely needed and stalls CPU)
//        // commandBuffer.waitUntilCompleted()
//    }
//}
//
//// MARK: - SwiftUI UIViewRepresentable
//
///// A `UIViewRepresentable` struct that bridges the `MTKView` (a UIKit view from MetalKit)
///// into the SwiftUI view hierarchy. This is necessary to embed a Metal drawing surface
///// within a SwiftUI application.
//struct MetalPatternViewRepresentable: UIViewRepresentable {
//    /// Specifies the type of UIKit view that this representable manages.
//    typealias UIViewType = MTKView
//
//    /// Creates the custom `Coordinator` object.
//    /// The coordinator acts as the delegate for the `MTKView` and holds the `PatternRenderer`.
//    /// It's the bridge for communication between the UIKit view and SwiftUI's context.
//    func makeCoordinator() -> PatternRenderer {
//        // Attempt to initialize our custom renderer class.
//        // The renderer's init handles getting the default Metal device.
//        guard let coordinator = PatternRenderer(device: MTLCreateSystemDefaultDevice()!) else { // Force unwrap as renderer checks in init, or add Nil-coalescing / error handling
//            // If the renderer failed to initialize (e.g., no Metal device), fatalError.
//            // In a real app, you might show an error message or alternative content.
//             fatalError("Fatal: PatternRenderer failed to initialize. Metal may not be supported.")
//        }
//        print("Coordinator (PatternRenderer) created.")
//        return coordinator
//    }
//
//    /// Creates and configures the underlying `MTKView` instance.
//    /// This method is called only once by SwiftUI when the view is first added to the hierarchy.
//    /// - Parameter context: Provides access to the `Coordinator` and SwiftUI environment information.
//    /// - Returns: The configured `MTKView`.
//    func makeUIView(context: Context) -> MTKView {
//        let mtkView = MTKView()
//        
//        // --- Configure MTKView Properties ---
//        // Assign the Metal device from the coordinator (Renderer) to the MTKView.
//        // The view needs to know which GPU to render with.
//        mtkView.device = context.coordinator.device
//        
//        // Configure the color format for the output texture the view draws into.
//        mtkView.colorPixelFormat = .bgra8Unorm_srgb // Standard RGBA format, with sRGB for correct color display
//        // Configure the pixel format for the depth/stencil buffer. Essential for 3D rendering or depth-based effects.
//        mtkView.depthStencilPixelFormat = .depth32Float // Request a 32-bit float depth buffer
//        
//        // Set the clear values for the color and depth buffers, used when `loadAction` is `.clear`.
//        mtkView.clearColor = MTLClearColor(red: 0.05, green: 0.05, blue: 0.08, alpha: 1.0) // Dark background from image
//        mtkView.clearDepth = 1.0 // Farthermost depth value
//
//        // Automatic resizing of the underlying drawable texture when the view's size changes.
//        mtkView.autoResizeDrawable = true
//        // Disable the default UIKit `setNeedsDisplay` drawing loop; we'll use the `MTKViewDelegate`'s `draw` method.
//        mtkView.enableSetNeedsDisplay = false
//        // Set the target frame rate. The `draw` delegate method will be called periodically to achieve this.
//        mtkView.preferredFramesPerSecond = 60
//
//        // --- Linking Renderer and View ---
//        // Allow the renderer to perform setup steps that depend on the MTKView's properties (like pixel formats).
//        context.coordinator.configure(metalKitView: mtkView)
//        
//        // Set the renderer (Coordinator) as the delegate for the MTKView.
//        // The MTKView will call the delegate methods (`mtkView`, `draw`).
//        mtkView.delegate = context.coordinator
//
//        // Manually trigger the initial size update call on the delegate *after* setting the delegate.
//        // This ensures that the renderer's uniforms (like view size) are set for the very first draw call.
//        context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
//        
//        print("MTKView created and configured for pattern.")
//        return mtkView
//    }
//
//    /// Updates the `MTKView` when relevant SwiftUI state changes.
//    /// This method is called by SwiftUI whenever the view's configuration needs to be updated
//    /// due to changes in the SwiftUI state that drives it.
//    /// - Parameters:
//    ///   - uiView: The `MTKView` instance being managed.
//    ///   - context: Provides access to the `Coordinator` and environment.
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // In this version, there is no external SwiftUI state controlling the
//        // geometric pattern's appearance directly. If you added SwiftUI controls
//        // (e.g., sliders for color or scale), you would update properties on the
//        // `context.coordinator` (our `PatternRenderer`) here.
//        // print("MetalPatternViewRepresentable updateUIView called.") // Debug
//    }
//}
//
//// MARK: - Main SwiftUI View
//
///// The primary SwiftUI view that structures the UI, embedding the Metal view representable.
//struct GeometricPatternView: View {
//    var body: some View {
//        // Use a VStack to place elements vertically.
//        VStack(spacing: 0) {
//            // Title Text for the view.
//            Text("Geometric Pattern (Metal)")
//                .font(.headline) // Make it a prominent headline
//                .padding()       // Add padding around the text
//                .frame(maxWidth: .infinity) // Make the background span the full width
//                .background(Color(red: 0.05, green: 0.05, blue: 0.08)) // Match the Metal clear color
//                .foregroundColor(.white) // Ensure text is visible on the dark background
//
//            // Embed the Metal View using our UIViewRepresentable.
//            // This representable will take up the remaining space in the VStack.
//            MetalPatternViewRepresentable()
//            
//            // Optionally, you can use .ignoresSafeArea() if you want the Metal view
//            // to extend behind system UI elements like the status bar or home indicator.
//            // .ignoresSafeArea(.all)
//            
//        }
//        // Apply the background color to the entire VStack container. This helps
//        // prevent white flashes during screen transitions or when the view appears.
//        .background(Color(red: 0.05, green: 0.05, blue: 0.08))
//        // Ignore safe area for the keyboard, useful in apps with text fields elsewhere.
//        .ignoresSafeArea(.keyboard)
//    }
//}
//
//// MARK: - Preview Provider
//
///// Provides a preview for the SwiftUI view in Xcode's canvas.
//#Preview {
//     // Option 1: Use a Placeholder View (Recommended for Previews with Metal)
//     // Metal views can sometimes be unstable or crash in SwiftUI previews,
//     // especially in the canvas drawing mode. A simple placeholder provides
//     // visual feedback without requiring Metal to run.
//     /* Uncomment this block and comment out Option 2 below to use the safe placeholder.
//    struct PatternPreviewPlaceholder: View {
//        var body: some View {
//            VStack {
//                Text("Geometric Pattern (Metal)")
//                    .font(.headline)
//                    .padding()
//                    .foregroundColor(.white)
//                
//                Spacer() // Spacers push the text to the center
//                
//                Text("Metal View Placeholder\n(Run on Simulator or Device to see pattern)")
//                    .foregroundColor(.gray)
//                    .italic()
//                    .multilineTextAlignment(.center)
//                    .padding()
//                
//                Spacer()
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity) // Make placeholder fill the preview area
//            .background(Color(red: 0.05, green: 0.05, blue: 0.08)) // Match the expected background color
//            .edgesIgnoringSafeArea(.all) // Extend placeholder background to safe areas
//        }
//    }
//    return PatternPreviewPlaceholder()
//      */
//
//    // Option 2: Attempt to Render the Actual Metal View
//    // Uncomment the line below and comment out Option 1 above if you want to
//    // try rendering the real Metal view in the preview canvas. Be aware this
//    // might not always work reliably depending on your Xcode/OS version
//    // and can sometimes cause preview crashes. It's usually reliable when
//    // running the app on a simulator or device.
//    return GeometricPatternView()
//}
//
//// MARK: - Original Octahedron Code (Provided but not used for pattern rendering)
//// The following code was part of the original user prompt's example but
//// is NOT used by the GeometricPatternView above, which renders a different 2D shape.
//// It is included here, commented out, for reference purposes only as requested
//// by the user to review the "entire documentation and Swift code implementation below as a whole".
///*
// 
// // MARK: - Metal Shaders (Embedded String) - Octahedron Example
// // Kept for reference, not used by PatternRenderer
// let octahedronMetalShaderSource_Reference = """
// #include <metal_stdlib> // Import the Metal Standard Library
// // (shader code for octahedron vertex/fragment functions goes here)
// """
// 
// // MARK: - Swift Data Structures (Matching Shaders) - Octahedron Example
// // Kept for reference, not used by PatternRenderer
// struct Uniforms_OctahedronReference {
// var modelViewProjectionMatrix: matrix_float4x4
// }
// 
// struct OctahedronVertex_Reference {
// var position: SIMD3<Float>
// var color: SIMD4<Float>
// }
// 
// // MARK: - Renderer Class (Handles Metal Logic) - Octahedron Example
// // Kept for reference, not used by PatternRenderer
// class OctahedronRenderer_Reference: NSObject, MTKViewDelegate {
// // (Metal objects, geometry, init, setup functions, etc. for Octahedron go here)
// 
// // MTKViewDelegate Methods
// // func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { ... }
// // func draw(in view: MTKView) { ... }
// }
// 
// // MARK: - SwiftUI UIViewRepresentable - Octahedron Example
// // Kept for reference, not used by PatternRenderer
// struct MetalOctahedronViewRepresentable_Reference: UIViewRepresentable {
// // typealias UIViewType = MTKView
// // func makeCoordinator() -> OctahedronRenderer_Reference { ... }
// // func makeUIView(context: Context) -> MTKView { ... }
// // func updateUIView(_ uiView: MTKView, context: Context) { ... }
// }
// 
// // MARK: - Main SwiftUI View - Octahedron Example
// // Kept for reference, not used by PatternRenderer
// struct OctahedronView_Reference: View {
// // var body: some View { ... }
// }
// 
// // MARK: - Matrix Math Helper Functions (using SIMD) - Octahedron Example
// // Kept for reference, not used by PatternRenderer's 2D rendering
// /*
// func matrix_perspective_left_hand(...) -> matrix_float4x4 { ... }
// func matrix_look_at_left_hand(...) -> matrix_float4x4 { ... }
// func matrix_rotation_y(...) -> matrix_float4x4 { ... }
// func matrix_rotation_x(...) -> matrix_float4x4 { ... }
// func matrix_multiply(_: _: ) -> matrix_float4x4 { ... }
// */
// 
// */
