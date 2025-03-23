//
//  AudioScrubberView.swift
//  MyApp
//
//  Created by Cong Le on 3/22/25.
//

import SwiftUI

struct AudioScrubberView: View {
    @State private var progress: CGFloat = 0.32
    @State private var duration: TimeInterval = 0
    @State private var isActive: Bool = false
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationStack {
            List {
                Section("Usage") {
                    Text(
                        """
                        **WaveformScrubber(url, progress) {**
                            // Info
                        **} onGestureActive: {**
                            // Status
                        **}**
                        """
                    )
                    .kerning(1.1)
                }
                
                if let audioURL {
                    Section("Preview") {
                        VStack(spacing: 6) {
                            let config: WaveformScrubber.Config = .init(activeTint: colorScheme == .dark ? .white : .black)
                            
                            WaveformScrubber(config: config, url: audioURL, progress: $progress) { info in
                                duration = info.duration
                            } onGestureActive: { status in
                                isActive = status
                            }
                            .frame(height: 60)
                            .scaleEffect(y: isActive ? 1.4 : 1, anchor: .center)
                            .animation(.bouncy, value: isActive)
                            
                            HStack {
                                Text(current)
                                    .contentTransition(.numericText())
                                    .animation(.snappy, value: progress)
                                
                                Spacer(minLength: 0)
                                
                                Text(end)
                            }
                            .monospaced()
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 10)
                            .padding(.bottom, 5)
                        }
                        .listRowInsets(.init(top: 5, leading: 10, bottom: 5, trailing: 10))
                    }
                }
                else {
                    Text("Add Any Audio URL !!!")
                }
            }
            .navigationTitle("Waveform Scrubber")
        }
    }
    
    var current: String {
        let minutes = Int(duration * progress) / 60
        let seconds = Int(duration * progress) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
    
    var end: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
    
    var audioURL: URL? {
        Bundle.main.url(forResource: "sample", withExtension: "mp3")
    }
}

// MARK: - Preview
#Preview {
    AudioScrubberView()
}
