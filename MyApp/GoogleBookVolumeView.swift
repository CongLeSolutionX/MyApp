//
//  GoogleBookVolumeView.swift
//  MyApp
//
//  Created by Cong Le on 3/1/25.
//
import SwiftUI

/// Enum to determine whether to use the live API or mock data.
enum SearchMode {
    case live
    case mock
}

/// A simple SwiftUI representation of the "Working with Volumes" section
/// from the Google Books API reference materials.
/// API Doc: https://developers.google.com/books/docs/v1/using
struct GoogleBookVolumeView: View {
    // Choose .live for real API calls, .mock for local JSON.
    let searchMode: SearchMode = .live

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Google Books API")) {

                    NavigationLink(destination: SearchVolumesView(searchMode: searchMode)) {
                        Text("Performing a Search")
                    }

                    NavigationLink(destination: RetrieveVolumeView()) {
                        Text("Retrieving a Specific Volume")
                    }

                }
            }
            .navigationTitle("Working with Volumes")
        }
    }
}

// MARK: - Search Volumes View
struct SearchVolumesView: View {

    // Network call state management
    @State private var isLoading: Bool = false
    let searchMode: SearchMode

    var body: some View {
        List {
            Section(header: Text("Overview")) {
                Text("You can search for volumes by sending an HTTP GET request to:")
                    .padding(.bottom, 2)
                Text("https://www.googleapis.com/books/v1/volumes?q=search+terms")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Section(header: Text("Query Parameters")) {
                NavigationLink(destination: SearchParametersView()) {
                    Text("• Parameters Overview")
                }
            }

            Section(header: Text("Example Request")) {
                Text("GET https://www.googleapis.com/books/v1/volumes?q=flowers+inauthor:keyes&key=YOUR_API_KEY")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Section(header: Text("Response Highlights")) {
                Text("• Returns JSON with a list of matching volumes.\n" +
                     "• Each volume includes 'volumeInfo' (title, authors, etc.)\n" +
                     "• If authorized, may include user-specific data (e.g., purchased status).")
            }

            Section {
                Button(action: performSearch) {
                    if isLoading {
                        HStack {
                            ProgressView()
                            Text("Loading…")
                        }
                    } else {
                        Text(searchMode == .live ? "Perform Sample Search" : "Perform Mocked Search")
                    }
                }
            }
        }
        .navigationTitle("Performing a Search")
    }

    /// Sends a GET request to the Google Books API or uses mock data, and prints the JSON response.
    private func performSearch() {
        isLoading = true
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }

        switch searchMode {
        case .live:
            guard let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=flowers+inauthor:keyes&key=YOUR_API_KEY") else {
                print("Invalid URL.")
                return
            }

            let task = URLSession.shared.dataTask(with: url) { data, response, error in

                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    print("Unexpected response status.")
                    return
                }

                guard let data = data else {
                    print("No data received.")
                    return
                }

                if let jsonString = String(data: data, encoding: .utf8) {
                    print("JSON Response:\n\(jsonString)")
                } else {
                    print("Unable to decode data to string.")
                }
            }
            task.resume()

        case .mock:
            // Mock JSON data.
            let mockJSONString = """
            {
              "kind": "books#volumes",
              "totalItems": 328,
              "items": [
                {
                  "kind": "books#volume",
                  "id": "6P_jN6zUuMcC",
                  "etag": "17a+ttKXimQ",
                  "selfLink": "https://www.googleapis.com/books/v1/volumes/6P_jN6zUuMcC",
                  "volumeInfo": {
                    "title": "Flowers for Algernon",
                    "authors": [
                      "Daniel Keyes"
                    ],
                    "publisher": "Houghton Mifflin Harcourt",
                    "publishedDate": "2004",
                    "description": "A mentally retarded adult has a brain operation that turns him into a genius.",
                    "industryIdentifiers": [
                      {
                        "type": "ISBN_13",
                        "identifier": "9780156030083"
                      },
                      {
                        "type": "ISBN_10",
                        "identifier": "015603008X"
                      }
                    ],
                    "readingModes": {
                      "text": false,
                      "image": true
                    },
                    "pageCount": 324,
                    "printType": "BOOK",
                    "categories": [
                      "Fiction"
                    ],
                    "averageRating": 4.5,
                    "ratingsCount": 12,
                    "maturityRating": "NOT_MATURE",
                    "allowAnonLogging": true,
                    "contentVersion": "1.4.3.0.preview.1",
                    "panelizationSummary": {
                      "containsEpubBubbles": false,
                      "containsImageBubbles": false
                    },
                    "imageLinks": {
                      "smallThumbnail": "http://books.google.com/books/content?id=6P_jN6zUuMcC&printsec=frontcover&img=1&zoom=5&edge=curl&source=gbs_api",
                      "thumbnail": "http://books.google.com/books/content?id=6P_jN6zUuMcC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api"
                    },
                    "language": "en",
                    "previewLink": "http://books.google.com/books?id=6P_jN6zUuMcC&printsec=frontcover&dq=flowers+inauthor:keyes&hl=&cd=1&source=gbs_api",
                    "infoLink": "http://books.google.com/books?id=6P_jN6zUuMcC&dq=flowers+inauthor:keyes&hl=&source=gbs_api",
                    "canonicalVolumeLink": "https://books.google.com/books/about/Flowers_for_Algernon.html?hl=&id=6P_jN6zUuMcC"
                  },
                  "saleInfo": {
                    "country": "US",
                    "saleability": "NOT_FOR_SALE",
                    "isEbook": false
                  },
                  "accessInfo": {
                    "country": "US",
                    "viewability": "PARTIAL",
                    "embeddable": true,
                    "publicDomain": false,
                    "textToSpeechPermission": "ALLOWED",
                    "epub": {
                      "isAvailable": false
                    },
                    "pdf": {
                      "isAvailable": true,
                      "acsTokenLink": "http://books.google.com/books/download/Flowers_for_Algernon-sample-pdf.acsm?id=6P_jN6zUuMcC&format=pdf&output=acs4_fulfillment_token&dl_type=sample&source=gbs_api"
                    },
                    "webReaderLink": "http://play.google.com/books/reader?id=6P_jN6zUuMcC&hl=&source=gbs_api",
                    "accessViewStatus": "SAMPLE",
                    "quoteSharingAllowed": false
                  },
                  "searchInfo": {
                    "textSnippet": "A mentally retarded adult has a brain operation that turns him into a genius."
                  }
                },
                {
                  "kind": "books#volume",
                  "id": "rUPPPQAACAAJ",
                  "etag": "Gn2buaHvWlQ",
                  "selfLink": "https://www.googleapis.com/books/v1/volumes/rUPPPQAACAAJ",
                  "volumeInfo": {
                    "title": "Flowers for Algernon (Pack of 16)",
                    "authors": [
                      "Daniel Keyes"
                    ],
                    "publisher": "Vintage",
                    "publishedDate": "1990-08",
                    "industryIdentifiers": [
                      {
                        "type": "ISBN_10",
                        "identifier": "0435129600"
                      },
                      {
                        "type": "ISBN_13",
                        "identifier": "9780435129606"
                      }
                    ],
                    "readingModes": {
                      "text": false,
                      "image": false
                    },
                    "printType": "BOOK",
                    "maturityRating": "NOT_MATURE",
                    "allowAnonLogging": false,
                    "contentVersion": "preview-1.0.0",
                    "language": "en",
                    "previewLink": "http://books.google.com/books?id=rUPPPQAACAAJ&dq=flowers+inauthor:keyes&hl=&cd=2&source=gbs_api",
                    "infoLink": "http://books.google.com/books?id=rUPPPQAACAAJ&dq=flowers+inauthor:keyes&hl=&source=gbs_api",
                    "canonicalVolumeLink": "https://books.google.com/books/about/Flowers_for_Algernon_Pack_of_16.html?hl=&id=rUPPPQAACAAJ"
                  },
                  "saleInfo": {
                    "country": "US",
                    "saleability": "NOT_FOR_SALE",
                    "isEbook": false
                  },
                  "accessInfo": {
                    "country": "US",
                    "viewability": "NO_PAGES",
                    "embeddable": false,
                    "publicDomain": false,
                    "textToSpeechPermission": "ALLOWED",
                    "epub": {
                      "isAvailable": false
                    },
                    "pdf": {
                      "isAvailable": false
                    },
                    "webReaderLink": "http://play.google.com/books/reader?id=rUPPPQAACAAJ&hl=&source=gbs_api",
                    "accessViewStatus": "NONE",
                    "quoteSharingAllowed": false
                  }
                },
                {
                  "kind": "books#volume",
                  "id": "64tuPwAACAAJ",
                  "etag": "FYjjTl5BYvo",
                  "selfLink": "https://www.googleapis.com/books/v1/volumes/64tuPwAACAAJ",
                  "volumeInfo": {
                    "title": "Flowers for Algernon",
                    "authors": [
                      "Daniel Keyes"
                    ],
                    "publisher": "Gollancz",
                    "publishedDate": "2000",
                    "description": "The classic novel about a daring experiment in human intelligence Charlie Gordon, IQ 68, is a floor sweeper and the gentle butt of everyone's jokes - until an experiment in the enhancement of human intelligence turns him into a genius. But then Algernon, the mouse whose triumphal experimental tranformation preceded his, fades and dies, and Charlie has to face the possibility that his salvation was only temporary.",
                    "industryIdentifiers": [
                      {
                        "type": "ISBN_10",
                        "identifier": "1857989384"
                      },
                      {
                        "type": "ISBN_13",
                        "identifier": "9781857989380"
                      }
                    ],
                    "readingModes": {
                      "text": false,
                      "image": false
                    },
                    "pageCount": 216,
                    "printType": "BOOK",
                    "categories": [
                      "Fiction"
                    ],
                    "maturityRating": "NOT_MATURE",
                    "allowAnonLogging": false,
                    "contentVersion": "preview-1.0.0",
                    "panelizationSummary": {
                      "containsEpubBubbles": false,
                      "containsImageBubbles": false
                    },
                    "imageLinks": {
                      "smallThumbnail": "http://books.google.com/books/content?id=64tuPwAACAAJ&printsec=frontcover&img=1&zoom=5&source=gbs_api",
                      "thumbnail": "http://books.google.com/books/content?id=64tuPwAACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api"
                    },
                    "language": "en",
                    "previewLink": "http://books.google.com/books?id=64tuPwAACAAJ&dq=flowers+inauthor:keyes&hl=&cd=3&source=gbs_api",
                    "infoLink": "http://books.google.com/books?id=64tuPwAACAAJ&dq=flowers+inauthor:keyes&hl=&source=gbs_api",
                    "canonicalVolumeLink": "https://books.google.com/books/about/Flowers_for_Algernon.html?hl=&id=64tuPwAACAAJ"
                  },
                  "saleInfo": {
                    "country": "US",
                    "saleability": "NOT_FOR_SALE",
                    "isEbook": false
                  },
                  "accessInfo": {
                    "country": "US",
                    "viewability": "NO_PAGES",
                    "embeddable": false,
                    "publicDomain": false,
                    "textToSpeechPermission": "ALLOWED",
                    "epub": {
                      "isAvailable": false
                    },
                    "pdf": {
                      "isAvailable": false
                    },
                    "webReaderLink": "http://play.google.com/books/reader?id=64tuPwAACAAJ&hl=&source=gbs_api",
                    "accessViewStatus": "NONE",
                    "quoteSharingAllowed": false
                  },
                  "searchInfo": {
                    "textSnippet": "The classic novel about a daring experiment in human intelligence..."
                  }
                },
                {
                  "kind": "books#volume",
                  "id": "6P_jN6zUuMcC",
                  "etag": "r1WUqiPHQfU",
                  "selfLink": "https://www.googleapis.com/books/v1/volumes/6P_jN6zUuMcC",
                  "volumeInfo": {
                    "title": "Flowers for Algernon",
                    "authors": [
                      "Daniel Keyes"
                    ],
                    "publisher": "Houghton Mifflin Harcourt",
                    "publishedDate": "2004",
                    "description": "A mentally retarded adult has a brain operation that turns him into a genius.",
                    "industryIdentifiers": [
                      {
                        "type": "ISBN_13",
                        "identifier": "9780156030083"
                      },
                      {
                        "type": "ISBN_10",
                        "identifier": "015603008X"
                      }
                    ],
                    "readingModes": {
                      "text": false,
                      "image": true
                    },
                    "pageCount": 324,
                    "printType": "BOOK",
                    "categories": [
                      "Fiction"
                    ],
                    "averageRating": 4.5,
                    "ratingsCount": 12,
                    "maturityRating": "NOT_MATURE",
                    "allowAnonLogging": true,
                    "contentVersion": "1.4.3.0.preview.1",
                    "panelizationSummary": {
                      "containsEpubBubbles": false,
                      "containsImageBubbles": false
                    },
                    "imageLinks": {
                      "smallThumbnail": "http://books.google.com/books/content?id=6P_jN6zUuMcC&printsec=frontcover&img=1&zoom=5&edge=curl&source=gbs_api",
                      "thumbnail": "http://books.google.com/books/content?id=6P_jN6zUuMcC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api"
                    },
                    "language": "en",
                    "previewLink": "http://books.google.com/books?id=6P_jN6zUuMcC&pg=PA283&dq=flowers+inauthor:keyes&hl=&cd=4&source=gbs_api",
                    "infoLink": "http://books.google.com/books?id=6P_jN6zUuMcC&dq=flowers+inauthor:keyes&hl=&source=gbs_api",
                    "canonicalVolumeLink": "https://books.google.com/books/about/Flowers_for_Algernon.html?hl=&id=6P_jN6zUuMcC"
                  },
                  "saleInfo": {
                    "country": "US",
                    "saleability": "NOT_FOR_SALE",
                    "isEbook": false
                  },
                  "accessInfo": {
                    "country": "US",
                    "viewability": "PARTIAL",
                    "embeddable": true,
                    "publicDomain": false,
                    "textToSpeechPermission": "ALLOWED",
                    "epub": {
                      "isAvailable": false
                    },
                    "pdf": {
                      "isAvailable": true,
                      "acsTokenLink": "http://books.google.com/books/download/Flowers_for_Algernon-sample-pdf.acsm?id=6P_jN6zUuMcC&format=pdf&output=acs4_fulfillment_token&dl_type=sample&source=gbs_api"
                    },
                    "webReaderLink": "http://play.google.com/books/reader?id=6P_jN6zUuMcC&hl=&source=gbs_api",
                    "accessViewStatus": "SAMPLE",
                    "quoteSharingAllowed": false
                  },
                  "searchInfo": {
                    "textSnippet": "... swirl of local snippet data..."
                  }
                },
                {
                  "kind": "books#volume",
                  "id": "gK98gXR8onwC",
                  "etag": "33c32gFEzpc",
                  "selfLink": "https://www.googleapis.com/books/v1/volumes/gK98gXR8onwC",
                  "volumeInfo": {
                    "title": "Flowers for Algernon",
                    "subtitle": "One Act",
                    "authors": [
                      "David Rogers",
                      "Daniel Keyes"
                    ],
                    "publisher": "Dramatic Publishing",
                    "publishedDate": "1969",
                    "industryIdentifiers": [
                      {
                        "type": "ISBN_10",
                        "identifier": "0871293870"
                      },
                      {
                        "type": "ISBN_13",
                        "identifier": "9780871293879"
                      }
                    ],
                    "readingModes": {
                      "text": false,
                      "image": true
                    },
                    "pageCount": 36,
                    "printType": "BOOK",
                    "categories": [
                      "Drama"
                    ],
                    "averageRating": 5,
                    "ratingsCount": 1,
                    "maturityRating": "NOT_MATURE",
                    "allowAnonLogging": false,
                    "contentVersion": "0.3.4.0.preview.1",
                    "panelizationSummary": {
                      "containsEpubBubbles": false,
                      "containsImageBubbles": false
                    },
                    "imageLinks": {
                      "smallThumbnail": "http://books.google.com/books/content?id=gK98gXR8onwC&printsec=frontcover&img=1&zoom=5&edge=curl&source=gbs_api",
                      "thumbnail": "http://books.google.com/books/content?id=gK98gXR8onwC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api"
                    },
                    "language": "en",
                    "previewLink": "http://books.google.com/books?id=gK98gXR8onwC&pg=PA28&dq=flowers+inauthor:keyes&hl=&cd=5&source=gbs_api",
                    "infoLink": "http://books.google.com/books?id=gK98gXR8onwC&dq=flowers+inauthor:keyes&hl=&source=gbs_api",
                    "canonicalVolumeLink": "https://books.google.com/books/about/Flowers_for_Algernon.html?hl=&id=gK98gXR8onwC"
                  },
                  "saleInfo": {
                    "country": "US",
                    "saleability": "NOT_FOR_SALE",
                    "isEbook": false
                  },
                  "accessInfo": {
                    "country": "US",
                    "viewability": "PARTIAL",
                    "embeddable": true,
                    "publicDomain": false,
                    "textToSpeechPermission": "ALLOWED",
                    "epub": {
                      "isAvailable": false
                    },
                    "pdf": {
                      "isAvailable": true,
                      "acsTokenLink": "http://books.google.com/books/download/Flowers_for_Algernon-sample-pdf.acsm?id=gK98gXR8onwC&format=pdf&output=acs4_fulfillment_token&dl_type=sample&source=gbs_api"
                    },
                    "webReaderLink": "http://play.google.com/books/reader?id=gK98gXR8onwC&hl=&source=gbs_api",
                    "accessViewStatus": "SAMPLE",
                    "quoteSharingAllowed": false
                  },
                  "searchInfo": {
                    "textSnippet": "some snippet from the text..."
                  }
                },
                {
                  "kind": "books#volume",
                  "id": "p5jLDwAAQBAJ",
                   ...
                },
                {
                  "kind": "books#volume",
                  "id": "DM_xN8z8ku0C",
                  ...
                },
                {
                  "kind": "books#volume",
                  "id": "BEVLEAAAQBAJ",
                  ...
                },
                {
                  "kind": "books#volume",
                  "id": "xgpyEAAAQBAJ",
                  ...
                },
                {
                  "kind": "books#volume",
                  "id": "x8mrEAAAQBAJ",
                    ...
                }
              ]
            }
            """

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("------------------------------")
                print("Mock JSON Response:\n\(mockJSONString)")
                print("------------------------------")
            }
        }
    }
}

