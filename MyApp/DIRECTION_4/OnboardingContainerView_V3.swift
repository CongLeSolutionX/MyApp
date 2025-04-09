//
//  OnboardingContainerView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI
import Combine // Useful for more advanced state management or keyboard handling if needed

// --- Enums for Choices (Unchanged) ---
enum ContributionFrequency: String, CaseIterable, Identifiable, Codable { // Added Codable
    case oneTime = "One-Time"
    case weekly = "Weekly"
    case biWeekly = "Bi-Weekly"
    case monthly = "Monthly"
    var id: String { self.rawValue }
}

enum InvestmentStrategy: String, CaseIterable, Identifiable, Codable { // Added Codable
    case conservative = "Conservative"
    case moderate = "Moderate"
    case aggressive = "Aggressive"
    var id: String { self.rawValue }
}

// --- Mock Data Model for User Settings (NEW) ---
// In a real app, this might be managed by a view model or data store (CoreData, UserDefaults, API)
struct UserContributionSettings: Codable {
    var contributionAmount: Double?
    var frequency: ContributionFrequency = .monthly // Default
    var strategy: InvestmentStrategy = .moderate // Default
    var isBankLinked: Bool = false // Default
    var termsAccepted: Bool = false // Default

    // Static mock instance for demonstration
    static var mock = UserContributionSettings()
}

// --- Data Model for Onboarding (Unchanged) ---
struct OnboardingPageData: Identifiable {
    let id = UUID()
    let imageName: String
    let primaryText: String
    let secondaryText: String
    let matchPercentage: Double?
    let showGetStarted: Bool
}

// --- Reusable Colors (Unchanged) ---
extension Color {
//    static let appDarkGreen = Color(red: 0.0, green: 0.15, blue: 0.1)
//    static let appLimeGreen = Color(red: 0.7, green: 1.0, blue: 0.35)
    static let appMutedGray = Color.gray.opacity(0.8)
    static let appErrorRed = Color.red.opacity(0.8)
}

// --- Main View Structure (Container - Logic Update for Sheet Data) ---
struct OnboardingContainerView: View {
    // Make onboardingPages static or load from a source if they don't change
    private static let onboardingPages: [OnboardingPageData] = [
        OnboardingPageData(imageName: "chart.pie.fill", primaryText: "Track your goals.", secondaryText: "Visualize your retirement journey and stay motivated.", matchPercentage: nil, showGetStarted: false),
        OnboardingPageData(imageName: "pencil.and.outline", primaryText: "You contribute.\nWe match.", secondaryText: "Instantly get up to 3% extra on every dollar you contribute. Every year.", matchPercentage: 3.0, showGetStarted: false),
        OnboardingPageData(imageName: "creditcard.fill", primaryText: "Link Your Bank.", secondaryText: "Securely connect your bank account for seamless contributions.", matchPercentage: nil, showGetStarted: false),
        OnboardingPageData(imageName: "lock.shield.fill", primaryText: "Secure & Insured.", secondaryText: "Your investments are protected with bank-level security.", matchPercentage: nil, showGetStarted: true)
    ]

    @State private var showingContributionSheet = false
    @State private var selectedTabIndex = 0 // Start at the first page (index 0)
    // Simulate persisted user settings (NEW)
    @State private var userSettings = UserContributionSettings.mock // Start with mock/default data

