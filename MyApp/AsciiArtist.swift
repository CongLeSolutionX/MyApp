//
//  AsciiArtist.swift
//  MyApp
//
//  Created by Cong Le on 12/30/24.
//

import Foundation
import UIKit

/** Transforms an image to ASCII art. */
class AsciiArtist
{
    fileprivate let
    image:   UIImage,
    palette: AsciiPalette
    
    init(_ image: UIImage, _ palette: AsciiPalette)
    {
        self.image   = image
        self.palette = palette
    }
    
    func createAsciiArt() -> String
    {
        let
        dataProvider = image.cgImage?.dataProvider,
        pixelData    = dataProvider?.data,
        pixelPointer = CFDataGetBytePtr(pixelData),
        intensities  = intensityMatrixFromPixelPointer(pixelPointer!),
        symbolMatrix = symbolMatrixFromIntensityMatrix(intensities)
        return symbolMatrix.joined(separator: "\n")
    }
    
    fileprivate func intensityMatrixFromPixelPointer(_ pointer: PixelPointer) -> [[Double]]
    {
        let
        width  = Int(image.size.width),
        height = Int(image.size.height),
        matrix = Pixel.createPixelMatrix(width, height)
        return matrix.map { pixelRow in
            pixelRow.map { pixel in
                pixel.intensityFromPixelPointer(pointer)
            }
        }
    }
    
    fileprivate func symbolMatrixFromIntensityMatrix(_ matrix: [[Double]]) -> [String]
    {
        return matrix.map { intensityRow in
            intensityRow.reduce("") {
                $0 + self.symbolFromIntensity($1)
            }
        }
    }
    
    fileprivate func symbolFromIntensity(_ intensity: Double) -> String
    {
        assert(0.0 <= intensity && intensity <= 1.0)
        
        let
        factor = palette.symbols.count - 1,
        value  = round(intensity * Double(factor)),
        index  = Int(value)
        return palette.symbols[index]
    }
}

//class AsciiArtist {
//    private let image: UIImage
//    private let palette: AsciiPalette
//
//    init(_ image: UIImage, _ palette: AsciiPalette) {
//        self.image = image
//        self.palette = palette
//    }
//
//
//    func createAsciiArt() -> String {
//        guard let cgImage = image.cgImage,
//              let dataProvider = cgImage.dataProvider,
//              let data = dataProvider.data,
//              let pixelPointer = CFDataGetBytePtr(data) else { return "" }
//
//        let intensityMatrix = intensityMatrixFromPixelPointer(pixelPointer)
//        let symbolMatrix = self.symbolMatrixFromIntensityMatrix(intensityMatrix)
//        return symbolMatrix.joined(separator: "\n")
//    }
//
//
//
//    private func intensityMatrixFromPixelPointer(_ pointer: PixelPointer) -> [[Double]] {
//        let width = Int(image.size.width)
//        let height = Int(image.size.height)
//        let pixelMatrix = Pixel.createPixelMatrix(width: width, height: height)
//        return pixelMatrix.map { $0.map { $0.intensityFromPixelPointer(pointer) } }
//    }
//
//
//    private func symbolMatrixFromIntensityMatrix(_ matrix: [[Double]]) -> [String] {
//        matrix.map { $0.map { self.symbolFromIntensity($0) }.joined() }
//    }
//
//
//    private func symbolFromIntensity(_ intensity: Double) -> String {
//        palette.symbolFromIntensity(intensity)
//    }
//}
