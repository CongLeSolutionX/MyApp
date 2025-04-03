//
//  LoadingMockDataFromDifferentSourcesViews.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//


import SwiftUI

// MARK: - Reusable Link Structure

/// Represents a standard link object found in JSON:API responses.
struct Link: Codable, Hashable { // Added Hashable for potential use in Sets or Dictionaries
    let href: String

    enum CodingKeys: String, CodingKey {
        case href
    }
}


// MARK: - Relationship Structure

/// Represents a relationship link structure common in JSON:API.
struct Relationship: Codable, Hashable { // Added Hashable
    // let data: RelationshipData? // Could model 'data' more precisely if needed
    let links: RelationshipLinks

    enum CodingKeys: String, CodingKey {
        case links //, data
    }
}

/// Contains the links within a Relationship object.
struct RelationshipLinks: Codable, Hashable { // Added Hashable
    let selfLink: Link? // Renamed from 'self', optional
    let related: Link? // Optional

    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case related
    }
}

// MARK: - Data Models


// Example Data Models (assuming these are defined elsewhere in your project or adjust based on your actual models)
struct FTCResponse: Decodable {
    let data: [EarlyTerminationNotice]
}

/// Represents the main data object for an Early Termination Notice.
struct EarlyTerminationNotice: Codable, Identifiable, Hashable { // Added Hashable
    let type: String
    let id: String // Using String for ID as per JSON
    let links: ResourceLinks
    let attributes: NoticeAttributes
    let relationships: NoticeRelationships

    // Conform to Hashable
    static func == (lhs: EarlyTerminationNotice, rhs: EarlyTerminationNotice) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    enum CodingKeys: String, CodingKey {
        case type, id, links, attributes, relationships
    }
}

// MARK: - Resource Links

/// Represents the links specific to a resource object.
struct ResourceLinks: Codable, Hashable { // Added Hashable
    let selfLink: Link // Renamed from 'self'

    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
    }
}

/// Represents the attributes of an Early Termination Notice.
struct NoticeAttributes: Codable, Hashable { // Added Hashable
    let title: String
    let created: String // Keep as String, parse later if needed
    let updated: String // Keep as String, parse later if needed
    let acquiredParty: String
    let acquiringParty: String
    let date: String // Keep as String (YYYY-MM-DD), parse later if needed
    let acquiredEntities: [String]
    let transactionNumber: String

    enum CodingKeys: String, CodingKey {
        case title, created, updated
        case acquiredParty = "acquired-party"
        case acquiringParty = "acquiring-party"
        case date
        case acquiredEntities = "acquired-entities"
        case transactionNumber = "transaction-number"
    }
}

// MARK: - Notice Relationships

/// Represents the relationships object for an Early Termination Notice.
struct NoticeRelationships: Codable, Hashable { // Added Hashable
    let nodeType: Relationship? // Optional based on potential variability
    let feedsItem: Relationship? // Optional based on potential variability

    enum CodingKeys: String, CodingKey {
        case nodeType = "node_type"
        case feedsItem = "feeds_item"
    }
}

// MARK: - Local Mock Data (Simulate loading from a file - you might have a separate file for this in a real project)
struct LocalMockData {
    /// Loads the raw JSON string from the local JSON file in the app bundle.
    static func loadMockFTCData() throws -> String {
        guard let url = Bundle.main.url(forResource: "MockFTCData", withExtension: "json") else {
            throw NSError(domain: "LocalMockDataError",
                          code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to find MockFTCData.json in bundle"])
        }

        // Read the contents of the file
        let data = try Data(contentsOf: url)
        // Convert data to string
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "LocalMockDataError",
                          code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to encode JSON data to String"])
        }
        return jsonString
    }
}


// MARK: - SwiftUI View

struct HRSEarlyTerminationNoticesView: View {
    @State private var notices: [EarlyTerminationNotice] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    // Data fetcher closure injected for flexibility, defaults to string data fetcher
    let dataFetcher: (@escaping (Result<FTCResponse, Error>) -> Void) -> Void

