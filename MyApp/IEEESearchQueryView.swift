//
//  IEEESearchQueryView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//
import SwiftUI

struct IEEEExploreAPIView: View {
    @State private var apiResponse: String = ""
    @State private var errorMessage: String? = nil
    @State private var apiKey: String = "YOUR_API_KEY_HERE" // ** 보안 경고 **: 실제 API 키를 여기에 직접 코딩하지 마십시오. 더 안전한 방법 (예: 환경 변수, Keychain)을 사용하세요.

    // Search Parameters - State variables for input fields
    @State private var queryText: String = ""
    @State private var articleTitle: String = ""
    @State private var authorName: String = ""
    @State private var publicationTitle: String = ""
    @State private var publicationYear: String = ""
    @State private var abstractText: String = ""
    @State private var affiliationText: String = ""
    @State private var articleNumber: String = ""
    @State private var doiValue: String = ""
    @State private var indexTerms: String = ""
    @State private var thesaurusTerms: String = ""
    @State private var metaDataText: String = ""
    @State private var isbnValue: String = ""
    @State private var issnValue: String = ""
    @State private var issueNumber: String = ""
    @State private var startDate: String = ""
    @State private var endDate: String = ""
    @State private var startRecord: String = ""

    var body: some View {
        Form { // Using Form for better layout of input fields
            Section(header: Text("API Key")) {
                TextField("Enter your IEEE API Key", text: $apiKey)
            }

            Section(header: Text("Search Parameters (Optional)")) {
                TextField("Query Text (Free-text search)", text: $queryText)
                TextField("Article Title", text: $articleTitle)
                TextField("Author Name", text: $authorName)
                TextField("Publication Title", text: $publicationTitle)
                TextField("Publication Year", text: $publicationYear)
                TextField("Abstract", text: $abstractText)
                TextField("Affiliation", text: $affiliationText)
                TextField("Article Number (Overrides all other parameters except API Key)", text: $articleNumber)
                TextField("DOI (Overrides all other parameters except API Key and Article Number)", text: $doiValue)
                TextField("Index Terms", text: $indexTerms)
                TextField("Thesaurus Terms (IEEE Terms)", text: $thesaurusTerms)
                TextField("Metadata (Advanced Metadata Query)", text: $metaDataText)
                TextField("ISBN", text: $isbnValue)
                TextField("ISSN", text: $issnValue)
                TextField("Issue Number (Journals Only)", text: $issueNumber)
                TextField("Start Date (YYYYMMDD)", text: $startDate)
                TextField("End Date (YYYYMMDD)", text: $endDate)
                TextField("Start Record", text: $startRecord)

            }

            Section {
                Button("Fetch Articles") {
                    Task {
                        await fetchData()
                    }
                }
            }

            if let error = errorMessage {
                Section(header: Text("Error")) {
                    Text(error)
                        .foregroundColor(.red)
                }
            } else if !apiResponse.isEmpty {
                Section(header: Text("API Response")) {
                    ScrollView {
                        Text(apiResponse)
                            .textSelection(.enabled)
                            .font(.system(.body, design: .monospaced)) // Monospaced font for better JSON readability
                    }
                }
            }
        }
    }

    func fetchData() async {
        guard !apiKey.isEmpty && apiKey != "YOUR_API_KEY_HERE" else {
            errorMessage = "Please enter your IEEE API Key."
            apiResponse = ""
            return
        }

        errorMessage = nil // Clear previous errors
        apiResponse = "Fetching data..." // 로딩 상태 표시

        guard let baseURL = URL(string: "https://ieeexploreapi.ieee.org/api/v1/search/articles") else {
            errorMessage = "Invalid base URL"
            apiResponse = ""
            return
        }

        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        var queryItems: [URLQueryItem] = []

        // Always add API Key
        queryItems.append(URLQueryItem(name: "apikey", value: apiKey))

        // Add Article Number - takes highest priority
        if !articleNumber.isEmpty {
            queryItems.append(URLQueryItem(name: "article_number", value: articleNumber))
        } else if !doiValue.isEmpty { // Add DOI - next priority if article_number is not present
            queryItems.append(URLQueryItem(name: "doi", value: doiValue))
        } else { // Add other parameters if article_number and doi are not used
            if !queryText.isEmpty {
                queryItems.append(URLQueryItem(name: "querytext", value: queryText))
            }
            if !articleTitle.isEmpty {
                queryItems.append(URLQueryItem(name: "article_title", value: articleTitle))
            }
            if !authorName.isEmpty {
                queryItems.append(URLQueryItem(name: "author", value: authorName))
            }
            if !publicationTitle.isEmpty {
                queryItems.append(URLQueryItem(name: "publication_title", value: publicationTitle))
            }
            if !publicationYear.isEmpty {
                queryItems.append(URLQueryItem(name: "publication_year", value: publicationYear))
            }
            if !abstractText.isEmpty {
                queryItems.append(URLQueryItem(name: "abstract", value: abstractText))
            }
            if !affiliationText.isEmpty {
                queryItems.append(URLQueryItem(name: "affiliation", value: affiliationText))
            }
            if !indexTerms.isEmpty {
                queryItems.append(URLQueryItem(name: "index_terms", value: indexTerms))
            }
            if !thesaurusTerms.isEmpty {
                queryItems.append(URLQueryItem(name: "thesaurus_terms", value: thesaurusTerms))
            }
            if !metaDataText.isEmpty {
                queryItems.append(URLQueryItem(name: "meta_data", value: metaDataText))
            }
            if !isbnValue.isEmpty {
                queryItems.append(URLQueryItem(name: "isbn", value: isbnValue))
            }
            if !issnValue.isEmpty {
                queryItems.append(URLQueryItem(name: "issn", value: issnValue))
            }
            if !issueNumber.isEmpty {
                queryItems.append(URLQueryItem(name: "is_number", value: issueNumber))
            }
            if !startDate.isEmpty {
                queryItems.append(URLQueryItem(name: "start_date", value: startDate))
            }
            if !endDate.isEmpty {
                queryItems.append(URLQueryItem(name: "end_date", value: endDate))
            }
            if !startRecord.isEmpty {
                queryItems.append(URLQueryItem(name: "start_record", value: startRecord))
            }
        }

        urlComponents.queryItems = queryItems

        guard let finalURL = urlComponents.url else {
            errorMessage = "Failed to construct final URL"
            apiResponse = ""
            return
        }

        print("Request URL: \(finalURL)") // 요청 URL 로그

        do {
            let (data, response) = try await URLSession.shared.data(from: finalURL)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                errorMessage = "HTTP Error: \(statusCode)"
                apiResponse = ""
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                apiResponse = jsonString
            } else {
                apiResponse = "Failed to decode response as UTF-8 string."
            }

        } catch {
            errorMessage = "Error fetching data: \(error.localizedDescription)"
            apiResponse = ""
        }
    }
}

struct IEEEExploreAPIView_Previews: PreviewProvider {
    static var previews: some View {
        IEEEExploreAPIView()
    }
}
