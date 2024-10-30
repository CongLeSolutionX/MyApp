//
//  MyAppComprehensiveFactoryPatternsTests.swift
//  MyAppComprehensiveFactoryPatternsTests
//
//  Created by Cong Le on 10/29/24.
//

import XCTest
import UIKit

@testable import MyApp // Replace with your module name

class CompressionTests: XCTestCase {
    
    var sampleImage: UIImage!
    
    override func setUp() {
        super.setUp()
        // Create a sample image for testing (a simple colored rectangle)
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        UIColor.red.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        sampleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func tearDown() {
        sampleImage = nil
        super.tearDown()
    }
    
    // MARK: - Factory Pattern Tests
    
    func testCompressionFactoryJPEG() {
        let factory = CompressionFactory()
        let strategy = factory.createCompressionStrategy(type: .jpeg)
        XCTAssertTrue(strategy is JPEGCompression, "Factory should return JPEGCompression instance")
        
        let compressedData = strategy.compress(image: sampleImage)
        XCTAssertNotNil(compressedData, "JPEG compression should return data")
        XCTAssertGreaterThan(compressedData!.count, 0, "JPEG compressed data should have size greater than 0")
    }
    
    func testCompressionFactoryPNG() {
        let factory = CompressionFactory()
        let strategy = factory.createCompressionStrategy(type: .png)
        XCTAssertTrue(strategy is PNGCompression, "Factory should return PNGCompression instance")
        
        let compressedData = strategy.compress(image: sampleImage)
        XCTAssertNotNil(compressedData, "PNG compression should return data")
        XCTAssertGreaterThan(compressedData!.count, 0, "PNG compressed data should have size greater than 0")
    }
    
    func testCompressionFactoryHEIC_available() {
        // This test should only run on iOS 11.0 and above
        if #available(iOS 11.0, *) {
            let factory = CompressionFactory()
            let strategy = factory.createCompressionStrategy(type: .heic)
            XCTAssertTrue(strategy is HEICCompression, "Factory should return HEICCompression instance")
            
            let compressedData = strategy.compress(image: sampleImage)
            XCTAssertNotNil(compressedData, "HEIC compression should return data")
            XCTAssertGreaterThan(compressedData!.count, 0, "HEIC compressed data should have size greater than 0")
        }
    }
    
    func testCompressionFactoryHEIC_unavailable() {
        // Simulating iOS version below 11.0 is not straightforward.
        // Hence, we can test the fallback manually by initializing HEICCompression directly.
        let strategy = HEICCompression()
        let compressedData = strategy.compress(image: sampleImage)
        XCTAssertNotNil(compressedData, "HEIC compression fallback should return data")
        XCTAssertGreaterThan(compressedData!.count, 0, "HEIC compressed data should have size greater than 0")
    }
    
    // MARK: - Factory Method Pattern Tests
    
    func testJPEGCompressionFactory() {
        let factory = JPEGCompressionFactory()
        let strategy = factory.createCompressionStrategy()
        XCTAssertTrue(strategy is JPEGCompression, "Factory Method should return JPEGCompression instance")
        
        let compressedData = strategy.compress(image: sampleImage)
        XCTAssertNotNil(compressedData, "JPEG compression should return data")
        XCTAssertGreaterThan(compressedData!.count, 0, "JPEG compressed data should have size greater than 0")
    }
    
    func testPNGCompressionFactory() {
        let factory = PNGCompressionFactory()
        let strategy = factory.createCompressionStrategy()
        XCTAssertTrue(strategy is PNGCompression, "Factory Method should return PNGCompression instance")
        
        let compressedData = strategy.compress(image: sampleImage)
        XCTAssertNotNil(compressedData, "PNG compression should return data")
        XCTAssertGreaterThan(compressedData!.count, 0, "PNG compressed data should have size greater than 0")
    }
    
