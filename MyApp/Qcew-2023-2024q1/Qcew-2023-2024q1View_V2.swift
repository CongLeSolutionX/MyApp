//
//  Qcew-2023-2024q1View_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/3/25.
//

// MARK: - QCEWCsvParser
import Foundation

struct QCEWCsvParser {
    
    // Errors remain the same
    enum ParserError: Error, LocalizedError {
        case missingHeader
        case invalidColumnCount(row: Int, expected: Int, found: Int)
        // Removed dataEncodingError as url.lines handles encoding implicitly (usually UTF-8)
        
        var errorDescription: String? {
            switch self {
            case .missingHeader:
                return "CSV data does not contain a header row."
            case .invalidColumnCount(let row, let expected, let found):
                return "Invalid column count at row \(row + 1). Expected \(expected) columns, but found \(found)."
            }
        }
    }
    
    // Expected number of columns based on the header provided
    private let expectedColumnCount = 15
    
    /// Parses a CSV file line by line from the given URL.
    /// - Parameters:
    ///   - url: The file URL of the CSV file.
    ///   - progressHandler: An optional closure called periodically with the progress (0.0 to 1.0).
    ///                      Note: Progress is estimated based on line count; total lines unknown beforehand.
    /// - Returns: An array of parsed QCEWEntry objects.
    /// - Throws: File reading errors or ParserError.
    func parse(url: URL, progressHandler: ((Double) -> Void)? = nil) async throws -> [QCEWEntry] {
        
        var entries: [QCEWEntry] = []
        var lineCount = 0
        let linesSequence = url.lines // Get the async sequence of lines
        
        // Estimate progress updates: Update every N lines
        let progressUpdateFrequency = 1000 // Adjust as needed
        
        // --- Header Handling ---
        // We need to consume the first line to check/skip the header
        var linesIterator = linesSequence.makeAsyncIterator()
        guard (try await linesIterator.next()) != nil else {
            // File is empty or unreadable immediately
            print("Warning: CSV file at \(url.path) is empty or couldn't be read.")
            return [] // Return empty for an empty file
        }
        // Optional: Validate headerLine contents if necessary
        lineCount += 1
        
        // --- Process Data Rows ---
        while let line = try await linesIterator.next() {
            lineCount += 1
            
            // Skip empty lines that might exist
            guard !line.trimmingCharacters(in: .whitespaces).isEmpty else {
                continue
            }
            
            let fields = line.components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            
            // Validate column count
            guard fields.count == expectedColumnCount else {
                print("Warning: Skipping row \(lineCount) due to incorrect column count. Expected \(expectedColumnCount), found \(fields.count).")
                // Optionally throw: throw ParserError.invalidColumnCount(row: lineCount-1, expected: expectedColumnCount, found: fields.count)
                continue // Skip this row
            }
            
            // Map fields to properties
            let properties = QCEWEntryProperties(
                areaType: fields[0],
                areaName: fields[1],
                year: fields[2],
                timePeriod: fields[3],
                ownership: fields[4],
                naicsLevel: fields[5],
                naicsCode: fields[6],
                industryName: fields[7],
                establishments: fields[8],
                averageMonthlyEmployment: fields[9],
                firstMonthEmp: fields[10],
                secondMonthEmp: fields[11],
                thirdMonthEmp: fields[12],
                totalWagesAllWorkers: fields[13],
                averageWeeklyWages: fields[14]
            )
            entries.append(QCEWEntry(properties: properties))
            
            // Report progress periodically
            if lineCount % progressUpdateFrequency == 0 {
                // Note: This progress is based on lines read, not total file size/lines.
                // For a true percentage, you'd need the total line count first,
                // which requires reading the file once - defeating pure streaming.
                // Providing *some* progress indication is better than none.
                // We can simulate a slow increase towards 1.0
                let estimatedProgress = Double(lineCount) / Double(lineCount + 100_000) // Very rough estimate - adjust denominator based on typical file size
                progressHandler?(min(estimatedProgress, 0.95)) // Cap near 1.0 until done
            }
        }
        
        // Final progress update after loop finishes
        progressHandler?(1.0)
        return entries
    }
}

