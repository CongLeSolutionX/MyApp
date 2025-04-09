////
////  NotificationSettingsView.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import SwiftUI
//import UIKit // Needed for UIApplication.openSettingsURLString
//
//struct NotificationSettingsView: View {
//
//    // Mock state for notification preferences - load from backend/UserDefaults
//    @State private var allowPushNotifications: Bool = true // App-level toggle (if system allows)
//    @State private var emailNotificationsEnabled: Bool = true
//    @State private var inAppNotificationsEnabled: Bool = true
//
//    // Granular push notification categories
//    @State private var promotionsEnabled: Bool = true
//    @State private var accountActivityEnabled: Bool = true
//    @State private var newFeaturesEnabled: Bool = false
//    @State private var remindersEnabled: Bool = true
//
//    var body: some View {
//        Form {
//            // --- General Notification Controls ---
//            Section(header: Text("General Preferences"),
//                    footer: Text("Control the main ways you receive notifications from us. Push notification settings are ultimately managed in your device's Settings app.")) {
//
//                // App-Level Push Toggle (often mirrors or depends on system settings)
//                Toggle(isOn: $allowPushNotifications) {
//                    HStack {
//                        Image(systemName: "bell.badge.fill")
//                            .foregroundColor(.rhGold)
//                        Text("Allow Push Notifications")
//                    }
//                }
//                .tint(.rhGold)
//                // In a real app, changing this might trigger checks for system permission
//                // or enable/disable all granular push toggles below.
//
//                // Email Notifications
//                Toggle(isOn: $emailNotificationsEnabled) {
//                     HStack {
//                         Image(systemName: "envelope.fill")
//                             .foregroundColor(.rhGold)
//                         Text("Email Notifications")
//                     }
//                 }
//                .tint(.rhGold)
//
//                // In-App Notifications (e.g., banners shown while using the app)
//                 Toggle(isOn: $inAppNotificationsEnabled) {
//                      HStack {
//                          Image(systemName: "app.badge.fill")
//                              .foregroundColor(.rhGold)
//                          Text("In-App Notifications")
//                      }
//                  }
//                 .tint(.rhGold)
//            }
//
//            // --- Detailed Push Notification Categories ---
//            // This section might be disabled visually if allowPushNotifications is false
//            Section(header: Text("Push Notification Types")) {
//                Toggle(isOn: $promotionsEnabled) {
//                    VStack(alignment: .leading) {
//                         Text("Promotions & Offers")
//                         Text("Receive updates on special deals and sales.")
//                             .font(.caption)
//                             .foregroundColor(.gray)
//                     }
//                }
//                .tint(.rhGold)
//
//                Toggle(isOn: $accountActivityEnabled) {
//                     VStack(alignment: .leading) {
//                          Text("Account Activity")
//                          Text("Get notified about logins, security alerts, etc.")
//                              .font(.caption)
//                              .foregroundColor(.gray)
//                      }
//                 }
//                 .tint(.rhGold)
//
//                Toggle(isOn: $newFeaturesEnabled) {
//                     VStack(alignment: .leading) {
//                          Text("New Feature Updates")
//                          Text("Learn about new functionalities in the app.")
//                              .font(.caption)
//                              .foregroundColor(.gray)
//                      }
//                 }
//                 .tint(.rhGold)
//
//                Toggle(isOn: $remindersEnabled) {
//                      VStack(alignment: .leading) {
//                           Text("Reminders")
//                           Text("Notifications for upcoming events or tasks.")
//                               .font(.caption)
//                               .foregroundColor(.gray)
//                       }
//                  }
//                  .tint(.rhGold)
//
//            }
//            .disabled(!allowPushNotifications) // Disable granular controls if master is off
//            .onChange(of: allowPushNotifications) { enabled in
//                 // Optional: Automatically toggle all sub-options based on master
//                 // if !enabled {
//                 //     promotionsEnabled = false
//                 //     accountActivityEnabled = false
//                 //     newFeaturesEnabled = false
//                 //     remindersEnabled = false
//                 // }
//                print("Allow Push Notifications Toggled: \(enabled)")
//                // Add logic to update backend preference
//                // Maybe prompt user to go to system settings if enabling here?
//            }
//            .onChange(of: [promotionsEnabled, accountActivityEnabled, newFeaturesEnabled, remindersEnabled]) { _ in
//                 // Handle changes to individual toggles
//                print("Granular preference changed. Saving...")
//                 // Add logic to update backend preference for the specific category
//             }
//
//            // --- Link to System Settings ---
//             Section(header: Text("System Settings")) {
//                 Button {
//                     // Open the app's specific notification settings in the iOS Settings app
//                     if let url = URL(string: UIApplication.openSettingsURLString),
//                       UIApplication.shared.canOpenURL(url) {
//                         UIApplication.shared.open(url)
//                     }
//                 } label: {
//                     HStack {
//                          Image(systemName: "gearshape.fill")
//                              .foregroundColor(.rhGold)
//                          Text("Open iOS Notification Settings")
//                          Spacer() // Pushes chevron to the right if needed in a full NavigationLink style
//                         Image(systemName: "arrow.up.right.square") // Indicates external action
//                             .font(.caption)
//                             .foregroundColor(.gray)
//                     }
//                     // Make sure the text color is appropriate
//                      .foregroundColor(Color(uiColor: .label)) // Use label color for adaptability
//                 }
//             }
//        }
//        .navigationTitle("Notifications")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// --- Previews ---
//struct NotificationSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            NotificationSettingsView()
//        }
//        .preferredColorScheme(.light)
//        .environment(\.colorScheme, .light) // More explicit for preview
//        .previewDisplayName("Light Mode")
//
//        NavigationView {
//            NotificationSettingsView()
//             .environment(\.colorScheme, .dark) // More explicit for preview
//        }
//         .preferredColorScheme(.dark) // Hint for the preview system
//        .previewDisplayName("Dark Mode")
//
//    }
//}
//
//// --- Dummy Color Extension ---
//// Ensure this is defined elsewhere in your project
//// extension Color {
////     static let rhGold = Color.orange // Placeholder
//// }
//
//// --- Extension for disabling effect consistency ---
//// Optional: Apply a consistent disabled look
//// extension View {
////     @ViewBuilder func disabled(_ isDisabled: Bool) -> some View {
////        self
////             .opacity(isDisabled ? 0.5 : 1.0)
////             .allowsHitTesting(!isDisabled)
////    }
//// }
