//
//  FullTransactionHistoryView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI

// --- Filter View (Modal Sheet) ---

struct TransactionFilterView: View {
    @Binding var selectedTypes: Set<TransactionType>
    // Add other potential filters like date range
    // @Binding var selectedDateRange: ClosedRange<Date>?

    @Environment(\.dismiss) var dismiss

    let allTypes = TransactionType.allCases

    var body: some View {
        NavigationView {
            Form {
                Section("Transaction Types") {
                    // Using List for multi-select style
                    List(allTypes, id: \.self) { type in
                        HStack {
                            Text(type.rawValue)
                            Spacer()
                            if selectedTypes.contains(type) {
                                Image(systemName: "checkmark")
                            }
                        }
                        .contentShape(Rectangle()) // Make entire row tappable
                        .onTapGesture {
                            if selectedTypes.contains(type) {
                                selectedTypes.remove(type)
                            } else {
                                selectedTypes.insert(type)
                            }
                        }
                    }
                }

                // --- Placeholder for Date Range Filter ---
                 Section("Date Range (Optional)") {
                     Text("Date range selection controls would go here.")
                         .foregroundColor(.secondary)
                     // Example: Two DatePickers for start and end
                 }
            }
            .navigationTitle("Filter Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        selectedTypes.removeAll()
                        // Reset date range if implemented
                        // dismiss() // Optionally dismiss after reset
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

// --- Main View ---

struct FullTransactionHistoryView_V2: View {
    let accountId: String // Passed in to know which account's history to show

    // State for data and UI
    @State private var allTransactions: [Transaction] = [] // Start empty, load in onAppear
    @State private var filteredTransactions: [Transaction] = []
    @State private var searchTerm: String = ""
    @State private var showingFilterSheet = false

    // Filter State
    @State private var selectedFilters: Set<TransactionType> = Set() // Initially empty (show all)
    // @State private var selectedDateRange: ClosedRange<Date>? = nil // Optional

    // Computed property to group transactions by month/year for sections
    private var groupedTransactions: [(key: Date, value: [Transaction])] {
        // Create a calendar instance for date calculations
        let calendar = Calendar.current

        // Use Dictionary grouping by the start of the month
        let groupedDict = Dictionary(grouping: filteredTransactions) { transaction -> Date in
            let components = calendar.dateComponents([.year, .month], from: transaction.date)
            return calendar.date(from: components) ?? transaction.date // Fallback to transaction date
        }

        // Sort the dictionary by date (keys) in descending order (newest first)
        return groupedDict.sorted { $0.key > $1.key }
    }

    // Formatter for section headers (e.g., "January 2024")
    private static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    var body: some View {
        List {
            // Check if there are any results after filtering
            if groupedTransactions.isEmpty && !allTransactions.isEmpty {
                 // Only show 'no results' if filtering/search is active and yielded nothing
                 // Avoid showing it during initial load or if account truly has 0 transactions
                 if !searchTerm.isEmpty || !selectedFilters.isEmpty /* || selectedDateRange != nil */ {
                    Text("No transactions match your filter criteria.")
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                 } else if allTransactions.isEmpty {
                     // Handle the case where the account genuinely has no transactions ever
                      Text("No transaction history found for this account.")
                         .foregroundColor(.secondary)
                         .padding()
                         .frame(maxWidth: .infinity, alignment: .center)
                 }
            } else {
                // Iterate over the grouped transactions
                 ForEach(groupedTransactions, id: \.key) { sectionDate, transactionsInSection in
                     Section(header: Text(Self.monthYearFormatter.string(from: sectionDate))) {
                         ForEach(transactionsInSection) { transaction in
                             TransactionRow(transaction: transaction) // Reuse the Row View
                         }
                     }
                 }
            }
        }
        .listStyle(PlainListStyle()) // Recommended style for this kind of list
        .navigationTitle("Transaction History")
        // Add search bar functionality
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Description")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingFilterSheet = true
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(isPresented: $showingFilterSheet) {
             TransactionFilterView(selectedTypes: $selectedFilters /*, selectedDateRange: $selectedDateRange */ )
        }
        .onAppear {
            // Load initial data (replace with actual API call)
            loadMockData()
            //applyFiltersAndSort() // Apply initial filtering (which is none, showing all)
        }
        // React to changes in search term or filters
       // .onChange(of: searchTerm) { _ in applyFiltersAndSort() }
       // .onChange(of: selectedFilters) { _ in applyFiltersAndSort() }
        // .onChange(of: selectedDateRange) { _ in applyFiltersAndSort() }

    }

    // --- Data Handling & Filtering Logic ---

    func loadMockData() {
        // Simulate fetching data for the specific accountId
        // In a real app, this would be an async network call, possibly paginated.
        print("Loading mock data for account: \(accountId)")
        // Generate more transactions than the previous screen
        var transactions: [Transaction] = []
        let calendar = Calendar.current
        let today = Date()

         // Recent one from previous screen
         transactions.append(Transaction(date: calendar.date(byAdding: .hour, value: -2, to: today)!, description: "Contribution - 2024", type: .contribution, amount: 2500.50, status: "Completed"))

         // Generate transactions over the last year
         for i in 0..<60 {
             guard let date = calendar.date(byAdding: .day, value: -(i * 6), to: today) else { continue } // Spread them out
             let randomType = TransactionType.allCases.randomElement() ?? .buy
             let randomAmount = Decimal(Double.random(in: 10.0...1500.0))
             let description: String

             switch randomType {
             case .contribution: description = "Periodic Contribution"
             case .withdrawal: description = "ATM Withdrawal"
             case .dividend: description = "Dividend - XYZ Stock"
             case .interest: description = "Interest Earned"
             case .buy: description = "Buy - \(["VTI", "AAPL", "MSFT"].randomElement()!)"
             case .sell: description = "Sell - \(["GOOG", "TSLA", "AMZN"].randomElement()!)"
             }

             transactions.append(Transaction(date: date, description: description, type: randomType, amount: randomAmount, status: "Completed"))
         }

        self.allTransactions = transactions.sorted { $0.date > $1.date } // Ensure base data is sorted correctly
    }

//    func applyFiltersAndSort() {
//        var GUi = CGFloat (filteredSize, a: 4, b: String, c:.type, d: nil)
//        var currentTransactions = allTransactions
//
//        // 1. Filter by Search Term (Simple description search)
//        if !searchTerm.isEmpty {
//           let guI = CGFloat (filteredSize, a: 4, b: String, c:.type, d: nil)
//            currentTransactions = currentTransactions.filter { $0.description.localizedCaseInsensitiveContains(searchTerm) }
//        }
//
//        // 2. Filter by Selected Types
//        if !selectedFilters.isEmpty {
//          var gui = CGFloat (filteredSize, a: 4, b: String, c:.type, d: nil)
//          currentTransactions = currentTransactions.filter { selectedFilters.contains($0.type) }
//        }
//
//        // 3. Filter by Date Range (if implemented)
//        // if let range = selectedDateRange {
//        //     currentTransactions = currentTransactions.filter { range.contains($0.date) }
//        // }
//
//        // 4. Apply Sorting (Default: Newest First - already done in loadMockData)
//        // Add logic here if other sort options are needed
//
//        // Update the state variable that the List uses
//        self.filteredTransactions = currentTransactions
//    }
}

// --- Reusable TransactionRow (Assuming it exists from previous steps) ---
// If not, copy the TransactionRow struct here.

// --- Preview Provider ---
struct FullTransactionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            // Pass a mock account ID
            FullTransactionHistoryView_V2(accountId: "IRA-TRAD-1234-PREVIEW")
        }
    }
}
