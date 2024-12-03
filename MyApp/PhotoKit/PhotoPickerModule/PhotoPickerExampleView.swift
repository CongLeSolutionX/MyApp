//
//  PhotoPickerExampleView.swift
//  MyApp
//
//  Created by Cong Le on 12/2/24.
//

import SwiftUI
import PhotosUI

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: Image
}

struct PhotoPickerExampleView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var images: [IdentifiableImage] = []
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(images) { identifiableImage in
                    identifiableImage.image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }
            }
        }
        
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: 5,
            matching: .any(of: [.images, .livePhotos])
        ) {
            Text("Select Photos")
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
        }
        // Use a single-parameter closure with explicit type
        .onChange(of: selectedItems) { (newItems: [PhotosPickerItem]) in
            images.removeAll()
            for item in newItems {
                // Start a Task to load the image asynchronously
                Task {
                    if let image = try? await loadPhoto(from: item) {
                        let identifiableImage = IdentifiableImage(image: Image(uiImage: image))
                        images.append(identifiableImage)
                    }
                }
            }
        }
    }
    
    // Async function to load UIImage from PhotosPickerItem
    func loadPhoto(from item: PhotosPickerItem) async throws -> UIImage {
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            return uiImage
        } else {
            throw URLError(.badServerResponse)
        }
    }
}

struct PhotoPickerExampleView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoPickerExampleView()
    }
}

