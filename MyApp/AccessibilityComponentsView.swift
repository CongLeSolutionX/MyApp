//
//  AccessibilityComponentsView.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//

import SwiftUI
import Accessibility // Required for AXChartDescriptor

// --- 1. AXChartDescriptorRepresentable Demo ---

/// A simple struct conforming to AXChartDescriptorRepresentable for demonstration.
/// In a real app, this would generate a descriptor based on actual chart data.
struct DemoChartDescriptor: AXChartDescriptorRepresentable {
    let title: String
    let dataSummary: String

    // Creates a basic descriptor.
    func makeChartDescriptor() -> AXChartDescriptor {
        // Define dummy axes and series for demonstration purposes
        let xAxis = AXNumericDataAxisDescriptor(
            title: "Categories",
            range: 0...5, // Example range
            gridlinePositions: [0, 1, 2, 3, 4, 5] // Example gridlines
        ) { value in "\(Int(value))" } // Simple value description

        let yAxis = AXNumericDataAxisDescriptor(
            title: "Values",
            range: 0...100, // Example range
            gridlinePositions: [0, 25, 50, 75, 100] // Example gridlines
        ) { value in "\(Int(value))%" } // Example value description with units

        // Example data points (replace with actual data)
        let dataPoints = [
            AXDataPoint(x: 1, y: 30, additionalValues: [], label: "Point A"),
            AXDataPoint(x: 2, y: 75, additionalValues: [], label: "Point B"),
            AXDataPoint(x: 3, y: 50, additionalValues: [], label: "Point C")
        ]

        let series = AXDataSeriesDescriptor(
            name: "Sample Series",
            isContinuous: false, // Bar chart is not continuous
            dataPoints: dataPoints
        )

        return AXChartDescriptor(
            title: title,
            summary: dataSummary,
            xAxis: xAxis,
            yAxis: yAxis,
            additionalAxes: [],
            series: [series]
        )
    }

    // Handles updates if the chart data or environment changes.
    func updateChartDescriptor(_ descriptor: AXChartDescriptor) {
        // In a real app, you'd update descriptor.title, descriptor.summary,
        // descriptor.series based on the latest data or environment values.
        // For this demo, we won't dynamically update it.
        print("updateChartDescriptor called (if environment changes)")
    }
}

/// A simple view simulating a chart to apply the descriptor.
struct SimpleChartView: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Rectangle().fill(.cyan)
                .frame(width: 30, height: 100)
            Rectangle().fill(.indigo)
                .frame(width: 30, height: 150)
            Rectangle().fill(.mint)
                .frame(width: 30, height: 80)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        // Apply the accessibility chart descriptor
        .accessibilityChartDescriptor(
            DemoChartDescriptor(title: "Monthly Sales", dataSummary: "Sales increased in the second month.")
        )
        .accessibilityLabel("A bar chart showing monthly sales figures.") // General label
    }
}

// --- 2. AccessibilityCustomContentKey Demo ---

/// Define custom keys for accessibility content.
struct CustomAccessibilityKeys {
    static let author = AccessibilityCustomContentKey("Author", id: "com.example.author")
    static let publishDate = AccessibilityCustomContentKey("Published", id: "com.example.publishDate")
    static let status = AccessibilityCustomContentKey(LocalizedStringKey("Status"), id: "com.example.status") // Using LocalizedStringKey
}

struct CustomContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "book.closed.fill")
                .font(.largeTitle)
                .foregroundColor(.brown)
                // Apply custom accessibility content using the defined keys.
                .accessibilityCustomContent(CustomAccessibilityKeys.author, Text("Jane Doe"))
                .accessibilityCustomContent(CustomAccessibilityKeys.publishDate, Text("2023-10-26"), importance: .high)
                .accessibilityCustomContent(CustomAccessibilityKeys.status, Text("Available"), importance: .default)
                .accessibilityLabel("Book Icon") // Provide a base label

            Text("Hover over the book icon with VoiceOver and use the rotor to access custom content.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// --- 3. AccessibilityHeadingLevel Demo ---

struct HeadingLevelView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Article Title")
                .font(.largeTitle)
                // Assign heading level 1 (main title)
                .accessibilityHeading(.h1)

            Text("Introduction")
                .font(.title2)
                // Assign heading level 2 (section)
                .accessibilityHeading(.h2)

            Text("This is the first paragraph...")

            Text("Methodology")
                .font(.title2)
                // Assign heading level 2 (another section)
                .accessibilityHeading(.h2)

            Text("Data Collection")
                .font(.title3)
                // Assign heading level 3 (subsection)
                .accessibilityHeading(.h3)

            Text("This subsection describes data collection details.")

            Text("Conclusion")
                .font(.title2)
                // Assign heading level 2 (final section)
                 .accessibilityHeading(.h2)

            Text("Unspecified Heading Level")
                .font(.headline)
                 // Default or for unstructured content
                 .accessibilityHeading(.unspecified)
        }
    }
}

