//
//  TikTokCameraView.swift
//  MyApp
//
//  Created by Cong Le on 11/13/24.
//
import SwiftUI

struct CameraView: View {
    var body: some View {
        ZStack {
            // Background Camera Feed Placeholder
            Color.blue
                .edgesIgnoringSafeArea(.all)
            
            
            // Effects Button Panel
            EffectsButtonPanel()
                .padding(.top, topPadding)
            
            // Overlay Content
            VStack {
                // Top Bar
                TopBarView()
                    .padding(.top, topPadding)
                
                Spacer()
                
                // Control Panels
                ControlPanelsView()
          
            }
        }
    }
    
    // Calculate dynamic top padding based on safe area
    private var topPadding: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.top ?? 60
    }
}

// MARK: - Top Bar View
struct TopBarView: View {
    var body: some View {
        HStack {
            ClockView()
            Spacer()
            SoundToggleView()
        }
        .padding(.horizontal)
    }
}

// MARK: - Clock View
struct ClockView: View {
    var body: some View {
        Text(Date(), style: .time)
            .font(.headline)
            .foregroundColor(.white)
            .accessibilityLabel("Current time")
    }
}

// MARK: - Sound Toggle View
struct SoundToggleView: View {
    @State private var isSoundOn: Bool = true
    
    var body: some View {
        Button(action: {
            isSoundOn.toggle()
            // Handle sound toggle action
        }) {
            Image(systemName: isSoundOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                .font(.headline)
                .foregroundColor(.white)
        }
        .accessibilityLabel(isSoundOn ? "Mute sounds" : "Unmute sounds")
    }
}

// MARK: - Control Panels View
struct ControlPanelsView: View {
    var body: some View {
        VStack {
            // Main Control Panel
            ControlPanelMainView()
                .padding(.bottom, 10)
            
            // Timer and Templates
            TimerTemplatesView()
        }
        .padding(.horizontal)
    }
}

// MARK: - Main Control Panel View
struct ControlPanelMainView: View {
    var body: some View {
        HStack {
            Spacer()
            
            // Recording Button
            RecordButton()
            
            Spacer()
            
            // Upload Button
            UploadButton()
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Recording Button
struct RecordButton: View {
    @State private var isRecording: Bool = false
    
    var body: some View {
        Button(action: {
            isRecording.toggle()
            // Handle recording action
        }) {
            Circle()
                .fill(isRecording ? Color.red.opacity(0.7) : Color.red)
                .frame(width: 80, height: 80)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                )
                .scaleEffect(isRecording ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isRecording)
        }
        .accessibilityLabel(isRecording ? "Stop Recording" : "Start Recording")
    }
}

// MARK: - Upload Button
struct UploadButton: View {
    var body: some View {
        Button(action: {
            // Handle upload action
        }) {
            Image(systemName: "photo.on.rectangle")
                .font(.title)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.5))
                .clipShape(Circle())
        }
        .accessibilityLabel("Upload photo")
    }
}

// MARK: - Timer and Templates View
struct TimerTemplatesView: View {
    var body: some View {
        HStack {
            TimerView(duration: "60s")
            Spacer()
            TimerView(duration: "15s")
            Spacer()
            TemplatesView()
        }
        .foregroundColor(.white)
        .padding(.bottom, 30)
    }
}

// MARK: - Timer View
struct TimerView: View {
    let duration: String
    
    var body: some View {
        Text(duration)
            .accessibilityLabel("\(duration) timer")
    }
}

// MARK: - Templates View
struct TemplatesView: View {
    var body: some View {
        Button(action: {
            // Handle templates action
        }) {
            Text("Templates")
                .underline()
        }
        .accessibilityLabel("Open templates")
    }
}

// MARK: - Effects Button Panel
struct EffectsButtonPanel: View {
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 20) {
                EffectButton(icon: "sparkles", tooltip: "Sparkle Effect", action: {
                    // Sparkle effect action
                })
                EffectButton(icon: "star.fill", tooltip: "Star Effect", action: {
                    // Star effect action
                })
                EffectButton(icon: "moon.fill", tooltip: "Moon Effect", action: {
                    // Moon effect action
                })
                EffectButton(icon: "flame.fill", tooltip: "Flame Effect", action: {
                    // Flame effect action
                })
            }
            .padding()
        }
    }
}

// MARK: - Effect Button
struct EffectButton: View {
    let icon: String
    let tooltip: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .clipShape(Circle())
                .shadow(radius: 5)
        }
        .accessibilityLabel(tooltip)
    }
}

// MARK: - Preview
//struct CameraView_Previews: PreviewProvider {
//    static var previews: some View {
//        CameraView()
//    }
//}


// MARK: - Preview
#Preview {
    CameraView()
}
