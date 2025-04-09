//
//import SwiftUI
//
//// MARK: - Data Models (Assume these are defined as in the previous response)
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
//        formatter.locale = Locale(identifier: "en_US")
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
//    let name: String
//    let quantity: Double
//    let currentValuePerCoin: Double
//    let graphColor: Color
//
//    var totalValue: Double { quantity * currentValuePerCoin }
//    var formattedQuantity: String { String(format: "%.2f", quantity) }
//}
//
//struct StockAsset: Identifiable {
//    let id = UUID()
//    let symbol: String
//    let name: String
//    let shares: Double
//    let currentValuePerShare: Double
//    let graphColor: Color
//
//    var totalValue: Double { shares * currentValuePerShare }
//    var formattedShares: String { String(format: "%.2f shares", shares) }
//}
//
//// MARK: - ViewModel (Assume this is defined as in the previous response)
//
//class PortfolioViewModel: ObservableObject {
//    @Published var cashDetails = CashDetails()
//    @Published var cryptoAssets: [CryptoAsset] = []
//    @Published var stockAssets: [StockAsset] = []
//
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
//        cryptoAssets = [
//            CryptoAsset(symbol: "USDC", name: "USD Coin", quantity: 1090.77, currentValuePerCoin: 1.00, graphColor: .green),
//            CryptoAsset(symbol: "BTC", name: "Bitcoin", quantity: 0.05, currentValuePerCoin: 65000.00, graphColor: .orange),
//            CryptoAsset(symbol: "ETH", name: "Ethereum", quantity: 0.5, currentValuePerCoin: 3500.00, graphColor: .purple)
//        ]
//        stockAssets = [
//            StockAsset(symbol: "REAL", name: "The RealReal, Inc.", shares: 250.45, currentValuePerShare: 4.76, graphColor: .red),
//            StockAsset(symbol: "XOM", name: "Exxon Mobil Corp.", shares: 4.59, currentValuePerShare: 98.78, graphColor: .blue),
//            StockAsset(symbol: "IRM", name: "Iron Mountain Inc.", shares: 4.85, currentValuePerShare: 76.46, graphColor: .green),
//             StockAsset(symbol: "AAPL", name: "Apple Inc.", shares: 10.0, currentValuePerShare: 175.50, graphColor: .gray)
//        ]
//        recalculateTotalBalance()
//    }
//
//    func recalculateTotalBalance() {
//         let cryptoTotal = cryptoAssets.reduce(0) { $0 + $1.totalValue }
//         let stockTotal = stockAssets.reduce(0) { $0 + $1.totalValue }
//         cashDetails.totalBalance = cryptoTotal + stockTotal
//    }
//
//    func formattedCurrency(_ value: Double) -> String {
//        currencyFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
//    }
//}
//
//// MARK: - Main ContentView & PortfolioView (Assume these are defined as in previous response)
//struct InvestingView: View {
//    var body: some View {
//        TabView {
//            PortfolioView()
//                .tabItem { Label("Investing", systemImage: "chart.line.uptrend.xyaxis") }
//                .tag(0)
//             Text("Explore Tab").tabItem { Label("Explore", systemImage: "safari") }.tag(1)
//             Text("Transfer Tab").tabItem { Label("Transfer", systemImage: "arrow.left.arrow.right.circle") }.tag(2)
//             Text("Profile Tab").tabItem { Label("Profile", systemImage: "person.crop.circle") }.tag(3)
//        }
//        .accentColor(.black)
//    }
//}
//
//struct PortfolioView: View {
//    @StateObject var viewModel = PortfolioViewModel()
//    @State private var isShowingSearchView = false
//    @State private var isShowingNotificationsView = false
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 25) {
//                    TopBarView(
//                        totalBalance: viewModel.formattedCurrency(viewModel.cashDetails.totalBalance),
//                        showSearchView: $isShowingSearchView,
//                        showNotificationsView: $isShowingNotificationsView
//                    )
//                    CashSectionView(
//                        cashDetails: viewModel.cashDetails,
//                        formatter: viewModel.currencyFormatter
//                    )
//                    CryptoSectionView(
//                        assets: viewModel.cryptoAssets,
//                        formatter: viewModel.currencyFormatter
//                    )
//                    StocksSectionView(
//                        assets: viewModel.stockAssets,
//                        formatter: viewModel.currencyFormatter
//                    )
//                }
//                .padding(.horizontal)
//            }
//             .navigationBarHidden(true)
//             .sheet(isPresented: $isShowingSearchView) { SearchView() }
//             .sheet(isPresented: $isShowingNotificationsView) { NotificationsView() }
//        }
//    }
//}
//
//// MARK: - TopBarView & Section Views (Assume these are defined as in previous response)
//
//struct TopBarView: View {
//    let totalBalance: String
//    @Binding var showSearchView: Bool
//    @Binding var showNotificationsView: Bool
//     @State private var hasNotification = true
//
//    var body: some View {
//        HStack(alignment: .center) {
//            VStack(alignment: .leading) {
//                Text(totalBalance).font(.largeTitle).fontWeight(.medium)
//                Text("Investing").font(.caption).foregroundColor(.secondary)
//            }
//            Spacer()
//            HStack(spacing: 20) {
//                Image(systemName: "magnifyingglass").font(.title2)
//                    .onTapGesture { showSearchView = true }
//                Image(systemName: hasNotification ? "bell.fill" : "bell").font(.title2)
//                     .overlay(
//                         Circle().fill(Color.red).frame(width: 8, height: 8)
//                            .offset(x: 7, y: -7).opacity(hasNotification ? 1 : 0),
//                         alignment: .topTrailing
//                     )
//                     .onTapGesture {
//                         showNotificationsView = true
//                         hasNotification = false
//                     }
//            }
//        }
//        .padding(.top).padding(.bottom, 10)
//    }
//}
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
//                Text("Cash").font(.title).fontWeight(.bold)
//                Image(systemName: "info.circle").foregroundColor(.gray)
//                    .onTapGesture { showApyInfoAlert = true }
//                Spacer()
//                Text(cashDetails.apyInfo).font(.caption).fontWeight(.medium)
//                    .padding(.vertical, 4).padding(.horizontal, 8)
//                    .background(Color.gray.opacity(0.2)).cornerRadius(10)
//                    .onTapGesture { showApyInfoAlert = true }
//            }
//            InterestRowView(label: "Interest accrued this month", value: cashDetails.formatted(cashDetails.interestAccruedThisMonth))
//            Divider()
//            InterestRowView(label: "Lifetime interest paid", value: cashDetails.formatted(cashDetails.lifetimeInterestPaid))
//            Divider()
//            InterestRowView(label: "Cash earning interest", value: cashDetails.formatted(cashDetails.cashEarningInterest), showInfoIcon: true)
//            Divider()
//            Button("Deposit cash") { isShowingDepositSheet = true }
//            .font(.headline).foregroundColor(.orange)
//        }
//        .sheet(isPresented: $isShowingDepositSheet) {
//            DepositView(cashBalance: cashDetails.formatted(cashDetails.cashEarningInterest))
//        }
//        .alert("APY Information", isPresented: $showApyInfoAlert) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text("Interest rates and APY are subject to change. \(cashDetails.apyInfo). Certain conditions may apply.")
//        }
//    }
//}
//
//struct CryptoSectionView: View {
//    let assets: [CryptoAsset]
//    let formatter: NumberFormatter
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            NavigationLink(destination: CryptoListView(assets: assets, formatter: formatter)) {
//                 HStack {
//                     Text("Crypto").font(.title).fontWeight(.bold)
//                     Image(systemName: "chevron.right").font(.caption).fontWeight(.bold).foregroundColor(.gray)
//                     Spacer()
//                 }.contentShape(Rectangle())
//            }.buttonStyle(.plain)
//            HStack {
//                Text("Offered by Robinhood Crypto").font(.caption).foregroundColor(.secondary)
//                Image(systemName: "info.circle").foregroundColor(.gray)
//            }.padding(.bottom, 5)
//            VStack(spacing: 0) {
//                 ForEach(assets.prefix(3)) { asset in
//                     NavigationLink(destination: AssetDetailView(assetSymbol: asset.symbol, assetName: asset.name)) {
//                         CryptoRowView(asset: asset, formatter: formatter)
//                     }.buttonStyle(.plain)
//                     Divider()
//                 }
//            }
//        }
//    }
//}
//
//struct StocksSectionView: View {
//    let assets: [StockAsset]
//    let formatter: NumberFormatter
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            NavigationLink(destination: StockListView(assets: assets, formatter: formatter)) {
//                 HStack {
//                     Text("Stocks & ETFs").font(.title).fontWeight(.bold)
//                     Image(systemName: "chevron.right").font(.caption).fontWeight(.bold).foregroundColor(.gray)
//                     Spacer()
//                 }.contentShape(Rectangle())
//            }.buttonStyle(.plain)
//            .padding(.bottom, 5)
//            VStack(spacing: 0) {
//                ForEach(assets) { asset in
//                    NavigationLink(destination: AssetDetailView(assetSymbol: asset.symbol, assetName: asset.name)) {
//                         StockRowView(stock: asset, formatter: formatter)
//                     }.buttonStyle(.plain)
//                     Divider()
//                 }
//            }
//        }
//    }
//}
//
//// MARK: - Reusable Row Views (Continued & Updated)
//
//struct InterestRowView: View {
//    let label: String
//    let value: String
//    var showInfoIcon: Bool = false
//    @State private var showRowInfoAlert = false // State for the alert specific to this row type
//
//    var body: some View {
//        HStack {
//            HStack(spacing: 5) {
//                Text(label)
//                    .font(.subheadline)
//                if showInfoIcon {
//                    Image(systemName: "questionmark.circle")
//                        .foregroundColor(.gray)
//                        .font(.caption)
//                        .onTapGesture { showRowInfoAlert = true } // Trigger the specific alert
//                }
//            }
//            Spacer()
//            Text(value)
//                .font(.subheadline)
//                .fontWeight(.medium)
//        }
//        .padding(.vertical, 4)
//        // Alert specifically for the question mark icon in this row type
//        .alert("Information", isPresented: $showRowInfoAlert) {
//            Button("OK", role: .cancel) {}
//        } message: {
//            // Provide context-specific information based on the label
//            if label == "Cash earning interest" {
//                Text("This is the portion of your cash balance currently eligible for interest.")
//            } else {
//                Text("More details about '\(label)'.") // Generic fallback
//            }
//        }
//    }
//}
//
//struct CryptoRowView: View {
//    let asset: CryptoAsset
//    let formatter: NumberFormatter // Use the shared formatter
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text(asset.symbol)
//                    .font(.headline)
//                Text(asset.formattedQuantity) // Use formatted quantity
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//
//            Spacer()
//
//             // Placeholder for tiny graph (can be customized further)
//            Rectangle()
//                .fill(asset.graphColor.opacity(0.5)) // Slightly transparent fill
//                .frame(width: 40, height: 20) // Make it a bit taller
//                .overlay(StockSparklinePlaceholder(color: asset.graphColor).clipped()) // Use placeholder
//                .cornerRadius(4)
//                .padding(.horizontal)
//
//            Spacer()
//
//            // Display formatted total value
//            Text(formatter.string(from: NSNumber(value: asset.totalValue)) ?? "$0.00")
//                 .font(.footnote)
//                 .fontWeight(.bold)
//                 .foregroundColor(.white) // White text for contrast
//                 .padding(.vertical, 5)
//                 .padding(.horizontal, 10)
//                 .background(asset.graphColor) // Use asset's color for background
//                 .clipShape(Capsule()) // Rounded capsule look
//                 .frame(minWidth: 70, alignment: .trailing) // Ensure minimum width, align right
//        }
//         .padding(.vertical, 8)
//    }
//}
//
//struct StockRowView: View {
//    let stock: StockAsset
//    let formatter: NumberFormatter // Use the shared formatter
//
//    var body: some View {
//        HStack(spacing: 15) {
//            VStack(alignment: .leading) {
//                Text(stock.symbol)
//                    .font(.headline)
//                Text(stock.formattedShares) // Use formatted shares
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//
//            Spacer()
//
//            StockSparklinePlaceholder(color: stock.graphColor)
//                 .frame(width: 60, height: 30)
//
//            Spacer()
//
//             // Display formatted total value
//            Text(formatter.string(from: NSNumber(value: stock.totalValue)) ?? "$0.00")
//                 .font(.footnote)
//                 .fontWeight(.bold)
//                 .foregroundColor(.white)
//                 .padding(.vertical, 5)
//                 .padding(.horizontal, 10)
//                 .background(stock.graphColor)
//                 .clipShape(Capsule())
//                 .frame(minWidth: 70, alignment: .trailing)
//        }
//         .padding(.vertical, 8)
//    }
//}
//
//// MARK: - Placeholder Views
//
//// Placeholder for Sparkline (from previous response, slightly enhanced)
//struct StockSparklinePlaceholder: View {
//    let color: Color
//    // Simple mock data points for the sparkline shape
//    private let points: [CGFloat] = [15, 20, 10, 15, 5, 25, 20]
//
//    var body: some View {
//        GeometryReader { geometry in
//            Path { path in
//                let stepX = geometry.size.width / CGFloat(points.count - 1)
//                let maxY = points.max() ?? 30 // Use max point or default
//                let minY = points.min() ?? 0   // Use min point or default
//                let scaleY = (geometry.size.height - 4) / max(1, (maxY - minY)) // Avoid division by zero, add padding
//
//                // Start path
//                path.move(to: CGPoint(x: 0, y: geometry.size.height - ((points[0] - minY) * scaleY) - 2))
//
//                // Add lines for other points
//                for i in 1..<points.count {
//                    path.addLine(to: CGPoint(x: CGFloat(i) * stepX, y: geometry.size.height - ((points[i] - minY) * scaleY) - 2))
//                }
//            }
//            .stroke(color, lineWidth: 1.5)
//            .overlay( // Optional baseline
//                 Path { path in
//                     path.move(to: CGPoint(x: 0, y: geometry.size.height - ((points[0] - minY) * scaleY) - 2)) // Start at first point's y
//                     path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height - ((points[0] - minY) * scaleY) - 2))
//                 }
//                 .stroke(Color.gray.opacity(0.4), style: StrokeStyle(lineWidth: 0.5, dash: [2]))
//            )
//        }
//    }
//}
//
//// --- Placeholder Views for Navigation and Sheets ---
//
//struct SearchView: View {
//    @Environment(\.dismiss) var dismiss
//    @State private var searchText = ""
//
//    var body: some View {
//        NavigationView { // Embed in NavigationView for title and potential bar items
//            List {
//                Text("Search functionality placeholder.")
//                Text("You could search for stocks, crypto, etc.")
//                                    // Add search results simulation here
//            }
//            .searchable(text: $searchText, prompt: "Search Stocks, Crypto...")
//            .navigationTitle("Search")
//            .navigationBarItems(trailing: Button("Done") { dismiss() })
//        }
//    }
//}
//
//struct NotificationsView: View {
//    @Environment(\.dismiss) var dismiss
//
//    var body: some View {
//        NavigationView {
//            List {
//                Text("Notification 1: AAPL price alert triggered.")
//                Text("Notification 2: Deposit confirmed.")
//                Text("Notification 3: Upcoming earnings report for XOM.")
//            }
//            .navigationTitle("Notifications")
//            .navigationBarItems(trailing: Button("Done") { dismiss() })
//        }
//    }
//}
//
//struct DepositView: View {
//    @Environment(\.dismiss) var dismiss
//    let cashBalance: String
//    @State private var depositAmount: String = ""
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section("Current Balance") {
//                    Text(cashBalance)
//                }
//                Section("Deposit Amount") {
//                    TextField("Amount", text: $depositAmount)
//                        .keyboardType(.decimalPad)
//                }
//                Button("Submit Deposit") {
//                    // TODO: Add deposit logic
//                    print("Depositing \(depositAmount)")
//                    dismiss() // Close the sheet after action
//                }
//            }
//            .navigationTitle("Deposit Cash")
//            .navigationBarItems(leading: Button("Cancel") { dismiss() })
//        }
//    }
//}
//
//struct StockListView: View {
//    let assets: [StockAsset]
//    let formatter: NumberFormatter
//
//    var body: some View {
//        List {
//            ForEach(assets) { asset in
//                NavigationLink(destination: AssetDetailView(assetSymbol: asset.symbol, assetName: asset.name)) {
//                    // Use the same row view for consistency
//                    StockRowView(stock: asset, formatter: formatter)
//                }
//            }
//        }
//        .navigationTitle("Stocks & ETFs")
//         .listStyle(.plain) // Use plain style for better look
//    }
//}
//
//struct CryptoListView: View {
//    let assets: [CryptoAsset]
//    let formatter: NumberFormatter
//
//    var body: some View {
//        List {
//            ForEach(assets) { asset in
//                 NavigationLink(destination: AssetDetailView(assetSymbol: asset.symbol, assetName: asset.name)) {
//                    CryptoRowView(asset: asset, formatter: formatter)
//                }
//            }
//        }
//        .navigationTitle("Cryptocurrencies")
//        .listStyle(.plain)
//    }
//}
//
//// Generic detail view placeholder
//struct AssetDetailView: View {
//    let assetSymbol: String
//    let assetName: String
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text(assetSymbol)
//                .font(.largeTitle)
//                .fontWeight(.bold)
//            Text(assetName)
//                .font(.title2)
//                .foregroundColor(.secondary)
//
//            // Placeholder for graph, news, buy/sell buttons etc.
//            Rectangle()
//                .fill(Color.gray.opacity(0.1))
//                .frame(height: 200)
//                .overlay(Text("Detailed Graph Placeholder"))
//                .cornerRadius(10)
//
//            HStack {
//                Button("Buy") { /* Add buy action */ }
//                    .buttonStyle(.borderedProminent)
//                    .tint(.green)
//                Button("Sell") { /* Add sell action */ }
//                    .buttonStyle(.borderedProminent)
//                    .tint(.red)
//            }
//            
//            List {
//                 Text("Recent News Placeholder 1")
//                 Text("Performance Data Placeholder")
//                 Text("About \(assetName) Placeholder")
//            }
//           
//
//            Spacer()
//        }
//        .padding()
//        .navigationTitle(assetSymbol) // Show symbol in nav bar
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    InvestingView()
//        // Optionally inject view model for preview if needed elsewhere
//        .environmentObject(PortfolioViewModel())
//}
