//
//  DynamicTypeView.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//


import SwiftUI

// MARK: - Root View with Tab Navigation

struct ContentView: View {
    var body: some View {
        TabView {
            TextScalingView()
                .tabItem {
                    Label("Text Styles", systemImage: "textformat.size")
                }

            DynamicLayoutContainerView()
                .tabItem {
                    Label("Dynamic Layout", systemImage: "rectangle.split.3x1")
                }

            ImageHandlingView()
                .tabItem {
                    Label("Images", systemImage: "photo.on.rectangle.angled")
                }

            LCVExampleView()
                .tabItem {
                    Label("LCV", systemImage: "arrow.up.left.and.arrow.down.right")
                }
        }
    }
}

// MARK: - Screen 1: Text Scaling Demo

struct TextScalingView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Using Built-In Text Styles")
                        .font(.title) // Example of a primary title

                    Text("SwiftUI's built-in text styles automatically adapt to the user's preferred text size, maintaining visual hierarchy.")
                        .font(.body) // Standard body text

                    Divider()

                    // Demonstrating various text styles
                    Group {
                        Text("Large Title Style")
                            .font(.largeTitle)
                        Text("Title Style")
                            .font(.title)
                        Text("Title 2 Style")
                            .font(.title2)
                        Text("Title 3 Style")
                            .font(.title3)
                        Text("Headline Style")
                            .font(.headline)
                        Text("Subheadline Style")
                            .font(.subheadline)
                        Text("Body Style - for longer reading.")
                            .font(.body)
                        Text("Callout Style")
                            .font(.callout)
                        Text("Footnote Style")
                            .font(.footnote)
                        Text("Caption Style")
                            .font(.caption)
                        Text("Caption 2 Style")
                            .font(.caption2)
                    }
                    .padding(.bottom, 5)

                    Divider()

                    Text("Important UIKit Note:")
                        .font(.headline)
                    Text("In UIKit, remember to set `label.adjustsFontForContentSizeCategory = true` and `label.numberOfLines = 0` for UILabels to ensure they scale and wrap correctly.")
                        .font(.footnote)
                }
                .padding()
            }
            .navigationTitle("Text Scaling")
        }
    }
}

// MARK: - Screen 2: Dynamic Layout Demo

// Data model for the figures
struct Figure: Identifiable, Hashable {
    let id = UUID()
    let systemImageName: String
    let imageTitle: String
}

// Reusable cell for displaying a figure
struct FigureCell: View {
    let figure: Figure

    var body: some View {
        // This cell itself *could* have a dynamic layout,
        // but for this demo, we focus on the container's layout change.
        VStack {
            Image(systemName: figure.systemImageName)
                .font(.largeTitle) // SF Symbols scale well with font size
                .frame(height: 50)
                .foregroundColor(.blue)

            Text(figure.imageTitle)
                .font(.caption) // Use a text style that scales
                .multilineTextAlignment(.center)
        }
        .padding(5)
        // Frame ensures cells have some minimum space, useful in HStack
        .frame(minWidth: 80)
    }
}

// Container view demonstrating the layout switch
struct DynamicLayoutContainerView: View {
    // Access the dynamic type size environment value
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let figures: [Figure] = [
        Figure(systemImageName: "figure.stand", imageTitle: "Standing Figure"),
        Figure(systemImageName: "figure.wave", imageTitle: "Waving Figure"),
        Figure(systemImageName: "figure.walk", imageTitle: "Walking Figure"),
        Figure(systemImageName: "figure.roll", imageTitle: "Rolling Figure")
    ]

