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
import Accessibility // Import the Accessibility framework for AXChart

// MARK: - Data Models (Reflecting AXChartDescriptor Needs)

struct DataPoint: Identifiable {
    let id = UUID() // For iterating in SwiftUI
    let x: Double
    let y: Double
    let category: String // Example: Used for symbol/color differentiation
    // Optional: Add a specific label for the data point if needed
    // let label: String?
}

struct DataSeries {
    let name: String
    let dataPoints: [DataPoint]
    let isContinuous: Bool // Line chart (true) vs. Scatter/Bar (false)
    let symbol: KeyPath<Symbols, Image> // Link to a symbol for visual differentiation
    let color: Color // Color for this series
}

struct AxisModel {
    let title: String
    let range: ClosedRange<Double>
    let gridlinePositions: [Double] = [] // Optional gridline values
    let valueDescriptionProvider: (Double) -> String // Closure to format axis values for VoiceOver
}

struct ChartModel {
    let title: String
    let summary: String? // Optional summary for Audio Graph Explorer
    let xAxis: AxisModel
    let yAxis: AxisModel
    let series: [DataSeries]
}

// Example Symbols (for Differentiate Without Color)
struct Symbols {
    let circle = Image(systemName: "circle.fill")
    let square = Image(systemName: "square.fill")
    let triangle = Image(systemName: "triangle.fill")
    // Add more as needed
}

// MARK: - Accessible Chart View

struct AccessibleChartView: View {
    let model: ChartModel
    private let symbols = Symbols()
    private let pointSize: CGFloat = 8 // Size for visual points/symbols

    // Environment variables for system accessibility settings
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    @Environment(\.colorScheme) var colorScheme // To potentially adjust contrast

    // Constants
    private let lowDataThreshold = 50 // Threshold for switching accessibility element strategy

    var body: some View {
        GeometryReader { geometry in
            // Overall container for the chart
            ZStack {
                // --- Visual Chart Drawing Placeholder ---
                // This section would contain the actual drawing logic (e.g., using Path, Canvas)
                // It should use `model`, `geometry`, and environment variables for styling.

                ForEach(model.series.indices, id: \.self) { seriesIndex in
                    let series = model.series[seriesIndex]
                    let seriesColor = determineColor(baseColor: series.color) // Adjust color based on settings
                    let seriesSymbol = series.symbol

                    // Example: Draw lines if continuous
                    if series.isContinuous {
                        Path { path in
                            guard series.dataPoints.count > 1 else { return }
                            let startPoint = position(for: series.dataPoints[0], in: geometry.size)
                            path.move(to: startPoint)
                            for i in 1..<series.dataPoints.count {
                                path.addLine(to: position(for: series.dataPoints[i], in: geometry.size))
                            }
                        }
                        .stroke(seriesColor, lineWidth: 2)
                        // Apply reduced transparency if needed
                        .opacity(reduceTransparency ? 1.0 : 0.8)
                    }

                    // Example: Draw points/symbols for all data points
                    ForEach(series.dataPoints) { point in
                        let pos = position(for: point, in: geometry.size)
                        
                        // Determine if symbol should be shown
                        let showSymbol = differentiateWithoutColor || !series.isContinuous // Show always if scatter/bar or if setting enabled

                        if showSymbol {
                            symbols[keyPath: seriesSymbol]
                                .resizable()
                                .frame(width: pointSize, height: pointSize)
                                .foregroundColor(seriesColor)
                                .position(pos)
                                .opacity(reduceTransparency ? 1.0 : 0.8)
                        } else if !series.isContinuous { // Draw simple circle if scatter and differentiate off
                             Circle()
                                .fill(seriesColor)
                                .frame(width: pointSize, height: pointSize)
                                .position(pos)
                                .opacity(reduceTransparency ? 1.0 : 0.8)
                        }
                        // Else (continuous line chart without differentiate) - no symbol needed per point
                    }
                }
                // --- End Visual Chart Drawing ---

                // --- Accessibility Elements Layer ---
                 // Option 1: Expose individual points (best for low data counts)
                if allDataPoints().count <= lowDataThreshold {
                    ForEach(allDataPoints()) { point in
                        let frame = frameRect(for: point, in: geometry.size)
                        // Invisible element placed over the data point's visual area
                         Color.clear
                            .frame(width: frame.width, height: frame.height)
                            .position(x: frame.midX, y: frame.midY)
                            .accessibilityElement(children: .ignore) // Treat as a leaf node
                            .accessibilityLabel(pointAccessibilityLabel(point) ?? "No Label") // Announce category/series if needed
                            .accessibilityValue(pointAccessibilityValue(point)) // Announce coordinates
                            // Note: .accessibilityFrame would ideally be used, but positioning
                            // an invisible element and using its default frame is often easier
                            // in SwiftUI, especially with complex layouts.
                            // .accessibilityFrame(in: .named("ChartSpace")) // Requires coordinate space
                    }
                }
                 // Option 2: Expose Intervals (best for high data counts) - Placeholder Logic
                 // else {
                 //    // Implement logic here to group points into intervals
                 //    // For each interval, create an invisible Color.clear similar to above
                 //    // Set .accessibilityLabel to the interval range (e.g., "X values 10 to 20")
                 //    // Set .accessibilityValue to a summary (e.g., "Average Y: 150")
                 //    // Position and size the invisible element to cover the interval's area
                 //}
                // --- End Accessibility Elements Layer ---
            }
            // Define a coordinate space if using .accessibilityFrame(in:)
            // .coordinateSpace(name: "ChartSpace")
            // Make the main ZStack the primary accessibility element representing the chart
            .accessibilityElement(children: accessibilityChildrenBehavior())
            .accessibilityLabel(model.title)
             // Provide instructions if individual points aren't exposed or as a hint
            .accessibilityHint(accessibilityHintValue())
        }
        // Apply chart descriptor conformance (see extension below)
//        .accessibilityChartDescriptor(self)
    }

