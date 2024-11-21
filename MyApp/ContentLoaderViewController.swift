//
//  URLSessionViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/20/24.
//

import UIKit
import WebKit
import SwiftSoup
import Kanna

class ContentLoaderViewController: UIViewController {
    
    lazy var webView: WKWebView = {
        // Initialize and configure the WKWebView
        let webView = WKWebView(frame: self.view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return webView
    }()
    
    let contentURL = URL(string: "https://conglesolutionx.github.io/")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.addSubview(webView)
        
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
            
            // Ensure data is not nil
            if let data = data, var htmlString = String(data: data, encoding: .utf8) {
                
                // Manipulate the HTML content
                //htmlString = self.modifyHTMLContent(htmlString)
                //htmlString = self.modifyHTMLContentUsingSwiftSoup(htmlString)
                htmlString = self.modifyHTMLContentUsingKanna(htmlString)
                
                // Load the manipulated content in the WKWebView on the main thread
                DispatchQueue.main.async {
                    self.webView.loadHTMLString(htmlString, baseURL: self.contentURL)
                }
            }
        }
        // Start the data task
        task.resume()
    }
    
    func modifyHTMLContent(_ html: String) -> String {
        var modifiedHTML = html
        
        // 1. Inject Custom CSS into <head>
        let customCSS = """
        <style>
        body { background-color: #357fd4; }
        h1 { color: red; }
        p { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; }
        </style>
        """
        if let range = modifiedHTML.range(of: "<head>") {
            modifiedHTML.insert(contentsOf: customCSS, at: range.upperBound)
        } else {
            modifiedHTML = "<head>\(customCSS)</head>" + modifiedHTML
        }
        
        // 2. Inject Custom JavaScript at the end of <body>
        let customJavaScript = """
        <script>
        document.addEventListener('DOMContentLoaded', function() {
            alert('Welcome to the modified page!');
        });
        </script>
        """
        if let range = modifiedHTML.range(of: "</body>") {
            modifiedHTML.insert(contentsOf: customJavaScript, at: range.lowerBound)
        } else {
            // If </body> tag is missing, append the script at the end
            modifiedHTML += customJavaScript
        }
        
        // 3. Remove all <img> tags to prevent image loading
        modifiedHTML = modifiedHTML.replacingOccurrences(of: "<img[^>]*>", with: "", options: .regularExpression)
        
        // 4. Replace occurrences of specific words or phrases
        let wordsToReplace = ["Example Domain": "Modified Domain", "More information...": "Learn more here..."]
        for (original, replacement) in wordsToReplace {
            modifiedHTML = modifiedHTML.replacingOccurrences(of: original, with: replacement)
        }
        
        // 5. Modify attributes of specific elements
        // Example: Set all <a> tags to open links in a new tab
        let pattern = "<a\\s+([^>]*?)>"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        modifiedHTML = regex?.stringByReplacingMatches(in: modifiedHTML, options: [], range: NSRange(location: 0, length: modifiedHTML.utf16.count), withTemplate: "<a $1 target=\"_blank\">") ?? modifiedHTML
        
        // 6. Add a custom footer before </body>
        let customFooter = """
        <footer style="text-align:center; padding:20px; background-color:#e6ba2c;">
            <p>&copy; 2025 MyApp. All rights reserved.</p>
        </footer>
        """
        if let range = modifiedHTML.range(of: "</body>") {
            modifiedHTML.insert(contentsOf: customFooter, at: range.lowerBound)
        } else {
            // If </body> tag is missing, append the footer at the end
            modifiedHTML += customFooter
        }
       
        // 7. Add Meta Tags for Responsive Design
        // Purpose: Ensure the content scales properly on mobile devices.
        let viewportMeta = """
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        """
        if let range = modifiedHTML.range(of: "<head>") {
            modifiedHTML.insert(contentsOf: viewportMeta, at: range.upperBound)
        } else {
            modifiedHTML = "<head>\(viewportMeta)</head>" + modifiedHTML
        }
        
        // 8. Wrap Content in a Custom Div
        // Purpose: Apply styles or scripts to the entire content by wrapping it in a container.
        modifiedHTML = "<div id=\"customContainer\">\(modifiedHTML)</div>"
        
        
        return modifiedHTML
    }
    
    func modifyHTMLContentUsingSwiftSoup(_ html: String) -> String {
        do {
            let document = try SwiftSoup.parse(html)

            // 1. Inject Custom CSS
            let styleElement = try document.head()?.appendElement("style").text("""
            body { background-color: #f0f0f0; }
            h1 { color: blue; }
            p { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; }
            """)

            // 2. Inject Custom JavaScript
            let scriptElement = try document.body()?.appendElement("script").attr("type", "text/javascript").text("""
            document.addEventListener('DOMContentLoaded', function() {
                alert('Welcome to the modified page!');
            });
            """)

            // 3. Remove All <img> Tags
            try document.select("img").remove()

            // 4. Replace Specific Text
            let bodyText = try document.body()?.html().replacingOccurrences(of: "Example Domain", with: "Modified Domain")
            try document.body()?.html(bodyText ?? "")

            // 5. Modify Attributes of <a> Tags
            let links = try document.select("a")
            for link in links {
                try link.attr("target", "_blank")
            }

            // 6. Add Custom Footer
            try document.body()?.append("""
            <footer style="text-align:center; padding:20px; background-color:#eee;">
                <p>&copy; 2023 MyApp. All rights reserved by SwiftSoup.</p>
            </footer>
            """)

            // Return the modified HTML
            return try document.outerHtml()
        } catch {
            print("Error modifying HTML content:", error)
            return html
        }
    }
    
    func modifyHTMLContentUsingKanna(_ html: String) -> String {

        var modifiedHTML = html

        if let doc = try? HTML(html: modifiedHTML, encoding: .utf8) {
            print(doc.title as Any)
            
            // Search for nodes by CSS
            for link in doc.css("a, link") {
                print(link.text as Any)
                print(link["href"] as Any)
            }
            
            // Search for nodes by XPath
            for link in doc.xpath("//a | //link") {
                print(link.text as Any)
                print(link["href"] as Any)
            }
        }
        print("Used Kanna to modify the HTML doc")
        return modifiedHTML
    }
}
