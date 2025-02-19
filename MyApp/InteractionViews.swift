//
//  InteractionView.swift
//  MyApp
//
//  Created by Cong Le on 2/18/25.
//


import SwiftUI

struct InteractionViews<Content: View>: View {
    var effect: InteractionEffect
    @ViewBuilder var content: (CGSize, Bool, Bool) -> Content
    /// View Properties
    @State private var showsTouch: Bool = false
    @State private var animate: Bool = false
    @State private var isStarted: Bool = false
    var body: some View {
        /// Let's create a dummy iPhone bezel (With Dynamic Island)
        RoundedRectangle(cornerRadius: 15)
            .stroke(Color.primary, style: .init(lineWidth: 6, lineCap: .round, lineJoin: .round))
            .frame(width: 100, height: 200)
            .background {
                GeometryReader {
                    let size = $0.size
                    content(size, showsTouch, animate)
                }
                .clipped()
            }
            .overlay(alignment: .top) {
                /// Dynamic Island
                Capsule()
                    .frame(width: 22, height: 7)
                    .offset(y: 7)
            }
            .overlay(alignment: .bottom) {
                /// Home Indicator
                Capsule()
                    .frame(width: 32, height: 2)
                    .offset(y: -7)
            }
            .overlay {
                /// Touch View
                let isSwipe = effect == .verticalSwipe || effect == .horizontalSwipe
                let isPinch = effect == .pinch
                /// Let's make circle size a little smaller for horizontal swipe
                let circleSize: CGFloat = effect == .horizontalSwipe ? 18 : 20
                
                Circle()
                    .fill(.fill)
                    .frame(width: circleSize, height: circleSize)
                    .offset(y: isPinch ? animate ? -40 : 0 : 0)
                    .overlay {
                        if isPinch {
                            Circle()
                                .fill(.fill)
                                .frame(width: circleSize, height: circleSize)
                                .offset(y: animate ? 40 : 0)
                        }
                    }
                    .opacity(showsTouch ? 1 : 0)
                    .blur(radius: showsTouch ? 0 : 5)
                    .offset(
                        x: effect == .horizontalSwipe ? (animate ? -25 : 25) : 0,
                        y: effect == .verticalSwipe ? (animate ? -50 : 50) : 0
                    )
                    .scaleEffect(isSwipe ? 1 : isPinch ? 0.8 : (animate ? 0.8 : 1.1))
            }
            .onAppear {
                /// Avoids calling multiple times when in LazyViews
                guard !isStarted else { return }
                isStarted = true
                /// Looping Animation Effect
                Task {
                    await animationEffect()
                }
            }
            .onDisappear {
                isStarted = false
            }
    }
    
    private func animationEffect() async {
        /// This is still calling even after the view is gone, beacuse of the recursive callback, to stop this we can make use of isStarted property
        guard isStarted else { return }
        
        let isSwipe = effect == .horizontalSwipe || effect == .verticalSwipe
        let isPinch = effect == .pinch
        
        withAnimation(.easeInOut(duration: 0.5)) {
            showsTouch = true
        }
        
        try? await Task.sleep(for: .seconds(0.5))
        
        /// Let's remove the delay for tap interactions
        if effect == .tap {
            withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                animate = true
            }
            
            try? await Task.sleep(for: .seconds(0.2))
        } else {
            withAnimation(.snappy(duration: 1, extraBounce: 0)) {
                animate = true
            }
            
            /// Let's add some extra delay for long press interaction
            try? await Task.sleep(for: .seconds(effect == .longPress ? 1.3 : 1))
        }
        
        /// Resetting Animation
        withAnimation(.easeInOut(duration: 0.3), completionCriteria: .logicallyComplete) {
            /// Let's modify the animation for long press to get a release effect
            /// We don't need reverse effect for pinch interactions
            if isSwipe || isPinch {
                showsTouch = false
            } else {
                animate = false
            }
        } completion: {
            if isSwipe {
                animate = false
            }
            
            if isPinch {
                withAnimation(.linear(duration: 0.2)) {
                    animate = false
                }
            }
        }
        
        /// Looping
        try? await Task.sleep(for: .seconds(effect == .tap ? 0.3 : isPinch ? 1 : 0.6))
        await animationEffect()
    }
}

enum InteractionEffect: String, CaseIterable {
    case tap = "Tap"
    case longPress = "Hold"
    case verticalSwipe = "Vertical"
    case horizontalSwipe = "Horizontal"
    case pinch = "Pinch"
}
