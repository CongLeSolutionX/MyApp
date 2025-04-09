//
//  IRAOpeningFundingView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI
import Combine // Needed for keyboard handling, regex etc. (optional here but common)

// Mock Funding Source Structure
struct FundingSource: Identifiable, Hashable {
    let id = UUID().uuidString // Use UUID for unique ID
    let accountName: String
    let accountNumberLast4: String
    let institution: String

    var displayName: String {
        "\(accountName) (\(institution)) - \(accountNumberLast4)"
    }
}

struct IRAOpeningFundingView: View {
    // Passed from previous screen
    let selectedType: IRAAccountType

    // State for user inputs
    @State private var contributionAmountString: String = ""
    @State private var selectedFundingSourceId: String? = nil // Use ID for selection
    @State private var selectedContributionYear: Int = Calendar.current.component(.year, from: Date()) // Default to current year

    // State for form validation & navigation
    @State private var isAmountValid: Bool = false
    @State private var isFormValid: Bool = false
    @State private var navigateToConfirmation: Bool = false

    // Mock Data (replace with actual data fetching in a real app)
    @State private var availableFundingSources: [FundingSource] = [
        FundingSource(accountName: "Checking", accountNumberLast4: "1234", institution: "Bank A"),
        FundingSource(accountName: "Savings", accountNumberLast4: "5678", institution: "Bank B")
    ]
    // Determine applicable contribution years
    let contributionYears: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        // Allow previous year contribution typically until ~April 15th
        // Simple check for demo: include previous year if before May 1st
        let month = Calendar.current.component(.month, from: Date())
        if month < 5 {
            return [currentYear, currentYear - 1]
        } else {
            return [currentYear]
        }
    }()

    // Computed property to parse the input string safely
     private var contributionAmount: Decimal? {
         // Use a NumberFormatter to handle potential locale differences (e.g., "," vs ".")
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            // Attempt to convert string to NSNumber, then to Decimal
            if let number = formatter.number(from: contributionAmountString) {
                return number.decimalValue
         }
         return nil // Return nil if parsing fails
     }

    var body: some View {
        // NavigationView should wrap this if it's pushed onto a stack
        // If presented modally, adjust structure accordingly
         VStack(alignment: .leading, spacing: 0) { // Use VStack instead of List for more control
            Text("Fund Your \(selectedType.rawValue)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top, 10) // Adjust as needed if not in NavView

            Text("IRA contribution limits apply. Max for \(selectedContributionYear): $\(mockContributionLimit(for: selectedContributionYear)).")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
                .padding(.bottom, 20)

             Form { // Use Form for grouped styling
                 Section(header: Text("Amount").font(.headline)) {
                     HStack {
                         Text("$")
                             .font(.title2)
                             .foregroundColor(.gray)
                         TextField("0.00", text: $contributionAmountString)
                              .keyboardType(.decimalPad)
                              .font(.title2)
                              .onChange(of: contributionAmountString) {
                                  validateAmount() // Validate on change
                                  updateFormValidation()
                              }
                     }
                     if !isAmountValid && !contributionAmountString.isEmpty {
                          Text("Please enter a valid positive amount.")
                              .font(.caption)
                              .foregroundColor(.red)
                     }
                 }

                 Section(header: Text("Contribution Year").font(.headline)) {
                     Picker("Select Year", selection: $selectedContributionYear) {
                         ForEach(contributionYears, id: \.self) { year in
                             Text(String(year)).tag(year)
                         }
                     }
                     .pickerStyle(.segmented) // Or .menu for more options
                     .onChange(of: selectedContributionYear) {
                          updateFormValidation()
                      }
                 }

                 Section(header: Text("From Account").font(.headline)) {
                      // Use Picker if multiple sources, otherwise just display
                      if availableFundingSources.count > 1 {
                          Picker("Select Funding Source", selection: $selectedFundingSourceId) {
                               Text("Select Account").tag(String?.none) // Placeholder
                               ForEach(availableFundingSources) { source in
                                   Text(source.displayName).tag(source.id as String?) // Tag with Optional ID
                               }
                           }
                          .onChange(of: selectedFundingSourceId) {
                             updateFormValidation()
                          }
                      } else if let firstSource = availableFundingSources.first {
                           // If only one source, just display it and auto-select
                           Text(firstSource.displayName)
                               .foregroundColor(.gray)
                               .onAppear {
                                   // Auto-select if not already set and only one option
                                   if selectedFundingSourceId == nil {
                                      selectedFundingSourceId = firstSource.id
                                      updateFormValidation()
                                   }
                               }
                      } else {
                           Text("No funding sources linked.")
                               .foregroundColor(.red)
                      }
                  }

             } // End Form

            Spacer() // Push button to bottom

            Button {
                submitContribution()
            } label: {
                Text("Confirm Contribution")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .disabled(!isFormValid)

             // Hidden Navigation Link for Next Step
             NavigationLink(
                 // Destination would be a confirmation screen
                 destination: Text("Confirmation Screen Placeholder for \(contributionAmountString) to \(selectedType.rawValue) for \(selectedContributionYear)"),
                 isActive: $navigateToConfirmation
             ) { EmptyView() }

        }
        // Remove .navigationTitle if not within a NavigationView defined here
        // Remove .navigationBarTitleDisplayMode if not within a NavigationView
        // .navigationTitle("Initial Funding") // Set title if needed
        // .navigationBarTitleDisplayMode(.inline) // Or .large
        .onAppear { // Set initial validation state
            validateAmount()
           updateFormValidation()
        }
    }

    // --- Helper Functions ---

    func validateAmount() {
         guard let amount = contributionAmount, amount > 0 else {
             isAmountValid = false
             return
         }
         // Add more checks if needed (e.g., against mock limits - complex in real app)
        isAmountValid = true
    }

     func updateFormValidation() {
         // Check if amount is valid AND a funding source is selected AND a year is selected
         isFormValid = isAmountValid && selectedFundingSourceId != nil
             // No explicit check for year needed if it defaults correctly and picker ensures a value
     }

    func submitContribution() {
        print("Submitting contribution:")
        print("- Type: \(selectedType.rawValue)")
        print("- Amount: \(contributionAmountString)")
        print("- Year: \(selectedContributionYear)")
        print("- Source ID: \(selectedFundingSourceId ?? "None Selected")")

        // --- Real App Logic ---
        // 1. Perform final validation (including server-side checks against actual limits)
        // 2. Initiate API call to transfer funds / record contribution
        // 3. On success -> navigateToConfirmation = true
        // 4. On failure -> show error message to user

        // For Demo: Directly navigate
        navigateToConfirmation = true
    }

    // Mock function for display purposes
    func mockContributionLimit(for year: Int) -> String {
         // In a real app, this would fetch actual IRS limits
         return year < Calendar.current.component(.year, from: Date()) ? "6,500" : "7,000" // Example values
     }

}

struct IRAOpeningFundingView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide the necessary selectedType for the preview
        NavigationView { // Add NavigationView for preview context
            IRAOpeningFundingView(selectedType: .roth) // Preview with Roth
        }

         NavigationView { // Add NavigationView for preview context
             IRAOpeningFundingView(selectedType: .traditional) // Preview with Traditional
         }

    }
}
