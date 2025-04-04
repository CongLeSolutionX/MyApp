////
////  LoadcsvDataView.swift
////  MyApp
////
////  Created by Cong Le on 4/3/25.
////
//
//// MARK: - QCEWModels
//
//import Foundation
//
//// Represents the properties derived from a row in the CSV
//struct QCEWEntryProperties {
//    // Note: Removed recordId as it's not in the CSV header provided
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
//    var firstMonthEmp: String = "" // Now corresponds to CSV Col 10
//    var secondMonthEmp: String = "" // Now corresponds to CSV Col 11
//    var thirdMonthEmp: String = "" // Now corresponds to CSV Col 12
//    var totalWagesAllWorkers: String = ""
//    var averageWeeklyWages: String = ""
//
//    // Computed properties remain the same
//    var establishmentsInt: Int? { Int(establishments) }
//    var averageMonthlyEmploymentInt: Int? { Int(averageMonthlyEmployment) }
//    var firstMonthEmpInt: Int? { Int(firstMonthEmp) }
//    var secondMonthEmpInt: Int? { Int(secondMonthEmp) }
//    var thirdMonthEmpInt: Int? { Int(thirdMonthEmp) }
//    var totalWagesAllWorkersInt: Int? { Int(totalWagesAllWorkers) }
//    var averageWeeklyWagesInt: Int? { Int(averageWeeklyWages) }
//}
//
//// Represents a single row/entry from the CSV
//struct QCEWEntry: Identifiable {
//    let id = UUID() // Unique ID for SwiftUI List iterations
//    var properties: QCEWEntryProperties
//}
//
//
//// MARK: - QCEWCsvParser
//
//import Foundation
//
//struct QCEWCsvParser {
//
//    enum ParserError: Error, LocalizedError {
//        case dataEncodingError
//        case missingHeader
//        case invalidColumnCount(row: Int, expected: Int, found: Int)
//
//        var errorDescription: String? {
//            switch self {
//            case .dataEncodingError:
//                return "Failed to decode CSV data into a UTF-8 string."
//            case .missingHeader:
//                return "CSV data does not contain a header row."
//            case .invalidColumnCount(let row, let expected, let found):
//                return "Invalid column count at row \(row + 1). Expected \(expected) columns, but found \(found)."
//            }
//        }
//    }
//
//    // Expected number of columns based on the header provided
//    private let expectedColumnCount = 15
//
//    func parse(data: Data) throws -> [QCEWEntry] {
//        // 1. Convert data to String
//        guard let csvString = String(data: data, encoding: .utf8) else {
//            throw ParserError.dataEncodingError
//        }
//
//        // 2. Split into lines, removing empty lines
//        let lines = csvString.components(separatedBy: .newlines)
//                           .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
//
//        // 3. Check for header row
//        guard !lines.isEmpty else {
//            // Treat as empty data, not necessarily an error, unless a header is strictly required
//            // If header IS required: throw ParserError.missingHeader
//            print("Warning: CSV file is empty or contains only whitespace.")
//            return [] // Return empty array for empty file
//        }
//
//        // 4. Skip header row (index 0) and process data rows
//        var entries: [QCEWEntry] = []
//        // Start from index 1 to skip header
//        for (index, line) in lines.enumerated() where index > 0 {
//            let fields = line.components(separatedBy: ",")
//                             .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//
//            // 5. Validate column count for the current row
//            guard fields.count == expectedColumnCount else {
//                // Log a warning or throw an error based on strictness required
//                print("Warning: Skipping row \(index + 1) due to incorrect column count. Expected \(expectedColumnCount), found \(fields.count). Line: '\(line)'")
//                // Optionally throw an error to stop parsing entirely:
//                // throw ParserError.invalidColumnCount(row: index, expected: expectedColumnCount, found: fields.count)
//                continue // Skip this row and continue with the next
//            }
//
//            // 6. Map fields to properties (indices are 0-based)
//            let properties = QCEWEntryProperties(
//                areaType: fields[0],
//                areaName: fields[1],
//                year: fields[2],
//                timePeriod: fields[3],
//                ownership: fields[4],
//                naicsLevel: fields[5],
//                naicsCode: fields[6],
//                industryName: fields[7],
//                establishments: fields[8],
//                averageMonthlyEmployment: fields[9],
//                firstMonthEmp: fields[10],
//                secondMonthEmp: fields[11],
//                thirdMonthEmp: fields[12],
//                totalWagesAllWorkers: fields[13],
//                averageWeeklyWages: fields[14]
//            )
//
//            entries.append(QCEWEntry(properties: properties))
//        }
//
//        return entries
//    }
//}
//
//
//// MARK: - QCEWViewModel
//
//import SwiftUI
//import Foundation
//
//@MainActor
//class QCEWViewModel: ObservableObject {
//    @Published var entries: [QCEWEntry] = []
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//
//    // Instance of the CSV parser
//    private let csvParser = QCEWCsvParser()
//
//    // Function to load and parse data from a local CSV file
//    func loadDataFromFile(filename: String = "qcew-2023-2024q1", fileType: String = "csv") {
//        guard !isLoading else { return }
//
//        isLoading = true
//        errorMessage = nil
//        entries = []
//
//        Task(priority: .userInitiated) {
//            do {
//                // 1. Find the file URL in the app bundle
//                guard let fileUrl = Bundle.main.url(forResource: filename, withExtension: fileType) else {
//                    throw NSError(domain: "QCEWViewModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "Error: \(filename).\(fileType) not found in the app bundle. Ensure it's added to the target."])
//                }
//
//                // 2. Load the data from the file URL
//                let data = try Data(contentsOf: fileUrl)
//
//                // 3. Parse the CSV data using the dedicated parser
//                let parsedEntries = try csvParser.parse(data: data) // parse can now throw
//
//                // 4. Update the UI state on the main thread
//                if parsedEntries.isEmpty && errorMessage == nil {
//                    // Check if parsing succeeded but returned no entries (e.g., empty file or only header)
//                    self.errorMessage = "CSV parsed successfully, but no QCEW entries were found in the data."
//                    print(self.errorMessage!)
//                    self.entries = []
//                } else {
//                    self.entries = parsedEntries
//                    self.errorMessage = nil
//                }
//                self.isLoading = false
//
//            } catch {
//                // Catch errors from file loading or CSV parsing
//                self.errorMessage = "Failed to load or parse '\(filename).\(fileType)': \(error.localizedDescription)"
//                print(self.errorMessage!)
//                self.entries = []
//                self.isLoading = false
//            }
//        }
//    }
//}
//
//// MARK: - QCEWViews
//
//import SwiftUI
//
//// MARK: - SwiftUI Views
//
//struct ContentView: View {
//    @StateObject private var viewModel = QCEWViewModel()
//
//    var body: some View {
//        NavigationStack {
//            Group {
//                if viewModel.isLoading {
//                    ProgressView("Loading Data from CSV...") // Updated text
//                } else if let errorMessage = viewModel.errorMessage {
//                    VStack(spacing: 10) {
//                         Image(systemName: "exclamationmark.triangle.fill") // ... (rest of error view same as before)
//                             .resizable().scaledToFit().frame(width: 50, height: 50).foregroundColor(.orange)
//                         Text("Error Loading Data").font(.headline)
//                         Text(errorMessage)
//                             .font(.caption).foregroundColor(.secondary).multilineTextAlignment(.center).padding(.horizontal)
//                         Button("Retry Load") {
//                             viewModel.loadDataFromFile()
//                         }.buttonStyle(.borderedProminent).padding(.top)
//                     }
//                } else if viewModel.entries.isEmpty {
//                     VStack { // Wrap in VStack for button spacing
//                         Text("No QCEW entries found in the local CSV file.")
//                             .foregroundColor(.secondary)
//                             .multilineTextAlignment(.center)
//                             .padding()
//                         Button("Attempt Load Again") {
//                             viewModel.loadDataFromFile()
//                         }
//                         .buttonStyle(.bordered)
//                     }
//                } else {
//                    List {
//                        ForEach(viewModel.entries) { entry in
//                            QCEWEntryRow(entry: entry.properties) // Passes the properties struct
//                        }
//                    }
//                }
//            }
//            .navigationTitle("QCEW Q1 2023+ (CSV)") // Updated title
//            .onAppear {
//                if viewModel.entries.isEmpty && viewModel.errorMessage == nil && !viewModel.isLoading {
//                    viewModel.loadDataFromFile()
//                }
//            }
//            .toolbar {
//                 ToolbarItem(placement: .navigationBarTrailing) {
//                     Button {
//                         viewModel.loadDataFromFile()
//                     } label: {
//                         Label("Refresh", systemImage: "arrow.clockwise")
//                     }
//                     .disabled(viewModel.isLoading)
//                 }
//             }
//        }
//    }
//}
//
//// Row view remains the same - it depends on QCEWEntryProperties which still exists
//struct QCEWEntryRow: View {
//    let entry: QCEWEntryProperties
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//             Text(entry.industryName.isEmpty ? "Unknown Industry" : entry.industryName)
//                .font(.headline)
//            // ... (rest of the row view is identical to the XML version)
//             HStack {
//                 Text(entry.areaName.isEmpty ? "N/A" : entry.areaName)
//                 Spacer()
//                 Text("\(entry.year.isEmpty ? "N/A" : entry.year) - \(entry.timePeriod.isEmpty ? "N/A" : entry.timePeriod)")
//             }.font(.subheadline).foregroundColor(.secondary)
//             Divider().padding(.vertical, 2)
//             Grid(alignment: .leading) {
//                GridRow {
//                    InfoItem(label: "Ownership", value: entry.ownership.isEmpty ? "N/A" : entry.ownership)
//                    InfoItem(label: "NAICS", value: entry.naicsCode.isEmpty ? "N/A" : entry.naicsCode)
//                }
//                GridRow {
//                    InfoItem(label: "Establishments", value: formattedInt(entry.establishmentsInt))
//                    InfoItem(label: "Avg Monthly Emp", value: formattedInt(entry.averageMonthlyEmploymentInt))
//                }
//                 GridRow {
//                      InfoItem(label: "Total Wages ($)", value: formattedInt(entry.totalWagesAllWorkersInt))
//                      InfoItem(label: "Avg Weekly Wage ($)", value: formattedInt(entry.averageWeeklyWagesInt))
//                 }
//             }
//        }
//        .padding(.vertical, 6)
//    }
//
//    private func formattedInt(_ value: Int?) -> String {
//        guard let value = value else { return "--" }
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        formatter.groupingSeparator = ","
//        return formatter.string(from: NSNumber(value: value)) ?? "--"
//    }
//}
//
//// InfoItem view remains the same
//struct InfoItem: View { // ... (Identical to previous version)
//    let label: String
//    let value: String
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 2) {
//            Text(label)
//                .font(.caption)
//                .foregroundColor(.gray)
//            Text(value)
//                .font(.system(.body, design: .rounded))
//                .lineLimit(1)
//                 .minimumScaleFactor(0.8)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//}
//
//// MARK: - SwiftUI Preview (Loads sample data for preview)
//
//// Updated sample data creation for CSV structure (no recordId)
//private func createPreviewData() -> [QCEWEntry] {
//     let sampleProps1 = QCEWEntryProperties(
//         // recordId removed
//         areaType: "County", areaName: "Preview County", year: "2023",
//         timePeriod: "1st Qtr", ownership: "Private", naicsLevel: "6", naicsCode: "524298",
//         industryName: "All Other Insurance Related Activities", establishments: "10",
//         averageMonthlyEmployment: "223", firstMonthEmp: "223", secondMonthEmp: "225",
//         thirdMonthEmp: "223", totalWagesAllWorkers: "8435605", averageWeeklyWages: "2901"
//     )
//     let sampleProps2 = QCEWEntryProperties(
//         areaType: "County", areaName: "Preview County", year: "2023",
//         timePeriod: "1st Qtr", ownership: "Private", naicsLevel: "2", naicsCode: "54",
//         industryName: "Professional and Technical Services", establishments: "7315",
//         averageMonthlyEmployment: "76545", firstMonthEmp: "76542", secondMonthEmp: "76918",
//         thirdMonthEmp: "76176", totalWagesAllWorkers: "3445535679", averageWeeklyWages: "3463"
//     )
//    let sampleProps3 = QCEWEntryProperties( // Keep the empty data example
//         areaType: "County", areaName: "Sample County", year: "2024",
//         timePeriod: "2nd Qtr", ownership: "Gov", naicsLevel: "", naicsCode: "",
//         industryName: "Test Industry No Numbers", establishments: "",
//         averageMonthlyEmployment: "", firstMonthEmp: "", secondMonthEmp: "",
//         thirdMonthEmp: "", totalWagesAllWorkers: "", averageWeeklyWages: ""
//     )
//     return [
//         QCEWEntry(properties: sampleProps1),
//         QCEWEntry(properties: sampleProps2),
//         QCEWEntry(properties: sampleProps3)
//     ]
// }
//
//#Preview() {
//    ContentView()
//}
//
////struct ContentView_Previews: PreviewProvider {
////    static var previews: some View {
////        // Preview with sample data loaded directly into the ViewModel
////         let previewViewModel = QCEWViewModel()
////         previewViewModel.entries = createPreviewData()
////         previewViewModel.isLoading = false
////         previewViewModel.errorMessage = nil
////         ContentView(viewModel: previewViewModel)
////             .previewDisplayName("Data Loaded (CSV Sample)") // Updated display name
////
////        // Loading State Preview (same as before)
////        let loadingViewModel = QCEWViewModel()
////        loadingViewModel.isLoading = true
////        ContentView(viewModel: loadingViewModel)
////            .previewDisplayName("Loading State (CSV)")
////
////        // Error State Preview (updated message)
////        let errorViewModel = QCEWViewModel()
////        errorViewModel.errorMessage = "Preview Error: Could not parse local CSV file 'qcew-data.csv'."
////        ContentView(viewModel: errorViewModel)
////            .previewDisplayName("Error State (CSV)")
////
////         // Empty State Preview (same logic, updated name)
////        let emptyViewModel = QCEWViewModel()
////        emptyViewModel.isLoading = false
////        emptyViewModel.entries = []
////        emptyViewModel.errorMessage = nil
////        ContentView(viewModel: emptyViewModel)
////            .previewDisplayName("Empty State (CSV)")
////    }
////}
////
//
