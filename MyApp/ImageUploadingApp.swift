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
    @State private var showingCamera = false // State to control camera presentation
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedItem: PhotosPickerItem? = nil

    var body: some View {
        NavigationView {
            VStack {
                // Image Placeholder
                if let inputImage = inputImage {
                    Image(uiImage: inputImage)
                        .resizable()
                        .scaledToFit() // Better than .scaleEffect for aspect ratio
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill available space
                } else {
                    Rectangle() // Placeholder
                        .fill(Color.gray.opacity(0.3)) // Light gray placeholder
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                Button("Upload Image") {
                    showingActionSheet = true
                }
                .padding()
                .background(Color.blue) // Blue background, matches the design
                .foregroundColor(.white)
                .font(.headline)
                .cornerRadius(10)
            }
            .navigationTitle("Upload Image") // Keep Navigation title
            .navigationBarTitleDisplayMode(.inline) // Make sure it is inline and not large
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        //Handle dismiss.
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                //Use the new photos picker.
                PhotoPickerView(selectedItem: $selectedItem)
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView(image: $inputImage, sourceType: $sourceType)
                    .ignoresSafeArea(.all, edges: .bottom)
            }
            .onChange(of: selectedItem) { _ in
                Task {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            inputImage = uiImage
                            return
                        }
                    }
                    print("Failed to load image")
                }
            }
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(title: Text("Select Source"), message: nil, buttons: [
                    .default(Text("Photo Gallery")) {
                        sourceType = .photoLibrary
                        showingImagePicker = true
                    },
                    .default(Text("Camera")) {
                        sourceType = .camera
                        showingCamera = true // Show the CameraView
                    },
                    .cancel()
                ])
            }
        }
    }
}

//Custom Camera View
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType // Use the sourceType passed from ContentView
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

//Custom Photo Picker
struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var selectedItem: PhotosPickerItem?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
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
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    //Handle your image.
                }
            }
            
            parent.selectedItem = results.first
        }
    }
}

struct ImageUploadingContentView_Previews: PreviewProvider {
    static var previews: some View {
        ImageUploadingContentView()
    }
}
