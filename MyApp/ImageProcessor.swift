//
//  ImageProcessor.swift
//  MyApp
//
//  Created by Cong Le on 10/15/24.
//

import UIKit


// MARK: - Strategy Protocol
protocol ImageCompressionStrategy {
    func compress(image: UIImage) -> Result<Data, Error>
}

// MARK: - Concrete Strategies
class JPEGCompression: ImageCompressionStrategy {
    func compress(image: UIImage) -> Result<Data, Error> {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return .failure(NSError(domain: "JPEGCompression", code: 0, userInfo: [NSLocalizedDescriptionKey: "JPEG compression failed"]))
        }
        return .success(data)
    }
}

class PNGCompression: ImageCompressionStrategy {
    func compress(image: UIImage) -> Result<Data, Error> {
        guard let data = image.pngData() else {
            return .failure(NSError(domain: "PNGCompression", code: 0, userInfo: [NSLocalizedDescriptionKey: "PNG compression failed"]))
        }
        return .success(data)
    }
}



// MARK: - Context Class
class ImageProcessor {
    var compressionStrategy: ImageCompressionStrategy
    
    // Using constructor injection to provide the strategy to the context
    init(compressionStrategy: ImageCompressionStrategy) {
        self.compressionStrategy = compressionStrategy
    }

    func processImage(image: UIImage) -> Result<Data, Error> {
        return compressionStrategy.compress(image: image)
    }

    func setCompressionStrategy(strategy: ImageCompressionStrategy) {
        self.compressionStrategy = strategy
    }
}

// MARK: - Compression Type Enum (for Strategy Selection)
enum CompressionType: CaseIterable, RawRepresentable {
    case jpeg, png

    typealias RawValue = String
    var rawValue: String {
        switch self {
        case .jpeg: return "jpeg"
        case .png: return "png"
        }
    }

    init?(rawValue: String) {
        switch rawValue {
        case "jpeg": self = .jpeg
        case "png": self = .png
        default: return nil
        }
    }
}

// MARK: - Strategy Factory (Advanced Usage)
struct CompressionStrategyFactory {
    static func createStrategy(for type: CompressionType) -> ImageCompressionStrategy? {
        switch type {
        case .jpeg: return JPEGCompression()
        case .png: return PNGCompression()
        }
    }
}
