//
//  StoreCardView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/21/25.
//

import SwiftUI

// --- Mock Data Structure ---
struct OrderDetails {
    let orderID: String = "FRT-12345-ABC"
    let storeName: String = "Front Door Fruit Stand"
    let storeLocation: String = "Cupertino"
    let pickupStatus: String = "Your basket is ready for pickup."
    let pickupWindow: String = "Today, 2:00 PM - 4:00 PM"
    let storeAddress: String = "1 Infinite Loop, Cupertino, CA 95014"
    let contactPhone: String = "(408) 555-1234"
    // Simulate data that might be encoded in the QR code
    let qrCodeData: String = "order:FRT-12345-ABC;status:ready"
}

// --- Main App Structure (for running in Xcode) ---
@main
struct StoreCardApp: App {
    var body: some Scene {
        WindowGroup {
            // Present the StoreCardView, perhaps modally in a real app
            // For this example, we show it directly.
            StoreCardView(orderDetails: OrderDetails())
        }
    }
}

// --- Custom Shape for Serrated Edge (Unchanged) ---
struct SerratedEdge: Shape {
    var toothHeight: CGFloat = 5
    var toothWidth: CGFloat = 10

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let initialOffset = toothWidth / 2.0
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        let numberOfTeeth = Int((rect.width - initialOffset) / toothWidth)

        for i in 0...numberOfTeeth {
            let xBase = rect.minX + initialOffset + CGFloat(i) * toothWidth
            let point1 = CGPoint(x: xBase - toothWidth / 2, y: rect.minY + toothHeight)
            let point2 = CGPoint(x: xBase + toothWidth / 2, y: rect.minY + toothHeight)
            let point3 = CGPoint(x: xBase + toothWidth / 2, y: rect.minY)

            if point1.x <= rect.maxX && point2.x <= rect.maxX {
                 path.addLine(to: point1)
                 path.addLine(to: point2)
                 if point3.x <= rect.maxX { path.addLine(to: point3) }
                 else {
                    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + toothHeight))
                    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                 }
            } else if point1.x <= rect.maxX {
                 path.addLine(to: point1)
                 path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + toothHeight))
                 path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                 break
            } else {
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                break
            }
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

// --- View for QR Code Detail Sheet ---
struct QRCodeDetailView: View {
    let qrCodeImageName: String
    let qrCodeData: String // Data to copy
    @Environment(\.dismiss) var dismiss // To close the sheet

