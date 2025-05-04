//
//  IcosahedronView_NEW_V1.swift
//  MyApp
//
//  Created by Cong Le on 5/3/25.
//

//
//  IcosahedronView.swift
//  IcosahedronMetalDemo
//
//  One-file SwiftUI + Metal sample that renders a rotating wire-frame
//  Icosahedron (20 triangular faces, 30 edges, 12 vertices).
//
//  • SwiftUI ⟶ UIViewRepresentable ⟶ MTKView (MetalKit)
//  • Renderer class handles all Metal objects & draw loop
//  • Embedded Metal shader source (vertex + fragment)
//  • Geometry data generated with the golden ratio ϕ = (1+√5)/2
//
//  Created by AI Assistant – May 2025
//

import SwiftUI
import MetalKit
import simd

//──────────────────────────────────────────────────────────────────────── MARK:─
// Metal Shader Source (embedded)
let icosahedronMetalShader = """
#include <metal_stdlib>
using namespace metal;

struct VertexIn  { float3 position [[attribute(0)]];
                   float4 color    [[attribute(1)]]; };

struct VertexOut { float4 position [[position]];
                   float4 color; };

struct Uniforms  { float4x4 mvp; };

vertex VertexOut icosahedron_vertex_shader(const device VertexIn *v  [[buffer(0)]],
                                           const device Uniforms &u [[buffer(1)]],
                                           uint vid                 [[vertex_id]]) {
    VertexOut o;
    o.position = u.mvp * float4(v[vid].position, 1.0);
    o.color    = v[vid].color;
    return o;
}

fragment half4 icosahedron_fragment_shader(VertexOut in [[stage_in]]) {
    return half4(in.color);
}
"""

//──────────────────────────────────────────────────────────────────────── MARK:─
// CPU-side structures matching shader layout
struct Uniforms       { var mvp: matrix_float4x4 }
struct IcosaVertex    { var position: SIMD3<Float>; var color: SIMD4<Float> }

//──────────────────────────────────────────────────────────────────────── MARK:─
// Renderer
final class IcosahedronRenderer: NSObject, MTKViewDelegate {
    
    // Metal
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    private var pipeline: MTLRenderPipelineState!
    private var depthState: MTLDepthStencilState!
    
    // Buffers
    private var vBuffer: MTLBuffer!
    private var iBuffer: MTLBuffer!
    private var uBuffer: MTLBuffer!
    
    // Animation / view
    private var aspect: Float = 1
    private var angle: Float = 0
    
    // MARK: - Geometry ----------------------------------------------------
    private static func buildGeometry() -> ([IcosaVertex], [UInt16]) {
        let φ: Float = (1 + sqrt(5.0)) / 2         // Golden ratio
        let s: Float = 1                           // scale (can normalise later)
        
        // 12 vertices (see documentation section)
        let positions: [SIMD3<Float>] = [
            SIMD3( 0,  s,  φ), SIMD3( 0, -s,  φ),
            SIMD3( 0,  s, -φ), SIMD3( 0, -s, -φ),
            SIMD3( s,  φ, 0),  SIMD3(-s,  φ, 0),
            SIMD3( s, -φ, 0),  SIMD3(-s, -φ, 0),
            SIMD3( φ, 0,  s),  SIMD3(-φ, 0,  s),
            SIMD3( φ, 0, -s),  SIMD3(-φ, 0, -s)
        ]
        // simple distinct colours
        let palette: [SIMD4<Float>] = [
            .init(1,0,0,1), .init(0,1,0,1), .init(0,0,1,1),
            .init(1,1,0,1), .init(1,0,1,1), .init(0,1,1,1),
            .init(1,0.5,0,1), .init(0.6,0,1,1),
            .init(0.3,1,0.5,1), .init(1,0.3,0.5,1),
            .init(0.2,0.8,1,1), .init(1,0.8,0.2,1)
        ]
        let vertices = zip(positions, palette).map { IcosaVertex(position: $0.0, color: $0.1) }
        
        // 20 triangular faces
        let faces: [[UInt16]] = [
            [0,1,8],  [0,9,1],  [0,5,9], [0,4,5], [0,8,4],
            [1,6,8],  [1,9,7],  [1,7,6], [2,3,10],[2,11,3],
            [2,5,4],  [2,4,10], [2,11,5],[3,6,7], [3,10,6],
            [3,7,11], [4,8,10], [5,9,11],[6,7,8], [7,9,11]
        ]
        let indices = faces.flatMap { $0 }   // flatten → [UInt16]
        return (vertices, indices)
    }
    