    var body: some View {
        TabView(selection: $selectedTabIndex) {
            ForEach(Array(Self.onboardingPages.enumerated()), id: \.element.id) { index, pageData in
                OnboardingPageView(
                    pageData: pageData,
                    showGetStartedButton: pageData.showGetStarted,
                    getStartedAction: {
                        showingContributionSheet = true
                    }
                )
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .sheet(isPresented: $showingContributionSheet) {
            // Fetch the percentage from the *currently viewed* page when sheet is shown
            let percentageForSheet = Self.onboardingPages[safe: selectedTabIndex]?.matchPercentage ?? 0.0
            ContributionSetupSheet(
                matchPercentage: percentageForSheet,
                // Pass the *current* settings to the sheet
                initialSettings: userSettings,
                // Provide a callback to update the main view's settings on save
                onSave: { updatedSettings in
                    self.userSettings = updatedSettings
                    print("✅ Settings updated in OnboardingContainerView: \(updatedSettings)")
                    // In a real app: Persist settings here (UserDefaults, CoreData, API call)
                }
            )
        }
        .background(Color.appDarkGreen.edgesIgnoringSafeArea(.all))
        .preferredColorScheme(.dark)
    }
}

// Helper to safely access array elements (Unchanged)
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// --- Individual Onboarding Page View (Accessibility Focus) ---
struct OnboardingPageView: View {
    let pageData: OnboardingPageData
    let showGetStartedButton: Bool
    let getStartedAction: () -> Void
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color.appDarkGreen.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                Spacer(minLength: 20)
                Image(systemName: pageData.imageName)
                    .resizable().scaledToFit().frame(width: 120, height: 120)
                    .foregroundColor(.appLimeGreen).padding(.bottom, 40)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .accessibilityHidden(true) // Hide decorative image from VoiceOver

                VStack(spacing: 15) {
                    Text(pageData.primaryText)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.appLimeGreen)
                        .multilineTextAlignment(.center).lineSpacing(4)
                        .accessibilityAddTraits(.isHeader) // Mark as header

                    Text(formatSecondaryText(pageData))
                        .font(.body).foregroundColor(.appMutedGray)
                        .multilineTextAlignment(.center).padding(.horizontal, 35)
                }
                .padding(.bottom, 30)
                Spacer()

                // Conditional Button
                if showGetStartedButton {
                    Button(action: getStartedAction) {
                        Text("Get started")
                            .font(.headline).fontWeight(.semibold)
                            .foregroundColor(.appDarkGreen)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Color.appLimeGreen).cornerRadius(25)
                            .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
                            .transition(.scale.combined(with: .opacity))
                    }
                    .padding(.horizontal, 20)
                    .id("GetStartedButton")
                } else {
                     // Use Spacer for consistent layout adjust
                     Spacer().frame(height: 50 + 16 * 2 + 20) // Match button vertical space + padding
                }
                 // Spacer moved inside the condition check area
            }
            .padding(.bottom, 20) // Consistent bottom padding
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                 isAnimating = true
             }
        }
        .accessibilityElement(children: .combine) // Combine text elements
        .accessibilityLabel("\(pageData.primaryText). \(formatSecondaryText(pageData))")
    }

    // Helper (Unchanged)
    private func formatSecondaryText(_ pageData: OnboardingPageData) -> String {
        if let percentage = pageData.matchPercentage {
            let formattedPercentage = String(format: percentage == floor(percentage) ? "%.0f%%" : "%.1f%%", percentage)
            return pageData.secondaryText.replacingOccurrences(of: "3%", with: formattedPercentage)
        }
        return pageData.secondaryText
    }
}

// --- Enhanced & Functional Modal Sheet View ---
struct ContributionSetupSheet: View {
    @Environment(\.dismiss) var dismiss
    let matchPercentage: Double
    let initialSettings: UserContributionSettings
    let onSave: (UserContributionSettings) -> Void // Callback to save changes

    // --- State Variables mirroring UserContributionSettings ---
    @State private var contributionAmountString: String = ""
    @State private var selectedFrequency: ContributionFrequency
    @State private var selectedStrategy: InvestmentStrategy
    @State private var isBankLinked: Bool
    @State private var termsAccepted: Bool

    // --- UI State ---
    @State private var showingAlert = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var amountIsValid: Bool = false // Derived validation state
    @FocusState private var amountFieldIsFocused: Bool // To dismiss keyboard

    // --- Constants ---
    private let maxContributionLimit: Double = 7000.00 // Example IRA limit for 2024 (adjust as needed)

    // --- Computed Property for Confirmation Button ---
    var isConfirmationDisabled: Bool {
        !amountIsValid || !isBankLinked || !termsAccepted
    }

