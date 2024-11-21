//
//  AttributedTextViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/20/24.
//

import UIKit

class AttributedTextViewController: UIViewController {

    var textView: UITextView!
    let contentURL = URL(string: "https://www.medium.com")!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize and configure the UITextView
        textView = UITextView(frame: self.view.bounds)
        textView.isEditable = false
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(textView)

        // Fetch, manipulate, and load content
        fetchAndLoadContent()
    }

    func fetchAndLoadContent() {
        let urlRequest = URLRequest(url: contentURL)

        // Create a URLSession data task
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in

            // Handle errors
            if let error = error {
                print("Error fetching content:", error)
                return
            }

            guard let self = self else { return }

            if let data = data, let htmlString = String(data: data, encoding: .utf8) {

                // Manipulate the HTML content as needed
                let modifiedHTMLString = self.modifyHTMLContent(htmlString)

                // Convert HTML string to NSAttributedString
                if let attributedString = self.convertHTMLToAttributedString(modifiedHTMLString) {

                    // Set the attributed text on the main thread
                    DispatchQueue.main.async {
                        self.textView.attributedText = attributedString
                    }
                }
            }
        }

        // Start the data task
        task.resume()
    }

    func modifyHTMLContent(_ html: String) -> String {
        var modifiedHTML = html

        // Example manipulation: Remove all <img> tags
        modifiedHTML = modifiedHTML.replacingOccurrences(of: "<img[^>]+>", with: "", options: .regularExpression)

        // Further manipulation can be done here

        return modifiedHTML
    }

    func convertHTMLToAttributedString(_ html: String) -> NSAttributedString? {
        guard let data = html.data(using: .utf8) else { return nil }

        do {
            let attributedString = try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            return attributedString
        } catch {
            print("Error converting HTML to NSAttributedString:", error)
            return nil
        }
    }
}
