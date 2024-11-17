//
//  PhotoPickerExampleView.swift
//  MyApp
//
//  Created by Cong Le on 11/16/24.
//
import SwiftUI
import PhotosUI

struct PhotoPickerExampleView: View {
    @State private var showPicker = false
    @State private var selectedImage: Image?

    var body: some View {
        VStack {
            selectedImage?
                .resizable()
                .scaledToFit()
            
            Button(action: {
                checkPhotoLibraryPermission()
            }) {
                Text("Select Photo")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .sheet(isPresented: $showPicker) {
            PhotoPicker(selectedImage: $selectedImage)
        }
    }
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            showPicker = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    DispatchQueue.main.async {
                        showPicker = true
                    }
                }
            }
        case .denied, .restricted:
            // Handle denied or restricted access (e.g., show an alert)
            print("Photo library access denied or restricted.")
        case .limited:
            print("Photo library access limited.")
        @unknown default:
            print("Unknown authorization status.")
        }
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: Image?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    if let image = image as? UIImage {
                        self.parent.selectedImage = Image(uiImage: image)
                    }
                }
            }
        }
    }
}
