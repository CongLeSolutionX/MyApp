////
////  QCEW_2023_2024_Q1_Dataset_View.swift
////  MyApp
////
////  Created by Cong Le on 4/3/25.
////
//
//
//import SwiftUI
//import Foundation // Required for XMLParser
//
//// MARK: - Data Models
//
//// Represents the properties within an <entry><content><m:properties> tag
//struct QCEWEntryProperties {
//    var recordId: String = "" // Corresponds to <d:_id>
//    var areaType: String = ""
//    var areaName: String = ""
//    var year: String = ""
//    var timePeriod: String = ""
//    var ownership: String = ""
//    var naicsLevel: String = ""
//    var naicsCode: String = ""
//    var industryName: String = ""
//    var establishments: String = ""
//    var averageMonthlyEmployment: String = ""
//    var firstMonthEmp: String = "" // Corresponds to <d:_1stMonthEmp>
//    var secondMonthEmp: String = "" // Corresponds to <d:_2ndMonthEmp>
//    var thirdMonthEmp: String = "" // Corresponds to <d:_3rdMonthEmp>
//    var totalWagesAllWorkers: String = ""
//    var averageWeeklyWages: String = ""
//
//    // Computed properties for convenient numeric access
//    var establishmentsInt: Int? { Int(establishments) }
//    var averageMonthlyEmploymentInt: Int? { Int(averageMonthlyEmployment) }
//    var firstMonthEmpInt: Int? { Int(firstMonthEmp) }
//    var secondMonthEmpInt: Int? { Int(secondMonthEmp) }
//    var thirdMonthEmpInt: Int? { Int(thirdMonthEmp) }
//    var totalWagesAllWorkersInt: Int? { Int(totalWagesAllWorkers) }
//    var averageWeeklyWagesInt: Int? { Int(averageWeeklyWages) }
//}
//
//// Represents a single <entry> in the Atom feed
//struct QCEWEntry: Identifiable {
//    let id = UUID() // Unique ID for SwiftUI List iterations
//    var properties: QCEWEntryProperties
//}
//
//// MARK: - XML Parser Delegate
//
//class QCEWXmlParser: NSObject, XMLParserDelegate {
//    private var entries: [QCEWEntry] = []
//    private var currentEntryProperties: QCEWEntryProperties?
//    private var currentElementString: String = ""
//    private var currentElementName: String = ""
//    private var parsingEntry = false
//    private var parsingProperties = false
//
//    func parse(data: Data) -> [QCEWEntry] {
//        let parser = XMLParser(data: data)
//        parser.delegate = self
//        parser.parse()
//        return entries
//    }
//
//    // Called when starting to parse an element
//    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
//        currentElementString = "" // Reset string accumulator
//        currentElementName = elementName // Store the raw element name
//
//        if elementName == "entry" {
//            parsingEntry = true
//            currentEntryProperties = QCEWEntryProperties()
//        } else if elementName == "m:properties" {
//            parsingProperties = true
//        } else if parsingProperties {
//            // Store the local name (without namespace prefix) if parsing a property
//            let localName = elementName.components(separatedBy: ":").last ?? elementName
//            currentElementName = localName // Use local name moving forward for properties
//        }
//    }
//
//    // Called when characters are found within an element
//    func parser(_ parser: XMLParser, foundCharacters string: String) {
//        currentElementString += string
//    }
//
//    // Called when ending parsing an element
//    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//        guard parsingEntry, var props = currentEntryProperties else {
//            // Reset flags if we finished an entry or properties block without being inside one
//            if elementName == "entry" { parsingEntry = false }
//            if elementName == "m:properties" { parsingProperties = false }
//            return
//        }
//
//        if elementName == "entry" {
//            entries.append(QCEWEntry(properties: props))
//            currentEntryProperties = nil
//            parsingEntry = false
//            parsingProperties = false // Ensure this resets too
//            // print("Parsed Entry: \(props.industryName)") // Debugging
//        } else if elementName == "m:properties" {
//            parsingProperties = false
//            // Update the properties struct state in case it's needed outside this block
//            currentEntryProperties = props
//        } else if parsingProperties {
//             // Use the stored local name for mapping
//            let propertyName = currentElementName
//            let value = currentElementString.trimmingCharacters(in: .whitespacesAndNewlines)
//
//             // Map the parsed value to the correct property in the struct
//            switch propertyName {
//                case "_id": props.recordId = value
//                case "AreaType": props.areaType = value
//                case "AreaName": props.areaName = value
//                case "Year": props.year = value
//                case "TimePeriod": props.timePeriod = value
//                case "Ownership": props.ownership = value
//                case "NAICSLevel": props.naicsLevel = value
//                case "NAICSCode": props.naicsCode = value
//                case "IndustryName": props.industryName = value
//                case "Establishments": props.establishments = value
//                case "AverageMonthlyEmployment": props.averageMonthlyEmployment = value
//                case "_1stMonthEmp": props.firstMonthEmp = value
//                case "_2ndMonthEmp": props.secondMonthEmp = value
//                case "_3rdMonthEmp": props.thirdMonthEmp = value
//                case "TotalWagesAllWorkers": props.totalWagesAllWorkers = value
//                case "AverageWeeklyWages": props.averageWeeklyWages = value
//                default: break // Ignore other elements within properties
//            }
//             // Update the struct state
//            currentEntryProperties = props
//        }
//        currentElementName = "" // Reset element name after processing end tag
//    }
//
//    // Handle parsing errors
//    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
//        print("XML Parsing Error: \(parseError.localizedDescription)")
//        // Optionally clear results or set an error state
//        entries = []
//    }
//}
//
//// MARK: - View Model
//
//@MainActor // Ensures @Published updates happen on the main thread
//class QCEWViewModel: ObservableObject {
//    @Published var entries: [QCEWEntry] = []
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//
//    // Replace with the actual URL from the XML feed if different
//    private let feedURL = URL(string: "https://data.ca.gov/bs/datastore/odata3.0/119eef38-3b59-499f-8f7c-9bea4768469d?$top=500")! // Using top=500 like the example XML next link
//
//    func fetchData() {
//        guard !isLoading else { return } // Prevent concurrent fetches
//
//        isLoading = true
//        errorMessage = nil
//        entries = [] // Clear previous results
//
//        let task = URLSession.shared.dataTask(with: feedURL) { [weak self] data, response, error in
//            guard let self = self else { return }
//
//            // Ensure UI updates run on the main thread
//             DispatchQueue.main.async {
//                self.isLoading = false
//
//                if let error = error {
//                    self.errorMessage = "Failed to fetch data: \(error.localizedDescription)"
//                    print(self.errorMessage!)
//                    return
//                }
//
//                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
//                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
//                    self.errorMessage = "Server returned status code: \(statusCode)"
//                    print(self.errorMessage!)
//                    return
//                }
//
//                guard let data = data else {
//                    self.errorMessage = "No data received from server."
//                    print(self.errorMessage!)
//                    return
//                }
//
//                // Parse the XML data
//                let parserDelegate = QCEWXmlParser()
//                let parsedEntries = parserDelegate.parse(data: data)
//
//                 if parsedEntries.isEmpty && self.errorMessage == nil {
//                     // Check if parsing itself failed silently or returned no results
//                     // The delegate should set errorMessage if parserErrorOccurred was called
//                     if self.errorMessage == nil {
//                        self.errorMessage = "Parsing completed, but no entries found or parsing failed silently."
//                        print(self.errorMessage!)
//                     }
//                 } else {
//                     self.entries = parsedEntries
//                 }
//            }
//        }
//        task.resume()
//    }
//}
//
//// MARK: - SwiftUI Views
//
//struct QCEW_2023_2024_Q1_Dataset_View: View {
//    @StateObject private var viewModel = QCEWViewModel()
//
//    var body: some View {
//        NavigationStack { // Use NavigationStack for iOS 16+ or NavigationView otherwise
//            Group {
//                if viewModel.isLoading {
//                    ProgressView("Loading QCEW Data...")
//                } else if let errorMessage = viewModel.errorMessage {
//                    VStack {
//                         Text("Error Loading Data")
//                             .font(.headline)
//                             .foregroundColor(.red)
//                         Text(errorMessage)
//                             .font(.caption)
//                             .multilineTextAlignment(.center)
//                             .padding()
//                         Button("Retry") {
//                             viewModel.fetchData()
//                         }
//                         .buttonStyle(.borderedProminent)
//                     }
//                } else if viewModel.entries.isEmpty {
//                     Text("No QCEW entries found.")
//                         .foregroundColor(.secondary)
//                } else {
//                    List(viewModel.entries) { entry in
//                        QCEWEntryRow(entry: entry.properties)
//                    }
//                }
//            }
//            .navigationTitle("QCEW Q1 2023 - Alameda")
//            .onAppear {
//                // Fetch data only if entries are empty to avoid refetching on view reappearance
//                if viewModel.entries.isEmpty {
//                    viewModel.fetchData()
//                }
//            }
//        }
//    }
//}
//
//struct QCEWEntryRow: View {
//    let entry: QCEWEntryProperties
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(entry.industryName)
//                .font(.headline)
//            HStack {
//                Text(entry.areaName)
//                Spacer()
//                Text("\(entry.year) - \(entry.timePeriod)")
//            }
//            .font(.subheadline)
//            .foregroundColor(.secondary)
//
//            Divider()
//
//            HStack {
//                InfoItem(label: "Ownership", value: entry.ownership)
//                Spacer()
//                InfoItem(label: "NAICS", value: entry.naicsCode)
//            }
//
//             HStack {
//                 InfoItem(label: "Establishments", value: formattedInt(entry.establishmentsInt))
//                 Spacer()
//                 InfoItem(label: "Avg Monthly Emp", value: formattedInt(entry.averageMonthlyEmploymentInt))
//             }
//
//            HStack {
//                InfoItem(label: "Total Wages ($)", value: formattedInt(entry.totalWagesAllWorkersInt))
//                 Spacer()
//                InfoItem(label: "Avg Weekly Wage ($)", value: formattedInt(entry.averageWeeklyWagesInt))
//             }
//
//        }
//        .padding(.vertical, 4) // Add some vertical padding to each row
//    }
//
//     // Helper to format optional integers with commas
//     private func formattedInt(_ value: Int?) -> String {
//         guard let value = value else { return "N/A" }
//         let formatter = NumberFormatter()
//         formatter.numberStyle = .decimal
//         return formatter.string(from: NSNumber(value: value)) ?? "N/A"
//     }
//}
//
//// Reusable view for displaying label-value pairs
//struct InfoItem: View {
//    let label: String
//    let value: String
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(label)
//                .font(.caption)
//                .foregroundColor(.gray)
//            Text(value)
//                .font(.body)
//        }
//    }
//}
//
//// MARK: - App Entry Point (for Preview and Running)
//
//// You would typically have an App struct like this:
///*
//@main
//struct QCEWApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
//*/
//
//// MARK: - SwiftUI Preview
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        QCEW_2023_2024_Q1_Dataset_View()
//            .preferredColorScheme(.dark) // Preview in dark mode
//        QCEW_2023_2024_Q1_Dataset_View() // Preview in light mode
//    }
//}