    // Define the layout property using AnyLayout
    var dynamicLayout: AnyLayout {
        // Switch layout based on whether the size is an accessibility size
        if dynamicTypeSize.isAccessibilitySize {
            // Use VStack for accessibility sizes to give text more width
            return AnyLayout(VStackLayout(alignment: .leading, spacing: 20))
        } else {
            // Use HStack for default/smaller sizes
            return AnyLayout(HStackLayout(alignment: .top, spacing: 10))
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Dynamic Layout Switching")
                        .font(.title)
                        .padding(.bottom)

                    Text("This layout switches from horizontal (standard sizes) to vertical (accessibility sizes) to ensure labels remain readable.")
                        .font(.body)
                        .padding(.bottom)

                    // Apply the dynamic layout
                    dynamicLayout {
                        ForEach(figures) { figure in
                            FigureCell(figure: figure)
                        }
                    }
                    .padding()
                    // Add a border to visualize the container
                    .border(Color.gray, width: 1)

                    Divider().padding(.vertical)

                    Text("Implementation Notes:")
                        .font(.headline)
                    Text("Uses `@Environment(\\.dynamicTypeSize)` and checks `.isAccessibilitySize`. `AnyLayout` facilitates the switch between `HStackLayout` and `VStackLayout`.")
                        .font(.footnote)
                     Text("In UIKit: Use `UIStackView`, check `traitCollection.preferredContentSizeCategory.isAccessibilityCategory`, and update `stackView.axis`. Subscribe to `UIContentSizeCategory.didChangeNotification`.")
                        .font(.footnote)
                }
                .padding()
            }
            .navigationTitle("Dynamic Layout")
        }
    }
}

// MARK: - Screen 3: Image Handling Demo

struct ImageHandlingView: View {
    // Use @ScaledMetric to scale a value based on text size
    @ScaledMetric var scaledCustomImageWidth: CGFloat = 75.0 // Base width for default size

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Handling Images & Symbols")
                        .font(.title)
                        .padding(.bottom)

                    // 1. Decorative Image (Non-Scaling)
                    Text("1. Decorative Image (Non-Scaling)")
                        .font(.headline)
                    Text("Prioritize text scaling. Ensure text wraps under non-scaling decorative elements. `List` provides this automatically.")
                        .font(.caption)

                    List {
                        HStack {
                            Image(systemName: "gearshape.fill") // Decorative icon
                                .font(.title) // Give it a base size
                                .foregroundColor(.gray)
                                // .resizable() // Do NOT make it resizable if decorative
                                // .scaledToFit()
                                .frame(width: 30, height: 30) // Fixed frame

                            Text("Settings Item: This text should wrap nicely below the fixed-size gear icon when the text size increases significantly.")
                                .font(.body) // This text will scale
                        }
                        .padding(.vertical, 5) // Add padding for larger text

                        // Example using Text Interpolation for similar effect outside List
                         HStack {
                             Text("\(Image(systemName: "star.fill").foregroundColor(.orange)) Important Note: Text with interpolated non-scaling symbols.")
                                .font(.body)
                         }
                         .padding(.vertical, 5)
                    }
                    .frame(height: 180) // Limit list height for demo layout
                    .listStyle(.plain)

                    // 2. SF Symbols (Auto-Scaling)
                    Text("2. SF Symbols (Auto-Scaling)")
                        .font(.headline)
                    Text("SF Symbols generally scale automatically with the associated text's font size.")
                        .font(.caption)
                    HStack {
                         Text("Profile \(Image(systemName: "person.crop.circle"))")
                            .font(.title2) // Text style applied to container scales both text and symbol
                    }

                    // 3. Custom Image (Scaling with @ScaledMetric)
                    Text("3. Custom Essential Image (Scaling)")
                        .font(.headline)
                     Text("Use `@ScaledMetric` for custom images (like logos or informative graphics) that *should* scale with text.")
                        .font(.caption)
                    VStack {
                        // Assume "Spatula" image is in Assets
                        Image("Spatula") // Placeholder - replace with your asset
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: scaledCustomImageWidth) // Use the scaled metric
                            .background(Color.gray.opacity(0.2)) // Background to show frame
                            .overlay(Text("Missing\nImage").font(.caption).multilineTextAlignment(.center).foregroundColor(.red).opacity(imageExists("Spatula") ? 0 : 1)) // Show placeholder if missing

