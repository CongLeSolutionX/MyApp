//
//  CockpitControls.swift
//  MyApp
//
//  Created by Cong Le on 1/17/25.
//

import Foundation
import SwiftUI


/// Error enum for the flight data download process.
enum FlightDataError: Error, LocalizedError {
    /// The URL provided is invalid.
    case invalidUrl
    /// The data received is invalid or cannot be converted to an image.
    case invalidData
    /// The HTTP response returned an error status code.
    case httpError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return NSLocalizedString("The provided URL is invalid.", comment: "")
        case .invalidData:
            return NSLocalizedString("The data received is invalid or cannot be converted to an image.", comment: "")
        case .httpError(let statusCode):
            return NSLocalizedString("HTTP error with status code: \(statusCode).", comment: "")
        }
    }
}

import UIKit

/// Protocol defining image fetching capability.
protocol ImageFetcher {
    /// Fetches image data from the given URL.
    /// - Parameter url: The URL to fetch image data from.
    func fetchImage(from url: URL) async throws -> UIImage
}

/// Default implementation of `ImageFetcher` using `URLSession`.
struct DefaultImageFetcher: ImageFetcher {
    func fetchImage(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Check for HTTP errors.
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw FlightDataError.httpError(statusCode: httpResponse.statusCode)
        }
        
        guard let image = UIImage(data: data) else {
            throw FlightDataError.invalidData
        }
        return image
    }
}



/// Protocol for displaying flight data.
protocol FlightDataDisplaying: View {
    /// The placeholder image to show when data is unavailable.
    var placeholderImage: Image { get }

    /// The error image to show when an error occurs.
    var errorImage: Image { get }

    /// The URL to fetch flight data from.
    var dataURL: URL? { get }

    /// The image fetcher used to fetch images.
    var imageFetcher: ImageFetcher { get }
}


/// Asynchronously fetches and displays flight data (as an Image).
struct AsyncFlightDataDisplay: FlightDataDisplaying {
    // MARK: - Properties

    /// The URL to fetch flight data from.
    let dataURL: URL?

    /// The placeholder image to show when data is unavailable.
    let placeholderImage: Image

    /// The error image to show when an error occurs.
    let errorImage: Image

    /// The image fetcher used to fetch images.
    let imageFetcher: ImageFetcher

    /// The fetched flight data image.
    @State private var flightData: Image?

    /// The error message to display if an error occurs.
    @State private var errorMessage: String?

    // MARK: - Initialization

    /// Initializes a new `AsyncFlightDataDisplay`.
    /// - Parameters:
    ///   - dataURL: The URL to fetch flight data from.
    ///   - placeholderImage: An optional placeholder image.
    ///   - errorImage: An optional error image to display when an error occurs.
    ///   - imageFetcher: The image fetcher to use for fetching images.
    init(
        dataURL: URL?,
        placeholderImage: Image = Image(systemName: "photo"),
        errorImage: Image = Image(systemName: "exclamationmark.triangle"),
        imageFetcher: ImageFetcher = DefaultImageFetcher()
    ) {
        self.dataURL = dataURL
        self.placeholderImage = placeholderImage
        self.errorImage = errorImage
        self.imageFetcher = imageFetcher
    }

    // MARK: - Body

    var body: some View {
        Group {
            if let flightData = flightData {
                flightData
                    .resizable()
                    .scaledToFit()
            } else if let errorMessage = errorMessage {
                VStack {
                    errorImage
                        .resizable()
                        .scaledToFit()
                    Text(errorMessage)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                }
            } else {
                placeholderImage
                    .resizable()
                    .scaledToFit()
            }
        }
        .task(id: dataURL) {
            await loadData()
        }
    }

    // MARK: - Data Loading

    /// Loads the image data asynchronously.
    @MainActor
    private func loadData() async {
        // Ensure the URL is valid.
        guard let url = dataURL else {
            errorMessage = FlightDataError.invalidUrl.localizedDescription
            return
        }

        do {
            let uiImage = try await imageFetcher.fetchImage(from: url)
            flightData = Image(uiImage: uiImage)
        } catch {
            if let flightError = error as? FlightDataError {
                errorMessage = flightError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
}


/// A reusable instrument panel view that styles its content in a consistent manner.
struct InstrumentPanel<Content: View>: View {
    /// The content to be displayed within the instrument panel.
    let content: Content

    /// Initializes an InstrumentPanel with the given content.
    /// - Parameter content: A closure that returns the content view.
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    /// The body of the instrument panel view.
    var body: some View {
        RoundedRectangle(cornerRadius: 12) // Rounded panel corners.
            .fill(Color.black.opacity(0.95)) // A dark panel background.
            .shadow(radius: 5) // A subtle shadow.
            .overlay(
                content
                    .padding(10)
            ) // Padding for content within the panel.
            .border(Color.gray.opacity(0.3)) // A gray border similar to instrument panels.
    }
}

// MARK: - Usage Example
struct InstrumentPanel_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentPanel {
            Text("Altimeter Info")
                .foregroundColor(.white)
        }
        .frame(width: 200, height: 100)
    }
}

/// The main content view of the app.
struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Instrument Panel with Flight Data Display.
            InstrumentPanel {
                AsyncFlightDataDisplay(
                    dataURL: URL(string: "https://images-assets.nasa.gov/image/PIA13005/PIA13005~orig.jpg")
                )
                .frame(width: 100, height: 100)
            }
            .frame(width: 120, height: 140)

            // Standalone Flight Data Display.
            AsyncFlightDataDisplay(
                dataURL: URL(string: "https://images-assets.nasa.gov/image/PIA18033/PIA18033~orig.jpg")
            )
            .frame(width: 100, height: 100)

            // Altitude Control Button.
            // AltitudeControlButton() // Uncomment if needed
        }
        .padding()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}


#Preview {
    ContentView()
}
