//
//  ErrorView.swift
//  MyApp
//
//  Created by Cong Le on 3/16/25.
//

import SwiftUI

struct ErrorView: View {
    // State for the selected tab
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            VStack {
                // Top Bar (Approximation - System Status Bar)
                HStack {
                    Spacer()
                    Text("9:30")  // System time (static for now)
                        .font(.system(size: 15, weight: .regular))
                    Spacer()
                    Image(systemName: "battery.100")  // Example battery icon
                        .font(.system(size: 15))
                    Image(systemName: "wifi")  // Example wifi icon
                        .font(.system(size: 15))
                }
                .padding(.horizontal)
                .foregroundColor(.black)

                // Main Content
                HStack {
                    Image(systemName: "magnifyingglass")
                    Spacer()
                    Text("Now in iOS Devices")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: "person.circle")
                }
                .padding()
                .foregroundColor(.black)

                Spacer() // Push content to center

                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 100))
                    .foregroundColor(Color(red: 0.5, green: 0.2, blue: 0.5)) // Darker purple

                Text("Error")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.5, green: 0.2, blue: 0.5))

                Text("You aren't connected to the internet")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Spacer() // Push content to center

                // Tab Bar
                HStack {
                    //For You Tab
                    VStack{
                        Image(systemName: selectedTab == 0 ? "sun.max.fill" : "sun.max")
                        Text("For you")
                    }
                    .foregroundColor(selectedTab == 0 ? .purple : .gray)
                    .onTapGesture {
                        selectedTab = 0
                    }
                    Spacer()
                    
                    //Episodes Tab
                    VStack{
                        Image(systemName: selectedTab == 1 ? "book.closed.fill" : "book.closed")
                        Text("Episodes")
                    }
                    .foregroundColor(selectedTab == 1 ? .purple : .gray)
                    .onTapGesture {
                        selectedTab = 1
                    }
                    Spacer()

                    //Saved Tab
                    VStack{
                        Image(systemName: selectedTab == 2 ? "bookmark.fill" : "bookmark")
                        Text("Saved")
                    }
                    .foregroundColor(selectedTab == 2 ? .purple : .gray)
                    .onTapGesture {
                        selectedTab = 2
                    }
                    
                    Spacer()

                    //Interests Tab
                    VStack{
                        Image(systemName: selectedTab == 3 ? "number.square.fill" : "number.square")
                            .font(.system(size: 20))
                        Text("Interests")
                            
                    }
                    .foregroundColor(selectedTab == 3 ? .purple : .gray)
                    .onTapGesture {
                        selectedTab = 3
                    }
                }
                .padding()
            .frame(maxWidth: .infinity)

            }
            .padding(.top, 1) // Adjust top padding to account for the status bar
            // Apply the background gradient
            .background(
                LinearGradient(gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.9, blue: 0.9),  // Light pink
                    Color(red: 0.9, green: 0.8, blue: 0.9)   // Light purple
                ]), startPoint: .top, endPoint: .bottom)
            )
            .navigationBarHidden(true)  // Hide the default navigation bar
            
        }
        .navigationViewStyle(.stack) // Use stack navigation view style for iPad
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
            .previewDevice("iPad Pro (11-inch) (4th generation)") // Specify iPad for preview
    }
}
