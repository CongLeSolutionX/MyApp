//
//  HousingIndicatorsAPIView.swift
//  MyApp
//
//  Created by Cong Le on 3/27/25.
//
import SwiftUI

// MARK: - Data Models (Matching OpenAPI Schema - CORRECTED)

struct IndicatorsReport: Codable, Identifiable {
    let id = UUID()
    let indicators: [IndicatorTimeSeriesDouble]?

    enum CodingKeys: String, CodingKey {
        case indicators
    }
}

struct IndicatorTimeSeriesDouble: Codable, Identifiable {
    let id = UUID()
    let category: Indicator?
    let effectiveDate: String? // Consider Date
    let indicatorName: String?
    let points: [TimeSeriesDataPointQuarterDouble]?
    // let timeSeries: [TimeSeriesDataPointQuarterDouble]? // Still seems redundant

    enum CodingKeys: String, CodingKey {
        case category
        case effectiveDate
        // Assuming the actual JSON key might be 'indicator-name' as hinted by XML section in schema
        case indicatorName = "indicator-name"
        case points
        // case timeSeries
    }
}

struct Indicator: Codable, Identifiable {
    let id = UUID()
    let subjectArea: String?
    let dataSetType: String?
    let indicatorName: String?

    // If JSON keys match property names exactly, CodingKeys isn't strictly needed
    // enum CodingKeys: String, CodingKey {
    //     case subjectArea, dataSetType, indicatorName
    // }
}

// CORRECTED Quarter structure to better align with likely JSON keys based on schema hints
// and resolve Decodable ambiguity. Assumes JSON keys "year" (string) and "quarter" (string) are primary.
struct Quarter: Codable, Identifiable {
    let id = UUID()
    let fullName: String?
    let quarterName: String? // Holds "Q1", "Q2", "EOY" etc. Mapped from JSON "quarter".
    let yearString: String?  // Holds "YYYY". Mapped from JSON "year".

    // Explicit CodingKeys to map JSON keys potentially differing from property names
    enum CodingKeys: String, CodingKey {
        case fullName
        case quarterName = "quarter" // Maps JSON "quarter" to Swift quarterName
        case yearString = "year"    // Maps JSON "year" to Swift yearString
    }
}


// CORRECTED TimeSeriesDataPointQuarterDouble: Removed direct 'year' and 'quarter' properties
// as they are derived from the 'slot' (Quarter) object, aligning with schema definition.
struct TimeSeriesDataPointQuarterDouble: Codable, Identifiable {
    let id = UUID()
    let slot: Quarter?
    let forecast: Bool?
    let value: Double?
    let unit: String?
    // No direct year/quarter properties here

    // Derived properties for easier access (matching API description)
    var dataYear: Int? {
        guard let yearStr = slot?.yearString else { return nil }
        return Int(yearStr) // Parse the year string from the slot
    }
    var dataQuarter: String? {
        slot?.quarterName // Get the quarter name from the slot
    }

    // CodingKeys now match the actual properties defined in this struct
    enum CodingKeys: String, CodingKey {
        case slot, forecast, value, unit
    }
}

// MARK: - Parameter Enums (Unchanged)

enum QueryType: String, CaseIterable, Identifiable {
    case byIndicator = "By Indicator"
    case byDataYear = "By Data Year"
    case byDataYearQuarter = "By Data Year & Quarter"
    case byReportYear = "By Report Year"
    case byReportYearMonth = "By Report Year & Month"
    var id: String { self.rawValue }
}

enum IndicatorName: String, CaseIterable, Identifiable, Codable {
    case totalHousingStarts = "total-housing-starts"
    case singleFamily1UnitHousingStarts = "single-family-1-unit-housing-starts"
    case multifamily2PlusUnitsHousingStarts = "multifamily-2+units-housing-starts"
    case totalHomeSales = "total-home-sales"
    case newSingleFamilyHomeSales = "new-single-family-home-sales"
    case existingSingleFamilyCondosCoopsHomeSales = "existing-single-family-condos-coops-home-sales"
    case medianNewHomePrice = "median-new-home-price"
    case medianExistingHomePrice = "median-existing-home-price"
    case fhfaPurchaseOnlyHousePriceIndex = "federal-housing-finance-agency-purchase-only-house-price-index"
    case thirtyYearFixedRateMortgage = "30-year-fixed-rate-mortgage"
    case fiveYearAdjustableRateMortgage = "5-year-adjustable-rate-mortgage"
    case singleFamilyMortgageOriginations = "single-family-mortgage-originations"
    case singleFamilyPurchaseMortgageOriginations = "single-family-purchase-mortgage-originations"
    case singleFamilyRefinanceMortgageOriginations = "single-family-refinance-mortgage-originations"
    case refinanceShare = "refinance-share-of-total-single-family-mortgage-originations"
    var id: String { self.rawValue }
}

