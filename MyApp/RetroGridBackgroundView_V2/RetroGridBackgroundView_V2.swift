////
////  RetroGridBackgroundView.swift
////  MyApp
////
////  Created by Cong Le on 4/17/25.
////
//
//import SwiftUI
//import MetalKit
//
//// MetalKit Wrapped in UIViewRepresentable for SwiftUI usage
//struct MetalView: UIViewRepresentable {
//    func makeCoordinator() -> Renderer {
//        Renderer()
//    }
//
//    func makeUIView(context: Context) -> MTKView {
//        let device = MTLCreateSystemDefaultDevice()!
//        let mtkView = MTKView(frame: .zero, device: device)
//        
//        mtkView.delegate = context.coordinator
//        mtkView.framebufferOnly = false
//        mtkView.isOpaque = false
//        mtkView.backgroundColor = .clear
//        context.coordinator.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
//        return mtkView
//    }
//
//    func updateUIView(_ uiView: MTKView, context: Context) {}
//}
//
//// MARK: - Renderers
//class Renderer: NSObject, MTKViewDelegate {
//    private var commandQueue: MTLCommandQueue!
//    private var pipelineState: MTLRenderPipelineState!
//    private var starsPipelineState: MTLRenderPipelineState!
//    private var time: Float = 0.0
//
//    override init() {
//        super.init()
//        setUpMetal()
//    }
//
//    private func setUpMetal() {
//        guard let device = MTLCreateSystemDefaultDevice() else { return }
//        commandQueue = device.makeCommandQueue()
//
//        let library = device.makeDefaultLibrary()
//        
//        // Grid pipeline setup
//        let gridPipelineDescriptor = MTLRenderPipelineDescriptor()
//        gridPipelineDescriptor.vertexFunction = library?.makeFunction(name: "gridVertexShader")
//        gridPipelineDescriptor.fragmentFunction = library?.makeFunction(name: "gridFragmentShader")
//        gridPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
//        gridPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
//        pipelineState = try? device.makeRenderPipelineState(descriptor: gridPipelineDescriptor)
//        
//        // Stars pipeline setup
//        let starPipelineDescriptor = MTLRenderPipelineDescriptor()
//        starPipelineDescriptor.vertexFunction = library?.makeFunction(name: "starsVertexShader")
//        starPipelineDescriptor.fragmentFunction = library?.makeFunction(name: "starsFragmentShader")
//        starPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
//        starPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
//        starsPipelineState = try? device.makeRenderPipelineState(descriptor: starPipelineDescriptor)
//    }
//
//    // Update drawable size if needed
//    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
//
//    // Render contents
//    func draw(in view: MTKView) {
//        guard let drawable = view.currentDrawable,
//              let renderPassDescriptor = view.currentRenderPassDescriptor,
//              let commandBuffer = commandQueue.makeCommandBuffer() else { return }
//
//        renderPassDescriptor.colorAttachments[0].loadAction = .clear
//        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
//
//        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
//        
//        // Render grid
//        encoder.setRenderPipelineState(pipelineState)
//        encoder.setFragmentBytes(&time, length: MemoryLayout<Float>.stride, index: 0)
//        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
//
//        // Render stars
//        encoder.setRenderPipelineState(starsPipelineState)
//        encoder.setFragmentBytes(&time, length: MemoryLayout<Float>.stride, index: 0)
//        encoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: 500) // 500 random stars
//
//        encoder.endEncoding()
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//
//        time += 0.01
//    }
//}
//
//// MARK: - Integration
//struct RetroGridBackgroundView: View {
//    var body: some View {
//        ZStack {
//            // Gradient background - purple sky
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color.black,
//                    Color.purple.opacity(0.8),
//                    Color.purple.opacity(0.6),
//                    Color.blue.opacity(0.3)]
//                ),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .edgesIgnoringSafeArea(.all)
//
//            // Metal View (grid & stars)
//            MetalView()
//                .edgesIgnoringSafeArea(.all)
//        }
//    }
//}
//
//// Canvas Preview
//struct RetroGridBackgroundView_Previews: PreviewProvider {
//    static var previews: some View {
//        RetroGridBackgroundView()
//    }
//}
//
//// MARK: - Metal design
//
