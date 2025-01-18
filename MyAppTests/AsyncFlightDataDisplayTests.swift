//
//  AsyncFlightDataDisplayTests.swift
//  MyApp
//
//  Created by Cong Le on 1/18/25.
//

//import XCTest
//@testable import MyApp // Replace with your actual project name.
//import SwiftUI
//
//@MainActor
//final class AsyncFlightDataDisplayTests: XCTestCase {
//    
//    // Helper mock image fetcher to simulate different scenarios.
//    struct MockImageFetcher: ImageFetcher {
//        enum Scenario {
//            case success(UIImage)
//            case failure(Error)
//        }
//        
//        let scenario: Scenario
//        
//        func fetchImage(from url: URL) async throws -> UIImage {
//            switch scenario {
//            case .success(let image):
//                return image
//            case .failure(let error):
//                throw error
//            }
//        }
//    }
//    
//    // Test successful image loading in AsyncFlightDataDisplay.
//    func testAsyncFlightDataDisplaySuccess() async {
//        // Given
//        let testImage = UIImage(systemName: "star")!
//        let fetcher = MockImageFetcher(scenario: .success(testImage))
//        let url = URL(string: "https://example.com/image.png")
//        let view = AsyncFlightDataDisplay(
//            dataURL: url,
//            imageFetcher: fetcher
//        )
//        
//        // When
//        await view.loadData()
//        
//        // Then
//        XCTAssertNotNil(view.flightData, "flightData should not be nil after successful fetch.")
//        XCTAssertNil(view.errorMessage, "errorMessage should be nil after successful fetch.")
//    }
//    
//    // Test image display starts with placeholder.
//    func testAsyncFlightDataDisplayPlaceholder() {
//        // Given
//        let fetcher = MockImageFetcher(scenario: .success(UIImage()))
//        let view = AsyncFlightDataDisplay(
//            dataURL: nil,
//            placeholderImage: Image(systemName: "photo"),
//            imageFetcher: fetcher
//        )
//        
//        // Then
//        XCTAssertNil(view.flightData, "flightData should be nil before loading.")
//        XCTAssertNil(view.errorMessage, "errorMessage should be nil before loading.")
//    }
//    
//    // Test error handling in AsyncFlightDataDisplay.
//    func testAsyncFlightDataDisplayError() async {
//        // Given
//        let fetcher = MockImageFetcher(scenario: .failure(FlightDataError.invalidUrl))
//        let url = URL(string: "invalid-url")
//        let view = AsyncFlightDataDisplay(
//            dataURL: url,
//            errorImage: Image(systemName: "exclamationmark.triangle"),
//            imageFetcher: fetcher
//        )
//        
//        // When
//        await view.loadData()
//        
//        // Then
//        XCTAssertNil(view.flightData, "flightData should be nil after failed fetch.")
//        XCTAssertNotNil(view.errorMessage, "errorMessage should not be nil after failed fetch.")
//        XCTAssertEqual(view.errorMessage, FlightDataError.invalidUrl.localizedDescription, "Error message should match expected description.")
//    }
//    
//    // Test handling of nil URL.
//    func testAsyncFlightDataDisplayNilURL() async {
//        // Given
//        let fetcher = MockImageFetcher(scenario: .success(UIImage()))
//        let view = AsyncFlightDataDisplay(
//            dataURL: nil,
//            imageFetcher: fetcher
//        )
//        
//        // When
//        await view.loadData()
//        
//        // Then
//        XCTAssertNil(view.flightData, "flightData should be nil when URL is nil.")
//        XCTAssertNotNil(view.errorMessage, "errorMessage should not be nil when URL is nil.")
//        XCTAssertEqual(view.errorMessage, FlightDataError.invalidUrl.localizedDescription, "Error message should indicate invalid URL.")
//    }
//}
