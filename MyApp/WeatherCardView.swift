//
//  WeatherCardView.swift
//  MyApp
//
//  Created by Cong Le on 3/29/25.
//

import SwiftUI

// Simple struct to hold weather data (can be expanded)
struct WeatherData {
    var locationLine1: String = "Messadine, Susah"
    var locationLine2: String = "Tunisia"
    var date: String = "March 13"
    var temperature: Int = 23
    var unit: String = "Celcius"
    // In a real app, add properties for weather condition (e.g., sunny, cloudy)
    // to dynamically change the icon.
}

struct WeatherIconView: View {
    // Properties for animation could be added here if needed
    // For now, it's static based on the CSS layout
    
    var body: some View {
        ZStack {
            // Sun
            Circle()
                .fill(LinearGradient(
                    // Use nil-coalescing (??) to provide default colors if hex parsing fails
                    gradient: Gradient(colors: [
                        Color(hex: "#fcbb04") ?? .orange, // Default to orange if hex is invalid
                        Color(hex: "#fffc00") ?? .yellow  // Default to yellow if hex is invalid
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 120, height: 120)
            // Add .animation for sun pulse if desired
            
            // Back Cloud
            ZStack {
                // Left part of back cloud
                Capsule()
                    .fill(Color(hex: "#4c9beb") ?? .orange)
                    .frame(width: 50, height: 30) // Adjusted from CSS interpretation
                    .offset(x: -15, y: 5) // Relative positioning
                
                // Right part of back cloud
                Circle()
                    .fill(Color(hex: "#4c9beb") ?? .orange)
                    .frame(width: 50, height: 50)
                    .offset(x: 15, y: 0) // Relative positioning
            }
            .offset(x: 45, y: -20) // Position the back cloud relative to sun center
            // Add .animation for cloud movement if desired
            
            // Front Cloud
            ZStack {
                // Left part of front cloud
                Circle()
                    .fill(Color(hex: "#4c9beb") ?? .green)
                    .frame(width: 65, height: 65)
                    .offset(x: -20) // Relative positioning
                
                // Right part of front cloud
                Capsule()
                    .fill(Color(hex: "#4c9beb") ?? .green)
                    .frame(width: 60, height: 45) // Adjusted from CSS interpretation
                    .offset(x: 15, y: 5) // Relative positioning
            }
            .offset(x: -25, y: 25) // Position the front cloud relative to sun center
            // Add .animation for cloud movement if desired
        }
        .compositingGroup() // Helps with rendering complex overlapping views
        .scaleEffect(0.7) // Scale down the entire icon assembly
    }
}

struct WeatherCardView: View {
    @State private var weatherData = WeatherData()
    
    // Custom Colors from CSS
    let primaryTextColor = Color(red: 87/255, green: 77/255, blue: 51/255) // rgba(87, 77, 51, 1)
    let secondaryTextColor = Color(red: 87/255, green: 77/255, blue: 51/255, opacity: 0.66)
    let tertiaryTextColor = Color(red: 87/255, green: 77/255, blue: 51/255, opacity: 0.33)
    let scaleBackgroundColor = Color(white: 0.0, opacity: 0.06)
    let gradientStartColor = Color(hex: "#FFF7B1") ?? .yellow.opacity(0.5)
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background Gradient and Base Color
            RoundedRectangle(cornerRadius: 23)
                .fill(.white)
            
            RoundedRectangle(cornerRadius: 23)
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: gradientStartColor, location: 0.0),
                            .init(color: .white.opacity(0.0), location: 0.7) // Approximate fade based on CSS
                        ]),
                        center: .init(x: 0.26, y: 1.06), // Bottom-leftish center
                        startRadius: 0,
                        endRadius: 350 // Larger radius to mimic spread
                    )
                )
                .allowsHitTesting(false) // Gradient shouldn't block interaction
            
            // Main Content Layer
            VStack(alignment: .leading, spacing: 0) {
                // Header: Location and Date
                VStack(alignment: .leading, spacing: 5) {
                    Text(weatherData.locationLine1)
                    Text(weatherData.locationLine2)
                }
                .font(.system(size: 15, weight: .heavy)) // Using heavier weight for first line
                .foregroundColor(secondaryTextColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8) // Allow shrinking if text is too long
                
                Text(weatherData.date)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(tertiaryTextColor)
                    .padding(.top, 5)
                
                Spacer() // Pushes temp and scale to the bottom
                
                HStack(alignment: .bottom) {
                    // Temperature
                    Text("\(weatherData.temperature)°")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(primaryTextColor)
                    
                    Spacer() // Pushes scale to the right
                    
                    // Temperature Scale
                    Text(weatherData.unit)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(secondaryTextColor)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(scaleBackgroundColor)
                        .cornerRadius(9)
                        .padding(.bottom, 13) // Align baseline better with large temp text
                }
            }
            .padding(25) // Inner padding for content
            
            // Weather Icon (Positioned absolutely relative to ZStack)
            WeatherIconView()
                .offset(x: 235, y: -40) // Adjusted offset for SwiftUI positioning
            
        }
        .frame(width: 350, height: 235)
        .background(.clear) // Make outer background clear to see shadow correctly
        .shadow(color: .black.opacity(0.01), radius: 62, x: 0, y: 155)
        .shadow(color: .black.opacity(0.05), radius: 52, x: 0, y: 87)
        .shadow(color: .black.opacity(0.09), radius: 39, x: 0, y: 39)
        .shadow(color: .black.opacity(0.1), radius: 21, x: 0, y: 10)
        // Note: SwiftUI shadows stack differently than CSS. This approximates the layered effect.
    }
}

// Helper extension for Hex colors (optional but convenient)
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}

// Main App Structure and Content View for Preview
struct WeatherWidgetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        ZStack {
            // Dark background similar to the original image context
            Color.black.opacity(0.9).ignoresSafeArea()
            
            WeatherCardView()
            // Add .scaleEffect and .animation here if hover effect is desired
        }
    }
}

// Xcode Preview Provider
#Preview {
    ContentView()
}
