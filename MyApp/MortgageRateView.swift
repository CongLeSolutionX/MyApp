////
////  MortgageRateView.swift
////  MyApp
////
////  Created by Cong Le on 3/26/25.
////
//
//import SwiftUI
//// If you intend to use the SwiftUI Charts framework
//import Charts
//
//// Mock Data Models
//struct MortgageRate: Identifiable {
//    let id = UUID()
//    let product: String
//    let currentRate: Double
//    let dailyChange: Double
//    let fiftyTwoWeekLow: Double
//    let fiftyTwoWeekHigh: Double
//}
//
//// Dummy Data
//let mockMortgageData = [
//    MortgageRate(product: "30 Yr. Fixed", currentRate: 6.80, dailyChange: 0.00, fiftyTwoWeekLow: 6.11, fiftyTwoWeekHigh: 7.52),
//    MortgageRate(product: "15 Yr. Fixed", currentRate: 6.22, dailyChange: 0.01, fiftyTwoWeekLow: 5.54, fiftyTwoWeekHigh: 6.91),
//    MortgageRate(product: "30 Yr. FHA", currentRate: 6.24, dailyChange: 0.00, fiftyTwoWeekLow: 5.65, fiftyTwoWeekHigh: 7.00),
//    MortgageRate(product: "30 Yr. Jumbo", currentRate: 6.95, dailyChange: 0.00, fiftyTwoWeekLow: 6.37, fiftyTwoWeekHigh: 7.68),
//    MortgageRate(product: "7/6 SOFR ARM", currentRate: 6.41, dailyChange: -0.01, fiftyTwoWeekLow: 5.95, fiftyTwoWeekHigh: 7.55),
//    MortgageRate(product: "30 Yr. VA", currentRate: 6.25, dailyChange: 0.00, fiftyTwoWeekLow: 5.66, fiftyTwoWeekHigh: 7.03)
//]
//
//struct MortgageRateView: View {
//    @State private var selectedAggregator = "MND"
//    let aggregators = ["MND", "FREDDIE MAC", "MBA"]
//    @State private var selectedTimeframe = "6M"
//    let timeframes = ["1M", "3M", "6M", "1Y", "5Y", "ALL"]
//    @State private var selectedChartRates: [String] = ["15YR Fixed", "30YR FHA"] // Example initial selection
//    let allChartRates = ["15YR Fixed", "30YR FHA", "30YR Fixed", "30YR Jumbo", "5/1-ARM", "30YR VA"]
//    let rateColors: [String: Color] = [
//        "15YR Fixed": .blue,
//        "30YR FHA": .green,
//        "30YR Fixed": .gray,
//        "30YR Jumbo": .orange,
//        "5/1-ARM": .purple,
//        "30YR VA": .red
//    ]
//    let chartData: [([Date], [Double], String)] = [
//        (datesForLastSixMonths(), generateRandomData(count: 180, base: 6.1, variation: 0.3), "15YR Fixed"),
//        (datesForLastSixMonths(), generateRandomData(count: 180, base: 6.3, variation: 0.2), "30YR FHA"),
//        (datesForLastSixMonths(), generateRandomData(count: 180, base: 6.6, variation: 0.4), "30YR Fixed"),
//        (datesForLastSixMonths(), generateRandomData(count: 180, base: 6.8, variation: 0.5), "30YR Jumbo"),
//        (datesForLastSixMonths(), generateRandomData(count: 180, base: 6.2, variation: 0.1), "5/1-ARM"),
//        (datesForLastSixMonths(), generateRandomData(count: 180, base: 6.0, variation: 0.2), "30YR VA")
//    ]
//
//    var filteredChartData: [([Date], [Double], String)] {
//        chartData.filter { selectedChartRates.contains($0.2) }
//    }
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                // Top Navigation Bar
//                HStack {
//                    Image(systemName: "chevron.left")
//                    Text("Back")
//                    Spacer()
//                    Text("Average Rates")
//                        .font(.headline)
//                    Spacer()
//                    Color.clear.frame(width: 20, height: 20) // Placeholder for potential right icon
//                }
//                .padding()
//                .background(Color(.systemBackground)) // Ensure background for visibility
//
//                // Segmented Control
//                Picker("Select Aggregator", selection: $selectedAggregator) {
//                    ForEach(aggregators, id: \.self) { aggregator in
//                        Text(aggregator)
//                    }
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .padding(.horizontal)
//
//                // Data Table Header
//                HStack {
//                    Text("").frame(maxWidth: .infinity, alignment: .leading)
//                    Text("Current").frame(width: 80, alignment: .trailing)
//                    Text("").frame(width: 60, alignment: .trailing)
//                    Text("52 Week Range").frame(maxWidth: .infinity, alignment: .trailing)
//                }
//                .font(.caption)
//                .foregroundColor(.secondary)
//                .padding(.horizontal)
//
//                // Data Table Rows
//                ScrollView {
//                    VStack {
//                        ForEach(mockMortgageData) { rate in
//                            RateTableCell(rate: rate)
//                                .padding(.horizontal)
//                                .padding(.vertical, 4)
//                            Divider()
//                        }
//                    }
//                }
//
//                // Timeframe Tabs
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack {
//                        ForEach(timeframes, id: \.self) { timeframe in
//                            Button(action: {
//                                selectedTimeframe = timeframe
//                                // In a real app, you'd fetch chart data based on the timeframe
//                            }) {
//                                Text(timeframe)
//                                    .padding(.horizontal, 12)
//                                    .padding(.vertical, 6)
//                                    .background(selectedTimeframe == timeframe ? Color.accentColor.opacity(0.2) : Color.clear)
//                                    .foregroundColor(selectedTimeframe == timeframe ? .accentColor : .primary)
//                                    .cornerRadius(8)
//                            }
//                        }
//                        Spacer()
//                    }
//                    .padding(.horizontal)
//                    .padding(.vertical, 8)
//                }
//
//                // Line Chart
//                if !filteredChartData.isEmpty {
//                    ChartView(chartData: filteredChartData, rateColors: rateColors)
//                        .frame(height: 200)
//                        .padding(.horizontal)
//                } else {
//                    Text("No chart data available for selected rates.")
//                        .padding()
//                }
//
//                // Legend
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack {
//                        ForEach(allChartRates, id: \.self) { rateType in
//                            HStack {
//                                Circle()
//                                    .fill(rateColors.first(where: { $0.key == rateType })?.value ?? .gray)
//                                    .frame(width: 10, height: 10)
//                                Text(rateType)
//                                    .font(.caption)
//                            }
//                            .padding(.trailing, 15)
//                            .onTapGesture {
//                                if selectedChartRates.contains(rateType) {
//                                    selectedChartRates.removeAll { $0 == rateType }
//                                } else {
//                                    selectedChartRates.append(rateType)
//                                }
//                            }
//                        }
//                    }
//                    .padding()
//                }
//
//                Spacer() // Push content to the top
//            }
//            .navigationBarHidden(true)
//            .overlay(alignment: .bottom) {
//                MainTabBarView()
//            }
//        }
//    }
//}
//
//struct RateTableCell: View {
//    let rate: MortgageRate
//
//    var body: some View {
//        HStack {
//            Text(rate.product)
//                .frame(maxWidth: .infinity, alignment: .leading)
//            Text(String(format: "%.2f%%", rate.currentRate))
//                .frame(width: 80, alignment: .trailing)
//            Text(String(format: "%+.2f%%", rate.dailyChange))
//                .foregroundColor(rate.dailyChange >= 0 ? .green : .red)
//                .frame(width: 60, alignment: .trailing)
//            HStack(spacing: 4) {
//                Text(String(format: "%.2f%%", rate.fiftyTwoWeekLow))
//                    .font(.caption)
//                GeometryReader { geometry in
//                    RoundedRectangle(cornerRadius: 4)
//                        .fill(Color.gray.opacity(0.3))
//                        .frame(height: 8)
//                        .overlay(alignment: .leading) {
//                            RoundedRectangle(cornerRadius: 4)
//                                .fill(Color.yellow)
//                                .frame(width: (geometry.size.width * CGFloat((rate.currentRate - rate.fiftyTwoWeekLow) / (rate.fiftyTwoWeekHigh - rate.fiftyTwoWeekLow))), height: 8)
//                        }
//                }
//                .frame(height: 8)
//                Text(String(format: "%.2f%%", rate.fiftyTwoWeekHigh))
//                    .font(.caption)
//            }
//            .frame(maxWidth: .infinity, alignment: .trailing)
//        }
//    }
//}
//
//struct ChartView: View {
//    let chartData: [([Date], [Double], String)]
//    let rateColors: [String: Color]
//
//    var body: some View {
//        // This requires the Charts framework
//        if #available(iOS 16.0, *) {
//            Chart {
//                ForEach(chartData, id: \.2) { dates, rates, rateType in
//                    ForEach(Array(zip(dates, rates)), id: \.0) { date, rate in
//                        LineMark(
//                            x: .value("Date", date),
//                            y: .value("Rate", rate)
//                        )
//                        .foregroundStyle(rateColors.first(where: { $0.key == rateType })?.value ?? .gray)
//                        .symbol(Circle())
//                        .symbolSize(4)
//                    }
//                    .interpolationMethod(.monotone)
//                    .lineStyle(StrokeStyle(lineWidth: 2))
//                }
//            }
//            .chartXAxis {
//                AxisMarks(values: .automatic(desiredCount: 5)) { value in
//                    if let date = value.as(Date.self) {
//                        AxisValueLabel(format: .dateTime.month().year().suffix("'yy"))
//                    }
//                    AxisGridLine()
//                }
//            }
//            .chartYAxis {
//                AxisMarks() { value in
//                    if let rate = value.as(Double.self) {
//                        AxisValueLabel(String(format: "%.2f%%", rate))
//                    }
//                    AxisGridLine()
//                }
//            }
//        } else {
//            Text("Line Chart requires iOS 16 or later.")
//        }
//    }
//}
//
//struct MainTabBarView: View {
//    var body: some View {
//        TabView {
//            ContentView()
//                .tabItem {
//                    Image(systemName: "percent")
//                    Text("Rates")
//                }
//
//            Text("Alerts")
//                .tabItem {
//                    Image(systemName: "bell")
//                    Text("Alerts")
//                }
//
//            Text("Calculators")
//                .tabItem {
//                    Image(systemName: "function")
//                    Text("Calculators")
//                }
//
//            Text("News")
//                .tabItem {
//                    Image(systemName: "newspaper")
//                    Text("News")
//                }
//
//            Text("Lenders")
//                .badge(6)
//                .tabItem {
//                    Image(systemName: "briefcase.fill")
//                    Text("Lenders")
//                }
//        }
//    }
//}
//
//// Dummy Data Generation Functions
//func datesForLastSixMonths() -> [Date] {
//    let calendar = Calendar.current
//    let endDate = Date()
//    var dates: [Date] = []
//    if let startDate = calendar.date(byAdding: .month, value: -6, to: endDate) {
//        var currentDate = startDate
//        while currentDate <= endDate {
//            dates.append(currentDate)
//            if let nextDate = calendar.date(byAdding: .day, value: Int.random(in: 1...5), to: currentDate) {
//                currentDate = nextDate
//            } else {
//                break
//            }
//        }
//    }
//    return dates
//}
//
//func generateRandomData(count: Int, base: Double, variation: Double) -> [Double] {
//    return (0..<count).map { _ in
//        base + Double.random(in: -variation...variation)
//    }
//}
//
//#Preview("Mortgage Rate View") {
//    MortgageRateView()
//}
