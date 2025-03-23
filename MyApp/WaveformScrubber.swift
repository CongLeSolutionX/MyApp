//
//  WaveformScrubber.swift
//  MyApp
//
//  Created by Cong Le on 3/22/25.
//


import SwiftUI
import AVKit

struct WaveformScrubber: View {
    var config: Config = .init()
    var url: URL
    /// Scrubber Progress
    @Binding var progress: CGFloat
    var info: (AudioInfo) -> () = { _ in }
    var onGestureActive: (Bool) -> () = { _ in }
    /// View Properties
    @State private var samples: [Float] = []
    @State private var dowsizedSamples: [Float] = []
    @State private var viewSize: CGSize = .zero
    /// Gesture Properties
    @State private var lastProgress: CGFloat = 0
    @GestureState private var isActive: Bool = false
    var body: some View {
        ZStack {
            WaveformShape(samples: dowsizedSamples)
                .fill(config.inActiveTint)
            
            WaveformShape(samples: dowsizedSamples)
                .fill(config.activeTint)
                .mask {
                    Rectangle()
                        .scale(x: progress, anchor: .leading)
                }
        }
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
        .gesture(
            DragGesture()
                .updating($isActive, body: { _, out, _ in
                    out = true
                }).onChanged({ value in
                    let progress = max(min((value.translation.width / viewSize.width) + lastProgress, 1), 0)
                    self.progress = progress
                }).onEnded({ _ in
                    lastProgress = progress
                })
        )
        .onChange(of: progress, { oldValue, newValue in
            guard !isActive else { return }
            lastProgress = newValue
        })
        .onChange(of: isActive, { oldValue, newValue in
            onGestureActive(newValue)
        })
        .onGeometryChange(for: CGSize.self) {
            $0.size
        } action: { newValue in
            /// Storing Initial Progress
            if viewSize == .zero {
                lastProgress = progress
            }
            
            viewSize = newValue
            initializeAudioFile(newValue)
        }
    }
    
    struct Config {
        var spacing: Float = 2
        var shapeWidth: Float = 2
        var activeTint: Color = .black
        var inActiveTint: Color = .gray.opacity(0.7)
        /// OTHER CONFIGS....
    }
    
    struct AudioInfo {
        var duration: TimeInterval = 0
        /// OTHER AUDIO INFO....
    }
}

/// Custom WaveFrom Shape
fileprivate struct WaveformShape: Shape {
    var samples: [Float]
    var spacing: Float = 2
    var width: Float = 2
    nonisolated func path(in rect: CGRect) -> Path {
        Path { path in
            var x: CGFloat = 0
            for sample in samples {
                let height = max(CGFloat(sample) * rect.height, 1)
                
                path.addRect(CGRect(
                    origin: .init(x: x + CGFloat(width), y: -height / 2),
                    size: .init(width: CGFloat(width), height: height)
                ))
                
                x += CGFloat(spacing + width)
            }
        }
        .offsetBy(dx: 0, dy: rect.height / 2)
    }
}

extension WaveformScrubber {
    /// Audio Helpers
    private func initializeAudioFile(_ size: CGSize) {
        guard samples.isEmpty else { return }
        
        Task.detached(priority: .high) {
            do {
                let audioFile = try AVAudioFile(forReading: url)
                let audioInfo = extractAudioInfo(audioFile)
                let samples = try extractAudioSamples(audioFile)
                
                let downSampleCount = Int(Float(size.width) / (config.spacing + config.shapeWidth))
                let downSamples = downSampleAudioSamples(samples, downSampleCount)
                await MainActor.run {
                    self.samples = samples
                    self.dowsizedSamples = downSamples
                    self.info(audioInfo)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    nonisolated private func extractAudioSamples(_ file: AVAudioFile) throws -> [Float] {
        let format = file.processingFormat
        let frameCount = UInt32(file.length)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return []
        }
        
        try file.read(into: buffer)
        
        if let channel = buffer.floatChannelData {
            let samples = Array(UnsafeBufferPointer(start: channel[0], count: Int(buffer.frameLength)))
            return samples
        }
        
        return []
    }
    
    nonisolated private func downSampleAudioSamples(_ samples: [Float], _ count: Int) -> [Float] {
        let chunk = samples.count / count
        var downSamples: [Float] = []
        
        for index in 0..<count {
            let start = index * chunk
            let end = min((index + 1) * chunk, samples.count)
            let chunkSamples = samples[start..<end]
            
            let maxValue = chunkSamples.max() ?? 0
            downSamples.append(maxValue)
        }
        
        return downSamples
    }
    
    nonisolated private func extractAudioInfo(_ file: AVAudioFile) -> AudioInfo {
        let format = file.processingFormat
        let sampleRate = format.sampleRate
        
        let duration = file.length / Int64(sampleRate)
        
        return .init(duration: TimeInterval(duration))
    }
}

// MARK: - Preview
#Preview {
    EmptyView()
}
