//
//  TermsView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/7/25.
//

// MARK: - Data Model
import Foundation // Need UUID

// Model for each term item
struct TermItem: Identifiable, Hashable { // Add Hashable for ForEach performance
    let id = UUID()
    let heading: String
    let body: String
}

// MARK: - ViewModel (`TermsViewModel`)

import SwiftUI // Needed for ObservableObject, Published

@MainActor // Ensures UI updates happen on the main thread
class TermsViewModel: ObservableObject {

    // --- Published Properties (Trigger UI Updates) ---
    @Published private(set) var terms: [TermItem] = [] // Keep data private, publish read-only
    @Published var canAccept: Bool = false // Controls the button state

    // --- Initialization ---
    init() {
        loadTerms() // Load terms when the ViewModel is created
    }

    // --- Data Loading ---
    // In a real app, this might fetch from a network or file.
    // Using mock data here for demonstration.
    private func loadTerms() {
        // (Using the same 'termsData' array from the previous example)
        // NOTE: Place the full 'termsData' array definition here or load from a source file
        self.terms = [
            TermItem(heading: "Adding Your Chase Card.",
                     body: "You can add an eligible Chase Card to a Wallet by either following our instructions..."),
            TermItem(heading: "Your Chase Card Terms Do Not Change.",
                     body: "The terms and agreement that govern your Chase Card do not change..."),
            TermItem(heading: "Applicable Fees.",
                     body: "Any applicable interest, fees, and charges that apply to your Chase Card..."),
            TermItem(heading: "Chase Is Not Responsible for the Wallet.",
                      body: "Chase is not the provider of the Wallet, and we are not responsible..."),
            TermItem(heading: "Transaction History.",
                      body: "You agree and acknowledge that the transaction history displayed..."),
            TermItem(heading: "Contacting You Electronically and by Email or through Your Mobile Device.",
                       body: "You consent to receive electronic communications and disclosures..."),
            TermItem(heading: "Removing Your Chase Card from the Wallet.",
                      body: "You should contact the Wallet provider on how to remove a Chase Card..."),
            TermItem(heading: "Governing Law and Disputes.",
                      body: "These Terms are governed by federal law and, to the extent that state law applies..."),
            TermItem(heading: "Ending or Changing these Terms; Assignments.",
                      body: "We can terminate these Terms at any time. We can also change these Terms..."),
            TermItem(heading: "Privacy.",
                      body: "Your privacy and the security of your information are important to us..."),
            TermItem(heading: "Notices.",
                      body: "We can provide notices to you concerning these Terms and your use of a Chase Card..."),
            TermItem(heading: "Limitation of Liability; No Warranties.",
                      body: "WE ARE NOT AND SHALL NOT BE LIABLE FOR ANY LOSS, DAMAGE OR INJURY..."),
            TermItem(heading: "Questions.",
                      body: "If you have any questions, disputes, or complaints about the Wallet, contact the Wallet provider...")
             // ... (Include all 13 items from the previous example)
        ]
    }

    // --- Logic ---
    func userScrolledToBounds(_ scrolledToBounds: Bool) {
        // Update canAccept only if it needs changing to avoid unnecessary UI refreshes
        if canAccept != scrolledToBounds {
            canAccept = scrolledToBounds
            print("Accept button enabled: \(canAccept)") // For debugging
        }
    }
}

// MARK: - ScrollView PreferenceKey (For Detecting Scroll Position)

import SwiftUI

struct ScrollViewBoundsPreferenceKey: PreferenceKey {
    // Represents whether the bottom of the content is visible within the scroll view's frame
    static var defaultValue: Bool = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        // If any part reports the bottom is visible, the final value is true.
        value = value || nextValue()
    }
}


// MARK: - Enhanced `TermsView`

import SwiftUI

struct TermsView: View {
    // --- State & ViewModel ---
    @StateObject private var viewModel = TermsViewModel() // Owns the ViewModel instance
    @State private var scrollViewContentBounds: CGRect = .zero // To store content size

