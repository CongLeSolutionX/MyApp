//
//  ProfileView.swift
//  MyApp
//
//  Created by Cong Le on 1/15/25.
//

import SwiftUI

struct ProfileView: View {
    let userID: Int

    var body: some View {
        VStack {
            Text("Profile View")
                .font(.largeTitle)
            Text("User ID: \(userID)")
        }
        .padding()
    }
}

