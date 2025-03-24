//
//  CIRTData_LongView.swift
//  MyApp
//
//  Created by Cong Le on 3/23/25.
//

import SwiftUI

// --- (LoanData struct from Phase 1 goes here) ---
// --- struct LoanData Paste Here ---
struct LoanData_FullVersion: Identifiable {
    var id = UUID() // Required for Identifiable
    let poolNumber: String
    let loanIdentifier: String
    let reportingPeriod: String
    let channel: String
    let sellerName: String
    let servicerName: String
    let masterServicer: String
    let originalInterestRate: String
    let currentInterestRate: String
    let originalUPB: String
    let issueUPB: String
    let currentActualUPB: String
    let originalTerm: String
    let originationDate: Date?
    let firstPaymentDate: Date?
    let monthsDelinquent: String
    let remainingMonthsToMaturityLegal: String
    let remainingMonthsToMaturityAmortization: String
    let maturityDate:  Date?
    let originalLoanToValue: String
    let originalCombinedLoanToValue: String
    let numberOfBorrowers: String
    let debtToIncomeRatio: String
    let borrowerCreditScore: String
    let coBorrowerCreditScore: String
    let firstTimeHomebuyerIndicator: String
    let loanPurpose: String
    let propertyType: String
    let numberOfUnits: String
    let occupancyStatus: String
    let propertyState: String
    let msaCode: String
    let zipCode: String
    let mortgageInsurancePercentage: String
    let loanProductType: String
    let coBorrowerCreditScoreIndicator: String
    let mortgageInsuranceType: String
    let relocationMortgageIndicator: String
    let zeroBalanceCode: String
    let zeroBalanceEffectiveDate:  Date?
    let upbAtTimeOfRemoval: String
    let interestForgivenUnderReliefPlan: String
    let daysDelinquentWithReliefOptions: String
    let zeroBalanceCodeUpdatedIndicator: String
    let modificationFlag: String
    let servicerLossMitigationEfforts: String // Long name, for clarity
    let delinquencyResolutionCount: String
    let totalRepaymentPlanCount: String
    let activeRepaymentPlanFlag: String
    let repaymentPlanStartDate:  Date?
    let bankruptcyIndicator: String
    let foreclosureIndicator: String
    let repurchaseIndicator: String
    let repurchaseDate:  Date?
    let deferralIndicator: String
    let loanAge: String
    let everDelinquent: String
    let currentlyDelinquent: String
    let lossSeverityCalculatedFlag: String
    let modificationLossAmount: String
    let foreclosureExpenses: String
    let netSalesProceeds: String
    let creditEnhancementProceeds: String
    let repurchaseProceeds: String
    let recoveries: String
    let miscellaneousExpenses: String
    let taxesAndInsurance: String
    let nonInterestBearingUPB: String
    let principalForgivenessAmount: String
    let originalListDate:  Date?
    let originalListPrice: String
    let currentListDate:  Date?
    let currentListPrice: String
    let borrowerPaidExpense: String
    let originalAppraisedValue: String
    let mandatoryDeliveryCommitNumber: String
    let monthsToAmortization: String
    let servicingActivityIndicator: String
    let currentDelinquencyStatusCode: String
    let paymentChangeDate: Date?
    let borrowerAssistanceStatusCode: String
    let currentPeriodModificationLossAmount: String
    let cumulativeModificationLossAmount: String
    let currentPeriodCreditEventNetGainOrLoss: String
    let cumulativeCreditEventNetGainOrLoss: String
    let homeReadyProgramIndicator: String
    let specialEligibilityProgramIndicator: String
    let foreclosurePrincipalWriteOffAmount: String
    let nonInterestBearingUPBFlag: String
    let delinquencyResolutionStrategyCode: String
    let monthsDelinquentDuringCOVIDForbearancePeriod: String
    let highBalanceLoanIndicator: String
    let armIndicator: String
    let dealName: String
    let repurchaseUPBFlag: String
    let replacementLoanFlag: String
    let originalDebtToIncomeRatioLowerRange: String
    let originalDebtToIncomeRatioUpperRange: String
    let currentActualUPBRounded: String
    
    // Helper computed property to format dates
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yyyy" // Customize as needed
        return formatter.string(from: date)
    }
    
    // Computed properties to expose formatted dates (optional, for convenience)
    var formattedOriginationDate: String { formattedDate(originationDate) }
    var formattedFirstPaymentDate: String { formattedDate(firstPaymentDate) }
    var formattedMaturityDate: String { formattedDate(maturityDate) }
    var formattedZeroBalanceEffectiveDate: String { formattedDate(zeroBalanceEffectiveDate) }
    var formattedRepurchaseDate: String { formattedDate(repurchaseDate) }
    var formattedRepaymentPlanStartDate: String { formattedDate(repaymentPlanStartDate) }
    var formattedOriginalListDate: String { formattedDate(originalListDate) }
    var formattedCurrentListDate: String { formattedDate(currentListDate) }
    var formattedPaymentChangeDate: String { formattedDate(paymentChangeDate) }
    
}


