//
//  StoreCardView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/21/25.
//

 
import SwiftUI
import UniformTypeIdentifiers // Needed for ShareLink if sharing custom data types

// --- Enhanced Mock Data Structure ---
struct OrderDetails {
    let orderID: String = "FRT-12345-ABC"
    let storeName: String = "Front Door Fruit Stand"
    let storeLocation: String = "Cupertino"
    let pickupStatus: String = "Your basket is ready for pickup."
    let pickupWindow: String = "Today, 2:00 PM - 4:00 PM"
    let storeAddress: String = "1 Infinite Loop, Cupertino, CA 95014"
    let contactPhone: String = "(408) 555-1234"
    let qrCodeData: String // Data encoded in the QR code
    let supportURL: URL? = URL(string: "https://support.apple.com/contact") // Example support URL
    let storeMapQuery: String // For opening in Maps

    // Computed property for sharing text
    var shareableSummary: String {
        """
        Order Details:
        ID: \(orderID)
        Store: \(storeName), \(storeLocation)
        Status: \(pickupStatus)
        Window: \(pickupWindow)
        """
    }

    // Initializer to create derived data
    init() {
        self.qrCodeData = "order:\(orderID);status:ready;store:\(storeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        // Basic map query, can be refined based on Maps URL scheme needs
        self.storeMapQuery = storeAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}

// --- Main App Structure (for running in Xcode) ---
@main
struct StoreCardApp: App {
    var body: some Scene {
        WindowGroup {
            // Usually presented modally, but shown directly here
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

        // Add the rest of the rectangle outline
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()

        return path
    }
}

// --- View for QR Code Detail Sheet ---
struct QRCodeDetailView: View {
    let qrCodeImageName: String
    let qrCodeData: String // Data to copy
    @Environment(\.dismiss) var dismiss // To close the sheet

    // State for copy button feedback
    @State private var copyButtonText: String = "Copy Code Data"
    @State private var copyButtonIcon: String = "doc.on.doc"

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Scan for Pickup").font(.title2).bold()

                Image(qrCodeImageName)
                    .resizable()
                    .interpolation(.none) // Keep QR code sharp
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .accessibilityLabel("Order QR Code")

                Button {
                    // --- Action: Copy QR Data ---
                    UIPasteboard.general.string = qrCodeData
                    print("QR Code Data Copied: \(qrCodeData)")
                    // Provide visual feedback
                    copyButtonText = "Copied!"
                    copyButtonIcon = "checkmark.circle.fill"
                    // Reset after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        copyButtonText = "Copy Code Data"
                        copyButtonIcon = "doc.on.doc"
                    }
                } label: {
                    Label(copyButtonText, systemImage: copyButtonIcon)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                         // Animate the text change slightly
                        .animation(.easeInOut(duration: 0.2), value: copyButtonText)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityHint("Copies the order data associated with the QR code.")
                .disabled(copyButtonText == "Copied!") // Briefly disable after copy

                Spacer() // Push content up
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                         .accessibilityLabel("Close QR Code View")
                }
            }
        }
    }
}

// --- View for Store/Order Info Sheet ---
struct StoreInfoView: View {
    let details: OrderDetails
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL

    // Helper to create map URL
    private var mapURL: URL? {
        URL(string: "maps://?q=\(details.storeMapQuery)")
    }

    // Helper to create phone URL
    private var phoneURL: URL? {
        let cleanedPhone = details.contactPhone.filter("0123456789".contains)
        return URL(string: "tel:\(cleanedPhone)")
    }

    var body: some View {
        NavigationView {
            List {
                Section("Order Details") {
                    InfoRow(label: "Order ID", value: details.orderID, systemImage: "number.square")
                    InfoRow(label: "Status", value: details.pickupStatus, systemImage: "basket")
                    InfoRow(label: "Pickup Window", value: details.pickupWindow, systemImage: "clock")
                }

                Section("Store Information") {
                    InfoRow(label: "Store", value: "\(details.storeName), \(details.storeLocation)", systemImage: "storefront")

                    // Address Row with Link
                    if let url = mapURL {
                        Link(destination: url) {
                            InfoRow(label: "Address", value: details.storeAddress, systemImage: "mappin.and.ellipse", isMultiline: true)
                                .contentShape(Rectangle()) // Make entire row tappable
                        }
                        .buttonStyle(.plain) // Remove default link styling
                        .accessibilityHint("Tap to open address in Maps.")
                    } else {
                        InfoRow(label: "Address", value: details.storeAddress, systemImage: "mappin.and.ellipse", isMultiline: true)
                    }

                    // Phone Row with Link
                    if let url = phoneURL {
                        Link(destination: url) {
                             InfoRow(label: "Phone", value: details.contactPhone, systemImage: "phone.fill")
                                 .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Tap to call the store.")
                    } else {
                         InfoRow(label: "Phone", value: details.contactPhone, systemImage: "phone.fill")
                    }
                }
            }
            .navigationTitle("Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                         .accessibilityLabel("Close Information View")
                }
            }
        }
    }
}

// Enhanced helper view for info rows with optional icons
struct InfoRow: View {
    let label: String
    let value: String
    var systemImage: String? = nil // Optional icon name
    var isMultiline: Bool = false

