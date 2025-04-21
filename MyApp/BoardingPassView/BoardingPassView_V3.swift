//
//  BoardingPassView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/21/25.
//

import Foundation
import SwiftUI

// (FlightStatus enum remains the same as before)
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
    let id = UUID()

    // Airline Info
    let airlineName: String
    let airlineLogoSystemName: String
    let airlineWebsiteURL: URL? // Optional URL for airline info

    // Flight Status & Gate
    var status: FlightStatus
    let gate: String
    let gateMapURL: URL? // Optional URL for terminal map

    // Route Info
    let originCity: String
    let originCode: String
    let originAirportMapURL: URL? // Optional URL for origin map
    let destinationCity: String
    let destinationCode: String
    let destinationAirportMapURL: URL? // Optional URL for destination map

    // Flight Details
    let scheduledTime: Date
    let flightNumber: String
    let seat: String
    let boardingGroup: String
    let flightDetailsURL: URL? // Optional URL for flight tracking/details

    // Passenger Info
    let passengerName: String

    // Barcode/QR Code Info
    let barcodeData: String

    // Meta Info
    var isAddedToWallet: Bool = false
    var isRemoved: Bool = false // To visually indicate removal

    // Static Mock Data
    static var mock: BoardingPass {
        BoardingPass(
            airlineName: "SwiftAir",
            airlineLogoSystemName: "airplane.circle.fill",
            airlineWebsiteURL: URL(string: "https://www.example-airline.com"), // Mock URL
            status: .onTime,
            gate: "B12",
            gateMapURL: URL(string: "https://maps.example.com/sfo/terminal-3/gate-b12"), // Mock URL
            originCity: "San Francisco",
            originCode: "SFO",
            originAirportMapURL: URL(string: "https://maps.example.com/sfo"), // Mock URL
            destinationCity: "New York",
            destinationCode: "JFK",
            destinationAirportMapURL: URL(string: "https://maps.example.com/jfk"), // Mock URL
            scheduledTime: Calendar.current.date(byAdding: .hour, value: 3, to: Date())!,
            flightNumber: "SA 101",
            seat: "14A",
            boardingGroup: "A",
            flightDetailsURL: URL(string: "https://track.example-airline.com/SA101"), // Mock URL
            passengerName: "Alex Applebaum",
            barcodeData: "ABC123XYZ789SA101JFK14A",
            isAddedToWallet: false,
            isRemoved: false
        )
    }

    // Formatter
    static var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }

    var formattedScheduledTime: String {
        BoardingPass.timeFormatter.string(from: scheduledTime)
    }
}

import SwiftUI

// Reusable view for displaying labeled information (Unchanged)
struct InfoItem: View {
    let label: String
    let value: String
    var alignment: HorizontalAlignment = .leading
    var valueColor: Color = .white

    var body: some View {
        VStack(alignment: alignment) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
                .textCase(.uppercase)
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(valueColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }
}

// Reusable view for displaying airport information (Unchanged)
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
import CoreImage.CIFilterBuiltins

struct BoardingPassView: View {
    @Binding var passData: BoardingPass

    // --- Actions passed from Parent ---
    var onAddToWalletTapped: () -> Void = {}
    var onGateTapped: (String, URL?) -> Void = { _, _ in } // Pass gate string and optional URL
    var onAirportTapped: (String, URL?) -> Void = { _, _ in } // Pass airport code and optional URL
    var onFlightNumberTapped: (String, URL?) -> Void = { _, _ in } // Pass flight num and optional URL
    var onAirlineTapped: (String, URL?) -> Void = { _, _ in } // Pass airline name and optional URL

