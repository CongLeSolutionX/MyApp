//
//  V2.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

//
//  MyApp.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import AuthenticationServices // Import needed framework

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            //                .environment(\.window, UIApplication.shared.windows.filter {$0.isKeyWindow}.first) // Provide window for anchor
        }
    }
}

// Environment Key to pass the window for the presentation anchor
struct WindowKey: EnvironmentKey {
    static let defaultValue: UIWindow? = nil
}

extension EnvironmentValues {
    var window: UIWindow? {
        get { self[WindowKey.self] }
        set { self[WindowKey.self] = newValue }
    }
}


//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import AuthenticationServices // Import needed framework

struct ContentView: View {
    @State private var isLoggedIn: Bool = false // State to track login status across app start
    
    var body: some View {
        // Choose view based on login state
        if isLoggedIn {
            // If logged in (potentially checked via credential state), show ResultView directly
            // Need to fetch user details associated with the keychain ID here
            NavigationView { // Wrap ResultView in NavigationView
                ResultView(user: loadUserFromKeychainIdentifier(), isLoggedIn: $isLoggedIn)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
        } else {
            // Otherwise, show the LoginView
            LoginView(isLoggedIn: $isLoggedIn) // Pass binding to LoginView
        }
    }
    
    // Helper function to load user data based on stored identifier
    // In a real app, you'd likely fetch this from your backend using the identifier
    private func loadUserFromKeychainIdentifier() -> User? {
        let identifier = KeychainItem.currentUserIdentifier
        guard !identifier.isEmpty else { return nil }
        // --- Fetch full user details from your backend based on 'identifier' ---
        // For this example, we'll simulate loading placeholder data.
        // IMPORTANT: Email/Name are typically only returned on *first* sign-in.
        // You MUST save them on your backend associated with the identifier then.
        print("Simulating user load for identifier: \(identifier)")
        return User(identifier: identifier,
                    givenName: "Stored", // Replace with actual fetched data
                    familyName: "User",  // Replace with actual fetched data
                    email: "stored_email@example.com") // Replace with actual fetched data
    }
}

#Preview {
    ContentView()
}

//
//  LoginView.swift
//  MyApp
//
//  Created by Cong Le on 3/14/25.
// Updated for Sign in with Apple
//

import SwiftUI
import AuthenticationServices // Import needed framework

// User Struct remains the same
struct User: Identifiable {
    let id: String
    let givenName: String
    let familyName: String
    let email: String
    
    init(identifier: String, givenName: String, familyName: String, email: String) {
        self.id = identifier
        self.givenName = givenName
        self.familyName = familyName
        self.email = email
    }
}

struct LoginView: View {
    // Bindings and State
    @Binding var isLoggedIn: Bool      // Control navigation via ContentView
    @State private var user: User? = nil // Store user data from Apple Sign In
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Environment property to get the window for the presentation anchor
    //    @Environment(\.window) var window: UIWindow?
    @Environment(\.colorScheme) var colorScheme // To adjust button style
    
    // Removed email/password state variables as we focus on Sign in with Apple
    
    init(isLoggedIn: Binding<Bool>) {
        self._isLoggedIn = isLoggedIn // Initialize the binding
        
        // Perform credential state check when LoginView appears
        // This could alternatively live in ContentView's onAppear
        checkCredentialState()
    }
    
