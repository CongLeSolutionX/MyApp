//
//  APIDocumentationView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//

import SwiftUI

// MARK: - Data Structures (Mirroring OpenAPI Schemas)

// Note: These structs are for visual representation in the UI, not actual data fetching.
struct NhsResultsRepresentation {
    let date: String = "Nov-17 (example)"
    let questions: [NhsQuestionRepresentation] = [NhsQuestionRepresentation()]
}

struct NhsQuestionRepresentation {
    let id: String = "Q15 (example)"
    let idEnum: [String] = ["Q10", "Q11", "Q12", "Q13", "Q15", "Q18", "Q20B", "Q22", "Q31", "Q112BF", "Q116"]
    let description: String = "During the next 12 months, do you think home prices in general will go up, go down, or stay the same... (example)"
    let responses: [NhsResponseRepresentation] = [NhsResponseRepresentation()]
}

struct NhsResponseRepresentation {
    let description: String = "Right track (example)"
    let percent: Double = 50.0
}

struct HpsiDataRepresentation {
    let hpsiValue: Double = 87.8
    let date: String = "Nov-17 (example)"
}

// MARK: - Helper Views

struct ParameterDetailView: View {
    let name: String
    let location: String // "path", "query", etc.
    let description: String
    let required: Bool
    let schemaType: String
    let enumValues: [String]? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name).bold().font(.system(.caption, design: .monospaced))
                Text("(\(location))").font(.caption).italic()
                if required {
                    Text("Required").font(.caption).foregroundColor(.orange)
                }
                Spacer()
                Text(schemaType).font(.system(.caption, design: .monospaced))
            }
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)

            if let enumValues = enumValues, !enumValues.isEmpty {
                 DisclosureGroup("Enum Values") {
                    VStack(alignment: .leading) {
                         ForEach(enumValues, id: \.self) { value in
                             Text(value).font(.caption).padding(.leading)
                         }
                    }
                 }.font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ResponseDetailView: View {
    let statusCode: String
    let description: String
    let schemaRef: String?
    let isError: Bool

    var body: some View {
        HStack {
            Text(statusCode)
                .bold()
                .foregroundColor(isError ? .red : .green)
                .font(.system(.body, design: .monospaced))
            Text(description)
            Spacer()
            if let schemaRef = schemaRef {
                 Text(schemaRef)
                     .font(.system(.caption, design: .monospaced))
                     .foregroundColor(.blue) // Indicate it's a schema reference
            }
        }
        .padding(.vertical, 2)
    }
}

struct EndpointView: View {
    let path: String
    let method: String
    let summary: String
    let description: String
    let parameters: [ParameterDetailView]
    let responses: [ResponseDetailView]

    var methodColor: Color {
        switch method.uppercased() {
        case "GET": return .green
        case "POST": return .blue
        case "PUT": return .orange
        case "DELETE": return .red
        default: return .gray
        }
    }

    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 10) {
                Text(description).font(.caption).foregroundColor(.secondary)
                Divider()

                if !parameters.isEmpty {
                    Text("Parameters").font(.headline).padding(.bottom, -5)
                    ForEach(parameters.indices, id: \.self) { index in
                         parameters[index]
                         if index < parameters.count - 1 { Divider() }
                    }
                    Divider()
                }


                Text("Responses").font(.headline).padding(.bottom, -5)
                ForEach(responses.indices, id: \.self) { index in
                    responses[index]
                     if index < responses.count - 1 { Divider().padding(.leading) }
                }
            }
            .padding(.top, 5)
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    Text(method.uppercased())
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .background(methodColor)
                        .cornerRadius(3)
                    Text(path)
                        .font(.system(.body, design: .monospaced))
                }
                Text(summary).font(.subheadline).padding(.top, 1)
            }
        }
        .padding(.vertical, 5)
    }
}

// MARK: - Main Documentation View

