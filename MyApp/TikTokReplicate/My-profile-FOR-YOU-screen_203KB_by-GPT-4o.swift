//
//  My-profile-FOR-YOU-screen_203KB.swift
//  MyApp
//
//  Created by Cong Le on 11/16/24.
//

/// The UI elements in the image are not aligned correct (but acceptable).
/// Buttons are monotone, and they are clickable and functional with print statement.
/// In this case, the image size is 203 KB, dimention is 1284 × 2778, resolution is 72 × 72
/// Code generated by GPT-4o
import SwiftUI
struct VideoInterfaceView: View {
    var body: some View {
        ZStack {
            // Placeholder for video content
            Rectangle()
                .fill(Color.gray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    Text("Video Placeholder")
                        .foregroundColor(.white)
                        .font(.callout)
                )
            
            VStack {
                // Top Navigation Bar
                HStack {
                    Text("12:50")
                    Spacer()
                    HStack {
                        Text("LIVE").bold()
                        Text("Explore")
                        Text("Following")
                        Text("Shop")
                        Text("For You").underline()
                    }
                    Spacer()
                    Image(systemName: "magnifyingglass")
                }
                .padding()
                .foregroundColor(.white)
                
                Spacer()
                
                // Right Side Vertical Buttons
                VStack(spacing: 20) {
                    ProfileButtonView(image: "person.circle.fill", action: {
                        print("Profile tapped")
                    })
                    
                    IconButtonView(icon: "heart.fill", text: "69.4K", action: {
                        print("Like tapped")
                    })
                    
                    IconButtonView(icon: "bubble.right.fill", text: "213", action: {
                        print("Comment tapped")
                    })
                    
                    IconButtonView(icon: "arrowshape.turn.up.right.fill", text: "6,563", action: {
                        print("Share tapped")
                    })
                }
                .padding(.trailing)
                .padding(.bottom, 65)
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                // Description
                VStack(alignment: .leading) {
                    Text("Phan Ái Vy")
                        .bold()
                        .foregroundColor(.white)
                    Text("Z ha #phanaizi #fyp #viral")
                        .foregroundColor(.white)
                    Text("See translation")
                        .foregroundColor(.gray)
                }
                .padding()
                
                // Bottom Navigation Bar
                HStack {
                    BottomNavBarButton(icon: "house.fill", label: "Home", action: {
                        print("Home tapped")
                    })
                    
                    Spacer()
                    
                    BottomNavBarButton(icon: "person.2.fill", label: "Friends", action: {
                        print("Friends tapped")
                    })
                    
                    Spacer()
                    
                    BottomNavBarButton(icon: "plus.circle.fill", label: "", action: {
                        print("New tapped")
                    })
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "plus")
                                    .foregroundColor(.black)
                                    .font(.headline)
                            )
                    )
                    
                    Spacer()
                    
                    BottomNavBarButton(icon: "envelope.fill", label: "Inbox", action: {
                        print("Inbox tapped")
                    })
                    
                    Spacer()
                    
                    BottomNavBarButton(icon: "person.fill", label: "Profile", action: {
                        print("Profile tapped")
                    })
                }
                .padding()
                .background(Color.black.opacity(0.8))
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct IconButtonView: View {
    var icon: String
    var text: String
    var action: () -> Void
    
    var body: some View {
        VStack {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
            }
            Text(text)
                .foregroundColor(.white)
                .font(.caption)
        }
    }
}

struct ProfileButtonView: View {
    var image: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: image)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
        }
    }
}

struct BottomNavBarButton: View {
    var icon: String
    var label: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                if !label.isEmpty {
                    Text(label)
                        .foregroundColor(.white)
                        .font(.caption)
                }
            }
        }
    }
}

struct VideoInterfaceView_Previews: PreviewProvider {
    static var previews: some View {
        VideoInterfaceView()
    }
}