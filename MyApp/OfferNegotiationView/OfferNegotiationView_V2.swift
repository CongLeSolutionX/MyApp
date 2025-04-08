//
//  OfferNegotiationView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/7/25.
//

import SwiftUI

// Represents the data for a single package
struct OfferPackage: Identifiable, Hashable { // Conform to Hashable for sheet item presentation
    let id = UUID()
    let title: String
    let description: String
    let price: String
    let guaranteedIncrease: String
    let detailsForConfirmation: String // Added field for more info
}

// Enum to identify which sheet is being presented
enum ActiveSheet: Identifiable {
    case confirmation(OfferPackage)
    case terms

    var id: String {
        switch self {
        case .confirmation(let package):
            return "confirm_\(package.id)"
        case .terms:
            return "terms"
        }
    }
}

struct OfferNegotiationView: View {
    // Environment variable to dismiss the view (if presented modally)
    @Environment(\.dismiss) var dismiss

    // State to track the selected package
    @State private var selectedPackageId: UUID?

    // State to manage which sheet (modal) is currently presented
    @State private var activeSheet: ActiveSheet?

    // Sample package data (expanded slightly)
    let packages = [
        OfferPackage(title: "Professional Package", description: "Guaranteed increase of $2,500 from initial offer. At least 1+ years of experience.", price: "$1,250", guaranteedIncrease: "$2,500", detailsForConfirmation: "Negotiation support for standard roles, script review, and 1 mock negotiation session."),
        OfferPackage(title: "Senior Package", description: "Guaranteed increase of $5,000 from initial offer. For third level ICs or higher.", price: "$2,450", guaranteedIncrease: "$5,000", detailsForConfirmation: "Includes Professional Package + competing offer strategy, advanced negotiation tactics, and 2 mock sessions."),
        OfferPackage(title: "Leadership Package", description: "Guaranteed increase of $20,000 from initial offer. Principal level or senior manager+.", price: "$5,000", guaranteedIncrease: "$20,000", detailsForConfirmation: "Includes Senior Package + executive compensation review, equity negotiation, and unlimited mock sessions.")
    ]

    // Placeholder for company logos
    let companyLogos = ["g.circle.fill", "s.circle.fill", "figure.wave.circle.fill", "chart.bar.fill", "apps.iphone", "questionmark.circle.fill"]
    let prominentLogoIndex = 2

    // Computed property to get the currently selected package
    var selectedPackage: OfferPackage? {
        packages.first { $0.id == selectedPackageId }
    }

    // Computed property to check if the main action button should be enabled
    var isMaximizeButtonEnabled: Bool {
        selectedPackageId != nil
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    Spacer().frame(height: 40) // Space for close button

                    IconBubbleArea(logos: companyLogos, prominentIndex: prominentLogoIndex)

                    TextHeader()

                    PackagesListView(packages: packages, selectedPackageId: $selectedPackageId)

                    ActionButtons(
                        isMaximizeEnabled: isMaximizeButtonEnabled,
                        maximizeAction: {
                            // Trigger confirmation sheet
                            if let package = selectedPackage {
                                activeSheet = .confirmation(package)
                            }
                        },
                        termsAction: {
                            // Trigger terms sheet
                            activeSheet = .terms
                        }
                    )

                    Spacer()
                }
                .padding(.horizontal)
            }
            .padding(.top, 20)

            CloseButton {
                 print("Attempting to dismiss view...")
                 dismiss() // Call the dismiss action
            }
            .padding(.trailing)
            .padding(.top, 10)
            .accessibilityLabel("Close negotiation screen")

        }
        .preferredColorScheme(.dark)
        // Sheet presenter modifier
        .sheet(item: $activeSheet) { sheetType in
             // Determine which view to show based on the sheetType
             switch sheetType {
             case .confirmation(let package):
                 ConfirmationView(package: package)
                     .presentationDetents([.medium]) // Example: Set sheet height
             case .terms:
                 TermsView()
             }
         }
    }
}

// MARK: - Subviews (Updated)

