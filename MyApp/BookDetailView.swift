//
//  BookDetailView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

struct BookDetailView: View {
    // State variables for dynamic UI elements (replace with your actual data)
    @State private var isBookmarked = false
    @State private var currentPage = 235
    private let totalPages = 384
    private let bisacCodes = [
        "BISAC1: FICTION: Hispanic & Latino",
        "BISAC2: FICTION: Family Life / Siblings",
        "BISAC3: FICTION: Literary",
        "BISAC4: FICTION: African American & Black / Women",
        "BISAC5: FICTION: Magical Realism"
    ]

    var body: some View {
        ZStack {
            // Background Image (Blurred)
            Image("backgroundImage") // Replace "backgroundImage" with your actual image name
                .resizable()
                .scaledToFit()
                .blur(radius: 10)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        // Back Button
                        Button(action: {
                            // Handle back navigation here
                        }) {
                            Image(systemName: "arrow.left.circle")
                                .font(.title)
                                .foregroundColor(.black)
                        }

                        Spacer()

                        // Bookmark Button
                        Button(action: {
                            isBookmarked.toggle()
                        }) {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                .font(.title)
                                .foregroundColor(isBookmarked ? .green : .black)
                        }
                    }
                    .padding()

                    VStack(alignment: .center) {
                        // Book Cover Image
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 180, height: 270) // Adjust size as needed
                            .cornerRadius(10)

                        // Book Title
                        Text("Family Lore")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top)
                            .foregroundColor(.black)

                        // Author
                        Text("by Elizabeth Acevedo")
                            .font(.subheadline)
                            .foregroundColor(.black)

                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: geometry.size.width, height: 8)
                                    .foregroundColor(Color.gray.opacity(0.3))
                                    .cornerRadius(4)

                                Rectangle()
                                    .frame(width: geometry.size.width * CGFloat(currentPage) / CGFloat(totalPages), height: 8)
                                    .foregroundColor(.green)
                                    .cornerRadius(4)
                            }
                        }
                        .frame(height: 8)
                        .padding(.top, 5)
                        .padding(.bottom, 2)

                        // Page Count
                        Text("Pages: \(currentPage)/\(totalPages)")
                            .font(.caption)
                            .foregroundColor(.black)

                        // BISAC Codes
                        ForEach(bisacCodes, id: \.self) { code in
                            HStack {
                                Text(code)
                                    .font(.caption)
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                            .padding(.vertical, 2)
                        }
                        .padding(.top)

                        // Continue Button
                        Button(action: {
                            // Handle continue action here
                        }) {
                            Text("Continue")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.7))
                                .cornerRadius(25)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 20) // Add padding to avoid content being too close to the top
                .background(Color.white.opacity(0.85))
                .cornerRadius(30)
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
            }
        }
    }
}

struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailView()
    }
}
