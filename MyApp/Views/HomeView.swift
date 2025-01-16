//
//  HomeView.swift
//  MyApp
//
//  Created by Cong Le on 1/11/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator

    var body: some View {
        VStack(spacing: 20) {
            Text("Home View")
                .font(.largeTitle)

            Button("Go to Settings") {
                appCoordinator.showSettings()
            }
            .buttonStyle(PrimaryButtonStyle())

            Button("View Profile") {
                appCoordinator.showProfile(for: 42) // Example user ID
            }
            .buttonStyle(PrimaryButtonStyle())

            Button("View Product Detail") {
                appCoordinator.showProductDetail(for: 101) // Example product ID
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }
}
