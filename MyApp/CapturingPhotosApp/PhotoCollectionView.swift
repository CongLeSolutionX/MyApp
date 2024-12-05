//
//  PhotoCollectionView.swift
//  MyApp
//
//  Created by Cong Le on 12/4/24.
//
// Source: https://developer.apple.com/tutorials/sample-apps/capturingphotos-captureandsave

import SwiftUI
import os.log

struct PhotoCollectionView: View {
    /// use a `PhotoCollectionView` to display your photos in a scrolling grid,
    /// with the most recent photos at the top.
    @ObservedObject var photoCollection : PhotoCollection
    
    @Environment(\.displayScale) private var displayScale
        
    private static let itemSpacing = 12.0
    private static let itemCornerRadius = 15.0
    private static let itemSize = CGSize(width: 90, height: 90)
    
    private var imageSize: CGSize {
        return CGSize(width: Self.itemSize.width * min(displayScale, 2), height: Self.itemSize.height * min(displayScale, 2))
    }
    
    private let columns = [
        GridItem(.adaptive(minimum: itemSize.width, maximum: itemSize.height), spacing: itemSpacing)
    ]
    
    var body: some View {
        ScrollView {
            /// Using `LazyGrid` because the layout uses a vertical grid,
            /// we only need to decide how many columns we want and the spacing between each item.
            /// After the grid has the number of columns, it expands vertically to add enough rows for displaying all of our photos.
            LazyVGrid(columns: columns, spacing: Self.itemSpacing) {
                ForEach(photoCollection.photoAssets) { asset in
                    /// create a `NavigationLink` for each grid item that, when tapped or clicked,
                    /// displays the individual photo at full size using the destination `PhotoView` initialized with the photo asset.
                    NavigationLink {
                        PhotoView(asset: asset, cache: photoCollection.cache)
                    } label: {
                        /// We’ll use this view as the label for the navigation link,
                        /// displaying each link as a thumbnail-sized image of the photo.
                        photoItemView(asset: asset) /// creates a view that displays a small image thumbnail for a photo asset.
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel(asset.accessibilityLabel)
                }
            }
            .padding([.vertical], Self.itemSpacing)
        }
        .navigationTitle(photoCollection.albumName ?? "Gallery")
        .navigationBarTitleDisplayMode(.inline)
        .statusBar(hidden: false)
    }
    
    private func photoItemView(asset: PhotoAsset) -> some View {
        PhotoItemView(asset: asset, cache: photoCollection.cache, imageSize: imageSize)
            .frame(width: Self.itemSize.width, height: Self.itemSize.height)
            .clipped()
            .cornerRadius(Self.itemCornerRadius)
            .overlay(alignment: .bottomLeading) {
                if asset.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 1)
                        .font(.callout)
                        .offset(x: 4, y: -4)
                }
            }
            .onAppear {
                Task {
                    await photoCollection.cache.startCaching(for: [asset], targetSize: imageSize)
                }
            }
            .onDisappear {
                Task {
                    await photoCollection.cache.stopCaching(for: [asset], targetSize: imageSize)
                }
            }
    }
}

// MARK: - Preview
#Preview {
    PhotoCollectionView(photoCollection: .init(albumNamed: "Unknown Album"))
}
