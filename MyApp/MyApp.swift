//
//  MyApp.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            // Point the main entry to ContentView, which now hosts LoginView
            ContentView()
        }
    }
}

//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

// ContentView now acts as the initial container, presenting the LoginView.
struct ContentView: View {
    var body: some View {
        // Present the SwiftUI LoginView as the root view
        LoginView()
    }
}

// Preview for ContentView now shows the LoginView
#Preview {
    ContentView()
}

//
//  LoginView.swift
//  MyApp
//
//  Created by Cong Le on 3/14/25.
//

import SwiftUI

// Define a simple User model to hold the user data
struct User: Identifiable { // Conform to Identifiable if needed for lists etc.
    let id: String // Use identifier as the id
    let givenName: String
    let familyName: String
    let email: String

    // Convenience init if identifier is the primary ID
    init(identifier: String, givenName: String, familyName: String, email: String) {
        self.id = identifier
        self.givenName = givenName
        self.familyName = familyName
        self.email = email
    }
}

// Main Login View (SwiftUI Implementation)
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false // Controls navigation
    @State private var user: User? = nil    // Optional user data for ResultView
    @State private var showingAlert = false // For showing login errors
    @State private var alertMessage = ""    // Error message text

    // Keychain interaction - Check if user is already logged in
    // This check is simplified. A real app would verify a session token.
    init() {
        let savedIdentifier = KeychainItem.currentUserIdentifier
        if !savedIdentifier.isEmpty {
            // If an identifier exists, you *might* pre-fill user data or try to auto-login.
            // For this example, we just print it. Auto-login would require session validation.
             print("Existing user identifier found on init: \(savedIdentifier)")
             // Example: Try to fetch user data based on identifier and validate session
             // If valid:
             //   _user = State(initialValue: User(identifier: savedIdentifier, ...))
             //   _isLoggedIn = State(initialValue: true)
        }
    }


    var body: some View {
        NavigationView { // Embed in a NavigationView for navigation
            ZStack { // Use ZStack for background color
                Color.orange.edgesIgnoringSafeArea(.all) // Orange background

                VStack(spacing: 16) { // Main content layout with spacing
                    Text("Cong Le SolutionX")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 40)

                    // Email input field
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(.systemGray6)) // Subtle background
                        .cornerRadius(8)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textContentType(.emailAddress) // Helps with autofill

                    // Password input field
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .textContentType(.password) // Helps with autofill

                    // Log In button
                    Button("Log In") {
                        login() // Call the login function
                    }
                    .padding()
                    .frame(maxWidth: .infinity) // Make button full width
                    .background(Color.white)    // Contrasting button
                    .foregroundColor(.orange)   // Text color matches theme
                    .cornerRadius(8)
                    .padding(.top, 20)
                    .shadow(radius: 3)          // Subtle shadow

                    // Forgot Password and Create Account links
                    HStack {
                        Button("Forgot Password?") {
                            // Action for password reset
                            print("Forgot Password tapped")
                            alertMessage = "Password reset feature not implemented."
                            showingAlert = true
                        }
                        .foregroundColor(.white)

                        Spacer() // Push buttons to opposite sides

                        Button("Create Account") {
                            // Action for account creation
                            print("Create Account tapped")
                            alertMessage = "Account creation feature not implemented."
                            showingAlert = true
                        }
                        .foregroundColor(.white)
                    }
                    .padding(.top, 10)

                    Spacer() // Push content to the top
                }
                .padding() // Padding around the VStack content
                .alert(isPresented: $showingAlert) { // Alert for errors/info
                    Alert(title: Text("Information"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }


                // Background NavigationLink, activated by isLoggedIn state
                NavigationLink(
                    destination: ResultView(user: user, isLoggedIn: $isLoggedIn), // Pass user data and binding
                    isActive: $isLoggedIn
                ) {
                    EmptyView() // Link UI is hidden
                }
            }
            .navigationBarHidden(true) // Hide the navigation bar for a cleaner login screen
        }
        // Use StackNavigationViewStyle for consistent behavior, especially on iPad
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // Function to handle the login process
    func login() {
        // --- Actual Authentication Logic Would Go Here ---
        // 1. Validate input locally
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please enter both email and password."
            showingAlert = true
            return
        }
        // Basic email format validation (optional, often better done server-side)
        guard email.contains("@") else {
            alertMessage = "Please enter a valid email address."
            showingAlert = true
            return
        }

        // 2. Send credentials to backend (Simulated)
        print("Simulating login attempt for email: \(email)")
        // Replace with actual URLSession call to your API endpoint

        // --- Simulation of Successful Login ---
        // In reality, this block executes only if the API call returns success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Simulate network delay
            let simulatedIdentifier = "user_\(Int.random(in: 1000...9999))"
            let loggedInUser = User(identifier: simulatedIdentifier, givenName: "Jane", familyName: "Smith", email: email)

            // 3. Save user identifier to Keychain on successful login
            do {
                // Use a unique service identifier for your app
                try KeychainItem(service: KeychainItem.userServiceIdentifier, account: "userIdentifier").saveItem(simulatedIdentifier)
                print("User identifier saved to keychain: \(simulatedIdentifier)")

                // 4. Update state to navigate
                self.user = loggedInUser // Set the user data for ResultView
                self.isLoggedIn = true   // Trigger navigation

            } catch {
                print("Failed to save user identifier to keychain: \(error)")
                self.alertMessage = "Login succeeded but failed to save user session. Please try again."
                self.showingAlert = true
                // Do not navigate if keychain save fails critical session info
            }
        }

        // --- Simulation of Failed Login ---
        // else { // If API call returns failure
        //   self.alertMessage = "Invalid email or password."
        //   self.showingAlert = true
        // }
    }
}

