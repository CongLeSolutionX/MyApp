//
//  SelfieScoresAndLandmarksMainView.swift
//  MyApp
//
//  Created by Cong Le on 12/5/24.
//

/*

 Abstract:
 Provides the initial option to select photos.
 */


import Foundation
import UIKit

// MARK: - Selfie
struct Selfie: Identifiable, Hashable {
    let id = UUID() // Unique identifier
    var photo: Data
    var score: Double
    // Add any other properties you need, e.g., facial landmarks

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Selfie, rhs: Selfie) -> Bool {
        return lhs.id == rhs.id
    }
}


// MARK: - SelfieScoresAndLandmarksMainView

import SwiftUI
import PhotosUI

@available(iOS 18.0, *)
struct SelfieScoresAndLandmarksMainView: View {
    // State variables
    @State private var selectedPhotos = [PhotosPickerItem]()
    @State private var selfies: [Selfie] = []
    @State private var hasPerformedRequests = false
    @State private var isLoading = false  // Indicates loading state
    @State private var loadingError: Error?
    @State private var cachedImages: [Data: UIImage] = [:]  // Simple image cache

    var body: some View {
        NavigationStack {
            VStack {
                if selfies.isEmpty {
                    // Display placeholder if no selfies are available
                    PlaceholderView(hasPerformedRequests: hasPerformedRequests)
                } else {
                    ScrollView {
                        Text("Tap an image to see more results")
                            .foregroundStyle(.gray)
                            .padding(.top)

                        LazyVStack {
                            ForEach(selfies) { selfie in
                                if let image = cachedImages[selfie.photo] ?? UIImage(data: selfie.photo) {
                                    NavigationLink(destination: SelfieResultsView(selfie: selfie)) {
                                        ZStack(alignment: .bottomTrailing) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxWidth: 350)
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .accessibilityLabel("Selfie with score \(String(format: "%.2f", selfie.score))")

                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.gray)
                                                .frame(width: 60, height: 30)
                                                .opacity(0.70)
                                                .overlay(
                                                    Text("\(selfie.score, specifier: "%.2f")")
                                                        .foregroundColor(.white)
                                                        .bold()
                                                )
                                                .padding(8)
                                        }
                                        .padding()
                                        .onAppear {
                                            // Cache the image when it appears
                                            if cachedImages[selfie.photo] == nil {
                                                cachedImages[selfie.photo] = image
                                            }
                                        }
                                    }
                                } else {
                                    // Handle the case where image cannot be loaded
                                    Text("Error loading image")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                }

                // PhotosPicker to select images
                PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 5, matching: .images) {
                    HStack {
                        Text("Select Selfies")
                        Image(systemName: "photo.badge.plus")
                    }
                }
                .padding(10)
                .font(.headline)
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .accessibilityLabel("Select selfies from your photo library")
                .padding(.bottom)
            }
            .padding()
            .disabled(isLoading) // Disable interaction during loading
            .overlay {
                if isLoading {
                    ProgressView("Processing...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)
                }
            }
            .alert(isPresented: .constant(loadingError != nil)) {
                Alert(
                    title: Text("Error"),
                    message: Text(loadingError?.localizedDescription ?? "Unknown error"),
                    dismissButton: .default(Text("OK"), action: { loadingError = nil })
                )
            }
        }
        .onChange(of: selectedPhotos, perform: { newSelectedPhotos in
            Task {
                await loadAndProcessPhotos(from: newSelectedPhotos)
            }
        })
    }

    // Function to load and process selected photos
    private func loadAndProcessPhotos(from photoItems: [PhotosPickerItem]) async {
        guard !photoItems.isEmpty else {
            selfies = [] // Clear if no photos selected
            hasPerformedRequests = false
            return
        }

        isLoading = true
        hasPerformedRequests = false
        var newSelfies: [Selfie] = []
        var newPhotosData: [Data] = []

        do {
            // Load photo data
            for photoItem in photoItems {
                if let imageData = try? await photoItem.loadTransferable(type: Data.self) {
                    newPhotosData.append(imageData)
                }
            }

            // Process selfies concurrently
            newSelfies = try await processAllSelfies(photos: newPhotosData)
            selfies = newSelfies
            hasPerformedRequests = true

        } catch {
            loadingError = error
            selfies = [] // Clear on error
            hasPerformedRequests = false
        }

        isLoading = false
    }
}

// MARK: - PlaceholderView

@available(iOS 18.0, *)
struct PlaceholderView: View {
    var hasPerformedRequests: Bool