    var body: some View {
        NavigationView { // Add Nav Bar for title and close button
            VStack(spacing: 30) {
                Text("Scan for Pickup").font(.title2).bold()

                Image(qrCodeImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250) // Larger QR code
                    .accessibilityLabel("Order QR Code")

                Button {
                    // --- Action: Copy QR Data ---
                    UIPasteboard.general.string = qrCodeData
                    print("QR Code Data Copied: \(qrCodeData)")
                    // Maybe show brief confirmation animation/message here
                } label: {
                    Label("Copy Code Data", systemImage: "doc.on.doc")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityHint("Copies the order data associated with the QR code.")

                Spacer() // Push content up
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

// --- View for Store/Order Info Sheet ---
struct StoreInfoView: View {
    let details: OrderDetails
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List { // Use List for scrollable, structured info
                Section("Order Details") {
                    InfoRow(label: "Order ID", value: details.orderID)
                    InfoRow(label: "Status", value: details.pickupStatus)
                    InfoRow(label: "Pickup Window", value: details.pickupWindow)
                }

                Section("Store Information") {
                    InfoRow(label: "Store", value: "\(details.storeName), \(details.storeLocation)")
                    InfoRow(label: "Address", value: details.storeAddress, isMultiline: true)
                    InfoRow(label: "Phone", value: details.contactPhone)
                     // Make phone tappable
                     Button {
                         if let url = URL(string: "tel:\(details.contactPhone.filter("0123456789".contains))") {
                             UIApplication.shared.open(url)
                             print("Attempting to call: \(url.absoluteString)")
                         }
                     } label : {
                         Label("Call Store", systemImage: "phone.fill")
                     }
                     .accessibilityHint("Opens the phone app to call the store.")
                }
            }
            .navigationTitle("Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

// Helper view for info rows
struct InfoRow: View {
    let label: String
    let value: String
    var isMultiline: Bool = false

    var body: some View {
        HStack(alignment: isMultiline ? .top : .center) {
            Text(label)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
                .multilineTextAlignment(.trailing)
                .foregroundColor(.primary)
        }
    }
}

// --- Main Functional Store Card View ---
struct StoreCardView: View {
    let orderDetails: OrderDetails

    // --- State for Sheet Presentation ---
    @State private var showingInfoSheet = false
    @State private var showingQRCodeSheet = false

    // --- Environment for Dismissing ---
    @Environment(\.dismiss) var dismiss

    // --- Configuration (Constants) ---
    let cardBackgroundColor = Color.blue
    let textColor = Color.white
    let cardPadding: CGFloat = 20
    let cornerRadius: CGFloat = 15
    let fruitImageName = "My-meme-orange_2" // ** REPLACE ASSET **
    let qrCodeImageName = "My-meme-heineken"       // ** REPLACE ASSET **

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // --- Card Content ---
                    VStack(alignment: .leading, spacing: 15) {
                        // Header
                        HStack {
                            Image(systemName: "figure.walk")
                                .font(.title2)
                                .foregroundColor(textColor)
                            Text(orderDetails.storeName)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(textColor)
                            Spacer()
                        }
                        .accessibilityElement(children: .combine) // Combine for Accessibility
                        .accessibilityLabel("\(orderDetails.storeName)")

                        // Main Image
                        Image(fruitImageName) // ** Replace with your image asset **
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                            .accessibilityHidden(true) // Decorative

                        // Info Text
                        VStack(alignment: .leading, spacing: 4) {
                           Text("\(orderDetails.storeName), \(orderDetails.storeLocation)")
                                .font(.subheadline)
                                .foregroundColor(textColor.opacity(0.9))
                           Text(orderDetails.pickupStatus)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(textColor)
                        }
                        .padding(.top, 5)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(orderDetails.storeName), \(orderDetails.storeLocation). \(orderDetails.pickupStatus)")

                        // QR Code Section (Interactive)
                        HStack {
                            Spacer()
                            Image(qrCodeImageName) // ** Replace with your QR code image asset **
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .onTapGesture {
                                    // --- Action: Show QR Code Sheet ---
                                    showingQRCodeSheet = true
                                }
                                .accessibilityLabel("Order QR Code")
                                .accessibilityHint("Tap to view larger QR code")
                            Spacer()
                        }
                        .padding(.vertical, 10)

                        // Footer
                        HStack {
                            Image(systemName: "figure.stand")
                                .font(.title3)
                                .foregroundColor(textColor)
                                .accessibilityHidden(true) // Likely decorative
                            Spacer()
                            Button {
                                // --- Action: Show Info Sheet ---
                                showingInfoSheet = true
                            } label: {
                                Image(systemName: "info.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(textColor)
                            }
                            .accessibilityLabel("More Information")
                            .accessibilityHint("Tap to view order and store details.")
                        }
                    }
                    .padding(cardPadding)
                }
                .background(cardBackgroundColor)
                .cornerRadius(cornerRadius)
                // Serrated Edge Overlays (Unchanged)
                .overlay(
                    SerratedEdge().stroke(cardBackgroundColor, lineWidth: 1).frame(height: 5).offset(y: -cornerRadius), alignment: .top
                )
                .overlay(
                     SerratedEdge().stroke(cardBackgroundColor, lineWidth: 1).frame(height: 5).rotationEffect(.degrees(180)).offset(y: cornerRadius), alignment: .bottom
                 )
                .padding(.horizontal)
                .padding(.top, 5)

            }
            .background(Color(.systemGroupedBackground))
           // .navigationTitle("Store Card") // Title usually set by the presenting view
           // .navigationBarTitleDisplayMode(.inline)
            // --- Toolbar Items ---
            .toolbar {
                // Leading Item: Done Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        // --- Action: Dismiss View ---
                        dismiss()
                        print("Done tapped - Dismissing View")
                    }
                    .accessibilityHint("Closes this card view.")
                }
                // Trailing Item: Ellipsis Button with Menu
                ToolbarItem(placement: .navigationBarTrailing) {
                  Menu {
                      Button {
                           // --- Action: Share ---
                           print("Share Tapped (Implement sharing logic)")
                           // Example: Use UIActivityViewController or ShareLink
                      } label: {
                           Label("Share", systemImage: "square.and.arrow.up")
                      }

                      Button {
                          // --- Action: Get Help ---
                           print("Get Help Tapped (Implement navigation to help/support)")
                           // Example: Navigate to a support screen or open a URL
                      } label: {
                           Label("Get Help", systemImage: "questionmark.circle")
                      }

                       Button {
                           // --- Action: View Order History ---
                           print("View Order History Tapped (Implement navigation)")
                            // Example: Navigate to an order history list
                      } label: {
                           Label("Order History", systemImage: "list.bullet.rectangle.portrait")
                      }

                  } label: {
                      Image(systemName: "ellipsis.circle.fill")
                           .accessibilityLabel("More Options")
                  }
                }
            }
            // --- Sheet Modifiers ---
            .sheet(isPresented: $showingQRCodeSheet) {
                 QRCodeDetailView(qrCodeImageName: qrCodeImageName, qrCodeData: orderDetails.qrCodeData)
             }
            .sheet(isPresented: $showingInfoSheet) {
                 StoreInfoView(details: orderDetails)
            }
        }
    }
}

// --- Preview Provider ---
struct StoreCardView_Previews: PreviewProvider {
    static var previews: some View {
        StoreCardView(orderDetails: OrderDetails()) // Use mock data for preview
            // Add previews for sheet views as well for easier development
            .previewDisplayName("Main Card")

         QRCodeDetailView(qrCodeImageName: "My-meme-heineken", qrCodeData: "preview-data")
            .previewDisplayName("QR Code Sheet")

         StoreInfoView(details: OrderDetails())
            .previewDisplayName("Info Sheet")

    }
}
