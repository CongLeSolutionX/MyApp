//
//  CIRTDataView.swift
//  MyApp
//
//  Created by Cong Le on 3/23/25.
//

import SwiftUI
import Charts

// 1. Data Model (Simplified for brevity, representative of the CSV columns)
struct LoanData: Identifiable {
    let id = UUID()
    let loanIdentifier: String
    let reportingPeriod: String
    let sellerName: String
    let originalUPB: Double
    let currentActualUPB: Double
    let originalInterestRate: Double
    let currentInterestRate: Double
    let borrowerCreditScore: Int?
    let dti: Int?
    let propertyState: String
    let loanPurpose: String // "P" (Purchase), "R" (Refinance), "C" (Cash-out Refinance)
    
    // Computed property for better chart labels combining identifier and period
    var chartLabel: String {
        "\(loanIdentifier)-\(reportingPeriod)"
    }
    
    // Handling missing values: Using init to cleanse the incoming loan data
    init(loanIdentifier: String, reportingPeriod: String, sellerName: String,
         originalUPB: String, currentActualUPB: String, originalInterestRate: String,
         currentInterestRate: String, borrowerCreditScore: String, dti: String,
         propertyState: String, loanPurpose: String) {
        
        self.loanIdentifier = loanIdentifier
        self.reportingPeriod = reportingPeriod
        self.sellerName = sellerName
        self.originalUPB = Double(originalUPB) ?? 0.0
        self.currentActualUPB = Double(currentActualUPB) ?? 0.0
        self.originalInterestRate = Double(originalInterestRate) ?? 0.0
        // Default value for missing current interest rate.
        self.currentInterestRate = Double(currentInterestRate) ?? self.originalInterestRate
        self.borrowerCreditScore = Int(borrowerCreditScore)
        self.dti = Int(dti)
        self.propertyState = propertyState
        self.loanPurpose = loanPurpose
    }
    
}

// 2. ViewModel (Parses CSV data, prepares data for charting)
class LoanDataViewModel: ObservableObject {
    @Published var loanData: [LoanData] = []
    @Published var selectedChartType: ChartType = .upbComparison
    @Published var selectedState: String? = nil // State filter
    @Published var selectedPurpose: String? = nil  // Loan Purpose filter
    @Published var states: [String] = []
    @Published var loanPurposes: [String] = []
    @Published var showCombinedCreditScoreChart: Bool = false // Control combined chart
    @Published var lowerDTIBound: Int = 0
    @Published var upperDTIBound: Int = 100
    @Published var showSellerComparison: Bool = false
    @Published var showInterestRateComparison: Bool = false
    
    // Available Chart Types
    enum ChartType: String, CaseIterable, Identifiable {
        case upbComparison = "UPB Comparison"
        case creditScoreDistribution = "Credit Score Distribution"
        case dtiDistribution = "DTI Distribution"
        //Add case for combinedCreditScoreDistribution
        case combinedCreditScoreDistribution = "Combined Credit Score Distribution"
        case sellerComparison = "Seller Comparison (Original UPB)"
        case interestRateComparison = "Interest Rate Comparison"
        var id: String { self.rawValue }
    }
    