    // MARK: - Helper Functions

    // Calculate visual position within the geometry
    private func position(for point: DataPoint, in size: CGSize) -> CGPoint {
         // Basic linear scaling - replace with your actual chart scaling logic
        let xRange = model.xAxis.range
        let yRange = model.yAxis.range

        // Avoid division by zero if range is single point
        let xRatio = (xRange.upperBound - xRange.lowerBound) == 0 ? 0.5 : (point.x - xRange.lowerBound) / (xRange.upperBound - xRange.lowerBound)
        let yRatio = (yRange.upperBound - yRange.lowerBound) == 0 ? 0.5 : 1.0 - ((point.y - yRange.lowerBound) / (yRange.upperBound - yRange.lowerBound)) // Invert Y for screen coordinates

        // Add some padding maybe
        let padding: CGFloat = 20
        let effectiveWidth = size.width - 2 * padding
        let effectiveHeight = size.height - 2 * padding

        return CGPoint(
            x: padding + CGFloat(xRatio) * effectiveWidth,
            y: padding + CGFloat(yRatio) * effectiveHeight
        )
    }

    // Calculate approximate frame for accessibility element
    private func frameRect(for point: DataPoint, in size: CGSize) -> CGRect {
        let center = position(for: point, in: size)
        let touchRadius: CGFloat = 22 // Minimum touch target size / 2
        return CGRect(x: center.x - touchRadius, y: center.y - touchRadius, width: touchRadius * 2, height: touchRadius * 2)
    }

     // Helper to flatten data points
    private func allDataPoints() -> [DataPoint] {
        model.series.flatMap { $0.dataPoints }
    }

     // Determine accessibility children behavior based on data count
    private func accessibilityChildrenBehavior() -> AccessibilityChildBehavior {
        // If exposing individual points, contain them. Otherwise, ignore children
        // and rely on the main label/hint and Audio Graph.
        return allDataPoints().count <= lowDataThreshold ? .contain : .ignore
    }

    // Determine appropriate hint
    private func accessibilityHintValue() -> String {
        if allDataPoints().count > lowDataThreshold {
            return "Chart data is extensive. Use the Audio Graph action in the rotor for details."
        } else {
             // Could potentially add a hint to swipe or use Audio Graph even for low counts
            return "Use the Audio Graph action in the rotor to explore data trends."
        }
    }

    // Create descriptive accessibility value for a point
    private func pointAccessibilityValue(_ point: DataPoint) -> String {
         // Use the description providers from the model
        let xDesc = model.xAxis.valueDescriptionProvider(point.x)
        let yDesc = model.yAxis.valueDescriptionProvider(point.y)
        return "\(xDesc), \(yDesc)"
    }

     // Create descriptive accessibility label (optional, can include category/series)
     private func pointAccessibilityLabel(_ point: DataPoint) -> String? {
         // Could return point.category or the series name if helpful context
         return point.category // Example
     }

    // Adjust color based on environment (simple contrast example)
    private func determineColor(baseColor: Color) -> Color {
        // Placeholder: Implement proper high contrast logic if needed
        // This could involve checking colorScheme and accessibilityContrast
        // For simplicity, just returning baseColor here.
        // Consider WCAG contrast ratio calculations against the background.
        return baseColor
    }
}

