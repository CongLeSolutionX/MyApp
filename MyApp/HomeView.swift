//
//  HomeView.swift
//  MyApp
//
//  Created by Cong Le on 1/19/25.
//


import SwiftUI
import PhotosUI

struct HomeView: View {
    @StateObject private var imageRemoverModel: ImageRemoverModel = .init()
    var body: some View {
        VStack(spacing: 15) {
            if let image = imageRemoverModel.fetchedImage {
                Group {
                    GeometryReader { proxy in
                        let size = proxy.size
                        
                        HStack {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: size.width, height: size.height)
                                .clipped()
                        }
                    }
                    .frame(height: UIApplication.shared.screenSize().width - 30)
                    .overlay(alignment: .topTrailing) {
                        Button {
                            imageRemoverModel.fetchedImage = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .tint(.red)
                        }
                        .offset(x: -10, y: -50)
                    }
                    
                    HStack(spacing: 12) {
                        Button("Remove Background") {
                            imageRemoverModel.removeBackground()
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        
                        ShareLink(item: ImageFile(image: image), preview: .init("Export Image", image: ImageFile(image: image))) {
                            Text("Share Image")
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
            } else {
                Group {
                    Button {
                        imageRemoverModel.showPicker.toggle()
                    } label: {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.title)
                    }
                    .buttonStyle(.bordered)
                    .tint(.primary)
                    .photosPicker(isPresented: $imageRemoverModel.showPicker, selection: $imageRemoverModel.pickedItem, matching: .images)
                    
                    Text("Tap to add an image")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }
}
// MARK: - Preview
struct Home_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
