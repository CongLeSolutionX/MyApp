////
////  HomeView.swift
////  MyApp
////
////  Created by Cong Le on 4/6/25.
////
//
//import SwiftUI
//
//// MARK: - Data Models (for sample data)
//
//struct AIModel: Identifiable {
//    let id = UUID()
//    let name: String
//    let iconName: String // Use SF Symbols or custom image names
//    let backgroundColor: Color
//    let systemIcon: Bool // Flag to differentiate SF Symbol vs custom asset
//}
//
//struct AITool: Identifiable {
//    let id = UUID()
//    let title: String
//    let subtitle: String
//    let creatorImageName: String // Use SF Symbols or custom image names
//    let backgroundImageName: String // Use SF Symbols or custom image names
//    let headline: String
//    let description: String
//}
//
//// MARK: - Sample Data
//
//let aiModels: [AIModel] = [
//    AIModel(name: "GPT-4o mini", iconName: "circle.grid.3x3.fill", backgroundColor: .green, systemIcon: true), // Placeholder icon
//    AIModel(name: "Grok AI", iconName: "xmark", backgroundColor: .black.opacity(0.8), systemIcon: true),      // Placeholder icon
//    AIModel(name: "R1", iconName: "figure.wave", backgroundColor: .white, systemIcon: true),                   // Placeholder icon & color
//    AIModel(name: "Sonnet 3", iconName: "sun.max.fill", backgroundColor: Color(hue: 0.05, saturation: 0.4, brightness: 0.9), systemIcon: true) // Placeholder icon & color
//]
//
//let aiTools: [AITool] = [
//    AITool(title: "Image Maker", subtitle: "Create art and images w...", creatorImageName: "person.fill", backgroundImageName: "photo.artframe", headline: "UNLIMITED CREATIVITY", description: "See your imagination come to life"), // Placeholder images
//    AITool(title: "Video Generator", subtitle: "Generate videos from text...", creatorImageName: "person.fill", backgroundImageName: "video.fill", headline: "DYNAMIC STORYTELLING", description: "Bring your stories to motion")      // Placeholder images
//    // Add more tools as needed
//]
//
//// MARK: - Reusable Views
//
//struct SectionHeaderView: View {
//    let iconName: String
//    let title: String
//
//    var body: some View {
//        HStack {
//            Image(systemName: iconName)
//                .foregroundColor(.white)
//            Text(title)
//                .font(.title2)
//                .fontWeight(.bold)
//                .foregroundColor(.white)
//            Spacer()
//        }
//        .padding(.horizontal)
//        .padding(.top)
//    }
//}
//
//struct AIModelIconView: View {
//    let model: AIModel
//
//    var body: some View {
//        VStack(spacing: 8) {
//            ZStack {
//                Circle()
//                    .fill(model.backgroundColor)
//                    .frame(width: 70, height: 70)
//
//                if model.systemIcon {
//                     // Special handling for the "Deepseek" like custom icon look if needed
//                    if model.name == "R1" { // Example for the 'Deepseek'/R1 icon style
//                        Image(systemName: model.iconName)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 30, height: 30)
//                            .foregroundColor(.blue) // Matching blue whale color
//                         Text("deepseek") // Example text inside
//                             .font(.caption2)
//                             .foregroundColor(.blue)
//                             .offset(y: 15)
//                    } else if model.name == "Sonnet 3" { // Example for Claude/Sonnet icon style
//                         Image(systemName: model.iconName)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 30, height: 30)
//                            .foregroundColor(.white)
//                         Text("Claude") // Example text inside
//                             .font(.caption)
//                             .fontWeight(.medium)
//                             .foregroundColor(.white)
//                             .offset(y: 18)
//                    } else if model.name == "Grok AI" {
//                        Image(systemName: model.iconName)
//                           .resizable()
//                           .fontWeight(.heavy)
//                           .scaledToFit()
//                           .scaleEffect(x: 1.5, y: 1.0) // Stretch horizontally like the 'X'
//                           .frame(width: 25, height: 25)
//                           .foregroundColor(.white)
//                    }
//                    else {
//                        Image(systemName: model.iconName)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 35, height: 35)
//                            .foregroundColor(model.backgroundColor == .white ? .black : .white) // Ensure contrast
//                    }
//                } else {
//                    Image(model.iconName) // For custom asset names
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 35, height: 35)
//                }
//            }
//
//            Text(model.name)
//                .font(.caption)
//                .foregroundColor(.gray)
//        }
//        .padding(.horizontal, 5)
//    }
//}
//
//struct AIToolCardView: View {
//    let tool: AITool
//
//    var body: some View {
//        ZStack(alignment: .bottomLeading) {
//            // Background Image
//            Image(systemName: tool.backgroundImageName) // Placeholder
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: 280, height: 350) // Approximate size from screenshot
//                .clipped()
//                .overlay(
//                    LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.6)]), startPoint: .center, endPoint: .bottom)
//                )
//
//            // Content Overlay
//            VStack(alignment: .leading, spacing: 8) {
//                Spacer() // Push text down
//
//                Text(tool.headline)
//                    .font(.caption)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.white.opacity(0.8))
//                    .textCase(.uppercase)
//
//                Text(tool.description)
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                    .lineLimit(2)
//                    .minimumScaleFactor(0.8) // Allow text to shrink slightly if needed
//
//                // Bottom Info Bar
//                HStack(spacing: 12) {
//                    Image(systemName: tool.creatorImageName) // Placeholder
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 40, height: 40)
//                        .background(Color.gray.opacity(0.5))
//                        .cornerRadius(8)
//                        .clipped()
//
//                    VStack(alignment: .leading, spacing: 2) {
//                        Text(tool.title)
//                            .font(.headline)
//                            .fontWeight(.semibold)
//                            .foregroundColor(.white)
//                        Text(tool.subtitle)
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                            .lineLimit(1)
//                    }
//
//                    Spacer()
//
//                    Button("Create") {
//                        // Action for create button
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .tint(Color.gray.opacity(0.8))
//                    .foregroundColor(.white)
//                    .controlSize(.regular)
//                    .cornerRadius(20)
//
//                }
//                .padding(12)
//                .background(.ultraThinMaterial.opacity(0.8)) // Blurred background effect
//                .cornerRadius(15, corners: [.bottomLeft, .bottomRight]) // Apply corner radius only to the info bar itself if desired, or handled by outer ZStack clip
//
//            }
//            .padding() // Padding for the overlayed content
//        }
//        .frame(width: 280, height: 350)
//        .cornerRadius(20)
//    }
//}
//
//struct TabBarItemView: View {
//    let iconName: String
//    let label: String
//    let isSelected: Bool
//
//    var body: some View {
//        VStack(spacing: 4) {
//            Image(systemName: iconName)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 24, height: 24)
//            Text(label)
//                .font(.caption2)
//        }
//        .foregroundColor(isSelected ? .white : .gray)
//    }
//}
//
//// MARK: - Main Screen Sections
//
//struct TopBarView: View {
//    var body: some View {
//        HStack {
//            Button {
//                // Action for Try Pro
//            } label: {
//                HStack(spacing: 4) {
//                    Image(systemName: "star.fill")
//                    Text("Try Pro")
//                }
//                .foregroundColor(Color(hue: 0.75, saturation: 0.8, brightness: 0.9)) // Purple color
//            }
//
//            Spacer()
//
//            Text("Discover") // Positioned more like a title here
//                .font(.headline)
//                .fontWeight(.medium)
//                .foregroundColor(.white)
//
//            Spacer()
//
//            Button {
//                // Action for Settings
//            } label: {
//                Image(systemName: "gearshape.fill")
//                    .font(.title2)
//                    .foregroundColor(.gray)
//            }
//        }
//        .padding(.horizontal)
//        .padding(.top, 5) // Adjust as needed for status bar
//        .padding(.bottom, 10)
//    }
//}
//
//struct AIModelsHorizontalScrollView: View {
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 15) {
//                ForEach(aiModels) { model in
//                    AIModelIconView(model: model)
//                }
//            }
//            .padding(.horizontal)
//            .padding(.bottom)
//        }
//    }
//}
//
//struct AIToolsHorizontalScrollView: View {
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 15) {
//                ForEach(aiTools) { tool in
//                    AIToolCardView(tool: tool)
//                }
//            }
//            .padding(.horizontal)
//            .padding(.bottom)
//        }
//    }
//}
//
//struct InputAreaView: View {
//    @State private var inputText: String = ""
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("ART & IDEAS")
//                .font(.caption)
//                .fontWeight(.bold)
//                .foregroundColor(.orange) // Adjust color
//                .padding(.horizontal)
//
//            HStack {
//                TextField("Ask me for fitness advice", text: $inputText)
//                    .padding(12)
//                    .background(Color.gray.opacity(0.3))
//                    .cornerRadius(25)
//                    .foregroundColor(.white) // Text color when typing
//
//                Button {
//                    // Send/Upload Action
//                } label: {
//                    Image(systemName: "arrow.up")
//                        .font(.title3)
//                        .foregroundColor(.white)
//                        .padding(10)
//                        .background(Color.gray.opacity(0.5))
//                        .clipShape(Circle())
//                }
//            }
//            .padding(.horizontal)
//        }
//        .padding(.bottom, 5)
//    }
//}
//
//struct CustomTabBarView: View {
//    @Binding var selectedTab: Int
//
//    var body: some View {
//        HStack {
//            Spacer()
//            TabBarItemView(iconName: "sparkles", label: "Discover", isSelected: selectedTab == 0)
//                 .onTapGesture { selectedTab = 0 }
//            Spacer()
//            Spacer()
//            TabBarItemView(iconName: "message", label: "Chats", isSelected: selectedTab == 1)
//                 .onTapGesture { selectedTab = 1 }
//            Spacer()
//        }
//        .padding(.top, 8)
//        .padding(.bottom, 25) // Adjust for bottom safe area / home indicator
//        .background(Color.black.opacity(0.8).blur(radius: 5)) // Match the dark theme
//        // Use .background(.ultraThinMaterial) for a more standard iOS blur
//        .edgesIgnoringSafeArea(.bottom) // Allow background to extend
//    }
//}
//
//// MARK: - Main Content View
//
//struct DiscoverView_V1: View {
//    @State private var selectedTab: Int = 0
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            // Main Scrollable Content
//            ScrollView {
//                VStack(spacing: 10) {
//                    TopBarView()
//
//                    SectionHeaderView(iconName: "message.fill", title: "Latest AI models") // Placeholder
//                    AIModelsHorizontalScrollView()
//
//                    SectionHeaderView(iconName: "flame.fill", title: "AI tools for you")
//                    AIToolsHorizontalScrollView()
//
//                    Spacer(minLength: 150) // Add space at the bottom so content scrolls above fixed elements
//                }
//            }
//            .scrollIndicators(.hidden)
//
//            // Fixed Bottom Elements
//            VStack(spacing: 0) {
//                 Spacer() // Pushes InputArea and TabBar to the bottom
//                 InputAreaView()
//                     .background(Color.black.opacity(0.9)) // Background for input area if needed
//                 CustomTabBarView(selectedTab: $selectedTab)
//            }
//
//        }
//        .background(Color.black.edgesIgnoringSafeArea(.all)) // Main background
//        .preferredColorScheme(.dark)
//    }
//}
//
//// MARK: - Corner Radius Helper
//
//// Helper extension to apply corner radius to specific corners
//extension View {
//    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//        clipShape( RoundedCorner(radius: radius, corners: corners) )
//    }
//}
//
//struct RoundedCorner: Shape {
//    var radius: CGFloat = .infinity
//    var corners: UIRectCorner = .allCorners
//
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        return Path(path.cgPath)
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    DiscoverView_V1()
//}
