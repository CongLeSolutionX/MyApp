////
////  TicketView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/21/25.
////
//
//import SwiftUI
//
//// MARK: - Data Model (No changes needed for this example)
//struct PassData: Identifiable { // Add Identifiable for potential Lists/ForEach
//    let id = UUID() // Conformance to Identifiable
//    var companyName: String
//    var eventTime: Date
//    var heroImageName: String
//    var venueName: String
//    var eventTitle: String
//    var label: String
//    var value: String // Make it var to allow updates
//    var logoSystemImageName: String
//    var logoBackgroundColor: Color
//    var passBackgroundColor: Color = Color(red: 235/255, green: 110/255, blue: 75/255)
//    var foregroundColor: Color = .white
//}
//
//// MARK: - Main Content View (Now with State and Actions)
//struct ContentView: View {
//
//    // Use @State to manage the pass data locally. In a real app, this might come from a ViewModel (@StateObject).
//    @State private var passData = PassData(
//        companyName: "Cosmic Lanes",
//        eventTime: Date.from(year: 2024, month: 8, day: 22, hour: 17, minute: 0),
//        heroImageName: "My-meme-orange_2", // *** Replace with your actual image asset name ***
//        venueName: "BOWL-A-RAMA CENTRAL",
//        eventTitle: "GALAXY BOWLING NIGHT",
//        label: "Lane",
//        value: "12", // Initial lane
//        logoSystemImageName: "sportscourt.fill",
//        logoBackgroundColor: Color(white: 0.95)
//    )
//
//    // State for presenting modals/sheets
//    @State private var showingOptionsSheet = false
//    @State private var showingPassDetailsAlert = false
//
//    // Environment variable to simulate dismissal (useful if this view is presented modally)
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) { // Add spacing between pass and button
//                BowlingPassView(data: passData)
//                    .padding(.horizontal) // Keep horizontal padding for the pass
//                    .onTapGesture {
//                        // Action when the pass itself is tapped
//                        print("Pass tapped!")
//                        showingPassDetailsAlert = true
//                    }
//                    .accessibilityElement(children: .combine) // Treat pass as one element
//                    .accessibilityLabel("Bowling Pass for \(passData.eventTitle) at \(passData.venueName)")
//                    .accessibilityHint("Tap to view details or options.")
//
//                // Button to simulate updating pass data
//                Button("Simulate Lane Change") {
//                    updateLaneNumber()
//                }
//                .padding()
//                .buttonStyle(.borderedProminent)
//
//                Spacer() // Pushes content up
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity) // Allow VStack to expand
//            .background(Color(.systemGroupedBackground).ignoresSafeArea()) // Background for the whole view
//            .navigationTitle("Ticket")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar { // Use .toolbar for more flexible nav bar items
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Done") {
//                        // Simulate dismissing the view
//                        print("Done tapped - simulating dismissal")
//                        // In a real modal presentation, you'd use:
//                        // presentationMode.wrappedValue.dismiss()
//                    }
//                    .accessibilityLabel("Done")
//                    .accessibilityHint("Dismisses the ticket view.")
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        print("More options tapped")
//                        showingOptionsSheet = true
//                    } label: {
//                        Image(systemName: "ellipsis.circle.fill")
//                            .imageScale(.large)
//                            // Keep foregroundColor adaptive unless specific design requires it
//                            // .foregroundColor(.primary)
//                    }
//                    .accessibilityLabel("More options")
//                    .accessibilityHint("Shows actions like Share or Add to Wallet.")
//                }
//            }
//            // Action Sheet for the ellipsis button
//            .actionSheet(isPresented: $showingOptionsSheet) {
//                ActionSheet(
//                    title: Text("Pass Options"),
//                    message: Text("What would you like to do with this ticket?"),
//                    buttons: [
//                        .default(Text("Share Pass")) { print("Sharing pass...") /* Add sharing logic */ },
//                        .default(Text("Add to Apple Wallet")) { print("Adding to Wallet...") /* Add Wallet logic */ },
//                        .destructive(Text("Report Issue")) { print("Reporting issue...") /* Add reporting logic */ },
//                        .cancel() // Standard cancel button
//                    ]
//                )
//            }
//            // Alert for tapping the pass
//            .alert("Pass Details", isPresented: $showingPassDetailsAlert) {
//                // Buttons for the alert
//                Button("OK", role: .cancel) { } // Simple dismissal
//                Button("View More") { print("Navigate to full details...") /* Add navigation */ }
//            } message: {
//                Text("You tapped the pass for \(passData.eventTitle).\nLane: \(passData.value)")
//            }
//        }
//    }
//
//    // Function to simulate updating the data
//    private func updateLaneNumber() {
//        let newLane = Int.random(in: 1...40)
//        // Create a new instance or modify the @State var directly
//        passData.value = String(newLane)
//        print("Lane updated to: \(newLane)")
//    }
//}
//
//// MARK: - Pass View Structure (Mostly Unchanged, receives data)
//struct BowlingPassView: View {
//    let data: PassData // Receive data, don't own it with @State here
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            TopBarView(data: data)
//                .padding(.horizontal)
//                .padding(.top)
//                .padding(.bottom, 8)
//
//            // Basic Image Loading - Consider Kingfisher/AsyncImage for network URLs
//             // Ensure the hero image exists in Assets.xcassets
//             Image(data.heroImageName)
//                 .resizable()
//                 .aspectRatio(contentMode: .fill)
//                 .frame(height: 150)
//                 .clipped()
//                 .accessibilityLabel("Promotional image for the event") // Accessibility for image
//
//            MainInfoView(data: data)
//                .padding()
//
//            Spacer()
//
//            BottomBarView(data: data)
//                .padding(.horizontal)
//                .padding(.bottom)
//        }
//        .background(data.passBackgroundColor)
//        .foregroundColor(data.foregroundColor)
//        .cornerRadius(15)
//        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3) // More distinct shadow
//    }
//}
//
//// MARK: - Helper Subviews (Unchanged Functionally)
//struct TopBarView: View {
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
//                // Use modern Date formatting
//                Text(data.eventTime.formatted(.dateTime.hour().minute()))
//                Text(data.eventTime.formatted(.dateTime.month(.abbreviated).day()))
//            }
//            .font(.subheadline)
//            .accessibilityElement(children: .combine) // Combine date/time accessibility
//            .accessibilityLabel("Event time: \(data.eventTime.formatted(date: .abbreviated, time: .shortened))")
//
//        }
//        .accessibilityElement(children: .contain) // Contains logo, name, date/time
//    }
//}
//
//struct MainInfoView: View {
//    let data: PassData
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) { // Add a little spacing
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
//                .textCase(.uppercase)
//                .padding(.bottom, 20)
//                .accessibilityLabel("Event: \(data.eventTitle)")
//
//            Spacer()
//
//             HStack {
//                 VStack(alignment: .leading) {
//                     Text(data.label)
//                         .font(.caption)
//                         .textCase(.uppercase)
//                         .opacity(0.8)
//                         .accessibilityHidden(true) // Value includes label context
//
//                     Text(data.value)
//                         .font(.title)
//                         .fontWeight(.semibold)
//                 }
//                 .accessibilityElement(children: .combine)
//                 .accessibilityLabel("\(data.label): \(data.value)")
//
//                 Spacer()
//             }
//        }
//        .accessibilityElement(children: .contain) // Contains venue, title, label/value
//    }
//}
//
//struct BottomBarView: View {
//    let data: PassData
//
//    var body: some View {
//        HStack {
//            PassLogoView(systemImageName: data.logoSystemImageName, backgroundColor: data.logoBackgroundColor)
//            Spacer()
//            Image(systemName: "wifi") // Or "dot.radiowaves.right" might be closer to NFC symbol
//                .font(.title2)
//                .fontWeight(.light)
//                .accessibilityLabel("Contactless symbol")
//        }
//        .accessibilityElement(children: .contain) // Contains logo and symbol
//    }
//}
//
//struct PassLogoView: View {
//    let systemImageName: String
//    let backgroundColor: Color
//
//    var body: some View {
//         Image(systemName: systemImageName)
//             .imageScale(.large) // Make logo slightly bigger
//             .foregroundColor(.black.opacity(0.7))
//             .frame(width: 30, height: 30) // Ensure consistent size
//             .padding(5) // Adjust padding if needed
//             .background(backgroundColor)
//             .clipShape(Circle())
//             .accessibilityLabel("Company logo")
//    }
//}
//
//// MARK: - Date Extension Helper (Ensure this exists in your project)
//extension Date {
//    static func from(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date {
//        Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)) ?? Date()
//    }
//}
//
//// MARK: - Preview
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            // .preferredColorScheme(.dark) // Uncomment for dark mode preview
//    }
//}
