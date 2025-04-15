////
////  ScientificContentView.swift
////  MyApp
////
////  Created by Cong Le on 4/15/25.
////
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
//    float4x4 modelMatrix [[attribute(2)]]; // Handles position, rotation, scale (spread across 2-5)
//    float4 color         [[attribute(6)]]; // Base color
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
//    // Transform normal to world space: Use upper 3x3 of model matrix.
//    // For accurate lighting with non-uniform scaling (like cylinders),
//    // the inverse transpose of the upper 3x3 is needed.
//    // We approximate here by just using the upper 3x3 rotation/scale part.
//    // For uniform scale (spheres), this is okay. For cylinders, it's an approximation.
//    float3x3 upper3x3 = float3x3(instance.modelMatrix[0].xyz,
//                                 instance.modelMatrix[1].xyz,
//                                 instance.modelMatrix[2].xyz);
//    // Ideally: float3x3 normalMatrix = inverse(transpose(upper3x3));
//    // out.normal_world = normalize(normalMatrix * in.normal);
//    out.normal_world = normalize(upper3x3 * in.normal); // Approximation
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
//struct InstanceDataSwift { // Matches InstanceData struct
//    var modelMatrix: matrix_float4x4
//    var color: SIMD4<Float>
//}
//
//struct UniformsSwift { // Matches Uniforms struct
//    var projectionMatrix: matrix_float4x4
//    var viewMatrix: matrix_float4x4
//    var lightDirection_world: SIMD3<Float>
//    // Ensure padding if needed to match Metal struct layout rules (MTLBuffer alignment)
//    // In this case, SIMD3F is likely 16-byte aligned anyway, but be mindful.
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
//    if length < 1e-6 { return matrix_identity_float4x4 } // Avoid division by zero for zero-length bonds
//
//    let direction = vector / length
//
//    // Calculate rotation axis and angle to align the cylinder's default Y-axis with the bond direction
//    let up = SIMD3<Float>(0, 1, 0) // Cylinder model points along Y axis
//    var rotationAxis = cross(up, direction)
//    var rotationAngle = acos(dot(up, direction))
//
//    // Handle cases where direction is parallel or anti-parallel to the default up vector
//    if simd.length(rotationAxis) < 1e-6 {
//        if dot(up, direction) > 0 { // Aligned with Y (direction points up)
//            rotationAxis = SIMD3<Float>(1, 0, 0) // Arbitrary axis perpendicular to Y
//            rotationAngle = 0 // No rotation needed
//        } else { // Opposite to Y (direction points down)
//            rotationAxis = SIMD3<Float>(1, 0, 0) // Arbitrary axis perpendicular to Y
//            rotationAngle = .pi // 180 degree rotation
//        }
//    } else {
//        rotationAxis = normalize(rotationAxis)
//    }
//
//    // --- Create the rotation matrix using the CORRECT SIMD initializer ---
//    let rotationMatrix = matrix_float4x4(simd_quatf(angle: rotationAngle, axis: rotationAxis))
//
//    // --- Scale matrix: X/Z for radius, Y for length ---
//    // The base cylinder geometry has radius 1 and height 1
//    let scaleMatrix = matrix_float4x4(diagonal: SIMD4<Float>(radius, length, radius, 1.0))
//
//    // --- Translation matrix to move the center of the cylinder to the midpoint of the bond ---
//    let midPoint = start + vector * 0.5
//    let translationMatrix = matrix_translation(midPoint)
//
//    // --- Combine transforms: Scale first, then rotate, then translate ---
//    // Order matters: SRT (Scale -> Rotate -> Translate)
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
//        let v = Float(i) / Float(vSegments) // Vertical parameter (latitude)
//        let phi = v * .pi // Angle from Y+ axis
//
//        for j in 0...hSegments {
//            let u = Float(j) / Float(hSegments) // Horizontal parameter (longitude)
//            let theta = u * (2.0 * .pi) // Angle around Y axis
//
//            let x = radius * sin(phi) * cos(theta)
//            let y = radius * cos(phi)
//            let z = radius * sin(phi) * sin(theta)
//
//            let position = SIMD3<Float>(x, y, z)
//            let normal = normalize(position) // For a sphere centered at origin, normal is position vector normalized
//
//            vertices.append(VertexSwift(position: position, normal: normal))
//        }
//    }
//
//    // Generate indices for triangles forming quads
//    for i in 0..<vSegments {
//        for j in 0..<hSegments {
//            let row1: UInt16 = UInt16(i * (hSegments + 1))
//            let row2: UInt16 = UInt16((i + 1) * (hSegments + 1))
//
//            let p1: UInt16 = row1 + UInt16(j)
//            let p2: UInt16 = row1 + UInt16(j + 1)
//            let p3: UInt16 = row2 + UInt16(j + 1)
//            let p4: UInt16 = row2 + UInt16(j)
//
//            // Quad = two triangles (p1, p2, p4) and (p2, p3, p4)
//            // Ensure correct winding order (counter-clockwise for front faces)
//            indices.append(contentsOf: [p1, p4, p2]) // Triangle 1
//            indices.append(contentsOf: [p2, p4, p3]) // Triangle 2
//        }
//    }
//
//    return (vertices, indices)
//}
//
//// Basic Cylinder (aligned along Y axis, origin at center, height 1, radius 1)
//func createCylinderVertices(segments: Int) -> ([VertexSwift], [UInt16]) {
//    var vertices: [VertexSwift] = []
//    var indices: [UInt16] = []
//    let radius: Float = 1.0 // Base radius
//    let height: Float = 1.0 // Base height
//    let halfHeight = height / 2.0
//
//    // --- Top Cap ---
//    let topCenterIndex = UInt16(vertices.count)
//    vertices.append(VertexSwift(position: SIMD3<Float>(0, halfHeight, 0), normal: SIMD3<Float>(0, 1, 0)))
//    let firstTopRingVertexIndex = topCenterIndex + 1
//    for i in 0...segments { // Include last point to close the circle
//        let angle = Float(i) / Float(segments) * (2.0 * .pi)
//        let x = radius * cos(angle)
//        let z = radius * sin(angle)
//        vertices.append(VertexSwift(position: SIMD3<Float>(x, halfHeight, z), normal: SIMD3<Float>(0, 1, 0)))
//    }
//    // Top Cap Indices (Create fans)
//    for i in 0..<segments { // Iterate segment count times
//        indices.append(contentsOf: [topCenterIndex, firstTopRingVertexIndex + UInt16(i + 1), firstTopRingVertexIndex + UInt16(i)])
//    }
//
//    // --- Bottom Cap ---
//    let bottomCenterIndex = UInt16(vertices.count)
//    vertices.append(VertexSwift(position: SIMD3<Float>(0, -halfHeight, 0), normal: SIMD3<Float>(0, -1, 0)))
//    let firstBottomRingVertexIndex = bottomCenterIndex + 1
//    for i in 0...segments { // Include last point to close the circle
//        let angle = Float(i) / Float(segments) * (2.0 * .pi)
//        let x = radius * cos(angle)
//        let z = radius * sin(angle)
//        vertices.append(VertexSwift(position: SIMD3<Float>(x, -halfHeight, z), normal: SIMD3<Float>(0, -1, 0)))
//    }
//    // Bottom Cap Indices (Create fans, reverse winding order for bottom face)
//    for i in 0..<segments {
//        indices.append(contentsOf: [bottomCenterIndex, firstBottomRingVertexIndex + UInt16(i), firstBottomRingVertexIndex + UInt16(i + 1)])
//    }
//
//    // --- Sides ---
//    let sideStartIndex = UInt16(vertices.count)
//    // Generate vertices for the sides (top and bottom rings for sides needed separately for correct normals)
//    for i in 0...segments { // Include last point to close the cylinder
//        let angle = Float(i) / Float(segments) * (2.0 * .pi)
//        let x = radius * cos(angle)
//        let z = radius * sin(angle)
//        let normal = normalize(SIMD3<Float>(x, 0, z)) // Normal points radially outward
//
//        // Top vertex for this side segment
//        vertices.append(VertexSwift(position: SIMD3<Float>(x, halfHeight, z), normal: normal))
//        // Bottom vertex for this side segment
//        vertices.append(VertexSwift(position: SIMD3<Float>(x, -halfHeight, z), normal: normal))
//    }
//    // Side Indices (Create quads, two triangles per segment)
//    for i in 0..<segments {
//        let idx = UInt16(i * 2)
//        let top1: UInt16 = sideStartIndex + idx
//        let bot1: UInt16 = sideStartIndex + idx + 1
//        let top2: UInt16 = sideStartIndex + idx + 2
//        let bot2: UInt16 = sideStartIndex + idx + 3
//
//        indices.append(contentsOf: [top1, bot1, top2]) // Triangle 1
//        indices.append(contentsOf: [bot1, bot2, top2]) // Triangle 2
//    }
//
//    return (vertices, indices)
//}
//
//// MARK: - Metal Renderer Class (Not a Delegate anymore)
//
//class ScientificRenderer: NSObject {
//    let device: MTLDevice
//    let commandQueue: MTLCommandQueue
//    let pipelineState: MTLRenderPipelineState
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
//    // Pre-calculated instance data (buffers created during prepareInstanceData)
//    var atomInstances: [InstanceDataSwift] = []
//    var bondInstances: [InstanceDataSwift] = []
//
//    // Initializer requires a pre-configured MTKView
//    init?(mtkView: MTKView) {
//        guard let device = mtkView.device else {
//             print("Error: MTKView must have a device set before initializing Renderer.")
//             return nil
//        }
//        // Check for valid pixel format configuration on the MTKView
//        // These are crucial for pipeline state creation.
//        guard mtkView.colorPixelFormat != .invalid, mtkView.depthStencilPixelFormat != .invalid else {
//             print("Error: MTKView pixel formats not configured.")
//             return nil
//        }
//
//        self.device = device
//
//        guard let commandQueue = device.makeCommandQueue() else { return nil }
//        self.commandQueue = commandQueue
//
//        // --- Generate Geometry ---
//        let (sphereVerts, sphereIdx) = createSphereVertices(radius: 1.0, segments: Configuration.sphereSegments)
//        let (cylinderVerts, cylinderIdx) = createCylinderVertices(segments: Configuration.cylinderSegments)
//
//        // --- Create Geometry Buffers ---
//        guard let sphereVB = device.makeBuffer(bytes: sphereVerts, length: sphereVerts.count * MemoryLayout<VertexSwift>.stride, options: [.storageModeShared]),
//              let sphereIB = device.makeBuffer(bytes: sphereIdx, length: sphereIdx.count * MemoryLayout<UInt16>.stride, options: [.storageModeShared]),
//              let cylinderVB = device.makeBuffer(bytes: cylinderVerts, length: cylinderVerts.count * MemoryLayout<VertexSwift>.stride, options: [.storageModeShared]),
//              let cylinderIB = device.makeBuffer(bytes: cylinderIdx, length: cylinderIdx.count * MemoryLayout<UInt16>.stride, options: [.storageModeShared])
//        else {
//            print("Error creating geometry buffers.")
//            return nil
//        }
//
//        self.sphereVertexBuffer = sphereVB
//        self.sphereIndexBuffer = sphereIB
//        self.sphereIndexCount = sphereIdx.count
//        self.cylinderVertexBuffer = cylinderVB
//        self.cylinderIndexBuffer = cylinderIB
//        self.cylinderIndexCount = cylinderIdx.count
//
//        // --- Create Uniform Buffer ---
//        // Use .storageModeShared for CPU/GPU access on unified memory architectures (iOS/Mac Silicon)
//        guard let uniformBuff = device.makeBuffer(length: MemoryLayout<UniformsSwift>.stride, options: .storageModeShared) else {
//            print("Error creating uniform buffer.")
//            return nil
//        }
//        self.uniformBuffer = uniformBuff
//
//        // --- Create Pipeline State ---
//        do {
//            let library = try device.makeLibrary(source: scientificShaderSource, options: nil)
//            guard let vertexFunction = library.makeFunction(name: "vertex_main"),
//                  let fragmentFunction = library.makeFunction(name: "fragment_main") else {
//                      print("Error creating shader functions.")
//                      return nil
//                  }
//
//            // Define Vertex Descriptor matching shader inputs
//            let vertexDescriptor = MTLVertexDescriptor()
//            // Per-Vertex (Position, Normal) - Bound to Buffer Index 1
//            vertexDescriptor.attributes[0].format = .float3 // position
//            vertexDescriptor.attributes[0].offset = MemoryLayout<VertexSwift>.offset(of: \.position)!
//            vertexDescriptor.attributes[0].bufferIndex = 1
//            vertexDescriptor.attributes[1].format = .float3 // normal
//            vertexDescriptor.attributes[1].offset = MemoryLayout<VertexSwift>.offset(of: \.normal)!
//            vertexDescriptor.attributes[1].bufferIndex = 1
//            vertexDescriptor.layouts[1].stride = MemoryLayout<VertexSwift>.stride
//            vertexDescriptor.layouts[1].stepFunction = .perVertex
//
//            // Per-Instance (Model Matrix, Color) - Bound to Buffer Index 2
//            // Instance Model Matrix (Col 0 @ attr 2)
//            vertexDescriptor.attributes[2].format = .float4
//            vertexDescriptor.attributes[2].offset = MemoryLayout<InstanceDataSwift>.offset(of: \.modelMatrix)! + MemoryLayout<SIMD4<Float>>.stride * 0
//            vertexDescriptor.attributes[2].bufferIndex = 2
//            // Instance Model Matrix (Col 1 @ attr 3)
//            vertexDescriptor.attributes[3].format = .float4
//            vertexDescriptor.attributes[3].offset = MemoryLayout<InstanceDataSwift>.offset(of: \.modelMatrix)! + MemoryLayout<SIMD4<Float>>.stride * 1
//            vertexDescriptor.attributes[3].bufferIndex = 2
//             // Instance Model Matrix (Col 2 @ attr 4)
//            vertexDescriptor.attributes[4].format = .float4
//            vertexDescriptor.attributes[4].offset = MemoryLayout<InstanceDataSwift>.offset(of: \.modelMatrix)! + MemoryLayout<SIMD4<Float>>.stride * 2
//            vertexDescriptor.attributes[4].bufferIndex = 2
//            // Instance Model Matrix (Col 3 @ attr 5)
//            vertexDescriptor.attributes[5].format = .float4
//            vertexDescriptor.attributes[5].offset = MemoryLayout<InstanceDataSwift>.offset(of: \.modelMatrix)! + MemoryLayout<SIMD4<Float>>.stride * 3
//            vertexDescriptor.attributes[5].bufferIndex = 2
//            // Instance Color (@ attr 6)
//            vertexDescriptor.attributes[6].format = .float4
//            vertexDescriptor.attributes[6].offset = MemoryLayout<InstanceDataSwift>.offset(of: \.color)!
//            vertexDescriptor.attributes[6].bufferIndex = 2
//            // Layout for Instance Buffer
//            vertexDescriptor.layouts[2].stride = MemoryLayout<InstanceDataSwift>.stride
//            vertexDescriptor.layouts[2].stepFunction = .perInstance
//
//            // Create Pipeline Descriptor
//            let pipelineDescriptor = MTLRenderPipelineDescriptor()
//            pipelineDescriptor.label = "Molecular Rendering Pipeline"
//            pipelineDescriptor.vertexFunction = vertexFunction
//            pipelineDescriptor.fragmentFunction = fragmentFunction
//            pipelineDescriptor.vertexDescriptor = vertexDescriptor
//            // **READ from the mtkView's configuration**
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
//        depthDescriptor.depthCompareFunction = .less // Draw closer things over farther things
//        depthDescriptor.isDepthWriteEnabled = true    // Write depth values to the buffer
//        guard let state = device.makeDepthStencilState(descriptor: depthDescriptor) else {
//            print("Error creating depth state.")
//            return nil
//        }
//        self.depthStencilState = state
//
//        // Initialize NSObject part
//        super.init() // Call super.init() now that all properties are initialized
//
//        prepareInstanceData() // Calculate instance matrices and create buffers
//    }
//
//    // Pre-calculate model matrices for atoms and bonds and create buffers
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
//            atomInstanceBuffer = device.makeBuffer(bytes: atomInstances, length: atomInstances.count * MemoryLayout<InstanceDataSwift>.stride, options: [.storageModeShared])
//        } else {
//            atomInstanceBuffer = nil // Ensure buffer is nil if no atoms
//        }
//
//        // Bonds
//        bondInstances = Configuration.bonds.compactMap { bondRaw in
//            guard bondRaw.atomIndex1 >= 0, bondRaw.atomIndex1 < Configuration.atoms.count,
//                  bondRaw.atomIndex2 >= 0, bondRaw.atomIndex2 < Configuration.atoms.count else {
//                print("Warning: Invalid bond indices \(bondRaw)")
//                return nil
//            }
//            let atom1 = Configuration.atoms[bondRaw.atomIndex1]
//            let atom2 = Configuration.atoms[bondRaw.atomIndex2]
//            let modelMatrix = matrix_for_cylinder(start: atom1.position, end: atom2.position, radius: Configuration.bondRadius)
//            return InstanceDataSwift(modelMatrix: modelMatrix, color: Configuration.bondColor)
//        }
//        bondCount = bondInstances.count
//         if !bondInstances.isEmpty {
//             bondInstanceBuffer = device.makeBuffer(bytes: bondInstances, length: bondInstances.count * MemoryLayout<InstanceDataSwift>.stride, options: [.storageModeShared])
//         } else {
//             bondInstanceBuffer = nil // Ensure buffer is nil if no bonds
//         }
//
//        if atomInstanceBuffer == nil { print("Atom instance buffer is nil.") }
//        if bondInstanceBuffer == nil { print("Bond instance buffer is nil.") }
//    }
//
//    func updateRotation(deltaX: Float, deltaY: Float) {
//        // Adjust rotation based on drag delta, add sensitivity multiplier
//        let sensitivity: Float = 0.01
//        rotationY += deltaX * sensitivity
//        rotationX += deltaY * sensitivity
//
//        // Clamp rotationX to avoid flipping upside down (prevents gimbal lock issues)
//        rotationX = max(-.pi/2 + 0.01, min(.pi/2 - 0.01, rotationX))
//    }
//
//    // Called BY the Coordinator's MTKViewDelegate method
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        // Handle aspect ratio change or other size-dependent updates if necessary
//        // Projection matrix is recalculated in draw(), so this might not be needed
//        // unless other calculations depend on size.
//        print("Renderer notified of size change to: \(size)")
//    }
//
//    // Called BY the Coordinator's MTKViewDelegate method
//    func draw(in view: MTKView) {
//        guard let drawable = view.currentDrawable,
//              let renderPassDescriptor = view.currentRenderPassDescriptor, // Gets clear color, textures etc.
//              let commandBuffer = commandQueue.makeCommandBuffer(),
//              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
//        else {
//            print("Warning: Failed to get drawable or command buffer/encoder in draw.")
//            return
//        }
//
//        // --- Update Uniforms ---
//        let size = view.drawableSize
//        // Avoid division by zero if height is zero during setup
//        let aspectRatio = Float(size.width / max(1, size.height))
//        let projectionMatrix = matrix_perspective_right_hand(fovyRadians: .pi / 3, aspectRatio: aspectRatio, nearZ: 0.1, farZ: 100.0)
//
//        let cameraPosition = SIMD3<Float>(0, 0, Configuration.cameraDistance) // Camera orbits origin
//        let baseViewMatrix = matrix_lookat_right_hand(eye: cameraPosition, center: SIMD3<Float>(0, 0, 0), up: SIMD3<Float>(0, 1, 0))
//
//        // Apply rotation from user interaction (around the world origin)
//        let rotationMatrixY = matrix_rotation_y(rotationY)
//        let rotationMatrixX = matrix_rotation_x(rotationX)
//        let viewMatrix = rotationMatrixX * rotationMatrixY * baseViewMatrix // Apply rotations to view
//
//        var uniforms = UniformsSwift(
//            projectionMatrix: projectionMatrix,
//            viewMatrix: viewMatrix,
//            lightDirection_world: -Configuration.lightDirection // Use negative since shader computes dot(N, -L)
//        )
//        uniformBuffer.contents().copyMemory(from: &uniforms, byteCount: MemoryLayout<UniformsSwift>.stride)
//
//        // --- Configure Render Encoder ---
//        renderEncoder.label = "Molecule RenderEncoder"
//        renderEncoder.setRenderPipelineState(pipelineState)
//        renderEncoder.setDepthStencilState(depthStencilState)
//        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 0) // Uniforms @ buffer 0
//        renderEncoder.setCullMode(.back) // Cull back-facing triangles for performance
//        renderEncoder.setFrontFacing(.counterClockwise) // Standard front face definition
//
//        // --- Draw Atoms (Spheres) ---
//        if let atomBuffer = atomInstanceBuffer, atomCount > 0 {
//            renderEncoder.setVertexBuffer(sphereVertexBuffer, offset: 0, index: 1) // Geometry data @ buffer 1
//            renderEncoder.setVertexBuffer(atomBuffer, offset: 0, index: 2)       // Instance data @ buffer 2
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
//            renderEncoder.setVertexBuffer(cylinderVertexBuffer, offset: 0, index: 1) // Geometry data @ buffer 1 (different geometry)
//            renderEncoder.setVertexBuffer(bondBuffer, offset: 0, index: 2)         // Instance data @ buffer 2 (different instances)
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
//        commandBuffer.present(drawable) // Schedule presentation
//        commandBuffer.commit()         // Send commands to GPU
//    }
//}
//
//// MARK: - Coordinator (Delegate and Gesture Handler)
//
//class ScientificCoordinator: NSObject, MTKViewDelegate {
//    var parent: ScientificMetalViewRepresentable
//    var renderer: ScientificRenderer? // Optional renderer, set in makeUIView
//
//    // Initializer takes only the parent
//    init(_ parent: ScientificMetalViewRepresentable) {
//        self.parent = parent
//        super.init()
//        print("Coordinator initialized")
//    }
//
//    // Called by the gesture recognizer
//    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
//        guard let renderer = renderer else {
//            print("Warning: Pan gesture handled but renderer is nil.")
//            return
//        }
//        let translation = gesture.translation(in: gesture.view)
//        // Update renderer's rotation state
//        renderer.updateRotation(deltaX: Float(translation.x), deltaY: Float(translation.y))
//        // Reset translation for the next delta calculation
//        gesture.setTranslation(.zero, in: gesture.view)
//
//        // MTKView redraws automatically if not paused
//    }
//
//    // MARK: MTKViewDelegate Methods
//
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//        // Forward to renderer if needed, or handle aspect ratio update directly if simpler
//         print("Coordinator: mtkView size changing to \(size)")
//         renderer?.mtkView(view, drawableSizeWillChange: size)
//    }
//
//    func draw(in view: MTKView) {
//        // Forward draw call to the actual renderer instance
//        guard let renderer = renderer else {
//            print("Warning: draw(in:) called but renderer is nil.")
//            return
//        }
//        renderer.draw(in: view)
//    }
//}
//
//// MARK: - UIViewRepresentable for SwiftUI
//
//struct ScientificMetalViewRepresentable: UIViewRepresentable {
//
//    func makeCoordinator() -> ScientificCoordinator {
//        // Only create the coordinator instance here
//        print("Representable: makeCoordinator()")
//        return ScientificCoordinator(self)
//    }
//
//    func makeUIView(context: Context) -> MTKView {
//        print("Representable: makeUIView()")
//        let mtkView = MTKView()
//
//        // --- Configure MTKView FIRST ---
//        mtkView.device = MTLCreateSystemDefaultDevice()
//        guard mtkView.device != nil else {
//             fatalError("Metal is not supported on this device.")
//        }
//
//        mtkView.depthStencilPixelFormat = .depth32Float_stencil8 // Use depth *and* stencil if needed, just depth often okay
//        mtkView.colorPixelFormat = .bgra8Unorm_srgb // Use sRGB for correct color display
//        mtkView.preferredFramesPerSecond = 60
//        mtkView.enableSetNeedsDisplay = false // Use internal timer
//        mtkView.isPaused = false // Draw continuously
//        mtkView.clearColor = MTLClearColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
//        mtkView.autoResizeDrawable = true // Let MTKView resize its drawable automatically
//
//        // --- Create the Renderer using the CONFIGURED MTKView ---
//        guard let renderer = ScientificRenderer(mtkView: mtkView) else {
//            // If this fails, there's likely an issue within ScientificRenderer.init?
//            // (e.g., shader compilation, buffer creation)
//             fatalError("ScientificRenderer could not be initialized in makeUIView. Check console for Metal errors.")
//        }
//
//        // --- Connect Renderer and Coordinator ---
//        context.coordinator.renderer = renderer // Store the renderer in the coordinator
//        mtkView.delegate = context.coordinator  // Set the coordinator as the delegate
//
//        // --- Add Gesture Recognizer ---
//        let panGesture = UIPanGestureRecognizer(target: context.coordinator,
//                                                action: #selector(ScientificCoordinator.handlePan(_:)))
//        mtkView.addGestureRecognizer(panGesture)
//        print("Representable: MTKView configured with renderer and gesture recognizer.")
//
//        return mtkView
//    }
//
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // Called when SwiftUI state bound to this view changes.
//        // We don't have any bindings here, so this usually won't do much in this example.
//        print("Representable: updateUIView()")
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
//                .border(Color.gray.opacity(0.5)) // Optional: Add border for visual clarity
//        }
//        .edgesIgnoringSafeArea(.bottom) // Allow Metal view tô extend
//        // Optionally embed in a NavigationView for a title bar
//        // .navigationTitle("Molecule Viewer")
//    }
//}
//
//// MARK: - Preview Provider
//#Preview() {
//    ScientificContentView()
//}
////struct ScientificContentView_Previews: PreviewProvider {
////    static var previews: some View {
////        // Wrap in a NavigationView if you want the title to show in previews
////        // NavigationView {
////             ScientificContentView()
////        // }
////    }
////}
//
///*
//// MARK: - App Entry Point (Optional - Uncomment if this is your main App file)
//@main
//struct MetalScientificApp: App {
//    var body: some Scene {
//        WindowGroup {
//            // Embed in NavigationView for title visibility if desired
//             NavigationView {
//                 ScientificContentView()
//                     .navigationTitle("Molecule Viewer") // Set title here if using NavigationView
//             }
//        }
//    }
//}
//*/
