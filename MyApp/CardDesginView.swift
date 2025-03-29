////
////  CardDesginView.swift
////  MyApp
////
////  Created by Cong Le on 3/29/25.
////
//

//// MARK: - Card Design Feature (From CardDesignView.swift)
//
//// MARK: Data Model for CardDesignView
//struct CardInfo: Identifiable {
//    let id = UUID()
//    let title: String
//    let description: String
//    let author: String
//    let date: String
//    // Note: imageName is currently unused in CardView but kept as a placeholder.
//    let imageName: String? = nil
//}
//
//// MARK: Styled Card View
//struct CardView: View {
//    let info: CardInfo
//    @State private var isHovering = false // For hover effect simulation on tap
//
//    // Define colors using the hex extension
//    let cardBackground = Color(hex: "#212121")
//    let shadowLight = Color(hex: "#272727")
//    let shadowDark = Color(hex: "#1b1b1b")
//    let imageBackground = Color(hex: "#313131")
//    // Simpler approximation for inset shadows, not a direct CSS translation
//    let imageShadowLight = Color.white.opacity(0.1)
//    let imageShadowDark = Color.black.opacity(0.2)
//    let titleColor = Color(hex: "#b2eccf")
//    let bodyColor = Color(hex: "#B8B8B8")
//    let footerColor = Color(hex: "#B3B3B3")
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            // Image Placeholder Area
//            RoundedRectangle(cornerRadius: 15)
//                .fill(imageBackground)
//                .frame(minHeight: 170)
//                // Attempt at inset shadow effect (simple approximation)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 15)
//                        .stroke(imageShadowDark, lineWidth: 4)
//                        .blur(radius: 3)
//                        .offset(x: 2, y: 2)
//                        .mask(RoundedRectangle(cornerRadius: 15))
//                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 15)
//                        .stroke(imageShadowLight, lineWidth: 4)
//                        .blur(radius: 3)
//                        .offset(x: -2, y: -2)
//                        .mask(RoundedRectangle(cornerRadius: 15))
//                )
//
//            // Card Title
//            Text(info.title)
//                .font(.system(size: 18, weight: .semibold))
//                .foregroundColor(titleColor)
//                .padding(.top, 15)
//                .padding(.leading, 10)
//
//            // Card Body
//            Text(info.description)
//                .font(.system(size: 15))
//                .foregroundColor(bodyColor)
//                .lineLimit(nil) // Allow multiple lines
//                .padding(.top, 13)
//                .padding(.leading, 10)
//                .padding(.trailing, 10)
//
//            Spacer() // Pushes the footer down
//
//            // Footer
//            HStack {
//                Spacer() // Pushes text to the right
//                Text(footerAttributedString())
//                    .font(.system(size: 13))
//                    .foregroundColor(footerColor)
//                    .padding(.trailing, 18)
//            }
//            .padding(.top, 28)
//        }
//        .padding(20) // Overall card padding
//        .frame(width: 330, alignment: .leading)
//        .frame(minHeight: 370)
//        .background(cardBackground)
//        .cornerRadius(20)
//        // Outer Shadows (Neumorphic Style Approximation)
//        .shadow(color: shadowDark, radius: 8, x: 5, y: 5)
//        .shadow(color: shadowLight, radius: 8, x: -5, y: -5)
//        .scaleEffect(isHovering ? 1.03 : 1.0) // Slight scale effect
//        .offset(y: isHovering ? -10 : 0)    // Vertical lift effect
//        .animation(.spring(), value: isHovering)
//        .onTapGesture {
//            // Simulate toggle hover for demo on iOS/iPadOS
//            isHovering.toggle()
//            // On macOS, consider using .onHover { hovering in isHovering = hovering }
//        }
//    }
//
//    // Helper to create attributed string for footer
//    private func footerAttributedString() -> AttributedString {
//        var part1 = AttributedString("Written by ")
//        var authorName = AttributedString(info.author)
//        authorName.font = .system(size: 13, weight: .bold) // Make author bold
//        var part2 = AttributedString(" on \(info.date)")
//
//        // Combine attributes correctly
//        part1.foregroundColor = footerColor
//        authorName.foregroundColor = footerColor
//        part2.foregroundColor = footerColor
//
//        var combined = part1
//        combined.append(authorName)
//        combined.append(part2)
//        return combined
//    }
//}
//
//// MARK: Container View for CardDesign
//struct CardDesignView: View {
//    // Sample Data
//    let sampleCard = CardInfo(
//        title: "Card title",
//        description: "Nullam ac tristique nulla, at convallis quam. Integer consectetur mi nec magna tristique, non lobortis.",
//        author: "Cong Le",
//        date: "03/28/25"
//    )
//
//    var body: some View {
//        ZStack {
//            // Dark background for the whole screen
//            Color(hex: "#1E1E1E").edgesIgnoringSafeArea(.all)
//            CardView(info: sampleCard)
//        }
//        .preferredColorScheme(.dark) // Enforce dark mode
//    }
//}
//
//// MARK: - Gemini Model Details Feature (From GeminiModelCardView.swift)
//
//// MARK: Helper Views for Gemini Model Details
//// Note: Names kept as original for direct mapping, consider renaming for broader reuse.
//
//struct GeminiModelStatusView: View { // Renamed slightly for clarity
//    let isSupported: Bool
//    var body: some View {
//        Text(isSupported ? "Supported" : "Not supported")
//            .font(.caption.weight(.medium))
//            .padding(.horizontal, 8)
//            .padding(.vertical, 4)
//            .foregroundColor(isSupported ? Color.green.opacity(0.9) : Color.red.opacity(0.9))
//            .background(isSupported ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
//            .cornerRadius(6)
//    }
//}
//
//struct GeminiModelPropertyRow: View { // Renamed slightly
//    let icon: String
//    let label: String
//    let value: String
//    var body: some View {
//        HStack(alignment: .top) {
//            Image(systemName: icon)
//                .foregroundColor(.accentColor)
//                .frame(width: 20, alignment: .center)
//            Text(label)
//                .font(.headline)
//                .frame(minWidth: 150, alignment: .leading) // Keep minWidth for alignment
//            Spacer()
//            Text(value)
//                .font(.body)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.trailing)
//        }
//    }
//}
//
//struct GeminiModelPropertyRowMultiLine: View { // Renamed slightly
//    let icon: String
//    let label: String
//    let lines: [(String, String)] // Represents Key-Value pairs for multiline display
//    var body: some View {
//        HStack(alignment: .top) {
//            Image(systemName: icon)
//                .foregroundColor(.accentColor)
//                .frame(width: 20, alignment: .center)
//            Text(label)
//                .font(.headline)
//                .frame(minWidth: 150, alignment: .leading)
//            Spacer()
//            VStack(alignment: .trailing, spacing: 4) {
//                ForEach(lines, id: \.0) { lineItem in // Using tuple elements directly
//                    VStack(alignment: .trailing, spacing: 0) {
//                        Text(lineItem.0).font(.caption).bold() // Key
//                        Text(lineItem.1) // Value
//                            .font(.body)
//                            .foregroundColor(.secondary)
//                            .multilineTextAlignment(.trailing) // Ensure value wraps correctly
//                    }
//                }
//            }
//        }
//    }
//}
//
//// Generic Row for complex value views
//struct GeminiModelPropertyRowComplexValue<Content: View>: View { // Renamed slightly
//    let icon: String
//    let label: String
//    @ViewBuilder let valueContent: Content // Custom content for the value part
//    var body: some View {
//        HStack(alignment: .top) {
//            Image(systemName: icon)
//                .foregroundColor(.accentColor)
//                .frame(width: 20, alignment: .center)
//            Text(label)
//                .font(.headline)
//                .frame(minWidth: 150, alignment: .leading)
//            Spacer()
//            valueContent // Embed the custom view content
//        }
//    }
//}
//
//struct GeminiModelCapabilityItemView: View { // Renamed slightly
//    // Nested struct for Capability data specific to Gemini Model View
//    struct Capability {
//        let name: String
//        let isSupported: Bool
//    }
//    let capability: Capability // Use the nested struct type
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(capability.name).font(.subheadline)
//            GeminiModelStatusView(isSupported: capability.isSupported)
//        }
//    }
//}
//
//// MARK: Main View for Gemini Model Details
//struct GeminiModelDetailView: View { // Renamed for clarity
//
//    // --- Data specific to this view ---
//    // Put Capability struct inside or nearby if only used here
//    typealias Capability = GeminiModelCapabilityItemView.Capability // Alias for convenience
//
//    // Model Information Constants
//    let modelDescription = "Gemini 2.5 Pro Experimental is our state-of-the-art thinking model, capable of reasoning over complex problems..." // Truncated for brevity
//    let modelCode = "gemini-2.5-pro-exp-03-25"
//    let supportedInputs = "Audio, images, video, and text"
//    let supportedOutputs = "Text"
//    let inputTokenLimit = "1,048,576"
//    let outputTokenLimit = "65,536"
//    let latestUpdate = "March 2025"
//    let knowledgeCutoff = "January 2025"
//
//    let capabilities: [Capability] = [ // Use the aliased type
//        Capability(name: "Structured outputs", isSupported: true),
//        Capability(name: "Caching", isSupported: false),
//        Capability(name: "Tuning", isSupported: false),
//        Capability(name: "Function calling", isSupported: true),
//        Capability(name: "Code execution", isSupported: true),
//        // ... (rest of the capabilities)
//        Capability(name: "Search grounding", isSupported: true),
//        Capability(name: "Image generation", isSupported: false),
//        Capability(name: "Native tool use", isSupported: true),
//        Capability(name: "Audio generation", isSupported: false),
//        Capability(name: "Live API", isSupported: false),
//        Capability(name: "Thinking", isSupported: true)
//    ]
//
//    // Grid layout definition
//    let capabilityGridLayout: [GridItem] = [
//        GridItem(.flexible(), alignment: .leading),
//        GridItem(.flexible(), alignment: .leading),
//        GridItem(.flexible(), alignment: .leading)
//    ]
//
//    // --- Body with Card Layout ---
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) { // Spacing BETWEEN cards
//
//                // --- Card 1: Header ---
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Gemini 2.5 Pro Experimental")
//                        .font(.title2) // Adjusted size
//                        .fontWeight(.semibold)
//                    Text(modelDescription)
//                        .font(.body)
//                        .foregroundColor(.secondary)
//                    Button {
//                        print("Try in Google AI Studio tapped") // Placeholder action
//                    } label: {
//                        Label("Try in Google AI Studio", systemImage: "sparkles")
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .padding(.top, 4)
//                }
//                .padding()
//                .background(Color(.secondarySystemGroupedBackground))
//                .cornerRadius(12)
//
//                // --- Card 2: Basic Properties ---
//                VStack(alignment: .leading, spacing: 12) {
//                    GeminiModelPropertyRow(icon: "display", label: "Model code", value: modelCode)
//                    Divider()
//                    GeminiModelPropertyRowMultiLine(
//                        icon: "square.stack.3d.up",
//                        label: "Supported data types",
//                        lines: [("Inputs", supportedInputs), ("Output", supportedOutputs)]
//                    )
//                    Divider()
//                    GeminiModelPropertyRowMultiLine(
//                        icon: "arrow.clockwise.circle",
//                        label: "Token limits [*]",
//                        lines: [("Input token limit", inputTokenLimit), ("Output token limit", outputTokenLimit)]
//                    )
//                }
//                .padding()
//                .background(Color(.secondarySystemGroupedBackground))
//                .cornerRadius(12)
//
//                // --- Card 3: Capabilities ---
//                VStack(alignment: .leading, spacing: 12) {
//                    HStack(spacing: 8) {
//                        Image(systemName: "wrench.and.screwdriver")
//                            .foregroundColor(.accentColor)
//                            .frame(width: 20, alignment: .center)
//                        Text("Capabilities")
//                            .font(.title3.weight(.semibold))
//                    }
//
//                    LazyVGrid(columns: capabilityGridLayout, alignment: .leading, spacing: 12) {
//                        ForEach(capabilities, id: \.name) { capability in
//                             GeminiModelCapabilityItemView(capability: capability)
//                        }
//                    }
//                }
//                .padding()
//                .background(Color(.secondarySystemGroupedBackground))
//                .cornerRadius(12)
//
//                // --- Card 4: Metadata ---
//                VStack(alignment: .leading, spacing: 12) {
//                    GeminiModelPropertyRowComplexValue(
//                        icon: "list.number",
//                        label: "Versions"
//                    ) {
//                        VStack(alignment: .trailing, spacing: 2) {
//                            // Example of complex value content
//                             Button("Read version patterns") { /* Action */ }
//                                .font(.caption)
//                            Text("• Experimental: \(modelCode)") // Direct text
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                    Divider()
//                    GeminiModelPropertyRow(icon: "calendar", label: "Latest update", value: latestUpdate)
//                    Divider()
//                    GeminiModelPropertyRow(icon: "brain.head.profile", label: "Knowledge cutoff", value: knowledgeCutoff)
//                }
//                .padding()
//                .background(Color(.secondarySystemGroupedBackground))
//                .cornerRadius(12)
//
//            } // End Main VStack
//            .padding() // Padding around the entire scrollable content
//        }
//        .background(Color(.systemGroupedBackground)) // Background for the whole view
//        .navigationTitle("Model Details")
//        .navigationBarTitleDisplayMode(.inline) // Or .large
//    }
//}
//
//// MARK: - Previews
//
//#Preview("Card Design") { // Labeled preview
//    CardDesignView()
//}
//
//#Preview("Gemini Model Details") { // Labeled preview
//    NavigationView { // Wrap in NavigationView for title display
//        GeminiModelDetailView()
//    }
//}
