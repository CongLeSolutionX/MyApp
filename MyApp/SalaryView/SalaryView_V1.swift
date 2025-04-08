////
////  SalaryView.swift
////  MyApp
////
////  Created by Cong Le on 4/7/25.
////
//
//import SwiftUI
//
//// MARK: - Data Model
//struct SalarySubmission: Identifiable {
//    let id = UUID()
//    let companyName: String
//    let companyLogoName: String // System name or asset name
//    let location: String
//    let date: String
//    let levelName: String
//    let levelTag: String
//    let totalComp: Int
//    let base: Int
//    let stock: Int
//    let bonus: Int
//
//    var formattedTotalComp: String {
//        "$\(totalComp / 1000)K" // Simplified formatting
//    }
//    var formattedBreakdown: String {
//        "\(base / 1000)K | \(stock / 1000)K | \(bonus / 1000)K" // Simplified
//    }
//}
//
//// MARK: - Main ContentView
//struct SalaryView_V1: View {
//    @State private var selectedTab = 0
//    @State private var searchText = "" // Placeholder state for filter
//
//    // Sample Data
//    let submissions: [SalarySubmission] = [
//        SalarySubmission(companyName: "Google", companyLogoName: "g.circle.fill", location: "Mountain View, CA", date: "an hour ago", levelName: "L5", levelTag: "Distributed Systems (Back-End)", totalComp: 411419, base: 228000, stock: 142000, bonus: 42000),
//        SalarySubmission(companyName: "Cruise", companyLogoName: "c.circle.fill", location: "San Francisco, CA", date: "an hour ago", levelName: "L4", levelTag: "ML / AI", totalComp: 349000, base: 182000, stock: 107000, bonus: 60000),
//        SalarySubmission(companyName: "Amazon", companyLogoName: "a.circle.fill", location: "Seattle, WA", date: "2 hours ago", levelName: "SDE II", levelTag: "Cloud Services", totalComp: 261400, base: 160000, stock: 80000, bonus: 21400),
//         SalarySubmission(companyName: "Meta", companyLogoName: "m.circle.fill", location: "Menlo Park, CA", date: "3 hours ago", levelName: "E5", levelTag: "Social / Infra", totalComp: 450000, base: 210000, stock: 180000, bonus: 60000),
//    ]
//
//    var body: some View {
//        ZStack(alignment: .bottomTrailing) {
//            // Main Content Area
//            TabView(selection: $selectedTab) {
//                NavigationView { // Added NavigationView for potential future title/bar items
//                    ScrollView {
//                        VStack(alignment: .leading, spacing: 20) {
//                            SearchBarView()
//
//                            SalaryTrendsSection()
//
//                            SalarySubmissionsSection(searchText: $searchText, submissions: submissions)
//
//                            NegotiateOfferView()
//
//                            // Spacer to push content up, leaving room for FABs visually
//                            Spacer(minLength: 120)
//                        }
//                        .padding(.horizontal)
//                    }
//                    .navigationBarHidden(true) // Hide the default navigation bar
//                    .background(Color(.systemGray6).edgesIgnoringSafeArea(.all)) // Dark background
//                }
//                .tag(0)
//                .tabItem {
//                    Image(systemName: "message.fill")
//                    Text("Chats")
//                }
//
//                Text("Placeholder Screen 2").tag(1)
//                    .tabItem {
//                        Image(systemName: "creditcard.fill") // Placeholder icon
//                        Text("Offers")
//                    }
//
//                 Text("Placeholder Screen 3").tag(2)
//                    .tabItem {
//                        Image(systemName: "chart.bar.xaxis")
//                        Text("Trends")
//                    }
//
//                Text("Placeholder Screen 4").tag(3)
//                    .tabItem {
//                         Image(systemName: "bell.fill")
//                         Text("Notifications")
//                    }
//
//                 Text("Placeholder Screen 5").tag(4)
//                    .tabItem {
//                         Image(systemName: "person.fill")
//                         Text("Profile")
//                     }
//            }
//
//            // Floating Action Buttons
//            FloatingActionButtons()
//                .padding(.bottom, 60) // Adjust padding to avoid tab bar overlap
//                .padding(.trailing)
//
//        }
//        .preferredColorScheme(.dark) // Enforce dark mode for the entire view
//    }
//}
//
//// MARK: - Subviews
//struct SearchBarView: View {
//    var body: some View {
//        HStack(spacing: 10) {
//            Image(systemName: "magnifyingglass")
//                .foregroundColor(.gray)
//
//            VStack(alignment: .leading) {
//                Text("Software Engineer")
//                    .font(.headline)
//                Text("United States")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//
//            Spacer()
//
//            Button(action: {}) {
//                Image(systemName: "plus")
//                    .font(.title2)
//                    .foregroundColor(Color(.systemBlue)) // Match blue color
//            }
//        }
//        .padding()
//        .background(Color(.systemGray4)) // Darker gray background for search bar
//        .cornerRadius(30) // High corner radius for pill shape
//    }
//}
//
//struct SalaryTrendsSection: View {
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            Text("Salary Trends")
//                .font(.title2)
//                .fontWeight(.bold)
//
//            // --- Placeholder Chart ---
//            SalaryChartView()
//                .frame(height: 180) // Give the chart some defined height
//            // --- End Placeholder Chart ---
//        }
//    }
//}
//
//struct SalaryChartView: View {
//    // Placeholder data for visualization
//       let salaryData: [CGFloat] = [0.2, 0.6, 0.8, 0.9, 1.0, 0.85, 0.7, 0.65, 0.5, 0.4, 0.35, 0.3, 0.25, 0.2, 0.15, 0.1, 0.05, 0.08, 0.5] // Relative heights 0-1
//       let labels = ["$55K", "$122K", "$189K", "$255K", "$322K", "$389K", "$456K"]
//
//       var body: some View {
//           GeometryReader { geometry in
//               ZStack(alignment: .bottomLeading) {
//                    // Background grid lines (optional, simplified)
//                   Path { path in
//                       let spacing = geometry.size.width / CGFloat(labels.count)
//                       for i in 1..<labels.count {
//                           let x = CGFloat(i) * spacing
//                           path.move(to: CGPoint(x: x, y: 0))
//                           path.addLine(to: CGPoint(x: x, y: geometry.size.height))
//                       }
//                   }
//                   .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
//
//                   HStack(alignment: .bottom, spacing: 4) {
//                       ForEach(0..<salaryData.count, id: \.self) { index in
//                           RoundedRectangle(cornerRadius: 5)
//                               .fill(Color.green)
//                               .frame(height: salaryData[index] * (geometry.size.height - 20)) // Leave space for labels
//                       }
//                   }
//
//                    // X-Axis Labels
//                   HStack {
//                       ForEach(labels, id: \.self) { label in
//                           Text(label)
//                               .font(.caption2)
//                               .foregroundColor(.gray)
//                               .frame(maxWidth: .infinity, alignment: .center)
//                               .rotationEffect(.degrees(-30)) // Angled labels
//                               .offset(y: 15) // Position below bars
//                       }
//                       // Add dummy views for spacing if needed, depending on bar count vs label count
//                       Spacer() // Adjust as needed
//                   }
//                   .offset(x: geometry.size.width / CGFloat(labels.count * 2)) // Center labels roughly under groups of bars
//
//                    // Percentile Markers (Simplified)
//                   PercentileMarkerView(label: "Median", xRatio: 0.3, height: geometry.size.height, isDashed: true)
//                   PercentileMarkerView(label: "75th", xRatio: 0.5, height: geometry.size.height)
//                   PercentileMarkerView(label: "90th", xRatio: 0.7, height: geometry.size.height)
//               }
//           }
//           .padding(.bottom, 25) // Add padding for angled labels
//           .background(Color(.systemGray5)) // Slightly lighter background for the chart area
//           .cornerRadius(8)
//       }
//}
//
//struct PercentileMarkerView: View {
//    let label: String
//    let xRatio: CGFloat // Position relative to width (0.0 to 1.0)
//    let height: CGFloat
//    var isDashed: Bool = false
//
//    var body: some View {
//        GeometryReader { geometry in
//            let xPos = geometry.size.width * xRatio
//            VStack(spacing: 2) {
//                Text(label)
//                    .font(.caption)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                    .background(Color(.systemGray3))
//                    .foregroundColor(.white)
//                    .cornerRadius(5)
//
//                Path { path in
//                    path.move(to: CGPoint(x: xPos, y: 30)) // Start below label
//                    path.addLine(to: CGPoint(x: xPos, y: height)) // Extend to bottom
//                }
//                .stroke(style: StrokeStyle(lineWidth: 1, dash: isDashed ? [4] : []))
//                .foregroundColor(.gray)
//            }
//             .offset(x: xPos - 25) // Adjust offset based on label width estimate
//             .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // Align within ZStack
//        }
//    }
//}
//
//struct SalarySubmissionsSection: View {
//    @Binding var searchText: String
//    let submissions: [SalarySubmission]
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            Text("Salary Submissions")
//                .font(.title2)
//                .fontWeight(.bold)
//
//            FilterBarView(searchText: $searchText)
//
//            SubmissionHeaderView()
//                .padding(.horizontal, 5) // Align headers with row content slightly
//
//            // List of Submissions
//            VStack(spacing: 0) {
//                ForEach(submissions) { submission in
//                    SubmissionRowView(submission: submission)
//                    Divider() // Add divider between rows
//                        .background(Color.gray)
//                }
//            }
//            .background(Color(.systemGray5)) // Background for the list area
//            .cornerRadius(8)
//        }
//    }
//}
//
//struct FilterBarView: View {
//    @Binding var searchText: String
//
//    var body: some View {
//        HStack {
//            Image(systemName: "line.3.horizontal.decrease.circle") // Filter icon
//                .foregroundColor(.gray)
//            TextField("Text filter", text: $searchText)
//
//            Spacer()
//
//            Button(action: {}) {
//                Image(systemName: "slider.horizontal.3") // Filter settings icon
//                    .foregroundColor(.white)
//            }
//        }
//        .padding()
//        .background(Color(.systemGray4))
//        .cornerRadius(8)
//    }
//}
//
//struct SubmissionHeaderView: View {
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text("Company")
//                    .font(.caption.weight(.semibold))
//                    .foregroundColor(.white)
//                Text("LOCATION | DATE")
//                    .font(.caption2)
//                    .foregroundColor(.gray)
//            }
//            .frame(maxWidth: .infinity, alignment: .leading) // Take up space
//
//            VStack(alignment: .leading) {
//                Text("Level Name")
//                     .font(.caption.weight(.semibold))
//                     .foregroundColor(.white)
//                 Text("TAG")
//                     .font(.caption2)
//                     .foregroundColor(.gray)
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//
//            VStack(alignment: .trailing) {
//                HStack(spacing: 4) {
//                    Image(systemName: "arrow.up.arrow.down") // Sort icon
//                        .font(.caption)
//                    Text("Total Comp")
//                        .font(.caption.weight(.semibold))
//                        .foregroundColor(.white)
//                }
//                 Text("BASE | STOCK / YR | BONUS")
//                     .font(.caption2)
//                     .foregroundColor(.gray)
//                     .lineLimit(1) // Prevent wrapping
//                     .minimumScaleFactor(0.8) // Allow shrinking slightly
//            }
//            .frame(maxWidth: .infinity, alignment: .trailing) // Align right
//        }
//        .padding(.vertical, 5)
//    }
//}
//
//struct SubmissionRowView: View {
//    let submission: SalarySubmission
//
//    var body: some View {
//        HStack(alignment: .top) {
//            // Company Info
//            Image(systemName: submission.companyLogoName) // Use system name for placeholder
//                .resizable()
//                .scaledToFit()
//                .frame(width: 25, height: 25)
//                .padding(.top, 5)
//                .foregroundColor(logoColor(for: submission.companyName)) // Assign color based on name
//
//            VStack(alignment: .leading) {
//                Text(submission.companyName)
//                    .font(.headline)
//                Text("\(submission.location) | \(submission.date)")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//
//            // Level Info
//            VStack(alignment: .leading) {
//                Text(submission.levelName)
//                     .font(.headline)
//                 Text(submission.levelTag)
//                     .font(.caption)
//                     .foregroundColor(.gray)
//                     .lineLimit(2) // Allow wrapping slightly
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//
//            // Compensation Info
//            VStack(alignment: .trailing) {
//                 Text(submission.formattedTotalComp)
//                     .font(.headline)
//                 Text(submission.formattedBreakdown)
//                     .font(.caption2) // Smaller font for breakdown
//                     .foregroundColor(.gray)
//            }
//            .frame(maxWidth: .infinity, alignment: .trailing)
//        }
//        .padding() // Add padding inside each row
//    }
//    
//    // Helper to assign colors loosely based on company name
//    func logoColor(for company: String) -> Color {
//        switch company {
//        case "Google": return .blue
//        case "Cruise": return .orange
//        case "Amazon": return .yellow
//        case "Meta": return .indigo
//        default: return .gray
//        }
//    }
//}
//
//struct NegotiateOfferView: View {
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Negotiate Your Offer")
//                .font(.headline)
//            Text("Increase guaranteed, or you don't pay")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//        }
//        .padding(.vertical)
//    }
//}
//
//struct FloatingActionButtons: View {
//    var body: some View {
//        VStack(spacing: 15) {
//            Button(action: {}) {
//                HStack {
//                    Text("Increase Offer")
//                    Image(systemName: "chevron.right")
//                }
//                .font(.headline)
//                .foregroundColor(.white)
//                .padding(.horizontal, 20)
//                .padding(.vertical, 12)
//                .background(Color.green) // Matching button color
//                .clipShape(Capsule())
//                .shadow(radius: 5)
//            }
//
//            Button(action: {}) {
//                 HStack {
//                     Image(systemName: "plus")
//                     Text("Add Salary")
//                 }
//                 .font(.headline)
//                 .foregroundColor(.black) // Contrasting text color
//                 .padding(.horizontal, 30) // Wider padding
//                 .padding(.vertical, 15) // Taller padding
//                 .background(Color.white)
//                 .clipShape(Capsule())
//                 .shadow(radius: 5)
//            }
//            .offset(x: -15, y: -10) // Offset slightly up and left for overlap effect
//        }
//    }
//}
//
//// MARK: - Preview
//struct SalaryView_Previews: PreviewProvider {
//    static var previews: some View {
//        SalaryView_V1()
//    }
//}