    var body: some View {
        HStack(alignment: isMultiline ? .top : .center, spacing: 10) {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .foregroundColor(.accentColor) // Use accent color for icons
                    .frame(width: 20, alignment: .center) // Align icons
            } else {
                // Placeholder to maintain alignment if no icon
                 Spacer().frame(width: 20)
            }

            VStack(alignment: .leading) {
                 Text(label)
                     .font(isMultiline ? .headline : .subheadline) // Adjust label font
                     .foregroundColor(.secondary)
                 Text(value)
                     .font(.body)
                    // .multilineTextAlignment(.leading) // Keep value left aligned
                     .foregroundColor(.primary)
                     .fixedSize(horizontal: false, vertical: true) // Allow text wrapping
            }
            Spacer() // Push content to the left
        }
        .padding(.vertical, isMultiline ? 4 : 2) // Adjust vertical padding
    }
}

// --- Main Functional Store Card View ---
struct StoreCardView: View {
    let orderDetails: OrderDetails

    // --- State for Sheet Presentation ---
    @State private var showingInfoSheet = false
    @State private var showingQRCodeSheet = false

    // --- Environment ---
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL

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
                    contentSection
                }
                 // Adjusted background and corner radius application for SerratedEdge
                .background(cardBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius)) // Clip content area
                // Serrated Edge Overlays (Now draw outside the clipped content)
                .overlay(
                    SerratedEdge()
                        .fill(cardBackgroundColor) // Fill instead of stroke for better overlap hide
                        .frame(height: 5) // Match tooth height
                        .offset(y: -5) // Position above top edge
                    , alignment: .top
                )
                .overlay(
                     SerratedEdge()
                        .fill(cardBackgroundColor)
                        .frame(height: 5)
                        .rotationEffect(.degrees(180))
                        .offset(y: 5) // Position below bottom edge
                     , alignment: .bottom
                 )
                .padding() // Add padding around the entire card structure

            }
            .background(Color(.systemGroupedBackground)) // Background for the whole screen
            .navigationBarTitleDisplayMode(.inline) // Keep nav bar space minimal
            .toolbar { toolbarContent } // Use extracted toolbar content
            .sheet(isPresented: $showingQRCodeSheet) {
                 QRCodeDetailView(qrCodeImageName: qrCodeImageName, qrCodeData: orderDetails.qrCodeData)
             }
            .sheet(isPresented: $showingInfoSheet) {
                 StoreInfoView(details: orderDetails)
            }
        }
    }

    // --- Extracted Views for Clarity ---

    private var contentSection: some View {
         VStack(alignment: .leading, spacing: 15) {
             // Header
             HStack {
                 Image(systemName: "basket.fill") // Changed icon
                     .font(.title3)
                     .foregroundColor(textColor)
                 Text(orderDetails.storeName)
                     .font(.headline)
                     .fontWeight(.semibold)
                     .foregroundColor(textColor)
                 Spacer()
             }
             .accessibilityElement(children: .combine)
             .accessibilityLabel("\(orderDetails.storeName)")

             // Main Image
             Image(fruitImageName)
                 .resizable()
                 .aspectRatio(contentMode: .fill)
                 .frame(height: 180)
                 .clipped()
                 .accessibilityHidden(true)

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
                 Image(qrCodeImageName)
                     .resizable()
                     .interpolation(.none) // Keep QR sharp
                     .scaledToFit()
                     .frame(width: 150, height: 150)
                     .background(Color.white) // Ensure contrast for QR code
                     .cornerRadius(8)
                     .onTapGesture { showingQRCodeSheet = true }
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
                     .accessibilityHidden(true)
                 Spacer()
                 Button { showingInfoSheet = true } label: {
                     Image(systemName: "info.circle.fill")
                         .font(.title3)
                         .foregroundColor(textColor)
                 }
                 .accessibilityLabel("More Information")
                 .accessibilityHint("Tap to view order and store details.")
             }
         }
         .padding(cardPadding) // Padding inside the content area
    }

    // --- Extracted Toolbar Content ---
     @ToolbarContentBuilder
     private var toolbarContent: some ToolbarContent {
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
               // --- Action: Share ---
               ShareLink(item: orderDetails.shareableSummary,
                         subject: Text("My Order: \(orderDetails.orderID)"),
                         message: Text("Check out my order details!")) {
                     Label("Share Order", systemImage: "square.and.arrow.up")
               }
                .accessibilityHint("Shares order details using the standard iOS share sheet.")

               // --- Action: Get Help ---
               if let url = orderDetails.supportURL {
                   Button {
                        openURL(url)
                        print("Get Help Tapped - Opening URL: \(url.absoluteString)")
                   } label: {
                        Label("Get Help", systemImage: "questionmark.circle")
                   }
                   .accessibilityHint("Opens the help website.")
               }

                // --- Action: View Order History ---
                Button {
                    print("Navigation Intent: Navigate to Order History Screen")
                    // In a real app, trigger navigation coordinator or change state
                } label: {
                    Label("Order History", systemImage: "list.bullet.rectangle.portrait")
                }
                .accessibilityHint("Navigates to your past orders list (simulated).")

           } label: {
               Image(systemName: "ellipsis.circle.fill")
                    .accessibilityLabel("More Options Menu")
           }
         }
     }
}

// --- Preview Provider ---
struct StoreCardView_Previews: PreviewProvider {
    static var previews: some View {
        StoreCardView(orderDetails: OrderDetails())
            .previewDisplayName("Main Card")

         QRCodeDetailView(qrCodeImageName: "My-meme-heineken", qrCodeData: OrderDetails().qrCodeData)
            .previewDisplayName("QR Code Sheet")

         StoreInfoView(details: OrderDetails())
            .previewDisplayName("Info Sheet")
    }
}
