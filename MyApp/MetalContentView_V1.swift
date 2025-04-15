////
////  MetalContentView.swift
////  MyApp
////
////  Created by Cong Le on 4/11/25.
////
//
//import SwiftUI
//import MetalKit // Import MetalKit for MTKView
//
//// MARK: - Metal Shaders (Embedded as Strings)
//
//let metalShaderSource = """
//using namespace metal;
//
//// Structure to define vertex data (position and color)
//struct Vertex {
//    float4 position [[position]]; // Output position for rasterizer
//    float4 color;             // Color associated with the vertex
//};
//
//// Structure defining the data passed from vertex to fragment shader
//struct VertexOut {
//    float4 position [[position]]; // Output position (required)
//    float4 color;             // Interpolated color for the fragment
//};
//
//// ---- Vertex Shader ----
//// Takes vertex data and a uniform time variable as input
//// Outputs transformed position and vertex color
//vertex VertexOut vertex_main(
//                             uint vertexID [[vertex_id]], // Built-in vertex identifier
//                             constant float3 *vertices [[buffer(0)]], // Input vertex positions
//                             constant float4 *colors [[buffer(1)]], // Input vertex colors
//                             constant float &time [[buffer(2)]] // Input uniform time
//                            )
//{
//    VertexOut out;
//
//    // Basic animation: Rotate the triangle based on time
//    float angle = time * 0.5; // Slower rotation speed
//    float cosA = cos(angle);
//    float sinA = sin(angle);
//
//    // Simple 2D rotation matrix applied in Z=0 plane
//    float4 pos = float4(vertices[vertexID], 1.0);
//    pos.x = pos.x * cosA - pos.y * sinA;
//    pos.y = pos.x * sinA + pos.y * cosA; // Note: using original pos.x for y calculation is common for simple rotation
//
//    out.position = pos;
//    out.color = colors[vertexID]; // Pass the original color through
//    return out;
//}
//
//// ---- Fragment Shader ----
//// Takes the interpolated data from the vertex shader (VertexOut)
//// Outputs the final color for the pixel/fragment
//fragment float4 fragment_main(VertexOut in [[stage_in]]) // Input is interpolated data
//{
//    // Output the interpolated color directly
//    return in.color;
//}
//"""
//
//// MARK: - Metal Renderer Class
//
//class MetalRenderer: NSObject {
//    let device: MTLDevice
//    let commandQueue: MTLCommandQueue
//    var pipelineState: MTLRenderPipelineState
//    var vertexBuffer: MTLBuffer
//    var colorBuffer: MTLBuffer
//    var timeBuffer: MTLBuffer // Buffer for the time uniform
//
//    var time: Float = 0.0 // Variable to hold the current time for animation
//
//    // Initializer
//    init?(mtkView: MTKView) {
//        // 1. Get Metal Device
//        guard let device = MTLCreateSystemDefaultDevice() else {
//            print("Metal is not supported on this device")
//            return nil
//        }
//        self.device = device
//        mtkView.device = device // Assign device to the view
//
//        // 2. Create Command Queue
//        guard let commandQueue = device.makeCommandQueue() else {
//            print("Could not create Metal command queue")
//            return nil
//        }
//        self.commandQueue = commandQueue
//
//        // 3. Define vertices for a triangle (centered, coordinates from -1 to 1)
//         let vertices: [SIMD3<Float>] = [
//             SIMD3<Float>( 0.0,  0.5, 0.0), // Top vertex
//             SIMD3<Float>(-0.5, -0.5, 0.0), // Bottom-left vertex
//             SIMD3<Float>( 0.5, -0.5, 0.0)  // Bottom-right vertex
//         ]
//
//         // Define colors for each vertex (Red, Green, Blue)
//         let colors: [SIMD4<Float>] = [
//             SIMD4<Float>(1.0, 0.0, 0.0, 1.0), // Red
//             SIMD4<Float>(0.0, 1.0, 0.0, 1.0), // Green
//             SIMD4<Float>(0.0, 0.0, 1.0, 1.0)  // Blue
//         ]
//
//        // 4. Create Vertex and Color Buffers in GPU memory
//        guard let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<SIMD3<Float>>.stride, options: []) else {
//            print("Could not create vertex buffer")
//            return nil
//        }
//        self.vertexBuffer = vertexBuffer
//
//        guard let colorBuffer = device.makeBuffer(bytes: colors, length: colors.count * MemoryLayout<SIMD4<Float>>.stride, options: []) else {
//            print("Could not create color buffer")
//            return nil
//        }
//        self.colorBuffer = colorBuffer
//
//        // 5. Create Time Buffer (initially zero)
//        guard let timeBuffer = device.makeBuffer(length: MemoryLayout<Float>.stride, options: .storageModeShared) else {
//             print("Could not create time buffer")
//             return nil
//        }
//        self.timeBuffer = timeBuffer
//
//        // 6. Load Shaders and Create Pipeline State
//        do {
//            // Create a Metal library from the embedded shader string
//            let library = try device.makeLibrary(source: metalShaderSource, options: nil)
//
//            // Get the vertex and fragment function objects
//            guard let vertexFunction = library.makeFunction(name: "vertex_main") else {
//                 print("Could not find vertex function")
//                 return nil
//            }
//            guard let fragmentFunction = library.makeFunction(name: "fragment_main") else {
//                print("Could not find fragment function")
//                return nil
//            }
//
//            // Create pipeline descriptor
//            let pipelineDescriptor = MTLRenderPipelineDescriptor()
//            pipelineDescriptor.vertexFunction = vertexFunction
//            pipelineDescriptor.fragmentFunction = fragmentFunction
//            // Pixel format must match the MTKView's pixel format
//            pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
//
//            // Create the pipeline state object (compiled shaders and rendering config)
//            self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//
//        } catch {
//            print("Error creating Metal pipeline state: \(error)")
//            return nil
//        }
//
//        super.init()
//    }
//
//    // Called by the Coordinator's draw(in:) method
//    func draw(in view: MTKView) {
//        // 1. Get necessary objects for drawing
//        guard let drawable = view.currentDrawable, // The texture to draw into
//              let renderPassDescriptor = view.currentRenderPassDescriptor, // Configures the render pass (e.g., clear color)
//              let commandBuffer = commandQueue.makeCommandBuffer(), // Buffer to hold GPU commands
//              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) // Encoder for render commands
//        else {
//            print("Could not get drawable, descriptor, command buffer, or render encoder")
//            return
//        }
//
//        // --- Update Time ---
//        // Simple increment, wrap around if needed (not shown here)
//        time += 0.016 // Assuming roughly 60 FPS
//        // Update the time buffer on the GPU
//        let timePtr = timeBuffer.contents().bindMemory(to: Float.self, capacity: 1)
//        timePtr[0] = time
//
//        // --- Configure Render Encoder ---
//        renderEncoder.setRenderPipelineState(pipelineState) // Use our compiled shaders/state
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0) // Bind vertex data to buffer index 0 in shader
//        renderEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)  // Bind color data to buffer index 1 in shader
//        renderEncoder.setVertexBuffer(timeBuffer, offset: 0, index: 2) // Bind time data to buffer index 2 in shader
//
//        // --- Issue Draw Call ---
//        // Draw 3 vertices (forming one triangle)
//        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
//
//        // --- Finalize ---
//        renderEncoder.endEncoding() // Finish encoding render commands
//
//        // --- Present Drawable ---
//        commandBuffer.present(drawable) // Schedule the drawable to be shown on screen
//
//        // --- Commit Command Buffer ---
//        commandBuffer.commit() // Send the commands to the GPU for execution
//        commandBuffer.waitUntilCompleted() // Wait for completion (useful for simple examples, often managed differently in complex apps)
//    }
//}
//
//// MARK: - Coordinator (MTKViewDelegate)
//
//class Coordinator: NSObject, MTKViewDelegate {
//    var parent: MetalViewRepresentable
//    var renderer: MetalRenderer
//
//    init(_ parent: MetalViewRepresentable, renderer: MetalRenderer) {
//        self.parent = parent
//        self.renderer = renderer
//        super.init()
//    }
//
//    // Called whenever the view size changes
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        // Handle view resizing if necessary (e.g., update projection matrix)
//        // For this simple example, Metal handles viewport scaling automatically based on drawable size
//        print("MTKView size changed to: \(size)")
//    }
//
//    // Called every frame to perform drawing
//    func draw(in view: MTKView) {
//        renderer.draw(in: view) // Delegate drawing to the renderer class
//    }
//}
//
//// MARK: - UIViewRepresentable for Metal View
//
//struct MetalViewRepresentable: UIViewRepresentable {
//
//    // Creates the MTKView and the Coordinator
//    func makeUIView(context: Context) -> MTKView {
//        let mtkView = MTKView()
//
//        // Attempt to create the Metal Renderer
//        guard let renderer = MetalRenderer(mtkView: mtkView) else {
//            fatalError("MetalRenderer could not be initialized") // Or handle more gracefully
//        }
//
//        // Assign the renderer to the coordinator
//        context.coordinator.renderer = renderer
//        // Set the coordinator as the MTKView's delegate
//        mtkView.delegate = context.coordinator
//
//        // Configure MTKView properties
//        mtkView.enableSetNeedsDisplay = false // We want continuous drawing for animation
//        mtkView.isPaused = false          // Don't pause rendering
//        // You might want to set mtkView.preferredFramesPerSecond here
//
//        // Set clear color (background color when cleared each frame)
//        mtkView.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0) // Dark grey
//
//        return mtkView
//    }
//
//    // Updates the view (not needed for this simple example)
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // Data from SwiftUI can be passed down here and updates applied
//        // to the renderer via the coordinator if needed.
//    }
//
//    // Creates the Coordinator instance
//    func makeCoordinator() -> Coordinator {
//        // Create a placeholder renderer initially; will be replaced in makeUIView
//        // This avoids needing an optional renderer in Coordinator if init? fails later
//        // Alternatively, make Coordinator's renderer optional, or handle failure differently.
//        guard let placeholderDevice = MTLCreateSystemDefaultDevice(),
//              let placeholderRenderer = MetalRenderer(mtkView: MTKView(frame: .zero, device: placeholderDevice)) else {
//             fatalError("Could not create placeholder renderer for coordinator")
//         }
//       return Coordinator(self, renderer: placeholderRenderer)
//   }
//}
//
//// MARK: - SwiftUI Content View
//
//struct MetalContentView: View {
//    var body: some View {
//        VStack {
//            Text("Metal Triangle in SwiftUI")
//                .font(.title)
//                .padding(.top)
//
//            MetalViewRepresentable() // Embed the Metal view
//                .frame(maxWidth: .infinity, maxHeight: .infinity) // Allow it to expand
//                .ignoresSafeArea() // Optional: Render into safe areas
//        }
//        .background(Color(white: 0.1)) // Match Metal view background for seamless look
//        .edgesIgnoringSafeArea(.bottom) // Extend background color
//    }
//}
//
//// MARK: - Preview Provider
//
//struct MetalContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        MetalContentView()
//    }
//}
//
//// MARK: - App Entry Point (Uncomment if this is the main file)
///*
//@main
//struct MetalSwiftUIApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
//*/
//
