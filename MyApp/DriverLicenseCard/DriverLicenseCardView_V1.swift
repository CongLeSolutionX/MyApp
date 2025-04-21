//
//  DriverLicenseCardView_V1.swift
//  MyApp
//
//  Created by Cong Le on 4/21/25.
//

import SwiftUI

// MARK: - Main Driver's License View
struct DriverLicenseView: View {
    @State private var showingPrivacySheet = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                DriverLicenseCard()
                    .padding(.horizontal)

                ReadyInfoCard()
                    .padding(.horizontal)

                Spacer() // Pushes content to the top
            }
            .padding(.top) // Add some padding below the navigation bar
            //.background(Color(.systemGroupedBackground)) // Optional: Set a background color
            .navigationBarTitleDisplayMode(.inline) // Keeps title area clean
            .toolbar {
                // --- Navigation Bar Buttons ---
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        // Action for Done button
                        print("Done tapped")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Action for ellipsis button
                        showingPrivacySheet = true // Example action: Show the privacy sheet
                        print("Ellipsis tapped")
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                    }
                }
            }
            // Present the Privacy Sheet modally
            .sheet(isPresented: $showingPrivacySheet) {
                PrivacySheetView()
            }
        }
    }
}

// MARK: - Helper View: Purple Driver's License Card
struct DriverLicenseCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.indigo.opacity(0.8), Color.purple.opacity(0.9)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200) // Approximate height

            VStack(alignment: .leading) {
                Text("DRIVER'S LICENSE")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 5)

                Spacer() // Pushes Name to the bottom

                Text("Name")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Helper View: Gray "Ready to Use" Info Card
struct ReadyInfoCard: View {
    var body: some View {
        HStack(spacing: 15) {
            // Placeholder for the checkered icon
            Image(systemName: "app.dashed") // Or a custom image
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.secondary)
                 .padding(5)
                 .background(Color.gray.opacity(0.2))
                 .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading) {
                Text("Driver's License")
                    .font(.headline)
                Text("Your driver's license is ready to use.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                // Action for close button
                print("Close info card tapped")
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray.opacity(0.5))
                    .imageScale(.large)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground)) // Light gray background
        .cornerRadius(15)
    }
}

// MARK: - Privacy Sheet View
struct PrivacySheetView: View {
    @Environment(\.dismiss) var dismiss // To allow programmatic dismissal

    var body: some View {
        NavigationView { // Add NavigationView for the toolbar within the sheet
            ScrollView {
                VStack(spacing: 25) {
                    WalletHeader()

                    AppInfoSection()

                    SheetIDCard()

                    InformationListSection()

                    FaceIDSection()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground)) // Background for the sheet content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss() // Dismiss the sheet
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Action for ellipsis in sheet
                        print("Ellipsis in sheet tapped")
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                    }
                }
            }
        }
    }
}

// MARK: - Helper Views for Privacy Sheet

struct WalletHeader: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        HStack {
            Image(systemName: "wallet.pass.fill") // Wallet icon
            Text("Wallet")
                .font(.headline)
            Spacer()
            Button {
                 dismiss() // Close sheet action
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray.opacity(0.5))
                    .imageScale(.large)
            }
        }
        .padding(.bottom, 10)
    }
}

struct AppInfoSection: View {
    var body: some View {
        VStack {
            Image(systemName: "app.dashed") // Placeholder App Icon
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray.opacity(0.5))
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text("App Name")
                .font(.title3)
                .fontWeight(.medium)
        }
    }
}

struct SheetIDCard: View {
     var body: some View {
         HStack(spacing: 15) {
             // Placeholder for the checkered icon
             Image(systemName: "app.dashed") // Or a custom image
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .foregroundColor(.secondary)
                 .padding(5)
                 .background(Color.gray.opacity(0.2))
                 .clipShape(RoundedRectangle(cornerRadius: 8))

             VStack(alignment: .leading) {
                 Text("State Driver's License")
                     .font(.headline)
                 Text("Government-Issued ID")
                     .font(.subheadline)
                     .foregroundColor(.secondary)
             }
             Spacer() // Pushes content to the left
         }
         .padding()
         .background(Color(.secondarySystemGroupedBackground))
         .cornerRadius(15)
     }
}

struct InformationListSection: View {
    // Sample data structure for rows
    struct InfoItem: Identifiable {
        let id = UUID()
        let personInfo: String
        let idInfo: String
    }

    let presentedInfo: [InfoItem] = [
        InfoItem(personInfo: "Legal Name", idInfo: "ID Photo"),
        InfoItem(personInfo: "Legal Name", idInfo: "ID Photo"),
        InfoItem(personInfo: "Legal Name", idInfo: "ID Photo")
    ]

    let notStoredInfo: [InfoItem] = [
        InfoItem(personInfo: "Legal Name", idInfo: "ID Photo"),
        InfoItem(personInfo: "Legal Name", idInfo: "ID Photo"),
        InfoItem(personInfo: "Legal Name", idInfo: "ID Photo")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // --- Presented Information ---
            VStack(alignment: .leading, spacing: 4) {
                 Text("The following information will be presented:")
                     .font(.subheadline).bold()
                 Text("Stored by app for up to 30 days")
                     .font(.caption)
                     .foregroundColor(.secondary)
            }

            // Use Grid for two columns
            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 8) {
                ForEach(presentedInfo) { item in
                    GridRow {
                        HStack {
                            Image(systemName: "person.fill")
                            Text(item.personInfo)
                        }
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text(item.idInfo)
                        }
                    }
                }
            }
            .font(.subheadline)
            .foregroundColor(.primary.opacity(0.8))

            Divider()

            // --- Not Stored Information ---
            Text("Not stored by app")
                .font(.subheadline).bold()

             Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 8) {
                 ForEach(notStoredInfo) { item in
                     GridRow {
                         HStack {
                             Image(systemName: "person.fill")
                             Text(item.personInfo)
                         }
                         HStack {
                             Image(systemName: "photo.on.rectangle.angled")
                             Text(item.idInfo)
                         }
                     }
                 }
             }
             .font(.subheadline)
             .foregroundColor(.primary.opacity(0.8))
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(15)
    }
}

struct FaceIDSection: View {
    var body: some View {
        VStack {
            Image(systemName: "faceid")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.blue) // Typically blue
            Text("Face ID")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }
}

// MARK: - Preview Provider
struct DriverLicenseView_Previews: PreviewProvider {
    static var previews: some View {
        DriverLicenseView()
            // .preferredColorScheme(.dark) // Uncomment to preview in dark mode
    }
}

struct PrivacySheetView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacySheetView()
           // .preferredColorScheme(.dark)  // Uncomment to preview in dark mode
    }
}
