////
////  TheFruitOfLifeView.swift
////  MyApp
////
////  Created by Cong Le on 5/3/25.
////
//
////  Description:
////  This file defines a SwiftUI view that displays the "Fruit of Life"
////  geometric pattern using Apple's Metal framework. It demonstrates:
////  - Embedding MTKView in SwiftUI via UIViewRepresentable.
////  - Basic Metal setup (device, command queue).
////  - Defining geometry for a base circle mesh.
////  - Using Metal Instancing to draw multiple circles efficiently.
////  - Defining instance-specific data (position, color - though color is uniform here).
////  - Creating vertex, index, instance, and uniform buffers.
////  - Writing Metal Shading Language (MSL) shaders for instanced drawing.
////  - Configuring MTLRenderPipelineState with vertex and instance descriptors.
////  - Using an orthographic projection for 2D rendering.
////  - Drawing the 13 circles that form the Fruit of Life pattern.
////
//import SwiftUI
//import MetalKit // Provides MTKView and Metal integration helpers
//import simd    // Provides efficient vector and matrix types/operations
//
//// MARK: - Metal Shaders (Embedded String)
//
///// Contains the source code for the Metal vertex and fragment shaders for Fruit of Life.
///// Uses instancing to draw multiple circles.
//let fruitOfLifeMetalShaderSource = """
//#include <metal_stdlib> // Import the Metal Standard Library
//
//using namespace metal; // Use the Metal namespace
//
//// --- Data Structures (Matching Swift) ---
//
//// Structure for vertex data of the base circle mesh.
//struct CircleVertexIn {
//    // Position relative to the circle's center (in model space, typically range -1 to 1).
//    float2 position [[attribute(0)]];
//};
//
//// Structure for instance-specific data. One per circle drawn.
//struct InstanceData {
//    // Center position of this specific circle instance in world/view space.
//    float2 centerPosition [[attribute(1)]];
//    // Color for this instance (can be unique per instance if needed).
//    float4 color          [[attribute(2)]];
//    // Could also add radius here if instances have different sizes.
//};
//
//// Structure for uniform data (constants applied to all instances in a draw call).
//struct Uniforms {
//    // Orthographic projection matrix (2D view).
//    float4x4 projectionMatrix;
//    // Radius for all circle instances.
//    float radius;
//};
//
//// Structure defining data passed from the vertex shader to the fragment shader.
//struct VertexOut {
//    // Final position in clip space (required output). [[position]] designates this.
//    float4 position [[position]];
//    // Color to be interpolated for the fragment shader.
//    float4 color;
//};
//
//// --- Vertex Shader ---
//// Processes each vertex of the base mesh for each instance.
//vertex VertexOut fruit_of_life_vertex_shader(
//    // Input: Base circle mesh vertex data. [[buffer(0)]].
//    const device CircleVertexIn *vertexArray [[buffer(0)]],
//    // Input: Array of instance data (centers, colors). [[buffer(1)]].
//    const device InstanceData *instanceArray [[buffer(1)]],
//    // Input: Uniform data (projection matrix, radius). [[buffer(2)]].
//    const device Uniforms &uniforms [[buffer(2)]],
//    // Input: Index of the current vertex in the base mesh.
//    ushort vid [[vertex_id]],
//    // Input: Index of the current instance being processed.
//    ushort iid [[instance_id]]
//) {
//    VertexOut out; // Prepare output
//
//    // Get the base vertex position for the current vertex ID.
//    float2 basePosition = vertexArray[vid].position;
//
//    // Get the data for the current instance ID.
//    InstanceData currentInstance = instanceArray[iid];
//
//    // Calculate the world/view position of this vertex for this specific instance:
//    // Instance Center + (Base Vertex Position * Radius)
//    float2 worldPosition = currentInstance.centerPosition + (basePosition * uniforms.radius);
//
//    // Transform the 2D world/view position to 3D clip space using the orthographic projection matrix.
//    // We set z=0, w=1 for 2D orthographic projection.
//    out.position = uniforms.projectionMatrix * float4(worldPosition, 0.0, 1.0);
//
//    // Pass the instance's color to the fragment shader.
//    out.color = currentInstance.color;
//
//    return out; // Return the processed vertex data
//}
//
//// --- Fragment Shader ---
//// Processes each pixel fragment generated during rasterization.
//fragment half4 fruit_of_life_fragment_shader(
//    // Input: Interpolated data from the vertex shader.
//    VertexOut in [[stage_in]]
//) {
//    // Simply return the interpolated color received from the vertex shader.
//    return half4(in.color);
//}
//"""
//
//// MARK: - Swift Data Structures (Matching Shaders)
//
///// Uniform data structure for Swift, matching MSL `Uniforms`.
//struct FruitOfLifeUniforms {
//    var projectionMatrix: matrix_float4x4
//    var radius: Float
//}
//
///// Base circle vertex data structure for Swift, matching MSL `CircleVertexIn`.
//struct CircleVertex {
//    var position: SIMD2<Float> // x, y
//}
//
///// Instance-specific data structure for Swift, matching MSL `InstanceData`.
//struct FruitOfLifeInstance {
//    var centerPosition: SIMD2<Float> // x, y
//    var color: SIMD4<Float>          // r, g, b, a
//}
//
//// MARK: - Renderer Class (Handles Metal Logic)
//
///// Manages Metal setup, resources, and rendering for the Fruit of Life pattern.
//class FruitOfLifeRenderer: NSObject, MTKViewDelegate {
//    
//    let device: MTLDevice
//    let commandQueue: MTLCommandQueue
//    var pipelineState: MTLRenderPipelineState!
//    // Note: Depth state might not be strictly necessary for perfect 2D circles
//    // if draw order doesn't matter, but good practice if shapes might overlap complexly.
//    // Let's keep it simple for now and omit it unless overlap issues arise.
//    // var depthState: MTLDepthStencilState!
//    
//    // Buffers
//    var vertexBuffer: MTLBuffer!       // For the base circle mesh vertices
//    var indexBuffer: MTLBuffer!        // For the base circle mesh indices
//    var instanceBuffer: MTLBuffer!     // For the 13 circle instances' data
//    var uniformBuffer: MTLBuffer!      // For projection matrix and radius
//    
//    // Geometry Data
//    var baseCircleVertices: [CircleVertex] = []
//    var baseCircleIndices: [UInt16] = []
//    let circleSegmentCount = 64 // Number of segments for smoothness
//    
//    var fruitOfLifeInstances: [FruitOfLifeInstance] = []
//    let fruitCircleRadius: Float = 0.9 // Radius of individual circles in the pattern
//    
//    var viewSize: CGSize = .zero // Keep track of view size for projection
//    
//    /// Initializer
//    init?(device: MTLDevice) {
//        self.device = device
//        guard let queue = device.makeCommandQueue() else {
//            print("Could not create command queue")
//            return nil
//        }
//        self.commandQueue = queue
//        super.init()
//        
//        // Generate geometry and setup initial instance positions
//        generateBaseCircleGeometry()
//        calculateFruitOfLifePositions()
//        
//        // Setup buffers (vertex, index, instance, uniform)
//        setupBuffers()
//        // setupDepthStencil() // Omitted for simplicity initially
//    }
//    
//    /// Generates vertices and indices for a unit circle (radius 1) centered at origin.
//    func generateBaseCircleGeometry() {
//        baseCircleVertices.removeAll()
//        baseCircleIndices.removeAll()
//        
//        // Center vertex for triangle fan
//        baseCircleVertices.append(CircleVertex(position: SIMD2<Float>(0, 0))) // Index 0
//        
//        // Outer vertices
//        let angleStep = (2.0 * Float.pi) / Float(circleSegmentCount)
//        for i in 0...circleSegmentCount { // Include last point to close the circle visually if needed
//            let angle = Float(i) * angleStep
//            baseCircleVertices.append(CircleVertex(position: SIMD2<Float>(cos(angle), sin(angle))))
//        }
//        
//        // Triangle Fan Indices (0, 1, 2; 0, 2, 3; ... 0, n, 1)
//        for i in 1...circleSegmentCount {
//            baseCircleIndices.append(0) // Center vertex
//            baseCircleIndices.append(UInt16(i))
//            baseCircleIndices.append(UInt16(i % circleSegmentCount + 1)) // Wrap around for the last triangle
//        }
//        print("Generated Base Circle: \(baseCircleVertices.count) vertices, \(baseCircleIndices.count) indices")
//    }
//    
//    /// Calculates the center positions for the 13 Fruit of Life circles.
//    /// Uses hexagonal grid logic. Assumes radius between centers is `2 * fruitCircleRadius`.
//    func calculateFruitOfLifePositions() {
//        // --- Initial Calculation Attempt (Using Angles/Rings) ---
//        // Let's keep the direct append method as the primary one,
//        // as the fallback calculation was incomplete anyway.
//        
//        fruitOfLifeInstances.removeAll() // Start fresh each time this function is called
//        
//        let radius = fruitCircleRadius // Visual radius of each circle
//        let spacing = radius // Distance from center to center along axes (adjust if needed for packing)
//        let R = spacing * 2.0 // Use spacing * 2 as the characteristic distance between centers based on Flower of Life logic
//        
//        // Predefined color for all circles (light blue like the diagram)
//        let circleColor = SIMD4<Float>(0.678, 0.847, 0.902, 1.0) // R, G, B, A (light blue)
//        
//        // Calculate positions using the known pattern structure directly from Flower of Life centers
//        
//        // Center (1)
//        fruitOfLifeInstances.append(FruitOfLifeInstance(centerPosition: SIMD2<Float>(0, 0), color: circleColor))
//        
//        // Inner Ring (6 circles) - Distance = R from center
//        for i in 0..<6 {
//            let angle = Float(i) * .pi / 3.0 // 0, 60, 120, 180, 240, 300 degrees
//            fruitOfLifeInstances.append(FruitOfLifeInstance(centerPosition: SIMD2<Float>(R * cos(angle), R * sin(angle)), color: circleColor))
//        }
//        
//        // Outer Ring (6 circles) - centers of circles *adjacent* to the center one in Flower of Life
//        // Distance = R * sqrt(3.0) from origin, angles offset by 30 deg
//        for i in 0..<6 {
//            let angle = Float(i) * .pi / 3.0 + .pi / 6.0 // 30, 90, 150, 210, 270, 330 degrees
//            let dist = R * sqrt(3.0) // Distance for these outer centers relative to true center
//            fruitOfLifeInstances.append(FruitOfLifeInstance(centerPosition: SIMD2<Float>(dist * cos(angle), dist * sin(angle)), color: circleColor))
//        }
//        
//        // --- Verification (Optional, but good practice) ---
//        if fruitOfLifeInstances.count != 13 {
//            print("Error: Generated \(fruitOfLifeInstances.count) instances, expected 13. Check calculation logic.")
//            // Potential fallback or error state here if needed
//        }
//        
//        print("Calculated \(fruitOfLifeInstances.count) Fruit of Life instance positions.")
//        
//    }
//    
//    /// Configures the Metal pipeline state (shaders, vertex descriptors).
//    func configure(metalKitView: MTKView) {
//        do {
//            let library = try device.makeLibrary(source: fruitOfLifeMetalShaderSource, options: nil)
//            guard let vertexFunction = library.makeFunction(name: "fruit_of_life_vertex_shader"),
//                  let fragmentFunction = library.makeFunction(name: "fruit_of_life_fragment_shader") else {
//                fatalError("Could not load shader functions from library.")
//            }
//            
//            let pipelineDescriptor = MTLRenderPipelineDescriptor()
//            pipelineDescriptor.label = "Fruit of Life Instanced Pipeline"
//            pipelineDescriptor.vertexFunction = vertexFunction
//            pipelineDescriptor.fragmentFunction = fragmentFunction
//            pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
//            // pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat // Omitted for now
//            
//            // --- Configure Vertex Descriptors (Base Mesh + Instances) ---
//            let vertexDescriptor = MTLVertexDescriptor()
//            
//            // == Layout for Base Circle Vertices (Buffer 0) ==
//            // Attribute 0: Base position (float2)
//            vertexDescriptor.attributes[0].format = .float2
//            vertexDescriptor.attributes[0].offset = 0
//            vertexDescriptor.attributes[0].bufferIndex = 0 // Corresponds to [[buffer(0)]]
//            
//            // Define stride for Layout 0
//            vertexDescriptor.layouts[0].stride = MemoryLayout<CircleVertex>.stride
//            vertexDescriptor.layouts[0].stepRate = 1              // Advance per vertex
//            vertexDescriptor.layouts[0].stepFunction = .perVertex
//            
//            // == Layout for Instance Data (Buffer 1) ==
//            // Attribute 1: Instance center position (float2)
//            vertexDescriptor.attributes[1].format = .float2
//            vertexDescriptor.attributes[1].offset = MemoryLayout.offset(of: \FruitOfLifeInstance.centerPosition)!
//            vertexDescriptor.attributes[1].bufferIndex = 1 // Corresponds to [[buffer(1)]]
//            
//            // Attribute 2: Instance color (float4)
//            vertexDescriptor.attributes[2].format = .float4
//            vertexDescriptor.attributes[2].offset = MemoryLayout.offset(of: \FruitOfLifeInstance.color)!
//            vertexDescriptor.attributes[2].bufferIndex = 1 // Also from buffer 1
//            
//            // Define stride for Layout 1 (instance data)
//            vertexDescriptor.layouts[1].stride = MemoryLayout<FruitOfLifeInstance>.stride
//            vertexDescriptor.layouts[1].stepRate = 1               // Advance per instance
//            vertexDescriptor.layouts[1].stepFunction = .perInstance // Crucial for instancing!
//            
//            pipelineDescriptor.vertexDescriptor = vertexDescriptor
//            
//            // Create the immutable pipeline state
//            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//            print("Render pipeline state created.")
//            
//        } catch {
//            fatalError("Failed to create Fruit of Life Render Pipeline State: \(error)")
//        }
//    }
//    
//    /// Creates and populates GPU buffers.
//    func setupBuffers() {
//        // --- Vertex Buffer (Base Circle Mesh) ---
//        let vertexDataSize = baseCircleVertices.count * MemoryLayout<CircleVertex>.stride
//        guard let vBuffer = device.makeBuffer(bytes: baseCircleVertices, length: vertexDataSize, options: []) else {
//            fatalError("Could not create vertex buffer")
//        }
//        vertexBuffer = vBuffer
//        vertexBuffer.label = "Base Circle Vertices"
//        
//        // --- Index Buffer (Base Circle Mesh) ---
//        let indexDataSize = baseCircleIndices.count * MemoryLayout<UInt16>.stride
//        guard let iBuffer = device.makeBuffer(bytes: baseCircleIndices, length: indexDataSize, options: []) else {
//            fatalError("Could not create index buffer")
//        }
//        indexBuffer = iBuffer
//        indexBuffer.label = "Base Circle Indices"
//        
//        // --- Instance Buffer (Positions & Colors) ---
//        let instanceDataSize = fruitOfLifeInstances.count * MemoryLayout<FruitOfLifeInstance>.stride
//        // Use storageModeShared if we might update instance data from CPU later (e.g., animation)
//        guard let instBuffer = device.makeBuffer(bytes: fruitOfLifeInstances, length: instanceDataSize, options: .storageModeShared) else {
//            fatalError("Could not create instance buffer")
//        }
//        instanceBuffer = instBuffer
//        instanceBuffer.label = "Fruit of Life Instances"
//        
//        // --- Uniform Buffer (Projection Matrix & Radius) ---
//        let uniformBufferSize = MemoryLayout<FruitOfLifeUniforms>.stride // Ensure stride not size for alignment
//        guard let uBuffer = device.makeBuffer(length: uniformBufferSize, options: .storageModeShared) else {
//            fatalError("Could not create uniform buffer")
//        }
//        uniformBuffer = uBuffer
//        uniformBuffer.label = "Uniforms (Projection + Radius)"
//        print("Buffers created.")
//    }
//    
//    /* // Depth Stencil Setup (if needed later)
//     func setupDepthStencil() {
//     let depthDescriptor = MTLDepthStencilDescriptor()
//     depthDescriptor.depthCompareFunction = .less
//     depthDescriptor.isDepthWriteEnabled = true
//     guard let state = device.makeDepthStencilState(descriptor: depthDescriptor) else {
//     fatalError("Failed to create depth stencil state")
//     }
//     depthState = state
//     }
//     */
//    
//    /// Calculates the orthographic projection matrix and updates the uniform buffer.
//    func updateUniforms() {
//        // Determine bounds based on the calculated instance positions to ensure all fit.
//        // Find min/max x and y from instance centers.
//        var minX: Float = 0, maxX: Float = 0, minY: Float = 0, maxY: Float = 0
//        if let first = fruitOfLifeInstances.first {
//            minX = first.centerPosition.x; maxX = first.centerPosition.x
//            minY = first.centerPosition.y; maxY = first.centerPosition.y
//        }
//        for instance in fruitOfLifeInstances {
//            minX = min(minX, instance.centerPosition.x)
//            maxX = max(maxX, instance.centerPosition.x)
//            minY = min(minY, instance.centerPosition.y)
//            maxY = max(maxY, instance.centerPosition.y)
//        }
//        // Add radius to bounds to ensure circle edges are visible
//        minX -= fruitCircleRadius; maxX += fruitCircleRadius
//        minY -= fruitCircleRadius; maxY += fruitCircleRadius
//        
//        // Make the view slightly larger than the content bounds
//        let padding: Float = 0.5
//        minX -= padding; maxX += padding; minY -= padding; maxY += padding
//        
//        // Ensure the aspect ratio of the projection matches the view's aspect ratio
//        let currentAspectRatio = Float(viewSize.width / max(1, viewSize.height))
//        let contentWidth = maxX - minX
//        let contentHeight = maxY - minY
//        let contentAspectRatio = contentWidth / max(1, contentHeight)
//        
//        var left, right, bottom, top: Float
//        if contentAspectRatio > currentAspectRatio {
//            // Content is wider than view aspect ratio, adjust height
//            let desiredHeight = contentWidth / currentAspectRatio
//            let heightAdjust = (desiredHeight - contentHeight) / 2.0
//            left = minX
//            right = maxX
//            bottom = minY - heightAdjust
//            top = maxY + heightAdjust
//        } else {
//            // Content is taller or equal aspect ratio, adjust width
//            let desiredWidth = contentHeight * currentAspectRatio
//            let widthAdjust = (desiredWidth - contentWidth) / 2.0
//            left = minX - widthAdjust
//            right = maxX + widthAdjust
//            bottom = minY
//            top = maxY
//        }
//        
//        let nearZ: Float = -1.0 // Can be anything for ortho, defines clipping planes
//        let farZ: Float = 1.0
//        
//        // Create orthographic projection matrix (Left-Handed)
//        let projectionMatrix = matrix_orthographic_left_hand(left: left, right: right, bottom: bottom, top: top, nearZ: nearZ, farZ: farZ)
//        
//        // Update Uniform Buffer
//        var uniforms = FruitOfLifeUniforms(projectionMatrix: projectionMatrix, radius: fruitCircleRadius)
//        let bufferPointer = uniformBuffer.contents()
//        memcpy(bufferPointer, &uniforms, MemoryLayout<FruitOfLifeUniforms>.stride) // Use STRIDE for safety
//    }
//    
//    // MARK: - MTKViewDelegate Methods
//    
//    /// Called when the MTKView's size changes. Updates the projection.
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        // Store the new size and recalculate projection matrix for the next frame.
//        if size != .zero && size != viewSize {
//            viewSize = size
//            print("MTKView Resized to: \(size)")
//            // updateUniforms() will be called in the next draw anyway
//        }
//    }
//    
//    /// Called for each frame to encode rendering commands.
//    func draw(in view: MTKView) {
//        guard let drawable = view.currentDrawable,
//              let renderPassDescriptor = view.currentRenderPassDescriptor, // Using view's default RP descriptor
//              let commandBuffer = commandQueue.makeCommandBuffer(),
//              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
//            print("Failed to get required Metal objects in draw(in:). Skipping frame.")
//            return
//        }
//        
//        // Update uniforms based on current view size (important for ortho projection)
//        updateUniforms()
//        
//        renderEncoder.label = "Fruit of Life Render Encoder"
//        renderEncoder.setRenderPipelineState(pipelineState)
//        // renderEncoder.setDepthStencilState(depthState) // If using depth testing
//        
//        // Bind Buffers (Update indices to match shader)
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)   // Base vertices at [[buffer(0)]]
//        renderEncoder.setVertexBuffer(instanceBuffer, offset: 0, index: 1) // Instance data at [[buffer(1)]]
//        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 2)  // Uniforms at [[buffer(2)]]
//        
//        // Issue Instanced Draw Call
//        renderEncoder.drawIndexedPrimitives(type: .triangle,            // Primitives are triangles (from base mesh)
//                                            indexCount: baseCircleIndices.count, // Indices per instance
//                                            indexType: .uint16,          // Index type
//                                            indexBuffer: indexBuffer,      // Index buffer for base mesh
//                                            indexBufferOffset: 0,
//                                            instanceCount: fruitOfLifeInstances.count) // Draw 13 instances!
//        
//        renderEncoder.endEncoding()
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
//}
//
//// MARK: - SwiftUI UIViewRepresentable
//
///// Bridges MTKView for Fruit of Life rendering into SwiftUI.
//struct MetalFruitOfLifeViewRepresentable: UIViewRepresentable {
//    typealias UIViewType = MTKView
//    
//    func makeCoordinator() -> FruitOfLifeRenderer {
//        guard let device = MTLCreateSystemDefaultDevice() else {
//            fatalError("Metal is not supported on this device.")
//        }
//        guard let coordinator = FruitOfLifeRenderer(device: device) else {
//            fatalError("FruitOfLifeRenderer failed to initialize.")
//        }
//        print("Coordinator (FruitOfLifeRenderer) created.")
//        return coordinator
//    }
//    
//    func makeUIView(context: Context) -> MTKView {
//        let mtkView = MTKView()
//        mtkView.device = context.coordinator.device
//        mtkView.preferredFramesPerSecond = 60 // Static drawing, could be lower
//        mtkView.enableSetNeedsDisplay = false // Use delegate draw method
//        mtkView.clearColor = MTLClearColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1.0) // Light background
//        mtkView.colorPixelFormat = .bgra8Unorm_srgb
//        // mtkView.depthStencilPixelFormat = .depth32Float // If enabling depth testing
//        
//        // Configure pipeline AFTER view's formats are known
//        context.coordinator.configure(metalKitView: mtkView)
//        mtkView.delegate = context.coordinator
//        
//        // Trigger initial size update
//        context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
//        
//        print("MTKView created and configured for Fruit of Life.")
//        return mtkView
//    }
//    
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // No external state updates handled in this version.
//    }
//}
//
//// MARK: - Main SwiftUI View
//
///// The SwiftUI view that displays the Fruit of Life Metal rendering.
//struct FruitOfLifeView: View {
//    var body: some View {
//        VStack(spacing: 0) {
//            Text("The Fruit of Life (Metal)")
//                .font(.headline)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color(red: 0.9, green: 0.9, blue: 0.94)) // Slightly darker for title BG
//                .foregroundColor(Color.primary.opacity(0.7))
//            
//            // Embed the Metal View
//            MetalFruitOfLifeViewRepresentable()
//            // Ensures the Metal view uses the light background color too
//                .background(Color(red: 0.95, green: 0.95, blue: 0.98))
//        }
//        .background(Color(red: 0.95, green: 0.95, blue: 0.98)) // Background for the whole VStack
//        .ignoresSafeArea(.keyboard)
//        // Use .edgesIgnoringSafeArea(.all) if you want it fullscreen
//        // .edgesIgnoringSafeArea(.all)
//    }
//}
//
//// MARK: - Preview Provider
//
//#Preview {
//    // Use a placeholder for previews as Metal often doesn't work well here.
//    struct PreviewPlaceholder: View {
//        var body: some View {
//            VStack {
//                Text("The Fruit of Life (Metal)")
//                    .font(.headline)
//                    .padding()
//                    .foregroundColor(Color.primary.opacity(0.7))
//                Spacer()
//                Text("Metal View Placeholder\n(Run on Simulator or Device)")
//                    .foregroundColor(.gray)
//                    .italic()
//                    .multilineTextAlignment(.center)
//                    .padding()
//                Spacer()
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color(red: 0.95, green: 0.95, blue: 0.98))
//            .edgesIgnoringSafeArea(.all)
//        }
//    }
//    //return PreviewPlaceholder()
//    
//    // Uncomment below to TRY rendering the real view in Preview (might fail)
//    return FruitOfLifeView()
//}
//
//// MARK: - Matrix Math Helper Functions (Orthographic)
//
///// Creates an orthographic projection matrix (Left-Handed).
///// Maps 3D view space coordinates directly to clip space without perspective distortion.
///// Used for 2D rendering or isometric views.
///// - Parameters:
/////   - left: Coordinate of the left vertical clipping plane.
/////   - right: Coordinate of the right vertical clipping plane.
/////   - bottom: Coordinate of the bottom horizontal clipping plane.
/////   - top: Coordinate of the top horizontal clipping plane.
/////   - nearZ: Distance to the near depth clipping plane.
/////   - farZ: Distance to the far depth clipping plane.
///// - Returns: A 4x4 orthographic projection matrix.
//func matrix_orthographic_left_hand(left: Float, right: Float, bottom: Float, top: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
//    let lr = 1.0 / (right - left)
//    let bt = 1.0 / (top - bottom)
//    let nf = 1.0 / (farZ - nearZ)
//    
//    // Construct column-major matrix
//    return matrix_float4x4(
//        // Column 0            Column 1            Column 2      Column 3
//        SIMD4<Float>(2.0 * lr,         0,                  0,            0),         // Scale X
//        SIMD4<Float>(       0, 2.0 * bt,                  0,            0),         // Scale Y
//        SIMD4<Float>(       0,        0,               1.0 * nf,        0),         // Scale Z (often 1.0*nf) - Check convention if needed
//        SIMD4<Float>( -(left + right) * lr, -(top + bottom) * bt, -nearZ * nf, 1)   // Translate X, Y, Z
//    )
//}
