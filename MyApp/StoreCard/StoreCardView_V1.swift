////
////  StoreCardView.swift
////  MyApp
////
////  Created by Cong Le on 4/21/25.
////
//
//import SwiftUI
//
//// Main App Structure (for running in Xcode)
//@main
//struct StoreCardApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
//
//// Custom Shape for the Serrated Edge
//struct SerratedEdge: Shape {
//    var toothHeight: CGFloat = 5
//    var toothWidth: CGFloat = 10
//
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        
//        // Start slightly offset to center the pattern visually
//        let initialOffset = toothWidth / 2.0
//        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
//        
//        // Calculate number of teeth, adjusting for the initial offset
//        let numberOfTeeth = Int((rect.width - initialOffset) / toothWidth)
//
//        // Draw teeth from left to right along the top edge
//        for i in 0...numberOfTeeth {
//            let xBase = rect.minX + initialOffset + CGFloat(i) * toothWidth
//            
//            // Point down
//            let point1 = CGPoint(x: xBase - toothWidth / 2, y: rect.minY + toothHeight)
//            // Point across bottom of tooth
//            let point2 = CGPoint(x: xBase + toothWidth / 2, y: rect.minY + toothHeight)
//            // Point back up to top edge
//            let point3 = CGPoint(x: xBase + toothWidth / 2, y: rect.minY)
//            
//            // Ensure we don't draw past the rect boundary
//            if point1.x <= rect.maxX && point2.x <= rect.maxX {
//                 path.addLine(to: point1)
//                 path.addLine(to: point2)
//                 if point3.x <= rect.maxX {
//                    path.addLine(to: point3)
//                 } else {
//                    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + toothHeight))
//                    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
//                 }
//            } else if point1.x <= rect.maxX {
//                 path.addLine(to: point1)
//                 path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + toothHeight))
//                 path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
//                 break // Exit loop as we reached the end
//            } else {
//                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
//                break // Exit loop
//            }
//        }
//        // Ensure path closes correctly at the right edge
//        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
//
//        // Add lines for the other sides to make it usable for overlay/masking
//        // If just using for a top/bottom line, these aren't strictly needed.
//        // path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
//        // path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
//        // path.closeSubpath()
//
//        return path
//    }
//}
//
//// Main ContentView
//struct ContentView: View {
//    // State for potential actions (optional)
//    @State private var showingInfo = false
//    
//    // --- Configuration ---
//    let cardBackgroundColor = Color.blue // Approximates the blue in the image
//    let textColor = Color.white
//    let cardPadding: CGFloat = 20
//    let cornerRadius: CGFloat = 15 // Moderate corner radius
//
//    // --- Placeholder Image Names ---
//    // Note: Replace these with your actual asset names
//    let fruitImageName = "fruit_vegetables_placeholder"
//    let qrCodeImageName = "qrcode_placeholder"
//
//    var body: some View {
//        // Use NavigationStack for modern navigation
//        NavigationStack {
//            ScrollView { // Allows content to scroll if it exceeds screen height
//                VStack(spacing: 0) { // Use spacing 0 for precise control with overlays
//
//                    // --- Card Content ---
//                    VStack(alignment: .leading, spacing: 15) {
//                        // Header Section
//                        HStack {
//                            Image(systemName: "figure.walk") // SF Symbol matching screenshot
//                                .font(.title2)
//                                .foregroundColor(textColor)
//                            Text("Front Door Fruit")
//                                .font(.headline)
//                                .fontWeight(.semibold)
//                                .foregroundColor(textColor)
//                            Spacer() // Pushes content to the left
//                        }
//                        .padding(.bottom, 5) // Add slight padding below header
//
//                        // Main Image
//                        Image(fruitImageName) // ** Replace with your image asset **
//                            .resizable()
//                            .aspectRatio(contentMode: .fill) // Fill the width, crop height if needed
//                            .frame(height: 180) // Fixed height for the image area
//                            .clipped() // Prevent image overflow
//
//                        // Info Text Section
//                        VStack(alignment: .leading, spacing: 4) {
//                           Text("Front Door Fruit Stand, Cupertino")
//                                .font(.subheadline)
//                                .foregroundColor(textColor.opacity(0.9))
//                           Text("Your basket is ready for pickup.")
//                                .font(.headline)
//                                .fontWeight(.medium)
//                                .foregroundColor(textColor)
//                        }
//                        .padding(.top, 5) // Add slight padding above text
//
//                        // QR Code Section (Centered)
//                        HStack {
//                            Spacer()
//                            Image(qrCodeImageName) // ** Replace with your QR code image asset **
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 150, height: 150) // Specific size for QR code
//                            Spacer()
//                        }
//                        .padding(.vertical, 10) // Add padding around QR code
//
//                        // Footer Section
//                        HStack {
//                            Image(systemName: "figure.stand") // Complementary SF Symbol
//                                .font(.title3)
//                                .foregroundColor(textColor)
//                            Spacer() // Pushes icons to edges
//                            Button {
//                                showingInfo = true // Action for info button
//                            } label: {
//                                Image(systemName: "info.circle.fill")
//                                    .font(.title3)
//                                    .foregroundColor(textColor)
//                            }
//                        }
//                    }
//                    .padding(cardPadding) // Inner padding for content within the blue area
//                }
//                .background(cardBackgroundColor)
//                .cornerRadius(cornerRadius) // Apply overall corner radius
//                // --- Serrated Edge Overlays ---
//                .overlay(
//                    // Top Serrated Edge
//                    SerratedEdge()
//                        .stroke(cardBackgroundColor, lineWidth: 1) // Stroke with background color to "cut" into the view below if needed, or just use fill if on top
//                        .frame(height: 5) // Height of the serrated pattern effect
//                        .offset(y: -cornerRadius) // Position just inside the top curve
//                    , alignment: .top
//                )
//                .overlay(
//                     // Bottom Serrated Edge (Rotated)
//                     SerratedEdge()
//                         .stroke(cardBackgroundColor, lineWidth: 1)
//                         .frame(height: 5)
//                         .rotationEffect(.degrees(180)) // Flip the shape for the bottom edge
//                         .offset(y: cornerRadius) // Position just inside the bottom curve
//                     , alignment: .bottom
//                )
//                .padding(.horizontal) // Add padding around the entire card on the screen
//                .padding(.top, 5) // Give some space from the Nav Bar
//
//            } // End ScrollView
//            .background(Color(.systemGroupedBackground)) // Background color for the screen behind the card
//            .navigationTitle("Store Card") // Set the title (appears large by default)
//            .navigationBarTitleDisplayMode(.inline) // Make title smaller like screenshot context text - NOTE: Title is ABOVE Nav Bar in screenshot, this puts it IN the bar.
//            // --- Toolbar Items ---
//            .toolbar {
//                // Leading Item: Done Button
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Done") {
//                        // Action for Done button (e.g., dismiss view)
//                        print("Done tapped")
//                    }
//                }
//                // Trailing Item: Ellipsis Button
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        // Action for Ellipsis button (e.g., show menu)
//                        print("More options tapped")
//                    } label: {
//                        Image(systemName: "ellipsis.circle.fill") // Using filled version for clarity
//                    }
//                }
//            }
//            // Present sheet if info button is tapped (example action)
//            .sheet(isPresented: $showingInfo) {
//                 Text("Store Information Details") // Placeholder content for info sheet
//                 Button("Close") { showingInfo = false }
//                 .padding()
//            }
//        } // End NavigationStack
//    }
//}
//
//// Preview Provider for Xcode Canvas
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
