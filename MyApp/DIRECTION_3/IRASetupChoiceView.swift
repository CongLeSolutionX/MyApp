//
//  IRASetupChoiceView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI

// Using system colors for standard background, customize if needed
// Assume previous Color extensions exist if limeAccent is reused

struct IRASetupChoiceView: View {
    // State variable to potentially drive navigation later
    @State private var navigateToPath: String? = nil // e.g., "new", "transfer"

    var body: some View {
        // Use NavigationView for a title bar, assuming this screen is pushed
        NavigationView {
            VStack(alignment: .leading, spacing: 0) { // Align content left

                Spacer().frame(height: 20)

                Text("Choose your path")
                    .font(.largeTitle.bold())
                    .padding(.horizontal)
                    .padding(.bottom, 5)

                Text("How would you like to start with your Robinhood IRA?")
                    .font(.subheadline)
                    .foregroundColor(.secondary) // Use secondary color for subtitle
                    .padding(.horizontal)

                Spacer().frame(height: 30)

                // Option 1: Open New IRA
                OptionCard(
                    iconName: "plus.circle.fill",
                    iconColor: .green,
                    title: "Open a new IRA",
                    description: "Start fresh with a Traditional or Roth IRA. You can set up recurring contributions or fund it anytime.",
                    backgroundColor: Color.green.opacity(0.1),
                    borderColor: Color.green.opacity(0.3)
                ) {
                    print("Selected: Open New IRA")
                    // In a real app, trigger navigation:
                    // self.navigateToPath = "new"
                }
                .padding(.horizontal)

                Spacer().frame(height: 20)

                // Option 2: Transfer Existing IRA
                OptionCard(
                    iconName: "arrow.right.arrow.left.circle.fill",
                    iconColor: .blue,
                    title: "Transfer an existing IRA",
                    description: "Bring your IRA from another institution to Robinhood. We can help you with the transfer process.",
                    backgroundColor: Color.blue.opacity(0.1),
                    borderColor: Color.blue.opacity(0.3)
                ) {
                    print("Selected: Transfer Existing IRA")
                    // In a real app, trigger navigation:
                    // self.navigateToPath = "transfer"
                }
                .padding(.horizontal)

                Spacer() // Pushes content towards the top

                Text("IRA contributions and transfers are subject to eligibility requirements and annual contribution limits.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.bottom, 10) // Padding before bottom edge
            }
            .navigationBarTitleDisplayMode(.inline) // Keep the large title area clear
            .navigationBarHidden(true) // Hide default Nav Bar if custom title used as above
            // Or use .navigationTitle("Set up IRA") if you prefer standard bar
        }
        // Add navigation links based on `navigateToPath` if using state for navigation
        // .background(NavigationLink(destination: NewIRAFormView(), tag: "new", selection: $navigateToPath) { EmptyView() })
        // .background(NavigationLink(destination: TransferIRAFormView(), tag: "transfer", selection: $navigateToPath) { EmptyView() })
    }
}

// Reusable Card View for Options
struct OptionCard: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let description: String
    let backgroundColor: Color
    let borderColor: Color
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 15) {
                Image(systemName: iconName)
                    .font(.title)
                    .foregroundColor(iconColor)
                    .frame(width: 30) // Align icons

                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary) // Use secondary for description
                }
                Spacer() // Push content left
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor, lineWidth: 1)
        )
        .contentShape(Rectangle()) // Make the whole area tappable
        .onTapGesture(perform: action)
    }
}

struct IRASetupChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        IRASetupChoiceView()
    }
}
