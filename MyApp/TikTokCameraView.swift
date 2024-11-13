//
//  TikTokCameraView.swift
//  MyApp
//
//  Created by Cong Le on 11/13/24.
//

import SwiftUI

struct CameraView: View {
    var body: some View {
        ZStack {
            // Full-Screen Camera View
            Color.black // Placeholder for camera feed
                .edgesIgnoringSafeArea(.all)

            // Top Bar
            VStack {
                HStack {
                    Text("9:41")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Text("Sounds")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                .padding(.top, 60) // Adjust top padding for status bar
                Spacer()
            }

            VStack {
                Spacer()

                // Main Control Panel
                HStack {
                    Button(action: {
                        // Action for Effects
                    }) {
                        Image(systemName: "sparkles")
                            .font(.title)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    // Recording Button
                    Button(action: {
                        // Action for recording
                    }) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 80, height: 80)
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    }
                    
                    Spacer()

                    Button(action: {
                        // Action for Upload
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding()

                // Timer and Templates
                HStack {
                    Text("60s")
                        .foregroundColor(.white)
                    Spacer()
                    Text("15s")
                        .foregroundColor(.white)
                    Spacer()
                    Text("Templates")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    CameraView()
}
