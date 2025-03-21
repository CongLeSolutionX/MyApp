//
//  NVIDIA_New_Model_Testing_View.swift
//  MyApp
//
//  Created by Cong Le on 3/21/25.
//
import SwiftUI
import UIKit
import Combine

// MARK: - ViewModel
class ImageUploadViewModel: ObservableObject {
    // MARK: - Published Properties (UI Updates)
    // @Published is a property wrapper that automatically updates UI
    @Published var image: UIImage?
    @Published var isShowingImagePicker = false // State variable to control the display of ImagePicker
    @Published var isShowingCamera = false
    @Published var isLoading = false // Flag to track whether app is waiting for response
    @Published var apiResponse: [String: Any]?
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private let invokeURLString =
    "https://ai.api.nvidia.com/v1/cv/nvidia/nv-yolox-page-elements-v1"
    private var cancellables = Set<AnyCancellable>() // Store subscriptions to avoid object deallocation or memory leak.

    // MARK: - Image Encoding

    func encodeImageToBase64(image: UIImage) -> String? {
        // Use JPEG representation for network efficiency (PNG can be large).
        // Adjust compression quality (0.7 is a good balance).
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            print("Error: Could not convert image to JPEG data.")
            return nil
        }
        return imageData.base64EncodedString()
    }

    // MARK: - API Request
    func uploadImage() {
        guard let image = self.image, let base64String = encodeImageToBase64(image:
            image) else {
            errorMessage = "No image to upload or encoding failed."
            return
        }

        assert(base64String.count < 180_000,
               "Image is too large.  Use assets API for larger images.")

        guard let invokeURL = URL(string: invokeURLString) else {
            errorMessage = "Invalid URL."
            return
        }

        let apiKey = "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" // Replace
        let headers = [
            "Authorization": "Bearer \(apiKey)",
            "Accept": "application/json"
        ]

        let payload: [String: Any] = [
            "input": [[
                "type": "image_url",
                "url": "data:image/png;base64,\(base64String)"
            ]]
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject:
            payload, options: []) else {
            errorMessage = "Failed to serialize JSON payload."
            return
        }

        var request = URLRequest(url: invokeURL)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonData

        isLoading = true // Start loading

        // Use dataTaskPublisher to handle asynchronous data
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in  // Check for HTTP Success in tryMap
                guard let httpResponse = response as? HTTPURLResponse,
                      (200 ... 299).contains(httpResponse.statusCode) else {
                    // Extract and throw meaningful HTTP error information
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    throw URLError(.badServerResponse,
                                   userInfo: [NSLocalizedDescriptionKey:
                                               "HTTP Error: \(statusCode)"])
                }
                return data
            }
            .decode(type: [String: String].self, decoder: JSONDecoder()) // Use JSONDecoder
            .receive(on: DispatchQueue.main) // Switch to the main thread for UI updates
            .sink(receiveCompletion: { [weak self] completion in // Handle the request completion
                self?.isLoading = false  // Stop loading indicators
                switch completion {
                case .finished:
                    break
                case .failure(let error): //Error handling, and display error message
                    DispatchQueue.main.async {
                        self?.errorMessage = "Network request failed: \(error.localizedDescription)"
                    }
                }
            }, receiveValue: { [weak self] response in
                self?.apiResponse = response  // Update with API response
                print(response)
            })
            .store(in: &cancellables) // Add the subscription to cancellables
    }
}

// MARK: - Image Picker Coordinator (Bridge between UIKit and SwiftUI)
// Coordinator class handles the callbacks from image picker UIImagePickerController
class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate,
    UIImagePickerControllerDelegate {
    // Reference Parent View (ImagePicker) to update its properties
    @ObservedObject var viewModel: ImageUploadViewModel

    init(viewModel: ImageUploadViewModel) {
        self.viewModel = viewModel
    }

    // Implement the required delegate method.
    //This method is being called when user has selected image
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [
                                UIImagePickerController.InfoKey: Any
                               ]) {
        if let image = info[.originalImage] as? UIImage {
            // Update ObservableObject's `image` in Main Thread to update UI change
            DispatchQueue.main.async {
                self.viewModel.image = image
            }
        }
        // Dismiss the image picker.
        viewModel.isShowingImagePicker = false
    }

    // Implement the required delegate method.
    //This method is being called when user has cancelled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        viewModel.isShowingImagePicker = false
    }
}

// MARK: - Image Picker (SwiftUI Representable)
// This struct adapts the UIKit view controller for use in SwiftUI
struct ImagePicker: UIViewControllerRepresentable {
    @ObservedObject var viewModel: ImageUploadViewModel
    var sourceType: UIImagePickerController.SourceType

    // Create and return the Coordinator for this UIViewControllerRepresentable.
    func makeCoordinator() -> ImagePickerCoordinator {
        return ImagePickerCoordinator(viewModel: viewModel)
    }

    // Creates the UIViewController (UIImagePickerController) for this representable.
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType //Source is defined when imagePicker is initialized
        picker.delegate = context.coordinator // Set the delegate to the coordinator
        return picker
    }

    // Updates the UIViewController when the SwiftUI view changes.
    // This is called when SwiftUI's state changes and need to reflect in UIKit
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: Context) {}
}

// MARK: - ContentView (SwiftUI)

struct NVIDIA_New_Model_Testing_View: View {
    @StateObject private var viewModel = ImageUploadViewModel()

    var body: some View {
        NavigationView { // Use a NavigationView for the main content.
            VStack { // Use a Vertical Stack to layout the image, buttons, and response.
                // Display the selected image (or a placeholder).
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                } else {
                    Text("No Image Selected")
                        .frame(width: 300, height: 300)
                }

                // Buttons to choose the image source.
                HStack { // Horizontal layout for selection
                    Button("Choose from Library") {
                        viewModel.isShowingImagePicker = true
                        viewModel.isShowingCamera = false
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    Button("Take Photo") {
                        viewModel.isShowingImagePicker = true
                        viewModel.isShowingCamera = true
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                // Button to upload the image.
                Button("Upload Image") {
                    viewModel.uploadImage()
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(viewModel.image == nil || viewModel.isLoading)

                // Display loader while waiting for response
                if viewModel.isLoading {
                    ProgressView() // UIKit, built in indicator
                }

                // Display the API response.
                if let response = viewModel.apiResponse {
                    // Use ScrollView and VStack, in case the data size is large
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text("API Response:")
                                .font(.headline)
                            Text(String(describing: response))
                                .font(.subheadline)
                        }
                        .padding()
                    }

                }
                // Display the error message.
                if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer() // Push content to the top
            }
            // Present the image picker when `isShowingImagePicker` is true.
            // This is a modal presentation.
            .sheet(isPresented: $viewModel.isShowingImagePicker) {
                if viewModel.isShowingCamera {
                    ImagePicker(viewModel: viewModel, sourceType: .camera)
                } else {
                    ImagePicker(viewModel: viewModel, sourceType: .photoLibrary)
                }
            }
            .navigationTitle("Image Uploader") // Set
        }
    }
}

struct NVIDIA_New_Model_Testing_View_Previews: PreviewProvider {
    static var previews: some View {
        NVIDIA_New_Model_Testing_View()
    }
}
