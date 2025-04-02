//
//  SwiftUIFoundationsCoreImprovements.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//
//
//import SwiftUI
//
//// --- Custom Container Definition ---
//
//// Define a custom value key for container-specific data
//private struct DisplayBoardCardStyleKey: ContainerValueKey {
//    static var defaultValue: DisplayBoardCardStyle = .standard
//}
//
//// Extend ContainerValues with the custom property using @Entry
//extension ContainerValues {
//    @Entry var displayBoardCardStyle: DisplayBoardCardStyle = .standard
//}
//
//// Define the possible styles
//enum DisplayBoardCardStyle {
//    case standard, prominent, subtle
//}
//
//// Simple Card View for wrapping subviews
//struct CardView<Content: View>: View {
//    @Environment(\.self) private var environment
//    let content: Content
//
//    // Read the custom container value
//    private var cardStyle: DisplayBoardCardStyle {
//        environment.displayBoardCardStyle.
//    }
//
//    var body: some View {
//        content
//            .padding()
//            .background(cardBackgroundColor, in: RoundedRectangle(cornerRadius: 8))
//            .shadow(radius: 2)
//            .padding(.vertical, 4) // Spacing between cards
//    }
//
//    private var cardBackgroundColor: Color {
//        switch cardStyle {
//        case .standard: .gray.opacity(0.1)
//        case .prominent: .blue.opacity(0.2)
//        case .subtle: .clear
//        }
//    }
//}
//
//// The Custom Container View
//struct DisplayBoard<Content: View>: View {
//    @ViewBuilder var content: Content
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading) {
//                // Iterate over the direct children provided at the call site
//                ForEach(subviewOf: content) { sectionSubview in
//                    // Check if the subview represents a Section
//                    if sectionSubview.represents(Section<AnyView, AnyView, EmptyView>.self) {
//                        // Handle sections explicitly
//                        AnyView(sectionSubview) // Type-erase to work with Section
//                            .padding(.top)
//                    } else {
//                         AnyView(sectionSubview) // Type-erase to work with other Views
//                        // Wrap individual, non-Section views
//                        // Note: In a real Section implementation, you'd iterate *inside* the section's content.
//                        // This basic example just shows identifying a Section vs other views.
//                        // For simplicity wrapping Sections directly. A real layout would dive deeper.
//                        CardView {
//                           AnyView(sectionSubview)
//                        }
//                    }
//                }
//            }
//            .padding()
//        }
//        .background(Color.gray.opacity(0.05))
//    }
//}
//
//// Custom Modifier to set the container value
//extension View {
//    func displayBoardCardStyle(_ style: DisplayBoardCardStyle) -> some View {
//        self.containerValue(\.displayBoardCardStyle, style)
//    }
//}
//
//// --- Custom Container Usage ---
//
//struct Song: Identifiable {
//    let id = UUID()
//    let title: String
//    var rating: Int? = nil
//}
//
//struct CustomContainerExampleView: View {
//    let songsFromSam = [Song(title: "Cupertino Dreamin'"), Song(title: "View Controller Blues")]
//    let songsFromSommer = [Song(title: "Smells Like Scene Spirit", rating: 5), Song(title: "Layout Livin'")]
//
//    var body: some View {
//        DisplayBoard {
//            Text("Upcoming Hits").font(.title) // Static content
//
//            Section("Sam's Jams") {
//                ForEach(songsFromSam) { song in
//                    Text(song.title)
//                }
//                 // Apply modifier to a specific section
//                .displayBoardCardStyle(.prominent)
//            }
//
//            Section("Sommer's Anthems") {
//                 ForEach(songsFromSommer) { song in
//                    HStack {
//                        Text(song.title)
//                        if let rating = song.rating {
//                           Spacer()
//                           Image(systemName: "\(rating).circle.fill")
//                        }
//                    }
//                }
//                .displayBoardCardStyle(.subtle) // Apply different style
//            }
//
//            Text("More to come...").font(.caption) // More static content
//        }
//        // Apply default style to the whole container
//        .displayBoardCardStyle(.standard)
//    }
//}
//
//#Preview {
//    CustomContainerExampleView()
//}
