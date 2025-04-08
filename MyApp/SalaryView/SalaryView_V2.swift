//
//  SalaryView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/7/25.
//

import SwiftUI
import Combine // Needed for ObservableObject and @Published

// MARK: - Data Model (Remains the same)
struct SalarySubmission: Identifiable, Equatable { // Equatable for sorting tracking
    let id = UUID()
    let companyName: String
    let companyLogoName: String // System name or asset name
    let location: String
    let date: String // Consider using Date type in a real app
    let levelName: String
    let levelTag: String
    let totalComp: Int
    let base: Int
    let stock: Int
    let bonus: Int

    var formattedTotalComp: String { "$\(totalComp / 1000)K" }
    var formattedBreakdown: String { "\(base / 1000)K | \(stock / 1000)K | \(bonus / 1000)K" }
}

// MARK: - Sort Descriptor
enum SortKey {
    case totalComp, date, companyName // Add more as needed
}

// MARK: - ViewModel
class SalaryViewModel: ObservableObject {

    // --- State Properties ---
    @Published var searchText: String = ""
    @Published var filteredSubmissions: [SalarySubmission] = []
    @Published var isShowingAddSalarySheet: Bool = false
    @Published var isShowingFilterSheet: Bool = false // For future filter options
    @Published var sortKey: SortKey = .date // Default sort
    @Published var sortAscending: Bool = false // Default: Newest first

    // --- Internal Data Storage ---
    private var allSubmissions: [SalarySubmission] = [] // Source of truth
    private var cancellables = Set<AnyCancellable>()

    // Sample Data Initialization
    init() {
        // In a real app, fetch this data asynchronously
        self.allSubmissions = sampleData
        setupBindings()
        applyFiltersAndSort() // Initial load
    }

    // --- Logic Methods ---

    private func setupBindings() {
        // Re-filter whenever searchText changes
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main) // Add delay
            .sink { [weak self] _ in
                self?.applyFiltersAndSort()
            }
            .store(in: &cancellables)

        // Re-sort whenever sort criteria change
        $sortKey
            .sink { [weak self] _ in
                self?.applyFiltersAndSort()
            }
            .store(in: &cancellables)

        $sortAscending
            .sink { [weak self] _ in
                self?.applyFiltersAndSort()
            }
            .store(in: &cancellables)
    }

    func applyFiltersAndSort() {
        var workingSubmissions = allSubmissions

        // Apply Filter
        if !searchText.isEmpty {
            let lowercasedSearch = searchText.lowercased()
            workingSubmissions = workingSubmissions.filter { submission in
                submission.companyName.lowercased().contains(lowercasedSearch) ||
                submission.location.lowercased().contains(lowercasedSearch) ||
                submission.levelTag.lowercased().contains(lowercasedSearch) ||
                submission.levelName.lowercased().contains(lowercasedSearch)
            }
        }

        // Apply Sort
        switch sortKey {
            case .totalComp:
                workingSubmissions.sort {
                    sortAscending ? $0.totalComp < $1.totalComp : $0.totalComp > $1.totalComp
                }
            case .date:
                 // Basic date sort (assumes "X hours/days ago" format converts predictably)
                 // In a real app, use actual Date objects!
                 workingSubmissions.sort {
                      sortAscending ? $0.date < $1.date : $0.date > $1.date // Simplistic comparison
                 }
            case .companyName:
                 workingSubmissions.sort {
                      sortAscending ? $0.companyName < $1.companyName : $0.companyName > $1.companyName
                 }
        }

        self.filteredSubmissions = workingSubmissions
    }

    func toggleSort(key: SortKey) {
         if sortKey == key {
             sortAscending.toggle() // Reverse direction if same key
         } else {
             sortKey = key        // Change key, default to descending (or preferred direction)
             sortAscending = false // Or set a default preference per key
         }
     }

    // Function to add a new submission (called from AddSalaryView)
    func addSalary(_ submission: SalarySubmission) {
        allSubmissions.insert(submission, at: 0) // Add to top
        applyFiltersAndSort() // Re-apply filters and sort
    }

    // --- Sample Data ---
    private let sampleData: [SalarySubmission] = [
        SalarySubmission(companyName: "Google", companyLogoName: "g.circle.fill", location: "Mountain View, CA", date: "1 hour ago", levelName: "L5", levelTag: "Distributed Systems (Back-End)", totalComp: 411419, base: 228000, stock: 142000, bonus: 42000),
        SalarySubmission(companyName: "Cruise", companyLogoName: "c.circle.fill", location: "San Francisco, CA", date: "1 hour ago", levelName: "L4", levelTag: "ML / AI", totalComp: 349000, base: 182000, stock: 107000, bonus: 60000),
        SalarySubmission(companyName: "Amazon", companyLogoName: "a.circle.fill", location: "Seattle, WA", date: "2 hours ago", levelName: "SDE II", levelTag: "Cloud Services", totalComp: 261400, base: 160000, stock: 80000, bonus: 21400),
        SalarySubmission(companyName: "Meta", companyLogoName: "m.circle.fill", location: "Menlo Park, CA", date: "3 hours ago", levelName: "E5", levelTag: "Social / Infra", totalComp: 450000, base: 210000, stock: 180000, bonus: 60000),
        SalarySubmission(companyName: "Apple", companyLogoName: "apple.logo", location: "Cupertino, CA", date: "4 hours ago", levelName: "ICT4", levelTag: "iOS Development", totalComp: 380000, base: 190000, stock: 150000, bonus: 40000),

    ]
}

