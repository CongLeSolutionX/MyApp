//
//  Rendering3DMushroomMetalView.swift
//  MyApp
//
//  Created by Cong Le on 12/13/24.
//
import SwiftUI
import MetalKit

// 1. MetalView: A SwiftUI view that hosts the MTKView
struct MetalView: UIViewRepresentable {
    @Binding var showLines: Bool

    func makeUIView(context: Context) -> MTKView {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU is not supported")
        }

        let mtkView = MTKView(frame: .zero, device: device)
        mtkView.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)

        // Use coordinator to manage the Metal rendering
        context.coordinator.configure(mtkView: mtkView)
        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        // This line ensures that changes to `showLines` in SwiftUI updates the Coordinator,
        // by passing the value bound via the closure on its initial instantiation
        context.coordinator.updateRendering(with: showLines)
        // The following line is not needed since the above is doing the job of updating.
        // context.coordinator.showLines = showLines // Removed this line
    }

    func makeCoordinator() -> Coordinator {
        // Modified closure to propagate changes from binding
        Coordinator(showLines: _showLines)
    }
}

// 2. Coordinator: Manages Metal drawing logic
class Coordinator: NSObject {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var mesh: MTKMesh!
     var dynamic_showLines: Bool //Store current updated lineStatus for rendering

    // Use @Binding to update view on status changes
    @Binding var showLines: Bool

    init(showLines: Binding<Bool>) {
        self._showLines = showLines // Store the binding from the UIViewRepresentable
        self.dynamic_showLines = showLines.wrappedValue
    }

    func configure(mtkView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU is not supported")
        }
        self.device = device

        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Could not create a command queue")
        }
        self.commandQueue = commandQueue

        setupMesh()
        setupPipeline(mtkView: mtkView)
        mtkView.delegate = self
    }

    private func setupMesh() {
        let allocator = MTKMeshBufferAllocator(device: device)

        guard let assetURL = Bundle.main.url(
            forResource: "mushroom",
            withExtension: "usdz") else {
            fatalError()
        }

        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0

        vertexDescriptor.layouts[0].stride =
            MemoryLayout<SIMD3<Float>>.stride
        let meshDescriptor =
            MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        (meshDescriptor.attributes[0] as! MDLVertexAttribute).name =
            MDLVertexAttributePosition

        let asset = MDLAsset(
            url: assetURL,
            vertexDescriptor: meshDescriptor,
            bufferAllocator: allocator)

        let mdlMesh =
            asset.childObjects(of: MDLMesh.self).first as! MDLMesh

        do {
            mesh = try MTKMesh(mesh: mdlMesh, device: device)
        } catch {
            fatalError("Could not create MTKMesh")
        }
    }

    private func setupPipeline(mtkView: MTKView) {
        let shader = """
        #include <metal_stdlib>
        using namespace metal;

        struct VertexIn {
          float4 position [[attribute(0)]];
        };

        vertex float4 vertex_main(const VertexIn vertex_in [[stage_in]]) {
          float4 position = vertex_in.position;
          position.y -= 0.5;
          return position;
        }

        fragment float4 fragment_main() {
          return float4(1, 0, 0, 1);
        }
        """

        do {
            let library = try device.makeLibrary(source: shader, options: nil)
            if let vertexFunction = library.makeFunction(name: "vertex_main"),
               let fragmentFunction = library.makeFunction(name: "fragment_main") {
                let pipelineDescriptor = MTLRenderPipelineDescriptor()
                pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
                pipelineDescriptor.vertexFunction = vertexFunction
                pipelineDescriptor.fragmentFunction = fragmentFunction
                pipelineDescriptor.vertexDescriptor =
                    MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)

                pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } else {
                fatalError("Could not create shader functions")
            }
        } catch {
            fatalError("Could not create shader library")
        }
    }

    //Accepts the status to update
    func updateRendering(with updatedStatus:Bool){

            self.dynamic_showLines = updatedStatus
    }
}

// 3. MTKViewDelegate: Rendering logic
extension Coordinator: MTKViewDelegate {
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else { return }

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(
            mesh.vertexBuffers[0].buffer, offset: 0, index: 0)

        if dynamic_showLines {
            renderEncoder.setTriangleFillMode(.lines)

        } else {
             renderEncoder.setTriangleFillMode(.fill)
        }

        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: submesh.indexCount,
                indexType: submesh.indexType,
                indexBuffer: submesh.indexBuffer.buffer,
                indexBufferOffset: submesh.indexBuffer.offset
            )
        }

        renderEncoder.endEncoding()

        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Handle resize if needed
    }
}

// 4. ContentView: Example usage
struct ContentView: View {
    @State private var showLines = false

    var body: some View {
        VStack {
            Toggle("show lines", isOn: $showLines)
                .padding()
            MetalView(showLines: $showLines)
        }
    }
}

#Preview {
    ContentView()
}
