//
//  AsciiPalette.swift
//  MyApp
//
//  Created by Cong Le on 12/30/24.
//

import Foundation
import UIKit

/** Provides a list of ASCII symbols sorted from darkest to brightest. */
class AsciiPalette
{
    fileprivate let font: UIFont
    
    init(font: UIFont) { self.font = font }
    
    lazy var symbols: [String] = self.loadSymbols()
    
    fileprivate func loadSymbols() -> [String]
    {
        return symbolsSortedByIntensityForAsciiCodes(32...126) // from ' ' to '~'
    }
    
    fileprivate func symbolsSortedByIntensityForAsciiCodes(_ codes: CountableClosedRange<Int>) -> [String]
    {
        let
        symbols          = codes.map { self.symbolFromAsciiCode($0) },
        symbolImages     = symbols.map { UIImage.imageOfSymbol($0, self.font) },
        whitePixelCounts = symbolImages.map { self.countWhitePixelsInImage($0) },
        sortedSymbols    = sortByIntensity(symbols, whitePixelCounts)
        return sortedSymbols
    }
    
    fileprivate func symbolFromAsciiCode(_ code: Int) -> String
    {
        return String(Character(UnicodeScalar(code)!))
    }
    
    fileprivate func countWhitePixelsInImage(_ image: UIImage) -> Int
    {
        let
        dataProvider = image.cgImage?.dataProvider,
        pixelData    = dataProvider?.data,
        pixelPointer = CFDataGetBytePtr(pixelData),
        byteCount    = CFDataGetLength(pixelData),
        pixelOffsets = stride(from: 0, to: byteCount, by: Pixel.bytesPerPixel)
        return pixelOffsets.reduce(0) { (count, offset) -> Int in
            let
            r = pixelPointer?[offset + 0],
            g = pixelPointer?[offset + 1],
            b = pixelPointer?[offset + 2],
            isWhite = (r == 255) && (g == 255) && (b == 255)
            return isWhite ? count + 1 : count
        }
    }
    
    fileprivate func sortByIntensity(_ symbols: [String], _ whitePixelCounts: [Int]) -> [String]
    {
        let
        mappings      = NSDictionary(objects: symbols, forKeys: whitePixelCounts as [NSCopying]),
        uniqueCounts  = Set(whitePixelCounts),
        sortedCounts  = uniqueCounts.sorted(),
        sortedSymbols = sortedCounts.map { mappings[$0] as! String }
        return sortedSymbols
    }
}


//class AsciiPalette {
//    private let font: UIFont
//    private(set) var symbols: [String] = [] // Private(set)
//
//    init(font: UIFont) {
//        self.font = font
//        symbols = loadSymbols()
//    }
//
//    private func loadSymbols() -> [String] {  // Make private
//        symbolsSortedByIntensityForAsciiCodes(32...126)  // Printable ASCII
//    }
//
//
//    private func symbolsSortedByIntensityForAsciiCodes(_ codes: ClosedRange<Int>) -> [String] {
//        var symbolsWithCounts: [(String, Int)] = [] // Store symbols and counts together
//        for code in codes {
//            guard let symbol = symbolFromAsciiCode(code) else {
//                continue  // Skip invalid codes
//            }
//            let image = UIImage.imageOfSymbol(symbol, font)
//            let whitePixels = countWhitePixelsInImage(image)
//            symbolsWithCounts.append((symbol, whitePixels))
//        }
//        symbolsWithCounts.sort { $0.1 < $1.1 } // Sort by count
//        return symbolsWithCounts.map { $0.0 } // Return sorted symbols
//    }
//
//
//
//
//    private func symbolFromAsciiCode(_ code: Int) -> String? {  // Make private, optional return
//        guard let unicodeScalar = UnicodeScalar(code) else {
//            return nil  // Return nil for invalid codes
//        }
//        return String(unicodeScalar)
//    }
//
//
//    private func countWhitePixelsInImage(_ image: UIImage) -> Int { // Make private
//        guard let cgImage = image.cgImage,
//              let dataProvider = cgImage.dataProvider,
//              let data = dataProvider.data,
//              let pixelPointer = CFDataGetBytePtr(data)
//        else { return 0 }
//
//        let byteCount = CFDataGetLength(data)
//
//        var whitePixelCount = 0
//        for offset in stride(from: 0, to: byteCount, by: Pixel.bytesPerPixel) {
//            if pixelPointer[offset] == 255,
//               pixelPointer[offset + 1] == 255,
//               pixelPointer[offset + 2] == 255 {
//                whitePixelCount += 1
//            }
//        }
//
//        return whitePixelCount
//    }
//
//    func symbolFromIntensity(_ intensity: Double) -> String {
//         let clampedIntensity = max(0.0, min(1.0, intensity))
//         let index = Int(clampedIntensity * Double(symbols.count - 1))
//         return symbols[index]
//    }
//}
