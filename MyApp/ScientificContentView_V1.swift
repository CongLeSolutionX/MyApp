////
////  ScientificContentView.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
//
//
//import SwiftUI
//import MetalKit
//import simd // Use SIMD for efficient vector/matrix math
//
//// MARK: - Configuration & Simple Data
//
//struct Configuration {
//    // Molecule Data (Simple Fictional Example: Water-like H2X)
//    static let atoms: [AtomData] = [
//        AtomData(position: SIMD3<Float>( 0.0,  0.0, 0.0), color: SIMD4<Float>(1.0, 0.2, 0.2, 1.0), radius: 0.5), // Central Atom (Red)
//        AtomData(position: SIMD3<Float>(-0.6,  0.7, 0.0), color: SIMD4<Float>(0.9, 0.9, 0.9, 1.0), radius: 0.3), // Hydrogen-like 1 (White)
//        AtomData(position: SIMD3<Float>( 0.6,  0.7, 0.0), color: SIMD4<Float>(0.9, 0.9, 0.9, 1.0), radius: 0.3), // Hydrogen-like 2 (White)
//    ]
//
//    static let bonds: [BondDataRaw] = [
//        BondDataRaw(atomIndex1: 0, atomIndex2: 1), // Bond 0 -> 1
//        BondDataRaw(atomIndex1: 0, atomIndex2: 2)  // Bond 0 -> 2
//    ]
//
//    static let bondRadius: Float = 0.08
//    static let bondColor: SIMD4<Float> = SIMD4<Float>(0.7, 0.7, 0.7, 1.0) // Grey bonds
//
//    // Rendering Settings
//    static let sphereSegments = 16 // Detail level for spheres (latitude/longitude divisions)
//    static let cylinderSegments = 8 // Detail level for cylinder caps/sides
//    static let lightDirection = normalize(SIMD3<Float>(0.5, 0.8, -0.4))
//    static let cameraDistance: Float = 4.0
//}
//
//// MARK: - Metal Shaders
//
//let scientificShaderSource = """
//using namespace metal;
//
//// ---- Data Structures ----
//
//struct Vertex {
//    float3 position [[attribute(0)]];
//    float3 normal   [[attribute(1)]];
//};
//
//// Instance data common for both atoms (spheres) and bonds (cylinders)
//// We'll use scale differently: uniform for spheres, non-uniform for cylinders
//struct InstanceData {
//    float4x4 modelMatrix [[attribute(2)]]; // Handles position, rotation, scale
//    float4 color         [[attribute(6)]]; // Base color (packed across attributes 6-9 if needed, but fits here)
//};
//
//struct VertexOut {
//    float4 position [[position]];
//    float3 normal_world; // Normal in world space for lighting
//    float4 color;
//};
//
//struct Uniforms {
//    float4x4 projectionMatrix;
//    float4x4 viewMatrix;
//    float3 lightDirection_world;
//};
//
//// ---- Vertex Shader ----
//vertex VertexOut vertex_main(
//    Vertex in            [[stage_in]],
//    InstanceData instance [[stage_in]], // Reads per-instance data directly via [[attribute()]]
//    constant Uniforms &uniforms [[buffer(0)]]
//) {
//    VertexOut out;
//
//    // Calculate world position: Apply instance's full model matrix to base vertex
//    float4 pos_model = float4(in.position, 1.0);
//    float4 pos_world = instance.modelMatrix * pos_model;
//
//    // Calculate final clip-space position
//    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * pos_world;
//
//    // Transform normal to world space: Use upper 3x3 of model matrix (inverse transpose is better for non-uniform scale, but approximate here)
//    // For rotation/uniform scale, just transforming by model matrix (ignoring translation) works okay.
//    // For cylinders, need proper inverse transpose if scaling non-uniformly.
//    float3 normal_model = in.normal;
//    float3 normal_world = (instance.modelMatrix * float4(normal_model, 0.0)).xyz;
//    out.normal_world = normalize(normal_world); // Ensure it's normalized
//
//    out.color = instance.color;
//
//    return out;
//}
//
//// ---- Fragment Shader ----
//fragment float4 fragment_main(VertexOut in [[stage_in]],
//                              constant Uniforms &uniforms [[buffer(0)]])
//{
//    // Basic Lambertian (diffuse) lighting
//    float diffuseFactor = max(0.0, dot(normalize(in.normal_world), -uniforms.lightDirection_world));
//
//    // Ambient component
//    float ambientFactor = 0.2;
//
//    // Combine ambient and diffuse, modulated by instance color
//    float3 finalColor = in.color.rgb * (ambientFactor + diffuseFactor * 0.8); // 0.8 scales diffuse brightness
//
//    return float4(finalColor, in.color.a); // Use alpha from instance color
//}
//"""
//
//// MARK: - Swift-side Data Structures
//
//struct AtomData {
//    var position: SIMD3<Float>
//    var color: SIMD4<Float>
//    var radius: Float
//}
//
//struct BondDataRaw { // Before processing into matrices
//    var atomIndex1: Int
//    var atomIndex2: Int
//}
//
//struct InstanceDataSwift { // Matches InstanceData struct (expanded to fit matrix)
//    var modelMatrix: matrix_float4x4
//    var color: SIMD4<Float>
//}
//
//struct UniformsSwift { // Matches Uniforms struct
//    var projectionMatrix: matrix_float4x4
//    var viewMatrix: matrix_float4x4
//    var lightDirection_world: SIMD3<Float>
//}
//
//struct VertexSwift { // Matches Vertex struct
//    var position: SIMD3<Float>
//    var normal: SIMD3<Float>
//}
//
//// MARK: - Math & Geometry Helpers
//
//// Simple Matrix Math Helpers
//func matrix_perspective_right_hand(fovyRadians: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
//    let y = 1.0 / tan(fovyRadians * 0.5)
//    let x = y / aspectRatio
//    let z = farZ / (nearZ - farZ)
//    return matrix_float4x4(
//        columns:(
//            SIMD4<Float>(x,  0,  0,  0),
//            SIMD4<Float>(0,  y,  0,  0),
//            SIMD4<Float>(0,  0,  z, -1),
//            SIMD4<Float>(0,  0,  z * nearZ,  0)
//        )
//    )
//}
//
//func matrix_lookat_right_hand(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> matrix_float4x4 {
//    let z = normalize(eye - center)
//    let x = normalize(cross(up, z))
//    let y = cross(z, x)
//    let t = SIMD3<Float>(-dot(x, eye), -dot(y, eye), -dot(z, eye))
//
//    return matrix_float4x4(
//        columns:(
//            SIMD4<Float>(x.x, y.x, z.x, 0),
//            SIMD4<Float>(x.y, y.y, z.y, 0),
//            SIMD4<Float>(x.z, y.z, z.z, 0),
//            SIMD4<Float>(t.x, t.y, t.z, 1)
//        )
//    )
//}
//
//func matrix_translation(_ t: SIMD3<Float>) -> matrix_float4x4 {
//    return matrix_float4x4(
//        columns:(
//            SIMD4<Float>(1, 0, 0, 0),
//            SIMD4<Float>(0, 1, 0, 0),
//            SIMD4<Float>(0, 0, 1, 0),
//            SIMD4<Float>(t.x, t.y, t.z, 1)
//        )
//    )
//}
//
//func matrix_uniform_scale(_ s: Float) -> matrix_float4x4 {
//    return matrix_float4x4(diagonal: SIMD4<Float>(s, s, s, 1))
//}
//
//func matrix_rotation_y(_ angleRadians: Float) -> matrix_float4x4 {
//    let c = cos(angleRadians)
//    let s = sin(angleRadians)
//    return matrix_float4x4(
//        columns:(
//            SIMD4<Float>( c, 0, s, 0),
//            SIMD4<Float>( 0, 1, 0, 0),
//            SIMD4<Float>(-s, 0, c, 0),
//            SIMD4<Float>( 0, 0, 0, 1)
//        )
//    )
//}
//
//func matrix_rotation_x(_ angleRadians: Float) -> matrix_float4x4 {
//    let c = cos(angleRadians)
//    let s = sin(angleRadians)
//    return matrix_float4x4(
//        columns:(
//            SIMD4<Float>(1,  0, 0, 0),
//            SIMD4<Float>(0,  c, s, 0),
//            SIMD4<Float>(0, -s, c, 0),
//            SIMD4<Float>(0,  0, 0, 1)
//        )
//    )
//}
//
//// Function to create a matrix that orients and scales a cylinder between two points
//func matrix_for_cylinder(start: SIMD3<Float>, end: SIMD3<Float>, radius: Float) -> matrix_float4x4 {
//    let vector = end - start
//    let length = simd.length(vector)
//    if length < 1e-6 { return matrix_identity_float4x4 } // Avoid division by zero
//
//    let direction = vector / length
//
//    // Calculate rotation axis and angle
//    let up = SIMD3<Float>(0, 1, 0) // Cylinder model points along Y axis
//    var rotationAxis = cross(up, direction)
//    var rotationAngle = acos(dot(up, direction))
//
//    // Handle cases where direction is parallel to up vector
//    if simd.length(rotationAxis) < 1e-6 {
//        if dot(up, direction) > 0 { // Aligned with Y
//             rotationAxis = SIMD3<Float>(1, 0, 0) // Any axis perpendicular to Y
//             rotationAngle = 0
//        } else { // Opposite to Y
//             rotationAxis = SIMD3<Float>(1, 0, 0) // Any axis perpendicular to Y
//             rotationAngle = .pi
//        }
//    } else {
//        rotationAxis = normalize(rotationAxis)
//    }
//
//    let rotationMatrix = matrix_float4x4(simd_quatf(angle: rotationAngle, axis: rotationAxis))
//    
//    // Scale matrix: X/Z for radius, Y for length
//    let scaleMatrix = matrix_float4x4(diagonal: SIMD4<Float>(radius, length, radius, 1.0))
//
//    // Translation matrix (to the midpoint, cylinder model is centered at origin)
//    let translationMatrix = matrix_translation(start + vector * 0.5) // Move to midpoint
//
//    return translationMatrix * rotationMatrix * scaleMatrix
//}
//
//// MARK: - Geometry Generation
//
//func createSphereVertices(radius: Float, segments: Int) -> ([VertexSwift], [UInt16]) {
//    var vertices: [VertexSwift] = []
//    var indices: [UInt16] = []
//    let vSegments = segments
//    let hSegments = segments * 2
//
//    // Generate vertices
//    for i in 0...vSegments {
//        let v = Float(i) / Float(vSegments) // Vertical texture coordinate (latitude)
//        let phi = v * .pi // Angle from Y+ axis
//
//        for j in 0...hSegments {
//            let u = Float(j) / Float(hSegments) // Horizontal texture coord (longitude)
//            let theta = u * (2.0 * .pi) // Angle around Y axis
//
//            let x = radius * sin(phi) * cos(theta)
//            let y = radius * cos(phi)
//            let z = radius * sin(phi) * sin(theta)
//
//            let position = SIMD3<Float>(x, y, z)
//            let normal = normalize(position) // For a sphere centered at origin, normal is position vector
//
//            vertices.append(VertexSwift(position: position, normal: normal))
//        }
//    }
//
//    // Generate indices for triangles
//    for i in 0..<vSegments {
//        for j in 0..<hSegments {
//            let row1 = UInt16(i * (hSegments + 1))
//            let row2 = UInt16((i + 1) * (hSegments + 1))
//
//            let p1 = row1 + UInt16(j)
//            let p2 = row1 + UInt16(j + 1)
//            let p3 = row2 + UInt16(j + 1)
//            let p4 = row2 + UInt16(j)
//
//            indices.append(contentsOf: [p1, p2, p4]) // First triangle
//            indices.append(contentsOf: [p2, p3, p4]) // Second triangle
//        }
//    }
//
//    return (vertices, indices)
//}
//
//// Basic Cylinder (aligned along Y axis, origin at center)
//func createCylinderVertices(radius: Float, height: Float, segments: Int) -> ([VertexSwift], [UInt16]) {
//    var vertices: [VertexSwift] = []
//    var indices: [UInt16] = []
//    let halfHeight = height / 2.0
//
//    // --- Top Cap ---
//    let topCenterIndex = UInt16(vertices.count)
//    vertices.append(VertexSwift(position: SIMD3<Float>(0, halfHeight, 0), normal: SIMD3<Float>(0, 1, 0)))
//    for i in 0...segments {
//        let angle = Float(i) / Float(segments) * (2.0 * .pi)
//        let x = radius * cos(angle)
//        let z = radius * sin(angle)
//        vertices.append(VertexSwift(position: SIMD3<Float>(x, halfHeight, z), normal: SIMD3<Float>(0, 1, 0)))
//    }
//    // Top Cap Indices
//    for i in 1...segments {
//        indices.append(contentsOf: [topCenterIndex, topCenterIndex + UInt16(i), topCenterIndex + UInt16(i + 1)])
//    }
//
//    // --- Bottom Cap ---
//    let bottomCenterIndex = UInt16(vertices.count)
//    vertices.append(VertexSwift(position: SIMD3<Float>(0, -halfHeight, 0), normal: SIMD3<Float>(0, -1, 0)))
//    for i in 0...segments {
//        let angle = Float(i) / Float(segments) * (2.0 * .pi)
//        let x = radius * cos(angle)
//        let z = radius * sin(angle)
//        vertices.append(VertexSwift(position: SIMD3<Float>(x, -halfHeight, z), normal: SIMD3<Float>(0, -1, 0)))
//    }
//    // Bottom Cap Indices
//    for i in 1...segments {
//        // Reverse order for correct winding
//        indices.append(contentsOf: [bottomCenterIndex, bottomCenterIndex + UInt16(i + 1), bottomCenterIndex + UInt16(i)])
//    }
//
//    // --- Sides ---
//    let sideStartIndex = UInt16(vertices.count)
//    for i in 0...segments {
//        let angle = Float(i) / Float(segments) * (2.0 * .pi)
//        let x = radius * cos(angle)
//        let z = radius * sin(angle)
//        let normal = normalize(SIMD3<Float>(x, 0, z))
//        // Top vertex for side
//        vertices.append(VertexSwift(position: SIMD3<Float>(x, halfHeight, z), normal: normal))
//        // Bottom vertex for side
//        vertices.append(VertexSwift(position: SIMD3<Float>(x, -halfHeight, z), normal: normal))
//    }
//    // Side Indices
//    for i in 0..<segments {
//        let top1 = sideStartIndex + UInt16(i * 2)
//        let bot1 = sideStartIndex + UInt16(i * 2 + 1)
//        let top2 = sideStartIndex + UInt16((i + 1) * 2) // Wraps around due to loop range
//        let bot2 = sideStartIndex + UInt16((i + 1) * 2 + 1)
//
//        indices.append(contentsOf: [top1, bot1, top2])
//        indices.append(contentsOf: [bot1, bot2, top2])
//    }
//
//    return (vertices, indices)
//}
//
//// MARK: - Metal Renderer Class
//
//class ScientificRenderer: NSObject, MTKViewDelegate {
//    let device: MTLDevice
//    let commandQueue: MTLCommandQueue
//    let pipelineState: MTLRenderPipelineState // One pipeline for both atoms and bonds
//    let depthStencilState: MTLDepthStencilState
//
//    // Geometry Buffers
//    var sphereVertexBuffer: MTLBuffer
//    var sphereIndexBuffer: MTLBuffer
//    var sphereIndexCount: Int
//    var cylinderVertexBuffer: MTLBuffer
//    var cylinderIndexBuffer: MTLBuffer
//    var cylinderIndexCount: Int
//
//    // Instance Buffers
//    var atomInstanceBuffer: MTLBuffer?
//    var bondInstanceBuffer: MTLBuffer?
//    var atomCount = 0
//    var bondCount = 0
//
//    var uniformBuffer: MTLBuffer
//
//    // Interaction State
//    var rotationX: Float = 0.0
//    var rotationY: Float = 0.0
//
//    // Pre-calculated instance data
//    var atomInstances: [InstanceDataSwift] = []
//    var bondInstances: [InstanceDataSwift] = []
//
//    init?(mtkView: MTKView) {
//        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
//        self.device = device
//        mtkView.device = device
//        mtkView.depthStencilPixelFormat = .depth32Float // Enable depth buffer
//
//        guard let commandQueue = device.makeCommandQueue() else { return nil }
//        self.commandQueue = commandQueue
//
//        // --- Generate Geometry ---
//        let (sphereVerts, sphereIdx) = createSphereVertices(radius: 1.0, segments: Configuration.sphereSegments) // Base radius 1
//        let (cylinderVerts, cylinderIdx) = createCylinderVertices(radius: 1.0, height: 1.0, segments: Configuration.cylinderSegments) // Base radius/height 1
//
//        // --- Create Geometry Buffers ---
//        guard let sphereVB = device.makeBuffer(bytes: sphereVerts, length: sphereVerts.count * MemoryLayout<VertexSwift>.stride, options: []),
//              let sphereIB = device.makeBuffer(bytes: sphereIdx, length: sphereIdx.count * MemoryLayout<UInt16>.stride, options: []),
//              let cylinderVB = device.makeBuffer(bytes: cylinderVerts, length: cylinderVerts.count * MemoryLayout<VertexSwift>.stride, options: []),
//              let cylinderIB = device.makeBuffer(bytes: cylinderIdx, length: cylinderIdx.count * MemoryLayout<UInt16>.stride, options: [])
//        else { return nil }
//
//        self.sphereVertexBuffer = sphereVB
//        self.sphereIndexBuffer = sphereIB
//        self.sphereIndexCount = sphereIdx.count
//        self.cylinderVertexBuffer = cylinderVB
//        self.cylinderIndexBuffer = cylinderIB
//        self.cylinderIndexCount = cylinderIdx.count
//
//        // --- Create Uniform Buffer ---
//        guard let uniformBuff = device.makeBuffer(length: MemoryLayout<UniformsSwift>.stride, options: .storageModeShared) else { return nil }
//        self.uniformBuffer = uniformBuff
//
//        // --- Create Pipeline State ---
//        do {
//            let library = try device.makeLibrary(source: scientificShaderSource, options: nil)
//            guard let vertexFunction = library.makeFunction(name: "vertex_main"),
//                  let fragmentFunction = library.makeFunction(name: "fragment_main") else { return nil }
//
//            // Define Vertex Descriptor matching shader inputs
//            let vertexDescriptor = MTLVertexDescriptor()
//            // Per-Vertex attributes (Buffer 0)
//            vertexDescriptor.attributes[0].format = .float3 // position
//            vertexDescriptor.attributes[0].offset = MemoryLayout<VertexSwift>.offset(of: \.position)!
//            vertexDescriptor.attributes[0].bufferIndex = 1 // Bind vertex data to buffer index 1
//            vertexDescriptor.attributes[1].format = .float3 // normal
//            vertexDescriptor.attributes[1].offset = MemoryLayout<VertexSwift>.offset(of: \.normal)!
//            vertexDescriptor.attributes[1].bufferIndex = 1
//            vertexDescriptor.layouts[1].stride = MemoryLayout<VertexSwift>.stride
//            vertexDescriptor.layouts[1].stepFunction = .perVertex
//
//            // Per-Instance attributes (Buffer 1) - Spread matrix over attributes 2-5
//            // Instance Model Matrix (Col 0)
//            vertexDescriptor.attributes[2].format = .float4
//            vertexDescriptor.attributes[2].offset = MemoryLayout<InstanceDataSwift>.offset(of: \.modelMatrix)! + MemoryLayout<SIMD4<Float>>.stride * 0
//            vertexDescriptor.attributes[2].bufferIndex = 2 // Bind instance data to buffer index 2
//            // Instance Model Matrix (Col 1)
//            vertexDescriptor.attributes[3].format = .float4
//            vertexDescriptor.attributes[3].offset = MemoryLayout<InstanceDataSwift>.offset(of: \.modelMatrix)! + MemoryLayout<SIMD4<Float>>.stride * 1
//            vertexDescriptor.attributes[3].bufferIndex = 2
//             // Instance Model Matrix (Col 2)
//            vertexDescriptor.attributes[4].format = .float4
//            vertexDescriptor.attributes[4].offset = MemoryLayout<InstanceDataSwift>.offset(of: \.modelMatrix)! + MemoryLayout<SIMD4<Float>>.stride * 2
//            vertexDescriptor.attributes[4].bufferIndex = 2
//            // Instance Model Matrix (Col 3)
//            vertexDescriptor.attributes[5].format = .float4
//            vertexDescriptor.attributes[5].offset = MemoryLayout<InstanceDataSwift>.offset(of: \.modelMatrix)! + MemoryLayout<SIMD4<Float>>.stride * 3
//            vertexDescriptor.attributes[5].bufferIndex = 2
//            // Instance Color
//            vertexDescriptor.attributes[6].format = .float4
//            vertexDescriptor.attributes[6].offset = MemoryLayout<InstanceDataSwift>.offset(of: \.color)!
//            vertexDescriptor.attributes[6].bufferIndex = 2
//
//            vertexDescriptor.layouts[2].stride = MemoryLayout<InstanceDataSwift>.stride
//            vertexDescriptor.layouts[2].stepFunction = .perInstance
//
//            // Create Pipeline Descriptor
//            let pipelineDescriptor = MTLRenderPipelineDescriptor()
//            pipelineDescriptor.label = "Molecular Rendering Pipeline"
//            pipelineDescriptor.vertexFunction = vertexFunction
//            pipelineDescriptor.fragmentFunction = fragmentFunction
//            pipelineDescriptor.vertexDescriptor = vertexDescriptor
//            pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
//            pipelineDescriptor.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat
//
//            self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
//
//        } catch {
//            print("Error creating Metal pipeline state: \(error)")
//            return nil
//        }
//
//        // --- Create Depth Stencil State ---
//        let depthDescriptor = MTLDepthStencilDescriptor()
//        depthDescriptor.depthCompareFunction = .less // Draw front things over back things
//        depthDescriptor.isDepthWriteEnabled = true    // Write depth values
//        guard let state = device.makeDepthStencilState(descriptor: depthDescriptor) else { return nil }
//        self.depthStencilState = state
//
//        super.init()
//        prepareInstanceData() // Calculate instance matrices once
//    }
//
//    // Pre-calculate model matrices for atoms and bonds
//    func prepareInstanceData() {
//        // Atoms
//        atomInstances = Configuration.atoms.map { atom in
//            let scaleMatrix = matrix_uniform_scale(atom.radius)
//            let translateMatrix = matrix_translation(atom.position)
//            // Combine: Scale first, then translate
//            return InstanceDataSwift(modelMatrix: translateMatrix * scaleMatrix, color: atom.color)
//        }
//        atomCount = atomInstances.count
//        if !atomInstances.isEmpty {
//            atomInstanceBuffer = device.makeBuffer(bytes: atomInstances, length: atomInstances.count * MemoryLayout<InstanceDataSwift>.stride, options: [])
//        }
//
//        // Bonds
//        bondInstances = Configuration.bonds.compactMap { bondRaw in
//            guard bondRaw.atomIndex1 < Configuration.atoms.count,
//                  bondRaw.atomIndex2 < Configuration.atoms.count else { return nil }
//            let atom1 = Configuration.atoms[bondRaw.atomIndex1]
//            let atom2 = Configuration.atoms[bondRaw.atomIndex2]
//            let modelMatrix = matrix_for_cylinder(start: atom1.position, end: atom2.position, radius: Configuration.bondRadius)
//            return InstanceDataSwift(modelMatrix: modelMatrix, color: Configuration.bondColor)
//        }
//        bondCount = bondInstances.count
//         if !bondInstances.isEmpty {
//             bondInstanceBuffer = device.makeBuffer(bytes: bondInstances, length: bondInstances.count * MemoryLayout<InstanceDataSwift>.stride, options: [])
//         }
//    }
//
//    func updateRotation(deltaX: Float, deltaY: Float) {
//        // Adjust rotation based on drag delta, add sensitivity multiplier
//        let sensitivity: Float = 0.01
//        rotationY += deltaX * sensitivity
//        rotationX += deltaY * sensitivity
//
//        // Clamp rotationX to avoid flipping upside down
//        rotationX = max(-.pi/2 + 0.01, min(.pi/2 - 0.01, rotationX))
//    }
//
//    // MARK: MTKViewDelegate Methods
//
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        // Handle view resizing if necessary (update projection matrix aspect ratio)
//    }
//
//    func draw(in view: MTKView) {
//        guard let drawable = view.currentDrawable,
//              let renderPassDescriptor = view.currentRenderPassDescriptor, // Gets clear color etc.
//              let commandBuffer = commandQueue.makeCommandBuffer(),
//              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
//        else { return }
//
//        // --- Update Uniforms ---
//        let aspectRatio = Float(view.drawableSize.width / max(1, view.drawableSize.height))
//        let projectionMatrix = matrix_perspective_right_hand(fovyRadians: .pi / 3, aspectRatio: aspectRatio, nearZ: 0.1, farZ: 100.0)
//
//        let cameraPosition = SIMD3<Float>(0, 0, Configuration.cameraDistance) // Static distance
//        let baseViewMatrix = matrix_lookat_right_hand(eye: cameraPosition, center: SIMD3<Float>(0, 0, 0), up: SIMD3<Float>(0, 1, 0))
//
//        // Apply rotation from user interaction
//        let rotationMatrixY = matrix_rotation_y(rotationY)
//        let rotationMatrixX = matrix_rotation_x(rotationX)
//        let viewMatrix = rotationMatrixX * rotationMatrixY * baseViewMatrix // Apply world rotation before view transform
//
//        var uniforms = UniformsSwift(
//            projectionMatrix: projectionMatrix,
//            viewMatrix: viewMatrix,
//            lightDirection_world: Configuration.lightDirection // Assume light is fixed in world space
//        )
//        uniformBuffer.contents().copyMemory(from: &uniforms, byteCount: MemoryLayout<UniformsSwift>.stride)
//
//        // --- Configure Render Encoder ---
//        renderEncoder.setRenderPipelineState(pipelineState)
//        renderEncoder.setDepthStencilState(depthStencilState)
//        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 0) // Uniforms at index 0
//        renderEncoder.setCullMode(.back) // Don't draw back faces of triangles
//
//        // --- Draw Atoms (Spheres) ---
//        if let atomBuffer = atomInstanceBuffer, atomCount > 0 {
//            renderEncoder.setVertexBuffer(sphereVertexBuffer, offset: 0, index: 1) // Geometry data @ index 1
//            renderEncoder.setVertexBuffer(atomBuffer, offset: 0, index: 2)       // Instance data @ index 2
//            renderEncoder.drawIndexedPrimitives(type: .triangle,
//                                                indexCount: sphereIndexCount,
//                                                indexType: .uint16,
//                                                indexBuffer: sphereIndexBuffer,
//                                                indexBufferOffset: 0,
//                                                instanceCount: atomCount)
//        }
//
//        // --- Draw Bonds (Cylinders) ---
//         if let bondBuffer = bondInstanceBuffer, bondCount > 0 {
//            renderEncoder.setVertexBuffer(cylinderVertexBuffer, offset: 0, index: 1) // Geometry data @ index 1 (different geometry)
//            renderEncoder.setVertexBuffer(bondBuffer, offset: 0, index: 2)         // Instance data @ index 2 (different instances)
//             renderEncoder.drawIndexedPrimitives(type: .triangle,
//                                                 indexCount: cylinderIndexCount,
//                                                 indexType: .uint16,
//                                                 indexBuffer: cylinderIndexBuffer,
//                                                 indexBufferOffset: 0,
//                                                 instanceCount: bondCount)
//         }
//
//        // --- Finalize ---
//        renderEncoder.endEncoding()
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
//}
//
//// MARK: - Coordinator for Interaction
//
//class ScientificCoordinator: NSObject {
//    var parent: ScientificMetalViewRepresentable
//    var renderer: ScientificRenderer
//
//    init(_ parent: ScientificMetalViewRepresentable, renderer: ScientificRenderer) {
//        self.parent = parent
//        self.renderer = renderer
//        super.init()
//    }
//
//    // Called by the gesture recognizer
//    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
//        let translation = gesture.translation(in: gesture.view)
//        renderer.updateRotation(deltaX: Float(translation.x), deltaY: Float(translation.y))
//        gesture.setTranslation(.zero, in: gesture.view) // Reset translation for next update
//
//        // No need to explicitly redraw if MTKView is not paused (.isPaused = false)
//        // If it were paused, you'd need: gesture.view?.setNeedsDisplay()
//    }
//}
//
//// MARK: - UIViewRepresentable for SwiftUI
//
//struct ScientificMetalViewRepresentable: UIViewRepresentable {
//    // No bindings needed if interaction is handled via Coordinator+GestureRecognizer
//    // Add bindings if SwiftUI state needed to control renderer props
//
//    func makeCoordinator() -> ScientificCoordinator {
//        // Create a dummy renderer initially, it will be replaced in makeUIView
//         guard let device = MTLCreateSystemDefaultDevice(), let renderer = ScientificRenderer(mtkView: MTKView(frame: .zero, device: device)) else {
//             fatalError("Could not create placeholder Renderer")
//         }
//        return ScientificCoordinator(self, renderer: renderer)
//    }
//
//    func makeUIView(context: Context) -> MTKView {
//        print("makeUIView called")
//        let mtkView = MTKView()
//        mtkView.delegate = context.coordinator.renderer // Renderer handles draw calls
//        mtkView.preferredFramesPerSecond = 60
//        mtkView.enableSetNeedsDisplay = false // Use internal timer for drawing
//        mtkView.isPaused = false // Draw continuously
//
//        // Attempt tô initialize renderer
//        guard let renderer = ScientificRenderer(mtkView: mtkView) else {
//            fatalError("ScientificRenderer could not be initialized")
//        }
//        context.coordinator.renderer = renderer // Assign the real renderer
//
//        // Default background color
//        mtkView.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
//
//        // Add Gesture Recognizer for rotation
//        let panGesture = UIPanGestureRecognizer(target: context.coordinator,
//                                                action: #selector(ScientificCoordinator.handlePan(_:)))
//        mtkView.addGestureRecognizer(panGesture)
//        print("MTKView configured with renderer and gesture recognizer.")
//
//        return mtkView
//    }
//
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // This is called when SwiftUI state bound to this view changes.
//        // If we had @Bindings for things like background color, zoom level, etc.,
//        // we would update the uiView or context.coordinator.renderer here.
//        print("updateUIView called") // Will be called on initial setup and redraws
//    }
//}
//
//// MARK: - SwiftUI Content View
//
//struct ScientificContentView: View {
//    var body: some View {
//        VStack(spacing: 0) {
//            Text("Scientific & Engineering Demo")
//                .font(.headline)
//                .padding(.top)
//            Text("Molecule Visualization (Drag tô Rotate)")
//                 .font(.caption)
//                 .foregroundColor(.gray)
//                 .padding(.bottom, 5)
//
//            ScientificMetalViewRepresentable()
//                // Let the MTKView handle its own background via clearColor
//        }
//        .edgesIgnoringSafeArea(.bottom) // Allow Metal view tô extend
//        .navigationTitle("Molecule Viewer") // Add title if embedded in NavigationView
//    }
//}
//
//// MARK: - Preview Provider
//
//struct ScientificContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScientificContentView()
//    }
//}
//
///*
//// MARK: - App Entry Point (Optional)
//@main
//struct MetalScientificApp: App {
//    var body: some Scene {
//        WindowGroup {
//            // Embed in NavigationView for title visibility if desired
//            // NavigationView {
//                 ScientificContentView()
//            // }
//        }
//    }
//}
//*/