    func testHEICCompressionFactory_available() {
        if #available(iOS 11.0, *) {
            let factory = HEICCompressionFactory()
            let strategy = factory.createCompressionStrategy()
            XCTAssertTrue(strategy is HEICCompression, "Factory Method should return HEICCompression instance")
            
            let compressedData = strategy.compress(image: sampleImage)
            XCTAssertNotNil(compressedData, "HEIC compression should return data")
            XCTAssertGreaterThan(compressedData!.count, 0, "HEIC compressed data should have size greater than 0")
        }
    }
    
    func testHEICCompressionFactory_unavailable() {
        // Similar to previous, test the fallback
        let factory = HEICCompressionFactory()
        let strategy = factory.createCompressionStrategy()
        let compressedData = strategy.compress(image: sampleImage)
        XCTAssertNotNil(compressedData, "HEIC compression fallback should return data")
        XCTAssertGreaterThan(compressedData!.count, 0, "HEIC compressed data should have size greater than 0")
    }
    
    // MARK: - Abstract Factory Pattern Tests
    
    func testLightThemeFactory() {
        let factory: AbstractFactory = LightThemeFactory()
        
        // Test Compression Strategy
        let compressionStrategy = factory.createCompressionStrategy()
        XCTAssertTrue(compressionStrategy is JPEGCompression, "LightThemeFactory should provide JPEGCompression")
        
        let compressedData = compressionStrategy.compress(image: sampleImage)
        XCTAssertNotNil(compressedData, "LightThemeFactory compression should return data")
        XCTAssertGreaterThan(compressedData!.count, 0, "Compressed data should have size greater than 0")
        
        // Test Data Validator
        let validator = factory.createDataValidator()
        XCTAssertTrue(validator is EmailValidator, "LightThemeFactory should provide EmailValidator")
        
        // Valid Email
        XCTAssertTrue(validator.validate(data: "test@example.com"), "Valid email should pass validation")
        
        // Invalid Email
        XCTAssertFalse(validator.validate(data: "invalid-email"), "Invalid email should fail validation")
    }
    
    func testDarkThemeFactory() {
        let factory: AbstractFactory = DarkThemeFactory()
        
        // Test Compression Strategy
        let compressionStrategy = factory.createCompressionStrategy()
        if #available(iOS 11.0, *) {
            XCTAssertTrue(compressionStrategy is HEICCompression, "DarkThemeFactory should provide HEICCompression")
        } else {
            XCTAssertTrue(compressionStrategy is HEICCompression, "DarkThemeFactory should provide HEICCompression")
        }
        
        let compressedData = compressionStrategy.compress(image: sampleImage)
        XCTAssertNotNil(compressedData, "DarkThemeFactory compression should return data")
        XCTAssertGreaterThan(compressedData!.count, 0, "Compressed data should have size greater than 0")
        
        // Test Data Validator
        let validator = factory.createDataValidator()
        XCTAssertTrue(validator is PasswordValidator, "DarkThemeFactory should provide PasswordValidator")
        
        // Valid Password
        XCTAssertTrue(validator.validate(data: "StrongPass123"), "Valid password should pass validation")
        
        // Invalid Password
        XCTAssertFalse(validator.validate(data: "short"), "Invalid password should fail validation")
    }
    
    // MARK: - ImageExtension Tests
    
    @available(iOS 11.0, *)
    func testUIImageHEICData() {
        let heicData = sampleImage.heicData(compressionQuality: 0.8)
        XCTAssertNotNil(heicData, "HEIC data should not be nil")
        XCTAssertGreaterThan(heicData!.count, 0, "HEIC data should have size greater than 0")
    }
    
    func testUIImageHEICDataFallback() {
        // Since we cannot actually simulate iOS versions below 11.0,
        // we can test the fallback by creating a dummy HEICCompression instance.
        let heicCompression = HEICCompression()
        let data = heicCompression.compress(image: sampleImage)
        XCTAssertNotNil(data, "HEIC compression fallback should not be nil")
        XCTAssertGreaterThan(data!.count, 0, "HEIC compression fallback data should have size greater than 0")
    }
    
    // MARK: - DataValidator Tests
    
    func testEmailValidator() {
        let validator = EmailValidator()
        
        // Valid Emails
        XCTAssertTrue(validator.validate(data: "user@example.com"), "Valid email should pass")
        XCTAssertTrue(validator.validate(data: "firstname.lastname@domain.co"), "Valid email should pass")
        XCTAssertTrue(validator.validate(data: "user+mailbox@sub.domain.com"), "Valid email should pass")
        
        // Invalid Emails
        XCTAssertFalse(validator.validate(data: "plainaddress"), "Invalid email should fail")
        XCTAssertFalse(validator.validate(data: "@no-local-part.com"), "Invalid email should fail")
        XCTAssertFalse(validator.validate(data: "Outlook Contact <outlook-contact@domain.com>"), "Invalid email should fail")
        XCTAssertFalse(validator.validate(data: "no-at.domain.com"), "Invalid email should fail")
        XCTAssertFalse(validator.validate(data: "no-tld@domain"), "Invalid email should fail")
    }
    
    func testPasswordValidator() {
        let validator = PasswordValidator()
        
        // Valid Passwords
        XCTAssertTrue(validator.validate(data: "password123"), "Password with 11 characters should pass")
        XCTAssertTrue(validator.validate(data: "12345678"), "Password with 8 characters should pass")
        XCTAssertTrue(validator.validate(data: "P@ssw0rd!"), "Password with special characters should pass")
        
        // Invalid Passwords
        XCTAssertFalse(validator.validate(data: "short"), "Password with less than 8 characters should fail")
        XCTAssertFalse(validator.validate(data: ""), "Empty password should fail")
        XCTAssertFalse(validator.validate(data: "     "), "Password with only spaces should fail")
    }
    
    // MARK: - Integration Tests
    
    func testDemoComprehensiveFactoryPatterns() {
        // Since demoComprehensiveFactoryPatterns involves print statements,
        // we'll focus on ensuring that no crashes occur and the methods return expected values.
        // In a real-world scenario, refactor the method to be more testable.
        
        // Create a sample image
        let image = sampleImage
        
        // Factory Pattern
        let compressionFactory = CompressionFactory()
        let jpegStrategy = compressionFactory.createCompressionStrategy(type: .jpeg)
        let jpegData = jpegStrategy.compress(image: image ?? UIImage())
        XCTAssertNotNil(jpegData, "JPEG data should not be nil")
        
        let pngStrategy = compressionFactory.createCompressionStrategy(type: .png)
        let pngData = pngStrategy.compress(image: image ?? UIImage())
        XCTAssertNotNil(pngData, "PNG data should not be nil")
        
        // Factory Method Pattern
        let jpegFactoryMethod = JPEGCompressionFactory()
        let jpegStrategyMethod = jpegFactoryMethod.createCompressionStrategy()
        let jpegDataMethod = jpegStrategyMethod.compress(image: image ?? UIImage())
        XCTAssertNotNil(jpegDataMethod, "Factory Method JPEG data should not be nil")
        
        let pngFactoryMethod = PNGCompressionFactory()
        let pngStrategyMethod = pngFactoryMethod.createCompressionStrategy()
        let pngDataMethod = pngStrategyMethod.compress(image: image ?? UIImage())
        XCTAssertNotNil(pngDataMethod, "Factory Method PNG data should not be nil")
        
        // Abstract Factory Pattern
        let lightFactory: AbstractFactory = LightThemeFactory()
        let lightCompression = lightFactory.createCompressionStrategy()
        let lightCompressedData = lightCompression.compress(image: image ?? UIImage())
        XCTAssertNotNil(lightCompressedData, "Light Factory compressed data should not be nil")
        
        let lightValidator = lightFactory.createDataValidator()
        XCTAssertTrue(lightValidator.validate(data: "user@example.com"), "Light Factory email should be valid")
        
        let darkFactory: AbstractFactory = DarkThemeFactory()
        let darkCompression = darkFactory.createCompressionStrategy()
        let darkCompressedData = darkCompression.compress(image: image ?? UIImage())
        XCTAssertNotNil(darkCompressedData, "Dark Factory compressed data should not be nil")
        
        let darkValidator = darkFactory.createDataValidator()
        XCTAssertTrue(darkValidator.validate(data: "password123"), "Dark Factory password should be valid")
    }
}