import SwiftUI

// MARK: - App Color Palette (Example)
extension Color {
    static let viewBackground = Color(.systemGray6)
    static let cardBackground = Color(.systemGray5)
    static let textFieldBackground = Color(.systemGray4)
    static let subtleText = Color.gray
    static let primaryAction = Color.green
    static let secondaryAction = Color.white
    static let accent = Color(.systemBlue) // For icons like the search '+'
}

// MARK: - Main View
struct SalaryView: View {
    // Use @StateObject to create and keep the ViewModel alive
    @StateObject private var viewModel = SalaryViewModel()
    @State private var selectedTab = 0 // Keep tab selection state here

    var body: some View {
        // ZStack for layering FABs over the TabView content
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                // --- Trends Tab (Main Content) ---
                NavigationView { // Essential for NavigationLinks
                    SalaryContentView(viewModel: viewModel) // Pass ViewModel
                    .navigationBarHidden(true) // Keep hiding default bar if needed
                }
                .tag(0)
                .tabItem {
                    Label("Trends", systemImage: "chart.bar.xaxis") // Use Label for icon+text
                }
                // Prevent NavigationView styling bleed in dark mode
                .navigationViewStyle(StackNavigationViewStyle())

                // --- Other Tabs (Placeholders/Actual Views) ---
                OffersView().tag(1) // Replace with actual view
                    .tabItem { Label("Offers", systemImage: "creditcard.fill") }

                ChatsView().tag(2) // Replace with actual view
                    .tabItem { Label("Chats", systemImage: "message.fill") }

                NotificationsView().tag(3) // Replace with actual view
                     .tabItem { Label("Notifications", systemImage: "bell.fill") }

                ProfileView().tag(4) // Replace with actual view
                     .tabItem { Label("Profile", systemImage: "person.fill") }
            }

