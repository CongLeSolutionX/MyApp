////
////  Homescreen.swift
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
//    AIModel(name: "GPT-4o mini", iconName: "circle.grid.3x3.fill", backgroundColor: .green, systemIcon: true),
//    AIModel(name: "Grok AI", iconName: "xmark", backgroundColor: .black.opacity(0.8), systemIcon: true),
//    AIModel(name: "R1", iconName: "figure.wave", backgroundColor: .white, systemIcon: true),
//    AIModel(name: "Sonnet 3", iconName: "sun.max.fill", backgroundColor: Color(hue: 0.05, saturation: 0.4, brightness: 0.9), systemIcon: true)
//]
//
//let aiTools: [AITool] = [
//    AITool(title: "Image Maker", subtitle: "Create art and images w...", creatorImageName: "person.fill", backgroundImageName: "photo.artframe", headline: "UNLIMITED CREATIVITY", description: "See your imagination come to life"),
//    AITool(title: "Video Generator", subtitle: "Generate videos from text...", creatorImageName: "person.fill", backgroundImageName: "video.fill", headline: "DYNAMIC STORYTELLING", description: "Bring your stories to motion")
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
//                    if model.name == "R1" {
//                        Image(systemName: model.iconName)
//                            .resizable().scaledToFit().frame(width: 30, height: 30).foregroundColor(.blue)
//                         Text("deepseek").font(.caption2).foregroundColor(.blue).offset(y: 15)
//                    } else if model.name == "Sonnet 3" {
//                         Image(systemName: model.iconName)
//                            .resizable().scaledToFit().frame(width: 30, height: 30).foregroundColor(.white)
//                         Text("Claude").font(.caption).fontWeight(.medium).foregroundColor(.white).offset(y: 18)
//                    } else if model.name == "Grok AI" {
//                        Image(systemName: model.iconName)
//                           .resizable().fontWeight(.heavy).scaledToFit().scaleEffect(x: 1.5, y: 1.0).frame(width: 25, height: 25).foregroundColor(.white)
//                    }
//                    else {
//                        Image(systemName: model.iconName)
//                            .resizable().scaledToFit().frame(width: 35, height: 35)
//                            .foregroundColor(model.backgroundColor == .white ? .black : .white)
//                    }
//                } else {
//                    Image(model.iconName)
//                        .resizable().scaledToFit().frame(width: 35, height: 35)
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
//            Image(systemName: tool.backgroundImageName)
//                .resizable().aspectRatio(contentMode: .fill).frame(width: 280, height: 350)
//                .clipped()
//                .overlay(
//                    LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.6)]), startPoint: .center, endPoint: .bottom)
//                )
//
//            VStack(alignment: .leading, spacing: 8) {
//                Spacer()
//                Text(tool.headline)
//                    .font(.caption).fontWeight(.semibold).foregroundColor(.white.opacity(0.8)).textCase(.uppercase)
//                Text(tool.description)
//                    .font(.title).fontWeight(.bold).foregroundColor(.white).lineLimit(2).minimumScaleFactor(0.8)
//
//                HStack(spacing: 12) {
//                    Image(systemName: tool.creatorImageName)
//                        .resizable().scaledToFit().frame(width: 40, height: 40)
//                        .background(Color.gray.opacity(0.5)).cornerRadius(8).clipped()
//
//                    VStack(alignment: .leading, spacing: 2) {
//                        Text(tool.title).font(.headline).fontWeight(.semibold).foregroundColor(.white)
//                        Text(tool.subtitle).font(.caption).foregroundColor(.gray).lineLimit(1)
//                    }
//                    Spacer()
//                    Button("Create") { /* Action */ }
//                    .buttonStyle(.borderedProminent).tint(Color.gray.opacity(0.8)).foregroundColor(.white)
//                    .controlSize(.regular).cornerRadius(20)
//                }
//                .padding(12)
//                .background(.ultraThinMaterial.opacity(0.8))
//            }
//            .padding()
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
//                .resizable().scaledToFit().frame(width: 24, height: 24)
//            Text(label).font(.caption2)
//        }
//        .foregroundColor(isSelected ? .white : .gray)
//    }
//}
//
//// MARK: - Main Screen Sections (Discover)
//
//struct TopBarView: View {
//    var body: some View {
//        HStack {
//            Button { /* Action */ } label: {
//                HStack(spacing: 4) {
//                    Image(systemName: "star.fill")
//                    Text("Try Pro")
//                }.foregroundColor(Color(hue: 0.75, saturation: 0.8, brightness: 0.9))
//            }
//            Spacer()
//            Text("Discover")
//                .font(.headline).fontWeight(.medium).foregroundColor(.white)
//            Spacer()
//             Button { /* Action */ } label: {
//                 Image(systemName: "gearshape.fill").font(.title2).foregroundColor(.gray)
//             }
//        }
//        .padding(.horizontal).padding(.top, 5).padding(.bottom, 10)
//    }
//}
//
//struct AIModelsHorizontalScrollView: View {
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 15) {
//                ForEach(aiModels) { model in AIModelIconView(model: model) }
//            }.padding(.horizontal).padding(.bottom)
//        }
//    }
//}
//
//struct AIToolsHorizontalScrollView: View {
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 15) {
//                ForEach(aiTools) { tool in AIToolCardView(tool: tool) }
//            }.padding(.horizontal).padding(.bottom)
//        }
//    }
//}
//
//// MARK: - Refactored Input Area
//
//struct InputAreaView: View {
//    let title: String? // Optional title like "ART & IDEAS"
//    let placeholder: String
//    @State private var inputText: String = ""
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            if let title = title {
//                Text(title)
//                    .font(.caption).fontWeight(.bold).foregroundColor(.orange)
//                    .padding(.horizontal)
//            }
//
//            HStack {
//                TextField(placeholder, text: $inputText, axis: .vertical)
//                    .lineLimit(1...5)
//                    .padding(12)
//                    .background(Color.gray.opacity(0.3))
//                    .cornerRadius(25)
//                    .foregroundColor(.white)
//                    .tint(.gray)
//
//                Button {
//                    print("Sending: \(inputText)")
//                    inputText = ""
//                } label: {
//                    Image(systemName: "arrow.up")
//                        .font(.title3).foregroundColor(.white).padding(10)
//                        .background(Color.gray.opacity(0.5)).clipShape(Circle())
//                }
//                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
//                .opacity(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
//            }
//            .padding(.horizontal)
//        }
//        .padding(.vertical, 5)
//        .background(Color.black.opacity(0.9)) // Changed for contrast/layering
//    }
//}
//
//// MARK: - Custom Tab Bar
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
//        .padding(.bottom, 25)
//        .background(.thinMaterial) // Use material for standard blur
//        // .background(Color.black.opacity(0.8).blur(radius: 5)) // Custom dark blur
//    }
//}
//
//// MARK: - Discover View Content Wrapper
//
//struct DiscoverView: View {
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 10) {
//                TopBarView()
//                SectionHeaderView(iconName: "wand.and.stars.inverse", title: "Latest AI models")
//                AIModelsHorizontalScrollView()
//                SectionHeaderView(iconName: "square.stack.3d.up.fill", title: "AI tools for you")
//                AIToolsHorizontalScrollView()
//                Spacer(minLength: 150) // Bottom spacing
//            }
//        }
//        .scrollIndicators(.hidden)
//    }
//}
//
//// MARK: - Chat View Content
//
//struct ChatView: View {
//    var body: some View {
//        VStack {
//            // Simple Top Bar for Chats
//            HStack {
//                Spacer()
//                Text("Chats")
//                    .font(.headline).fontWeight(.medium).foregroundColor(.white)
//                Spacer()
//            }
//            .padding()
//
//            Spacer()
//
//            Text("No chats yet")
//                .font(.headline)
//                .foregroundColor(.gray)
//
//            Spacer()
//            Spacer()
//        }
//        .padding(.bottom, 150) // Bottom padding to avoid overlap
//    }
//}
//
//// MARK: - Main Content View (Switcher)
//
//struct HomescreenView: View {
//    @State private var selectedTab: Int = 0
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            // Background Color
//            Color.black.edgesIgnoringSafeArea(.all)
//
//            // Main Content Area (Switches Views)
//            VStack(spacing: 0) {
//                 if selectedTab == 0 {
//                     DiscoverView()
//                 } else {
//                     ChatView()
//                 }
//            }
//            // Prevent content from going under the tab bar implicitly
//            // The padding/spacer *inside* DiscoverView/ChatView handles this now
//
//            // Fixed Bottom Elements (Input Area + TabBar)
//            VStack(spacing: 0) {
//                Spacer() // Pushes bottom elements down
//
//                // Conditional Input Area
//                if selectedTab == 0 {
//                    InputAreaView(title: "ART & IDEAS", placeholder: "Ask me for fitness advice")
//                } else {
//                    InputAreaView(title: nil, placeholder: "How can I help?")
//                }
//
//                CustomTabBarView(selectedTab: $selectedTab)
//            }
//             .edgesIgnoringSafeArea(.bottom) // Allows TabBar Material background to extend fully
//
//        }
//        .preferredColorScheme(.dark)
//    }
//}
//
//// MARK: - Corner Radius Helper (If Needed)
//
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
//#Preview("Discover Tab") {
//    HomescreenView()
//}
////
////#Preview("Chats Tab") {
////    // Create an instance and set the initial state for the preview
////    let contentView = HomescreenView()
////    contentView.$selectedTab.wrappedValue = 1 // Start with Chats tab selected
////    contentView
////}
