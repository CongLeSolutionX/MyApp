//
//  SettingsView.swift
//  MyApp
//
//  Created by Cong Le on 3/17/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedTheme: Theme = .default
    @State private var selectedAppearance: Appearance = .light
    @State private var appVersion: String = "0.0.2"
    @State private var isSwitchOn: Bool = false

    enum Theme: String, CaseIterable, Identifiable {
        case `default` = "Default"
        case androidBrand = "Android brand"
        var id: String { self.rawValue }
    }

    enum Appearance: String, CaseIterable, Identifiable {
        case systemDefault = "System default"
        case light = "Light"
        case dark = "Dark"
        var id: String { self.rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection
                userSection
                themeSection
                appearanceSection
                appVersionSection
                switchSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground)) // For grouped background
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline) // Keep the title inline
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // Handle close action
                }) {
                    Image(systemName: "xmark")
                }
            }
            ToolbarItem(placement: .principal) {
                HStack {
                    Text(formattedTime)
                        .font(.subheadline)
                    Image(systemName: "circle.fill")
                        .font(.system(size: 8))
                }
            }
            ToolbarItem(placement:.topBarTrailing) {
                HStack(spacing:15) {
                Image(systemName: "wifi")
                                .font(.system(size: 16))
                Image(systemName: "battery.100")
                                .font(.system(size: 16))
                }

            }
        }

    }

     var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateFormat = "H:mm"
        return formatter.string(from: Date())
    }
    
    var headerSection: some View {
       //Using empty view to match the design
        EmptyView()
    }

    var userSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                VStack(alignment: .leading) {
                    Text("Cong")
                        .font(.title2)
                    Text("@materialdesign")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.down")
            }
            .padding(.vertical, 8)
            Button("Manage your Google Account") {
                // Handle button action
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    var themeSection: some View {
        VStack(alignment: .leading) {
            Text("Theme")
                .font(.headline)
            ForEach(Theme.allCases) { theme in
                HStack {
                    Circle()
                        .fill(selectedTheme == theme ? Color.purple : Color.clear)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))

                    Text(theme.rawValue)
                    Spacer()
                }
                .contentShape(Rectangle()) // Make the whole row tappable
                .onTapGesture {
                    selectedTheme = theme
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    var appearanceSection: some View {
        VStack(alignment: .leading) {
            Text("Appearance")
                .font(.headline)

            ForEach(Appearance.allCases) { appearance in
                HStack {
                    Circle()
                        .fill(selectedAppearance == appearance ? Color.purple : Color.clear)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))

                    Text(appearance.rawValue)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedAppearance = appearance
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    var appVersionSection: some View {
        VStack(alignment: .leading) {
            Text("App version")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(appVersion)
                 .font(.subheadline)
                .foregroundColor(.gray)

        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    var switchSection: some View{
        
        HStack {
               Text("Switch text")
            Spacer()
           Toggle(isOn: $isSwitchOn) {
               EmptyView()
           }
           .labelsHidden() // Hide the default label

       }
       .padding()
       .background(Color(.systemBackground))
       .cornerRadius(12)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
