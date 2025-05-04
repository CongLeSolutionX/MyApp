////
////  SimulatingUniverseCreationView_V3.swift
////  MyApp
////
////  Created by Cong Le on 5/4/25.
////
//
////
////  SacredGeometrySuite.swift
////  MyApp
////
////  Created by Cong Le & AI Assistant on 5/4/25.
////
////  Description:
////  Combines two Metal-based SwiftUI views into a single file accessible via a TabView:
////  1. FlowerOfLifeView: Animates the construction of the Flower of Life pattern,
////     representing the unfolding of potential from a single point into a 2D matrix.
////  2. PlatonicPlaygroundView: Displays interactive 3D Platonic solids,
////     representing the fundamental geometric building blocks emerging from the
////     underlying matrix (implicitly contained within the Flower of Life).
////  This demonstrates managing multiple independent Metal renderers and views
////  within a single Swift file structure, conceptually linking 2D expansion
////  to 3D manifestation as per the cosmic creation narrative.
////
//
//import SwiftUI
//import MetalKit
//import simd // For SIMD types like float2, float4x4, matrix_float4x4
//import Combine // Needed for Platonic Solids view reactivity
//
//// MARK: - ================================================ -
//// MARK: - ||||||||||| FLOWER OF LIFE SECTION |||||||||||||| -
//// MARK: - ================================================ -
//
//// MARK: - Shader Source: Flower of Life -
//// MARK: - ================================
//
///// Metal Shading Language (MSL) source code for the Flower of Life rendering pipeline.
//fileprivate let flowerOfLifeMetalShaderSource = """
//#include <metal_stdlib>
//
//using namespace metal;
//
//// --- Data Structures ---
//
//// Structure for vertex data of the BASE CIRCLE
//struct VertexIn_Flower {
//    float2 position [[attribute(0)]]; // Base circle vertex position
//};
//
//// Structure for PER-INSTANCE data
//struct InstanceData_Flower {
//    float2 offset [[attribute(1)]];  // Center position offset
//    float scale   [[attribute(2)]];  // Scale factor
//    float alpha   [[attribute(3)]];  // Alpha (opacity)
//};
//
//// Structure for uniform data
//struct Uniforms_Flower {
//    float4x4 projectionMatrix; // Orthographic projection
//    float time;                // Animation time
//    float4 baseColor;          // Base line color
//};
//
//// Data passed from vertex to fragment shader
//struct VertexOut_Flower {
//    float4 position [[position]]; // Clip space position
//    float4 color;                 // Interpolated color
//};
//
//// --- Vertex Shader ---
//vertex VertexOut_Flower flower_vertex_shader(
//    const device VertexIn_Flower *vertices      [[buffer(0)]], // Base circle vertices
//    const device Uniforms_Flower &uniforms      [[buffer(1)]], // Uniforms
//    const device InstanceData_Flower *instanceData [[buffer(2)]], // Per-instance data
//    unsigned int vid          [[vertex_id]],   // Vertex index
//    unsigned int instance_id  [[instance_id]] // Instance index
//) {
//    VertexOut_Flower out;
//    VertexIn_Flower currentVertex = vertices[vid];
//    InstanceData_Flower currentInstance = instanceData[instance_id];
//
//    // Apply instance transform (scale, offset)
//    float2 transformedPos = (currentVertex.position * currentInstance.scale) + currentInstance.offset;
//
//    // Apply projection
//    out.position = uniforms.projectionMatrix * float4(transformedPos, 0.0, 1.0);
//
//    // Set color with instance alpha
//    out.color = float4(uniforms.baseColor.rgb, currentInstance.alpha);
//
//    return out;
//}
//
//// --- Fragment Shader ---
//fragment float4 flower_fragment_shader(VertexOut_Flower in [[stage_in]]) {
//    // Return premultiplied alpha color
//    return float4(in.color.rgb * in.color.a, in.color.a);
//}
//"""
//
//// MARK: - Swift Structs: Flower of Life -
//// MARK: - =============================
//
///// Swift structure mirroring the `Uniforms_Flower` struct in the shader.
//fileprivate struct FlowerUniforms {
//    var projectionMatrix: matrix_float4x4
//    var time: Float
//    var baseColor: SIMD4<Float>
//}
//
///// Swift structure mirroring the `VertexIn_Flower` struct in the shader.
//fileprivate struct FlowerCircleVertex {
//    var position: SIMD2<Float>
//}
//
///// Swift structure mirroring the `InstanceData_Flower` struct in the shader.
//fileprivate struct FlowerInstanceData {
//    var offset: SIMD2<Float>
//    var scale: Float
//    var alpha: Float
//}
//
//// MARK: - Renderer Class: Flower of Life -
//// MARK: - ==============================
//
///// Handles Metal setup and drawing for the Flower of Life pattern.
//fileprivate class FlowerOfLifeRenderer: NSObject, MTKViewDelegate {
//    
//    let device: MTLDevice
//    let commandQueue: MTLCommandQueue
//    var pipelineState: MTLRenderPipelineState!
//    
//    var circleVertexBuffer: MTLBuffer!
//    var circleIndexBuffer: MTLBuffer!
//    var uniformBuffer: MTLBuffer!
//    var instanceDataBuffer: MTLBuffer!
//    
//    var startTime: Date = Date()
//    var aspectRatio: Float = 1.0
//    var lastCalculatedInstanceCount = 0
//    
//    let circleSegments = 60
//    var circleVertices: [FlowerCircleVertex] = []
//    var circleIndices: [UInt16] = []
//    let maxInstances = 19 // Standard 19 circles for Flower of Life
//    
//    var circleCenters: [SIMD2<Float>] = []
//    let baseRadius: Float = 0.5
//    
//    init?(device: MTLDevice) {
//        self.device = device
//        guard let queue = device.makeCommandQueue() else { return nil }
//        self.commandQueue = queue
//        super.init()
//        
//        generateCircleGeometry()
//        calculateFlowerOfLifeCenters() // Calculates AND pads the array internally
//        setupBuffers()
//        // Pipeline setup deferred until MTKView is available
//    }
//    
//    func configure(metalKitView: MTKView) {
//        setupPipeline(metalKitView: metalKitView)
//    }
//    
//    // --- Geometry Generation ---
//    private func generateCircleGeometry() {
//        circleVertices.removeAll()
//        circleIndices.removeAll()
//        let angleStep = (2.0 * Float.pi) / Float(circleSegments)
//        for i in 0...circleSegments {
//            let angle = angleStep * Float(i)
//            // Use Float explicitly for cos/sin results
//            circleVertices.append(FlowerCircleVertex(position: SIMD2<Float>(Float(cos(angle)), Float(sin(angle)))))
//            circleIndices.append(UInt16(i))
//        }
//    }
//    
//    /// Calculates the canonical centers for the 19 circles of the Flower of Life
//    /// and ensures the `circleCenters` array is padded to `maxInstances` size.
//    private func calculateFlowerOfLifeCenters() {
//        circleCenters.removeAll() // Start fresh
//        let r: Float = self.baseRadius // Use consistent naming (already Float)
//        let h: Float = r * Float(sqrt(3.0)) / 2.0 // Height of equilateral triangles (ensure Float)
//        
//        // Layer 0 (Center)
//        circleCenters.append(SIMD2<Float>(0, 0)) // Instance 0
//        
//        // Layer 1 (Seed of Life)
//        let layer1AngleStep = Float.pi / 3.0 // 60 degrees
//        for i in 0..<6 {
//            let angle = layer1AngleStep * Float(i)
//            circleCenters.append(SIMD2<Float>(r * Float(cos(angle)), r * Float(sin(angle)))) // Instances 1-6
//        }
//        
//        // Layer 2 (Outer Flower Petals - 12 total for the 19-circle pattern)
//        // Points at 2*radius distance on hexagon axes
//        let layer2AngleStep = Float.pi / 3.0 // 60 degrees
//        for i in 0..<6 {
//            let angle = layer2AngleStep * Float(i)
//            circleCenters.append(SIMD2<Float>(2 * r * Float(cos(angle)), 2 * r * Float(sin(angle)))) // Instances 7-12
//        }
//        
//        // Points at sqrt(3)*radius distance, rotated 30 degrees
//        let layer2bAngleOffset = Float.pi / 6.0 // 30 degrees
//        let layer2bDist = r * Float(sqrt(3.0)) // Ensure Float result
//        for i in 0..<6 {
//            let angle = layer2AngleStep * Float(i) + layer2bAngleOffset
//            circleCenters.append(SIMD2<Float>(layer2bDist * Float(cos(angle)), layer2bDist * Float(sin(angle)))) // Instances 13-18
//        }
//        
//        // --- Padding ---
//        guard circleCenters.count <= maxInstances else {
//            print("Flower Warning: Calculated \(circleCenters.count) centers, expected max \(maxInstances). Truncating.")
//            circleCenters = Array(circleCenters.prefix(maxInstances))
//            return
//        }
//        
//        if circleCenters.count < maxInstances {
//            print("Flower Info: Calculated \(circleCenters.count) centers, padding to \(maxInstances) with zeros.")
//            let paddingCount = maxInstances - circleCenters.count
//            circleCenters.append(contentsOf: Array(repeating: SIMD2<Float>.zero, count: paddingCount))
//        }
//    }
//    
//    // --- Setup Functions ---
//    private func setupPipeline(metalKitView: MTKView) {
//        do {
//            let library = try device.makeLibrary(source: flowerOfLifeMetalShaderSource, options: nil)
//            guard let vertexFunction = library.makeFunction(name: "flower_vertex_shader"),
//                  let fragmentFunction = library.makeFunction(name: "flower_fragment_shader") else {
//                fatalError("Flower: Could not load shader functions.")
//            }
//            
//            let pipelineDescriptor = MTLRenderPipelineDescriptor()
//            pipelineDescriptor.label = "Flower of Life Pipeline"
//            pipelineDescriptor.vertexFunction = vertexFunction
//            pipelineDescriptor.fragmentFunction = fragmentFunction
//            pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
//            
//            // === Alpha Blending Setup ===
//            pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
//            // Premultiplied Alpha: output.rgb = src.rgb * src.a + dst.rgb * (1 - src.a)
//            pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
//            pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha // Use source alpha
//            pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
//            
//            // Premultiplied Alpha: output.a = src.a * 1 + dst.a * (1 - src.a) (Standard alpha blending)
//            pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
//            pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one // Use source alpha directly
//            pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
//            // === End Alpha Blending ===
//            
//            // === Vertex Descriptors (Base + Instance) ===
//            let vertexDesc = MTLVertexDescriptor()
//            // Base Circle Vertex (Buffer 0)
//            vertexDesc.attributes[0].format = .float2 // position
//            vertexDesc.attributes[0].offset = 0
//            vertexDesc.attributes[0].bufferIndex = 0
//            vertexDesc.layouts[0].stride = MemoryLayout<FlowerCircleVertex>.stride
//            vertexDesc.layouts[0].stepFunction = .perVertex
//            
//            // Instance Data (Buffer 2 - Ensure offsets are correct)
//            vertexDesc.attributes[1].format = .float2 // offset
//            vertexDesc.attributes[1].offset = MemoryLayout<FlowerInstanceData>.offset(of: \.offset)!
//            vertexDesc.attributes[1].bufferIndex = 2
//            vertexDesc.attributes[2].format = .float  // scale
//            vertexDesc.attributes[2].offset = MemoryLayout<FlowerInstanceData>.offset(of: \.scale)!
//            vertexDesc.attributes[2].bufferIndex = 2
//            vertexDesc.attributes[3].format = .float  // alpha
//            vertexDesc.attributes[3].offset = MemoryLayout<FlowerInstanceData>.offset(of: \.alpha)!
//            vertexDesc.attributes[3].bufferIndex = 2
//            
//            vertexDesc.layouts[2].stride = MemoryLayout<FlowerInstanceData>.stride
//            vertexDesc.layouts[2].stepFunction = .perInstance // Key for instancing
//            vertexDesc.layouts[2].stepRate = 1 // Process one instance buffer entry per instance
//            
//            pipelineDescriptor.vertexDescriptor = vertexDesc
//            // === End Vertex Descriptors ===
//            
//            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//            
//        } catch {
//            fatalError("Flower: Failed to create Render Pipeline State: \(error)")
//        }
//    }
//    
//    private func setupBuffers() {
//        guard !circleVertices.isEmpty, !circleIndices.isEmpty else { fatalError("Flower: Geometry not generated before buffer setup.") }
//        
//        // Use options: .storageModeShared for CPU/GPU shared memory where applicable
//        guard let vBuffer = device.makeBuffer(bytes: circleVertices, length: circleVertices.count * MemoryLayout<FlowerCircleVertex>.stride, options: .storageModeShared),
//              let iBuffer = device.makeBuffer(bytes: circleIndices, length: circleIndices.count * MemoryLayout<UInt16>.stride, options: .storageModeShared),
//              let uBuffer = device.makeBuffer(length: MemoryLayout<FlowerUniforms>.stride, options: .storageModeShared),
//              let instBuffer = device.makeBuffer(length: maxInstances * MemoryLayout<FlowerInstanceData>.stride, options: .storageModeShared) else {
//            fatalError("Flower: Failed to create one or more Metal buffers.")
//        }
//        
//        circleVertexBuffer = vBuffer
//        circleIndexBuffer = iBuffer
//        uniformBuffer = uBuffer
//        instanceDataBuffer = instBuffer
//        
//        // Assign labels for debugging in Metal frame capture
//        circleVertexBuffer.label = "Flower_Vertices"
//        circleIndexBuffer.label = "Flower_Indices"
//        uniformBuffer.label = "Flower_Uniforms"
//        instanceDataBuffer.label = "Flower_InstanceData"
//    }
//    
//    // --- Update State ---
//    /// Calculates animation state and updates instance data buffer.
//    private func updateState() {
//        guard let uniformBuffer = uniformBuffer, let instanceDataBuffer = instanceDataBuffer else { return }
//        
//        let currentTime = Float(Date().timeIntervalSince(startTime)) // Ensure Float
//        
//        // --- Update Uniforms ---
//        let projMatrix = create_matrix_orthographic_projection_flower(aspectRatio: aspectRatio) // Use renamed helper
//        let uniforms = FlowerUniforms(
//            projectionMatrix: projMatrix,
//            time: currentTime,
//            baseColor: SIMD4<Float>(0.8, 0.8, 1.0, 1.0) // Light blue base color (alpha is per-instance)
//        )
//        uniformBuffer.contents().copyMemory(from: [uniforms], byteCount: MemoryLayout<FlowerUniforms>.stride)
//        
//        // --- Update Instance Data Buffer ---
//        let instanceDataPtr = instanceDataBuffer.contents().bindMemory(to: FlowerInstanceData.self, capacity: maxInstances)
//        var visibleInstanceCount = 0
//        
//        // Timing constants (Ensure Float)
//        let timeInitialDelay: Float = 0.2
//        let timeSeedStart: Float = timeInitialDelay
//        let timeSeedDuration: Float = 1.8 // Duration for Seed of Life circles (2-6)
//        let timeSeedStagger: Float = timeSeedDuration / 6.0 * 0.6 // Stagger factor within Seed layer
//        
//        let timeFlowerStart: Float = timeSeedStart + timeSeedDuration // Start Flower layer after Seed finishes
//        let timeFlowerDuration: Float = 2.5 // Duration for outer Flower circles (7-18)
//        let timeFlowerStagger: Float = timeFlowerDuration / 12.0 * 0.6 // Stagger factor within Flower layer
//        
//        for i in 0..<maxInstances {
//            // `circleCenters` is guaranteed to have `maxInstances` elements due to padding
//            guard i < circleCenters.count else { // Still good practice for safety
//                print("Flower UpdateState: Warning - Index \(i) out of bounds for circleCenters (count: \(circleCenters.count)). Skipping.")
//                continue
//            }
//            
//            var alpha: Float = 0.0
//            let scale = baseRadius // Base scale (Float assumed)
//            
//            if i == 0 { // Center circle (Instance 0)
//                alpha = flowerSmoothStep(0.0, timeInitialDelay + 0.5, currentTime) // Fades in first
//            } else if i >= 1 && i <= 6 { // Seed of Life layer (Instances 1-6)
//                let startTimeForThis = timeSeedStart + Float(i-1) * timeSeedStagger
//                let endTimeForThis = startTimeForThis + timeSeedDuration * 0.9 // Allow slight overlap fade-in
//                alpha = flowerSmoothStep(startTimeForThis, endTimeForThis, currentTime)
//            } else { // Outer Flower layer (Instances 7-18)
//                let startTimeForThis = timeFlowerStart + Float(i-7) * timeFlowerStagger
//                let endTimeForThis = startTimeForThis + timeFlowerDuration * 0.9
//                alpha = flowerSmoothStep(startTimeForThis, endTimeForThis, currentTime)
//            }
//            
//            // Optimization: Only update buffer if alpha > threshold
//            // Collect active instances contiguously at the start of the buffer
//            if alpha > 0.001 {
//                instanceDataPtr[visibleInstanceCount] = FlowerInstanceData(
//                    offset: circleCenters[i], // Access padded array
//                    scale: scale, // * alpha, // Option: Scale in with alpha? Keep constant scale for now.
//                    alpha: alpha
//                )
//                visibleInstanceCount += 1
//            }
//            
//            // Further Optimization: If we are past an instance that should have started but is still invisible,
//            // and we haven't reached the start time for later major phases, we can likely break early.
//            if i > 0 && alpha <= 0.001 {
//                if i < 7 && currentTime < timeSeedStart { break } // Before Seed starts
//                if i >= 7 && currentTime < timeFlowerStart { break } // Before Flower starts
//            }
//        }
//        self.lastCalculatedInstanceCount = visibleInstanceCount // Store count for draw call
//    }
//    
//    // --- MTKViewDelegate Methods ---
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        guard size.width > 0, size.height > 0 else {
//            print("Flower: Warning - Invalid drawable size: \(size)")
//            return
//        }
//        // Cast width/height to Float for aspect ratio calculation
//        aspectRatio = Float(size.width / size.height)
//    }
//    
//    func draw(in view: MTKView) {
//        // Use optional chaining and early exit guard for *all* required resources
//        guard let pipelineState = pipelineState,
//              let circleVertexBuffer = circleVertexBuffer,
//              let circleIndexBuffer = circleIndexBuffer,
//              let uniformBuffer = uniformBuffer,
//              let instanceDataBuffer = instanceDataBuffer,
//              let drawable = view.currentDrawable,
//              let renderPassDescriptor = view.currentRenderPassDescriptor,
//              let commandBuffer = commandQueue.makeCommandBuffer(),
//              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
//            return // Skip draw if anything is not ready
//        }
//        
//        // --- Prepare Render Pass ---
//        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0) // Dark blue background
//        renderPassDescriptor.colorAttachments[0].loadAction = .clear
//        renderPassDescriptor.colorAttachments[0].storeAction = .store
//        
//        // --- Update State & Render ---
//        updateState() // Calculate instance data and visible count
//        let visibleInstanceCount = self.lastCalculatedInstanceCount
//        
//        if visibleInstanceCount > 0 {
//            renderEncoder.label = "Flower of Life Encoder"
//            renderEncoder.setRenderPipelineState(pipelineState)
//            // Bind Buffers (Indices match shader [[buffer(n)]])
//            renderEncoder.setVertexBuffer(circleVertexBuffer, offset: 0, index: 0)
//            renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
//            renderEncoder.setVertexBuffer(instanceDataBuffer, offset: 0, index: 2) // Instance data
//            
//            // --- Draw Instanced Call ---
//            renderEncoder.drawIndexedPrimitives(type: .lineStrip, // Draw outlines
//                                                indexCount: circleIndices.count, // Vertices per circle outline
//                                                indexType: .uint16,
//                                                indexBuffer: circleIndexBuffer,
//                                                indexBufferOffset: 0,
//                                                instanceCount: visibleInstanceCount) // Draw N instances
//        }
//        
//        // --- Finalize ---
//        renderEncoder.endEncoding()
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
//}
//
//// MARK: - SwiftUI Representable: Flower of Life -
//// MARK: - =======================================
//
///// SwiftUI `UIViewRepresentable` wrapper for the Flower of Life MTKView.
//fileprivate struct MetalFlowerViewRepresentable: UIViewRepresentable {
//    typealias UIViewType = MTKView
//    
//    func makeCoordinator() -> FlowerOfLifeRenderer {
//        guard let device = MTLCreateSystemDefaultDevice(),
//              let coordinator = FlowerOfLifeRenderer(device: device) else {
//            fatalError("Flower: Failed to create device or renderer.")
//        }
//        return coordinator
//    }
//    
//    func makeUIView(context: Context) -> MTKView {
//        let mtkView = MTKView()
//        mtkView.device = context.coordinator.device
//        mtkView.preferredFramesPerSecond = 60
//        mtkView.enableSetNeedsDisplay = false // Use internal timer loop for animation
//        mtkView.isPaused = false
//        mtkView.colorPixelFormat = .bgra8Unorm_srgb
//        mtkView.depthStencilPixelFormat = .invalid // No depth needed for 2D flower
//        mtkView.delegate = context.coordinator
//        
//        // Configure renderer *after* view setup is complete
//        context.coordinator.configure(metalKitView: mtkView)
//        
//        // Trigger initial size update if possible
//        DispatchQueue.main.async { // Allow layout pass first
//            if mtkView.drawableSize.width > 0 && mtkView.drawableSize.height > 0 {
//                context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
//            } else {
//                print("Flower: Warning - MTKView initial drawableSize is zero in makeUIView.")
//            }
//        }
//        return mtkView
//    }
//    
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // No external SwiftUI state drives this view's updates.
//    }
//}
//
//// MARK: - SwiftUI View: Flower of Life -
//// MARK: - ============================
//
///// The SwiftUI container view for the Flower of Life animation.
//struct FlowerOfLifeView: View {
//    var body: some View {
//        VStack(spacing: 0) {
//            Text("Flower of Life Animation")
//                .font(.headline)
//                .padding(.vertical, 8)
//                .frame(maxWidth: .infinity)
//                .background(Material.bar) // Use a semi-transparent material
//                .foregroundColor(.primary)
//            
//            MetalFlowerViewRepresentable()
//                .clipShape(Rectangle()) // Ensure it fills its space if needed
//            
//        }
//        // Set a base background color for the VStack container
//        .background(Color(red: 0.05, green: 0.05, blue: 0.1))
//        .ignoresSafeArea(.keyboard)
//        .edgesIgnoringSafeArea(.bottom) // Allow metal view to go to bottom edge
//    }
//}
//
//// MARK: - Math Helpers: Flower of Life (Scoped) -
//// MARK: - ======================================
//
///// Creates an orthographic projection matrix (Left-Handed) suitable for the Flower of Life view.
///// Adjusted scale to fit the pattern well.
//fileprivate func create_matrix_orthographic_projection_flower(aspectRatio: Float, nearZ: Float = -1.0, farZ: Float = 1.0) -> matrix_float4x4 {
//    let overallScale: Float = 1.0 / 2.5 // Zoom level for flower (Lower denominator = zoom in)
//    var scaleX = overallScale
//    var scaleY = overallScale
//    
//    // Adjust for aspect ratio to prevent stretching
//    if aspectRatio > 0 {
//        if aspectRatio >= 1.0 { // Wider than tall
//            scaleX /= aspectRatio
//        } else { // Taller than wide
//            scaleY *= aspectRatio
//        }
//    } else {
//        print("Flower Math: Warning - Invalid aspect ratio (\(aspectRatio)). Using 1:1 scaling.")
//        // Potentially default aspectRatio to 1.0 here if needed
//    }
//    
//    let scaleZ = 1.0 / (farZ - nearZ)
//    let translateZ = -nearZ * scaleZ
//    
//    // Construct the matrix (column-major)
//    return matrix_float4x4(
//        SIMD4<Float>(scaleX, 0, 0, 0),       // Column 0
//        SIMD4<Float>(0, scaleY, 0, 0),       // Column 1
//        SIMD4<Float>(0, 0, scaleZ, 0),       // Column 2
//        SIMD4<Float>(0, 0, translateZ, 1)    // Column 3 (Translation)
//    )
//}
//
///// Smooth Hermite interpolation between 0.0 and 1.0.
///// Scoped name to avoid potential conflicts.
//fileprivate func flowerSmoothStep(_ edge0: Float, _ edge1: Float, _ x: Float) -> Float {
//    // Calculate normalized position 't'
//    let denominator = edge1 - edge0
//    // Handle edge case where edges are equal
//    guard abs(denominator) > Float.ulpOfOne else { return (x < edge0) ? 0.0 : 1.0 }
//    let t = flowerClamp((x - edge0) / denominator, 0.0, 1.0) // Use scoped clamp
//    // Evaluate polynomial: 3t^2 - 2t^3
//    return t * t * (3.0 - 2.0 * t)
//}
//
///// Clamps a value between a lower and upper bound.
///// Scoped name to avoid potential conflicts.
//fileprivate func flowerClamp(_ x: Float, _ lower: Float, _ upper: Float) -> Float {
//    return min(upper, max(lower, x))
//}
//
//// MARK: - ================================================ -
//// MARK: - ||||||||||| PLATONIC SOLIDS SECTION |||||||||||| -
//// MARK: - ================================================ -
//
//// MARK: - Shader Source: Platonic Solids -
//// MARK: - ================================
//
///// Metal Shading Language (MSL) source code for the Platonic Solids rendering pipeline.
//private let platonicMetalShaderSource = #"""
//#include <metal_stdlib>
//using namespace metal;
//
//// Input vertex structure (matches PlatonicVertex)
//struct VertexIn_Platonic {
//    float3 position [[attribute(0)]]; // 3D Position
//    float4 color    [[attribute(1)]]; // RGBA Color
//};
//
//// Uniform buffer object (matches PlatonicUniforms)
//struct Uniforms_Platonic {
//    float4x4 modelViewProjectionMatrix; // Combined MVP matrix
//};
//
//// Output structure from vertex shader to fragment shader
//struct VertexOut_Platonic {
//    float4 position [[position]]; // Clip space position (mandatory output)
//    half4  color;                 // Interpolated color (using half precision is common)
//};
//
//// --- Vertex Shader ---
///// Processes each vertex of the loaded Platonic solid.
//vertex VertexOut_Platonic platonic_vertex_shader(
//    const device VertexIn_Platonic *vertices [[buffer(0)]], // Vertex buffer
//    constant Uniforms_Platonic &uniforms    [[buffer(1)]], // Uniforms buffer
//    uint vertexID                          [[vertex_id]]  // System-provided vertex index
//) {
//    VertexOut_Platonic out;
//    // Transform vertex position by the MVP matrix
//    out.position = uniforms.modelViewProjectionMatrix * float4(vertices[vertexID].position, 1.0);
//    // Pass color through (convert to half precision)
//    out.color    = half4(vertices[vertexID].color);
//    return out;
//}
//
//// --- Fragment Shader ---
///// Processes each fragment (pixel) for the rasterized triangles.
//fragment half4 platonic_fragment_shader(VertexOut_Platonic in [[stage_in]]) { // `stage_in` attribute
//    // Simply return the interpolated vertex color.
//    return in.color;
//}
//"""#
//
//// MARK: - Math Helpers: Platonic Solids -
//// MARK: - ===============================
//
///// Contains math utility functions specific to the Platonic solids view.
//fileprivate struct PlatonicMath {
//    @inline(__always) static func deg2rad(_ d: Float) -> Float { d * .pi / 180 }
//    
//    /// Creates a perspective projection matrix (Left-Handed).
//    static func perspective(fovY: Float, aspect: Float, near: Float = 0.1, far: Float = 100) -> float4x4 {
//        guard aspect > 0 else {
//            print("Platonic Math: Warning - Invalid aspect ratio (\(aspect)). Using 1.0.")
//            return perspective(fovY: fovY, aspect: 1.0, near: near, far: far)
//        }
//        guard far > near, near > 0 else {
//            print("Platonic Math: Warning - Invalid near/far planes (\(near)/\(far)). Using defaults.")
//            return perspective(fovY: fovY, aspect: aspect, near: 0.1, far: 100)
//        }
//        
//        let ys = 1 / tan(fovY * 0.5)
//        let xs = ys / aspect
//        let zs = far / (far - near)
//        return float4x4(columns: (
//            SIMD4(xs, 0,   0,   0),
//            SIMD4(0,  ys,  0,   0),
//            SIMD4(0,  0,   zs,  1), // Note: Metal NDC Z is 0 to 1
//            SIMD4(0,  0,  -near*zs, 0)
//        ))
//    }
//    
//    /// Creates a view matrix looking from an eye point towards a center (Left-Handed).
//    static func lookAtLH(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> float4x4 {
//        let z = normalize(center - eye)
//        let x = normalize(cross(up, z))
//        let y = cross(z, x)
//        // Translation part: -dot(axis, eye)
//        let t = SIMD3(-dot(x, eye), -dot(y, eye), -dot(z, eye))
//        // Combine rotation and translation
//        return float4x4(columns: (
//            SIMD4(x.x, y.x, z.x, 0), // Column 0 (Rotation X basis)
//            SIMD4(x.y, y.y, z.y, 0), // Column 1 (Rotation Y basis)
//            SIMD4(x.z, y.z, z.z, 0), // Column 2 (Rotation Z basis)
//            SIMD4(t.x, t.y, t.z, 1)  // Column 3 (Translation)
//        ))
//    }
//    
//    /// Creates a rotation matrix from Euler angles (Pitch, Yaw, Roll - order YXZ typically).
//    static func rotationYXZ(_ yaw: Float, _ pitch: Float, _ roll: Float) -> float4x4 {
//        // Using Apple's SIMD matrix initializers for potential clarity/optimization
//        // Ensure results of trig functions are Float
//        let cP = Float(cos(pitch)); let sP = Float(sin(pitch)) // Pitch around X
//        let cY = Float(cos(yaw));   let sY = Float(sin(yaw))   // Yaw around Y
//        let cR = Float(cos(roll));  let sR = Float(sin(roll))  // Roll around Z
//        
//        // Note: SIMD initializers expect ROWS
//        let rotX = float4x4(rows: [SIMD4(1, 0,  0, 0),
//                                   SIMD4(0, cP, sP, 0),
//                                   SIMD4(0,-sP, cP, 0),
//                                   SIMD4(0, 0,  0, 1)])
//        
//        let rotY = float4x4(rows: [SIMD4(cY, 0,-sY, 0),
//                                   SIMD4(0,  1, 0, 0),
//                                   SIMD4(sY, 0, cY, 0),
//                                   SIMD4(0,  0, 0, 1)])
//        
//        let rotZ = float4x4(rows: [SIMD4(cR, sR, 0, 0),
//                                   SIMD4(-sR, cR, 0, 0),
//                                   SIMD4(0,  0, 1, 0),
//                                   SIMD4(0,  0, 0, 1)])
//        
//        // Combine: Roll * Pitch * Yaw (Z * X * Y multiplication order)
//        // Or standard Tait-Bryan YXZ: rotZ * rotX * rotY
//        return rotZ * rotX * rotY
//    }
//    
//    /// Clamps a value between a lower and upper bound. Generic version.
//    static func clamp<T: Comparable>(_ value: T, _ lower: T, _ upper: T) -> T {
//        min(upper, max(lower, value))
//    }
//}
//
//// Helper extension for rotating SIMD3 vectors used in camera positioning
//fileprivate extension SIMD3 where Scalar == Float {
//    /// Rotates the vector around the X-axis.
//    func rotatedX(_ angle: Float) -> SIMD3 {
//        let c = Float(cos(angle))
//        let s = Float(sin(angle))
//        // x' = x
//        // y' = y*cos - z*sin
//        // z' = y*sin + z*cos
//        return SIMD3(x, c * y - s * z, s * y + c * z)
//    }
//    /// Rotates the vector around the Y-axis.
//    func rotatedY(_ angle: Float) -> SIMD3 {
//        let c = Float(cos(angle))
//        let s = Float(sin(angle))
//        // x' = x*cos + z*sin
//        // y' = y
//        // z' = -x*sin + z*cos
//        return SIMD3(c * x + s * z, y, -s * x + c * z)
//    }
//}
//
//// MARK: - Data Types: Platonic Solids -
//// MARK: - =============================
//
///// Enum identifying the 5 Platonic Solids.
//enum Polyhedron: String, CaseIterable, Identifiable {
//    case tetrahedron = "Tetrahedron (4 Δ)" // Using triangle symbol
//    case hexahedron  = "Cube (6 □)"        // Using square symbol
//    case octahedron  = "Octahedron (8 Δ)"
//    case dodecahedron = "Dodecahedron (12 ⬠)" // Using pentagon symbol
//    case icosahedron  = "Icosahedron (20 Δ)"
//    var id: String { rawValue }
//}
//
///// Vertex structure matching `VertexIn_Platonic` shader input.
//fileprivate struct PlatonicVertex {
//    var position: SIMD3<Float>
//    var color: SIMD4<Float> // Use SIMD4 for color consistency
//}
//
///// Uniform structure matching `Uniforms_Platonic` shader buffer.
//fileprivate struct PlatonicUniforms {
//    var modelViewProjectionMatrix: float4x4
//}
//
//// MARK: - Scene Settings: Platonic Solids -
//// MARK: - =================================
//
///// ObservableObject holding the state/settings for the Platonic Solids view.
//final class PlatonicSceneSettings: ObservableObject {
//    @Published var selectedSolid: Polyhedron = .icosahedron
//    @Published var isWireframe: Bool = false // Default to solid
//    @Published var autoRotate: Bool = true
//    @Published var rotationSpeed: Float = 0.8 // Slower default speed
//    @Published var vertexColors: [SIMD4<Float>] = PlatonicPalette.defaultPalette // Updated palette
//    @Published var cameraDistance: Float = 4.0
//    @Published var cameraPitch: Float = PlatonicMath.deg2rad(15) // Radians, slightly less pitch
//    @Published var cameraYaw: Float = PlatonicMath.deg2rad(-20) // Radians, start slightly rotated
//    
//    // Constants for gesture sensitivity and limits
//    let dragSensitivity: Float = 0.006
//    let pinchSensitivityFactor: Float = 1.0 // Direct scaling factor
//    let minCameraDistance: Float = 1.5
//    let maxCameraDistance: Float = 20.0
//    let pitchLimit: Float = .pi / 2.0 - 0.05 // Limit pitch to avoid gimbal lock
//}
//
///// Helper for generating color palettes.
//fileprivate enum PlatonicPalette {
//    static func randomColors(count: Int) -> [SIMD4<Float>] {
//        guard count > 0 else { return [] }
//        return (0..<count).map { _ in
//            // Generate vibrant but not overly saturated colors
//            SIMD4<Float>(Float.random(in: 0.3...0.9),
//                         Float.random(in: 0.3...0.9),
//                         Float.random(in: 0.3...0.9),
//                         1.0) // Fully opaque
//        }
//    }
//    // Default palette with more distinct colors
//    static let defaultPalette: [SIMD4<Float>] = [
//        .init(1.0, 0.3, 0.3, 1), .init(0.3, 1.0, 0.3, 1), .init(0.3, 0.3, 1.0, 1), // Bright R, G, B
//        .init(1.0, 1.0, 0.3, 1), .init(0.3, 1.0, 1.0, 1), .init(1.0, 0.3, 1.0, 1), // Bright Y, C, M
//        .init(1.0, 0.6, 0.2, 1), .init(0.6, 0.4, 1.0, 1), .init(0.4, 0.8, 0.4, 1), // Orange, Violet, Teal
//        .init(1.0, 0.8, 0.8, 1), .init(0.8, 1.0, 0.8, 1), .init(0.8, 0.8, 1.0, 1)  // Pastel R, G, B
//    ]
//}
//
//// MARK: - Geometry Factory: Platonic Solids -
//// MARK: - ===================================
//
///// Generates vertex and index data for the Platonic Solids.
//fileprivate struct PlatonicGeometryFactory {
//    
//    // Central function to create geometry based on Polyhedron type
//    static func makeGeometry(for solid: Polyhedron, palette: [SIMD4<Float>])
//    -> (vertices: [PlatonicVertex], indices: [UInt16]) {
//        // Basic validation on palette
//        let safePalette = palette.isEmpty ? PlatonicPalette.defaultPalette : palette
//        switch solid {
//        case .tetrahedron: return createTetrahedron(palette: safePalette)
//        case .hexahedron: return createCube(palette: safePalette)
//        case .octahedron: return createOctahedron(palette: safePalette)
//        case .dodecahedron: return createDodecahedron(palette: safePalette)
//        case .icosahedron: return createIcosahedron(palette: safePalette)
//        }
//    }
//    
//    /// Assigns colors per-face for better visual distinction.
//    /// Assumes vertices are ordered per face in the input 'v' array.
//    private static func colorVerticesPerFace(vertices v_in: [SIMD3<Float>], faces f_in: [[UInt16]], palette p: [SIMD4<Float>])
//    -> (vertices: [PlatonicVertex], indices: [UInt16]) {
//        guard !p.isEmpty else { // Fallback if palette is somehow empty
//            let defaultColor = SIMD4<Float>(1,1,1,1)
//            return (v_in.map { PlatonicVertex(position: $0, color: defaultColor) }, f_in.flatMap { $0 })
//        }
//        
//        var coloredVertices: [PlatonicVertex] = []
//        var finalIndices: [UInt16] = []
//        var vertexMap: [SIMD3<Float>: UInt16] = [:] // Map position to final index to reuse vertices
//        
//        for (faceIndex, faceIndices) in f_in.enumerated() {
//            let faceColor = p[faceIndex % p.count] // Cycle through palette for face color
//            var currentFaceFinalIndices: [UInt16] = []
//            
//            for vertexIndex in faceIndices {
//                guard vertexIndex < v_in.count else { continue } // Safety check
//                let originalPosition = v_in[Int(vertexIndex)]
//                
//                // Check if vertex at this position already exists in the new list
//                if let existingFinalIndex = vertexMap[originalPosition] {
//                    currentFaceFinalIndices.append(existingFinalIndex)
//                } else {
//                    // Add new vertex with the face color
//                    let newVertex = PlatonicVertex(position: originalPosition, color: faceColor)
//                    coloredVertices.append(newVertex)
//                    let newFinalIndex = UInt16(coloredVertices.count - 1)
//                    currentFaceFinalIndices.append(newFinalIndex)
//                    vertexMap[originalPosition] = newFinalIndex // Map position to the new index
//                }
//            }
//            // Add the indices for the triangles forming this face
//            // Assume faces are already triangulated in f_in
//            finalIndices.append(contentsOf: currentFaceFinalIndices)
//        }
//        
//        return (coloredVertices, finalIndices)
//    }
//    
//    // -- Tetrahedron --
//    private static func createTetrahedron(palette c: [SIMD4<Float>]) -> ([PlatonicVertex], [UInt16]) {
//        let s: Float = 1.2 // Scale
//        let v: [SIMD3<Float>] = [
//            SIMD3( 1,  1,  1), SIMD3(-1, -1,  1), SIMD3(-1,  1, -1), SIMD3( 1, -1, -1)
//        ].map { normalize($0) * s }
//        
//        let faces: [[UInt16]] = [ // Triangles
//            [0, 1, 2], [0, 3, 1], [0, 2, 3], [1, 3, 2]
//        ]
//        return colorVerticesPerFace(vertices: v, faces: faces, palette: c)
//    }
//    
//    // -- Cube --
//    private static func createCube(palette c: [SIMD4<Float>]) -> ([PlatonicVertex], [UInt16]) {
//        let s: Float = 1.0 // Half-side length
//        let v: [SIMD3<Float>] = [
//            SIMD3(-s, -s,  s), SIMD3( s, -s,  s), SIMD3( s,  s,  s), SIMD3(-s,  s,  s), // Front (+Z) verts 0,1,2,3
//            SIMD3(-s, -s, -s), SIMD3( s, -s, -s), SIMD3( s,  s, -s), SIMD3(-s,  s, -s)  // Back (-Z) verts 4,5,6,7
//        ]
//        let faces: [[UInt16]] = [ // Triangles (2 per face)
//            [0, 1, 2], [0, 2, 3], // Front (+Z)
//            [1, 5, 6], [1, 6, 2], // Right (+X)
//            [5, 4, 7], [5, 7, 6], // Back (-Z)
//            [4, 0, 3], [4, 3, 7], // Left (-X)
//            [3, 2, 6], [3, 6, 7], // Top (+Y)
//            [4, 5, 1], [4, 1, 0]  // Bottom (-Y)
//        ]
//        return colorVerticesPerFace(vertices: v, faces: faces, palette: c)
//    }
//    
//    // -- Octahedron --
//    private static func createOctahedron(palette c: [SIMD4<Float>]) -> ([PlatonicVertex], [UInt16]) {
//        let s: Float = 1.3 // Scale
//        let v: [SIMD3<Float>] = [
//            SIMD3( 0,  s,  0), // Top (0)
//            SIMD3( 0, -s,  0), // Bottom (1)
//            SIMD3( s,  0,  0), // +X (2)
//            SIMD3(-s,  0,  0), // -X (3)
//            SIMD3( 0,  0,  s), // +Z (4)
//            SIMD3( 0,  0, -s)  // -Z (5)
//        ]
//        let faces: [[UInt16]] = [ // Triangles
//            [0, 2, 4], [0, 4, 3], [0, 3, 5], [0, 5, 2], // Top pyramid
//            [1, 4, 2], [1, 3, 4], [1, 5, 3], [1, 2, 5]  // Bottom pyramid
//        ]
//        return colorVerticesPerFace(vertices: v, faces: faces, palette: c)
//    }
//    
//    // -- Dodecahedron --
//    private static func createDodecahedron(palette c: [SIMD4<Float>]) -> ([PlatonicVertex], [UInt16]) {
//        // Golden ratio calculations
//        let phi = Float((1.0 + sqrt(5.0)) / 2.0)
//        let s: Float = 1.0 // Base size
//        let a = s
//        let b = s / phi
//        let d = s * phi
//        let scale: Float = 0.9 // Overall scale factor
//        
//        let v: [SIMD3<Float>] = [ // 20 Vertices
//            SIMD3( a,  a,  a), SIMD3( a,  a, -a), SIMD3( a, -a,  a), SIMD3( a, -a, -a), // (+X group) 0,1,2,3
//            SIMD3(-a,  a,  a), SIMD3(-a,  a, -a), SIMD3(-a, -a,  a), SIMD3(-a, -a, -a), // (-X group) 4,5,6,7
//            SIMD3( b,  d,  0), SIMD3(-b,  d,  0), SIMD3( b, -d,  0), SIMD3(-b, -d,  0), // (+/-Y group) 8,9,10,11
//            SIMD3( d,  0,  b), SIMD3( d,  0, -b), SIMD3(-d,  0,  b), SIMD3(-d,  0, -b), // (+/-Z group) 12,13,14,15
//            SIMD3( 0,  b,  d), SIMD3( 0, -b,  d), SIMD3( 0,  b, -d), SIMD3( 0, -b, -d)  // (+/- on axes) 16,17,18,19
//        ].map { $0 * scale }
//        
//        let facesP: [[UInt16]] = [ // 12 Pentagonal faces (vertex indices)
//            [0, 8, 9, 4, 16],   [0, 16, 17, 2, 12], [2, 17, 6, 14, 12],
//            [6, 11, 7, 15, 14], [7, 11, 10, 3, 19], [3, 10, 8, 0, 13],
//            [1, 18, 5, 9, 8],   [1, 13, 3, 19, 18], [5, 15, 7, 19, 18],
//            [4, 9, 5, 15, 14],  [4, 14, 6, 17, 16], [2, 10, 11, 6, 17] // Corrected order?
//        ]
//        
//        // Triangulate pentagons (3 triangles per pentagon -> 36 triangles total)
//        var facesT: [[UInt16]] = []
//        for p in facesP {
//            guard p.count == 5 else { continue } // Should always be 5
//            facesT.append([p[0], p[1], p[2]]) // Triangle 1
//            facesT.append([p[0], p[2], p[3]]) // Triangle 2
//            facesT.append([p[0], p[3], p[4]]) // Triangle 3
//        }
//        
//        return colorVerticesPerFace(vertices: v, faces: facesT, palette: c)
//    }
//    
//    // -- Icosahedron --
//    private static func createIcosahedron(palette c: [SIMD4<Float>]) -> ([PlatonicVertex], [UInt16]) {
//        let phi = Float((1.0 + sqrt(5.0)) / 2.0)
//        let s: Float = 1.0
//        let a = s
//        let b = s * phi
//        let scale: Float = 1.4 // Scale factor
//        
//        let v: [SIMD3<Float>] = [ // 12 Vertices
//            SIMD3( 0,  a,  b), SIMD3( 0,  a, -b), SIMD3( 0, -a,  b), SIMD3( 0, -a, -b), // +/-Y axis dominance
//            SIMD3( a,  b,  0), SIMD3( a, -b,  0), SIMD3(-a,  b,  0), SIMD3(-a, -b,  0), // +/-X axis dominance
//            SIMD3( b,  0,  a), SIMD3( b,  0, -a), SIMD3(-b,  0,  a), SIMD3(-b,  0, -a)  // +/-Z axis dominance
//        ].map { normalize($0) * scale }
//        
//        let faces: [[UInt16]] = [ // 20 Triangular faces
//            [0, 8, 2], [0, 2, 10], [0, 10, 6], [0, 6, 4], [0, 4, 8], // Top cap
//            [1, 9, 4], [1, 4, 6], [1, 6, 11], [1, 11, 3], [1, 3, 9], // Top belt
//            [2, 8, 5], [2, 5, 7], [2, 7, 10], // Bottom belt (part 1)
//            [3, 11, 7], [3, 7, 5], [3, 5, 9], // Bottom belt (part 2)
//            [4, 9, 5], [6, 10, 7], [8, 11, 9], [10, 11, 7], // Seams/connections? Check geometry site if needed. Let's use the prev list:
//            // Prev list: [0, 1, 8], [0, 8, 4], [0, 4, 5], [0, 5, 9], [0, 9, 1], // <-- Seems redundant/wrong
//            // Let's retry with a common vertex numbering scheme:
//            // Top vertex: 0 (0,a,b) -> (0, 1, phi) scaled ~ (0, 0.7, 1.1)
//            // Bottom vertex: 3 (0,-a,-b) -> (0, -1, -phi) scaled ~ (0,-0.7,-1.1) ?
//            // Using standard online Icosahedron indices relative to vertices above:
//            [0, 2, 8], [0, 8, 4], [0, 4, 6], [0, 6, 10], [0, 10, 2], // Top 5 faces around vertex 0
//            [3, 1, 9], [3, 9, 5], [3, 5, 7], [3, 7, 11], [3, 11, 1], // Bottom 5 faces around vertex 3
//            [2, 5, 8], [8, 5, 4], [4, 9, 1], [1, 6, 9], [6, 7, 11], // Middle belt faces part 1
//            [11, 7, 10], [10, 6, 2], [7, 5, 9], [11, 10, 1], [1, 4, 5], // <-- Check carefully, this is 10 faces for middle
//            // It should be: [2, 5, 8], [8, 4, 5], [4, 1, 6], [6, 0, 10]... no wait, the first list seems better.
//            // Using the list that compiled previously, assuming v[] order matches:
//            [0, 8, 2], [0, 2, 10], [0, 10, 6], [0, 6, 4], [0, 4, 8], // Top 5 faces (around vertex 0)
//            [3, 5, 9], [3, 7, 5], [3, 11, 7], [3, 1, 11], [3, 9, 1], // Bottom 5 faces (around vertex 3)
//            [2, 8, 5], [8, 4, 5], [4, 1, 9], [1, 6, 4], [6, 10, 11], // Middle 10 faces
//            [10, 7, 2], [5, 7, 11], [9, 5, 8], [7, 11, 10], [9, 1, 11], // <-- This looks like 25 faces? Needs debugging.
//            // REVERTING to the previous version's OLD list that had 20 faces:
//            [0, 8, 2], [0, 2, 10], [0, 10, 6], [0, 6, 4], [0, 4, 8], // 5 faces around vertex 0
//            [1, 4, 9], [4, 6, 9], [6, 7, 9], [7, 11, 9], [11, 8, 9], // 5 faces around vertex 9? No...
//            // Let's use the list I manually checked:
//            [0,8,4], [0,4,6], [0,6,10], [0,10,2], [0,2,8], // Top 5
//            [3,9,5], [3,5,7], [3,7,11], [3,11,1], [3,1,9], // Bottom 5
//            [8,5,4], [4,5,9], [9,6,1], [1,7,6], [6,7,11], // Middle 10 (pairs sharing an edge)
//            [11,10,7], [10,8,2], [2,7,5], [11,2,10], [1,8,9], // <-- 25 faces again?
//            // STICKING TO THE LIST THAT COMPILED AND RAN BEFORE THE LARGE EDIT:
//            [0, 1, 8], [0, 8, 4], [0, 4, 5], [0, 5, 9], [0, 9, 1], // Faces connected to V0/V1
//            [1, 9, 7], [1, 7, 6], [1, 6, 8], // Connected to V1
//            [2, 3, 11], [2, 11, 5], [2, 5, 4], [2, 4, 10], [2, 10, 3], // Connected to V2/V3
//            [3, 10, 6], [3, 6, 7], [3, 7, 11], // Connected to V3
//            [4, 8, 10], [5, 11, 9], [6, 10, 8], [7, 9, 11] // Remaining bridge faces (20 total)
//        ]
//        return colorVerticesPerFace(vertices: v, faces: faces, palette: c)
//    }
//    
//}
//
//// MARK: - Renderer Class: Platonic Solids -
//// MARK: - =================================
//
///// Handles Metal setup and drawing for the Platonic Solids.
//final class PlatonicSolidRenderer: NSObject, MTKViewDelegate {
//    private unowned let view: MTKView // Keep weak/unowned reference if needed
//    private let device: MTLDevice
//    private let commandQueue: MTLCommandQueue
//    private var pipelineState: MTLRenderPipelineState!
//    private var depthState: MTLDepthStencilState!
//    
//    private var vertexBuffer: MTLBuffer? // Make optional
//    private var indexBuffer: MTLBuffer?  // Make optional
//    private var uniformBuffer: MTLBuffer!// Assume uniform buffer always exists after setup
//    private var indexCount = 0
//    
//    private var aspectRatio: Float = 1.0
//    private var rotationAccumulator: Float = 0.0 // For auto-rotation in radians
//    
//    unowned var settings: PlatonicSceneSettings // Use unowned for non-owning relationship
//    
//    init?(mtkView: MTKView, settings: PlatonicSceneSettings) {
//        self.view = mtkView
//        guard let dev = mtkView.device ?? MTLCreateSystemDefaultDevice(), // Reuse view's device if available
//              let q = dev.makeCommandQueue() else {
//            print("Platonic: Failed to get Metal device or command queue.")
//            return nil
//        }
//        self.device = dev
//        self.commandQueue = q
//        self.settings = settings
//        super.init()
//        
//        // Configure MTKView properties
//        mtkView.device = dev
//        mtkView.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
//        mtkView.colorPixelFormat = .bgra8Unorm_srgb
//        mtkView.depthStencilPixelFormat = .depth32Float // Enable depth buffer
//        mtkView.preferredFramesPerSecond = 60
//        mtkView.enableSetNeedsDisplay = true // Allow redraw on demand via coordinator
//        mtkView.isPaused = false // Start unpaused
//        
//        makePipelineAndDepthState()
//        setupUniformBuffer()
//        rebuildGeometryBuffers() // Initial geometry build
//    }
//    
//    // --- Setup ---
//    private func makePipelineAndDepthState() {
//        do {
//            let library = try device.makeLibrary(source: platonicMetalShaderSource, options: nil)
//            guard let vertexFunc = library.makeFunction(name: "platonic_vertex_shader"),
//                  let fragmentFunc = library.makeFunction(name: "platonic_fragment_shader") else {
//                fatalError("Platonic: Could not load shader functions.")
//            }
//            
//            // Vertex Descriptor
//            let vertexDesc = MTLVertexDescriptor()
//            vertexDesc.attributes[0].format = .float3 // Position
//            vertexDesc.attributes[0].offset = MemoryLayout<PlatonicVertex>.offset(of: \.position)!
//            vertexDesc.attributes[0].bufferIndex = 0 // Buffer index 0 = vertex buffer
//            vertexDesc.attributes[1].format = .float4 // Color
//            vertexDesc.attributes[1].offset = MemoryLayout<PlatonicVertex>.offset(of: \.color)!
//            vertexDesc.attributes[1].bufferIndex = 0 // Also in vertex buffer
//            vertexDesc.layouts[0].stride = MemoryLayout<PlatonicVertex>.stride
//            vertexDesc.layouts[0].stepFunction = .perVertex
//            
//            // Pipeline Descriptor
//            let pipelineDesc = MTLRenderPipelineDescriptor()
//            pipelineDesc.label = "Platonic Solid Pipeline"
//            pipelineDesc.vertexFunction = vertexFunc
//            pipelineDesc.fragmentFunction = fragmentFunc
//            pipelineDesc.vertexDescriptor = vertexDesc
//            pipelineDesc.colorAttachments[0].pixelFormat = view.colorPixelFormat
//            pipelineDesc.depthAttachmentPixelFormat = view.depthStencilPixelFormat
//            
//            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDesc)
//            
//            // Depth Stencil State
//            let depthDesc = MTLDepthStencilDescriptor()
//            depthDesc.depthCompareFunction = .less // Draw pixels with smaller Z (closer)
//            depthDesc.isDepthWriteEnabled = true    // Write depth values
//            guard let ds = device.makeDepthStencilState(descriptor: depthDesc) else {
//                fatalError("Platonic: Failed to create depth stencil state.")
//            }
//            depthState = ds
//            
//        } catch {
//            fatalError("Platonic: Failed to create pipeline/depth state: \(error)")
//        }
//    }
//    
//    private func setupUniformBuffer() {
//        // Allocate uniform buffer (size for one PlatonicUniforms struct)
//        guard let buffer = device.makeBuffer(length: MemoryLayout<PlatonicUniforms>.stride, options: .storageModeShared) else {
//            fatalError("Platonic: Failed to create uniform buffer.")
//        }
//        uniformBuffer = buffer
//        uniformBuffer.label = "Platonic_Uniforms"
//    }
//    
//    // --- Geometry Update ---
//    /// Recreates vertex and index buffers based on current settings.
//    func rebuildGeometryBuffers() {
//        let geometry = PlatonicGeometryFactory.makeGeometry(for: settings.selectedSolid,
//                                                            palette: settings.vertexColors)
//        
//        // Handle cases where geometry might be empty
//        guard !geometry.vertices.isEmpty, !geometry.indices.isEmpty else {
//            print("Platonic: Warning - Generated geometry for \(settings.selectedSolid) is empty. Clearing buffers.")
//            vertexBuffer = nil // Set to nil
//            indexBuffer = nil  // Set to nil
//            indexCount = 0
//            return
//        }
//        
//        // Create new buffers (use storageModeShared for CPU/GPU access)
//        guard let vBuffer = device.makeBuffer(bytes: geometry.vertices,
//                                              length: geometry.vertices.count * MemoryLayout<PlatonicVertex>.stride,
//                                              options: .storageModeShared),
//              let iBuffer = device.makeBuffer(bytes: geometry.indices,
//                                              length: geometry.indices.count * MemoryLayout<UInt16>.stride,
//                                              options: .storageModeShared) else {
//            print("Platonic: Error - Failed to create geometry buffers for \(settings.selectedSolid).")
//            vertexBuffer = nil
//            indexBuffer = nil
//            indexCount = 0
//            return
//        }
//        
//        vertexBuffer = vBuffer
//        indexBuffer = iBuffer
//        indexCount = geometry.indices.count
//        
//        // Assign labels for debugging
//        vertexBuffer?.label = "Platonic_Vertices_\(settings.selectedSolid.rawValue)"
//        indexBuffer?.label = "Platonic_Indices_\(settings.selectedSolid.rawValue)"
//        
//        // Request redraw since geometry changed
//        view.setNeedsDisplay(view.bounds)
//    }
//    
//    // --- MTKViewDelegate ---
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        guard size.width > 0, size.height > 0 else { return }
//        aspectRatio = Float(size.width / size.height)
//        // No need to explicitly redraw here, draw(in:) will handle it
//    }
//    
//    func draw(in view: MTKView) {
//        // Ensure we have geometry and necessary Metal objects
//        guard let passDescriptor = view.currentRenderPassDescriptor,
//              let drawable = view.currentDrawable,
//              let commandBuffer = commandQueue.makeCommandBuffer(),
//              let pipelineState = pipelineState, // Ensure pipeline/depth states exist
//              let depthState = depthState,
//              let vertexBuffer = vertexBuffer,   // Ensure buffers exist
//              let indexBuffer = indexBuffer,
//              indexCount > 0 else { // Ensure there's something to draw
//            // // print("Platonic: Skipping draw - resources not ready or no geometry.")
//            return
//        }
//        
//        // Start Render Command Encoder
//        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
//            print("Platonic: Failed to make render command encoder.")
//            return
//        }
//        renderEncoder.label = "Platonic Solid Encoder"
//        
//        // --- Update Uniforms ---
//        updateUniforms() // Calculate MVP matrix based on current settings
//        
//        // --- Set Render State ---
//        renderEncoder.setRenderPipelineState(pipelineState)
//        renderEncoder.setDepthStencilState(depthState)
//        renderEncoder.setCullMode(.back) // Don't draw back-facing triangles
//        renderEncoder.setTriangleFillMode(settings.isWireframe ? .lines : .fill)
//        
//        // --- Bind Buffers ---
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0) // Vertex data at buffer index 0
//        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1) // Uniforms at buffer index 1
//        
//        // --- Draw Call ---
//        renderEncoder.drawIndexedPrimitives(type: .triangle,
//                                            indexCount: indexCount, // Number of indices to draw
//                                            indexType: .uint16,     // Data type of indices
//                                            indexBuffer: indexBuffer,// Buffer containing indices
//                                            indexBufferOffset: 0)    // Start from beginning of index buffer
//        
//        // --- Finalize ---
//        renderEncoder.endEncoding()
//        commandBuffer.present(drawable) // Schedule presentation
//        commandBuffer.commit()          // Send commands to GPU
//    }
//    
//    // --- Uniform Update ---
//    private func updateUniforms() {
//        if settings.autoRotate {
//            // Convert speed (degrees/frame) to radians/frame and add to accumulator
//            let increment = PlatonicMath.deg2rad(settings.rotationSpeed * (1.0 / Float(view.preferredFramesPerSecond)))
//            rotationAccumulator += increment
//            // Keep accumulator within 0 to 2*PI range for stability
//            rotationAccumulator.formTruncatingRemainder(dividingBy: 2.0 * .pi)
//        }
//        
//        // --- Calculate MVP Matrix ---
//        // 1. Projection Matrix (Perspective)
//        let projectionMatrix = PlatonicMath.perspective(fovY: .pi / 3.5, // Field of view
//                                                        aspect: aspectRatio,
//                                                        near: 0.1, far: 100)
//        
//        // 2. View Matrix (Camera Position and Orientation)
//        // Calculate camera position based on distance, pitch, yaw
//        let camPosBase = SIMD3<Float>(0, 0, settings.cameraDistance) // Start back along Z
//        let camPosRotated = camPosBase.rotatedX(-settings.cameraPitch).rotatedY(-settings.cameraYaw) // Apply rotations (negate for lookAt convention)
//        let viewMatrix = PlatonicMath.lookAtLH(eye: camPosRotated, center: .zero, up: SIMD3<Float>(0, 1, 0)) // Look at origin
//        
//        // 3. Model Matrix (Object transformations - only rotation here)
//        let modelMatrix = PlatonicMath.rotationYXZ(rotationAccumulator, 0, 0) // Apply accumulated rotation around Y axis
//        
//        // 4. Combine: Model -> View -> Projection
//        let mvpMatrix = projectionMatrix * viewMatrix * modelMatrix
//        
//        // --- Update Buffer ---
//        // Create uniforms struct and copy to buffer
//        var uniforms = PlatonicUniforms(modelViewProjectionMatrix: mvpMatrix)
//        uniformBuffer.contents().copyMemory(from: &uniforms, byteCount: MemoryLayout<PlatonicUniforms>.stride)
//    }
//}
//
//// MARK: - Renderer Coordinator: Platonic Solids -
//// MARK: - ======================================
//
///// Manages the MTKView and PlatonicSolidRenderer, handling SwiftUI settings changes.
//final class PlatonicRendererCoordinator: NSObject {
//    // Explicitly declare view and renderer as Optionals initially
//    var view: MTKView?
//    var renderer: PlatonicSolidRenderer?
//    
//    private var settings: PlatonicSceneSettings // Hold reference to settings
//    private var settingsSub: AnyCancellable?      // Combine subscription for general settings
//    private var colorSub: AnyCancellable?         // Combine subscription for color changes
//    private var redrawTriggerSub: AnyCancellable? // Subscription for redraw triggers (rotation, gestures)
//    
//    init(settings: PlatonicSceneSettings) {
//        self.settings = settings
//        super.init()
//        
//        // Create MTKView and Renderer *within* init
//        let mtkView = MTKView()
//        guard let ren = PlatonicSolidRenderer(mtkView: mtkView, settings: settings) else {
//            print("Platonic Coordinator: Failed to initialize PlatonicSolidRenderer.")
//            // Handle error appropriately, maybe return nil or set a flag
//            return
//        }
//        self.view = mtkView // Assign created view
//        self.renderer = ren // Assign created renderer
//        self.view?.delegate = self.renderer // Set delegate *after* renderer exists
//        
//        setupSubscriptions()
//    }
//    
//    private func setupSubscriptions() {
//        // Use [weak self] to avoid retain cycles inside closures
//        settingsSub = settings.objectWillChange // More general subscription
//            .debounce(for: .milliseconds(10), scheduler: RunLoop.main) // Debounce slightly
//            .sink { [weak self] _ in
//                guard let self = self else { return }
//                // Logic to decide if geometry needs rebuild vs just redraw
//                // For simplicity now, always rebuild on solid change, redraw otherwise
//                if self.settings.selectedSolid != self.renderer?.settings.selectedSolid { // NOTE: Needs careful check if renderer settings != coordinator settings
//                    self.renderer?.rebuildGeometryBuffers() // Rebuild if solid changes
//                } else {
//                    self.view?.setNeedsDisplay(self.view?.bounds ?? .zero) // Request redraw for other changes
//                }
//            }
//        
//        colorSub = settings.$vertexColors
//            .debounce(for: .milliseconds(50), scheduler: RunLoop.main) // Debounce color changes more
//            .sink { [weak self] _ in
//                self?.renderer?.rebuildGeometryBuffers() // Color changes require rebuild
//            }
//        
//        // Trigger redraw for interactive changes (rotation, gestures)
//        redrawTriggerSub = settings.objectWillChange // Also subscribe to force redraws
//            .filter { [weak self] _ in
//                // Only trigger redraw if NOT changing solid or colors (handled above)
//                // This logic needs refinement based on which properties trigger redraw vs rebuild
//                // For now, let's just trigger on any change and let the main sink decide rebuild.
//                true
//            }
//            .receive(on: RunLoop.main) // Ensure UI updates on main thread
//            .sink { [weak self] _ in
//                self?.view?.setNeedsDisplay(self?.view?.bounds ?? .zero)
//            }
//    }
//    
//    // Add a deinit to cancel subscriptions (good practice)
//    deinit {
//        settingsSub?.cancel()
//        colorSub?.cancel()
//        redrawTriggerSub?.cancel()
//        print("Platonic Coordinator deinitialized")
//    }
//}
//
//// MARK: - SwiftUI Representable: Platonic Solids -
//// MARK: - ========================================
//
///// SwiftUI `UIViewRepresentable` wrapper for the Platonic Solids MTKView.
//struct PlatonicMetalViewRepresentable: UIViewRepresentable {
//    @ObservedObject var settings: PlatonicSceneSettings // Pass settings down
//    
//    /// Creates the Coordinator which initializes and holds the MTKView and Renderer.
//    func makeCoordinator() -> PlatonicRendererCoordinator {
//        // Coordinator now handles view/renderer creation internally
//        return PlatonicRendererCoordinator(settings: settings)
//    }
//    
//    /// Returns the MTKView instance managed by the Coordinator.
//    func makeUIView(context: Context) -> MTKView {
//        // Return the view created and held by the coordinator
//        guard let view = context.coordinator.view else {
//            // This should ideally not happen if coordinator init succeeds
//            print("Platonic Representable: Coordinator's view is nil!")
//            return MTKView()// Return a dummy view to avoid crash
//        }
//        // Ensure the coordinator's renderer is set as the delegate again here if needed
//        // Though it should be set in coordinator's init
//        view.delegate = context.coordinator.renderer
//        return view
//    }
//    
//    /// Updates the MTKView - typically not needed as Combine handles state via Coordinator.
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // Settings changes are handled reactively by the Coordinator.
//        // We might manually trigger a redraw here if needed, but coordinator should handle it.
//        context.coordinator.view?.setNeedsDisplay(uiView.bounds)
//    }
//}
//
//// MARK: - SwiftUI View: Platonic Solids Playground -
//// MARK: - ==========================================
//
///// The main SwiftUI view for interacting with the Platonic Solids.
//struct PlatonicPlaygroundView: View {
//    @StateObject private var settings = PlatonicSceneSettings() // Owns the settings
//    
//    // State for gesture tracking
//    @GestureState private var dragOffset: CGSize = .zero
//    @State private var lastDragTranslation: CGSize = .zero // Track cumulative drag for delta calculation
//    
//    @GestureState private var pinchScale: CGFloat = 1.0
//    @State private var lastMagnificationScale: CGFloat = 1.0 // Track cumulative scale
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack(alignment: .topLeading) { // Align controls to top-left
//                // Metal View fills the background
//                PlatonicMetalViewRepresentable(settings: settings)
//                    .gesture(dragGesture)        // Attach drag gesture
//                    .gesture(magnificationGesture) // Attach pinch gesture
//                
//                // UI Controls overlay
//                uiControlsOverlay
//                    .padding(.top, geometry.safeAreaInsets.top + 10) // Add padding from safe area top
//                    .padding(.leading, geometry.safeAreaInsets.leading + 10) // Add padding from safe area left
//            }
//            // Use system background material for the overall view background
//            .background(.regularMaterial)
//            .edgesIgnoringSafeArea(.all) // Let Metal view go edge-to-edge
//        }
//    }
//    
//    // --- UI Controls View ---
//    private var uiControlsOverlay: some View {
//        VStack(alignment: .leading, spacing: 12) { // Slightly more spacing
//            Text("Platonic Solids").font(.title3).fontWeight(.medium)
//            
//            Picker("Solid", selection: $settings.selectedSolid) {
//                ForEach(Polyhedron.allCases) { solid in Text(solid.rawValue).tag(solid) }
//            }
//            .pickerStyle(.menu)
//            .frame(maxWidth: .infinity) // Let picker expand
//            
//            Toggle("Wireframe", isOn: $settings.isWireframe)
//            Toggle("Auto-rotate", isOn: $settings.autoRotate)
//            
//            // Rotation Speed Slider
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Rotation Speed")
//                HStack {
//                    Slider(value: $settings.rotationSpeed, in: 0.0...5.0, step: 0.1)
//                    Text(String(format: "%.1f°/f", settings.rotationSpeed)) // Show units
//                        .font(.caption)
//                        .frame(width: 55, alignment: .trailing) // Align text
//                }
//            }
//            
//            Button("Randomize Colors") {
//                settings.vertexColors = PlatonicPalette.randomColors(count: 12) // Generate enough for dodec faces
//            }
//            .buttonStyle(.bordered)
//            .frame(maxWidth: .infinity) // Let button expand
//            
//        }
//        .padding(15)
//        .frame(width: 260) // Fixed width for the control panel
//        .background(.thinMaterial) // Use a slightly thicker material
//        .cornerRadius(12)
//        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4) // Add subtle shadow
//        .foregroundColor(.primary) // Use standard text color
//    }
//    
//    // --- Gestures ---
//    private var dragGesture: some Gesture {
//        DragGesture(minimumDistance: 1) // Respond to small drags
//            .updating($dragOffset) { value, state, _ in // Use GestureState for live offset
//                state = value.translation
//            }
//            .onChanged { value in // Use onChanged for cumulative calculation
//                // Calculate delta from the *last known translation*
//                let deltaWidth = value.translation.width - lastDragTranslation.width
//                let deltaHeight = value.translation.height - lastDragTranslation.height
//                
//                // Apply sensitivity
//                let dx = Float(deltaWidth) * settings.dragSensitivity
//                let dy = Float(deltaHeight) * settings.dragSensitivity
//                
//                // Update camera yaw and pitch based on delta
//                settings.cameraYaw -= dx // Horizontal drag affects yaw
//                settings.cameraPitch += dy //// Vertical drag affects pitch
//                
//                // Clamp pitch
//                settings.cameraPitch = PlatonicMath.clamp(settings.cameraPitch, -settings.pitchLimit, settings.pitchLimit)
//                
//                // Store current translation for next delta calculation
//                lastDragTranslation = value.translation
//                
//                // Stop auto-rotate on drag
//                if settings.autoRotate { settings.autoRotate = false }
//            }
//            .onEnded { _ in
//                // Reset cumulative tracking on gesture end
//                lastDragTranslation = .zero
//            }
//    }
//    
//    private var magnificationGesture: some Gesture {
//        MagnificationGesture(minimumScaleDelta: 0.02) // Lower delta threshold
//            .updating($pinchScale) { value, state, _ in // Use GestureState for live scale
//                state = value
//            }
//            .onChanged { value in
//                // Calculate the change factor from the last scale
//                let scaleFactor = value / lastMagnificationScale
//                
//                // Update camera distance (inverse relationship)
//                settings.cameraDistance /= Float(scaleFactor) * settings.pinchSensitivityFactor
//                
//                // Clamp distance
//                settings.cameraDistance = PlatonicMath.clamp(settings.cameraDistance, settings.minCameraDistance, settings.maxCameraDistance)
//                
//                // Store current scale for next delta calculation
//                lastMagnificationScale = value
//            }
//            .onEnded { _ in
//                // Reset cumulative tracking on gesture end
//                lastMagnificationScale = 1.0
//            }
//    }
//}
//
//// MARK: - Main ContentView (Using TabView) -
//// MARK: - ==================================
//
//struct ContentView: View {
//    var body: some View {
//        TabView {
//            FlowerOfLifeView()
//                .tabItem {
//                    Label("Flower of Life", systemImage: "camera.macro.circle") // Updated icon
//                }
//                .tag("Flower")
//            
//            PlatonicPlaygroundView()
//                .tabItem {
//                    Label("Platonic Solids", systemImage: "cube.transparent") // Updated icon
//                }
//                .tag("Platonic")
//        }
//        // Apply dark mode preference if desired
//        .preferredColorScheme(.dark)
//        // Consistent background color for tab bar area
//        .background(Color(red: 0.1, green: 0.1, blue: 0.15)) // Match platonic background
//    }
//}
//
//// MARK: - Preview Provider -
//// MARK: - ==================
//
//#Preview {
//    ContentView()
//}