    init() {
        loadLoanData()
    }
    // Load Data
    func loadLoanData() {
        // Multi-line string for CSV data (for demonstration purposes)
        let csvString = """
        5125|94751875|122024|C|Wells Fargo Bank, N.A.||FANNIE MAE|4.000||225000.00|223000.00|0.00|360|082019|102019|||||74|74|2|44|701|775|N|R|SF|1|P|FL|38940|349||FRM|N|N||||||NA|01|112022|234859.40|||0.00|||||||||||||||0.00|||||690|761||||||0.00||0.00|7|0.00|N|112022||||A|N|||||||||||||N||7|N|CIRT 2020-1|N|7|||7|
        5125|94751876|122024|R|Movement Mortgage, LLC||FANNIE MAE|4.125||111000.00|110000.00|0.00|360|072019|092019|||||80|80|1|27|754||N|P|CO|1|P|FL|27260|320||FRM|N|N||||||NA|01|122020|48121.47|||0.00||||||||||||||||||||740|||||||0.00||0.00|7||N|122020||||A|N|||||||||||||N||7|N|CIRT 2020-1|N|7|||7|
        5125|94751877|122024|R|Movement Mortgage, LLC|New Residential Mortgage LLC|FANNIE MAE|3.990|3.990|215000.00|213000.00|192317.97|360|052019|072019|66|294|294|062049|80|80|2|38|794|799|Y|P|SF|2|P|VA|47260|236||FRM|N|N|||00|000000000000000000000000000000000000000000000000|N|NA||||||385.42||||||||||||||||||||787|802|802|807||N||0.00||0.00|7||N|||||A|N|||||||||||||N||7|N|CIRT 2020-1||7|||7|192317.97
        5125|94751878|122024|R|Other||FANNIE MAE|3.990||155000.00|154000.00|0.00|360|082019|102019|||||65|65|1|23|798||N|P|PU|1|P|GA|12060|301||FRM|N|N||||||NA|01|042021|150836.48|||0.00||||||||||||||||||||801|||||||0.00||0.00|7||N|042021||||A|N|||||||||||||N||7|N|CIRT 2020-1|N|7|||7|
        5125|94751879|122024|C|United Wholesale Mortgage, LLC|Lakeview Loan Servicing, LLC|FANNIE MAE|5.250|5.250|161000.00|160000.00|147378.68|360|062019|082019|65|295|295|072049|75|75|1|28|807||N|C|SF|1|I|TX|19100|750||FRM|N|N|||00|000000000000000000000000000000000000000000000000|N|NA||||||244.58||||||||||||||||||||801||737|||Y||0.00||0.00|7||N|||||A|N|||||||||||||N||7|N|CIRT 2020-1||7|||7|147378.68
        5125|94751880|122024|R|Other||FANNIE MAE|3.875||169000.00|168000.00|0.00|360|082019|102019|||||80|80|1|44|724||N|P|SF|1|S|NH|14460|038||FRM|N|N||||||NA|01|112021|149400.28|||0.00||||||||||||||||||||710|||||||0.00||0.00|7||N|112021||||W|N|||||||||||||N||7|N|CIRT 2020-1|N|7|||7|
        5125|94751881|122024|C|Wells Fargo Bank, N.A.||FANNIE MAE|4.625||208000.00|207000.00|0.00|360|062019|082019|||||80|80|2|40|691|736|N|R|SF|1|P|CA|40140|923||FRM|N|N||||||NA|01|052020|205552.84|||0.00||||||||||||||||||||691|760||||||0.00||0.00|7||N|052020||||A|N|||||||||||||||7|N|CIRT 2020-1|N|7|||7|
        5125|94751882|122024|R|Other||FANNIE MAE|3.750||272000.00|270000.00|0.00|360|062019|082019|||||80|80|2|33|792|787|N|P|PU|1|S|FL|15980|339||FRM|N|N||||||NA|01|032021|263993.44|||0.00||||||||||||||||||||780|780||||||0.00||0.00|7||N|032021||||A|N|||||||||||||N||7|N|CIRT 2020-1|N|7|||7|
        5125|94751883|122024|R|Other|Other|FANNIE MAE|3.875|3.875|218000.00|217000.00|195544.31|360|082019|112019|62|298|298|102049|75|75|2|17|735|725|N|R|PU|1|P|CO|17820|809||FRM|N|N|||00|000000000000000000000000000000000000000000000000|N|NA||||||390.07||||||||||||||||||||709|698|782|787||N||0.00||0.00|7||N|||||A|N|||||||||||||N||7|N|CIRT 2020-1||7|||7|195544.31
        5125|94751884|122024|R|Other|Other|FANNIE MAE|3.250|3.250|356000.00|353000.00|308076.21|360|072019|092019|64|296|286|082049|80|80|2|20|763|763|Y|P|SF|1|P|CA|40900|958||FRM|N|N|||00|000000000000000000000000000000000000000000000000|N|NA||||||797.80||||||||||||||||||||756|712|787|762||N||0.00||0.00|7||N|||||A|N|||||||||||||N||7|N|CIRT 2020-1||7|||7|308076.21
        """
        
        // Split into rows
        let rows = csvString.components(separatedBy: "\n")
        
        var loadedLoanData: [LoanData] = []
        
        // Parse CSV (using a simple split, robust parsing would use a library)
        for row in rows {
            let columns = row.components(separatedBy: "|")
            // Data validation and cleansing within the LoanData initializer
            if columns.count > 10 { //Basic Sanity check
                let loan = LoanData(loanIdentifier: columns[1],
                                    reportingPeriod: columns[2],
                                    sellerName: columns[3],
                                    originalUPB: columns[10],
                                    currentActualUPB: columns[12],
                                    originalInterestRate: columns[7],
                                    currentInterestRate: columns[8],
                                    borrowerCreditScore: columns[24],
                                    dti: columns[23],
                                    propertyState: columns[30],
                                    loanPurpose: columns[28])
                loadedLoanData.append(loan)
            }
        }
        loanData = loadedLoanData
        states = Array(Set(loanData.map { $0.propertyState })).sorted() // Unique, sorted states
        loanPurposes = Array(Set(loanData.map { $0.loanPurpose })).sorted() // Unique, sorted purposes
    }
    // Filtered data based on filter criteria
    var filteredData: [LoanData] {
        var tempData = loanData
        
        //Apply filters
        
        //state
        if let state = selectedState, !state.isEmpty {
            tempData = tempData.filter { $0.propertyState == state }
        }
        //purpose
        if let purpose = selectedPurpose, !purpose.isEmpty {
            tempData = tempData.filter { $0.loanPurpose == purpose }
        }
        
        //DTI Range Filter
        tempData = tempData.filter { ($0.dti ?? 0) >= lowerDTIBound && ($0.dti ?? 100) <= upperDTIBound }
        
        return tempData
    }
    
