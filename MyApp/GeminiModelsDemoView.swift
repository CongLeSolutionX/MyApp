////
////  GeminiModelsDemoView.swift
////  MyApp
////
////  Created by Cong Le on 3/30/25.
////
//
//import SwiftUI
//import GoogleGenerativeAI
//import PhotosUI // For PhotosPicker
//
//// MARK: - Configuration & Constants
//
//// !!! --- IMPORTANT: Replace with your actual API Key --- !!!
//// --- DO NOT HARDCODE IN PRODUCTION ---
//let geminiAPIKey = "YOUR_API_KEY"
//// !!! ---------------------------------------------- !!!
//
//enum AppError: Error, LocalizedError {
//    case apiKeyMissing
//    case imageSelectionFailed
//    case videoSelectionFailed
//    case fileUploadFailed(String)
//    case fileProcessingFailed(String)
//    case fileDeletionFailed(String)
//    case fileListingFailed(String)
//    case generationFailed(String)
//    case invalidURL
//    case parsingError(String)
//    case featureNotFullyImplemented(String)
//
//    var errorDescription: String? {
//        switch self {
//        case .apiKeyMissing: return "API Key is missing. Please configure it."
//        case .imageSelectionFailed: return "Failed to load the selected image."
//        case .videoSelectionFailed: return "Failed to load the selected video."
//        case .fileUploadFailed(let msg): return "File Upload Failed: \(msg)"
//        case .fileProcessingFailed(let msg): return "File Processing Failed: \(msg)"
//        case .fileDeletionFailed(let msg): return "File Deletion Failed: \(msg)"
//        case .fileListingFailed(let msg): return "File Listing Failed: \(msg)"
//        case .generationFailed(let msg): return "Content Generation Failed: \(msg)"
//        case .invalidURL: return "The provided URL is invalid."
//        case .parsingError(let msg): return "Failed to parse response: \(msg)"
//        case .featureNotFullyImplemented(let msg): return "Feature Note: \(msg)"
//        }
//    }
//}
//
//// MARK: - Main Application Struct
//
//@main
//struct GeminiVisionApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .onAppear {
//                    if geminiAPIKey == "YOUR_API_KEY" || geminiAPIKey.isEmpty {
//                         print("WARNING: Gemini API Key not set. Please replace 'YOUR_API_KEY'.")
//                         // Optionally show an alert or disable functionality
//                    }
//                }
//        }
//    }
//}
//
//// MARK: - Core Content View
//
//struct ContentView: View {
//    var body: some View {
//        NavigationStack {
//            List {
//                Section("Image Capabilities") {
//                    CapabilityCard(
//                        title: "Image Query",
//                        description: "Ask questions about a single image.",
//                        destination: ImageQueryView()
//                    )
//                    CapabilityCard(
//                        title: "Multi-Image Query",
//                        description: "Ask questions about multiple images.",
//                        destination: MultiImageQueryView()
//                    )
//                    CapabilityCard(
//                        title: "Object Detection",
//                        description: "Get bounding boxes for objects in an image.",
//                        destination: ObjectDetectionView()
//                    )
//                }
//
//                Section("Video Capabilities") {
//                     CapabilityCard(
//                        title: "Video Summary",
//                        description: "Summarize a video file or YouTube URL.",
//                        destination: VideoSummaryView()
//                    )
//                     CapabilityCard(
//                        title: "Video Transcription & Description",
//                        description: "Transcribe audio and describe visuals in a video.",
//                        destination: VideoTranscriptionView()
//                    )
//                     CapabilityCard(
//                        title: "Video Timestamp Query",
//                        description: "Ask questions about specific timestamps in a video.",
//                        destination: VideoTimestampQueryView()
//                    )
//                }
//
//                 Section("File API Management") {
//                     CapabilityCard(
//                        title: "Upload & Use File",
//                        description: "Upload a large image/video via File API and query it.",
//                        destination: FileAPIUploadView()
//                    )
//                    CapabilityCard(
//                        title: "List & Delete Files",
//                        description: "Manage files previously uploaded via the File API.",
//                        destination: FileManagementView()
//                    )
//                 }
//                 
//                 Section("Notes") {
//                     Text("PDF processing mentioned in docs but lacks specific examples for generateContent. File API can upload them.")
//                         .font(.caption)
//                         .foregroundColor(.secondary)
//                     Text("Ensure Photo Library permissions are granted in Info.plist.")
//                         .font(.caption)
//                         .foregroundColor(.secondary)
//                 }
//            }
//            .navigationTitle("Gemini Vision")
//            .listStyle(.insetGrouped)
//        }
//    }
//}
//
//// MARK: - Reusable Card View
//
//struct CapabilityCard<Destination: View>: View {
//    let title: String
//    let description: String
//    let destination: Destination
//
//    var body: some View {
//        NavigationLink(destination: destination) {
//            VStack(alignment: .leading) {
//                Text(title).font(.headline)
//                Text(description)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            .padding(.vertical, 5) // Add some vertical padding inside the link
//        }
//    }
//}
//
//// MARK: - Image Capability Views
//
//struct ImageQueryView: View {
//    @State private var prompt: String = "What is this image?"
//    @State private var selectedImageItem: PhotosPickerItem?
//    @State private var selectedUIImage: UIImage?
//    @State private var responseText: String = ""
//    @State private var isLoading: Bool = false
//    @State private var errorMessage: String?
//
//    // B64 / URL Input (Optional, added for completeness)
//    @State private var imageUrl: String = ""
//    @State private var useUrlInput: Bool = false
//
//    private var apiClient: GenerativeModel? {
//        guard !geminiAPIKey.isEmpty, geminiAPIKey != "YOUR_API_KEY" else {
//            errorMessage = AppError.apiKeyMissing.localizedDescription
//            return nil
//        }
//        // Model selection can be dynamic, using 1.5 Flash as default
//        return GenerativeModel(name: "gemini-1.5-flash", apiKey: geminiAPIKey)
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 15) {
//                Text("Select an Image or provide URL")
//                    .font(.headline)
//
//                Toggle("Use Image URL/Base64", isOn: $useUrlInput)
//
//                if useUrlInput {
//                     TextField("Enter Image URL", text: $imageUrl)
//                         .textFieldStyle(.roundedBorder)
//                         .autocapitalization(.none)
//                         .disableAutocorrection(true)
//                     Text("Or paste Base64 string in prompt (less common for UI)")
//                         .font(.caption)
//                         .foregroundColor(.gray)
//                } else {
//                    PhotosPicker(selection: $selectedImageItem, matching: .images) {
//                        Label("Select Image", systemImage: "photo")
//                    }
//                    .onChange(of: selectedImageItem) { newItem in
//                        Task { await loadImage(from: newItem) }
//                    }
//
//                    if let selectedUIImage {
//                        Image(uiImage: selectedUIImage)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(maxHeight: 200)
//                            .cornerRadius(8)
//                            .overlay(
//                               RoundedRectangle(cornerRadius: 8)
//                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
//                            )
//                    }
//                }
//
//
//                Text("Enter Prompt")
//                    .font(.headline)
//
//                TextEditor(text: $prompt)
//                     .frame(height: 100)
//                     .border(Color.gray.opacity(0.3))
//                     .cornerRadius(5)
//
//
//                Button("Generate Response") {
//                    Task { await generateResponse() }
//                }
//                .buttonStyle(.borderedProminent)
//                .disabled(isLoading || (selectedUIImage == nil && imageUrl.isEmpty && !useUrlInput && !prompt.contains("data:image"))) // Basic check
//
//                if isLoading {
//                    ProgressView()
//                        .padding(.top)
//                }
//
//                if !responseText.isEmpty {
//                    Text("Response:")
//                        .font(.headline)
//                        .padding(.top)
//                    Text(responseText)
//                        .padding()
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(8)
//                        .textSelection(.enabled)
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("Image Query")
//        .alert("Error", isPresented: .constant(errorMessage != nil), actions: {
//            Button("OK") { errorMessage = nil }
//        }, message: {
//            Text(errorMessage ?? "An unknown error occurred.")
//        })
//    }
//
//    func loadImage(from item: PhotosPickerItem?) async {
//        guard let item = item else { return }
//        do {
//            if let data = try await item.loadTransferable(type: Data.self) {
//                if let uiImage = UIImage(data: data) {
//                    selectedUIImage = uiImage
//                    errorMessage = nil // Clear previous errors
//                    return
//                }
//            }
//            throw AppError.imageSelectionFailed
//        } catch {
//            selectedUIImage = nil
//            errorMessage = error.localizedDescription
//        }
//    }
//
//    func generateResponse() async {
//        guard let model = apiClient else { return } // API Key checked in computed property
//
//        isLoading = true
//        responseText = ""
//        errorMessage = nil
//
//        do {
//            var parts: [ModelContent.Part] = []
//
//            if useUrlInput {
//                guard let url = URL(string: imageUrl) else {
//                    throw AppError.invalidURL
//                }
//                 // Download image data from URL
//                 let (data, response) = try await URLSession.shared.data(from: url)
//                 guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                     throw URLError(.badServerResponse)
//                 }
//                 guard let mimeType = response.mimeType, mimeType.hasPrefix("image/") else {
//                    throw AppError.generationFailed("Invalid MimeType from URL: \(response.mimeType ?? "Unknown")")
//                }
//
//                 // Add downloaded image data
//                 parts.append(.data(mimetype: mimeType, data))
//
//            } else if let uiImage = selectedUIImage {
//                 // Convert UIImage to Data (JPEG for broad compatibility)
//                 guard let imageData = uiImage.jpegData(compressionQuality: 0.8) else {
//                     throw AppError.generationFailed("Could not convert image to data.")
//                 }
//                 // Add image data
//                 parts.append(.data(mimetype: "image/jpeg", imageData))
//             }
//             // --- Add Base64 Handling Here if needed ---
//             // This UI focuses on picker/URL, but you could parse `prompt`
//             // for "data:image/..." strings if required.
//
//            // Add the text prompt *after* the image(s) as per best practices
//            parts.append(.text(prompt))
//
//            guard !parts.filter({ !$0.isText }).isEmpty else {
//                throw AppError.generationFailed("No image provided or loaded.")
//            }
//
//            let response = try await model.generateContent(parts)
//
//            if let text = response.text {
//                responseText = text
//            } else {
//                 responseText = "Model did not return text."
//             }
//
//        } catch {
//            errorMessage = "Generation Error: \(error.localizedDescription)"
//             print("Error details: \(error)") // Log detailed error
//        }
//
//        isLoading = false
//    }
//}
//
//struct MultiImageQueryView: View {
//    @State private var prompt: String = "What do these images have in common?"
//    @State private var selectedImageItems: [PhotosPickerItem] = []
//    @State private var selectedUIImages: [UIImage] = []
//    @State private var responseText: String = ""
//    @State private var isLoading: Bool = false
//    @State private var errorMessage: String?
//
//    private var apiClient: GenerativeModel? {
//        guard !geminiAPIKey.isEmpty, geminiAPIKey != "YOUR_API_KEY" else {
//            errorMessage = AppError.apiKeyMissing.localizedDescription
//            return nil
//        }
//        return GenerativeModel(name: "gemini-1.5-flash", apiKey: geminiAPIKey)
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 15) {
//                Text("Select Multiple Images")
//                    .font(.headline)
//
//                PhotosPicker(selection: $selectedImageItems, maxSelectionCount: 10, matching: .images) { // Limit selection count reasonably
//                    Label("Select Images", systemImage: "photo.on.rectangle.angled")
//                }
//                .onChange(of: selectedImageItems) { newItems in
//                    Task { await loadImages(from: newItems) }
//                }
//
//                ScrollView(.horizontal, showsIndicators: false) {
//                     HStack {
//                         ForEach(selectedUIImages.indices, id: \.self) { index in
//                             Image(uiImage: selectedUIImages[index])
//                                 .resizable()
//                                 .scaledToFit()
//                                 .frame(height: 100)
//                                 .cornerRadius(6)
//                                 .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.5), lineWidth: 1))
//                         }
//                     }
//                 }
//                 .frame(height: selectedUIImages.isEmpty ? 0 : 110) // Hide if empty
//
//
//                Text("Enter Prompt")
//                    .font(.headline)
//
//                TextEditor(text: $prompt)
//                    .frame(height: 100)
//                    .border(Color.gray.opacity(0.3))
//                    .cornerRadius(5)
//
//                Button("Generate Response") {
//                    Task { await generateResponse() }
//                }
//                .buttonStyle(.borderedProminent)
//                .disabled(isLoading || selectedUIImages.count < 2) // Need at least 2 images
//
//                if isLoading {
//                    ProgressView().padding(.top)
//                }
//
//                if !responseText.isEmpty {
//                    Text("Response:")
//                        .font(.headline)
//                        .padding(.top)
//                    Text(responseText)
//                         .padding()
//                         .background(Color.gray.opacity(0.1))
//                         .cornerRadius(8)
//                         .textSelection(.enabled)
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("Multi-Image Query")
//        .alert("Error", isPresented: .constant(errorMessage != nil), actions: {
//            Button("OK") { errorMessage = nil }
//        }, message: {
//            Text(errorMessage ?? "An unknown error occurred.")
//        })
//    }
//
//    func loadImages(from items: [PhotosPickerItem]) async {
//        isLoading = true // Use loading state during image loading too
//        var loadedImages: [UIImage] = []
//        errorMessage = nil
//        do {
//            for item in items {
//                if let data = try await item.loadTransferable(type: Data.self),
//                   let uiImage = UIImage(data: data) {
//                    loadedImages.append(uiImage)
//                }
//            }
//            // Limit total images for performance/token reasons if needed
//            // loadedImages = Array(loadedImages.prefix(MAX_IMAGES))
//            selectedUIImages = loadedImages
//            if loadedImages.isEmpty && !items.isEmpty {
//                 throw AppError.imageSelectionFailed
//            }
//        } catch {
//            selectedUIImages = [] // Clear on error
//            errorMessage = "Failed to load one or more images: \(error.localizedDescription)"
//        }
//         isLoading = false
//    }
//
//    func generateResponse() async {
//         guard let model = apiClient else { return }
//         guard !selectedUIImages.isEmpty else {
//             errorMessage = "Please select at least two images."
//             return
//         }
//
//        isLoading = true
//        responseText = ""
//        errorMessage = nil
//
//        do {
//            var parts: [ModelContent.Part] = []
//
//            // Add all selected images
//            for uiImage in selectedUIImages {
//                 guard let imageData = uiImage.jpegData(compressionQuality: 0.8) else {
//                    print("Warning: Could not convert one of the images to data.")
//                    continue // Skip this image if conversion fails
//                 }
//                 parts.append(.data(mimetype: "image/jpeg", imageData))
//             }
//
//             // Add the text prompt *after* the images
//             parts.append(.text(prompt))
//
//             guard parts.count > 1 else { // Make sure we have images + prompt
//                 throw AppError.generationFailed("Failed to prepare image data.")
//             }
//
//            let response = try await model.generateContent(parts)
//
//            if let text = response.text {
//                responseText = text
//            } else {
//                 responseText = "Model did not return text."
//             }
//
//        } catch {
//             errorMessage = "Generation Error: \(error.localizedDescription)"
//             print("Error details: \(error)")
//        }
//
//        isLoading = false
//    }
//}
//
//// MARK: - Object Detection View
//
//struct BoundingBox: Identifiable, Hashable {
//    let id = UUID()
//    let ymin: CGFloat
//    let xmin: CGFloat
//    let ymax: CGFloat
//    let xmax: CGFloat
//    let label: String? // Optional label if model provides one
//
//     // Initializer for normalized 0-1000 coordinates
//     init?(coords: [Int], label: String? = nil) {
//         guard coords.count == 4 else { return nil }
//         // Normalize from 0-1000 range to 0-1 range
//         self.ymin = CGFloat(coords[0]) / 1000.0
//         self.xmin = CGFloat(coords[1]) / 1000.0
//         self.ymax = CGFloat(coords[2]) / 1000.0
//         self.xmax = CGFloat(coords[3]) / 1000.0
//         self.label = label
//     }
//
//     // Get frame in the image's coordinate system (origin top-left)
//     func frame(in imageSize: CGSize) -> CGRect {
//         let originX = xmin * imageSize.width
//         let originY = ymin * imageSize.height
//         let width = (xmax - xmin) * imageSize.width
//         let height = (ymax - ymin) * imageSize.height
//         return CGRect(x: originX, y: originY, width: width, height: height)
//     }
// }
//
// struct ObjectDetectionView: View {
//     @State private var prompt: String = "Return a bounding box for each object in this image in [ymin, xmin, ymax, xmax] format. Example: object1: [100, 200, 500, 600]" // Be explicit in prompt
//     @State private var selectedImageItem: PhotosPickerItem?
//     @State private var selectedUIImage: UIImage?
//     @State private var responseText: String = ""
//     @State private var boundingBoxes: [BoundingBox] = []
//     @State private var isLoading: Bool = false
//     @State private var errorMessage: String?
//
//     // Use a model known to be good at structured output if possible (Pro often better)
//     private var apiClient: GenerativeModel? {
//         guard !geminiAPIKey.isEmpty, geminiAPIKey != "YOUR_API_KEY" else {
//             errorMessage = AppError.apiKeyMissing.localizedDescription
//             return nil
//         }
//         // Gemini 1.5 Pro is mentioned in the example
//         return GenerativeModel(name: "gemini-1.5-pro", apiKey: geminiAPIKey)
//     }
//
//     var body: some View {
//         ScrollView {
//             VStack(alignment: .leading, spacing: 15) {
//                 Text("Select an Image")
//                     .font(.headline)
//
//                 PhotosPicker(selection: $selectedImageItem, matching: .images) {
//                     Label("Select Image", systemImage: "photo")
//                 }
//                 .onChange(of: selectedImageItem) { newItem in
//                     Task { await loadImage(from: newItem) }
//                 }
//
//                 if let selectedUIImage {
//                     Image(uiImage: selectedUIImage)
//                         .resizable()
//                         .scaledToFit()
//                         .frame(maxHeight: 300)
//                         .cornerRadius(8)
//                         .overlay(GeometryReader { geometry in // Use GeometryReader to get size for drawing
//                             ForEach(boundingBoxes) { box in
//                                 Rectangle()
//                                     .stroke(Color.red, lineWidth: 2)
//                                     .frame(
//                                         width: box.frame(in: geometry.size).width,
//                                         height: box.frame(in: geometry.size).height
//                                     )
//                                     .offset(
//                                         x: box.frame(in: geometry.size).minX,
//                                         y: box.frame(in: geometry.size).minY
//                                     )
//                                 // Optionally add label text here near the box
//                             }
//                         })
//                         .overlay(
//                              RoundedRectangle(cornerRadius: 8)
//                                 .stroke(Color.gray.opacity(0.5), lineWidth: 1)
//                         )
//
//                 }
//
//                 Text("Enter Prompt (be specific about format)")
//                     .font(.headline)
//
//                 TextEditor(text: $prompt)
//                      .frame(height: 100)
//                      .border(Color.gray.opacity(0.3))
//                      .cornerRadius(5)
//
//                 Button("Detect Objects") {
//                     Task { await generateBoundingBoxes() }
//                 }
//                 .buttonStyle(.borderedProminent)
//                 .disabled(isLoading || selectedUIImage == nil)
//
//                 if isLoading {
//                     ProgressView().padding(.top)
//                 }
//
//                 if !responseText.isEmpty {
//                     Text("Raw Response:")
//                         .font(.headline)
//                         .padding(.top)
//                     Text(responseText)
//                          .padding()
//                          .background(Color.gray.opacity(0.1))
//                          .cornerRadius(8)
//                          .textSelection(.enabled)
//                          .font(.caption) // Raw response potentially long
//                 }
//             }
//             .padding()
//         }
//         .navigationTitle("Object Detection")
//         .alert("Error", isPresented: .constant(errorMessage != nil), actions: {
//             Button("OK") { errorMessage = nil }
//         }, message: {
//             Text(errorMessage ?? "An unknown error occurred.")
//         })
//     }
//
//      func loadImage(from item: PhotosPickerItem?) async {
//         guard let item = item else { return }
//         // Reset state when new image is selected
//         selectedUIImage = nil
//         boundingBoxes = []
//         responseText = ""
//         errorMessage = nil
//         isLoading = true // Show loading while image loads
//
//         do {
//             if let data = try await item.loadTransferable(type: Data.self) {
//                 if let uiImage = UIImage(data: data) {
//                     selectedUIImage = uiImage
//                     isLoading = false
//                     return
//                 }
//             }
//             throw AppError.imageSelectionFailed
//         } catch {
//             errorMessage = error.localizedDescription
//         }
//         isLoading = false
//     }
//
//
//     func generateBoundingBoxes() async {
//         guard let model = apiClient else { return }
//         guard let uiImage = selectedUIImage else {
//             errorMessage = "Please select an image first."
//             return
//         }
//
//         isLoading = true
//         responseText = ""
//         boundingBoxes = []
//         errorMessage = nil
//
//         do {
//             guard let imageData = uiImage.jpegData(compressionQuality: 0.8) else {
//                 throw AppError.generationFailed("Could not convert image to data.")
//             }
//
//            // Construct the prompt with the image first, then text
//             let parts: [ModelContent.Part] = [
//                 .data(mimetype: "image/jpeg", imageData),
//                 .text(prompt)
//             ]
//
//            let response = try await model.generateContent(parts)
//
//             if let text = response.text {
//                 responseText = text
//                 // Attempt to parse the bounding boxes from the text response
//                 boundingBoxes = parseBoundingBoxes(from: text)
//                 if boundingBoxes.isEmpty && !text.isEmpty && !text.lowercased().contains("no objects") {
//                     // Parsing might have failed or format was unexpected
//                     print("Warning: Received text but failed to parse bounding boxes: \(text)")
//                    // errorMessage = AppError.parsingError("Could not extract boxes from response.").localizedDescription
//                 }
//             } else {
//                 responseText = "Model did not return text."
//              }
//
//         } catch {
//             errorMessage = "Generation Error: \(error.localizedDescription)"
//              print("Error details: \(error)")
//         }
//
//         isLoading = false
//     }
//
//    // Simple text parsing - This is FRAGILE and likely needs refinement based on actual model output
//    func parseBoundingBoxes(from text: String) -> [BoundingBox] {
//         var boxes: [BoundingBox] = []
//         // Regex to find patterns like `[int, int, int, int]`
//         let regex = try? NSRegularExpression(pattern: #"\\[\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\\]"#, options: [])
//
//         guard let regex = regex else {
//              print("Error creating regex for bounding box parsing.")
//             return []
//         }
//
//         let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
//         let matches = regex.matches(in: text, options: [], range: nsRange)
//
//         for match in matches {
//             guard match.numberOfRanges == 5 else { continue } // Full match + 4 capture groups
//
//             var coords: [Int] = []
//             for i in 1...4 { // Capture groups start at index 1
//                 let range = match.range(at: i)
//                 if let swiftRange = Range(range, in: text) {
//                     if let coord = Int(text[swiftRange]) {
//                         coords.append(coord)
//                     } else {
//                         coords = [] // Invalid number found
//                         break
//                     }
//                 } else {
//                    coords = [] // Invalid range
//                     break
//                 }
//             }
//
//            if coords.count == 4, let box = BoundingBox(coords: coords) {
//                 boxes.append(box)
//             }
//         }
//
//         return boxes
//     }
// }
//
//// MARK: - Video Capability Views
//
//struct VideoSummaryView: View {
//    @State private var prompt: String = "Summarize this video."
//    @State private var selectedVideoItem: PhotosPickerItem?
//    @State private var selectedVideoURL: URL? // For local file reference
//    @State private var youTubeURL: String = ""
//    @State private var useYouTube: Bool = false
//    @State private var responseText: String = ""
//    @State private var isLoading: Bool = false
//    @State private var errorMessage: String?
//    @State private var uploadProgress: String? = nil // For File API status
//
//    // Use a model that supports video input
//    private var apiClient: GenerativeModel? {
//         guard !geminiAPIKey.isEmpty, geminiAPIKey != "YOUR_API_KEY" else {
//             errorMessage = AppError.apiKeyMissing.localizedDescription
//             return nil
//         }
//         return GenerativeModel(name: "gemini-1.5-pro", apiKey: geminiAPIKey) // 1.5 Pro supports longer video
//     }
//
//     // File API client (can be the same model instance)
//      private var fileApiClient: GenerativeModel? { apiClient }
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 15) {
//                Text("Select Video or YouTube URL")
//                    .font(.headline)
//
//                Toggle("Use YouTube URL", isOn: $useYouTube)
//
//                if useYouTube {
//                     TextField("Enter YouTube URL", text: $youTubeURL)
//                         .textFieldStyle(.roundedBorder)
//                         .autocapitalization(.none)
//                         .disableAutocorrection(true)
//                } else {
//                    PhotosPicker(selection: $selectedVideoItem, matching: .videos) {
//                         Label("Select Video File", systemImage: "video")
//                     }
//                     .onChange(of: selectedVideoItem) { newItem in
//                         Task { await loadVideo(from: newItem) }
//                     }
//                    if let url = selectedVideoURL {
//                        Text("Selected: \(url.lastPathComponent)")
//                            .font(.caption)
//                            .lineLimit(1)
//                            // Optionally show a video preview if needed using AVKit
//                    }
//                }
//
//                 Text("Enter Prompt")
//                     .font(.headline)
//
//                 TextEditor(text: $prompt)
//                      .frame(height: 100)
//                      .border(Color.gray.opacity(0.3))
//                      .cornerRadius(5)
//
//                 Button("Generate Summary") {
//                     Task { await generateSummary() }
//                 }
//                 .buttonStyle(.borderedProminent)
//                 .disabled(isLoading || (selectedVideoURL == nil && youTubeURL.isEmpty))
//
//                 if isLoading {
//                    VStack {
//                        ProgressView()
//                        if let progress = uploadProgress {
//                             Text(progress)
//                                 .font(.caption)
//                                 .foregroundColor(.secondary)
//                                 .padding(.top, 5)
//                         }
//                     }
//                     .padding(.top)
//                 }
//
//                 if !responseText.isEmpty {
//                     Text("Response:")
//                         .font(.headline)
//                         .padding(.top)
//                     Text(responseText)
//                          .padding()
//                          .background(Color.gray.opacity(0.1))
//                          .cornerRadius(8)
//                          .textSelection(.enabled)
//                 }
//            }
//            .padding()
//        }
//        .navigationTitle("Video Summary")
//        .alert("Error", isPresented: .constant(errorMessage != nil), actions: {
//            Button("OK") { errorMessage = nil }
//        }, message: {
//            Text(errorMessage ?? "An unknown error occurred.")
//        })
//    }
//
//     func loadVideo(from item: PhotosPickerItem?) async {
//        guard let item = item else { return }
//         selectedVideoURL = nil // Reset
//         errorMessage = nil
//         isLoading = true // Show loading for file copy
//
//         do {
//             // Get a temporary URL for the selected video
//             let loadedData = try await item.loadTransferable(type: VideoDataContainer.self)
//             selectedVideoURL = loadedData.url // Keep the URL for potential File API upload
//             print("Video loaded to temporary URL: \(selectedVideoURL!)")
//         } catch {
//             errorMessage = "Failed to load video: \(error.localizedDescription)"
//         }
//         isLoading = false
//     }
//
//     // Helper struct to load video URL easily
//     struct VideoDataContainer: Transferable {
//         let url: URL
//         static var transferRepresentation: some TransferRepresentation {
//             FileRepresentation(contentType: .movie) { movie in
//                 SentTransferredFile(movie.url)
//             } importing: { received in
//                 // Copy to a temporary location to ensure we have access
//                 let tempDir = FileManager.default.temporaryDirectory
//                 let fileName = "\(UUID().uuidString).\(received.file.pathExtension)"
//                 let tempURL = tempDir.appendingPathComponent(fileName)
//                 try FileManager.default.copyItem(at: received.file, to: tempURL)
//                 print("Copied video to: \(tempURL)")
//                 return Self.init(url: tempURL)
//             }
//         }
//     }
//
//
//     func generateSummary() async {
//         guard let model = apiClient else { return }
//         isLoading = true
//         responseText = ""
//         errorMessage = nil
//         uploadProgress = nil
//
//         do {
//             var videoPart: ModelContent.Part?
//
//             if useYouTube {
//                 guard let url = URL(string: youTubeURL),
//                       youTubeURL.contains("youtube.com/watch?v=") || youTubeURL.contains("youtu.be/") else {
//                     throw AppError.invalidURL // Basic check
//                 }
//                 // Use fileData for YouTube URLs
//                 videoPart = .fileData(mimetype: "video/youtube", uri: url.absoluteString) // Docs example uses file_uri, matching that
//
//             } else if let localURL = selectedVideoURL {
//                  // Decide whether to upload inline or via File API based on size (approximate)
//                 let fileAttributes = try FileManager.default.attributesOfItem(atPath: localURL.path)
//                 let fileSize = fileAttributes[.size] as? Int64 ?? 0
//                 let maxSizeInline: Int64 = 20 * 1024 * 1024 // 20MB
//
//                 if fileSize > 0 && fileSize < maxSizeInline {
//                     // Upload Inline
//                     uploadProgress = "Reading video data for inline upload..."
//                     let videoData = try Data(contentsOf: localURL)
//                     // Get MIME type (needs refinement for robustness)
//                     let mimeType = getMimeType(for: localURL) ?? "video/mp4" // Default or use UTType
//                     videoPart = .data(mimetype: mimeType, videoData)
//                     uploadProgress = "Using inline video data."
//
//                 } else if fileSize >= maxSizeInline {
//                     // Upload via File API
//                     guard let fileAPIModel = fileApiClient else { throw AppError.apiKeyMissing }
//                     uploadProgress = "Uploading video via File API (size: \(ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)))..."
//                     let uploadedFile = try await fileAPIModel.uploadFile(url: localURL, mimeType: getMimeType(for: localURL))
//                     uploadProgress = "Upload complete. URI: \(uploadedFile.uri). Waiting for processing..."
//
//                     // Poll for ACTIVE state with timeout
//                     let startTime = Date()
//                     var currentFile = uploadedFile
//                     while currentFile.state == .processing {
//                         if Date().timeIntervalSince(startTime) > 300 { // 5 min timeout
//                             throw AppError.fileProcessingFailed("Timeout waiting for video processing.")
//                         }
//                         uploadProgress = "File State: PROCESSING (\(Int(Date().timeIntervalSince(startTime)))s)"
//                         try await Task.sleep(nanoseconds: 5_000_000_000) // Wait 5 seconds
//                         currentFile = try await fileAPIModel.getFile(name: uploadedFile.name)
//                     }
//
//                     if currentFile.state != .active {
//                         throw AppError.fileProcessingFailed("File processing finished with state: \(currentFile.state)")
//                     }
//                     uploadProgress = "File is ACTIVE. Generating summary..."
//                     videoPart = .file(uri: currentFile.uri) // Use the File API URI
//
//                 } else {
//                    throw AppError.videoSelectionFailed // File size is 0 or failed to read
//                }
//             }
//
//             guard let finalVideoPart = videoPart else {
//                 throw AppError.generationFailed("No valid video source provided.")
//             }
//
//             // Construct prompt: Video first, then text
//             let parts: [ModelContent.Part] = [finalVideoPart, .text(prompt)]
//             let response = try await model.generateContent(parts)
//
//             if let text = response.text {
//                 responseText = text
//             } else {
//                 responseText = "Model did not return text."
//             }
//
//         } catch {
//             errorMessage = "Generation Error: \(error.localizedDescription)"
//             print("Error details: \(error)")
//         }
//
//         isLoading = false
//         uploadProgress = nil // Clear progress message
//     }
//
//    // Helper to guess MIME type - improve with UTType in production
//       func getMimeType(for url: URL) -> String? {
//           // Basic mapping based on extension
//           switch url.pathExtension.lowercased() {
//           case "mp4": return "video/mp4"
//           case "mov": return "video/mov"
//           case "avi": return "video/avi"
//           case "mpeg", "mpg": return "video/mpeg"
//           case "webm": return "video/webm"
//           case "wmv": return "video/wmv"
//           case "flv": return "video/x-flv"
//           case "3gp", "3gpp": return "video/3gpp"
//           default: return nil // Let the API try to determine or default
//           }
//       }
//}
//
//struct VideoTranscriptionView: View {
//     // Similar state variables as VideoSummaryView but different prompt
//     @State private var prompt: String = "Transcribe the audio from this video, giving timestamps for salient events. Also provide visual descriptions (sampled at 1 FPS)."
//     @State private var selectedVideoItem: PhotosPickerItem?
//     @State private var selectedVideoURL: URL?
//     @State private var responseText: String = ""
//     @State private var isLoading: Bool = false
//     @State private var errorMessage: String?
//     @State private var uploadProgress: String? = nil
//
//     // Use same model as summary view
//     private var apiClient: GenerativeModel? {
//         guard !geminiAPIKey.isEmpty, geminiAPIKey != "YOUR_API_KEY" else {
//             errorMessage = AppError.apiKeyMissing.localizedDescription
//             return nil
//         }
//         return GenerativeModel(name: "gemini-1.5-pro", apiKey: geminiAPIKey)
//     }
//      private var fileApiClient: GenerativeModel? { apiClient }
//
//      var body: some View {
//         ScrollView {
//             VStack(alignment: .leading, spacing: 15) {
//                 Text("Select Video File")
//                     .font(.headline)
//
//                 PhotosPicker(selection: $selectedVideoItem, matching: .videos) {
//                     Label("Select Video", systemImage: "video")
//                 }
//                 .onChange(of: selectedVideoItem) { newItem in
//                     Task { await loadVideo(from: newItem) } // Reuse loadVideo
//                 }
//                  if let url = selectedVideoURL {
//                      Text("Selected: \(url.lastPathComponent)")
//                          .font(.caption)
//                          .lineLimit(1)
//                  }
//
//                  // Prompt is fixed for this view's purpose usually
//                 Text("Prompt:")
//                    .font(.headline)
//                 Text(prompt)
//                    .padding(8)
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(5)
//                    .font(.callout)
//
//
//                  Button("Transcribe & Describe") {
//                      Task { await generateTranscription() } // Call specific function
//                  }
//                  .buttonStyle(.borderedProminent)
//                  .disabled(isLoading || selectedVideoURL == nil)
//
//                  if isLoading {
//                     VStack {
//                         ProgressView()
//                         if let progress = uploadProgress {
//                              Text(progress)
//                                  .font(.caption)
//                                  .foregroundColor(.secondary)
//                                  .padding(.top, 5)
//                          }
//                      }
//                      .padding(.top)
//                  }
//
//                  if !responseText.isEmpty {
//                      Text("Output:")
//                          .font(.headline)
//                          .padding(.top)
//                      Text(responseText)
//                           .padding()
//                           .background(Color.gray.opacity(0.1))
//                           .cornerRadius(8)
//                           .textSelection(.enabled)
//                  }
//             }
//             .padding()
//         }
//         .navigationTitle("Video Transcription")
//         .alert("Error", isPresented: .constant(errorMessage != nil), actions: {
//             Button("OK") { errorMessage = nil }
//         }, message: {
//             Text(errorMessage ?? "An unknown error occurred.")
//         })
//     }
//
//      // Reuse loadVideo function from VideoSummaryView
//       func loadVideo(from item: PhotosPickerItem?) async {
//          guard let item = item else { return }
//          selectedVideoURL = nil
//          errorMessage = nil
//          isLoading = true
//
//          do {
//               let loadedData = try await item.loadTransferable(type: VideoSummaryView.VideoDataContainer.self) // Use helper struct
//               selectedVideoURL = loadedData.url
//               print("Video loaded to temporary URL: \(selectedVideoURL!)")
//          } catch {
//               errorMessage = "Failed to load video: \(error.localizedDescription)"
//          }
//          isLoading = false
//      }
//
//        // Reuse getMimeType function
//        func getMimeType(for url: URL) -> String? {
//           switch url.pathExtension.lowercased() {
//           case "mp4": return "video/mp4"
//           case "mov": return "video/mov"
//           case "avi": return "video/avi"
//           case "mpeg", "mpg": return "video/mpeg"
//           case "webm": return "video/webm"
//           case "wmv": return "video/wmv"
//           case "flv": return "video/x-flv"
//           case "3gp", "3gpp": return "video/3gpp"
//           default: return nil
//           }
//       }
//
//      // Reuse much of generateSummary logic, just change the prompt
//      func generateTranscription() async {
//          guard let model = apiClient else { return }
//          guard let localURL = selectedVideoURL else {
//              errorMessage = "Please select a video file."
//              return
//          }
//
//          isLoading = true
//          responseText = ""
//          errorMessage = nil
//          uploadProgress = nil
//
//          do {
//              var videoPart: ModelContent.Part?
//
//              let fileAttributes = try FileManager.default.attributesOfItem(atPath: localURL.path)
//              let fileSize = fileAttributes[.size] as? Int64 ?? 0
//              let maxSizeInline: Int64 = 20 * 1024 * 1024 // 20MB
//
//              if fileSize > 0 && fileSize < maxSizeInline {
//                  uploadProgress = "Reading video data for inline upload..."
//                  let videoData = try Data(contentsOf: localURL)
//                  let mimeType = getMimeType(for: localURL) ?? "video/mp4"
//                  videoPart = .data(mimetype: mimeType, videoData)
//                 uploadProgress = "Using inline video data."
//              } else if fileSize >= maxSizeInline {
//                  guard let fileAPIModel = fileApiClient else { throw AppError.apiKeyMissing }
//                  uploadProgress = "Uploading video via File API (size: \(ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)))..."
//                  let uploadedFile = try await fileAPIModel.uploadFile(url: localURL, mimeType: getMimeType(for: localURL))
//                  uploadProgress = "Upload complete. Waiting for processing..."
//
//                  // Poll for ACTIVE state
//                  let startTime = Date()
//                  var currentFile = uploadedFile
//                  while currentFile.state == .processing {
//                      if Date().timeIntervalSince(startTime) > 300 { throw AppError.fileProcessingFailed("Timeout") }
//                      uploadProgress = "File State: PROCESSING (\(Int(Date().timeIntervalSince(startTime)))s)"
//                      try await Task.sleep(nanoseconds: 5_000_000_000)
//                      currentFile = try await fileAPIModel.getFile(name: uploadedFile.name)
//                  }
//
//                  if currentFile.state != .active { throw AppError.fileProcessingFailed("State: \(currentFile.state)") }
//                   uploadProgress = "File is ACTIVE. Generating..."
//                  videoPart = .file(uri: currentFile.uri)
//
//              } else {
//                   throw AppError.videoSelectionFailed
//              }
//
//              guard let finalVideoPart = videoPart else {
//                  throw AppError.generationFailed("No valid video source prepared.")
//              }
//
//              // Use the specific prompt for transcription/description
//              let parts: [ModelContent.Part] = [finalVideoPart, .text(prompt)]
//              let response = try await model.generateContent(parts)
//
//             if let text = response.text {
//                 responseText = text
//             } else {
//                 responseText = "Model did not return text."
//             }
//
//          } catch {
//              errorMessage = "Generation Error: \(error.localizedDescription)"
//              print("Error details: \(error)")
//          }
//
//          isLoading = false
//          uploadProgress = nil
//      }
//}
//
//struct VideoTimestampQueryView: View {
//    // Again, similar state but focused prompt
//    @State private var timeStampPrompt: String = "What happens at 00:15?" // Example
//    @State private var selectedVideoItem: PhotosPickerItem?
//    @State private var selectedVideoURL: URL?
//    @State private var fileAPIUri: String? // Store URI after upload
//    @State private var responseText: String = ""
//    @State private var isLoading: Bool = false
//    @State private var errorMessage: String?
//    @State private var uploadProgress: String? = nil
//
//    // Use same model
//    private var apiClient: GenerativeModel? {
//        guard !geminiAPIKey.isEmpty, geminiAPIKey != "YOUR_API_KEY" else {
//            errorMessage = AppError.apiKeyMissing.localizedDescription
//            return nil
//        }
//        return GenerativeModel(name: "gemini-1.5-pro", apiKey: geminiAPIKey)
//    }
//    private var fileApiClient: GenerativeModel? { apiClient }
//
//    var body: some View {
//         ScrollView {
//             VStack(alignment: .leading, spacing: 15) {
//                 Text("Select Video File (will be uploaded via File API)")
//                     .font(.headline)
//
//                PhotosPicker(selection: $selectedVideoItem, matching: .videos) {
//                     Label("Select Video", systemImage: "video")
//                 }
//                 .onChange(of: selectedVideoItem) { newItem in
//                      fileAPIUri = nil // Reset URI when new video selected
//                     Task { await uploadForTimestamp(item: newItem) } // Upload immediately
//                 }
//                  if let url = selectedVideoURL {
//                      Text("Selected: \(url.lastPathComponent)")
//                          .font(.caption)
//                          .lineLimit(1)
//                  }
//                  if fileAPIUri != nil {
//                       Text("Video Ready (File API URI obtained)")
//                           .font(.caption).foregroundColor(.green)
//                   }
//
//                  Divider().padding(.vertical, 5)
//
//                  Text("Enter Prompt with Timestamp (MM:SS)")
//                      .font(.headline)
//
//                  TextEditor(text: $timeStampPrompt)
//                       .frame(height: 100)
//                       .border(Color.gray.opacity(0.3))
//                       .cornerRadius(5)
//                      // Add validation for MM:SS format if desired
//
//                  Button("Query Timestamp") {
//                      Task { await generateTimestampResponse() }
//                  }
//                  .buttonStyle(.borderedProminent)
//                  .disabled(isLoading || fileAPIUri == nil) // Enabled only after successful upload
//
//                  if isLoading {
//                      VStack {
//                          ProgressView()
//                          if let progress = uploadProgress {
//                               Text(progress)
//                                   .font(.caption)
//                                   .foregroundColor(.secondary)
//                                   .padding(.top, 5)
//                           }
//                       }
//                       .padding(.top)
//                  }
//
//                   if !responseText.isEmpty {
//                        Text("Response:")
//                            .font(.headline)
//                            .padding(.top)
//                        Text(responseText)
//                             .padding()
//                             .background(Color.gray.opacity(0.1))
//                             .cornerRadius(8)
//                             .textSelection(.enabled)
//                    }
//             }
//             .padding()
//         }
//         .navigationTitle("Video Timestamp Query")
//         .alert("Error", isPresented: .constant(errorMessage != nil), actions: {
//             Button("OK") { errorMessage = nil }
//         }, message: {
//             Text(errorMessage ?? "An unknown error occurred.")
//         })
//     }
//
//      // Need separate upload function as it's a prerequisite
//       func uploadForTimestamp(item: PhotosPickerItem?) async {
//           guard let item = item else { return }
//           guard let fileAPIModel = fileApiClient else {
//               errorMessage = AppError.apiKeyMissing.localizedDescription
//               return
//           }
//
//           selectedVideoURL = nil
//           fileAPIUri = nil // Reset URI
//           errorMessage = nil
//           isLoading = true
//           uploadProgress = "Loading video data..."
//
//           do {
//                // Load video to temp URL first
//               let loadedData = try await item.loadTransferable(type: VideoSummaryView.VideoDataContainer.self) // Reuse helper struct
//               let localURL = loadedData.url
//               selectedVideoURL = localURL // Update state for display
//                print("Video loaded to temporary URL: \(localURL)")
//
//                // --- Upload via File API ---
//               let fileAttributes = try FileManager.default.attributesOfItem(atPath: localURL.path)
//               let fileSize = fileAttributes[.size] as? Int64 ?? 0
//                uploadProgress = "Uploading video via File API (size: \(ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)))..."
//
//               let uploadedFile = try await fileAPIModel.uploadFile(url: localURL, mimeType: getMimeType(for: localURL))
//                uploadProgress = "Upload complete. Waiting for processing..."
//
//                 // Poll for ACTIVE state
//                let startTime = Date()
//                var currentFile = uploadedFile
//                while currentFile.state == .processing {
//                    if Date().timeIntervalSince(startTime) > 300 { throw AppError.fileProcessingFailed("Timeout") }
//                    uploadProgress = "File State: PROCESSING (\(Int(Date().timeIntervalSince(startTime)))s)"
//                    try await Task.sleep(nanoseconds: 5_000_000_000)
//                    currentFile = try await fileAPIModel.getFile(name: uploadedFile.name)
//                }
//
//                if currentFile.state != .active {
//                    throw AppError.fileProcessingFailed("File processing ended with state: \(currentFile.state)")
//                }
//
//                // Store the URI for later use
//                fileAPIUri = currentFile.uri
//                uploadProgress = "Video Ready for Querying."
//
//
//            } catch {
//                errorMessage = "Upload/Processing Error: \(error.localizedDescription)"
//                print("Error details: \(error)")
//                fileAPIUri = nil // Ensure URI is nil on error
//            }
//           isLoading = false
//           // Keep uploadProgress message if successful ("Video Ready...")
//           if errorMessage != nil { uploadProgress = nil }
//       }
//
//        // Reuse getMimeType function
//       func getMimeType(for url: URL) -> String? {
//          switch url.pathExtension.lowercased() {
//          case "mp4": return "video/mp4"
//          case "mov": return "video/mov"
//          case "avi": return "video/avi"
//          case "mpeg", "mpg": return "video/mpeg"
//          case "webm": return "video/webm"
//          case "wmv": return "video/wmv"
//          case "flv": return "video/x-flv"
//          case "3gp", "3gpp": return "video/3gpp"
//          default: return nil
//          }
//      }
//
//      func generateTimestampResponse() async {
//          guard let model = apiClient else { return }
//          guard let videoUri = fileAPIUri else {
//               errorMessage = "Video has not been successfully uploaded and processed yet."
//               return
//           }
//           // Basic check for MM:SS format in prompt
//           let timeRegex = "\\d{2}:\\d{2}"
//            guard timeStampPrompt.range(of: timeRegex, options: .regularExpression) != nil else {
//                errorMessage = "Prompt does not appear to contain a timestamp in MM:SS format."
//                return
//            }
//
//
//          isLoading = true
//          responseText = ""
//          errorMessage = nil
//          uploadProgress = "Querying timestamp..." // Update progress
//
//          do {
//                // Construct prompt: Video URI part first, then text
//               let videoPart = ModelContent.Part.file(uri: videoUri)
//               let textPart = ModelContent.Part.text(timeStampPrompt)
//               let parts = [videoPart, textPart]
//
//               let response = try await model.generateContent(parts)
//
//              if let text = response.text {
//                  responseText = text
//              } else {
//                  responseText = "Model did not return text."
//              }
//
//          } catch {
//              errorMessage = "Timestamp Query Error: \(error.localizedDescription)"
//              print("Error details: \(error)")
//          }
//
//         isLoading = false
//         uploadProgress = "Video Ready for Querying." // Reset progress message
//     }
//}
//
//// MARK: - File API Management Views
//
//struct FileAPIUploadView: View {
//     // State for selecting file, uploading, and querying
//      @State private var selectedItem: PhotosPickerItem?
//      @State private var selectedFileURL: URL?
//      @State private var fileAPIUri: String?
//      @State private var queryPrompt: String = "Describe this file."
//      @State private var responseText: String = ""
//      @State private var isLoading: Bool = false // Covers upload and query
//      @State private var errorMessage: String?
//      @State private var uploadProgress: String? = nil
//      @State private var selectedFilename: String = ""
//
//     // Use a general-purpose model
//      private var apiClient: GenerativeModel? {
//          guard !geminiAPIKey.isEmpty, geminiAPIKey != "YOUR_API_KEY" else {
//              errorMessage = AppError.apiKeyMissing.localizedDescription
//              return nil
//          }
//          return GenerativeModel(name: "gemini-1.5-flash", apiKey: geminiAPIKey)
//      }
//      // Explicitly use the same instance for file operations
//      private var fileApiClient: GenerativeModel? { apiClient }
//
//
//      var body: some View {
//          ScrollView {
//              VStack(alignment: .leading, spacing: 15) {
//                  Text("Upload Large File (Image/Video)")
//                       .font(.headline)
//
//                  PhotosPicker(selection: $selectedItem, matching: .any(of: [.images, .videos])) { // Allow images or videos
//                       Label("Select File", systemImage: "doc.badge.arrow.up")
//                   }
//                   .onChange(of: selectedItem) { newItem in
//                       fileAPIUri = nil // Reset
//                       responseText = ""
//                       Task { await uploadFile(item: newItem) }
//                   }
//
//                   Text("Selected: \(selectedFilename)")
//                       .font(.caption)
//                       .lineLimit(1)
//
//                   if fileAPIUri != nil {
//                       Text("File Uploaded & Processed!")
//                           .font(.caption).foregroundColor(.green)
//                       Text("URI: \(fileAPIUri!)")
//                            .font(.caption2).foregroundColor(.gray)
//                   }
//
//                  Divider().padding(.vertical, 5)
//
//                  Text("Query the Uploaded File")
//                      .font(.headline)
//
//                   TextEditor(text: $queryPrompt)
//                       .frame(height: 100)
//                       .border(Color.gray.opacity(0.3))
//                       .cornerRadius(5)
//
//                  Button("Generate Response from File") {
//                      Task { await generateFromFileAPI() }
//                  }
//                  .buttonStyle(.borderedProminent)
//                  .disabled(isLoading || fileAPIUri == nil) // Enabled only after successful upload
//
//                   if isLoading {
//                       VStack {
//                           ProgressView()
//                           if let progress = uploadProgress {
//                                Text(progress)
//                                    .font(.caption)
//                                    .foregroundColor(.secondary)
//                                    .padding(.top, 5)
//                            }
//                        }
//                        .padding(.top)
//                   }
//
//                    if !responseText.isEmpty {
//                         Text("Response:")
//                             .font(.headline)
//                             .padding(.top)
//                         Text(responseText)
//                              .padding()
//                              .background(Color.gray.opacity(0.1))
//                              .cornerRadius(8)
//                              .textSelection(.enabled)
//                     }
//              }
//              .padding()
//          }
//          .navigationTitle("File API Upload & Query")
//          .alert("Error", isPresented: .constant(errorMessage != nil), actions: {
//              Button("OK") { errorMessage = nil }
//          }, message: {
//              Text(errorMessage ?? "An unknown error occurred.")
//          })
//      }
//
//       // Combined Load & Upload Function
//       func uploadFile(item: PhotosPickerItem?) async {
//           guard let item = item else { return }
//            guard let fileAPIModel = fileApiClient else {
//                errorMessage = AppError.apiKeyMissing.localizedDescription
//                return
//            }
//
//           selectedFileURL = nil
//           fileAPIUri = nil
//           errorMessage = nil
//           isLoading = true
//           uploadProgress = "Loading file data..."
//           selectedFilename = item.itemIdentifier ?? "Unknown File" // Get filename early if possible
//
//           do {
//               // Determine type and load URL
//               let tempURL: URL
//               let detectedMimeType: String?
//
//               if let videoTransfer = try? await item.loadTransferable(type: VideoSummaryView.VideoDataContainer.self) {
//                   tempURL = videoTransfer.url
//                   detectedMimeType = getMimeType(for: tempURL) ?? "video/mp4" // Reuse MIME helper
//                   selectedFilename = tempURL.lastPathComponent // Update filename from temp URL
//               } else if let imageTransfer = try? await item.loadTransferable(type: Data.self) {
//                   // Save image data to a temporary file to get a URL
//                   let tempDir = FileManager.default.temporaryDirectory
//                   let ext = item.supportedContentTypes.first?.preferredFilenameExtension ?? "jpg"
//                   let fileName = "\(UUID().uuidString).\(ext)"
//                   let tempImgURL = tempDir.appendingPathComponent(fileName)
//                   try imageTransfer.write(to: tempImgURL)
//                   tempURL = tempImgURL
//                   detectedMimeType = item.supportedContentTypes.first?.preferredMIMEType ?? "image/jpeg"
//                    selectedFilename = tempURL.lastPathComponent
//               } else {
//                   throw AppError.featureNotFullyImplemented("Unsupported file type selected via PhotosPicker.")
//               }
//
//               selectedFileURL = tempURL // Store URL
//                print("File loaded to temporary URL: \(tempURL)")
//
//                // --- Upload via File API ---
//               let fileAttributes = try FileManager.default.attributesOfItem(atPath: tempURL.path)
//               let fileSize = fileAttributes[.size] as? Int64 ?? 0
//                uploadProgress = "Uploading file via File API (size: \(ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)))..."
//
//               let uploadedFile = try await fileAPIModel.uploadFile(url: tempURL, mimeType: detectedMimeType) // Pass detected MIME type
//                uploadProgress = "Upload complete. Waiting for processing..."
//
//                 // Poll for ACTIVE state
//                let startTime = Date()
//                var currentFile = uploadedFile
//                while currentFile.state == .processing {
//                    if Date().timeIntervalSince(startTime) > 300 { throw AppError.fileProcessingFailed("Timeout") }
//                    uploadProgress = "File State: PROCESSING (\(Int(Date().timeIntervalSince(startTime)))s)"
//                    try await Task.sleep(nanoseconds: 5_000_000_000)
//                    currentFile = try await fileAPIModel.getFile(name: uploadedFile.name)
//                }
//
//                if currentFile.state != .active {
//                    throw AppError.fileProcessingFailed("File processing ended with state: \(currentFile.state)")
//                }
//
//                // Store the URI
//                fileAPIUri = currentFile.uri
//                uploadProgress = "File Ready for Querying."
//
//                // Clean up temporary file (optional but good practice)
//                try? FileManager.default.removeItem(at: tempURL)
//
//            } catch {
//                errorMessage = "Upload/Processing Error: \(error.localizedDescription)"
//                print("Error details: \(error)")
//                fileAPIUri = nil
//                // Also try to clean up temp file on error
//                if let url = selectedFileURL { try? FileManager.default.removeItem(at: url) }
//            }
//           isLoading = false
//           if errorMessage != nil { uploadProgress = nil; selectedFilename = item.itemIdentifier ?? "Error Loading" }
//            else if fileAPIUri != nil { isLoading = false } // Stop loading only if successful
//       }
//
//
//        // Reuse getMimeType function
//        func getMimeType(for url: URL) -> String? {
//           // You might need a more robust way, perhaps using UTTypeIdentifiers
//           switch url.pathExtension.lowercased() {
//           // Video types
//           case "mp4": return "video/mp4"
//           case "mov": return "video/mov"
//           case "avi": return "video/avi"
//           case "mpeg", "mpg": return "video/mpeg"
//           case "webm": return "video/webm"
//           case "wmv": return "video/wmv"
//           case "flv": return "video/x-flv"
//           case "3gp", "3gpp": return "video/3gpp"
//           // Image types
//           case "png": return "image/png"
//           case "jpg", "jpeg": return "image/jpeg"
//           case "webp": return "image/webp"
//           case "heic": return "image/heic"
//           case "heif": return "image/heif"
//           default: return nil
//           }
//       }
//
//
//      func generateFromFileAPI() async {
//          guard let model = apiClient else { return }
//          guard let fileUri = fileAPIUri else {
//               errorMessage = "No file has been successfully uploaded and processed yet."
//               return
//           }
//
//           isLoading = true
//          responseText = ""
//          errorMessage = nil
//            uploadProgress = "Generating from uploaded file..." // Reuse progress indicator
//
//          do {
//               let filePart = ModelContent.Part.file(uri: fileUri)
//               let textPart = ModelContent.Part.text(queryPrompt)
//               let parts = [filePart, textPart] // File first, then prompt
//
//               let response = try await model.generateContent(parts)
//
//              if let text = response.text {
//                  responseText = text
//              } else {
//                  responseText = "Model did not return text."
//              }
//
//          } catch {
//              errorMessage = "Generation Error from File: \(error.localizedDescription)"
//              print("Error details: \(error)")
//          }
//
//          isLoading = false
//           if fileAPIUri != nil {
//                uploadProgress = "File Ready for Querying." // Reset progress message if file is still valid
//            } else {
//                uploadProgress = nil
//            }
//       }
//}
//
//
//struct FileManagementView: View {
//     @State private var uploadedFiles: [GoogleGenerativeAI.File] = []
//     @State private var isLoading: Bool = false
//     @State private var errorMessage: String?
//     @State private var statusMessage: String?
//
//     // Use a general-purpose model instance for file operations
//      private var fileApiClient: GenerativeModel? {
//          guard !geminiAPIKey.isEmpty, geminiAPIKey != "YOUR_API_KEY" else {
//              errorMessage = AppError.apiKeyMissing.localizedDescription
//              return nil
//          }
//          // Model name doesn't matter for file listing/deletion, just need configured client
//          return GenerativeModel(name: "gemini-1.5-flash", apiKey: geminiAPIKey)
//      }
//
//      var body: some View {
//          VStack {
//                if isLoading {
//                    ProgressView("Accessing File API...")
//                        .padding()
//                }
//
//                if let msg = statusMessage {
//                    Text(msg)
//                        .font(.caption)
//                        .foregroundColor(.green)
//                        .padding()
//                }
//
//
//               List {
//                   if uploadedFiles.isEmpty && !isLoading {
//                       Text("No files found or API key missing.")
//                           .foregroundColor(.secondary)
//                   } else {
//                       ForEach(uploadedFiles, id: \.name) { file in
//                           HStack {
//                               VStack(alignment: .leading) {
//                                    Text(file.displayName ?? file.name)
//                                        .font(.headline)
//                                        .lineLimit(1)
//                                    Text("URI: \(file.uri)")
//                                         .font(.caption2)
//                                         .foregroundColor(.gray)
//                                         .lineLimit(1)
//                                    Text("State: \(file.state.rawValue.capitalized)") // Display state
//                                        .font(.caption)
//                                        .foregroundColor(file.state == .active ? .green : .orange)
//                                    if let expiry = file.expirationTime {
//                                         Text("Expires: \(expiry, style: .relative) ago")
//                                             .font(.caption)
//                                             .foregroundColor(.secondary)
//                                     }
//                               }
//                               Spacer()
//                               Button {
//                                   Task { await deleteFile(name: file.name) }
//                               } label: {
//                                   Image(systemName: "trash")
//                                       .foregroundColor(.red)
//                               }
//                               .buttonStyle(.borderless) // Make button less intrusive in list row
//                          }
//                          .padding(.vertical, 4)
//                       }
//                   }
//               }
//               .listStyle(.plain)
//               .refreshable { // Allow pull-to-refresh
//                   await listFiles()
//               }
//
//               Spacer() // Push list up
//          }
//          .navigationTitle("Manage Files")
//          .onAppear {
//              Task { await listFiles() }
//          }
//          .alert("Error", isPresented: .constant(errorMessage != nil), actions: {
//               Button("OK") { errorMessage = nil }
//           }, message: {
//               Text(errorMessage ?? "An unknown error occurred.")
//           })
//           .alert("Status", isPresented: .constant(statusMessage != nil && errorMessage == nil), actions: { // Show status only if no error
//                Button("OK") { statusMessage = nil }
//           }, message: {
//                Text(statusMessage ?? "")
//           })
//      }
//
//      func listFiles() async {
//          guard let client = fileApiClient else { return }
//          isLoading = true
//          errorMessage = nil
//          statusMessage = nil
//          // Defer setting isLoading to false until the end
//          defer { isLoading = false }
//
//          do {
//                let response = try await client.listFiles()
//                // Sort files, maybe by creation time if available, or name
//               uploadedFiles = response.files.sorted { ($0.createTime ?? Date.distantPast) > ($1.createTime ?? Date.distantPast) }
//           } catch {
//               errorMessage = "Failed to list files: \(error.localizedDescription)"
//               uploadedFiles = [] // Clear list on error
//           }
//       }
//
//       func deleteFile(name: String) async {
//           guard let client = fileApiClient else { return }
//          isLoading = true // Indicate activity
//          errorMessage = nil
//           statusMessage = nil
//
//           do {
//                try await client.deleteFile(name: name)
//                statusMessage = "Successfully deleted file: \(name)"
//                // Refresh the list after deletion
//               await listFiles() // Calls listFiles which will set isLoading back to false
//           } catch {
//               errorMessage = "Failed to delete file \(name): \(error.localizedDescription)"
//               isLoading = false // Set loading false here on error
//           }
//           // Don't set isLoading = false here on success, listFiles will handle it
//       }
//}
