//
//  Factory Patterns - Comprehensive  version.swift
//  MyApp
//
//  Created by Cong Le on 10/29/24.
//

import UIKit
import UniformTypeIdentifiers

// MARK: - Factory Pattern

/// Marker class for Factory Pattern
class FactoryPattern {}

/// Enumeration for Compression Types
enum CompressionType {
    case jpeg
    case png
    case heic
}

/// Protocol defining the Image Compression Strategy
protocol ImageCompressionStrategy {
    func compress(image: UIImage) -> Data?
}

/// Concrete Strategy for JPEG Compression
class JPEGCompression: ImageCompressionStrategy {
    func compress(image: UIImage) -> Data? {
        return image.jpegData(compressionQuality: 0.8)
    }
}

/// Concrete Strategy for PNG Compression
class PNGCompression: ImageCompressionStrategy {
    func compress(image: UIImage) -> Data? {
        return image.pngData()
    }
}

/// Concrete Strategy for HEIC Compression
class HEICCompression: ImageCompressionStrategy {
    func compress(image: UIImage) -> Data? {
        if #available(iOS 11.0, *) {
            return image.heicData(compressionQuality: 0.8)
        } else {
            // Fallback to JPEG for iOS versions below 11.0
            return image.jpegData(compressionQuality: 0.8)
        }
    }
}

/// Class responsible for processing images and validating data
class ImageProcessor {
    private let compressionStrategy: ImageCompressionStrategy
    private let dataValidator: DataValidator
    
    /// Initializes the ImageProcessor with specific strategies
    /// - Parameters:
    ///   - compressionStrategy: The strategy to use for image compression
    ///   - dataValidator: The validator to use for data validation
    init(compressionStrategy: ImageCompressionStrategy, dataValidator: DataValidator) {
        self.compressionStrategy = compressionStrategy
        self.dataValidator = dataValidator
    }
    
    /// Compresses the given image and validates the provided data
    /// - Parameters:
    ///   - image: The UIImage to compress
    ///   - data: The String data to validate
    /// - Returns: A tuple containing the compressed image data and the validation result
    func process(image: UIImage, data: String) -> (compressedData: Data?, isValid: Bool) {
        let compressedData = compressionStrategy.compress(image: image)
        let isValid = dataValidator.validate(data: data)
        return (compressedData, isValid)
    }
}

@available(iOS 11.0, *)
extension UIImage {
    /// Helper method to encode UIImage to HEIC Data
    func heicData(compressionQuality: CGFloat) -> Data? {
        guard let cgImage = self.cgImage else { return nil }
        let heicUTType = UTType.heic
        let destinationData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(destinationData, heicUTType.identifier as CFString, 1, nil) else {
            return nil
        }
        CGImageDestinationAddImage(destination, cgImage, [kCGImageDestinationLossyCompressionQuality: compressionQuality] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return destinationData as Data
    }
}

/// Factory class to create Image Compression Strategies
class CompressionFactory: FactoryPattern {
    func createCompressionStrategy(type: CompressionType) -> ImageCompressionStrategy {
        switch type {
        case .jpeg:
            return JPEGCompression()
        case .png:
            return PNGCompression()
        case .heic:
            return HEICCompression()
        }
    }
}

// MARK: - Factory Method Pattern

/// Marker class for Factory Method Pattern
class FactoryMethodPattern {}

/// Base Factory Method class for creating Image Compression Strategies
class CompressionFactoryMethod {
    func createCompressionStrategy() -> ImageCompressionStrategy {
        fatalError("This method should be overridden by subclasses.")
    }
}

/// Concrete Factory Method for JPEG Compression
class JPEGCompressionFactory: CompressionFactoryMethod {
    override func createCompressionStrategy() -> ImageCompressionStrategy {
        return JPEGCompression()
    }
}

/// Concrete Factory Method for PNG Compression
class PNGCompressionFactory: CompressionFactoryMethod {
    override func createCompressionStrategy() -> ImageCompressionStrategy {
        return PNGCompression()
    }
}

/// Concrete Factory Method for HEIC Compression
class HEICCompressionFactory: CompressionFactoryMethod {
    override func createCompressionStrategy() -> ImageCompressionStrategy {
        return HEICCompression()
    }
}

// MARK: - Abstract Factory Pattern

/// Marker class for Abstract Factory Pattern
class AbstractFactoryPattern {}

/// Protocol defining the Abstract Factory
protocol AbstractFactory {
    func createCompressionStrategy() -> ImageCompressionStrategy
    func createDataValidator() -> DataValidator
}

/// Protocol defining Data Validation
protocol DataValidator {
    func validate(data: String) -> Bool
}

/// Concrete Validator for Email
class EmailValidator: DataValidator {
    func validate(data: String) -> Bool {
        // Simple regex for email validation
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: data)
    }
}

