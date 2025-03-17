//
//  LoadingView.swift
//  MyApp
//
//  Created by Cong Le on 3/16/25.
//

import SwiftUI

struct LoadingView: View {
    // State variable to manage the selected tab
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            // Background Color (Light Purple/Pink)
            Color(red: 255/255, green: 240/255, blue: 250/255) // Approximate color
                .ignoresSafeArea() // Extend color to safe area edges

            VStack(spacing: 0) {
                // MARK: - Top Bar
                HStack {
                    Image(systemName: "magnifyingglass") // Search Icon
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Spacer() // Push items to the edges

                    Text("Now in iOS Devices") // Title
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer() // Push items to the edges

                    Image(systemName: "person.circle.fill") // Profile Icon
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding()
                .padding(.top, 30) // Add more top padding for status bar.

                // MARK: - Content Area (Scrollable)
                ScrollView {
                    VStack {
                        // Loading Indicator
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                            .scaleEffect(1.5)  //make it larger
                            .padding(.top, 20)
                            .padding(.bottom, 40)

                        // Placeholder Content (Rounded Rectangles)
                        // Use a loop to create multiple placeholders.
                        ForEach(0..<5) { _ in  // Create 5 placeholder blocks
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 245/255, green: 230/255, blue: 240/255)) // Lighter shade
                                .frame(height: 150) // Adjust height as needed
                                .padding(.horizontal)
                                .padding(.bottom, 10)

                            //add nested views within the RoundedRectange
                            VStack(alignment: .leading){
                                HStack{
                                    Circle()
                                        .fill(Color(red: 235/255, green: 220/255, blue: 230/255))
                                        .frame(width: 20, height: 20)
                                    
                                    Rectangle()
                                    .fill(Color(red: 235/255, green: 220/255, blue: 230/255))
                                    .frame(width: 100, height: 10)
                                    .cornerRadius(5)
                                }
                                .padding(.leading, 20)
                                .padding(.top,20)

                                Rectangle()
                                .fill(Color(red: 235/255, green: 220/255, blue: 230/255))
                                .frame(width: 250, height: 10)
                                .cornerRadius(5)
                                .padding(.leading, 20)
                                .padding(.top,5)

                                Rectangle()
                                .fill(Color(red: 235/255, green: 220/255, blue: 230/255))
                                .frame(width: 200, height: 10)
                                .cornerRadius(5)
                                .padding(.leading, 20)
                                .padding(.top,5)

                                Rectangle()
                                .fill(Color(red: 235/255, green: 220/255, blue: 230/255))
                                .frame(width: 280, height: 10)
                                .cornerRadius(5)
                                .padding(.leading, 20)
                                .padding(.top,5)

                                HStack{
                                    ForEach(0..<3) { _ in
                                        Circle()
                                            .fill(Color(red: 235/255, green: 220/255, blue: 230/255))
                                            .frame(width: 40, height: 40)
                                            .padding(.leading, 20)
                                            .padding(.top,5)

                                    }
                                }
                                .padding(.bottom, 20)

                            }
                            .frame(maxWidth: .infinity, alignment: .leading) //fill width of the rectangle
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color(red: 245/255, green: 230/255, blue: 240/255)))
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                            
                        }
                    }
                }

                // MARK: - Bottom Navigation (TabView)
                TabView(selection: $selectedTab) {
                    // Tab 1: For you
                    Text("For you")
                        .tabItem {
                            Image(systemName: "sparkles") // Replace with your icon
                            Text("For you")
                        }
                        .tag(0)

                    // Tab 2: Episodes
                    Text("Episodes Content")
                        .tabItem {
                            Image(systemName: "book.closed") // Replace with your icon
                            Text("Episodes")
                        }
                        .tag(1)

                    // Tab 3: Saved
                    Text("Saved Content")
                        .tabItem {
                            Image(systemName: "bookmark") // Replace with your icon
                            Text("Saved")
                        }
                        .tag(2)

                    // Tab 4: Interests
                    Text("Interests Content")
                        .tabItem {
                            Image(systemName: "number") // Replace with your icon
                            Text("Interests")
                        }
                        .tag(3)
                }
                .accentColor(.purple) // Set the active tab color
                //.background(Color.white) // Ensure tab bar has a background
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
