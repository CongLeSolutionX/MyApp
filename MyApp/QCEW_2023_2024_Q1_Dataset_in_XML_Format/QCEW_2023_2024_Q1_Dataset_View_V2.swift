//
//  V2.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//

import Foundation

// Represents the properties within an <entry><content><m:properties> tag
struct QCEWEntryProperties {
    var recordId: String = "" // Corresponds to <d:_id>
    var areaType: String = ""
    var areaName: String = ""
    var year: String = ""
    var timePeriod: String = ""
    var ownership: String = ""
    var naicsLevel: String = ""
    var naicsCode: String = ""
    var industryName: String = ""
    var establishments: String = ""
    var averageMonthlyEmployment: String = ""
    var firstMonthEmp: String = "" // Corresponds to <d:_1stMonthEmp>
    var secondMonthEmp: String = "" // Corresponds to <d:_2ndMonthEmp>
    var thirdMonthEmp: String = "" // Corresponds to <d:_3rdMonthEmp>
    var totalWagesAllWorkers: String = ""
    var averageWeeklyWages: String = ""

    // Computed properties for convenient numeric access
    var establishmentsInt: Int? { Int(establishments) }
    var averageMonthlyEmploymentInt: Int? { Int(averageMonthlyEmployment) }
    var firstMonthEmpInt: Int? { Int(firstMonthEmp) }
    var secondMonthEmpInt: Int? { Int(secondMonthEmp) }
    var thirdMonthEmpInt: Int? { Int(thirdMonthEmp) }
    var totalWagesAllWorkersInt: Int? { Int(totalWagesAllWorkers) }
    var averageWeeklyWagesInt: Int? { Int(averageWeeklyWages) }
}

// Represents a single <entry> in the Atom feed
struct QCEWEntry: Identifiable {
    let id = UUID() // Unique ID for SwiftUI List iterations
    var properties: QCEWEntryProperties
}

// MARK: - QCEWViewModel


import SwiftUI
import Foundation

// MARK: - View Model

@MainActor // Ensures @Published updates happen on the main thread
class QCEWViewModel: ObservableObject {
    @Published var entries: [QCEWEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // Function to load and parse data from a local file
    func loadDataFromFile(filename: String = "qcew_data", fileType: String = "xml") {
        guard !isLoading else { return } // Prevent concurrent loads

        isLoading = true
        errorMessage = nil
        entries = [] // Clear previous results

        Task(priority: .userInitiated) { // Perform file reading and parsing in background
            do {
                // 1. Find the file URL in the app bundle
                guard let fileUrl = Bundle.main.url(forResource: filename, withExtension: fileType) else {
                     // Use a custom Error enum for better error handling if desired
                    throw NSError(domain: "QCEWViewModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "Error: \(filename).\(fileType) not found in the app bundle. Ensure it's added to the target."])
                }

                // 2. Load the data from the file URL
                let data = try Data(contentsOf: fileUrl) // This can throw an error

                // 3. Parse the XML data using our dedicated parser
                let parserDelegate = QCEWXmlParser()
                let parsedEntries = parserDelegate.parse(data: data)

                // 4. Update the UI state on the main thread
                // await MainActor.run { ... } // Not strictly needed since the class is @MainActor
                if let parseError = parserDelegate.parsingError {
                     // If the delegate caught an error during parsing itself
                    throw parseError // Propagate the parsing error
                 } else if parsedEntries.isEmpty {
                      // Check if parsing succeeded but returned no entries
                      self.errorMessage = "XML parsed successfully, but no QCEW entries were found in the data."
                      print(self.errorMessage!)
                      self.entries = [] // Ensure entries are empty
                 } else {
                     self.entries = parsedEntries
                     self.errorMessage = nil // Ensure no previous error message lingers
                 }
                 self.isLoading = false // Stop loading indicator

            } catch {
                // Catch errors from file loading (Data(contentsOf:)) or parsing errors propagated
                // await MainActor.run { ... } // Not strictly needed since the class is @MainActor
                self.errorMessage = "Failed to load or parse local file: \(error.localizedDescription)"
                print(self.errorMessage!)
                self.entries = [] // Clear entries on error
                self.isLoading = false // Stop loading indicator
            }
        }
    }
}


import Foundation

// MARK: - XML Parser Delegate

class QCEWXmlParser: NSObject, XMLParserDelegate {
    private var entries: [QCEWEntry] = []
    private var currentEntryProperties: QCEWEntryProperties?
    private var currentElementString: String = ""
    private var currentElementName: String = ""
    private var parsingEntry = false
    private var parsingProperties = false
    private(set) var parsingError: Error? // Store parsing error

    func parse(data: Data) -> [QCEWEntry] {
        self.entries = [] // Reset before parsing
        self.parsingError = nil // Reset error state
        let parser = XMLParser(data: data)
        parser.delegate = self
        // The delegate methods will populate self.entries and self.parsingError
        if parser.parse() {
            // Parsing itself succeeded, return entries (might be empty if data was valid but empty)
             return entries
        } else {
             // Parsing failed, parsingError should be set by the delegate's parseErrorOccurred
             print("XMLParser reported failure.")
             return [] // Return empty on failure
        }
    }

    // Called when starting to parse an element
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElementString = "" // Reset string accumulator
        currentElementName = elementName // Store element name (might include prefix)

        if elementName == "entry" {
            parsingEntry = true
            currentEntryProperties = QCEWEntryProperties()
        } else if elementName == "m:properties" {
             // Handle potential variations like <properties> vs <m:properties>
             parsingProperties = true
        } else if parsingProperties {
            // Store the local name (without namespace prefix) if parsing a property
            let localName = elementName.components(separatedBy: ":").last ?? elementName
            currentElementName = localName // Use local name for easier matching in didEndElement
        }
    }

    // Called when characters are found within an element
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentElementString += string
    }

