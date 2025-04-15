//
//  ContentView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/15/25.
//

import SwiftUI
import PDFKit

//@main
//struct PortfolioApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .preferredColorScheme(.none) // System appearance
//        }
//    }
//}

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            ProjectsView()
                .tabItem { Label("Projects", systemImage: "folder.fill") }
            SkillsView()
                .tabItem { Label("Skills", systemImage: "chart.pie.fill") }
            ContactView()
                .tabItem { Label("Contact", systemImage: "envelope.fill") }
        }
    }
}
#Preview("ContentView") {
    ContentView()
}
// MARK: - Home / Profile + Resume

struct HomeView: View {
    @State private var showingResume = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ProfileHeaderView()
                    Text("Passionate iOS Developer skilled in Swift, SwiftUI, and elegant app experiences. I build clean, efficient, and user-centric apps.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.secondary)
                    
                    Button(action: { showingResume.toggle() }) {
                        Label("View Resume", systemImage: "doc.richtext.fill")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor.opacity(0.1))
                            .foregroundColor(Color.accentColor)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $showingResume) {
                        ResumeView()
                    }
                    Spacer(minLength: 150)
                }
                .padding(.top)
            }
            .navigationTitle("About Me")
        }
    }
}

struct ResumeView: View {
    var body: some View {
        Group {
            if let url = Bundle.main.url(forResource: "Resume", withExtension: "pdf") {
                PDFKitView(url: url)
            } else {
                Text("Resume PDF not found.")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.document = PDFDocument(url: url)
        view.autoScales = true
        view.displayDirection = .vertical
        return view
    }
    func updateUIView(_ uiView: PDFView, context: Context) { }
}


struct ProfileHeaderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image("My-meme-orange") // Replace with your profile photo asset
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 140, height: 140)
                .clipShape(Circle())
                .shadow(color: .primary.opacity(0.25), radius: 8, x: 0, y: 4)
            
            Text("Cong Le")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("iOS Developer")
                .font(.title3)
                .foregroundColor(.accentColor)
            
            HStack(spacing: 16) {
                Link(destination: URL(string: "https://github.com/CongLeSolutionX")!) {
                    Label("GitHub", systemImage: "chevron.left.slash.chevron.right")
                }
                Link(destination: URL(string: "https://www.linkedin.com/in/conglesolutionx/")!) {
                    Label("LinkedIn", systemImage: "link")
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }
}

// MARK: - Projects with Filter + Search

struct ProjectsView: View {
    @State private var selectedFilter: TechFilter = .all
    @State private var searchText: String = ""
    
    private var filteredProjects: [Project] {
        SampleData.projects.filter { p in
            (selectedFilter == .all || p.techStack.contains(selectedFilter.rawValue)) &&
            (searchText.isEmpty ||
             p.title.localizedCaseInsensitiveContains(searchText) ||
             p.shortDescription.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(TechFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                SearchBar(text: $searchText, placeholder: "Search Projects")
                    .padding([.horizontal, .bottom])
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if filteredProjects.isEmpty {
                            Text("No projects found.")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                        ForEach(filteredProjects) { project in
                            ProjectCardView(project: project)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Projects")
        }
    }
}

enum TechFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case Swift = "Swift"
    case SwiftUI = "SwiftUI"
    case UIKit = "UIKit"
    case Combine = "Combine"
    case CoreData = "CoreData"
    case SpriteKit = "SpriteKit"
    
    var id: String { rawValue }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        let bar = UISearchBar(frame: .zero)
        bar.delegate = context.coordinator
        bar.placeholder = placeholder
        bar.autocapitalizationType = .none
        bar.searchBarStyle = .minimal
        return bar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
}

struct ProjectCardView: View {
    let project: Project
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: project.iconName)
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                    .frame(width: 50, height: 50)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.title)
                        .font(.headline)
                    Text(project.shortDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Button(action: { withAnimation(.spring()) { isExpanded.toggle() } }) {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .foregroundColor(.accentColor)
                        .imageScale(.large)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if isExpanded {
                Divider()
                Text(project.detailedDescription)
                    .font(.body)
                    .transition(.opacity.combined(with: .slide))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(project.techStack, id: \.self) { tech in
                            Text(tech)
                                .font(.caption)
                                .padding(8)
                                .background(Color.accentColor.opacity(0.15))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                HStack(spacing: 30) {
                    if let github = project.githubURL {
                        Link(destination: github) {
                            Label("GitHub", systemImage: "link")
                        }
                    }
                    if let demo = project.demoURL {
                        Link(destination: demo) {
                            Label("Live Demo", systemImage: "play.circle.fill")
                        }
                    }
                }
                .font(.subheadline)
                .foregroundColor(.accentColor)
                .padding(.top, 6)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.primary.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Skills View with Rings Animation

struct SkillsView: View {
    let skills = SampleData.skills
    
    // Adaptive columns for various devices
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 140), spacing: 20)]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(skills) { skill in
                        SkillRingView(skill: skill)
                    }
                }
                .padding()
            }
            .navigationTitle("Skills")
        }
    }
}

