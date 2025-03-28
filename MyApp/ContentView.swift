//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
//
//import SwiftUI
//
//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//// After iOS 17, we can use this syntax for preview:
//#Preview {
//    ContentView()
//}

import SwiftUI

// MARK: - Data Structures (Mirroring API Concepts)

struct EndpointInfo: Identifiable {
    let id = UUID()
    let path: String
    let method: String // "GET", "POST"
    let summary: String
    let parameters: [ParameterInfo]?
    let requestBodySchema: SchemaType?
    let responseSchema: SchemaType?
    let possibleStatusCodes: [StatusCodeInfo]
}

struct ParameterInfo: Identifiable {
    let id = UUID()
    let name: String
    let location: String // "query", "path", "header", etc.
    let description: String
    let required: Bool
    let type: String
}

struct StatusCodeInfo: Identifiable {
    let id = UUID()
    let code: String
    let description: String
    let category: StatusCategory // Success, ClientError, ServerError
}

enum StatusCategory {
    case success, clientError, serverError, informational, redirection
}

enum SchemaType: String, CaseIterable, Identifiable {
    case multiplePostQuery = "MultiplePostQuery"
    case multiplePostQueryItem = "MultiplePostQueryItem"
    case multiplePostResponse = "MultiplePostResponse"
    case multiplePostResponseItem = "MultiplePostResponseItem"
    case constructionSpendingDto = "ConstructionSpendingDto"
    case constructionSpendingDatumDto = "ConstructionSpendingDatumDto"
    // Add others like HttpHeaders, MediaType if needed for detail
    case genericObject = "Object (Generic)"
    case genericArray = "Array (Generic)"

    var id: String { self.rawValue }

    // Basic representation for demonstration
    @ViewBuilder
    var schemaStructureView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(self.rawValue).font(.headline).padding(.bottom, 2)
            switch self {
            case .multiplePostQuery:
                Text("{").codeStyle()
                Text("  \"queryItems\": [").codeStyle()
                Text("    { MultiplePostQueryItem }").codeStyle()
                Text("    ,").codeStyle()
                Text("    ...").codeStyle()
                Text("  ]").codeStyle()
                Text("}").codeStyle()
            case .multiplePostQueryItem:
                Text("{").codeStyle()
                Text("  \"section\": \"string\",").codeStyle()
                Text("  \"sector\": \"string\" (optional),").codeStyle()
                Text("  \"subsector\": \"string\" (optional)").codeStyle()
                Text("}").codeStyle()
            case .multiplePostResponse:
                Text("{").codeStyle()
                Text("  \"postResponseItems\": [").codeStyle()
                Text("    { MultiplePostResponseItem }").codeStyle()
                Text("    ,").codeStyle()
                Text("    ...").codeStyle()
                Text("  ]").codeStyle()
                Text("}").codeStyle()
            case .multiplePostResponseItem:
                Text("{ (Attributes)").codeStyle()
                Text("  \"value\": float,").codeStyle()
                Text("  \"path\": \"string\",").codeStyle()
                Text("  \"spendingValueType\": \"string\",").codeStyle()
                Text("  \"monthYear\": \"string\"").codeStyle()
                Text("}").codeStyle()
            case .constructionSpendingDto:
                Text("{").codeStyle()
                Text("  \"constructionSpending\": [").codeStyle()
                Text("    { ConstructionSpendingDatumDto }").codeStyle()
                Text("    ,").codeStyle()
                Text("    ...").codeStyle()
                Text("  ]").codeStyle()
                Text("}").codeStyle()
            case .constructionSpendingDatumDto:
                Text("{ (Attributes)").codeStyle()
                Text("  \"construction-spending-value\": double,").codeStyle()
                Text("  \"month-and-value-type\": \"string\",").codeStyle()
                Text("  \"month-label-type\": \"string\",").codeStyle()
                Text("  \"data-section-name\": \"string\"").codeStyle()
                Text("}").codeStyle()
            case .genericObject:
                Text("{ ... }").codeStyle()
            case .genericArray:
                Text("[ ... ]").codeStyle()
            }
        }
        .padding(.leading)
    }
}

// MARK: - Helper Views

struct LabeledText: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 80, alignment: .trailing)
            Text(value)
                .font(.body)
        }
    }
}

struct CodeStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.caption, design: .monospaced))
            .foregroundColor(.secondary) // Use a slightly dimmer color for code
    }
}

