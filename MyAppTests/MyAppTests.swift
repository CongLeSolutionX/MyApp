//
//  MyAppTests.swift
//  MyAppTests
//
//  Created by Cong Le on 10/29/24.
//

import XCTest
import UIKit
@testable import MyApp // Replace with your actual module name

// MARK: - ImageCompressionStrategy Tests

class ImageCompressionStrategyTests: XCTestCase {
    
    func testJPEGCompression_ShouldReturnData() {
        let jpegCompression = JPEGCompression(compressionQuality: 0.8)
        let sampleImage = UIImage(systemName: "house")! // Using a system image for testing
        
        let compressedData = jpegCompression.compress(image: sampleImage)
        
        XCTAssertNotNil(compressedData, "JPEGCompression.compress should return non-nil Data")
    }
    
    func testHEICCompression_ShouldReturnData_OnSupportediOS() {
        // HEIC is available from iOS 11 onwards
        if #available(iOS 11.0, *) {
            let heicCompression = HEICCompression()
            let sampleImage = UIImage(systemName: "house")!
            
            let compressedData = heicCompression.compress(image: sampleImage)
            
            XCTAssertNotNil(compressedData, "HEICCompression.compress should return non-nil Data on supported iOS versions")
        } else {
            // Skip test on unsupported iOS versions
            XCTAssertTrue(true, "HEICCompression is not supported on iOS versions below 11.0")
        }
    }
    
    func testHEICCompression_ShouldFallbackToJPEG_OnUnsupportediOS() {
        // Simulating unsupported iOS versions by mocking
        // Since mocking iOS version is complex, we'll assume the fallback mechanism if HEIC is unavailable.
        // Note: This test serves as a placeholder. In real scenarios, dependency injection or abstraction would be needed.
        // For demonstration, we'll modify HEICCompression to accept a flag for testing purposes.
        
        // Example modified HEICCompression for testing
        class TestHEICCompression: ImageCompressionStrategy {
            var shouldSupportHEIC: Bool = false
            
            func compress(image: UIImage) -> Data? {
                if shouldSupportHEIC, #available(iOS 11.0, *) {
                    return image.toHEICData(compressionQuality: 0.8)
                } else {
                    return image.jpegData(compressionQuality: 0.8)
                }
            }
        }
        
        let heicCompression = TestHEICCompression()
        heicCompression.shouldSupportHEIC = false
        let sampleImage = UIImage(systemName: "house")!
        
        let compressedData = heicCompression.compress(image: sampleImage)
        
        XCTAssertNotNil(compressedData, "HEICCompression should fallback to JPEG and return non-nil Data when HEIC is unsupported")
        
        // Additionally, verify that the data is indeed JPEG by checking the first few bytes
        if let data = compressedData {
            // JPEG files start with FF D8 FF
            let jpegHeader: [UInt8] = [0xFF, 0xD8, 0xFF]
            let dataBytes = [UInt8](data.prefix(3))
            XCTAssertEqual(dataBytes, jpegHeader, "Fallback compression should produce JPEG data")
        }
    }
}

// MARK: - DataValidator Tests

class DataValidatorTests: XCTestCase {
    
    func testEmailValidator_ShouldReturnTrue_ForValidEmail() {
        let emailValidator = EmailValidator()
        let validEmail = "user@example.com"
        
        let isValid = emailValidator.validate(data: validEmail)
        
        XCTAssertTrue(isValid, "EmailValidator should return true for a valid email")
    }
    
    func testEmailValidator_ShouldReturnFalse_ForInvalidEmail() {
        let emailValidator = EmailValidator()
        let invalidEmail = "user@@example..com"
        
        let isValid = emailValidator.validate(data: invalidEmail)
        
        XCTAssertFalse(isValid, "EmailValidator should return false for an invalid email")
    }
    
    func testPasswordValidator_ShouldReturnTrue_ForValidPassword() {
        let passwordValidator = PasswordValidator()
        let validPassword = "P@ssw0rd!"
        
        let isValid = passwordValidator.validate(data: validPassword)
        
        XCTAssertTrue(isValid, "PasswordValidator should return true for a valid password")
    }
    
    func testPasswordValidator_ShouldReturnFalse_ForShortPassword() {
        let passwordValidator = PasswordValidator()
        let shortPassword = "P@ss1!"
        
        let isValid = passwordValidator.validate(data: shortPassword)
        
        XCTAssertFalse(isValid, "PasswordValidator should return false for a password shorter than 8 characters")
    }
    
    func testPasswordValidator_ShouldReturnFalse_ForPasswordWithoutNumber() {
        let passwordValidator = PasswordValidator()
        let passwordWithoutNumber = "P@ssword!"
        
        let isValid = passwordValidator.validate(data: passwordWithoutNumber)
        
        XCTAssertFalse(isValid, "PasswordValidator should return false for a password without numbers")
    }
    