    private let vertices: [IcosaVertex]
    private let indices:  [UInt16]
    
    // MARK: - Init ---------------------------------------------------------
    init?(device: MTLDevice) {
        self.device = device
        guard let queue = device.makeCommandQueue() else { return nil }
        commandQueue = queue
        (vertices, indices) = Self.buildGeometry()
        super.init()
        buildBuffers()
        buildDepthState()
    }
    
    // MARK: - Setup --------------------------------------------------------
    func configure(view: MTKView) {
        buildPipeline(for: view)
    }
    
    private func buildBuffers() {
        vBuffer = device.makeBuffer(bytes: vertices,
                                    length: vertices.count * MemoryLayout<IcosaVertex>.stride)
        iBuffer = device.makeBuffer(bytes: indices,
                                    length: indices.count * MemoryLayout<UInt16>.stride)
        uBuffer = device.makeBuffer(length: MemoryLayout<Uniforms>.stride,
                                    options: .storageModeShared)
    }
    
    private func buildDepthState() {
        let desc = MTLDepthStencilDescriptor()
        desc.depthCompareFunction = .less
        desc.isDepthWriteEnabled = true
        depthState = device.makeDepthStencilState(descriptor: desc)
    }
    
    private func buildPipeline(for view: MTKView) {
        do {
            let lib = try device.makeLibrary(source: icosahedronMetalShader, options: nil)
            let vFn  = lib.makeFunction(name: "icosahedron_vertex_shader")
            let fFn  = lib.makeFunction(name: "icosahedron_fragment_shader")
            
            let vDesc = MTLVertexDescriptor()
            vDesc.attributes[0].format = .float3
            vDesc.attributes[0].offset = 0
            vDesc.attributes[0].bufferIndex = 0
            vDesc.attributes[1].format = .float4
            vDesc.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
            vDesc.attributes[1].bufferIndex = 0
            vDesc.layouts[0].stride = MemoryLayout<IcosaVertex>.stride
            
            let pDesc = MTLRenderPipelineDescriptor()
            pDesc.vertexFunction   = vFn
            pDesc.fragmentFunction = fFn
            pDesc.vertexDescriptor = vDesc
            pDesc.colorAttachments[0].pixelFormat = view.colorPixelFormat
            pDesc.depthAttachmentPixelFormat      = view.depthStencilPixelFormat
            pipeline = try device.makeRenderPipelineState(descriptor: pDesc)
        } catch {
            fatalError("Pipeline build failed: \(error)")
        }
    }
    
    //───────────────────────────────────────────────────────────────────────
    // MARK: - MTKViewDelegate
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        aspect = Float(size.width / max(size.height, 1))
    }
    
    func draw(in view: MTKView) {
        guard let pass = view.currentRenderPassDescriptor,
              let drawable = view.currentDrawable,
              let cmdBuf = commandQueue.makeCommandBuffer(),
              let enc = cmdBuf.makeRenderCommandEncoder(descriptor: pass) else { return }
        
        updateUniforms()
        
        enc.setRenderPipelineState(pipeline)
        enc.setDepthStencilState(depthState)
        enc.setCullMode(.none)                  // disable culling for wireframe
        enc.setTriangleFillMode(.lines)         // wire-frame look
        
        enc.setVertexBuffer(vBuffer, offset: 0, index: 0)
        enc.setVertexBuffer(uBuffer, offset: 0, index: 1)
        enc.drawIndexedPrimitives(type: .triangle,
                                  indexCount: indices.count,
                                  indexType: .uint16,
                                  indexBuffer: iBuffer,
                                  indexBufferOffset: 0)
        enc.endEncoding()
        cmdBuf.present(drawable)
        cmdBuf.commit()
    }
    
    //───────────────────────────────────────────────────────────────────────
    // MARK: - Uniforms
    
    private func updateUniforms() {
        // Projection
        let proj = matrix_perspective_left_hand(fovy: .pi/3, aspect: aspect, near: 0.1, far: 100)
        // View
        let view = matrix_look_at_left_hand(eye: [0, 0.5, -4],
                                            center: [0,0,0],
                                            up: [0,1,0])
        // Model
        let rotY = matrix_rotation_y(angle)
        let rotX = matrix_rotation_x(angle*0.5)
        let model = rotY * rotX
        
        var uniforms = Uniforms(mvp: proj * view * model)
        memcpy(uBuffer.contents(), &uniforms, MemoryLayout<Uniforms>.size)
        angle += 0.01
    }
}

