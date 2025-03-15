//
//  SwiftChartsView.swift
//  MyApp
//
//  Created by Cong Le on 3/15/25.
//

import SwiftUI
import Charts

// MARK: - Data Models

struct MyLineData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct MyPieData: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
}

// MARK: - Demo View
struct SwiftUIChartGestureTutorial: View {

    // MARK: Sample Data

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    // For line chart
    private var lineData: [MyLineData] {
        [
            MyLineData(date: dateFormatter.date(from: "2010-01-01")!, value: -5),
            MyLineData(date: dateFormatter.date(from: "2011-01-01")!, value: 23),
            MyLineData(date: dateFormatter.date(from: "2012-01-01")!, value: 3),
            MyLineData(date: dateFormatter.date(from: "2013-01-01")!, value: 6),
            MyLineData(date: dateFormatter.date(from: "2014-01-01")!, value: 48),
            MyLineData(date: dateFormatter.date(from: "2015-01-01")!, value: 32),
            MyLineData(date: dateFormatter.date(from: "2016-01-01")!, value: 10),
            MyLineData(date: dateFormatter.date(from: "2017-01-01")!, value: 14),
            MyLineData(date: dateFormatter.date(from: "2018-01-01")!, value: -1),
            MyLineData(date: dateFormatter.date(from: "2019-01-01")!, value: 6),
        ]
    }

    // For pie chart
    private var pieData: [MyPieData] {
        [
            MyPieData(name: "Apple",     value: 100),
            MyPieData(name: "Google",    value: 10),
            MyPieData(name: "Microsoft", value: 15),
            MyPieData(name: "Amazon",    value: 50)
        ]
    }

    // MARK: Selection State

    // Single value selections
    @State private var selectedDate: Date?
    @State private var selectedValue: Double?

    // Angle-based selection for pie
    @State private var selectedAccValue: Double?

    // Range selection (two-finger)
    @State private var selectedDateRange: ClosedRange<Date>?
    @State private var selectedValueRange: ClosedRange<Double>?

    // MARK: Body
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Example 1: Single Value Selection
                exampleSingleValueSelection

                // Example 2: Angle (Pie) Selection
                exampleAngleSelection

                // Example 3: Range (Two-Finger) Selection
                exampleRangeSelection

                // Example 4: Custom Gesture for Data Points
                exampleCustomDataPointGesture
            }
            .padding()
        }
    }
}

// MARK: - Subviews / Examples
extension SwiftUIChartGestureTutorial {

