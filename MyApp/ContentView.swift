////
////  ContentView.swift
////  MyApp
////
////  Created by Cong Le on 8/19/24.
////
////
////import SwiftUI
////
////// Step 2: Use in SwiftUI view
////struct ContentView: View {
////    var body: some View {
////        UIKitViewControllerWrapper()
////            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
////    }
////}
////
////// Before iOS 17, use this syntax for preview UIKit view controller
////struct UIKitViewControllerWrapper_Previews: PreviewProvider {
////    static var previews: some View {
////        UIKitViewControllerWrapper()
////    }
////}
////
////// After iOS 17, we can use this syntax for preview:
////#Preview {
////    ContentView()
////}
//import SwiftUI
//import Contacts // Required for CNContact data types
//import ContactsUI // Required for CNContactPickerViewController and its delegate
//
//// MARK: - Configuration (Info.plist Reminder)
//// REMINDER: You MUST add the following key-value pair to your app's Info.plist file:
//// Key: Privacy - Contacts Usage Description
//// Value: (String) Explain why your app needs access to contacts (e.g., "To select a contact to display their information.")
//
//// MARK: - Contact Picker Wrapper (UIViewControllerRepresentable)
//
//struct ContactPickerView: UIViewControllerRepresentable {
//
//    // Binding to control the presentation state of the sheet/picker
//    @Binding var isPresented: Bool
//
//    // Binding to pass the selected contact's information back to the calling view
//    @Binding var selectedContactInfo: String?
//
//    // Create and configure the CNContactPickerViewController instance
//    func makeUIViewController(context: Context) -> CNContactPickerViewController {
//        let contactPicker = CNContactPickerViewController()
//        contactPicker.delegate = context.coordinator // Set the coordinator as the delegate
//        // Optional: Customize the picker
//        // contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey] // Only show contacts with phone numbers
//        // contactPicker.predicateForEnablingContact = ... // Filter which contacts are selectable
//        // contactPicker.predicateForSelectionOfContact = ... // Filter which contacts *can* be selected (vs just shown)
//        return contactPicker
//    }
//
//    // Update the view controller if needed (rarely used for simple presentations)
//    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {
//        // No update logic needed for this basic example
//    }
//
//    // Create the Coordinator instance that acts as the delegate
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    // MARK: - Coordinator Class
//
//    class Coordinator: NSObject, CNContactPickerDelegate {
//        var parent: ContactPickerView // Reference back to the SwiftUI view struct
//
//        init(_ parent: ContactPickerView) {
//            self.parent = parent
//        }
//
//        // MARK: CNContactPickerDelegate Methods
//
//        // Called when the user selects a single contact
//        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
//            print("Contact selected: \(contact.identifier)")
//
//            // Extract desired information from the CNContact object
//            let firstName = contact.givenName
//            let lastName = contact.familyName
//            var contactInfo = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
//
//            if let firstPhoneNumber = contact.phoneNumbers.first?.value.stringValue {
//                 contactInfo += "\nPhone: \(firstPhoneNumber)"
//            } else {
//                contactInfo += "\n(No phone number available)"
//            }
//
//            // Update the binding in the parent SwiftUI view
//            parent.selectedContactInfo = contactInfo
//
//            // Dismiss the contact picker
//            parent.isPresented = false
//        }
//
//        /*
//        // --- Alternative Delegate Method: Selecting a specific property ---
//         // Uncomment this method and comment out `didSelect contact` if you only want to select,
//         // for example, a single phone number instead of the whole contact.
//         // You would also likely want to set `displayedPropertyKeys` in `makeUIViewController`.
//
//         func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
//              print("Contact property selected: \(contactProperty.identifier)")
//
//              var info = "\(contactProperty.contact.givenName) \(contactProperty.contact.familyName)"
//
//              if let phoneNumber = contactProperty.value as? CNPhoneNumber {
//                  info += "\nSelected: \(phoneNumber.stringValue)"
//              } else if let emailAddress = contactProperty.value as? String, contactProperty.key == CNContactEmailAddressesKey {
//                  info += "\nSelected Email: \(emailAddress)"
//              } // Add more checks for other properties if needed
//
//              parent.selectedContactInfo = info
//              parent.isPresented = false
//         }
//        */
//
//        // Called when the user cancels the contact picker
//        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
//            print("Contact picker cancelled.")
//            // Dismiss the contact picker
//            parent.isPresented = false
//        }
//    }
//}
//
//// MARK: - Content View (Example Usage)
//
//struct ContentView: View {
//    // State to control whether the contact picker sheet is shown
//    @State private var showingContactPicker = false
//
//    // State to store the information returned from the picker
//    @State private var contactInfo: String? = nil
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                Button("Select Contact") {
//                    // Request permissions implicitly (or check/request explicitly beforehand)
//                    self.showingContactPicker = true
//                }
//                .padding()
//                .buttonStyle(.borderedProminent)
//
//                if let info = contactInfo {
//                    Text("Selected Contact:")
//                        .font(.headline)
//                    Text(info)
//                        .padding()
//                        .multilineTextAlignment(.center)
//                        .background(Color.secondary.opacity(0.1))
//                        .cornerRadius(8)
//                } else {
//                    Text("No contact selected yet.")
//                        .foregroundColor(.secondary)
//                }
//
//                Spacer() // Push content to the top
//            }
//            .padding()
//            .navigationTitle("Contact Picker Demo")
//            // Use the .sheet modifier to present the ContactPickerView
//            .sheet(isPresented: $showingContactPicker) {
//                // Pass the necessary bindings to the ContactPickerView
//                ContactPickerView(isPresented: $showingContactPicker, selectedContactInfo: $contactInfo)
//            }
//        }
//    }
//}
//
//// MARK: - Preview Provider
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//
//// MARK: - App Entry Point (Requires Info.plist Permissions)
///*
//@main
//struct ContactPickerApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
//*/
