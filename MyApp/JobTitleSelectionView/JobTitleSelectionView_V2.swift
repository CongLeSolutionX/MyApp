//
//  JobTitleSelectionView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/7/25.
//

import SwiftUI
import Combine // Needed for Debouncing

// Represents a single job title item
struct JobTitle: Identifiable, Hashable { // Conform to Hashable for potential future use
    let id = UUID()
    let name: String
}

@MainActor // Ensures UI updates happen on the main thread
class JobTitleViewModel: ObservableObject {
    
    // --- Inputs / Published Properties ---
    @Published var searchText: String = ""
    @Published var allJobTitles: [JobTitle] = [] // Source of truth
    @Published var filteredJobTitles: [JobTitle] = [] // For the UI list
    @Published var isRequestSheetPresented: Bool = false // Controls the "Request Title" sheet
    
    // --- Private Properties for Debouncing ---
    private var cancellables = Set<AnyCancellable>()
    
    // --- Mock Data Loading ---
    init(mockJobs: [JobTitle]? = nil) {
        // Use provided mock data or load default
        self.allJobTitles = mockJobs ?? loadDefaultJobs()
        self.filteredJobTitles = self.allJobTitles // Initially show all
        setupSearchDebouncing()
    }
    
    // --- Setup Debouncing for Search ---
    private func setupSearchDebouncing() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main) // Wait 300ms after user stops typing
            .removeDuplicates() // Only process if the text actually changed
            .sink { [weak self] searchText in
                self?.filterJobs(query: searchText)
            }
            .store(in: &cancellables)
    }
    
    // --- Filtering Logic ---
    private func filterJobs(query: String) {
        if query.isEmpty {
            filteredJobTitles = allJobTitles
        } else {
            // Simple case-insensitive search
            filteredJobTitles = allJobTitles.filter {
                $0.name.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
    // --- Action Triggers ---
    func presentRequestSheet() {
        isRequestSheetPresented = true
    }
    
    // --- Mock Data Loader (Replace with actual data fetching) ---
    private func loadDefaultJobs() -> [JobTitle] {
        return [
            JobTitle(name: "Software Engineer"),
            JobTitle(name: "iOS Engineer"),
            JobTitle(name: "Android Engineer"),
            JobTitle(name: "Product Manager"),
            JobTitle(name: "Data Scientist"),
            JobTitle(name: "Data Analyst"),
            JobTitle(name: "Software Engineering Manager"),
            JobTitle(name: "Technical Program Manager"),
            JobTitle(name: "Solution Architect"),
            JobTitle(name: "Program Manager"),
            JobTitle(name: "UX Designer"),
            JobTitle(name: "UI Designer"),
            JobTitle(name: "QA Engineer")
        ].sorted { $0.name < $1.name } // Sort alphabetically
    }
}
struct FunctionalJobTitleSelectionView: View {
    
    // Initialize directly here. SwiftUI handles the context correctly.
    @StateObject private var viewModel = JobTitleViewModel()
    
    // Environment variable to dismiss the sheet
    @Environment(\.dismiss) var dismiss
    
    // Closure to call when a title is selected
    let onSelect: (JobTitle) -> Void
    
    // REMOVE the custom initializer IF you don't need to pass specific
    // data *to the view itself* during creation.
    // If you ONLY needed the init to create the ViewModel, it's no longer needed.
    
    // --- OR --- Keep a simplified init if you need parameters for the VIEW
    // (like `onSelect`) but DON'T initialize the ViewModel here.
    init(onSelect: @escaping (JobTitle) -> Void) {
        self.onSelect = onSelect
        // DO NOT initialize _viewModel here. SwiftUI does it.
    }
    
    var body: some View {
        // ... rest of your body code remains the same ...
        // It will use the `viewModel` instance that SwiftUI correctly initialized.
        
        VStack(spacing: 0) {
            // 1. Sheet Handle
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.vertical, 8)
            
            // 2. Search Bar (binding to ViewModel)
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search job families", text: $viewModel.searchText) // Use viewModel directly
                    .foregroundColor(.white)
                    .accentColor(.blue)
                    .submitLabel(.search)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.gray.opacity(0.25))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom)
            
            // 3. Request Button (triggers ViewModel action)
            Button(action: viewModel.presentRequestSheet) { // Use viewModel directly
                HStack {
                    Image(systemName: "plus")
                    Text("Request My Title")
                }
                .foregroundColor(Color(UIColor.systemBlue))
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            // 4. Section Header (Could be dynamic if needed)
            Text("TECHNOLOGY")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 8)
            
            // 5. Job Title List (data from ViewModel)
            ScrollViewReader { scrollProxy in
                ScrollView {
                    // Use viewModel directly here too...
                    if viewModel.filteredJobTitles.isEmpty && !viewModel.searchText.isEmpty {
                        Text("No results found for \"\(viewModel.searchText)\"")
                            .foregroundColor(.gray)
                            .padding(.top, 30)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .id("EmptyState")
                    } else {
                        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: []) {
                            ForEach(viewModel.filteredJobTitles) { jobTitle in
                                JobTitleRow(title: jobTitle.name) {
                                    onSelect(jobTitle)
                                    dismiss()
                                }
                                .id(jobTitle.id)
                                if jobTitle.id != viewModel.filteredJobTitles.last?.id {
                                    Divider().background(Color.gray.opacity(0.3)).padding(.leading)
                                }
                            }
                        }
                        .padding(.top, 5)
                        .id("JobListContent")
                    }
                }
                .onChange(of: viewModel.searchText) {
                    // Scroll to top when search text changes significantly (optional)
                    // Could scroll to "EmptyState" or "JobListContent"
                    withAnimation {
                        scrollProxy.scrollTo(viewModel.filteredJobTitles.isEmpty ? "EmptyState" : "JobListContent", anchor: .top)
                    }
                }
            }
            .frame(maxHeight: .infinity)
            
        }
        .padding(.top, 5)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .preferredColorScheme(.dark)
        .sheet(isPresented: $viewModel.isRequestSheetPresented) { // Use viewModel directly
            RequestTitleView { requestedTitle in
                print("User requested title: \(requestedTitle)")
                viewModel.isRequestSheetPresented = false
                 dismiss() // Optional
            }
        }
    }
}
//
//struct FunctionalJobTitleSelectionView: View {
//
//    // Use @StateObject for owning the ViewModel instance within this sheet's lifecycle
//    @StateObject private var viewModel: JobTitleViewModel
//
//    // Environment variable to dismiss the sheet
//    @Environment(\.dismiss) var dismiss
//
//    // Closure to call when a title is selected
//    let onSelect: (JobTitle) -> Void
//
//    // Initializer to inject ViewModel or dependencies
//    init(viewModel: JobTitleViewModel = JobTitleViewModel(), onSelect: @escaping (JobTitle) -> Void) {
//        _viewModel = StateObject(wrappedValue: viewModel)
//        self.onSelect = onSelect
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // 1. Sheet Handle
//            Capsule()
//                .fill(Color.gray.opacity(0.5))
//                .frame(width: 40, height: 5)
//                .padding(.vertical, 8)
//
//            // 2. Search Bar (binding to ViewModel)
//            HStack {
//                Image(systemName: "magnifyingglass")
//                    .foregroundColor(.gray)
//
//                TextField("Search job families", text: $viewModel.searchText)
//                    .foregroundColor(.white)
//                    .accentColor(.blue)
//                    .submitLabel(.search) // Adds semantic meaning
//                    .autocorrectionDisabled() // Often useful for search fields
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 10)
//            .background(Color.gray.opacity(0.25))
//            .cornerRadius(10)
//            .padding(.horizontal)
//            .padding(.bottom)
//
//            // 3. Request Button (triggers ViewModel action)
//            Button(action: viewModel.presentRequestSheet) { // Use ViewModel action
//                HStack {
//                    Image(systemName: "plus")
//                    Text("Request My Title")
//                }
//                .foregroundColor(Color(UIColor.systemBlue))
//                .padding(.vertical, 10)
//                .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            .padding(.horizontal)
//            .padding(.bottom)
//
//            // 4. Section Header (Could be dynamic if needed)
//            Text("TECHNOLOGY") // Kept static for simplicity
//                .font(.caption)
//                .foregroundColor(.gray)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal)
//                .padding(.bottom, 8)
//
//            // 5. Job Title List (data from ViewModel)
//            ScrollViewReader { scrollProxy in // Allows scrolling to top if needed
//                ScrollView {
//                    if viewModel.filteredJobTitles.isEmpty && !viewModel.searchText.isEmpty {
//                         // Empty State when search yields no results
//                         Text("No results found for \"\(viewModel.searchText)\"")
//                             .foregroundColor(.gray)
//                             .padding(.top, 30)
//                             .frame(maxWidth: .infinity, alignment: .center)
//                             .id("EmptyState") // ID for ScrollViewReader
//                    } else {
//                        // List Content
//                        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: []) { // LazyVStack is efficient
//                            ForEach(viewModel.filteredJobTitles) { jobTitle in
//                                JobTitleRow(title: jobTitle.name) {
//                                    // Action on tap: call callback and dismiss
//                                    onSelect(jobTitle)
//                                    dismiss()
//                                }
//                                .id(jobTitle.id) // ID for ScrollViewReader
//
//                                // Optional Divider
//                                if jobTitle.id != viewModel.filteredJobTitles.last?.id {
//                                     Divider().background(Color.gray.opacity(0.3)).padding(.leading)
//                                }
//                            }
//                        }
//                        .padding(.top, 5) // Add padding above the list content
//                        .id("JobListContent") // ID for ScrollViewReader
//                    }
//                }
//                .onChange(of: viewModel.searchText) { _ in
//                    // Scroll to top when search text changes significantly (optional)
//                    // Could scroll to "EmptyState" or "JobListContent"
//                    // withAnimation {
//                    //    scrollProxy.scrollTo(viewModel.filteredJobTitles.isEmpty ? "EmptyState" : "JobListContent", anchor: .top)
//                    // }
//                }
//            }
//            .frame(maxHeight: .infinity) // Occupy remaining space
//
//        }
//        .padding(.top, 5)
//        .background(Color.black.edgesIgnoringSafeArea(.all))
//        .preferredColorScheme(.dark)
//        // 6. Present the "Request Title" sheet
//        .sheet(isPresented: $viewModel.isRequestSheetPresented) {
//            RequestTitleView { requestedTitle in
//                print("User requested title: \(requestedTitle)")
//                // Handle the requested title (e.g., send to backend)
//                // Optionally dismiss the main sheet too, or show confirmation
//                viewModel.isRequestSheetPresented = false // Dismiss request sheet
//                 // dismiss() // Optional: dismiss the main sheet after request
//            }
//        }
//    }
//}

