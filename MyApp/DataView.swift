//
//  DataView.swift
//  MyApp
//
//  Created by Cong Le on 3/23/25.
//

import SwiftUI
import Charts

// MARK: - Data Model

struct DataPoint: Identifiable {
    let id: UUID = UUID() // For Identifiable conformance
    let date: Date
    let value: Double

    // Custom initializer for Double, Date
     init(date: Date, value: Double) {
         self.date = date
         self.value = value
     }

    // Custom initializer for string-based date (more flexible)
    init?(dateString: String, valueString: String, dateFormatter: DateFormatter) {
        guard let value = Double(valueString),
              let date = dateFormatter.date(from: dateString) else {
            return nil // Fail gracefully if parsing fails
        }
        self.date = date
        self.value = value
    }
}

// MARK: - CSV Parser

class CSVParser {
    static func parseCSV(fileURL: URL, dateFormatter: DateFormatter) -> [DataPoint]? {
        do {
            let csvString = try String(contentsOf: fileURL)
            let lines = csvString.components(separatedBy: .newlines).filter{!$0.isEmpty} // Split and ignore final empty line, if any
            guard !lines.isEmpty else {  return [] } // empty data set check
            let dataLines = lines.dropFirst()  // Skip the header row
            
            let dataPoints = dataLines.compactMap { line -> DataPoint? in
                let components = line.components(separatedBy: ",")
                guard components.count == 2 else {
                    print("Invalid CSV line format: \(line)") // Log the problematic line
                    return nil
                }

                return DataPoint(dateString: components[0], valueString: components[1], dateFormatter: dateFormatter)

            }

            return dataPoints

        } catch {
            print("Error reading CSV file: \(error)") // Specific error details
            return nil
        }
    }
}

// MARK: - ViewModel

class ChartViewModel: ObservableObject {
    @Published var dataPoints: [DataPoint] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let dateFormatter: DateFormatter

    init(dateFormatter: DateFormatter) {
         self.dateFormatter = dateFormatter
     }

    func loadCSVData(from url: URL) {
        isLoading = true
        errorMessage = nil // Clear previous error

        // Simulate a network delay (for testing the loading state)
         DispatchQueue.main.async { [weak self] in // All UI Updates on Main Thread.
             guard let self = self else { return }  // Avoid strong retention cycles.
             if let data = CSVParser.parseCSV(fileURL: url, dateFormatter: self.dateFormatter) {
                 self.dataPoints = data
             } else {
                 self.errorMessage = "Failed to load or parse CSV data."
             }
             self.isLoading = false
         }
    }
}

// MARK: - SwiftUI View
struct DataView: View {

    @StateObject private var viewModel: ChartViewModel
    @State private var fileURL: URL?
    @State private var isDocumentPickerPresented = false

     init() {
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "yyyy-MM-dd"  // Adapt to your CSV format
          _viewModel = StateObject(wrappedValue: ChartViewModel(dateFormatter: dateFormatter))
      }

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Data...") // User feedback
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else if viewModel.dataPoints.isEmpty {
                    // Placeholder text before the user selects a file and after loading
                    Text("No data to display. Please select a .csv file")
                }
                else {
                    // MARK: -  Chart
                    Chart(viewModel.dataPoints) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Value", dataPoint.value)
                        )
                        .interpolationMethod(.cardinal) // Smoother line (optional)
                        .foregroundStyle(.blue) // Change the line color (optional)

                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { _ in // Adjust as needed
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(format: .dateTime.day().month()) // Customize date format
                        }
                    }
                    .chartYAxis {
                         AxisMarks(position: .leading)
                     }
                    .padding() // Add some padding around the chart
                }
               
            }
            .navigationTitle("CSV Chart Viewer")
            .toolbar {
                 // MARK: -- Toolbar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Select CSV") {
                        isDocumentPickerPresented = true
                    }
                }
            }
            .sheet(isPresented: $isDocumentPickerPresented) {
                DocumentPicker(fileURL: $fileURL)
            }
            .onChange(of: fileURL) { oldURL, newURL in
                if let url = newURL {
                    viewModel.loadCSVData(from: url)
                }
            }
        }
    }
}

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var fileURL: URL?

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.commaSeparatedText], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(_ documentPicker: DocumentPicker) {
            self.parent = documentPicker
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.fileURL = url
            
        }
    }
}

// MARK: - Preview
#Preview {
    DataView()
}