    var body: some View {
        ZStack { // Use ZStack for overlay
            VStack(spacing: 20) {
                // --- Top Info: Logo, Status, Gate ---
                HStack {
                    // Airline Logo (Tappable)
                    Button {
                        onAirlineTapped(passData.airlineName, passData.airlineWebsiteURL)
                    } label: {
                        HStack {
                            Image(systemName: passData.airlineLogoSystemName)
                                .font(.title)
                                .foregroundStyle(.white)
                            Text(passData.airlineName)
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain) // Use plain style to avoid default button appearance interfering
                    .accessibilityHint("View airline information")

                    Spacer()

                    InfoItem(label: "Status", value: passData.status.rawValue, alignment: .trailing, valueColor: passData.status.color)
                        .accessibilityHint(passData.isRemoved ? "Pass removed" : "Current flight status") // Hint reflects removal

                    // Gate (Tappable)
                    Button {
                        onGateTapped(passData.gate, passData.gateMapURL)
                    } label: {
                        InfoItem(label: "Gate", value: passData.gate, alignment: .trailing)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                    .disabled(passData.gateMapURL == nil) // Disable if no map URL
                    .accessibilityHint(passData.gateMapURL != nil ? "View gate location on map" : "Gate information")
                }
                .padding(.horizontal)
                .padding(.top)

                // --- Flight Route: Origin -> Destination ---
                HStack {
                    // Origin Airport (Tappable)
                    Button {
                        onAirportTapped(passData.originCode, passData.originAirportMapURL)
                    } label: {
                        AirportInfo(city: passData.originCity, code: passData.originCode)
                    }
                    .buttonStyle(.plain)
                    .disabled(passData.originAirportMapURL == nil)
                    .accessibilityHint("View departure airport information or map")

                    Spacer()
                    Image(systemName: "airplane")
                        .font(.largeTitle)
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.white)
                        .accessibilityHidden(true)
                    Spacer()

                    // Destination Airport (Tappable)
                    Button {
                        onAirportTapped(passData.destinationCode, passData.destinationAirportMapURL)
                    } label: {
                        AirportInfo(city: passData.destinationCity, code: passData.destinationCode, alignment: .trailing)
                    }
                    .buttonStyle(.plain)
                    .disabled(passData.destinationAirportMapURL == nil)
                    .accessibilityHint("View arrival airport information or map")
                }
                .padding(.horizontal)

                // --- Flight Details: Scheduled, Flight, Seat, Group ---
                HStack(alignment: .top) {
                    InfoItem(label: "Scheduled", value: passData.formattedScheduledTime)
                    Spacer()
                    // Flight Number (Tappable)
                    Button {
                        onFlightNumberTapped(passData.flightNumber, passData.flightDetailsURL)
                    } label: {
                        InfoItem(label: "Flight", value: passData.flightNumber, alignment: .center)
                    }
                    .buttonStyle(.plain)
                    .disabled(passData.flightDetailsURL == nil)
                    .accessibilityHint(passData.flightDetailsURL != nil ? "View flight tracking details" : "Flight number")

                    Spacer()
                    InfoItem(label: "Seat", value: passData.seat, alignment: .trailing)
                        .accessibilityHint("Assigned seat") // Added hint
                    Spacer()
                    InfoItem(label: "Group", value: passData.boardingGroup, alignment: .trailing)
                        .accessibilityHint("Boarding group") // Added hint
                }
                .padding(.horizontal)

                // --- Passenger Name ---
                InfoItem(label: "Passenger", value: passData.passengerName.uppercased(), alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                // --- QR Code Section ---
                VStack(spacing: 5) {
                    Image(uiImage: generateQRCode(from: passData.barcodeData))
                          .resizable()
                          .interpolation(.none)
                          .scaledToFit()
                          .frame(width: 150, height: 150)
                          .accessibilityLabel("Boarding Pass QR Code")
                          .accessibilityHint("Scan this code for boarding")

                    Text(passData.barcodeData)
                        .font(.caption)
                        .foregroundStyle(.black.opacity(0.8))
                        .accessibilityLabel("Barcode number")
                }
                .padding()
                .background(.white)
                .cornerRadius(10)
                .padding(.horizontal)

                // --- Bottom Icons: Wallet, NFC ---
                HStack {
                    Button {
                        onAddToWalletTapped()
                    } label: {
                        HStack {
                            Image(systemName: passData.isAddedToWallet ? "checkmark.circle.fill" : "wallet.pass.fill")
                                .foregroundStyle(passData.isAddedToWallet ? .green : .white)
                            Text(passData.isAddedToWallet ? "Added to Wallet" : "Add to Wallet")
                                .font(.footnote)
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain) // Ensure consistent tap area
                    .disabled(passData.isAddedToWallet)
                    .accessibilityLabel(passData.isAddedToWallet ? "Pass added to Apple Wallet" : "Add pass to Apple Wallet")

                    Spacer()
                    Image(systemName: "wave.3.right.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.7))
                        .accessibilityLabel("NFC Enabled Pass")
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            // Dimming overlay if removed
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.black.opacity(passData.isRemoved ? 0.6 : 0)) // Semi-transparent black overlay
                    .animation(.easeInOut, value: passData.isRemoved) // Animate the overlay
            )
            .overlay( // "Removed" text overlay
                 Text("REMOVED")
                     .font(.largeTitle)
                     .fontWeight(.bold)
                     .foregroundStyle(.red.opacity(0.8))
                     .padding(10)
                     .background(.secondary.opacity(0.3))
                     .clipShape(RoundedRectangle(cornerRadius: 10))
                     .rotationEffect(.degrees(-15))
                     .opacity(passData.isRemoved ? 1 : 0)
                     .animation(.easeInOut.delay(0.1), value: passData.isRemoved) // Animate text appearance
                      // Don't allow interaction if removed
                     .allowsHitTesting(false)
            )
            // Disable taps on the underlying content if removed
            .allowsHitTesting(!passData.isRemoved)
        } // End ZStack
    }

    // QR Code generation (unchanged)
    func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "H" // Higher error correction

        let transform = CGAffineTransform(scaleX: 10, y: 10) // Increase scale for better resolution

        if let outputImage = filter.outputImage?.transformed(by: transform),
           let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgimg)
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}


import SwiftUI
import PassKit // Still needed conceptually for Wallet features

struct ContentView: View {
    @State private var passData = BoardingPass.mock
    @State private var showActionSheet = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = [] // Items for the share sheet

    // State for modal sheets triggered by taps
    @State private var showingGateMapInfo = false
    @State private var infoSheetTitle = ""
    @State private var infoSheetMessage = ""
    @State private var infoSheetURL: URL?

    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL // Environment action to open URLs

    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemGray6).ignoresSafeArea()

                ScrollView { // Wrap in ScrollView in case content overflows on smaller devices
                    VStack(spacing: 20) {
                        BoardingPassView(
                            passData: $passData,
                            onAddToWalletTapped: handleAddToWallet,
                            onGateTapped: handleGateTap,
                            onAirportTapped: handleAirportTap,
                            onFlightNumberTapped: handleFlightNumberTap,
                            onAirlineTapped: handleAirlineTap
                        )
                        .padding()

                        // --- Simulation Controls (For Demo Purposes) ---
                        VStack {
                            Text("Simulation Controls")
                                .font(.headline)
                            Button("Simulate Status Change (Boarding)") {
                                simulateStatusChange(.boarding)
                            }
                            .disabled(passData.isRemoved)
                            Button("Simulate Status Change (Delayed)") {
                                simulateStatusChange(.delayed)
                            }
                             .disabled(passData.isRemoved)
                        }
                        .padding()
                        .background(Color(uiColor: .systemGray4))
                        .cornerRadius(10)
                        .opacity(passData.isRemoved ? 0.5 : 1) // Dim if removed
                        .disabled(passData.isRemoved)

                        Spacer() // Push pass and controls towards the top
                    }
                    .padding(.vertical) // Padding for scroll content
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Your Boarding Pass")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { // Changed from "Done" for clarity
                        dismiss()
                    }
                    .accessibilityHint("Close the boarding pass view")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showActionSheet = true
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("More options")
                    .disabled(passData.isRemoved) // Disable if pass removed
                }
            }
            .actionSheet(isPresented: $showActionSheet) { createActionSheet() } // Use helper function
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showShareSheet) { // Share sheet presentation
                ShareSheet(activityItems: shareItems)
            }
            .sheet(isPresented: $showingGateMapInfo) { // Info/Web View sheet
                InfoSheetView(title: infoSheetTitle, message: infoSheetMessage, url: infoSheetURL)
            }
        }
    }

    // --- Action Sheet Creation ---
    func createActionSheet() -> ActionSheet {
         ActionSheet(
             title: Text("Pass Options"),
             message: Text("Select an action"),
             buttons: [
                 .default(Text("Share Pass Image")) { handleSharePass() }, // Changed label
                 !passData.isAddedToWallet ? .default(Text("Add to Apple Wallet")) { handleAddToWallet() } : nil,
                 passData.flightDetailsURL != nil ? .default(Text("View Flight Details Online")) { handleFlightNumberTap(flightNum: passData.flightNumber, url: passData.flightDetailsURL)} : nil,
                 .destructive(Text("Remove Pass")) { handleRemovePassConfirmation() },
                 .cancel()
             ].compactMap { $0 }
         )
     }

    // --- Action Handlers ---

    func handleGateTap(gate: String, url: URL?) {
        print("Action: Gate Tapped - \(gate)")
        if let url = url {
            // Option 1: Try to open directly (might switch to Maps app etc.)
            // openURL(url)

            // Option 2: Show info sheet with option to open
             infoSheetTitle = "Gate \(gate) Map"
             infoSheetMessage = "View the location of Gate \(gate) in the terminal."
             infoSheetURL = url
             showingGateMapInfo = true

        } else {
            presentAlert(title: "Gate \(gate)", message: "No map available for this gate.")
        }
    }

    func handleAirportTap(code: String, url: URL?) {
         print("Action: Airport Tapped - \(code)")
         infoSheetTitle = "Airport: \(code)"
         infoSheetMessage = "View map or information for \(code) airport."
         infoSheetURL = url // Will be nil if no URL provided, sheet can handle this
         showingGateMapInfo = true // Reuse the same sheet state
     }

     func handleFlightNumberTap(flightNum: String, url: URL?) {
         print("Action: Flight Number Tapped - \(flightNum)")
         infoSheetTitle = "Flight \(flightNum) Details"
         infoSheetMessage = "Track flight status and details online."
         infoSheetURL = url
         showingGateMapInfo = true
     }

     func handleAirlineTap(name: String, url: URL?) {
         print("Action: Airline Tapped - \(name)")
         infoSheetTitle = name
         infoSheetMessage = "Visit the airline's website for more information."
         infoSheetURL = url
         showingGateMapInfo = true
     }

    func handleSharePass() {
        print("Action: Share Pass")
        // Generate a placeholder image or use actual pass data if possible
        let passInfo = """
        Flight: \(passData.flightNumber) (\(passData.originCode) -> \(passData.destinationCode))
        Passenger: \(passData.passengerName)
        Seat: \(passData.seat), Group: \(passData.boardingGroup)
        Departs: \(passData.formattedScheduledTime) from Gate \(passData.gate)
        Status: \(passData.status.rawValue)
        """
        // Could also generate an image of the BoardingPassView here if needed
        shareItems = [passInfo]
        showShareSheet = true // Trigger the .sheet modifier
    }

    func handleAddToWallet() {
        print("Action: Add to Apple Wallet")
        // (Simulation remains the same - toggle state, show alert)
        if !passData.isAddedToWallet {
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                passData.isAddedToWallet = true
                 presentAlert(title: "Success", message: "Boarding pass has been added to Apple Wallet (Simulated).")
             }
        } else {
             presentAlert(title: "Already Added", message: "This pass is already in your Apple Wallet.")
        }
    }

    func handleRemovePassConfirmation() {
        // Show a confirmation alert before actually removing
        alertTitle = "Remove Pass?"
        alertMessage = "Are you sure you want to remove this boarding pass? This action cannot be undone."
        // We need a way to handle the confirmation action
        showAlert = true
        // In a real app, the alert would have "Remove" and "Cancel" buttons.
        // Since SwiftUI's basic alert doesn't easily support this, we'll just simulate
        // the confirmation by setting isRemoved directly after a delay for demo.
        // Proper implementation would use ConfirmationDialog or a custom alert.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Simulate user confirming
            handleRemovePassConfirmed()
        }

    }

    func handleRemovePassConfirmed() {
        print("Action: Remove Pass Confirmed")
        withAnimation {
             passData.isRemoved = true
        }
        // Optional: Automatically dismiss the view after removal
        // DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        //      dismiss()
        // }
    }

    // --- Simulation Logic ---
    func simulateStatusChange(_ newStatus: FlightStatus) {
        if !passData.isRemoved {
            withAnimation {
                passData.status = newStatus
            }
            presentAlert(title: "Status Updated", message: "Flight status changed to \(newStatus.rawValue)")
        }
    }

    // Helper to present alerts
    func presentAlert(title: String, message: String) {
        self.alertTitle = title
        self.alertMessage = message
        self.showAlert = true // Trigger the .alert modifier
    }
}

