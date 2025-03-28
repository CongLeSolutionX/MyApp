//
//  ShareSheetView_V2.swift
//  MyApp
//
//  Created by Cong Le on 3/27/25.
//

import SwiftUI
import Photos // Needed for Photo Library access

// MARK: - Main Share Sheet View
struct ShareSheetView: View {
    // Environment variable to dismiss the sheet
    @Environment(\.dismiss) var dismiss

    // --- Data Dependencies ---
    let articleTitle: String
    let articleURL: String
    let friendLinkURL: String? // Optional specific link
    // Pass other data needed for the card if it's dynamic
    let authorName: String
    let readTime: String
    let mediumHandle: String
    let platformName: String
    // -------------------------

    // --- State for Functionalities ---
    @State private var showShareSheet = false
    @State private var showSaveConfirmation = false
    @State private var showCopyConfirmation = false
    @State private var confirmationMessage = ""
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var imageToShare: UIImage? = nil // For sharing the rendered image

    // Instance of the class handling photo saving completion
    private let photoSaver = PhotoSaver()

    var body: some View {
        VStack(spacing: 0) {
            NavigationBarView(closeAction: {
                dismiss() // Use dismiss environment action
            })

            Spacer()

            // Pass dynamic data to the card
            ArticlePreviewCard(
                articleTitle: articleTitle,
                articleSubtitle: articleTitle, // Using title as subtitle for simplicity here
                authorName: authorName,
                readTime: readTime,
                mediumHandle: mediumHandle,
                platformName: platformName
            )
            .padding(.horizontal)
            .id("articleCard") // Give it an ID if needed for rendering specific views later

            Spacer()

            ActionButtonsView(
                copyLinkAction: copyLink,
                friendLinkAction: copyFriendLink,
                shareViaAction: prepareStandardShare,
                saveImageAction: saveCardImage,
                instaStoryAction: prepareImageShare // Simulate Insta Story via image share
            )
            .padding(.bottom)
            .padding(.top)

        }
        .background(Color.black.opacity(0.9).edgesIgnoringSafeArea(.all))
        .foregroundColor(.white)
        .sheet(isPresented: $showShareSheet) { // Present the standard iOS Share Sheet
            ShareSheet(activityItems: makeActivityItems())
                .edgesIgnoringSafeArea(.bottom) // Allow it to go to the bottom edge
        }
        .alert("Success", isPresented: $showCopyConfirmation) { // Confirmation for Copy
            Button("OK", role: .cancel) { }
        } message: {
            Text(confirmationMessage)
        }
        .alert("Success", isPresented: $showSaveConfirmation) { // Confirmation for Save
            Button("OK", role: .cancel) { }
        } message: {
            Text("Image saved to Photos.")
        }
        .alert("Error", isPresented: $showErrorAlert) { // Error Alert
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Action Handlers

    private func copyLink() {
        UIPasteboard.general.string = articleURL
        confirmationMessage = "Article link copied!"
        showCopyConfirmation = true
        print("Copied: \(articleURL)")
    }

    private func copyFriendLink() {
        guard let friendURL = friendLinkURL, !friendURL.isEmpty else {
            errorMessage = "Friend Link is not available for this article."
            showErrorAlert = true
            print("Friend Link requested but not available.")
            return
        }
        UIPasteboard.general.string = friendURL
        confirmationMessage = "Friend Link copied!"
        showCopyConfirmation = true
        print("Copied Friend Link: \(friendURL)")
    }

    private func prepareStandardShare() {
        // Reset imageToShare, we only want URL and Title here
        imageToShare = nil
        showShareSheet = true
        print("Preparing standard share...")
    }

    private func prepareImageShare() {
        Task {
            // Render the image first
            await renderCardImage()
            if imageToShare != nil {
                 // Now trigger the share sheet
                 showShareSheet = true
                 print("Preparing image share...")
            }
            // Error handling for rendering is inside renderCardImage
        }
    }

    // Determines what items go into the UIActivityViewController
    private func makeActivityItems() -> [Any] {
        if let image = imageToShare {
            // If we have an image, share primarily that (e.g., for Instagram)
             // You could potentially add the URL too, but image is primary here
            return [image, articleTitle] // Share image and title
        } else {
            // Standard share: URL and Title
            var items: [Any] = []
            if let url = URL(string: articleURL) {
                items.append(url)
            }
            items.append(articleTitle)
            return items
        }
    }

    // MARK: - Image Rendering & Saving

    @MainActor // Ensure UI operations are on the main thread
    private func renderCardImage() async {
        // Create the card view instance again for rendering
        // This ensures it uses the most up-to-date data if needed
        let cardView = ArticlePreviewCard(
            articleTitle: articleTitle,
            articleSubtitle: articleTitle,
            authorName: authorName,
            readTime: readTime,
            mediumHandle: mediumHandle,
            platformName: platformName
        )
        // Define the desired size explicitely for rendering if needed
        // .frame(width: 350) // Example fixed width

        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: cardView)
            // Configure the renderer if needed (e.g., scale)
            // renderer.scale = displayScale
            if let uiImage = renderer.uiImage {
                self.imageToShare = uiImage
                print("Card rendered to UIImage (iOS 16+).")
            } else {
                errorMessage = "Failed to render card image."
                showErrorAlert = true
                print("Error: ImageRenderer failed.")
            }
        } else {
            // Fallback for older iOS versions (More complex - Placeholder)
            // This often involves hosting the SwiftUI view in a UIHostingController
            // and using UIGraphicsImageRenderer on the controller's view layer.
            errorMessage = "Image rendering requires iOS 16+ for this implementation."
            showErrorAlert = true
            print("Error: iOS version too old for ImageRenderer.")
            // Set imageToShare to nil to prevent proceeding
            self.imageToShare = nil
        }
    }