extension View {
    func codeStyle() -> some View {
        self.modifier(CodeStyleModifier())
    }
}

// MARK: - Main Content Views

struct APIOverviewView: View {
    var body: some View {
        GroupBox("API Overview") {
            VStack(alignment: .leading, spacing: 10) {
                LabeledText(label: "Title", value: "Construction Spending API")
                LabeledText(label: "Description", value: "Monthly estimates of the total dollar value of construction work done in the U.S.")
                LabeledText(label: "Server", value: "https://api.fanniemae.com")
                LabeledText(label: "Version", value: "1.0 (derived from /v1 path)") // Assuming v1 implies 1.0
                LabeledText(label: "Formats", value: "application/json, application/xml")

            }
            .padding(.vertical, 5)
        }
        .padding(.horizontal)
    }
}

struct EndpointsListView: View {
    let endpoints: [EndpointInfo] = apiEndpoints // Defined later

    var body: some View {
        List {
            Section("API Endpoints") {
                ForEach(endpoints) { endpoint in
                    NavigationLink(destination: EndpointDetailView(endpoint: endpoint)) {
                        HStack {
                            Text(endpoint.method)
                                .font(.caption.bold())
                                .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
                                .foregroundColor(.white)
                                .background(endpoint.method == "POST" ? Color.orange : Color.blue)
                                .cornerRadius(4)
                            VStack(alignment: .leading) {
                                Text(endpoint.path).font(.headline)
                                Text(endpoint.summary).font(.caption).foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Endpoints") // Use .navigationTitle in actual NavigationView context
    }
}

struct EndpointDetailView: View {
    let endpoint: EndpointInfo

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Basic Info
                GroupBox("Endpoint Details") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(endpoint.method)
                                .font(.title2.bold())
                                .foregroundColor(endpoint.method == "POST" ? .orange : .blue)
                            Text(endpoint.path).font(.title2)
                        }
                        Text(endpoint.summary).font(.body)
                    }.padding(.vertical, 5)
                }

                // Parameters (for GET)
                if let parameters = endpoint.parameters, !parameters.isEmpty {
                    GroupBox("Query Parameters") {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(parameters) { param in
                                DisclosureGroup(param.name) {
                                    VStack(alignment: .leading, spacing: 5) {
                                        LabeledText(label: "In", value: param.location)
                                        LabeledText(label: "Type", value: param.type)
                                        LabeledText(label: "Required", value: param.required ? "Yes" : "No")
                                        LabeledText(label: "Description", value: param.description)
                                    }.padding(.top, 5)
                                }
                                .font(.headline)
                            }
                        }.padding(.vertical, 5)
                    }
                }

                // Request Body (for POST)
                if let requestSchema = endpoint.requestBodySchema {
                    GroupBox("Request Body (\(endpoint.method == "POST" ? "json/xml" : ""))") {
                        SchemaDetailView(schemaType: requestSchema)
                            .padding(.vertical, 5)
                    }
                }

                // Response Body
                if let responseSchema = endpoint.responseSchema {
                    GroupBox("Success Response (200 OK - json/xml)") {
                         SchemaDetailView(schemaType: responseSchema)
                             .padding(.vertical, 5)
                    }
                } else if endpoint.path.contains("multiple") {
                     GroupBox("Success Response (200 OK - json/xml)") {
                        SchemaDetailView(schemaType: .multiplePostResponse)
                            .padding(.vertical, 5)
                     }
                 } else {
                     GroupBox("Success Response (200 OK - json/xml)") {
                         Text("Array of ").font(.caption) + Text(SchemaType.constructionSpendingDto.rawValue).font(.caption.bold())
                         SchemaDetailView(schemaType: .constructionSpendingDto)
                             .padding(.vertical, 5)
                      }
                 }


                // Status Codes
                GroupBox("Possible Responses") {
                    VStack(alignment: .leading) {
                        ForEach(endpoint.possibleStatusCodes) { status in
                            HStack {
                                Circle()
                                    .fill(status.category.color)
                                    .frame(width: 10, height: 10)
                                Text(status.code).font(.headline).frame(width: 40, alignment: .leading)
                                Text(status.description).font(.caption)
                            }
                            Divider()
                        }
                    }.padding(.vertical, 5)
                }

            }
            .padding()
        }
        .navigationTitle(endpoint.path)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DataHierarchyView: View {
    // Example values for pickers or display
    @State private var selectedSection = "Private"
    @State private var selectedSector = "Residential"
    @State private var selectedSubsector = "Office"

    let sections = ["Total", "Private", "Public"]
    let sectors = ["Residential", "Nonresidential"]
    let subsectors = ["Lodging", "Office", "Commercial", "Health care", "Educational", "Religious", /* ... others */ "Manufacturing"]

    var body: some View {
        Form { // Using Form for better structure with Pickers
           Section("Data Hierarchy") {
               Text("Construction spending data is organized hierarchically:")
                   .font(.caption)
                   .foregroundColor(.gray)

               VStack(alignment: .leading, spacing: 10) {
                   Text("1. Section")
                       .font(.headline)
                   Picker("Section", selection: $selectedSection) {
                       ForEach(sections, id: \.self) { Text($0) }
                   }.pickerStyle(.segmented) // Or .menu

                   Divider().padding(.vertical, 5)

                   Text("2. Sector")
                       .font(.headline)
                       .padding(.leading, 20) // Indent
                   Picker("Sector", selection: $selectedSector) {
                      ForEach(sectors, id: \.self) { Text($0) }
                   }
                   .padding(.leading, 20)

                    Divider().padding(.vertical, 5)

                   Text("3. Subsector")
                       .font(.headline)
                       .padding(.leading, 40) // Further Indent
                    Picker("Subsector", selection: $selectedSubsector) {
                        ForEach(subsectors, id: \.self) { Text($0) }
                    }.pickerStyle(.menu) // Use menu for long lists
                   .padding(.leading, 40)


               }
               .padding(.vertical)
           }

            Section("Corresponding Endpoints") {
                  Text("`/section` uses Section.")
                  Text("`/sectionandsector` uses Section + Sector.")
                  Text("`/sectionsectorandsubsector` uses Section + Sector + Subsector.")
                  Text("`/multiple` (POST) can use any combination.")
            }.font(.caption)
        }
        .navigationTitle("Data Hierarchy")
    }
}

struct DataModelsView: View {
    var body: some View {
        List {
            Section("Request/Response Schemas") {
                ForEach(SchemaType.allCases) { schemaType in
                    NavigationLink(destination: SchemaDetailView(schemaType: schemaType)) {
                        Text(schemaType.rawValue)
                    }
                }
            }
        }
        .navigationTitle("Data Models")
    }
}

struct SchemaDetailView: View {
    let schemaType: SchemaType

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                 schemaType.schemaStructureView
                    .padding()
                Spacer() // Pushes content to top
            }

        }
        .navigationTitle(schemaType.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatusCodesView: View {
    let allCodes: [StatusCodeInfo] = commonStatusCodes // Defined later

    var body: some View {
        List {
            Section("Common HTTP Status Codes") {
                ForEach(allCodes) { status in
                     HStack {
                         Circle()
                             .fill(status.category.color)
                             .frame(width: 10, height: 10)
                         Text(status.code).font(.headline).frame(width: 40, alignment: .leading)
                         Text(status.description).font(.body)
                     }
                     .padding(.vertical, 2)
                }
            }
        }
        .navigationTitle("Status Codes")
    }
}

// MARK: - Main App View

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("API Overview", destination: APIOverviewView().navigationTitle("Overview"))
                NavigationLink("Endpoints", destination: EndpointsListView()) // Navigation title set inside
                NavigationLink("Data Hierarchy", destination: DataHierarchyView()) // Navigation title set inside
                NavigationLink("Data Models (Schemas)", destination: DataModelsView()) // Navigation title set inside
                NavigationLink("Common Status Codes", destination: StatusCodesView()) // Navigation title set inside
            }
            .navigationTitle("Construction Spending API")

            // Detail view placeholder for iPad/macOS
            Text("Select an item from the sidebar.")
                .foregroundColor(.gray)
        }
    }
}