// --- (Data Parsing extension from Phase 1 goes here) ---
// --- extension LoanData Paste Here ---
// Example extension for sample data
extension LoanData_FullVersion {
    static var sample: LoanData_FullVersion {
        LoanData_FullVersion(
            poolNumber: "5125",
            loanIdentifier: "94751875",
            reportingPeriod: "122024",
            channel: "C",
            sellerName: "Wells Fargo Bank, N.A.",
            servicerName: "FANNIE MAE",
            masterServicer: "",
            originalInterestRate: "4.000",
            currentInterestRate: "",
            originalUPB: "225000.00",
            issueUPB: "223000.00",
            currentActualUPB: "0.00",
            originalTerm: "360",
            originationDate: DateFormatter().date(from: "08/2019"), // Provide a valid date string here
            firstPaymentDate: DateFormatter().date(from: "10/2019"), // And here
            monthsDelinquent: "",
            remainingMonthsToMaturityLegal: "",
            remainingMonthsToMaturityAmortization: "",
            maturityDate: Date(),
            originalLoanToValue: "74",
            originalCombinedLoanToValue: "74",
            numberOfBorrowers: "2",
            debtToIncomeRatio: "44",
            borrowerCreditScore: "701",
            coBorrowerCreditScore: "775",
            firstTimeHomebuyerIndicator: "N",
            loanPurpose: "R",
            propertyType: "SF",
            numberOfUnits: "1",
            occupancyStatus: "p",
            propertyState: "FL",
            msaCode: "38940",
            zipCode: "349",
            mortgageInsurancePercentage: "",
            loanProductType: "FRM",
            coBorrowerCreditScoreIndicator: "N",
            mortgageInsuranceType: "",
            relocationMortgageIndicator: "N",
            zeroBalanceCode: "",
            zeroBalanceEffectiveDate: Date(),
            upbAtTimeOfRemoval: "234859.40",
            interestForgivenUnderReliefPlan: "",
            daysDelinquentWithReliefOptions: "",
            zeroBalanceCodeUpdatedIndicator: "0.00",
            modificationFlag: "",
            servicerLossMitigationEfforts: "",
            delinquencyResolutionCount: "",
            totalRepaymentPlanCount: "",
            activeRepaymentPlanFlag: "",
            repaymentPlanStartDate: Date(),
            bankruptcyIndicator: "",
            foreclosureIndicator: "",
            repurchaseIndicator: "",
            repurchaseDate: Date(),
            deferralIndicator: "",
            loanAge: "7",
            everDelinquent: "",
            currentlyDelinquent: "N",
            lossSeverityCalculatedFlag: "",
            modificationLossAmount: "",
            foreclosureExpenses: "",
            netSalesProceeds: "",
            creditEnhancementProceeds: "",
            repurchaseProceeds: "",
            recoveries: "",
            miscellaneousExpenses: "",
            taxesAndInsurance: "",
            nonInterestBearingUPB: "",
            principalForgivenessAmount: "",
            originalListDate: Date(),
            originalListPrice: "",
            currentListDate: Date(),
            currentListPrice: "",
            borrowerPaidExpense: "",
            originalAppraisedValue: "",
            mandatoryDeliveryCommitNumber: "",
            monthsToAmortization: "",
            servicingActivityIndicator: "N",
            currentDelinquencyStatusCode: "",
            paymentChangeDate: Date(),
            borrowerAssistanceStatusCode: "",
            currentPeriodModificationLossAmount: "",
            cumulativeModificationLossAmount: "",
            currentPeriodCreditEventNetGainOrLoss: "",
            cumulativeCreditEventNetGainOrLoss: "",
            homeReadyProgramIndicator: "",
            specialEligibilityProgramIndicator: "",
            foreclosurePrincipalWriteOffAmount: "",
            nonInterestBearingUPBFlag: "",
            delinquencyResolutionStrategyCode: "",
            monthsDelinquentDuringCOVIDForbearancePeriod: "",
            highBalanceLoanIndicator: "",
            armIndicator: "N",
            dealName: "CIRT 2020-1",
            repurchaseUPBFlag: "",
            replacementLoanFlag: "",
            originalDebtToIncomeRatioLowerRange: "",
            originalDebtToIncomeRatioUpperRange: "",
            currentActualUPBRounded: ""
        )
    }
}

