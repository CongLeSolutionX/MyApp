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
        center: CLLocationCoordinate2D(latitude: 33.77, longitude: -118.1), // Approximate center
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    @State private var searchText = ""
    @State private var selection = "Nearby"
    @State private var showFilter = false // State to control filter button visibility

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Bar (Search, Pickup/Delivery, Skip)
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.leading)
                    TextField("Search", text: $searchText)
                        .padding(.vertical, 8)
                    Spacer()
                    Button("Skip") {
                        // Handle skip action
                    }
                    .padding(.trailing)
                }
                .background(Color(.systemGray6)) // Light gray background

                // Pickup/Delivery Segmented Control
                Picker(selection: .constant(0), label: Text("Order Type")) {
                    Text("Pickup").tag(0)
                    Text("Delivery").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .background(Color(UIColor(red: 0.1, green: 0.4, blue: 0.1, alpha: 1.0))) // Dark green background
                .foregroundColor(.white)

                // Map View
                Map(coordinateRegion: $region, showsUserLocation: true)
                //removed: interactionModes: [.all] to follow the original image
                    .overlay(
                        // Location Pin
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 15, height: 15)
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .offset(y: -2),  //offset to center the pin
                        alignment: .center

                    )
                    .overlay(
                        // Send Location Button (Top Trailing)
                        VStack{
                            Spacer()
                            HStack{
                                Spacer()
                                Button(action: {
                                    // Handle send location action
                                }) {
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
                        //Filter button
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

                // Tab Bar (Nearby, Previous, Favorites)
                Picker(selection: $selection, label: Text("")) {
                    Text("Nearby").tag("Nearby")
                    Text("Previous").tag("Previous")
                    Text("Favorites").tag("Favorites")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top)

                // List of Stores (Conditional based on tab selection)
                // Use a ScrollView to handle potential overflow
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) { // LazyVStack for performance
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
                            //  placeholder
                            Text("Previous Orders Content")
                        } else {
                            // placeholder
                            Text("Favorite Orders Content")
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, alignment: .leading) // Ensure the list takes full width

                // Bottom Navigation Bar
                HStack {
                    BottomNavLink(imageName: "house.fill", title: "Home")
                    BottomNavLink(imageName: "qrcode.viewfinder", title: "Scan")
                    BottomNavLink(imageName: "cup.and.saucer.fill", title: "Order")
                        .foregroundColor(Color(UIColor(red: 0.1, green: 0.4, blue: 0.1, alpha: 1.0))) // Dark green
                    BottomNavLink(imageName: "gift.fill", title: "Gift")
                    BottomNavLink(imageName: "star.fill", title: "Offers")
                }
                .padding(.top, 8)
                .background(Color(.systemGray6))
            }
            .edgesIgnoringSafeArea(.bottom) // Ignore safe area for bottom nav
            .navigationBarHidden(true) // Hide the default navigation bar
            .sheet(isPresented: $showFilter) {
                //present your filter view
                FilterView(isPresented: $showFilter)
            }
        }
    }
}

// Reusable Store Row View
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
            Divider() // Add a divider between rows
        }
    }
}

// Reusable Bottom Navigation Link
struct BottomNavLink: View {
    let imageName: String
    let title: String

    var body: some View {
        Button(action: {
            // Handle navigation
        }) {
            VStack {
                Image(systemName: imageName).font(.title2)
                Text(title).font(.caption)
            }
        }
        .frame(maxWidth: .infinity) // Equal spacing
    }
}

struct FilterView: View {
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            VStack {
                //  filter options
                Text("Filter Options")
                    .font(.title)

            }
            .navigationBarTitle("Filter", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .previewDevice("iPhone 14 Pro") //or any other device
        MapView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