// MARK: - Retrieve Volume View
struct RetrieveVolumeView: View {
    var body: some View {
        List {
            Section(header: Text("Overview")) {
                Text("Retrieve information for a specific volume by sending a GET request to:")
                    .padding(.bottom, 2)
                Text("https://www.googleapis.com/books/v1/volumes/volumeId")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Section(header: Text("Volume ID")) {
                Text("Volume IDs are unique strings, e.g. 'zyTCAlFPjgYC'.\n" +
                     "You can find the ID in search results or from the Google Books site.")
            }

            Section(header: Text("Example Request")) {
                Text("GET https://www.googleapis.com/books/v1/volumes/zyTCAlFPjgYC?key=YOUR_API_KEY")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Section(header: Text("Response Highlights")) {
                Text("• Returns JSON representing the volume you requested.\n" +
                     "• 'volumeInfo' includes title, authors, date, etc.\n" +
                     "• 'accessInfo' indicates eBook availability (epub, pdf).")
            }
        }
        .navigationTitle("Retrieving a Volume")
    }
}

// MARK: - Search Parameters View
struct SearchParametersView: View {
    var body: some View {
        List {
            Section(header: Text("Key Parameters")) {
                DisclosureGroup("q") {
                    Text("Full-text query string. Combine terms with '+', or special keywords\n" +
                         "like 'intitle:', 'inauthor:', 'inpublisher:', 'isbn:', etc.")
                }
                DisclosureGroup("download") {
                    Text("Restrict to volumes by download availability, e.g. 'epub'.")
                }
                DisclosureGroup("filter") {
                    Text("Restrict by volume availability: 'partial', 'full', 'free-ebooks', etc.")
                }
                DisclosureGroup("langRestrict") {
                    Text("Search results for a specific language, e.g. 'en' or 'fr'.")
                }
                DisclosureGroup("maxResults & startIndex") {
                    Text("Use these to paginate results (up to 40 max).")
                }
                DisclosureGroup("orderBy") {
                    Text("Change ordering: 'relevance' or 'newest'.")
                }
                DisclosureGroup("printType") {
                    Text("Restrict search to 'books' or 'magazines'.")
                }
                DisclosureGroup("projection") {
                    Text("Control how much data is returned: 'full' or 'lite'.")
                }
            }
        }
        .navigationTitle("Search Parameters")
    }
}

// MARK: - Preview
#Preview {
    GoogleBookVolumeView()
}
