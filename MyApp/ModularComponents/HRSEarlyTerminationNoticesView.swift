//
//  HRSEarlyTerminationNoticesView.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//

import SwiftUI

// MARK: - SwiftUI View

struct HRSEarlyTerminationNoticesView: View {
    @State private var notices: [EarlyTerminationNotice] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

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
        
        // Simulate fetching data - In a real app, this would be a network call
        fetchMockDataFromASeparateJSONFile { result in
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
    
    // MARK: - Mock Data Fetching (Replace with actual network service)
    func fetchMockDataFromASeparateJSONFile(completion: @escaping (Result<FTCResponse, Error>) -> Void) {
            isLoading = true
            errorMessage = nil

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
    }
//
//    func fetchMockData(completion: @escaping (Result<FTCResponse, Error>) -> Void) {
//        // Hardcoded JSON string for demonstration
//        let jsonString = """
//        {
//          "jsonapi": {
//            "version": "1.0",
//            "meta": {
//              "links": {
//                "self": {
//                  "href": "http://jsonapi.org/format/1.0/"
//                }
//              }
//            }
//          },
//          "data": [
//            {
//              "type": "early_termination_notice",
//              "id": "0254a428-d492-4d98-8bc6-e704bad804b7",
//              "links": {
//                "self": {
//                  "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/0254a428-d492-4d98-8bc6-e704bad804b7?resourceVersion=id%3A2358"
//                }
//              },
//              "attributes": {
//                "title": "20110718: Carl C. Icahn; Blockbuster Inc. - Debtor-in-Possession",
//                "created": "2013-09-24T20:05:39+00:00",
//                "updated": "2013-09-24T22:22:27+00:00",
//                "acquired-party": "Blockbuster Inc. - Debtor-in-Possession",
//                "acquiring-party": "Carl C. Icahn",
//                "date": "2011-04-11",
//                "acquired-entities": [
//                  "Blockbuster Inc. - Debtor-in-Possession"
//                ],
//                "transaction-number": "20110718"
//              },
//              "relationships": {
//                "node_type": {
//                  "data": null,
//                  "links": {
//                    "self": {
//                      "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/0254a428-d492-4d98-8bc6-e704bad804b7/relationships/node_type?resourceVersion=id%3A2358"
//                    }
//                  }
//                },
//                "feeds_item": {
//                  "data": [ ],
//                  "links": {
//                    "related": {
//                      "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/0254a428-d492-4d98-8bc6-e704bad804b7/feeds_item?resourceVersion=id%3A2358"
//                    },
//                    "self": {
//                      "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/0254a428-d492-4d98-8bc6-e704bad804b7/relationships/feeds_item?resourceVersion=id%3A2358"
//                    }
//                  }
//                }
//              }
//            },
//            {
//              "type": "early_termination_notice",
//              "id": "633b56f1-a499-4ac5-903d-7e46427563f7",
//              "links": {
//                "self": {
//                  "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/633b56f1-a499-4ac5-903d-7e46427563f7?resourceVersion=id%3A2359"
//                }
//              },
//              "attributes": {
//                "title": "20110728: Charles W. Ergen; Blockbuster Inc. - Debtor-in-Possession",
//                "created": "2013-09-24T20:05:39+00:00",
//                "updated": "2013-09-24T22:22:27+00:00",
//                "acquired-party": "Blockbuster Inc. - Debtor-in-Possession",
//                "acquiring-party": "Charles W. Ergen",
//                "date": "2011-04-08",
//                "acquired-entities": [
//                  "Blockbuster Inc. - Debtor-in-Possession"
//                ],
//                "transaction-number": "20110728"
//              },
//              "relationships": {
//                "node_type": {
//                  "data": null,
//                  "links": {
//                    "self": {
//                      "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/633b56f1-a499-4ac5-903d-7e46427563f7/relationships/node_type?resourceVersion=id%3A2359"
//                    }
//                  }
//                },
//                "feeds_item": {
//                  "data": [ ],
//                  "links": {
//                    "related": {
//                      "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/633b56f1-a499-4ac5-903d-7e46427563f7/feeds_item?resourceVersion=id%3A2359"
//                    },
//                    "self": {
//                      "href": "https://www.ftc.gov/v0/hsr-early-termination-notices/633b56f1-a499-4ac5-903d-7e46427563f7/relationships/feeds_item?resourceVersion=id%3A2359"
//                    }
//                  }
//                }
//              }
//            }
//          ],
//          "meta": {
//            "count": 2
//          },
//          "links": {
//            "self": {
//              "href": "https://www.ftc.gov/v0/hsr-early-termination-notices?filter%5Btitle%5D%5Boperator%5D=CONTAINS&filter%5Btitle%5D%5Bvalue%5D=Blockbuster"
//            }
//          }
//        }
//        """
//        
//        guard let jsonData = jsonString.data(using: .utf8) else {
//            completion(.failure(NSError(domain: "DataError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON string to data."])))
//            return
//        }
//
//        // Simulate network delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            do {
//                let decoder = JSONDecoder()
//                // Configure decoder if necessary (e.g., date strategies)
//                let response = try decoder.decode(FTCResponse.self, from: jsonData)
//                completion(.success(response))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//    }
//}

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

// MARK: - Preview

#Preview("HRS Early Termination Notices View") {
    HRSEarlyTerminationNoticesView()
}