     // Initialize state from initialSettings
    init(matchPercentage: Double, initialSettings: UserContributionSettings, onSave: @escaping (UserContributionSettings) -> Void) {
        self.matchPercentage = matchPercentage
        self.initialSettings = initialSettings
        self.onSave = onSave

        // Initialize @State variables from the passed initialSettings
        _contributionAmountString = State(initialValue: initialSettings.contributionAmount.map { String(format: "%.2f", $0) } ?? "")
        _selectedFrequency = State(initialValue: initialSettings.frequency)
        _selectedStrategy = State(initialValue: initialSettings.strategy)
        _isBankLinked = State(initialValue: initialSettings.isBankLinked)
        _termsAccepted = State(initialValue: initialSettings.termsAccepted)

        // Perform initial validation on load
        // Need to do this slightly differently as `validateAmount` uses the @State var
        // We'll call validate in onAppear
    }

    var body: some View {
        NavigationView {
            Form {
                // --- Section 1: Contribution Details ---
                Section { // Header outside for cleaner look if needed
                    VStack(alignment: .leading, spacing: 5) { // Add spacing
                        HStack {
                            Text("Amount ($)")
                                .foregroundColor(.appMutedGray)
                            Spacer()
                            TextField("0.00", text: $contributionAmountString)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .focused($amountFieldIsFocused) // Bind focus state
                                .onChange(of: contributionAmountString) { newValue in
                                    validateAmount(newValue)
                                }
                                .accessibilityLabel("Contribution Amount")
                                .accessibilityHint("Enter the amount you wish to contribute.")
                                // Use overlay for border to avoid layout shifts
                                .overlay(
                                     RoundedRectangle(cornerRadius: 5)
                                         .stroke(amountIsValid || contributionAmountString.isEmpty ? Color.clear : Color.appErrorRed, lineWidth: 1)
                                 )
                        }

                        // Validation Feedback Text
                        if !amountIsValid && !contributionAmountString.isEmpty {
                             Text("Enter a valid amount (e.g., 50.00) up to $\(String(format: "%.0f", maxContributionLimit)).")
                                .font(.caption)
                                .foregroundColor(.appErrorRed)
                                .transition(.opacity.combined(with: .scale(scale: 0.9))) // Add animation
                        }
                         // Display potential match amount dynamically
                        if let amountValue = Double(contributionAmountString), amountValue > 0, matchPercentage > 0 {
                             let matchValue = amountValue * (matchPercentage / 100.0)
                             Text("Potential Match: \(formatCurrency(matchValue)) (\(formatPercentage(matchPercentage)))")
                                 .font(.caption)
                                 .foregroundColor(.appLimeGreen)
                                 .padding(.top, 2)
                                 .transition(.opacity)
                         }

                    } // End VStack for Amount+Validation

                    Picker("Frequency", selection: $selectedFrequency) {
                        ForEach(ContributionFrequency.allCases) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                    .accessibilityLabel("Contribution Frequency")
                     .accessibilityHint("Select how often you want to contribute.")

                } header: { // Use standard header placement
                    Text("Contribution Details")
                         // .foregroundColor(.appMutedGray) // Default Form header color is often sufficient
                }
                 .listRowBackground(Color.secondary.opacity(0.1)) // Subtle background

                // --- Section 2: Investment Setup ---
                Section("Investment Setup") {
                     Picker("Investment Strategy", selection: $selectedStrategy) {
                         ForEach(InvestmentStrategy.allCases) { strategy in
                             Text(strategy.rawValue).tag(strategy)
                         }
                     }
                     .pickerStyle(.menu) // Good default for potentially longer lists
                     .accessibilityLabel("Investment Strategy")
                     .accessibilityHint("Choose your risk tolerance.")

                     Button(action: simulateBankLinking) {
                         HStack {
                             Image(systemName: isBankLinked ? "checkmark.circle.fill" : "link.circle.fill")
                                 .foregroundColor(isBankLinked ? .appLimeGreen : .accentColor)
                             Text(isBankLinked ? "Bank Account Linked" : "Link Bank Account")
                                 .foregroundColor(isBankLinked ? .appMutedGray : .accentColor) // Adjust color when linked
                             Spacer()
                             if !isBankLinked {
                                 Image(systemName: "chevron.right")
                                     .foregroundColor(.gray.opacity(0.5)) // Subtler chevron
                             }
                         }
                     }
                     .disabled(isBankLinked) // Disable if already linked
                     .accessibilityHint(isBankLinked ? "Your bank account is linked." : "Tap to securely link your bank account.")
                 }
                  .listRowBackground(Color.secondary.opacity(0.1))

                // --- Section 3: Agreement ---
                Section("Agreement") {
                    Toggle(isOn: $termsAccepted) {
                        // Use AttributedString for link appearance
                        Text(.init("I agree to the [Terms & Conditions](https://example.com/terms)")) // Use .init for markdown
                           .font(.footnote)
                           .accentColor(.appLimeGreen) // Make link color match theme
                    }
                    .tint(.appLimeGreen) // Color the toggle switch
                    .accessibilityLabel("Agree to Terms and Conditions")
                }
                  .listRowBackground(Color.secondary.opacity(0.1))

            } // End Form
            .scrollContentBackground(.hidden) // Make form background transparent
            .background(Color.appDarkGreen.edgesIgnoringSafeArea(.all)) // Set overall background
            .navigationTitle("IRA Setup")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                // Dismiss Keyboard Toolbar Item (NEW)
                ToolbarItemGroup(placement: .keyboard) {
                     Spacer() // Pushes button to the right
                     Button("Done") {
                        amountFieldIsFocused = false // Dismiss keyboard
                     }
                    .foregroundColor(.appLimeGreen)
                 }

                // --- Standard Toolbar Buttons ---
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                    .foregroundColor(.appLimeGreen)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { confirmAndSaveChanges() } // Renamed action
                    .foregroundColor(isConfirmationDisabled ? .gray : .appLimeGreen) // Dynamic color
                    .disabled(isConfirmationDisabled) // Dynamic enable/disable state
                }
            }
            // --- Alert Presentation ---
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                 // Validate amount when the sheet appears, in case it was pre-filled
                validateAmount(contributionAmountString)
            }
        } // End NavigationView
    }

    // --- Helper Functions within the Sheet ---

    func validateAmount(_ amountString: String) {
        // Remove any currency symbols or commas first
        let cleanedString = amountString.filter("0123456789.".contains)

        if cleanedString.isEmpty {
            amountIsValid = false
            return
        }
        // Check if it's a valid positive number within limits
        if let amount = Double(cleanedString), amount > 0, amount <= maxContributionLimit {
            // Optional: Check for too many decimal places (allow only 2)
             let components = cleanedString.split(separator: ".")
             if components.count > 1 && components[1].count > 2 {
                 amountIsValid = false
             } else {
                 amountIsValid = true
             }
        } else {
            amountIsValid = false
        }

        // Update the string only if validation logic requires it (e.g., formatting)
        // For now, simple validation is enough.
        // self.contributionAmountString = formattedString if needed
    }

    func simulateBankLinking() {
        print("🏦 Initiating simulated bank linking flow...")
        // In a real app, this would present a Plaid Link SDK flow or similar webview
        // For simulation, just toggle the state after a short delay
        isBankLinked = false // Visually indicate process started (optional)

        // Show a loading indicator here if desired

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Simulate network/process time
            self.isBankLinked = true
            print("🏦 Simulated bank linking successful.")
            showAlert(title: "Bank Linked", message: "Your bank account has been securely linked.")
        }
    }

    func confirmAndSaveChanges() {
         amountFieldIsFocused = false // Dismiss keyboard before showing alerts

        // --- Re-validate just before saving (belt and suspenders) ---
        validateAmount(contributionAmountString) // Ensure validation state is current

        guard amountIsValid, let finalAmount = Double(contributionAmountString.filter("0123456789.".contains)) else {
            showAlert(title: "Invalid Amount", message: "Please enter a valid contribution amount up to $\(String(format: "%.0f", maxContributionLimit)).")
            return
        }
        guard isBankLinked else {
            showAlert(title: "Bank Not Linked", message: "Please link your bank account before saving.")
            return
        }
        guard termsAccepted else {
            showAlert(title: "Terms Not Accepted", message: "Please accept the Terms & Conditions to proceed.")
            return
        }

        // --- All Validations Passed ---

        // Construct the updated settings object
        let updatedSettings = UserContributionSettings(
            contributionAmount: finalAmount,
            frequency: selectedFrequency,
            strategy: selectedStrategy,
            isBankLinked: isBankLinked,
            termsAccepted: termsAccepted // Persist terms acceptance if needed
        )

        print("💾 Simulating Save Operation...")
        print("--- Settings to Save ---")
        print("Amount: \(formatCurrency(finalAmount))")
        print("Frequency: \(selectedFrequency.rawValue)")
        print("Strategy: \(selectedStrategy.rawValue)")
        print("Bank Linked: \(isBankLinked)")
        print("Terms Accepted: \(termsAccepted)")
        print("Match Rate Applied: \(formatPercentage(matchPercentage))")
        print("------------------------")

        // Call the save callback provided by the parent view
        onSave(updatedSettings)

        // Show success feedback to the user
        showAlert(title: "Settings Saved", message: "Your IRA contribution setup for \(formatCurrency(finalAmount)) (\(selectedFrequency.rawValue)) has been saved.")

        // Dismiss the sheet *after* the alert is shown (user needs to tap OK on alert first)
        // Auto-dismissal might happen too quickly. If needed:
        // DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        //     dismiss()
        // }
        // OR dismiss when the alert's OK button is tapped (more complex setup needed)
         // For simplicity, let the user dismiss manually after tapping OK on the alert.
         // If auto-dismiss is crucial, the alert completion handler is the place.

         // Let's keep it simple: dismiss after showing alert. User taps OK then sheet can be closed.
         // We could even chain the dismiss to the alert button if needed. For now, manual dismissal after OK is fine.
    }

    func showAlert(title: String, message: String) {
        self.alertTitle = title
        self.alertMessage = message
        self.showingAlert = true
    }

    // --- Formatting Helpers ---
    func formatPercentage(_ percentage: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = (percentage == floor(percentage)) ? 0 : 1 // Show decimal only if needed
        formatter.minimumFractionDigits = 0
        formatter.multiplier = 1 // Percentage is already 0-100
        return formatter.string(from: NSNumber(value: percentage)) ?? "\(percentage)%"
    }

    func formatCurrency(_ value: Double) -> String {
         let formatter = NumberFormatter()
         formatter.numberStyle = .currency
         formatter.maximumFractionDigits = 2
         formatter.minimumFractionDigits = 2
         // Optional: Set locale if needed: formatter.locale = Locale(identifier: "en_US")
         return formatter.string(from: NSNumber(value: value)) ?? "$\(String(format: "%.2f", value))"
     }
}

