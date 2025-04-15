//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//
//
//import SwiftUI
//
//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//// After iOS 17, we can use this syntax for preview:
//#Preview {
//    ContentView()
//}

import SwiftUI

struct PortfolioApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.none) // Uses system setting (dark/light mode)
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            ProjectsView()
                .tabItem {
                    Label("Projects", systemImage: "folder.fill")
                }
            SkillsView()
                .tabItem {
                    Label("Skills", systemImage: "chart.pie.fill")
                }
            ContactView()
                .tabItem {
                    Label("Contact", systemImage: "envelope.fill")
                }
        }
    }
}

// MARK: - Home / Profile View

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ProfileHeaderView()
                
                Text("Chance led me to iOS development,\nbut the COVID-19 pandemic cemented my choice of a software engineering career,\nwhich I stay current with through my writing on Medium𓂃🖊📱")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    // Add resume download or link action here
                }) {
                    Label("Download Resume", systemImage: "arrow.down.doc.fill")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor.opacity(0.1))
                        .foregroundColor(Color.accentColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("About Me")
        }
    }
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

// MARK: - Projects View

struct ProjectsView: View {
    let projects = SampleData.projects
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(projects) { project in
                        ProjectCardView(project: project)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Projects")
        }
    }
}

struct ProjectCardView: View {
    let project: Project
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
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
                
                Button(action: {
                    withAnimation(.spring()) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.accentColor)
                        .imageScale(.large)
                }
            }
            
            if isExpanded {
                Divider()
                Text(project.detailedDescription)
                    .font(.body)
                
                HStack {
                    ForEach(project.techStack, id: \.self) { tech in
                        Text(tech)
                            .font(.caption)
                            .padding(6)
                            .background(Color.accentColor.opacity(0.15))
                            .cornerRadius(8)
                    }
                    Spacer()
                }
                .padding(.top, 4)
                
                HStack(spacing: 20) {
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
                .padding(.top, 8)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.primary.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Skills View

struct SkillsView: View {
    let skills = SampleData.skills
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 20)], spacing: 24) {
                    ForEach(skills) { skill in
                        SkillProgressView(skill: skill)
                    }
                }
                .padding()
            }
            .navigationTitle("Skills")
        }
    }
}

struct SkillProgressView: View {
    let skill: Skill
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.25), lineWidth: 14)
                .frame(width: 140, height: 140)
            
            Circle()
                .trim(from: 0, to: CGFloat(skill.proficiency))
                .stroke(style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .foregroundColor(Color.accentColor)
                .rotationEffect(.degrees(-90))
                .frame(width: 140, height: 140)
                .animation(.easeInOut(duration: 1), value: skill.proficiency)
            
            VStack {
                Image(systemName: skill.iconName)
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                Text(skill.name)
                    .font(.headline)
                Text("\(Int(skill.proficiency*100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Contact View

struct ContactView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Get in touch!")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.top, 40)
                
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.accentColor)
                        Text("CongLeJobs@gmail.com")
                    }
//                    HStack {
//                        Image(systemName: "phone.fill")
//                            .foregroundColor(.accentColor)
//                        Text("+1 (123) 456-7890")
//                    }
                }
                .font(.body)
                
                Spacer()
                
                Button(action: {
                    // Open mail app or contact form
                    let email = "mailto:CongLeJobs@gmail.com"
                    if let url = URL(string: email) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Label("Send Email", systemImage: "paperplane.fill")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundColor(.accentColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationTitle("Contact")
        }
    }
}

// MARK: - Sample Data Models

struct Project: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let shortDescription: String
    let detailedDescription: String
    let techStack: [String]
    let githubURL: URL?
    let demoURL: URL?
}

struct Skill: Identifiable {
    let id = UUID()
    let iconName: String
    let name: String
    let proficiency: Double // 0 to 1
}

struct SampleData {
    static let projects: [Project] = [
        Project(iconName: "app.fill",
                title: "Weatherly",
                shortDescription: "Beautiful weather app with SwiftUI animations.",
                detailedDescription: "A fully native iOS weather app using SwiftUI and Combine, featuring live weather data, animations, and hourly forecasts.",
                techStack: ["Swift", "SwiftUI", "Combine", "OpenWeatherAPI"],
                githubURL: URL(string: "https://github.com/janedoe/weatherly"),
                demoURL: URL(string: "https://weatherly.demo.com")),
        
        Project(iconName: "play.rectangle.fill",
                title: "PodMate",
                shortDescription: "Podcast player with custom playlists and offline support.",
                detailedDescription: "An advanced podcast player supporting background playback, offline downloads, and customizable playlists built with UIKit and AVFoundation.",
                techStack: ["Swift", "UIKit", "AVFoundation", "CoreData"],
                githubURL: URL(string: "https://github.com/janedoe/podmate"),
                demoURL: nil),
        
        Project(iconName: "gamecontroller.fill",
                title: "Maze Runner",
                shortDescription: "2D puzzle game using SpriteKit and GameController.",
                detailedDescription: "A fun and challenging 2D maze puzzle game with physics, touch controls, and GameController support, built on SpriteKit.",
                techStack: ["Swift", "SpriteKit", "GameController"],
                githubURL: nil,
                demoURL: nil)
    ]
    
    static let skills: [Skill] = [
        Skill(iconName: "swift", name: "Swift", proficiency: 0.9),
        Skill(iconName: "swiftui", name: "SwiftUI", proficiency: 0.85),
        Skill(iconName: "applelogo", name: "UIKit", proficiency: 0.8),
        Skill(iconName: "server.rack", name: "Backend APIs", proficiency: 0.6),
        Skill(iconName: "cloud", name: "CloudKit", proficiency: 0.55),
        Skill(iconName: "gearshape.fill", name: "CI/CD", proficiency: 0.5)
    ]
}

// For preview

struct PortfolioApp_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDevice("iPhone 14")
            ContentView()
                .preferredColorScheme(.dark)
                .previewDevice("iPhone 14")
        }
    }
}
