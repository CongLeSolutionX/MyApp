//
//  SavedStateComplexedView.swift
//  MyApp
//
//  Created by Cong Le on 3/16/25.
//

import SwiftUI

struct SavedStateComplexedView: View {
    var body: some View {
        VStack(spacing: 0) { // Remove extra spacing between major sections

            // Top Navigation Bar
            HStack {
                Image(systemName: "magnifyingglass")
                Spacer()
                Text("Saved")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "person.circle")
            }
            .padding()
            .background(Color.black) // Set background color
            .foregroundColor(.white)

            // Main Content Card
            VStack(alignment: .leading) {
                ZStack {
                    Image("watch_image") // Replace with your actual image asset
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(15)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }

                Text("Author")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("New Compose for Wear OS codelab")
                    .font(.title2)
                    .fontWeight(.bold)

                HStack {
                    Image(systemName: "circle.fill")
                         .resizable()
                         .frame(width: 8, height: 8)
                         .foregroundColor(.purple)
                    Text("January 1, 2021  developer.android.com")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Image(systemName: "bookmark")
                }

                Text("In this codelab, you can learn how Wear OS can work with Compose, what Wear OS specific composables are available, and more!")
                    .font(.body)
                    .foregroundColor(.gray)

                HStack {
                    TagView(text: "Topic")
                    TagView(text: "Compose")
                    TagView(text: "Events")
                    TagView(text: "Performance")
                    Spacer()
                    Image(systemName: "ellipsis")
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 25).fill(Color.gray.opacity(0.2)))
            .padding()
            .foregroundColor(.white)

            Spacer() // Push the bottom nav bar to the bottom

            // Bottom Navigation Bar
            HStack {
                BottomNavItem(imageName: "square.grid.2x2", label: "For you")
                BottomNavItem(imageName: "book", label: "Episodes")
                BottomNavItem(imageName: "bookmark.fill", label: "Saved", selected: true)
                BottomNavItem(imageName: "number", label: "Interests")
            }
            .padding(.top)
            .background(Color.black) // Set background color

        }
        .background(Color.black) // Set overall background color
        .edgesIgnoringSafeArea(.bottom) // Extend to bottom edge
    }
}

struct TagView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(RoundedRectangle(cornerRadius: 15).fill(Color.pink.opacity(0.5)))
            .foregroundColor(.black)
    }
}

struct BottomNavItem: View {
    let imageName: String
    let label: String
    var selected: Bool = false

    var body: some View {
        VStack {
            Image(systemName: imageName)
                .foregroundColor(selected ? .purple : .gray)
            Text(label)
                .font(.caption)
                .foregroundColor(selected ? .purple : .gray)
        }
        .frame(maxWidth: .infinity) // Important for equal spacing
    }
}

struct SavedStateComplexedView_Previews: PreviewProvider {
    static var previews: some View {
        SavedStateComplexedView()
    }
}