// MARK: - Data Definitions (Populate based on OpenAPI Spec)

let commonStatusCodes: [StatusCodeInfo] = [
    .init(code: "200", description: "OK. Data found and returned.", category: .success),
    .init(code: "204", description: "No Content. Request successful, but no data records found for the criteria.", category: .success),
    .init(code: "400", description: "Bad Request. Malformed request syntax or invalid parameters.", category: .clientError),
    .init(code: "401", description: "Unauthorized. Authentication required or invalid credentials.", category: .clientError),
    .init(code: "403", description: "Forbidden. Authenticated user lacks permission.", category: .clientError),
    .init(code: "404", description: "Not Found. The requested resource or path does not exist.", category: .clientError),
    .init(code: "500", description: "Internal Server Error. An unexpected error occurred on the server.", category: .serverError)
]

// Specific endpoint status codes (subset of common + specifics)
let getSectionCodes: [StatusCodeInfo] = [
    commonStatusCodes[0], // 200
    commonStatusCodes[1], // 204
    commonStatusCodes[3], // 401
    commonStatusCodes[4], // 403
    .init(code: "404", description: "No Construction Spending data found for {section}.", category: .clientError),
    commonStatusCodes[6] // 500
]

let getSectionSectorCodes: [StatusCodeInfo] = [
    commonStatusCodes[0], // 200
    commonStatusCodes[1], // 204
    commonStatusCodes[3], // 401
    commonStatusCodes[4], // 403
    .init(code: "404", description: "No Construction Spending data found for {section} and {sector}.", category: .clientError),
    commonStatusCodes[6] // 500
]

