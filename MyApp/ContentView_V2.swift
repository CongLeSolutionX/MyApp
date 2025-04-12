//
//  ContentView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/11/25.
//
import SwiftUI
import Contacts // Required for CNContact data types and CNContactStore
import ContactsUI // Required for CNContactPickerViewController and its delegate

// MARK: - Configuration (Info.plist Reminder)
// REMINDER: You MUST add the following key-value pair to your app's Info.plist file:
// Key: Privacy - Contacts Usage Description
// Value: (String) Explain why your app needs access to contacts (e.g., "To select a contact to display their information.")

// MARK: - Contact Data Model

struct ContactInfo: Identifiable {
    let id: String // Use contact identifier for uniqueness
    var firstName: String
    var lastName: String
    var avatarData: Data? // Optional data for the contact's thumbnail image
    var phoneNumbers: [String]
    var emailAddresses: [String]

    var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Static placeholder for preview or initial state
    static let mock = ContactInfo(
        id: "mock-contact-001",
        firstName: "Jane",
        lastName: "Appleseed",
        avatarData: UIImage(systemName: "person.fill")?.pngData(), // Example placeholder image
        phoneNumbers: ["(555) 123-4567", "(555) 987-6543"],
        emailAddresses: ["jane.appleseed@example.com"]
    )
}

// MARK: - Contact Permission Manager

class ContactPermissionManager: ObservableObject {
    @Published var permissionStatus: CNAuthorizationStatus = .notDetermined
    private let store = CNContactStore()

    init() {
        checkPermission()
    }

    func checkPermission() {
        permissionStatus = CNContactStore.authorizationStatus(for: .contacts)
    }

    func requestPermission() async -> Bool {
        // If already authorized, return true immediately
        if permissionStatus == .authorized { return true }

        // Request permission only if not determined
        if permissionStatus == .notDetermined {
            do {
                let granted = try await store.requestAccess(for: .contacts)
                DispatchQueue.main.async { [weak self] in
                    self?.permissionStatus = granted ? .authorized : .denied
                }
                return granted
            } catch {
                print("Error requesting contact access: \(error)")
                DispatchQueue.main.async { [weak self] in
                    self?.permissionStatus = .denied // Assume denial on error
                }
                return false
            }
        } else {
            // If denied or restricted, return false
            return false
        }
    }
}

// MARK: - Contact Picker Wrapper (UIViewControllerRepresentable)

struct ContactPickerView: UIViewControllerRepresentable {

    // Binding to control the presentation state
    @Binding var isPresented: Bool
    // Binding to pass the structured contact data back
    @Binding var selectedContact: ContactInfo?

    // Create and configure the CNContactPickerViewController
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = context.coordinator
        // Optional: Define which properties are needed to reduce loading time (if known)
        // contactPicker.displayedPropertyKeys = [
        //     CNContactGivenNameKey, CNContactFamilyNameKey,
        //     CNContactPhoneNumbersKey, CNContactEmailAddressesKey,
        //     CNContactThumbnailImageDataKey // Request thumbnail data
        // ]
        return contactPicker
    }

    // No update logic needed for this basic presentation
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    // Create the Coordinator instance
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator Class (Delegate)

    class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: ContactPickerView

        init(_ parent: ContactPickerView) {
            self.parent = parent
        }

        // MARK: CNContactPickerDelegate Methods

        // Called when the user selects a single contact
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            print("Contact selected: \(contact.identifier)")

            // Extract comprehensive information
            let firstName = contact.givenName
            let lastName = contact.familyName
            let avatarData = contact.thumbnailImageData // Get thumbnail data
            let phoneNumbers = contact.phoneNumbers.map { $0.value.stringValue }
            let emailAddresses = contact.emailAddresses.map { $0.value as String }

            // Create the structured ContactInfo object
            let contactInfo = ContactInfo(
                id: contact.identifier,
                firstName: firstName,
                lastName: lastName,
                avatarData: avatarData,
                phoneNumbers: phoneNumbers,
                emailAddresses: emailAddresses
            )

            // Update the binding in the parent SwiftUI view
            parent.selectedContact = contactInfo

            // Dismiss the contact picker
            parent.isPresented = false
        }

        /*
        // --- Alternative Delegate Method: Selecting properties ---
        // This method is less common now that the full contact can be retrieved easily.
        // Use it if you *only* want the user to pick ONE specific phone number or email.
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
            // ... (Implementation if needed, updates parent.selectedContact appropriately) ...
            parent.isPresented = false
        }
        */

        // Called when the user cancels
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            print("Contact picker cancelled.")
            // Just dismiss
            parent.isPresented = false
        }
    }
}

// MARK: - Content View (Example Usage)

