////
////  OnboardingContainerView.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import SwiftUI
//
//// --- Data Model ---
//struct OnboardingPageData: Identifiable {
//    let id = UUID()
//    let imageName: String // SF Symbol name for placeholder graphic
//    let primaryText: String
//    let secondaryText: String
//    let matchPercentage: Double? // Optional: Only relevant for the matching page
//    let showGetStarted: Bool // Show button only on the last page? (or specific pages)
//}
//
//// --- Reusable Colors ---
//extension Color {
////    static let appDarkGreen = Color(red: 0.0, green: 0.15, blue: 0.1)
////    static let appLimeGreen = Color(red: 0.7, green: 1.0, blue: 0.35)
//    static let appMutedGray = Color.gray.opacity(0.8)
//}
//
//// --- Main View Structure (Container for the TabView) ---
//struct OnboardingContainerView: View {
//    // Mock data for the onboarding pages
//    @State private var onboardingPages: [OnboardingPageData] = [
//        OnboardingPageData(imageName: "chart.pie.fill",
//                           primaryText: "Track your goals.",
//                           secondaryText: "Visualize your retirement journey and stay motivated.",
//                           matchPercentage: nil,
//                           showGetStarted: false),
//        OnboardingPageData(imageName: "pencil.and.outline", // Use the specific icon for this page
//                           primaryText: "You contribute.\nWe match.",
//                           secondaryText: "Instantly get up to 3% extra on every dollar you contribute. Every year.",
//                           matchPercentage: 3.0, // Pass the specific match percentage
//                           showGetStarted: false), // Or true if it's the last page
//        OnboardingPageData(imageName: "lock.shield.fill",
//                           primaryText: "Secure & Insured.",
//                           secondaryText: "Your investments are protected with bank-level security.",
//                           matchPercentage: nil,
//                           showGetStarted: true) // Show button on the last page
//    ]
//
//    // State to control the modal sheet presentation
//    @State private var showingContributionSheet = false
//    // State to track the selected tab index for potential delegate actions
//    @State private var selectedTabIndex = 0
//
//    var body: some View {
//        // Use TabView with PageTabViewStyle for swipeable pages & dots
//        TabView(selection: $selectedTabIndex) {
//            ForEach(Array(onboardingPages.enumerated()), id: \.element.id) { index, pageData in
//                OnboardingPageView(
//                    pageData: pageData,
//                    isLastPage: index == onboardingPages.count - 1, // Pass if it's the last page
//                    getStartedAction: {
//                        showingContributionSheet = true // Trigger the sheet presentation
//                    }
//                )
//                .tag(index) // Tag each page for selection tracking
//            }
//        }
//        .tabViewStyle(.page(indexDisplayMode: .always)) // Use page style with always visible dots
//        .indexViewStyle(.page(backgroundDisplayMode: .always)) // Style dots background if needed
//        .sheet(isPresented: $showingContributionSheet) {
//            // Present the modal sheet when the state variable is true
//            ContributionSetupSheet(matchPercentage: onboardingPages[selectedTabIndex].matchPercentage ?? 0.0) // Pass relevant data
//        }
//        // Ensure the background color fills the entire safe area space
//        .background(Color.appDarkGreen.edgesIgnoringSafeArea(.all))
//        .preferredColorScheme(.dark) // Enforce dark mode appearance
//    }
//}
//
//// --- Individual Onboarding Page View ---
//struct OnboardingPageView: View {
//    let pageData: OnboardingPageData
//    let isLastPage: Bool // Determined by the container
//    let getStartedAction: () -> Void // Closure action for the button
//
//    // Internal state for potential animations or interactions on this specific page
//    @State private var isAnimating = false
//
//    var body: some View {
//        ZStack {
//            // Background for this specific page view (already set by container, but good practice)
//            Color.appDarkGreen
//                .edgesIgnoringSafeArea(.all)
//
//            VStack(spacing: 0) {
//
//                Spacer(minLength: 20)
//
//                // --- Graphic Section (Using SF Symbols as placeholders) ---
//                Image(systemName: pageData.imageName)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 120, height: 120)
//                    .foregroundColor(.appLimeGreen)
//                    .padding(.bottom, 40)
//                    .scaleEffect(isAnimating ? 1.1 : 1.0) // Example subtle animation
//
//                // --- Text Section ---
//                VStack(spacing: 15) {
//                    Text(pageData.primaryText)
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundColor(.appLimeGreen)
//                        .multilineTextAlignment(.center)
//                        .lineSpacing(4)
//
//                    // Use the dynamic match percentage if available
//                    let secondaryText = formatSecondaryText(pageData)
//                    Text(secondaryText)
//                        .font(.body)
//                        .foregroundColor(.appMutedGray)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal, 40)
//                }
//                .padding(.bottom, 30)
//
//                Spacer() // Push content up and button down
//
//                // --- Conditional Button ---
//                if pageData.showGetStarted {
//                    Button(action: getStartedAction) { // Call the passed-in action
//                        Text("Get started")
//                            .font(.headline)
//                            .fontWeight(.semibold)
//                            .foregroundColor(.appDarkGreen)
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 16)
//                            .background(Color.appLimeGreen)
//                            .cornerRadius(25)
//                            // Add a subtle transition effect
//                            .transition(.scale.combined(with: .opacity))
//                    }
//                    .padding(.horizontal, 20)
//                } else {
//                     // Maintain space even if button isn't shown, or use Spacer() here
//                     // depending on desired layout for non-button pages.
//                     // Adding a fixed height invisible element ensures consistent spacing.
//                     Rectangle()
//                        .fill(Color.clear)
//                        .frame(height: 50 + 16*2) // Approx height of button + padding
//                        .padding(.horizontal, 20)
//                }
//
//                 // Add space below button / above tab indicator dots
//                 // The TabView adds its own padding for the dots usually.
//                 Spacer(minLength: 60) // Increased space to avoid crowding dots
//
//            }
//            .padding(.bottom, 20) // Overall padding from bottom edge (adjust as needed)
//        }
//        .onAppear {
//            // Trigger animation when the page appears
//             withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
//                 isAnimating = true
//             }
//        }
//    }
//
//    // Helper to format the secondary text, incorporating the match %
//    private func formatSecondaryText(_ pageData: OnboardingPageData) -> String {
//        if let percentage = pageData.matchPercentage {
//            // Format the percentage cleanly (e.g., remove ".0")
//            let formattedPercentage = String(format: percentage == floor(percentage) ? "%.0f%%" : "%.1f%%", percentage)
//            // Replace placeholder or augment the text
//            return pageData.secondaryText.replacingOccurrences(of: "3%", with: formattedPercentage)
//        }
//        return pageData.secondaryText
//    }
//}
//
//// --- Modal Sheet View (Placeholder) ---
//struct ContributionSetupSheet: View {
//    @Environment(\.dismiss) var dismiss // Environment value to dismiss the sheet
//    let matchPercentage: Double // Example data passed in
//
//    @State private var contributionAmount: String = "" // Example state for input
//
//    var body: some View {
//        NavigationView { // Often useful to have a NavigationView for title/buttons in sheets
//            VStack(spacing: 20) {
//                Text("Set Up Your Contribution")
//                    .font(.title2).fontWeight(.bold)
//
//                Text("You're eligible for a \(formatPercentage(matchPercentage)) match!")
//                    .font(.headline)
//                    .foregroundColor(.appLimeGreen)
//
//                TextField("Enter initial contribution amount", text: $contributionAmount)
//                    .keyboardType(.decimalPad)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
//
//                // Add more setup controls here...
//                // E.g., Frequency selection, bank linking simulation etc.
//
//                Spacer() // Pushes content up
//
//                Button("Confirm Setup") {
//                    print("Contribution setup 'confirmed' with amount: \(contributionAmount)")
//                    // Add logic to save data, navigate further if needed
//                    dismiss() // Dismiss the sheet
//                }
//                .buttonStyle(.borderedProminent) // Use a standard prominent style
//                .tint(.appLimeGreen) // Tint the prominent button
//
//                Button("Cancel") {
//                    dismiss() // Dismiss the sheet
//                }
//                .padding(.top, 5)
//
//            }
//            .padding()
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.appDarkGreen.opacity(0.95).edgesIgnoringSafeArea(.all)) // Slightly different bg for sheet
//            .preferredColorScheme(.dark)
//            .navigationTitle("IRA Setup")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Close") {
//                        dismiss()
//                    }
//                    .foregroundColor(.appLimeGreen)
//                }
//            }
//        }
//    }
//
//     // Helper to format percentage within the sheet
//    private func formatPercentage(_ percentage: Double) -> String {
//        return String(format: percentage == floor(percentage) ? "%.0f%%" : "%.1f%%", percentage)
//    }
//}
//
//// --- Preview Provider ---
//struct OnboardingContainerView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Simulate being inside a main app structure (e.g., a TabView)
//        TabView {
//            OnboardingContainerView()
//                .tabItem {
//                    Label("Home", systemImage: "house.fill")
//                }
//
//            Text("Placeholder Settings Tab")
//                 .tabItem {
//                     Label("Settings", systemImage: "gear")
//                 }
//        }
//    }
//}