    var body: some View {
        // No NavigationView needed here if ContentView handles it
        ZStack {
            Color.orange.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Cong Le SolutionX")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 50) // Adjust top padding
                    .padding(.bottom, 40)
                
                
                // --- Removed Email/Password Fields ---
                
                
                // --- Removed Manual Log In Button ---
                
                
                // Sign in with Apple Button integrated using UIViewRepresentable
                SignInWithAppleButtonView(
                    isLoggedIn: $isLoggedIn,
                    user: $user,
                    showingAlert: $showingAlert,
                    alertMessage: $alertMessage
                    //                     window: window // Pass the window
                )
                .frame(height: 50) // Standard height for the button
                .padding(.horizontal) // Padding around the button
                .shadow(radius: 3)
                
                
                // Optional: Add separator or text like "OR" if keeping email/pass login
                // Text("OR")
                //    .foregroundColor(.white.opacity(0.8))
                //    .padding(.vertical)
                
                
                // --- Footer links remain the same ---
                HStack {
                    Button("Forgot Password?") {
                        print("Forgot Password tapped (Manual flow)")
                        alertMessage = "Password reset is for manual login only."
                        showingAlert = true
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Create Account") {
                        print("Create Account tapped (Manual flow)")
                        alertMessage = "Account creation is for manual login only."
                        showingAlert = true
                    }
                    .foregroundColor(.white)
                }
                .padding(.top, 10)
                .padding(.horizontal) // Add padding to HStack
                
                Spacer() // Push content to the top
            }
            .padding() // Overall padding for the VStack
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Sign In Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            
            // Navigation is now handled by the binding change triggering ContentView update
            // No hidden NavigationLink needed here anymore.
        } // ZStack End
        .onAppear {
            // Optionally re-check credential state if needed when view appears
            // checkCredentialState() // Might be redundant if checked on init/ContentView
        }
    }
    
    
    // --- Removed manual login() function ---
    
    
    // Function to check Apple ID credential state
    // Typically called once when the app/view initializes
    func checkCredentialState() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let userId = KeychainItem.currentUserIdentifier // Fetch stored identifier
        
        guard !userId.isEmpty else {
            print("No user identifier found in keychain. User needs to sign in.")
            // Ensure isLoggedIn state is false if no ID exists
            DispatchQueue.main.async {
                if self.isLoggedIn { self.isLoggedIn = false }
            }
            return
        }
        
        appleIDProvider.getCredentialState(forUserID: userId) { (credentialState, error) in
            DispatchQueue.main.async { // Ensure UI updates on main thread
                switch credentialState {
                case .authorized:
                    // User is authorized, potentially bypass login screen
                    print("Credential state: Authorized for user \(userId)")
                    // Check if already logged in to avoid unnecessary state change
                    if !self.isLoggedIn {
                        // You might want to fetch full user details here before setting loggedIn
                        // For now, directly set loggedIn based on state check
                        self.isLoggedIn = true
                    }
                case .revoked:
                    // User revoked authorization
                    print("Credential state: Revoked for user \(userId)")
                    self.handleLogoutState() // Clear keychain and ensure logged out
                    self.alertMessage = "Sign in with Apple authorization was revoked."
                    self.showingAlert = true
                case .notFound:
                    // Credential not found for this user ID
                    print("Credential state: Not Found for user \(userId)")
                    self.handleLogoutState() // Clear potentially stale keychain item
                    self.alertMessage = "Sign in with Apple credential not found."
                    self.showingAlert = true
                default:
                    print("Credential state: Unknown or Transferred")
                    // Treat as logged out for safety
                    self.handleLogoutState()
                }
            }
        }
    }
    
    // Helper to ensure Keychain is cleared and state is logged out
    private func handleLogoutState() {
        print("Handling logout state: Clearing keychain and setting isLoggedIn to false.")
        KeychainItem.deleteUserIdentifierFromKeychain()
        if self.isLoggedIn { self.isLoggedIn = false }
    }
}

// --- ResultView remains largely the same ---
// (Included for completeness, minor adjustments)
struct ResultView: View {
    let user: User?
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        ZStack {
            Color.orange.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Welcome!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                Group {
                    // Display Identifier (Crucial, always available after login)
                    InfoRow(label: "User Identifier:", value: user?.id ?? KeychainItem.currentUserIdentifier) // Fallback to keychain just in case
                    // Display Name/Email (May be empty on subsequent logins if not saved server-side)
                    InfoRow(label: "Given Name:", value: user?.givenName ?? "Not Provided") // Indicate if not available
                    InfoRow(label: "Family Name:", value: user?.familyName ?? "Not Provided")
                    InfoRow(label: "Email:", value: user?.email ?? "Not Provided")
                }
                .padding(.bottom, 5)
                
                Spacer()
                
                Button("Sign Out") {
                    signOut()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(radius: 3)
                .padding(.bottom, 20)
            }
            .padding()
        }
        .navigationTitle("User Profile")
        .navigationBarBackButtonHidden(true) // Keep this for sign-out navigation
        // Add a sign out button in the navigation bar as well (optional)
        // .navigationBarItems(leading: Button("Sign Out") { signOut() })
    }
    
    func signOut() {
        print("Signing out user...")
        KeychainItem.deleteUserIdentifierFromKeychain()
        // State change triggers navigation back via ContentView
        isLoggedIn = false
    }
}

// Helper view for displaying info rows consistently
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8)) // Slightly dimmer label
            Text(value)
                .font(.body)
                .foregroundColor(.white)
        }
    }
}

// --- Previews remain largely the same ---
// (Adjust to reflect Sign in with Apple focus)
struct LoginFlow_Previews: PreviewProvider {
    static let sampleUser = User(identifier: "preview123", givenName: "Preview", familyName: "User", email: "preview@example.com")
    