            // --- Floating Action Buttons ---
            // Only show FABs on the main Trends tab
            if selectedTab == 0 {
                 FloatingActionButtons(
                     addSalaryAction: { viewModel.isShowingAddSalarySheet = true },
                     increaseOfferAction: { /* Navigation handled by link inside */ }
                 )
                 .padding(.bottom, 60) // Adjust padding as needed
                 .padding(.trailing)
                 // Attach sheet modifier here for Add Salary
                 .sheet(isPresented: $viewModel.isShowingAddSalarySheet) {
                     AddSalaryView()
                          .environmentObject(viewModel) // Pass ViewModel if needed for adding data
                 }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Main Content Area (Scrollable)
struct SalaryContentView: View {
    @ObservedObject var viewModel: SalaryViewModel // Use ObservedObject for passed ViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Pass binding to searchText
                SearchBarView(searchText: $viewModel.searchText)

                // Trends section now navigable
                NavigationLink(destination: TrendsDetailView()) {
                     SalaryTrendsSection()
                }
                .buttonStyle(PlainButtonStyle()) // Remove default button styling

                // Submissions section uses filtered data and handles sorting
                SalarySubmissionsSection(viewModel: viewModel)

                // Negotiate section is now a NavigationLink
                NavigationLink(destination: NegotiateOfferView_Actual()) {
                    NegotiateOfferButtonView() // Use a button-like appearance
                }
                .buttonStyle(PlainButtonStyle())

                // Spacer for FAB visibility
                Spacer(minLength: 120)
            }
            .padding(.horizontal)
             // Attach sheet modifier for Filter options (if needed at this level)
             .sheet(isPresented: $viewModel.isShowingFilterSheet) {
                 FilterOptionsView() // Create this view for filter options
                  .environmentObject(viewModel) // Pass VM if needed
             }
        }
        .background(Color.viewBackground.edgesIgnoringSafeArea(.all))
    }
}

// MARK: - Subviews (Updated for Functionality)

struct SearchBarView: View {
    @Binding var searchText: String // Use binding to connect to ViewModel

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.subtleText)

            // Use TextField for actual input
            TextField("Search Engineer, Location, Company...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle()) // Basic styling

            Spacer()

            Button(action: { /* TODO: Add specific action like 'add alert' */ }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(Color.accent)
            }
        }
        .padding()
        .background(Color.textFieldBackground)
        .cornerRadius(30)
    }
}

struct SalaryTrendsSection: View {
    // No changes needed if just for navigation trigger
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Salary Trends")
                .font(.title2)
                .fontWeight(.bold)
            SalaryChartView() // Keep placeholder chart visuals
                .frame(height: 180)
        }
        .contentShape(Rectangle()) // Make the whole VStack tappable for NavigationLink
    }
}

// Placeholder Chart - remains visual
struct SalaryChartView: View {
    let salaryData: [CGFloat] = [0.2, 0.6, 0.8, 0.9, 1.0, 0.85, 0.7, 0.65, 0.5, 0.4, 0.35, 0.3, 0.25, 0.2, 0.15, 0.1, 0.05, 0.08, 0.5]
    let labels = ["$55K", "$122K", "$189K", "$255K", "$322K", "$389K", "$456K"]

    var body: some View {
        // ... (Keep the previous GeometryReader/HStack/Path implementation) ...
        // (Code from previous response for chart visuals)
        GeometryReader { geometry in
                           ZStack(alignment: .bottomLeading) {
                                // Background grid lines (optional, simplified)
                               Path { path in
                                   let spacing = geometry.size.width / CGFloat(labels.count)
                                   for i in 1..<labels.count {
                                       let x = CGFloat(i) * spacing
                                       path.move(to: CGPoint(x: x, y: 0))
                                       path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                                   }
                               }
                               .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)

                               HStack(alignment: .bottom, spacing: 4) {
                                   ForEach(0..<salaryData.count, id: \.self) { index in
                                       RoundedRectangle(cornerRadius: 5)
                                           .fill(Color.green)
                                           .frame(height: salaryData[index] * (geometry.size.height - 20)) // Leave space for labels
                                   }
                               }

                                // X-Axis Labels
                               HStack {
                                   ForEach(labels, id: \.self) { label in
                                       Text(label)
                                           .font(.caption2)
                                           .foregroundColor(.gray)
                                           .frame(maxWidth: .infinity, alignment: .center)
                                           .rotationEffect(.degrees(-30)) // Angled labels
                                           .offset(y: 15) // Position below bars
                                   }
                                   // Add dummy views for spacing if needed, depending on bar count vs label count
                                   Spacer() // Adjust as needed
                               }
                               .offset(x: geometry.size.width / CGFloat(labels.count * 2)) // Center labels roughly under groups of bars

                                // Percentile Markers (Simplified)
                               PercentileMarkerView(label: "Median", xRatio: 0.3, height: geometry.size.height, isDashed: true)
                               PercentileMarkerView(label: "75th", xRatio: 0.5, height: geometry.size.height)
                               PercentileMarkerView(label: "90th", xRatio: 0.7, height: geometry.size.height)
                           }
                       }
                       .padding(.bottom, 25) // Add padding for angled labels
                       .background(Color.cardBackground) // Slightly lighter background for the chart area
                       .cornerRadius(8)
    }
}
// PercentileMarkerView remains the same
struct PercentileMarkerView: View {
    let label: String
    let xRatio: CGFloat // Position relative to width (0.0 to 1.0)
    let height: CGFloat
    var isDashed: Bool = false

