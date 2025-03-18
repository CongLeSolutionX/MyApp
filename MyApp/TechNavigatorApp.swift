//
//  TechNavigatorApp.swift
//  MyApp
//
//  Created by Cong Le on 3/18/25.
//

import SwiftUI
import Combine

// MARK: - TECHNICAL MODELS

// TechSection defines different technical documentation sections.
enum TechSection: Int, Hashable, CaseIterable, Identifiable, Codable {
    case fundamentals
    case uiComponents
    case navigation
    case architecture
    case concurrency
    
    var id: Int { rawValue }
    
    var localizedName: LocalizedStringKey {
        switch self {
        case .fundamentals: return "Fundamentals"
        case .uiComponents: return "UI Components"
        case .navigation: return "Navigation"
        case .architecture: return "Architecture"
        case .concurrency: return "Concurrency"
        }
    }
}

// Article represents a technical article or documentation page.
struct Article: Hashable, Identifiable, Codable {
    let id = UUID()
    var title: String
    var section: TechSection
    var content: String  // This can include code, diagrams (markdown), etc.
    var related: [Article.ID] = []
    var imageName: String? = nil
}

// ContentModel stores all articles and provides filtering functions.
class ContentModel: ObservableObject {
    @Published var articles: [Article] = []
    private var articlesById: [Article.ID: Article]? = nil
    private var cancellables: [AnyCancellable] = []
    
    static let shared = ContentModel()
    
    private init() {
        articles = builtInArticles
        $articles
            .sink { [weak self] _ in
                self?.articlesById = nil
            }
            .store(in: &cancellables)
    }
    
    func articles(in section: TechSection?) -> [Article] {
        articles.filter { $0.section == section }
            .sorted { $0.title < $1.title }
    }
    
    func articles(relatedTo article: Article) -> [Article] {
        articles.filter { article.related.contains($0.id) }
            .sorted { $0.title < $1.title }
    }
    
    subscript(articleId: Article.ID) -> Article? {
        if articlesById == nil {
            articlesById = Dictionary(uniqueKeysWithValues: articles.map { ($0.id, $0) })
        }
        return articlesById![articleId]
    }
}

// Sample built-in articles (for demonstration, you can extend these)
private let builtInArticles: [Article] = {
    var articles = [
        Article(title: "SwiftUI Overview", section: .fundamentals, content: "Learn the basics of SwiftUI layout, data-binding, and state management.", imageName: "swiftui"),
        Article(title: "Building Custom Views", section: .uiComponents, content: "Create reusable custom views with modifiers and view composition."),
        Article(title: "NavigationStack Deep Dive", section: .navigation, content: "Explore NavigationStack, NavigationLink, and programmatic navigation in SwiftUI."),
        Article(title: "Using NavigationSplitView", section: .navigation, content: "Learn to create adaptative UIs using NavigationSplitView and multi-column navigation."),
        Article(title: "Understanding MVVM Architecture", section: .architecture, content: "Best practices for building scalable apps using Model-View-ViewModel pattern."),
        Article(title: "Concurrency in Swift", section: .concurrency, content: "Delve into Async/Await, structured concurrency, and performance optimizations.")
    ]
    
    // Example of related articles
    articles[0].related = [articles[2].id, articles[3].id]
    articles[2].related = [articles[0].id]
    
    return articles
}()

// MARK: - NAVIGATION MODEL

// NavigationModel tracks the user’s navigation state.
final class NavigationModel: ObservableObject, Codable {
    @Published var selectedSection: TechSection?
    @Published var articlePath: [Article]
    @Published var columnVisibility: NavigationSplitViewVisibility
    
    private lazy var decoder = JSONDecoder()
    private lazy var encoder = JSONEncoder()
    
    init(columnVisibility: NavigationSplitViewVisibility = .automatic,
         selectedSection: TechSection? = nil,
         articlePath: [Article] = []
    ) {
        self.columnVisibility = columnVisibility
        self.selectedSection = selectedSection
        self.articlePath = articlePath
    }
    
    var selectedArticle: Article? {
        get { articlePath.first }
        set { articlePath = [newValue].compactMap { $0 } }
    }
    
    var jsonData: Data? {
        get { try? encoder.encode(self) }
        set {
            guard let data = newValue,
                  let model = try? decoder.decode(Self.self, from: data)
            else { return }
            selectedSection = model.selectedSection
            articlePath = model.articlePath
            columnVisibility = model.columnVisibility
        }
    }
    
