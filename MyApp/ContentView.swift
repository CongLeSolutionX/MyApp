//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

//import SwiftUI
//
//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//// After iOS 17, we can use this syntax for preview:
//#Preview {
//    ContentView()
//}

import SwiftUI
import MetalKit

/// A SwiftUI view wrapping a MTKView to render a static image via Metal.
struct ContentView: View {
    var body: some View {
        MetalImageView(imageName: "screenshot")
            .edgesIgnoringSafeArea(.all)
    }
}

struct MetalImageView: UIViewRepresentable {
    let imageName: String

    func makeCoordinator() -> Renderer {
        Renderer(imageName: imageName)
    }

    func makeUIView(context: Context) -> MTKView {
        let mtk = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        mtk.enableSetNeedsDisplay = true
        mtk.isPaused = true               // static image, no continuous redraw
        mtk.delegate = context.coordinator
        context.coordinator.configure(view: mtk)
        return mtk
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        uiView.setNeedsDisplay()
    }
}

final class Renderer: NSObject, MTKViewDelegate {
    private let device: MTLDevice
    private var pipelineState: MTLRenderPipelineState!
    private var texture: MTLTexture!

    init(imageName: String) {
        guard let dev = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal not supported on this device")
        }
        self.device = dev
        super.init()
        self.buildPipeline()
        self.loadTexture(named: imageName)
    }

    /// Configure common MTKView properties
    func configure(view: MTKView) {
        view.device = device
        view.colorPixelFormat = .bgra8Unorm
        view.framebufferOnly = true
    }

    // MARK: - MTKViewDelegate

    func draw(in view: MTKView) {
        guard
            let drawable = view.currentDrawable,
            let passDesc = view.currentRenderPassDescriptor
        else { return }

        let cmdBuf = device.makeCommandQueue()!.makeCommandBuffer()!

        let encoder = cmdBuf.makeRenderCommandEncoder(descriptor: passDesc)!
        encoder.setRenderPipelineState(pipelineState)
        encoder.setFragmentTexture(texture, index: 0)
        
        // Draw a full-screen quad: 4 vertices
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        encoder.endEncoding()

        cmdBuf.present(drawable)
        cmdBuf.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // No action needed for a static image
    }

    // MARK: - Setup

    private func buildPipeline() {
        let lib = try! device.makeLibrary(source: Self.shaderSource, options: nil)
        let vFunc = lib.makeFunction(name: "vertex_main")
        let fFunc = lib.makeFunction(name: "fragment_main")

        let desc = MTLRenderPipelineDescriptor()
        desc.vertexFunction   = vFunc
        desc.fragmentFunction = fFunc
        desc.colorAttachments[0].pixelFormat = .bgra8Unorm

        pipelineState = try! device.makeRenderPipelineState(descriptor: desc)
    }

    private func loadTexture(named name: String) {
        let loader = MTKTextureLoader(device: device)
        guard
            let uiImage = UIImage(named: name),
            let cgImage = uiImage.cgImage
        else {
            fatalError("Failed to load image \(name)")
        }
        texture = try! loader.newTexture(cgImage: cgImage, options: [
            MTKTextureLoader.Option.SRGB : false
        ])
    }

    /// Inline Metal shader source (vertex + fragment)
    private static let shaderSource = """
    #include <metal_stdlib>
    using namespace metal;
    struct Vertex { float4 position [[position]]; float2 texCoord; };

    vertex Vertex vertex_main(uint vid [[vertex_id]]) {
        float2 positions[4] = { {-1,-1}, {1,-1}, {-1,1}, {1,1} };
        float2 uvs[4]       = { {0,1},   {1,1},   {0,0},   {1,0} };
        Vertex out;
        out.position = float4(positions[vid], 0.0, 1.0);
        out.texCoord = uvs[vid];
        return out;
    }

    fragment float4 fragment_main(Vertex in [[stage_in]],
                                  texture2d<float> tex [[texture(0)]]) {
        constexpr sampler s(coord::normalized,
                            address::clamp_to_edge,
                            filter::linear);
        return tex.sample(s, in.texCoord);
    }
    """
}

#Preview() {
    ContentView()
}