    var body: some View {
        GeometryReader { geometry in
            let xPos = geometry.size.width * xRatio
            VStack(spacing: 2) {
                Text(label)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray3))
                    .foregroundColor(.white)
                    .cornerRadius(5)

                Path { path in
                    path.move(to: CGPoint(x: xPos, y: 30)) // Start below label
                    path.addLine(to: CGPoint(x: xPos, y: height)) // Extend to bottom
                }
                .stroke(style: StrokeStyle(lineWidth: 1, dash: isDashed ? [4] : []))
                .foregroundColor(.gray)
            }
             .offset(x: xPos - 25) // Adjust offset based on label width estimate
             .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // Align within ZStack
        }
    }
}
struct SalarySubmissionsSection: View {
    @ObservedObject var viewModel: SalaryViewModel // Use the ViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Salary Submissions")
                .font(.title2)
                .fontWeight(.bold)

            // Filter bar now has interactive elements (TextField binding handled elsewhere)
            FilterBarView(
                filterAction: { viewModel.isShowingFilterSheet = true } // Trigger filter sheet
            )

            // Header is now interactive for sorting
            SubmissionHeaderView(
                 sortKey: viewModel.sortKey,
                 sortAscending: viewModel.sortAscending,
                 sortAction: { key in viewModel.toggleSort(key: key) } // Call ViewModel's sort toggle
             )
            .padding(.horizontal, 5)

            // List uses filtered and sorted data from ViewModel
            VStack(spacing: 0) {
                // Show message if list is empty after filtering
                if viewModel.filteredSubmissions.isEmpty {
                     Text("No submissions match your filter.")
                        .foregroundColor(.subtleText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(viewModel.filteredSubmissions) { submission in
                        // Wrap row in NavigationLink
                        NavigationLink(destination: SalaryDetailView(submission: submission)) {
                           SubmissionRowView(submission: submission)
                        }
                        .buttonStyle(PlainButtonStyle()) // Consistent navigation look

                        Divider().background(Color.gray)
                    }
                }
            }
            .background(Color.cardBackground)
            .cornerRadius(8)
        }
    }
}

struct FilterBarView: View {
    // No need for binding here anymore as it's handled in ViewModel/Parent
    var filterAction: () -> Void // Action for filter icon

    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .foregroundColor(.subtleText)

            // Simple text placeholder, real filtering happens via SearchBarView's binding
            Text("Filter by...")
                .foregroundColor(.subtleText) // Placeholder appearance
                  .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Button(action: filterAction) { // Button triggers the action
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.white) // Changed color for visibility
            }
            .accessibilityLabel("Filter Options")
        }
        .padding()
        .background(Color.textFieldBackground) // Use text field background color
        .cornerRadius(8)
    }
}

struct SubmissionHeaderView: View {
    var sortKey: SortKey
     var sortAscending: Bool
     var sortAction: (SortKey) -> Void // Closure to handle sort tap

