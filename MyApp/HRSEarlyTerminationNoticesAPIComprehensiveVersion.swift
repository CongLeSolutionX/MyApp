////
////  HRSEarlyTerminationNoticesView.swift
////  MyApp
////
////  Created by Cong Le on 4/3/25.
////
//
//import SwiftUI // Using SwiftUI context as requested for "app design"
//
//// MARK: - Top-Level Response Structure
//
//struct FTCResponse: Codable {
//    let jsonapi: JsonApiInfo
//    let data: [EarlyTerminationNotice]
//    let meta: TopLevelMeta
//    let links: TopLevelLinks
//
//    enum CodingKeys: String, CodingKey {
//        case jsonapi, data, meta, links
//    }
//}
//
//// MARK: - JSON:API Information
//
//struct JsonApiInfo: Codable {
//    let version: String
//    let meta: JsonApiMeta? // Making optional as it might not always be present
//
//    enum CodingKeys: String, CodingKey {
//        case version, meta
//    }
//}
//
//struct JsonApiMeta: Codable {
//    let links: JsonApiLinks? // Making optional
//
//    enum CodingKeys: String, CodingKey {
//        case links
//    }
//}
//
//struct JsonApiLinks: Codable {
//    let selfLink: Link? // Renamed from 'self'
//
//    enum CodingKeys: String, CodingKey {
//        case selfLink = "self"
//    }
//}
//
//// MARK: - Resource Object (Early Termination Notice)
//
//struct EarlyTerminationNotice: Codable, Identifiable { // Identifiable via 'id'
//    let type: String
//    let id: String // Using String for ID as per JSON
//    let links: ResourceLinks
//    let attributes: NoticeAttributes
//    let relationships: NoticeRelationships
//
//    enum CodingKeys: String, CodingKey {
//        case type, id, links, attributes, relationships
//    }
//}
//
//// MARK: - Resource Links
//
//struct ResourceLinks: Codable {
//    let selfLink: Link // Renamed from 'self'
//
//    enum CodingKeys: String, CodingKey {
//        case selfLink = "self"
//    }
//}
//
//// MARK: - Notice Attributes
//
//struct NoticeAttributes: Codable {
//    let title: String
//    let created: String // Keep as String, parse later if needed
//    let updated: String // Keep as String, parse later if needed
//    let acquiredParty: String
//    let acquiringParty: String
//    let date: String // Keep as String (YYYY-MM-DD), parse later if needed
//    let acquiredEntities: [String]
//    let transactionNumber: String
//
//    enum CodingKeys: String, CodingKey {
//        case title, created, updated
//        case acquiredParty = "acquired-party"
//        case acquiringParty = "acquiring-party"
//        case date
//        case acquiredEntities = "acquired-entities"
//        case transactionNumber = "transaction-number"
//    }
//}
//
//// MARK: - Notice Relationships
//
//struct NoticeRelationships: Codable {
//    let nodeType: Relationship? // Optional based on potential variability
//    let feedsItem: Relationship? // Optional based on potential variability
//
//    enum CodingKeys: String, CodingKey {
//        case nodeType = "node_type"
//        case feedsItem = "feeds_item"
//    }
//}
//
//// MARK: - Relationship Structure
//
//struct Relationship: Codable {
//    // let data: RelationshipData? // Could model 'data' more precisely if needed (null, single, array)
//    // For this example, focusing on links as they are consistently structured in the JSON
//    let links: RelationshipLinks
//
//    enum CodingKeys: String, CodingKey {
//        case links //, data
//    }
//}
//
//struct RelationshipLinks: Codable {
//    let selfLink: Link? // Renamed from 'self', optional
//    let related: Link? // Optional
//
//    enum CodingKeys: String, CodingKey {
//        case selfLink = "self"
//        case related
//    }
//}
//
//// MARK: - Top-Level Meta & Links
//
//struct TopLevelMeta: Codable {
//    let count: Int
//
//    enum CodingKeys: String, CodingKey {
//        case count
//    }
//}
//
//struct TopLevelLinks: Codable {
//    let selfLink: Link // Renamed from 'self'
//
//    enum CodingKeys: String, CodingKey {
//        case selfLink = "self"
//    }
//}
//
//// MARK: - Reusable Link Structure
//
//struct Link: Codable {
//    let href: String
//
//    enum CodingKeys: String, CodingKey {
//        case href
//    }
//}
//
//// MARK: - Example Usage (Conceptual)
//
//struct HRSEarlyTerminationNoticesView: View {
//    @State private var notices: [EarlyTerminationNotice] = []
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//
//    var body: some View {
//        NavigationView {
//            List(notices) { notice in
//                VStack(alignment: .leading) {
//                    Text(notice.attributes.title).font(.headline)
//                    Text("Acquiring: \(notice.attributes.acquiringParty)")
//                    Text("Acquired: \(notice.attributes.acquiredParty)")
//                    Text("Date: \(notice.attributes.date)")
//                    Text("Transaction #: \(notice.attributes.transactionNumber)")
//                }
//            }
//            .navigationTitle("FTC Notices")
//            .onAppear(perform: loadData)
//            .overlay {
//                if isLoading {
//                    ProgressView("Loading...")
//                } else if let errorMessage = errorMessage {
//                    Text("Error: \(errorMessage)")
//                        .foregroundColor(.red)
//                        .padding()
//                }
//            }
//        }
//    }
//
//    func loadData() {
//        // In a real app, you would perform the network request here
//        // For now, let's simulate loading from the provided JSON string
//        isLoading = true
//        errorMessage = nil
//        
//        let jsonString = """
//{
//  "jsonapi": {
//    "version": "1.0",
//    "meta": {
//      "links": {
//        "self": {
//          "href": "http://jsonapi.org/format/1.0/"
//        }
//      }
//    }
//  },
//  "data": [
//    {
//      "type": "early_termination_notice",
//      "id": "0254a428-d492-4d98-8bc6-e704bad804b7",
//      "links": {
//        "self": {
//          "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/0254a428-d492-4d98-8bc6-e704bad804b7?resourceVersion=id%3A2358"
//        }
//      },
//      "attributes": {
//        "title": "20110718: Carl C. Icahn; Blockbuster Inc. - Debtor-in-Possession",
//        "created": "2013-09-24T20:05:39+00:00",
//        "updated": "2013-09-24T22:22:27+00:00",
//        "acquired-party": "Blockbuster Inc. - Debtor-in-Possession",
//        "acquiring-party": "Carl C. Icahn",
//        "date": "2011-04-11",
//        "acquired-entities": [
//          "Blockbuster Inc. - Debtor-in-Possession"
//        ],
//        "transaction-number": "20110718"
//      },
//      "relationships": {
//        "node_type": {
//          "data": null,
//          "links": {
//            "self": {
//              "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/0254a428-d492-4d98-8bc6-e704bad804b7/relationships/node_type?resourceVersion=id%3A2358"
//            }
//          }
//        },
//        "feeds_item": {
//          "data": [ ],
//          "links": {
//            "related": {
//              "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/0254a428-d492-4d98-8bc6-e704bad804b7/feeds_item?resourceVersion=id%3A2358"
//            },
//            "self": {
//              "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/0254a428-d492-4d98-8bc6-e704bad804b7/relationships/feeds_item?resourceVersion=id%3A2358"
//            }
//          }
//        }
//      }
//    },
//    {
//      "type": "early_termination_notice",
//      "id": "633b56f1-a499-4ac5-903d-7e46427563f7",
//      "links": {
//        "self": {
//          "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/633b56f1-a499-4ac5-903d-7e46427563f7?resourceVersion=id%3A2359"
//        }
//      },
//      "attributes": {
//        "title": "20110728: Charles W. Ergen; Blockbuster Inc. - Debtor-in-Possession",
//        "created": "2013-09-24T20:05:39+00:00",
//        "updated": "2013-09-24T22:22:27+00:00",
//        "acquired-party": "Blockbuster Inc. - Debtor-in-Possession",
//        "acquiring-party": "Charles W. Ergen",
//        "date": "2011-04-08",
//        "acquired-entities": [
//          "Blockbuster Inc. - Debtor-in-Possession"
//        ],
//        "transaction-number": "20110728"
//      },
//      "relationships": {
//        "node_type": {
//          "data": null,
//          "links": {
//            "self": {
//              "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/633b56f1-a499-4ac5-903d-7e46427563f7/relationships/node_type?resourceVersion=id%3A2359"
//            }
//          }
//        },
//        "feeds_item": {
//          "data": [ ],
//          "links": {
//            "related": {
//              "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/633b56f1-a499-4ac5-903d-7e46427563f7/feeds_item?resourceVersion=id%3A2359"
//            },
//            "self": {
//              "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/633b56f1-a499-4ac5-903d-7e46427563f7/relationships/feeds_item?resourceVersion=id%3A2359"
//            }
//          }
//        }
//      }
//    }
//  ],
//  "meta": {
//    "count": 2
//  },
//  "links": {
//    "self": {
//      "href": "https://www.ftc.gov/v0/hsr-early-termination-notices?filter%5Btitle%5D%5Boperator%5D=CONTAINS&filter%5Btitle%5D%5Bvalue%5D=Blockbuster"
//    }
//  }
//}
//
//"""
//        // Make sure to replace the placeholder above with the actual full JSON content
//        // This is just a conceptual demonstration
//        guard let jsonData = jsonString.data(using: .utf8) else {
//            errorMessage = "Failed to convert JSON string to data."
//            isLoading = false
//            return
//        }
//
//        // Simulate network delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            do {
//                let decoder = JSONDecoder()
//                // Configure decoder for date parsing if needed, e.g.:
//                // let dateFormatter = ISO8601DateFormatter()
//                // decoder.dateDecodingStrategy = .formatted(dateFormatter)
//                // Or handle multiple date formats
//
//                let response = try decoder.decode(FTCResponse.self, from: jsonData)
//                self.notices = response.data
//                self.isLoading = false
//            } catch {
//                self.errorMessage = "Failed to decode JSON: \(error.localizedDescription)"
//                print("Decoding error: \(error)") // Print detailed error for debugging
//                self.isLoading = false
//            }
//        }
//    }
//}
//
//#Preview("HRS Early Termination Notices View") {
//    HRSEarlyTerminationNoticesView()
//}
