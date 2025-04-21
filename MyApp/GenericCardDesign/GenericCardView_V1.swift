//
//  GenericCardView_V1.swift
//  MyApp
//
//  Created by Cong Le on 4/21/25.
//

import SwiftUI

// Define custom colors matching the design
extension Color {
    static let passYellow = Color(red: 250/255, green: 204/255, blue: 21/255) // Approx #FACC15
    static let passDarkGray = Color(red: 55/255, green: 65/255, blue: 81/255) // Approx #374151
}

struct GenericPassView: View {
    var body: some View {
        // Main container mimicking the navigation bar setup shown
        NavigationView {
             ZStack(alignment: .top) {
                 // Background for the view behind the pass
                 Color(UIColor.systemGroupedBackground).ignoresSafeArea()

                 // The Pass Card
                 VStack(spacing: 0) {
                     // Header Section
                     HeaderView()

                     // Logo/Title Section
                     LogoTitleView()

                     // Main Info Section (includes Member Info and Barcode)
                     // This VStack takes up remaining space and holds yellow background content
                     VStack {
                         MemberInfoView()
                         Spacer() // Pushes barcode towards the bottom of this section
                         BarcodeView()
                         Spacer() // Add some space below barcode if needed visually
                     }
                     .frame(maxWidth: .infinity)
                     .background(Color.passYellow) // Yellow background for the main body
                     .overlay(alignment: .bottom) {
                         // Bottom Icons Overlay
                         BottomIconsView()
                             .padding(.horizontal)
                             .padding(.bottom, 10) // Adjust padding as needed
                     }
                 }
                 .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                 .padding() // Padding around the entire card
                 .shadow(radius: 5) // Optional shadow for depth
             }
            .navigationTitle("Generic Pass") // Title as seen vaguely above
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        // Action for Done button
                        print("Done tapped")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Action for ellipsis button
                        print("More options tapped")
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}

// MARK: - Subviews for Card Sections

struct HeaderView: View {
    var body: some View {
        HStack {
            Image(systemName: "figure.strengthtraining.traditional") // Placeholder dumbbell icon
                .font(.title2)
                .foregroundColor(.passDarkGray)

            Text("Lift It")
                .font(.headline)
                .foregroundColor(.passDarkGray)

            Spacer()

            VStack(alignment: .trailing) {
                Text("LEVEL")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.passDarkGray.opacity(0.8))
                Text("Premier")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.passDarkGray)
            }
        }
        .padding()
        .background(Color.passYellow) // Header has yellow background
    }
}

struct LogoTitleView: View {
    var body: some View {
        HStack {
            // Placeholder for the custom crossed dumbbell logo
            Image(systemName: "dumbbell.fill") // Using SF Symbol as placeholder
                .font(.system(size: 40))
                .rotationEffect(.degrees(-45))
                .overlay(
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 40))
                        .rotationEffect(.degrees(45))
                        .padding(.leading, 5) // Adjust overlap
                )
                .foregroundColor(.passYellow)
                .padding(.trailing, 5)

            VStack(alignment: .leading) {
                Text("LIFT IT")
                    .font(.headline)
                Text("MEMBERSHIP CARD")
                    .font(.subheadline.weight(.medium)) // Slightly lighter than headline
            }
            .foregroundColor(.passYellow) // Text color on dark background

            Spacer() // Pushes content to the left
        }
        .padding(.vertical, 20)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(Color.passDarkGray) // Dark gray background
    }
}

struct MemberInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            InfoField(label: "POLICY HOLDER", value: "Liz Chetelat")
            InfoField(label: "MEMBER ID", value: "235 933 7415")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading) // Ensure it takes full width and align left
    }
}

struct InfoField: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundColor(.passDarkGray.opacity(0.8))
            Text(value)
                .font(.title2.weight(.medium))
                .foregroundColor(.passDarkGray)
        }
    }
}

struct BarcodeView: View {
    var body: some View {
        VStack {
            // Placeholder for the actual PDF417 barcode image
            // In a real app, you'd generate this using CoreImage or a third-party lib
            Image(systemName: "barcode") // Using SF Symbol as placeholder
                .resizable()
                .scaledToFit()
                .frame(height: 60) // Adjust height as needed
                .padding(.vertical, 5)

            Text("57801237606617")
                .font(.caption)
                .foregroundColor(.black)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 30) // Padding to center it horizontally
        .padding(.bottom, 30) // Space above the bottom icons
    }
}

struct BottomIconsView: View {
    var body: some View {
        HStack {
            Image(systemName: "qrcode.viewfinder") // Placeholder for QR/expand icon
                .font(.title2)
                .foregroundColor(.passDarkGray)

            Spacer()

            Image(systemName: "wifi") // Placeholder for contactless icon
                .font(.title2)
                 .rotationEffect(.degrees(90)) // Rotate to match appearance
                .foregroundColor(.passDarkGray)
        }
        .foregroundColor(.passDarkGray.opacity(0.9))
    }
}

// MARK: - Preview

struct GenericPassView_Previews: PreviewProvider {
    static var previews: some View {
        GenericPassView()
    }
}
