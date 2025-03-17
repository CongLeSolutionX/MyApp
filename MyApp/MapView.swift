//
//  MapView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//
import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.77, longitude: -118.1),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    @State private var searchText = ""
    @State private var selection = "Nearby"
    @State private var showFilter = false
    @State private var orderType = 0 // 0 for Pickup, 1 for Delivery

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.leading)
                    TextField("Search", text: $searchText)
                        .padding(.vertical, 8)
                    Spacer()
                    Button("Skip") { }
                    .padding(.trailing)
                }
                .background(Color(.systemGray6))

                // Pickup/Delivery - Now a segmented control bound to orderType
                Picker(selection: $orderType, label: Text("Order Type")) {
                    Text("Pickup").tag(0)
                    Text("Delivery").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .background(Color(UIColor(red: 0.1, green: 0.4, blue: 0.1, alpha: 1.0)))
                .foregroundColor(.white)

                // Conditional View: Delivery or Map/List
                if orderType == 1 { // Delivery View
                    DeliveryView()
                } else { // Pickup View (Map and List)

                    // Map View
                    Map(coordinateRegion: $region, showsUserLocation: true)
                        .overlay(
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 15, height: 15)
                                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                .offset(y: -2),
                            alignment: .center
                        )
                        .overlay(
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: {}) {
                                        Image(systemName: "paperplane.circle.fill")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.white)
                                            .background(Color.gray.opacity(0.5))
                                            .clipShape(Circle())
                                            .padding()
                                    }
                                }
                            }
                        )
                        .overlay(
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        showFilter = true
                                    }) {
                                        Text("Filter")
                                            .padding()
                                            .foregroundColor(.white)
                                            .background(Color.gray.opacity(0.7))
                                            .clipShape(RoundedRectangle(cornerRadius: 30))
                                    }
                                    .padding()
                                }
                            }
                        )

                    // Tab Bar
                    Picker(selection: $selection, label: Text("")) {
                        Text("Nearby").tag("Nearby")
                        Text("Previous").tag("Previous")
                        Text("Favorites").tag("Favorites")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.top)

                    // List of Stores
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            if selection == "Nearby" {
                                StoreRow(storeName: "Brookhurst & Westminster", address: "13992 Brookhurst St, Garden Grove", distance: "0.9 mi", openUntil: "Open until 9:30 PM", inStore: true, driveThru: true)
                                StoreRow(storeName: "Highland & Wilshire", address: "5020 Wilshire Blvd, Los Angeles", distance: "30.4 mi", openUntil: "Open until 7:00 PM", inStore: true, driveThru: false)
                                StoreRow(storeName: "Chicago Roastery", address: "646 N. Michigan Avenue, Chicago", distance: "1741.6 mi", openUntil: "Open until 8:00 PM", inStore: false, driveThru: false, isNotAvailable: true)
                                StoreRow(storeName: "Brookhurst & Westminster", address: "13992 Brookhurst St, Garden Grove", distance: "0.9 mi", openUntil: "Open until 9:30 PM", inStore: true, driveThru: true)
                                StoreRow(storeName: "Highland & Wilshire", address: "5020 Wilshire Blvd, Los Angeles", distance: "30.4 mi", openUntil: "Open until 7:00 PM", inStore: true, driveThru: false)
                                StoreRow(storeName: "Chicago Roastery", address: "646 N. Michigan Avenue, Chicago", distance: "1741.6 mi", openUntil: "Open until 8:00 PM", inStore: false, driveThru: false, isNotAvailable: true)
                                StoreRow(storeName: "Brookhurst & Westminster", address: "13992 Brookhurst St, Garden Grove", distance: "0.9 mi", openUntil: "Open until 9:30 PM", inStore: true, driveThru: true)
                                StoreRow(storeName: "Highland & Wilshire", address: "5020 Wilshire Blvd, Los Angeles", distance: "30.4 mi", openUntil: "Open until 7:00 PM", inStore: true, driveThru: false)
                                StoreRow(storeName: "Chicago Roastery", address: "646 N. Michigan Avenue, Chicago", distance: "1741.6 mi", openUntil: "Open until 8:00 PM", inStore: false, driveThru: false, isNotAvailable: true)
                                StoreRow(storeName: "Brookhurst & Westminster", address: "13992 Brookhurst St, Garden Grove", distance: "0.9 mi", openUntil: "Open until 9:30 PM", inStore: true, driveThru: true)
                                StoreRow(storeName: "Highland & Wilshire", address: "5020 Wilshire Blvd, Los Angeles", distance: "30.4 mi", openUntil: "Open until 7:00 PM", inStore: true, driveThru: false)
                                StoreRow(storeName: "Chicago Roastery", address: "646 N. Michigan Avenue, Chicago", distance: "1741.6 mi", openUntil: "Open until 8:00 PM", inStore: false, driveThru: false, isNotAvailable: true)

                            } else if selection == "Previous" {
                                Text("Previous Orders Content")
                            } else {
                                Text("Favorite Orders Content")
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Bottom Navigation Bar
                HStack {
                    BottomNavLink(imageName: "house.fill", title: "Home")
                    BottomNavLink(imageName: "qrcode.viewfinder", title: "Scan")
                    BottomNavLink(imageName: "cup.and.saucer.fill", title: "Order")
                        .foregroundColor(Color(UIColor(red: 0.1, green: 0.4, blue: 0.1, alpha: 1.0)))
                    BottomNavLink(imageName: "gift.fill", title: "Gift")
                    BottomNavLink(imageName: "star.fill", title: "Offers")
                }
                .padding(.top, 8)
                .background(Color(.systemGray6))
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarHidden(true)
            .sheet(isPresented: $showFilter) {
                StoreFiltersView(isPresented: $showFilter, storeCount: 50)
            }
        }
    }
}

