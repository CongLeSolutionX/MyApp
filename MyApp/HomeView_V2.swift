////
////  HomeView_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/2/25.
////
//
//import SwiftUI
//
//// MARK: - Data Models with Default Values
//
//struct ListingItem: Identifiable {
//    let id = UUID()
//    var images: [String] = [] // Default to empty array
//    var isGuestFavorite: Bool = false
//    var isFavorite: Bool = false
//    var location: String = "Unknown Location"
//    var distance: String = "" // Default to empty
//    var dates: String = ""    // Default to empty
//    var price: Int = 0
//    var priceQualifier: String = "per night" // More sensible default
//    var rating: Double = 0.0
//}
//
//struct CategoryItem: Identifiable, Hashable {
//    let id = UUID()
//    var imageName: String = "questionmark.circle" // Default SF Symbol
//    var title: String = "Category"
//}
//
//// Enum remains the same as it defines discrete cases
//enum AirbnbTabItem: CaseIterable, Identifiable {
//    case explore, wishlists, trips, messages, profile
//
//    var id: Self { self }
//
//    var iconName: String {
//        switch self {
//        case .explore: return "magnifyingglass"
//        case .wishlists: return "heart"
//        case .trips: return "airplane" // Proxy icon
//        case .messages: return "message"
//        case .profile: return "person.circle"
//        }
//    }
//
//    var title: String {
//        switch self {
//        case .explore: return "Explore"
//        case .wishlists: return "Wishlists"
//        case .trips: return "Trips"
//        case .messages: return "Messages"
//        case .profile: return "Profile"
//        }
//    }
//
//    @ViewBuilder
//    var view: some View {
//        switch self {
//        case .explore:
//            ExploreContentView()
//        case .wishlists:
//            PlaceholderTabView(title: "Wishlists", icon: "heart.fill")
//        case .trips:
//            PlaceholderTabView(title: "Trips", icon: "airplane")
//        case .messages:
//            PlaceholderTabView(title: "Messages", icon: "message.fill")
//        case .profile:
//            PlaceholderTabView(title: "Profile", icon: "person.fill")
//        }
//    }
//}
//
//// MARK: - Sample Data (Using Initializers, some explicit values override defaults)
//
//let sampleCategories: [CategoryItem] = [
//    CategoryItem(imageName: "house.lodge", title: "Cabins"),
//    CategoryItem(imageName: "star", title: "Icons"),
//    CategoryItem(imageName: "photo.artframe", title: "Amazing views"),
//    CategoryItem(imageName: "figure.wave", title: "OMG!"),
//    CategoryItem(imageName: "leaf", title: "Farms"),
//    CategoryItem(imageName: "beach.umbrella", title: "Beach"),
//    CategoryItem(imageName: "house.and.flag", title: "National parks"),
//    CategoryItem(imageName: "figure.pool.swim", title: "Pools"),
//]
//
//let sampleListings: [ListingItem] = [
//    // Explicitly provide values, otherwise defaults would be used
//    ListingItem(images: ["My-meme-original", "My-meme-microphone", "My-meme-heineken", "My-meme-cordyceps"], // <<< Will use placeholders if these assets don't exist
//                isGuestFavorite: true,
//                isFavorite: false, // Initial state
//                location: "Lake Arrowhead, California",
//                distance: "54 miles away",
//                dates: "Apr 14 – 19",
//                price: 2077,
//                priceQualifier: "for 5 nights",
//                rating: 5.0),
//    ListingItem(images: ["My-meme-microphone", "My-meme-red-wine-glass", "My-meme-cordyceps"], // <<< Will use placeholders if these assets don't exist
//                isGuestFavorite: false,
//                isFavorite: true, // Initial state
//                location: "Big Bear Lake, California",
//                distance: "90 miles away",
//                dates: "May 1 – 7",
//                price: 1850,
//                priceQualifier: "for 6 nights",
//                rating: 4.8),
//    ListingItem(images: ["My-meme-cordyceps"], // <<< Will use placeholders if these assets don't exist
//                isGuestFavorite: true,
//                isFavorite: false, // Initial state
//                location: "Joshua Tree, California",
//                distance: "130 miles away",
//                dates: "Apr 20 – 25",
//                price: 1500,
//                priceQualifier: "for 5 nights",
//                rating: 4.9),
//    ListingItem() // Example using all default values
//]
//
//// MARK: - Safe Image View (Handles Missing Assets)
//
//struct SafeImageView: View {
//    let imageName: String
//    let contentMode: ContentMode
//
//    // Placeholder view configuration
//    let placeholderSystemName: String = "photo.on.rectangle.angled"
//    let placeholderColor: Color = .gray.opacity(0.3)
//    let placeholderBackgroundColor: Color = .gray.opacity(0.1)
//
//    var body: some View {
//        // Check if the named UIImage exists in the asset catalog
//        if UIImage(named: imageName) != nil {
//            Image(imageName)
//                .resizable()
//                .aspectRatio(contentMode: contentMode)
//        } else {
//            // Display placeholder if the asset is missing
//            Image(systemName: placeholderSystemName)
//                .resizable()
//                .aspectRatio(contentMode: .fit) // Fit placeholder icon within bounds
//                .padding() // Add some padding around the SF symbol
//                .foregroundColor(placeholderColor)
//                .frame(maxWidth: .infinity, maxHeight: .infinity) // Take up available space
//                .background(placeholderBackgroundColor) // Background for the placeholder area
//        }
//    }
//}
//
//// MARK: - Custom Styles & Colors (No changes needed here)
//
//extension Color {
//    static let airbnbPink = Color(red: 255/255, green: 56/255, blue: 92/255)
//    static let airbnbGray = Color(uiColor: .systemGray)
//    static let airbnbLightGray = Color(uiColor: .systemGray4)
//    static let airbnbDarkGray = Color(uiColor: .darkGray)
//}
//
//// MARK: - Placeholder View for Unimplemented Tabs (No changes needed)
//
//struct PlaceholderTabView: View {
//    let title: String
//    let icon: String
//    // ... (body remains the same)
//    var body: some View {
//        NavigationView {
//            VStack {
//                Spacer()
//                Image(systemName: icon)
//                    .font(.system(size: 60))
//                    .foregroundColor(.airbnbLightGray)
//                Text(title)
//                    .font(.title)
//                    .foregroundColor(.airbnbGray)
//                    .padding(.top)
//                Text("Content coming soon!")
//                    .font(.subheadline)
//                    .foregroundColor(.airbnbGray)
//                Spacer()
//                Spacer()
//            }
//            .navigationTitle(title)
//            .navigationBarHidden(true)
//        }
//        .navigationViewStyle(.stack)
//    }
//}
//
//// MARK: - Explore Tab Content & Sub-components
//
//// --- Search Bar --- (No changes needed)
//struct SearchBarView: View {
//    // ... (body remains the same)
//    var body: some View {
//        HStack(spacing: 10) {
//            Image(systemName: "magnifyingglass")
//                .foregroundColor(.primary)
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text("Start your search")
//                    .fontWeight(.semibold)
//                    .font(.subheadline)
//            }
//            Spacer()
//        }
//        .padding(.vertical, 10)
//        .padding(.horizontal)
//        .background(Color(UIColor.systemBackground))
//        .clipShape(Capsule())
//        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//    }
//}
//
//// --- Category Filter --- (No changes needed - uses SF Symbols)
//struct CategoryFilterView: View {
//    let categories: [CategoryItem]
//    @State private var selectedCategory: CategoryItem? = sampleCategories.first
//
//    // ... (body remains the same)
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 25) {
//                ForEach(categories) { category in
//                    CategoryItemView(
//                        category: category,
//                        isSelected: category == selectedCategory
//                    )
//                    .onTapGesture {
//                        withAnimation(.easeInOut(duration: 0.2)) {
//                            selectedCategory = category
//                        }
//                        print("Selected category: \(category.title)")
//                    }
//                }
//            }
//            .padding(.horizontal)
//        }
//    }
//}
//
//// --- Category Item View --- (No changes needed - uses SF Symbols)
//struct CategoryItemView: View {
//    let category: CategoryItem
//    let isSelected: Bool
//    // ... (body remains the same)
//    var body: some View {
//        VStack(spacing: 5) {
//            // Assumes category.imageName is an SF Symbol name
//            Image(systemName: category.imageName)
//                .font(.title2)
//                .frame(height: 25)
//                .foregroundColor(isSelected ? .primary : .airbnbGray)
//
//            Text(category.title)
//                .font(.caption)
//                .fontWeight(isSelected ? .semibold : .regular)
//                .foregroundColor(isSelected ? .primary : .airbnbGray)
//                .lineLimit(1)
//
//            if isSelected {
//                Rectangle()
//                    .fill(.primary)
//                    .frame(height: 2)
//                    .transition(.scale(scale: 0.5, anchor: .bottom).combined(with: .opacity))
//            } else {
//                Rectangle()
//                    .fill(.clear)
//                    .frame(height: 2)
//            }
//        }
//        .frame(minWidth: 60)
//    }
//}
//
//// --- Fee Info --- (No changes needed)
//struct FeeInfoView: View {
//    // ... (body remains the same)
//     var body: some View {
//         HStack(spacing: 8) {
//             Image(systemName: "tag.fill")
//                 .foregroundColor(.airbnbPink)
//             Text("Prices include all fees")
//                 .font(.subheadline)
//                 .fontWeight(.semibold)
//         }
//         .padding(.vertical, 8)
//     }
//}
//
//// ---- Image Carousel (UPDATED TO USE SafeImageView) ---
//struct ImageCarouselView: View {
//    let imageNames: [String]
//    @State private var currentIndex = 0
//
//    var body: some View {
//        GeometryReader { geometry in
//            TabView(selection: $currentIndex) {
//                // Use default image if imageNames is empty
//                 if imageNames.isEmpty {
//                     SafeImageView(imageName: "", contentMode: .fill) // Will show placeholder
//                         .tag(0) // Need a tag even for one item
//                 } else {
//                     ForEach(imageNames.indices, id: \.self) { index in
//                         SafeImageView(imageName: imageNames[index], contentMode: .fill) // Use SafeImageView
//                             .frame(width: geometry.size.width)
//                             .clipped()
//                             .tag(index)
//                     }
//                 }
//            }
//            .tabViewStyle(.page(indexDisplayMode: .never))
//            .frame(height: geometry.size.width * 0.85) // Keep aspect ratio calculation
//            // Custom Page Indicator Overlay (only show if there's more than one image)
//              .overlay(
//                  // Only show indicator if there are images and more than one
//                  Group { // Use Group to conditionally apply overlay content
//                      if !imageNames.isEmpty && imageNames.count > 1 {
//                          HStack(spacing: 6) {
//                              ForEach(imageNames.indices, id: \.self) { index in
//                                  Circle()
//                                      .fill(Color.white.opacity(index == currentIndex ? 1.0 : 0.5))
//                                      .frame(width: 6, height: 6)
//                                      .animation(.easeInOut(duration: 0.2), value: currentIndex == index) // Animate selection
//                              }
//                          }
//                          .padding(.bottom, 10)
//                          .padding(.horizontal) // Prevent dots sticking to edge
//                               // Add a semi-transparent background for better visibility on light images
//                               .background(Color.black.opacity(0.2).blur(radius: 5))
//                               .clipShape(Capsule())
//                               .padding(.bottom, 8) // Adjust positioning
//                      }
//                  }
//                  , alignment: .bottom // Align the Group to the bottom
//              )
//        }
//        .aspectRatio(4 / 3.3, contentMode: .fit)
//    }
//}
//
//// --- Listing Card (UPDATED TO USE SafeImageView VIA ImageCarouselView) ---
//struct ListingCardView: View {
//    @State var listing: ListingItem // Use @State to allow mutation (like isFavorite)
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            ZStack(alignment: .topTrailing) {
//                // ImageCarouselView now implicitly uses SafeImageView
//                ImageCarouselView(imageNames: listing.images)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//
//                // Heart Button... (no changes needed here)
//                Button {
//                     withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
//                           listing.isFavorite.toggle()
//                     }
//                } label: {
//                    Image(systemName: listing.isFavorite ? "heart.fill" : "heart")
//                        .foregroundColor(listing.isFavorite ? .airbnbPink : .white)
//                        .font(.title2)
//                        .padding(8)
//                        .background(Color.black.opacity(0.3))
//                        .clipShape(Circle())
//                }
//                .padding(10)
//
//                // Guest Favorite Badge... (no changes needed here)
//                if listing.isGuestFavorite {
//                    HStack {
//                        Image(systemName: "trophy.fill")
//                        Text("Guest favorite")
//                    }
//                    // ... (rest of badge styling remains the same)
//                     .font(.caption)
//                     .fontWeight(.semibold)
//                     .padding(.horizontal, 10)
//                     .padding(.vertical, 5)
//                     .background(.white)
//                     .foregroundColor(.black)
//                     .clipShape(Capsule())
//                     .padding([.top, .leading], 10)
//                     .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//                }
//            }
//
//            // Text Details... (no changes needed here, defaults handled by ListingItem)
//             HStack {
//                 Text(listing.location)
//                     .fontWeight(.semibold)
//                 Spacer()
//                 HStack(spacing: 3) {
//                     Image(systemName: "star.fill")
//                     Text(String(format: "%.1f", listing.rating))
//                 }
//             }
//             .font(.subheadline)
//             .opacity(listing.location.isEmpty ? 0 : 1) // Hide if empty
//
//             Text(listing.distance)
//                 .font(.subheadline)
//                 .foregroundColor(.airbnbGray)
//                 .opacity(listing.distance.isEmpty ? 0 : 1) // Hide if empty
//
//             Text(listing.dates)
//                 .font(.subheadline)
//                 .foregroundColor(.airbnbGray)
//                 .opacity(listing.dates.isEmpty ? 0 : 1) // Hide if empty
//
//             HStack(spacing: 3) {
//                 Text("$\(listing.price)")
//                     .fontWeight(.semibold)
//                 Text(listing.priceQualifier)
//             }
//              .font(.subheadline)
//              .padding(.top, 1)
//              .opacity(listing.price <= 0 ? 0 : 1) // Hide price if zero or less
//
//        }
//    }
//}
//
//// --- Main Content View for Explore Tab --- (No changes needed)
//struct ExploreContentView: View {
//    // ... (body remains the same)
//     var body: some View {
//         ScrollView {
//             LazyVStack(alignment: .leading, spacing: 15) {
//                 SearchBarView()
//                     .padding(.horizontal)
//                     .padding(.top)
//
//                 CategoryFilterView(categories: sampleCategories)
//                     .padding(.vertical, 10)
//
//                 Divider()
//                      .padding(.horizontal)
//
//                 FeeInfoView()
//                      .padding(.horizontal)
//
//                 ForEach(sampleListings) { listing in
//                     ListingCardView(listing: listing)
//                         .padding(.horizontal)
//                         .padding(.bottom, 15)
//                 }
//                 Spacer(minLength: 90)
//             }
//         }
//     }
//}
//
//// --- Tab Bar View Implementation --- (No changes needed)
//struct AirbnbTabBarView: View {
//    @Binding var selectedTab: AirbnbTabItem
////    @Environment(\.safeAreaInsets) private var safeAreaInsets
//    // ... (body remains the same)
//    var body: some View {
//        HStack {
//            ForEach(AirbnbTabItem.allCases) { item in
//                Spacer()
//                VStack(spacing: 4) {
//                    Image(systemName: item.iconName)
//                        .font(.system(size: 22))
//                        .symbolVariant(selectedTab == item ? .fill : .none)
//                        .frame(height: 25)
//
//                    Text(item.title)
//                        .font(.system(size: 10))
//                }
//                .foregroundColor(selectedTab == item ? .airbnbPink : .airbnbGray)
//                .padding(.top, 8)
//                .frame(maxWidth: .infinity)
//                .contentShape(Rectangle())
//                .onTapGesture {
//                     if selectedTab != item {
//                        selectedTab = item
//                     }
//                }
//                Spacer()
//            }
//        }
//        .frame(height: 55)
////        .padding(.bottom, safeAreaInsets.bottom > 0 ? safeAreaInsets.bottom - 10 : 0 ) // Adjust padding based on safe area
//        .background(.thinMaterial)
//        .overlay(Divider(), alignment: .top)
//    }
//}
//
//// MARK: - Main Container View (Manages Tabs) (No changes needed)
//struct MainAirbnbTabView: View {
//    @State private var selectedTab: AirbnbTabItem = .explore
////    @Environment(\.safeAreaInsets) private var safeAreaInsets // Needed for Map Button positioning
//
//    // ... (body remains the same)
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            selectedTab.view
//
//             if selectedTab == .explore {
//                 MapButtonView()
////                    .padding(.bottom, (safeAreaInsets.bottom > 0 ? safeAreaInsets.bottom : 10) + 55) // Position above tab bar
//                 .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
//                 .transition(.scale.combined(with: .opacity))
//                 .animation(.easeInOut, value: selectedTab)
//             }
//
//            AirbnbTabBarView(selectedTab: $selectedTab)
//        }
//        .edgesIgnoringSafeArea(.bottom)
//    }
//}
//
//// --- Map Button --- (No changes needed)
//struct MapButtonView: View {
//    // ... (body remains the same)
//       var body: some View {
//           Button {
//               print("Map button tapped!")
//           } label: {
//               HStack(spacing: 6) {
//                   Text("Map")
//                   Image(systemName: "map")
//                       .font(.subheadline)
//               }
//               .padding(.horizontal, 16)
//               .padding(.vertical, 10)
//               .background(.black)
//               .foregroundColor(.white)
//               .clipShape(Capsule())
//               .shadow(radius: 5)
//           }
//      }
//}
//
//// MARK: - App Entry Point
//
////@main
////struct AirbnbCloneOptimizedApp: App { // RENAME this to your project's App name
////    var body: some Scene {
////        WindowGroup {
////            MainAirbnbTabView()
////        }
////    }
////}
//
//// MARK: - Previews (Should now work even without assets)
//
//#Preview("Full App") {
//    MainAirbnbTabView()
//}
//
//#Preview("Listing Card (Missing Assets)") {
//    // This card will show placeholders if "missing_image_1", etc. don't exist
//    ListingCardView(listing: ListingItem(images: ["missing_image_1", "missing_image_2"]))
//        .padding()
//        .background(Color.gray.opacity(0.1))
//}
//
//#Preview("Listing Card (Default Item)") {
//    // This card uses all default values, including empty images -> placeholder
//    ListingCardView(listing: ListingItem())
//        .padding()
//        .background(Color.gray.opacity(0.1))
//}
//
//#Preview("Safe Image View (Missing)") {
//    SafeImageView(imageName: "non_existent_asset", contentMode: .fit)
//        .frame(width: 150, height: 100)
//        .border(Color.red)
//}
//
//// Other previews (CategoryFilter, SearchBar, TabBar, MapButton) remain the same
//#Preview("Category Filter") {
//    CategoryFilterView(categories: sampleCategories)
//        .padding(.vertical)
//        .background(Color.gray.opacity(0.1))
//}
//
//#Preview("Tab Bar") {
//    AirbnbTabBarView(selectedTab: .constant(.explore))
//         .background(Color.white)
//}
