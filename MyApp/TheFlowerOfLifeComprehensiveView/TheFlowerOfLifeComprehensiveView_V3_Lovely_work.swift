////
////  TheFlowerOfLifeComprehensiveView.swift
////  MyApp
////
////  Created by Cong Le on 5/3/25.
////
//
////  Description:
////  This file defines a SwiftUI view that displays an animated construction
////  of the Flower of Life pattern using Apple's Metal framework. It demonstrates:
////  - Embedding an MTKView within SwiftUI using UIViewRepresentable.
////  - Basic Metal pipeline for 2D drawing.
////  - Defining geometry for a circle (line strip).
////  - Using Instanced Drawing to render multiple circles efficiently.
////  - Passing instance-specific data (position, scale, alpha) to the GPU.
////  - Passing time-based uniform data to drive animation.
////  - Animating the sequential appearance of circles forming the Seed and Flower of Life.
////
//import SwiftUI
//import MetalKit
//import simd
//
//// MARK: - Metal Shaders (Flower of Life)
//
//let flowerOfLifeMetalShaderSource = """
//#include <metal_stdlib>
//
//using namespace metal;
//
//// Structure for vertex data of the BASE CIRCLE
//struct VertexIn {
//    float2 position [[attribute(0)]]; // 2D position for circle segment vertex
//};
//
//// Structure for PER-INSTANCE data (one for each circle draw)
//// Passed in a separate buffer bound at index 2
//struct InstanceData {
//    float2 offset [[attribute(1)]];  // Center position offset for this instance
//    float scale   [[attribute(2)]];  // Scale factor for this instance
//    float alpha   [[attribute(3)]];  // Alpha (opacity) for this instance
//};
//
//// Structure for uniform data (constant for the entire draw call)
//struct Uniforms {
//    float4x4 projectionMatrix; // Orthographic projection matrix
//    float time;                // Current animation time
//    float4 baseColor;           // Base color for the lines
//};
//
//// Data passed from vertex to fragment shader
//struct VertexOut {
//    float4 position [[position]]; // Clip space position
//    float4 color;                 // Color (with alpha from instance data)
//};
//
//// --- Vertex Shader ---
//vertex VertexOut flower_vertex_shader(
//    const device VertexIn *vertices [[buffer(0)]],        // Base circle vertices
//    const device Uniforms &uniforms [[buffer(1)]],        // Uniforms (Proj Matrix, Time, Color)
//    const device InstanceData *instanceData [[buffer(2)]],// Per-instance data array
//    unsigned int vid [[vertex_id]],                       // Index of current vertex in base circle
//    unsigned int instance_id [[instance_id]]              // Index of the current instance being drawn
//) {
//    VertexOut out;
//    VertexIn currentVertex = vertices[vid];               // Get base circle vertex
//    InstanceData currentInstance = instanceData[instance_id]; // Get data for this specific circle instance
//
//    // Apply instance scale and offset to the base vertex position
//    float2 transformedPos = (currentVertex.position * currentInstance.scale) + currentInstance.offset;
//
//    // Apply projection matrix
//    out.position = uniforms.projectionMatrix * float4(transformedPos, 0.0, 1.0);
//
//    // Set the color, using the instance's alpha value
//    out.color = float4(uniforms.baseColor.rgb, currentInstance.alpha);
//
//    return out;
//}
//
//// --- Fragment Shader ---
//fragment float4 flower_fragment_shader(VertexOut in [[stage_in]]) {
//  // Return the interpolated color (including alpha)
//      // Premultiplied alpha is generally good practice if blending were enabled.
//      // For simple opacity, this works.
//      return float4(in.color.rgb * in.color.a, in.color.a); // <-- Changed from half4(...)
//  }
//"""
//
//// MARK: - Swift Data Structures
//
///// Uniform data structure matching the shader.
//struct FlowerUniforms {
//    var projectionMatrix: matrix_float4x4
//    var time: Float
//    var baseColor: SIMD4<Float> // Using SIMD4 for color
//}
//
///// Base circle vertex data matching the shader `VertexIn`.
//struct CircleVertex {
//    var position: SIMD2<Float> // Changed to SIMD2 for 2D
//}
//
///// Per-instance data matching the shader `InstanceData`.
//struct InstanceData {
//    var offset: SIMD2<Float>
//    var scale: Float
//    var alpha: Float
//}
//
//// MARK: - Renderer Class
//
//class FlowerOfLifeRenderer: NSObject, MTKViewDelegate {
//    
//    let device: MTLDevice
//    let commandQueue: MTLCommandQueue
//    var pipelineState: MTLRenderPipelineState!
//    // No depth state needed for this 2D example initially
//    
//    var circleVertexBuffer: MTLBuffer!
//    var circleIndexBuffer: MTLBuffer! // For line strip indices
//    var uniformBuffer: MTLBuffer!
//    var instanceDataBuffer: MTLBuffer!
//    
//    var startTime: Date = Date() // To track animation time
//    var aspectRatio: Float = 1.0
//    var lastCalculatedInstanceCount = 0 // Stores the count calculated in updateState
//    
//    // --- Geometry Data ---
//    let circleSegments = 48 // Number of line segments to approximate the circle
//    var circleVertices: [CircleVertex] = []
//    var circleIndices: [UInt16] = []
//    let maxInstances = 19 // Maximum circles for the standard Flower of Life pattern
//    
//    // --- Center Positions Data ---
//    var circleCenters: [SIMD2<Float>] = []
//    let baseRadius: Float = 0.5 // Base radius for the circles
//    
//    /// Initializes the renderer, sets up buffers, and calculates circle geometry/centers.
//    init?(device: MTLDevice) {
//        self.device = device
//        guard let queue = device.makeCommandQueue() else { return nil }
//        self.commandQueue = queue
//        super.init()
//        
//        generateCircleGeometry()
//        calculateFlowerOfLifeCenters()
//        setupBuffers()
//        // Note: Pipeline setup depends on MTKView's pixel format, done in `configure()`
//    }
//    
//    /// Called after MTKView is ready to set up the pipeline state.
//    func configure(metalKitView: MTKView) {
//        setupPipeline(metalKitView: metalKitView)
//    }
//    
//    // --- Geometry Generation ---
//    
//    /// Creates vertex and index data for a single circle line strip.
//    func generateCircleGeometry() {
//        circleVertices.removeAll()
//        circleIndices.removeAll()
//        
//        let angleStep = (2.0 * Float.pi) / Float(circleSegments)
//        
//        for i in 0...circleSegments { // Include last point to close the loop visually if needed elsewhere (though line strip handles it)
//            let angle = angleStep * Float(i)
//            // Using baseRadius=1 initially makes scaling easier via instance data
//            let x = cos(angle)
//            let y = sin(angle)
//            circleVertices.append(CircleVertex(position: SIMD2<Float>(x, y)))
//            circleIndices.append(UInt16(i))
//        }
//        // For line strip, we need to connect back to the start
//        // The index buffer should just be 0, 1, 2, ..., circleSegments
//        // The draw call will handle connecting them. Adjust index count accordingly.
//        print("Generated \(circleVertices.count) vertices and \(circleIndices.count) indices for base circle.")
//    }
//    
//    /// Calculates the center positions for the 19 circles of the Flower of Life.
//    func calculateFlowerOfLifeCenters() {
//        circleCenters.removeAll()
//        let r = baseRadius // Use the defined radius
//        let h = r * sqrt(3.0) / 2.0 // Height of equilateral triangle formed by centers
//        
//        // Center circle (1)
//        circleCenters.append(SIMD2<Float>(0, 0))
//        
//        // First layer (Seed of Life - next 6 circles)
//        circleCenters.append(SIMD2<Float>(r, 0))        // Right
//        circleCenters.append(SIMD2<Float>(r/2, h))      // Top-Right
//        circleCenters.append(SIMD2<Float>(-r/2, h))     // Top-Left
//        circleCenters.append(SIMD2<Float>(-r, 0))       // Left
//        circleCenters.append(SIMD2<Float>(-r/2, -h))    // Bottom-Left
//        circleCenters.append(SIMD2<Float>(r/2, -h))     // Bottom-Right
//        
//        // Second layer (Flower of Life - next 12 circles)
//        circleCenters.append(SIMD2<Float>(2*r, 0))      // Far Right
//        circleCenters.append(SIMD2<Float>(r, 2*h))      // Right, Top-Top-Right
//        circleCenters.append(SIMD2<Float>(0, 2*h))      // Center, Top-Top
//        circleCenters.append(SIMD2<Float>(-r, 2*h))     // Left, Top-Top-Left
//        circleCenters.append(SIMD2<Float>(-2*r, 0))     // Far Left
//        circleCenters.append(SIMD2<Float>(-r, -2*h))    // Left, Bottom-Bottom-Left
//        circleCenters.append(SIMD2<Float>(0, -2*h))     // Center, Bottom-Bottom
//        circleCenters.append(SIMD2<Float>(r, -2*h))     // Right, Bottom-Bottom-Right
//        
//        circleCenters.append(SIMD2<Float>(r * 1.5, h))  // Outer Mid-Top-Right
//        circleCenters.append(SIMD2<Float>(-r * 1.5, h)) // Outer Mid-Top-Left
//        circleCenters.append(SIMD2<Float>(-r * 1.5, -h))// Outer Mid-Bottom-Left
//        circleCenters.append(SIMD2<Float>(r * 1.5, -h)) // Outer Mid-Bottom-Right
//        
//        print("Calculated \(circleCenters.count) circle center positions.")
//    }
//    
//    // --- Setup Functions ---
//    
//    func setupPipeline(metalKitView: MTKView) {
//        do {
//            let library = try device.makeLibrary(source: flowerOfLifeMetalShaderSource, options: nil)
//            guard let vertexFunction = library.makeFunction(name: "flower_vertex_shader"),
//                  let fragmentFunction = library.makeFunction(name: "flower_fragment_shader") else {
//                fatalError("Shader function error")
//            }
//            
//            let pipelineDescriptor = MTLRenderPipelineDescriptor()
//            pipelineDescriptor.label = "Flower of Life Pipeline"
//            pipelineDescriptor.vertexFunction = vertexFunction
//            pipelineDescriptor.fragmentFunction = fragmentFunction
//            pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
//            
//            // --- Blending for Alpha ---
//            pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
//            pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
//            pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
//            pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
//            pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
//            pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
//            pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
//            
//            // --- Configure Vertex Descriptors (Base Circle + Instance Data) ---
//            let vertexDescriptor = MTLVertexDescriptor()
//            
//            // Attribute 0: Base Circle Position (buffer 0)
//            vertexDescriptor.attributes[0].format = .float2
//            vertexDescriptor.attributes[0].offset = 0
//            vertexDescriptor.attributes[0].bufferIndex = 0 // Points to circleVertexBuffer
//            
//            // Layout 0: Describes base circle vertex stride
//            vertexDescriptor.layouts[0].stride = MemoryLayout<CircleVertex>.stride
//            vertexDescriptor.layouts[0].stepFunction = .perVertex // One step per vertex
//            
//            // --- Instance Data Layout (buffer 2) ---
//            // Attribute 1: Instance Offset (float2)
//            vertexDescriptor.attributes[1].format = .float2
//            vertexDescriptor.attributes[1].offset = 0 // Start of InstanceData struct
//            vertexDescriptor.attributes[1].bufferIndex = 2 // Points to instanceDataBuffer
//            
//            // Attribute 2: Instance Scale (float)
//            vertexDescriptor.attributes[2].format = .float
//            vertexDescriptor.attributes[2].offset = MemoryLayout<SIMD2<Float>>.stride // After offset
//            vertexDescriptor.attributes[2].bufferIndex = 2
//            
//            // Attribute 3: Instance Alpha (float)
//            vertexDescriptor.attributes[3].format = .float
//            vertexDescriptor.attributes[3].offset = MemoryLayout<SIMD2<Float>>.stride + MemoryLayout<Float>.stride // After offset and scale
//            vertexDescriptor.attributes[3].bufferIndex = 2
//            
//            // Layout 2: Describes instance data stride and step function
//            vertexDescriptor.layouts[2].stride = MemoryLayout<InstanceData>.stride
//            vertexDescriptor.layouts[2].stepFunction = .perInstance // One step per instance drawn
//            vertexDescriptor.layouts[2].stepRate = 1 // Use same instance data for 1 instance
//            
//            pipelineDescriptor.vertexDescriptor = vertexDescriptor
//            
//            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//            
//        } catch {
//            fatalError("Failed to create Metal Pipeline State: \(error)")
//        }
//    }
//    
//    func setupBuffers() {
//        // Circle Vertex Buffer
//        guard !circleVertices.isEmpty else { fatalError("Circle vertices not generated.") }
//        let vertexDataSize = circleVertices.count * MemoryLayout<CircleVertex>.stride
//        circleVertexBuffer = device.makeBuffer(bytes: circleVertices, length: vertexDataSize, options: [])
//        circleVertexBuffer.label = "Circle Vertices"
//        
//        // Circle Index Buffer (for line strip)
//        guard !circleIndices.isEmpty else { fatalError("Circle indices not generated.") }
//        let indexDataSize = circleIndices.count * MemoryLayout<UInt16>.stride
//        circleIndexBuffer = device.makeBuffer(bytes: circleIndices, length: indexDataSize, options: [])
//        circleIndexBuffer.label = "Circle Indices"
//        
//        // Uniform Buffer
//        let uniformBufferSize = MemoryLayout<FlowerUniforms>.stride // stride is usually safer than size for buffers
//        uniformBuffer = device.makeBuffer(length: uniformBufferSize, options: .storageModeShared)
//        uniformBuffer.label = "Uniforms Buffer"
//        
//        // Instance Data Buffer (allocate for max instances)
//        let instanceDataSize = maxInstances * MemoryLayout<InstanceData>.stride
//        instanceDataBuffer = device.makeBuffer(length: instanceDataSize, options: .storageModeShared)
//        instanceDataBuffer.label = "Instance Data Buffer"
//    }
//    
//    // --- Update State Per Frame ---
//    
//    /// Updates uniform data (time, projection matrix) and instance data (controls animation).
//    func updateState() {
//        let currentTime = Float(Date().timeIntervalSince(startTime))
//        
//        // 1. Update Uniforms
//        let projMatrix = matrix_orthographic_projection(aspectRatio: aspectRatio)
//        let uniforms = FlowerUniforms(
//            projectionMatrix: projMatrix,
//            time: currentTime,
//            baseColor: SIMD4<Float>(0.8, 0.8, 1.0, 1.0) // Light blueish color
//        )
//        uniformBuffer.contents().copyMemory(from: [uniforms], byteCount: MemoryLayout<FlowerUniforms>.stride)
//        
//        // 2. Update Instance Data Buffer based on Time
//        let instanceDataPtr = instanceDataBuffer.contents().bindMemory(to: InstanceData.self, capacity: maxInstances)
//        
//        var instanceCount = 0 // How many circles to actually draw this frame
//        
//        // --- Define animation timings AS FLOAT --- // MODIFIED HERE
//        let timeSeedStart: Float = 0.5         // Time the Seed of Life starts appearing
//        let timeSeedDuration: Float = 2.0      // Duration for Seed of Life circles to fade in
//        let timeFlowerStart: Float = timeSeedStart + timeSeedDuration + 0.5 // Time Flower starts
//        let timeFlowerDuration: Float = 3.0    // Duration for Flower of Life circles to fade in
//        
//        for i in 0..<maxInstances {
//            if i >= circleCenters.count { continue } // Safety check
//            
//            var alpha: Float = 0.0 // Already Float, good
//            let scale: Float = baseRadius // Already Float, good
//            
//            // Determine alpha based on animation stage
//            if i == 0 { // Center circle always visible after start
//                // Use 0.0 literal, which will now be inferred as Float due to context
//                alpha = smoothstep(0.0, timeSeedStart, currentTime) // OK
//            } else if i < 7 { // Seed of Life circles (indices 1 to 6)
//                // All calculations now use Float
//                let startTimeForThis = timeSeedStart + Float(i-1) * (timeSeedDuration / 6.0) * 0.5 // calculations are Float now
//                alpha = smoothstep(startTimeForThis, startTimeForThis + timeSeedDuration * 0.8, currentTime) // OK
//            } else { // Flower of Life circles (indices 7 to 18)
//                // All calculations now use Float
//                let startTimeForThis = timeFlowerStart + Float(i-7) * (timeFlowerDuration / 12.0) * 0.5 // calculations are Float now
//                alpha = smoothstep(startTimeForThis, startTimeForThis + timeFlowerDuration * 0.8, currentTime) // OK
//            }
//            
//            if alpha > 0.001 { // 0.001 is Float here due to comparison with Float 'alpha'
//                instanceDataPtr[instanceCount] = InstanceData(
//                    offset: circleCenters[i],
//                    scale: scale * alpha, // Optionally scale in as well
//                    alpha: alpha
//                )
//                instanceCount += 1
//            }
//            
//            // Optimization Checks (now comparing Float with Float literals)
//            if alpha <= 0.001 && i >= 6 && currentTime < timeFlowerStart { // OK
//                break
//            }
//            if alpha <= 0.001 && i > 0 && currentTime < timeSeedStart { // OK
//                break
//            }
//        }
//        // Store the calculated count for the draw call
//        self.lastCalculatedInstanceCount = instanceCount // Add a property to the class: var lastCalculatedInstanceCount = 0
//    }
//    
//    // MARK: - MTKViewDelegate Methods
//    
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        aspectRatio = Float(size.width / max(1, size.height))
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
//        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
//        
//        updateState() // Update uniforms and instance data, calculates lastCalculatedInstanceCount
//        
//        // *** USE THE STORED COUNT ***
//        let visibleInstanceCount = self.lastCalculatedInstanceCount // Use the value calculated in updateState
//        
//        if visibleInstanceCount > 0 { // Only draw if there's something visible
//            renderEncoder.label = "Flower of Life Render Encoder"
//            renderEncoder.setRenderPipelineState(pipelineState)
//            
//            // Bind Buffers
//            renderEncoder.setVertexBuffer(circleVertexBuffer, offset: 0, index: 0) // Base circle geo
//            renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)      // Uniforms
//            renderEncoder.setVertexBuffer(instanceDataBuffer, offset: 0, index: 2) // Instance data
//            
//            // Issue Instanced Draw Call for Line Strips
//            renderEncoder.drawIndexedPrimitives(type: .lineStrip,
//                                                indexCount: circleIndices.count,
//                                                indexType: .uint16,
//                                                indexBuffer: circleIndexBuffer,
//                                                indexBufferOffset: 0,
//                                                instanceCount: visibleInstanceCount) // Use the calculated count
//        }
//        
//        renderEncoder.endEncoding()
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
//}
//
//// MARK: - SwiftUI UIViewRepresentable
//
//struct MetalFlowerViewRepresentable: UIViewRepresentable {
//    typealias UIViewType = MTKView
//    
//    func makeCoordinator() -> FlowerOfLifeRenderer {
//        guard let device = MTLCreateSystemDefaultDevice() else { fatalError("Metal not supported") }
//        guard let coordinator = FlowerOfLifeRenderer(device: device) else { fatalError("Renderer init failed") }
//        return coordinator
//    }
//    
//    func makeUIView(context: Context) -> MTKView {
//        let mtkView = MTKView()
//        mtkView.device = context.coordinator.device
//        mtkView.preferredFramesPerSecond = 60
//        mtkView.enableSetNeedsDisplay = false
//        //mtkView.clearColor = MTLClearColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0) // Set in delegate draw call
//        mtkView.colorPixelFormat = .bgra8Unorm_srgb
//        // No depth buffer needed for this 2D visualization
//        // mtkView.depthStencilPixelFormat = .invalid
//        
//        context.coordinator.configure(metalKitView: mtkView) // Setup pipeline *after* view config
//        mtkView.delegate = context.coordinator
//        
//        context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize) // Initial size update
//        print("MTKView created and configured for Flower of Life.")
//        return mtkView
//    }
//    
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // No external state updates needed for this animation
//    }
//}
//
//// MARK: - Main SwiftUI View
//
//struct FlowerOfLifeView: View {
//    var body: some View {
//        VStack(spacing: 0) {
//            Text("Flower of Life Animation (Metal)")
//                .font(.headline)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color(red: 0.05, green: 0.05, blue: 0.1))
//                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 1.0))
//            
//            MetalFlowerViewRepresentable()
//        }
//        .background(Color(red: 0.05, green: 0.05, blue: 0.1))
//        .ignoresSafeArea(.keyboard)
//        .edgesIgnoringSafeArea(.bottom) // Allow extending to bottom edge
//    }
//}
//
//// MARK: - Preview Provider
//
//#Preview {
//    // Placeholder recommended for complex Metal previews
//    struct PreviewPlaceholder: View {
//        var body: some View {
//            VStack(spacing: 0) {
//                Text("Flower of Life Animation (Metal)")
//                    .font(.headline)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color(red: 0.05, green: 0.05, blue: 0.1))
//                    .foregroundColor(Color(red: 0.8, green: 0.8, blue: 1.0))
//                
//                Spacer()
//                Text("Metal View Placeholder")
//                    .foregroundColor(.gray)
//                    .multilineTextAlignment(.center)
//                Spacer()
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color(red: 0.05, green: 0.05, blue: 0.1))
//            .edgesIgnoringSafeArea(.all)
//        }
//    }
//    // return PreviewPlaceholder() // <-- Use this for safety
//    
//    return FlowerOfLifeView() // <-- Try this if previews work on your machine
//}
//
//// MARK: - Matrix Math Helper Functions (using SIMD)
//
///// Creates an orthographic projection matrix (Left-Handed). Suitable for 2D.
///// Maps view space coordinates directly to clip space without perspective distortion.
///// Adjusts the scale based on aspect ratio to prevent stretching.
///// - Parameter aspectRatio: Width / Height of the viewport.
///// - Returns: A 4x4 orthographic projection matrix.
//func matrix_orthographic_projection(aspectRatio: Float, nearZ: Float = -1.0, farZ: Float = 1.0) -> matrix_float4x4 {
//    // Scale viewport to range [-1, 1] vertically, adjust horizontal range based on aspect ratio
//    let scaleX = 1.0 / max(1.0, aspectRatio)  // Scale X range down if wider than tall
//    let scaleY = 1.0 / max(1.0, 1.0/aspectRatio)  // Scale Y range down if taller than wide
//    
//    // Remap Z to [0, 1] range often used by Metal's NDC.
//    // For simple 2D we might not even need Z depth, but this is common.
//    let scaleZ = 1.0 / (farZ - nearZ)
//    let translateZ = -nearZ * scaleZ
//    // Scale to fit [-2, 2] world units vertically into [-1, 1] NDC
//    let overallScale:Float = 1.0 / 2.5 // Adjust this to control zoom (smaller value = zoomed in)
//    
//    // Remember SIMD matrices are column-major
//    return matrix_float4x4(
//        // Column 0         Column 1         Column 2         Column 3
//        SIMD4<Float>(overallScale * scaleX, 0, 0, 0),  // X Scale + Aspect Ratio Correction
//        SIMD4<Float>(0, overallScale * scaleY, 0, 0),  // Y Scale + Aspect Ratio Correction
//        SIMD4<Float>(0, 0, scaleZ, 0),                 // Z Remapping Scale
//        SIMD4<Float>(0, 0, translateZ, 1)              // Z Remapping Translation + W
//    )
//}
//
//// Smoothstep function for smooth animation transitions (0 to 1)
//func smoothstep(_ edge0: Float, _ edge1: Float, _ x: Float) -> Float {
//    let t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
//    return t * t * (3.0 - 2.0 * t)
//}
//
//// Clamp function helper
//func clamp(_ x: Float, _ lower: Float, _ upper: Float) -> Float {
//    return min(upper, max(lower, x))
//}
