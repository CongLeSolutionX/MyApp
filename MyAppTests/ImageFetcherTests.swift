//
//  ImageFetcherTests.swift
//  MyAppTests
//
//  Created by Cong Le on 1/18/25.
//
//
//import XCTest
//@testable import MyApp // Replace with your actual project name.
//
//import UIKit
//
//final class ImageFetcherTests: XCTestCase {
//    
//    // Test successful image fetching using DefaultImageFetcher.
//    func testFetchImageSuccess() async throws {
//        // Given
//        let fetcher = DefaultImageFetcher()
//        let url = URL(string: "https://via.placeholder.com/150")! // A URL that returns an image.
//        
//        // When
//        let image = try await fetcher.fetchImage(from: url)
//        
//        // Then
//        XCTAssertNotNil(image, "Image should not be nil for a valid URL.")
//    }
//    
//    // Test HTTP error handling.
//    func testFetchImageHttpError() async {
//        // Given
//        let fetcher = DefaultImageFetcher()
//        let url = URL(string: "https://httpstat.us/404")! // A URL that returns a 404 error.
//        
//        // When
//        do {
//            _ = try await fetcher.fetchImage(from: url)
//            XCTFail("Expected to throw an HTTP error.")
//        } catch let error as FlightDataError {
//            // Then
//            if case let .httpError(statusCode) = error {
//                XCTAssertEqual(statusCode, 404, "Expected HTTP status code 404.")
//            } else {
//                XCTFail("Expected httpError with status code 404.")
//            }
//        } catch {
//            XCTFail("Unexpected error: \(error).")
//        }
//    }
//    
//    // Test invalid data handling.
//    func testFetchImageInvalidData() async {
//        // Given
//        let fetcher = DefaultImageFetcher()
//        let url = URL(string: "https://example.com")! // A URL that returns HTML, not image data.
//        
//        // When
//        do {
//            _ = try await fetcher.fetchImage(from: url)
//            XCTFail("Expected to throw an invalidData error.")
//        } catch let error as FlightDataError {
//            // Then
//            XCTAssertEqual(error, .invalidData, "Expected invalidData error.")
//        } catch {
//            XCTFail("Unexpected error: \(error).")
//        }
//    }
//}