    // --- Callbacks for Interaction ---
    let onAccept: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationView { // Often presented within a NavigationView for title/buttons
            VStack(spacing: 0) { // Use spacing: 0 to have ScrollView fill space
                GeometryReader { scrollViewProxy in // Get the ScrollView's available frame
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                             // --- Title ---
                            Text("Terms for Adding Your Chase Card to a Third Party Digital Wallet")
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 10)
                                .frame(maxWidth: .infinity)

                            // --- Introductory Paragraphs ---
                            Text("These Terms for Adding Your Chase Card...") // Truncated for brevity
                                .font(.body)
                            Text("When you add a Chase Card to a Wallet, you agree to these Terms:")
                                .font(.body)
                                .padding(.top, 5)

                            // --- Numbered List from ViewModel ---
                            ForEach(viewModel.terms) { term in // Use terms from ViewModel
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("**\(viewModel.terms.firstIndex(of: term)! + 1). \(term.heading)**") // Safely unwrap index
                                        .font(.body)
                                    Text(term.body)
                                        .font(.body)
                                }
                                .padding(.bottom, 10)
                            }

                             // --- Footer Disclosure ---
                             Divider().padding(.vertical, 10)
                             Text("Credit and debit card products are provided by JPMorgan Chase Bank, N.A. Member FDIC")
                                 .font(.footnote)
                                 .foregroundColor(.secondary)
                                 .multilineTextAlignment(.center)
                                 .frame(maxWidth: .infinity)
                        }
                        .padding() // Padding for the inner content
                        .background( // Detect content bounds
                            GeometryReader { contentProxy in
                                Color.clear
                                    .preference(key: ScrollViewBoundsPreferenceKey.self,
                                                // Check if bottom of content is within scroll view frame
                                                value: contentProxy.frame(in: .named("scrollView")).maxY < scrollViewProxy.size.height + 20) // Add small tolerance
                            }
                        )
                    }
                    .coordinateSpace(name: "scrollView") // Name the coordinate space
                    .onPreferenceChange(ScrollViewBoundsPreferenceKey.self) { scrolledToBounds in
                        // Update the ViewModel when the preference changes
                        viewModel.userScrolledToBounds(scrolledToBounds)
                    }
                } // End GeometryReader for ScrollView

                // --- Accept Button Area ---
                Divider() // Visual separation for the button area
                VStack { // Encapsulate button for padding
                    Button(action: onAccept) {
                        Text("Accept")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity) // Make button wide
                    }
                    .buttonStyle(.borderedProminent) // Modern button style
                    .disabled(!viewModel.canAccept) // Enable/disable based on ViewModel
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .accessibilityHint(viewModel.canAccept ? "" : "Scroll to the bottom of the terms to enable.") // Accessibility hint
                }
                .background(.regularMaterial) // Subtle background for the button area
            }
            // --- Navigation Bar ---
            .navigationTitle("Terms and Conditions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Dismiss", action: onDismiss)
                }
            }
            .ignoresSafeArea(.container, edges: .bottom) // Allow button area to go to bottom edge
        }
    }
}

// MARK: - Hosting View (`ContentView`)

import SwiftUI

struct TermsView_V2: View {
    @State private var isShowingTerms: Bool = false
    @State private var acceptanceStatus: String = "Terms have not been accepted."
    @AppStorage("userHasAcceptedTerms") private var userHasAcceptedTerms: Bool = false // Persist acceptance

    var body: some View {
        VStack(spacing: 20) {
             // Show different content based on acceptance
            if userHasAcceptedTerms {
                 Text("✅ Terms Accepted!")
                     .font(.largeTitle)
                     .foregroundColor(.green)
                 Button("Reset Acceptance (for demo)") {
                     userHasAcceptedTerms = false
                 }
                 .buttonStyle(.bordered)

             } else {
                 Text(acceptanceStatus)
                     .font(.headline)
                 Button("Show Terms and Conditions") {
                     isShowingTerms = true
                 }
                 .buttonStyle(.borderedProminent)
             }
        }
        .padding()
        .sheet(isPresented: $isShowingTerms) {
            // --- Present TermsView ---
            TermsView(
                onAccept: {
                    print("Terms Accepted!")
                    acceptanceStatus = "Terms Accepted!"
                    userHasAcceptedTerms = true // Update persisted state
                    isShowingTerms = false // Dismiss sheet
                },
                onDismiss: {
                    print("Terms Dismissed.")
                    acceptanceStatus = "Terms were dismissed."
                    isShowingTerms = false // Dismiss sheet
                }
            )
        }
    }
}

// Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TermsView_V2()
    }
}