    // Codable conformance keys.
    enum CodingKeys: String, CodingKey {
        case selectedSection, articlePathIds, columnVisibility
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.selectedSection = try container.decodeIfPresent(TechSection.self, forKey: .selectedSection)
        let articlePathIds = try container.decode([Article.ID].self, forKey: .articlePathIds)
        self.articlePath = articlePathIds.compactMap { ContentModel.shared[$0] }
        self.columnVisibility = try container.decode(NavigationSplitViewVisibility.self, forKey: .columnVisibility)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(selectedSection, forKey: .selectedSection)
        try container.encode(articlePath.map(\.id), forKey: .articlePathIds)
        try container.encode(columnVisibility, forKey: .columnVisibility)
    }
}

// MARK: - NAVIGATION EXPERIENCE ENUM

// Experience enum defines the available navigation layouts.
enum Experience: Int, Identifiable, CaseIterable, Codable {
    var id: Int { rawValue }
    
    case stack
    case twoColumn
    case threeColumn
    case challenge
    
    var imageName: String {
        switch self {
        case .stack: return "list.bullet.rectangle.portrait"
        case .twoColumn: return "sidebar.left"
        case .threeColumn: return "rectangle.split.3x1"
        case .challenge: return "hands.sparkles"
        }
    }
    
    var localizedName: LocalizedStringKey {
        switch self {
        case .stack: return "Stack"
        case .twoColumn: return "Two Columns"
        case .threeColumn: return "Three Columns"
        case .challenge: return "Interactive Challenge"
        }
    }
    
    var localizedDescription: LocalizedStringKey {
        switch self {
        case .stack: return "Presents a linear stack of views."
        case .twoColumn: return "Displays a sidebar and detail view together."
        case .threeColumn: return "Uses three columns: sidebar, content, and detail."
        case .challenge: return "Presents interactive coding challenges for learning navigation."
        }
    }
}

// MARK: - TECHNAVIGATOR APP ENTRY POINT

@main
struct TechNavigatorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
#if os(macOS)
                .frame(minWidth: 1024, minHeight: 768)
#endif
        }
#if os(macOS)
        .commands {
            SidebarCommands()
        }
#endif
    }
}

// MARK: - ROOT CONTENT VIEW

struct ContentView: View {
    // Persist the navigation experience and navigation model
    @SceneStorage("experience") private var experience: Experience?
    @SceneStorage("navigationData") private var navigationData: Data?
    @StateObject private var navigationModel = NavigationModel()
    @State private var showExperiencePicker = false
    
    var body: some View {
        Group {
            // Switch defined by the selected experience
            switch experience {
            case .stack?:
                StackContentView(showExperiencePicker: $showExperiencePicker)
            case .twoColumn?:
                TwoColumnContentView(showExperiencePicker: $showExperiencePicker)
            case .threeColumn?:
                ThreeColumnContentView(showExperiencePicker: $showExperiencePicker)
            case .challenge?:
                ChallengeContentView(showExperiencePicker: $showExperiencePicker)
            case nil:
                VStack {
                    Text("Welcome to TechNavigator!")
                        .font(.largeTitle)
                    ExperienceButton(isActive: $showExperiencePicker)
                }
                .padding()
                .onAppear {
                    showExperiencePicker = true
                }
            }
        }
        .environmentObject(navigationModel)
        .sheet(isPresented: $showExperiencePicker) {
            ExperiencePicker(experience: $experience)
        }
        .task {
            if let jsonData = navigationData {
                navigationModel.jsonData = jsonData
            }
            
            // Persist state.  Use .values to get an AsyncSequence.
            Task { // Create a separate Task for observing changes
                for await _ in navigationState.$path.values {
                    saveNavigationState()
                }
            }
            Task {
                for await _ in navigationState.$selectedNode.values {
                    saveNavigationState()
                }
            }
            Task {
                for await _ in navigationState.$columnVisibility.values {
                    saveNavigationState()
                }
            }
            
        }
    }
    
    
    private func saveNavigationState() {
        do {
            let encodedData = try JSONEncoder().encode(navigationState)
            navigationData = encodedData
        } catch {
            print("Encoding Error \(error)")
        }
    }
}

// MARK: - NAVIGATION EXPERIENCE PICKER & BUTTON

