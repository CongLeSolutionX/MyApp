//
//  Pixel.swift
//  MyApp
//
//  Created by Cong Le on 12/30/24.
//

import Foundation

/** Represents the memory address of a pixel. */
typealias PixelPointer = UnsafePointer<UInt8>

/** A point in an image converted to an ASCII character. */
struct Pixel
{
    /** The number of bytes a pixel occupies. 1 byte per channel (RGBA). */
    static let bytesPerPixel = 4
    
    fileprivate let offset: Int
    fileprivate init(_ offset: Int) { self.offset = offset }
    
    static func createPixelMatrix(_ width: Int, _ height: Int) -> [[Pixel]]
    {
        return (0..<height).map { row in
            (0..<width).map { col in
                let offset = (width * row + col) * Pixel.bytesPerPixel
                return Pixel(offset)
            }
        }
    }
    
    func intensityFromPixelPointer(_ pointer: PixelPointer) -> Double
    {
        let
        red   = pointer[offset + 0],
        green = pointer[offset + 1],
        blue  = pointer[offset + 2]
        return Pixel.calculateIntensity(red, green, blue)
    }
    
    fileprivate static func calculateIntensity(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> Double
    {
        // Normalize the pixel's grayscale value to between 0 and 1.
        // Weights from http://en.wikipedia.org/wiki/Grayscale#Luma_coding_in_video_systems
        let
        redWeight   = 0.229,
        greenWeight = 0.587,
        blueWeight  = 0.114,
        weightedMax = 255.0 * redWeight   +
                      255.0 * greenWeight +
                      255.0 * blueWeight,
        weightedSum = Double(r) * redWeight   +
                      Double(g) * greenWeight +
                      Double(b) * blueWeight
        return weightedSum / weightedMax
    }
}



//typealias PixelPointer = UnsafePointer<UInt8>
//
//struct Pixel {
//    static let bytesPerPixel = 4
//    private let offset: Int
//
//    private init(_ offset: Int) { // Make private
//        self.offset = offset
//    }
//
//    static func createPixelMatrix(width: Int, height: Int) -> [[Pixel]] {
//       (0..<height).map { row in
//           (0..<width).map { col in
//               Pixel((width * row + col) * Pixel.bytesPerPixel)
//           }
//       }
//    }
//    func intensityFromPixelPointer(_ pointer: PixelPointer) -> Double {
//        let red = pointer[offset]
//        let green = pointer[offset + 1]
//        let blue = pointer[offset + 2]
//        return Pixel.calculateIntensity(r: red, g: green, b: blue)
//    }
//
//    private static func calculateIntensity(r: UInt8, g: UInt8, b: UInt8) -> Double {
//        // Normalize pixel grayscale value to between 0 and 1.
//        // Weights from http://en.wikipedia.org/wiki/Grayscale#Luma_coding_in_video_systems
//        return 0.21 * Double(r) + 0.72 * Double(g) + 0.07 * Double(b) / 255.0 // Normalized
//    }
//}

