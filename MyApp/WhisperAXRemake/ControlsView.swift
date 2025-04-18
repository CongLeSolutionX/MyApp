//
//  ControlsView.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

// ControlsView.swift
import SwiftUI
import WhisperKit // For AudioDevice, if needed directly

struct ControlsView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @EnvironmentObject var settings: AppSettings
    @Binding var isFilePickerPresented: Bool // Passed down

    var body: some View {
        GroupBox("Controls") { // Card style
            VStack {
                BasicSettingsView() // Extracted basic settings

                Divider().padding(.vertical, 5)

                // Mode specific controls
                switch viewModel.selectedTab {
                case .transcribe:
                     transcribeModeControls
                case .stream:
                     streamModeControls
                }
            }
        }
         .padding(.top, 5) // Add some space above controls
         // Show settings sheet
        .sheet(isPresented: $viewModel.showSettingsSheet) {
             SettingsView() // Pass environment objects if SettingsView needs them
                 .environmentObject(viewModel)
                 .environmentObject(settings)
         }
    }

    // --- Mode Specific Control Views ---

    private var transcribeModeControls: some View {
        VStack {
            HStack {
                resetButton
                Spacer()
                #if os(macOS)
                audioDevicePicker.disabled(viewModel.isRecording)
                #endif
                Spacer()
                settingsButton
            }
            .padding(.bottom, 10)

            HStack(spacing: 20) {
                 fileButton
                 recordButton(isStream: false)
            }
        }
    }

    private var streamModeControls: some View {
        VStack {
             HStack {
                resetButton
                Spacer()
                #if os(macOS)
                 audioDevicePicker.disabled(viewModel.isRecording)
                #endif
                Spacer()
                settingsButton
             }
             .padding(.bottom, 10)

            ZStack {
                 recordButton(isStream: true)

                 if viewModel.isRecording {
                     VStack {
                         Text("Enc: \(viewModel.metrics.currentEncodingLoops)")
                         Text("Dec: \(viewModel.metrics.currentDecodingLoops)")
                     }
                     .font(.caption)
                     .foregroundColor(.secondary)
                     .frame(maxWidth: .infinity, alignment: .leading)
                     .padding(.leading, 20) // Adjust positioning

                     Text("\(String(format: "%.1f", viewModel.audioSignal.bufferSeconds)) s")
                         .font(.caption)
                         .foregroundColor(.secondary)
                         .frame(maxWidth: .infinity, alignment: .trailing)
                         .padding(.trailing, 20) // Adjust positioning
                 }
             }
        }
    }

    // --- Common Control Elements ---

    private var resetButton: some View {
        Button {
             viewModel.resetTranscriptionState() // Call ViewModel's reset
        } label: {
            Label("Reset", systemImage: "arrow.clockwise")
        }
        .buttonStyle(.borderless)
    }

    private var settingsButton: some View {
        Button {
             viewModel.showSettingsSheet = true
        } label: {
            Label("Settings", systemImage: "slider.horizontal.3")
        }
        .buttonStyle(.borderless)
    }

    #if os(macOS)
    private var audioDevicePicker: some View {
        Picker("", selection: $settings.selectedAudioInput) {
             ForEach(viewModel.audioDevices, id: \.self) { device in
                 Text(device.name).tag(device.name) // Assuming AudioDevice is Hashable
             }
        }
        .frame(maxWidth: 250) // Limit width
    }
    #endif

    private var fileButton: some View {
        Button {
             isFilePickerPresented = true // Trigger the file importer in ContentView
        } label: {
            VStack {
                Image(systemName: "doc.text.fill")
                    .font(.largeTitle)
                 Text("FROM FILE")
                     .font(.headline)
            }
            .padding()
            .frame(minWidth: 100, minHeight: 70) // Consistent size
            .contentShape(Rectangle()) // Ensure whole area is tappable
        }
        .buttonStyle(CardButtonStyle(enabled: viewModel.modelState == .loaded))
        .disabled(viewModel.modelState != .loaded || viewModel.isRecording)
    }

     private func recordButton(isStream: Bool) -> some View {
         Button {
             viewModel.toggleRecording(isStream: isStream)
         } label: {
             if viewModel.isRecording {
                 Image(systemName: "stop.circle.fill")
                     .resizable()
                     .scaledToFit()
                     .frame(width: 70, height: 70)
                     .foregroundColor(viewModel.modelState == .loaded ? .red : .gray)
             } else {
                 VStack {
                    Image(systemName: isStream ? "record.circle" : "mic.circle.fill")
                        .font(.largeTitle)
                     Text(isStream ? "STREAM" : "RECORD")
                        .font(.headline)
                 }
                 .padding()
                 .frame(minWidth: 100, minHeight: 70) // Consistent size
             }
         }
          .buttonStyle(CardButtonStyle(enabled: viewModel.modelState == .loaded, isRecording: viewModel.isRecording))
          .disabled(viewModel.modelState != .loaded)
          .contentTransition(.symbolEffect(.replace)) // Nice transition
     }
}

// --- Reusable Button Style for Card Look ---
struct CardButtonStyle: ButtonStyle {
    var enabled: Bool = true
    var isRecording: Bool = false // Optional for changing style while recording

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity) // Make buttons expand
            .background(enabled ? (isRecording ? Color.red.opacity(0.1) : Color.blue.opacity(0.1)) : Color.gray.opacity(0.1))
            .foregroundColor(enabled ? (isRecording ? .red : .blue) : .gray)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(enabled ? (isRecording ? Color.red : Color.blue) : Color.gray, lineWidth: enabled ? 1.5 : 1)
            )
    }
}
