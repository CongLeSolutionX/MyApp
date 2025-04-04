//
//  Untitled.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//

import SwiftUI

// MARK: - Data Models (Matching JSON Structure)

// Represents the top-level API response
struct ApiResponse: Decodable {
    let help: String
    let success: Bool
    let result: ApiResult
}

// Represents the 'result' object in the JSON
struct ApiResult: Decodable {
    let includeTotal: Bool
    let limit: Int
    let recordsFormat: String
    let resourceId: String
    let totalEstimationThreshold: String? // Use optional if it can be null
    let records: [EmploymentRecord]
    let fields: [Field]
    let links: Links
    let total: Int
    let totalWasEstimated: Bool

    enum CodingKeys: String, CodingKey {
        case includeTotal = "include_total"
        case limit
        case recordsFormat = "records_format"
        case resourceId = "resource_id"
        case totalEstimationThreshold = "total_estimation_threshold"
        case records
        case fields
        case links = "_links"
        case total
        case totalWasEstimated = "total_was_estimated"
    }
}

// Represents a single employment record
struct EmploymentRecord: Decodable, Identifiable {
    let id: Int // Use _id as the identifiable ID
    let areaType: String
    let areaName: String
    let year: String
    let quarter: String
    let ownership: String
    let naicsLevel: String
    let naicsCode: String
    let industryName: String
    let establishments: String // Keep as String as per JSON, can convert later if needed
    let averageMonthlyEmployment: String
    let firstMonthEmp: String
    let secondMonthEmp: String
    let thirdMonthEmp: String
    let totalWagesAllWorkers: String
    let averageWeeklyWages: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case areaType = "Area Type"
        case areaName = "Area Name"
        case year = "Year"
        case quarter = "Quarter"
        case ownership = "Ownership"
        case naicsLevel = "NAICS Level"
        case naicsCode = "NAICS Code"
        case industryName = "Industry Name"
        case establishments = "Establishments"
        case averageMonthlyEmployment = "Average Monthly Employment"
        case firstMonthEmp = "1st Month Emp"
        case secondMonthEmp = "2nd Month Emp"
        case thirdMonthEmp = "3rd Month Emp"
        case totalWagesAllWorkers = "Total Wages (All Workers)"
        case averageWeeklyWages = "Average Weekly Wages"
    }
}

// Represents a field description
struct Field: Decodable, Identifiable { // Add Identifiable if needed for display
    let id: String
    let type: String
    let info: FieldInfo? // Optional as it might not always be present
}

// Represents the 'info' object within a field description
struct FieldInfo: Decodable {
    let label: String? // Optional based on JSON sample
    let notes: String? // Optional based on JSON sample
    let typeOverride: String?

    enum CodingKeys: String, CodingKey {
        case label
        case notes
        case typeOverride = "type_override"
    }
}

// Represents the pagination links
struct Links: Decodable {
    let start: String
    let next: String
}

// MARK: - Sample Data (For Previewing)

