//
//  GenericCardView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/21/25.
//

import SwiftUI

// Data structure for the membership pass
struct MembershipPassData: Identifiable {
    let id = UUID() // Conformance to Identifiable for sheets/lists if needed
    let holderName: String
    let memberId: String
    let barcodeData: String // The string data to encode in the barcode/QR
    let level: String
    let organizationName: String = "CongLeSolutionX"
    let cardTitle: String = "MEMBERSHIP CARD"

    // Mock data instance
    static let mock = MembershipPassData(
        holderName: "Liz Chetelat",
        memberId: "235 933 7415",
        barcodeData: "57801237606617", // Use the actual number for encoding
        level: "Premier"
    )
}

import UIKit
import CoreImage.CIFilterBuiltins // Easier filter access

// Utility functions to generate codes
enum CodeGenerator {
    static func generateBarcode(from string: String) -> UIImage? {
        let data = string.data(using: .ascii)
        let filter = CIFilter.pdf417BarcodeGenerator()
        filter.message = data ?? Data()
        // You might need to adjust correction level or other params for PDF417
        // filter.correctionLevel = ... // Example if available

        guard let outputImage = filter.outputImage else { return nil }

        // Scale up the barcode for clarity
        let scaleX = CGFloat(10)
        let scaleY = CGFloat(5) // PDF417 is wider than tall
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        let context = CIContext()
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    static func generateQRCode(from string: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        // You can adjust correction level: L, M, Q, H
        filter.correctionLevel = "M" // Medium correction

        guard let outputImage = filter.outputImage else { return nil }

        // Scale up the QR code for clarity
        let scale: CGFloat = 10
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        let context = CIContext()
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

import UIKit

// Helper to manage screen brightness temporarily
class BrightnessManager {
    private var originalBrightness: CGFloat = UIScreen.main.brightness

    func maximizeBrightness() {
        originalBrightness = UIScreen.main.brightness // Store current brightness
        UIScreen.main.brightness = 1.0 // Max brightness
        print("Brightness maximized")
    }

    func restoreBrightness() {
        UIScreen.main.brightness = originalBrightness
        print("Brightness restored to \(originalBrightness)")
    }
}

import SwiftUI

// Define custom colors matching the design (same as before)
extension Color {
    static let passYellow = Color(red: 250/255, green: 204/255, blue: 21/255)
    static let passDarkGray = Color(red: 55/255, green: 65/255, blue: 81/255)
}

// MARK: - Main Pass View

struct GenericPassView: View {
    // Use mock data for the pass
    let passData = MembershipPassData.mock

    // Environment for dismissing the view (if presented modally)
    @Environment(\.presentationMode) var presentationMode

    // State variables for managing modals and alerts
    @State private var showingOptionsSheet = false
    @State private var showingQRCodeSheet = false
    @State private var showingEnlargedBarcode = false
    @State private var showingContactlessInfo = false

    // Instance of the brightness manager
    private let brightnessManager = BrightnessManager()

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    HeaderView(
                        orgName: passData.organizationName,
                        level: passData.level
                    )

                    LogoTitleView(
                        orgName: passData.organizationName,
                        cardTitle: passData.cardTitle
                    )

                    VStack {
                        MemberInfoView(
                            name: passData.holderName,
                            memberId: passData.memberId
                        )

                        Spacer()

                        BarcodeView(
                            barcodeNumber: passData.barcodeData,
                            barcodeImage: CodeGenerator.generateBarcode(from: passData.barcodeData),
                            onTap: { // Closure to handle tap
                                brightnessManager.maximizeBrightness()
                                showingEnlargedBarcode = true
                            }
                        )

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Takes available space
                    .background(Color.passYellow)
                    .overlay(alignment: .bottom) {
                        BottomIconsView(
                            onQRTap: { showingQRCodeSheet = true },
                            onContactlessTap: { showingContactlessInfo = true }
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .padding()
                .shadow(radius: 5)
            }
            .navigationTitle("Membership Pass") // More specific title
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        print("Done tapped - Dismissing view")
                        presentationMode.wrappedValue.dismiss() // Dismiss if modal
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        print("Ellipsis tapped - Showing options")
                        showingOptionsSheet = true
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            // --- Modifiers for Sheets and Alerts ---
            .actionSheet(isPresented: $showingOptionsSheet) {
                ActionSheet(
                    title: Text("Pass Options"),
                    message: Text("Select an action for this pass."),
                    buttons: [
                        .default(Text("Share Pass")) { print("Share tapped") /* Add sharing logic */ },
                        .destructive(Text("Remove Pass")) { print("Remove tapped") /* Add removal logic */ },
                        .default(Text("Report an Issue")) { print("Report tapped") /* Add reporting logic */ },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showingQRCodeSheet) {
                // Present the QR Code View
                QRCodeSheetView(qrCodeData: passData.barcodeData)
            }
            .sheet(isPresented: $showingEnlargedBarcode, onDismiss: {
                // Restore brightness when the sheet is dismissed
                brightnessManager.restoreBrightness()
            }) {
                // Present the Enlarged Barcode View
                EnlargedBarcodeView(
                    barcodeNumber: passData.barcodeData,
                    barcodeImage: CodeGenerator.generateBarcode(from: passData.barcodeData)
                )
            }
            .alert("Contactless Payment", isPresented: $showingContactlessInfo) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("This pass can be used for contactless entry where available. Hold your device near the reader.")
            }
            .onDisappear {
                // Ensure brightness is restored if the entire view disappears
                // while the barcode sheet might be up (though less likely with modal presentation)
                brightnessManager.restoreBrightness()
             }
        }
    }
}

// MARK: - Updated Subviews

struct HeaderView: View {
    let orgName: String
    let level: String

    var body: some View {
        HStack {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.title2)
                .foregroundColor(.passDarkGray)

            Text(orgName) // Use data
                .font(.headline)
                .foregroundColor(.passDarkGray)

            Spacer()

            VStack(alignment: .trailing) {
                Text("LEVEL")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.passDarkGray.opacity(0.8))
                Text(level) // Use data
                    .font(.title3.weight(.bold))
                    .foregroundColor(.passDarkGray)
            }
        }
        .padding()
        .background(Color.passYellow)
    }
}

struct LogoTitleView: View {
    let orgName: String
    let cardTitle: String

    var body: some View {
        HStack {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 40))
                .rotationEffect(.degrees(-45))
                .overlay(
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 40))
                        .rotationEffect(.degrees(45))
                        .padding(.leading, 5)
                )
                .foregroundColor(.passYellow)
                .padding(.trailing, 5)

