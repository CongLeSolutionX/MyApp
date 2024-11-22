//
//  ArticleViewModel.swift
//  MyApp
//
//  Created by Cong Le on 11/22/24.
//


import Foundation
import Kanna

class ArticleViewModel: ObservableObject {
    @Published var article: Article?

    func fetchArticle() {
        guard let url = URL(string: "https://medium.com/towards-data-science/understanding-low-rank-adaptation-lora-in-fine-tuning-llms-d3dd283f1f0a") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent") // Set User-Agent to mimic a web browser

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching HTML content: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            // Parse the HTML content
            self.parseHTML(data: data)
        }

        task.resume()
    }

    private func parseHTML(data: Data) {
        guard let htmlString = String(data: data, encoding: .utf8) else {
            print("Failed to convert data to String")
            return
        }

        guard let doc = try? HTML(html: htmlString, encoding: .utf8) else {
            print("Failed to parse HTML")
            return
        }

        // Extract the content
        let title = doc.at_xpath("//h1")?.text ?? "No Title"
        let author = doc.at_xpath("//a[@data-action='show-user-card']")?.text ?? "Unknown Author"

        // Extract paragraphs
        var paragraphs: [String] = []
        for paragraph in doc.xpath("//article//p") {
            if let text = paragraph.text {
                paragraphs.append(text)
            }
        }

        let article = Article(title: title, author: author, content: paragraphs)

        // Update UI on the main thread
        DispatchQueue.main.async {
            self.article = article
        }
    }
}
