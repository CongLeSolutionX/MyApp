//
//  Home.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI

struct Home: View {
    /// Setting true will work on simulator and actual device but on previews!
    @State private var showMiniPlayer: Bool = false
    @State private var hideMiniPlayer: Bool = false
    var body: some View {
        /// Dummy Tab View
        TabView {
            Tab.init("Home", systemImage: "house") {
                NavigationStack {
                    Button("Hide Mini Player") {
                        withAnimation(.snappy) {
                            hideMiniPlayer.toggle()
                        }
                    }
                    .navigationTitle("Home")
                }
            }
            
            Tab.init("Search", systemImage: "magnifyingglass") {
                Text("Search")
            }
            
            Tab.init("Notifications", systemImage: "bell") {
                Text("Notifications")
            }
            
            Tab.init("Settings", systemImage: "gearshape") {
                Text("Settings")
            }
        }
        .universalOverlay(show: $showMiniPlayer) {
            ExpandableMusicPlayer(show: $showMiniPlayer, hideMiniPlayer: $hideMiniPlayer)
        }
        .onAppear {
            showMiniPlayer = true
        }
    }
}

#Preview {
    RootView {
        Home()
    }
}
