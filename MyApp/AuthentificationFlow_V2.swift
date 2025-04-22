//
//  AuthentificationFlow_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/21/25.
//

import SwiftUI

// --- Data Structures for API Communication ---

struct LoginRequestBody: Codable {
    let email: String
    let password: String
}

struct TwoFactorRequestBody: Codable {
    let code: String
    let sessionToken: String // Renamed from sessionToken for clarity
}

// Unified Response Structure (flexible for both endpoints)
struct ApiResponse: Codable {
    // Fields from initial /authenticate response
    let twoFactorRequired: Bool?
    let sessionToken: String? // Token needed if twoFactorRequired is true
    
    // Fields from final /authenticate/2fa response (or initial if no 2FA)
    let accountId: String?
    let profile: Profile?
    
    // Potential error details from either endpoint
    let error: ApiErrorDetail? // Use a nested struct for clarity
}

struct Profile: Codable, Equatable { // Make Profile Equatable if needed later
    let id: Int
    let username: String
    let email: String // Assuming email comes back in profile too
    let avatarUrl: String? // Keep optional as per original comment example
}

// Example structure for API error responses
struct ApiErrorDetail: Codable {
    let message: String? // Assuming structure like { "error": { "message": "..." } }
    // Add other potential error fields if the API provides them (e.g., code)
}

// Represents the different states the authentication UI can be in.
// Add associated data to states where needed (e.g., storing profile on success)
enum AuthenticationState: Equatable {
    case initial
    case loggingIn
    case twoFactorRequired(sessionToken: String) // Store the token
    case submittingTwoFactor(sessionToken: String) // Pass token along for potential retries
    case authenticated(profileData: Profile) // Store profile on success
    case error(message: String)
    
    // Equatable conformance is needed for .onChange and state comparison
    static func == (lhs: AuthenticationState, rhs: AuthenticationState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial): return true
        case (.loggingIn, .loggingIn): return true
        case (.twoFactorRequired(let token1), .twoFactorRequired(let token2)): return token1 == token2
        case (.submittingTwoFactor(let token1), .submittingTwoFactor(let token2)): return token1 == token2 // Compare tokens if needed for retry logic
        case (.authenticated(let profile1), .authenticated(let profile2)): return profile1 == profile2 // Compare profile data
        case (.error(let msg1), .error(let msg2)): return msg1 == msg2
        default: return false
        }
    }
}

struct AuthView: View {
    // --- State ---
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var twoFactorCode: String = ""
    @State private var authState: AuthenticationState = .initial
    
    // --- API Configuration ---
    // !! SECURITY WARNING: Hardcoding API keys is extremely insecure! !!
    // !! Replace with a secure method in a real application.        !!
    private let apiBaseUrl = "https://app.onlyfansapi.com/api" // Use HTTPS
    private let hardcodedBearerToken = "Bearer sk_00000000000000000000000000000000" // !! INSECURE !!
    
