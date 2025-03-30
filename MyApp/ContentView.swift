//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
import SwiftUI
// Import Accessibility specifically if you need deeper interaction,
// but for applying modifiers, SwiftUI is often sufficient.
import Accessibility

// --- Data Model (Placeholder for Chart Data) ---
// Represents simple data points for our chart example.
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let category: String
    let value: Double
}

// --- AXChartDescriptorRepresentable Implementation ---
// This struct creates and updates the accessibility descriptor for the chart.
struct MyChartDescriptorRepresentable: AXChartDescriptorRepresentable {
    // Sample data for the chart
    let data: [ChartDataPoint]
    let chartTitle: String = "Monthly Sales"
    let xAxisTitle: String = "Month"
    let yAxisTitle: String = "Sales (USD)"

    // Creates the initial accessibility descriptor.
    // This is called once when the descriptor is first needed.
    func makeChartDescriptor() -> AXChartDescriptor {
        // Create an accessibility descriptor for the X-axis (e.g., categories).
        let xAxis = AXNumericDataAxisDescriptor(
            title: xAxisTitle,
            range: 0...Double(data.count - 1), // Assuming categories are indexed
            gridlinePositions: []) { value in
                // Provide a label for each category index.
                let index = Int(value.rounded())
                return data.indices.contains(index) ? data[index].category : ""
        }

        // Create an accessibility descriptor for the Y-axis (e.g., values).
        // Find the min/max values for the range.
        let minValue = data.map { $0.value }.min() ?? 0
        let maxValue = data.map { $0.value }.max() ?? 100 // Default max if no data

        let yAxis = AXNumericDataAxisDescriptor(
            title: yAxisTitle,
            // Add a little padding to the range for better readability.
            range: (minValue - (maxValue * 0.1))...(maxValue + (maxValue * 0.1)),
            gridlinePositions: []) { value in
                // Format the numeric value as currency or a simple number.
                // Correction: Use String(format:) for formatting
                "\(String(format: "%.2f", value)) USD"
        }

        // Create a series descriptor for the actual data points.
        let series = AXDataSeriesDescriptor(
            name: "Monthly Sales Data", // Name of this data series
            isContinuous: false,        // Bar charts are typically not continuous
            dataPoints: data.enumerated().map { index, dataPoint in
                AXDataPoint(
                    x: Double(index), // Use index for X value
                    y: dataPoint.value,
                    // Correction: Use String(format:) for formatting the label
                    label: "\(dataPoint.category): \(String(format: "%.2f", dataPoint.value)) USD" // Accessible label for the data point
                )
            }
        )

        // Construct the final chart descriptor.
        let descriptor = AXChartDescriptor(
            title: chartTitle,          // Accessible title for the whole chart
            summary: "A bar chart showing monthly sales figures.", // Optional summary
            xAxis: xAxis,               // Assign the X-axis descriptor
            yAxis: yAxis,               // Assign the Y-axis descriptor
            additionalAxes: [],         // No additional axes in this example
            series: [series]            // Assign the data series descriptor
        )

        print("Making AXChartDescriptor")
        return descriptor
    }

    // Updates the existing descriptor when data or environment changes.
    // This is called when SwiftUI detects relevant changes.
    func updateChartDescriptor(_ descriptor: AXChartDescriptor) {
        // In a real app, you'd update properties of the descriptor based on
        // the *current* state (e.g., new data, environment changes).
        // For simplicity, we'll just reuse the logic from makeChartDescriptor
        // to update the axes ranges and series data points, assuming `data` might change.

        // Update X-axis (range might change if data count changes)
        if let xAxis = descriptor.xAxis as? AXNumericDataAxisDescriptor {
            xAxis.range = 0...Double(data.count - 1)
             // The value description closure might also need updating if categories change fundamentally
            xAxis.valueDescriptionProvider = { value in
                let index = Int(value.rounded())
                return data.indices.contains(index) ? data[index].category : ""
            }
            print("Updating X Axis Range")
        }

        // Update Y-axis (range might change significantly if values change)
        if let yAxis = descriptor.yAxis as? AXNumericDataAxisDescriptor {
            let minValue = data.map { $0.value }.min() ?? 0
            let maxValue = data.map { $0.value }.max() ?? 100
            yAxis.range = (minValue - (maxValue * 0.1))...(maxValue + (maxValue * 0.1))
            yAxis.valueDescriptionProvider = { value in
                 // Correction: Use String(format:) for formatting
                "\(String(format: "%.2f", value)) USD"
            }
            print("Updating Y Axis Range")
        }

        // Update Series data points
        if let series = descriptor.series.first {
            series.dataPoints = data.enumerated().map { index, dataPoint in
                AXDataPoint(
                    x: Double(index),
                    y: dataPoint.value,
                    // Correction: Use String(format:) for formatting the label
                    label: "\(dataPoint.category): \(String(format: "%.2f", dataPoint.value)) USD"
                )
            }
            print("Updating Series Data")
        }
         print("Updating AXChartDescriptor finished.")
    }
}