    var body: some View {
        HStack {
            // Company Header (Example: Make Company tappable for sorting)
            Button(action: { sortAction(.companyName) }) { // << Make Company Sortable
                 HeaderItemView(
                     title: "Company",
                     subtitle: "LOCATION | DATE",
                     alignment: .leading,
                     isActiveSortKey: sortKey == .companyName,
                     isAscending: sortAscending
                 )
            }
            .buttonStyle(PlainButtonStyle())

            Spacer() // Add spacers for better distribution

            // Level Header (Not sortable in this example)
             HeaderItemView(
                title: "Level Name",
                subtitle: "TAG",
                alignment: .leading
            )

             Spacer()

            // Total Comp Header (Sortable)
            Button(action: { sortAction(.totalComp) }) { // << ACTION
                HeaderItemView(
                    title: "Total Comp",
                    subtitle: "BASE | STOCK / YR | BONUS",
                    alignment: .trailing,
                    isActiveSortKey: sortKey == .totalComp, // << Pass sort state
                    isAscending: sortAscending          // << Pass sort state
                )
            }
            .buttonStyle(PlainButtonStyle()) // Remove default button look
        }
        .padding(.vertical, 5)
    }
}

// Reusable View for Header Items (with Sort Indicator)
struct HeaderItemView: View {
    let title: String
    let subtitle: String
    let alignment: HorizontalAlignment
    var isActiveSortKey: Bool = false // Is this the column being sorted?
    var isAscending: Bool = true      // Direction of sort

    var body: some View {
        VStack(alignment: alignment) {
            HStack(spacing: 4) {
                 // Show sort icon only if this is the active sort column
                 if isActiveSortKey {
                     Image(systemName: isAscending ? "arrow.up" : "arrow.down") // Sort icon
                         .font(.caption)
                         .foregroundColor(.accent) // Use accent color
                 }
                 Text(title)
                     .font(.caption.weight(.semibold))
                     .foregroundColor(.white)
             }
             Text(subtitle)
                 .font(.caption2)
                 .foregroundColor(.subtleText)
                 .lineLimit(1)
                 .minimumScaleFactor(0.8)
         }
         .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .trailing) // Ensure alignment takes effect
    }
}