    // Called when ending parsing an element
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard parsingEntry, var props = currentEntryProperties else {
            if elementName == "entry" { parsingEntry = false }
            if elementName == "m:properties" || elementName == "properties" { parsingProperties = false }
            return
        }

        // Use the element name without prefix for closing tags as well
        let localEndElementName = elementName.components(separatedBy: ":").last ?? elementName

        if localEndElementName == "entry" {
            // Sanity check: Ensure we were actually parsing properties before finishing entry
            // (Helps catch malformed XML where <entry> closes prematurely)
             if !props.recordId.isEmpty || !props.industryName.isEmpty { // Check if *any* property was set
                entries.append(QCEWEntry(properties: props))
             } else {
                 print("Warning: Closed <entry> tag without finding any relevant properties inside.")
             }
            currentEntryProperties = nil
            parsingEntry = false
            parsingProperties = false
        } else if localEndElementName == "properties" {
            parsingProperties = false
            // Update the state of the optional property struct
            currentEntryProperties = props
        } else if parsingProperties {
             // Use the stored local name (from didStartElement) for mapping
            let propertyName = currentElementName
            let value = currentElementString.trimmingCharacters(in: .whitespacesAndNewlines)

             // Map the parsed value to the correct property in the struct
            switch propertyName {
                 case "_id": props.recordId = value
                 case "AreaType": props.areaType = value
                 case "AreaName": props.areaName = value
                 case "Year": props.year = value
                 case "TimePeriod": props.timePeriod = value
                 case "Ownership": props.ownership = value
                 case "NAICSLevel": props.naicsLevel = value
                 case "NAICSCode": props.naicsCode = value
                 case "IndustryName": props.industryName = value
                 case "Establishments": props.establishments = value
                 case "AverageMonthlyEmployment": props.averageMonthlyEmployment = value
                 case "_1stMonthEmp": props.firstMonthEmp = value
                 case "_2ndMonthEmp": props.secondMonthEmp = value
                 case "_3rdMonthEmp": props.thirdMonthEmp = value
                 case "TotalWagesAllWorkers": props.totalWagesAllWorkers = value
                 case "AverageWeeklyWages": props.averageWeeklyWages = value
                 default: break // Ignore other elements within properties
            }
             currentEntryProperties = props // Update the struct state
        }
         currentElementName = "" // Reset for the next element start
    }

    // Handle parsing errors
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("XML Parsing Delegate Error: \(parseError.localizedDescription)")
        // Store the error so the ViewModel can access it
        self.parsingError = parseError
    }
}