struct ExperiencePicker: View {
    @Binding var experience: Experience?
    @Environment(\.dismiss) private var dismiss
    @State private var selection: Experience?
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Select Your Navigation Experience")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))]) {
                    ForEach(Experience.allCases) { exp in
                        ExperiencePickerItem(selection: $selection, experience: exp)
                    }
                }
                Spacer()
            }
            .scenePadding()
#if os(iOS)
            .safeAreaInset(edge: .bottom) {
                ContinueButton(action: continueAction)
                    .disabled(selection == nil)
                    .scenePadding()
            }
#endif
        }
#if os(macOS)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                ContinueButton(action: continueAction)
                    .disabled(selection == nil)
            }
        }
        .frame(width: 600, height: 350)
#endif
        .interactiveDismissDisabled(selection == nil)
    }
    
    func continueAction() {
        experience = selection
        dismiss()
    }
}

struct ExperiencePickerItem: View {
    @Binding var selection: Experience?
    var experience: Experience
    
    var body: some View {
        Button {
            selection = experience
        } label: {
            HStack(spacing: 16) {
                Image(systemName: experience.imageName)
                    .font(.title)
                    .foregroundColor(.accentColor)
                VStack(alignment: .leading) {
                    Text(experience.localizedName)
                        .bold()
                    Text(experience.localizedDescription)
                        .font(.callout)
                        .lineLimit(3)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(selection == experience ? Color.accentColor.opacity(0.2) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(selection == experience ? Color.accentColor : .clear)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ExperienceButton: View {
    @Binding var isActive: Bool
    
    var body: some View {
        Button {
            isActive = true
        } label: {
            Label("Experience", systemImage: "wand.and.stars")
                .help("Choose your navigation experience")
        }
    }
}

#if os(iOS)
struct ContinueButton: View {
    var action: () -> Void
    var body: some View {
        Button("Continue", action: action)
            .buttonStyle(ContinueButtonStyle())
    }
}

struct ContinueButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.bold)
            .frame(maxWidth: horizontalSizeClass == .compact ? .infinity : 280)
            .foregroundColor(.white)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isEnabled ? Color.accentColor : Color.gray.opacity(0.6))
                    .opacity(configuration.isPressed ? 0.8 : 1)
                    .scaleEffect(configuration.isPressed ? 0.98 : 1)
                    .animation(.easeInOut, value: configuration.isPressed)
            }
    }
}
#endif

// MARK: - ARTICLE / TECHNICAL CONTENT VIEWS

// ArticleDetail shows a technical article's full content.
struct ArticleDetail<Link: View>: View {
    var article: Article?
    var relatedLink: (Article) -> Link
    
    var body: some View {
        ZStack {
            if let article = article {
                ArticleContent(article: article, relatedLink: relatedLink)
            } else {
                Text("Select an Article")
                    .navigationTitle("")
            }
        }
    }
}

private struct ArticleContent<Link: View>: View {
    var article: Article
    var relatedLink: (Article) -> Link
    var dataModel = ContentModel.shared
    
    var body: some View {
        ScrollView {
            ViewThatFits(in: .horizontal) {
                wideLayout
                narrowLayout
            }
            .padding()
        }
        .navigationTitle(article.title)
    }
    
    var wideLayout: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(article.title)
                .font(.largeTitle)
                .bold()
            Divider()
            Text(article.content)
            relatedArticlesView
        }
    }
    
    var narrowLayout: some View {
        VStack(alignment: .center, spacing: 16) {
            Text(article.title)
                .font(.largeTitle)
                .bold()
            Divider()
            Text(article.content)
            relatedArticlesView
        }
    }
    
    var relatedArticlesView: some View {
        if !article.related.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Related Articles")
                    .font(.headline)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
                    ForEach(dataModel.articles(relatedTo: article)) { relatedArticle in
                        relatedLink(relatedArticle)
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
}

// ArticleTile shows a summary tile for an article.
struct ArticleTile: View {
    var article: Article
    
    var body: some View {
        VStack {
            if let imageName = article.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 240, maxHeight: 240)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(maxWidth: 240, maxHeight: 240)
                    .overlay(Image(systemName: "doc.text").font(.largeTitle))
            }
            Text(article.title)
                .font(.headline)
                .lineLimit(2)
        }
        .padding(4)
    }
}

