//
//  AuthentificationFlow.swift
//  MyApp
//
//  Created by Cong Le on 4/21/25.
//

import SwiftUI

// Represents the different states the authentication UI can be in.
enum AuthenticationState {
    case initial // Waiting for email/password
    case loggingIn // First API call in progress
    case twoFactorRequired(sessionToken: String) // Waiting for 2FA code
    case submittingTwoFactor // Second API call in progress
    case authenticated // Login successful
    case error(message: String) // An error occurred
}

struct AuthView: View {
    // State variables to manage UI and data
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var twoFactorCode: String = ""

    // Manages the overall flow and UI presentation
    @State private var authState: AuthenticationState = .initial

    // Derived properties to simplify view logic
    private var isLoading: Bool {
        if case .loggingIn = authState { return true }
        if case .submittingTwoFactor = authState { return true }
        return false
    }

    private var errorMessage: String? {
        if case .error(let message) = authState { return message }
        return nil
    }

    private var showTwoFactorInput: Bool {
        if case .twoFactorRequired = authState { return true }
        // Also keep showing it if submitting 2FA or error occurred during 2FA
        if case .submittingTwoFactor = authState { return true }
        if case .error(let message) = authState, twoFactorCode.isEmpty == false { return true } // Simplistic check
         return false
    }

    var body: some View {
        ZStack {
            // Background (optional, could be a gradient, color, etc.)
            Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)

            // Main Content Vending Machine
            VStack {
                Spacer() // Pushes card towards center/top

                // --- Card View ---
                VStack(alignment: .leading, spacing: 20) {
                    Text(showTwoFactorInput ? "Enter 2FA Code" : "Log In")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    // --- Input Fields ---
                    if showTwoFactorInput {
                        // --- 2FA Code Input ---
                         Text("A code was sent to your authentication device.")
                             .font(.subheadline)
                             .foregroundColor(.secondary)
                        SecureField("6-Digit Code", text: $twoFactorCode)
                             .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode) // Helps with autofill
                            .padding(10)
                            .background(Color(UIColor.secondarySystemBackground))
                           .cornerRadius(8)
                             .disabled(isLoading) // Disable input when loading

                    } else {
                        // --- Email & Password Input ---
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(10)
                             .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                           .disabled(isLoading)

                        SecureField("Password", text: $password)
                           .textContentType(.password)
                            .padding(10)
                            .background(Color(UIColor.secondarySystemBackground))
                           .cornerRadius(8)
                           .disabled(isLoading)
                    }

                   // --- Error Message Display ---
                    if let errorMsg = errorMessage {
                         Text(errorMsg)
                            .foregroundColor(.red)
                            .font(.caption)
                   }

                   // --- Action Button ---
                   Button(action: handleButtonTap) {
                        HStack {
                            Spacer()
                           Text(showTwoFactorInput ? "Submit Code" : "Continue")
                                .fontWeight(.semibold)
                           Spacer()
                       }
                       .padding()
                       .foregroundColor(.white)
                       .background(isLoading ? Color.gray : Color.blue) // Indicate loading/disabled state visually
                       .cornerRadius(10)
                   }
                   .disabled(isLoading) // Disable button when loading

               }
               .padding(30) // Inner padding for card content
                .background(.regularMaterial) // Use material for card background
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
               .padding(.horizontal, 20) // Outer padding for card position

               Spacer() // Pushes card towards center/bottom
                Spacer() // Add more space at the bottom if needed
           }

           // --- Loading Overlay ---
           if isLoading {
              ProgressView()
                   .progressViewStyle(CircularProgressViewStyle(tint: .white))
                   .scaleEffect(1.5)
                  .frame(width: 80, height: 80)
                   .background(Color.black.opacity(0.5))
                  .cornerRadius(15)
           }
       }
       // Add logic here if needed when authState becomes .authenticated
       // e.g., using .onChange to trigger navigation outside this view
        .onChange(of: authState) { newState in
            if case .authenticated = newState {
                print("Authentication Successful! Navigate to next screen.")
                // In a real app, you'd trigger navigation here,
                // clear sensitive fields, etc.
                 // Example: password = ""
                 // Example: twoFactorCode = ""
             }
       }
   }

   // --- Action Handlers ---
    func handleButtonTap() {
       if showTwoFactorInput {
            submitTwoFactor()
        } else {
            performLogin()
        }
    }

   func performLogin() {
       print("Attempting login with Email: \(email)")
       authState = .loggingIn
       // ** Simulate API Call 1 **
        Task {
           // Replace with actual network call
            await Task.sleep(2 * 1_000_000_000) // Simulate 2 second delay

           // --- Simulation Logic ---
           if email.lowercased() == "user@example.com" && password == "password123" {
                // Simulate 2FA required scenario
                print("Login step successful, 2FA required.")
                let fakeSessionToken = "session_token_12345"
                authState = .twoFactorRequired(sessionToken: fakeSessionToken)
            } else if email.lowercased() == "no2fa@example.com" && password == "password123" {
               // Simulate direct login success
                print("Login successful (no 2FA).")
               authState = .authenticated
           } else {
               // Simulate login failure
                print("Login failed.")
                authState = .error(message: "Invalid email or password.")
            }
        }
    }

    func submitTwoFactor() {
       guard case .twoFactorRequired(let sessionToken) = authState else {
           print("Error: Trying to submit 2FA in wrong state.")
           authState = .error(message: "Internal error. Please try logging in again.")
           return
        }

       print("Attempting to submit 2FA code: \(twoFactorCode) with token: \(sessionToken)")
       authState = .submittingTwoFactor

       // ** Simulate API Call 2 **
        Task {
            // Replace with actual network call using twoFactorCode and sessionToken
            await Task.sleep(1 * 1_000_000_000) // Simulate 1 second delay

           // --- Simulation Logic ---
           if twoFactorCode == "123456" {
                // Simulate 2FA success
                print("2FA submission successful.")
                authState = .authenticated
            } else {
               // Simulate 2FA failure
                print("2FA submission failed.")
               authState = .error(message: "Invalid 2FA code.")
                // Reset to allow re-entry, keeping the session token
                authState = .twoFactorRequired(sessionToken: sessionToken)
                // Optionally add a more specific error message here:
                // authState = .error(message: "Incorrect 2FA Code") followed by setting back to .twoFactorRequired
            }
        }
    }
}

// Add Equatable conformance for onChange usage if needed,
// although direct comparison might work for simple enums.
extension AuthenticationState: Equatable {
    static func == (lhs: AuthenticationState, rhs: AuthenticationState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial): return true
        case (.loggingIn, .loggingIn): return true
        case (.twoFactorRequired(let token1), .twoFactorRequired(let token2)): return token1 == token2
        case (.submittingTwoFactor, .submittingTwoFactor): return true
        case (.authenticated, .authenticated): return true
        case (.error(let msg1), .error(let msg2)): return msg1 == msg2
         default: return false
       }
   }
}

// --- Preview Provider ---
#Preview {
    AuthView()
}
