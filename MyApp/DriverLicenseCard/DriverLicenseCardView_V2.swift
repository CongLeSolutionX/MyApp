////
////  DriverLicenseCardView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/21/25.
////
//
//import SwiftUI
//
//// MARK: - Data Models (Mock Data)
//
//struct DriverLicenseInfo: Identifiable {
//    let id = UUID()
//    let name: String
//    let state: String // e.g., "California", "Arizona"
//    let licenseNumber: String // Masked for display usually
//    let expirationDate: Date
//    let issueDate: Date
//    let photoAssetName: String // Use an SF Symbol name for mock photo
//    let realIDCompliant: Bool
//}
//
//struct AppPrivacyInfo {
//    let appName: String
//    let appIconName: String // SF Symbol for mock icon
//    let presentedFields: [String] // What the user sees being shared *now*
//    let storedFields: [String] // What the app *says* it will store
//    let retentionPolicy: String // How long stored data is kept
//    let developerWebsite: URL? // Link for more info
//}
//
//// MARK: - Main Driver's License View
//
//struct DriverLicenseView: View {
//    // --- Mock Data Instances ---
//    @State private var licenseInfo = DriverLicenseInfo(
//        name: "Kevin Nguyen",
//        state: "California",
//        licenseNumber: "714-****-1234",
//        expirationDate: Calendar.current.date(byAdding: .year, value: 4, to: Date())!,
//        issueDate: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
//        photoAssetName: "person.crop.rectangle.stack.fill", // Placeholder SF Symbol
//        realIDCompliant: true
//    )
//
//    @State private var requestingAppInfo = AppPrivacyInfo(
//        appName: "Example Retail App",
//        appIconName: "cart.fill", // Placeholder SF Symbol
//        presentedFields: ["ID Photo", "Full Name", "Age Over 21", "Issuing Authority"],
//        storedFields: ["Age Over 21 Verification Result", "Transaction Timestamp"],
//        retentionPolicy: "Stored by app for up to 30 days for verification records.",
//        developerWebsite: URL(string: "https://www.example.com/privacy")
//    )
//
//    // --- State Variables ---
//    @State private var showingPrivacySheet = false
//    @State private var showReadyInfoCard = true
//
//    var body: some View {
//        NavigationView {
//            VStack(alignment: .leading, spacing: 20) {
//                DriverLicenseCard(name: licenseInfo.name, state: licenseInfo.state, iconName: licenseInfo.photoAssetName)
//                    .padding(.horizontal)
//
//                // Conditionally show the info card
//                if showReadyInfoCard {
//                    ReadyInfoCard(licenseState: licenseInfo.state) {
//                        // Action to close the card with animation
//                        withAnimation {
//                            showReadyInfoCard = false
//                        }
//                        print("User dismissed the 'Ready to Use' info card.")
//                    }
//                    .padding(.horizontal)
//                    .transition(.opacity.combined(with: .scale(scale: 0.9))) // Add transition
//                }
//
//                Spacer() // Pushes content to the top
//            }
//            .padding(.top)
//            .background(Color(.systemGroupedBackground).ignoresSafeArea(.all)) // Background color for the whole view
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Done") {
//                        // Action for Done button
//                        // In a real app, this might dismiss a parent modal,
//                        // navigate back, or finalize a setup process.
//                        print("Done button tapped on main view.")
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        showingPrivacySheet = true
//                        print("Ellipsis tapped, showing privacy sheet.")
//                    } label: {
//                        Image(systemName: "ellipsis.circle")
//                            .imageScale(.large)
//                    }
//                }
//            }
//            .sheet(isPresented: $showingPrivacySheet) {
//                // Present the Privacy Sheet modally, passing necessary data
//                PrivacySheetView(licenseInfo: licenseInfo, appInfo: requestingAppInfo)
//            }
//        }
//         // Use on Navigation View for iOS 16+ compatibility with background color
//         .navigationViewStyle(.stack)
//    }
//}
//
//// MARK: - Helper View: Purple Driver's License Card (Updated)
//struct DriverLicenseCard: View {
//    let name: String
//    let state: String
//    let iconName: String // SF Symbol name
//
//    var body: some View {
//        ZStack(alignment: .leading) {
//            RoundedRectangle(cornerRadius: 15)
//                .fill(
//                    LinearGradient(
//                        gradient: Gradient(colors: [Color.indigo.opacity(0.8), Color.purple.opacity(0.9)]),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//                .frame(height: 200) // Approximate height
//                 .shadow(color: .black.opacity(0.1), radius: 5, y: 3)
//
//            HStack {
//                 VStack(alignment: .leading) {
//                     Text(state.uppercased())
//                         .font(.caption)
//                         .fontWeight(.medium)
//                         .foregroundColor(.white.opacity(0.8))
//                         .padding(.bottom, 1)
//
//                     Text("DRIVER'S LICENSE")
//                         .font(.caption)
//                         .fontWeight(.medium)
//                         .foregroundColor(.white.opacity(0.8))
//
//                     Spacer() // Pushes Name to the bottom
//
//                     Text(name)
//                         .font(.title2)
//                         .fontWeight(.semibold)
//                         .foregroundColor(.white)
//                         .minimumScaleFactor(0.8) // Allow text shrinking
//                 }
//                 Spacer() // Pushes icon to the right
//                 Image(systemName: iconName)
//                    .resizable()
//                    .scaledToFit()
//                    .foregroundColor(.white.opacity(0.7))
//                    .frame(width: 50, height: 50)
//                    .padding(.trailing, 20)
//             }
//            .padding()
//            //.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading) // Already handled by HStack/VStack/Spacer
//        }
//    }
//}
//
//// MARK: - Helper View: Gray "Ready to Use" Info Card (Updated)
//struct ReadyInfoCard: View {
//    let licenseState: String
//    var onClose: () -> Void // Closure to handle dismissal
//
//    var body: some View {
//        HStack(spacing: 15) {
//            Image(systemName: "checkmark.seal.fill") // More appropriate icon
//                .resizable()
//                .scaledToFit()
//                .frame(width: 35, height: 35)
//                .foregroundColor(.green)
//                 .padding(8)
//                 .background(Color.green.opacity(0.15))
//                 .clipShape(RoundedRectangle(cornerRadius: 8))
//
//            VStack(alignment: .leading) {
//                Text("\(licenseState) Driver's License")
//                    .font(.headline)
//                Text("Your ID is ready to use in Wallet.")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//
//            Spacer()
//
//            Button(action: onClose) { // Use the closure for the action
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.gray.opacity(0.5))
//                    .imageScale(.large)
//            }
//            .buttonStyle(.plain) // Prevent the whole row from becoming tappable
//        }
//        .padding()
//        .background(Color(.secondarySystemGroupedBackground)) // Light gray background
//        .cornerRadius(15)
//    }
//}
//
//// MARK: - Privacy Sheet View (Updated)
//
//struct PrivacySheetView: View {
//    // --- Environment & State ---
//    @Environment(\.dismiss) var dismiss // To allow programmatic dismissal
//    @State private var showingPrivacyOptions = false
//
//    // --- Passed Data ---
//    let licenseInfo: DriverLicenseInfo
//    let appInfo: AppPrivacyInfo
//
//    var body: some View {
//        NavigationView { // Add NavigationView for the toolbar within the sheet
//            ScrollView {
//                VStack(spacing: 25) {
//                    // Note: WalletHeader is now integrated visually below the Nav Bar
//                    AppInfoSection(appName: appInfo.appName, iconName: appInfo.appIconName)
//                        .padding(.top, 5) // Add padding if needed below nav bar
//
//                    SheetIDCard(state: licenseInfo.state)
//
//                    InformationListSection(
//                        presentedFields: appInfo.presentedFields,
//                        storedFields: appInfo.storedFields,
//                        retentionPolicy: appInfo.retentionPolicy
//                    )
//
//                    FaceIDSection() // Remains mostly visual indicator
//                }
//                .padding()
//            }
//            .background(Color(.systemGroupedBackground).ignoresSafeArea(.all)) // Background for the sheet content
//            .navigationTitle("Privacy") // Use Navigation Title
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Done") {
//                        dismiss() // Dismiss the sheet
//                        print("Privacy sheet dismissed via Done button.")
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        showingPrivacyOptions = true
//                        print("Ellipsis in sheet tapped, showing options.")
//                    } label: {
//                        Image(systemName: "ellipsis.circle")
//                            .imageScale(.large)
//                    }
//                }
//            }
//            // --- Action Sheet for Ellipsis Button ---
//            .actionSheet(isPresented: $showingPrivacyOptions) {
//                ActionSheet(
//                    title: Text("Privacy Options"),
//                    message: Text("Manage privacy settings or learn more."),
//                    buttons: [
//                        .default(Text("Learn More About Wallet Privacy")) {
//                            print("User wants to learn more about Wallet privacy.")
//                            // In a real app, open a URL (e.g., Apple's privacy page)
//                            if let url = URL(string: "https://www.apple.com/legal/privacy/data/en/apple-wallet/") {
//                                // UIApplication.shared.open(url) // Needs UIKit import, handle carefully in SwiftUI lifecycle
//                                print("Would open URL: \(url)")
//                            }
//                        },
//                        .default(Text("View App Privacy Details")) {
//                             print("User wants to see App privacy details.")
//                             // Open the app's developer website if available
//                             if let url = appInfo.developerWebsite {
//                                 // UIApplication.shared.open(url)
//                                 print("Would open URL: \(url)")
//                             } else {
//                                 print("No developer website provided.")
//                             }
//                        },
//                        .destructive(Text("Report a Problem")) {
//                             print("User wants to report a problem.")
//                             // In a real app, trigger feedback mechanism
//                        },
//                        .cancel() {
//                             print("User cancelled privacy options.")
//                        }
//                    ]
//                )
//            }
//        }
//         // Use on Navigation View for compatibility
//         .navigationViewStyle(.stack)
//    }
//}
//
//// MARK: - Helper Views for Privacy Sheet (Updated)
//
//// **Removed redundant WalletHeader:** Functionality integrated into Nav Bar
//
//struct AppInfoSection: View {
//    let appName: String
//    let iconName: String // SF Symbol
//
//    var body: some View {
//        VStack {
//            Image(systemName: iconName) // Use dynamic icon
//                .resizable()
//                .scaledToFit()
//                .symbolRenderingMode(.hierarchical) // Or .multicolor if applicable
//                .foregroundStyle(.tint) // Use accent color
//                .frame(width: 60, height: 60)
//                .padding(10)
//                .background(Color(.secondarySystemGroupedBackground))
//                .clipShape(RoundedRectangle(cornerRadius: 16)) // Smoother corners
//                .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
//
//            Text(appName) // Use dynamic name
//                .font(.title3)
//                .fontWeight(.medium)
//        }
//    }
//}
//
//struct SheetIDCard: View {
//     let state: String // Pass state name
//
//     var body: some View {
//         HStack(spacing: 15) {
//             Image(systemName: "person.text.rectangle.fill") // Better icon for ID card
//                .resizable()
//                .scaledToFit()
//                .frame(width: 35, height: 35)
//                .foregroundColor(.blue)
//                 .padding(8)
//                 .background(Color.blue.opacity(0.15))
//                 .clipShape(RoundedRectangle(cornerRadius: 8))
//
//             VStack(alignment: .leading) {
//                 Text("\(state) Driver's License") // Dynamic state
//                     .font(.headline)
//                 Text("Tap card reader to present ID") // More instructional text
//                     .font(.subheadline)
//                     .foregroundColor(.secondary)
//             }
//             Spacer() // Pushes content to the left
//         }
//         .padding()
//         .background(Color(.secondarySystemGroupedBackground))
//         .cornerRadius(15)
//     }
//}
//
//struct InformationListSection: View {
//    let presentedFields: [String]
//    let storedFields: [String]
//    let retentionPolicy: String
//
//    // Helper to create consistent rows
//    @ViewBuilder
//    private func infoRow(icon: String, text: String) -> some View {
//        HStack(spacing: 8) {
//            Image(systemName: icon).frame(width: 20, alignment: .center) // Align icons
//            Text(text)
//        }
//        .font(.subheadline)
//        .foregroundColor(.primary.opacity(0.9))
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            // --- Presented Information ---
//            VStack(alignment: .leading, spacing: 4) {
//                 Text("Shared with \"\(appInfo.appName)\"") // Dynamic App Name Reference
//                     .font(.subheadline).bold()
//                 // You could add logic here if *none* are stored
//                 if !storedFields.isEmpty {
//                    Text(retentionPolicy) // Display retention policy
//                         .font(.caption)
//                         .foregroundColor(.secondary)
//                 } else {
//                      Text("Information is presented but not stored by the app.")
//                         .font(.caption)
//                         .foregroundColor(.secondary)
//                 }
//            }
//
//            // Use Grid for two columns more robustly
//            // Calculate items per column for better balancing if needed, or just list them
//            VStack(alignment: .leading, spacing: 8) {
//                ForEach(presentedFields, id: \.self) { field in
//                    // Simple single column for clarity in this example
//                    infoRow(icon: iconForField(field), text: field)
//                }
//            }
//
//            // Only show the Stored section if there are fields to list
//            if !storedFields.isEmpty {
//                Divider().padding(.vertical, 5)
//
//                Text("Stored by \"\(appInfo.appName)\"") // Dynamic App Name Reference
//                    .font(.subheadline).bold()
//
//                VStack(alignment: .leading, spacing: 8) {
//                    ForEach(storedFields, id: \.self) { field in
//                         infoRow(icon: iconForField(field), text: field)
//                    }
//                }
//            }
//        }
//        .padding()
//        .background(Color(.secondarySystemGroupedBackground))
//        .cornerRadius(15)
//    }
//
//    // Helper func to map field names to SF Symbols (customize as needed)
//    private func iconForField(_ fieldName: String) -> String {
//        switch fieldName.lowercased() {
//        case "id photo": return "person.crop.rectangle.stack"
//        case "full name", "legal name": return "person.text.rectangle"
//        case "age over 21", "age over 18": return "checkmark.seal"
//        case "issuing authority": return "building.columns"
//        case "transaction timestamp": return "clock"
//        case "address": return "house"
//        case "date of birth": return "calendar"
//        // Add more cases for common fields
//        default: return "questionmark.circle" // Default icon
//        }
//    }
//
//     // Mock appInfo used just within this view for preview/default text
//     // Could be passed in properly if needed outside the sheet context
//     private var appInfo: AppPrivacyInfo {
//         AppPrivacyInfo(appName: "Example App", appIconName: "", presentedFields: [], storedFields: [], retentionPolicy: "", developerWebsite: nil)
//     }
//}
//
//struct FaceIDSection: View {
//    var body: some View {
//        VStack {
//            Image(systemName: "faceid")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 40, height: 40)
//                .foregroundColor(.blue)
//            Text("Authenticated with Face ID") // More descriptive
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//                .padding(.top, 2)
//        }
//        .padding(.top) // Add space above Face ID section
//    }
//}
//
//// MARK: - Preview Provider (Updated)
//
//struct DriverLicenseView_Previews: PreviewProvider {
//    static var previews: some View {
//        DriverLicenseView()
//             // Preview in different modes
//             .preferredColorScheme(.light)
//             .previewDisplayName("Light Mode")
//
//        DriverLicenseView()
//             .preferredColorScheme(.dark)
//             .previewDisplayName("Dark Mode")
//    }
//}
//
//// No separate preview needed for PrivacySheetView as it's presented by DriverLicenseView
//// You could create one passing mock data if isolated testing is desired:
//// struct PrivacySheetView_Previews: PreviewProvider {
////     static var previews: some View {
////         PrivacySheetView(licenseInfo: /* create mock DriverLicenseInfo */,
////                          appInfo: /* create mock AppPrivacyInfo */)
////     }
//// }
