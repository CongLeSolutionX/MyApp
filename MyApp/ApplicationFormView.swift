////
////  NewApplicationFormView.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import SwiftUI
//
//// --- Mock Data ---
//let usStates = [
//    "Select State", "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
//    "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
//    "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
//    "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
//    "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"
//]
//
//// --- Main Application Form View ---
//struct ApplicationFormView: View {
//    @Environment(\.dismiss) var dismiss
//
//    // --- State for Form Inputs ---
//    // Personal Info
//    @State private var firstName: String = ""
//    @State private var lastName: String = ""
//    @State private var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date() // Default to 25 years ago
//    @State private var ssn: String = "" // Social Security Number
//    @State private var phoneNumber: String = ""
//    @State private var email: String = "" // Often pre-filled if logged in
//
//    // Address Info
//    @State private var streetAddress: String = ""
//    @State private var aptSuiteEtc: String = "" // Optional field
//    @State private var city: String = ""
//    @State private var selectedState: String = usStates[0] // Default to "Select State"
//    @State private var zipCode: String = ""
//
//    // Financial Info (Simplified)
//    @State private var annualIncome: String = ""
//
//    // Agreement
//    @State private var termsAgreed: Bool = false
//
//    // --- State for Processing ---
//    @State private var isLoading: Bool = false
//    @State private var showErrorAlert: Bool = false
//    @State private var showSuccessAlert: Bool = false
//    @State private var errorMessage: String = ""
//    @State private var successMessage: String = "Your application has been submitted successfully! We'll notify you of the decision soon."
//
//    // Basic validation check (can be expanded significantly)
//    var isFormValid: Bool {
//        !firstName.isEmpty &&
//        !lastName.isEmpty &&
//        ssn.count >= 9 && // Simple check
//        !phoneNumber.isEmpty &&
//        !streetAddress.isEmpty &&
//        !city.isEmpty &&
//        selectedState != usStates[0] && // Ensure a state is selected
//        zipCode.count == 5 && // Simple check
//        !annualIncome.isEmpty &&
//        termsAgreed
//    }
//
//    var body: some View {
//        NavigationView {
//            Form { // Using Form for standard input field styling
//                Section("Personal Information") {
//                    TextField("First Name", text: $firstName)
//                        .textContentType(.givenName)
//                    TextField("Last Name", text: $lastName)
//                        .textContentType(.familyName)
//                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
//                        .environment(\.locale, Locale(identifier: "en_US")) // Ensure consistent format
//                    SecureField("Social Security Number", text: $ssn)
//                        .keyboardType(.numberPad)
//                        .textContentType(.creditCardNumber) // Hint for input type (though not CC)
//                    TextField("Phone Number", text: $phoneNumber)
//                        .keyboardType(.phonePad)
//                        .textContentType(.telephoneNumber)
//                    TextField("Email Address", text: $email)
//                        .keyboardType(.emailAddress)
//                        .textContentType(.emailAddress)
//                        .autocapitalization(.none)
//                }
//
//                Section("Residential Address") {
//                    TextField("Street Address", text: $streetAddress)
//                        .textContentType(.streetAddressLine1)
//                    TextField("Apt, Suite, etc. (Optional)", text: $aptSuiteEtc)
//                        .textContentType(.streetAddressLine2)
//                    TextField("City", text: $city)
//                        .textContentType(.addressCity)
//
//                    // State Picker
//                    Picker("State", selection: $selectedState) {
//                        ForEach(usStates, id: \.self) { state in
//                            Text(state).tag(state) // Use state abbreviation as tag
//                        }
//                    }
//                    .pickerStyle(.menu) // Or .wheel, depending on preference
//
//                    TextField("ZIP Code", text: $zipCode)
//                        .keyboardType(.numberPad)
//                        .textContentType(.postalCode)
//                }
//
//                Section("Financial Information") {
//                    TextField("Estimated Annual Income", text: $annualIncome)
//                        .keyboardType(.decimalPad) // Allow for numbers
//                }
//
//                Section("Agreement") {
//                    Toggle(isOn: $termsAgreed) {
//                        Text("I have read and agree to the Cardholder Agreement and relevant terms.")
//                            .font(.footnote)
//                            .foregroundColor(.gray) // Subtle text
//                    }
//                    // You might add a link here to view the terms again if needed
//                     Button("View Terms (Simulated)") {
//                         // In a real app, present the terms modal again
//                         print("Modal terms view should be presented here.")
//                     }
//                     .font(.footnote)
//                }
//
//                // --- Submit Button Section ---
//                Section {
//                    Button {
//                        Task {
//                            await submitApplication()
//                        }
//                    } label: {
//                        ZStack {
//                            Text("Submit Application")
//                                .font(.headline)
//                                .foregroundColor(isLoading || !isFormValid ? .gray : Color.rhButtonTextGold) // Dim if invalid/loading
//
//                            if isLoading {
//                                ProgressView()
//                                     .progressViewStyle(CircularProgressViewStyle(tint: Color.rhButtonTextGold))
//                            }
//                        }
//                        .padding(.vertical, 10)
//                        .frame(maxWidth: .infinity, alignment: .center)
//                    }
//                    .buttonStyle(.borderedProminent) // Use system prominent style or custom
//                    .tint(isFormValid ? Color.rhButtonDark : Color.gray.opacity(0.5)) // Use theme color if valid
//                    .disabled(isLoading || !isFormValid) // Disable if loading or invalid
//                    .listRowBackground(Color.clear) // Remove default Form row background for button
//                }
//            }
//            .navigationTitle("Gold Card Application")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss() // Dismiss the modal view
//                    }
//                }
//            }
//            .alert("Submission Error", isPresented: $showErrorAlert, actions: {
//                Button("OK", role: .cancel) {}
//            }, message: {
//                Text(errorMessage)
//            })
//            .alert("Submission Successful", isPresented: $showSuccessAlert, actions: {
//                Button("Done") {
//                    dismiss() // Dismiss the form on success acknowledgment
//                }
//            }, message: {
//                Text(successMessage)
//            })
//             // Optional: Add background if needed, but Form often looks best on default background
//             // .background(Color.rhBeige.ignoresSafeArea())
//        }
//        .interactiveDismissDisabled(isLoading) // Prevent accidental dismissal while submitting
//    }
//
//    // --- Action Logic ---
//    @MainActor
//    private func submitApplication() async {
//        // Basic client-side check (more robust validation needed in production)
//        guard isFormValid else {
//            errorMessage = "Please complete all required fields and agree to the terms."
//            showErrorAlert = true
//            return
//        }
//
//        isLoading = true
//        errorMessage = "" // Clear previous error
//        await MainActor.run { UIImpactFeedbackGenerator(style: .medium).impactOccurred() } // Haptic feedback
//
//        do {
//            // Simulate network call (e.g., POSTing form data)
//            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds delay
//
//            // Simulate success/failure outcome
//            let submissionSuccess = Bool.random() // 50/50 chance for demo
//
//            if submissionSuccess {
//                print("Application submitted successfully (Simulated)")
//                showSuccessAlert = true
//                 // In a real app: Clear form fields or navigate away after success alert
//            } else {
//                print("Application submission failed (Simulated)")
//                throw URLError(.cannotConnectToHost) // Simulate a network/backend error
//            }
//
//        } catch {
//            errorMessage = "There was an issue submitting your application. Please check your connection and try again."
//            showErrorAlert = true
//        }
//
//        isLoading = false
//    }
//}
//
//// --- Previews ---
//struct ApplicationFormView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Present modally for a realistic preview context
//        NavigationView { EmptyView() }
//            .sheet(isPresented: .constant(true)) {
//                ApplicationFormView()
//                    // Inject mock data for preview if needed
//                    // .onAppear { /* set initial state vars */ }
//            }
//            // Add specific color scheme if needed
//            // .preferredColorScheme(.light)
//    }
//}
//
//// --- Re-add Color Extension if needed in this file ---
//// (Assuming it's defined elsewhere or add it here)
//extension Color {
//    static let rhBlack = Color(red: 0.05, green: 0.05, blue: 0.05)
//    static let rhGold = Color(red: 0.8, green: 0.65, blue: 0.3)
//    static let rhBeige = Color(red: 0.96, green: 0.94, blue: 0.91)
//    static let rhButtonDark = Color(red: 0.15, green: 0.15, blue: 0.1)
//    static let rhButtonTextGold = Color(red: 0.9, green: 0.8, blue: 0.5)
//    // ... other colors if used ...
//}