// --- Preview Provider (Enhanced for Sheet Testing) ---
struct OnboardingContainerView_Previews: PreviewProvider {
    // Create a stateful wrapper for previewing the sheet interaction
    struct PreviewWrapper: View {
        @State private var settings = UserContributionSettings(contributionAmount: 50.0, isBankLinked: false) // Example starting state
        @State private var showingSheet = true // Start with sheet shown

        var body: some View {
            Text("Background View (for Preview)")
                .sheet(isPresented: $showingSheet) {
                     ContributionSetupSheet(
                        matchPercentage: 3.0, // Example match
                        initialSettings: settings,
                        onSave: { updatedSettings in
                            print("Preview Save Callback: \(updatedSettings)")
                            self.settings = updatedSettings
                            // Optionally hide sheet after save in preview:
                            // self.showingSheet = false
                        }
                    )
                }
        }
    }

    static var previews: some View {
        Group {
            // Preview the main onboarding flow
            OnboardingContainerView()
                .previewDisplayName("Onboarding Flow")

            // Preview the sheet directly using the wrapper
            PreviewWrapper()
                 .previewDisplayName("Contribution Sheet")

             // Preview specific states of the sheet
             ContributionSetupSheet(
                 matchPercentage: 0.0,
                 initialSettings: UserContributionSettings(contributionAmount: 1000.0, isBankLinked: true, termsAccepted: true),
                 onSave: { _ in }
             )
             .previewDisplayName("Sheet - Linked & Accepted")
        }
    }
}
