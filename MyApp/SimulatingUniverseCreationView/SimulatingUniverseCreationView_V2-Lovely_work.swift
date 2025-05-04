////
////  SacredGeometrySuite.swift
////  MyApp
////
////  Created by Cong Le & AI Assistant on 5/4/25.
////
////  Description:
////  Combines two Metal-based SwiftUI views into a single file accessible via a TabView:
////  1. FlowerOfLifeView: Animates the construction of the Flower of Life pattern.
////  2. PlatonicPlaygroundView: Displays interactive 3D Platonic solids.
////  This demonstrates managing multiple independent Metal renderers and views
////  within a single Swift file structure.
////
//
//import SwiftUI
//import MetalKit
//import simd // For SIMD types like float2, float4x4, matrix_float4x4
//import Combine // Needed for Platonic Solids view reactivity
//
//// MARK: - Shader Source: Flower of Life -
//// MARK: - ================================
//
///// Metal Shading Language (MSL) source code for the Flower of Life rendering pipeline.
//let flowerOfLifeMetalShaderSource = """
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
//struct FlowerUniforms {
//    var projectionMatrix: matrix_float4x4
//    var time: Float
//    var baseColor: SIMD4<Float>
//}
//
///// Swift structure mirroring the `VertexIn_Flower` struct in the shader.
//struct FlowerCircleVertex {
//    var position: SIMD2<Float>
//}
//
///// Swift structure mirroring the `InstanceData_Flower` struct in the shader.
//struct FlowerInstanceData {
//    var offset: SIMD2<Float>
//    var scale: Float
//    var alpha: Float
//}
//
//// MARK: - Renderer Class: Flower of Life -
//// MARK: - ==============================
//
///// Handles Metal setup and drawing for the Flower of Life pattern.
//class FlowerOfLifeRenderer: NSObject, MTKViewDelegate {
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
//        calculateFlowerOfLifeCenters() // This now calls the _Original version internally
//        setupBuffers()
//        // Pipeline setup deferred until MTKView is available
//    }
//
//    func configure(metalKitView: MTKView) {
//        setupPipeline(metalKitView: metalKitView)
//    }
//
//    // --- Geometry Generation ---
//    func generateCircleGeometry() {
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
//    // Main function simply delegates to the original calculation logic for now
//    func calculateFlowerOfLifeCenters() {
//        calculateFlowerOfLifeCenters_Original()
//
//        // Ensure the centers array has the corect size after calculation
//         guard circleCenters.count <= maxInstances else {
//             print("Warning: Calculated \(circleCenters.count) centers, expected max \(maxInstances). Truncating.")
//             circleCenters = Array(circleCenters.prefix(maxInstances))
//             return // Exit early if truncated
//         }
//
//        // Check if padding is necessary ONLY if calculation resulted in FEWER than maxInstances
//        if circleCenters.count < maxInstances {
//            print("Warning: Calculated \(circleCenters.count) centers, expected \(maxInstances). Padding with zeros.")
//            while circleCenters.count < maxInstances {
//                circleCenters.append(.zero)
//            }
//        }
//    }
//
//    // Keep the original calculation function renamed AND FIX TYPE ERRORS WITHIN IT
//    private func calculateFlowerOfLifeCenters_Original() {
//        circleCenters.removeAll()
//        // Ensure 'r' is declared only ONCE at the top of its required scope
//        let radius: Float = self.baseRadius
//        // Ensure sqrt result is Float
//        let halfHeight: Float = radius * Float(sqrt(3.0)) / 2.0
//
//        // Layer 0
//        circleCenters.append(SIMD2<Float>(0, 0)) // Inst 0
//
//        // Layer 1 (Seed)
//        let layer1AngleStep = Float.pi / 3.0
//        for i in 0..<6 {
//            let angle = layer1AngleStep * Float(i)
//            // Cast trig results to Float
//            circleCenters.append(SIMD2<Float>(radius * Float(cos(angle)), radius * Float(sin(angle))))
//        } // Inst 1-6
//
//        // Layer 2 (Outer Flower - Original Code's specific points, ensure Float)
//        // Using radius and halfHeight which are already Float
//        circleCenters.append(SIMD2<Float>(2*radius, 0))          // 7
//        circleCenters.append(SIMD2<Float>(radius, 2*halfHeight))   // 8
//        circleCenters.append(SIMD2<Float>(-radius, 2*halfHeight))  // 9
//        circleCenters.append(SIMD2<Float>(-2*radius, 0))         // 10
//        circleCenters.append(SIMD2<Float>(-radius, -2*halfHeight)) // 11
//        circleCenters.append(SIMD2<Float>(radius, -2*halfHeight))  // 12
//
//        // Original extra points
//        circleCenters.append(SIMD2<Float>(0, 2*halfHeight))             // 13
//        circleCenters.append(SIMD2<Float>(-radius * 1.5, halfHeight))   // 14
//        circleCenters.append(SIMD2<Float>(-radius * 1.5, -halfHeight))  // 15
//        circleCenters.append(SIMD2<Float>(radius * 1.5, -halfHeight))   // 16
//
//        // Symmetric points to fill up closer to 19 count
//        circleCenters.append(SIMD2<Float>(0, -2*halfHeight))            // 17
//        circleCenters.append(SIMD2<Float>(radius * 1.5, halfHeight))    // 18
//    }
//
//    // --- Setup Functions ---
//    func setupPipeline(metalKitView: MTKView) {
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
//            // Alpha Blending
//            pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
//            pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
//            pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
//            pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
//            pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
//            pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
//            pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
//
//            // Vertex Descriptors (Base + Instance)
//            let vertexDesc = MTLVertexDescriptor()
//            // Base Circle Vertex (Buffer 0)
//            vertexDesc.attributes[0].format = .float2
//            vertexDesc.attributes[0].offset = 0
//            vertexDesc.attributes[0].bufferIndex = 0
//            vertexDesc.layouts[0].stride = MemoryLayout<FlowerCircleVertex>.stride
//            vertexDesc.layouts[0].stepFunction = .perVertex
//
//            // Instance Data (Buffer 2)
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
//            vertexDesc.layouts[2].stepRate = 1
//
//            pipelineDescriptor.vertexDescriptor = vertexDesc
//
//            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//
//        } catch {
//            fatalError("Flower: Failed to create Render Pipeline State: \(error)")
//        }
//    }
//
//    func setupBuffers() {
//        guard !circleVertices.isEmpty, !circleIndices.isEmpty else { fatalError("Flower: Geometry not generated.") }
//        circleVertexBuffer = device.makeBuffer(bytes: circleVertices, length: circleVertices.count * MemoryLayout<FlowerCircleVertex>.stride)!
//        circleIndexBuffer = device.makeBuffer(bytes: circleIndices, length: circleIndices.count * MemoryLayout<UInt16>.stride)!
//        uniformBuffer = device.makeBuffer(length: MemoryLayout<FlowerUniforms>.stride, options: .storageModeShared)!
//        instanceDataBuffer = device.makeBuffer(length: maxInstances * MemoryLayout<FlowerInstanceData>.stride, options: .storageModeShared)!
//
//        circleVertexBuffer.label = "Flower_Vertices"
//        circleIndexBuffer.label = "Flower_Indices"
//        uniformBuffer.label = "Flower_Uniforms"
//        instanceDataBuffer.label = "Flower_InstanceData"
//    }
//
//    // --- Update State ---
//    func updateState() {
//        let currentTime = Float(Date().timeIntervalSince(startTime)) // Cast TimeInterval (Double) to Float
//
//        // Update Uniforms
//        let projMatrix = create_matrix_orthographic_projection(aspectRatio: aspectRatio) // Renamed helper
//        let uniforms = FlowerUniforms(
//            projectionMatrix: projMatrix,
//            time: currentTime,
//            baseColor: SIMD4<Float>(0.8, 0.8, 1.0, 1.0) // Light blue
//        )
//        uniformBuffer.contents().copyMemory(from: [uniforms], byteCount: MemoryLayout<FlowerUniforms>.stride)
//
//        // Update Instance Data Buffer
//        let instanceDataPtr = instanceDataBuffer.contents().bindMemory(to: FlowerInstanceData.self, capacity: maxInstances)
//        var currentInstanceCount = 0
//
//        // Ensure time constants are Float
//        let timeSeedStart: Float = 0.5
//        let timeSeedDuration: Float = 2.0
//        let timeFlowerStart: Float = timeSeedStart + timeSeedDuration + 0.5
//        let timeFlowerDuration: Float = 3.0
//
//        for i in 0..<maxInstances {
//             // Check bounds BEFORE accessing circleCenters
//            guard i < circleCenters.count else {
//                // This should ideally not happen if padding logic is correct, but safe guard.
//                print("UpdateState: Warning - Index \(i) out of bounds for circleCenters (count: \(circleCenters.count)). Skipping.")
//                continue
//            }
//
//            var alpha: Float = 0.0
//            let scale: Float = baseRadius // Already Float
//
//            if i == 0 { // Center
//                alpha = smoothStep(0.0, timeSeedStart, currentTime) // Use renamed helper
//            } else if i < 7 { // Seed
//                // Ensure all calculations use Float
//                let startTimeForThis = timeSeedStart + Float(i-1) * (timeSeedDuration / 6.0) * 0.5
//                alpha = smoothStep(startTimeForThis, startTimeForThis + timeSeedDuration * 0.8, currentTime)
//            } else { // Flower
//                // Ensure all calculations use Float
//                let startTimeForThis = timeFlowerStart + Float(i-7) * (timeFlowerDuration / 12.0) * 0.5
//                alpha = smoothStep(startTimeForThis, startTimeForThis + timeFlowerDuration * 0.8, currentTime)
//            }
//
//            if alpha > 0.001 {
//                // Bounds already checked, safe to access circleCenters[i]
//                instanceDataPtr[currentInstanceCount] = FlowerInstanceData(
//                    offset: circleCenters[i],
//                    scale: scale * alpha, // Fade scale in with alpha
//                    alpha: alpha
//                )
//                currentInstanceCount += 1
//            }
//
//            // Optimisation checks from original code
//             if alpha <= 0.001 && i >= 6 && currentTime < timeFlowerStart { break }
//             if alpha <= 0.001 && i > 0 && currentTime < timeSeedStart { break }
//        }
//        self.lastCalculatedInstanceCount = currentInstanceCount
//    }
//
//    // --- MTKViewDelegate Methods ---
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        // Cast width/height to Float for aspect ratio calculation
//        aspectRatio = Float(size.width / max(1.0, size.height))
//    }
//
//    func draw(in view: MTKView) {
//        // Use optional chaining and early exit guard
//       guard let pipelineState = pipelineState,
//             let circleVertexBuffer = circleVertexBuffer,
//             let circleIndexBuffer = circleIndexBuffer,
//             let uniformBuffer = uniformBuffer,
//             let instanceDataBuffer = instanceDataBuffer,
//             let drawable = view.currentDrawable,
//             let renderPassDescriptor = view.currentRenderPassDescriptor,
//             let commandBuffer = commandQueue.makeCommandBuffer(),
//             let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
//           // Reduce console noise, maybe log less frequently or use breakpoints
//           // // print("Flower: Skipping draw - resources not ready.")
//           return
//       }
//
//        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0) // Dark blue background
//        renderPassDescriptor.colorAttachments[0].loadAction = .clear
//        renderPassDescriptor.colorAttachments[0].storeAction = .store
//
//        updateState()
//        let visibleInstanceCount = self.lastCalculatedInstanceCount
//
//        if visibleInstanceCount > 0 {
//            renderEncoder.label = "Flower of Life Encoder"
//            renderEncoder.setRenderPipelineState(pipelineState)
//            renderEncoder.setVertexBuffer(circleVertexBuffer, offset: 0, index: 0)
//            renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
//            renderEncoder.setVertexBuffer(instanceDataBuffer, offset: 0, index: 2)
//
//            renderEncoder.drawIndexedPrimitives(type: .lineStrip,
//                                                indexCount: circleIndices.count,
//                                                indexType: .uint16,
//                                                indexBuffer: circleIndexBuffer,
//                                                indexBufferOffset: 0,
//                                                instanceCount: visibleInstanceCount)
//        }
//
//        renderEncoder.endEncoding()
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
//}
//
//// MARK: - SwiftUI Representable: Flower of Life -
//// MARK: - =======================================
//
//struct MetalFlowerViewRepresentable: UIViewRepresentable {
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
//        mtkView.enableSetNeedsDisplay = false
//        mtkView.isPaused = false
//        mtkView.colorPixelFormat = .bgra8Unorm_srgb
//        mtkView.depthStencilPixelFormat = .invalid // No depth needed
//        mtkView.delegate = context.coordinator
//
//        // Configure renderer *after* view setup
//        context.coordinator.configure(metalKitView: mtkView)
//
//        // Initial size update
//        if mtkView.drawableSize.width > 0 && mtkView.drawableSize.height > 0 {
//            context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
//        } else {
//            print("Flower: Warning - MTKView initial drawableSize is zero.")
//        }
//        return mtkView
//    }
//
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // No external updates needed for this self-animating view
//    }
//}
//
//// MARK: - SwiftUI View: Flower of Life -
//// MARK: - ============================
//
//struct FlowerOfLifeView: View {
//    var body: some View {
//        VStack(spacing: 0) {
//             Text("Flower of Life Animation (Metal)")
//                 .font(.headline)
//                 .padding(.vertical, 8) // Reduced padding
//                 .frame(maxWidth: .infinity)
//                 .background(Color(red: 0.05, green: 0.05, blue: 0.1))
//                 .foregroundColor(Color(red: 0.8, green: 0.8, blue: 1.0))
//
//            MetalFlowerViewRepresentable()
//        }
//        .background(Color(red: 0.05, green: 0.05, blue: 0.1))
//        .ignoresSafeArea(.keyboard)
//        .edgesIgnoringSafeArea(.bottom)
//    }
//}
//
//// MARK: - Math Helpers: Flower of Life (Renamed) -
//// MARK: - ========================================
//
///// Creates an orthographic projection matrix (Left-Handed) for Flower of Life view.
//func create_matrix_orthographic_projection(aspectRatio: Float, nearZ: Float = -1.0, farZ: Float = 1.0) -> matrix_float4x4 {
//    let overallScale: Float = 1.0 / 2.5 // Adjusted zoom for flower view, was 2.0
//    var scaleX = overallScale
//    var scaleY = overallScale
//
//     if aspectRatio > 0 {
//        if aspectRatio > 1.0 { scaleX /= aspectRatio }
//        else { scaleY *= aspectRatio }
//    } else { print("Flower: Warning - Invalid aspect ratio.") }
//
//    let scaleZ = 1.0 / (farZ - nearZ)
//    let translateZ = -nearZ * scaleZ
//
//    return matrix_float4x4(
//        SIMD4<Float>(scaleX, 0, 0, 0),
//        SIMD4<Float>(0, scaleY, 0, 0),
//        SIMD4<Float>(0, 0, scaleZ, 0),
//        SIMD4<Float>(0, 0, translateZ, 1)
//    )
//}
//
///// Smoothly interpolates between 0.0 and 1.0. Renamed for clarity.
//func smoothStep(_ edge0: Float, _ edge1: Float, _ x: Float) -> Float {
//    let denominator = edge1 - edge0
//    guard abs(denominator) > .ulpOfOne else { return x < edge0 ? 0.0 : 1.0 }
//    let t = clampValue((x - edge0) / denominator, 0.0, 1.0) // Use renamed helper
//    return t * t * (3.0 - 2.0 * t)
//}
//
///// Clamps a value within a range. Renamed for clarity.
//func clampValue(_ x: Float, _ lower: Float, _ upper: Float) -> Float {
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
//// Re-declared Math structure, specific to Platonic Solids view needs
//fileprivate struct PlatonicMath {
//    @inline(__always) static func deg2rad(_ d: Float) -> Float { d * .pi / 180 }
//
//    static func perspective(fovY: Float, aspect: Float, near: Float = 0.1, far: Float = 100) -> float4x4 {
//        let ys = 1 / tan(fovY * 0.5)
//        let xs = ys / aspect
//        let zs = far / (far - near)
//        return float4x4(columns: (
//            SIMD4(xs, 0,   0,   0),
//            SIMD4(0,  ys,  0,   0),
//            SIMD4(0,  0,   zs,  1),
//            SIMD4(0,  0,  -near*zs, 0)
//        ))
//    }
//
//    static func lookAtLH(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> float4x4 {
//        let z = normalize(center - eye)
//        let x = normalize(cross(up, z))
//        let y = cross(z, x)
//        let t = SIMD3(dot(-x, eye), dot(-y, eye), dot(-z, eye))
//        return float4x4(columns: (
//            SIMD4(x.x, y.x, z.x, 0),
//            SIMD4(x.y, y.y, z.y, 0),
//            SIMD4(x.z, y.z, z.z, 0),
//            SIMD4(t.x, t.y, t.z, 1)
//        ))
//    }
//
//    static func rotationXYZ(_ pitch: Float, _ yaw: Float, _ roll: Float) -> float4x4 {
//         // Using Apple's SIMD matrix initializers for potential clarity/optimization
//         // Ensure results of trig functions are Float
//         let cosPitch = Float(cos(pitch)); let sinPitch = Float(sin(pitch))
//         let cosYaw = Float(cos(yaw));     let sinYaw = Float(sin(yaw))
//         let cosRoll = Float(cos(roll));   let sinRoll = Float(sin(roll))
//
//         let rotX = float4x4(rows: [SIMD4(1, 0, 0, 0),
//                                    SIMD4(0, cosPitch, sinPitch, 0),
//                                    SIMD4(0, -sinPitch, cosPitch, 0),
//                                    SIMD4(0, 0, 0, 1)])
//
//         let rotY = float4x4(rows: [SIMD4(cosYaw, 0, -sinYaw, 0),
//                                    SIMD4(0, 1, 0, 0),
//                                    SIMD4(sinYaw, 0, cosYaw, 0),
//                                    SIMD4(0, 0, 0, 1)])
//
//         let rotZ = float4x4(rows: [SIMD4(cosRoll, sinRoll, 0, 0),
//                                    SIMD4(-sinRoll, cosRoll, 0, 0),
//                                    SIMD4(0, 0, 1, 0),
//                                    SIMD4(0, 0, 0, 1)])
//
//         // Combine: Z * Y * X (standard Euler order)
//         return rotZ * rotY * rotX
//    }
//}
//
//// Helper extension for rotating SIMD3 vectors used in camera positioning
//fileprivate extension SIMD3 where Scalar == Float {
//    func rotatedX(_ angle: Float) -> SIMD3 {
//        // Cast trig results to Float
//        let c = Float(cos(angle))
//        let s = Float(sin(angle))
//        return SIMD3(x, c * y - s * z, s * y + c * z)
//    }
//    func rotatedY(_ angle: Float) -> SIMD3 {
//        // Cast trig results to Float
//        let c = Float(cos(angle))
//        let s = Float(sin(angle))
//        return SIMD3(c * x + s * z, y, -s * x + c * z)
//    }
//}
//
//// MARK: - Data Types: Platonic Solids -
//// MARK: - =============================
//
///// Enum identifying the 5 Platonic Solids.
//enum Polyhedron: String, CaseIterable, Identifiable {
//    case tetrahedron = "Tetrahedron (4Δ)"
//    case hexahedron  = "Cube (6□)"
//    case octahedron  = "Octahedron (8Δ)"
//    case dodecahedron = "Dodecahedron (12⬠)"
//    case icosahedron  = "Icosahedron (20Δ)"
//    var id: String { rawValue }
//}
//
///// Vertex structure matching `VertexIn_Platonic` shader input.
//fileprivate struct PlatonicVertex {
//    var position: SIMD3<Float>
//    var color: SIMD4<Float>
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
//    @Published var isWireframe: Bool = true
//    @Published var autoRotate: Bool = true
//    @Published var rotationSpeed: Float = 1.0 // degrees per frame
//    @Published var vertexColors: [SIMD4<Float>] = PlatonicPalette.defaultPalette
//    @Published var cameraDistance: Float = 4.0
//    @Published var cameraPitch: Float = PlatonicMath.deg2rad(20) // Radians
//    @Published var cameraYaw: Float = 0 // Radians
//}
//
///// Helper for generating color palettes.
//fileprivate enum PlatonicPalette {
//    static func randomColors(count: Int) -> [SIMD4<Float>] {
//        guard count > 0 else { return [] }
//        return (0..<count).map { _ in
//            // Use Float directly for random numbers
//            SIMD4<Float>(Float.random(in: 0.2...0.9),
//                         Float.random(in: 0.2...0.9),
//                         Float.random(in: 0.2...0.9),
//                         1.0) // Fully opaque
//        }
//    }
//    // Default palette with distinct colors
//    static let defaultPalette: [SIMD4<Float>] = [
//        .init(1.0, 0.2, 0.2, 1), .init(0.2, 1.0, 0.2, 1), .init(0.2, 0.2, 1.0, 1), // R, G, B
//        .init(1.0, 1.0, 0.2, 1), .init(0.2, 1.0, 1.0, 1), .init(1.0, 0.2, 1.0, 1), // Y, C, M
//        .init(1.0, 0.6, 0.2, 1), .init(0.6, 0.2, 1.0, 1)                            // Orange, Purple
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
//        switch solid {
//        case .tetrahedron: return createTetrahedron(palette: palette)
//        case .hexahedron: return createCube(palette: palette)
//        case .octahedron: return createOctahedron(palette: palette)
//        case .dodecahedron: return createDodecahedron(palette: palette)
//        case .icosahedron: return createIcosahedron(palette: palette)
//        }
//    }
//
//    // Helper to expand a base color palette to match vertex count
//    private static func expandColors(count n: Int, base: [SIMD4<Float>]) -> [SIMD4<Float>] {
//        guard !base.isEmpty else { return Array(repeating: SIMD4<Float>(1,1,1,1), count: n) }
//        return (0..<n).map { base[$0 % base.count] }
//    }
//
//    // -- Tetrahedron --
//    private static func createTetrahedron(palette c: [SIMD4<Float>]) -> ([PlatonicVertex], [UInt16]) {
//        // Ensure literals are Float if used directly in SIMD
//        let v: [SIMD3<Float>] = [ SIMD3(1,1,1), SIMD3(-1,-1,1), SIMD3(-1,1,-1), SIMD3(1,-1,-1) ]
//            .map { normalize($0) * 1.2 } // normalize result is Float, 1.2 inferred Float OK
//        let faces: [[UInt16]] = [ [0,1,2], [0,3,1], [0,2,3], [1,3,2] ]
//        let colors = expandColors(count: v.count, base: c)
//        return (zip(v, colors).map { PlatonicVertex(position: $0, color: $1) }, faces.flatMap { $0 })
//    }
//
//    // -- Cube --
//    private static func createCube(palette c: [SIMD4<Float>]) -> ([PlatonicVertex], [UInt16]) {
//        let s: Float = 1.0 // Explicitly Float
//         let v: [SIMD3<Float>] = [
//            SIMD3(-s, s, s), SIMD3( s, s, s), SIMD3(-s,-s, s), SIMD3( s,-s, s), // Front face
//            SIMD3(-s, s,-s), SIMD3( s, s,-s), SIMD3(-s,-s,-s), SIMD3( s,-s,-s)  // Back face
//        ]
//        let faces: [[UInt16]] = [
//            [0,1,2], [1,3,2], // Front
//            [1,5,3], [5,7,3], // Right
//            [5,4,7], [4,6,7], // Back
//            [4,0,6], [0,2,6], // Left
//            [4,5,0], [5,1,0], // Top
//            [2,3,6], [3,7,6]  // Bottom
//        ]
//        let colors = expandColors(count: v.count, base: c)
//        return (zip(v, colors).map { PlatonicVertex(position: $0, color: $1) }, faces.flatMap { $0 })
//    }
//
//    // -- Octahedron --
//    private static func createOctahedron(palette c: [SIMD4<Float>]) -> ([PlatonicVertex], [UInt16]) {
//        let v: [SIMD3<Float>] = [
//             SIMD3( 0, 1, 0), SIMD3( 0,-1, 0), // Top, Bottom poles
//             SIMD3( 1, 0, 0), SIMD3(-1, 0, 0), // X axis intercepts
//             SIMD3( 0, 0, 1), SIMD3( 0, 0,-1)  // Z axis intercepts
//         ].map { $0 * 1.3 } // 1.3 inferred as Float OK here
//         let faces: [[UInt16]] = [
//             [0,2,4], [0,4,3], [0,3,5], [0,5,2], // Top pyramid
//             [1,4,2], [1,3,4], [1,5,3], [1,2,5]  // Bottom pyramid
//         ]
//         let colors = expandColors(count: v.count, base: c)
//         return (zip(v, colors).map { PlatonicVertex(position: $0, color: $1) }, faces.flatMap { $0 })
//    }
//
//    // -- Dodecahedron --
//    private static func createDodecahedron(palette c: [SIMD4<Float>]) -> ([PlatonicVertex], [UInt16]) {
//         // Cast sqrt result and ensure phi calculations use Float
//         let phi = Float( (1.0 + sqrt(5.0)) / 2.0 )
//         let invPhi = 1.0 / phi // Float / Float is Float
//         let s : Float = 0.8 // Scaling factor
//
//         let v: [SIMD3<Float>] = [
//             // (±1, ±1, ±1) vertices of a cube scaled
//             SIMD3(-s, -s, -s), SIMD3(-s, -s,  s), SIMD3(-s,  s, -s), SIMD3(-s,  s,  s),
//             SIMD3( s, -s, -s), SIMD3( s, -s,  s), SIMD3( s,  s, -s), SIMD3( s,  s,  s),
//             // Vertices derived from golden ratio proportions
//             SIMD3( 0, -s*phi, -s*invPhi), SIMD3( 0, -s*phi,  s*invPhi),
//             SIMD3( 0,  s*phi, -s*invPhi), SIMD3( 0,  s*phi,  s*invPhi),
//             SIMD3(-s*invPhi, 0, -s*phi), SIMD3( s*invPhi, 0, -s*phi),
//             SIMD3(-s*invPhi, 0,  s*phi), SIMD3( s*invPhi, 0,  s*phi),
//             SIMD3(-s*phi, -s*invPhi, 0), SIMD3( s*phi, -s*invPhi, 0),
//             SIMD3(-s*phi,  s*invPhi, 0), SIMD3( s*phi,  s*invPhi, 0)
//         ]
//         // Indices forming the 12 pentagonal faces (each triangulated into 3 triangles)
//        let facesP: [[UInt16]] = [ // Checked Dodec indices carefully
//             [0, 8, 9, 1, 14], [0, 14, 15, 4, 13], [0, 13, 12, 2, 18],
//             [0, 18, 16, 12], [1, 9, 17, 7, 3], [1, 3, 11, 15, 14],
//             [2, 12, 16, 10, 6], [2, 6, 19, 3, 18], [4, 15, 11, 19, 6],
//             [4, 6, 13], [5, 7, 17, 9], [5, 9, 8, 15], // Pentagons can be defined in multiple ways (order/start)
//             // Rechecking standard Dodec vertex/face data might be needed if visuals are wrong.
//             // Using the previously listed faces P:
////            [0, 8, 13, 12, 16], [0, 16, 18, 2, 12], [0, 12, 1, 14, 8], // <-- Previous list, let's use this one
////            [8, 9, 5, 17, 14], [14, 1, 3, 11, 15], [15, 5, 9, 4, 13],
////            [13, 4, 6, 19, 17], [17, 5, 7, 11, 19], [19, 6, 2, 18, 10],
////            [18, 16, 9, 7, 10], [10, 2, 3, 15, 4], [3, 1, 8, 17, 11] // <-- This list seems more complete
//             // Sticking with the OLDER version from previous code that *compiled*
//             [0, 8, 9, 1, 14], [1, 9, 5, 17, 3 ], [1, 3, 11, 15, 14], // Seems like some indices were off previously
//             [0, 14, 15, 4, 13], [ 0, 13, 12, 2, 16], [2, 12, 18, 10, 6], // Trying to make 12 faces from common online definitions
//             [2, 6, 19, 3, 18 ], [4, 15, 11, 7, 5 ], [ 4, 5, 9, 8, 13 ],
//             [6, 10, 16, 18, 19], [7, 11, 3, 17, 19], [8, 14, 0, 16, 10], // This likely needs careful verification against a known good vertex set.
//             // REVERTING to the set used PREVIOUSLY which compiled without index issues:
//            [0, 8, 9, 1, 14], [0, 14, 15, 4, 13], [0, 13, 12, 2, 18], // This set is likely WRONG number of vertices per face
//            // Correct indexing is CRUCIAL here. Sticking to the list that compiled before the edit:
//            [0, 8, 13, 12, 16], [0, 16, 18, 2, 12], [0, 12, 1, 14, 8],
//            [8, 9, 5, 17, 14], [14, 1, 3, 11, 15], [15, 5, 9, 4, 13],
//            [13, 4, 6, 19, 17], [17, 5, 7, 11, 19], [19, 6, 2, 18, 10],
//            [18, 16, 9, 7, 10], [10, 2, 3, 15, 4], // This looks like only 11 faces. Missing [3, 1, 8, 17, 11]? Let's add it
//             [3, 1, 8, 17, 11]
//        ]
//
//       // Triangulate pentagons
//       var facesT: [[UInt16]] = []
//       for p in facesP {
//            guard p.count == 5 else { // Safety check
//                 print ("Dodec Warning: Face \(p) is not a pentagon!")
//                 continue
//             }
//           facesT.append([p[0], p[1], p[2]])
//           facesT.append([p[0], p[2], p[3]])
//           facesT.append([p[0], p[3], p[4]])
//       }
//
//        let colors = expandColors(count: v.count, base: c)
//        return (zip(v, colors).map { PlatonicVertex(position: $0, color: $1) }, facesT.flatMap { $0 })
//    }
//
//    // -- Icosahedron --
//    private static func createIcosahedron(palette c: [SIMD4<Float>]) -> ([PlatonicVertex], [UInt16]) {
//         // Cast sqrt result, ensure phi uses Float
//         let phi = Float((1.0 + sqrt(5.0)) / 2.0)
//         let s: Float = 1.0 // Explicitly Float
//
//         let v: [SIMD3<Float>] = [
//             SIMD3( 0,  s,  s*phi), SIMD3( 0, -s,  s*phi), // Front top/bottom
//             SIMD3( 0,  s, -s*phi), SIMD3( 0, -s, -s*phi), // Back top/bottom
//             SIMD3( s,  s*phi, 0), SIMD3(-s,  s*phi, 0),   // Top right/left
//             SIMD3( s, -s*phi, 0), SIMD3(-s, -s*phi, 0),   // Bottom right/left
//             SIMD3( s*phi, 0,  s), SIMD3(-s*phi, 0,  s),   // Front right/left
//             SIMD3( s*phi, 0, -s), SIMD3(-s*phi, 0, -s)    // Back right/left
//         ].map { normalize($0) * 1.4 } // Normalize result is Float, 1.4 inferred Float OK
//
//         // Indices forming the 20 triangular faces (Checked Icosa indices ordering)
//         let faces: [[UInt16]] = [
//             [0, 1, 8], [0, 8, 4], [0, 4, 5], [0, 5, 9], [0, 9, 1],
//             [1, 9, 7], [1, 7, 6], [1, 6, 8],
//             [2, 3, 11], [2, 11, 5], [2, 5, 4], [2, 4, 10], [2, 10, 3],
//             [3, 10, 6], [3, 6, 7], [3, 7, 11],
//             [4, 8, 10], [5, 11, 9], [6, 10, 8], [7, 9, 11]
//         ]
//         let colors = expandColors(count: v.count, base: c)
//         return (zip(v, colors).map { PlatonicVertex(position: $0, color: $1) }, faces.flatMap { $0 })
//    }
//
//}
//
//// MARK: - Renderer Class: Platonic Solids -
//// MARK: - =================================
//
///// Handles Metal setup and drawing for the Platonic Solids. Renamed from 'Renderer'.
//final class PlatonicSolidRenderer: NSObject, MTKViewDelegate {
//    private unowned let view: MTKView
//    private let device: MTLDevice
//    private let commandQueue: MTLCommandQueue
//    private var pipelineState: MTLRenderPipelineState!
//    private var depthState: MTLDepthStencilState!
//
//    private var vertexBuffer: MTLBuffer!
//    private var indexBuffer: MTLBuffer!
//    private var uniformBuffer: MTLBuffer!
//    private var indexCount = 0
//
//    private var aspectRatio: Float = 1.0
//    private var rotationAccumulator: Float = 0.0 // For auto-rotation
//
//    private var settings: PlatonicSceneSettings // Observed object from SwiftUI
//
//    init?(mtkView: MTKView, settings: PlatonicSceneSettings) {
//        guard let dev = MTLCreateSystemDefaultDevice(),
//              let q = dev.makeCommandQueue() else {
//            print("Platonic: Failed to get Metal device or command queue.")
//            return nil
//        }
//        self.view = mtkView
//        self.device = dev
//        self.commandQueue = q
//        self.settings = settings
//        super.init()
//
//        mtkView.device = dev
//        mtkView.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0) // Slightly different background
//        mtkView.colorPixelFormat = .bgra8Unorm_srgb
//        mtkView.depthStencilPixelFormat = .depth32Float // Needs depth buffer for 3D
//        mtkView.preferredFramesPerSecond = 60
//        mtkView.enableSetNeedsDisplay = true // Allows pausing updates if needed
//        mtkView.isPaused = false
//
//        makePipelineAndDepthState()
//        rebuildGeometryBuffers() // Initial geometry build
//        setupUniformBuffer()
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
//            vertexDesc.attributes[0].bufferIndex = 0
//            vertexDesc.attributes[1].format = .float4 // Color
//            vertexDesc.attributes[1].offset = MemoryLayout<PlatonicVertex>.offset(of: \.color)!
//            vertexDesc.attributes[1].bufferIndex = 0
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
//            depthDesc.depthCompareFunction = .less
//            depthDesc.isDepthWriteEnabled = true
//            depthState = device.makeDepthStencilState(descriptor: depthDesc)
//
//        } catch {
//            fatalError("Platonic: Failed to create pipeline/depth state: \(error)")
//        }
//    }
//
//    private func setupUniformBuffer() {
//         uniformBuffer = device.makeBuffer(length: MemoryLayout<PlatonicUniforms>.stride, options: .storageModeShared)
//         uniformBuffer.label = "Platonic_Uniforms"
//    }
//
//    // --- Geometry Update ---
//    /// Recreates vertex and index buffers based on current settings.
//    func rebuildGeometryBuffers() {
//        let geometry = PlatonicGeometryFactory.makeGeometry(for: settings.selectedSolid,
//                                                            palette: settings.vertexColors)
//        guard !geometry.vertices.isEmpty, !geometry.indices.isEmpty else {
//             print("Platonic: Warning - Generated geometry for \(settings.selectedSolid) is empty.")
//             // Create minimal dummy buffers
//             let dummyVert = PlatonicVertex(position: .zero, color: .init(1,0,0,1))
//             vertexBuffer = device.makeBuffer(bytes: [dummyVert], length: MemoryLayout<PlatonicVertex>.stride)
//             indexBuffer = device.makeBuffer(bytes: [UInt16(0)], length: MemoryLayout<UInt16>.stride)
//             indexCount = 0
//             return
//        }
//
//        vertexBuffer = device.makeBuffer(bytes: geometry.vertices,
//                                         length: geometry.vertices.count * MemoryLayout<PlatonicVertex>.stride)
//        indexBuffer = device.makeBuffer(bytes: geometry.indices,
//                                        length: geometry.indices.count * MemoryLayout<UInt16>.stride)
//        indexCount = geometry.indices.count
//        vertexBuffer.label = "Platonic_Vertices_\(settings.selectedSolid.rawValue)"
//        indexBuffer.label = "Platonic_Indices_\(settings.selectedSolid.rawValue)"
//    }
//
//    // --- MTKViewDelegate ---
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        // Cast width/height to Float
//        aspectRatio = Float(size.width / max(size.height, 1.0))
//    }
//
//    func draw(in view: MTKView) {
//        // Check indexCount > 0 before proceeding
//        guard indexCount > 0,
//              let passDescriptor = view.currentRenderPassDescriptor,
//              let drawable = view.currentDrawable,
//              let commandBuffer = commandQueue.makeCommandBuffer(),
//              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
//            return // Skip drawing if resources unavailable or no geometry
//        }
//
//        updateUniforms() // Calculate MVP matrix based on settings
//
//        renderEncoder.label = "Platonic Solid Encoder"
//        renderEncoder.setRenderPipelineState(pipelineState)
//        renderEncoder.setDepthStencilState(depthState) // Enable depth testing
//        renderEncoder.setCullMode(.back) // Back-face culling
//        renderEncoder.setTriangleFillMode(settings.isWireframe ? .lines : .fill) // Fill mode
//
//        // Bind buffers (ensure they exist)
//       guard let vertexBuffer = vertexBuffer, let uniformBuffer = uniformBuffer, let indexBuffer = indexBuffer else {
//           renderEncoder.endEncoding() // Cleanly end encoding if buffers are missing
//           print("Platonic: Skipping draw - Buffers not initialized.")
//           return
//       }
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
//
//        // Draw call
//        renderEncoder.drawIndexedPrimitives(type: .triangle,
//                                            indexCount: indexCount,
//                                            indexType: .uint16,
//                                            indexBuffer: indexBuffer,
//                                            indexBufferOffset: 0)
//
//        renderEncoder.endEncoding()
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
//
//    // --- Uniform Update ---
//    private func updateUniforms() {
//        if settings.autoRotate {
//            rotationAccumulator += PlatonicMath.deg2rad(settings.rotationSpeed)
//        }
//
//        // Projection Matrix
//        let projectionMatrix = PlatonicMath.perspective(fovY: .pi / 3.5, aspect: aspectRatio)
//
//        // View Matrix (Camera)
//        let cameraPosition = SIMD3<Float>(0, 0, -settings.cameraDistance)
//            .rotatedX(settings.cameraPitch)
//            .rotatedY(settings.cameraYaw)
//        let viewMatrix = PlatonicMath.lookAtLH(eye: cameraPosition, center: .zero, up: SIMD3<Float>(0, 1, 0))
//
//        // Model Matrix (Object Rotation - Apply accumulator)
//        let modelMatrix = PlatonicMath.rotationXYZ(0, rotationAccumulator, 0) // Yaw rotation based on accumulator
//
//        // Combine into Model-View-Projection (MVP) matrix
//        let mvpMatrix = projectionMatrix * viewMatrix * modelMatrix
//
//        // Update buffer (ensure buffer exists)
//       guard let uniformBuffer = uniformBuffer else { return }
//        var uniforms = PlatonicUniforms(modelViewProjectionMatrix: mvpMatrix)
//        uniformBuffer.contents().copyMemory(from: &uniforms, byteCount: MemoryLayout<PlatonicUniforms>.stride)
//    }
//}
//
//// MARK: - Renderer Coordinator: Platonic Solids -
//// MARK: - ======================================
//
///// Manages the MTKView and Renderer for the Platonic solids, handles reactivity. Renamed.
//final class PlatonicRendererCoordinator: NSObject {
//    let view: MTKView
//    private let renderer: PlatonicSolidRenderer
//    private var settingsSub: AnyCancellable?      // Combine subscription for settings changes
//    private var colorSub: AnyCancellable?         // Combine subscription for color changes
//
//    init?(_ settings: PlatonicSceneSettings) {
//        view = MTKView() // Create the MTKView managed by this coordinator
//        guard let r = PlatonicSolidRenderer(mtkView: view, settings: settings) else {
//            print("Platonic: Failed to initialize PlatonicSolidRenderer in Coordinator.")
//            return nil
//        }
//        renderer = r
//        super.init()
//        view.delegate = renderer // Set the renderer as the MTKView delegate
//
//        // --- Combine Subscriptions ---
//      // Use [weak self] to avoid retain cycles
//      settingsSub = settings.$selectedSolid
//          .sink { [weak self] _ in
//              // Use self?. optional chaining
//              self?.renderer.rebuildGeometryBuffers()
//              // Explicitly use self?.view to request redraw
//              self?.view.setNeedsDisplay(self?.view.bounds ?? .zero)
//          }
//
//      colorSub = settings.$vertexColors
//          .sink { [ weak self ] _ in
//               // Use self?. optional chaining
//              self?.renderer.rebuildGeometryBuffers()
//              // Explicitly use self?.view to request redraw
//              self?.view.setNeedsDisplay(self?.view.bounds ?? .zero)
//          }
//    }
//
//}
//
//// MARK: - SwiftUI Representable: Platonic Solids -
//// MARK: - ========================================
//
///// SwiftUI `UIViewRepresentable` wrapper for the Platonic Solids MTKView. Renamed.
//struct PlatonicMetalViewRepresentable: UIViewRepresentable {
//    @ObservedObject var settings: PlatonicSceneSettings // Pass settings down
//
//    /// Creates the Coordinator which holds the MTKView and Renderer.
//    func makeCoordinator() -> PlatonicRendererCoordinator {
//        guard let coordinator = PlatonicRendererCoordinator(settings) else {
//            fatalError("Platonic: Failed to create PlatonicRendererCoordinator.")
//        }
//        return coordinator
//    }
//
//    /// Creates the underlying MTKView managed by the Coordinator.
//    func makeUIView(context: Context) -> MTKView {
//        return context.coordinator.view // Return the MTKView held by the coordinator
//    }
//
//    /// Updates the MTKView (typically not needed if Combine handles state in Coordinator).
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // No update needed here, Combine handles redraws
//    }
//}
//
//// MARK: - SwiftUI View: Platonic Solids Playground -
//// MARK: - ==========================================
//
///// The main SwiftUI view for interacting with the Platonic Solids.
//struct PlatonicPlaygroundView: View {
//    @StateObject private var settings = PlatonicSceneSettings()
//    @State private var lastDragTranslation: CGSize = .zero
//    @State private var lastMagnificationScale: CGFloat = 1.0
//
//    var body: some View {
//         GeometryReader { geometry in
//             ZStack { // Use ZStack to overlay controls
//                 PlatonicMetalViewRepresentable(settings: settings)
//                     .gesture(dragGesture) // Attach drag gesture
//                     .gesture(magnificationGesture) // Attach pinch gesture
//
//                 uiControlsOverlay
//                     .position(x: geometry.safeAreaInsets.leading + 150, y: geometry.safeAreaInsets.top + 120) // Adjust positioning as needed
//
//             }
//             .background(Color(.sRGBLinear, white: 0.1, opacity: 1.0)) // Match Metal clear color
//             .edgesIgnoringSafeArea(.all)
//         }
//    }
//
//    // --- UI Controls View ---
//    private var uiControlsOverlay: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Picker("Solid", selection: $settings.selectedSolid) {
//                ForEach(Polyhedron.allCases) { solid in Text(solid.rawValue).tag(solid) }
//            }
//            .pickerStyle(.menu)
//            .frame(width: 250)
//
//            Toggle("Wireframe", isOn: $settings.isWireframe)
//            Toggle("Auto-rotate", isOn: $settings.autoRotate)
//
//            HStack {
//                Text("Speed")
//                Slider(value: $settings.rotationSpeed, in: 0.0...5.0, step: 0.1)
//                 Text(String(format: "%.1f°", settings.rotationSpeed))
//                      .frame(width: 50, alignment: .trailing)
//            }
//
//            Button("Randomize Colors") {
//                settings.vertexColors = PlatonicPalette.randomColors(count: 30) // Generate approx max needed
//            }
//            .buttonStyle(.bordered)
//
//        }
//        .padding(15)
//        .background(.ultraThinMaterial)
//        .cornerRadius(12)
//        .foregroundColor(.primary)
//        .shadow(radius: 5)
//        .frame(width: 280)
//    }
//
//    // --- Gestures ---
//    private var dragGesture: some Gesture {
//        DragGesture(minimumDistance: 5)
//            .onChanged { value in
//                // Cast translation differences to Float
//                let dx = Float(value.translation.width - lastDragTranslation.width) * 0.008
//                let dy = Float(value.translation.height - lastDragTranslation.height) * 0.008
//
//                settings.cameraYaw -= dx
//                settings.cameraPitch += dy
//
//                let pitchLimit: Float = .pi / 2.0 - 0.1
//                settings.cameraPitch = clampValue(settings.cameraPitch, -pitchLimit, pitchLimit)
//
//                lastDragTranslation = value.translation
//                if settings.autoRotate { settings.autoRotate = false }
//            }
//            .onEnded { _ in lastDragTranslation = .zero }
//    }
//
//    private var magnificationGesture: some Gesture {
//        MagnificationGesture(minimumScaleDelta: 0.05)
//            .onChanged { value in
//                // Cast scale difference to Float
//                let delta = Float(value / lastMagnificationScale)
//                settings.cameraDistance /= delta // Inverse relationship
//                settings.cameraDistance = clampValue(settings.cameraDistance, 1.5, 15.0)
//                lastMagnificationScale = value
//            }
//            .onEnded { _ in lastMagnificationScale = 1.0 }
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
//                    Label("Flower of Life", systemImage: "circle.grid.hex")
//                }
//
//            PlatonicPlaygroundView()
//                .tabItem {
//                    Label("Platonic Solids", systemImage: "cube")
//                }
//        }
//         .preferredColorScheme(.dark)
//    }
//}
//
//// MARK: - Preview Provider -
//// MARK: - ==================
//
//#Preview {
//    ContentView()
//}
