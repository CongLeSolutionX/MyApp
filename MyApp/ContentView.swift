//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        AnimatedSplashScreen(color: "Orange", logo: "SwiftLogo",animationTiming: 2.65) {
            // MARK: Your Home View
            ScrollView{
                VStack(spacing: 15){
                    ForEach(1...5,id: \.self){index in
                        GeometryReader{proxy in
                            let size = proxy.size
                            Image("Thumb\(index+5)")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: size.width, height: size.height)
                                .cornerRadius(15)
                        }
                        .frame(height: 200)
                    }
                }
                .padding(15)
            }
        } onAnimationEnd: {
            print("Animation Ended")
        }
    }
}
// MARK: - Previews

// After iOS 17, we can use this syntax for preview:
#Preview {
    ContentView()
}


// Before iOS 17, use this syntax for preview UIKit view controller
struct UIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerWrapper()
    }
}