let sampleJsonData = """
{
  "help": "https://data.ca.gov/api/3/action/help_show?name=datastore_search",
  "success": true,
  "result": {
    "include_total": true,
    "limit": 5,
    "records_format": "objects",
    "resource_id": "577beabf-3f53-4848-807f-adfd0551831c",
    "total_estimation_threshold": null,
    "records": [
      {
        "_id": 1,
        "Area Type": "County",
        "Area Name": "Alameda County",
        "Year": "2004",
        "Quarter": "1st Qtr",
        "Ownership": "State Government",
        "NAICS Level": "5",
        "NAICS Code": "92212",
        "Industry Name": "Police Protection",
        "Establishments": "10",
        "Average Monthly Employment": "354",
        "1st Month Emp": "356",
        "2nd Month Emp": "353",
        "3rd Month Emp": "353",
        "Total Wages (All Workers)": "2532357",
        "Average Weekly Wages": "550"
      },
      {
        "_id": 2,
        "Area Type": "County",
        "Area Name": "Alameda County",
        "Year": "2004",
        "Quarter": "1st Qtr",
        "Ownership": "Private",
        "NAICS Level": "6",
        "NAICS Code": "325612",
        "Industry Name": "Polish and Sanitation Good Manufacturing",
        "Establishments": "7",
        "Average Monthly Employment": "638",
        "1st Month Emp": "636",
        "2nd Month Emp": "639",
        "3rd Month Emp": "641",
        "Total Wages (All Workers)": "53376354",
        "Average Weekly Wages": "6429"
      },
      {
        "_id": 3,
        "Area Type": "County",
        "Area Name": "Alameda County",
        "Year": "2004",
        "Quarter": "1st Qtr",
        "Ownership": "Private",
        "NAICS Level": "5",
        "NAICS Code": "33341",
        "Industry Name": "HVAC and Commercial Refrigeration Equip",
        "Establishments": "15",
        "Average Monthly Employment": "354",
        "1st Month Emp": "356",
        "2nd Month Emp": "354",
        "3rd Month Emp": "352",
        "Total Wages (All Workers)": "7828534",
        "Average Weekly Wages": "1701"
      },
      {
        "_id": 4,
        "Area Type": "County",
        "Area Name": "Alameda County",
        "Year": "2004",
        "Quarter": "1st Qtr",
        "Ownership": "Private",
        "NAICS Level": "4",
        "NAICS Code": "4441",
        "Industry Name": "Building Material and Supplies Dealers",
        "Establishments": "225",
        "Average Monthly Employment": "5172",
        "1st Month Emp": "5163",
        "2nd Month Emp": "5132",
        "3rd Month Emp": "5221",
        "Total Wages (All Workers)": "42069506",
        "Average Weekly Wages": "626"
      },
      {
        "_id": 5,
        "Area Type": "County",
        "Area Name": "Alameda County",
        "Year": "2004",
        "Quarter": "1st Qtr",
        "Ownership": "Private",
        "NAICS Level": "6",
        "NAICS Code": "711130",
        "Industry Name": "Musical Groups and Artists",
        "Establishments": "35",
        "Average Monthly Employment": "306",
        "1st Month Emp": "252",
        "2nd Month Emp": "261",
        "3rd Month Emp": "406",
        "Total Wages (All Workers)": "1053787",
        "Average Weekly Wages": "265"
      }
    ],
    "fields": [
      {"id": "_id", "type": "int"},
      {"id": "Area Type", "type": "text", "info": {"notes": "Geo type"}},
      {"id": "Area Name", "type": "text", "info": {"notes": "Geo name"}},
      {"id": "Year", "type": "text"},
      {"id": "Quarter", "type": "text"},
      {"id": "Ownership", "type": "text"},
      {"id": "NAICS Level", "type": "text"},
      {"id": "NAICS Code", "type": "text"},
      {"id": "Industry Name", "type": "text"},
      {"id": "Establishments", "type": "text"},
      {"id": "Average Monthly Employment", "type": "text"},
      {"id": "1st Month Emp", "type": "text"},
      {"id": "2nd Month Emp", "type": "text"},
      {"id": "3rd Month Emp", "type": "text"},
      {"id": "Total Wages (All Workers)", "type": "text"},
      {"id": "Average Weekly Wages", "type": "text"}
    ],
    "_links": {
      "start": "/api/3/action/datastore_search?limit=5&resource_id=...",
      "next": "/api/3/action/datastore_search?limit=5&resource_id=...&offset=5"
    },
    "total": 1033078,
    "total_was_estimated": false
  }
}
""".data(using: .utf8)!

// Function to decode sample data (replace with actual network call later)
func loadSampleData() -> ApiResponse? {
    let decoder = JSONDecoder()
    do {
        let decodedResponse = try decoder.decode(ApiResponse.self, from: sampleJsonData)
        return decodedResponse
    } catch {
        print("Error decoding sample JSON: \(error)")
        return nil
    }
}

// MARK: - SwiftUI Views

// Main view displaying the list of employment records
struct EmploymentDataView: View {
    // In a real app, this would be a @StateObject ViewModel fetching data
    @State private var apiResponse: ApiResponse? = loadSampleData() // Load sample data

    var body: some View {
        NavigationView {
            VStack {
                if let response = apiResponse {
                    Text("Total Records: \(response.result.total)")
                        .font(.headline)
                        .padding(.top)

                    List(response.result.records) { record in
                        RecordRow(record: record)
                    }
                } else {
                    ProgressView("Loading Data...") // Show loading indicator
                }
            }
            .navigationTitle("CA Employment Data")
        }
        // Add .onAppear or Task to fetch real data in a real app
    }
}

// Represents a single row in the list
struct RecordRow: View {
    let record: EmploymentRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(record.industryName)
                .font(.headline)
            Text("\(record.areaName) (\(record.year) - \(record.quarter))")
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack {
                Text("Ownership:")
                Text(record.ownership).fontWeight(.medium)
                Spacer()
                Text("Avg Weekly Wage:")
                Text(record.averageWeeklyWages).fontWeight(.medium)
            }
            .font(.caption)
        }
        .padding(.vertical, 4) // Add some vertical padding within the row
    }
}

// MARK: - Preview

struct EmploymentDataView_Previews: PreviewProvider {
    static var previews: some View {
        EmploymentDataView()
    }
}
