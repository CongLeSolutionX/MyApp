//
//  AuthorDetailView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

struct AuthorView: View {
    @State private var isFollowing = true // State for the follow button

    var body: some View {
        NavigationView { // Use NavigationView for navigation bar
            ScrollView {
                VStack(alignment: .leading) { // Use .leading alignment for the entire content
                    HStack {
                        Image(systemName: "chevron.left") // Back button
                            .font(.title2)
                        Spacer()
                        Button(action: {
                            isFollowing.toggle()
                        }) {
                            HStack {
                                if isFollowing {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                                Text(isFollowing ? "Following" : "Follow")
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(isFollowing ? Color.pink.opacity(0.2) : Color.gray.opacity(0.2)) // Conditional background
                            .foregroundColor(isFollowing ? .pink : .gray)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }

                    }
                    .padding(.horizontal)
                    .padding(.top)
                    

                    VStack(alignment: .center) { // Centered content
                        Image(systemName: "person.crop.circle.fill") // Profile picture
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.purple)

                        Text("Cong Le") // Name
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top)

                        Text("iOS Developer Advocate @google, sketch comedienne, opera singer. BLM.") // Bio
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 2)
                    }
                    .frame(maxWidth: .infinity) // Ensure centering

                    VStack(alignment: .leading){
                        HStack { // Link section
                            Text("developers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Image(systemName: "link") // Replace with your actual image
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            
                            VStack(alignment: .leading) {
                                Text("Link title") // Link title
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                Text("developer.CongLeSolutionX.tech") // Link URL
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal)

                    HStack { // Sort and View options
                        HStack{
                            Text("Newest first")
                            Image(systemName: "chevron.down")
                        }
                        .font(.subheadline)
                        
                        
                        Spacer()

                        HStack {
                            Text("Compact view")
                            Image(systemName: "line.3.horizontal")
                        }
                        .font(.subheadline)
                        
                    }
                    .padding(.horizontal)
                    .foregroundColor(.secondary)

                    // Placeholder for Card view
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.teal.opacity(0.8))
                            .frame(height: 250)
                        Image(systemName: "desktopcomputer")  // Replace with a suitable image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .shadow(radius: 5)

                    Spacer() // Push content to the top
                }
                .padding(.top, 1)
                
            }
           
            
            .navigationBarHidden(true)  //Hide default bar
            
            .toolbar { // Custom bottom toolbar
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {}) {
                        VStack {
                            Image(systemName: "person.crop.circle") // Replace with your actual image
                            Text("For you")
                        }
                    }
                    Spacer()
                    Button(action: {}) {
                        VStack {
                            Image(systemName: "book") // Replace with your actual image
                            Text("Episodes")
                        }
                    }
                    Spacer()
                    Button(action: {}) {
                        VStack {
                            Image(systemName: "bookmark") // Replace with your actual image
                            Text("Saved")
                        }
                    }
                    Spacer()
                    Button(action: {}) {
                        VStack {
                            Image(systemName: "number.circle") // Replace with your actual image
                            Text("Interests")
                        }
                        .foregroundColor(.pink)
                    }
                }
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorView()
            .previewDevice("iPhone 13") // Specify preview device

        AuthorView()
            .previewDevice("iPad Pro (11-inch) (4th generation)") // iPad Preview
    }
}
