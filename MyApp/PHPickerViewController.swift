//
//  PHPickerViewController.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import SwiftUI
import PhotosUI // Essential for PHPickerViewController

// MARK: - Image Picker (UIViewControllerRepresentable)

struct ImagePicker: UIViewControllerRepresentable {

    // Binding to the array that will hold the selected UIImages
    @Binding var selectedImages: [UIImage]

    // Environment variable to dismiss the sheet
    @Environment(\.dismiss) var dismiss

    // Creates the Coordinator instance
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Creates the PHPickerViewController instance
    func makeUIViewController(context: Context) -> PHPickerViewController {
        // 1. Create a configuration object
        var config = PHPickerConfiguration()
        config.filter = .images // We only want images
        config.selectionLimit = 0 // 0 means no limit (multiple selection)
        // Optional: Use .ordered to keep selection order
        // config.selection = .ordered

        // 2. Create the picker view controller
        let picker = PHPickerViewController(configuration: config)

        // 3. Set the coordinator as the delegate
        picker.delegate = context.coordinator
        return picker
    }

    // This function is required, but we don't need to update the VC
    // after it's been presented for this basic usage.
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No update needed
    }

    // MARK: - Coordinator Class

    // The Coordinator acts as the delegate for the PHPickerViewController
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker // Reference back to the ImagePicker struct

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // This delegate method is called when the user finishes picking photos
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // Dismiss the picker sheet
            parent.dismiss()

            // Guard against no selections
            guard !results.isEmpty else {
                return
            }

            // Create a temporary array to hold newly selected images
            var newlySelectedImages: [UIImage] = []
            let dispatchGroup = DispatchGroup() // Use DispatchGroup to wait for all async loads

            // Process each result
            for result in results {
                dispatchGroup.enter() // Enter group before async load
                let itemProvider = result.itemProvider

                // Check if the item provider can load a UIImage
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    // Load the UIImage object asynchronously
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        defer { dispatchGroup.leave() } // Leave group when load finishes (success or fail)

                        if let error = error {
                            print("Error loading image: \(error.localizedDescription)")
                            return
                        }

                        // Safely unwrap the image
                        if let uiImage = image as? UIImage {
                            // Collect the image (can happen on background thread)
                            // We will update the main state array after all are loaded
                            // Synchronization is handled by DispatchGroup and final main thread update
                            newlySelectedImages.append(uiImage)
                        }
                    }
                } else {
                    print("Item provider cannot load UIImage.")
                    dispatchGroup.leave() // Leave group if cannot load
                }
            }

            // Notify on the main thread *after* all async operations are done
            dispatchGroup.notify(queue: .main) { [weak self] in
                 // Update the parent's binding array with the collected images
                 // This example replaces the existing selection. Use append if you want to add.
                 self?.parent.selectedImages = newlySelectedImages
                 print("Finished processing \(newlySelectedImages.count) images.")
            }
        }
    }
}

// MARK: - Content View (Example Usage)

struct PHPickerViewController_ContentView: View {
    // State variable to control the presentation of the image picker sheet
    @State private var showingImagePicker = false

    // State variable to store the images selected by the user
    @State private var selectedImages: [UIImage] = []

    var body: some View {
        NavigationView {
            VStack {
                if selectedImages.isEmpty {
                    Text("No images selected.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill space
                } else {
                    // Display selected images in a horizontal scroll view
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(selectedImages, id: \.self) { img in
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150) // Fixed height for consistency
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .padding(.horizontal, 4)
                            }
                        }
                        .padding(.vertical)
                    }
                    .frame(height: 170) // Give the scroll view a fixed height

                    // Allow clearing the selection
                    Button("Clear Selection") {
                        selectedImages.removeAll()
                    }
                    .padding(.top)

                    Spacer() // Push content to top
                }
            }
            .navigationTitle("PHPicker Demo")
            .toolbar {
                // Button in the navigation bar to trigger the image picker
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingImagePicker = true // Set state to true to present the sheet
                    } label: {
                        Label("Select Images", systemImage: "photo.on.rectangle.angled")
                    }
                }
            }
            // The .sheet modifier presents the ImagePicker when showingImagePicker is true
            .sheet(isPresented: $showingImagePicker) {
                 // Pass the binding to the selectedImages array to the ImagePicker
                 ImagePicker(selectedImages: $selectedImages)
            }
        }
         // Use stack style for better behavior on iPad/macOS
        .navigationViewStyle(.stack)
    }
}

// MARK: - App Entry Point

//@main
//struct PHPickerDemoApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

// MARK: - Preview Provider

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PHPickerViewController_ContentView()
    }
}
