//
//  FirebaseAuthUIView.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import SwiftUI
import Combine // For ObservableObject

// --- Firebase ---
import FirebaseCore
import FirebaseAuth
import FirebaseAuthUI // Core FirebaseUI
import FirebaseGoogleAuthUI // Example: Add if using Google Sign-In
// import FirebaseFacebookAuthUI // Example: Add if using Facebook Sign-In
// import FirebaseOAuthUI // Example: Add if using generic OAuth providers

// MARK: - Firebase Authentication Manager (ObservableObject)

class FirebaseAuthenticationManager: ObservableObject {
    @Published var isUserLoggedIn: Bool = false
    @Published var user: User? = nil // Optional: Store the Firebase User object

    private var authStateHandler: AuthStateDidChangeListenerHandle?

    init() {
        // Listen for Firebase authentication state changes
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            DispatchQueue.main.async { // Ensure updates are on the main thread
                self.user = user
                self.isUserLoggedIn = (user != nil)
                print("Auth State Changed: User is \(user == nil ? "nil" : user!.uid)")
            }
        }
        // Initial check
        self.user = Auth.auth().currentUser
        self.isUserLoggedIn = (self.user != nil)
    }

    deinit {
        // Remove listener when the manager is deallocated
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
            print("Auth State Change Listener Removed.")
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            print("User signed out successfully.")
            // The listener above will automatically update isUserLoggedIn and user
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            // Handle the error appropriately (e.g., show an alert)
        }
    }
}

// MARK: - Firebase Auth UI View (UIViewControllerRepresentable)

struct FirebaseAuthUIView: UIViewControllerRepresentable {
    // Binding to control presentation (managed by .sheet in the parent)
    @Binding var isPresented: Bool // If false, the sheet will dismiss

    // Inject the manager to update state via the Coordinator
    @ObservedObject var authManager: FirebaseAuthenticationManager

    // --- ** IMPORTANT: Configure your providers here! ** ---
    private func getAuthUI() -> FUIAuth? {
        guard let authUI = FUIAuth.defaultAuthUI() else { return nil }

        let providers: [FUIAuthProvider] = [
            FUIEmailAuth(), // Email/Password Authentication
            FUIGoogleAuth(authUI: authUI), // Google Sign-In (Requires FirebaseGoogleSignIn setup)
            // FUIFacebookAuth(authUI: authUI), // Facebook Sign-In (Requires Facebook SDK & setup)
            // FUIOAuth.appleAuthProvider(), // Sign in with Apple (Requires configuration)
            // Add other providers as needed...
        ]
        authUI.providers = providers
        return authUI
    }

    // Create the Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self, authManager: authManager)
    }

    // Create the Firebase Auth UI ViewController
    func makeUIViewController(context: Context) -> UINavigationController {
        guard let authUI = getAuthUI() else {
            // Return an empty Navigation Controller or handle error appropriately
            // This case shouldn't happen if FirebaseUI is set up correctly
            print("Error: FUIAuth.defaultAuthUI() returned nil")
            return UINavigationController()
        }
        // Set the delegate *before* presenting the view controller
        authUI.delegate = context.coordinator

        let authViewController = authUI.authViewController()
        return authViewController // Returns the UINavigationController containing the auth UI
    }

    // Update the ViewController (usually not needed for modal presentation)
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No update needed in this case, as the view controller manages its own state oncce presented.
        // Dismissal is handled by SwiftUI's .sheet modifier via the isPresented binding.
    }

    // MARK: - Coordinator Class
    class Coordinator: NSObject, FUIAuthDelegate {
        var parent: FirebaseAuthUIView
        var authManager: FirebaseAuthenticationManager // Hold reference to update state

        init(_ parent: FirebaseAuthUIView, authManager: FirebaseAuthenticationManager) {
            self.parent = parent
            self.authManager = authManager
        }

        // --- FUIAuthDelegate Methods ---

        func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
            if let user = authDataResult?.user {
                // Sign-in successful!
                print("Coordinator: Successfully signed in user \(user.uid)")
                // Update the state via the manager (which publishes changes)
                // The AuthStateDidChangeListener in the Manager ALREADY handles this,
                // so strictly speaking, direct update here might be redundant but often done.
                // If the listener is slightly delayed, this provides immediate feedback.
                // authManager.isUserLoggedIn = true
                // authManager.user = user
                parent.isPresented = false // Signal SwiftUI to dismiss the sheet

            } else {
                // Sign-in failed.
                if let nsError = error as NSError? {
                    // Avoid dismissing if the user simply cancelled the flow
                    if nsError.code == FUIAuthErrorCode.userCancelled.rawValue {
                        print("Coordinator: User cancelled sign-in.")
                    } else {
                        print("Coordinator: Error signing in: \(error?.localizedDescription ?? "Unknown error")")
                        // Handle other errors appropriately (e.g., show an alert to the user)
                    }
                }
                // Important: Only dismiss if it wasn't a cancellation,
                // or maybe you always want to dismiss regardless. Adjust logic as needed.
                parent.isPresented = false // Dismiss the sheet even on error/cancel
            }
        }

        // Optional: You might implement other FUIAuthDelegate methods if needed
        // For example, if you customize the UI significantly:
        // func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        //     return CustomAuthPickerViewController(authUI: authUI)
        // }
    }
}

