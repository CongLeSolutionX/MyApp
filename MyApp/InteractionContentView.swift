//
//  InteractionContentView.swift
//  MyApp
//
//  Created by Cong Le on 2/18/25.
//


import SwiftUI

struct InteractionContentView: View {
    /// If you want to change the interaction dynamically, then you must remove the view and reload the view to get the perfect animation effect
    @State private var effect = InteractionEffect.verticalSwipe
    @State private var showView: Bool = true
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                Text("Usage")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(
                    """
                    Interactions(.tap) {
                      /// Inner View
                    }
                    """
                )
                .font(.callout)
                .monospaced()
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.fill.opacity(0.4), in: .rect(cornerRadius: 15))
                
                Picker("", selection: $effect) {
                    ForEach(InteractionEffect.allCases, id: \.rawValue) { effect in
                        Text(effect.rawValue)
                            .font(.caption)
                            .tag(effect)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: effect) { oldValue, newValue in
                    showView = false
                    Task {
                        showView = true
                    }
                }
                
                ZStack {
                    if showView {
                        InteractionViews(effect: effect) { size, showsTouch, isAnimated in
                            /// YOUR CUSTOMIZED INNER VIEW CONTENTS
                            /// Now, let’s design some visually appealing cards to illustrate the outcomes of this interaction.
                            switch effect {
                            case .tap:
                                PressView(animates: isAnimated, scale: 0.95)
                            case .longPress:
                                PressView(animates: isAnimated)
                            case .verticalSwipe:
                                VerticalSwipeView(size, animates: isAnimated)
                            case .horizontalSwipe:
                                HorizontalSwipeView(size, animates: isAnimated)
                            case .pinch:
                                PressView(animates: isAnimated, scale: 1.3)
                            }
                        }
                    }
                }
                .frame(width: 100, height: 200)
                .padding(.top, 30)
                .padding(.bottom, 10)
                
                Text("\(effect.rawValue) Interaction")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                
                Spacer(minLength: 0)
            }
            .padding(15)
            .navigationTitle("Interactions")
        }
    }
    
    @ViewBuilder
    func HorizontalSwipeView(_ size: CGSize, animates: Bool) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 10)
                .fill(.fill)
                .frame(width: 80, height: 150)
                .frame(width: size.width, height: size.height)
            
            RoundedRectangle(cornerRadius: 10)
                .fill(.fill)
                .frame(width: 80, height: 150)
                .frame(width: size.width, height: size.height)
        }
        .offset(x: animates ? -(size.width + 10) : 0)
    }
    
    @ViewBuilder
    func VerticalSwipeView(_ size: CGSize, animates: Bool) -> some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 10)
                .fill(.fill)
                .frame(width: 80, height: 150)
                .frame(width: size.width, height: size.height)
            
            RoundedRectangle(cornerRadius: 10)
                .fill(.fill)
                .frame(width: 80, height: 150)
                .frame(width: size.width, height: size.height)
        }
        .offset(y: animates ? -(size.height + 10) : 0)
    }
    
    @ViewBuilder
    func PressView(animates: Bool, scale: CGFloat = 0.9) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.fill)
            .frame(width: 80, height: 150)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scaleEffect(animates ? scale : 1)
    }
}

// MARK: - Preview 
#Preview {
    InteractionContentView()
}