    private func saveCardImage() {
         Task {
             // Ensure we have the image rendered
             await renderCardImage()

             guard let image = imageToShare else {
                 // Error already shown by renderCardImage if it failed
                 print("Cannot save image: Rendering failed or image is nil.")
                 return
             }

             // --- Check Photo Library Permissions ---
             let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)

             switch status {
             case .authorized, .limited:
                 // Permission granted, proceed to save
                 saveImageToLibrary(image)
             case .notDetermined:
                 // Request permission
                 PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                     DispatchQueue.main.async { // Update UI on main thread
                         if newStatus == .authorized || newStatus == .limited {
                             self.saveImageToLibrary(image)
                         } else {
                             self.errorMessage = "Photo Library access denied. Please enable it in Settings."
                             self.showErrorAlert = true
                             print("Photo Library permission denied after request.")
                         }
                     }
                 }
             case .denied, .restricted:
                 // Permission denied or restricted, show error
                 errorMessage = "Photo Library access denied. Please enable it in Settings."
                 showErrorAlert = true
                 print("Photo Library permission denied or restricted.")
             @unknown default:
                 errorMessage = "Unknown Photo Library authorization status."
                 showErrorAlert = true
                 print("Unknown Photo Library status.")
             }
         }
     }

    // Saves the image using the helper class for completion handling
    private func saveImageToLibrary(_ image: UIImage) {
        // Assign completion handlers to the PhotoSaver instance
        photoSaver.completionHandler = { success, error in
             DispatchQueue.main.async { // Ensure UI updates on main thread
                if success {
                    self.showSaveConfirmation = true
                    print("Image successfully saved.")
                } else {
                    self.errorMessage = error?.localizedDescription ?? "Failed to save image."
                    self.showErrorAlert = true
                    print("Error saving image: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        // Use the PhotoSaver instance's method which includes the Objective-C selector
        photoSaver.writeToPhotoAlbum(image: image)
    }
}

// MARK: - Navigation Bar Component (No functional changes needed)
struct NavigationBarView: View {
    var closeAction: () -> Void

    var body: some View {
        HStack {
            Button(action: closeAction) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            // ... rest of the NavigationBarView code remains the same ...
             Spacer()

             Text("Share")
                 .font(.headline)
                 .foregroundColor(.white)

             Spacer()

             Image(systemName: "xmark")
                 .font(.title2)
                 .opacity(0)
         }
         .padding()
         .frame(height: 50)
    }
}

// MARK: - Article Preview Card Component (Now accepts data)
struct ArticlePreviewCard: View {
    // Accept data dynamically
    let articleTitle: String
    let articleSubtitle: String
    let authorName: String
    let readTime: String
    let mediumHandle: String
    let platformName: String

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main Card Content
            VStack(alignment: .leading, spacing: 0) {
                // Blurred Top Area Placeholder
                 Rectangle()
                     .fill(.gray.opacity(0.3))
                     .frame(height: 180) // Adjust height as needed
                     .blur(radius: 10)
                     .overlay( // Simulate some subtle gradient/lighting
                         LinearGradient(
                             gradient: Gradient(colors: [.black.opacity(0.2), .clear, .black.opacity(0.1)]),
                             startPoint: .topLeading,
                             endPoint: .bottomTrailing
                         )
                     )
                     .clipped() // Ensure overlay doesn't bleed

                 // Text Content Area
                 VStack(alignment: .leading, spacing: 12) {
                     Text(readTime) // Use dynamic data
                         .font(.caption)
                         .foregroundColor(.gray)
                         .padding(.top)

                     Text(articleTitle) // Use dynamic data
                         .font(.title)
                         .fontWeight(.bold)
                         .foregroundColor(.black)
                         .lineLimit(3)
                         .minimumScaleFactor(0.8)

                     Text(articleSubtitle) // Use dynamic data
                         .font(.body)
                         .foregroundColor(.gray)
                         .lineLimit(2)

                     Divider()
                         .padding(.vertical, 8)

                     // Author Info Footer
                     HStack {
                         Image(systemName: "person.crop.circle.fill") // Placeholder
                             .resizable()
                             .frame(width: 40, height: 40)
                             .clipShape(Circle())
                             .foregroundColor(.purple)

                         Text(authorName) // Use dynamic data
                             .font(.footnote)
                             .fontWeight(.medium)
                             .foregroundColor(.black)

                         Spacer()

                         Text(platformName) // Use dynamic data
                             .font(.footnote)
                             .fontWeight(.bold)
                             .foregroundColor(.black)
                     }
                 }
                 .padding(.horizontal)
                 .padding(.bottom)
             }

            // Vertical Text
             Text(mediumHandle) // Use dynamic data
                 .font(.caption2)
                 .foregroundColor(.gray)
                 .lineLimit(1)
                 .fixedSize()
                 .rotationEffect(.degrees(-90))
                 .frame(width: 180, height: 20)
                 .offset(x: 80, y: 100) // Adjust offset carefully

        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Action Buttons Area Component (Connects buttons to actions)
struct ActionButtonsView: View {
    // Actions passed in from the parent view
    var copyLinkAction: () -> Void
    var friendLinkAction: () -> Void
    var shareViaAction: () -> Void
    var saveImageAction: () -> Void
    var instaStoryAction: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            ActionButton(iconName: "link", label: "Copy link", action: copyLinkAction)
            ActionButton(iconName: "heart", label: "Friend Link...", action: friendLinkAction)
            ActionButton(iconName: "square.and.arrow.up", label: "Share via...", action: shareViaAction)
            ActionButton(iconName: "arrow.down.to.line", label: "Save image", action: saveImageAction)
            ActionButton(iconName: "camera", label: "Insta sto...", action: instaStoryAction)
        }
        .padding(.horizontal)
    }
}

// MARK: - Individual Action Button Component (Executes provided action)
struct ActionButton: View {
    let iconName: String
    let label: String
    let action: () -> Void // Action closure

    var body: some View {
        Button(action: action) { // Execute the passed-in action
            VStack(spacing: 8) {
                 Image(systemName: iconName)
                     .font(.title2)
                     .frame(height: 30)
                     .foregroundColor(.white)

                 Text(label)
                     .font(.caption)
                     .lineLimit(2)
                     .multilineTextAlignment(.center)
                     .foregroundColor(.gray)
                     .frame(width: 70)
             }
        }
    }
}

// MARK: - UIActivityViewController Representable (for Share Sheet)
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed usually
    }
}

// MARK: - Helper Class for Photo Saving Completion
// Needs to be NSObject to use #selector
class PhotoSaver: NSObject {
    var completionHandler: ((Bool, Error?) -> Void)?

    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        completionHandler?(error == nil, error)
    }
}


// MARK: - Preview Provider
struct ShareSheetView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide sample data for the preview
        ShareSheetView(
            articleTitle: "Creating Paging ScrollView using _VariadicView",
            articleURL: "https://medium.com/@Eng.OmarElsayed/creating-paging-scrollview-using-variadicview-XXXXXXXX",
            friendLinkURL: "https://medium.com/@Eng.OmarElsayed/creating-paging-scrollview-using-variadicview-YYYYYYYY?source=friends_link",
            authorName: "Omar Elsayed",
            readTime: "8 min read",
            mediumHandle: "medium.com/@Eng.OmarElsayed",
            platformName: "Medium"
        )
    }
}