// MARK: - Main Content View

struct ContentView: View {
    @StateObject private var authManager = FirebaseAuthenticationManager()
    @State private var showAuthSheet = false // Controls the presentation of the login sheet

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if authManager.isUserLoggedIn {
                    // --- Logged In View ---
                    Text("Welcome!")
                        .font(.largeTitle)
                    if let user = authManager.user {
                        Text("User ID: \(user.uid)")
                        Text("Email: \(user.email ?? "N/A")")
                        if let displayName = user.displayName, !displayName.isEmpty {
                             Text("Display Name: \(displayName)")
                        }
                    }
                    Button("Sign Out") {
                        authManager.signOut()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)

                } else {
                    // --- Logged Out View ---
                    Text("Please Sign In")
                        .font(.title)
                    Button("Sign In / Register") {
                        showAuthSheet = true // Trigger the .sheet presentation
                    }
                    .buttonStyle(.borderedProminent)
                }

                Spacer() // Pushes content to the top
            }
            .padding()
            .navigationTitle("Firebase Auth Demo")
            // --- Present the Firebase Auth UI Sheet ---
            .sheet(isPresented: $showAuthSheet) {
                 // Pass the binding and the manager to the Representable View
                 FirebaseAuthUIView(isPresented: $showAuthSheet, authManager: authManager)
                     // Optional: Prevent interactive dismissal if needed
                     // .interactiveDismissDisabled()
             }
        }
        // Ensure manager is available if moving between views (or use @EnvironmentObject)
        // .environmentObject(authManager)
    }
}

// MARK: - App Entry Point

@main
struct FirebaseAuthUIDemoApp: App {
    // --- Configure Firebase on App Launch ---
    // Option 1: Using init() (Classic approach)
    init() {
        print("Configuring Firebase...")
        FirebaseApp.configure()
        print("Firebase configured.")
    }

    // Option 2: Using AppDelegateAdaptor (If you need more AppDelegate functionality)
    // @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                /*
                // Option 3: Configure Firebase using .onAppear (More SwiftUI idiomatic)
                .onAppear {
                    if FirebaseApp.app() == nil { // Configure only once
                        print("Configuring Firebase...")
                        FirebaseApp.configure()
                        print("Firebase configured.")
                    }
                }
                 */
        }
    }
}

// Optional: If using AppDelegateAdaptor (Option 2)
/*
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Configuring Firebase via AppDelegate...")
        FirebaseApp.configure()
        print("Firebase configured via AppDelegate.")
        return true
    }

    // Required for Google Sign-In and potentially others like Facebook
    // Handle the URL that your app receives at the end of the authentication process
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // Other URL handling logic (if any)
        return false
    }
}
*/

// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Note: Previews won't fully work with Firebase Auth UI unless you mock extensively.
        // It's best to run on a Simulator or Device.
        ContentView()
    }
}
