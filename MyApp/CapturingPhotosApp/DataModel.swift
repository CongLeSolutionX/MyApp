//
//  DataModel.swift
//  MyApp
//
//  Created by Cong Le on 12/4/24.
//
// Source: https://developer.apple.com/tutorials/sample-apps/capturingphotos-captureandsave

import AVFoundation
import SwiftUI
import os.log

final class DataModel: ObservableObject {
    let camera = Camera()
    let photoCollection = PhotoCollection(smartAlbum: .smartAlbumUserLibrary)
    
    @Published var viewfinderImage: Image?
    @Published var thumbnailImage: Image?
    
    var isPhotosLoaded = false
    
    init() {
        Task { /// This is a  dedicated task to handle the stream of preview images from the camera
            await handleCameraPreviews()
        }
        
        Task { /// This is a dedicated task for handling the captured photo stream.
            await handleCameraPhotos()
        }
    }
    
    ///`handleCameraPreviews` turns the preview stream of `CIImage` objects from the camera
    /// into a stream of Image views, ready for display.
    func handleCameraPreviews() async {
        /// We use `stream’s map(_:)` function to convert each element — `$0` — into an Image instance
        /// using an image property extension of `CIImage`.
        /// This transforms the stream of `CIImage` instances into a stream of Image instances.
        let imageStream = camera.previewStream
            .map { $0.image }

        /// The `for-await` loop waits for each image in our transformed `imageStream`
        /// before doing something with it.
        for await image in imageStream {
            Task { @MainActor in
                /// We use the image from the preview stream
                ///  to update your data model’s viewfinderImage property.
                ///  SwiftUI makes sure that any views using this property get updated
                ///  when the viewfinderImage value changes.
                viewfinderImage = image
            }
        }
    }
    
    /// Each `AVCapturePhoto` element in the camera’s `photoStream` may contain several images at different resolutions,
    /// as well as other metadata about the image, such as its size and the date and time the image was captured.
    /// We have to unpack it to get the images and metadata that we want.
    /// This funtion help to convert `photoStream` into a more useful `unpackedPhotoStream`,
    /// in which each element is an instance of the `PhotoData` structure that contains the data we want.
    func handleCameraPhotos() async {
        let unpackedPhotoStream = camera.photoStream
            .compactMap { self.unpackPhoto($0) }
        
        /// The `for-await` loop now waits for a `photoData` element to arrive in our unpacked stream before processing it.
        for await photoData in unpackedPhotoStream {
            Task { @MainActor in
                /// We use the thumbnail image in `photoData` to update our model’s `thumbnailImage` property.
                thumbnailImage = photoData.thumbnailImage
            }
            savePhoto(imageData: photoData.imageData) /// Call the model’s `savePhoto(imageData:)` method to save the image data from `photoData` as a new photo in our photo library.
            

        }
    }
    
    /// To unpack the `photoStream`, we'll use the `unpackPhoto(_:)` function,
    /// which takes a captured photo and returns a `PhotoData` instance that contains a low-resolution image thumbnail as an `Image`,
    /// the size of the image thumbnail, a high-resolution image as `Data`,
    /// and the size of the high-resolution image.
    private func unpackPhoto(_ photo: AVCapturePhoto) -> PhotoData? {
        guard let imageData = photo.fileDataRepresentation() else { return nil }

        guard let previewCGImage = photo.previewCGImageRepresentation(),
           let metadataOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
              let cgImageOrientation = CGImagePropertyOrientation(rawValue: metadataOrientation) else { return nil }
        let imageOrientation = Image.Orientation(cgImageOrientation)
        let thumbnailImage = Image(decorative: previewCGImage, scale: 1, orientation: imageOrientation)
        
        let photoDimensions = photo.resolvedSettings.photoDimensions
        let imageSize = (width: Int(photoDimensions.width), height: Int(photoDimensions.height))
        let previewDimensions = photo.resolvedSettings.previewDimensions
        let thumbnailSize = (width: Int(previewDimensions.width), height: Int(previewDimensions.height))
        
        return PhotoData(thumbnailImage: thumbnailImage, thumbnailSize: thumbnailSize, imageData: imageData, imageSize: imageSize)
    }
    
    /// The `savePhoto(imageData:)` method creates a task and passes on the real work of saving the photo data
    /// to the `photoCollection` object by calling its `addImage(_:)` method.
    func savePhoto(imageData: Data) {
        Task {
            do {
                try await photoCollection.addImage(imageData)
                logger.debug("Added image data to photo collection.")
            } catch let error {
                logger.error("Failed to add image to photo collection: \(error.localizedDescription)")
            }
        }
    }
    
    func loadPhotos() async {
        guard !isPhotosLoaded else { return }
        
        let authorized = await PhotoLibrary.checkAuthorization()
        guard authorized else {
            logger.error("Photo library access was not authorized.")
            return
        }
        
        Task {
            do {
                try await self.photoCollection.load()
                await self.loadThumbnail()
            } catch let error {
                logger.error("Failed to load photo collection: \(error.localizedDescription)")
            }
            self.isPhotosLoaded = true
        }
    }
    
    func loadThumbnail() async {
        guard let asset = photoCollection.photoAssets.first  else { return }
        await photoCollection.cache.requestImage(for: asset, targetSize: CGSize(width: 256, height: 256))  { result in
            if let result = result {
                Task { @MainActor in
                    self.thumbnailImage = result.image
                }
            }
        }
    }
}

fileprivate struct PhotoData {
    var thumbnailImage: Image
    var thumbnailSize: (width: Int, height: Int)
    var imageData: Data
    var imageSize: (width: Int, height: Int)
}

fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

fileprivate extension Image.Orientation {

    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "DataModel")
