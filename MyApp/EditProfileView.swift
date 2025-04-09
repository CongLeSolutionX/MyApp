//
//  EditProfileView.swift
//  MyApp
//
//  Created by Cong Le on 4/9/25.
//

import SwiftUI

// (Optional) Simple struct to represent profile data - more robust in real apps
struct UserProfileData {
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String
    // Add other fields like address, birthdate etc. as needed
}

struct EditProfileView: View {

    // State variables to hold the editable profile data
    // Initialize with mock data, simulating data passed from the previous screen or fetched
    @State private var profileData = UserProfileData(
        firstName: "Kevin",
        lastName: "Nguyen",
        email: "Kevin.Nguyen@example.com",
        phoneNumber: "+1 (555) 123-4567"
    )

    // State for managing focus (optional, but good UX)
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case firstName, lastName, email, phoneNumber
    }

    // Environment variable to dismiss the view
    @Environment(\.presentationMode) var presentationMode

    // State to track if data has been changed (for enabling Save button)
    @State private var hasChanges: Bool = false
    // Store initial data to compare against
    private let initialProfileData: UserProfileData

    init() {
        // In a real app, you'd pass the actual current user data here
        let currentData = UserProfileData(
            firstName: "CongLeSolutionX",
            lastName: "I Asked AI Bots",
            email: "CongLeJobs@gmail.com",
            phoneNumber: "+1 (714) 696-9696"
        )
        _profileData = State(initialValue: currentData)
        initialProfileData = currentData
    }

    var body: some View {
        Form {
            // --- Profile Picture Section ---
            Section {
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "person.crop.circle.fill") // Placeholder Icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.rhGold) // Or load actual image
                            .padding(.bottom, 5)

                        Button("Change Profile Picture") {
                            // Action to open image picker
                            print("Change picture tapped")
                            // Integrate PHPickerViewController or similar here
                        }
                        .font(.caption)
                        .buttonStyle(.borderless) // Use borderless for subtle look in Form
                        .tint(.rhGold) // Use accent color for the button tint
                    }
                    Spacer()
                }
                .padding(.vertical) // Add padding for visual spacing
            }
            .listRowBackground(Color(uiColor: .systemGroupedBackground)) // Blend section background

            // --- Personal Information Section ---
            Section(header: Text("Personal Information")) {
                TextField("First Name", text: $profileData.firstName)
                    .textContentType(.givenName) // Helps with autofill
                    .focused($focusedField, equals: .firstName)
                    .submitLabel(.next) // Keyboard return key suggests next field

                TextField("Last Name", text: $profileData.lastName)
                    .textContentType(.familyName)
                    .focused($focusedField, equals: .lastName)
                    .submitLabel(.next)

                TextField("Email Address", text: $profileData.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)

                TextField("Phone Number", text: $profileData.phoneNumber)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                    .focused($focusedField, equals: .phoneNumber)
                    .submitLabel(.done) // Last field suggests done
            }
            // Monitor changes
            .onChange(of: profileData.firstName) { checkForChanges() }
            .onChange(of: profileData.lastName) { checkForChanges() }
            .onChange(of: profileData.email) { checkForChanges() }
            .onChange(of: profileData.phoneNumber) { checkForChanges() }
            // Add onChange for other fields if they exist
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline) // Keep title compact
        .toolbar {
            // --- Keyboard Done Button ---
            ToolbarItemGroup(placement: .keyboard) {
                 Spacer() // Push button to the right
                 Button("Done") {
                     focusedField = nil // Dismiss keyboard
                 }
                 .tint(.rhGold)
            }

            // --- Navigation Bar Buttons ---
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss() // Dismiss the view
                }
                 .tint(.rhGold)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveProfileChanges()
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(!hasChanges) // Disable Save if no changes were made
                .tint(.rhGold)
            }
        }
        .onSubmit { // Handle return key presses to move focus
            switch focusedField {
            case .firstName:
                focusedField = .lastName
            case .lastName:
                focusedField = .email
            case .email:
                focusedField = .phoneNumber
            default:
                focusedField = nil // Dismiss keyboard if on last field or no focus
            }
        }
        // Detect tap outside to dismiss keyboard
         .onTapGesture {
               focusedField = nil
           }
    }

    // --- Helper Functions ---

    func checkForChanges() {
         // Compare current data with the initial data
         hasChanges = (profileData.firstName != initialProfileData.firstName ||
                       profileData.lastName != initialProfileData.lastName ||
                       profileData.email != initialProfileData.email ||
                       profileData.phoneNumber != initialProfileData.phoneNumber)
         // Add comparisons for other fields if they exist
     }

    func saveProfileChanges() {
        // In a real app:
        // 1. Validate the input (e.g., email format, phone number format, non-empty names)
        // 2. Show loading indicator
        // 3. Make API call to update the user profile on the server
        // 4. Handle success: Update local user model/cache, dismiss view, maybe show success message
        // 5. Handle error: Show error message to the user, don't dismiss
        focusedField = nil // Dismiss keyboard before potentially dismissing view
        print("Saving Profile Data:")
        print("- First Name: \(profileData.firstName)")
        print("- Last Name: \(profileData.lastName)")
        print("- Email: \(profileData.email)")
        print("- Phone: \(profileData.phoneNumber)")
        // Assume success for this example
        // Reset change tracking after save if staying on page (not relevant here as we dismiss)
        // hasChanges = false
    }
}

// --- Previews ---
struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Embed in NavigationView for previewing Navigation Bar items
        NavigationView {
            EditProfileView()
        }
         .preferredColorScheme(.light)
         .previewDisplayName("Light Mode")

        NavigationView {
            EditProfileView()
        }
         .preferredColorScheme(.dark)
         .previewDisplayName("Dark Mode")
    }
}

// Dummy Color Extension (ensure these exist in your project)
//extension Color {
//     static let rhGold = Color.orange // Placeholder
//     static let rhBeige = Color(UIColor.systemGray6) // Placeholder
//}