    var body: some View {
        NavigationView {
            List(notices) { notice in
                NoticeRow(notice: notice) // Extract row into its own view for clarity
            }
            .navigationTitle("FTC Notices")
            .onAppear(perform: loadData)
            .overlay {
                // Loading and Error Overlay
                if isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.red)
                        Text("Error loading data")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                }
            }
        }
    }

    // MARK: - Data Loading Logic

    func loadData() {
        isLoading = true
        errorMessage = nil

        dataFetcher { result in // Use injected dataFetcher
            isLoading = false
            switch result {
            case .success(let response):
                self.notices = response.data
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                print("Error loading or decoding data: \(error)")
            }
        }
    }


    // Static function to load preview data, can be reused in Previews
    static func loadPreviewData(fetcher: @escaping (@escaping (Result<FTCResponse, Error>) -> Void) -> Void, notices: Binding<[EarlyTerminationNotice]>) {
        fetcher { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    notices.wrappedValue = response.data // Update bound notices
                }
            case .failure(let error):
                print("Preview Error: \(error)") // Handle preview error if needed
            }
        }
    }
}

// MARK: - Mock Data Fetching (Replace with actual network service)
extension HRSEarlyTerminationNoticesView {
    static func fetchMockDataFromASeparateJSONFile(completion: @escaping (Result<FTCResponse, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                // Load the JSON from MockFTCData.json using LocalMockData
                let jsonString = try LocalMockData.loadMockFTCData()

                guard let jsonData = jsonString.data(using: .utf8) else {
                    throw NSError(domain: "DataError",
                                  code: 3,
                                  userInfo: [NSLocalizedDescriptionKey: "Could not convert JSON string to Data"])
                }

                // Simulate a short delay to mimic network fetch
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    do {
                        let decoder = JSONDecoder()
                        // If needed, configure dateDecodingStrategy here
                        let response = try decoder.decode(FTCResponse.self, from: jsonData)
                        completion(.success(response))
                    } catch {
                        completion(.failure(error))
                    }
                }
            } catch {
                // If the file couldn't be loaded or converted
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    static func fetchMockDataFromALongString(completion: @escaping (Result<FTCResponse, Error>) -> Void) {
        // Hardcoded JSON string for demonstration
        let jsonString = """
        {
          "jsonapi": {
            "version": "1.0",
            "meta": {
              "links": {
                "self": {
                  "href": "http://jsonapi.org/format/1.0/"
                }
              }
            }
          },
          "data": [
            {
              "type": "early_termination_notice",
              "id": "0254a428-d492-4d98-8bc6-e704bad804b7",
              "links": {
                "self": {
                  "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/0254a428-d492-4d98-8bc6-e704bad804b7?resourceVersion=id%3A2358"
                }
              },
              "attributes": {
                "title": "20110718: Carl C. Icahn; Blockbuster Inc. - Debtor-in-Possession",
                "created": "2013-09-24T20:05:39+00:00",
                "updated": "2013-09-24T22:22:27+00:00",
                "acquired-party": "Blockbuster Inc. - Debtor-in-Possession",
                "acquiring-party": "Carl C. Icahn",
                "date": "2011-04-11",
                "acquired-entities": [
                  "Blockbuster Inc. - Debtor-in-Possession"
                ],
                "transaction-number": "20110718"
              },
              "relationships": {
                "node_type": {
                  "data": null,
                  "links": {
                    "self": {
                      "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/0254a428-d492-4d98-8bc6-e704bad804b7/relationships/node_type?resourceVersion=id%3A2358"
                    }
                  }
                },
                "feeds_item": {
                  "data": [ ],
                  "links": {
                    "related": {
                      "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/0254a428-d492-4d98-8bc6-e704bad804b7/feeds_item?resourceVersion=id%3A2358"
                    },
                    "self": {
                      "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/0254a428-d492-4d98-8bc6-e704bad804b7/relationships/feeds_item?resourceVersion=id%3A2358"
                    }
                  }
                }
              }
            },
            {
              "type": "early_termination_notice",
              "id": "633b56f1-a499-4ac5-903d-7e46427563f7",
              "links": {
                "self": {
                  "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/633b56f1-a499-4ac5-903d-7e46427563f7?resourceVersion=id%3A2359"
                }
              },
              "attributes": {
                "title": "20110728: Charles W. Ergen; Blockbuster Inc. - Debtor-in-Possession",
                "created": "2013-09-24T20:05:39+00:00",
                "updated": "2013-09-24T22:22:27+00:00",
                "acquired-party": "Blockbuster Inc. - Debtor-in-Possession",
                "acquiring-party": "Charles W. Ergen",
                "date": "2011-04-08",
                "acquired-entities": [
                  "Blockbuster Inc. - Debtor-in-Possession"
                ],
                "transaction-number": "20110728"
              },
              "relationships": {
                "node_type": {
                  "data": null,
                  "links": {
                    "self": {
                      "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/633b56f1-a499-4ac5-903d-7e46427563f7/relationships/node_type?resourceVersion=id%3A2359"
                    }
                  }
                },
                "feeds_item": {
                  "data": [ ],
                  "links": {
                    "related": {
                      "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/633b56f1-a499-4ac5-903d-7e46427563f7/feeds_item?resourceVersion=id%3A2359"
                    },
                    "self": {
                      "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/633b56f1-a499-4ac5-903d-7e46427563f7/relationships/feeds_item?resourceVersion=id%3A2359"
                    }
                  }
                }
              }
            }
          ],
          "meta": {
            "count": 2
          },
          "links": {
            "self": {
              "href": "https://www.ftc.gov/v0/hsr-early-termination-notices?filter%5Btitle%5D%5Boperator%5D=CONTAINS&filter%5Btitle%5D%5Bvalue%5D=Blockbuster"
            }
          }
        }
        """

        guard let jsonData = jsonString.data(using: .utf8) else {
            completion(.failure(NSError(domain: "DataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON string to data."])))
            return
        }

        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            do {
                let decoder = JSONDecoder()
                // Configure decoder if necessary (e.g., date strategies)
                let response = try decoder.decode(FTCResponse.self, from: jsonData)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
    }
}


// MARK: - List Row View

struct NoticeRow: View {
    let notice: EarlyTerminationNotice

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(notice.attributes.title)
                .font(.headline)
            Text("Acquiring: \(notice.attributes.acquiringParty)")
                .font(.subheadline)
            Text("Acquired: \(notice.attributes.acquiredParty)")
                .font(.subheadline)
            HStack {
                Text("Date: \(notice.attributes.date)")
                Spacer()
                Text("Trans #: \(notice.attributes.transactionNumber)")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}


// MARK: - Preview Content Views for different data sources

struct ContentViewForStringPreview: View {
    @State var notices: [EarlyTerminationNotice] = []

    var body: some View {
        HRSEarlyTerminationNoticesView(dataFetcher: HRSEarlyTerminationNoticesView.fetchMockDataFromALongString)
        .onAppear {
            // Load data directly when preview appears using String source
            HRSEarlyTerminationNoticesView.loadPreviewData(fetcher: HRSEarlyTerminationNoticesView.fetchMockDataFromALongString, notices: $notices)
        }
    }
}


struct ContentViewForFilePreview: View {
    @State var notices: [EarlyTerminationNotice] = []

    var body: some View {
        HRSEarlyTerminationNoticesView(dataFetcher: HRSEarlyTerminationNoticesView.fetchMockDataFromASeparateJSONFile)
        .onAppear {
            // Load data directly when preview appears using JSON File source
            HRSEarlyTerminationNoticesView.loadPreviewData(fetcher: HRSEarlyTerminationNoticesView.fetchMockDataFromASeparateJSONFile, notices: $notices)
        }
    }
}


// MARK: - Preview

#Preview("Notices from String") {
    ContentViewForStringPreview()
}

#Preview("Notices from JSON File") {
    ContentViewForFilePreview()
}

