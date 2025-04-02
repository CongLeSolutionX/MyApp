//
//  HomeTestingView.swift
//  MyApp
//
//  Created by Cong Le on 4/2/25.
//
import SwiftUI


struct HomeTestingView: View {
    var body: some View {
        ZStack(alignment: .bottom) {

            // --- TEMPORARY TEST ---
            Color.blue // Replace ScrollView contents with a simple Color
            Text("Test Content Visible?")
                 .padding(50)
                 .background(Color.yellow)
            // --- END TEMPORARY TEST ---

            // --- TEMPORARY TEST ---
                 Rectangle() // Replace TabBarView with simple Rectangle
                     .fill(Color.red.opacity(0.5))
                     .frame(height: 50)
            // --- END TEMPORARY TEST ---

            // TabBarView() // Comment out original TabBarView

        } // End ZStack
        .background(Color(UIColor.systemGray6)) // Keep background on ZStack
        .edgesIgnoringSafeArea(.bottom)       // Keep edge ignoring
    }
}

#Preview {
    HomeTestingView()
}