struct StoreRow: View {
    let storeName: String
    let address: String
    let distance: String
    let openUntil: String
    let inStore: Bool
    let driveThru: Bool
    var isNotAvailable = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading) {
                    Text(storeName).font(.headline)
                    Text(address).font(.subheadline).foregroundColor(.gray)
                    Text("\(distance) · \(openUntil)").font(.subheadline).foregroundColor(.gray)

                    HStack {
                        if inStore {
                            Image(systemName: "door.left.hand.open")
                            Text("In store").font(.caption)
                        }
                        if driveThru {
                            Image(systemName: "car.fill")
                            Text("Drive-thru").font(.caption)
                        }
                    }
                    .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "heart.fill").foregroundColor(.green)
                Image(systemName: "info.circle")
            }
            if isNotAvailable {
                Text("Order ahead not available")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.7))
                    .cornerRadius(4)
            }
            Divider()
        }
    }
}

struct BottomNavLink: View {
    let imageName: String
    let title: String

    var body: some View {
        Button(action: {}) {
            VStack {
                Image(systemName: imageName).font(.title2)
                Text(title).font(.caption)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct StoreFiltersView: View {
    @Binding var isPresented: Bool
    @State private var filters: [String: Bool] = [:]
    let storeCount: Int

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Store filters")
                        .font(.largeTitle)
                        .padding(.bottom)

                    Section(header: Text("Store Hours").font(.headline)) {
                        FilterButton(label: "Open 24 hours per day", isSelected: $filters["Open 24 hours per day"])
                        FilterButton(label: "Open Now", isSelected: $filters["Open Now"])
                    }

                    Section(header: Text("Pickup Options").font(.headline).padding(.top)) {
                        FilterButton(label: "Curbside", isSelected: $filters["Curbside"])
                        FilterButton(label: "Drive-thru", isSelected: $filters["Drive-thru"])
                        FilterButton(label: "In store", isSelected: $filters["In store"])
                        FilterButton(label: "Outdoor pickup", isSelected: $filters["Outdoor pickup"])
                    }

                    Section(header: Text("Amenities").font(.headline).padding(.top)) {
                        FilterButton(label: "Café Seating", isSelected: $filters["Café Seating"])
                        FilterButton(label: "Nitro Cold Brew", isSelected: $filters["Nitro Cold Brew"])
                        FilterButton(label: "Order ahead", isSelected: $filters["Order ahead"])
                        FilterButton(label: "Order ahead without account", isSelected: $filters["Order ahead without account"])
                        FilterButton(label: "Outdoor Seating", isSelected: $filters["Outdoor Seating"])
                        FilterButton(label: "Redeem Rewards", isSelected: $filters["Redeem Rewards"])
                        FilterButton(label: "Starbucks Reserve Coffee", isSelected: $filters["Starbucks Reserve Coffee"])
                        FilterButton(label: "Starbucks Wi-Fi", isSelected: $filters["Starbucks Wi-Fi"])
                    }

                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Show \(storeCount) stores")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor(red: 0.1, green: 0.4, blue: 0.1, alpha: 1.0)))
                            .cornerRadius(25)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationBarItems(trailing: Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark")
                    .imageScale(.large)
                    .padding(.leading)
            })
            .navigationBarTitle("", displayMode: .inline)
        }
    }
}

struct FilterButton: View {
    let label: String
    @Binding var isSelected: Bool?

