//
//  BookDetailView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

struct BookDetailView: View {
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.8, green: 0.6, blue: 0.2), Color(red: 0.5, green: 0.3, blue: 0.1)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading) {
                    // Top Navigation Buttons (placed in HStack for correct layout)
                    HStack {
                        Button(action: {
                            // Handle close action
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .padding()
                        }
                        Spacer()
                        Button(action: {
                            // Handle add action
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .padding()
                        }
                        Button(action: {
                            // Handle more options action
                        }) {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    .padding(.horizontal)

                    // Book Cover Image
                    Image("bookCover")  // Replace "bookCover" with the actual asset name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 300)
                        .padding(.top)
                        .frame(maxWidth: .infinity) // Center the image horizontally

                    // Book Title (with link)
                    Button(action: {
                        // Handle link action
                    }) {
                        Text("PYTHON ESSENTIALS")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Image(systemName: "chevron.right") // Add the chevron
                            .foregroundColor(.white)
                    }
                    .padding(.top)
                    .padding(.horizontal)

                    // Book Description
                    Text("Python Essentials 1: The Official OpenEDG Python Institute beginners course with practical... Aligned with PCEP-30-0X")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.top, 2)
                        .padding(.horizontal)

                    // Author Link
                    Button(action: {
                        // Handle author link action
                    }) {
                        Text("The OpenEDG Python Institute")
                            .font(.body)
                            .foregroundColor(.white)
                            .underline() //Added underline.
                        Image(systemName: "chevron.right") // Add the chevron
                            .foregroundColor(.white)

                    }
                    .padding(.top, 2)
                    .padding(.horizontal)
                    
                    Text("Computers & Internet")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 2)
                        .padding(.horizontal)

                    // Book Info
                    HStack {
                        Text("Book")
                            .font(.headline)
                            .foregroundColor(.white)
                        Image(systemName: "info.circle") //info circle
                            .foregroundColor(.white)
                    }
                    .padding(.top, 8)
                    .padding(.horizontal)

                    Text("520 Pages")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal)

                    // Action Buttons (Sample and Price)
                    HStack {
                        Button(action: {
                            // Handle sample action
                        }) {
                            Text("Sample")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 40)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(20)
                        }

                        Spacer() // Pushes the buttons apart

                        Button(action: {
                            // Handle purchase action
                        }) {
                            Text("$19.99")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 40)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    //From the Publisher
                    Text("From the Publisher")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    Text("Unleash Your Potential and Transform Your Life with Python Essentials 1 — Your Gateway to Python Proficiency.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal)
                        .padding(.bottom)

                   
                }
            }

            // Tab Bar (placed at the bottom, outside the ScrollView)
            VStack {
                Spacer() // Push the tab bar to the bottom
                HStack {
                    Button(action: {
                        // Handle home action
                    }) {
                        VStack {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)

                    Button(action: {
                        // Handle library action
                    }) {
                        VStack {
                            Image(systemName: "books.vertical.fill")
                            Text("Library")
                        }
                        .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)

                    Button(action: {
                        // Handle book store action
                    }) {
                        VStack {
                            Image(systemName: "bag.fill")
                            Text("Book Store")
                        }
                        .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)

                    Button(action: {
                        // Handle audiobooks action
                    }) {
                        VStack {
                            Image(systemName: "headphones")
                            Text("Audiobooks")
                        }
                        .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)

                    Button(action: {
                        // Handle search action
                    }) {
                        VStack{
                            Image(systemName: "magnifyingglass")
                            Text("Search")
                        }
                        .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, 10)
                .background(Color.black.opacity(0.8)) // Tab bar background
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

// MARK: - Preview Provider (for Xcode previews)
struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailView()
            .previewDevice("iPhone 14 Pro") // You might need to adjust

        BookDetailView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)") // Example iPad
    }
}
