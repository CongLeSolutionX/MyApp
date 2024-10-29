////
////  Factory Pattern.swift
////  MyApp
////
////  Created by Cong Le on 10/29/24.
////
//
//
//import AVFoundation
//import UIKit
//import ImageIO
//
//
//// MARK: - Strategy Protocol
//
//protocol ImageCompressionStrategy {
//    func compress(image: UIImage) -> Data?
//}
//
//// MARK: - Concrete Strategies
//
//class JPEGCompression: ImageCompressionStrategy {
//    private let compressionQuality: CGFloat
//    
//    init(compressionQuality: CGFloat = 0.8) {
//        self.compressionQuality = compressionQuality
//    }
//    
//    func compress(image: UIImage) -> Data? {
//        return image.jpegData(compressionQuality: compressionQuality)
//    }
//}
//
//class PNGCompression: ImageCompressionStrategy {
//    func compress(image: UIImage) -> Data? {
//        return image.pngData()
//    }
//}
//
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
//// MARK: - Compression Types
//
//enum CompressionType {
//    case jpeg
//    case png
//    case heic
//}
//
//// MARK: - Factory Class
//
//class CompressionFactory {
//    static func createCompressionStrategy(type: CompressionType) -> ImageCompressionStrategy {
//        switch type {
//        case .jpeg:
//            return JPEGCompression()
//        case .png:
//            return PNGCompression()
//        case .heic:
//            return HEICCompression()
//        }
//    }
//}
//
//// MARK: - Context Class
//
//class ImageCompressor {
//    private var strategy: ImageCompressionStrategy
//    
//    init(strategy: ImageCompressionStrategy) {
//        self.strategy = strategy
//    }
//    
//    func setStrategy(strategy: ImageCompressionStrategy) {
//        self.strategy = strategy
//    }
//    
//    func compress(image: UIImage) -> Data? {
//        return strategy.compress(image: image)
//    }
//}
//
//// MARK: - Usage Example
//
//// Example function to demonstrate usage
//func compressSampleImage() {
//    // Assume there's a UIImage named "sampleImage" in the project's assets
//    guard let image = UIImage(named: "sampleImage") else {
//        print("Image not found")
//        return
//    }
//    
//    // Specify the desired compression type (could be dynamically determined)
//    let compressionType: CompressionType = .heic
//    
//    // Create the appropriate compression strategy using the factory
//    let compressionStrategy = CompressionFactory.createCompressionStrategy(type: compressionType)
//    
//    // Initialize the compressor with the selected strategy
//    let compressor = ImageCompressor(strategy: compressionStrategy)
//    
//    // Compress the image
//    if let compressedData = compressor.compress(image: image) {
//        // Use the compressed data (e.g., save to disk, upload to server)
//        print("Image compressed successfully. Size: \(compressedData.count) bytes")
//    } else {
//        print("Image compression failed.")
//    }
//}