                        Text("Grill Party!")
                            .font(.title3) // Scalable text
                    }
                    .padding()
                    .border(Color.gray)

                    Divider().padding(.vertical)

                     Text("UIKit Notes:")
                        .font(.headline)
                    Text("""
                        - Non-Scaling: Use `NSAttributedString` with `NSTextAttachment`.
                        - Scaling: Use `UIImage.SymbolConfiguration(textStyle:)` or adjust frame based on `UIFontMetrics`.
                        """)
                        .font(.footnote)

                }
                .padding()
            }
            .navigationTitle("Image Handling")
        }
    }

    // Helper to check if image exists in assets (for demo purposes)
    func imageExists(_ name: String) -> Bool {
        return UIImage(named: name) != nil
    }
}

// MARK: - Screen 4: Large Content Viewer Demo

// Define the tabs for the custom bar
enum CustomTab: CaseIterable, Identifiable {
    case world, alarm, stopwatch, timer
    var id: Self { self }

    var title: String {
        switch self {
        case .world: return "World Clock"
        case .alarm: return "Alarm"
        case .stopwatch: return "Stopwatch"
        case .timer: return "Timer"
        }
    }

    var systemImage: String {
        switch self {
        case .world: return "globe"
        case .alarm: return "alarm.fill"
        case .stopwatch: return "stopwatch.fill"
        case .timer: return "timer"
        }
    }
}

struct LCVExampleView: View {
    @State private var selectedTab: CustomTab = .world

    var body: some View {
        NavigationView {
            VStack {
                // Placeholder content area
                Spacer()
                Text("Content for \(selectedTab.title)")
                    .font(.largeTitle)
                Spacer()

                // Custom Tab Bar Implementation
                CustomTabBar(selectedTab: $selectedTab)
                    .padding(.bottom) // Avoid home indicator
            }
            .navigationTitle("Large Content Viewer")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// The custom tab bar that needs LCV support
struct CustomTabBar: View {
    @Binding var selectedTab: CustomTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(CustomTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 22)) // Use fixed size or moderate scaling
                        Text(tab.title)
                            .font(.system(size: 10)) // Small font that won't scale well
                    }
                    .foregroundColor(selectedTab == tab ? .blue : .gray)
                    .frame(maxWidth: .infinity) // Distribute space
                    .padding(.vertical, 5) // Small vertical padding
                }
                // --- LCV Implementation ---
                .accessibilityShowsLargeContentViewer {
                    // Provide the content to display in the LCV popup
                    Label(tab.title, systemImage: tab.systemImage)
                        // Optionally adjust font size for the LCV popup itself
                        .font(.system(size: 60, weight: .bold))
                }
                // --- End LCV Implementation ---
            }
        }
        .background(.thinMaterial) // Apply a background like a real tab bar
        // Note: Height is implicitly determined, which is why it's constrained
         .overlay(Divider(), alignment: .top) // Add a top border
    }
}

// MARK: - Previews (for Development & Testing)

#Preview("Text Scaling") {
    TextScalingView()
}

#Preview("Dynamic Layout - Default") {
    DynamicLayoutContainerView()
        .environment(\.sizeCategory, .large) // Default size
}

#Preview("Dynamic Layout - Accessibility") {
    DynamicLayoutContainerView()
        .environment(\.sizeCategory, .accessibilityExtraLarge) // Accessibility size
}

#Preview("Image Handling") {
    ImageHandlingView()
}

#Preview("LCV Example - Default") {
    LCVExampleView()
        .environment(\.sizeCategory, .large)
}

#Preview("LCV Example - Accessibility") {
    LCVExampleView()
        .environment(\.sizeCategory, .accessibilityExtraLarge)
}

#Preview("ContentView - Default") {
     ContentView()
         .environment(\.sizeCategory, .large)
}

#Preview("ContentView - Accessibility") {
     ContentView()
         .environment(\.sizeCategory, .accessibilityExtraLarge)
}
