//
//  Abstract Factory Pattern.swift
//  MyApp
//
//  Created by Cong Le on 10/29/24.
//

import UIKit
import UniformTypeIdentifiers

// MARK: - Product Interfaces

/// Protocol defining the image compression strategy.
protocol ImageCompressionStrategy {
    func compress(image: UIImage) -> Data?
}

/// Protocol defining the data validator.
protocol DataValidator {
    func validate(data: String) -> Bool
}

// MARK: - Concrete Products

/// Concrete implementation of ImageCompressionStrategy for JPEG compression.
class JPEGCompression: ImageCompressionStrategy {
    private let compressionQuality: Double
    
    init(compressionQuality: Double = 0.8) {
        self.compressionQuality = compressionQuality
    }
    
    func compress(image: UIImage) -> Data? {
        return image.jpegData(compressionQuality: CGFloat(compressionQuality))
    }
}

/// Concrete implementation of ImageCompressionStrategy for HEIC compression.
class HEICCompression: ImageCompressionStrategy {
    func compress(image: UIImage) -> Data? {
        if #available(iOS 11.0, *) {
            return image.heicData(compressionQuality: 0.8)
        } else {
            // Fallback to JPEG if HEIC is not supported
            return image.jpegData(compressionQuality: 0.8)
        }
    }
}

/// Extension to UIImage to handle HEIC compression.
@available(iOS 11.0, *)
extension UIImage {
    func heicData(compressionQuality: CGFloat) -> Data? {
        return UIImage.heicData(from: self, compressionQuality: compressionQuality)
    }
    
    static func heicData(from image: UIImage, compressionQuality: CGFloat) -> Data? {
        guard let cgImage = image.cgImage else { return nil }
        let mutableData = CFDataCreateMutable(nil, 0)
        guard let destination = CGImageDestinationCreateWithData(mutableData!, UTType.heic.identifier as CFString, 1, nil) else {
            return nil
        }
        CGImageDestinationAddImage(destination, cgImage, [kCGImageDestinationLossyCompressionQuality: compressionQuality] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData as Data?
    }
}

/// Concrete implementation of DataValidator for validating email addresses.
class EmailValidator: DataValidator {
    func validate(data: String) -> Bool {
        // Simple regex for email validation
        let emailRegEx = "(?:[A-Z0-9a-z._%+-]+)@(?:[A-Z0-9a-z.-]+)\\.(?:[A-Za-z]{2,64})"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: data)
    }
}

/// Concrete implementation of DataValidator for validating passwords.
class PasswordValidator: DataValidator {
    func validate(data: String) -> Bool {
        // Example criteria: at least 8 characters, including a number and a special character
        let passwordRegEx = "^(?=.*[0-9])(?=.*[!@#$&*]).{8,}$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return predicate.evaluate(with: data)
    }
}

// MARK: - Abstract Factory Interface

/// Protocol defining the abstract factory.
protocol AbstractFactory {
    func createCompressionStrategy() -> ImageCompressionStrategy
    func createDataValidator() -> DataValidator
}

// MARK: - Concrete Factories

/// Concrete factory for creating components for the Light Theme.
class LightThemeFactory: AbstractFactory {
    func createCompressionStrategy() -> ImageCompressionStrategy {
        return JPEGCompression(compressionQuality: 0.7)
    }
    
    func createDataValidator() -> DataValidator {
        return EmailValidator()
    }
}

/// Concrete factory for creating components for the Dark Theme.
class DarkThemeFactory: AbstractFactory {
    func createCompressionStrategy() -> ImageCompressionStrategy {
        return HEICCompression()
    }
    
    func createDataValidator() -> DataValidator {
        return PasswordValidator()
    }
}

// MARK: - Usage Example

// Factory Selection based on Theme
enum Theme {
    case light
    case dark
}

class Client {
    private let factory: AbstractFactory
    private let compressionStrategy: ImageCompressionStrategy
    private let dataValidator: DataValidator
    
    init(theme: Theme) {
        switch theme {
        case .light:
            factory = LightThemeFactory()
        case .dark:
            factory = DarkThemeFactory()
        }
        compressionStrategy = factory.createCompressionStrategy()
        dataValidator = factory.createDataValidator()
    }
    
    func performOperations(with image: UIImage, data: String) {
        // Compress Image
        if let compressedData = compressionStrategy.compress(image: image) {
            print("Image compressed successfully. Size: \(compressedData.count) bytes")
        } else {
            print("Image compression failed.")
        }
        
        // Validate Data
        if dataValidator.validate(data: data) {
            print("Data is valid.")
        } else {
            print("Data is invalid.")
        }
    }
}

func compressSampleImage() {
    
    // Example Usage
    let sampleImage = UIImage(named: "sampleImage") // Assume a valid UIImage
    let sampleData = "user@example.com"
    let clientLight = Client(theme: .light)
    clientLight.performOperations(with: sampleImage ?? UIImage(), data: sampleData)

    let samplePassword = "P@ssw0rd!"
    let clientDark = Client(theme: .dark)
    clientDark.performOperations(with: sampleImage ?? UIImage(), data: samplePassword)

}