struct SkillRingView: View {
    let skill: Skill
    @State private var animatedProgress: CGFloat = 0
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 14)
                    .opacity(0.2)
                    .foregroundColor(Color.accentColor)
                    .frame(width: 140, height: 140)
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .foregroundColor(Color.accentColor)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.easeOut(duration: 1.2), value: animatedProgress)
                    .frame(width: 140, height: 140)
                
                VStack(spacing: 6) {
                    Image(systemName: skill.iconName)
                        .font(.largeTitle)
                        .foregroundColor(.accentColor)
                    Text(skill.name)
                        .font(.headline)
                    Text("\(Int(skill.proficiency * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            animatedProgress = CGFloat(skill.proficiency)
        }
    }
}

// MARK: - Contact View with Copy & Mail

struct ContactView: View {
    @State private var email = "CongLeJobs@gmail.com"
    @State private var phone = "TBD"
    @State private var showAlert = false
    @State private var alertText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Get in Touch!")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.top, 40)
                
                ContactInfoRow(icon: "envelope.fill", label: email) {
                    copyToClipboard(email)
                }
                ContactInfoRow(icon: "phone.fill", label: phone) {
                    copyToClipboard(phone)
                }
                
                Spacer()
                
                Button(action: sendEmail) {
                    Label("Send Email", systemImage: "paperplane.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundColor(.accentColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationTitle("Contact")
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertText))
            }
            .padding()
        }
    }
    
    func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        alertText = "\(text) copied to clipboard!"
        showAlert = true
    }
    
    func sendEmail() {
        guard let url = URL(string: "mailto:\(email)") else {
            alertText = "Invalid email address."
            showAlert = true
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            alertText = "Cannot open Mail app."
            showAlert = true
        }
    }
}

struct ContactInfoRow: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                Text(label)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "doc.on.doc.fill")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Data Models and Sample Data

struct Project: Identifiable, Hashable {
    let id = UUID()
    let iconName: String
    let title: String
    let shortDescription: String
    let detailedDescription: String
    let techStack: [String]
    let githubURL: URL?
    let demoURL: URL?
}

struct Skill: Identifiable, Hashable {
    let id = UUID()
    let iconName: String
    let name: String
    let proficiency: Double // 0...1
}

