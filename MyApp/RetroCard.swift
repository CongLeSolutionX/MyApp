//
//  RetroCard.swift
//  MyApp
//
//  Created by Cong Le on 3/25/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack {
                RetroCard(title: "RUNAWAY", subtitle: "Dimension", backgroundImage: "runaway_bg")
                    .padding()
                
                RetroCard(title: "TOKYO", subtitle: "Showdown", backgroundImage: "tokyo_bg")
                    .padding()
                
                RetroCard(title: "DANGER", subtitle: "ZONE", backgroundImage: "danger_bg")
                    .padding()
            }
        }
    }
}

struct RetroCard: View {
    let title: String
    let subtitle: String
    let backgroundImage: String

    var body: some View {
        ZStack {
            Image(backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .clipped()

            VStack {
                Text(title)
                    .font(.system(size: 50, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 5, x: 0, y: 2)

                Text(subtitle)
                    .font(.system(size: 30, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(.neonPink)
                    .shadow(color: .black, radius: 3, x: 0, y: 2)
            }
            .multilineTextAlignment(.center)
        }
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

extension Color {
    static let neonPink = Color(red: 1.0, green: 0.3, blue: 0.8)
}

#Preview {
    ContentView()
}
