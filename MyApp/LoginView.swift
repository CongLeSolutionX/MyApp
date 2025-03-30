////
////  LoginView.swift
////  MyApp
////
////  Created by Cong Le on 3/14/25.
////
//
//import SwiftUI
//
//// Define a simple User model to hold the user data
//struct User {
//    let identifier: String
//    let givenName: String
//    let familyName: String
//    let email: String
//}
//
//// Main Login View
//struct LoginView: View {
//    @State private var email = ""
//    @State private var password = ""
//    @State private var isLoggedIn = false // Controls navigation
//    @State private var user: User? = nil    // Optional user data
//
//    var body: some View {
//        NavigationView { // Embed in a NavigationView for navigation
//            ZStack { // Use ZStack for background color
//                Color.orange.edgesIgnoringSafeArea(.all) // Orange background
//
//                VStack { // Main content layout
//                    Text("Cong Le SolutionX")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                        .padding(.bottom, 40)
//
//                    // Email input
//                    TextField("Email", text: $email)
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(8)
//                        .keyboardType(.emailAddress)
//                        .autocapitalization(.none) // Disable autocapitalization
//                        .disableAutocorrection(true)
//
//                    // Password input (SecureField)
//                    SecureField("Password", text: $password)
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(8)
//                        .textContentType(.password) // Specify password content type
//
//                    // Log In button
//                    Button("Log In") {
//                        login() // Call the login function
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity) // Make button full width
//                    .background(Color.white)
//                    .foregroundColor(.orange)
//                    .cornerRadius(8)
//                    .padding(.top, 20)
//
//                    // Forgot Password and Create Account (styled as text)
//                    HStack {
//                        Button("Forgot Password?") {
//                            // In a real app, you'd navigate to a password reset view.
//                            print("Forgot Password tapped")
//                        }
//                        .foregroundColor(.white)
//
//                        Spacer() // Push to opposite sides
//
//                        Button("Create Account") {
//                            // In a real app, navigate to a registration view.
//                            print("Create Account tapped")
//                        }
//                        .foregroundColor(.white)
//                    }
//                    .padding(.top, 10)
//
//                    Spacer() // Push content to the top
//                }
//                .padding()
//
//                // Navigation Link (hidden until isLoggedIn is true)
//                NavigationLink(
//                    destination: ResultView(user: user, isLoggedIn: $isLoggedIn), // Where to go
//                    isActive: $isLoggedIn // When to go
//                ) {
//                    EmptyView() // Hidden view
//                }
//                .hidden() // Hide the NavigationLink itself
//            }
//            .navigationBarTitle("", displayMode: .inline) // Hide the default title
//        }
//    }
//
//    // Simulate a login process.  Replace this with your actual authentication logic.
//    func login() {
//        // In a real app, you'd validate credentials against a backend
//        // (e.g., using URLSession, Firebase, etc.).
//        // For this example, we'll just simulate a successful login.
//
//        if !email.isEmpty && !password.isEmpty {
//            // Simulate fetching user data (replace with your actual data)
//            user = User(identifier: "123", givenName: "John", familyName: "Doe", email: email)
//            isLoggedIn = true // Trigger navigation
//        } else {
//            // Show an error (in a real app, use an @State variable and an alert)
//            print("Invalid credentials")
//        }
//    }
//}
//
//// Result View (after successful login)
//struct ResultView: View {
//    let user: User? // Receive the user data
//    @Binding var isLoggedIn: Bool // Use a binding to control login state
//
//    var body: some View {
//        ZStack {
//            Color.orange.edgesIgnoringSafeArea(.all)
//
//            VStack {
//                Text("User Identifier:")
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                Text(user?.identifier ?? "N/A") // Display identifier or "N/A"
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.bottom, 10)
//
//                Text("Given Name:")
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                Text(user?.givenName ?? "N/A")
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.bottom, 10)
//
//                Text("Family Name:")
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                Text(user?.familyName ?? "N/A")
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.bottom, 10)
//
//                Text("Email:")
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                Text(user?.email ?? "N/A")
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.bottom, 20)
//
//                Button("Sign Out") {
//                    signOut()
//                }
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color.red) // Red sign-out button
//                .foregroundColor(.white)
//                .cornerRadius(8)
//
//                Spacer() // Push content to the top
//            }
//            .padding()
//            .navigationTitle("Result View Controller") // Set the navigation title
//        }
//    }
//
//    func signOut() {
//        // In a real app, clear user session, tokens, etc.
//        isLoggedIn = false // This will navigate back to the LoginView
//        // You might also want to clear the user data:
//        // user = nil  //  This would cause a runtime error.  user is a let constant.
//        // To fix this, you'd need to make user an @State variable in LoginView,
//        // and pass a Binding<User?> to ResultView.  But that's more complex
//        // than is necessary for this example, since signing out doesn't *need*
//        // to immediately clear the displayed data.
//    }
//}
//
//// Preview Provider (for Xcode Previews)
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//        ResultView(user: nil, isLoggedIn: .constant(true))
//        
//    }
//}
