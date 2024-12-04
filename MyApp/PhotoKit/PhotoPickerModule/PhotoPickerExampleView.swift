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
            .onChange(of: selectedItems) { newItems in
                images.removeAll()
                Task {
                    await loadImages(from: newItems)
                }
            }
        }
    }
    
    // Async function to load images from PhotosPickerItems
    @MainActor
    private func loadImages(from items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                let identifiableImage = IdentifiableImage(image: Image(uiImage: uiImage))
                images.append(identifiableImage)
            }
        }
    }
}

struct PhotoPickerExampleView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoPickerExampleView()
    }
}