//──────────────────────────────────────────────────────────────────────── MARK:─
// UIViewRepresentable  ➜  SwiftUI

struct MetalIcosahedronView: UIViewRepresentable {
    typealias UIViewType = MTKView
    
    func makeCoordinator() -> IcosahedronRenderer {
        guard let dev = MTLCreateSystemDefaultDevice(),
              let rend = IcosahedronRenderer(device: dev) else {
            fatalError("Metal unavailable")
        }
        return rend
    }
    
    func makeUIView(context: Context) -> MTKView {
        let view = MTKView(frame: .zero, device: context.coordinator.device)
        view.colorPixelFormat = .bgra8Unorm_srgb
        view.depthStencilPixelFormat = .depth32Float
        view.clearColor = MTLClearColorMake(0.1, 0.1, 0.15, 1)
        view.preferredFramesPerSecond = 60
        view.enableSetNeedsDisplay = false
        
        context.coordinator.configure(view: view)
        view.delegate = context.coordinator
        context.coordinator.mtkView(view, drawableSizeWillChange: view.drawableSize)
        return view
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) { }
}

//──────────────────────────────────────────────────────────────────────── MARK:─
// SwiftUI View

struct IcosahedronView: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Rotating Wireframe Icosahedron (Metal)")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.1, green: 0.1, blue: 0.15))
                .foregroundColor(.white)
            MetalIcosahedronView()
        }
        .background(Color(red: 0.1, green: 0.1, blue: 0.15))
        .ignoresSafeArea(.keyboard)
    }
}

//──────────────────────────────────────────────────────────────────────── MARK:─
// Preview

#Preview { IcosahedronView() }

//──────────────────────────────────────────────────────────────────────── MARK:─
// Matrix Helpers  (Left-handed coordinate system)

@inline(__always)
func matrix_perspective_left_hand(fovy: Float, aspect: Float, near: Float, far: Float)
-> matrix_float4x4 {
    let y = 1 / tan(fovy * 0.5)
    let x = y / aspect
    let z = far / (far - near)
    return matrix_float4x4(
        SIMD4<Float>( x, 0, 0, 0),
        SIMD4<Float>( 0, y, 0, 0),
        SIMD4<Float>( 0, 0, z, 1),
        SIMD4<Float>( 0, 0, -near * z, 0)
    )
}

@inline(__always)
func matrix_look_at_left_hand(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>)
-> matrix_float4x4 {
    let z = simd_normalize(center - eye)
    let x = simd_normalize(simd_cross(up, z))
    let y = simd_cross(z, x)
    let t = SIMD3(simd_dot(-x, eye), simd_dot(-y, eye), simd_dot(-z, eye))
    return matrix_float4x4(
        SIMD4<Float>(x.x, y.x, z.x, 0),
        SIMD4<Float>(x.y, y.y, z.y, 0),
        SIMD4<Float>(x.z, y.z, z.z, 0),
        SIMD4<Float>(t.x, t.y, t.z, 1)
    )
}

@inline(__always)
func matrix_rotation_y(_ angle: Float) -> matrix_float4x4 {
    let c = cos(angle), s = sin(angle)
    return matrix_float4x4(
        SIMD4<Float>( c, 0,  s, 0),
        SIMD4<Float>( 0, 1,  0, 0),
        SIMD4<Float>(-s, 0,  c, 0),
        SIMD4<Float>( 0, 0,  0, 1)
    )
}

@inline(__always)
func matrix_rotation_x(_ angle: Float) -> matrix_float4x4 {
    let c = cos(angle), s = sin(angle)
    return matrix_float4x4(
        SIMD4<Float>(1, 0, 0, 0),
        SIMD4<Float>(0, c, s, 0),
        SIMD4<Float>(0,-s, c, 0),
        SIMD4<Float>(0, 0, 0, 1)
    )
}
