//
//  PhotoView.swift
//  MyApp
//
//  Created by Cong Le on 12/4/24.
//

import SwiftUI

struct PhotoView: View {
    @ObservedObject var viewModel: PhotoViewModel

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let photo = viewModel.photo,
                          let uiImage = UIImage(data: photo.imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding()
                } else {
                    Text("No image available")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Random Image")
            .onAppear {
                Task {
                    await viewModel.fetchPhoto()
                }
            }
            .alert(item: $viewModel.error) { error in
                Alert(
                    title: Text("Error"),
                    message: Text(error.localizedDescription),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
