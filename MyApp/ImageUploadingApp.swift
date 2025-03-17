//
//  ImageUploadingApp.swift
//  MyApp
//
//  Created by Cong Le on 3/16/25.
//

import SwiftUI
import PhotosUI

struct ImageUploadingContentView: View {
    @State private var showingImagePicker = false
    @State private var showingActionSheet = false
    @State private var inputImage: UIImage?
    @State private var showingCamera = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    // No need for selectedItem here anymore
    // @State private var selectedItem: PhotosPickerItem? = nil

    var body: some View {
        NavigationView {
            VStack {
                // Image Placeholder
                if let inputImage = inputImage {
                    Image(uiImage: inputImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                Button("Upload Image") {
                    showingActionSheet = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .font(.headline)
                .cornerRadius(10)
            }
            .navigationTitle("Upload Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // Handle dismiss (if needed, e.g., clearing state)
                        showingImagePicker = false // Dismiss if it was open
                        showingCamera = false // Dismiss if it was open
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                PhotoPickerView(image: $inputImage) // Pass the image binding directly
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView(image: $inputImage, sourceType: $sourceType)
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            // No need for onChange here anymore
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(title: Text("Select Source"), message: nil, buttons: [
                    .default(Text("Photo Gallery")) {
                        sourceType = .photoLibrary
                        showingImagePicker = true
                    },
                    .default(Text("Camera")) {
                        sourceType = .camera
                        showingCamera = true
                    },
                    .cancel()
                ])
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage? // Directly bind to the image

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared()) // Specify photo library
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView

        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            // Correctly load the UIImage
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] loadingResults, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error loading image: \(error)") // Better error handling
                            return
                        }
                        // Cast to UIImage, update the binding
                        if let uiImage = loadingResults as? UIImage {
                            self?.parent.image = uiImage
                        }
                    }
                }
            }
        }
    }
}

struct ImageUploadingContentView_Previews: PreviewProvider {
    static var previews: some View {
        ImageUploadingContentView()
    }
}
