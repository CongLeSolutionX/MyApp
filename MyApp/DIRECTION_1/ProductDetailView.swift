////
////  ProductDetailView.swift
////  MyApp
////
////  Created by Cong Le on 4/9/25.
////
//
//import Foundation
//
//// Mock Data Structure for a Product
//struct Product: Identifiable {
//    let id = UUID() // Conforms to Identifiable
//    let name: String
//    let price: Double
//    let description: String
//    let imageName: String // In real apps, likely a URL string
//    let rating: Double // e.g., 4.5
//    let reviewCount: Int // e.g., 120
//    let seller: String
//    let specifications: [String: String] // e.g., ["Material": "Cotton", "Color": "Blue"]
//    let stockStatus: StockStatus // Enum for availability
//
//    enum StockStatus: String {
//        case inStock = "In Stock"
//        case lowStock = "Low Stock"
//        case outOfStock = "Out of Stock"
//    }
//
//    // Helper for formatted price
//    var formattedPrice: String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.locale = Locale.current // Use user's locale
//        return formatter.string(from: NSNumber(value: price)) ?? "$\(String(format: "%.2f", price))"
//    }
//
//    // Mock Data Example
//    static let mock = Product(
//        name: "Premium Cotton T-Shirt",
//        price: 29.99,
//        description: "A soft, durable t-shirt made from 100% premium cotton. Perfect for everyday wear.",
//        imageName: "My-meme-heineken", // Name of an image asset in your project
//        rating: 4.7,
//        reviewCount: 255,
//        seller: "Modern Threads Co.",
//        specifications: [
//            "Material": "100% Premium Cotton",
//            "Fit": "Regular",
//            "Neckline": "Crew Neck",
//            "Care": "Machine Wash Cold"
//        ],
//        stockStatus: .inStock
//    )
//
//     // Another mock example
//    static let mock2 = Product(
//        name: "Wireless Noise-Cancelling Headphones",
//        price: 149.50,
//        description: "Immersive sound experience with active noise cancellation. Bluetooth 5.2 and 30-hour battery life.",
//        imageName: "My-meme-orange",
//        rating: 4.9,
//        reviewCount: 1087,
//        seller: "SoundWave Electronics",
//        specifications: [
//            "Connectivity": "Bluetooth 5.2",
//            "Battery Life": "Up to 30 hours",
//            "Features": "ANC, Built-in Mic",
//            "Color": "Matte Black"
//        ],
//        stockStatus: .lowStock
//    )
//}
//
//import SwiftUI
//
//struct ProductDetailView: View {
//    // The product data is passed into this view
//    let product: Product
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                // --- Image Section ---
//                productImage
//
//                // --- Core Info Section ---
//                VStack(alignment: .leading, spacing: 8) {
//                    Text(product.name)
//                        .font(.title)
//                        .fontWeight(.bold)
//
//                    Text("Sold by \(product.seller)")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//
//                    HStack {
//                        Text(product.formattedPrice)
//                            .font(.title2)
//                            .fontWeight(.semibold)
//                            .foregroundColor(.blue) // Make price stand out
//                        Spacer()
//                        stockIndicator // Show stock status
//                    }
//
//                    ratingView // Show star rating and review count
//                }
//                .padding(.horizontal)
//
//                Divider()
//
//                // --- Description Section ---
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Description")
//                        .font(.headline)
//                    Text(product.description)
//                        .font(.body)
//                        .foregroundColor(.gray)
//                }
//                .padding(.horizontal)
//
//                Divider()
//
//                // --- Specifications Section ---
//                DisclosureGroup("Specifications") {
//                    VStack(alignment: .leading, spacing: 5) {
//                        ForEach(product.specifications.sorted(by: <), id: \.key) { key, value in
//                            HStack {
//                                Text(key)
//                                    .fontWeight(.medium)
//                                Spacer()
//                                Text(value)
//                                    .foregroundColor(.secondary)
//                            }
//                            .font(.footnote)
//                        }
//                    }
//                    .padding(.top, 5)
//                }
//                .padding(.horizontal)
//
//                Divider()
//
//                // --- Action Buttons ---
//                actionButtons
//                    .padding(.horizontal)
//                    .padding(.bottom) // Add padding at the very bottom
//
//            } // End Main VStack
//        } // End ScrollView
//        .navigationTitle("Product Details") // Set the title for the navigation bar
//        .navigationBarTitleDisplayMode(.inline) // Or .large depending on design
//    }
//
//    // --- Helper Views ---
//
//    // Product Image (Replace with AsyncImage in real app)
//    private var productImage: some View {
//        Image(product.imageName) // Assumes image is in Asset Catalog
//            .resizable()
//            .scaledToFit()
//            .frame(maxWidth: .infinity) // Takes full width available
//            .background(Color(.systemGray6)) // Placeholder background
//            .accessibilityLabel("Image of \(product.name)") // Accessibility
//            // In a real app, use AsyncImage for URL loading:
//            // AsyncImage(url: URL(string: product.imageUrl)) { phase in ... }
//    }
//
//    // Star Rating View
//    private var ratingView: some View {
//        HStack(spacing: 4) {
//            ForEach(0..<5) { index in
//                Image(systemName: index < Int(product.rating.rounded(.down)) ? "star.fill" : (index < Int(product.rating.rounded(.up)) && product.rating.truncatingRemainder(dividingBy: 1) >= 0.5 ? "star.leadinghalf.filled" : "star"))
//                    .foregroundColor(.orange)
//            }
//            Text("(\(product.reviewCount) reviews)")
//                .font(.caption)
//                .foregroundColor(.secondary)
//        }
//    }
//
//    // Stock Status Indicator
//    private var stockIndicator: some View {
//        Text(product.stockStatus.rawValue)
//            .font(.caption)
//            .fontWeight(.medium)
//            .padding(.horizontal, 8)
//            .padding(.vertical, 4)
//            .foregroundColor(stockStatusColorForeground)
//            .background(stockStatusColorBackground.opacity(0.2))
//            .cornerRadius(6)
//    }
//
//    // Action Buttons (Add to Cart, Buy Now)
//    private var actionButtons: some View {
//        VStack(spacing: 12) {
//            Button {
//                // TODO: Add to Cart Action
//                print("Add to Cart tapped for \(product.name)")
//            } label: {
//                Label("Add to Cart", systemImage: "cart.fill")
//                    .frame(maxWidth: .infinity)
//            }
//            .buttonStyle(.bordered) // A less prominent style
//            .tint(.secondary) // Subtle tint
//
//            Button {
//                // TODO: Buy Now Action (Navigate to checkout?)
//                print("Buy Now tapped for \(product.name)")
//            } label: {
//                 Text("Buy Now")
//                    .fontWeight(.semibold)
//                    .frame(maxWidth: .infinity)
//            }
//            .buttonStyle(.borderedProminent) // More prominent style
//            .tint(.blue) // Primary action color
//            .disabled(product.stockStatus == .outOfStock) // Disable if out of stock
//        }
//    }
//
//    // --- Helper Computed Properties for Styling ---
//
//    private var stockStatusColorForeground: Color {
//        switch product.stockStatus {
//        case .inStock: return .green
//        case .lowStock: return .orange
//        case .outOfStock: return .red
//        }
//    }
//
//     private var stockStatusColorBackground: Color {
//        switch product.stockStatus {
//        case .inStock: return .green
//        case .lowStock: return .orange
//        case .outOfStock: return .red
//        }
//    }
//}
//
//// --- Preview Provider ---
//struct ProductDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Wrap in NavigationView for preview context
//        NavigationView {
//            ProductDetailView(product: Product.mock) // Use mock data
//        }
//
//         NavigationView {
//            ProductDetailView(product: Product.mock2) // Use other mock data
//        }
//        .preferredColorScheme(.dark) // Preview in dark mode too
//    }
//}
