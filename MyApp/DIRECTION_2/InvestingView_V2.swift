////
////  InvestingView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//
//import SwiftUI
//
//// MARK: - Data Models
//
//struct CashDetails {
//    var totalBalance: Double = 8437.83
//    var interestAccruedThisMonth: Double = 0.90
//    var lifetimeInterestPaid: Double = 100.60
//    var cashEarningInterest: Double = 1090.77
//    var apyInfo: String = "4% APY with Gold"
//    var currencyFormatter: NumberFormatter = {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.locale = Locale(identifier: "en_US") // Or user's current locale
//        return formatter
//    }()
//
//    func formatted(_ value: Double) -> String {
//        currencyFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
//    }
//}
//
//struct CryptoAsset: Identifiable {
//    let id = UUID()
//    let symbol: String
//    let name: String // Added for detail view
//    let quantity: Double
//    let currentValuePerCoin: Double
//    let graphColor: Color
//
//    var totalValue: Double { quantity * currentValuePerCoin }
//    var formattedQuantity: String {
//        // Basic formatting, adjust as needed
//        String(format: "%.2f", quantity)
//    }
//}
//
//struct StockAsset: Identifiable {
//    let id = UUID()
//    let symbol: String
//    let name: String // Added for detail view
//    let shares: Double
//    let currentValuePerShare: Double
//    let graphColor: Color
//
//    var totalValue: Double { shares * currentValuePerShare }
//    var formattedShares: String {
//        String(format: "%.2f shares", shares)
//    }
//}
//
//// MARK: - ViewModel
//
//class PortfolioViewModel: ObservableObject {
//    @Published var cashDetails = CashDetails()
//    @Published var cryptoAssets: [CryptoAsset] = []
//    @Published var stockAssets: [StockAsset] = []
//
//    // Currency Formatter (shared instance)
//    let currencyFormatter: NumberFormatter = {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.locale = Locale(identifier: "en_US")
//        return formatter
//    }()
//
//    init() {
//        loadMockData()
//    }
//
//    func loadMockData() {
//        // Mock Cash (already initialized in property)
//
//        // Mock Crypto
//        cryptoAssets = [
//            CryptoAsset(symbol: "USDC", name: "USD Coin", quantity: 1090.77, currentValuePerCoin: 1.00, graphColor: .green),
//            CryptoAsset(symbol: "BTC", name: "Bitcoin", quantity: 0.05, currentValuePerCoin: 65000.00, graphColor: .orange),
//            CryptoAsset(symbol: "ETH", name: "Ethereum", quantity: 0.5, currentValuePerCoin: 3500.00, graphColor: .purple)
//        ]
//
//        // Mock Stocks
//        stockAssets = [
//            StockAsset(symbol: "REAL", name: "The RealReal, Inc.", shares: 250.45, currentValuePerShare: 4.76, graphColor: .red),
//            StockAsset(symbol: "XOM", name: "Exxon Mobil Corp.", shares: 4.59, currentValuePerShare: 98.78, graphColor: .blue),
//            StockAsset(symbol: "IRM", name: "Iron Mountain Inc.", shares: 4.85, currentValuePerShare: 76.46, graphColor: .green),
//             StockAsset(symbol: "AAPL", name: "Apple Inc.", shares: 10.0, currentValuePerShare: 175.50, graphColor: .gray)
//        ]
//
//        // Recalculate total balance based on mock data
//        recalculateTotalBalance()
//    }
//
//    func recalculateTotalBalance() {
//         let cryptoTotal = cryptoAssets.reduce(0) { $0 + $1.totalValue }
//         let stockTotal = stockAssets.reduce(0) { $0 + $1.totalValue }
//        // Assuming Cash balance should be part of the total 'Investing' value
//         // let cashTotal = cashDetails.cashEarningInterest // Or another relevant cash field
//        
//        // Let's assume the 'Investing' total *is* the sum of stocks and crypto for this example
//        // and the cash portion displayed is separate or managed differently.
//        // If cash earning interest *is* part of the investment total:
//         cashDetails.totalBalance = cryptoTotal + stockTotal // + cashDetails.cashEarningInterest
//    }
//    
//    func formattedCurrency(_ value: Double) -> String {
//        currencyFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
//    }
//}
//
//// MARK: - Main ContentView with TabView (Unchanged)
//
////struct InvestingView: View {
////    var body: some View {
////        TabView {
////            PortfolioView()
////                .tabItem {
////                    Label("Investing", systemImage: "chart.line.uptrend.xyaxis")
////                }
////                .tag(0)
////
////            // Placeholder for other tabs
////             Text("Explore Tab")
////                 .tabItem { Label("Explore", systemImage: "safari") }
////                 .tag(1)
////
////             Text("Transfer Tab")
////                 .tabItem { Label("Transfer", systemImage: "arrow.left.arrow.right.circle") }
////                 .tag(2)
////
////             Text("Profile Tab")
////                 .tabItem { Label("Profile", systemImage: "person.crop.circle") }
////                 .tag(3)
////        }
////        .accentColor(.black) // Matches screenshot selection color
////    }
////}
//
//// MARK: - Portfolio Tab Content View
////
////struct PortfolioView: View {
////    // Use @StateObject to create and manage the ViewModel instance
////    @StateObject var viewModel = PortfolioViewModel()
////    @State private var isShowingSearchView = false
////    @State private var isShowingNotificationsView = false
////
////    var body: some View {
////        // NavigationStack enables NavigationLinks within its hierarchy
////        NavigationStack {
////            ScrollView {
////                VStack(alignment: .leading, spacing: 25) { // Increased spacing
////                    TopBarView(
////                        totalBalance: viewModel.formattedCurrency(viewModel.cashDetails.totalBalance),
////                        showSearchView: $isShowingSearchView,
////                        showNotificationsView: $isShowingNotificationsView
////                    )
////
////                    CashSectionView(
////                        cashDetails: viewModel.cashDetails,
////                        formatter: viewModel.currencyFormatter
////                    )
////                    
////                    // Pass only the necessary data/formatter down
////                    CryptoSectionView(
////                        assets: viewModel.cryptoAssets,
////                        formatter: viewModel.currencyFormatter
////                    )
////                    
////                    StocksSectionView(
////                        assets: viewModel.stockAssets,
////                        formatter: viewModel.currencyFormatter
////                    )
////                }
////                .padding(.horizontal)
////            }
////             // Add a title to the navigation bar (optional, can be hidden)
////             // .navigationTitle("Portfolio")
////             // .navigationBarTitleDisplayMode(.inline)
////             .navigationBarHidden(true) // Keep custom top bar look
////             .sheet(isPresented: $isShowingSearchView) { SearchView() }
////             .sheet(isPresented: $isShowingNotificationsView) { NotificationsView() }
////        }
////    }
////}
//
//// MARK: - Top Bar View (Updated for Functionality)
//
//struct TopBarView: View {
//    let totalBalance: String
//    @Binding var showSearchView: Bool
//    @Binding var showNotificationsView: Bool
//     @State private var hasNotification = true // Mock state for badge
//
//    var body: some View {
//        HStack(alignment: .center) {
//            VStack(alignment: .leading) {
//                Text(totalBalance)
//                    .font(.largeTitle)
//                    .fontWeight(.medium)
//                Text("Investing")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//
//            Spacer()
//
//            HStack(spacing: 20) {
//                Image(systemName: "magnifyingglass")
//                    .font(.title2)
//                    .onTapGesture { showSearchView = true } // Show search sheet
//
//                Image(systemName: hasNotification ? "bell.fill" : "bell") // Dynamic icon
//                     .font(.title2)
//                     .overlay(
//                         Circle()
//                            .fill(Color.red)
//                            .frame(width: 8, height: 8)
//                            .offset(x: 7, y: -7)
//                            .opacity(hasNotification ? 1 : 0), // Show badge conditionally
//                         alignment: .topTrailing
//                     )
//                     .onTapGesture {
//                         showNotificationsView = true // Show notifications sheet
//                         hasNotification = false // Example: Mark as read
//                     }
//            }
//        }
//        .padding(.top)
//        .padding(.bottom, 10)
//    }
//}
//
//// MARK: - Cash Section View (Updated)
//
//struct CashSectionView: View {
//    let cashDetails: CashDetails
//    let formatter: NumberFormatter
//    @State private var isShowingDepositSheet = false
//    @State private var showApyInfoAlert = false
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            HStack {
//                Text("Cash")
//                    .font(.title)
//                    .fontWeight(.bold)
//                Image(systemName: "info.circle")
//                    .foregroundColor(.gray)
//                    // Add action for info icon
//                    .onTapGesture { showApyInfoAlert = true }
//                Spacer()
//                Text(cashDetails.apyInfo)
//                    .font(.caption)
//                    .fontWeight(.medium)
//                    .padding(.vertical, 4)
//                    .padding(.horizontal, 8)
//                    .background(Color.gray.opacity(0.2))
//                    .cornerRadius(10)
//                    .onTapGesture { showApyInfoAlert = true } // Make APY badge tappable too
//            }
//
////            InterestRowView(label: "Interest accrued this month", value: cashDetails.formatted(cashDetails.interestAccruedThisMonth))
//            Divider()
////            InterestRowView(label: "Lifetime interest paid", value: cashDetails.formatted(cashDetails.lifetimeInterestPaid))
//            Divider()
//            // Assuming question mark is specific to this row
////            InterestRowView(label: "Cash earning interest", value: cashDetails.formatted(cashDetails.cashEarningInterest), showInfoIcon: true)
//            Divider()
//
//            Button("Deposit cash") {
//                isShowingDepositSheet = true // Trigger the sheet presentation
//            }
//            .font(.headline)
//            .foregroundColor(.orange) // Use accent color or specific brand color
//        }
//        // Sheet modifier for deposit action
//        .sheet(isPresented: $isShowingDepositSheet) {
////            DepositView(cashBalance: cashDetails.formatted(cashDetails.cashEarningInterest))
//        }
//        // Alert modifier for APY info
//        .alert("APY Information", isPresented: $showApyInfoAlert) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text("Interest rates and APY are subject to change. \(cashDetails.apyInfo). Certain conditions may apply.")
//        }
//    }
//}
//
//
//// MARK: - Crypto Section View (Updated for Navigation)
//
//
//// MARK: - Stocks & ETFs Section View (Updated for Navigation)
//
////struct StocksSectionView: View {
////    let assets: [StockAsset]
////    let formatter: NumberFormatter
////
////    var body: some View {
////        VStack(alignment: .leading, spacing: 8) {
////             // Make the header tappable
////            NavigationLink(destination: StockListView(assets: assets, formatter: formatter)) {
////                 HStack {
////                     Text("Stocks & ETFs")
////                         .font(.title)
////                         .fontWeight(.bold)
////                     Image(systemName: "chevron.right")
////                         .font(.caption)
////                         .fontWeight(.bold)
////                         .foregroundColor(.gray)
////                     Spacer()
////                 }
////                  .contentShape(Rectangle())
////            }
////             .buttonStyle(.plain)
////            .padding(.bottom, 5)
////
////            VStack(spacing: 0) {
////                 // Display all stocks or a subset
////                ForEach(assets) { asset in
////                     // Each row is navigable
////                    NavigationLink(destination: AssetDetailView(assetSymbol: asset.symbol, assetName: asset.name)) {
////                         StockRowView(stock: asset, formatter: formatter)
////                     }
////                     .buttonStyle(.plain)
////                     Divider()
////                 }
////            }
////        }
////    }
////}
//
//
//// MARK: - Reusable Row Views (Updated for Models and Formatting)
////
////struct InterestRowView: View {
////    let label: String
////    let value: String
////    var showInfoIcon: Bool = false
////    @State private var showRowInfoAlert = false
////
////    var body: some View {
////        HStack {
////            HStack(spacing: 5) {
////                Text(label)
////                    .font(.subheadline)
////                if showInfoIcon {
////                    Image(systemName: "questionmark.circle")
////                        .foregroundColor(.gray)
////                        .font(.caption)
////                        .onTapGesture { showRowInfoAlert = true } // Tappable info icon
////                }
////            }
////            Spacer()
////            Text
