//
//  AsyncFlightDataDisplaySnapshotTests.swift
//  MyApp
//
//  Created by Cong Le on 1/18/25.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import MyApp

class AsyncFlightDataDisplaySnapshotTests: XCTestCase {
    
    func testAsyncFlightDataDisplay_placeholder() {
        // Given
        let dataURL: URL? = nil
        let view = AsyncFlightDataDisplay(dataURL: dataURL)
            .frame(width: 100, height: 100)
        
        // Then
        assertSnapshot(of: view, as: .image)
    }
    
    @MainActor func testAsyncFlightDataDisplay_successfulFetch() {
        // Given
        let image = UIImage(systemName: "photo")!
        let mockFetcher = MockImageFetcher(result: .success(image))
        let dataURL = URL(string: "https://example.com/image.png")
        let viewModel = FlightDataViewModel(dataURL: dataURL, imageFetcher: mockFetcher)
        let view = AsyncFlightDataDisplay(
            dataURL: dataURL,
            imageFetcher: mockFetcher
        )
        .frame(width: 100, height: 100)
        
        // Mock the ViewModel's state
        viewModel.flightData = Image(uiImage: image)
        
        // Then
        assertSnapshot(of: view, as: .image)
    }
    
    func testAsyncFlightDataDisplay_error() {
        // Given
        let httpError = FlightDataError.httpError(statusCode: 404)
        let mockFetcher = MockImageFetcher(result: .failure(httpError))
        let dataURL = URL(string: "https://example.com/error.png")
        let view = AsyncFlightDataDisplay(
            dataURL: dataURL,
            imageFetcher: mockFetcher
        )
        .frame(width: 100, height: 100)
        
        // Mock the ViewModel's state
        // Note: Requires further refactoring to inject ViewModel state or use Dependency Injection
        
        // Then
        assertSnapshot(of: view, as: .image)
    }
}
