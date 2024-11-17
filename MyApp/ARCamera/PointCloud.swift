//
//  PointCloud.swift
//  MyApp
//
//  Created by Cong Le on 11/17/24.
//

import Foundation
import ARKit
import SceneKit

actor PointCloud {
    
    func process(frame: ARFrame) async {
        guard let depth = (frame.smoothedSceneDepth ?? frame.sceneDepth),
              let depthBuffer = PixelBuffer<Float32>(pixelBuffer: depth.depthMap),
              let confidenceMap = depth.confidenceMap,
              let confidenceBuffer = PixelBuffer<UInt8>(pixelBuffer: confidenceMap),
              let imageBuffer = YCBCRBuffer(pixelBuffer: frame.capturedImage) else { return }
        
        for row in 0..<depthBuffer.size.height {
            for col in 0..<depthBuffer.size.width {
                // Safe Unwrapping for confidenceRawValue
                guard let confidenceRawValue = confidenceBuffer.value(x: col, y: row) else {
                    // Handle the case where confidenceRawValue is nil, perhaps skip this iteration or log a warning
                    print("Warning: confidence value is nil at col \(col), row \(row)")
                    continue
                }
                
                // Now you can use confidenceRawValue as UInt8 safely as it's successfully unwrapped
                let confidence = ARConfidenceLevel(rawValue: Int(confidenceRawValue))
                guard confidence == .high else { continue }
                
                
                // Assuming depthBuffer.value(x: col, y: row) now returns Float32? if you made changes there as well
                guard let depth = depthBuffer.value(x: col, y: row) else {
                    // Handle the case where depth is nil, e.g., skip processing this pixel
                    print("Warning: depth value is nil at col \(col), row \(row)")
                    continue
                }
                
                if depth > 2 { continue }
                
                let normalizedCoord = simd_float2(Float(col) / Float(depthBuffer.size.width), Float(row) / Float(depthBuffer.size.height))
                let imageSize = imageBuffer.size.asFloat
                let pixelRow = Int(round(normalizedCoord.y * imageSize.y))
                let pixelColumn = Int(round(normalizedCoord.x * imageSize.x))
                let color = imageBuffer.color(x: pixelColumn, y: pixelRow)
                
                let screenPoint = simd_float3(normalizedCoord * imageSize, 1)
                let localPoint = simd_inverse(frame.camera.intrinsics) * screenPoint * depth
                let rotateToARCamera = makeRotateToARCameraMatrix(orientation: .portrait)
                let cameraTransform = frame.camera.viewMatrix(for: .portrait).inverse * rotateToARCamera
                let worldPoint = cameraTransform * simd_float4(localPoint, 1)
                let resultPosition = SCNVector3(worldPoint.x / worldPoint.w, worldPoint.y / worldPoint.w, worldPoint.z / worldPoint.w)
                
                print("Point: \(resultPosition), Color: \(color)")
            }
        }
    }
    
    private func makeRotateToARCameraMatrix(orientation: UIInterfaceOrientation) -> matrix_float4x4 {
        let flipYZ = matrix_float4x4([1, 0, 0, 0], [0, -1, 0, 0], [0, 0, -1, 0], [0, 0, 0, 1])
        let rotationAngle: Float = {
            switch orientation {
            case .landscapeLeft: return .pi
            case .portrait: return .pi / 2
            case .portraitUpsideDown: return -.pi / 2
            default: return 0
            }
        }()
        let quaternion = simd_quaternion(rotationAngle, simd_float3(0, 0, 1))
        let rotationMatrix = matrix_float4x4(quaternion)
        return flipYZ * rotationMatrix
    }
}

struct Vertex {
    let position: SCNVector3
    let color: simd_float4
}