struct APIDocumentationView: View {
    var body: some View {
        NavigationView {
            List {
                // MARK: - API Info
                Section(header: Text("API Information").font(.title2)) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("National Housing Survey API")
                            .font(.title3)
                            .bold()
                        Text("Provides National Housing Survey (NHS) and Home Purchase Sentiment Index (HPSI) data.")
                            .foregroundColor(.secondary)
                        Link("Official Fannie Mae NHS Page", destination: URL(string: "http://www.fanniemae.com/portal/research-insights/surveys/national-housing-survey.html")!)
                            .font(.caption)
                    }
                    .padding(.vertical)
                }

                // MARK: - Server Info
                 Section(header: Text("Server")) {
                      HStack {
                           Image(systemName: "server.rack")
                           Text("Base URL:")
                           Spacer()
                           Text("https://api.fanniemae.com")
                                .font(.system(.body, design: .monospaced))
                      }
                 }

                // MARK: - Endpoints
                Section(header: Text("Endpoints").font(.title3)) {

                    // --- /v1/nhs/results ---
                    EndpointView(
                        path: "/v1/nhs/results",
                        method: "GET",
                        summary: "Get all NHS results.",
                        description: "Returns all available monthly survey data, including questions and participant response percentages. Polls 1,000 consumers monthly on housing topics.",
                        parameters: [],
                        responses: [
                            ResponseDetailView(statusCode: "200", description: "Success", schemaRef: "[NhsResults]", isError: false),
                            ResponseDetailView(statusCode: "401", description: "Unauthorized", schemaRef: nil, isError: true),
                            ResponseDetailView(statusCode: "403", description: "Forbidden", schemaRef: nil, isError: true),
                            ResponseDetailView(statusCode: "404", description: "No NHS data found", schemaRef: nil, isError: true),
                            ResponseDetailView(statusCode: "500", description: "Server Error", schemaRef: nil, isError: true)
                        ]
                    )

                    // --- /v1/nhs/hpsi ---
                    EndpointView(
                        path: "/v1/nhs/hpsi",
                        method: "GET",
                        summary: "Get all HPSI data.",
                        description: "Returns the monthly Home Purchase Sentiment Index (HPSI) values, a predictive indicator based on the NHS.",
                        parameters: [],
                        responses: [
                            ResponseDetailView(statusCode: "200", description: "Success", schemaRef: "[HpsiData]", isError: false),
                            ResponseDetailView(statusCode: "401", description: "Unauthorized", schemaRef: nil, isError: true),
                            ResponseDetailView(statusCode: "403", description: "Forbidden", schemaRef: nil, isError: true),
                            ResponseDetailView(statusCode: "404", description: "No HPSI data found", schemaRef: nil, isError: true),
                            ResponseDetailView(statusCode: "500", description: "Server Error", schemaRef: nil, isError: true)
                        ]
                    )

                    // --- /v1/nhs/hpsi/area-type/{areatype} ---
                     EndpointView(
                         path: "/v1/nhs/hpsi/area-type/{areatype}",
                         method: "GET",
                         summary: "Get HPSI data by Area Type.",
                         description: "Returns HPSI values filtered by the specified area type.",
                         parameters: [
                            ParameterDetailView(name: "areatype", location: "path", description: "The area type.", required: true, schemaType: "string")
                         ],
                         responses: [
                             ResponseDetailView(statusCode: "200", description: "Success", schemaRef: "[HpsiData]", isError: false),
                             ResponseDetailView(statusCode: "400", description: "Invalid area type", schemaRef: nil, isError: true),
                             ResponseDetailView(statusCode: "401", description: "Unauthorized", schemaRef: nil, isError: true),
                             ResponseDetailView(statusCode: "403", description: "Forbidden", schemaRef: nil, isError: true),
                             ResponseDetailView(statusCode: "404", description: "No HPSI data found", schemaRef: nil, isError: true),
                             ResponseDetailView(statusCode: "500", description: "Server Error", schemaRef: nil, isError: true)
                         ]
                     )

                     // --- /v1/nhs/hpsi/ownership-status/{ownershipstatus} ---
                     EndpointView(
                         path: "/v1/nhs/hpsi/ownership-status/{ownershipstatus}",
                         method: "GET",
                         summary: "Get HPSI data by Ownership Status.",
                         description: "Returns HPSI values filtered by owner or renter status.",
                         parameters: [
                              ParameterDetailView(name: "ownershipstatus", location: "path", description: "The ownership status.", required: true, schemaType: "string")
                         ],
                         responses: [
                             ResponseDetailView(statusCode: "200", description: "Success", schemaRef: "[HpsiData]", isError: false),
                             ResponseDetailView(statusCode: "400", description: "Invalid ownership status", schemaRef: nil, isError: true),
                             // ... other common errors 401, 403, 404, 500
                         ]
                     )

                    // --- Add other HPSI filtered endpoints similarly ---
                    // /housing-cost-ratio/{housingcostratio}
                    // /age-groups/{agegp}
                    // /census-region/{censusregion}
                    // /income-groups/{incomegp}
                    // /education/{educationlvl}
                    // (For brevity, these follow the same pattern as area-type and ownership-status)
                     Group {
                         Text("Other HPSI Filtered Endpoints:").font(.caption).foregroundColor(.gray).padding(.leading)
                         Text(" • /housing-cost-ratio/{housingcostratio} ('1'=Low, '2'=Mid, '3'=High)")
                         Text(" • /age-groups/{agegp} ('1'=18-34, '2'=35-44, '3'=45-64, '4'=65+)")
                         Text(" • /census-region/{censusregion} ('1'=NE, '2'=MW, '3'=S, '4'=W)")
                         Text(" • /income-groups/{incomegp} ('1'=<$50K, '2'=$50-100K, '3'=$100K+)")
                         Text(" • /education/{educationlvl} ('1'=<HS, '2'=HS, '3'=Some College, '4'=College+)")
                     }
                     .font(.caption)
                     .foregroundColor(.secondary)
                     .padding(.vertical, 5)

                }

                 // MARK: - Data Schemas (Components)
                 Section(header: Text("Data Schemas").font(.title3)) {
                     DisclosureGroup("NhsResults") {
                          VStack(alignment: .leading) {
                               Text("Represents the results for a specific survey date.").font(.caption).foregroundColor(.gray)
                               Divider()
                               HStack { Text("date").bold(); Spacer(); Text("string").italic(); Text("e.g., Nov-17") }
                               HStack { Text("questions").bold(); Spacer(); Text("[NhsQuestion]").italic().foregroundColor(.blue) }
                          }.padding(.vertical, 5)
                     }

                     DisclosureGroup("NhsQuestion") {
                          VStack(alignment: .leading) {
                               Text("Represents a single question asked in the survey.").font(.caption).foregroundColor(.gray)
                               Divider()
                               HStack { Text("id").bold(); Spacer(); Text("string (enum)").italic(); Text("e.g., Q15") }
                               ParameterDetailView(name: "id enum values", location: "", description: "", required: false, schemaType: "")
                                   .padding(.leading)


                               HStack { Text("description").bold(); Spacer(); Text("string").italic() }
                               Text(NhsQuestionRepresentation().description).font(.caption).foregroundColor(.gray).padding(.bottom, 5)


                               HStack { Text("responses").bold(); Spacer(); Text("[NhsResponse]").italic().foregroundColor(.blue) }
                          }.padding(.vertical, 5)
                     }

                     DisclosureGroup("NhsResponse") {
                          VStack(alignment: .leading) {
                               Text("Represents a possible response to a question and the percentage of participants choosing it.").font(.caption).foregroundColor(.gray)
                               Divider()
                               HStack { Text("description").bold(); Spacer(); Text("string").italic(); Text("e.g., Right track") }
                               HStack { Text("percent").bold(); Spacer(); Text("number (double)").italic(); Text("e.g., 50.0") }
                          }.padding(.vertical, 5)
                     }

                     DisclosureGroup("HpsiData") {
                          VStack(alignment: .leading) {
                               Text("Represents the Home Purchase Sentiment Index value for a specific date.").font(.caption).foregroundColor(.gray)
                               Divider()
                               HStack { Text("hpsiValue").bold(); Spacer(); Text("number (double)").italic(); Text("e.g., 87.8") }
                               HStack { Text("date").bold(); Spacer(); Text("string").italic(); Text("e.g., Nov-17") }
                          }.padding(.vertical, 5)
                     }
                 }

            } // End List
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("NHS API Documentation")
        } // End NavigationView
    }
}

// MARK: - Preview
struct APIDocumentationView_Previews: PreviewProvider {
    static var previews: some View {
        APIDocumentationView()
    }
}
