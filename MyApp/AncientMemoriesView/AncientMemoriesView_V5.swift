////
////  AncientMemoriesView_V5.swift
////  MyApp
////
////  Created by Cong Le on 5/4/25.
////
//
////
////  FlowerFullscreenRenderer.swift
////  Created 05-2025 – adapts the previous line-based prototype
////
//
//import SwiftUI
//import MetalKit
//import simd
//
//// MARK: ‑- Metal shader source (fullscreen-tri vertex + analytic flower frag)
//private let shaderSrc = """
//#include <metal_stdlib>
//using namespace metal;
//
//// — Full-screen triangle (3 hard-coded vertices)
//vertex float4 vs_fullscreen(
//    uint vid [[vertex_id]]
//){
//    float2 p = float2( (vid << 1) & 2,  vid & 2 ); // (-1,-1) ( 3,-1) (-1, 3)
//    return float4(p * 2.0 - 1.0, 0.0, 1.0);
//}
//
//// Helper: rotation by 60°
//float2 rot60(float2 p){
//    const float A = 0.5f;                     // cos60 = 0.5
//    const float B = 0.8660254037844386f;      // sin60 = √3/2
//    return float2(A*p.x - B*p.y, B*p.x + A*p.y);
//}
//
//// Signed distance to a circle
//inline float sdCircle(float2 p, float r){ return length(p) - r; }
//
//// Re-map distance to antialiased alpha
//inline float strokify(float d, float halfWidth){
//    float aa = fwidth(d);                     // built-in derivative for 1-px AA
//    return smoothstep(halfWidth + aa, halfWidth - aa, abs(d));
//}
//
//// Main fragment: analytic flower + glow + background
//fragment half4 fs_flower(
//    float4 pos   [[position]],
//    float2 fragC [[position]]           // clip-space coords
//){
//    // Map to NDC → polar space ([-1,1] box to XY with aspect correction)
//    float2 uv = pos.xy;
//    float aspect = 1.0;                 // if needed pass via buffer
//    uv.x *= aspect;
//
//    // Parameters
//    const float R   = 0.5;              // core radius
//    const float w   = 0.008;            // stroke half-width in NDC
//    const float glowMul = 0.04;         // glow thickness
//
//    // Build seed-of-life centres
//    float2 centres[7];
//    centres[0] = float2(0.0,0.0);
//    centres[1] = float2( R, 0.0);
//    for(uint i=2;i<7;++i) centres[i] = rot60( centres[i-1]);
//
//    // Distance to nearest circle
//    float dMin = 1e5;
//    for(uint i=0;i<7;++i) dMin = min( dMin, abs(sdCircle( uv - centres[i], R )) );
//
//    // Outer ring (big bounding circle)
//    float outer = abs(sdCircle(uv, 2.*R));
//    dMin = min(dMin, outer);
//
//    // Stroke alpha + glow
//    float alpha = strokify(dMin, w);
//    float glow  = strokify(dMin, w + glowMul) * 0.6;
//
//    // Base colours
//    half4 strokeColor = half4(0.13, 1.0, 0.65, 1.0);  // neon green
//    half4 glowColor   = strokeColor * half4(1.0,1.0,1.0,0.4);
//
//    // Background radial gradient
//    float bgRad = length(uv)/2.0;                      // 0-1
//    half4 bg = half4( mix( float3(0.04,0.05,0.09), float3(0.07,0.0,0.16), bgRad ), 1.0 );
//
//    // Compose
//    half4 color = bg
//                + glowColor * half(glow)
//                + strokeColor * half(alpha);
//
//    return color;
//}
//"""
//
//// MARK: – Renderer (no vertex/index/uniform buffers needed)
//final class FullscreenFlowerRenderer: NSObject, MTKViewDelegate {
//    let device: MTLDevice
//    private let queue: MTLCommandQueue
//    private let pipeline: MTLRenderPipelineState
//
//    init?(device: MTLDevice, mtkView: MTKView) {
//        self.device = device
//        guard let q = device.makeCommandQueue() else { return nil }
//        queue = q
//
//        // Compile pipeline
//        let lib = try? device.makeLibrary(source: shaderSrc, options: nil)
//        guard
//            let vFn = lib?.makeFunction(name: "vs_fullscreen"),
//            let fFn = lib?.makeFunction(name: "fs_flower")
//        else { return nil }
//
//        let desc = MTLRenderPipelineDescriptor()
//        desc.label = "Flower Fullscreen"
//        desc.vertexFunction   = vFn
//        desc.fragmentFunction = fFn
//        desc.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
//        pipeline = try! device.makeRenderPipelineState(descriptor: desc)
//        super.init()
//    }
//
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
//
//    func draw(in view: MTKView) {
//        guard
//            let pass = view.currentRenderPassDescriptor,
//            let buf  = queue.makeCommandBuffer(),
//            let enc  = buf.makeRenderCommandEncoder(descriptor: pass),
//            let drawable = view.currentDrawable
//        else { return }
//
//        enc.setRenderPipelineState(pipeline)
//        enc.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
//        enc.endEncoding()
//        buf.present(drawable)
//        buf.commit()
//    }
//}
//
//// MARK: – SwiftUI wrapper
//struct MetalFlowerView: UIViewRepresentable {
//    func makeCoordinator() -> FullscreenFlowerRenderer { fatalError() }
//
//    func makeUIView(context: Context) -> MTKView {
//        let v = MTKView()
//        guard let dev = MTLCreateSystemDefaultDevice() else { return v }
//        v.device = dev
//        v.framebufferOnly = false
//        v.enableSetNeedsDisplay = false
//        v.isPaused = false
//        v.preferredFramesPerSecond = 60
//        v.clearColor = MTLClearColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 1)
//
//        if let r = FullscreenFlowerRenderer(device: dev, mtkView: v) {
//            v.delegate = r
//            // store renderer to keep alive
//            objc_setAssociatedObject(v, "renderer", r, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//        return v
//    }
//    func updateUIView(_ uiView: MTKView, context: Context) {}
//}
//
//// MARK: – SwiftUI screen
//struct FlowerScreen: View {
//    var body: some View {
//        MetalFlowerView()
//            .ignoresSafeArea()
//    }
//}
//
////#Preview { FlowerScreen() }
