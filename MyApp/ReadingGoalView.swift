//
//  ReadingGoalView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

struct ReadingGoalView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Reading Goals
                Text("Reading Goals")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 4)
                
                Text("Read every day, see your stats soar, and finish more books.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 16)
                
                // Today's Reading Progress
                VStack {
                    ZStack {
                        // Circular Progress Bar (Outer Ring)
                        Circle()
                            .stroke(lineWidth: 10)
                            .opacity(0.3)
                            .foregroundColor(.gray)
                        
                        // Circular Progress Bar (Progress)
                        Circle()
                            .trim(from: 0.0, to: 0.75) // Example: 75% progress (adjust as needed)
                            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                            .foregroundColor(.white)
                            .rotationEffect(Angle(degrees: -90)) // Start from the top
                        
                        // Inner Circle (for a cleaner look)
                        Circle()
                            .fill(Color.black) // Match background
                            .frame(width: 150, height: 150)
                        
                        VStack {
                            Text("Today's Reading")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("0:00") // Example: 0 minutes read
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("of your 5-minute goal") // Dynamic goal value
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: 180, height: 180)
                    .padding()
                }
                .frame(maxWidth: .infinity) // Center the ZStack horizontally
                .padding(.vertical)
                
                // Keep Reading Button
                Button(action: {
                    // Handle "Keep Reading" action
                }) {
                    VStack(alignment:.leading) {
                        Text("Keep Reading")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("Ethics for the Information Age (8th Editi...")
                            .font(.subheadline)
                            .lineLimit(1) // Truncate with ellipsis
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading) // Ensure full width
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray6)))
                    
                }
                .buttonStyle(PlainButtonStyle())  //Removes blue tint.
                .padding(.bottom)
                
                // Weekday Buttons
                HStack {
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                        Text(day)
                            .font(.headline)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding(.vertical, 8) // Padding for touch target
                            .background(Circle().fill(Color(UIColor.systemGray5)))
                    }
                }
                .padding(.bottom)
                
                // Start a new streak
                Button(action: {}) {
                    HStack {
                        Text("Start a new streak")
                            .font(.headline)
                            .foregroundColor(.white)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Read daily and set new records.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Books Read This Year
                VStack(alignment: .leading) {
                    Text("Books Read This Year")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                        .padding(.bottom, 8)
                    
                    HStack(spacing: 20) {
                        ForEach(1..<4) { index in
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: 100, height: 150)
                                .overlay(Text("\(index)").font(.largeTitle).foregroundColor(.gray)) // Example book number
                        }
                    }
                }
                .padding(.bottom)
            }
            .padding()
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    createTabBarButton(imageName: "house.fill", title: "Home")
                    Spacer()
                    createTabBarButton(imageName: "books.vertical.fill", title: "Library")
                    Spacer()
                    createTabBarButton(imageName: "bag.fill", title: "Book Store")
                    Spacer()
                    createTabBarButton(imageName: "headphones", title: "Audiobooks")
                    Spacer()
                    createTabBarButton(imageName: "magnifyingglass", title: "Search")
                }
            }
        }
        .accentColor(.white)  //Set the navigation title color
    }
    
    private func createTabBarButton(imageName: String, title: String) -> some View{
        Button(action: {}) {
            VStack {
                Image(systemName: imageName)
                Text(title)
                    .font(.caption)
            }
        }
    }
}
// MARK: -  Preview
struct ReadingGoalView_Previews: PreviewProvider {
    static var previews: some View {
        ReadingGoalView()
            .preferredColorScheme(.dark)
    }
}