extension LoanData_FullVersion {
    // Static function to parse the data string
    static func parse(from markdownTable: String) -> [LoanData_FullVersion] {
        let rows = markdownTable.components(separatedBy: "\n")
        
        // Get the headers (first row)
        let headerRow = rows[0]
        let headers = headerRow.components(separatedBy: "|").dropFirst().dropLast().map { $0.trimmingCharacters(in: .whitespaces) } // Remove padding, first and last "|"
        
        // Parse data rows (skip headers and separator lines)
        let dataRows = rows.dropFirst(2) // Skip header and separator line
        
        var loanDataArray: [LoanData_FullVersion] = []
        
        
        //Helper
        func dateFromString(_ dateString: String) -> Date? {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/yyyy" // Match the format in your data
            return formatter.date(from: dateString)
        }
        
        for row in dataRows {
            
            var values = row.components(separatedBy: "|").dropFirst().dropLast().map { $0.trimmingCharacters(in: .whitespaces) }
            
            // Handle cases where the last values might be missing
            while values.count < headers.count {
                values.append("") // Or some other placeholder for missing data
            }
            
            // Ensure we have enough values, even if some are empty strings.
            if values.count == headers.count {
                let loan = LoanData_FullVersion(
                    poolNumber: values[0],
                    loanIdentifier: values[1],
                    reportingPeriod: values[2],
                    channel: values[3],
                    sellerName: values[4],
                    servicerName: values[5],
                    masterServicer: values[6],
                    originalInterestRate: values[7],
                    currentInterestRate: values[8],
                    originalUPB: values[9],
                    issueUPB: values[10],
                    currentActualUPB: values[11],
                    originalTerm: values[12],
                    originationDate: dateFromString(values[13]),
                    firstPaymentDate: dateFromString(values[14]),
                    monthsDelinquent: values[15],
                    remainingMonthsToMaturityLegal: values[16],
                    remainingMonthsToMaturityAmortization: values[17],
                    maturityDate: dateFromString(values[18]),
                    originalLoanToValue: values[19],
                    originalCombinedLoanToValue: values[20],
                    numberOfBorrowers: values[21],
                    debtToIncomeRatio: values[22],
                    borrowerCreditScore: values[23],
                    coBorrowerCreditScore: values[24],
                    firstTimeHomebuyerIndicator: values[25],
                    loanPurpose: values[26],
                    propertyType: values[27],
                    numberOfUnits: values[28],
                    occupancyStatus: values[29],
                    propertyState: values[30],
                    msaCode: values[31],
                    zipCode: values[32],
                    mortgageInsurancePercentage: values[33],
                    loanProductType: values[34],
                    coBorrowerCreditScoreIndicator: values[35],
                    mortgageInsuranceType: values[36],
                    relocationMortgageIndicator: values[37],
                    zeroBalanceCode: values[38],
                    zeroBalanceEffectiveDate: dateFromString(values[39]),
                    upbAtTimeOfRemoval: values[40],
                    interestForgivenUnderReliefPlan: values[41],
                    daysDelinquentWithReliefOptions: values[42],
                    zeroBalanceCodeUpdatedIndicator: values[43],
                    modificationFlag: values[44],
                    servicerLossMitigationEfforts: values[45], // Long name, for clarity
                    delinquencyResolutionCount: values[46],
                    totalRepaymentPlanCount: values[47],
                    activeRepaymentPlanFlag: values[48],
                    repaymentPlanStartDate: dateFromString(values[49]),
                    bankruptcyIndicator: values[50],
                    foreclosureIndicator: values[51],
                    repurchaseIndicator: values[52],
                    repurchaseDate: dateFromString(values[53]),
                    deferralIndicator: values[54],
                    loanAge: values[55],
                    everDelinquent: values[56],
                    currentlyDelinquent: values[57],
                    lossSeverityCalculatedFlag: values[58],
                    modificationLossAmount: values[59],
                    foreclosureExpenses: values[60],
                    netSalesProceeds: values[61],
                    creditEnhancementProceeds: values[62],
                    repurchaseProceeds: values[63],
                    recoveries: values[64],
                    miscellaneousExpenses: values[65],
                    taxesAndInsurance: values[66],
                    nonInterestBearingUPB: values[67],
                    principalForgivenessAmount: values[68],
                    originalListDate: dateFromString(values[69]),
                    originalListPrice: values[70],
                    currentListDate: dateFromString(values[71]),
                    currentListPrice: values[72],
                    borrowerPaidExpense: values[73],
                    originalAppraisedValue: values[74],
                    mandatoryDeliveryCommitNumber: values[75],
                    monthsToAmortization: values[76],
                    servicingActivityIndicator: values[77],
                    currentDelinquencyStatusCode: values[78],
                    paymentChangeDate: dateFromString(values[79]),
                    borrowerAssistanceStatusCode: values[80],
                    currentPeriodModificationLossAmount: values[81],
                    cumulativeModificationLossAmount: values[82],
                    currentPeriodCreditEventNetGainOrLoss: values[83],
                    cumulativeCreditEventNetGainOrLoss: values[84],
                    homeReadyProgramIndicator: values[85],
                    specialEligibilityProgramIndicator: values[86],
                    foreclosurePrincipalWriteOffAmount: values[87],
                    nonInterestBearingUPBFlag: values[88],
                    delinquencyResolutionStrategyCode: values[89],
                    monthsDelinquentDuringCOVIDForbearancePeriod: values[90],
                    highBalanceLoanIndicator: values[91],
                    armIndicator: values[92],
                    dealName: values[93],
                    repurchaseUPBFlag: values[94],
                    replacementLoanFlag: values[95],
                    originalDebtToIncomeRatioLowerRange: values[96],
                    originalDebtToIncomeRatioUpperRange: values[97],
                    currentActualUPBRounded: values[98]
                )
                loanDataArray.append(loan)
            }
        }
        
        return loanDataArray
    }
}
// --- (LoanListView, LoanListRow, and LoanDetailView from Phase 2 go here) ---
// --- struct LoanListView, LoanListRow, and LoanDetailView Paste Here ---

struct LoanListView: View {
    let loanData: [LoanData_FullVersion]
    
    var body: some View {
        NavigationView {
            List(loanData) { loan in
                NavigationLink(destination: LoanDetailView(loan: loan)) {
                    LoanListRow(loan: loan) // A custom view to display a concise row
                }
            }
            .navigationTitle("Loan Data")
        }
    }
}

// A concise representation of a loan in the list
struct LoanListRow: View {
    let loan: LoanData_FullVersion
    
    var body: some View {
        HStack {
            Text("ID: \(loan.loanIdentifier)")
            Spacer()
            Text("State: \(loan.propertyState)")
            Spacer()
            Text("Score: \(loan.borrowerCreditScore)")
        }
    }
}

