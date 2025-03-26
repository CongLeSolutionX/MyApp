//
//  MetalTokyoBackgroundWithText.swift
//  MyApp
//
//  Created by Cong Le on 3/25/25.
//

import SwiftUI
import MetalKit

struct MetalTokyoBackgroundWithText: View {
    var body: some View {
        ZStack {
            MetalView(metalDevice: MTLCreateSystemDefaultDevice()!)
                .ignoresSafeArea()

            VStack {
                Text("TOKYO")
                    .font(.system(size: 50, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 5, x: 0, y: 2)

                Text("Showdown")
                    .font(.system(size: 30, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(.neonPink)
                    .shadow(color: .black, radius: 3, x: 0, y: 2)
            }
            .multilineTextAlignment(.center)
        }
    }
}

struct MetalView: UIViewRepresentable {
    let metalDevice: MTLDevice

    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView(frame: .zero, device: metalDevice)
        mtkView.delegate = context.coordinator
        mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = false // Ensure the view is continuously rendered
        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        // Update view properties if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MTKViewDelegate {
        let parent: MetalView
        var metalDevice: MTLDevice!
        var metalCommandQueue: MTLCommandQueue!
        var metalRenderPipelineState: MTLRenderPipelineState!

        init(_ parent: MetalView) {
            self.parent = parent
            metalDevice = parent.metalDevice
            metalCommandQueue = metalDevice.makeCommandQueue()!

            let shaderString = """
            #include <metal_stdlib>
            using namespace metal;

            struct VertexIn {
                float4 position [[attribute(0)]];
                float2 texCoord [[attribute(1)]];
            };

            struct VertexOut {
                float4 position [[position]];
                float2 texCoord;
            };

            vertex VertexOut vertexShader(VertexIn in [[stage_in]]) {
                VertexOut out;
                out.position = in.position;
                out.texCoord = in.texCoord;
                return out;
            }

            fragment half4 fragmentShader(VertexOut in [[stage_in]]) {
                // Simple gradient
                half red = in.texCoord.y;
                half green = 0.2;
                half blue = 0.5 + in.texCoord.x * 0.5;
                return half4(red, green, blue, 1.0);
            }
            """

            do {
                let metalCompiler = try metalDevice.makeLibrary(source: shaderString, options: nil)
                let vertexFunction = metalCompiler.makeFunction(name: "vertexShader")
                let fragmentFunction = metalCompiler.makeFunction(name: "fragmentShader")

                let pipelineDescriptor = MTLRenderPipelineDescriptor()
                pipelineDescriptor.vertexFunction = vertexFunction
                pipelineDescriptor.fragmentFunction = fragmentFunction
                pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

                let vertexDescriptor = MTLVertexDescriptor()
                vertexDescriptor.attributes[0].format = .float4
                vertexDescriptor.attributes[0].offset = 0
                vertexDescriptor.attributes[0].bufferIndex = 0
                vertexDescriptor.attributes[1].format = .float2
                vertexDescriptor.attributes[1].offset = 16
                vertexDescriptor.attributes[1].bufferIndex = 0
                vertexDescriptor.layouts[0].stride = 24

                pipelineDescriptor.vertexDescriptor = vertexDescriptor
                metalRenderPipelineState = try metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch {
                print("Error creating Metal pipeline state: \(error)")
            }
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            // Respond to drawable size changes
        }

        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable else { return }
            let renderPassDescriptor = view.currentRenderPassDescriptor!

            let commandBuffer = metalCommandQueue.makeCommandBuffer()!
            let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
            renderCommandEncoder.setRenderPipelineState(metalRenderPipelineState)

            // Vertex data for a quad
            let vertices: [Float] = [
                -1.0, -1.0, 0.0, 1.0, 0.0, 0.0,
                 1.0, -1.0, 0.0, 1.0, 1.0, 0.0,
                -1.0,  1.0, 0.0, 1.0, 0.0, 1.0,
                 1.0,  1.0, 0.0, 1.0, 1.0, 1.0
            ]

            let vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Float>.size, options: [])!
            renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

            renderCommandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)

            renderCommandEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

extension Color {
    static let neonPink = Color(red: 1.0, green: 0.3, blue: 0.8)
}

#Preview {
    MetalTokyoBackgroundWithText()
}