// --- Helper View for Share Sheet ---
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

// --- Helper View for Info Sheet ---
struct InfoSheetView: View {
    let title: String
    let message: String
    let url: URL?
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL

    var body: some View {
        NavigationView {
             VStack(alignment: .leading, spacing: 20) {
                   Text(message)
                       .font(.body)

                   if let url = url {
                       Button {
                           openURL(url) // Attempt to open the URL
                       } label: {
                           Label("Open Link", systemImage: "safari.fill")
                               .frame(maxWidth: .infinity)
                       }
                       .buttonStyle(.borderedProminent)
                       .accessibilityHint("Opens \(url.host ?? "link") in browser or related app")
                   } else {
                       Text("No specific link available.")
                           .font(.callout)
                           .foregroundStyle(.secondary)
                   }

                   Spacer()
               }
               .padding()
               .navigationTitle(title)
               .navigationBarTitleDisplayMode(.inline)
               .toolbar {
                   ToolbarItem(placement: .navigationBarTrailing) {
                       Button("Done") { dismiss() }
                   }
            }
        }
    }
}

// --- Previews ---
#Preview("ContentView - Default") {
    ContentView()
}

//#Preview("Boarding Pass - Removed") {
//    var removedPass = BoardingPass.mock
//    removedPass.isRemoved = true
//    struct PassPreviewWrapper: View {
//        @State var pass = removedPass
//        var body: some View {
//            BoardingPassView(passData: $pass)
//                .padding()
//                .background(Color.gray)
//        }
//    }
//    PassPreviewWrapper()
//}

#Preview("Boarding Pass Info Sheet") {
    InfoSheetView(title: "Gate B12", message: "View map for Gate B12", url: URL(string: "https://example.com")!)
}