// Result View (Displayed after successful login)
struct ResultView: View {
    let user: User? // Receive the user data (optional safeguard)
    @Binding var isLoggedIn: Bool // Binding to control login state

    var body: some View {
        ZStack {
            Color.orange.edgesIgnoringSafeArea(.all) // Consistent background

            VStack(alignment: .leading, spacing: 12) { // Align content left, add spacing
                Text("Welcome!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)

                // Display user details group
                Group {
                    InfoRow(label: "User Identifier:", value: user?.id ?? KeychainItem.currentUserIdentifier) // Display ID
                    InfoRow(label: "Given Name:", value: user?.givenName ?? "N/A")
                    InfoRow(label: "Family Name:", value: user?.familyName ?? "N/A")
                    InfoRow(label: "Email:", value: user?.email ?? "N/A")
                }
                .padding(.bottom, 5) // Small spacing after each row group

                Spacer() // Pushes button to the bottom

                // Sign Out button
                Button("Sign Out") {
                    signOut()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red) // Clear sign-out action color
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(radius: 3)
                .padding(.bottom, 20) // Add some bottom padding

            }
            .padding() // Padding around the main VStack
        }
        .navigationTitle("User Profile") // Clear navigation title
        .navigationBarBackButtonHidden(true) // Hide default back button
        // Custom navigation bar items if needed (e.g., edit profile)
        // .navigationBarItems(trailing: Button("Edit") { /* Edit action */ })
    }

    // Function to handle sign out
    func signOut() {
        // --- Actual Sign Out Logic ---
        // 1. Clear sensitive data from Keychain (user ID, session tokens)
        print("Signing out user...")
        KeychainItem.deleteUserIdentifierFromKeychain()

        // 2. Clear local state (optional, as view will dismiss)
        //    user = nil // Not possible as user is 'let'

        // 3. Notify backend API about logout (optional but good practice)

        // 4. Update binding to trigger navigation back
        isLoggedIn = false // This dismisses the ResultView
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


// Preview Provider for Login and Result Views
struct LoginFlow_Previews: PreviewProvider {
    // Create a sample user for previews
    static let sampleUser = User(identifier: "preview123", givenName: "Preview", familyName: "User", email: "preview@example.com")

    static var previews: some View {
        // Preview the Login Screen
        LoginView()
            .previewDisplayName("Login Screen")

        // Preview the Result Screen with sample data
        NavigationView { // Embed in NavigationView for title display
             ResultView(user: sampleUser, isLoggedIn: .constant(true))
        }
        .previewDisplayName("Result Screen (Logged In)")
        .navigationViewStyle(StackNavigationViewStyle()) // Ensure style consistency

         // Preview Result Screen when user data might be missing (fallback check)
         NavigationView {
             ResultView(user: nil, isLoggedIn: .constant(true))
         }
         .previewDisplayName("Result Screen (No User Data)")
         .navigationViewStyle(StackNavigationViewStyle())
    }
}


//
//  KeychainItem.swift (Single Consolidated Version)
//  MyApp
//
//  Created by Cong Le on 3/14/25.
//
/*
 Abstract:
 A struct for accessing generic password keychain items. Provides basic
 save, read, and delete functionality for strings associated with a
 service and account key.
 */

import Foundation
// Import Security framework for Keychain services
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
