//
//  AddToWalletView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI
import PassKit

// --- Mock Data Structures (Adjusted) ---
struct ProvisioningConfigurationData {
    // Data needed JUST for the initial configuration
    let cardholderName: String = "Jane Doe"
    let primaryAccountSuffix: String = "1234" // Last 4 digits (display only)
    // let paymentNetwork: PKPaymentNetwork = .visa // Optional: if known beforehand

    // Display representation of the card
    let cardVisual: CardDisplayInfo = CardDisplayInfo(last4: "1234", network: "Visa", issuer: "Robinhood")

    // Placeholder for identifying the card to your backend
    let cardIdentifier: String = "unique-card-id-123"
}

// --- Secure Payload Data (This comes FROM your backend during the delegate callback) ---
struct SecureProvisioningPayloads {
    let encryptedPassData: Data
    let activationData: Data
    let ephemeralPublicKey: Data
}

struct CardDisplayInfo {
    let last4: String
    let network: String
    let issuer: String
}

// --- Add Card To Wallet View (Adjusted) ---
struct AddToWalletView: View {
    @Environment(\.dismiss) var dismiss
    @State private var configData = ProvisioningConfigurationData() // Use configuration data

    // State to manage the presentation of the Apple Wallet sheet
    @State private var showAddCardSheet = false
    // We only need the configuration initially, not the full request
    @State private var addCardConfiguration: PKAddPaymentPassRequestConfiguration? = nil

    // State for feedback after attempting to add
    @State private var provisioningResult: Bool? = nil // true for success, false for failure/cancel

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // ... (rest of the UI remains largely the same: SimpleCardView, Text, AddPaymentPassButton) ...
                 Spacer()

                // --- Visual Cue - Simple Card Representation ---
                SimpleCardView(cardInfo: configData.cardVisual)
                    .padding(.horizontal)

                // --- Explanatory Text ---
                Text("Add your \(configData.cardVisual.issuer) card to Apple Wallet for easy, secure payments in stores, apps, and online.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                // --- Add to Apple Wallet Button ---
                 AddPaymentPassButton {
                    initiateAddToWallet()
                }
                .frame(height: 60)
                .padding(.horizontal, 50)

                // --- Result Feedback (Optional) ---
                 if let result = provisioningResult {
                     Text(result ? "Card added!" : "Card not added.") // Adjusted text slightly
                         .font(.footnote)
                         .foregroundColor(result ? .green : .red)
                         .padding(.top, 10)
                 } else {
                   Text("").font(.footnote).padding(.top, 10)
                 }
                Spacer()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.rhBeige.ignoresSafeArea())
            .navigationTitle("Add to Wallet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { /* ... Toolbar remains the same ... */
                 ToolbarItem(placement: .navigationBarLeading) {
                     Button("Back") { dismiss() }
                         .foregroundColor(Color.rhGold)
                 }
            }
            .sheet(isPresented: $showAddCardSheet) {
                // Pass the CONFIGURATION to the representable
                if let configuration = addCardConfiguration {
                    AddPaymentPassViewControllerRepresentable(
                        configuration: configuration,
                        cardIdentifier: configData.cardIdentifier // Pass identifier for backend call
                    ) { result in
                        // Handle the result from the final delegate method
                        print("Provisioning finished with result: \(result.rawValue)")
                        provisioningResult = (result == .success)
                        showAddCardSheet = false // Dismiss sheet
                    }
                      .interactiveDismissDisabled()
                  } else {
                      Text("Error: Provisioning configuration unavailable.")
                          .onAppear { showAddCardSheet = false }
                  }
             }
        }
        .accentColor(Color.rhGold)
    }

    // --- Function to Initiate the Process (Adjusted) ---
    func initiateAddToWallet() {
        // 1. Check device capability
        guard PKAddPaymentPassViewController.canAddPaymentPass() else {
            print("Error: Device cannot add payment passes.")
            provisioningResult = false
            return
        }

        // 2. Create the configuration for the request
        guard let configuration = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2) else {
             print("Error: Failed to create PassKit configuration.")
             provisioningResult = false
            return
        }

        // Populate configuration details (Non-sensitive)
        configuration.cardholderName = configData.cardholderName
        configuration.primaryAccountSuffix = configData.primaryAccountSuffix
        // configuration.paymentNetwork = configData.paymentNetwork // If known

        // 3. Store the configuration and trigger the sheet presentation
        self.addCardConfiguration = configuration // Store the config
        self.provisioningResult = nil
        self.showAddCardSheet = true
    }
}

