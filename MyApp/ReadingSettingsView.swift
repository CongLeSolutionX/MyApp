//
//  ReadingSettingsView.swift
//  MyApp
//
//  Created by Cong Le on 3/28/25.
//


import SwiftUI

struct ReadingSettingsView: View {
    @EnvironmentObject var settings: ReadingSettings // Access shared settings
    @Environment(\.dismiss) var dismiss // To close the sheet
    
    var body: some View {
        NavigationView {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $settings.selectedTheme) {
                        ForEach(ReadingTheme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Line Spacing: \(settings.lineSpacingMultiplier, specifier: "%.1f")x")
                        Slider(value: $settings.lineSpacingMultiplier, in: 1.0...3.0, step: 0.1) {
                            Text("Line Spacing Slider") // Hidden label
                        } minimumValueLabel: {
                            Text("1.0x")
                        } maximumValueLabel: {
                            Text("3.0x")
                        }
                        .accessibilityLabel("Line Spacing")
                        .accessibilityValue("\(settings.lineSpacingMultiplier, specifier: "%.1f") times normal")
                    }
                }
                
                Section("Layout") {
                    VStack(alignment: .leading) {
                        Text("Content Width: \(Int(settings.columnWidthMultiplier * 100))%")
                        Slider(value: $settings.columnWidthMultiplier, in: 0.5...1.0, step: 0.1) {
                            Text("Content Width Slider") // Hidden label
                        } minimumValueLabel: {
                            Text("50%")
                        } maximumValueLabel: {
                            Text("100%")
                        }
                        .accessibilityLabel("Content Width")
                        .accessibilityValue("\(Int(settings.columnWidthMultiplier * 100)) percent")
                    }
                    .accessibilityElement(children: .combine) // Combine labels for VoiceOver
                }
            }
            .navigationTitle("Reading Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
//
//#Preview {
//    ReadingSettingsView()
//}
