//
//  MyApp.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI


//@available(iOS 18.0, *)
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            //ContentView()
            if #available(iOS 18.0, *) {
                InvitesIntroPageView()
                    .ignoresSafeArea(.all)
                    .preferredColorScheme(.dark)
            } else {
                ContentView()
            }
        }
    }
}
