//
//  PhotoPickerExampleView.swift
//  MyApp
//
//  Created by Cong Le on 12/2/24.
//

import SwiftUI
import PhotosUI

struct PhotoPickerExampleView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var images: [Image] = []
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(images, id: \.self) { image in
                    image
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
                for item in newItems {
                    item.loadObject(ofClass: UIImage.self) { result in
                        switch result {
                        case .success(let image):
                            if let uiImage = image as? UIImage {
                                DispatchQueue.main.async {
                                    images.append(Image(uiImage: uiImage))
                                }
                            }
                        case .failure(let error):
                            print("Error loading image: \(error)")
                        }
                    }
                }
            }
        }
    }
}

struct PhotoPickerExampleView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoPickerExampleView()
    }
}
