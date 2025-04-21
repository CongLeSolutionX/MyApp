////
////  BoardingPassView.swift
////  MyApp
////
////  Created by Cong Le on 4/21/25.
////
//
//import SwiftUI
//
//// Reusable view for displaying labeled information
//struct InfoItem: View {
//    let label: String
//    let value: String
//    var alignment: HorizontalAlignment = .leading
//
//    var body: some View {
//        VStack(alignment: alignment) {
//            Text(label)
//                .font(.caption)
//                .foregroundStyle(.white.opacity(0.8))
//                .textCase(.uppercase)
//            Text(value)
//                .font(.headline)
//                .fontWeight(.semibold)
//                .foregroundStyle(.white)
//        }
//    }
//}
//
//// Reusable view for displaying airport information
//struct AirportInfo: View {
//    let city: String
//    let code: String
//    var alignment: HorizontalAlignment = .leading
//
//    var body: some View {
//        VStack(alignment: alignment) {
//            Text(city)
//                .font(.subheadline)
//                .foregroundStyle(.white.opacity(0.9))
//            Text(code)
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .foregroundStyle(.white)
//        }
//    }
//}
//
//// The main Boarding Pass View
//struct BoardingPassView: View {
//    var body: some View {
//        VStack(spacing: 20) {
//            // Top Info: Logo, Status, Gate
//            HStack {
//                Image(systemName: "airplane.circle.fill") // Placeholder logo
//                    .font(.title)
//                    .foregroundStyle(.white)
//
//                Spacer()
//
//                InfoItem(label: "Status", value: "On Time", alignment: .trailing)
//                InfoItem(label: "Gate", value: "62", alignment: .trailing)
//                    .padding(.leading, 5) // Add slight space between Status and Gate
//
//            }
//            .padding(.horizontal)
//            .padding(.top) // Add padding only at the top inside edge
//
//            // Flight Route: Origin -> Destination
//            HStack {
//                AirportInfo(city: "San Francisco", code: "SFO")
//                Spacer()
//                Image(systemName: "airplane")
//                    .font(.largeTitle)
//                    .rotationEffect(.degrees(90)) // Rotate airplane to point right
//                    .foregroundStyle(.white)
//                Spacer()
//                AirportInfo(city: "New York", code: "LGA", alignment: .trailing)
//            }
//            .padding(.horizontal)
//
//            // Flight Details: Scheduled, Flight, Seat, Group
//            HStack(alignment: .top) {
//                InfoItem(label: "Scheduled", value: "2:40")
//                Spacer()
//                InfoItem(label: "Flight", value: "AP 2214", alignment: .center) // Center align flight
//                Spacer()
//                InfoItem(label: "Seat", value: "33A", alignment: .trailing)
//                Spacer()
//                InfoItem(label: "Group", value: "B", alignment: .trailing)
//            }
//            .padding(.horizontal)
//
//            // Passenger Name
//            InfoItem(label: "Passenger", value: "LIZ CHETELAT", alignment: .leading)
//                .frame(maxWidth: .infinity, alignment: .leading) // Ensure it takes full width
//                .padding(.horizontal)
//
//            // QR Code Section
//            VStack(spacing: 5) {
//                // Placeholder for QR Code
//                Image(systemName: "qrcode")
//                      .resizable()
//                      .interpolation(.none) // Keep pixels sharp
//                      .scaledToFit()
//                      .foregroundStyle(.black)
//                      .frame(width: 150, height: 150) // Adjust size as needed
//
//                Text("57801237606617")
//                    .font(.caption)
//                    .foregroundStyle(.black)
//            }
//            .padding()
//            .background(.white)
//            .cornerRadius(10)
//            .padding(.horizontal) // Padding around the white QR code box
//
//            // Bottom Icons: Wallet, NFC
//            HStack {
//                Image(systemName: "wallet.pass.fill")
//                    .font(.title2)
//                    .foregroundStyle(.white)
//                Spacer()
//                Image(systemName: "wave.3.right.circle.fill")
//                    .font(.title2)
//                    .foregroundStyle(.white)
//            }
//            .padding(.horizontal)
//            .padding(.bottom) // Add padding only at the bottom inside edge
//
//        }
//        .background(.blue) // Main background color
//        .clipShape(RoundedRectangle(cornerRadius: 15)) // Rounded corners for the pass
//    }
//}
//
//// Container View with Navigation
//struct ContentView: View {
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // Background color matching the screenshot's outer area
//                Color(uiColor: .systemGray6) // or .clear if it should be transparent
//                    .ignoresSafeArea()
//
//                VStack {
//                    BoardingPassView()
//                        .padding() // Padding around the entire boarding pass
//                    Spacer() // Push the pass towards the top
//                }
//            }
//            .navigationBarTitleDisplayMode(.inline) // Keep title area compact
//            .navigationBarItems(
//                leading: Button("Done") {
//                    // Action for Done button
//                    print("Done tapped")
//                },
//                trailing: Button {
//                    // Action for Ellipsis button
//                    print("Ellipsis tapped")
//                } label: {
//                    Image(systemName: "ellipsis.circle")
//                }
//            )
//            // No title shown in the nav bar itself in the screenshot
//            // .navigationTitle("Boarding Pass")
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
