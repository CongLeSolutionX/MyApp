//
//  BoardingPassView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/21/25.
//

import Foundation
import SwiftUI // Needed for Color

// Enum for flight status for better type safety
enum FlightStatus: String, CaseIterable {
    case onTime = "On Time"
    case delayed = "Delayed"
    case boarding = "Boarding"
    case cancelled = "Cancelled"
    case departed = "Departed"

    var color: Color {
        switch self {
        case .onTime, .boarding: .green
        case .delayed: .orange
        case .cancelled: .red
        case .departed: .gray
        }
    }
}

struct BoardingPass: Identifiable {
    let id = UUID() // Conformance to Identifiable

    // Airline Info
    let airlineName: String
    let airlineLogoSystemName: String // System name for SF Symbols

    // Flight Status & Gate
    var status: FlightStatus
    let gate: String

    // Route Info
    let originCity: String
    let originCode: String
    let destinationCity: String
    let destinationCode: String

    // Flight Details
    let scheduledTime: Date
    let flightNumber: String
    let seat: String
    let boardingGroup: String

    // Passenger Info
    let passengerName: String

    // Barcode/QR Code Info
    let barcodeData: String // The data the QR code represents

    // Meta Info (for UI state)
    var isAddedToWallet: Bool = false

    // Static Mock Data (for previews and testing)
    static var mock: BoardingPass {
        BoardingPass(
            airlineName: "SwiftAir",
            airlineLogoSystemName: "airplane.circle.fill",
            status: .onTime,
            gate: "B12",
            originCity: "San Francisco",
            originCode: "SFO",
            destinationCity: "New York",
            destinationCode: "JFK",
            scheduledTime: Calendar.current.date(byAdding: .hour, value: 3, to: Date())!, // 3 hours from now
            flightNumber: "SA 101",
            seat: "14A",
            boardingGroup: "A",
            passengerName: "Alex Applebaum",
            barcodeData: "ABC123XYZ789SA101JFK14A",
            isAddedToWallet: false
        )
    }

    // Formatter for display
    static var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // e.g., 3:30 PM
        return formatter
    }

    var formattedScheduledTime: String {
        BoardingPass.timeFormatter.string(from: scheduledTime)
    }
}

import SwiftUI

// Reusable view for displaying labeled information
struct InfoItem: View {
    let label: String
    let value: String
    var alignment: HorizontalAlignment = .leading
    var valueColor: Color = .white // Allow customizing value color

    var body: some View {
        VStack(alignment: alignment) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
                .textCase(.uppercase)
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(valueColor) // Use customizable color
                .fixedSize(horizontal: false, vertical: true) // Prevent truncation
        }
        .accessibilityElement(children: .combine) // Combine label & value for VoiceOver
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }
}

// Reusable view for displaying airport information
struct AirportInfo: View {
    let city: String
    let code: String
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        VStack(alignment: alignment) {
            Text(city)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
            Text(code)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(city), airport code \(code)")
    }
}

import SwiftUI
// Note: For real QR Code generation, you'd need a library like CoreImage or a third-party one.
import CoreImage.CIFilterBuiltins // For placeholder QR generation

struct BoardingPassView: View {
    // Input: The boarding pass data
    @Binding var passData: BoardingPass // Use Binding to reflect changes (like Wallet status)

    // Actions triggered by buttons within the pass (defined by the parent view)
    var onAddToWalletTapped: () -> Void = {} // Placeholder action