// ArticleGrid displays a grid of article tiles for a selected section.
struct ArticleGrid: View {
    var section: TechSection?
    var dataModel = ContentModel.shared
    
    var body: some View {
        ZStack {
            if let section = section {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 240))]) {
                        ForEach(dataModel.articles(in: section)) { article in
                            NavigationLink(value: article) {
                                ArticleTile(article: article)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .navigationTitle(section.localizedName)
                .navigationDestination(for: Article.self) { article in
                    ArticleDetail(article: article) { related in
                        NavigationLink(value: related) {
                            ArticleTile(article: related)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                Text("Select a Section to Explore")
                    .navigationTitle("")
            }
        }
    }
}

// MARK: - NAVIGATION EXPERIENCES

// StackContentView uses a NavigationStack to present sections and articles.
struct StackContentView: View {
    @Binding var showExperiencePicker: Bool
    @EnvironmentObject private var navigationModel: NavigationModel
    var dataModel = ContentModel.shared
    
    var body: some View {
        NavigationStack(path: $navigationModel.articlePath) {
            List(TechSection.allCases) { section in
                Section(header: Text(section.localizedName)) {
                    ForEach(dataModel.articles(in: section)) { article in
                        NavigationLink(article.title, value: article)
                    }
                }
            }
            .navigationTitle("Sections")
            .toolbar { ExperienceButton(isActive: $showExperiencePicker) }
            .navigationDestination(for: Article.self) { article in
                ArticleDetail(article: article) { related in
                    NavigationLink(value: related) { ArticleTile(article: related) }
                        .buttonStyle(.plain)
                }
            }
        }
    }
}

// TwoColumnContentView uses a NavigationSplitView with sidebar and detail.
struct TwoColumnContentView: View {
    @Binding var showExperiencePicker: Bool
    @EnvironmentObject private var navigationModel: NavigationModel
    var dataModel = ContentModel.shared
    
    var body: some View {
        NavigationSplitView(columnVisibility: $navigationModel.columnVisibility) {
            List(TechSection.allCases, selection: $navigationModel.selectedSection) { section in
                NavigationLink(section.localizedName, value: section)
            }
            .navigationTitle("Sections")
            .toolbar { ExperienceButton(isActive: $showExperiencePicker) }
        } detail: {
            NavigationStack(path: $navigationModel.articlePath) {
                ArticleGrid(section: navigationModel.selectedSection)
            }
        }
    }
}

// ThreeColumnContentView uses a three-column NavigationSplitView experience.
struct ThreeColumnContentView: View {
    @Binding var showExperiencePicker: Bool
    @EnvironmentObject private var navigationModel: NavigationModel
    var dataModel = ContentModel.shared
    var sections = TechSection.allCases
    
    var body: some View {
        NavigationSplitView(columnVisibility: $navigationModel.columnVisibility) {
            List(sections, selection: $navigationModel.selectedSection) { section in
                NavigationLink(section.localizedName, value: section)
            }
            .navigationTitle("Sections")
        } content: {
            ZStack {
                if let section = navigationModel.selectedSection {
                    List(selection: $navigationModel.selectedArticle) {
                        ForEach(dataModel.articles(in: section)) { article in
                            NavigationLink(article.title, value: article)
                        }
                    }
                    .navigationTitle(section.localizedName)
                    .onDisappear {
                        if navigationModel.selectedArticle == nil {
                            navigationModel.selectedSection = nil
                        }
                    }
                    .toolbar { ExperienceButton(isActive: $showExperiencePicker) }
                } else {
                    Text("Select a Section")
                        .navigationTitle("")
                }
            }
        } detail: {
            ArticleDetail(article: navigationModel.selectedArticle) { related in
                Button {
                    navigationModel.selectedSection = related.section
                    navigationModel.selectedArticle = related
                } label: {
                    ArticleTile(article: related)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// ChallengeContentView can be used to present interactive coding challenges.
struct ChallengeContentView: View {
    @Binding var showExperiencePicker: Bool
    @EnvironmentObject private var navigationModel: NavigationModel
    var dataModel = ContentModel.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Interactive Navigation Challenge")
                .font(.title)
            Text("Explore code examples and answer quiz questions on navigation.")
                .multilineTextAlignment(.center)
            ExperienceButton(isActive: $showExperiencePicker)
        }
        .padding()
    }
}

// MARK: - PREVIEWS

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(NavigationModel())
    }
}
