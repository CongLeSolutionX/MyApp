////
////  TransactionDetailView.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//// --- Additions/Modifications to Transaction struct (in the file with TransactionHistoryView) ---
//import CoreLocation // Add this import for coordinates
//
//struct Transaction: Decodable, Identifiable, Hashable {
//    let id = UUID()
//    let merchantName: String
//    let amount: Double
//    let currencyCode: String // e.g., "USD"
//    let date: Date
////    let status: TransactionStatus
//    let category: String // e.g., "Shopping", "Food & Drink"
//    let logoSystemName: String // SF Symbol name for merchant/category representation
//
//    // --- New Optional Fields for Detail View ---
//    let transactionID: String? // For support reference
//    let cardLastFour: String? // e.g., "4242"
//    let location: CLLocationCoordinate2D? // Optional location data
//
//    // Existing computed properties (formattedAmount, amountColor) remain the same...
//    // ...
//}
//
//// Implement Hashable for CLLocationCoordinate2D if needed (often needed for Identifiable conformance in SwiftUI if used directly in ForEach, though not strictly needed here as it's just data passed)
//extension CLLocationCoordinate2D: @retroactive Equatable {}
//extension CLLocationCoordinate2D: @retroactive Hashable {
//    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
//        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
//    }
//
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(latitude)
//        hasher.combine(longitude)
//    }
//}
//
//// --- Updated Mock Data Generation (in TransactionHistoryView) ---
//extension TransactionHistoryView { // Or wherever mockTransactions is defined
//    static var mockTransactions: [Transaction] {
//        let now = Date()
//        let calendar = Calendar.current
//
//        return [
//            // Add new fields to some transactions
//            Transaction(merchantName: "Blue Bottle Coffee", amount: -5.75, currencyCode: "USD", date: calendar.date(byAdding: .hour, value: -2, to: now)!, status: .completed, category: "Food & Drink", logoSystemName: "cup.and.saucer.fill",
//                          transactionID: "txn_1MAbcdeFG12345", cardLastFour: "1234", location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)), // SF Location
//            Transaction(merchantName: "Amazon Marketplace", amount: -35.99, currencyCode: "USD", date: calendar.date(byAdding: .day, value: -1, to: now)!, status: .completed, category: "Shopping", logoSystemName: "cart.fill",
//                          transactionID: "txn_2MAbcdeFG67890", cardLastFour: "1234", location: nil), // No Location
//            Transaction(merchantName: "Spotify Premium", amount: -10.99, currencyCode: "USD", date: calendar.date(byAdding: .day, value: -2, to: now)!, status: .completed, category: "Entertainment", logoSystemName: "music.note",
//                         transactionID: "txn_3MAbcdeFG11223", cardLastFour: "5678", location: nil),
//            Transaction(merchantName: "Whole Foods Market", amount: -78.43, currencyCode: "USD", date: calendar.date(byAdding: .day, value: -2, to: now)!, status: .pending, category: "Groceries", logoSystemName: "carrot.fill",
//                         transactionID: "txn_4MAbcdeFG44556", cardLastFour: "1234", location: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)), // NYC Location
//             Transaction(merchantName: "Uber Trip", amount: -15.20, currencyCode: "USD", date: calendar.date(byAdding: .day, value: -3, to: now)!, status: .completed, category: "Transport", logoSystemName: "car.fill",
//                          transactionID: "txn_5MAbcdeFG77889", cardLastFour: "5678", location: nil),
//             Transaction(merchantName: "Refund from ASOS", amount: 45.00, currencyCode: "USD", date: calendar.date(byAdding: .day, value: -4, to: now)!, status: .refunded, category: "Shopping", logoSystemName: "arrow.uturn.backward.circle.fill",
//                          transactionID: "txn_6MAbcdeFG99001", cardLastFour: "1234", location: nil),
//             Transaction(merchantName: "Restaurant Payment", amount: -55.00, currencyCode: "USD", date: calendar.date(byAdding: .day, value: -5, to: now)!, status: .failed, category: "Food & Drink", logoSystemName: "fork.knife.circle.fill",
//                          transactionID: "txn_7MAbcdeFG22334", cardLastFour: "5678", location: nil), // Failed
//            Transaction(merchantName: "Apple Store", amount: -1200.00, currencyCode: "USD", date: calendar.date(byAdding: .day, value: -6, to: now)!, status: .completed, category: "Electronics", logoSystemName: "apple.logo",
//                         transactionID: "txn_8MAbcdeFG55667", cardLastFour: "1234", location: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0091)) // Cupertino Location
//
//        ].sorted { $0.date > $1.date }
//    }
//}
//
//import SwiftUI
//import MapKit // Import for map view
//
//// --- Reusable Row for Detail Items ---
//struct DetailRow: View {
//    let label: String
//    let value: String
//    var valueColor: Color = .primary // Default text color
//    var systemImageName: String? = nil // Optional icon
//
//    var body: some View {
//        HStack {
//            if let systemImageName = systemImageName {
//                Image(systemName: systemImageName)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .frame(width: 20, alignment: .center) // Align icons
//            } else {
//                 Spacer().frame(width: 20) // Keep alignment if no icon
//            }
//
//            Text(label)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//            Spacer()
//            Text(value)
//                .font(.subheadline)
//                .fontWeight(.medium)
//                .foregroundColor(valueColor)
//                .multilineTextAlignment(.trailing)
//                .lineLimit(1) // Prevent wrapping for simple values
//        }
//        .padding(.vertical, 6)
//    }
//}
//
//// --- Main Transaction Detail View ---
//struct TransactionDetailView: View {
//    let transaction: Transaction
//
//    // State for Map Annotation Item
//    // Use a simple struct that conforms to Identifiable for map annotations
//    struct LocationPin: Identifiable {
//        let id = UUID()
//        let coordinate: CLLocationCoordinate2D
//    }
//    @State private var mapRegion: MKCoordinateRegion? = nil
//    @State private var annotationItems: [LocationPin] = []
//
//    private static var dateTimeFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .long // e.g., September 19, 2023
//        formatter.timeStyle = .short // e.g., 10:30 AM
//        return formatter
//    }()
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 0) {
//
//                // --- Header Section (Merchant & Amount) ---
//                VStack(spacing: 8) {
//                    Image(systemName: transaction.logoSystemName)
//                        .font(.system(size: 40))
//                        .foregroundColor(Color.rhGold) // Use accent color or derive from category
//                        .padding(15)
//                        .background(Color.gray.opacity(0.1))
//                        .clipShape(Circle())
//
//                    Text(transaction.merchantName)
//                         .font(.title2)
//                         .fontWeight(.semibold)
//                         .multilineTextAlignment(.center)
//                         .padding(.horizontal)
//
//                    Text(transaction.formattedAmount)
//                        .font(.system(size: 34, weight: .bold))
//                        .foregroundColor(transaction.amountColor)
//
//                    // Display status prominently if not completed
//                    if transaction.status != .completed {
//                        Text(transaction.status.rawValue)
//                            .font(.headline)
//                            .fontWeight(.medium)
//                            .foregroundColor(transaction.status.displayColor)
//                            .padding(.horizontal, 12)
//                            .padding(.vertical, 5)
//                            .background(transaction.status.displayColor.opacity(0.15))
//                            .clipShape(Capsule())
//                            .padding(.top, 5)
//                    }
//                }
//                .frame(maxWidth: .infinity)
//                .padding(.vertical, 25)
//                .background(Color.rhBeige) // Or a slightly different shade for emphasis
//
//                 Divider().padding(.horizontal)
//
//                // --- Details Section ---
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("Details")
//                         .font(.headline)
//                         .padding(.bottom, 5)
//
//                    DetailRow(label: "Date & Time", value: transaction.date, formatter: Self.dateTimeFormatter, systemImageName: "calendar")
//                    DetailRow(label: "Status", value: transaction.status.rawValue, valueColor: transaction.status.displayColor, systemImageName: "checkmark.circle.fill") // Use status color
//                    DetailRow(label: "Category", value: transaction.category, systemImageName: "tag.fill")
//
//                    if let card = transaction.cardLastFour {
//                        DetailRow(label: "Card Used", value: "**** \(card)", systemImageName: "creditcard.fill")
//                    }
//
//                    if let txID = transaction.transactionID {
//                         DetailRow(label: "Transaction ID", value: txID, systemImageName: "number.square.fill")
//                              .lineLimit(1) // Ensure ID doesn't wrap excessively
//                              .truncationMode(.middle) // Truncate if too long
//                    }
//                }
//                .padding()
//                .background(Color.rhBeige)
//
//                // --- Map Section (Conditional) ---
//                if let location = transaction.location, mapRegion != nil {
//                    Divider().padding(.horizontal)
//                    VStack(alignment: .leading) {
//                        Text("Location")
//                            .font(.headline)
//                            .padding([.top, .horizontal])
//                            .padding(.bottom, 5)
//
//                        // Use Map directly
//                         Map(coordinateRegion: Binding(get: { mapRegion! }, set: { mapRegion = $0 }),
//                              annotationItems: annotationItems) { item in
//                             // MapMarker(coordinate: item.coordinate, tint: Color.rhGold) // Simple marker
//                             MapAnnotation(coordinate: item.coordinate) { // Custom annotation view
//                                 Image(systemName: "mappin.circle.fill")
//                                     .font(.title)
//                                     .foregroundColor(.red)
//                                     .background(Color.white.opacity(0.7))
//                                      .clipShape(Circle())
//                             }
//                         }
//                         .frame(height: 200)
//                         .clipShape(RoundedRectangle(cornerRadius: 10))
//                         .padding(.horizontal)
//                         .padding(.bottom)
//                    }
//                      .background(Color.rhBeige) // Keep background consistent
//                }
//
//                 Divider().padding(.horizontal)
//
//                // --- Actions Section ---
//                VStack(spacing: 0) {
//                     Button {
//                         // Action to report issue
//                         print("Report Issue tapped for transaction: \(transaction.id)")
//                         // Show alert, navigate to support flow, etc.
//                    } label: {
//                        HStack {
//                            Image(systemName: "exclamationmark.bubble.fill")
//                            Text("Report an Issue")
//                            Spacer()
//                             Image(systemName: "chevron.right")
//                        }
//                        .foregroundColor(.primary) // Or .red for emphasis
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                         // .background(Color.rhBeige) // Keep consistent
//                    }
//
//                    Divider().padding(.leading) // Indent divider slightly
//
//                     Button {
//                         // Action to add note or tag
//                         print("Add Note tapped for transaction: \(transaction.id)")
//                     } label: {
//                         HStack {
//                            Image(systemName: "note.text.badge.plus")
//                            Text("Add Note / Tag")
//                            Spacer()
//                             Image(systemName: "chevron.right")
//                        }
//                        .foregroundColor(.primary)
//                         .padding()
//                        .frame(maxWidth: .infinity)
//                        // .background(Color.rhBeige) // Keep consistent
//                     }
//                     // Add more actions like "View Receipt", "Split Bill" etc.
//                 }
//                 .background(Color(uiColor: .secondarySystemBackground) // Slightly different background for actions section
//                     .clipShape(RoundedRectangle(cornerRadius: 10))
//                       .padding(.horizontal)
//                       .padding(.top) // Add some space before actions
//                 )
//
//                 Spacer(minLength: 20) // Give some space at the bottom
//
//            }
//        }
//          .background(Color.rhBeige.ignoresSafeArea()) // Ensure entire scrollable area has background
//          .navigationTitle("Transaction Details")
//          .navigationBarTitleDisplayMode(.inline) // Keep it concise
//          .onAppear(perform: setupMapRegion) // Setup map when view appears
//          .accentColor(Color.rhGold) // Ensure back button, etc., use accent
//    }
//
//    // --- Helper Function to Setup Map ---
//    private func setupMapRegion() {
//        if let location = transaction.location {
//            mapRegion = MKCoordinateRegion(
//                center: location,
//                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // Zoom level
//            )
//             annotationItems = [LocationPin(coordinate: location)] // Set the pin
//        } else {
//            mapRegion = nil // Explicitly set to nil if no location
//              annotationItems = []
//        }
//    }
//}
//
//// --- Previews ---
//struct TransactionDetailView_Previews: PreviewProvider {
//    // Helper to get a specific mock transaction for previewing easily
//    static func getMockTransaction(status: TransactionStatus = .completed, withLocation: Bool = true) -> Transaction {
//        let base = TransactionHistoryView.mockTransactions.first { tx in
//            (withLocation ? tx.location != nil : tx.location == nil) &&
//              (status == .completed ? tx.status == .completed || tx.status == .refunded || tx.status == .failed : tx.status == status) // Find one matching roughly
//        }
//        // Fallback if specific type not found
//        return base ?? TransactionHistoryView.mockTransactions[0]
//    }
//
//    static var previews: some View {
//        NavigationView { // Embed in NavigationView for preview title
//            TransactionDetailView(transaction: getMockTransaction(status: .completed, withLocation: true))
//                 .preferredColorScheme(.light)
//                 .previewDisplayName("Completed w/ Location")
//        }
//
//        NavigationView {
//            TransactionDetailView(transaction: getMockTransaction(status: .pending, withLocation: false))
//                .preferredColorScheme(.light)
//                .previewDisplayName("Pending w/o Location")
//        }
//
//         NavigationView {
//            TransactionDetailView(transaction: getMockTransaction(status: .refunded, withLocation: false))
//                .preferredColorScheme(.light)
//                .previewDisplayName("Refunded")
//        }
//
//          NavigationView {
//            TransactionDetailView(transaction: getMockTransaction(status: .failed, withLocation: true))
//                .preferredColorScheme(.light)
//                .previewDisplayName("Failed w/ Location")
//         }
//    }
//}
//
//// Assume rhBeige and rhGold are defined elsewhere
//// extension Color { ... }