// MARK: - QCEWViews

import SwiftUI

// MARK: - SwiftUI Views

struct ContentView: View {
    // Use @StateObject for the ViewModel in the view that owns it
    @StateObject private var viewModel = QCEWViewModel()

    var body: some View {
        NavigationStack { // Or NavigationView for older iOS versions
            Group { // Use Group to easily switch content based on state
                if viewModel.isLoading {
                    ProgressView("Loading Data from File...")
                } else if let errorMessage = viewModel.errorMessage {
                    // Display error state
                    VStack(spacing: 10) {
                         Image(systemName: "exclamationmark.triangle.fill")
                             .resizable()
                             .scaledToFit()
                             .frame(width: 50, height: 50)
                             .foregroundColor(.orange)
                         Text("Error Loading Data")
                             .font(.headline)
                         Text(errorMessage)
                             .font(.caption)
                             .foregroundColor(.secondary)
                             .multilineTextAlignment(.center)
                             .padding(.horizontal)
                         Button("Retry Load") {
                             viewModel.loadDataFromFile() // Call the correct loading function
                         }
                         .buttonStyle(.borderedProminent)
                         .padding(.top)
                     }
                } else if viewModel.entries.isEmpty {
                    // Display empty state
                     Text("No QCEW entries found in the local file.")
                         .foregroundColor(.secondary)
                         .multilineTextAlignment(.center)
                         .padding()
                         Button("Attempt Load Again") {
                             viewModel.loadDataFromFile()
                         }
                         .buttonStyle(.bordered)
                } else {
                    // Display the list of data
                    List { // Automatically handles dynamic data updates via ForEach
                        ForEach(viewModel.entries) { entry in
                             QCEWEntryRow(entry: entry.properties)
                         }
                    }
                }
            }
            .navigationTitle("QCEW Q1 2023 - Alameda (Local)")
            .onAppear {
                // Load data when the view first appears if it hasn't been loaded yet
                if viewModel.entries.isEmpty && viewModel.errorMessage == nil && !viewModel.isLoading {
                    viewModel.loadDataFromFile() // Call the correct loading function
                }
            }
            // Optional: Add a refresh button if needed
             .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button {
                         viewModel.loadDataFromFile()
                     } label: {
                         Label("Refresh", systemImage: "arrow.clockwise")
                     }
                     .disabled(viewModel.isLoading)
                 }
             }
        }
    }
}

// Row view remains largely the same
struct QCEWEntryRow: View {
    let entry: QCEWEntryProperties

    var body: some View {
         VStack(alignment: .leading, spacing: 8) {
             Text(entry.industryName.isEmpty ? "Unknown Industry" : entry.industryName) // Handle empty string
                .font(.headline)

             HStack {
                 Text(entry.areaName.isEmpty ? "N/A" : entry.areaName)
                 Spacer()
                 Text("\(entry.year.isEmpty ? "N/A" : entry.year) - \(entry.timePeriod.isEmpty ? "N/A" : entry.timePeriod)")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            Divider().padding(.vertical, 2) // Add small padding around divider

             // Use Grid for potentially better alignment if needed, HStack is fine too
            Grid(alignment: .leading) {
                 GridRow {
                     InfoItem(label: "Ownership", value: entry.ownership.isEmpty ? "N/A" : entry.ownership)
                     InfoItem(label: "NAICS", value: entry.naicsCode.isEmpty ? "N/A" : entry.naicsCode)
                 }
                 GridRow {
                     InfoItem(label: "Establishments", value: formattedInt(entry.establishmentsInt))
                     InfoItem(label: "Avg Monthly Emp", value: formattedInt(entry.averageMonthlyEmploymentInt))
                 }
                 GridRow {
                      InfoItem(label: "Total Wages ($)", value: formattedInt(entry.totalWagesAllWorkersInt))
                      InfoItem(label: "Avg Weekly Wage ($)", value: formattedInt(entry.averageWeeklyWagesInt))
                 }
             }
        }
        .padding(.vertical, 6) // Consistent padding for the whole row
    }

     // Helper to format optional integers with commas, moved outside body
     private func formattedInt(_ value: Int?) -> String {
         guard let value = value else { return "--" } // Use "--" or "N/A" for clarity
         let formatter = NumberFormatter()
         formatter.numberStyle = .decimal
         formatter.groupingSeparator = "," // Explicitly set separator
         return formatter.string(from: NSNumber(value: value)) ?? "--"
     }
}

// Reusable helper view remains the same
struct InfoItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) { // Reduced spacing
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.system(.body, design: .rounded)) // Use rounded design for numbers potentially
                .lineLimit(1) // Prevent wrapping if value is too long
                 .minimumScaleFactor(0.8) // Allow text to shrink slightly
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Ensure it takes available width in Grid
    }
}

