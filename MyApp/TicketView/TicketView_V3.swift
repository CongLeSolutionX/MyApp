////
////  TicketView_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/21/25.
////
//
//import SwiftUI
//import MapKit // Needed for Directions
//
//// MARK: - Enhanced Data Model
//struct PassData: Identifiable {
//    let id = UUID()
//    var companyName: String
//    var eventTime: Date
//    var heroImageName: String
//    var venueName: String
//    var eventTitle: String
//    var label: String
//    var value: String // Mutable for simulation
//    var logoSystemImageName: String
//    var logoBackgroundColor: Color
//    var passBackgroundColor: Color = Color(red: 235/255, green: 110/255, blue: 75/255)
//    var foregroundColor: Color = .white
//
//    // New fields for functionality
//    var venueAddress: String // For Maps Directions
//    var websiteURL: URL?     // For View Website link
//    var shareableDetails: String // Simple text to share
//}
//
//// MARK: - Main Content View (Interactive & Functional)
//struct ContentView: View {
//
//    @State private var passData = PassData(
//        companyName: "Cosmic Lanes",
//        eventTime: Date.from(year: 2024, month: 8, day: 22, hour: 17, minute: 0),
//        heroImageName: "My-meme-orange_2", // *** Replace with your actual image asset name ***
//        venueName: "BOWL-A-RAMA CENTRAL",
//        eventTitle: "GALAXY BOWLING NIGHT",
//        label: "Lane",
//        value: "12",
//        logoSystemImageName: "sportscourt.fill",
//        logoBackgroundColor: Color(white: 0.95),
//        // --- New Data ---
//        venueAddress: "123 Main St, Anytown, CA 90210", // Example Address
//        websiteURL: URL(string: "https://www.example.com/galaxybowling"), // Example URL
//        shareableDetails: "Check out Galaxy Bowling Night at Bowl-A-Rama Central! Lane 12." // Example Share Text
//    )
//
//    @State private var showingOptionsSheet = false
//    @State private var showingPassDetailsAlert = false
//    @State private var showShareSheet = false // State for sharing sheet
//
//    @Environment(\.presentationMode) var presentationMode
//    @Environment(\.openURL) var openURL // Environment action to open URLs
//
//    var body: some View {
//        NavigationView {
//            ScrollView { // Use ScrollView if content might exceed screen height
//                VStack(spacing: 20) {
//                    BowlingPassView(data: passData)
//                        .padding(.horizontal)
//                        .padding(.top) // Add padding at the top inside ScrollView
//                        .onTapGesture {
//                            showingPassDetailsAlert = true
//                        }
//                        .accessibilityElement(children: .combine)
//                        .accessibilityLabel("Bowling Pass for \(passData.eventTitle) at \(passData.venueName)")
//                        .accessibilityHint("Tap to view details or options.")
//
//                    Button("Simulate Lane Change") {
//                        updateLaneNumber()
//                    }
//                    .padding()
//                    .buttonStyle(.borderedProminent)
//                    .accessibilityHint("Updates the lane number on the pass.")
//
//                    // Example using Link for website (could also be in ActionSheet)
//                    if let url = passData.websiteURL {
//                         Link("Visit Event Website", destination: url)
//                            .padding(.vertical)
//                            .buttonStyle(.borderless) // More subtle link style
//                            .accessibilityHint("Opens the event website in your browser.")
//                    }
//
//                    Spacer() // Pushes content up within the VStack
//                }
//                .frame(maxWidth: .infinity) // Allow VStack to expand horizontally
//            }
//            .background(Color(.systemGroupedBackground).ignoresSafeArea())
//            .navigationTitle("Ticket")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Done") {
//                        dismissView()
//                    }
//                    .accessibilityLabel("Done")
//                    .accessibilityHint("Dismisses the ticket view.")
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        showingOptionsSheet = true
//                    } label: {
//                        Image(systemName: "ellipsis.circle.fill")
//                            .imageScale(.large)
//                    }
//                    .accessibilityLabel("More options")
//                    .accessibilityHint("Shows actions like Share, Add to Wallet, Get Directions, or View Website.")
//                }
//            }
//            // Action Sheet for More Options
//            .actionSheet(isPresented: $showingOptionsSheet) {
//                createActionSheet() // Keep action sheet creation clean
//            }
//            // Alert for tapping the pass
//            .alert("Pass Details", isPresented: $showingPassDetailsAlert) {
//                 Button("OK", role: .cancel) { }
//            } message: {
//                 Text("Event: \(passData.eventTitle)\nVenue: \(passData.venueName)\nTime: \(passData.eventTime.formatted(date: .abbreviated, time: .shortened))\n\(passData.label): \(passData.value)")
//            }
//             // Share Sheet Modifier
//             .sheet(isPresented: $showShareSheet) {
//                  ShareSheet(activityItems: [passData.shareableDetails])
//             }
//        }
//    }
//
//    // MARK: - Actions
//    private func dismissView() {
//        print("Done tapped - simulating dismissal")
//        presentationMode.wrappedValue.dismiss()
//    }
//
//    private func updateLaneNumber() {
//        let newLane = Int.random(in: 1...40)
//        passData.value = String(newLane)
//        // Also update shareable details if lane changes
//        passData.shareableDetails = "Check out Galaxy Bowling Night at Bowl-A-Rama Central! Lane \(newLane)."
//        print("Lane updated to: \(newLane)")
//    }
//
//    private func getDirections() {
//        print("Getting directions to: \(passData.venueAddress)")
//        let geocoder = CLGeocoder()
//        geocoder.geocodeAddressString(passData.venueAddress) { (placemarks, error) in
//            if let error = error {
//                print("Geocoding error: \(error.localizedDescription)")
//                // Handle error (e.g., show an alert)
//                return
//            }
//            guard let placemark = placemarks?.first else {
//                print("No placemark found for address.")
//                // Handle error
//                return
//            }
//
//            let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
//            mapItem.name = passData.venueName
//            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
//        }
//    }
//
//    private func addToWallet() {
//        // --- PassKit Simulation ---
//        // Real implementation requires PassKit framework, a server to generate
//        // the .pkpass file, and proper entitlements/certificates.
//        print("Simulating Add to Apple Wallet...")
//        // You might show an alert confirming the simulation or a placeholder message.
//        // In a real app: Fetch the .pkpass file URL and use PKAddPassesViewController
//    }
//
//     private func viewWebsite() {
//         guard let url = passData.websiteURL else {
//             print("No website URL provided.")
//             // Optionally show an alert to the user
//             return
//         }
//         print("Opening website: \(url)")
//         openURL(url) // Uses the environment's openURL action
//     }
//
//    // MARK: - Action Sheet Creation
//     private func createActionSheet() -> ActionSheet {
//         var buttons: [ActionSheet.Button] = []
//
//         // 1. Share
//         buttons.append(.default(Text("Share Pass")) { showShareSheet = true })
//
//         // 2. Add to Wallet
//         buttons.append(.default(Text("Add to Apple Wallet")) { addToWallet() })
//
//         // 3. Get Directions
//         buttons.append(.default(Text("Get Directions")) { getDirections() })
//
//         // 4. View Website (only if URL exists)
//         if passData.websiteURL != nil {
//             buttons.append(.default(Text("View Website")) { viewWebsite() })
//         }
//
//         // 5. Cancel
//         buttons.append(.cancel())
//
//         return ActionSheet(
//             title: Text("Pass Options"),
//             message: Text("What would you like to do?"),
//             buttons: buttons
//         )
//     }
//}
//
//// MARK: - Bowling Pass View & Subviews (Mostly Unchanged Structurally)
//// (Keeping these concise as they weren't the focus of the functionality update)
//struct BowlingPassView: View {
//    let data: PassData
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            TopBarView(data: data)
//                .padding([.horizontal, .top])
//                .padding(.bottom, 8)
//
//             Image(data.heroImageName) // Ensure image is in Assets.xcassets
//                 .resizable()
//                 .aspectRatio(contentMode: .fill)
//                 .frame(height: 150)
//                 .clipped()
//                 .accessibilityLabel("Promotional image for \(data.eventTitle)")
//
//            MainInfoView(data: data)
//                .padding()
//
//            Spacer() // Ensure content pushes to top and bottom
//
//            BottomBarView(data: data)
//                .padding([.horizontal, .bottom])
//        }
//        .background(data.passBackgroundColor)
//        .foregroundColor(data.foregroundColor)
//        .cornerRadius(15)
//        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
//    }
//}
//
//// --- Other Subviews (TopBarView, MainInfoView, BottomBarView, PassLogoView) ---
//// --- remain largely the same as the previous example, just ensure they   ---
//// --- use the `data: PassData` passed into them. Add accessibility where ---
//// --- appropriate if not already done.                                   ---
//
//// Example: Update MainInfoView slightly for clarity
//struct MainInfoView: View {
//    let data: PassData
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 5) { // Consistent spacing
//            Text(data.venueName)
//                .font(.caption)
//                .fontWeight(.medium)
//                .textCase(.uppercase)
//                .opacity(0.8)
//                .accessibilityLabel("Venue: \(data.venueName)")
//
//            Text(data.eventTitle)
//                .font(.title2)
//                .fontWeight(.bold)
//                .lineLimit(1) // Prevent overly long titles from wrapping awkwardly
//                .minimumScaleFactor(0.8) // Allow shrinking if needed
//                .textCase(.uppercase)
//                .padding(.bottom, 20) // Space before details
//                .accessibilityLabel("Event: \(data.eventTitle)")
//
//            Spacer() // Push details down if there's empty space
//
//            HStack {
//                VStack(alignment: .leading) {
//                    Text(data.label)
//                        .font(.caption)
//                        .textCase(.uppercase)
//                        .opacity(0.8)
//                        .accessibilityHidden(true)
//
//                    Text(data.value)
//                        .font(.title)
//                        .fontWeight(.semibold)
//                        .minimumScaleFactor(0.7) // Allow shrinking large lane numbers
//                        .lineLimit(1)
//                 }
//                 .accessibilityElement(children: .combine)
//                 .accessibilityLabel("\(data.label): \(data.value)")
//
//                 Spacer() // Keep details aligned left
//            }
//        }
//        .accessibilityElement(children: .contain)
//    }
//}
//
//// Assume TopBarView, BottomBarView, PassLogoView are defined as before...
//// Make sure to include the necessary definitions for them.
//
//struct TopBarView: View { /* ... as before ... */
//    let data: PassData
//
//    var body: some View {
//        HStack(alignment: .center) {
//            PassLogoView(systemImageName: data.logoSystemImageName, backgroundColor: data.logoBackgroundColor)
//            Text(data.companyName)
//                .font(.headline)
//                .fontWeight(.medium)
//                .accessibilityLabel("Company: \(data.companyName)")
//
//            Spacer()
//
//            VStack(alignment: .trailing) {
//                Text(data.eventTime.formatted(.dateTime.hour().minute()))
//                Text(data.eventTime.formatted(.dateTime.month(.abbreviated).day()))
//            }
//            .font(.subheadline)
//            .accessibilityElement(children: .combine)
//            .accessibilityLabel("Event time: \(data.eventTime.formatted(date: .abbreviated, time: .shortened))")
//        }
//        .accessibilityElement(children: .contain)
//    }
//}
//
//struct BottomBarView: View { /* ... as before ... */
//    let data: PassData
//
//    var body: some View {
//        HStack {
//            PassLogoView(systemImageName: data.logoSystemImageName, backgroundColor: data.logoBackgroundColor)
//            Spacer()
//            Image(systemName: "wifi")
//                .font(.title2)
//                .fontWeight(.light)
//                .accessibilityLabel("Contactless symbol")
//        }
//        .accessibilityElement(children: .contain)
//    }
//}
//
//struct PassLogoView: View { /* ... as before ... */
//    let systemImageName: String
//    let backgroundColor: Color
//
//    var body: some View {
//         Image(systemName: systemImageName)
//             .imageScale(.large)
//             .foregroundColor(.black.opacity(0.7))
//             .frame(width: 30, height: 30)
//             .padding(5)
//             .background(backgroundColor)
//             .clipShape(Circle())
//             .accessibilityLabel("Company logo")
//    }
//}
//
//// MARK: - Helper Utilities
//
//// Date Extension (Ensure this exists)
//extension Date {
//    static func from(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date {
//        Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)) ?? Date()
//    }
//}
//
//// Share Sheet Helper (Using UIActivityViewController)
//struct ShareSheet: UIViewControllerRepresentable {
//    var activityItems: [Any]
//    var applicationActivities: [UIActivity]? = nil
//
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
//        // No update needed typically
//    }
//}
//
//// MARK: - Preview
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//          //.preferredColorScheme(.dark) // Optional: Preview in dark mode
//    }
//}
