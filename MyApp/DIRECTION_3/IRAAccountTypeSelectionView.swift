//
//  IRAAccountTypeSelectionView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI

// Define an enum for clarity and type safety
enum IRAAccountType: String, Identifiable {
    case traditional = "Traditional IRA"
    case roth = "Roth IRA"

    var id: String { self.rawValue }

    var description: String {
        switch self {
        case .traditional:
            return "Contributions may be tax-deductible now. Taxes are typically paid upon withdrawal in retirement."
        case .roth:
            return "Contributions made with after-tax dollars. Qualified withdrawals in retirement are generally tax-free."
        }
    }

    var backgroundColor: Color {
        switch self {
        case .traditional:
            return Color.yellow.opacity(0.1) // Example color
        case .roth:
            return Color.blue.opacity(0.1) // Example color
        }
    }

    var borderColor: Color {
        switch self {
        case .traditional:
            return Color.yellow.opacity(0.4) // Example color
        case .roth:
            return Color.blue.opacity(0.4) // Example color
        }
    }
}

struct IRAAccountTypeSelectionView: View {
    // State to track the user's selection
    @State private var selectedType: IRAAccountType? = nil
    // State to potentially show more info
    @State private var showingLearnMore = false // For modal presentation

    // Placeholder navigation trigger
    @State private var navigateToNext = false

    var body: some View {
        // Use NavigationView if this screen is part of a larger flow
        // If presented modally, you might use a different structure
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {

                Text("Choose the type of IRA you'd like to open:")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 20) // Add padding below nav bar
                    .padding(.bottom, 15)

                // Options Section
                VStack(spacing: 15) {
                    AccountTypeOption(
                        type: .traditional,
                        isSelected: selectedType == .traditional
                    ) {
                        selectedType = .traditional
                    }

                    AccountTypeOption(
                        type: .roth,
                        isSelected: selectedType == .roth
                    ) {
                        selectedType = .roth
                    }
                }
                .padding(.horizontal)

                 // Learn More Link
                Button {
                    showingLearnMore = true
                } label: {
                    Text("Learn more about IRA types")
                        .font(.callout)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .center) // Center the link
                }
                .padding(.horizontal)

                Spacer() // Pushes the button to the bottom

                // Continue Button
                Button {
                    print("Selected type: \(selectedType?.rawValue ?? "None")")
                    // Trigger navigation to the next step (e.g., funding, details)
                    navigateToNext = true
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity) // Make button full width
                }
                .buttonStyle(.borderedProminent) // Standard prominent style
                .padding() // Add padding around the button
                .disabled(selectedType == nil) // Disable if nothing is selected

                // Hidden Navigation Link (Example)
                NavigationLink(
                    // destination: IRADetailsEntryView(selectedType: selectedType ?? .traditional), // Pass selection
                    destination: Text("Next Screen Placeholder (e.g., Funding/Details for \(selectedType?.rawValue ?? ""))"),
                    isActive: $navigateToNext
                ) { EmptyView() }

            }
            .navigationTitle("Select Account Type")
            .navigationBarTitleDisplayMode(.inline) // Or .large if preferred
            .sheet(isPresented: $showingLearnMore) {
                 // Simple placeholder - replace with actual informational view
                NavigationView {
                    ScrollView { // Make content scrollable if long
                        VStack(alignment: .leading, spacing: 15) {
                            Text("IRA Type Details").font(.title)
                            Text("Traditional IRA").font(.title2)
                            Text("Contributions might be tax-deductible in the year they are made, lowering your current taxable income. Investment earnings grow tax-deferred. Withdrawals in retirement are taxed as ordinary income.")
                             Text("Roth IRA").font(.title2)
                            Text("Contributions are made with money you've already paid taxes on (after-tax). Investment earnings grow tax-free. Qualified withdrawals in retirement (generally after age 59½ and after the account has been open for 5 years) are tax-free.")
                            // Add more details, eligibility, limits etc.
                         }.padding()
                    }
                    .navigationTitle("Learn More")
                    .navigationBarItems(trailing: Button("Done") { showingLearnMore = false })
                }
            }
        }
    }
}

// Reusable View for each account type option
struct AccountTypeOption: View {
    let type: IRAAccountType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 5) {
                Text(type.rawValue)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(type.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3) // Prevent excessive text wrap
            }

            Spacer() // Push text left

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .blue : .gray.opacity(0.5)) // Use accent color or primary
                .font(.title2) // Adjust size as needed
        }
        .padding() // Inner padding for content
        .background(type.backgroundColor) // Use type-specific background
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : type.borderColor, lineWidth: isSelected ? 2 : 1) // Highlight if selected
        )
        .contentShape(Rectangle()) // Ensure entire area is tappable
        .onTapGesture(perform: action)
    }
}

struct IRAAccountTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        IRAAccountTypeSelectionView()
    }
}
