//
//  ActivityViewController.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//

import SwiftUI
import UIKit
import LinkPresentation // Import for URL metadata

struct ActivityViewController: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil

    // Required: Creates the UIViewController instance
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        controller.excludedActivityTypes = excludedActivityTypes

        // Optional: Enhance link previews
        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            // Handle completion or errors if needed
            print("Share sheet completed: \(completed), Activity: \(activityType?.rawValue ?? "none")")
            if let error = error {
                print("Error sharing: \(error.localizedDescription)")
            }
        }
        return controller
    }

    // Required: Updates the controller (often not needed for simple cases)
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Usually no update needed here for the standard share sheet
        // unless activityItems or excluded types change dynamically while presented.
    }

    // MARK: - Optional Coordinator for LPLinkMetadataSource
    // This helps provide richer previews for URLs
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIActivityItemSource {
        var parent: ActivityViewController

        init(_ parent: ActivityViewController) {
            self.parent = parent
        }

        // Placeholder for the actual data (required by the protocol)
        func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
            // Return a lightweight placeholder, often the first item or simple text
            return parent.activityItems.first ?? ""
        }

        // The actual item data to be shared
        func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
            // Return the appropriate item based on activity type if needed,
            // otherwise, return the primary items. For simplicity, we just return all.
            // You could customize this, e.g., return only URL for Mail, etc.
            return parent.activityItems.first // Simple approach, often sufficient
        }

        // --- LPLinkMetadataSource Implementation ---
        // Provides rich preview data for URLs
        @available(iOS 13.0, *)
        func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
            guard let url = parent.activityItems.first(where: { $0 is URL }) as? URL else {
                return nil // Only provide metadata if a URL is being shared
            }

            let metadata = LPLinkMetadata()
            metadata.url = url
            metadata.originalURL = url // Specify the original URL

            // Attempt to infer metadata title (you might fetch this dynamically)
            // For now, use a placeholder or infer from other shared items
             if let title = parent.activityItems.first(where: { $0 is String }) as? String {
                 metadata.title = title // Use the shared text as title
             } else {
                 // Fallback title if no string is shared
                 metadata.title = "Shared Song" // Placeholder
             }

            // You could also try to set an icon/image here if you fetch it
            // metadata.iconProvider = ...
            // metadata.imageProvider = ...

            return metadata
        }
    }
}
