//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

// Step 2: Use in SwiftUI view
struct ContentView: View {
    @State private var isShowingDetails = false
    @State private var userName = ""
    @State private var rotationAngle: Double = 0
    @State private var isZoomed = false
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            // .disabled(_:)
            Button("Show Details") {
                isShowingDetails.toggle()
            }
            .disabled(userName.isEmpty) // Disable button if userName is empty
            
            // .hidden(_:)
            if isShowingDetails {
                Text("Details are shown!")
                    .transition(.opacity) // Use a transition for appearance/disappearance
            }
            
            // .opacity(_:)
            Image(systemName: "cloud.sun.fill")
                .opacity(isLoading ? 0.5 : 1.0) // Reduce opacity while loading
            
            // .scaleEffect(_:)
            Circle()
                .fill(Color.blue)
                .frame(width: 50, height: 50)
                .scaleEffect(isZoomed ? 1.5 : 1.0)
                .onTapGesture {
                    withAnimation {
                        isZoomed.toggle()
                    }
                }
            
            // .rotationEffect(_:)
            Rectangle()
                .fill(Color.red)
                .frame(width: 100, height: 50)
                .rotationEffect(.degrees(rotationAngle))
                .onTapGesture {
                    withAnimation {
                        rotationAngle += 45
                    }
                }
            
            
            // .blur(radius:) and .shadow(radius:)
            Text("Hello, SwiftUI!")
                .font(.largeTitle)
                .blur(radius: isLoading ? 5 : 0)
                .shadow(radius: 5)
            
            // .animation(_:)
            TextField("Enter your name", text: $userName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .animation(.spring(), value: userName) // Animate changes to the text field
            
            // .gesture(_:)
            Image(systemName: "hand.point.right.fill")
                .font(.largeTitle)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Update view based on drag gesture
                        }
                )
            
            // .onAppear(_:) and .onDisappear(_:)
            Text("This view appears and disappears")
                .onAppear {
                    isLoading = true // Simulate loading
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isLoading = false
                    }
                }
                .onDisappear {
                    // Perform cleanup when the view disappears
                }
            
            // .onChange(of:)
            Stepper("Rotation Angle: \(Int(rotationAngle))", value: $rotationAngle, step: 45)
                .onChange(of: rotationAngle) { oldValue, newValue in
                    // React to changes in rotationAngle
                    print("Rotation angle changed from \(oldValue) to \(newValue)")
                }
        }
        .padding()
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
