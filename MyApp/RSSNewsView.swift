////
////  RssNewsView.swift
////  MyApp
////
////  Created by Cong Le on 4/3/25.
////
//
////
////  NewsView.swift
////  MyApp
////
////  Created by Cong Le on 4/3/25.
////
//
//import SwiftUI
//import Foundation // Needed for URL, Date
//
//// --- Data Model ---
//
//struct HSRNotice: Identifiable, Hashable {
//    let id: String // Use transactionNumber or guid for uniqueness
//    let title: String
//    let link: URL?
//    let transactionNumber: String
//    let acquiringParty: String
//    let acquiredParty: String
//    let grantingStatus: String
//    let acquiredEntities: [String]
//    let noticeDate: Date? // Date from description
//    let publicationDate: Date? // Date from pubDate
//    let creator: String
//    let guid: String
//
//    // Custom initializer if parsing logic were here
//    // init(from rssItem: RssItem) { ... parsing logic ... }
//
//    // Sample data generation for preview/design
//    static func sampleData() -> [HSRNotice] {
//        // NOTE: Dates are manually created for this example.
//        // In a real app, you'd parse them from the XML/HTML.
//        let dateFormatter = ISO8601DateFormatter()
//        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Adjust based on actual format if needed
//
//        let noticeDateFormatter = DateFormatter()
//        noticeDateFormatter.dateFormat = "MMMM d, yyyy" // Example format
//
//        return [
//            HSRNotice(
//                id: "20251002",
//                title: "20251002: Quartz Fibre pvt Ltd.; Owens Corning",
//                link: URL(string: "https://www.ftc.gov/legal-library/browse/early-termination-notices/20251002"),
//                transactionNumber: "20251002",
//                acquiringParty: "Quartz Fibre pvt Ltd.",
//                acquiredParty: "Owens Corning",
//                grantingStatus: "Granted",
//                acquiredEntities: [
//                    "Owens Corning Composite Materials Canada GP Inc",
//                    "Owens Corning Composite Materials, LLC",
//                    "OCV Italia Srl",
//                    "Owens-Corning (India) Private Limited",
//                    "OCV Chambery France"
//                ],
//                noticeDate: noticeDateFormatter.date(from: "March 31, 2025"),
//                publicationDate: dateFormatter.date(from: "2025-04-01T13:51:49Z"), // Adjusted example
//                creator: "bacree",
//                guid: "87977 at https://www.ftc.gov"
//            ),
//            HSRNotice(
//                id: "20251008",
//                title: "20251008: AbbVie Inc.; Gubra A/S",
//                link: URL(string: "https://www.ftc.gov/legal-library/browse/early-termination-notices/20251008"),
//                transactionNumber: "20251008",
//                acquiringParty: "AbbVie Inc.",
//                acquiredParty: "Gubra A/S",
//                grantingStatus: "Granted",
//                acquiredEntities: ["Gubra A/S", "Gubra Alpha APS"],
//                noticeDate: noticeDateFormatter.date(from: "March 28, 2025"),
//                publicationDate: dateFormatter.date(from: "2025-03-31T16:20:41Z"), // Adjusted example
//                creator: "bjames@ftc.gov",
//                guid: "87973 at https://www.ftc.gov"
//            ),
//            HSRNotice(
//                id: "20250987",
//                title: "20250987: Castlelake Group TopCo, L.P.; Castlelake V, L.P.",
//                link: URL(string: "https://www.ftc.gov/legal-library/browse/early-termination-notices/20250987"),
//                transactionNumber: "20250987",
//                acquiringParty: "Castlelake Group TopCo, L.P.",
//                acquiredParty: "Castlelake V, L.P.",
//                grantingStatus: "Granted",
//                acquiredEntities: ["CLGF Holdco 1, LLC"],
//                noticeDate: noticeDateFormatter.date(from: "March 25, 2025"),
//                publicationDate: dateFormatter.date(from: "2025-03-26T17:33:18Z"), // Adjusted example
//                creator: "bacree",
//                guid: "87667 at https://www.ftc.gov"
//            ),
//            HSRNotice(
//                 id: "20211736",
//                 title: "20211736: Green Dot Corporation; Republic Bancorp, Inc.",
//                 link: URL(string: "https://www.ftc.gov/legal-library/browse/early-termination-notices/20211736"),
//                 transactionNumber: "20211736",
//                 acquiringParty: "Green Dot Corporation",
//                 acquiredParty: "Republic Bancorp, Inc.",
//                 grantingStatus: "Granted",
//                 acquiredEntities: ["Republic Bank & Trust Company"],
//                 noticeDate: noticeDateFormatter.date(from: "July 21, 2021"),
//                 publicationDate: dateFormatter.date(from: "2021-07-22T16:54:10Z"), // Adjusted example
//                 creator: "wfg-adm109",
//                 guid: "78335 at https://www.ftc.gov"
//             )
//        ]
//    }
//}
//
//// --- ViewModel ---
//
//@MainActor // Ensure UI updates happen on the main thread
//class HSRFeedViewModel: ObservableObject {
//    @Published var notices: [HSRNotice] = []
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//
//    init() {
//        // In a real app, you would trigger the fetch here
//        loadSampleData() // For design purposes
//    }
//
//    func fetchNotices() {
//        isLoading = true
//        errorMessage = nil
//        // --- Placeholder for Network Fetching & Parsing ---
//        // 1. Use URLSession to fetch the XML data.
//        // 2. Use XMLParser (or another XML library) to parse the RSS structure.
//        // 3. For each <item>, extract the <description> string.
//        // 4. Use an HTML Parser (like SwiftSoup) or Regex to extract data
//        //    from the escaped HTML within <description>.
//        // 5. Create HSRNotice objects.
//        // 6. Update the @Published notices array on the main thread.
//        // 7. Handle errors and update isLoading/errorMessage.
//        // --- End Placeholder ---
//
//        // Simulating a delay and loading sample data for now
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            self.notices = HSRNotice.sampleData()
//            self.isLoading = false
//        }
//    }
//
//    func loadSampleData() {
//        self.notices = HSRNotice.sampleData()
//    }
//}
//
//// --- SwiftUI Views ---
//
//struct NewsView: View {
//    // Use @StateObject for ViewModels owned by the view
//    @StateObject private var viewModel = HSRFeedViewModel()
//
//    var body: some View {
//        NavigationView {
//            Group {
//                if viewModel.isLoading {
//                    ProgressView("Loading Notices...")
//                } else if let errorMessage = viewModel.errorMessage {
//                    Text("Error: \(errorMessage)")
//                        .foregroundColor(.red)
//                        .padding()
//                } else {
//                    List {
//                        ForEach(viewModel.notices) { notice in
//                            // NavigationLink directs to the detail view
//                            NavigationLink(destination: HSRNoticeDetailView(notice: notice)) {
//                                HSRNoticeRow(notice: notice)
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationTitle("HSR Notices")
//            .toolbar { // Add a refresh button (optional)
//                ToolbarItem(placement: .navigationBarTrailing) {
//                     Button {
//                         // viewModel.fetchNotices() // Uncomment for real fetch
//                     } label: {
//                         Image(systemName: "arrow.clockwise")
//                     }
//                     .disabled(viewModel.isLoading)
//                }
//            }
//            // Uncomment the line below in a real app to fetch on appear
//            // .onAppear {
//            //     if viewModel.notices.isEmpty { // Fetch only if needed
//            //         viewModel.fetchNotices()
//            //     }
//            // }
//        }
//         // Use stack navigation style for typical master-detail flow on iPhone
//        .navigationViewStyle(.stack)
//    }
//}
//
//// Row view for the list
//struct HSRNoticeRow: View {
//    let notice: HSRNotice
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 5) {
//            Text(notice.title)
//                .font(.headline)
//            HStack {
//                Text("Acquiring:")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                Text(notice.acquiringParty)
//                    .font(.caption)
//            }
//             HStack {
//                 Text("Acquired:")
//                     .font(.caption)
//                     .foregroundColor(.gray)
//                 Text(notice.acquiredParty)
//                     .font(.caption)
//             }
//            if let noticeDate = notice.noticeDate {
//                Text("Notice Date: \(noticeDate, style: .date)")
//                    .font(.footnote)
//                    .foregroundColor(.secondary)
//            }
//        }
//        .padding(.vertical, 4) // Add some vertical padding within the row
//    }
//}
//
//// Detail view for a selected notice
//struct HSRNoticeDetailView: View {
//    let notice: HSRNotice
//
//    var body: some View {
//        ScrollView { // Use ScrollView for potentially long content
//            VStack(alignment: .leading, spacing: 15) {
//                Text(notice.title).font(.title2).bold()
//
//                DetailRow(label: "Transaction #", value: notice.transactionNumber)
//                DetailRow(label: "Acquiring Party", value: notice.acquiringParty)
//                DetailRow(label: "Acquired Party", value: notice.acquiredParty)
//                DetailRow(label: "Granting Status", value: notice.grantingStatus)
//
//                if let noticeDate = notice.noticeDate {
//                    DetailRow(label: "Notice Date", value: noticeDate.formatted(date: .long, time: .omitted))
//                }
//                if let pubDate = notice.publicationDate {
//                    DetailRow(label: "Publication Date", value: pubDate.formatted(date: .long, time: .shortened))
//                }
//
//                DetailRow(label: "Creator", value: notice.creator)
//
//                // Display Acquired Entities if available
//                if !notice.acquiredEntities.isEmpty {
//                    VStack(alignment: .leading) {
//                        Text("Acquired Entities:")
//                            .font(.headline)
//                        ForEach(notice.acquiredEntities, id: \.self) { entity in
//                            Text("• \(entity)")
//                                .padding(.leading, 8)
//                        }
//                    }
//                }
//
//                // Link to the source (optional)
//                if let link = notice.link {
////                     Link("View Original Notice", destination: link)
////                         .padding(.top)
//                }
//
//                Spacer() // Push content to the top
//            }
//            .padding() // Add padding around the VStack content
//        }
//        .navigationTitle("Notice Details")
//        // Use large title display mode for consistency or inline if preferred
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// Helper View for consistent detail rows
//struct DetailRow: View {
//    let label: String
//    let value: String
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(label)
//                .font(.headline)
//            Text(value)
//                .foregroundColor(.secondary)
//        }
//    }
//}
//
//// --- App Entry Point (if creating a full app project) ---
///*
// @main
// struct HSRViewerApp: App {
//     var body: some Scene {
//         WindowGroup {
//             ContentView()
//         }
//     }
// }
//*/
//
//// --- Preview Provider ---
//
//#Preview {
//    NewsView()
//}