// MARK: - AXChart Conformance
//
//extension AccessibleChartView: AXChart {
//
//    var accessibilityChartDescriptor: AXChartDescriptor? {
//        get {
//            // 1. Create Axis Descriptors
//            let xAxisDescriptor = AXNumericDataAxisDescriptor(
//                title: model.xAxis.title,
//                range: model.xAxis.range,
//                gridlinePositions: model.xAxis.gridlinePositions, // Pass gridlines if available
//                valueDescriptionProvider: model.xAxis.valueDescriptionProvider
//            )
//
//            let yAxisDescriptor = AXNumericDataAxisDescriptor(
//                title: model.yAxis.title,
//                range: model.yAxis.range,
//                gridlinePositions: model.yAxis.gridlinePositions,
//                valueDescriptionProvider: model.yAxis.valueDescriptionProvider
//            )
//
//            // 2. Create Data Series Descriptors
//            let seriesDescriptors = model.series.map { series -> AXDataSeriesDescriptor in
//                // Map your DataPoint struct to AXDataPoint
//                let dataPoints = series.dataPoints.map { dataPoint -> AXDataPoint in
//                    AXDataPoint(
//                        x: dataPoint.x,
//                        y: dataPoint.y,
//                        // additionalValues: [], // Add if you have more dimensions (e.g., Z-axis, size)
//                        label: dataPoint.category // Optional label per point
//                    )
//                }
//
//                return AXDataSeriesDescriptor(
//                    name: series.name,
//                    isContinuous: series.isContinuous,
//                    dataPoints: dataPoints
//                )
//            }
//
//            // 3. Create the Main Chart Descriptor
//            return AXChartDescriptor(
//                title: model.title,
//                summary: model.summary, // Provide the optional summary text
//                xAxis: xAxisDescriptor,
//                yAxis: yAxisDescriptor,
//                additionalAxes: [], // Add any other axes if your chart has them
//                series: seriesDescriptors
//            )
//        }
//        set {
//            // Usually, you don't need to implement the setter.
//            // It's required by the protocol but often unused for read-only descriptors.
//        }
//    }
//}

// MARK: - Example Usage

struct ContentView: View {
    // Sample Data (Replace with your actual data loading)
    let coffeeChartModel = ChartModel(
        title: "Cups of Coffee vs. Lines of Code",
        summary: "Shows a general positive correlation between coffee consumed and code produced, plateauing after 8 cups.",
        xAxis: AxisModel(title: "Cups of Coffee", range: 0...12) { value in
            // Example pluralization (simple)
            let cups = Int(value.rounded())
            return "\(cups) \(cups == 1 ? "cup" : "cups")"
        },
        yAxis: AxisModel(title: "Lines of Code", range: 0...1000) { value in
             "\(Int(value.rounded())) lines of code"
        },
        series: [
            DataSeries(
                name: "Engineer Productivity",
                dataPoints: [
                    DataPoint(x: 0, y: 20, category: "Start"), DataPoint(x: 1, y: 150, category: "Routine"),
                    DataPoint(x: 2, y: 300, category: "Routine"), DataPoint(x: 3, y: 450, category: "Routine"),
                    DataPoint(x: 4, y: 600, category: "Routine"), DataPoint(x: 5, y: 700, category: "Routine"),
                    DataPoint(x: 6, y: 800, category: "Routine"), DataPoint(x: 7, y: 850, category: "Routine"),
                    DataPoint(x: 8, y: 880, category: "Plateau"), DataPoint(x: 9, y: 890, category: "Plateau"),
                    DataPoint(x: 10, y: 895, category: "Plateau"), DataPoint(x: 11, y: 885, category: "Plateau"),
                    DataPoint(x: 12, y: 870, category: "Plateau")
                ],
                isContinuous: true, // Line chart
                symbol: \.circle, // Use circle symbol if differentiate enabled
                color: .blue       // Base color
            )
             // Add more series here if needed
             // DataSeries(name: "...", dataPoints: [...], isContinuous: false, symbol: \.square, color: .green)
        ]
    )

    var body: some View {
        NavigationView {
            VStack {
                Text("Coffee Consumption Study")
                    .font(.headline)
                    .padding(.top)

                AccessibleChartView(model: coffeeChartModel)
                    .frame(height: 300) // Give the chart some space
                    .padding()

                Spacer()
            }
            .navigationTitle("Chart Accessibility Demo")
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDisplayName("Default")

        // Preview with Differentiate Without Color enabled
        ContentView()
//            .environment(\.accessibilityDifferentiateWithoutColor, true)
            .previewDisplayName("Differentiate Color")
            
        // Preview with different color scheme
         ContentView()
             .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
    }
}