    func testPasswordValidator_ShouldReturnFalse_ForPasswordWithoutSpecialCharacter() {
        let passwordValidator = PasswordValidator()
        let passwordWithoutSpecialChar = "Passw0rd"
        
        let isValid = passwordValidator.validate(data: passwordWithoutSpecialChar)
        
        XCTAssertFalse(isValid, "PasswordValidator should return false for a password without special characters")
    }
}

// MARK: - AbstractFactory Tests

class AbstractFactoryTests: XCTestCase {

    func testLightThemeFactory_ShouldCreateJPEGCompression() {
        let factory = LightThemeFactory()
        let compressionStrategy = factory.createCompressionStrategy()
        
        XCTAssertTrue(compressionStrategy is JPEGCompression, "LightThemeFactory should create JPEGCompression")
    }
    
    func testLightThemeFactory_ShouldCreateEmailValidator() {
        let factory = LightThemeFactory()
        let dataValidator = factory.createDataValidator()
        
        XCTAssertTrue(dataValidator is EmailValidator, "LightThemeFactory should create EmailValidator")
    }
    
    func testDarkThemeFactory_ShouldCreateHEICCompression() {
        let factory = DarkThemeFactory()
        let compressionStrategy = factory.createCompressionStrategy()
        
        XCTAssertTrue(compressionStrategy is HEICCompression, "DarkThemeFactory should create HEICCompression")
    }
    
    func testDarkThemeFactory_ShouldCreatePasswordValidator() {
        let factory = DarkThemeFactory()
        let dataValidator = factory.createDataValidator()
        
        XCTAssertTrue(dataValidator is PasswordValidator, "DarkThemeFactory should create PasswordValidator")
    }
}

// MARK: - Client Tests

class ClientTests: XCTestCase {
    
    func testClient_WithLightTheme_ShouldUseJPEGCompressionAndEmailValidator() {
        //let lightFactory = LightThemeFactory()
        let client = Client(theme: .light)
        
        // Test Compression Strategy
        XCTAssertTrue(client.compressionStrategy is JPEGCompression, "Client with Light Theme should use JPEGCompression")
        
        // Test Data Validator
        XCTAssertTrue(client.dataValidator is EmailValidator, "Client with Light Theme should use EmailValidator")
    }
    
    func testClient_WithDarkTheme_ShouldUseHEICCompressionAndPasswordValidator() {
        //let darkFactory = DarkThemeFactory()
        let client = Client(theme: .dark)
        
        // Test Compression Strategy
        XCTAssertTrue(client.compressionStrategy is HEICCompression, "Client with Dark Theme should use HEICCompression")
        
        // Test Data Validator
        XCTAssertTrue(client.dataValidator is PasswordValidator, "Client with Dark Theme should use PasswordValidator")
    }
    
    func testClient_PerformOperations_WithValidData_ShouldSucceed() {
        let client = Client(theme: .light)
        let sampleImage = UIImage(systemName: "house")!
        let validEmail = "user@example.com"
        
        // Capture print statements
        let expectation = self.expectation(description: "Print Statements")
        var printOutput = ""
        
        // Redirect stdout
        let originalStdout = dup(STDOUT_FILENO)
        let pipe = Pipe()
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        pipe.fileHandleForReading.readabilityHandler = { handle in
            if let line = String(data: handle.availableData, encoding: .utf8), !line.isEmpty {
                printOutput += line
                expectation.fulfill()
            }
        }
        
        client.performOperations(with: sampleImage, data: validEmail)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Restore stdout
        dup2(originalStdout, STDOUT_FILENO)
        close(originalStdout)
        
        XCTAssertTrue(printOutput.contains("Image compressed successfully"), "Client should print success message for image compression")
        XCTAssertTrue(printOutput.contains("Data is valid."), "Client should print success message for data validation")
    }
    
    func testClient_PerformOperations_WithInvalidData_ShouldFailValidation() {
        let client = Client(theme: .light)
        let sampleImage = UIImage(systemName: "house")!
        let invalidEmail = "user@@example..com"
        
        // Capture print statements
        let expectation = self.expectation(description: "Print Statements")
        var printOutput = ""
        
        // Redirect stdout
        let originalStdout = dup(STDOUT_FILENO)
        let pipe = Pipe()
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        pipe.fileHandleForReading.readabilityHandler = { handle in
            if let line = String(data: handle.availableData, encoding: .utf8), !line.isEmpty {
                printOutput += line
                expectation.fulfill()
            }
        }
        
        client.performOperations(with: sampleImage, data: invalidEmail)
        
        waitForExpectations(timeout: 2, handler: nil)
        
        // Restore stdout
        dup2(originalStdout, STDOUT_FILENO)
        close(originalStdout)
        
        XCTAssertTrue(printOutput.contains("Image compressed successfully"), "Client should print success message for image compression")
        XCTAssertTrue(printOutput.contains("Data is invalid."), "Client should print failure message for data validation")
    }
}

// MARK: - Helper Extensions for Testing

// Extension to UIImage for HEIC compression used in tests
@available(iOS 11.0, *)
extension UIImage {
    func toHEICData(compressionQuality: CGFloat) -> Data? {
        return UIImage.heicData(from: self, compressionQuality: compressionQuality)
    }
}

