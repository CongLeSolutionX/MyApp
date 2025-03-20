//
//  YCBCRBuffer.swift
//  MyApp
//
//  Created by Cong Le on 3/20/25.
//


import Foundation
import CoreVideo
import simd

final class YCBCRBuffer {
    let pixelBuffer: CVPixelBuffer
    let size: Size
    
    private let yPlane: UnsafeMutableRawPointer
    private let cbCrPlane: UnsafeMutableRawPointer
    
    init?(pixelBuffer: CVPixelBuffer) {
        self.pixelBuffer = pixelBuffer
        
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        }
        
        guard let yAddr = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0),
              let cbCrAddr = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1) else {
            return nil
        }
        
        yPlane = yAddr
        cbCrPlane = cbCrAddr
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        size = Size(width: width, height: height)
    }
    
    func color(x: Int, y: Int) -> simd_float4 {
        let offset = y * CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0) + x // For Y plane
        let yValue = yPlane.load(fromByteOffset: offset, as: UInt8.self)
        
        let cbCrOffset = (y / 2) * CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1) + (x / 2) * 2 // For CbCr plane, each pixel is 2 bytes
        let cbValue = cbCrPlane.load(fromByteOffset: cbCrOffset, as: UInt8.self)
        let crValue = cbCrPlane.load(fromByteOffset: cbCrOffset + 1, as: UInt8.self)
        
        // Now, convert YCbCr to RGB
        return ycbcrToRGB(y: Float(yValue), cb: Float(cbValue), cr: Float(crValue))
    }
    
    private func ycbcrToRGB(y: Float, cb: Float, cr: Float) -> simd_float4 {
        let r = 1.16438 * (y - 16) + 1.59603 * (cr - 128)
        let g = 1.16438 * (y - 16) - 0.81297 * (cr - 128) - 0.39176 * (cb - 128)
        let b = 1.16438 * (y - 16) + 2.01723 * (cb - 128)
        
        return simd_float4(Float(r) / 255.0, Float(g) / 255.0, Float(b) / 255.0, 1.0)
    }
}