    var body: some View {
        Button(action: {
            isSelected = !(isSelected ?? false)
        }) {
            Text(label)
                .font(.subheadline)
                .foregroundColor((isSelected ?? false) ? .white : .green)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background((isSelected ?? false) ? Color.green : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.green, lineWidth: 1)
                )
                .cornerRadius(20)
        }
    }
}

// MARK: - DeliveryView

struct DeliveryView: View {
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    // Background Image (Gradient)
                    LinearGradient(gradient: Gradient(colors: [
                        Color(UIColor(red: 0.8, green: 0.85, blue: 0.8, alpha: 1.0)), // Light greenish-gray
                        Color(UIColor(red: 0.1, green: 0.4, blue: 0.1, alpha: 1.0))  // Dark green
                    ]), startPoint: .top, endPoint: .bottom)
                    .frame(width: geometry.size.width, height: geometry.size.height / 2) // Half the screen
                    .clipShape(RoundedRectangle(cornerRadius: 35))

                    VStack {
                        Spacer()
                        // Placeholder image (bag and cups)
                        Image(systemName: "bag.fill.badge.plus")  // Use a system image
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height / 3) // Adjust size
                            .foregroundColor(Color(UIColor(red: 0.1, green: 0.4, blue: 0.1, alpha: 1.0))) // Dark Green

                        Text("Today deserves delivery")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top)

                        Button(action: {
                            // Handle "Get started" action
                        }) {
                            Text("Get started")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(UIColor(red: 0.1, green: 0.4, blue: 0.1, alpha: 1.0)))
                                .cornerRadius(25)
                        }
                        .padding(.horizontal)

                        Button(action: {
                            // Handle "Delivery FAQs" action
                        }) {
                            Text("Delivery FAQs")
                                .font(.headline)
                                .foregroundColor(.green)
                                .padding()
                        }

                        Spacer() // Push content to the top
                    }
                    .frame(width: geometry.size.width) // Ensure content respects width

                }

            }
            // DoorDash attribution (outside GeometryReader)
            VStack(alignment: .leading){
                Text("POWERED BY")
                    .font(.caption)
                    .foregroundColor(.gray)
                    + Text("  ")
                    + Text(Image(systemName: "arrow.up.right.circle.fill")) // DoorDash logo placeholder
                    + Text(" DOORDASH")
                        .font(.caption)
                        .foregroundColor(.red)

                Text("Menu limited. Menu pricing for delivery may be higher than posted in stores or as marked. Additional fees may apply. Delivery orders are not eligible for Starbucks® Rewards benefits at this time. Check our Delivery FAQs for additional help.")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.top) // Ignore safe area at the top for the gradient
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .previewDevice("iPhone 14 Pro")
        MapView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