// --- SwiftUI View Representable (Adjusted) ---
struct AddPaymentPassViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = PKAddPaymentPassViewController

    // Takes configuration, not the request
    let configuration: PKAddPaymentPassRequestConfiguration
    let cardIdentifier: String // Needed for the backend call in delegate
    let completionHandler: (PKAddPaymentPassResult) -> Void

    func makeUIViewController(context: Context) -> UIViewControllerType {
        // Initialize with the CONFIGURATION
        guard let controller = PKAddPaymentPassViewController(requestConfiguration: configuration, delegate: context.coordinator) else {
            print("Error: Failed to initialize PKAddPaymentPassViewController.")
            // Return an empty one or handle error better
            return PKAddPaymentPassViewController()
        }
        // Pass necessary data to the coordinator
        context.coordinator.cardIdentifier = cardIdentifier
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // No update logic needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // --- Coordinator Class (Adjusted with generateRequest delegate method) ---
    class Coordinator: NSObject, PKAddPaymentPassViewControllerDelegate {
        var parent: AddPaymentPassViewControllerRepresentable
        var cardIdentifier: String = "" // To hold the ID for the backend call

        init(_ parent: AddPaymentPassViewControllerRepresentable) {
            self.parent = parent
        }

        // ** IMPLEMENT THIS DELEGATE METHOD **
        func addPaymentPassViewController(
            _ controller: PKAddPaymentPassViewController,
            generateRequestWithCertificateChain certificates: [Data],
            nonce: Data,
            nonceSignature: Data,
            completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void
        ) {
            print("Delegate: generateRequestWithCertificateChain called.")

            // ** CRITICAL: ASYNCHRONOUS BACKEND CALL NEEDED HERE **
            // 1. Prepare data for your backend
            //    (certificates, nonce, nonceSignature, self.cardIdentifier)

            // 2. Make an asynchronous network call to YOUR backend server.
            //    Your backend MUST perform crypto and return the required payloads.
            Task { // Example using Task for async operation
                do {
                    // Replace with your actual backend call
                    let securePayloads = try await fetchSecurePayloadsFromBackend(
                        cardId: self.cardIdentifier,
                        certificates: certificates,
                        nonce: nonce,
                        nonceSignature: nonceSignature
                    )

                    // 3. Create the FINAL request object *using* the backend response
                    let request = PKAddPaymentPassRequest()
                    request.encryptedPassData = securePayloads.encryptedPassData
                    request.activationData = securePayloads.activationData
                    request.ephemeralPublicKey = securePayloads.ephemeralPublicKey
                    // Potentially set other request properties if needed

                    // 4. Call the completion handler with the final request
                    handler(request)
                    print("Delegate: Called completionHandler with final request.")

                } catch {
                    print("Delegate Error: Failed to fetch secure payloads from backend - \(error)")
                    // Handle the error appropriately. You might need a way to signal
                    // failure back to Wallet, though the primary way is via the
                    // didFinishAdding delegate method after Wallet tries (and fails).
                    // Calling the handler with an empty/invalid request might cause Wallet
                    // to eventually fail and call didFinishAdding with an error.
                     // Consider creating a placeholder/dummy request that's known to fail
                     // or calling the handler with a request that signals an error if possible,
                     // but the framework doesn't explicitly document this. Best bet is logging
                     // and letting the didFinishAdding handle the resulting Wallet-side error.
                     // For now, we might just call handler with an empty request to proceed:
                    handler(PKAddPaymentPassRequest()) // Let Wallet fail
                }
             }
             // IMPORTANT: The work MUST be done asynchronously if fetching from network.
        }

        // This method remains the same - called when the whole process is done
          func addPaymentPassViewController(
             _ controller: PKAddPaymentPassViewController,
             didFinishAdding pass: PKPaymentPass?,
             error: Error?
         ) {
           controller.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                // ... (rest of the didFinishAdding logic is the same as before) ...
                 if let error = error as? PKPassKitError {
                     print("PassKit Error adding card: \(error.localizedDescription) (Code: \(error.code.rawValue))")
                     switch error.code {
                     case .invalidDataError, .invalidSignature, .notEntitledError, .unknownError, .unsupportedVersionError: self.parent.completionHandler(.cancelled)
                       default: self.parent.completionHandler(.failure)
                     }
                } else if error != nil {
                     print("Unknown error adding card: \(error!.localizedDescription)")
                     self.parent.completionHandler(.failure)
                } else if pass != nil {
                     print("Card added successfully: \(pass?.primaryAccountNumberSuffix ?? "N/A")")
                    self.parent.completionHandler(.success)
               } else {
                    print("Add card cancelled by user or unknown reason.")
                    self.parent.completionHandler(.cancelled)
                }
            }
        }

       // --- Placeholder for Backend Interaction ---
        private func fetchSecurePayloadsFromBackend(
            cardId: String,
            certificates: [Data],
            nonce: Data,
            nonceSignature: Data
        ) async throws -> SecureProvisioningPayloads {
           // !!! --- THIS IS A MOCK --- !!!
           // !!! --- REPLACE WITH ACTUAL NETWORK CALL TO YOUR SERVER --- !!!
           print("Backend Call Simulation: Sending certs/nonce for cardID: \(cardId)")
           // Simulate network delay
           try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

           // Simulate receiving data from backend (replace with actual decoded data)
            let dummyData = "dummy_payload".data(using: .utf8)!
           print("Backend Call Simulation: Received dummy payloads.")
           return SecureProvisioningPayloads(
               encryptedPassData: dummyData,
               activationData: dummyData,
               ephemeralPublicKey: dummyData
           )
           // !!! --- END MOCK --- !!!
       }
    }
}