struct LoanDetailView: View {
    let loan: LoanData_FullVersion
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    
    var body: some View {
        
        //First check if the device is iPad or not.
        if horizontalSizeClass == .regular {
            //For iPad, display all the values.
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Loan Details")
                        .font(.largeTitle)
                        .padding(.bottom)
                    
                    // Use Grid for layout
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 10) {
                        detailViewGridContent
                    }
                }
                .padding()
            }
        }
        else{
            //For iPhone, you can show an error message, or display a reasonable set of content.
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Loan Details")
                        .font(.largeTitle)
                        .padding(.bottom)
                    
                    Group {
                        DetailRow(title: "Pool Number", value: loan.poolNumber)
                        DetailRow(title: "Loan Identifier", value: loan.loanIdentifier)
                        DetailRow(title: "Reporting Period", value: loan.reportingPeriod)
                        
                        // Add as many of the simplified rows that you want to be displayed on an iOS device.
                    }
                    
                    
                    
                }
                .padding()
            }
        }
        
        
    }
    
    // Helper to render grid detail view using a Group Builder
    @ViewBuilder
    private var detailViewGridContent: some View {
        Group {
            Text("Pool Number:").bold()
            Text(loan.poolNumber)
            Text("Loan Identifier:").bold()
            Text(loan.loanIdentifier)
            Text("Reporting Period:").bold()
            Text(loan.reportingPeriod)
            Text("Channel:").bold()
            Text(loan.channel)
            Text("Seller Name:").bold()
            Text(loan.sellerName)
            Text("Servicer Name:").bold()
            Text(loan.servicerName)
            Text("Master Servicer:").bold()
            Text(loan.masterServicer)
            Text("Original Interest Rate:").bold()
            Text(loan.originalInterestRate)
            Text("Current Interest Rate:").bold()
            Text(loan.currentInterestRate)
            Text("Original UPB:").bold()
            Text(loan.originalUPB)
            Text("Issue UPB:").bold()
            Text(loan.issueUPB)
            Text("Current Actual UPB:").bold()
            Text(loan.currentActualUPB)
            Text("Original Term:").bold()
            Text(loan.originalTerm)
            Text("Origination Date:").bold()
            Text(loan.formattedOriginationDate)
            Text("First Payment Date:").bold()
            Text(loan.formattedFirstPaymentDate)
            Text("Months Delinquent:").bold()
            Text(loan.monthsDelinquent)
        }
        Group {
            
            Text("Remaining Months (Legal):").bold()
            Text(loan.remainingMonthsToMaturityLegal)
            Text("Remaining Months (Amort):").bold()
            Text(loan.remainingMonthsToMaturityAmortization)
            Text("Maturity Date:").bold()
            Text(loan.formattedMaturityDate)
            Text("Original LTV:").bold()
            Text(loan.originalLoanToValue)
            Text("Original CLTV:").bold()
            Text(loan.originalCombinedLoanToValue)
            Text("Number of Borrowers:").bold()
            Text(loan.numberOfBorrowers)
            Text("DTI:").bold()
            Text(loan.debtToIncomeRatio)
            Text("Borrower Credit Score:").bold()
            Text(loan.borrowerCreditScore)
            Text("Co-Borrower Credit Score:").bold()
            Text(loan.coBorrowerCreditScore)
            Text("First Time Homebuyer:").bold()
            Text(loan.firstTimeHomebuyerIndicator)
            Text("Loan Purpose:").bold()
            Text(loan.loanPurpose)
            Text("Property Type:").bold()
            Text(loan.propertyType)
            
        }
        
        Group {
            Text("Number of Units:").bold()
            Text(loan.numberOfUnits)
            Text("Occupancy Status:").bold()
            Text(loan.occupancyStatus)
            Text("Property State:").bold()
            Text(loan.propertyState)
            Text("MSA Code:").bold()
            Text(loan.msaCode)
            Text("Zip Code:").bold()
            Text(loan.zipCode)
            Text("Mortgage Insurance %:").bold()
            Text(loan.mortgageInsurancePercentage)
            Text("Loan Product Type:").bold()
            Text(loan.loanProductType)
            Text("Co-Borrower Score Ind:").bold()
            Text(loan.coBorrowerCreditScoreIndicator)
            Text("Mortgage Insurance Type:").bold()
            Text(loan.mortgageInsuranceType)
            Text("Relocation Mortgage:").bold()
            Text(loan.relocationMortgageIndicator)
            Text("Zero Balance Code:").bold()
            Text(loan.zeroBalanceCode)
            Text("Zero Balance Date:").bold()
            Text(loan.formattedZeroBalanceEffectiveDate)
            Text("UPB at Removal:").bold()
            Text(loan.upbAtTimeOfRemoval)
        }
        
        Group{
            Text("Interest Forgiven:").bold()
            Text(loan.interestForgivenUnderReliefPlan)
            Text("Days Delinquent (Relief):").bold()
            Text(loan.daysDelinquentWithReliefOptions)
            Text("Zero Balance Code Updated:").bold()
            Text(loan.zeroBalanceCodeUpdatedIndicator)
            Text("Modification Flag:").bold()
            Text(loan.modificationFlag)
            Text("Servicer Loss Mitigation:").bold()
            Text(loan.servicerLossMitigationEfforts)
            Text("Delinquency Resolution Count:").bold()
            Text(loan.delinquencyResolutionCount)
            Text("Total Repayment Plan Count:").bold()
            Text(loan.totalRepaymentPlanCount)
            Text("Active Repayment Plan:").bold()
            Text(loan.activeRepaymentPlanFlag)
            Text("Repayment Plan Start Date:").bold()
            Text(loan.formattedRepaymentPlanStartDate)
            Text("Bankruptcy Indicator:").bold()
            Text(loan.bankruptcyIndicator)
            Text("Foreclosure Indicator:").bold()
            Text(loan.foreclosureIndicator)
            Text("Repurchase Indicator:").bold()
            Text(loan.repurchaseIndicator)
        }
        
        Group{
            Text("Repurchase Date:").bold()
            Text(loan.formattedRepurchaseDate)
            Text("Deferral Indicator:").bold()
            Text(loan.deferralIndicator)
            Text("Loan Age:").bold()
            Text(loan.loanAge)
            Text("Ever Delinquent:").bold()
            Text(loan.everDelinquent)
            Text("Currently Delinquent:").bold()
            Text(loan.currentlyDelinquent)
            Text("Loss Severity Calculated:").bold()
            Text(loan.lossSeverityCalculatedFlag)
            Text("Modification Loss Amount:").bold()
            Text(loan.modificationLossAmount)
            Text("Foreclosure Expenses:").bold()
            Text(loan.foreclosureExpenses)
            Text("Net Sales Proceeds:").bold()
            Text(loan.netSalesProceeds)
            Text("Credit Enhancement Proceeds:").bold()
            Text(loan.creditEnhancementProceeds)
            Text("Repurchase Proceeds:").bold()
            Text(loan.repurchaseProceeds)
            Text("Recoveries:").bold()
            Text(loan.recoveries)
            
            
            Text("Miscellaneous Expenses:").bold()
            Text(loan.miscellaneousExpenses)
            Text("Taxes and Insurance:").bold()
            Text(loan.taxesAndInsurance)
            Text("Non-Interest Bearing UPB:").bold()
            Text(loan.nonInterestBearingUPB)
        }
        
        
        Group{
            Text("Principal Forgiveness:").bold()
            Text(loan.principalForgivenessAmount)
            
            
            Text("Original List Date:").bold()
            Text(loan.formattedOriginalListDate)
            Text("Original List Price:").bold()
            Text(loan.originalListPrice)
            
            
            Text("Current List Date:").bold()
            Text(loan.formattedCurrentListDate)
            Text("Current List Price:").bold()
            Text(loan.currentListPrice)
            
            Text("Borrower Paid Expense:").bold()
            Text(loan.borrowerPaidExpense)
            Text("Original Appraised Value:").bold()
            Text(loan.originalAppraisedValue)
            Text("Mandatory Delivery Commit #:" ).bold()
            Text(loan.mandatoryDeliveryCommitNumber)
            
            Text("Months to Amortization:").bold()
            Text(loan.monthsToAmortization)
            Text("Servicing Activity Indicator:").bold()
            Text(loan.servicingActivityIndicator)
            Text("Current Delinquency Status:").bold()
            Text(loan.currentDelinquencyStatusCode)
        }
        
        Group{
            Text("Payment Change Date:").bold()
            Text(loan.formattedPaymentChangeDate)
            Text("Borrower Assistance Status:").bold()
            Text(loan.borrowerAssistanceStatusCode)
            
            Text("Current Period Mod Loss:").bold()
            Text(loan.currentPeriodModificationLossAmount)
            Text("Cumulative Mod Loss:").bold()
            Text(loan.cumulativeModificationLossAmount)
            
            
            Text("Current Period Credit Event:").bold()
            Text(loan.currentPeriodCreditEventNetGainOrLoss)
            
            
            Text("Cumulative Credit Event:").bold()
            Text(loan.cumulativeCreditEventNetGainOrLoss)
            
            Text("HomeReady Program:").bold()
            Text(loan.homeReadyProgramIndicator)
            
            Text("Special Eligibility Program:").bold()
            Text(loan.specialEligibilityProgramIndicator)
        }
        
        Group{
            
            Text("Foreclosure Principal WriteOff:").bold()
            Text(loan.foreclosurePrincipalWriteOffAmount)
            
            
            Text("Non-Interest Bearing UPB Flag:").bold()
            Text(loan.nonInterestBearingUPBFlag)
            Text("Delinquency Resolution Strategy:").bold()
            Text(loan.delinquencyResolutionStrategyCode)
            
            Text("Months Delinq. (COVID):").bold()
            Text(loan.monthsDelinquentDuringCOVIDForbearancePeriod)
            Text("High Balance Loan:").bold()
            Text(loan.highBalanceLoanIndicator)
            Text("ARM Indicator:").bold()
            Text(loan.armIndicator)
            Text("Deal Name:").bold()
            Text(loan.dealName)
            Text("Repurchase UPB Flag:").bold()
            Text(loan.repurchaseUPBFlag)
            
            
            Text("Replacement Loan Flag:").bold()
            Text(loan.replacementLoanFlag)
            
            Text("Orig. DTI Lower Range:").bold()
            Text(loan.originalDebtToIncomeRatioLowerRange)
            
            Text("Orig. DTI Upper Range:").bold()
            Text(loan.originalDebtToIncomeRatioUpperRange)
            
            
            
            Text("Current Actual UPB (Rounded):").bold()
            Text(loan.currentActualUPBRounded)
        }
    }
    
    // A reusable view for a single detail row (iPhone)
    struct DetailRow: View {
        let title: String
        let value: String
        
        var body: some View {
            HStack {
                Text(title)
                    .bold()
                Spacer() // Push content to the sides
                Text(value)
            }
            .padding(.vertical, 4) // Add some vertical spacing
        }
    }
}


