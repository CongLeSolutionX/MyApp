//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView { // Added ScrollView to accommodate all elements
            VStack(alignment: .leading, spacing: 20) {
                // Text Examples
                Text("Hello, SwiftUI!")
                    .font(.title)
                    .foregroundColor(.blue)
                    .bold()
                
                Text("This is a multiline text example that demonstrates line limiting.")
                    .lineLimit(2)
                
                // Image Example
                Image("yourImageName") // Replace with your image name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                
                // Button Example
                Button("Click Me") {
                    print("Button tapped!")
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                
                // Stack Examples
                VStack {
                    Text("VStack Top")
                    Spacer()
                    Text("VStack Bottom")
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("HStack Example")
                }
                
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 100, height: 100)
                    Text("ZStack")
                        .foregroundColor(.white)
                }
                
                // Spacer and Divider Examples
                VStack {
                    Text("Spacer Top")
                    Spacer()
                    Text("Spacer Bottom")
                }
                
                HStack {
                    Text("Divider Left")
                    Divider()
                    Text("Divider Right")
                }
                
                // Background and Overlay Examples
                Text("Background and Overlay")
                    .background(Color.green)
                    .padding()
                    .background(Color.orange)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.purple, lineWidth: 2)
                    )
            }
            .padding()
        }
    }
}

// Before iOS 17, use this syntax for preview UIKit view controller
struct UIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerWrapper()
    }
}

// After iOS 17, we can use this syntax for preview:
#Preview {
    ContentView()
}
