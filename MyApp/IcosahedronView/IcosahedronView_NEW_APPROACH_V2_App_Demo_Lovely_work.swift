//
//  IcosahedronView_NEW_APPRAOCH_V2.swift
//  MyApp
//
//  Created by Cong Le on 5/3/25.
//

//
//  PlatonicPlayground.swift
//  SacredGeometryDemo
//
//  A complete SwiftUI + Metal playground for exploring the 5 Platonic solids.
//  • Picker  : choose polyhedron
//  • Toggle  : auto-rotate vs. drag-to-orbit
//  • Slider  : rotation speed
//  • Toggle  : wire-frame ⇆ solid fill
//  • Button  : randomise vertex colours
//
//  Touch gestures
//  • One-finger drag  → orbit camera
//  • Pinch            → zoom
//
//  Created by AI Assistant (May-2025)
//  ---------------------------------------------------------------
//  Requires: iOS 16+ (Swift Concurrency & .onChange modifiers),
//            Metal-capable device / Simulator.
//

import SwiftUI
import MetalKit
import simd

// MARK: ‑- Shader Source (embedded) ‑-––––––––––––––––––––––––––––––––––

private let msl = #"""
#include <metal_stdlib>
using namespace metal;

struct VIn  { float3 pos [[attribute(0)]];
              float4 col [[attribute(1)]]; };

struct UBO  { float4x4 mvp; };

struct VOut { float4 pos [[position]];
              half4  col; };

vertex VOut v_main(const device VIn *v       [[buffer(0)]],
                   constant     UBO &u       [[buffer(1)]],
                   uint          id          [[vertex_id]])
{
    VOut o;
    o.pos = u.mvp * float4(v[id].pos, 1.0);
    o.col = half4(v[id].col);
    return o;
}

