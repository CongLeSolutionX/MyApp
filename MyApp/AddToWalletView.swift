////
////  AddToWalletView.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import SwiftUI
//import PassKit // Import PassKit framework
//
//// --- Mock Data (Potentially passed or fetched) ---
//// In a real app, this sensitive data would be securely fetched from your backend
//// ONLY when the user initiates the "Add to Wallet" process.
//// It should NOT be stored persistently on the device or passed insecurely between views.
//struct ProvisioningData {
//    let cardholderName: String = "Jane Doe"
//    let primaryAccountSuffix: String = "1234" // Last 4 digits (display only)
//    // --- Data actually needed for the request (fetched securely) ---
//    // These would be provided by your backend API for security:
//    let activationData: Data = Data() // Placeholder for encrypted payload, etc.
//    let encryptedPassData: Data = Data() // Placeholder
//    let ephemeralPublicKey: Data = Data() // Placeholder
//
//    // Display representation of the card
//    let cardVisual: CardDisplayInfo = CardDisplayInfo(last4: "1234", network: "Visa", issuer: "Robinhood")
//}
//
//struct CardDisplayInfo {
//    let last4: String
//    let network: String // e.g., "Visa", "Mastercard"
//    let issuer: String
//}
//
//// --- Add Card To Wallet View ---
//struct AddToWalletView: View {
//    @Environment(\.dismiss) var dismiss
//    @State private var provisioningData = ProvisioningData() // Load mock data
//
//    // State to manage the presentation of the Apple Wallet sheet
//    @State private var showAddCardSheet = false
//    @State private var addCardRequest: PKAddPaymentPassRequest? = nil
//
//    // State for feedback after attempting to add
//    @State private var provisioningResult: Bool? = nil // true for success, false for failure/cancel
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 30) {
//
//                Spacer()
//
//                // --- Visual Cue - Simple Card Representation ---
//                SimpleCardView(cardInfo: provisioningData.cardVisual)
//                    .padding(.horizontal)
//
//                // --- Explanatory Text ---
//                Text("Add your \(provisioningData.cardVisual.issuer) card to Apple Wallet for easy, secure payments in stores, apps, and online.")
//                    .font(.body)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//
//                // --- Add to Apple Wallet Button ---
//                // Apple provides a standard button for this
//                 AddPaymentPassButton {
//                    initiateAddToWallet()
//                }
//                 // Recommended button size by Apple HIG
//                .frame(height: 60)
//                .padding(.horizontal, 50)
//
//                // --- Result Feedback (Optional) ---
//                 if let result = provisioningResult {
//                     Text(result ? "Card successfully added!" : "Card not added.")
//                         .font(.footnote)
//                         .foregroundColor(result ? .green : .red)
//                         .padding(.top, 10)
//                 } else {
//                   // Placeholder for spacing consistency
//                  Text("").font(.footnote).padding(.top, 10)
//                 }
//
//                Spacer()
//                Spacer() // More space at bottom
//
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.rhBeige.ignoresSafeArea()) // Background color
//            .navigationTitle("Add to Wallet")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Back") { // Or "Cancel" depending on flow
//                        dismiss()
//                    }
//                    .foregroundColor(Color.rhGold)
//                 } // Optional Done/Close button if needed
////                ToolbarItem(placement: .navigationBarTrailing) {
////                    Button("Done") { dismiss() }
////                        .foregroundColor(Color.rhGold)
////                }
//            }
//             // Use .sheet to present the PassKit view controller
//             .sheet(isPresented: $showAddCardSheet) {
//                 // Ensure we have a request before presenting
//                 if let request = addCardRequest {
//                     AddPaymentPassViewControllerRepresentable(request: request) { result in
//                         // Handle the result from the delegate
//                         print("Provisioning finished with result: \(result.rawValue)")
//                         provisioningResult = (result == .success)
//                         showAddCardSheet = false // Dismiss sheet
//                         // Perform further actions based on result (e.g., analytics, UI update)
//                     }
//                      // Prevent interactive dismissal (user must use Apple's UI buttons)
//                      .interactiveDismissDisabled()
//                 } else {
//                     // Handle the error case where request is nil (should not happen here)
//                    Text("Error: Provisioning request is unavailable.")
//                        .onAppear {
//                           showAddCardSheet = false // Dismiss if request is bad
//                      }
//                 }
//             }
//        }
//        .accentColor(Color.rhGold)
//    }
//
//    // --- Function to Initiate the Process ---
//    func initiateAddToWallet() {
//         // 1. Fetch Secure Provisioning Data from Backend (Simulated here)
//         //    In a real app, this involves an API call that returns the necessary
//         //    encryptedPassData, activationData, etc. specific to this user and card.
//         //    We are using placeholder data from provisioningData.
//
//         // 2. Check if the device can add the card (requires Wallet capability)
//         guard PKAddPaymentPassViewController.canAddPaymentPass() else {
//             print("Error: Device cannot add payment passes.")
//             // Show an alert to the user explaining the issue
//             provisioningResult = false // Indicate failure
//             return
//         }
//
//         // 3. Create the configuration for the request
//          //    NOTE: THIS IS HIGHLY SIMPLIFIED. Real configuration involves specific
//          //    details about your payment network, encryption schemes, etc.
//          //    Refer to Apple's documentation and your payment processor.
//          guard let configuration = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2) else {
//              print("Error: Failed to create PassKit configuration.")
//               provisioningResult = false
//             return
//         }
//
//         // Populate configuration details (THESE ARE EXAMPLES - CONSULT DOCUMENTATION)
//         configuration.cardholderName = provisioningData.cardholderName
//         configuration.primaryAccountSuffix = provisioningData.primaryAccountSuffix
//         // configuration.localizedDescription = "Your Robinhood Card"  // Optional description
//         // configuration.paymentNetwork = .visa // Example - Specify network if known
//         // configuration.primaryAccountIdentifier = ... // Optional: If you have a specific identifier
//
//         // 4. Create the request object
//          let request = PKAddPaymentPassRequest()
////          request.configuration = configuration
//
//         // THESE REQUIRE SECURE DATA FROM YOUR BACKEND IN A REAL APP
//          request.encryptedPassData = provisioningData.encryptedPassData // FROM BACKEND
//          request.activationData = provisioningData.activationData        // FROM BACKEND
//          request.ephemeralPublicKey = provisioningData.ephemeralPublicKey  // FROM BACKEND
//
//          // 5. Store the request and trigger the sheet presentation
//          self.addCardRequest = request
//          self.provisioningResult = nil // Reset previous result
//          self.showAddCardSheet = true
//    }
//}
//
//// --- SwiftUI View Representable for PKAddPaymentPassViewController ---
//struct AddPaymentPassViewControllerRepresentable: UIViewControllerRepresentable {
//    typealias UIViewControllerType = PKAddPaymentPassViewController
//
//    let request: PKAddPaymentPassRequest
//    let completionHandler: (PKAddPaymentPassResult) -> Void
//
////    func makeUIViewController(context: Context) -> UIViewControllerType {
////         // PKAddPaymentPassViewController must have a delegate
////        guard let controller = PKAddPaymentPassViewController(requestConfiguration: request, delegate: context.coordinator) else {
////             // Handle the extremely rare case where initialization fails
////             print("Error: Failed to initialize PKAddPaymentPassViewController.")
////             // Return a placeholder or handle error appropriately
////             return PKAddPaymentPassViewController() // Return empty controller to avoid crash
////         }
////         return controller
////    }
//
//    func makeUIViewController(context: Context) -> UIViewControllerType {
//            // PKAddPaymentPassViewController must have a delegate
//            // Use the initializer that takes the full request object
//            guard let controller = PKAddPaymentPassViewController(request: request, delegate: context.coordinator) else { // <--- CORRECTED INITIALIZER
//                // Handle the extremely rare case where initialization fails
//                print("Error: Failed to initialize PKAddPaymentPassViewController.")
//                // Return a placeholder or handle error appropriately
//                return PKAddPaymentPassViewController() // Return empty controller to avoid crash
//            }
//            return controller
//       }
//    
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        // No update logic needed typically, as the request is set on initialization
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    // --- Coordinator Class to act as the Delegate ---
//    class Coordinator: NSObject, PKAddPaymentPassViewControllerDelegate {
////        func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController,
////                                          generateRequestWithCertificateChain certificates: [Data],
////                                          nonce: Data,
////                                          nonceSignature: Data,
////                                          completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void
////        ) {
////            return
////        }
//        
//        func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController, generateRequestWithCertificateChain certificates: [Data], nonce: Data, nonceSignature: Data) async -> PKAddPaymentPassRequest {
//            return await parent.request
//        }
//        
//         var parent: AddPaymentPassViewControllerRepresentable
//
//         init(_ parent: AddPaymentPassViewControllerRepresentable) {
//             self.parent = parent
//         }
//
//         // Delegate method called when the process completes
//         func addPaymentPassViewController(
//             _ controller: PKAddPaymentPassViewController,
//             didFinishAdding pass: PKPaymentPass?, // The pass if successfully added
//             error: Error? // Error object if it failed
//         ) {
//             controller.dismiss(animated: true) { [weak self] in
//                guard let self = self else { return }
//
//                 if let error = error as? PKPassKitError {
//                     print("PassKit Error adding card: \(error.localizedDescription) (Code: \(error.code.rawValue))")
//                     // Map specific PKPassKitError codes to user-friendly messages if needed
//                     switch error.code {
//                     case .invalidDataError:
//                             self.parent.completionHandler(.cancelled)
//                     case .invalidSignature, .notEntitledError, .unsupportedVersionError, .unknownError:
//                             self.parent.completionHandler(.failure) // Technical / configuration failures
//                         default:
//                            self.parent.completionHandler(.failure) // Other failures
//                    }
//
//                 } else if error != nil {
//                     print("Unknown error adding card: \(error!.localizedDescription)")
//                    self.parent.completionHandler(.failure)
//                } else if pass != nil {
//                    // Successfully added the pass!
//                    print("Card added successfully: \(pass?.primaryAccountNumberSuffix ?? "N/A")")
//                   self.parent.completionHandler(.success)
//               } else {
//                   // Dismissed without adding (e.g., user tapped Cancel)
//                   print("Add card cancelled by user or unknown reason.")
//                   self.parent.completionHandler(.cancelled) // Treat as cancellation if no pass and no specific error
//                }
//             }
//         }
//     }
//}
//
//// --- Simple Card Visual Placeholder ---
//struct SimpleCardView: View {
//    let cardInfo: CardDisplayInfo
//    private let cornerRadius: CGFloat = 10.0
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                 Text(cardInfo.issuer)
//                    .font(.headline)
//                    .fontWeight(.bold)
//                Text("Card ending in \(cardInfo.last4)")
//                     .font(.subheadline)
//                     .foregroundColor(.secondary)
//            }
//            Spacer()
//             // Placeholder for Network Logo
//             Image(systemName: cardInfo.network.lowercased() == "visa" ? "creditcard.fill" : "creditcard") // Example mapping
//                .font(.title)
//                .foregroundColor(Color.rhGold) // Use brand color
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(cornerRadius)
//        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//         .overlay(
//             RoundedRectangle(cornerRadius: cornerRadius)
//                 .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//         )
//
//    }
//}
//
//// --- Enum for Result Handling ---
//enum PKAddPaymentPassResult: Int {
//     case success
//     case failure
//     case cancelled
// }
//
//// --- Apple Pay Button (Uses UIKit Wrapper) ---
//struct AddPaymentPassButton: UIViewRepresentable {
//     let action: () -> Void
//
//     func makeUIView(context: Context) -> PKAddPassButton {
//         let button = PKAddPassButton(addPassButtonStyle: .blackOutline) // Or .black for solid
//         button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
//         return button
//     }
//
//     func updateUIView(_ uiView: PKAddPassButton, context: Context) { }
//
//     func makeCoordinator() -> Coordinator {
//         Coordinator(action: action)
//     }
//
//     class Coordinator: NSObject {
//         let action: () -> Void
//
//         init(action: @escaping () -> Void) {
//             self.action = action
//         }
//
//         @objc func buttonTapped() {
//             action()
//         }
//     }
// }
//
//// --- Previews ---
//struct AddToWalletView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddToWalletView()
//            .environment(\.colorScheme, .light)
//    }
//}
//
//// Extend Color if not already done in the project
//// extension Color { ... } // Include rhBeige, rhGold etc.
