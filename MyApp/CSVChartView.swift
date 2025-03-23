//
//  CSVChartView.swift
//  MyApp
//
//  Created by Cong Le on 3/23/25.
//
import SwiftUI
import Charts

// MARK: - Data Model (No Changes)

struct DataPoint: Identifiable {
    let id: UUID = UUID()
    let date: Date
    let value: Double

    init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }

    init?(dateString: String, valueString: String, dateFormatter: DateFormatter) {
        guard let value = Double(valueString),
              let date = dateFormatter.date(from: dateString) else {
            return nil
        }
        self.date = date
        self.value = value
    }
}

// MARK: - CSV Parser (No Changes)

class CSVParser {
    static func parseCSV(fileURL: URL, dateFormatter: DateFormatter) -> [DataPoint]? {
        do {
            let csvString = try String(contentsOf: fileURL)
            let lines = csvString.components(separatedBy: .newlines).filter { !$0.isEmpty }
            guard !lines.isEmpty else { return [] }
            let dataLines = lines.dropFirst()

            let dataPoints = dataLines.compactMap { line -> DataPoint? in
                let components = line.components(separatedBy: ",")
                guard components.count == 2 else {
                    print("Invalid CSV line format: \(line)")
                    return nil
                }
                return DataPoint(dateString: components[0], valueString: components[1], dateFormatter: dateFormatter)
            }
            return dataPoints
        } catch {
            print("Error reading CSV file: \(error)")
            return nil
        }
    }
}

// MARK: - ViewModel (Modified)

class ChartViewModel: ObservableObject {
    @Published var dataPoints: [DataPoint] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let dateFormatter: DateFormatter
    private let fileName: String // Add a property for the file name
    private let fileExtension: String // Add a property for the file extension

       init(dateFormatter: DateFormatter, fileName: String, fileExtension: String) {
           self.dateFormatter = dateFormatter
           self.fileName = fileName
           self.fileExtension = fileExtension
           loadCSVData() // Directly load on init
       }

    func loadCSVData() {
        isLoading = true
        errorMessage = nil

        // Load from Bundle.main
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            errorMessage = "File not found in bundle: \(fileName).\(fileExtension)"
            isLoading = false
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let data = CSVParser.parseCSV(fileURL: fileURL, dateFormatter: self.dateFormatter) {
                self.dataPoints = data
            } else {
                self.errorMessage = "Failed to load or parse CSV data."
            }
            self.isLoading = false
        }
    }
}

// MARK: - SwiftUI View (Modified)

struct CSVChartView: View {
    @StateObject private var viewModel: ChartViewModel

    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        // Initialize ViewModel with file name and extension
        _viewModel = StateObject(wrappedValue: ChartViewModel(dateFormatter: dateFormatter, fileName: "data", fileExtension: "csv"))
    }

    var body: some View {
        NavigationStack {  // Use NavigationStack for consistent UI
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Data...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else if viewModel.dataPoints.isEmpty {
                    Text("No data to display.")
                } else {
                    Chart(viewModel.dataPoints) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Value", dataPoint.value)
                        )
                        .interpolationMethod(.cardinal)
                        .foregroundStyle(.blue)
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { _ in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(format: .dateTime.day().month())
                        }
                    }
                    .chartYAxis {
                         AxisMarks(position: .leading)
                     }
                    .padding()
                }
            }
            .navigationTitle("CSV Chart Viewer")
        }
    }
}

// MARK: -  No Need Document Picker

// MARK: - Preview
#Preview {
    CSVChartView()
}