    static var previews: some View {
        // Preview LoginView (requires a constant binding)
        LoginView(isLoggedIn: .constant(false))
            .previewDisplayName("Login Screen")
        
        // Preview ResultView
        NavigationView {
            ResultView(user: sampleUser, isLoggedIn: .constant(true))
        }
        .previewDisplayName("Result Screen (Logged In)")
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// --- KeychainItem remains the same ---
// (Included for completeness, use the refined version from the previous response)
import Security

struct KeychainItem {
    // MARK: Types
    
    /// Errors that can occur during Keychain operations.
    enum KeychainError: Error {
        case itemNotFound                 // No item found for the given query (renamed from noPassword)
        case duplicateItem                // Item already exists when trying to add (less common with update logic)
        case unexpectedDataFormat         // Data retrieved is not in the expected format (renamed from unexpectedPasswordData)
        case unhandledError(status: OSStatus) // Wraps unexpected OSStatus codes
    }
    
    // MARK: Properties
    
    /// A unique identifier for the service associated with this keychain item.
    /// Recommended format: reverse domain name notation (e.g., "com.myapp.userservice").
    let service: String
    
    /// The account key associated with this item (e.g., "userIdentifier", "sessionToken").
    let account: String
    
    /// An optional access group for sharing keychain items between apps from the same developer.
    let accessGroup: String?
    
    // MARK: Static Constants
    /// Define the service identifier centrally for consistent use across the app.
    static let userServiceIdentifier = "com.example.solutionx.myapp" // Make this unique to your app/company
    
    // MARK: Initialization
    
    /// Initializes a KeychainItem instance.
    /// - Parameters:
    ///   - service: The service identifier (e.g., `KeychainItem.userServiceIdentifier`).
    ///   - account: The account key (e.g., "userIdentifier").
    ///   - accessGroup: Optional access group for sharing.
    init(service: String, account: String, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }
    
    // MARK: Keychain Operations
    
    /// Reads the value associated with this keychain item.
    /// - Returns: The stored string value.
    /// - Throws: A `KeychainError` if reading fails.
    func readItem() throws -> String {
        var query = self.baseQuery()
        // Specify we want the data returned and match only one item.
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var item: CFTypeRef? // Use CFTypeRef for the result
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        switch status {
        case errSecSuccess:
            // Item found, attempt to decode the data.
            guard let data = item as? Data,
                  let value = String(data: data, encoding: .utf8) else {
                // Data exists but isn't valid UTF-8 string.
                throw KeychainError.unexpectedDataFormat
            }
            return value
        case errSecItemNotFound:
            // Item simply doesn't exist.
            throw KeychainError.itemNotFound
        default:
            // Any other error.
            print("Keychain read failed with status: \(status)")
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    /// Saves a string value to the keychain. Updates the item if it exists, otherwise adds it.
    /// - Parameter value: The string value to save.
    /// - Throws: A `KeychainError` if saving fails.
    func saveItem(_ value: String) throws {
        guard let encodedValue = value.data(using: .utf8) else {
            // Should not happen with standard strings, but good practice to check.
            throw KeychainError.unexpectedDataFormat
        }
        
        // Try to update first. If it fails because the item doesn't exist, then add.
        var query = self.baseQuery()
        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: encodedValue,
            // Update modification date automatically
            // kSecAttrModificationDate as String: Date() // Optional: Explicitly set modification date
        ]
        
        let statusUpdate = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        switch statusUpdate {
        case errSecSuccess:
            // Update was successful.
            print("Keychain item updated successfully for account: \(account)")
            return // Done
        case errSecItemNotFound:
            // Item not found, so proceed to add it.
            print("Item not found for update, attempting to add...")
            // Add the value and accessibility attribute to the base query for adding.
            query[kSecValueData as String] = encodedValue
            query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            
            let statusAdd = SecItemAdd(query as CFDictionary, nil)
            if statusAdd == errSecSuccess {
                // Add was successful.
                print("Keychain item added successfully for account: \(account)")
                return // Done
            } else if statusAdd == errSecDuplicateItem {
                // This case is rare if update logic is correct, but handle defensively.
                print("Keychain add failed: Duplicate item exists (unexpected after update check).")
                throw KeychainError.duplicateItem
            }
            else {
                // Add failed for another reason.
                print("Keychain add failed with status: \(statusAdd)")
                throw KeychainError.unhandledError(status: statusAdd)
            }
        default:
            // Update failed for a reason other than not found.
            print("Keychain update failed with status: \(statusUpdate)")
            throw KeychainError.unhandledError(status: statusUpdate)
        }
    }
    
    /// Deletes the item from the keychain. Does not throw an error if the item was already missing.
    /// - Throws: A `KeychainError` if deletion fails for reasons other than the item not being found.
    func deleteItem() throws {
        let query = self.baseQuery()
        let status = SecItemDelete(query as CFDictionary)
        
        // Treat success and item not found as successful deletion from the user's perspective.
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Keychain delete failed with status: \(status)")
            throw KeychainError.unhandledError(status: status)
        }
        print("Keychain item deleted (or was not found) for account: \(account)")
    }
    
    // MARK: Convenience Helper
    
    /// Creates the base dictionary query for keychain operations for this item.
    private func baseQuery() -> [String: Any] {
        var query: [String: Any] = [:]
        query[kSecClass as String] = kSecClassGenericPassword // Type of item
        query[kSecAttrService as String] = self.service        // Service identifier
        query[kSecAttrAccount as String] = self.account        // Account key
        
        // Include access group if specified.
        if let accessGroup = self.accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        // Optional: Specify synchronization behavior (e.g., iCloud Keychain)
        // query[kSecAttrSynchronizable as String] = kCFBooleanTrue // To sync with iCloud Keychain
        // query[kSecAttrSynchronizable as String] = kCFBooleanFalse // To keep local only
        // Default (not specifying) is kSecAttrSynchronizableAny
        
        return query
    }
    
    // MARK: Static Convenience Accessors
    
    /// Retrieves the currently stored user identifier using the app's standard service ID.
    /// Returns an empty string if not found or an error occurs.
    static var currentUserIdentifier: String {
        let keychainItem = KeychainItem(service: userServiceIdentifier, account: "userIdentifier")
        do {
            let identifier = try keychainItem.readItem()
            print("Successfully read user identifier from keychain.")
            return identifier
        } catch KeychainError.itemNotFound {
            print("No user identifier found in keychain for account 'userIdentifier'.")
            return ""
        } catch {
            print("Error reading userIdentifier from keychain: \(error)")
            return "" // Return empty for any other error
        }
    }
    
    /// Deletes the stored user identifier from the keychain using the app's standard service ID.
    static func deleteUserIdentifierFromKeychain() {
        let keychainItem = KeychainItem(service: userServiceIdentifier, account: "userIdentifier")
        do {
            try keychainItem.deleteItem()
        } catch {
            // Log the error, but maybe don't crash the app.
            // Depending on the scenario, UI feedback might be needed if deletion fails.
            print("Failed to delete userIdentifier from keychain: \(error)")
        }
    }
}


// MARK: - Sign in With Apple Button View Representable

struct SignInWithAppleButtonView: UIViewRepresentable {
    // Bindings to update the parent view's state
    @Binding var isLoggedIn: Bool
    @Binding var user: User?
    @Binding var showingAlert: Bool
    @Binding var alertMessage: String
   
    
    @Environment(\.colorScheme) var colorScheme // Access color scheme
    
    // Create the UIKit button
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        // Determine button style based on color scheme
        let style: ASAuthorizationAppleIDButton.Style = (colorScheme == .dark) ? .white : .black
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: style) // Use .signIn type
        button.addTarget(context.coordinator, action: #selector(Coordinator.handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        return button
    }
    
    // Update the view (not typically needed for this button)
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
    
    // Create the Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator Class
    class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        var parent: SignInWithAppleButtonView
        
        init(_ parent: SignInWithAppleButtonView) {
            self.parent = parent
            super.init()
            
            // Add observer for credential revoked notification (good practice)
            NotificationCenter.default.addObserver(self, selector: #selector(appleIDCredentialRevoked), name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        // Notification handler
        @objc func appleIDCredentialRevoked() {
            print("Apple ID Credential Revoked notification received.")
            parent.alertMessage = "Your Sign in with Apple authorization was revoked."
            parent.showingAlert = true
            // Ensure user is logged out in the app state
            KeychainItem.deleteUserIdentifierFromKeychain()
            parent.isLoggedIn = false
        }
        
        
        // Action called when the Sign in with Apple button is pressed
        @objc func handleAuthorizationAppleIDButtonPress() {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            // Request full name and email (only provided on first sign-in)
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
        
        // MARK: - ASAuthorizationControllerDelegate Methods
        
        // Handle successful authorization
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                let userIdentifier = appleIDCredential.user // This is the stable user ID
                let fullName = appleIDCredential.fullName // PersonNameComponents (Optional)
                let email = appleIDCredential.email       // String (Optional, possibly proxied)
                
                // --- IMPORTANT: Handle User Data ---
                // 1. Save the userIdentifier securely (e.g., Keychain)
                // 2. On the *very first* login for this userIdentifier,
                //    send fullName and email to your backend and associate
                //    them with the userIdentifier.
                // 3. Subsequent logins will likely NOT contain fullName or email.
                //    Your app should fetch these details from YOUR backend using the userIdentifier.
                
                print("Apple ID Credential Received:")
                print("- User Identifier: \(userIdentifier)")
                print("- Full Name: \(fullName?.givenName ?? "N/A") \(fullName?.familyName ?? "N/A")")
                print("- Email: \(email ?? "N/A")")
                
                // Save the crucial user identifier to Keychain
                do {
                    try KeychainItem(service: KeychainItem.userServiceIdentifier, account: "userIdentifier").saveItem(userIdentifier)
                    print("User identifier successfully saved to keychain.")
                    
                    // Create User object for the ResultView
                    // Use fetched name/email from your backend if this isn't the first login
                    let userForView = User(
                        identifier: userIdentifier,
                        // Use provided name/email, fallback to placeholder or backend data
                        givenName: fullName?.givenName ?? "First",
                        familyName: fullName?.familyName ?? "Last",
                        email: email ?? "email@example.com" // Use real or placeholder if nil
                    )
                    
                    // Update parent view's state on the main thread
                    DispatchQueue.main.async {
                        self.parent.user = userForView
                        self.parent.isLoggedIn = true // Trigger navigation/UI update
                    }
                    
                } catch {
                    print("Error saving user identifier to keychain: \(error)")
                    DispatchQueue.main.async {
                        self.parent.alertMessage = "Sign in succeeded but failed to save session."
                        self.parent.showingAlert = true
                        // Ensure loggedIn state remains false if keychain save fails
                        self.parent.isLoggedIn = false
                    }
                }
                
            case let passwordCredential as ASPasswordCredential:
                // Handle sign-in using existing iCloud Keychain credentials
                let username = passwordCredential.user
                let password = passwordCredential.password // Use this to log in to your backend
                
                print("Password Credential Received:")
                print("- Username: \(username)")
                // Never print the password in production code!
                // print("- Password: \(password)")
                
                // --- Implement your logic to sign in with username/password ---
                // Example: Call your backend API with these credentials
                
                DispatchQueue.main.async {
                    // Show feedback or navigate based on your backend response
                    self.parent.alertMessage = "Password credential received (login not implemented)."
                    self.parent.showingAlert = true
                    self.parent.isLoggedIn = false // Keep logged out until backend confirms
                }
                
            default:
                break // Handle other credential types if necessary
            }
        }
        
        // Handle authorization error
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            // Handle errors (e.g., user cancelled, network issue)
            print("Sign in with Apple failed: \(error.localizedDescription)")
            
            // Don't show alert if user simply cancelled
            if (error as? ASAuthorizationError)?.code == .canceled {
                print("User cancelled Sign in with Apple.")
                return
            }
            
            DispatchQueue.main.async {
                self.parent.alertMessage = "Sign in with Apple failed: \(error.localizedDescription)"
                self.parent.showingAlert = true
                self.parent.isLoggedIn = false // Ensure logged out state on error
            }
        }
        
        // MARK: - ASAuthorizationControllerPresentationContextProviding Methods
        
        // Provide the window in which to present the Apple Sign In sheet
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            // Find the relevant window scene and window
            guard let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
                // Handle the error appropriately - maybe return a fallback window
                // or log an error. Returning the key window of the app delegate might
                // work as a last resort, but finding the active scene is preferred.
                print("Error: Could not find active UIWindowScene.")
                // Fallback (less reliable):
                if let fallbackWindow = UIApplication.shared.delegate?.window ?? nil {
                    return fallbackWindow
                } else {
                    // If absolutely no window can be found, you might have to prevent the operation.
                    // Returning a default UIWindow() is unlikely to work correctly.
                    // Consider logging this scenario heavily.
                    fatalError("Could not determine presentation anchor window.")
                }
            }
            
            // Get the key window from the found scene
            guard let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                print("Error: Could not find key window in the active scene.")
                // Fallback to the first window of the scene if no key window (less common)
                if let fallbackWindow = windowScene.windows.first {
                    return fallbackWindow
                } else {
                    fatalError("Active scene has no windows to use as presentation anchor.")
                }
            }
            print("Presentation Anchor: Found key window \(keyWindow)")
            return keyWindow
        }
        
    }
}