// MARK: - SwiftUI Preview (Loads sample data for preview)

// Create sample data specifically for the preview
private func createPreviewData() -> [QCEWEntry] {
     let sampleProps1 = QCEWEntryProperties(
         recordId: "1", areaType: "County", areaName: "Alameda County", year: "2023",
         timePeriod: "1st Qtr", ownership: "Private", naicsLevel: "6", naicsCode: "524298",
         industryName: "All Other Insurance Related Activities", establishments: "10",
         averageMonthlyEmployment: "223", firstMonthEmp: "223", secondMonthEmp: "225",
         thirdMonthEmp: "223", totalWagesAllWorkers: "8435605", averageWeeklyWages: "2901"
     )
     let sampleProps2 = QCEWEntryProperties(
         recordId: "2", areaType: "County", areaName: "Alameda County", year: "2023",
         timePeriod: "1st Qtr", ownership: "Private", naicsLevel: "2", naicsCode: "54",
         industryName: "Professional and Technical Services", establishments: "7315",
         averageMonthlyEmployment: "76545", firstMonthEmp: "76542", secondMonthEmp: "76918",
         thirdMonthEmp: "76176", totalWagesAllWorkers: "3445535679", averageWeeklyWages: "3463"
     )
     let sampleProps3 = QCEWEntryProperties( // Example with potentially missing data for testing formatting
         recordId: "3", areaType: "County", areaName: "Sample County", year: "2024",
         timePeriod: "2nd Qtr", ownership: "Gov", naicsLevel: "", naicsCode: "",
         industryName: "Test Industry No Numbers", establishments: "",
         averageMonthlyEmployment: "", firstMonthEmp: "", secondMonthEmp: "",
         thirdMonthEmp: "", totalWagesAllWorkers: "", averageWeeklyWages: ""
     )
     return [
         QCEWEntry(properties: sampleProps1),
         QCEWEntry(properties: sampleProps2),
         QCEWEntry(properties: sampleProps3)
     ]
 }

//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Preview with sample data loaded directly into the ViewModel
//         let previewViewModel = QCEWViewModel()
//         previewViewModel.entries = createPreviewData() // Manually set sample data
//         previewViewModel.isLoading = false
//         previewViewModel.errorMessage = nil
//
//         ContentView(viewModel: previewViewModel) // Inject the configured ViewModel
//
//        // Preview the Loading State
//        let loadingViewModel = QCEWViewModel()
//        loadingViewModel.isLoading = true
//        ContentView(viewModel: loadingViewModel)
//            .previewDisplayName("Loading State")
//
//        // Preview the Error State
//        let errorViewModel = QCEWViewModel()
//        errorViewModel.errorMessage = "Preview Error: Could not find the local XML file 'sample.xml'."
//        ContentView(viewModel: errorViewModel)
//            .previewDisplayName("Error State")
//
//         // Preview the Empty State (after loading attempt with no results)
//        let emptyViewModel = QCEWViewModel()
//        emptyViewModel.isLoading = false
//        emptyViewModel.entries = []
//        emptyViewModel.errorMessage = nil // Explicitly nil
//        ContentView(viewModel: emptyViewModel)
//            .previewDisplayName("Empty State")
//    }
//}



#Preview() {
    ContentView()
}
