////
////  AncientMemoriesView_V5.swift
////  MyApp
////
////  Created by Cong Le on 5/4/25.
////
////
////  FlowerOfLifeMetalView.swift
////  MyApp
////
////  A *self-contained* Metal implementation that renders the “flower / seed of life”
////  pattern exactly as described in the previous answers, **without any implicitly-
////  unwrapped optionals** and with a minimal SwiftUI/MetalKit bridge.
////
////  – No vertex / index buffers (fullscreen-triangle trick)
////  – All math & colouring in the fragment shader (distance-field approach)
////  – Clean coordinator-less UIViewRepresentable (simplest + preview-safe)
////
////  Created: 05 May 2025
////  License: MIT
////
//
//import SwiftUI
//import MetalKit
//
//// ──────────────────────────────────────────────────────────────
//// MARK: Shader Source
//// ──────────────────────────────────────────────────────────────
//
//private let flowerShaderSrc = """
//#include <metal_stdlib>
//using namespace metal;
//
//// ───────── Full-screen triangle ─────────
//vertex float4 vs_fullscreen(uint vid [[vertex_id]])
//{
//    float2 p = float2( (vid << 1) & 2,  vid & 2 );
//    return float4(p * 2.0 - 1.0, 0.0, 1.0);
//}
//
//// ───────── Helpers ─────────
//inline float sdCircle(float2 p, float r)            { return length(p) - r; }
//inline float strokify(float d, float h)
//{
//    float aa = fwidth(d);
//    return smoothstep(h + aa, h - aa, fabs(d));
//}
//inline float2 rot60(float2 p)    // rotate by 60°
//{
//    const float c = 0.5f;
//    const float s = 0.8660254037844386f;
//    return float2(c*p.x - s*p.y, s*p.x + c*p.y);
//}
//
//// ───────── Fragment – analytic flower ─────────
//fragment half4 fs_flower(float4 pos [[position]])
//{
//    float2 uv = pos.xy;                // clip-space (-1…1)
//    
//    // Keep aspect in previews / rotations
//    // (for simplicity assume square viewport → looks fine in portrait too)
//    
//    const float R  = 0.5;              // core radius
//    const float w  = 0.008;            // line half-width
//    const float g  = 0.04;             // glow thickness
//
//    // === Build centres: 1 central + 6 around ===
//    float2 centres[7];
//    centres[0] = float2(0.0, 0.0);
//    centres[1] = float2(R, 0.0);
//    for (uint i = 2; i < 7; ++i) centres[i] = rot60(centres[i-1]);
//
//    // Smallest distance to any circle
//    float d = 1e4;
//    for (uint i = 0; i < 7; ++i) d = min(d, fabs(sdCircle(uv - centres[i], R)));
//
//    // Outer ring
//    d = min(d, fabs(sdCircle(uv, 2.0 * R)));
//
//    // Alpha for stroke & glow
//    float  alpha = strokify(d, w);
//    float  glow  = strokify(d, w + g) * 0.6;
//
//    half3 strokeCol = half3(0.13, 1.0, 0.65);          // neon green
//    half3 bg1       = half3(0.04, 0.05, 0.09);
//    half3 bg2       = half3(0.07, 0.00, 0.16);
//    float  t        = clamp(length(uv) / 2.0, 0.0, 1.0);
//    half3  bg       = mix(bg1, bg2, half(t));
//
//    half3 colour = bg + (half3)glow * strokeCol + (half3)alpha * strokeCol;
//    return half4(colour, 1.0);
//}
//"""
//
//// ──────────────────────────────────────────────────────────────
//// MARK: Metal Renderer (no IUOs)
//// ──────────────────────────────────────────────────────────────
//
//final class FlowerRenderer: NSObject, MTKViewDelegate {
//    
//    // immutable after init
//    let device  : MTLDevice
//    private let queue   : MTLCommandQueue
//    private let pipeline: MTLRenderPipelineState
//    
//    // ── init may fail → optional
//    init?(mtkView: MTKView) {
//        guard
//            let dev  = MTLCreateSystemDefaultDevice(),
//            let q    = dev.makeCommandQueue(),
//            let lib  = try? dev.makeLibrary(source: flowerShaderSrc, options: nil),
//            let vFun = lib.makeFunction(name: "vs_fullscreen"),
//            let fFun = lib.makeFunction(name: "fs_flower")
//        else { return nil }
//        
//        let desc = MTLRenderPipelineDescriptor()
//        desc.vertexFunction                = vFun
//        desc.fragmentFunction              = fFun
//        desc.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
//        
//        guard let pipe = try? dev.makeRenderPipelineState(descriptor: desc)
//        else { return nil }
//        
//        device   = dev
//        queue    = q
//        pipeline = pipe
//        super.init()
//    }
//    
//    // no drawable-size bookkeeping needed
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
//    
//    func draw(in view: MTKView) {
//        guard
//            let pass     = view.currentRenderPassDescriptor,
//            let drawable = view.currentDrawable,
//            let cmdBuf   = queue.makeCommandBuffer(),
//            let enc      = cmdBuf.makeRenderCommandEncoder(descriptor: pass)
//        else { return }
//        
//        enc.setRenderPipelineState(pipeline)
//        enc.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
//        enc.endEncoding()
//        cmdBuf.present(drawable)
//        cmdBuf.commit()
//    }
//}
//
//// ──────────────────────────────────────────────────────────────
//// MARK: SwiftUI / MetalKit bridge (no coordinator needed)
//// ──────────────────────────────────────────────────────────────
//
//struct FlowerOfLifeMetalView: UIViewRepresentable {
//    
//    typealias UIViewType = MTKView
//    
//    func makeUIView(context: Context) -> MTKView {
//        let view = MTKView()
//        view.enableSetNeedsDisplay       = false
//        view.isPaused                    = false
//        view.preferredFramesPerSecond    = 60
//        view.framebufferOnly             = true
//        view.colorPixelFormat            = .bgra8Unorm_srgb
//        view.clearColor                  = MTLClearColor(red: 0.05, green: 0.05, blue: 0.09, alpha: 1.0)
//        
//        // Create renderer and keep it alive via associated-object
//        if let renderer = FlowerRenderer(mtkView: view) {
//            view.device   = renderer.device
//            view.delegate = renderer
//            objc_setAssociatedObject(view,
//                                     Unmanaged.passUnretained(self).toOpaque(),
//                                     renderer,
//                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//        return view
//    }
//    
//    func updateUIView(_ uiView: MTKView, context: Context) { /* no-op */ }
//}
//
//// ──────────────────────────────────────────────────────────────
//// MARK: Demo screen
//// ──────────────────────────────────────────────────────────────
//
//struct FlowerDemoScreen: View {
//    var body: some View {
//        FlowerOfLifeMetalView()
//            .ignoresSafeArea()
//    }
//}
//
//// ──────────────────────────────────────────────────────────────
//// MARK: Preview (safe – Metal works on device/simulator; canvas may be blank)
//// ──────────────────────────────────────────────────────────────
//
//#Preview { FlowerDemoScreen() }