            VStack(alignment: .leading) {
                Text(orgName.uppercased()) // Use data
                    .font(.headline)
                Text(cardTitle) // Use data
                    .font(.subheadline.weight(.medium))
            }
            .foregroundColor(.passYellow)

            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(Color.passDarkGray)
    }
}

struct MemberInfoView: View {
    let name: String
    let memberId: String

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            InfoField(label: "POLICY HOLDER", value: name) // Use data
            InfoField(label: "MEMBER ID", value: memberId) // Use data
        }
        .padding([.top, .leading, .trailing]) // Add top padding
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct InfoField: View { // No changes needed here
    let label: String
    let value: String
    // ... body remains the same
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
    let barcodeNumber: String
    let barcodeImage: UIImage?
    let onTap: () -> Void // Closure for tap action

    var body: some View {
        VStack {
            if let barcodeImg = barcodeImage {
                Image(uiImage: barcodeImg)
                    .interpolation(.none) // Keep pixels sharp
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .padding(.vertical, 5)
            } else {
                // Fallback if image generation fails
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .frame(height: 60)
                 Text("Error generating barcode")
                     .font(.caption)
                     .foregroundColor(.red)
            }

            Text(barcodeNumber)
                .font(.caption)
                .foregroundColor(.black)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 30)
        .padding(.bottom, 20) // Adjust spacing
        .onTapGesture {
            print("Barcode tapped")
            onTap() // Trigger the closure passed from parent
        }
    }
}

struct BottomIconsView: View {
    let onQRTap: () -> Void
    let onContactlessTap: () -> Void

    var body: some View {
        HStack {
            Button(action: onQRTap) { // Make icon a button
                Image(systemName: "qrcode.viewfinder")
                    .font(.title2)
            }

            Spacer()

            Button(action: onContactlessTap) { // Make icon a button
                Image(systemName: "wifi")
                    .font(.title2)
                    .rotationEffect(.degrees(90))
            }
        }
        .foregroundColor(.passDarkGray.opacity(0.9)) // Button label color
    }
}

// MARK: - New Views for Sheets

struct QRCodeSheetView: View {
    let qrCodeData: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView { // Add nav bar for a title and done button
             VStack {
                 Text("Scan QR Code")
                     .font(.title2).padding(.top)

                 if let qrImage = CodeGenerator.generateQRCode(from: qrCodeData) {
                     Image(uiImage: qrImage)
                         .interpolation(.none)
                         .resizable()
                         .scaledToFit()
                         .padding(30) // More padding around QR
                 } else {
                      Text("Error generating QR Code")
                         .foregroundColor(.red)
                         .padding()
                 }
                 Spacer()
             }
             .navigationBarItems(trailing: Button("Done") {
                 presentationMode.wrappedValue.dismiss()
             })
             .navigationBarTitleDisplayMode(.inline)
         }
    }
}

struct EnlargedBarcodeView: View {
    let barcodeNumber: String
    let barcodeImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
         NavigationView { // Add nav bar for a title and done button
             VStack {
                 Spacer() // Push barcode down slightly

                 if let barcodeImg = barcodeImage {
                     Image(uiImage: barcodeImg)
                         .interpolation(.none)
                         .resizable()
                         .scaledToFit()
                         .frame(width: UIScreen.main.bounds.width * 0.9) // Make it wide
                         .padding(.vertical, 20)
                 } else {
                     Text("Error generating barcode")
                         .foregroundColor(.red)
                         .padding()
                 }

                 Text(barcodeNumber)
                     .font(.title3) // Larger font for number
                     .padding(.bottom)

                 Spacer() // Push barcode up slightly
             }
             .frame(maxWidth: .infinity, maxHeight: .infinity)
             .background(Color.white) // White background for max contrast
             .edgesIgnoringSafeArea(.bottom) // Extend white bg down
             .navigationBarItems(trailing: Button("Done") {
                  presentationMode.wrappedValue.dismiss()
              })
             .navigationBarTitle("Scan Barcode", displayMode: .inline)
         }
    }
}

// MARK: - Preview

struct GenericPassView_Previews: PreviewProvider {
    static var previews: some View {
        GenericPassView()
    }
}
