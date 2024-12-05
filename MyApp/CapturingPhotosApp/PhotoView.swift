//
//  PhotoView.swift
//  MyApp
//
//  Created by Cong Le on 12/4/24.
//
// Source: https://developer.apple.com/tutorials/sample-apps/capturingphotos-captureandsave

import SwiftUI
import Photos


/// When it comes to displaying a photo on its own,
/// we'll use `PhotoView`. In our photo view, we display a high-resolution image that we request from the photo.
/// We also have an overlay with buttons for favoriting or deleting the photo.
struct PhotoView: View {
    var asset: PhotoAsset /// This is the photo the view displays.
    
    ///`cache` holds a reference to your image cache.
    /// We can request an image of a specified size from the image cache.
    /// After loading the image from the photo asset, the cache delivers it back to us.
    /// The image cache also keeps recently-requested images in memory,
    /// so it doesn’t have to reload them if you request them again.
    var cache: CachedImageManager?
    
    @State private var image: Image?
    @State private var imageRequestID: PHImageRequestID?
    @Environment(\.dismiss) var dismiss
    private let imageSize = CGSize(width: 1024, height: 1024)
    
    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
                    .accessibilityLabel(asset.accessibilityLabel)
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(Color.secondary)
        .navigationTitle("Photo")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            buttonsView()
                .offset(x: 0, y: -50)
        }
        .task {/// A view can use its `task(priority:_:)` modifier to run some code asynchronously whenever the view loads.
            guard image == nil, let cache = cache else { return }
            imageRequestID = await cache.requestImage(for: asset, targetSize: imageSize) { result in
                Task {
                    /// This is where we request a high-resolution image from the cache for the photo asset,
                    /// specifying the size we want.
                    /// We also provide the cache with a closure that contains code it can call when it has a result.
                    if let result = result {
                        self.image = result.image /// updates our `image` property if found an image in the `result`.
                    }
                }
            }
        }
    }
    
    private func buttonsView() -> some View {
        HStack(spacing: 60) {
            
            Button {
                Task {
                    await asset.setIsFavorite(!asset.isFavorite)
                }
            } label: {
                Label("Favorite", systemImage: asset.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 24))
            }

            Button {
                Task {
                    await asset.delete()
                    await MainActor.run {
                        dismiss()
                    }
                }
            } label: {
                Label("Delete", systemImage: "trash")
                    .font(.system(size: 24))
            }
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding(EdgeInsets(top: 20, leading: 30, bottom: 20, trailing: 30))
        .background(Color.secondary.colorInvert())
        .cornerRadius(15)
    }
}

// MARK: - Preview
#Preview {
    PhotoView(asset: PhotoAsset(identifier: "Random identifier"))
}