/// Concrete Validator for Password
class PasswordValidator: DataValidator {
    func validate(data: String) -> Bool {
        // Example password validation: at least 8 characters
        return data.count >= 8
    }
}

/// Concrete Factory for Light Theme
class LightThemeFactory: AbstractFactory {
    func createCompressionStrategy() -> ImageCompressionStrategy {
        return JPEGCompression()
    }
    
    func createDataValidator() -> DataValidator {
        return EmailValidator()
    }
}

/// Concrete Factory for Dark Theme
class DarkThemeFactory: AbstractFactory {
    func createCompressionStrategy() -> ImageCompressionStrategy {
        return HEICCompression()
    }
    
    func createDataValidator() -> DataValidator {
        return PasswordValidator()
    }
}

// MARK: - Example Usage

func demoComprehensiveFactoryPatterns() {
    
    // Example Image (Placeholder)
    let exampleImage = UIImage(named: "sampleImage")

    // ------------------ Factory Pattern Usage ------------------
    let compressionFactory = CompressionFactory()
    let jpegStrategy = compressionFactory.createCompressionStrategy(type: .jpeg)
    if let jpegData = jpegStrategy.compress(image: exampleImage ?? UIImage()) {
        print("JPEG Compression Successful, Data Size: \(jpegData.count) bytes")
    }

    let pngStrategy = compressionFactory.createCompressionStrategy(type: .png)
    if let pngData = pngStrategy.compress(image: exampleImage ?? UIImage()) {
        print("PNG Compression Successful, Data Size: \(pngData.count) bytes")
    }

    // ------------------ Factory Method Pattern Usage ------------------
    let jpegFactoryMethod = JPEGCompressionFactory()
    let jpegStrategyMethod = jpegFactoryMethod.createCompressionStrategy()
    if let jpegDataMethod = jpegStrategyMethod.compress(image: exampleImage ?? UIImage()) {
        print("Factory Method - JPEG Compression Successful, Data Size: \(jpegDataMethod.count) bytes")
    }

    let pngFactoryMethod = PNGCompressionFactory()
    let pngStrategyMethod = pngFactoryMethod.createCompressionStrategy()
    if let pngDataMethod = pngStrategyMethod.compress(image: exampleImage ?? UIImage()) {
        print("Factory Method - PNG Compression Successful, Data Size: \(pngDataMethod.count) bytes")
    }

    // ------------------ Abstract Factory Pattern Usage ------------------
    let lightFactory: AbstractFactory = LightThemeFactory()
    let lightCompression = lightFactory.createCompressionStrategy()
    if let lightCompressedData = lightCompression.compress(image: exampleImage ?? UIImage()) {
        print("Abstract Factory - Light Theme Compression Successful, Data Size: \(lightCompressedData.count) bytes")
    }

    let lightValidator = lightFactory.createDataValidator()
    let isEmailValid = lightValidator.validate(data: "user@example.com")
    print("Light Theme Email Validation: \(isEmailValid)")

    let darkFactory: AbstractFactory = DarkThemeFactory()
    let darkCompression = darkFactory.createCompressionStrategy()
    if let darkCompressedData = darkCompression.compress(image: exampleImage ?? UIImage()) {
        print("Abstract Factory - Dark Theme Compression Successful, Data Size: \(darkCompressedData.count) bytes")
    }

    let darkValidator = darkFactory.createDataValidator()
    let isPasswordValid = darkValidator.validate(data: "password123")
    print("Dark Theme Password Validation: \(isPasswordValid)")

}

// MARK: - Example Usage with Dependency Injection

func demoDependencyInjection() {
    // Example Image (Placeholder)
    let exampleImage = UIImage(named: "sampleImage") ?? UIImage()
    
    // Using CompressionFactory to create strategies
    let compressionFactory = CompressionFactory()
    let jpegStrategy = compressionFactory.createCompressionStrategy(type: .jpeg)
    
    // Using LightThemeFactory to create validators
    let lightFactory: AbstractFactory = LightThemeFactory()
    let emailValidator = lightFactory.createDataValidator()
    
    // Inject dependencies into ImageProcessor
    let imageProcessor = ImageProcessor(compressionStrategy: jpegStrategy, dataValidator: emailValidator)
    
    // Process Image and Data
    let result = imageProcessor.process(image: exampleImage, data: "user@example.com")
    
    if let data = result.compressedData {
        print("Compression Successful, Data Size: \(data.count) bytes")
    }
    print("Data Validation Result: \(result.isValid)")
}