// MARK: - QCEWViewModel

import SwiftUI
import Foundation

@MainActor // Ensures @Published properties are updated on the main thread
class QCEWViewModel: ObservableObject {
    @Published var entries: [QCEWEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var progress: Double = 0.0 // For progress reporting
    
    private let csvParser = QCEWCsvParser()
    
    func loadDataFromFile(filename: String = "qcew-2023-2024q1_Full", fileType: String = "csv") {
        // Prevent concurrent loads
        guard !isLoading else { return }
        
        // Reset state before loading
        isLoading = true
        errorMessage = nil
        progress = 0.0
        // Don't clear entries immediately, maybe wait until parsing starts successfully
        // self.entries = []
        
        Task(priority: .userInitiated) {
            do {
                // 1. Find the file URL
                guard let fileUrl = Bundle.main.url(forResource: filename, withExtension: fileType) else {
                    throw NSError(domain: "QCEWViewModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "Error: \(filename).\(fileType) not found in the app bundle. Ensure it's added to the target."])
                }
                
                // Clear previous entries just before parsing starts
                self.entries = []
                
                // 2. Parse asynchronously using the stream-based parser
                let parsedEntries = try await csvParser.parse(url: fileUrl) { [weak self] currentProgress in
                    // Update progress on the main thread
                    DispatchQueue.main.async {
                        self?.progress = currentProgress
                    }
                }
                
                // 3. Update UI state on the main thread (already ensured by @MainActor)
                if parsedEntries.isEmpty && errorMessage == nil {
                    self.errorMessage = "CSV parsed successfully, but no QCEW entries were found."
                    print(self.errorMessage!)
                    self.entries = [] // Ensure it's empty
                } else {
                    self.entries = parsedEntries
                    self.errorMessage = nil // Clear any potential previous error
                }
                self.isLoading = false
                self.progress = 1.0 // Ensure progress hits 100%
                
            } catch {
                // Handle errors from file finding or parsing
                self.errorMessage = "Failed to load or parse '\(filename).\(fileType)': \(error.localizedDescription)"
                print(self.errorMessage!)
                self.entries = [] // Clear entries on error
                self.isLoading = false
                self.progress = 0.0 // Reset progress on error
            }
        }
    }
}

// MARK: - QCEWViews
import SwiftUI

// MARK: - SwiftUI Views

struct ContentView: View {
    @StateObject private var viewModel = QCEWViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    VStack { // Wrap in VStack to combine ProgressViews
                        ProgressView(value: viewModel.progress, total: 1.0) {
                            Text("Loading Data (CSV)...") // Label for accessibility
                        } currentValueLabel: {
                            // Show percentage below the bar
                            Text(String(format: "%.0f%%", viewModel.progress * 100))
                        }
                        .padding(.horizontal) // Add some horizontal padding
                        
                        Text("Processing large file, please wait.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                        
                        // Optional: Show an indeterminate spinner as well
                        // ProgressView()
                        //     .padding(.top, 10)
                        
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    // Error View remains the same...
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable().scaledToFit().frame(width: 50, height: 50).foregroundColor(.orange)
                        Text("Error Loading Data").font(.headline)
                        Text(errorMessage)
                            .font(.caption).foregroundColor(.secondary).multilineTextAlignment(.center).padding(.horizontal)
                        Button("Retry Load") {
                            viewModel.loadDataFromFile()
                        }.buttonStyle(.borderedProminent).padding(.top)
                    }
                } else if viewModel.entries.isEmpty {
                    // Empty state view remains the same...
                    VStack {
                        Text("No QCEW entries found in the local CSV file.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Attempt Load Again") {
                            viewModel.loadDataFromFile()
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    // List view remains the same...
                    List {
                        ForEach(viewModel.entries) { entry in
                            QCEWEntryRow(entry: entry.properties)
                        }
                    }
                }
            }
            .navigationTitle("QCEW Q1 2023+ (CSV)")
            .onAppear {
                // Only trigger load if data isn't already loaded/loading/errored
                if viewModel.entries.isEmpty && viewModel.errorMessage == nil && !viewModel.isLoading {
                    viewModel.loadDataFromFile()
                }
            }
            .toolbar {
                // Toolbar item remains the same...
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

// MARK: - QCEWModels

import Foundation

// Represents the properties derived from a row in the CSV
struct QCEWEntryProperties {
    // Note: Removed recordId as it's not in the CSV header provided
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
    var firstMonthEmp: String = "" // Now corresponds to CSV Col 10
    var secondMonthEmp: String = "" // Now corresponds to CSV Col 11
    var thirdMonthEmp: String = "" // Now corresponds to CSV Col 12
    var totalWagesAllWorkers: String = ""
    var averageWeeklyWages: String = ""
    
    // Computed properties remain the same
    var establishmentsInt: Int? { Int(establishments) }
    var averageMonthlyEmploymentInt: Int? { Int(averageMonthlyEmployment) }
    var firstMonthEmpInt: Int? { Int(firstMonthEmp) }
    var secondMonthEmpInt: Int? { Int(secondMonthEmp) }
    var thirdMonthEmpInt: Int? { Int(thirdMonthEmp) }
    var totalWagesAllWorkersInt: Int? { Int(totalWagesAllWorkers) }
    var averageWeeklyWagesInt: Int? { Int(averageWeeklyWages) }
}

// Represents a single row/entry from the CSV
struct QCEWEntry: Identifiable {
    let id = UUID() // Unique ID for SwiftUI List iterations
    var properties: QCEWEntryProperties
}

// Row view remains the same - it depends on QCEWEntryProperties which still exists
struct QCEWEntryRow: View {
    let entry: QCEWEntryProperties
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.industryName.isEmpty ? "Unknown Industry" : entry.industryName)
                .font(.headline)
            // ... (rest of the row view is identical to the XML version)
            HStack {
                Text(entry.areaName.isEmpty ? "N/A" : entry.areaName)
                Spacer()
                Text("\(entry.year.isEmpty ? "N/A" : entry.year) - \(entry.timePeriod.isEmpty ? "N/A" : entry.timePeriod)")
            }.font(.subheadline).foregroundColor(.secondary)
            Divider().padding(.vertical, 2)
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
        .padding(.vertical, 6)
    }
    
    private func formattedInt(_ value: Int?) -> String {
        guard let value = value else { return "--" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? "--"
    }
}

// InfoItem view remains the same
struct InfoItem: View { // ... (Identical to previous version)
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.system(.body, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - SwiftUI Preview (Loads sample data for preview)

// Updated sample data creation for CSV structure (no recordId)
private func createPreviewData() -> [QCEWEntry] {
    let sampleProps1 = QCEWEntryProperties(
        // recordId removed
        areaType: "County", areaName: "Preview County", year: "2023",
        timePeriod: "1st Qtr", ownership: "Private", naicsLevel: "6", naicsCode: "524298",
        industryName: "All Other Insurance Related Activities", establishments: "10",
        averageMonthlyEmployment: "223", firstMonthEmp: "223", secondMonthEmp: "225",
        thirdMonthEmp: "223", totalWagesAllWorkers: "8435605", averageWeeklyWages: "2901"
    )
    let sampleProps2 = QCEWEntryProperties(
        areaType: "County", areaName: "Preview County", year: "2023",
        timePeriod: "1st Qtr", ownership: "Private", naicsLevel: "2", naicsCode: "54",
        industryName: "Professional and Technical Services", establishments: "7315",
        averageMonthlyEmployment: "76545", firstMonthEmp: "76542", secondMonthEmp: "76918",
        thirdMonthEmp: "76176", totalWagesAllWorkers: "3445535679", averageWeeklyWages: "3463"
    )
    let sampleProps3 = QCEWEntryProperties( // Keep the empty data example
        areaType: "County", areaName: "Sample County", year: "2024",
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

#Preview() {
    ContentView()
}