struct SubmissionRowView: View {
    let submission: SalarySubmission
    // No changes needed structurally, just uses the passed submission
    // ... (Keep the existing HStack/VStack structure) ...
    // ... (Optional: Add small visual indicator if row is 'new' maybe) ...
    var body: some View {
        HStack(alignment: .top) {
            // Company Info
            Image(systemName: submission.companyLogoName) // Use system name for placeholder
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .padding(.top, 5)
                .foregroundColor(logoColor(for: submission.companyName)) // Assign color based on name

            VStack(alignment: .leading) {
                Text(submission.companyName)
                    .font(.headline)
                Text("\(submission.location) | \(submission.date)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Level Info
            VStack(alignment: .leading) {
                Text(submission.levelName)
                     .font(.headline)
                 Text(submission.levelTag)
                     .font(.caption)
                     .foregroundColor(.gray)
                     .lineLimit(2) // Allow wrapping slightly
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Compensation Info
            VStack(alignment: .trailing) {
                 Text(submission.formattedTotalComp)
                     .font(.headline)
                 Text(submission.formattedBreakdown)
                     .font(.caption2) // Smaller font for breakdown
                     .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding() // Add padding inside each row
    }

    func logoColor(for company: String) -> Color { /* ... Same as before ... */
        switch company {
            case "Google": return .blue
            case "Cruise": return .orange
            case "Amazon": return .yellow
            case "Meta": return .indigo
            case "Apple": return .gray // Use gray or black/white for Apple
            default: return .gray
        }
    }
}

struct NegotiateOfferButtonView: View {
    // Visually represent the section as a tappable area/button
    var body: some View {
        HStack { // Use HStack to allow adding an arrow or chevron
            VStack(alignment: .leading) {
                Text("Negotiate Your Offer")
                    .font(.headline)
                Text("Increase guaranteed, or you don't pay")
                    .font(.subheadline)
                    .foregroundColor(.subtleText)
            }
            Spacer() // Push arrow to the right
            Image(systemName: "chevron.right")
                 .foregroundColor(.subtleText)
        }
        .padding()
        .background(Color.cardBackground) // Give it a card-like background
        .cornerRadius(8)
         .contentShape(Rectangle()) // Ensure the whole area is tappable
    }
}

struct FloatingActionButtons: View {
    var addSalaryAction: () -> Void
    var increaseOfferAction: () -> Void // Still needed for NavigationLink wrapper later

    var body: some View {
        VStack(spacing: 15) {
             // Increase Offer Button now wrapped in NavigationLink
             NavigationLink(destination: NegotiateOfferView_Actual()) {
                 HStack {
                     Text("Increase Offer")
                     Image(systemName: "chevron.right")
                 }
                 .font(.headline)
                 .foregroundColor(.white)
                 .padding(.horizontal, 20)
                 .padding(.vertical, 12)
                 .background(Color.primaryAction)
                 .clipShape(Capsule())
                 .shadow(radius: 5)
             }
             .simultaneousGesture(TapGesture().onEnded(increaseOfferAction)) // Keep original action if needed

            Button(action: addSalaryAction) { // Add Salary remains a Button triggering a sheet
                 HStack {
                     Image(systemName: "plus")
                     Text("Add Salary")
                 }
                 .font(.headline)
                 .foregroundColor(.black)
                 .padding(.horizontal, 30)
                 .padding(.vertical, 15)
                 .background(Color.secondaryAction)
                 .clipShape(Capsule())
                 .shadow(radius: 5)
            }
            .accessibilityLabel("Add New Salary")
            .offset(x: -15, y: -10) // Keep overlap effect
        }
    }
}

// MARK: - Placeholder Destination Views
struct SalaryDetailView: View {
    let submission: SalarySubmission
    var body: some View {
        ScrollView{ // Make detail scrollable if needed
            VStack(alignment: .leading, spacing: 15){
                HStack{
                    Image(systemName: submission.companyLogoName)
                        .resizable().scaledToFit().frame(width: 50, height: 50)
                        .foregroundColor(SubmissionRowView(submission: submission).logoColor(for: submission.companyName))
                    Text(submission.companyName).font(.largeTitle)
                }

                Text("Level: \(submission.levelName) (\(submission.levelTag))")
                Text("Location: \(submission.location)")
                Text("Reported: \(submission.date)")

                Divider()

                Text("Total Compensation: \(submission.formattedTotalComp)")
                     .font(.title2).padding(.top)
                Text("Base: $\(submission.base)")
                Text("Stock/Year: $\(submission.stock)")
                Text("Bonus: $\(submission.bonus)")

                 // Add more details like comments, years of experience etc. here
                 Spacer()
            }
            .padding()
        }
        .navigationTitle("Salary Details") // Give the detail view a title
        .background(Color.viewBackground.edgesIgnoringSafeArea(.all)) // Match background
        .preferredColorScheme(.dark)

    }
}

struct TrendsDetailView: View {
    var body: some View {
        Text("Detailed Salary Trends View (Placeholder)")
            .navigationTitle("Trends Analysis")
            .background(Color.viewBackground.edgesIgnoringSafeArea(.all))
            .preferredColorScheme(.dark)
    }
}

struct NegotiateOfferView_Actual: View { // Renamed to avoid conflict
    var body: some View {
        Text("Offer Negotiation Screen (Placeholder)")
            .navigationTitle("Negotiate Offer")
            .background(Color.viewBackground.edgesIgnoringSafeArea(.all))
            .preferredColorScheme(.dark)
    }
}

// MARK: - Views for Other Tabs (Placeholders)
struct OffersView: View {
     var body: some View { ZStack { Color.viewBackground.edgesIgnoringSafeArea(.all); Text("Offers Screen") }.preferredColorScheme(.dark) }
}
struct ChatsView: View {
     var body: some View { ZStack { Color.viewBackground.edgesIgnoringSafeArea(.all); Text("Chats Screen") }.preferredColorScheme(.dark) }
}
struct NotificationsView: View {
     var body: some View { ZStack { Color.viewBackground.edgesIgnoringSafeArea(.all); Text("Notifications Screen") }.preferredColorScheme(.dark) }
}
struct ProfileView: View {
     var body: some View { ZStack { Color.viewBackground.edgesIgnoringSafeArea(.all); Text("User Profile Screen") }.preferredColorScheme(.dark) }
}

// MARK: - Sheet Views (Placeholders / Simple Examples)
struct AddSalaryView: View {
    @Environment(\.presentationMode) var presentationMode // To dismiss the sheet
    @EnvironmentObject var viewModel: SalaryViewModel // Access ViewModel to add data
    
    // State for form fields
    @State private var companyName: String = ""
    @State private var location: String = ""
    @State private var levelName: String = ""
    @State private var levelTag: String = ""
    @State private var totalCompStr: String = "" // Use String for TextField input
    @State private var baseStr: String = ""
    @State private var stockStr: String = ""
    @State private var bonusStr: String = ""

    // Basic validation
    var isFormValid: Bool {
        !companyName.isEmpty && !levelName.isEmpty && Int(totalCompStr) != nil
        // Add more checks as needed
    }

    var body: some View {
        NavigationView { // Embed in NavigationView for title and toolbar
            Form { // Use Form for standard iOS input layout
                Section("Company & Role") {
                    TextField("Company Name", text: $companyName)
                    TextField("Location (e.g., City, ST)", text: $location)
                    TextField("Level Name (e.g., L5, SDE II)", text: $levelName)
                    TextField("Level Tag (e.g., Backend, iOS)", text: $levelTag)
                }

                Section("Compensation (USD)") {
                     TextField("Total Compensation", text: $totalCompStr).keyboardType(.numberPad)
                     TextField("Base Salary", text: $baseStr).keyboardType(.numberPad)
                     TextField("Stock / Year", text: $stockStr).keyboardType(.numberPad)
                     TextField("Bonus", text: $bonusStr).keyboardType(.numberPad)
                 }
            }
            .navigationTitle("Add Salary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveSalary() }
                     .disabled(!isFormValid) // Disable save if form invalid
                }
            }
            .preferredColorScheme(.dark) // Match theme in sheet
        }
    }
    
    func saveSalary() {
        // Convert strings to Ints, handle potential errors gracefully
        let totalComp = Int(totalCompStr) ?? 0
        let base = Int(baseStr) ?? 0
        let stock = Int(stockStr) ?? 0
        let bonus = Int(bonusStr) ?? 0

        let newSubmission = SalarySubmission(
            companyName: companyName,
            companyLogoName: logoName(for: companyName), // Determine logo
            location: location,
            date: "Just now", // Use current time
            levelName: levelName,
            levelTag: levelTag,
            totalComp: totalComp,
            base: base,
            stock: stock,
            bonus: bonus
        )
        
        viewModel.addSalary(newSubmission) // Add to ViewModel
        presentationMode.wrappedValue.dismiss() // Close sheet
    }

     // Helper to guess logo based on name (basic)
    func logoName(for company: String) -> String {
        let lowercasedName = company.lowercased()
        if lowercasedName.contains("google") { return "g.circle.fill" }
        if lowercasedName.contains("amazon") { return "a.circle.fill" }
        if lowercasedName.contains("meta") || lowercasedName.contains("facebook") { return "m.circle.fill" }
        if lowercasedName.contains("apple") { return "apple.logo" }
        if lowercasedName.contains("cruise") { return "c.circle.fill" }
        // Add more mappings
        return "building.2.crop.circle.fill" // Default generic logo
    }
}

struct FilterOptionsView: View {
     @Environment(\.presentationMode) var presentationMode
     @EnvironmentObject var viewModel: SalaryViewModel
     // Add @State variables for filter options (e.g., location, level, etc.)

     var body: some View {
         NavigationView {
             Form {
                 Text("Add filter controls here...")
                 // Example: Picker for location, toggles for remote, etc.
             }
             .navigationTitle("Filter Options")
             .navigationBarTitleDisplayMode(.inline)
             .toolbar {
                 ToolbarItem(placement: .navigationBarLeading) {
                     Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                 }
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button("Apply") {
                         // TODO: Update ViewModel with filter settings
                         presentationMode.wrappedValue.dismiss()
                     }
                 }
             }
              .preferredColorScheme(.dark)
         }
     }
}

// MARK: - Preview
struct SalaryView_Previews: PreviewProvider {
    static var previews: some View {
        SalaryView()
    }
}
