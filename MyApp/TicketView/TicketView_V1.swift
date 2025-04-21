////
////  TicketView.swift
////  MyApp
////
////  Created by Cong Le on 4/21/25.
////
//
//import SwiftUI
//
//// MARK: - Data Model
//struct PassData {
//    let companyName: String
//    let eventTime: Date
//    let heroImageName: String // Use an image name from your asset catalog
//    let venueName: String
//    let eventTitle: String
//    let label: String
//    let value: String
//    let logoSystemImageName: String // SF Symbol for placeholder logo
//    let logoBackgroundColor: Color
//    let passBackgroundColor: Color = Color(red: 235/255, green: 110/255, blue: 75/255) // Coral/Orange
//    let foregroundColor: Color = .white
//}
//
//// MARK: - Main Content View
//struct ContentView: View {
//    // Sample Data
//    let samplePassData = PassData(
//        companyName: "Company Name",
//        eventTime: Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Calendar.current.date(from: DateComponents(year: 2024, month: 8, day: 22))!)!, // Example Date: Aug 22, 5:00 PM
//        heroImageName: "bowling-hero", // *** Replace with your actual image asset name ***
//        venueName: "BOWL-A-RAMA ALLEY",
//        eventTitle: "BOWLING BONANZA",
//        label: "Lane", // Changed label for context
//        value: "33",
//        logoSystemImageName: "sportscourt.fill", // Placeholder SF Symbol
//        logoBackgroundColor: Color(white: 0.95) // Off-white/beige background for logo
//    )
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // Background for the view behind the pass (optional, often gray or black in Wallet)
//                Color(.systemGroupedBackground) // Or Color.black
//                    .ignoresSafeArea()
//
//                BowlingPassView(data: samplePassData)
//                    .padding() // Add padding around the pass
//            }
//            .navigationTitle("Ticket") // Set the title
//            .navigationBarTitleDisplayMode(.inline) // Make title smaller, stays in place
//            .navigationBarItems(
//                leading: Button("Done") {
//                    // Action for Done button
//                    print("Done tapped")
//                },
//                trailing: Button {
//                    // Action for Ellipsis button
//                    print("More options tapped")
//                } label: {
//                    Image(systemName: "ellipsis.circle.fill")
//                        .imageScale(.large) // Make icon slightly larger
//                        .foregroundColor(.primary) // Use default color, adapts to light/dark mode
//                }
//            )
//        }
//    }
//}
//
//// MARK: - Pass View Structure
//struct BowlingPassView: View {
//    let data: PassData
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) { // No automatic spacing between sections
//            TopBarView(data: data)
//                .padding(.horizontal)
//                .padding(.top)
//                .padding(.bottom, 8) // Add slight space before image
//
//            Image(data.heroImageName)
//                .resizable()
//                .aspectRatio(contentMode: .fill) // Fill the width, potentially crop vertically
//                .frame(height: 150) // Fixed height for the image area
//                .clipped() // Prevent image from overflowing
//
//            MainInfoView(data: data)
//                .padding() // Padding inside the main info section
//
//            Spacer() // Pushes the bottom bar down
//
//            BottomBarView(data: data)
//                .padding(.horizontal)
//                .padding(.bottom) // Padding at the very bottom of the pass
//        }
//        .background(data.passBackgroundColor)
//        .foregroundColor(data.foregroundColor) // Default text color for the pass
//        .cornerRadius(15) // Rounded corners for the pass
//        .shadow(radius: 5) /// Optional shadow like Wallet passes
//    }
//}
//
//// MARK: - Helper Subviews
//struct TopBarView: View {
//    let data: PassData
//
//    var body: some View {
//        HStack(alignment: .center) {
//            PassLogoView(systemImageName: data.logoSystemImageName, backgroundColor: data.logoBackgroundColor)
//            Text(data.companyName)
//                .font(.headline)
//                .fontWeight(.medium)
//
//            Spacer()
//
//            VStack(alignment: .trailing) {
//                Text(data.eventTime, style: .time) // Format time (e.g., 5:00 PM)
//                Text(data.eventTime.formatted(.dateTime.month(.wide).day())) // Format date (e.g., August 22)
//            }
//            .font(.subheadline)
//        }
//    }
//}
//
//struct MainInfoView: View {
//    let data: PassData
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(data.venueName)
//                .font(.caption)
//                .fontWeight(.medium)
//                .textCase(.uppercase)
//                .opacity(0.8) // Slightly less prominent
//
//            Text(data.eventTitle)
//                .font(.title2)
//                .fontWeight(.bold)
//                .textCase(.uppercase)
//                .padding(.bottom, 20) // Space below title
//
//            Spacer() // Pushes Label/Value down within this section
//
//            HStack {
//                 VStack(alignment: .leading) {
//                     Text(data.label)
//                         .font(.caption)
//                         .textCase(.uppercase)
//                         .opacity(0.8)
//                     Text(data.value)
//                         .font(.title) // Larger font for the value
//                         .fontWeight(.semibold)
//                 }
//                 Spacer() // Allow other elements if needed later
//             }
//        }
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
//            Image(systemName: "wifi") // SF Symbol for wireless/NFC
//                .font(.title2)
//                .fontWeight(.light)
//        }
//    }
//}
//
//struct PassLogoView: View {
//    let systemImageName: String
//    let backgroundColor: Color
//
//    var body: some View {
//         Image(systemName: systemImageName)
//             .foregroundColor(.black.opacity(0.6)) // Icon color inside the circle
//             .padding(8)
//             .background(backgroundColor) // Background color of the circle
//             .clipShape(Circle())
//    }
//}
//
//// MARK: - Preview
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            // Optional: Preview in dark mode
//            // .preferredColorScheme(.dark)
//    }
//}
//
//// MARK: - Date Extension Helper (Optional but Recommended)
//// If you don't have a date extension elsewhere
//extension Date {
//    // Example function to set a specific time for preview data easily
//    static func from(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date {
//        Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)) ?? Date()
//    }
//}
//
//// To run this code:
//// 1. Create image asset named "bowling-hero" in your Assets.xcassets or replace the name.
//// 2. Ensure you have a SwiftUI App lifecycle (`@main App` struct).
//// 3. Instantiate `ContentView()` in your App struct's body.
