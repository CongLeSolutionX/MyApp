////
////  SimulatedAddToWalletView.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import SwiftUI
//import PassKit
//
//// --- Data Structures for Simulation ---
//
//struct FakeCardDetails {
//    // For initial configuration (non-sensitive)
//    let cardholderName: String = "Fake Cardholder"
//    let primaryAccountSuffix: String = "9876" // Last 4 digits
//
//    // For display purposes
//    let displayInfo: CardDisplayInfo = CardDisplayInfo(
//        last4: "9876",
//        network: "Visa", // Or "Mastercard", etc.
//        issuer: "Simulated Bank"
//    )
//
//    // Identifier used internally (not sent to Apple initially)
//    let internalCardIdentifier: String = "simulated-card-001"
//}
//
//// Represents the visual info for the card preview
//struct CardDisplayInfo {
//    let last4: String
//    let network: String
//    let issuer: String
//}
//
//// Represents the *fake* sensitive payloads we pretend to get from a backend
//struct FakeSecurePayloads {
//    let encryptedPassData: Data
//    let activationData: Data
//    let ephemeralPublicKey: Data
//
//    // Static factory for dummy data
//    static func generateDummy() -> FakeSecurePayloads {
//        // Use simple strings converted to Data for simulation
//        let dummyEncrypted = "FAKE_ENCRYPTED_PASS_DATA".data(using: .utf8)!
//        let dummyActivation = "FAKE_ACTIVATION_DATA".data(using: .utf8)!
//        let dummyPublicKey = "FAKE_EPHEMERAL_PUBLIC_KEY".data(using: .utf8)!
//
//        return FakeSecurePayloads(
//            encryptedPassData: dummyEncrypted,
//            activationData: dummyActivation,
//            ephemeralPublicKey: dummyPublicKey
//        )
//    }
//}
//
//// --- Main SwiftUI View ---
//
//struct SimulatedAddToWalletView: View {
//    @Environment(\.dismiss) var dismiss
//    @State private var fakeCard = FakeCardDetails()
//
//    // State for PassKit flow
//    @State private var showAddCardSheet = false
//    @State private var addCardConfiguration: PKAddPaymentPassRequestConfiguration?
//    @State private var provisioningResult: PKAddPaymentPassResult? // Tracks the final outcome
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 30) {
//                Spacer()
//
//                // --- Visual Cue - Card Representation ---
//                SimpleCardView(cardInfo: fakeCard.displayInfo)
//                    .padding(.horizontal)
//
//                // --- Explanatory Text ---
//                Text("Simulate adding your \(fakeCard.displayInfo.issuer) card to Apple Wallet.")
//                    .font(.body)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//
//                // --- Add to Apple Wallet Button ---
//                 AddPaymentPassButton {
//                    print("Add to Wallet button tapped.")
//                    initiateAddToWalletSimulation()
//                }
//                .frame(height: 60) // Standard height
//                .padding(.horizontal, 50)
//
//                // --- Result Feedback ---
//                 if let result = provisioningResult {
//                     Text("Simulation Result: \(result.description)")
//                         .font(.footnote)
//                         .foregroundColor(result == .success ? .green : (result == .failure ? .red : .orange))
//                         .padding(.top, 10)
//                 } else {
//                     // Keep space consistent
//                     Text("Tap 'Add to Apple Wallet' to start simulation.")
//                         .font(.footnote)
//                         .foregroundColor(.gray)
//                         .padding(.top, 10)
//                 }
//
//                Spacer()
//                Spacer()
//
//                Text("Note: Actual provisioning will fail as this uses fake data.")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .padding(.bottom)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea()) // Use system background
//            .navigationTitle("Wallet Simulation")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                 ToolbarItem(placement: .navigationBarLeading) {
//                     Button("Close") { dismiss() }
//                 }
//            }
//            .sheet(isPresented: $showAddCardSheet) {
//                // --- Present the PassKit View Controller ---
//                if let configuration = addCardConfiguration {
//                    AddPaymentPassViewControllerRepresentable(
//                        configuration: configuration,
//                        // Pass any needed info (like ID) for the simulated backend step
//                        internalCardIdentifier: fakeCard.internalCardIdentifier
//                    ) { result in
//                        // This completion is called when the *entire* process finishes
//                        print("-----------------------------------------")
//                        print("SwiftUI View: Received final result = \(result.description)")
//                        print("-----------------------------------------")
//                        self.provisioningResult = result
//                        self.showAddCardSheet = false // Dismiss sheet automatically
//                    }
//                      .interactiveDismissDisabled() // Prevent swipe-down dismissal during process
//                  } else {
//                      // Should not happen in normal flow if button is enabled correctly
//                      Text("Error: Configuration unavailable.")
//                          .onAppear {
//                              print("Error: Sheet presented without configuration!")
//                              showAddCardSheet = false
//                           }
//                  }
//             }
//        }
//    }
//
//    // --- Function to Start the Simulation ---
//    func initiateAddToWalletSimulation() {
//        provisioningResult = nil // Reset result display
//
//        // 1. Check device capability (still good practice)
//        guard PKAddPaymentPassViewController.canAddPaymentPass() else {
//            print("Error: Device cannot add payment passes (or simulator limitation).")
//            provisioningResult = .failure // Cannot even start
//            return
//        }
//        print("Device capability check passed.")
//
//        // 2. Create the *initial* configuration (non-sensitive details)
//        guard let configuration = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2) else {
//             print("Error: Failed to create PassKit configuration.")
//             provisioningResult = .failure
//            return
//        }
//        print("PKAddPaymentPassRequestConfiguration created.")
//
//        // Populate with fake (but valid format) non-sensitive data
//        configuration.cardholderName = fakeCard.cardholderName
//        configuration.primaryAccountSuffix = fakeCard.primaryAccountSuffix
//        // configuration.localizedDescription = "Add your Simulated Card" // Optional display text
//        // configuration.paymentNetwork = .visa // Can set if known
//
//        // 3. Store configuration and trigger sheet presentation
//        self.addCardConfiguration = configuration
//        self.showAddCardSheet = true
//        print("Configuration stored. Requesting sheet presentation.")
//    }
//}
//
//// --- UIViewControllerRepresentable Wrapper ---
//struct AddPaymentPassViewControllerRepresentable: UIViewControllerRepresentable {
//    typealias UIViewControllerType = PKAddPaymentPassViewController
//
//    let configuration: PKAddPaymentPassRequestConfiguration
//    let internalCardIdentifier: String // Pass info needed for simulation step
//    let completionHandler: (PKAddPaymentPassResult) -> Void
//
//    func makeUIViewController(context: Context) -> UIViewControllerType {
//        print("Representable: makeUIViewController called.")
//        guard let controller = PKAddPaymentPassViewController(requestConfiguration: configuration, delegate: context.coordinator) else {
//            print("Representable Error: Failed to initialize PKAddPaymentPassViewController!")
//            // Return a placeholder or handle error more robustly
//            // In a real app, you might call completionHandler(.failure) here
//            return PKAddPaymentPassViewController() // Return empty to avoid crash
//        }
//        print("Representable: PKAddPaymentPassViewController initialized successfully.")
//        // Pass necessary data/parent ref to Coordinator
//        context.coordinator.parent = self
//        context.coordinator.internalCardIdentifier = self.internalCardIdentifier
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        // Usually no updates needed for this controller
//         print("Representable: updateUIViewController called (no action).")
//    }
//
//    func makeCoordinator() -> Coordinator {
//        print("Representable: makeCoordinator called.")
//        // Don't pass parent here, do it in makeUIViewController
//        return Coordinator()
//    }
//
//    // --- Coordinator: Handles PK Delegate Callbacks ---
//    class Coordinator: NSObject, PKAddPaymentPassViewControllerDelegate {
//        var parent: AddPaymentPassViewControllerRepresentable?
//        var internalCardIdentifier: String = ""
//
//        // ** DELEGATE METHOD 1: Generate the Final Request **
//        // This is where the simulated "backend" call happens.
//        func addPaymentPassViewController(
//            _ controller: PKAddPaymentPassViewController,
//            generateRequestWithCertificateChain certificates: [Data],
//            nonce: Data,
//            nonceSignature: Data,
//            completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void
//        ) {
//            print("-----------------------------------------")
//            print("Coordinator: generateRequestWithCertificateChain called.")
//            print("   > Received \(certificates.count) certificates.")
//            print("   > Received nonce: \(nonce.count) bytes.")
//            print("   > Received nonceSignature: \(nonceSignature.count) bytes.")
//            print("   > Using internal card ID: \(internalCardIdentifier)")
//
//            // *** SIMULATE BACKEND INTERACTION ***
//            print("   > Simulating backend call to get secure payloads...")
//            // In a real app, you'd make an async network call here, sending
//            // certificates, nonce, nonceSignature, and internalCardIdentifier
//            // to your server.
//
//            // Generate FAKE secure payloads immediately
//            let fakePayloads = FakeSecurePayloads.generateDummy()
//            print("   > Simulation complete. Generated fake payloads.")
//
//            // Create the FINAL request object using the FAKE payloads
//            let request = PKAddPaymentPassRequest()
//            request.encryptedPassData = fakePayloads.encryptedPassData
//            request.activationData = fakePayloads.activationData
//            request.ephemeralPublicKey = fakePayloads.ephemeralPublicKey
//
//            // Optionally add Cardholder Name and Suffix again if needed by issuer/network
//            // request.cardholderName = parent?.configuration.cardholderName
//            // request.primaryAccountSuffix = parent?.configuration.primaryAccountSuffix
//
//            print("   > Created PKAddPaymentPassRequest with FAKE secure data.")
//
//            // Call the completion handler provided by PassKit, passing the request
//            // containing the FAKE data. Wallet UI will proceed with this.
//             handler(request)
//             print("   > Called PassKit completionHandler with the fake request.")
//             print("-----------------------------------------")
//        }
//
//        // ** DELEGATE METHOD 2: Final Result **
//        // This is called AFTER Wallet UI tries (and fails) to use the fake request.
//        func addPaymentPassViewController(
//            _ controller: PKAddPaymentPassViewController,
//            didFinishAdding pass: PKPaymentPass?,
//            error: Error?
//        ) {
//            print("-----------------------------------------")
//            print("Coordinator: didFinishAdding called.")
//
//             var result: PKAddPaymentPassResult
//
//             if let nsError = error as NSError? {
//                 print("   > Error received: \(nsError.localizedDescription) (Domain: \(nsError.domain), Code: \(nsError.code))")
//                // Check for specific PassKit errors
//                if let pkError = error as? PKPassKitError {
//                    print("   > Error is PKPassKitError with code: \(pkError.code.rawValue)")
//                    if pkError.code == .invalidDataError {
//                         print("   > Result: invalidDataError")
//                         result = .cancelled
//                    } else {
//                        print("   > Result: Failure (PKPassKitError)")
//                         result = .failure
//                     }
//                } else {
//                    // Treat other errors as failures
//                    print("   > Result: Failure (Non-PKPassKitError)")
//                     result = .failure
//                 }
//            } else if pass != nil {
//                // This case is unlikely in simulation with fake data, but handle it
//                print("   > Success: PKPaymentPass object received (unexpected in simulation!).")
//                print("     - Pass Primary Account Identifier: \(pass!.primaryAccountIdentifier)")
//                print("     - Pass Primary Account Number Suffix: \(pass!.primaryAccountNumberSuffix)")
//                 result = .success
//             } else {
//                 // No error, no pass - Treat as user cancelled or unknown failure
//                 print("   > No pass and no specific error received. Assuming cancelled or unknown failure.")
//                 result = .cancelled // Or .failure, depending on desired interpretation
//             }
//
//            // Dismiss the PassKit view controller (important!)
//             controller.dismiss(animated: true) { [weak self] in
//                 print("   > PKAddPaymentPassViewController dismissed.")
//                 // Call the SwiftUI completion handler AFTER dismissal
//                 self?.parent?.completionHandler(result)
//                 print("   > Called SwiftUI completion handler.")
//             }
//             print("-----------------------------------------")
//            // Note: Don't call parent?.completionHandler immediately here,
//            // wait for the dismiss completion for smoother UI.
//        }
//    }
//}
//
//// --- Helper Enum for Result Handling ---
//enum PKAddPaymentPassResult: Int {
//    case success
//    case failure
//    case cancelled
//
//    var description: String {
//        switch self {
//        case .success: return "Success" // Unlikely in simulation
//        case .failure: return "Failure" // Expected outcome
//        case .cancelled: return "Cancelled" // Possible outcome
//        }
//    }
//}
//
//// --- Simple Card Visual Placeholder ---
//struct SimpleCardView: View {
//    let cardInfo: CardDisplayInfo
//    private let cornerRadius: CGFloat = 12.0
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                 Text(cardInfo.issuer)
//                    .font(.headline)
//                    .fontWeight(.medium)
//                     .foregroundColor(.primary) // Use primary text color
//                Text("•••• \(cardInfo.last4)") // Use dots for hidden numbers
//                     .font(.subheadline)
//                     .foregroundColor(.secondary) // Use secondary text color
//                     .monospacedDigit() // Helps align numbers if needed
//            }
//            Spacer()
//             // Simple network logo simulation
//             Image(systemName: cardInfo.network.lowercased() == "visa" ? "creditcard.fill" : "creditcard") // Example icon
//                .font(.title)
//                 .foregroundColor(cardInfo.network.lowercased() == "visa" ? .blue : .orange) // Example colors
//        }
//        .padding()
//        .background(Material.regular) // Use a material background for modern look
//        .cornerRadius(cornerRadius)
//        .overlay(
//            RoundedRectangle(cornerRadius: cornerRadius)
//                .stroke(Color.gray.opacity(0.2), lineWidth: 1) // Subtle border
//        )
//         .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2) // Softer shadow
//    }
//}
//
//// --- Apple Pay Button UIViewRepresentable Wrapper ---
//// (Standard implementation - No changes needed for simulation)
//struct AddPaymentPassButton: UIViewRepresentable {
//     let action: () -> Void
//
//     func makeUIView(context: Context) -> PKAddPassButton {
//         // Or .blackOutline depending on preference
//         let button = PKAddPassButton(addPassButtonStyle: .black)
//         button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
//         return button
//     }
//
//     func updateUIView(_ uiView: PKAddPassButton, context: Context) { }
//
//     func makeCoordinator() -> Coordinator { Coordinator(action: action) }
//
//     class Coordinator: NSObject {
//         let action: () -> Void
//         init(action: @escaping () -> Void) { self.action = action }
//         @objc func buttonTapped() {
//             print("AddPaymentPassButton: Native button tapped, calling action.")
//             action()
//         }
//     }
// }
//
//// --- Previews ---
//struct SimulatedAddToWalletView_Previews: PreviewProvider {
//    static var previews: some View {
//        SimulatedAddToWalletView()
//    }
//}
