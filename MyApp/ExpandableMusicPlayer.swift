//
//  ExpandableMusicPlayer.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI

struct ExpandableMusicPlayer: View {
    @Binding var show: Bool
    @Binding var hideMiniPlayer: Bool
    /// View Properties
    @State private var expandPlayer: Bool = false
    @State private var offsetY: CGFloat = 0
    @State private var mainWindow: UIWindow?
    @State private var windowProgress: CGFloat = 0
    @Namespace private var animation
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            let cornerRadius: CGFloat = safeArea.bottom == 0 ? 0 : 45
            
            ZStack(alignment: .top) {
                /// Background
                ZStack {
                    Rectangle()
                        .fill(.playerBackground)
                    
                    Rectangle()
                        .fill(.linearGradient(colors: [.artwork1, .artwork2, .artwork3], startPoint: .top, endPoint: .bottom))
                        .opacity(expandPlayer ? 1 : 0)
                }
                .clipShape(.rect(cornerRadius: expandPlayer ? cornerRadius : 15))
                .frame(height: expandPlayer ? nil : 55)
                /// Shadows
                .shadow(color: .primary.opacity(0.06), radius: 5, x: 5, y: 5)
                .shadow(color: .primary.opacity(0.05), radius: 5, x: -5, y: -5)
                
                MiniPlayer()
                    .opacity(expandPlayer ? 0 : 1)
                
                ExpandedPlayer(size, safeArea)
                    .opacity(expandPlayer ? 1 : 0)
            }
            .frame(height: expandPlayer ? nil : 55, alignment: .top)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, expandPlayer ? 0 : safeArea.bottom + 55)
            .padding(.horizontal, expandPlayer ? 0 : 15)
            .offset(y: offsetY)
            .gesture(
                PanGesture { value in
                    guard expandPlayer else { return }
                    
                    let translation = max(value.translation.height, 0)
                    offsetY = translation
                    windowProgress = max(min(translation / size.height, 1), 0) * 0.1
                    
                    resizeWindow(0.1 - windowProgress)
                } onEnd: { value in
                    guard expandPlayer else { return }
                    
                    let translation = max(value.translation.height, 0)
                    let velocity = value.velocity.height / 5
                    
                    withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                        if (translation + velocity) > (size.height * 0.5) {
                            /// Closing View
                            expandPlayer = false
                            windowProgress = 0
                            /// Resetting Window To Identity With Animation
                            resetWindowWithAnimation()
                        } else {
                            /// Reset Window To 0.1 With Animation
                            UIView.animate(withDuration: 0.3) {
                                resizeWindow(0.1)
                            }
                        }
                        
                        offsetY = 0
                    }
                }
            )
            .offset(y: hideMiniPlayer && !expandPlayer ? safeArea.bottom + 200 : 0)
            .ignoresSafeArea()
        }
        .onAppear {
            if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow, mainWindow == nil {
                mainWindow = window
            }
        }
    }
    
    /// Mini Player
    @ViewBuilder
    func MiniPlayer() -> some View {
        HStack(spacing: 12) {
            ZStack {
                if !expandPlayer {
                    Image(.myMemeOrange)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(.rect(cornerRadius: 10))
                        .matchedGeometryEffect(id: "Artwork", in: animation)
                }
            }
            .frame(width: 45, height: 45)
            
            Text("Calm Down")
            
            Spacer(minLength: 0)
            
            Group {
                Button("", systemImage: "play.fill") {
                    
                }
                
                Button("", systemImage: "forward.fill") {
                    
                }
            }
            .font(.title3)
            .foregroundStyle(Color.primary)
        }
        .padding(.horizontal, 10)
        .frame(height: 55)
        .contentShape(.rect)
        .onTapGesture {
            withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                expandPlayer = true
            }
            
            /// Reszing Window When Opening Player
            UIView.animate(withDuration: 0.3) {
                resizeWindow(0.1)
            }
        }
    }
    
    /// Expanded Player
    @ViewBuilder
    func ExpandedPlayer(_ size: CGSize, _ safeArea: EdgeInsets) -> some View {
        VStack(spacing: 12) {
            Capsule()
                .fill(.white.secondary)
                .frame(width: 35, height: 5)
                .offset(y: -10)
            
            /// Sample Player View
            HStack(spacing: 12) {
                ZStack {
                    if expandPlayer {
                        Image(.myMemeOrange)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(.rect(cornerRadius: 10))
                            .matchedGeometryEffect(id: "Artwork", in: animation)
                            .transition(.offset(y: 1))
                    }
                }
                .frame(width: 80, height: 80)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Calm Down")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Text("Rema, Selena Gomez")
                        .font(.caption2)
                        .foregroundStyle(.white.secondary)
                }
                
                Spacer(minLength: 0)
                
                HStack(spacing: 0) {
                    Button("", systemImage: "star.circle.fill") {
                        
                    }
                    
                    Button("", systemImage: "ellipsis.circle.fill") {
                        
                    }
                }
                .foregroundStyle(.white, .white.tertiary)
                .font(.title2)
            }
        }
        .padding(15)
        .padding(.top, safeArea.top)
    }
    
    func resizeWindow(_ progress: CGFloat) {
        if let mainWindow = mainWindow?.subviews.first {
            let offsetY = (mainWindow.frame.height * progress) / 2
            
            /// Your Custom Corner Radius
            mainWindow.layer.cornerRadius = (progress / 0.1) * 30
            mainWindow.layer.masksToBounds = true
            
            mainWindow.transform = .identity.scaledBy(x: 1 - progress, y: 1 - progress).translatedBy(x: 0, y: offsetY)
        }
    }
    
    func resetWindowWithAnimation() {
        if let mainWindow = mainWindow?.subviews.first {
            UIView.animate(withDuration: 0.3) {
                mainWindow.layer.cornerRadius = 0
                mainWindow.transform = .identity
            }
        }
    }
}

#Preview {
    RootView {
        Home()
    }
}