    /// 1) Demonstrates the built-in single-value selection on X and Y using chartXSelection(value:) and chartYSelection(value:).
    private var exampleSingleValueSelection: some View {
        VStack {
            Text("Single Value Selections (X & Y)").font(.headline)

            Chart {
                ForEach(lineData) { data in
                    LineMark(
                        x: .value("Date", data.date),
                        y: .value("Value", data.value)
                    )
                    .symbol(.circle)
                }

                // When both selectedDate and selectedValue are non-nil, highlight:
                if let sDate = selectedDate, let sVal = selectedValue {
                    PointMark(
                        x: .value("", sDate),
                        y: .value("", sVal)
                    )
                    .symbol(.asterisk)
                    .symbolSize(40)
                    .foregroundStyle(.red)
                    .annotation(position: .top,
                                content: {
                        Text("(\(dateFormatter.string(from: sDate)), \(String(format: "%.1f", sVal)))")
                            .padding(6)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.gray.opacity(0.7)))
                            .foregroundStyle(.white)
                    })
                }
            }
            .chartYScale(domain: -10...50)
            .chartXSelection(value: $selectedDate) // picks single X
            .chartYSelection(value: $selectedValue) // picks single Y
            .frame(height: 240)
            .padding(.horizontal, 32)
        }
    }

    /// 2) Demonstrates angle-based selection for Pie (SectorMark) using chartAngleSelection(value:).
    private var exampleAngleSelection: some View {
        VStack {
            Text("Angle (Pie) Selection").font(.headline)

            Chart {
                ForEach(pieData) { datum in
                    SectorMark(
                        angle: .value("Value", datum.value),
                        innerRadius: .ratio(0.6)
                    )
                    .foregroundStyle(by: .value("Name", datum.name))
                }
            }
            // The angle-based selection returns the *accumulated* data value at the point of selection
            .chartAngleSelection(value: $selectedAccValue)
            .chartBackground { chartProxy in
                GeometryReader { geo in
                    if let frame = chartProxy.plotFrame, let accVal = selectedAccValue {
                        // Check which pie data is selected
                        if let foundPie = findPieData(accumulatedVal: accVal) {
                            let bounding = geo[frame]
                            // Display info in the center
                            VStack {
                                Text("\(foundPie.name)\n\(String(format: "%0.1f", foundPie.value))")
                                    .bold()
                                    .padding(6)
                                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.white.opacity(0.8)))
                            }
                            .position(x: bounding.midX, y: bounding.midY)
                        }
                    }
                }
            }
            .frame(height: 240)
            .padding(.horizontal, 32)
        }
    }

    /// 3) Demonstrates 2-finger range selection, capturing a range on X and Y.
    private var exampleRangeSelection: some View {
        VStack {
            Text("Two-Finger Range Selection").font(.headline)

            Chart {
                ForEach(lineData) { data in
                    LineMark(
                        x: .value("Date", data.date),
                        y: .value("Value", data.value)
                    )
                    .symbol(.circle)
                }

                // Show the selected rectangle region if present
                if let rangeX = selectedDateRange {
                    RectangleMark(
                        xStart: .value("", rangeX.lowerBound),
                        xEnd: .value("", rangeX.upperBound)
                    )
                    .opacity(0.2)
                }
                if let rangeY = selectedValueRange {
                    RectangleMark(
                        yStart: .value("", rangeY.lowerBound),
                        yEnd: .value("", rangeY.upperBound)
                    )
                    .opacity(0.2)
                }
            }
            .chartYScale(domain: -10...50)
            .chartXSelection(range: $selectedDateRange)
            .chartYSelection(range: $selectedValueRange)
            .frame(height: 240)
            .padding(.horizontal, 32)
        }
    }

    /// 4) Demonstrates a custom gesture bound to the Chart for selecting data points only if an actual data point is near the gesture location.
    private var exampleCustomDataPointGesture: some View {
        VStack {
            Text("Custom Gesture: Select Only If Data Point Exists").font(.headline)

            Chart {
                ForEach(lineData) { data in
                    LineMark(
                        x: .value("Date", data.date),
                        y: .value("Value", data.value)
                    )
                    .symbol(.circle)
                }
                // We can show highlight if we want. For instance, if we replicate the approach from Single Value selection
                if let existingDate = selectedDate, let existingValue = selectedValue {
                    PointMark(
                        x: .value("", existingDate),
                        y: .value("", existingValue)
                    )
                    .symbol(.asterisk)
                    .symbolSize(40)
                    .foregroundStyle(.orange)
                }
            }
            .chartYScale(domain: -10...50)
            .frame(height: 240)
            .padding(.horizontal, 32)
            .chartGesture { chartProxy in
                DragGesture(minimumDistance: 0)
                    .onChanged { gestureValue in

                        let location = gestureValue.location
                        let thresholdPercent: CGFloat = 0.05
                        guard let firstXY = chartProxy.value(at: location, as: (Date, Double).self) else {
                            return
                        }
                        let thresholdX = chartProxy.plotSize.width * thresholdPercent
                        let thresholdY = chartProxy.plotSize.height * thresholdPercent

                        // Example: Compare each data's Chart-projected position to the gesture location
                        for ld in lineData {
                            if let pos = chartProxy.position(for: (ld.date, ld.value)) {
                                let dx = abs(pos.x - location.x)
                                let dy = abs(pos.y - location.y)
                                if dx < thresholdX && dy < thresholdY {
                                    // This means we are near a data point
                                    selectedDate = ld.date
                                    selectedValue = ld.value

                                    // Also, we can highlight it visually in the chart
                                    chartProxy.selectXValue(at: pos.x)
                                    chartProxy.selectYValue(at: pos.y)
                                    return
                                }
                            }
                        }

                        // If none matched, reset or do nothing
                        // selectedDate = nil
                        // selectedValue = nil
                    }
                    .onEnded { _ in
                        // optionally keep the selection or clear it:
                        // selectedDate = nil
                        // selectedValue = nil
                    }
            }
        }
    }
}

// MARK: - Helpers
extension SwiftUIChartGestureTutorial {

    /// Utility function to find which PieData is selected given the partial sum (accumulated) from chartAngleSelection
    private func findPieData(accumulatedVal: Double) -> MyPieData? {
        var partial: Double = 0
        for slice in pieData {
            partial += slice.value
            if accumulatedVal < partial {
                return slice
            }
        }
        return nil
    }
}

// MARK: - Preview (Optional)
struct SwiftUIChartGestureTutorial_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIChartGestureTutorial()
    }
}
