//
//  HomeView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    // Top Bar (Status Bar is handled by the system)

                    // Title
                    Text("Home")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, 20) // Add top padding

                    // User Profile and Points (Top Right) - Using HStack
                    HStack {
                        Spacer() // Push to the right

                        // Points (Circular)
                        ZStack {
                            Circle()
                                .fill(.gray.opacity(0.2))
                                .frame(width: 30, height: 30)
                            Text("0")  // Placeholder for actual points
                                .font(.system(size: 12))
                                .fontWeight(.bold)
                        }

                        // Profile Image (Circular)
                        Image(systemName: "person.crop.circle.fill") // Placeholder
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)

                    }
                    .padding(.horizontal)

                    // Continue Section
                    Text("Continue")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)

                    // Continue Card
                    ContinueCardView()
                        .padding(.horizontal)

                    // Top Picks Section
                    Text("Top Picks")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            BookCardView(title: "Why Machines Learn", subtitle: "The Elegant Math Behind Modern AI", author: "Anil Ananthaswamy", category: "Computers & Internet")
                            BookCardView(title: "C.B...", subtitle: "...", author: "JOHN SANDFORD", category: "Current Bests") // Truncated for brevity, add full details as needed
                            // Add more BookCardViews as needed
                        }
                        .padding(.horizontal)
                    }

                    // For You Section
                    HStack {
                        Text("For You")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()  // Push "arrow.right" to the right
                        Image(systemName: "arrow.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    Text("Recommendations based on books you've purchased or shown interest in.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20) // Add some bottom padding to prevent content sticking to the tab bar
            }
            .navigationBarHidden(true) // Hide the default navigation bar
            // Tab Bar
            .overlay(
                TabBarView()
                , alignment: .bottom)

        }
    }
}

// MARK: - Subviews

// Continue Card View
struct ContinueCardView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 100)

            HStack {
                // Placeholder for Book Image
                Image(systemName: "book.closed") // Placeholder
                    .resizable()
                    .frame(width: 60, height: 80)
                    .padding(.leading)

                VStack(alignment: .leading) {
                    Text("Ethics for the Information Age (...")
                        .font(.headline)
                        .lineLimit(2)
                    Text("Unknown Author")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("PDF • 5%")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical)
                Spacer() // Push content to left, icons to right

                VStack {
                    Image(systemName: "icloud.and.arrow.down")
                        .foregroundColor(.gray)
                    Image(systemName: "ellipsis")
                       .rotationEffect(.degrees(90)) // Rotate to vertical
                       .foregroundColor(.gray)
                }
                .padding(.trailing)
            }
        }
    }
}

// Book Card View
struct BookCardView: View {
    let title: String
    let subtitle: String
    let author: String
    let category: String

    var body: some View {
        VStack(alignment: .leading) {
            // Placeholder for Book Image (Ideally, you'd use AsyncImage here)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 160, height: 200)

                 Image(systemName: "book.fill") // Replace with actual book cover
                 .resizable()
                 .scaledToFit()
                .frame(width: 150, height: 190) // Adjust as needed

            }

            Text(title)
                .font(.headline)
                .lineLimit(2)
                .frame(width: 160, alignment: .leading)

            Text(author)
              .font(.subheadline)
              .lineLimit(1)
              .foregroundColor(.gray)
              .frame(width: 160, alignment: .leading)

            Text(category)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray) // Added background
                .cornerRadius(4)
                .padding(.top, 2)
                .frame(width: 160, alignment: .leading)

            Text("Explore best-selling books in this genre.")
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)
                .frame(width: 160, alignment: .leading)
        }
        .frame(width: 180) // Set a fixed width for the card
    }
}

// Tab Bar View
struct TabBarView: View {
    var body: some View {
        HStack {
            TabBarButton(imageName: "house.fill", title: "Home")
            Spacer()
            TabBarButton(imageName: "books.vertical.fill", title: "Library")
            Spacer()
            TabBarButton(imageName: "bag.fill", title: "Book Store")
            Spacer()
            TabBarButton(imageName: "headphones", title: "Audiobooks")
            Spacer()
            TabBarButton(imageName: "magnifyingglass", title: "Search")
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.5)) // Semi-transparent background
    }
}

// Tab Bar Button
struct TabBarButton: View {
    let imageName: String
    let title: String

    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
            Text(title)
                .font(.caption)
        }
        .foregroundColor(.white)
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark) // For dark mode preview
    }
}