// --- Other components (SimpleCardView, AddPaymentPassButton, PKAddPaymentPassResult, Previews) remain the same ---
// ... (Include SimpleCardView, AddPaymentPassButton, PKAddPaymentPassResult enum, Previews struct here) ...

// --- Simple Card Visual Placeholder ---
struct SimpleCardView: View { /* ... Same as before ... */
    let cardInfo: CardDisplayInfo
    private let cornerRadius: CGFloat = 10.0

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                 Text(cardInfo.issuer)
                    .font(.headline)
                    .fontWeight(.bold)
                Text("Card ending in \(cardInfo.last4)")
                     .font(.subheadline)
                     .foregroundColor(.secondary)
            }
            Spacer()
             Image(systemName: cardInfo.network.lowercased() == "visa" ? "creditcard.fill" : "creditcard")
                .font(.title)
                .foregroundColor(Color.rhGold)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(cornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
         .overlay(
             RoundedRectangle(cornerRadius: cornerRadius)
                 .stroke(Color.gray.opacity(0.2), lineWidth: 1)
         )

    }
}

// --- Enum for Result Handling ---
enum PKAddPaymentPassResult: Int { /* ... Same as before ... */
     case success
     case failure
     case cancelled
 }

// --- Apple Pay Button (Uses UIKit Wrapper) ---
struct AddPaymentPassButton: UIViewRepresentable { /* ... Same as before ... */
     let action: () -> Void

     func makeUIView(context: Context) -> PKAddPassButton {
         let button = PKAddPassButton(addPassButtonStyle: .blackOutline)
         button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
         return button
     }

     func updateUIView(_ uiView: PKAddPassButton, context: Context) { }

     func makeCoordinator() -> Coordinator { Coordinator(action: action) }

     class Coordinator: NSObject {
         let action: () -> Void
         init(action: @escaping () -> Void) { self.action = action }
         @objc func buttonTapped() { action() }
     }
 }

// --- Color Extension ---
// extension Color { ... } // Ensure rhBeige, rhGold are defined

// --- Previews ---
struct AddToWalletView_Previews: PreviewProvider {
    static var previews: some View {
        AddToWalletView()
    }
}