enum QuarterName: String, CaseIterable, Identifiable, Codable {
    case q1, q2, q3, q4, eoy
    var id: String { self.rawValue }
}

// MARK: - SwiftUI Views (Largely Unchanged, adjusted for model corrections)

struct HousingIndicatorAPIView: View {
    @State private var selectedQueryType: QueryType = .byIndicator
    @State private var selectedIndicator: IndicatorName? = .totalHousingStarts
    @State private var selectedQuarter: QuarterName? = .q1
    @State private var inputYear: String = "\(Calendar.current.component(.year, from: Date()))"
    @State private var inputMonth: String = "\(Calendar.current.component(.month, from: Date()))"

    @State private var fetchedReport: IndicatorsReport? = nil
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Query Fannie Mae Housing Indicators")
                    .font(.title2)
                    .padding(.bottom)

                Picker("Query Type", selection: $selectedQueryType) {
                    ForEach(QueryType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.bottom)

                queryInputView

                Button {
                    fetchMockData()
                } label: {
                    HStack {
                        Spacer()
                        if isLoading { ProgressView() }
                        else { Text("Fetch Data").padding(.vertical, 8) }
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.vertical)

                Divider()

                if let report = fetchedReport {
                    IndicatorsReportView(report: report)
                } else if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else if isLoading {
                   Spacer()
                   ProgressView("Loading...")
                   Spacer()
                } else {
                    Spacer()
                    Text("Select parameters and fetch data.")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding()
            .navigationTitle("Housing Indicators")
        }
    }

    @ViewBuilder
    private var queryInputView: some View {
        // (This view logic remains the same as before)
         VStack(alignment: .leading) {
            switch selectedQueryType {
            case .byIndicator:
                Picker("Indicator", selection: $selectedIndicator) {
                    Text("Select Indicator").tag(IndicatorName?(nil))
                    ForEach(IndicatorName.allCases) { indicator in
                        Text(indicator.rawValue).tag(IndicatorName?(indicator))
                    }
                }
            case .byDataYear:
                HStack {
                    Text("Data Year:")
                    TextField("YYYY", text: $inputYear)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
            case .byDataYearQuarter:
                HStack {
                    Text("Data Year:")
                    TextField("YYYY", text: $inputYear)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
                Picker("Quarter", selection: $selectedQuarter) {
                     Text("Select Quarter").tag(QuarterName?(nil))
                     ForEach(QuarterName.allCases) { q in
                         Text(q.rawValue.uppercased()).tag(QuarterName?(q))
                     }
                }
            case .byReportYear:
                HStack {
                    Text("Report Year:")
                    TextField("YYYY", text: $inputYear)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
            case .byReportYearMonth:
                HStack {
                    Text("Report Year:")
                    TextField("YYYY", text: $inputYear)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
                HStack {
                    Text("Report Month:")
                    TextField("MM", text: $inputMonth)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 50)
                    Spacer()
                }
            }
        }
        .animation(.default, value: selectedQueryType)
    }

    func fetchMockData() {
        isLoading = true
        errorMessage = nil
        fetchedReport = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            if selectedQueryType == .byIndicator && selectedIndicator == nil {
                errorMessage = "Please select an indicator."
            } else {
                fetchedReport = createMockReport()
            }
        }
    }

    // --- Mock Data Creation (CORRECTED Initializers) ---
    func createMockReport() -> IndicatorsReport {
        // Create Quarter instances using the corrected struct
        let q1_2023 = Quarter(fullName: "Q1 2023", quarterName: "Q1", yearString: "2023")
        let q2_2023 = Quarter(fullName: "Q2 2023", quarterName: "Q2", yearString: "2023")
        let q3_2023_f = Quarter(fullName: "Q3 2023", quarterName: "Q3", yearString: "2023")

        // Create TimeSeriesDataPointQuarterDouble instances WITHOUT year/quarter args
        let point1 = TimeSeriesDataPointQuarterDouble(slot: q1_2023, forecast: false, value: 1450.5, unit: "thousands")
        let point2 = TimeSeriesDataPointQuarterDouble(slot: q2_2023, forecast: false, value: 1510.2, unit: "thousands")
        let point3 = TimeSeriesDataPointQuarterDouble(slot: q3_2023_f, forecast: true, value: 1550.0, unit: "thousands")

        let indicatorCat = Indicator(subjectArea: "research", dataSetType: "housing-indicators", indicatorName: IndicatorName.totalHousingStarts.rawValue)

        let timeSeries1 = IndicatorTimeSeriesDouble(category: indicatorCat,
                                                    effectiveDate: "2023-08-15T10:00:00Z",
                                                    indicatorName: IndicatorName.totalHousingStarts.rawValue,
                                                    points: [point1, point2, point3])

        // Create more points WITHOUT year/quarter args
        let point4 = TimeSeriesDataPointQuarterDouble(slot: q1_2023, forecast: false, value: 4.5, unit: "%")
        let point5 = TimeSeriesDataPointQuarterDouble(slot: q2_2023, forecast: false, value: 4.8, unit: "%")
        let point6 = TimeSeriesDataPointQuarterDouble(slot: q3_2023_f, forecast: true, value: 5.1, unit: "%")
        let mortgageIndicatorCat = Indicator(subjectArea: "research", dataSetType: "economic-forecasts", indicatorName: IndicatorName.thirtyYearFixedRateMortgage.rawValue)
         let timeSeries2 = IndicatorTimeSeriesDouble(category: mortgageIndicatorCat,
                                                    effectiveDate: "2023-08-15T10:00:00Z",
                                                    indicatorName: IndicatorName.thirtyYearFixedRateMortgage.rawValue,
                                                    points: [point4, point5, point6])

        return IndicatorsReport(indicators: [timeSeries1, timeSeries2])
    }
}

// --- View to display the whole report ---
struct IndicatorsReportView: View {
    let report: IndicatorsReport

    var body: some View {
        List {
            // Use optional chaining safely
            if let indicators = report.indicators, !indicators.isEmpty {
                 ForEach(indicators) { timeSeries in
                    IndicatorTimeSeriesView(timeSeries: timeSeries)
                }
            } else {
                Text("No indicator data found in this report.")
            }
        }
        .listStyle(.plain)
    }
}

// --- View to display a single indicator's time series from one report ---
struct IndicatorTimeSeriesView: View {
    let timeSeries: IndicatorTimeSeriesDouble

    private func formattedDate(_ dateString: String?) -> String {
         guard let dateString = dateString else { return "N/A" }
         // Use ISO8601DateFormatter for reliable parsing
        let isoFormatter = ISO8601DateFormatter()
        // Common variations for internet date time
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withColonSeparatorInTimeZone]

        if let date = isoFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString // Fallback if parsing fails
    }

     var body: some View {
        Section {
             // Use optional chaining safely
             ForEach(timeSeries.points ?? []) { point in
                TimeSeriesDataPointView(dataPoint: point)
            }
        } header: {
            VStack(alignment: .leading) {
                Text(timeSeries.indicatorName ?? "Unknown Indicator")
                    .font(.headline)
                Text("Report Date: \(formattedDate(timeSeries.effectiveDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}

// --- View to display a single data point ---
struct TimeSeriesDataPointView: View {
    let dataPoint: TimeSeriesDataPointQuarterDouble

    private var formattedValue: String {
        guard let value = dataPoint.value else { return "N/A" }
        // Format with 1 decimal place, adjust as needed
        return String(format: "%.1f", value)
    }

    var body: some View {
        HStack {
            // Use computed properties dataYear/dataQuarter which now correctly derive from slot
            Text("\(dataPoint.dataYear.map(String.init) ?? "YYYY") \(dataPoint.dataQuarter ?? "Q?")")
                .font(.caption)
                .frame(width: 80, alignment: .leading)

            Spacer()

            Text(formattedValue)
                .font(.body.monospacedDigit())

            if let unit = dataPoint.unit, !unit.isEmpty {
                 Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if dataPoint.forecast == true {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                    .help("Forecasted Value")
            } else {
                 Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
                    .help("Historical Value")
            }
        }
        .padding(.vertical, 2)
    }
}


// MARK: - Xcode Preview Provider
#if DEBUG
struct HousingIndicatorAPIView_Previews: PreviewProvider {
    static var previews: some View {
        HousingIndicatorAPIView()
    }
}
#endif