struct SampleData {
    static let projects: [Project] = [
        Project(iconName: "app.fill",
                title: "Metal Primitives",
                shortDescription: "This project showcases the fundamental components of Apple's Metal framework.",
                detailedDescription: "The project covers a range of rendering examples:\nClear Screen: Basics of setting up a Metal view and clearing the screen with a solid color.\nDraw 2D Triangle: Rendering a simple 2D triangle on the screen.\nDraw Spinning 3D Cube: Displaying a rotating 3D cube with basic transformations.\nDraw Spinning Teapot with Manual Lighting: Rendering a spinning teapot model with custom lighting effects.\nDraw Spinning Cow with Manual Lighting and Custom Texture: Displaying a textured cow model with lighting.\nEach example is fully programmatic—no Storyboards, XIBs, or NIBs are used—providing a clear understanding of the code involved in setting up and rendering Metal views.",
                techStack: ["Swift", "SwiftUI", "UIKit", "MetalKit Framework", "Objective-C"],
                githubURL: URL(string: "https://github.com/CongLeSolutionX/Metal-Primitives"),
                demoURL: URL(string: "https://github.com/CongLeSolutionX/Metal-Primitives/blob/main/Resources/Demo-on-iOS-devices.gif")),
        
        Project(iconName: "phone.fill",
                title: "iOS Development Vault",
                shortDescription: "A collection of my iOS development notes and resources.",
                detailedDescription: "These notes cover a wide array of subjects with varying levels of depth and detail. I aim to present iOS development concepts and practices using visual representations.",
                techStack: ["Swift", "UIKit", "AVFoundation", "CoreData"],
                githubURL: URL(string: "https://github.com/CongLeSolutionX/iOS-development-vault"),
                demoURL: nil),
        
        Project(iconName: "app.fill",
                title: "Mermaid Canvas",
                shortDescription: "MermaidCanvas for SwiftUI.",
                detailedDescription: "Seamlessly render Mermaid diagrams within your SwiftUI applications.",
                techStack: ["Swift", "SwiftUI", "Mermaid"],
                githubURL: URL(string: "https://github.com/CongLeSolutionX/Mermaid-Canvas"),
                demoURL: URL(string: "https://github.com/CongLeSolutionX/Mermaid-Canvas/blob/main/Media/Demo_Rendering_Mermaid_Syntax.png")),
        Project(iconName: "gamecontroller.fill",
                title: "RealityKit SwiftUI Bridge",
                shortDescription: "Bridging SwiftUI view and RealityKit view using Coordinator pattern.",
                detailedDescription: "",
                techStack: ["Swift", "SwiftUI", "RealityKit"],
                githubURL: URL(string: "https://github.com/CongLeSolutionX/RealityKit_SwiftUI_Bridge"),
                demoURL: nil),
        Project(iconName: "app.fill",
                title: "Apple Frameworks in Mermaid Diagrams",
                shortDescription: "This is a collection of official Apple frameworks that being converting to a series of Mermaid diagrams or illustration for quickly to look up something and easy to understand when studying any new concepts.",
                detailedDescription: "Apple-Frameworks-in-Mermaid-Diagrams is a comprehensive collection of official Apple frameworks translated into Mermaid diagrams and illustrations. This project aims to provide developers, students, and enthusiasts with a quick and intuitive way to visualize and understand complex frameworks, facilitating easier learning and reference when exploring new concepts.\nMermaid is a popular JavaScript-based diagramming and charting tool that uses a simple markdown-like syntax. By leveraging Mermaid diagrams, this project ensures that the visual representations are both easy to create and maintain.",
                techStack: ["Swift", "SwiftUI"],
                githubURL: URL(string: "https://github.com/CongLeSolutionX/Apple-Frameworks-in-Mermaid-Diagrams"),
                demoURL: nil),
        Project(iconName: "app.fill",
                title: "Alchemy Models",
                shortDescription: "Alchemy Models: OpenAI Model Explorer.",
                detailedDescription: "A sleek SwiftUI app for browsing OpenAI models, showcasing robust API integration, dynamic data handling, and modern Swift concurrency.",
                techStack: ["Swift", "SwiftUI"],
                githubURL: URL(string: "https://github.com/CongLeSolutionX/Alchemy-Models"),
                demoURL: nil),
        Project(iconName: "app.fill",
                title: "Synthetic Zooniverse",
                shortDescription: "A Deep Dive into Cutting-Edge AI Models and Techniques",
                detailedDescription: "This repository provides curated insights, in-depth research, and practical explorations of the newest and most impactful AI models and methodologies shaping the future of technology. Whether you're a seasoned AI researcher, a student eager to dive into the field, or a tech enthusiast looking to understand the cutting edge, the Synthetic Zooniverse is designed to provide you with comprehensive and accessible resources.",
                techStack: ["Swift", "SwiftUI"],
                githubURL: URL(string: "https://github.com/CongLeSolutionX/Synthetic-Zooniverse"),
                demoURL: nil)
        
    ]
    static let skills: [Skill] = [
        Skill(iconName: "swift", name: "Swift", proficiency: 0.9),
        Skill(iconName: "swiftui", name: "SwiftUI", proficiency: 0.85),
        Skill(iconName: "applelogo", name: "UIKit", proficiency: 0.8),
        Skill(iconName: "server.rack", name: "Backend APIs", proficiency: 0.6),
        Skill(iconName: "cloud", name: "CloudKit", proficiency: 0.55),
        Skill(iconName: "gearshape.fill", name: "CI/CD", proficiency: 0.5),
        Skill(iconName: "gamecontroller.fill", name: "SpriteKit", proficiency: 0.45)
    ]
}
