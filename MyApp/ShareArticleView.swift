//
//  ShareArticleView.swift
//  MyApp
//
//  Created by Cong Le on 3/26/25.
//

import SwiftUI

struct ShareArticleView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                HStack {
                    Text("Share This Article")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        // Handle close action
                        print("Close button tapped")
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                }
                .padding()

                // Placeholder for Mortgage Rates Content (replace with actual view)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.darkGray))
                    .frame(height: 150)
                    .overlay(
                        Text("Mortgage Rates Summary (Placeholder)")
                            .foregroundColor(.white)
                    )
                    .padding(.horizontal)

                VStack(spacing: 10) {
                    ShareOptionRow(text: "Facebook", imageName: "facebook.logo") {
                        // Handle Facebook share
                        print("Share to Facebook")
                    }
                    ShareOptionRow(text: "Twitter", imageName: "twitter") {
                        // Handle Twitter share
                        print("Share to Twitter")
                    }
                    ShareOptionRow(text: "Copy link", imageName: "link") {
                        // Handle copy link
                        print("Copy link")
                    }
                    ShareOptionRow(text: "SMS", imageName: "message.fill") {
                        // Handle SMS share
                        print("Share via SMS")
                    }
                    ShareOptionRow(text: "Email", imageName: "envelope.fill") {
                        // Handle Email share
                        print("Share via Email")
                    }
                    ShareOptionRow(text: "More", imageName: "ellipsis") {
                        // Handle more options
                        print("Show more options")
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 50) // Adjust for status bar
        }
    }
}

struct ShareOptionRow: View {
    let text: String
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: imageName)
                    .foregroundColor(.blue) // Adjust color as needed
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
}

struct ShareArticleView_Previews: PreviewProvider {
    static var previews: some View {
        ShareArticleView()
            .preferredColorScheme(.dark)
    }
}
