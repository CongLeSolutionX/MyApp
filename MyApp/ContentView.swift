//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

struct ContentView: View {
    /// View Properties
    @State private var trigger: (Bool, Bool, Bool) = (false, false, false)
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    Image("My-meme-original").resizable().frame(width: 400, height: 300)
                    
                    GlitchTextView("Hello!", trigger: trigger.0)
                        .font(.system(size: 60, design: .rounded))
                    
                    GlitchTextView("This is Glitch Text Effect", trigger: trigger.1)
                        .font(.system(size: 35, design: .rounded))
                    
                    GlitchTextView("Made With SwiftUI", trigger: trigger.2)
                        .font(.system(size: 22, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .lineLimit(1)
                .scaleEffect(0.9)
                
                Button(action: {
                    Task {
                        trigger.0.toggle()
                        try? await Task.sleep(for: .seconds(0.6))
                        trigger.1.toggle()
                        try? await Task.sleep(for: .seconds(0.6))
                        trigger.2.toggle()
                    }
                }, label: {
                    Text("Trigger")
                        .padding(.horizontal, 15)
                })
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(.black)
                .padding(.top, 20)
            }
            .padding(15)
            .navigationTitle("Text Effect's")
        }
    }
    
    @ViewBuilder
    func GlitchTextView(_ text: String, trigger: Bool) -> some View {
        ZStack {
            GlitchText(text: text, trigger: trigger) {
                LinearKeyframe(
                    GlitchFrame(top: -5, center: 0, bottom: 0, shadowOpacity: 0.2),
                    duration: 0.1
                )
                LinearKeyframe(
                    GlitchFrame(top: -5, center: -5, bottom: -5, shadowOpacity: 0.6),
                    duration: 0.1
                )
                LinearKeyframe(
                    GlitchFrame(top: -5, center: -5, bottom: 5, shadowOpacity: 0.8),
                    duration: 0.1
                )
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 5, bottom: 5, shadowOpacity: 0.4),
                    duration: 0.1
                )
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 0, bottom: 5, shadowOpacity: 0.1),
                    duration: 0.1
                )
                LinearKeyframe(
                    GlitchFrame(),
                    duration: 0.1
                )
            }
            
            GlitchText(text: text, trigger: trigger, shadow: .green) {
                LinearKeyframe(
                    GlitchFrame(top: 0, center: 5, bottom: 0, shadowOpacity: 0.2),
                    duration: 0.1
                )
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 5, bottom: 5, shadowOpacity: 0.3),
                    duration: 0.1
                )
                LinearKeyframe(
                    GlitchFrame(top: 5, center: 5, bottom: -5, shadowOpacity: 0.5),
                    duration: 0.1
                )
                LinearKeyframe(
                    GlitchFrame(top: 0, center: 5, bottom: -5, shadowOpacity: 0.6),
                    duration: 0.1
                )
                LinearKeyframe(
                    GlitchFrame(top: 0, center: -5, bottom: 0, shadowOpacity: 0.3),
                    duration: 0.1
                )
                LinearKeyframe(
                    GlitchFrame(),
                    duration: 0.1
                )
            }
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