    var body: some View {
        VStack {
            Image(systemName: "photo.stack")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .foregroundStyle(.primary)
                .opacity(0.3)
                .accessibilityHidden(true)

            if hasPerformedRequests {
                Text("No faces detected. Try another photo!")
                    .foregroundStyle(.red)
                    .padding()
                    .multilineTextAlignment(.center)
            } else {
                Text("Select selfies to analyze")
                    .foregroundStyle(.gray)
                    .padding()
            }
        }
        .padding()
    }
}

// MARK: - SelfieResultsView

import SwiftUI

@available(iOS 18.0, *)
struct SelfieResultsView: View {
    var selfie: Selfie

    var body: some View {
        VStack {
            if let image = UIImage(data: selfie.photo) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding()
            }

            Text("Score: \(selfie.score, specifier: "%.2f")")
                .font(.title)
                .padding()

            // Add more details like landmarks if available
            // ...
        }
        .navigationTitle("Selfie Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - SelfieProcessingError

import UIKit

enum SelfieProcessingError: LocalizedError {
    case noFaceDetected
    case invalidImageData
    case processingFailed
    case unknownError(Error)

    var errorDescription: String? {
        switch self {
        case .noFaceDetected:
            return "No faces were detected in the selected photos."
        case .invalidImageData:
            return "Selected image data is invalid."
        case .processingFailed:
            return "Failed to process the selfies."
        case .unknownError(let error):
            return error.localizedDescription
        }
    }
}

func processAllSelfies(photos: [Data]) async throws -> [Selfie] {
    // Process images concurrently using TaskGroup
    return try await withThrowingTaskGroup(of: Selfie?.self) { group in
        for photoData in photos {
            group.addTask {
                return try await processSingleSelfie(photoData: photoData)
            }
        }

        var selfies: [Selfie] = []
        for try await selfie in group {
            if let selfie = selfie {
                selfies.append(selfie)
            }
        }

        if selfies.isEmpty {
            throw SelfieProcessingError.noFaceDetected
        }

        return selfies
    }
}

// Function to process a single selfie
private func processSingleSelfie(photoData: Data) async throws -> Selfie? {
    guard let image = UIImage(data: photoData) else {
        throw SelfieProcessingError.invalidImageData
    }

    // Call the face detection and scoring function
    let faceDetectionResult = await detectFaceAndCalculateScore(image: image)

    switch faceDetectionResult {
    case .success(let selfie):
        return selfie
    case .failure(let error):
        if let selfieError = error as? SelfieProcessingError {
            throw selfieError
        } else {
            throw SelfieProcessingError.unknownError(error)
        }
    }
}

// Placeholder for face detection and selfie score calculation result
enum FaceDetectionResult {
    case success(Selfie)
    case failure(Error)
}

// Placeholder function for face detection and scoring
private func detectFaceAndCalculateScore(image: UIImage) async -> FaceDetectionResult {
    // Replace this with actual face detection and scoring logic
    // For demonstration, we simulate the process

    // Simulate processing delay
    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

    // Simulate face detection
    let hasFace = true // Assume a face is detected
    let score = Double.random(in: 0.0...1.0) // Random score between 0 and 1

    if hasFace {
        if let photoData = image.jpegData(compressionQuality: 0.8) {
            let selfie = Selfie(photo: photoData, score: score)
            return .success(selfie)
        } else {
            return .failure(SelfieProcessingError.invalidImageData)
        }
    } else {
        return .failure(SelfieProcessingError.noFaceDetected)
    }
}

// MARK: - Previews

#Preview("Selfie Scores And Landmarks Main View") {
    if #available(iOS 18.0, *) {
        let sampleSelfieData = UIImage(named: "Selfie-sample-1")?.jpegData(compressionQuality: 0.8) ?? Data()
        let sampleSelfie = Selfie(photo: sampleSelfieData, score: 0.85)

        SelfieScoresAndLandmarksMainView_PreviewWrapper(sampleSelfie: sampleSelfie)
    } else {
        EmptyView()
    }
}

// Wrapper for the preview to inject sample data
@available(iOS 18.0, *)
struct SelfieScoresAndLandmarksMainView_PreviewWrapper: View {
    var sampleSelfie: Selfie

    var body: some View {
        SelfieScoresAndLandmarksMainView()
            .onAppear {
                // Inject sample data into the view's state
                // Note: This requires modifying the original view to accept initial data or using environmental objects
            }
    }
}