// --- 4. AccessibilityTextContentType Demo ---

struct TextContentTypeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(" Regular paragraph text.")
                // Implicitly .plain, or explicitly set:
                .accessibilityTextContentType(.plain)

            Text("Error: File not found.")
                // Hint that this is console/log output
                .accessibilityTextContentType(.console)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.red)

            Text("func calculate(value: Int) -> Int { return value * 2 }")
                 // Hint that this is source code
                .accessibilityTextContentType(.sourceCode)
                .font(.system(.caption, design: .monospaced))
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)

            Text("Hey, are you free tonight?")
                // Hint that this is messaging content
                .accessibilityTextContentType(.messaging)

            Text("Chapter 1: The Journey Begins...")
                // Hint that this is narrative content
                .accessibilityTextContentType(.narrative)
                .font(.italic(.body)())

             Text("A1: 10, B1: 20, C1: =A1+B1")
                  // Hint that this represents spreadsheet data
                 .accessibilityTextContentType(.spreadsheet)
                 .font(.system(.body, design: .monospaced))

              Text("Report on Findings")
                 // Hint that this is part of a word processing document
                  .accessibilityTextContentType(.wordProcessing)
                   .font(.headline)
        }
    }
}

// --- 5. AccessibilityTraits Demo ---

struct TraitsView: View {
    @State private var isToggled = false

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Button("Action Button") {
                print("Button tapped")
            }
            // .isButton is often inferred, but can be added explicitly if needed
            // .accessibilityAddTraits(.isButton)

            Text("Section Header")
                .font(.title3).bold()
                // Trait indicating this acts as a header
                .accessibilityAddTraits(.isHeader)

            Link("Visit Example.com", destination: URL(string: "https://example.com")!)
                // .isLink is automatically applied by Link

            Image(systemName: "photo")
                .font(.title)
                 // Trait indicating this is an image
                .accessibilityAddTraits(.isImage)
                .accessibilityLabel("Stock photo icon") // Always provide a label

            Toggle("Enable Feature", isOn: $isToggled)
                 // .isToggle can be useful for custom toggles
                 // .accessibilityAddTraits(.isToggle)

            Text("Read Only Static Text")
                .accessibilityAddTraits(.isStaticText) // Explicitly mark as static
                .foregroundColor(.gray)

            Text("Frequently updating value: \(Int.random(in: 1...100))")
                .accessibilityAddTraits(.updatesFrequently) // Hint for polling

//            // Example of removing a trait (less common, usually used conditionally)
//            Text("SometimesInteractive") // Example: Might sometimes be a button
//                .if(isToggled) { view in
//                    view.accessibilityAddTraits(.isButton) // Add when toggled on
//                       .accessibilityLabel("Interactive Element")
//                } else: { view in
//                     view.accessibilityRemoveTraits(.isButton) // Remove when toggled off
//                        .accessibilityLabel("Non-interactive Element")
//                }
        }
    }
}

// --- Main Demo View ---

struct AccessibilityComponentsDemoView: View {
    var body: some View {
        NavigationView { // Use NavigationView or NavigationStack for title
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    
                    Section("AXChartDescriptorRepresentable") {
                        Text("Provides detailed accessibility information for charts. Applied via `.accessibilityChartDescriptor()`.")
                            .font(.caption).foregroundColor(.secondary)
                        SimpleChartView()
                    }

                    Divider()

                    Section("AccessibilityCustomContentKey") {
                         Text("Adds specific key-value pairs for VoiceOver users, accessed via the rotor. Applied via `.accessibilityCustomContent()`.")
                            .font(.caption).foregroundColor(.secondary)
                         CustomContentView()
                    }

                    Divider()

                    Section("AccessibilityHeadingLevel") {
                         Text("Defines semantic heading levels (h1-h6) for navigation structure. Applied via `.accessibilityHeading()`.")
                             .font(.caption).foregroundColor(.secondary)
                         HeadingLevelView()
                    }

                    Divider()

                    Section("AccessibilityTextContentType") {
                         Text("Provides context about the *type* of text (code, console, narrative, etc.). Applied via `.accessibilityTextContentType()`.")
                            .font(.caption).foregroundColor(.secondary)
                        TextContentTypeView()
                    }

                    Divider()

                    Section("AccessibilityTraits") {
                         Text("Describes the behavior or state of an element (button, header, selected, etc.). Applied via `.accessibilityAddTraits()` or `.accessibilityRemoveTraits()`.")
                            .font(.caption).foregroundColor(.secondary)
                         TraitsView()
                    }
                }
                .padding()
            }
            .navigationTitle("Accessibility Demos")
        }
    }
}

// --- SwiftUI Previews ---
#Preview {
    AccessibilityComponentsDemoView()
}

// --- Helper Extension for Conditional Modifiers ---
extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
