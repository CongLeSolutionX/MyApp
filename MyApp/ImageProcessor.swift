//
//  ImageProcessor.swift
//  MyApp
//
//  Created by Cong Le on 10/15/24.
//

import UIKit

/**
 Defines the interface for image compression strategies.  This protocol ensures that all concrete strategies adhere to a consistent method signature.
 */
protocol ImageCompressionStrategy {
    /// Compresses the given image and returns the compressed data or an error.
    /// - Parameter image: The `UIImage` to compress.
    /// - Returns: A `Result<Data, Error>` containing the compressed image data on success, or an `Error` on failure.
    func compress(image: UIImage) -> Result<Data, Error>
}

/**
 Implements JPEG compression strategy. Conforms to the `ImageCompressionStrategy` protocol.
 */
class JPEGCompression: ImageCompressionStrategy {
    
    /// Compresses the input image using JPEG compression with a quality of 0.8.
    /// - Parameter image: The `UIImage` to be compressed.
    /// - Returns: A `Result<Data, Error>` containing the compressed JPEG data or an error if compression fails.
    func compress(image: UIImage) -> Result<Data, Error> {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return .failure(NSError(domain: "JPEGCompression", code: 0, userInfo: [NSLocalizedDescriptionKey: "JPEG compression failed"]))
        }
        return .success(data)
    }
}

/**
 Implements PNG compression strategy. Conforms to the `ImageCompressionStrategy` protocol.
 */
class PNGCompression: ImageCompressionStrategy {
    
    /// Compresses the input image using PNG compression.
    /// - Parameter image: The `UIImage` to be compressed.
    /// - Returns: A `Result<Data, Error>` containing the compressed PNG data or an error if compression fails.
    func compress(image: UIImage) -> Result<Data, Error> {
        guard let data = image.pngData() else {
            return .failure(NSError(domain: "PNGCompression", code: 0, userInfo: [NSLocalizedDescriptionKey: "PNG compression failed"]))
        }
        return .success(data)
    }
}



// MARK: - Context Class
/**
 The context class that uses a concrete strategy to compress images.  Manages the currently selected compression strategy.
 */
class ImageProcessor {
    /// The currently selected image compression strategy.
    var compressionStrategy: ImageCompressionStrategy

    /**
     Initializes the `ImageProcessor` with a specific compression strategy.
     - Parameter compressionStrategy: The initial `ImageCompressionStrategy` to use.
     */
    init(compressionStrategy: ImageCompressionStrategy) {
        self.compressionStrategy = compressionStrategy
    }

    /**
     Processes the given image using the currently assigned compression strategy.
     - Parameter image: The `UIImage` to process.
     - Returns: A `Result<Data, Error>` containing the compressed image data or an error if processing fails.
     */
    func processImage(image: UIImage) -> Result<Data, Error> {
        return compressionStrategy.compress(image: image)
    }

    /**
     Sets a new compression strategy for the image processor.
     - Parameter strategy: The new `ImageCompressionStrategy` to use.
     */
    func setCompressionStrategy(strategy: ImageCompressionStrategy) {
        self.compressionStrategy = strategy
    }
}

/**
 Represents the available image compression types. Used for selecting the appropriate strategy.
 Conforms to `CaseIterable` and `RawRepresentable` for easy iteration and string conversion.
 */
enum CompressionType: CaseIterable, RawRepresentable {
    case jpeg, png

    typealias RawValue = String
    
    /// The string representation of the compression type.
    var rawValue: String {
        switch self {
        case .jpeg: return "jpeg"
        case .png: return "png"
        }
    }

    /**
     Initializes a `CompressionType` from a raw string value.
     - Parameter rawValue: The string representation of the compression type.
     */
    init?(rawValue: String) {
        switch rawValue {
        case "jpeg": self = .jpeg
        case "png": self = .png
        default: return nil
        }
    }
}

// MARK: - Strategy Factory (Advanced Usage)
/**
 A factory struct responsible for creating concrete `ImageCompressionStrategy` instances based on a given `CompressionType`.
*/
struct CompressionStrategyFactory {
    
    /**
     Creates and returns an `ImageCompressionStrategy` based on the specified compression type.
     - Parameter type: The `CompressionType` indicating the desired strategy.
     - Returns: An optional `ImageCompressionStrategy` instance. Returns `nil` if the compression type is not supported.
     */
    static func createStrategy(for type: CompressionType) -> ImageCompressionStrategy? {
        switch type {
        case .jpeg: return JPEGCompression()
        case .png: return PNGCompression()
        }
    }
}

