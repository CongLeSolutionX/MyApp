//
//  CallingView.swift
//  MyApp
//
//  Created by Cong Le on 3/25/25.
//

import SwiftUI


struct CallingView: View {
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0.2, blue: 0.2), .black]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            
            VStack {
                // Top Section
                HStack {
                    Image(systemName: "waveform")
                    Spacer()
                    Image(systemName: "info.circle")
                }.padding()
                    .foregroundColor(.white)
                
                Spacer()
                    .frame(height: 20)
                
                Text("Calling home...")
                    .font(.title3)
                    .foregroundColor(.gray)
                
                Text("Mom")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 50)
                
                
                Spacer()
                
                
                // Button Grid
                VStack(spacing: 20) {
                    HStack(spacing: 40) {
                        CallButton(icon: "speaker.wave.2.fill", label: "Speaker", color: .gray)
                        CallButton(icon: "questionmark.video", label: "FaceTime", color: .gray)
                        CallButton(icon: "mic.slash.fill", label: "Mute", color: .gray)
                    }
                    
                    
                    HStack(spacing: 40) {
                        CallButton(icon: "person.badge.plus", label: "Add", color: .gray)
                        CallButton(icon: "phone.down.fill", label: "End", color: .red)
                        CallButton(icon: "square.grid.3x3.fill", label: "Keypad", color: .gray)
                    }
                }
                .padding(.bottom, 50)
                
                
                // Bottom Bar (Home Indicator)
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 150, height: 5)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            }
            .padding()
        }
    }
}


struct CallButton: View {
    let icon: String
    let label: String
    let color: Color
    
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .frame(width: 70, height: 70)
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3)) // Soft Gray color based on the image
                
                Image(systemName: icon)
                    .font(.system(size: 25))
                    .foregroundColor(.white)
            }
            
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}


struct CallingView_Previews: PreviewProvider {
    static var previews: some View {
        CallingView()
    }
}