    // Computed properties for showing/hiding specific charts
    var showUPBComparison: Bool {
        selectedChartType == .upbComparison
    }
    
    var showCreditScoreDistribution: Bool {
        selectedChartType == .creditScoreDistribution
    }
    
    var showDTIDistribution: Bool {
        selectedChartType == .dtiDistribution
    }
    
}

// 3. Main View
struct CIRTDataView: View {
    @ObservedObject var viewModel = LoanDataViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    //Filter Section
                    filterSection
                    
                    // Chart Selection
                    chartSelectionSection
                    
                    // Conditional Charts based on Chart Selection
                    if viewModel.showUPBComparison {
                        upbComparisonChart
                    }
                    if viewModel.showCreditScoreDistribution {
                        creditScoreDistributionChart
                    }
                    if viewModel.showDTIDistribution {
                        dtiDistributionChart
                    }
                    if viewModel.showCombinedCreditScoreChart {
                        combinedCreditScoreAndDTIChart
                    }
                    if viewModel.showSellerComparison {
                        sellerComparisonChart
                    }
                    
                    if viewModel.showInterestRateComparison{
                        interestRateComparisonChart
                    }
                    
                }
                .padding()
            }
            .navigationTitle("Loan Data Analysis")
        }
    }
    // Filter Section ViewBuilder
    @ViewBuilder
    private var filterSection: some View {
        // State Filter Picker
        Picker("State", selection: $viewModel.selectedState) {
            Text("All States").tag(nil as String?) // "All" option
            ForEach(viewModel.states, id: \.self) { state in
                Text(state).tag(state as String?)
            }
        }
        
        // Loan Purpose Filter Picker
        Picker("Loan Purpose", selection: $viewModel.selectedPurpose) {
            Text("All Purposes").tag(nil as String?)
            ForEach(viewModel.loanPurposes, id: \.self) { purpose in
                Text(purpose).tag(purpose as String?)
            }
        }
        
        // DTI Range Sliders
        Text("Filter by DTI Range")
        HStack {
            Text("Min DTI: \(viewModel.lowerDTIBound)")
            Slider(value: Binding(
                get: { Double(viewModel.lowerDTIBound) },
                set: { viewModel.lowerDTIBound = Int($0) }
            ), in: 0...100, step: 1)
        }
        HStack {
            Text("Max DTI: \(viewModel.upperDTIBound)")
            Slider(value: Binding(
                get: { Double(viewModel.upperDTIBound) },
                set: { viewModel.upperDTIBound = Int($0) }
            ), in: 0...100, step: 1)
        }
    }
    // Chart Selector ViewBuilder
    @ViewBuilder
    private var chartSelectionSection: some View {
        Picker("Select Chart", selection: $viewModel.selectedChartType) {
            ForEach(LoanDataViewModel.ChartType.allCases) { chartType in
                Text(chartType.rawValue).tag(chartType)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        
        //Additional chart toggles
        Toggle("Show Combined Credit Score and DTI Chart", isOn: $viewModel.showCombinedCreditScoreChart)
        
        
        Toggle("Show Seller Comparison Chart", isOn: $viewModel.showSellerComparison)
        
        Toggle("Show Interest Rate Comparison", isOn: $viewModel.showInterestRateComparison)
        
    }
    //UPB Comparison
    @ViewBuilder
    private var upbComparisonChart: some View{
        Chart(viewModel.filteredData) { data in
            BarMark(
                x: .value("Loan", data.chartLabel),
                y: .value("Original UPB", data.originalUPB),
                stacking: .unstacked // Explicitly unstacked
            )
            .foregroundStyle(Color.blue)
            .annotation {
                Text(String(format: "%.0f", data.originalUPB)) // Format as integer
                    .font(.caption)
            }
            
            BarMark(
                x: .value("Loan", data.chartLabel),
                y: .value("Current UPB", data.currentActualUPB),
                stacking: .unstacked // Explicitly unstacked
                
            )
            .foregroundStyle(Color.green)
            .annotation {
                Text(String(format: "%.0f", data.currentActualUPB))
                    .font(.caption)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) // Put Y-axis labels on the left
        }
        .frame(height: 300)
    }
    //Credit Score Distribution Chart
    @ViewBuilder
    private var creditScoreDistributionChart: some View{
        Chart(viewModel.filteredData) { data in
            if let score = data.borrowerCreditScore {
                BarMark(
                    x: .value("Credit Score", String(score)), // Show as String
                    y: .value("Frequency", 1) // Count of occurrences
                )
                .foregroundStyle(Color.cyan)
            }
        }
        .chartYAxis { AxisMarks(position: .leading) } // Correct way to specify the Y-axis marks
        .chartXAxis {
            AxisMarks(values: .automatic) { value in //Explicitly using .automatic
                AxisGridLine()
                AxisTick()
                if let stringValue = value.as(String.self), let intValue = Int(stringValue) {
                    AxisValueLabel("\(intValue)") // Display the score
                }
            }
        }
        .frame(height: 300)
    }
    //DTI Distribution
    @ViewBuilder
    private var dtiDistributionChart: some View{
        Chart(viewModel.filteredData) { data in
            if let dti = data.dti {
                BarMark(
                    x: .value("DTI", String(dti)), // Show as String
                    y: .value("Frequency", 1)
                )
            }
        }
        .chartYAxis { AxisMarks(position: .leading) }  //correct way to specify y axis mark
        .chartXAxis {
            AxisMarks(values: .automatic) { value in  // Use explicit .automatic
                AxisGridLine()
                AxisTick()
                if let stringValue = value.as(String.self), let intValue = Int(stringValue) {
                    AxisValueLabel("\(intValue)") // Display the DTI
                }
            }
        }
        .frame(height: 300)
    }
    
    // Combined Credit Score and DTI Chart
    @ViewBuilder
    private var combinedCreditScoreAndDTIChart: some View {
        Chart(viewModel.filteredData) { data in
            if let score = data.borrowerCreditScore, let dti = data.dti {
                PointMark(
                    x: .value("Credit Score", score),
                    y: .value("DTI", dti)
                )
                .foregroundStyle(Color.purple)
            }
        }
        .chartYAxis { AxisMarks(position: .leading) }  //correct way to specify y axis mark
        
        .chartXAxis {
            AxisMarks(values: .automatic) { value in  // Use explicit .automatic
                AxisGridLine()
                AxisTick()
                AxisValueLabel()  //correct display
            }
        }
        .frame(height: 300)
        .chartForegroundStyleScale([ // Added scale for clarity
            "Point": .purple
                                   ])
    }
    
    
    @ViewBuilder
    private var sellerComparisonChart: some View {
        Chart(viewModel.filteredData) { data in
            BarMark(
                x: .value("Seller", data.sellerName),
                y: .value("Original UPB", data.originalUPB)
            )
            .foregroundStyle(by: .value("Seller", data.sellerName)) // Different colors
        }
        .chartYAxis { AxisMarks(position: .leading) }  //correct way to specify y axis mark
        .chartXAxis {
            AxisMarks(values: .automatic) { value in  // Use explicit .automatic
                AxisGridLine()
                AxisTick()
                AxisValueLabel()  //correct display
            }
        }
        .frame(height: 300)
    }
    
    @ViewBuilder
    private var interestRateComparisonChart: some View {
        Chart(viewModel.filteredData) { data in
            LineMark( // Use LineMark for interest rate trends
                x: .value("Loan", data.chartLabel),
                y: .value("Original Interest Rate", data.originalInterestRate)
            )
            .foregroundStyle(Color.orange)
            .interpolationMethod(.catmullRom) // Smooth line
            
            LineMark(
                x: .value("Loan", data.chartLabel),
                y: .value("Current Interest Rate", data.currentInterestRate)
            )
            .foregroundStyle(Color.red)
            .interpolationMethod(.catmullRom)
        }
        .chartYAxis { AxisMarks(position: .leading) }  //correct way to specify y axis mark
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()  //correct display
            }
        }
        
        .frame(height: 300)
        .chartForegroundStyleScale([ // Add a legend
            "Original Interest Rate": .orange,
            "Current Interest Rate": .red
                                   ])
    }
    
}
// Preview
struct CIRTDataView_Previews: PreviewProvider {
    static var previews: some View {
        CIRTDataView()
    }
}
