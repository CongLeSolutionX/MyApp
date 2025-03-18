//
//  GoogleNewsListView.swift
//  MyApp
//
//  Created by Cong Le on 3/18/25.
//

import SwiftUI

struct GoogleNewsListView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    // Top Bar (Assuming this is part of the ScrollView for simplicity)
                    HStack {
                        Image(systemName: "chevron.left") // Back button
                            .font(.title2)
                        Text("Full Coverage")
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: "square.and.arrow.up") // Share button
                        Image(systemName: "ellipsis") // More options
                    }
                    .padding(.horizontal)
                    
                    Text("News about Canadians • US")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    Text("Top news")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // First News Item (Large Image)
                    VStack(alignment: .leading) {
                        Image("My-meme-red-wine-glass") // Placeholder image name.  Replace with actual asset name.
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .clipped()
                            .cornerRadius(10)
                        
                        HStack {
                            Image("nlr_logo") // Placeholder logo
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("The National Law Review")
                                .font(.caption)
                        }
                        
                        Text("USCIS Issues Regulation Requiring Alien Registration")
                            .font(.headline)
                        
                        Text("Yesterday")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Spacer()
                            Image(systemName: "ellipsis")
                                .padding(.trailing,8)
                        }
                    }
                    .padding(.horizontal)
                    
                    
                    // Subsequent News Items (Smaller Image)
                    NewsItem(
                        logo: "cbc_logo", // Placeholder
                        source: "CBC News",
                        headline: "Canadians exempted from fingerprinting for U.S. travel under new Homeland Security rules",
                        timeAgo: "6 days ago",
                        image: "My-meme-heineken" // Placeholder
                    )
                    
                    NewsItem(
                        logo: "axios_logo", // Placeholder
                        source: "Axios",
                        headline: "Canadian snowbirds will have to register with U.S. under new Trump rule",
                        timeAgo: "4 days ago",
                        image: "My-meme-cordyceps" // Placeholder
                    )
                    
                }
            }
            .navigationBarHidden(true) // Hide the default navigation bar
        }
    }
}

// Helper View for News Items (Refactored for reusability)
struct NewsItem: View {
    let logo: String
    let source: String
    let headline: String
    let timeAgo: String
    let image: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading){
                    HStack {
                        Image(logo) // Placeholder logo
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text(source)
                            .font(.caption)
                    }
                    
                    
                    Text(headline)
                        .font(.headline)
                    
                    
                    Text(timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer() // Push image to the right
                
                Image(image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(10)
            }
            HStack{
                Spacer()
                Image(systemName: "ellipsis")
                    .padding(.trailing, 8)
            }
        }
        .padding(.horizontal)
    }
}

// Preview (for Xcode Canvas)
struct GoogleNewsListView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleNewsListView()
            .previewDevice("iPad Pro (11-inch) (4th generation)")
    }
}
