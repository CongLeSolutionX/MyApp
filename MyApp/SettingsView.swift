//
//  SettingsView.swift
//  MyApp
//
//  Created by Cong Le on 3/11/25.
//

import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    // Scanner Configuration Settings
    @State private var soundFeedbackEnabled: Bool = true
    @State private var vibrationFeedbackEnabled: Bool = true
    @State private var autoScanOption: AutoScanOption = .disabled

    // Data Synchronization Settings
    @State private var selectedCloudService: CloudService = .iCloud
    @State private var syncFrequency: SyncFrequency = .manual

    // User Interface Settings
    @State private var selectedTheme: Theme = .light

    var body: some View {
        NavigationView {
            Form {
                // MARK: Scanner Configuration Section
                Section(header: Text("Scanner Configuration")) {
                    Toggle("Sound Feedback", isOn: $soundFeedbackEnabled)
                    Toggle("Vibration Feedback", isOn: $vibrationFeedbackEnabled)
                    
                    Picker("Auto-Scan Options", selection: $autoScanOption) {
                        ForEach(AutoScanOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }
                
                // MARK: Data Synchronization Section
                Section(header: Text("Data Synchronization")) {
                    Picker("Cloud Service", selection: $selectedCloudService) {
                        ForEach(CloudService.allCases) { service in
                            Text(service.rawValue).tag(service)
                        }
                    }
                    
                    Picker("Sync Frequency", selection: $syncFrequency) {
                        ForEach(SyncFrequency.allCases) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                }
                
                // MARK: User Interface Section
                Section(header: Text("User Interface")) {
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(Theme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    
                    NavigationLink("Display Options", destination: DisplayOptionsView())
                }
                
                // MARK: About & Privacy
                Section {
                    NavigationLink("About & Privacy Policy", destination: AboutPrivacyView())
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Enumerations for Picker Options

enum AutoScanOption: String, CaseIterable, Identifiable {
    case disabled = "Disabled"
    case continuous = "Continuous"
    
    var id: String { self.rawValue }
}

enum CloudService: String, CaseIterable, Identifiable {
    case iCloud = "iCloud"
    case custom = "Custom"
    
    var id: String { self.rawValue }
}

enum SyncFrequency: String, CaseIterable, Identifiable {
    case manual = "Manual"
    case automatic = "Automatic"
    
    var id: String { self.rawValue }
}

enum Theme: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    
    var id: String { self.rawValue }
}

// MARK: - Display Options View

struct DisplayOptionsView: View {
    @State private var fontSize: Double = 14
    @State private var listDensity: Double = 1.0
    
    var body: some View {
        Form {
            Section(header: Text("Display Options")) {
                HStack {
                    Text("Font Size")
                    Slider(value: $fontSize, in: 10...24, step: 1)
                    Text("\(Int(fontSize))")
                }
                HStack {
                    Text("List Density")
                    Slider(value: $listDensity, in: 0.5...2.0, step: 0.1)
                    Text(String(format: "%.1f", listDensity))
                }
            }
        }
        .navigationTitle("Display Options")
    }
}

// MARK: - About & Privacy Policy View

struct AboutPrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("About")
                    .font(.headline)
                Text("This inventory app supports barcode scanning, manual entry, and robust data management. The design emphasizes user-friendly interactions and clear feedback.")
                
                Text("Privacy Policy")
                    .font(.headline)
                Text("We take user privacy seriously. Data is securely stored and synchronized. For full details, please review our privacy policy.")
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("About & Privacy Policy")
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
