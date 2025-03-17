//
//  ForYouView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

struct ForYouView: View {
    @State private var searchText: String = ""
    @State private var isCompactView: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    // Top Bar (Search, Title, Profile)
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Text("For You")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: "person.circle")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)

                    // Filter Bar (Newest First, Compact View, More Options)
                    HStack {
                        Button(action: {
                            // Handle sorting
                        }) {
                            HStack {
                                Text("Newest first")
                                Image(systemName: "arrow.up.arrow.down")
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(20)
                        
                        Spacer()

                        Button(action: {
                            isCompactView.toggle()
                        }) {
                            Image(systemName: isCompactView ? "rectangle.grid.1x2.fill" : "rectangle.grid.1x2")
                        }
                        .foregroundColor(.gray)

                        Button(action: {
                            // Show more options
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)

                    // Updates Notification
                    HStack {
                        Image(systemName: "3.circle.fill")
                            .foregroundColor(.red)
                        Text("updates since you last vist")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)

                    // Main Content Card
                    ZStack(alignment: .topTrailing) { // Use ZStack for the bookmark icon
                        VStack(alignment: .leading) {
                            // Image Placeholder
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.teal.opacity(0.3))  // Placeholder color
                                    .aspectRatio(1.0, contentMode: .fit)

                                Image(systemName: "clock.fill") // Placeholder for the Wear OS image
                                    .resizable()
                                    .scaledToFit()
                                    .padding(40)
                                    .foregroundColor(.white)
                                
                                RoundedRectangle(cornerRadius: 25)
                                   .stroke(Color.white, lineWidth: 3) // Inner border

                            }

                            Text("Author") // Placeholder for the author's name
                                .font(.caption)
                                .foregroundColor(.gray)

                            Text("New Compose for Wear OS codelab")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.top, 2)

                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.gray)
                                Text("January 1, 2021 developer.android.com")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 1)

                            Text("In this codelab, you can learn how Wear OS can work with Compose, what Wear OS specific composables are available, and more!")
                                .font(.body)
                                .foregroundColor(.gray)
                                .padding(.top, 2)

                            // Topic Tags
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    TopicTag(title: "Topic")
                                    TopicTag(title: "Compose")
                                    TopicTag(title: "Events")
                                    TopicTag(title: "Performance")
                                    Button(action: {
                                        //show more options
                                    }) {
                                        Image(systemName: "ellipsis")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25).fill(Color.black))

                        // Bookmark Icon
                        Button(action: {
                            // Handle bookmark action
                        }) {
                            Image(systemName: "bookmark")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .padding(10) // Padding for the bookmark icon itself
                    }
                    .padding(.horizontal)

                    // Add more content cards here if needed...
                }
                .padding(.top) // Add padding at the top of the VStack
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))  // Extend background to safe area
            .navigationBarHidden(true) // Hide the default navigation bar

            // Tab Bar
            HStack {
                TabBarButton(iconName: "waveform.path.ecg", label: "For you", isActive: true)
                TabBarButton(iconName: "book", label: "Episodes")
                TabBarButton(iconName: "bookmark", label: "Saved")
                TabBarButton(iconName: "number", label: "Interests")
            }
            .padding()
            .background(Color.black)
            .frame(maxWidth: .infinity)
            .border(Color.gray.opacity(0.3), width: 1)
        }
    }
}

// Helper Views

struct TopicTag: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.purple.opacity(0.5)) // Placeholder color
            .cornerRadius(20)
    }
}

struct TabBarButton: View {
    let iconName: String
    let label: String
    var isActive: Bool = false

    var body: some View {
        Button(action: {
            // Handle tab selection
        }) {
            VStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(isActive ? .pink : .gray)
                Text(label)
                    .font(.caption)
                    .foregroundColor(isActive ? .pink : .gray)
            }
            .frame(maxWidth: .infinity) // Make buttons take equal width
        }
    }
}

struct ForYouView_Previews: PreviewProvider {
    static var previews: some View {
        ForYouView()
            .preferredColorScheme(.dark) // Set dark mode for preview
    }
}