struct ContentView: View {
    // State for controlling the sheet presentation
    @State private var showingContactPicker = false
    // State to hold the selected contact's structured data
    @State private var selectedContact: ContactInfo? = nil
    // State to manage permission status and alerts
    @StateObject private var permissionManager = ContactPermissionManager()
    @State private var showPermissionAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                actionButton
                    .padding(.top)

                // Display area for contact info or status messages
                contactDisplayArea
                
                Spacer() // Push content to the top
            }
            .padding()
            .navigationTitle("Contact Picker Demo")
            // Use the .sheet modifier to present the ContactPickerView
            .sheet(isPresented: $showingContactPicker) {
                ContactPickerView(isPresented: $showingContactPicker, selectedContact: $selectedContact)
            }
            // Alert to guide user if permissions are denied
            .alert("Permission Required", isPresented: $showPermissionAlert) {
                Button("Open Settings", action: openAppSettings)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This app needs access to your contacts to select one. Please grant permission in Settings.")
            }
            // Check permission status when the view appears
            .onAppear {
                permissionManager.checkPermission()
            }
        }
    }

    // MARK: View Components

    @ViewBuilder // Allows returning different views based on state
    private var actionButton: some View {
        Button {
            handleSelectContactTap()
        } label: {
            Label("Select Contact", systemImage: "person.crop.circle.badge.plus")
        }
        .padding()
        .buttonStyle(.borderedProminent)
        .disabled(permissionManager.permissionStatus == .denied) // Disable if denied
    }

    @ViewBuilder
    private var contactDisplayArea: some View {
        Group {
            if let contact = selectedContact {
                ContactCardView(contact: contact)
                
                Button("Clear Selection", role: .destructive) {
                    selectedContact = nil
                }
                .padding(.top, 5)
                .buttonStyle(.borderless)

            } else {
                statusTextView
            }
        }
        .frame(maxWidth: .infinity) // Allow card/text to expand
    }

    @ViewBuilder
    private var statusTextView: some View {
        switch permissionManager.permissionStatus {
        case .authorized:
            Text("Tap 'Select Contact' to begin.")
                .foregroundColor(.secondary)
        case .denied:
            Text("Contact access denied. Please enable it in Settings.")
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
        case .restricted:
            Text("Contact access is restricted (e.g., by parental controls).")
                .foregroundColor(.orange)
                .multilineTextAlignment(.center)
        case .notDetermined:
            Text("Contact permission not yet requested.")
                .foregroundColor(.secondary)
        @unknown default:
            Text("Unknown contact permission status.")
                .foregroundColor(.gray)
        }
    }

    // MARK: Helper Functions

    private func handleSelectContactTap() {
        Task {
            let granted = await permissionManager.requestPermission()
            if granted {
                showingContactPicker = true
            } else {
                // If denied and we just asked, show the alert
                if permissionManager.permissionStatus == .denied {
                    showPermissionAlert = true
                }
                // If restricted, the status view already shows info
            }
        }
    }
    
    // Opens the app's settings in the Settings app
    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl) else {
            return
        }
        UIApplication.shared.open(settingsUrl)
    }
}

// MARK: - Contact Card View (Sub-View)

struct ContactCardView: View {
    let contact: ContactInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 15) {
                // Avatar Image
                avatarImage
                    .frame(width: 60, height: 60)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(Circle())

                // Name
                Text(contact.fullName)
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            // --- Phone Numbers ---
            if !contact.phoneNumbers.isEmpty {
                sectionTitle("Phone Numbers")
                ForEach(contact.phoneNumbers, id: \.self) { number in
                    LabeledContent { // Better semantics than HStack
                        Text(number)
                    } label: {
                         Image(systemName: "phone.fill") // Example label
                    }
                     Divider() // Optional separator
                }
               // .labeledContentStyle(.vertical) // Adjust layout
            }

            // --- Email Addresses ---
            if !contact.emailAddresses.isEmpty {
                 sectionTitle("Email Addresses")
                 ForEach(contact.emailAddresses, id: \.self) { email in
                    LabeledContent {
                         Text(email)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    } label: {
                         Image(systemName: "envelope.fill")
                    }
                     Divider() // Optional separator
                 }
                // .labeledContentStyle(.vertical) // Adjust layout
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground)) // Subtle background
        .cornerRadius(12)
        .shadow(radius: 3, x: 1, y: 2)
    }
    
    @ViewBuilder
    private var avatarImage: some View {
        if let data = contact.avatarData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill() // Fill the circle
        } else {
            // Placeholder if no image data
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray)
                .opacity(0.8)
        }
    }
    
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.secondary)
            .padding(.top, 5) // Add a bit of space before the section
    }
}

// MARK: - Preview Provider

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            // Example with a mock contact initially displayed in preview
            .previewDisplayName("Default State")

//        ContentView(selectedContact: ContactInfo.mock)
//            .previewDisplayName("With Mock Contact")
    }
}

// MARK: - App Entry Point (Requires Info.plist Permissions)
/*
@main
struct ContactPickerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/
