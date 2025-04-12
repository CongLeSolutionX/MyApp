//
//  CoreConceptAndObtainingInstances.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//

import SwiftUI
import AVFoundation // Import AVFoundation to reference its types

// MARK: - Main View Container

struct AVCaptureDeviceConceptsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("AVCaptureDevice Concepts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)

                CoreConceptView()
                ObtainingInstancesView()
                BasicUsageFlowView()

                Spacer() // Pushes content up
            }
            .padding()
        }
    }
}

// MARK: - 1. Core Concept Section

struct CoreConceptView: View {
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "camera.fill") // Represents AVCaptureDevice
                        .font(.title)
                        .foregroundColor(.purple)
                    Text("AVCaptureDevice")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                Divider()
                // Description Points
                InfoRow(icon: "cube.box.fill", text: "Represents Physical Hardware")
                HStack {
                    Spacer().frame(width: 30) // Indent
                    VStack(alignment: .leading) {
                        InfoRow(icon: "video.fill", text: "Camera")
                        InfoRow(icon: "mic.fill", text: "Microphone")
                    }
                }
                InfoRow(icon: "play.rectangle.fill", text: "Provides Realtime Input Media Data")
                HStack {
                     Spacer().frame(width: 30) // Indent
                    VStack(alignment: .leading) {
                        InfoRow(icon: "film.fill", text: "Video")
                        InfoRow(icon: "waveform", text: "Audio")
                    }
                }
                InfoRow(icon: "nosign", text: "Cannot be initialized directly")
                    .foregroundColor(.red)

            }
        } label: {
            Label("Core Concept", systemImage: "info.circle.fill")
                .font(.headline)
        }
    }
}

// MARK: - 2. Obtaining Instances Section

struct ObtainingInstancesView: View {
    var body: some View {
         GroupBox {
            VStack(alignment: .leading, spacing: 15) {
                Text("How to Find/Obtain an Instance?")
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.bottom, 5)

                MethodRow(
                    icon: "sparkle.magnifyingglass",
                    title: "Specific Criteria (Recommended)",
                    method: "AVCaptureDevice.DiscoverySession (iOS 10+)",
                    details: "Find devices by type, media type, position using `.devices` property.",
                    output: "[AVCaptureDevice]"
                )

                MethodRow(
                    icon: "star.fill",
                    title: "Get Default Device",
                    method: """
                    AVCaptureDevice.default(for:)
                    AVCaptureDevice.default(deviceType:for:position:) (iOS 10+)
                    """,
                    details: "Returns the system's default device for the criteria.",
                    output: "AVCaptureDevice?"
                )

                 MethodRow(
                    icon: "tag.fill",
                    title: "Known Unique ID",
                    method: "AVCaptureDevice(uniqueID:)",
                    details: "Retrieve a specific device using its persistent ID.",
                    output: "AVCaptureDevice?"
                )

                MethodRow(
                    icon: "gearshape.2.fill",
                    title: "Preferred Camera (iOS 17+)",
                    method: """
                    AVCaptureDevice.systemPreferredCamera
                    AVCaptureDevice.userPreferredCamera
                    """,
                    details: "Access the camera preferred by the system or set by the user.",
                    output: "AVCaptureDevice?"
                )

                MethodRow(
                    icon: "archivebox.fill",
                    title: "All Devices (Deprecated iOS 10)",
                    method: """
                    AVCaptureDevice.devices()
                    AVCaptureDevice.devices(for:)
                    """,
                    details: "Returns all available devices (requires manual filtering).",
                    output: "[AVCaptureDevice]"
                )

                HStack {
                    Spacer()
                    Image(systemName: "arrow.down.forward.circle.fill")
                    Text("Selected AVCaptureDevice Instance")
                        .font(.headline)
                    Spacer()
                }
                .padding(.top)

            }
        } label: {
             Label("Obtaining Instances", systemImage: "hand.point.up.left.fill")
                .font(.headline)
        }
    }
}

// MARK: - 3. Basic Usage Flow Section

struct BasicUsageFlowView: View {
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                FlowStep(step: 1, icon: "camera.fill", text: "Obtain `AVCaptureDevice` Instance (using methods above)")
                FlowArrow()
                FlowStep(step: 2, icon: "rectangle.inset.filled.and.person.filled", text: "Create `AVCaptureDeviceInput(device:)`")
                FlowArrow()
                FlowStep(step: 3, icon: "film.stack", text: "Obtain/Create `AVCaptureSession`")
                FlowArrow()
                FlowStep(step: 4, icon: "plus.viewfinder", text: "Add Input to Session: `session.addInput(...)`")
                 FlowArrow()
                FlowStep(step: 5, icon: "slider.horizontal.3", text: "Configure Session / Add Outputs (e.g., Photo, Video Data)")
                FlowArrow()
                FlowStep(step: 6, icon: "play.circle.fill", text: "Start Session Running: `session.startRunning()`")
            }
        } label: {
             Label("Basic Usage Flow", systemImage: "list.number")
                .font(.headline)
        }
    }
}

// MARK: - Helper Views for Styling

struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .frame(width: 20, alignment: .center) // Align icons
                .foregroundColor(.secondary)
            Text(text)
                .fixedSize(horizontal: false, vertical: true) // Allow text wrap
        }
    }
}

struct MethodRow: View {
    let icon: String
    let title: String
    let method: String
    let details: String
    let output: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
             HStack {
                Image(systemName: icon)
                     .font(.headline)
                     .foregroundColor(.blue)
                     .frame(width: 25)
                Text(title)
                     .font(.headline)
            }
            Text("Method(s):")
                .font(.caption.weight(.semibold))
                .padding(.leading, 30)
            Text("```swift\n\(method)\n```") // Display code-like
                .font(.caption.monospaced())
                .padding(.leading, 30)
                .tint(.primary.opacity(0.8)) // Make markdown styling visible

            Text("Details:")
                .font(.caption.weight(.semibold))
                .padding(.leading, 30)
            Text(details)
                 .font(.caption)
                 .foregroundColor(.secondary)
                 .padding(.leading, 30)
                 .fixedSize(horizontal: false, vertical: true) // Allow text wrap

            Text("Output:")
                .font(.caption.weight(.semibold))
                .padding(.leading, 30)
            Text("`\(output)`")
                .font(.caption.monospaced())
                .padding(.leading, 30)
                .tint(.primary.opacity(0.8)) // Make markdown styling visible

            Divider().padding(.vertical, 5)
        }
    }
}

struct FlowStep: View {
    let step: Int
    let icon: String
    let text: String

    var body: some View {
        HStack {
            Text("\(step).")
                .font(.headline)
                .frame(width: 25)
            Image(systemName: icon)
                .foregroundColor(.green)
            Text(text)
        }
    }
}

struct FlowArrow: View {
    var body: some View {
        HStack {
            Spacer().frame(width: 30) // Indent arrow
            Image(systemName: "arrow.down")
                .foregroundColor(.gray)
        }
        .frame(height: 10)
    }
}

// MARK: - Preview

#Preview {
    AVCaptureDeviceConceptsView()
}
