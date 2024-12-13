////
////  Metal3DView.swift
////  MyApp
////
////  Created by Cong Le on 12/13/24.
////
//import SwiftUI
//import MetalKit
//
//// MARK: - MTKViewWrapper
//struct Rendering3DMTKViewWrapper: UIViewRepresentable {
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, MTKViewDelegate {
//        
//        var parent: Rendering3DMTKViewWrapper
//        var device: MTLDevice!
//        var commandQueue: MTLCommandQueue!
//        var pipelineState: MTLRenderPipelineState!
//        var mesh: MTKMesh!
//      
//        init(_ parent: Rendering3DMTKViewWrapper) {
//            self.parent = parent
//            super.init()
//            self.setupMetal()
//            self.setupMesh()
//            self.setupPipeline()
//        }
//
//        func setupMetal() {
//            device = MTLCreateSystemDefaultDevice()
//            guard device != nil else {
//              fatalError("GPU is not supported")
//            }
//            
//            commandQueue = device.makeCommandQueue()
//            guard commandQueue != nil else {
//              fatalError("Could not create a command queue")
//            }
//            
//        }
//
//        func setupMesh() {
//            let allocator = MTKMeshBufferAllocator(device: device!)
//            let mdlMesh = MDLMesh(
//              coneWithExtent: [1, 1, 1],
//              segments: [10, 10],
//              inwardNormals: false,
//              cap: true,
//              geometryType: .triangles,
//              allocator: allocator)
//            
//            do {
//               mesh = try MTKMesh(mesh: mdlMesh, device: device!)
//            }
//            catch {
//                fatalError("Could not create Metal mesh")
//            }
//        }
//      
//        
//        func setupPipeline() {
//            let shader = """
//            #include <metal_stdlib>
//            using namespace metal;
//
//            struct VertexIn {
//              float4 position [[attribute(0)]];
//            };
//
//            vertex float4 vertex_main(const VertexIn vertex_in [[stage_in]]) {
//              return vertex_in.position;
//            }
//
//            fragment float4 fragment_main() {
//              return float4(1, 0, 0, 1);
//            }
//            """
//            
//              let library = try! device!.makeLibrary(source: shader, options: nil)
//              let vertexFunction = library.makeFunction(name: "vertex_main")
//              let fragmentFunction = library.makeFunction(name: "fragment_main")
//
//              let pipelineDescriptor = MTLRenderPipelineDescriptor()
//              pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
//              pipelineDescriptor.vertexFunction = vertexFunction
//              pipelineDescriptor.fragmentFunction = fragmentFunction
//
//              pipelineDescriptor.vertexDescriptor =
//                MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
//
//               pipelineState = try! device!.makeRenderPipelineState(descriptor: pipelineDescriptor)
//
//        }
//        
//        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//            
//        }
//
//      func draw(in view: MTKView) {
//        guard let commandBuffer = commandQueue.makeCommandBuffer(),
//          let renderPassDescriptor = view.currentRenderPassDescriptor,
//          let renderEncoder = commandBuffer.makeRenderCommandEncoder(
//            descriptor:  renderPassDescriptor)
//        else { return }
//
//        renderEncoder.setRenderPipelineState(pipelineState)
//
//        renderEncoder.setVertexBuffer(
//            mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
//        renderEncoder.setTriangleFillMode(.lines)
//
//          guard let submesh = mesh.submeshes.first else {
//            return
//          }
//        renderEncoder.drawIndexedPrimitives(
//          type: .triangle,
//          indexCount: submesh.indexCount,
//          indexType: submesh.indexType,
//          indexBuffer: submesh.indexBuffer.buffer,
//          indexBufferOffset: 0)
//
//        renderEncoder.endEncoding()
//        guard let drawable = view.currentDrawable else {
//             return
//        }
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//      }
//    }
//
//    func makeUIView(context: Context) -> MTKView {
//       let mtkView = MTKView()
//        mtkView.delegate = context.coordinator
//        mtkView.device = context.coordinator.device
//           mtkView.clearColor = MTLClearColor(red: 1,
//             green: 1, blue: 0.8, alpha: 1)
//
//        return mtkView
//    }
//
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        // update the view when any of the state variables change (none in this example)
//    }
//}
//
//// MARK: - Metal3DView
//struct Metal3DView: View {
//  var body: some View {
//      Rendering3DMTKViewWrapper()
//  }
//}
//
//// MARK: - Preview
//#Preview("Metal 3D View") {
//    Metal3DView()
//}
//
