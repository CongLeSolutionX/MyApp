//
//  CurrentWeatherCardView.swift
//  MyApp
//
//  Created by Cong Le on 3/29/25.
//

import SwiftUI

// MARK: - Data Models (Using Static Data for Local Representation)

struct CurrentWeather {
    let condition: String
    let iconName: String
    let temperature: Int
    let highTemp: Int
    let lowTemp: Int
    let time: String
    let date: String
    let location: String
}

struct DailyForecast: Identifiable {
    let id = UUID()
    let dayAbbreviation: String
    let iconName: String
}

// MARK: - Main Weather Widget View

struct WeatherWidgetView: View {
    // Sample Data (Simulating Local Storage Retrieval)
    let currentData = CurrentWeather(
        condition: "Sunny",
        iconName: "sun.max.fill",
        temperature: 36,
        highTemp: 42,
        lowTemp: 28,
        time: "23:56",
        date: "MON 08-23",
        location: "A Coruña"
    )

    let dailyForecasts = [
        DailyForecast(dayAbbreviation: "TUE", iconName: "sun.max.fill"),
        DailyForecast(dayAbbreviation: "WED", iconName: "cloud.rain.fill"),
        DailyForecast(dayAbbreviation: "THU", iconName: "cloud.rain.fill"),
        DailyForecast(dayAbbreviation: "FRI", iconName: "sun.max.fill")
    ]

    // Custom Colors from CSS
    let backgroundColor = Color(hex: "#ec7263")
    let circleColor = Color(hex: "#efc745")
    let forecastSectionBgColor = Color(hex: "#974859")
    let forecastButtonBgColor = Color(hex: "#a75265")

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Info Section (Top 75%)
            infoSection
                .frame(height: 180 * 0.75) // 75% of total height

            // MARK: - Days Section (Bottom 25%)
            daysSection
                .frame(height: 180 * 0.25) // 25% of total height
        }
        .frame(width: 280, height: 180)
        .background(Color.gray.opacity(0.2)) // Light grey fallback for overall card bg if needed
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 2, y: 3)
        .foregroundColor(.white) // Default text color
    }

    // MARK: - Info Section View
    private var infoSection: some View {
        ZStack {
            // Background Design
            backgroundColor // Base color for the top section

            // Decorative Circles
            Circle()
                .fill(circleColor)
                .frame(width: 300, height: 300)
                .opacity(0.4)
                .offset(x: 280 * 0.4, y: -180 * 0.5) // Position relative to top-right

            Circle()
                .fill(circleColor)
                .frame(width: 210, height: 210)
                .opacity(0.4)
                .offset(x: 280 * 0.3, y: -180 * 0.4) // Position relative to top-right

            Circle()
                .fill(circleColor)
                .frame(width: 100, height: 100)
                .opacity(1.0) // More opaque circle
                .offset(x: 280 * 0.25, y: -180 * 0.15) // Position relative to top-right

            // Content Layer
            HStack {
                // Left Side Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: currentData.iconName)
                        Text(currentData.condition)
                            .font(.headline)
                            .fontWeight(.medium)
                    }

                    Text("\(currentData.temperature)°")
                        .font(.system(size: 56, weight: .medium)) // Adjusted size for visual match
                        .lineLimit(1)

                    Text("\(currentData.highTemp)° / \(currentData.lowTemp)°")
                        .font(.title3)
                        .fontWeight(.medium)

                    Spacer() // Pushes content up if less vertical space
                }
                .padding(.leading, 18)

                Spacer() // Pushes left and right sides apart

                // Right Side Content
                VStack(alignment: .trailing, spacing: 4) {
                    Text(currentData.time)
                        .font(.system(size: 30, weight: .medium)) // Adjusted size
                        .lineLimit(1)

                    Text(currentData.date)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer() // Pushes time/date up

                    Text(currentData.location)
                        .font(.callout)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
                .padding(.trailing, 18)
            }
            .padding(.vertical) // Add some top/bottom padding inside the ZStack
        }
        .clipped() // Clip the background circles to the bounds of this section
    }

    // MARK: - Days Section View
    private var daysSection: some View {
        HStack(spacing: 2) { // Gap between buttons
            ForEach(dailyForecasts) { forecast in
                Button(action: {
                    // Action for tapping a forecast day (optional)
                    print("Tapped on \(forecast.dayAbbreviation)")
                }) {
                    VStack(spacing: 3) { // Gap between day text and icon
                        Text(forecast.dayAbbreviation)
                            .font(.system(size: 13, weight: .medium)) // Adjusted size
                            .opacity(0.7)
                        Image(systemName: forecast.iconName)
                            .font(.system(size: 16)) // Adjusted icon size
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Make button fill space
                    .background(forecastButtonBgColor) // Background for each button area
                }
                .buttonStyle(PlainButtonStyle()) // Remove default button styling
            }
        }
        .background(forecastSectionBgColor) // Background for the whole section
    }
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0) // Default to black
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview Provider

struct WeatherWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherWidgetView()
            .previewLayout(.sizeThatFits) // Preview in a fitting size
            .padding()
            .background(Color.black) // Add dark background for contrast in preview
    }
}

// MARK: - App Entry Point (Optional for single file test)
/*
@main
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
            Color.black.ignoresSafeArea() // Example background
            WeatherWidgetView()
        }
    }
}
*/
