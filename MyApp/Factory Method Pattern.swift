////
////  Factory Method Pattern.swift
////  MyApp
////
////  Created by Cong Le on 10/29/24.
////
//
//import AVFoundation
//import UIKit
//import ImageIO
//
///// Protocol defining the compression strategy
//protocol ImageCompressionStrategy {
//    func compress(image: UIImage) -> Data?
//}
//
///// Concrete strategy for JPEG compression
//class JPEGCompression: ImageCompressionStrategy {
//    private let compressionQuality: Double
//    
//    init(compressionQuality: Double = 0.8) {
//        self.compressionQuality = compressionQuality
//    }
//    
//    func compress(image: UIImage) -> Data? {
//        return image.jpegData(compressionQuality: CGFloat(compressionQuality))
//    }
//}
//
///// Concrete strategy for PNG compression
//class PNGCompression: ImageCompressionStrategy {
//    func compress(image: UIImage) -> Data? {
//        return image.pngData()
//    }
//}
//
//
///// Concrete strategy for HEIC compression
//class HEICCompression: ImageCompressionStrategy {
//    func compress(image: UIImage) -> Data? {
//        guard let cgImage = image.cgImage else { return nil }
//        let heicData = NSMutableData()
//        guard let destination = CGImageDestinationCreateWithData(heicData, AVFileType.heic as CFString, 1, nil) else { return nil }
//        CGImageDestinationAddImage(destination, cgImage, nil)
//        guard CGImageDestinationFinalize(destination) else { return nil }
//        return heicData as Data
//    }
//}
//
///// Protocol defining the compression factory
//protocol CompressionFactory {
//    func createCompressionStrategy() -> ImageCompressionStrategy
//}
//
//
///// Factory for creating JPEGCompression
//class JPEGCompressionFactory: CompressionFactory {
//    func createCompressionStrategy() -> ImageCompressionStrategy {
//        return JPEGCompression()
//    }
//}
//
//
///// Factory for creating PNGCompression
//class PNGCompressionFactory: CompressionFactory {
//    func createCompressionStrategy() -> ImageCompressionStrategy {
//        return PNGCompression()
//    }
//}
//
///// Factory for creating HEICCompression
//class HEICCompressionFactory: CompressionFactory {
//    func createCompressionStrategy() -> ImageCompressionStrategy {
//        return HEICCompression()
//    }
//}
//
//
///// Context class that uses an ImageCompressionStrategy
//class ImageCompressor {
//    private var strategy: ImageCompressionStrategy
//    
//    init(strategy: ImageCompressionStrategy) {
//        self.strategy = strategy
//    }
//    
//    /// Allows changing the compression strategy at runtime
//    func setStrategy(strategy: ImageCompressionStrategy) {
//        self.strategy = strategy
//    }
//    
//    /// Compresses the provided image using the current strategy
//    func compress(image: UIImage) -> Data? {
//        return strategy.compress(image: image)
//    }
//}
//
//// MARK: - Usage Example
//
//// Example function to demonstrate usage
//func compressSampleImage() {
//    let image = UIImage(named: "sampleImage")! // I keep this force unwrap for documentation purpose
//    let compressionFactory: CompressionFactory = HEICCompressionFactory() // Could be JPEGCompressionFactory() or PNGCompressionFactory()
//    let compressionStrategy = compressionFactory.createCompressionStrategy()
//    let compressor = ImageCompressor(strategy: compressionStrategy)
//    
//    if let compressedData = compressor.compress(image: image) {
//        // Proceed with the compressed image data, e.g., saving to disk or uploading
//        print("Image compressed successfully, size: \(compressedData.count) bytes")
//    } else {
//        print("Failed to compress the image.")
//    }
//}