// IconBubbleArea and TextHeader remain the same as before...
struct IconBubbleArea: View {
    let logos: [String]
    let prominentIndex: Int
    // (Code is identical to previous version - omitted for brevity)
    var body: some View { /* ... Same as before ... */
        ZStack(alignment: .top) {
            // Company Logos Row
            HStack(spacing: 15) {
                ForEach(logos.indices, id: \.self) { index in
                    Image(systemName: logos[index]) // Use system names as placeholders
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: index == prominentIndex ? 55 : 35, height: index == prominentIndex ? 55 : 35)
                        .foregroundColor(index == prominentIndex ? .blue : .gray.opacity(0.8)) // Example prominent color
                        .clipShape(index == prominentIndex ? AnyShape(Circle()) : AnyShape(RoundedRectangle(cornerRadius: 8))) // Style differently
                        .opacity(index == prominentIndex ? 1.0 : 0.6) // Dim non-prominent logos
                        .accessibilityHidden(true) // Hide decorative images
                }
            }
            .padding(.top, 35) // Push logos down to make space for the bubble
            .accessibilityElement(children: .ignore) // Treat HStack as one element
            .accessibilityLabel("Company logos including Google, Slack, Facebook, and others")

            // "+$100K" Bubble
            Text("+$100K")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(Color(white: 0.15)) // Dark gray background
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color(white: 0.3), lineWidth: 1) // Subtle border
                )
                .accessibilityLabel("Example potential increase: Over $100,000")
                // Simple offset for positioning - more complex geometry needed for exact pointer
                .offset(y: -10)
        }
     }

}

struct TextHeader: View {
    // (Code is identical to previous version - omitted for brevity)
     var body: some View { /* ... Same as before ... */
        VStack(spacing: 10) {
             Text("Get Paid, Not Played")
                 .font(.largeTitle)
                 .fontWeight(.bold)
                 .foregroundColor(.white)

             Text("Interviewing or negotiating an offer? We'll help you maximize your offer. Risk-free.")
                 .font(.subheadline)
                 .foregroundColor(.gray)
                 .multilineTextAlignment(.center)
                 .padding(.horizontal) // Constrain width slightly
                 .accessibilityElement(children: .combine) // Combine title and subtitle for accessibility
         }
     }
}

struct PackagesListView: View {
    let packages: [OfferPackage]
    @Binding var selectedPackageId: UUID?

    var body: some View {
        VStack(spacing: 15) {
            ForEach(packages) { package in
                PackageView(
                    package: package,
                    isSelected: package.id == selectedPackageId
                )
                .onTapGesture {
                    selectedPackageId = package.id
                }
                 .accessibilityElement(children: .combine) // Read content together
                 .accessibilityHint("Tap to select this package")
                 .accessibilityAddTraits(package.id == selectedPackageId ? [.isSelected] : [])
            }
        }
         .accessibilityElement(children: .contain) // Group packages
         .accessibilityLabel("Available Negotiation Packages")
    }
}

struct PackageView: View {
    let package: OfferPackage
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                .foregroundColor(isSelected ? .blue : .gray)
                .font(.title2)
                .accessibilityHidden(true) // Radio button state handled by trait

            VStack(alignment: .leading, spacing: 4) {
                Text(package.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(package.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            // Combine title and description for better flow, but keep price separate
            .accessibilityElement(children: .combine)

            Spacer()

            Text(package.price)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .accessibilityLabel("Price: \(package.price)") // Explicit price label
        }
        .padding()
        .background(Color(white: 0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue.opacity(0.7) : Color(white: 0.3), lineWidth: isSelected ? 2 : 1)
        )
        // Root level label combines underlying info if needed, but above settings are often better
         // .accessibilityLabel("\(package.title), Price \(package.price). \(package.description). \(isSelected ? "Selected" : "Not selected")")
    }
}

struct ActionButtons: View {
    let isMaximizeEnabled: Bool
    let maximizeAction: () -> Void
    let termsAction: () -> Void

    var body: some View {
        VStack(spacing: 15) {
            Button(action: maximizeAction) {
                Text("Maximize Offer")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isMaximizeEnabled ? .blue : .gray) // Dim text when disabled
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(white: 0.25).opacity(isMaximizeEnabled ? 1.0 : 0.5)) // Dim background when disabled
                    .cornerRadius(12)
            }
            .disabled(!isMaximizeEnabled) // Disable the button itself
            .accessibilityHint(isMaximizeEnabled ? "Proceeds with the selected package" : "Select a package first")

            Button(action: termsAction) {
                Text("View Terms & Conditions")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .underline()
            }
            .accessibilityHint("Opens the terms and conditions")
        }
    }
}