// --- Custom Content Key ---
// Define keys for specific pieces of custom accessibility information.
let lastUpdatedKey = AccessibilityCustomContentKey("Last Updated", id: "com.example.lastUpdated")
let dataSourceKey = AccessibilityCustomContentKey("Data Source", id: "com.example.dataSource")

// --- Custom Chart View ---
// A simple view representing a chart, demonstrating accessibility modifiers.
struct MyChartView: View {
    // Use @State to allow modification and trigger updates
    @State private var chartData: [ChartDataPoint] = [
        ChartDataPoint(category: "Jan", value: 50),
        ChartDataPoint(category: "Feb", value: 80),
        ChartDataPoint(category: "Mar", value: 65),
        ChartDataPoint(category: "Apr", value: 95)
    ]

    @State private var lastUpdateTime = Date()
    @State private var customSource = "Internal DB"

    var body: some View {
        VStack(alignment: .leading) {
            // Placeholder for the visual chart rendering
            HStack(alignment: .bottom, spacing: 5) {
                ForEach(chartData) { dataPoint in
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(.blue)
                            // Scale height based on value relative to max value (simple example)
                            .frame(width: 20, height: dataPoint.value)
                        Text(dataPoint.category)
                            .font(.caption)
                    }
                }
            }
            .frame(height: 120) // Give the chart area some height
            .border(Color.gray) // Visual border for the chart area
            .padding()

            // --- Applying Accessibility Modifiers ---

            // 1. Chart Descriptor
            // Pass the current chartData state
            .accessibilityChartDescriptor(MyChartDescriptorRepresentable(data: chartData))

            // 2. Custom Content
            // Provides extra contextual information accessible via VoiceOver Rotor.
            .accessibilityCustomContent(lastUpdatedKey, Text(lastUpdateTime, style: .date), importance: .default)
            .accessibilityCustomContent(dataSourceKey, Text(customSource), importance: .default)

            // 3. Heading Level (Applied to the container, could be on a Text title too)
            .accessibilityHeading(.h1) // Mark this whole view as a level 1 heading section

            // 4. Text Content Type (More relevant for Text views, but shown here)
            .accessibilityTextContentType(.spreadsheet) // Hint that content is like a spreadsheet

            // 5. Traits
            // Adds traits to the chart container.
            .accessibilityAddTraits(.isSummaryElement) // Describes the chart as a summary
            .accessibilityAddTraits(.updatesFrequently) // If the data refreshed often


            // Example controls to potentially update the chart (and trigger descriptor update)
            Button("Refresh Data (Simulated)") {
                // Simulate fetching new data by modifying the @State array
                chartData = [
                    ChartDataPoint(category: "Jan", value: Double.random(in: 40...100)),
                    ChartDataPoint(category: "Feb", value: Double.random(in: 40...100)),
                    ChartDataPoint(category: "Mar", value: Double.random(in: 40...100)),
                    ChartDataPoint(category: "Apr", value: Double.random(in: 40...100))
                ]
                lastUpdateTime = Date()
                customSource = Bool.random() ? "API Feed" : "Local Cache"
                // Note: SwiftUI automatically watches @State changes (like chartData)
                // and view inputs to decide when to call updateChartDescriptor.
                // No direct call needed.
                 print("Chart Data Refreshed (Simulated)")
            }
            .padding(.top)

        }
        .padding()
        .navigationTitle("Sales Chart") // Example title

    }
}


// --- Main ContentView ---
// Hosts the MyChartView and demonstrates its usage.
struct ContentView: View {
    var body: some View {
        NavigationView {
            MyChartView()
        }
    }
}

// --- Preview Provider ---
#Preview {
    ContentView()
}
