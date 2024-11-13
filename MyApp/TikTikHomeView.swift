//
//  TikTikHomeView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

struct TikTikHomeView: View {
    var body: some View {
        ZStack {
            // Background Color set to Black
            Color.black
                .ignoresSafeArea()

            VStack {
                // Top Bar
                HStack {
                    Text("Following")
                    Spacer()
                    Text("For You")
                }
                .padding()
                .foregroundColor(.white)
                .font(.headline)

                Spacer()

                // Center Content
                VStack {
                    Spacer()
                    // Profile Picture and User Info
                    HStack {
                        Image("Round_logo")
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 50, height: 50)
                        VStack(alignment: .leading) {
                            Text("@IAskedAIBots")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Text("1-28")
                                .font(.caption)
                                .foregroundColor(.white)
                                .opacity(0.7)
                        }
                    }
                    .padding()

                    // Hashtags and Music Info
                    Text("#avicii #wflove")
                        .foregroundColor(.white)
                    Text("🎵 Avicii - Waiting For Love (ft.)")
                        .foregroundColor(.white)
                        .font(.caption)

                    // Interaction Buttons
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                        }
                        Text("4445")
                            .foregroundColor(.white)

                        Spacer()

                        Button(action: {}) {
                            Image(systemName: "message")
                                .foregroundColor(.white)
                        }
                        Text("64")
                            .foregroundColor(.white)

                        Spacer()

                        Button(action: {}) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .font(.body)

                    // Bottom Navigation
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "house")
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white) // Set icon color to white
                        }
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "envelope")
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "person.circle")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.8)) // Background for bottom navigation
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TikTikHomeView()
    }
}

// After iOS 17, we can use this syntax for preview:
#Preview {
    TikTikHomeView()
}