fragment half4 f_main(VOut in [[stage_in]]) { return in.col; }
"""#

// MARK: ‑- Math helpers ––––––––––––––––––––––––––––––––––––––––––––––––

@inline(__always) func deg2rad(_ d: Float) -> Float { d * .pi / 180 }

struct Math {

    static func perspective(fovY: Float, aspect: Float,
                            near: Float = 0.1, far: Float = 100) -> float4x4 {
        let ys = 1 / tan(fovY * 0.5)
        let xs = ys / aspect
        let zs = far / (far - near)
        return float4x4(columns: (
            SIMD4(xs, 0,   0,   0),
            SIMD4(0,  ys,  0,   0),
            SIMD4(0,  0,   zs,  1),
            SIMD4(0,  0,  -near*zs, 0)
        ))
    }

    static func lookAtLH(eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) -> float4x4 {
        let z = normalize(center - eye)
        let x = normalize(cross(up, z))
        let y = cross(z, x)
        let t = SIMD3(dot(-x, eye), dot(-y, eye), dot(-z, eye))
        return float4x4(columns: (
            SIMD4(x.x, y.x, z.x, 0),
            SIMD4(x.y, y.y, z.y, 0),
            SIMD4(x.z, y.z, z.z, 0),
            SIMD4(t.x, t.y, t.z, 1)
        ))
    }

    static func rotationXYZ(_ pitch: Float, _ yaw: Float, _ roll: Float) -> float4x4 {
        let cx = cos(pitch), sx = sin(pitch)
        let cy = cos(yaw),   sy = sin(yaw)
        let cz = cos(roll),  sz = sin(roll)
        let rx = float4x4(rows: [
            SIMD4(1, 0,  0, 0),
            SIMD4(0, cx, sx,0),
            SIMD4(0,-sx, cx,0),
            SIMD4(0, 0,  0,1)
        ])
        let ry = float4x4(rows: [
            SIMD4( cy,0,-sy,0),
            SIMD4(  0,1,  0,0),
            SIMD4( sy,0, cy,0),
            SIMD4(  0,0,  0,1)
        ])
        let rz = float4x4(rows: [
            SIMD4(cz, sz,0,0),
            SIMD4(-sz,cz,0,0),
            SIMD4( 0, 0,1,0),
            SIMD4( 0, 0,0,1)
        ])
        return rz * ry * rx
    }
}

// MARK: ‑- Data Types ––––––––––––––––––––––––––––––––––––––––––––––––

enum Polyhedron: String, CaseIterable, Identifiable {
    case tetrahedron = "Tetrahedron"
    case hexahedron  = "Cube (Hexahedron)"
    case octahedron  = "Octahedron"
    case dodecahedron = "Dodecahedron"
    case icosahedron  = "Icosahedron"
    var id: String { rawValue }
}

// Vertex matching shader layout
fileprivate struct Vertex {
    var pos: SIMD3<Float>
    var col: SIMD4<Float>
}

// UBO
fileprivate struct Uniforms { var mvp: float4x4 }

// MARK: ‑- Scene Settings model (Observable) ––––––––––––––––––––––––––

final class SceneSettings: ObservableObject {
    @Published var solid: Polyhedron         = .icosahedron
    @Published var wireframe                = true
    @Published var autoRotate               = true
    @Published var rotateSpeed: Float       = 1.0      // deg / frame
    @Published var colours: [SIMD4<Float>]  = Palette.default
    @Published var distance: Float          = 4.0
    @Published var camPitch: Float          = deg2rad(20)
    @Published var camYaw  : Float          = 0
}

enum Palette {
    static func random(count: Int) -> [SIMD4<Float>] {
        (0..<count).map { _ in
            SIMD4(Float.random(in: 0.2...1),
                  Float.random(in: 0.2...1),
                  Float.random(in: 0.2...1), 1)
        }
    }
    static let `default`: [SIMD4<Float>] =
        [ .init(1,0,0,1),.init(0,1,0,1),.init(0,0,1,1),
          .init(1,1,0,1),.init(0,1,1,1),.init(1,0,1,1) ]
}

// MARK: ‑- Geometry generators ––––––––––––––––––––––––––––––––––––––––

struct GeometryFactory {

    fileprivate static func make(_ p: Polyhedron, palette: [SIMD4<Float>])
    -> (vertices: [Vertex], indices: [UInt16]) {
        switch p {
        case .tetrahedron:   return tetrahedron(palette)
        case .hexahedron:    return cube(palette)
        case .octahedron:    return octahedron(palette)
        case .dodecahedron:  return dodecahedron(palette)
        case .icosahedron:   return icosahedron(palette)
        }
    }

    // MARK: Tetrahedron (4 faces) -------------------------------------
    private static func tetrahedron(_ c: [SIMD4<Float>])
    -> ([Vertex],[UInt16]) {
        let v: [SIMD3<Float>] = [
            SIMD3( 1, 1, 1),
            SIMD3(-1,-1, 1),
            SIMD3(-1, 1,-1),
            SIMD3( 1,-1,-1)
        ]
        let faces: [[UInt16]] = [
            [0,1,2],[0,3,1],[0,2,3],[1,3,2]
        ]
        let colors = expandedColours(count: v.count, base: c)
        return (zip(v,colors).map(Vertex.init), faces.flatMap{$0})
    }

    // MARK: Cube (6 faces *2 triangles) --------------------------------
    private static func cube(_ c: [SIMD4<Float>])
    -> ([Vertex],[UInt16]) {
        let v: [SIMD3<Float>] = [
            SIMD3(-1, 1, 1), SIMD3( 1, 1, 1),
            SIMD3(-1,-1, 1), SIMD3( 1,-1, 1),
            SIMD3(-1, 1,-1), SIMD3( 1, 1,-1),
            SIMD3(-1,-1,-1), SIMD3( 1,-1,-1)
        ]
        let faces: [[UInt16]] = [
            [0,1,2],[1,3,2],    // front
            [1,5,3],[5,7,3],    // right
            [5,4,7],[4,6,7],    // back
            [4,0,6],[0,2,6],    // left
            [4,5,0],[5,1,0],    // top
            [2,3,6],[3,7,6]     // bottom
        ]
        let colors = expandedColours(count: v.count, base: c)
        return (zip(v,colors).map(Vertex.init), faces.flatMap{$0})
    }

    // MARK: Octahedron -------------------------------------------------
    private static func octahedron(_ c: [SIMD4<Float>])
    -> ([Vertex],[UInt16]) {
        let v: [SIMD3<Float>] = [
            SIMD3( 0, 0, 1), SIMD3( 1, 0, 0),
            SIMD3( 0, 0,-1), SIMD3(-1, 0, 0),
            SIMD3( 0, 1, 0), SIMD3( 0,-1, 0)
        ]
        let faces: [[UInt16]] = [
            [0,4,1],[1,4,2],[2,4,3],[3,4,0],
            [0,5,3],[3,5,2],[2,5,1],[1,5,0]
        ]
        let colors = expandedColours(count: v.count, base: c)
        return (zip(v,colors).map(Vertex.init), faces.flatMap{$0})
    }

    // MARK: Dodecahedron (12 pentagons, 30 verts) ----------------------
    private static func dodecahedron(_ c: [SIMD4<Float>])
    -> ([Vertex],[UInt16]) {
        let φ: Float = (1 + sqrt(5.0))/2
        let a: Float = 1 / φ
        let v: [SIMD3<Float>] = [
            // (±1, ±1, ±1)
            SIMD3(-1,-1,-1), SIMD3(-1,-1, 1),
            SIMD3(-1, 1,-1), SIMD3(-1, 1, 1),
            SIMD3( 1,-1,-1), SIMD3( 1,-1, 1),
            SIMD3( 1, 1,-1), SIMD3( 1, 1, 1),
            // (0, ±±φ, ±a)
            SIMD3( 0,-a,-φ), SIMD3( 0,-a, φ),
            SIMD3( 0, a,-φ), SIMD3( 0, a, φ),
            // (±a, 0, ±φ)
            SIMD3(-a,-φ, 0), SIMD3(-a, φ, 0),
            SIMD3( a,-φ, 0), SIMD3( a, φ, 0),
            // (±φ, ±a, 0)
            SIMD3(-φ, 0,-a), SIMD3( φ, 0,-a),
            SIMD3(-φ, 0, a), SIMD3( φ, 0, a)
        ]
        // 36 = 12 pentagons ×3 triangles
        let p: [[UInt16]] = [
            [0,8,9,1,13],[1,9,5,19,11],[5,15,7,6,19],
            [7,17,3,12,2],[3,11,19,6,18],[12,3,11,10,2],
            [4,14,15,5,9],[4,16,18,6,14],[0,12,17,8,13],
            [2,10,16,4,14],[0,13,1,11,3],[8,17,7,15,14]
        ]
        var faces = [[UInt16]]()
        for pent in p {
            // fan triangulate (0,1,2)(0,2,3)(0,3,4)
            faces += [[pent[0],pent[1],pent[2]],
                      [pent[0],pent[2],pent[3]],
                      [pent[0],pent[3],pent[4]]]
        }
        let colors = expandedColours(count: v.count, base: c)
        return (zip(v,colors).map(Vertex.init), faces.flatMap{$0})
    }

    // MARK: Icosahedron ------------------------------------------------
    private static func icosahedron(_ c: [SIMD4<Float>])
    -> ([Vertex],[UInt16]) {
        let φ: Float = (1 + sqrt(5.0))/2
        let v: [SIMD3<Float>] = [
            SIMD3( 0, 1, φ), SIMD3( 0,-1, φ),
            SIMD3( 0, 1,-φ), SIMD3( 0,-1,-φ),
            SIMD3( 1, φ, 0), SIMD3(-1, φ, 0),
            SIMD3( 1,-φ, 0), SIMD3(-1,-φ, 0),
            SIMD3( φ, 0, 1), SIMD3(-φ, 0, 1),
            SIMD3( φ, 0,-1), SIMD3(-φ, 0,-1)
        ]
        let f:[[UInt16]] = [
            [0,1,8],[0,9,1],[0,5,9],[0,4,5],[0,8,4],
            [1,6,8],[1,9,7],[1,7,6],[2,3,10],[2,11,3],
            [2,5,4],[2,4,10],[2,11,5],[3,6,7],[3,10,6],
            [3,7,11],[4,8,10],[5,9,11],[6,7,8],[7,9,11]
        ]
        let colors = expandedColours(count: v.count, base: c)
        return (zip(v,colors).map(Vertex.init), f.flatMap{$0})
    }

    private static func expandedColours(count n:Int, base:[SIMD4<Float>]) -> [SIMD4<Float>] {
        guard !base.isEmpty else { return Array(repeating: SIMD4(1,1,1,1), count: n) }
        var out = [SIMD4<Float>]()
        for i in 0..<n { out.append(base[i % base.count]) }
        return out
    }
}

// MARK: ‑- Renderer (MTKViewDelegate) ––––––––––––––––––––––––––––––––

final class Renderer: NSObject, MTKViewDelegate {
    private unowned let view: MTKView
    private let device: MTLDevice
    private let queue:  MTLCommandQueue
    private var pipe:   MTLRenderPipelineState!
    private var depth:  MTLDepthStencilState!

    private var vBuf:   MTLBuffer!
    private var iBuf:   MTLBuffer!
    private var uBuf:   MTLBuffer!
    private var indexCount = 0

    private var aspect: Float = 1
    private var angleAccum: Float = 0

    private var settings: SceneSettings  // observed externally

    init?(mtkView: MTKView, settings: SceneSettings) {
        guard let dev = MTLCreateSystemDefaultDevice(),
              let q   = dev.makeCommandQueue() else { return nil }
        self.view      = mtkView
        self.device    = dev
        self.queue     = q
        self.settings  = settings
        super.init()
        mtkView.device = dev
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        mtkView.depthStencilPixelFormat = .depth32Float
        mtkView.preferredFramesPerSecond = 60

        makePipeline()
        makeDepth()
        rebuildGeometry()
        uBuf = dev.makeBuffer(length: MemoryLayout<Uniforms>.stride,
                              options: .storageModeShared)
    }

    // MARK: ‑- Pipeline & Depth
    private func makePipeline() {
        do {
            let lib  = try device.makeLibrary(source: msl, options: nil)
            let vFn  = lib.makeFunction(name:"v_main")
            let fFn  = lib.makeFunction(name:"f_main")
            let desc = MTLVertexDescriptor()
            desc.attributes[0].format = .float3
            desc.attributes[1].format = .float4
            desc.attributes[0].offset = 0
            desc.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
            desc.layouts[0].stride    = MemoryLayout<Vertex>.stride

            let p = MTLRenderPipelineDescriptor()
            p.vertexFunction   = vFn
            p.fragmentFunction = fFn
            p.vertexDescriptor = desc
            p.colorAttachments[0].pixelFormat = view.colorPixelFormat
            p.depthAttachmentPixelFormat      = view.depthStencilPixelFormat
            pipe = try device.makeRenderPipelineState(descriptor: p)
        } catch { fatalError("Pipeline: \(error)") }
    }

    private func makeDepth() {
        let d = MTLDepthStencilDescriptor()
        d.isDepthWriteEnabled = true
        d.depthCompareFunction = .less
        depth = device.makeDepthStencilState(descriptor: d)
    }

    // MARK: ‑- Geometry (re-build when user changes solid/colours)
    func rebuildGeometry() {
        let (verts, idx) = GeometryFactory.make(settings.solid,
                                                palette: settings.colours)
        indexCount = idx.count
        vBuf = device.makeBuffer(bytes: verts,
                                 length: verts.count * MemoryLayout<Vertex>.stride)
        iBuf = device.makeBuffer(bytes: idx,
                                 length: idx.count * MemoryLayout<UInt16>.stride)
    }

    // MARK: ‑- MTKViewDelegate
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        aspect = Float(size.width / max(size.height, 1))
    }

    func draw(in view: MTKView) {
        guard let pass = view.currentRenderPassDescriptor,
              let drawable = view.currentDrawable,
              let cmd = queue.makeCommandBuffer(),
              let enc = cmd.makeRenderCommandEncoder(descriptor: pass) else { return }

        updateUniforms()
        enc.setRenderPipelineState(pipe)
        enc.setDepthStencilState(depth)

        enc.setCullMode(.none)
        enc.setTriangleFillMode(settings.wireframe ? .lines : .fill)

        enc.setVertexBuffer(vBuf, offset: 0, index: 0)
        enc.setVertexBuffer(uBuf, offset: 0, index: 1)
        enc.drawIndexedPrimitives(type: .triangle,
                                  indexCount: indexCount,
                                  indexType: .uint16,
                                  indexBuffer: iBuf,
                                  indexBufferOffset: 0)
        enc.endEncoding()
        cmd.present(drawable)
        cmd.commit()
    }

    // MARK: ‑- Uniforms
    private func updateUniforms() {
        if settings.autoRotate {
            angleAccum += settings.rotateSpeed * .pi/180
        }
        let proj = Math.perspective(fovY: .pi/3, aspect: aspect)
        let eye  = SIMD3<Float>(0, 0, -settings.distance)
            .rotatedX(settings.camPitch)
            .rotatedY(settings.camYaw)
        let view = Math.lookAtLH(eye: eye, center: .zero, up: SIMD3(0,1,0))
        let model = Math.rotationXYZ(0, angleAccum, 0)
        var u = Uniforms(mvp: proj * view * model)
        memcpy(uBuf.contents(), &u, MemoryLayout<Uniforms>.size)
    }
}

// simple helpers
fileprivate extension SIMD3 where Scalar == Float {
    func rotatedX(_ a: Float) -> SIMD3 { [x, cos(a)*y - sin(a)*z, sin(a)*y + cos(a)*z] }
    func rotatedY(_ a: Float) -> SIMD3 { [ cos(a)*x + sin(a)*z, y, -sin(a)*x + cos(a)*z] }
}

// MARK: ‑- SwiftUI wrapper ––––––––––––––––––––––––––––––––––––––––––––

struct MetalView: UIViewRepresentable {
    @ObservedObject var settings: SceneSettings
    func makeCoordinator() -> RendererCoordinator { RendererCoordinator(settings)! }

    func makeUIView(context: Context) -> MTKView { context.coordinator.view }

    func updateUIView(_ uiView: MTKView, context: Context) { }
}

final class RendererCoordinator: NSObject {
    let view: MTKView
    private let renderer: Renderer
    init?(_ settings: SceneSettings) {
        view = MTKView()
        guard let r = Renderer(mtkView: view, settings: settings) else { return nil }
        renderer = r
        super.init()
        view.delegate = renderer
        // respond to changes from SwiftUI
        settings.$solid.combineLatest(settings.$colours)
            .sink { _ , _ in r.rebuildGeometry() }
            .store(in: &bag)
    }
    private var bag = Set<AnyCancellable>()
}

import Combine // for AnyCancellable

// MARK: ‑- Main SwiftUI UI ––––––––––––––––––––––––––––––––––––––––––––

struct PlatonicPlaygroundView: View {

    @StateObject private var settings = SceneSettings()

    // Gesture state
    @State private var lastDrag : CGSize = .zero
    @State private var lastMag  : CGFloat = 1

    var body: some View {
        VStack {
            // Metal
            MetalView(settings: settings)
                .gesture(dragGesture)
                .gesture(pinchGesture)
                .overlay(uiOverlay, alignment: .topLeading)
        }
        .background(Color(.sRGBLinear, white: 0.1, opacity: 1))
        .ignoresSafeArea()
    }

    // MARK: Overlay Controls ------------------------------------------
    private var uiOverlay: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Solid", selection: $settings.solid) {
                ForEach(Polyhedron.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.menu)

            Toggle("Wire-frame", isOn: $settings.wireframe)
            Toggle("Auto-rotate", isOn: $settings.autoRotate)

            HStack {
                Text("Speed")
                Slider(value: $settings.rotateSpeed, in: 0...5)
            }
            Button("Random Colours") {
                settings.colours = Palette.random(count: 32)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        .padding()
        .font(.subheadline.weight(.medium))
        .foregroundColor(.white)
    }

    // MARK: Gestures ---------------------------------------------------
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { v in
                let dx = Float(v.translation.width - lastDrag.width) * 0.01
                let dy = Float(v.translation.height - lastDrag.height) * 0.01
                settings.camYaw  += dx
                settings.camPitch += dy
                settings.camPitch = min(max(settings.camPitch, -Float.pi/2+0.2), Float.pi/2-0.2)
                lastDrag = v.translation
            }
            .onEnded { _ in lastDrag = .zero }
    }

    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { v in
                let delta = Float(v / lastMag)
                settings.distance = max(1, min(10, settings.distance / delta))
                lastMag = v
            }
            .onEnded { _ in lastMag = 1 }
    }
}

// MARK: ‑- Preview ––––––––––––––––––––––––––––––––––––––––––––––––––––
#Preview { PlatonicPlaygroundView() }
