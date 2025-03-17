//
//  ShareSheetView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

struct ShareSheetView: View {
    var body: some View {
        VStack {
            // Handle Bar
            RoundedRectangle(cornerRadius: 3.0)
                .frame(width: 40, height: 5)
                .foregroundColor(Color.gray)
                .padding(.top, 10)

            VStack(spacing: 20) {
                // Preview Card
                VStack(alignment: .leading) {
                    HStack {
                        Image("albumArt") // Replace with your image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)

                        VStack(alignment: .leading) {
                            Text("Ngày Mưa Ấy")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("Vicky Nhung")
                                .foregroundColor(.gray)
                            HStack {
                                Image("spotify-logo") // Replace with your Spotify logo asset
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                Text("Spotify")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)

                // Color Options
                HStack(spacing: 20) {
                    Button(action: {}) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 30, height: 30)
                            .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    }
                    Button(action: {}) {
                        Circle()
                            .fill(Color.orange.opacity(0.7)) // Brownish color
                            .frame(width: 30, height: 30)
                            .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    }
                    Button(action: {}) {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 30, height: 30)
                            .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    }
                    Button(action: {}) {
                        Circle()
                            .fill(Color.gray.opacity(0.2)) // Placeholder for color picker
                            .frame(width: 30, height: 30)
                            .overlay(Image(systemName: "eyedropper").foregroundColor(.black))
                            .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    }
                }

                // Share Actions Grid (Simplified HStack for example)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ShareActionButton(iconName: "link", text: "Copy link")
                    ShareActionButton(iconName: "tiktok-logo", text: "TikTok") //replace with your asset
                    ShareActionButton(iconName: "message-logo", text: "Messages") //replace with your asset
                    ShareActionButton(iconName: "facebook-stories-logo", text: "Stories") //replace with your asset
                    ShareActionButton(iconName: "whatsapp-logo", text: "WhatsApp") //replace with your asset
                    ShareActionButton(iconName: "ellipsis.circle.fill", text: "More")
                }
                .padding(.horizontal, 10)

            }
            .padding()
        }
        .presentationDetents([.medium, .large]) // Set sheet size
        .presentationDragIndicator(.visible) // Show handle bar
    }
}

struct ShareActionButton: View {
    var iconName: String
    var text: String

    var body: some View {
        Button(action: {
            print("Share to \(text)") // Placeholder action
        }) {
            VStack {
                Image(iconName) //replace with your asset or SF Symbol if applicable
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                Text(text)
                    .font(.caption)
                    .foregroundColor(.black)
            }
        }
    }
}
