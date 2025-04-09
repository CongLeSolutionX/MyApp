////
////  OnboardingContainerView_Previews.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import SwiftUI
//import Combine // Needed for keyboard handling publishers (optional but good practice)
//
//// --- Enums for Choices ---
//enum ContributionFrequency: String, CaseIterable, Identifiable {
//    case oneTime = "One-Time"
//    case weekly = "Weekly"
//    case biWeekly = "Bi-Weekly"
//    case monthly = "Monthly"
//    var id: String { self.rawValue }
//}
//
//enum InvestmentStrategy: String, CaseIterable, Identifiable {
//    case conservative = "Conservative"
//    case moderate = "Moderate"
//    case aggressive = "Aggressive"
//    var id: String { self.rawValue }
//}
//
//// --- Data Model (Unchanged) ---
//struct OnboardingPageData: Identifiable {
//    let id = UUID()
//    let imageName: String
//    let primaryText: String
//    let secondaryText: String
//    let matchPercentage: Double?
//    let showGetStarted: Bool
//}
//
//// --- Reusable Colors (Unchanged) ---
//extension Color {
////    static let appDarkGreen = Color(red: 0.0, green: 0.15, blue: 0.1)
////    static let appLimeGreen = Color(red: 0.7, green: 1.0, blue: 0.35)
//    static let appMutedGray = Color.gray.opacity(0.8)
//    static let appErrorRed = Color.red.opacity(0.8)
//}
//
//// --- Main View Structure (Container - Unchanged conceptually) ---
//struct OnboardingContainerView: View {
//    @State private var onboardingPages: [OnboardingPageData] = [
//        OnboardingPageData(imageName: "chart.pie.fill", primaryText: "Track your goals.", secondaryText: "Visualize your retirement journey and stay motivated.", matchPercentage: nil, showGetStarted: false),
//        OnboardingPageData(imageName: "pencil.and.outline", primaryText: "You contribute.\nWe match.", secondaryText: "Instantly get up to 3% extra on every dollar you contribute. Every year.", matchPercentage: 3.0, showGetStarted: false),
//        OnboardingPageData(imageName: "creditcard.fill", primaryText: "Link Your Bank.", secondaryText: "Securely connect your bank account for seamless contributions.", matchPercentage: nil, showGetStarted: false), // Added Bank Link info page
//        OnboardingPageData(imageName: "lock.shield.fill", primaryText: "Secure & Insured.", secondaryText: "Your investments are protected with bank-level security.", matchPercentage: nil, showGetStarted: true)
//    ]
//    @State private var showingContributionSheet = false
//    @State private var selectedTabIndex = 0 // Start at the first page (index 0)
//
//    var body: some View {
//        TabView(selection: $selectedTabIndex) {
//            ForEach(Array(onboardingPages.enumerated()), id: \.element.id) { index, pageData in
//                 // Use the currently selected page's data for the sheet
//                let relevantMatchPercentage = onboardingPages[safe: selectedTabIndex]?.matchPercentage ?? 0.0
//
//                OnboardingPageView(
//                    pageData: pageData,
//                    // Determine if *this specific page* should show the button
//                    showGetStartedButton: pageData.showGetStarted,
//                    getStartedAction: {
//                        showingContributionSheet = true
//                    }
//                )
//                .tag(index)
//            }
//        }
//        .tabViewStyle(.page(indexDisplayMode: .always))
//        .indexViewStyle(.page(backgroundDisplayMode: .always))
//        // Pass the relevant percentage *at the time the sheet is presented*
//        .sheet(isPresented: $showingContributionSheet) {
//             // Fetch the percentage from the *currently viewed* page when sheet is shown
//            let percentageForSheet = onboardingPages[safe: selectedTabIndex]?.matchPercentage ?? 0.0
//            ContributionSetupSheet(matchPercentage: percentageForSheet)
//        }
//        .background(Color.appDarkGreen.edgesIgnoringSafeArea(.all))
//        .preferredColorScheme(.dark)
//    }
//}
//
//// Helper to safely access array elements
//extension Array {
//    subscript(safe index: Int) -> Element? {
//        return indices.contains(index) ? self[index] : nil
//    }
//}
//
//// --- Individual Onboarding Page View (Minor Update) ---
//struct OnboardingPageView: View {
//    let pageData: OnboardingPageData
//    let showGetStartedButton: Bool // Renamed for clarity
//    let getStartedAction: () -> Void
//    @State private var isAnimating = false
//
//    var body: some View {
//        ZStack {
//            Color.appDarkGreen.edgesIgnoringSafeArea(.all)
//            VStack(spacing: 0) {
//                Spacer(minLength: 20)
//                Image(systemName: pageData.imageName)
//                    .resizable().scaledToFit().frame(width: 120, height: 120)
//                    .foregroundColor(.appLimeGreen).padding(.bottom, 40)
//                    .scaleEffect(isAnimating ? 1.05 : 1.0) // Slightly adjusted animation
//
//                VStack(spacing: 15) {
//                    Text(pageData.primaryText)
//                        .font(.system(size: 30, weight: .bold, design: .rounded)) // Slightly different font
//                        .foregroundColor(.appLimeGreen).multilineTextAlignment(.center).lineSpacing(4)
//                    Text(formatSecondaryText(pageData))
//                        .font(.body).foregroundColor(.appMutedGray)
//                        .multilineTextAlignment(.center).padding(.horizontal, 35) // Slightly adjust padding
//                }
//                .padding(.bottom, 30)
//                Spacer()
//
//                // --- Conditional Button ---
//                if showGetStartedButton {
//                    Button(action: getStartedAction) {
//                        Text("Get started")
//                            .font(.headline).fontWeight(.semibold)
//                            .foregroundColor(.appDarkGreen)
//                            .frame(maxWidth: .infinity).padding(.vertical, 16)
//                            .background(Color.appLimeGreen).cornerRadius(25)
//                            .shadow(color: .black.opacity(0.2), radius: 5, y: 3) // Add subtle shadow
//                            .transition(.scale.combined(with: .opacity))
//                    }
//                    .padding(.horizontal, 20)
//                    .id("GetStartedButton") // Add ID for potential UI testing
//                } else {
//                    Rectangle().fill(Color.clear)
//                        .frame(height: 50 + 16*2) // Keep consistent spacing
//                        .padding(.horizontal, 20)
//                }
//                Spacer(minLength: 60)
//            }
//            .padding(.bottom, 20)
//        }
//        .onAppear {
//            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
//                 isAnimating = true
//             }
//        }
//        // Add accessibility labels
//        .accessibilityElement(children: .combine) // Combine elements for better reading order
//        .accessibilityLabel("\(pageData.primaryText). \(formatSecondaryText(pageData))")
//    }
//
//    // Helper (Unchanged)
//    private func formatSecondaryText(_ pageData: OnboardingPageData) -> String {
//        if let percentage = pageData.matchPercentage {
//            let formattedPercentage = String(format: percentage == floor(percentage) ? "%.0f%%" : "%.1f%%", percentage)
//            return pageData.secondaryText.replacingOccurrences(of: "3%", with: formattedPercentage)
//        }
//        return pageData.secondaryText
//    }
//}
//
//// --- Enhanced Modal Sheet View ---
//struct ContributionSetupSheet: View {
//    @Environment(\.dismiss) var dismiss
//    let matchPercentage: Double
//
//    // --- State Variables for Form ---
//    @State private var contributionAmount: String = ""
//    @State private var selectedFrequency: ContributionFrequency = .monthly // Sensible default
//    @State private var selectedStrategy: InvestmentStrategy = .moderate // Sensible default
//    @State private var isBankLinked: Bool = false // Simulate link status
//    @State private var termsAccepted: Bool = false
//    @State private var showingAlert = false
//    @State private var alertTitle: String = ""
//    @State private var alertMessage: String = ""
//    @State private var amountIsValid: Bool = false
//
//    // --- Computed Property for Confirmation Button ---
//    var isConfirmationDisabled: Bool {
//        !amountIsValid || !isBankLinked || !termsAccepted
//    }
//
//    var body: some View {
//        NavigationView {
//            // Use Form for better grouping and standard iOS settings appearance
//            Form {
//                // --- Section 1: Contribution Details ---
//                Section(header: Text("Contribution Details").foregroundColor(.appMutedGray)) {
//                    HStack {
//                        Text("Amount ($)")
//                        Spacer()
//                        TextField("e.g., 100.00", text: $contributionAmount)
//                            .keyboardType(.decimalPad)
//                            .multilineTextAlignment(.trailing)
//                            .onChange(of: contributionAmount) { newValue in
//                                validateAmount(newValue)
//                            }
//                            // Add a visual cue for invalid input
//                            .border(amountIsValid || contributionAmount.isEmpty ? Color.clear : Color.appErrorRed, width: 1)
//                    }
//
//                    Picker("Frequency", selection: $selectedFrequency) {
//                        ForEach(ContributionFrequency.allCases) { frequency in
//                            Text(frequency.rawValue).tag(frequency)
//                        }
//                    }
//
//                    // Display the match info clearly
//                    HStack {
//                          Text("Eligible Match")
//                              .foregroundColor(matchPercentage > 0 ? .primary : .appMutedGray) // Dim if no match
//                          Spacer()
//                          Text(formatPercentage(matchPercentage))
//                              .fontWeight(.semibold)
//                              .foregroundColor(matchPercentage > 0 ? .appLimeGreen : .appMutedGray)
//                      }
//                }
//                 .listRowBackground(Color.appDarkGreen.opacity(0.6)) // Style form rows
//
//                // --- Section 2: Investment Setup ---
//                Section(header: Text("Investment Setup").foregroundColor(.appMutedGray)) {
//                    Picker("Investment Strategy", selection: $selectedStrategy) {
//                        ForEach(InvestmentStrategy.allCases) { strategy in
//                            Text(strategy.rawValue).tag(strategy)
//                        }
//                    }
//                    .pickerStyle(.menu) // Use menu style for space saving
//
//                    Button(action: simulateBankLinking) {
//                        HStack {
//                            Image(systemName: isBankLinked ? "checkmark.circle.fill" : "link.circle.fill")
//                                .foregroundColor(isBankLinked ? .appLimeGreen : .accentColor)
//                            Text(isBankLinked ? "Bank Account Linked" : "Link Bank Account")
//                            Spacer()
//                            if !isBankLinked {
//                                Image(systemName: "chevron.right")
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                    }
//                    .disabled(isBankLinked) // Disable if already linked
//                }
//                .listRowBackground(Color.appDarkGreen.opacity(0.6)) // Style form rows
//
//                // --- Section 3: Agreement ---
//                Section(header: Text("Agreement").foregroundColor(.appMutedGray)) {
//                    Toggle(isOn: $termsAccepted) {
//                        Text("I agree to the [Terms & Conditions](https://example.com)") // Example link
//                           .font(.footnote) // Smaller font for terms
//                    }
//                    .tint(.appLimeGreen) // Color the toggle switch
//                }
//                 .listRowBackground(Color.appDarkGreen.opacity(0.6)) // Style form rows
//
//            } // End Form
//            .scrollContentBackground(.hidden) // Make form background transparent
//            .background(Color.appDarkGreen.edgesIgnoringSafeArea(.all)) // Set overall background
//            .navigationTitle("IRA Setup")
//            .navigationBarTitleDisplayMode(.inline)
//            .preferredColorScheme(.dark)
//            .toolbar {
//                // --- Toolbar Buttons ---
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") { dismiss() }
//                    .foregroundColor(.appLimeGreen)
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Confirm") { confirmSetup() }
//                    .foregroundColor(isConfirmationDisabled ? .gray : .appLimeGreen) // Dynamic color
//                    .disabled(isConfirmationDisabled) // Dynamic enable/disable state
//                }
//            }
//            // --- Alert Presentation ---
//            .alert(isPresented: $showingAlert) {
//                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//            }
//        } // End NavigationView
//    }
//
//    // --- Helper Functions within the Sheet ---
//
//    func validateAmount(_ amountString: String) {
//        // Allow empty string initially
//        if amountString.isEmpty {
//            amountIsValid = false
//            return
//        }
//        // Check if it's a valid positive number
//        if let amount = Double(amountString), amount > 0 {
//            amountIsValid = true
//        } else {
//            amountIsValid = false
//        }
//    }
//
//    func simulateBankLinking() {
//        print("Initiating simulated bank linking flow...")
//        // In a real app, this would present a Plaid Link flow or similar
//        // For simulation, just toggle the state after a short delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            self.isBankLinked = true
//            print("Simulated bank linking successful.")
//            // Optionally show a success alert/message
//             // showAlert(title: "Success", message: "Bank account linked successfully.")
//        }
//    }
//
//    func confirmSetup() {
//        guard amountIsValid else {
//            showAlert(title: "Invalid Amount", message: "Please enter a valid positive contribution amount.")
//            return
//        }
//        guard isBankLinked else {
//            showAlert(title: "Bank Not Linked", message: "Please link your bank account before confirming.")
//            return
//        }
//        guard termsAccepted else {
//            showAlert(title: "Terms Not Accepted", message: "Please accept the Terms & Conditions.")
//            return
//        }
//
//        // --- All Validations Passed ---
//        print("--- Confirmation Details ---")
//        print("Amount: \(contributionAmount)")
//        print("Frequency: \(selectedFrequency.rawValue)")
//        print("Strategy: \(selectedStrategy.rawValue)")
//        print("Match Applied: \(formatPercentage(matchPercentage))")
//        print("--------------------------")
//
//        // Simulate saving data and show success
//        showAlert(title: "Setup Complete", message: "Your IRA contribution of $\(contributionAmount) (\(selectedFrequency.rawValue)) has been scheduled with the \(selectedStrategy.rawValue) strategy.")
//
//        // Dismiss the sheet after a short delay to allow reading the alert
//         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Adjust delay as needed
//             dismiss()
//         }
//    }
//
//    func showAlert(title: String, message: String) {
//        self.alertTitle = title
//        self.alertMessage = message
//        self.showingAlert = true
//    }
//
//    func formatPercentage(_ percentage: Double) -> String {
//        return String(format: percentage == floor(percentage) ? "%.0f%%" : "%.1f%%", percentage)
//    }
//}
//
//// --- Preview Provider (Updated to reflect changes) ---
//struct OnboardingContainerView_Previews: PreviewProvider {
//    static var previews: some View {
//        TabView {
//            OnboardingContainerView()
//                .tabItem { Label("Save", systemImage: "dollarsign.circle.fill") } // More relevant tab icon
//
//            Text("Placeholder Portfolio Tab").tabItem { Label("Portfolio", systemImage: "chart.bar.fill") }
//            Text("Placeholder Settings Tab").tabItem { Label("Settings", systemImage: "gear") }
//        }
//         // Preview the sheet directly for easier testing
//        // ContributionSetupSheet(matchPercentage: 5.0) // Preview sheet with a 5% match
//    }
//}