// Simplified Row View with Action
struct JobTitleRow: View {
    let title: String
    let action: () -> Void // Closure for tap action
    
    var body: some View {
        Button(action: action) { // Execute the passed-in action
            HStack(spacing: 15) {
                Image(systemName: "briefcase")
                    .foregroundColor(.gray)
                
                Text(title)
                    .foregroundColor(.white) // White text color
                
                Spacer() // Pushes content to the left
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
struct RequestTitleView: View {
    @State private var requestedTitle: String = ""
    @Environment(\.dismiss) var dismiss
    let onSubmit: (String) -> Void // Callback with the requested title
    
    var body: some View {
        NavigationView { // Add NavigationView for title/buttons
            VStack(spacing: 20) {
                Text("Enter the job title you couldn't find.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("Your Job Title", text: $requestedTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button("Submit Request") {
                    if !requestedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        onSubmit(requestedTitle)
                        // Dismissal is handled by the parent view now
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(requestedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // Disable if empty
                
                Spacer() // Pushes content up
            }
            .padding(.top, 30)
            .navigationTitle("Request Job Title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .preferredColorScheme(.dark) // Match theme
            .background(Color.black.opacity(0.9).ignoresSafeArea()) // Background for request sheet body
        }
    }
}

struct JobTitleSelectionView: View {
    @State private var showingJobSheet = false
    @State private var selectedJobTitle: JobTitle? = nil // Store the selected JobTitle
    
    // You might inject a shared ViewModel instance here if needed across views
    // For this example, the sheet creates its own instance.
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Selected Job Title:")
                    .font(.title2)
                
                Text(selectedJobTitle?.name ?? "None Selected")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                Button("Select Job Title") {
                    selectedJobTitle = nil // Clear previous selection before showing sheet
                    showingJobSheet = true
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile Setup")
            .sheet(isPresented: $showingJobSheet) {
                // Present the functional sheet
                FunctionalJobTitleSelectionView { selectedTitle in
                    // This closure is called when a title is selected inside the sheet
                    self.selectedJobTitle = selectedTitle
                    // Dismissal is handled inside the sheet row action now
                    // showingJobSheet = false // No longer needed here if dismiss() is called inside
                }
            }
            .preferredColorScheme(.dark) // Example: Have the parent view also dark
        }
    }
}

#Preview("JobTitleSelectionView") {
    JobTitleSelectionView()
}
