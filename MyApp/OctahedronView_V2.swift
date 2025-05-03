////
////  OctahedronView_V2.swift
////  MyApp
////
////  Created by Cong Le on 5/3/25.
////
//
//import SwiftUI
//import MetalKit
//import simd // For matrix math
//
//// MARK: - Vertex Data Structure (Swift & Metal Compatible)
//// (Keep this struct in the Swift file as it's used for buffer creation)
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
//    var indexBuffer: MTLBuffer!
//    var uniformBuffer: MTLBuffer!
//
//    var rotationAngle: Float = 0.0
//    var aspectRatio: Float = 1.0
//
//    // Octahedron vertex and index data (Keep this in Swift)
//    let vertices: [OctahedronVertex] = [
//        OctahedronVertex(position: SIMD3<Float>(0, 1, 0), color: SIMD4<Float>(0, 1, 0, 1)), // 0: Top
//        OctahedronVertex(position: SIMD3<Float>(1, 0, 0), color: SIMD4<Float>(1, 0, 0, 1)), // 1: +X
//        OctahedronVertex(position: SIMD3<Float>(0, 0, 1), color: SIMD4<Float>(0, 0, 1, 1)), // 2: +Z
//        OctahedronVertex(position: SIMD3<Float>(-1, 0, 0), color: SIMD4<Float>(1, 1, 0, 1)),// 3: -X
//        OctahedronVertex(position: SIMD3<Float>(0, 0, -1), color: SIMD4<Float>(0, 1, 1, 1)),// 4: -Z
//        OctahedronVertex(position: SIMD3<Float>(0, -1, 0), color: SIMD4<Float>(1, 0, 1, 1)) // 5: Bottom
//    ]
//
//    let indices: [UInt16] = [
//        0, 1, 2, 0, 2, 3, 0, 3, 4, 0, 4, 1, // Top faces
//        5, 2, 1, 5, 3, 2, 5, 4, 3, 5, 1, 4  // Bottom faces
//    ]
//
//    init?(metalKitView: MTKView) {
//        guard let device = MTLCreateSystemDefaultDevice(),
//              let queue = device.makeCommandQueue() else {
//            print("Metal is not supported on this device")
//            return nil
//        }
//        self.device = device
//        self.commandQueue = queue
//        metalKitView.device = device
//
//        super.init()
//
//        // Load shaders *before* setting up pipeline that uses them
//        guard let defaultLibrary = device.makeDefaultLibrary() else {
//             fatalError("Could not load default Metal library. Ensure OctahedronShaders.metal is included in the target.")
//         }
//
//        setupPipeline(metalKitView: metalKitView, library: defaultLibrary)
//        setupBuffers()
//        setupDepthStencil()
//    }
//
//    // --- Setup Functions ---
//
//    // Modified setupPipeline to accept the library
//    func setupPipeline(metalKitView: MTKView, library: MTLLibrary) {
//        do {
//            // Load functions from the pre-compiled library
//            guard let vertexFunction = library.makeFunction(name: "octahedron_vertex_shader"),
//                  let fragmentFunction = library.makeFunction(name: "octahedron_fragment_shader") else {
//                fatalError("Could not load shader functions from Metal library")
//            }
//
//            // --- The rest of the pipeline setup remains the same ---
//            let pipelineDescriptor = MTLRenderPipelineDescriptor()
//            pipelineDescriptor.label = "Octahedron Pipeline"
//            pipelineDescriptor.vertexFunction = vertexFunction
//            pipelineDescriptor.fragmentFunction = fragmentFunction
//            pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
//            pipelineDescriptor.depthAttachmentPixelFormat = metalKitView.depthStencilPixelFormat
//
//            let vertexDescriptor = MTLVertexDescriptor()
//            vertexDescriptor.attributes[0].format = .float3 // position
//            vertexDescriptor.attributes[0].offset = 0
//            vertexDescriptor.attributes[0].bufferIndex = 0
//            vertexDescriptor.attributes[1].format = .float4 // color
//            vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
//            vertexDescriptor.attributes[1].bufferIndex = 0
//            vertexDescriptor.layouts[0].stride = MemoryLayout<OctahedronVertex>.stride
//            vertexDescriptor.layouts[0].stepRate = 1
//            vertexDescriptor.layouts[0].stepFunction = .perVertex
//            pipelineDescriptor.vertexDescriptor = vertexDescriptor
//
//            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//
//        } catch {
//            fatalError("Failed to create Metal pipeline state: \(error)")
//        }
//    }
//
//    func setupBuffers() {
//        let vertexDataSize = vertices.count * MemoryLayout<OctahedronVertex>.stride
//        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertexDataSize, options: [])
//
//        let indexDataSize = indices.count * MemoryLayout<UInt16>.stride
//        indexBuffer = device.makeBuffer(bytes: indices, length: indexDataSize, options: [])
//
//        let uniformBufferSize = MemoryLayout<Uniforms>.size // Now referencing struct from .metal implicitly
//        uniformBuffer = device.makeBuffer(length: uniformBufferSize, options: .storageModeShared)
//    }
//
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
//    // --- Update Uniforms ---
//    func updateUniforms() {
//        let projectionMatrix = matrix_perspective_left_hand(fovyRadians: Float.pi / 3.0,
//                                                             aspectRatio: aspectRatio,
//                                                             nearZ: 0.1,
//                                                             farZ: 100.0)
//        let viewMatrix = matrix_look_at_left_hand(eye: SIMD3<Float>(0, 0, -4),
//                                                  center: SIMD3<Float>(0, 0, 0),
//                                                  up: SIMD3<Float>(0, 1, 0))
//        let modelMatrix = matrix_multiply(matrix_rotation_y(radians: rotationAngle),
//                                          matrix_rotation_x(radians: rotationAngle * 0.5))
//        let modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix)
//        let mvpMatrix = matrix_multiply(projectionMatrix, modelViewMatrix)
//
//        let bufferPointer = uniformBuffer.contents()
//        // We still need the layout struct in Swift to know the size and layout for memcpy
//        // Note: The `Uniforms` struct definition is implicitly used via the shader introspection
//        struct SwiftUniformsLayout { var modelViewProjectionMatrix: matrix_float4x4 }
//        var uniforms = SwiftUniformsLayout(modelViewProjectionMatrix: mvpMatrix)
//        memcpy(bufferPointer, &uniforms, MemoryLayout<SwiftUniformsLayout>.size)
//
//        rotationAngle += 0.005
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
//        updateUniforms()
//
//        renderEncoder.label = "Octahedron Render Encoder"
//        renderEncoder.setRenderPipelineState(pipelineState)
//        renderEncoder.setDepthStencilState(depthState)
//        renderEncoder.setTriangleFillMode(.lines) // Wireframe
//        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
//
//        renderEncoder.drawIndexedPrimitives(type: .triangle,
//                                            indexCount: indices.count,
//                                            indexType: .uint16,
//                                            indexBuffer: indexBuffer,
//                                            indexBufferOffset: 0)
//
//        renderEncoder.endEncoding()
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
//}
//
//// MARK: - SwiftUI View Representable (No changes needed here)
//
//struct MetalOctahedronViewRepresentable: UIViewRepresentable {
//    typealias UIViewType = MTKView
//
//    func makeCoordinator() -> OctahedronRenderer {
//        guard let coordinator = OctahedronRenderer(metalKitView: MTKView()) else { // Pass dummy view initially
//            fatalError("Failed to create OctahedronRenderer Coordinator")
//        }
//        return coordinator
//    }
//
//    func makeUIView(context: Context) -> MTKView {
//        let mtkView = MTKView()
//        mtkView.delegate = nil // Set delegate *after* renderer is fully configured below
//        mtkView.preferredFramesPerSecond = 60
//        mtkView.enableSetNeedsDisplay = false
//
//        mtkView.depthStencilPixelFormat = .depth32Float
//        mtkView.clearDepth = 1.0
//        mtkView.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
//        mtkView.colorPixelFormat = .bgra8Unorm_srgb
//
//        // Initialize renderer with the actual view we just configured
//        // The coordinator instance is already created by makeCoordinator
//        guard let renderer = OctahedronRenderer(metalKitView: mtkView) else {
//             fatalError("Renderer could not be initialized with final MTKView")
//        }
//        mtkView.delegate = renderer // Assign the fully initialized renderer as delegate
//         context.coordinator.drawableSizeWillChange(mtkView.drawableSize) // Initial aspect ratio setup
//
//        // Re-assign the potentially re-created renderer to the coordinator instance SwiftUI holds
//        // NOTE: This assignment might be tricky. A better pattern involves passing the MTKView TO the coordinator's init,
//        // but the above should work if makeCoordinator returns the *same instance* used here. Let's test this way first.
//        // If issues arise, refine the init pass-through.
//
//        return mtkView
//    }
//
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // No updates needed for constant rotation
//    }
//}
//
//// MARK: - Main SwiftUI View (No changes needed here)
//
//struct OctahedronView: View {
//    var body: some View {
//        VStack {
//            Text("Rotating Wireframe Octahedron (Metal)")
//                .font(.headline)
//                .padding(.top)
//
//            MetalOctahedronViewRepresentable()
//                .edgesIgnoringSafeArea(.all)
//        }
//         .background(Color(red: 0.1, green: 0.1, blue: 0.15))
//         .colorScheme(.dark)
//    }
//}
//
//// MARK: - Preview Provider (No changes needed here)
//
//#Preview {
//    OctahedronView()
//}
//
//// MARK: - Matrix Math Helper Functions (Keep in Swift)
//
//func matrix_perspective_left_hand(fovyRadians: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
//    let y = 1.0 / tan(fovyRadians * 0.5)
//    let x = y / aspectRatio
//    let z = farZ / (farZ - nearZ)
//    let w = -nearZ * z
//
//    return matrix_float4x4(
//        SIMD4<Float>(x, 0, 0, 0),
//        SIMD4<Float>(0, y, 0, 0),
//        SIMD4<Float>(0, 0, z, 1),
//        SIMD4<Float>(0, 0, w, 0)
//    )
//}
//
//func matrix_look_at_left_hand(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> matrix_float4x4 {
//    let z = normalize(center - eye)
//    let x = normalize(cross(up, z))
//    let y = cross(z, x)
//    let t = SIMD3<Float>(-dot(x, eye), -dot(y, eye), -dot(z, eye))
//
//    return matrix_float4x4(
//        SIMD4<Float>(x.x, y.x, z.x, 0),
//        SIMD4<Float>(x.y, y.y, z.y, 0),
//        SIMD4<Float>(x.z, y.z, z.z, 0),
//        SIMD4<Float>(t.x, t.y, t.z, 1)
//   )
//}
//
//func matrix_rotation_y(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians)
//    let s = sin(radians)
//    return matrix_float4x4(
//        SIMD4<Float>( c, 0, s, 0),
//        SIMD4<Float>( 0, 1, 0, 0),
//        SIMD4<Float>(-s, 0, c, 0),
//        SIMD4<Float>( 0, 0, 0, 1)
//    )
//}
//
//func matrix_rotation_x(radians: Float) -> matrix_float4x4 {
//    let c = cos(radians)
//    let s = sin(radians)
//    return matrix_float4x4(
//        SIMD4<Float>(1,  0, 0, 0),
//        SIMD4<Float>(0,  c, s, 0),
//        SIMD4<Float>(0, -s, c, 0),
//        SIMD4<Float>(0,  0, 0, 1)
//    )
//}
//
//func matrix_multiply(_ matrix1: matrix_float4x4, _ matrix2: matrix_float4x4) -> matrix_float4x4 {
//    return matrix1 * matrix2
//}