let getSectionSectorSubsectorCodes: [StatusCodeInfo] = [
    commonStatusCodes[0], // 200
    commonStatusCodes[1], // 204
    commonStatusCodes[3], // 401
    commonStatusCodes[4], // 403
    .init(code: "404", description: "No Construction Spending data found for {section}, {sector}, and {subsector}.", category: .clientError),
    commonStatusCodes[6] // 500
]

let postMultipleCodes: [StatusCodeInfo] = [
    commonStatusCodes[0], // 200
    commonStatusCodes[1], // 204
    commonStatusCodes[2], // 400
    commonStatusCodes[3], // 401
    commonStatusCodes[4], // 403
    commonStatusCodes[5], // 404 (Endpoint itself not found)
    commonStatusCodes[6] // 500
]


// Endpoint Definitions
let apiEndpoints: [EndpointInfo] = [
    .init(path: "/v1/construction-spending/multiple",
          method: "POST",
          summary: "Get spending for an arbitrary list of paths (section, section/sector, or section/sector/subsector).",
          parameters: nil,
          requestBodySchema: .multiplePostQuery,
          responseSchema: .multiplePostResponse,
          possibleStatusCodes: postMultipleCodes),

    .init(path: "/v1/construction-spending/sectionandsector",
          method: "GET",
          summary: "Get construction spending by specifying a section and a sector.",
          parameters: [
            .init(name: "section", location: "query", description: "Valid sections - Total, Private, Public", required: true, type: "string"),
            .init(name: "sector", location: "query", description: "Valid sectors - Residential, Nonresidential", required: true, type: "string")
          ],
          requestBodySchema: nil,
          responseSchema: .genericArray, // Array of ConstructionSpendingDto
          possibleStatusCodes: getSectionSectorCodes),

    .init(path: "/v1/construction-spending/sectionsectorandsubsector",
          method: "GET",
          summary: "Get construction spending by specifying a section, sector, and subsector.",
          parameters: [
             .init(name: "section", location: "query", description: "Valid sections - Total, Private, Public", required: true, type: "string"),
             .init(name: "sector", location: "query", description: "Valid sectors - Residential, Nonresidential", required: true, type: "string"),
             .init(name: "subsector", location: "query", description: "Valid subsectors - Lodging, Office, Commercial, Health care, Educational, Religious, Public safety, Amusement and recreation, Transportation, Communication, Power, Highway and street, Sewage and waste disposal, Water supply, Conservation and development, Manufacturing", required: true, type: "string")
          ],
          requestBodySchema: nil,
         responseSchema: .genericArray, // Array of ConstructionSpendingDto
         possibleStatusCodes: getSectionSectorSubsectorCodes),

     .init(path: "/v1/construction-spending/section",
          method: "GET",
          summary: "Get construction spending by specifying a section.",
          parameters: [
             .init(name: "section", location: "query", description: "Valid sections - Total, Private, Public", required: true, type: "string")
          ],
          requestBodySchema: nil,
          responseSchema: .genericArray, // Array of ConstructionSpendingDto
          possibleStatusCodes: getSectionCodes)
]

// MARK: - Helper Extensions

extension StatusCategory {
    var color: Color {
        switch self {
        case .success: return .green
        case .clientError: return .orange
        case .serverError: return .red
        case .informational: return .blue
        case .redirection: return .purple
        }
    }
}

// MARK: - Preview Provider

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