struct CloseButton: View {
    let action: () -> Void
    // (Code is identical to previous version - omitted for brevity)
     var body: some View { /* ... Same as before ... */
         Button(action: action) {
             Image(systemName: "xmark")
                 .font(.system(size: 12, weight: .bold))
                 .foregroundColor(.black) // Icon color
                 .padding(8)
                 .background(Color.gray.opacity(0.8)) // Background color similar to screenshot
                 .clipShape(Circle())
         }
     }
}

// MARK: - New Sheet Views

struct ConfirmationView: View {
    @Environment(\.dismiss) var dismissSheet
    let package: OfferPackage

    var body: some View {
        NavigationView { // Add NavigationView for title and potential toolbar items
            VStack(alignment: .leading, spacing: 20) {
                Text("Confirm Your Selection")
                    .font(.title2)
                    .fontWeight(.bold)

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    Text(package.title)
                        .font(.headline)
                    Text("Price: \(package.price)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Guaranteed Increase: \(package.guaranteedIncrease)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Details: \(package.detailsForConfirmation)")
                        .font(.body)
                }

                Spacer() // Pushes button to bottom

                Button {
                    print("Confirmed package: \(package.title)")
                    // --- Functional Action ---
                    // Simulate API call or further navigation
                    // For now, just dismiss the sheet
                    dismissSheet()
                } label: {
                    Text("Confirm Package - \(package.price)")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                 .accessibilityHint("Confirms selection and proceeds to payment or next step")

            }
            .padding()
            .navigationTitle("Confirmation") // Title for the sheet
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismissSheet()
                    }
                    .accessibilityLabel("Cancel confirmation")
                }
            }
            .preferredColorScheme(.dark) // Match parent view's scheme
        }
    }
}

struct TermsView: View {
    @Environment(\.dismiss) var dismissSheet

    var body: some View {
         NavigationView {
             ScrollView {
                 VStack(alignment: .leading, spacing: 15) {
                     Text("Terms & Conditions")
                         .font(.title2)
                         .fontWeight(.bold)
                         .padding(.bottom)

                     Text("Mock Terms Introduction")
                         .font(.headline)
                     Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi.")
                         .font(.body)
                         .foregroundColor(.gray)

                     Text("Service Agreement")
                         .font(.headline)
                     Text("Nulla quis sem at nibh elementum imperdiet. Duis sagittis ipsum. Praesent mauris. Fusce nec tellus sed augue semper porta. Mauris massa. Vestibulum lacinia arcu eget nulla.")
                         .font(.body)
                         .foregroundColor(.gray)

                     Text("Payment and Guarantees")
                          .font(.headline)
                      Text("Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Curabitur sodales ligula in libero. Sed dignissim lacinia nunc. Curabitur tortor. Pellentesque nibh. Aenean quam. In scelerisque sem at dolor.")
                          .font(.body)
                          .foregroundColor(.gray)

                      // Add more placeholder sections as needed...

                      Spacer()
                  }
                  .padding()

             }
             .navigationTitle("Terms")
             .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button("Done") {
                         dismissSheet()
                     }
                     .accessibilityLabel("Close terms and conditions")
                 }
             }
              .preferredColorScheme(.dark)
         }

    }
}

// MARK: - Preview & Hosting

// To test the dismiss and sheet functionality effectively in previews,
// it's helpful to wrap the view or provide a simple host.
struct OfferNegotiationView_Hosted: View {
     @State private var showOfferSheet = true // Start with sheet shown

     var body: some View {
         NavigationView { // Provides context for potential navigation titles if needed
             Text("Parent View")
                 .navigationTitle("Offers")
                 .toolbar {
                     ToolbarItem(placement: .navigationBarTrailing) {
                         Button("Show Offer") {
                             showOfferSheet = true
                         }
                     }
                 }
         }
         .sheet(isPresented: $showOfferSheet) {
              // Present OfferNegotiationView modally
              OfferNegotiationView()
          }
     }
 }

#Preview("Main View") {
    OfferNegotiationView()
}

#Preview("Hosted Sheet") {
     OfferNegotiationView_Hosted()
}

#Preview("Confirmation Sheet") {
     // Preview the confirmation sheet directly
     ConfirmationView(package: OfferNegotiationView().packages[1]) // Example package
}

#Preview("Terms Sheet") {
     // Preview the terms sheet directly
     TermsView()
}

// Custom shape for easier previewing (Identical to previous version)
struct AnyShape: Shape { /* ... Same as before ... */
    private let builder: (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        builder = { rect in
            shape.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        builder(rect)
    }
}