    // --- Computed Properties for UI Logic ---
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
        switch authState {
        case .twoFactorRequired, .submittingTwoFactor:
            return true
            // Keep showing 2FA input if an error occurred *during* the 2FA step
        case .error where !twoFactorCode.isEmpty:
            // Check if the error state likely followed a 2FA attempt
            // This logic might need refinement based on how states transition
            return true // Simplistic check: if 2FA code has been entered prior to error
        default:
            return false
        }
    }
    
    // --- Body ---
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // --- Card View ---
                VStack(alignment: .leading, spacing: 20) {
                    Text(showTwoFactorInput ? "Enter 2FA Code" : "Log In")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // --- Input Fields ---
                    if showTwoFactorInput {
                        // Moved prompt inside the if block
                        Text("A code was sent to your authentication device.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, -10) // Adjust spacing
                        
                        SecureField("6-Digit Code", text: $twoFactorCode)
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                            .padding(10)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                            .disabled(isLoading)
                        
                    } else {
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
                            .frame(maxWidth: .infinity, alignment: .leading) // Ensure it takes space
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
                        .background(isLoading ? Color.gray : Color.blue)
                        .cornerRadius(10)
                    }
                    .disabled(isLoading)
                    
                }
                .padding(30)
                .background(.regularMaterial)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
                
                Spacer()
                Spacer()
            } // End Main VStack
            
            // --- Loading Overlay ---
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white)) // Customize color if needed
                    .scaleEffect(1.5)
                    .frame(width: 80, height: 80)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(15)
            }
        } // End ZStack
        .onChange(of: authState) { newState in
            if case .authenticated(let profile) = newState {
                print("Authentication Successful! User: \(profile.username). Clear fields and navigate.")
                // Clear sensitive fields after successful authentication
                self.password = ""
                self.twoFactorCode = ""
                // Trigger navigation or other post-login actions here
            } else if case .error(let message) = newState {
                print("Authentication Error: \(message)")
                // Optionally clear fields based on the error type
                // e.g., clear password on invalid login, but not 2FA code on invalid code
                if !showTwoFactorInput { // Error during initial login
                    self.password = ""
                }
            } else if case .twoFactorRequired = newState {
                // Clear password field when moving to 2FA step
                self.password = ""
            }
        }
        .animation(.default, value: showTwoFactorInput) // Animate the input switch
        .animation(.default, value: isLoading)       // Animate loading indicator appearance
        .animation(.default, value: errorMessage) // Animate error message appearance
    }
    
    // --- Action Handlers ---
    func handleButtonTap() {
        // Reset error state before attempting action
        // if case .error = authState { authState = .initial } // Or more specific reset needed?
        
        if showTwoFactorInput {
            // Extract session token safely
            guard case .twoFactorRequired(let token) = authState else {
                // Or handle potential state after error
                if case .submittingTwoFactor(let token) = authState { // Allow retry
                    submitTwoFactor(sessionToken: token)
                } else if case .error = authState, let previousToken = getPreviousSessionToken() { // Attempt retry after error
                    submitTwoFactor(sessionToken: previousToken)
                }
                else {
                    print("Error: Invalid state or missing token for 2FA submission.")
                    authState = .error(message: "An internal error occurred. Please restart the login process.")
                    return
                }
                return // Needed because guard didn't return
            }
            submitTwoFactor(sessionToken: token)
        } else {
            performLogin()
        }
    }
    
    // Helper to potentially recover session token after an error in the 2FA screen
    func getPreviousSessionToken() -> String? {
        // This is simplistic. A real app might store the token more robustly
        // during the 2FA phase in case of recoverable errors.
        // For this example, if we are in error state AND 2fa code isn't empty
        // assume we *were* in twoFactorRequired state. VERY UNSAFE ASSUMPTION.
        // A better approach is to pass the token to the submittingTwoFactor state too.
        // --> Updated the enum state to handle this better.
        if case .submittingTwoFactor(let token) = authState { return token }
        return nil
    }
    
    // --- API Call Functions ---
    
    func performLogin() {
        print("Attempting login with Email: \(email)")
        authState = .loggingIn
        
        guard let url = URL(string: "\(apiBaseUrl)/authenticate") else {
            authState = .error(message: "Invalid API URL.")
            return
        }
        
        let requestBody = LoginRequestBody(email: email, password: password)
        guard let encodedBody = try? JSONEncoder().encode(requestBody) else {
            authState = .error(message: "Failed to prepare login data.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // !! SECURITY WARNING: Hardcoded Bearer token is insecure !!
        request.setValue(hardcodedBearerToken, forHTTPHeaderField: "Authorization")
        request.httpBody = encodedBody
        
        Task { // Perform network request in a background task
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                print("Login Response Status Code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    // Try to decode error message from body for non-2xx responses
                    let decodedError = try? JSONDecoder().decode(ApiResponse.self, from: data)
                    let errorMessage = decodedError?.error?.message ?? "Login failed with status: \(httpResponse.statusCode)"
                    throw NetworkError.serverError(message: errorMessage)
                }
                
                let decodedResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                
                if decodedResponse.twoFactorRequired == true, let token = decodedResponse.sessionToken {
                    print("Login step successful, 2FA required. Token: \(token)")
                    // Update state on the main thread
                    await MainActor.run { authState = .twoFactorRequired(sessionToken: token) }
                } else if let profile = decodedResponse.profile, decodedResponse.accountId != nil {
                    // Successfully authenticated without 2FA
                    print("Login successful (no 2FA). Profile: \(profile.username)")
                    await MainActor.run { authState = .authenticated(profileData: profile) }
                } else {
                    // Unexpected response structure
                    throw NetworkError.dataCorrupted(message: "Missing expected data in login response.")
                }
                
            } catch let error as NetworkError {
                print("Network Error during login: \(error.localizedDescription)")
                await MainActor.run { authState = .error(message: error.localizedDescription) }
            } catch { // Catch other errors like decoding errors
                print("Error during login: \(error)")
                let displayMessage = (error as? DecodingError).map { _ in "Invalid response data." } ?? error.localizedDescription
                await MainActor.run { authState = .error(message: displayMessage) }
            }
        }
    }
    
    func submitTwoFactor(sessionToken: String) {
        // Ensure we have a code to send
        guard !twoFactorCode.isEmpty else {
            authState = .error(message: "Please enter the 2FA code.")
            // Revert state slightly to allow re-entry without losing token
            Task { await MainActor.run { authState = .twoFactorRequired(sessionToken: sessionToken) } }
            return
        }
        
        print("Attempting to submit 2FA code: \(twoFactorCode) with token: \(sessionToken)")
        // Update state to indicate submission is in progress, carrying over the token
        authState = .submittingTwoFactor(sessionToken: sessionToken)
        
        guard let url = URL(string: "\(apiBaseUrl)/authenticate/2fa") else {
            authState = .error(message: "Invalid 2FA API URL.")
            return
        }
        
        let requestBody = TwoFactorRequestBody(code: twoFactorCode, sessionToken: sessionToken)
        guard let encodedBody = try? JSONEncoder().encode(requestBody) else {
            authState = .error(message: "Failed to prepare 2FA data.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // !! SECURITY WARNING: Hardcoded Bearer token is insecure !!
        request.setValue(hardcodedBearerToken, forHTTPHeaderField: "Authorization")
        request.httpBody = encodedBody
        
        Task { // Perform network request in a background task
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                print("2FA Response Status Code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    // Try to decode error message from body
                    let decodedError = try? JSONDecoder().decode(ApiResponse.self, from: data)
                    let errorMessage = decodedError?.error?.message ?? "2FA failed with status: \(httpResponse.statusCode)"
                    // Important: revert to a state where user can retry 2FA
                    // await MainActor.run { authState = .error(message: errorMessage) } // This would show the error
                    // Instead, show error AND revert to allow re-entry
                    await MainActor.run {
                        authState = .error(message: errorMessage)
                        // After showing error briefly, maybe revert? Or user must tap again.
                        // Let's revert state so they can re-enter code immediately
                        self.twoFactorCode = "" // Clear the incorrect code
                        authState = .twoFactorRequired(sessionToken: sessionToken)
                    }
                    return // Don't proceed after error
                }
                
                let decodedResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                
                if let profile = decodedResponse.profile, decodedResponse.accountId != nil {
                    print("2FA submission successful. Profile: \(profile.username)")
                    await MainActor.run { authState = .authenticated(profileData: profile) }
                } else {
                    // Unexpected success response structure
                    throw NetworkError.dataCorrupted(message: "Missing expected data in 2FA response.")
                }
                
            } catch let error as NetworkError {
                print("Network Error during 2FA: \(error.localizedDescription)")
                // Revert state to allow retry after showing error
                await MainActor.run {
                    authState = .error(message: error.localizedDescription)
                    self.twoFactorCode = "" // Clear code on error
                    authState = .twoFactorRequired(sessionToken: sessionToken) // Allow retry
                }
            } catch { // Catch other errors like decoding errors
                print("Error during 2FA: \(error)")
                let displayMessage = (error as? DecodingError).map { _ in "Invalid 2FA response data." } ?? error.localizedDescription
                // Revert state to allow retry after showing error
                await MainActor.run {
                    authState = .error(message: displayMessage)
                    self.twoFactorCode = "" // Clear code on error
                    authState = .twoFactorRequired(sessionToken: sessionToken) // Allow retry
                }
            }
        }
    }
}

// --- Custom Error Enum ---
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(statusCode: Int, message: String?)
    case serverError(message: String) // Specific case for non-2xx status
    case decodingError(Error)
    case dataCorrupted(message: String) // For when JSON structure is wrong
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The API endpoint URL is invalid."
        case .invalidResponse: return "Received an invalid response from the server."
        case .requestFailed(let statusCode, let message): return message ?? "Request failed with status code \(statusCode)."
        case .serverError(let message): return message // Already formatted message
        case .decodingError(let underlyingError): return "Failed to decode the server response: \(underlyingError.localizedDescription)"
        case .dataCorrupted(let message): return "Invalid data format received: \(message)"
        case .unknown(let underlyingError): return "An unknown error occurred: \(underlyingError.localizedDescription)"
        }
    }
}

// --- Preview Provider ---
#Preview {
    AuthView()
}