    var body: some View {
        VStack(spacing: 20) {
            // Top Info: Logo, Status, Gate
            HStack {
                Image(systemName: passData.airlineLogoSystemName)
                    .font(.title)
                    .foregroundStyle(.white)
                    .accessibilityLabel("\(passData.airlineName) logo")

                Spacer()

                // Use the status color
                InfoItem(label: "Status", value: passData.status.rawValue, alignment: .trailing, valueColor: passData.status.color)
                InfoItem(label: "Gate", value: passData.gate, alignment: .trailing)
                    .padding(.leading, 5)

            }
            .padding(.horizontal)
            .padding(.top)

            // Flight Route: Origin -> Destination
            HStack {
                AirportInfo(city: passData.originCity, code: passData.originCode)
                    .accessibilityHint("Departure airport")
                Spacer()
                Image(systemName: "airplane")
                    .font(.largeTitle)
                    .rotationEffect(.degrees(90))
                    .foregroundStyle(.white)
                    .accessibilityHidden(true) // Decorative
                Spacer()
                AirportInfo(city: passData.destinationCity, code: passData.destinationCode, alignment: .trailing)
                    .accessibilityHint("Arrival airport")
            }
            .padding(.horizontal)

            // Flight Details: Scheduled, Flight, Seat, Group
            HStack(alignment: .top) {
                InfoItem(label: "Scheduled", value: passData.formattedScheduledTime)
                Spacer()
                InfoItem(label: "Flight", value: passData.flightNumber, alignment: .center)
                Spacer()
                InfoItem(label: "Seat", value: passData.seat, alignment: .trailing)
                Spacer()
                InfoItem(label: "Group", value: passData.boardingGroup, alignment: .trailing)
            }
            .padding(.horizontal)

            // Passenger Name
            InfoItem(label: "Passenger", value: passData.passengerName.uppercased(), alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            // QR Code Section
            VStack(spacing: 5) {
                Image(uiImage: generateQRCode(from: passData.barcodeData))
                      .resizable()
                      .interpolation(.none) // Keep pixels sharp
                      .scaledToFit()
                      .frame(width: 150, height: 150)
                      .accessibilityLabel("Boarding Pass QR Code")
                      .accessibilityHint("Scan this code for boarding")

                Text(passData.barcodeData)
                    .font(.caption)
                    .foregroundStyle(.black.opacity(0.8))
                    .accessibilityLabel("Barcode number") // More specific label
            }
            .padding()
            .background(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            // Bottom Icons: Wallet, NFC
            HStack {
                // Wallet Button - Now functional
                Button {
                    onAddToWalletTapped() // Call the action provided by the parent
                } label: {
                    HStack {
                        Image(systemName: passData.isAddedToWallet ? "checkmark.circle.fill" : "wallet.pass.fill")
                            .foregroundColor(passData.isAddedToWallet ? .green : .white)
                        Text(passData.isAddedToWallet ? "Added to Wallet" : "Add to Wallet")
                            .font(.footnote)
                            .foregroundStyle(.white)
                    }
                }
                .disabled(passData.isAddedToWallet) // Disable if already added
                .accessibilityLabel(passData.isAddedToWallet ? "Pass added to Apple Wallet" : "Add pass to Apple Wallet")

                Spacer()
                Image(systemName: "wave.3.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.7)) // Slightly dimmed as it's likely indicator only
                    .accessibilityLabel("NFC Enabled Pass")
            }
            .padding(.horizontal)
            .padding(.bottom)

        }
        .background(.blue)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    // Basic QR Code Generation (Requires importing CoreImage.CIFilterBuiltins)
    func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        // Improve quality slightly
        let transform = CGAffineTransform(scaleX: 5, y: 5)

        if let outputImage = filter.outputImage?.transformed(by: transform),
           let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgimg)
        }

        // Fallback placeholder
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}


import SwiftUI
import PassKit // Needed for Add to Wallet functionality simulation

struct ContentView: View {
    // State for the boarding pass data
    @State private var passData = BoardingPass.mock

    // State for action sheet presentation
    @State private var showActionSheet = false

    // State for alert presentation (e.g., Wallet confirmation)
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    // Environment variable to dismiss the view (if presented modally)
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemGray6).ignoresSafeArea()

                VStack {
                    BoardingPassView(
                        passData: $passData, // Pass as a Binding
                        onAddToWalletTapped: handleAddToWallet // Pass the action handler
                    )
                    .padding()

                    Spacer() // Push the pass towards the top
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Boarding Pass") // Add a title for context
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        // Action: Dismiss the view
                        dismiss()
                        print("Done tapped - Dismissing view")
                    }
                    .accessibilityHint("Dismiss the boarding pass view")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Action: Show action sheet with options
                        showActionSheet = true
                        print("Ellipsis tapped - Showing action sheet")
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("More options")
                }
            }
            // Action Sheet for the Ellipsis button
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(
                    title: Text("Pass Options"),
                    message: Text("What would you like to do?"),
                    buttons: [
                        .default(Text("Share Pass...")) { handleSharePass() },
                        // Conditionally show Add to Wallet if not already added
                        !passData.isAddedToWallet ? .default(Text("Add to Apple Wallet")) { handleAddToWallet() } : nil,
                        .default(Text("View Flight Details")) { handleViewDetails() },
                        .destructive(Text("Remove Pass")) { handleRemovePass() }, // Example destructive action
                        .cancel()
                    ].compactMap { $0 } // Remove nil buttons (like conditional Wallet)
                )
            }
            // Alert for showing confirmations (like Add to Wallet)
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        // Optimize for appearance (might not be needed depending on presentation)
        // .navigationViewStyle(.stack)
    }

    // --- Action Handlers ---

    func handleSharePass() {
        print("Action: Share Pass")
        // In a real app: Use UIActivityViewController to share pass data/image
        presentAlert(title: "Share", message: "Sharing functionality not implemented in this demo.")
    }

    func handleAddToWallet() {
        print("Action: Add to Apple Wallet")
        // --- Real App Pseuodocode ---
        // 1. Check if PassKit is available
        // 2. Generate a valid .pkpass file (server-side or on-device with caution)
        // 3. Present PKAddPassesViewController
        // 4. Handle delegate callbacks for success/failure

        // --- Demo Simulation ---
        if !passData.isAddedToWallet {
             // Simulate adding delay / async work
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                 passData.isAddedToWallet = true
                 presentAlert(title: "Success", message: "Boarding pass has been added to Apple Wallet.")
             }
        } else {
             presentAlert(title: "Already Added", message: "This pass is already in your Apple Wallet.")
        }
    }

    func handleViewDetails() {
        print("Action: View Flight Details")
        // In a real app: Navigate to a new screen showing more detailed flight info, map, etc.
        presentAlert(title: "Flight Details", message: "Navigation to details screen not implemented.")
    }

    func handleRemovePass() {
        print("Action: Remove Pass")
        // In a real app: Delete the pass data, potentially update server, maybe dismiss view
        presentAlert(title: "Remove Pass", message: "Pass removal not fully implemented.")
        // Example: After confirmation, you might dismiss
        // dismiss()
    }

    // Helper to present alerts
    func presentAlert(title: String, message: String) {
        self.alertTitle = title
        self.alertMessage = message
        self.showAlert = true
    }
}

#Preview {
    // Preview the ContentView which includes the BoardingPassView
    ContentView()
}
//
//// Optional: Preview just the pass view with different states
//#Preview("Boarding Pass - Delayed") {
//    var delayedPass = BoardingPass.mock
//    delayedPass.status = .delayed
//    // Need a wrapper view to hold state for binding preview
//    struct PassPreviewWrapper: View {
//        @State var pass = delayedPass
//        var body: some View {
//            BoardingPassView(passData: $pass)
//                .padding()
//                .background(Color.gray) // Add background for context
//        }
//    }
//    return PassPreviewWrapper()
//}
//
//#Preview("Boarding Pass - Added") {
//  var addedPass = BoardingPass.mock
//    addedPass.isAddedToWallet = true
//    struct PassPreviewWrapper: View {
//        @State var pass = addedPass
//        var body: some View {
//            BoardingPassView(passData: $pass)
//                .padding()
//                .background(Color.gray)
//        }
//    }
//    return PassPreviewWrapper()
//}
