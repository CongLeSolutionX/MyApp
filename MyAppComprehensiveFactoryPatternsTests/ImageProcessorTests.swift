//
//  ImageProcessorTests.swift
//  MyApp
//
//  Created by Cong Le on 10/29/24.
//

import XCTest
import UIKit

@testable import MyApp // Replace with your module name

class ImageProcessorTests: XCTestCase {
    
    var sampleImage: UIImage!
    
    override func setUp() {
        super.setUp()
        // Create a sample image for testing (a simple colored rectangle)
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        UIColor.blue.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        sampleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func tearDown() {
        sampleImage = nil
        super.tearDown()
    }
    
    // MARK: - ImageProcessor with Mocks Tests
    
    func testImageProcessor_CompressionSuccess_ValidationSuccess() {
        let mockCompression = MockCompressionStrategy()
        mockCompression.compressedData = Data([0x00, 0x01, 0x02])
        let mockValidator = MockDataValidator()
        mockValidator.shouldValidate = true
        
        let processor = ImageProcessor(compressionStrategy: mockCompression, dataValidator: mockValidator)
        let result = processor.process(image: sampleImage, data: "validData")
        
        XCTAssertNotNil(result.compressedData, "Compressed data should not be nil")
        XCTAssertTrue(result.isValid, "Data should be valid")
    }
    
    func testImageProcessor_CompressionFailure_ValidationSuccess() {
        let mockCompression = MockCompressionStrategy()
        mockCompression.shouldReturnData = false
        let mockValidator = MockDataValidator()
        mockValidator.shouldValidate = true
        
        let processor = ImageProcessor(compressionStrategy: mockCompression, dataValidator: mockValidator)
        let result = processor.process(image: sampleImage, data: "validData")
        
        XCTAssertNil(result.compressedData, "Compressed data should be nil due to compression failure")
        XCTAssertTrue(result.isValid, "Data should be valid")
    }
    
    func testImageProcessor_CompressionSuccess_ValidationFailure() {
        let mockCompression = MockCompressionStrategy()
        mockCompression.compressedData = Data([0x00, 0x01, 0x02])
        let mockValidator = MockDataValidator()
        mockValidator.shouldValidate = false
        
        let processor = ImageProcessor(compressionStrategy: mockCompression, dataValidator: mockValidator)
        let result = processor.process(image: sampleImage, data: "invalidData")
        
        XCTAssertNotNil(result.compressedData, "Compressed data should not be nil")
        XCTAssertFalse(result.isValid, "Data should be invalid")
    }
    
    func testImageProcessor_CompressionFailure_ValidationFailure() {
        let mockCompression = MockCompressionStrategy()
        mockCompression.shouldReturnData = false
        let mockValidator = MockDataValidator()
        mockValidator.shouldValidate = false
        
        let processor = ImageProcessor(compressionStrategy: mockCompression, dataValidator: mockValidator)
        let result = processor.process(image: sampleImage, data: "invalidData")
        
        XCTAssertNil(result.compressedData, "Compressed data should be nil due to compression failure")
        XCTAssertFalse(result.isValid, "Data should be invalid")
    }
    
    // MARK: - Integration Tests with Mocks
    
    func testImageProcessor_WithRealStrategies() {
        // Using real strategies for integration testing
        let compressionFactory = CompressionFactory()
        let jpegStrategy = compressionFactory.createCompressionStrategy(type: .jpeg)
        let lightFactory: AbstractFactory = LightThemeFactory()
        let emailValidator = lightFactory.createDataValidator()
        
        let processor = ImageProcessor(compressionStrategy: jpegStrategy, dataValidator: emailValidator)
        let result = processor.process(image: sampleImage, data: "user@example.com")
        
        XCTAssertNotNil(result.compressedData, "JPEG compression should return data")
        XCTAssertTrue(result.isValid, "Email should be valid")
    }
}
