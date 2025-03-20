//
//  PixelBuffer.swift
//  MyApp
//
//  Created by Cong Le on 3/20/25.
//



import Foundation
import CoreVideo
import simd

struct Size {
    let width: Int
    let height: Int
    
    var asFloat: simd_float2 {
        simd_float2(Float(width), Float(height))
    }
}

final class PixelBuffer<T> {
    let pixelBuffer: CVPixelBuffer
    let size: Size
    private let baseAddress: UnsafeMutablePointer<T>?
    
    init?(pixelBuffer: CVPixelBuffer) {
        self.pixelBuffer = pixelBuffer
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        self.baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)?.assumingMemoryBound(to: T.self)
        self.size = Size(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        
        if self.baseAddress == nil {
            return nil // Still fail initializer if base address cannot be obtained
        }
    }
    
    func value(x: Int, y: Int) -> T? { // Return an optional T
        guard let baseAddress = self.baseAddress else {
            return nil // Returns nil if baseAddress is nil
        }
        return baseAddress[y * size.width + x]
    }
}

