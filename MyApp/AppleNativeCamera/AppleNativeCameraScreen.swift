//
//  AppleNativeCameraScreen.swift
//  MyApp
//
//  Created by Cong Le on 11/16/24.
//

import SwiftUI

struct CameraInterfaceView: View {
    var body: some View {
        VStack {
            // Top Bar
            HStack {
                Image(systemName: "sparkles")
                Spacer()
                Image(systemName: "chevron.up")
                Spacer()
                Text("RAW")
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "circle.grid.2x2.fill")
            }
            .padding()
            .foregroundColor(.white)
            
            // Spacer for Image Placeholder
            Spacer()
            
            // Image Placeholder
            Rectangle()
                .fill(Color.gray)
                .overlay(
                    Text("FILL THIS RECTANGLE WITH AN IMAGE !")
                        .foregroundColor(.white)
                        .font(.callout)
                )
                .frame(height: 600) // Adjust height as needed
            
            Spacer()
            
            // Bottom Controls
            VStack {
                // Mode Switch
                HStack {
                    Text("CINEMATIC")
                    Spacer()
                    Text("VIDEO")
                    Spacer()
                    Text("PHOTO")
                        .foregroundColor(.yellow)
                        .bold()
                    Spacer()
                    Text("PORTRAIT")
                    Spacer()
                    Text("PANO")
                }
                .padding()
                .foregroundColor(.white)
                
                // Zoom Level and Capture
                HStack {
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.gray.opacity(0.5)))
                    
                    Spacer()
                    
                    HStack {
                        Text("0.5")
                            .foregroundColor(.gray)
                        Text("1x")
                            .foregroundColor(.yellow)
                            .bold()
                        Text("3")
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 4)
                        )
                    
                    Spacer()
                    
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.black))
                }
                .padding(.horizontal, 30)
                
                Spacer().frame(height: 20)
            }
            .background(Color.black)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

// MARK: - Previews
struct CameraInterfaceView_Previews: PreviewProvider {
    static var previews: some View {
        CameraInterfaceView()
    }
}