struct CIRTData_LongView: View {
    let rawData = """
| Pool Number | Loan Identifier | Reporting Period | Channel | Seller Name                    | Servicer Name                | Master Servicer | Original Interest Rate | Current Interest Rate | Original UPB | Issue UPB | Current Actual UPB | Original Term | Origination Date | First Payment Date | Months Delinquent | Remaining Months to Maturity (Legal) | Remaining Months to Maturity (Amortization) | Maturity Date | Original Loan to Value (OLTV) | Original Combined Loan to Value (OCLTV) | Number of Borrowers | Debt-To-Income Ratio (DTI) | Borrower Credit Score at Origination | Co-Borrower Credit Score at Origination | First Time Homebuyer Indicator | Loan Purpose | Property Type | Number of Units | Occupancy Status | Property State | MSA Code | Zip Code | Mortgage Insurance Percentage | Loan Product Type | Co-Borrower Credit Score Indicator | Mortgage Insurance Type | Relocation Mortgage Indicator | Zero Balance Code | Zero Balance Effective Date | UPB at the Time of Removal | Interest Forgiven Under Relief Plan | Days Delinquent with Relief Options | Zero Balance Code Updated Indicator | Modification Flag | Servicer Loss Mitigation Efforts | Delinquency Resolution Count | Total Repayment Plan Count | Active Repayment Plan Flag | Repayment Plan Start Date | Bankruptcy Indicator | Foreclosure Indicator | Repurchase Indicator | Repurchase Date | Deferral Indicator | Loan Age | Ever Delinquent | Currently Delinquent | Loss Severity Calculated Flag | Modification Loss Amount | Foreclosure/REO Disposition Expenses | Net Sales Proceeds | Credit Enhancement Proceeds | Repurchase Proceeds | Recoveries | Miscellaneous Expenses | Taxes and Insurance | Non-Interest Bearing UPB | Principal Forgiveness Amount | Original List Date | Original List Price | Current List Date | Current List Price | Borrower Paid Expense | Original Appraised Value | Mandatory Delivery Commit Number | Months to Amortization | Servicing Activity Indicator | Current Delinquency Status Code | Payment Change Date | Borrower Assistance Status Code | Current Period Modification Loss Amount | Cumulative Modification Loss Amount | Current Period Credit Event Net Gain or Loss | Cumulative Credit Event Net Gain or Loss | HomeReady Program Indicator | Special Eligibility Program Indicator | Foreclosure Principal Write-Off Amount | Non-Interest Bearing UPB Flag | Delinquency Resolution Strategy Code | Months Delinquent During COVID Forbearance Period | High Balance Loan Indicator | ARM Indicator | Deal Name   | Repurchase UPB Flag | Replacement Loan Flag | Original Debt-To-Income Ratio (ODTI) Lower Range | Original Debt-To-Income Ratio (ODTI) Upper Range | Current Actual UPB (Rounded) |           |
| :---------- | :-------------- | :--------------- | :------ | :----------------------------- | :--------------------------- | :-------------- | :--------------------- | :-------------------- | :----------- | :-------- | :----------------- | :------------ | :--------------- | :----------------- | :---------------- | :----------------------------------- | :------------------------------------------ | :------------ | :---------------------------- | :-------------------------------------- | :------------------ | :------------------------- | :----------------------------------- | :-------------------------------------- | :----------------------------- | :----------- | :------------ | :-------------- | :--------------- | :------------- | :------- | :------- | :---------------------------- | :---------------- | :--------------------------------- | :---------------------- | :---------------------------- | :---------------- | :-------------------------- | :------------------------- | :---------------------------------- | :---------------------------------- | :---------------------------------- | :---------------- | :------------------------------- | :--------------------------- | :------------------------- | :------------------------- | :------------------------ | :------------------- | :-------------------- | :------------------- | :-------------- | :----------------- | :------- | :-------------- | :------------------- | :---------------------------- | :----------------------- | :----------------------------------- | :----------------- | :-------------------------- | :------------------ | :--------- | :--------------------- | :------------------ | :----------------------- | :--------------------------- | :----------------- | :------------------ | :---------------- | :----------------- | :-------------------- | :----------------------- | :------------------------------- | :--------------------- | :--------------------------- | :------------------------------ | :------------------ | :------------------------------ | :-------------------------------------- | :---------------------------------- | :------------------------------------------- | :--------------------------------------- | :-------------------------- | :------------------------------------ | :------------------------------------- | :---------------------------- | :----------------------------------- | :------------------------------------------------ | :-------------------------- | :------------ | :---------- | :------------------ | :-------------------- | ------------------------------------------------ | ------------------------------------------------ | ---------------------------- | --------- |
| 5125        | 94751875        | 122024           | C       | Wells Fargo Bank, N.A.         | FANNIE MAE                   |                 | 4.000                  |                       | 225000.00    | 223000.00 | 0.00               | 360           | 082019           | 102019             |                   |                                      |                                             |               | 74                            | 74                                      | 2                   | 44                         | 701                                  | 775                                     | N                              | R            | SF            | 1               | P                | FL             | 38940    | 349      |                               | FRM               | N                                  |                         | N                             |                   | 01                          | 112022                     | 234859.40                           |                                     |                                     | 0.00              |                                  |                              |                            |                            |                           |                      |                       |                      |                 |                    |          | N               | N                    | N                             |                          |                                      | 7                  |                             | N                   | Y          |                        |                     |                          |                              |                    |                     | 0.00              | 0.00               | 7                     |                          | N                                |                        |                              |                                 | A                   | N                               |                                         |                                     |                                              |                                          |                             |                                       |                                        |                               | N                                    | 7                                                 | N                           | CIRT 2020-1   | N           | 7                   |                       |                                                  | 7                                                |                              |           |
| 5125        | 94751876        | 122024           | R       | Movement Mortgage, LLC         | FANNIE MAE                   |                 | 4.125                  |                       | 111000.00    | 110000.00 | 0.00               | 360           | 072019           | 092019             |                   |                                      |                                             |               | 80                            | 80                                      | 1                   | 27                         | 754                                  |                                         | N                              | P            | CO            | 1               | P                | FL             | 27260    | 320      |                               | FRM               | N                                  |                         | N                             |                   | 01                          | 122020                     | 48121.47                            |                                     |                                     | 0.00              |                                  |                              |                            |                            |                           |                      |                       |                      |                 |                    |          |                 | N                    | N                             | N                        |                                      |                    | 7                           |                     | N          |                        |                     |                          | A                            | N                  |                     |                   |                    |                       |                          |                                  |                        |                              |                                 |                     |                                 | N                                       | 7                                   | N                                            | CIRT 2020-1                              | N                           | 7                                     |                                        |                               | 7                                    |                                                   |                             |               |             |                     |                       |                                                  |                                                  |                              |           |
| 5125        | 94751877        | 122024           | R       | Movement Mortgage, LLC         | New Residential Mortgage LLC | FANNIE MAE      | 3.990                  | 3.990                 | 215000.00    | 213000.00 | 192317.97          | 360           | 052019           | 072019             | 66                | 294                                  | 294                                         | 062049        | 80                            | 80                                      | 2                   | 38                         | 794                                  | 799                                     | Y                              | P            | SF            | 2               | P                | VA             | 47260    | 236      |                               | FRM               | N                                  |                         | N                             | 00                |                             |                            | 385.42                              |                                     |                                     |                   |                                  |                              |                            |                            |                           |                      |                       |                      |                 |                    | N        |                 |                      |                               |                          |                                      |                    |                             |                     |            |                        |                     |                          | 0.00                         |                    |                     | 0.00              | 7                  |                       | N                        |                                  |                        |                              | A                               | N                   |                                 |                                         |                                     |                                              |                                          |                             |                                       |                                        |                               | N                                    |                                                   | 7                           | N             | CIRT 2020-1 |                     | 7                     |                                                  |                                                  | 7                            | 192317.97 |
| 5125        | 94751878        | 122024           | R       | Other                          | FANNIE MAE                   |                 | 3.990                  |                       | 155000.00    | 154000.00 | 0.00               | 360           | 082019           | 102019             |                   |                                      |                                             |               | 65                            | 65                                      | 1                   | 23                         | 798                                  |                                         | N                              | P            | PU            | 1               | P                | GA             | 12060    | 301      |                               | FRM               | N                                  |                         | N                             |                   | 01                          | 042021                     | 150836.48                           |                                     |                                     | 0.00              |                                  |                              |                            |                            |                           |                      |                       |                      |                 |                    |          |                 | N                    | N                             | N                        |                                      |                    | 7                           |                     | N          |                        |                     |                          | A                            | N                  |                     |                   |                    |                       |                          |                                  |                        |                              |                                 |                     |                                 | N                                       | 7                                   | N                                            | CIRT 2020-1                              | N                           | 7                                     |                                        |                               | 7                                    |                                                   |                             |               |             |                     |                       |                                                  |                                                  |                              |           |
| 5125        | 94751879        | 122024           | C       | United Wholesale Mortgage, LLC | Lakeview Loan Servicing, LLC | FANNIE MAE      | 5.250                  | 5.250                 | 161000.00    | 160000.00 | 147378.68          | 360           | 062019           | 082019             | 65                | 295                                  | 295                                         | 072049        | 75                            | 75                                      | 1                   | 28                         | 807                                  |                                         | N                              | C            | SF            | 1               | I                | TX             | 19100    | 750      |                               | FRM               | N                                  |                         | N                             | 00                |                             |                            | 244.58                              |                                     |                                     |                   |                                  |                              |                            |                            |                           |                      |                       |                      |                 | N                  |          |                 |                      |                               |                          |                                      |                    |                             |                     |            |                        |                     |                          | 0.00                         |                    | 0.00                | 7                 |                    | N                     |                          |                                  |                        |                              | A                               | N                   |                                 |                                         |                                     |                                              |                                          |                             |                                       |                                        |                               | N                                    |                                                   | 7                           | N             | CIRT 2020-1 |                     | 7                     |                                                  |                                                  | 7                            | 147378.68 |
| 5125        | 94751880        | 122024           | R       | Other                          | FANNIE MAE                   |                 | 3.875                  |                       | 169000.00    | 168000.00 | 0.00               | 360           | 082019           | 102019             |                   |                                      |                                             |               | 80                            | 80                                      | 1                   | 44                         | 724                                  |                                         | N                              | P            | SF            | 1               | S                | NH             | 14460    | 038      |                               | FRM               | N                                  |                         | N                             |                   | 01                          | 112021                     | 149400.28                           |                                     |                                     | 0.00              |                                  |                              |                            |                            |                           |                      |                       |                      |                 |                    |          |                 |                      |                               | W                        | N                                    |                    |                             |                     | 7          |                        | N                   |                          |                              |                    |                     |                   |                    |                       |                          |                                  |                        |                              | N                               | 7                   | N                               | CIRT 2020-1                             | N                                   | 7                                            |                                          |                             | 7                                     |                                        |                               |                                      |                                                   |                             |               |             |                     |                       |                                                  |                                                  |                              |           |
| 5125        | 94751881        | 122024           | C       | Wells Fargo Bank, N.A.         | FANNIE MAE                   |                 | 4.625                  |                       | 208000.00    | 207000.00 | 0.00               | 360           | 062019           | 082019             |                   |                                      |                                             |               | 80                            | 80                                      | 2                   | 40                         | 691                                  | 736                                     | N                              | R            | SF            | 1               | P                | CA             | 40140    | 923      |                               | FRM               | N                                  |                         | N                             |                   | 01                          | 052020                     | 205552.84                           |                                     |                                     | 0.00              |                                  |                              |                            |                            |                           |                      |                       |                      |                 |                    |          |                 |                      |                               |                          |                                      |                    |                             | A                   | N          |                        |                     |                          |                              |                    |                     |                   |                    |                       |                          |                                  |                        | 7                            | N                               | CIRT 2020-1         | N                               | 7                                       |                                     |                                              | 7                                        |                             |                                       |                                        |                               |                                      |                                                   |                             |               |             |                     |                       |                                                  |                                                  |                              |           |
| 5125        | 94751882        | 122024           | R       | Other                          | FANNIE MAE                   |                 | 3.750                  |                       | 272000.00    | 270000.00 | 0.00               | 360           | 062019           | 082019             |                   |                                      |                                             |               | 80                            | 80                                      | 2                   | 33                         | 792                                  | 787                                     | N                              | P            | PU            | 1               | S                | FL             | 15980    | 339      |                               | FRM               | N                                  |                         | N                             |                   | 01                          | 032021                     | 263993.44                           |                                     |                                     | 0.00              |                                  |                              |                            |                            |                           |                      |                       |                      |                 |                    |          |                 |                      |                               |                          | A                                    | N                  |                             |                     |            |                        |                     |                          |                              |                    |                     |                   |                    | N                     | 7                        | N                                | CIRT 2020-1            | N                            | 7                               |                     |                                 | 7                                       |                                     |                                              |                                          |                             |                                       |                                        |                               |                                      |                                                   |                             |               |             |                     |                       |                                                  |                                                  |                              |           |
| 5125        | 94751883        | 122024           | R       | Other                          | Other                        | FANNIE MAE      | 3.875                  | 3.875                 | 218000.00    | 217000.00 | 195544.31          | 360           | 082019           | 112019             | 62                | 298                                  | 298                                         | 102049        | 75                            | 75                                      | 2                   | 17                         | 735                                  | 725                                     | N                              | R            | PU            | 1               | P                | CO             | 17820    | 809      |                               | FRM               | N                                  |                         | N                             | 00                |                             |                            | 390.07                              |                                     |                                     |                   |                                  |                              |                            |                            |                           |                      |                       |                      |                 |                    |          |                 | A                    | N                             |                          |                                      |                    |                             |                     |            |                        |                     |                          |                              |                    | N                   | 7                 | N                  | CIRT 2020-1           |                          | 7                                |                        |                              | 7                               | 195544.31           |                                 |                                         |                                     |                                              |                                          |                             |                                       |                                        |                               |                                      |                                                   |                             |               |             |                     |                       |                                                  |                                                  |                              |           |
| 5125        | 94751884        | 122024           | R       | Other                          | Other                        | FANNIE MAE      | 3.250                  | 3.250                 | 356000.00    | 353000.00 | 308076.21          | 360           | 072019           | 092019             | 64                | 296                                  | 286                                         | 082049        | 80                            | 80                                      | 2                   | 20                         | 763                                  | 763                                     | Y                              | P            | SF            | 1               | P                | CA             | 40900    | 958      |                               | FRM               | N                                  |                         | N                             | 00                |                             |                            | 797.80                              |                                     |                                     |                   |                                  |                              |                            |                            |                           |                      |                       |                      |                 |                    |          |                 |                      |                               | A                        | N                                    |                    |                             |                     |            |                        |                     |                          |                              |                    |                     |                   | N                  | 7                     | N                        | CIRT 2020-1                      |                        | 7                            |                                 |                     | 7                               | 308076.21                               |                                     |                                              |                                          |                             |                                       |                                        |                               |                                      |                                                   |                             |               |             |                     |                       |                                                  |                                                  |                              |           |
"""
    
    //Parse the data and store them in an array.
    @State private var loans: [LoanData_FullVersion] = []
    
    var body: some View {
        //        LoanListView(loanData: LoanData.parse(from: rawData)) // Old
        LoanListView(loanData: loans)
        // Use onAppear to set the state *after* the view has been initialized
            .onAppear {
                loans = LoanData_FullVersion.parse(from: rawData)
            }
            .previewDisplayName("List + Detail") // For Xcode Previews
        
        
    }
}

// Provide previews for both iPhone and iPad
#Preview("iPhone Preview") {
    CIRTData_LongView()
        .environment(\.horizontalSizeClass, .compact) // Simulate iPhone
}

#Preview("iPad Preview") {
    CIRTData_LongView()
        .environment(\.horizontalSizeClass, .regular) // Simulate iPad
}
