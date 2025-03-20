//
//  SafariViewWithHistoryManagement.swift
//  MyApp
//
//  Created by Cong Le on 3/20/25.
//

import SwiftUI
import SafariServices

// MARK: - Model for a News Article
struct NewsArticle: Identifiable {
    let id = UUID()
    let logo: String
    let source: String
    let headline: String
    let timeAgo: String
    let image: String
    let url: URL
}

// MARK: - Sample Data
let newsArticles: [NewsArticle] = [
    NewsArticle(logo: "nlr_logo",
                source: "The National Law Review",
                headline: "USCIS Issues Regulation Requiring Alien Registration",
                timeAgo: "Yesterday",
                image: "uscis",
                url: URL(string: "https://www.natlawreview.com")!),
    NewsArticle(logo: "cbc_logo",
                source: "CBC News",
                headline: "Canadians exempted from fingerprinting for U.S. travel under new Homeland Security rules",
                timeAgo: "6 days ago",
                image: "cbc_news_image",
                url: URL(string: "https://www.cbc.ca")!),
    NewsArticle(logo: "axios_logo",
                source: "Axios",
                headline: "Canadian snowbirds will have to register with U.S. under new Trump rule",
                timeAgo: "4 days ago",
                image: "axios_news_image",
                url: URL(string: "https://www.axios.com")!)
]

// MARK: - Main View
struct GoogleNewsListWithHistoryManagementView: View {
    @State private var selectedArticle: NewsArticle?
    @State private var showingLinkHistory = false  // state for link history sheet
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    // Top Bar – includes Link History button
                    topBar
                    
                    headerTexts
                    
                    ForEach(newsArticles) { article in
                        Button(action: {
                            selectedArticle = article
                            LinkHistoryManager.shared.addLink(url: article.url, title: article.headline)
                        }) {
                            NewsItemWithHistoryManagementView(article: article)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedArticle) { article in
                // Use our custom safari view
                CustomSafariView(url: article.url)
            }
            .sheet(isPresented: $showingLinkHistory) {
                LinkHistoryView()
            }
        }
    }
    
    // MARK: - Subviews
    private var topBar: some View {
        HStack {
            Image(systemName: "chevron.left")
                .font(.title2)
            Text("Full Coverage")
                .font(.subheadline)
            Spacer()
            
            // Link History Button
            Button(action: { showingLinkHistory = true }) {
                Image(systemName: "link")
                    .font(.title2)
            }
            
            // These icons are shown as placeholders – add actions as needed
            Image(systemName: "square.and.arrow.up")
            Image(systemName: "ellipsis")
        }
        .padding(.horizontal)
    }
    
    private var headerTexts: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("News about Canadians • US")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            Text("Top news")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top, 4)
        }
    }
}

// MARK: - News Item View
struct NewsItemWithHistoryManagementView: View {
    let article: NewsArticle
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(article.logo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text(article.source)
                            .font(.caption)
                    }
                    Text(article.headline)
                        .font(.headline)
                    Text(article.timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(article.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(10)
            }
            
            HStack { // trailing ellipsis icon for each item
                Spacer()
                Image(systemName: "ellipsis")
                    .padding(.trailing, 8)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Custom Safari View (using UIViewControllerRepresentable)
struct CustomSafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> CustomSafariViewController {
        CustomSafariViewController(url: url, entersReaderIfAvailable: true)
    }

    func updateUIViewController(_ safariViewController: CustomSafariViewController, context: Context) {
        // No update logic needed for now
    }
}

// MARK: - Custom SFSafariViewController with Custom UI
class CustomSafariViewController: SFSafariViewController {
    
    // Custom UI Elements
    private let topBar = UIView()
    private let bottomBar = UIView()
    private let closeButton = UIButton(type: .system)
    // Back, forward and reload buttons are available as stubs since SFSafariViewController does
    // not expose programmatic navigation controls
    private let backButton = UIButton(type: .system)
    private let forwardButton = UIButton(type: .system)
    private let reloadButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomUI()
    }
    
    private func setupCustomUI() {
        // --- Top Bar Setup ---
        topBar.backgroundColor = .systemBackground
        view.addSubview(topBar)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Close Button in Top Bar
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        topBar.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 16),
            closeButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor)
        ])
        
        // --- Bottom Bar Setup ---
        bottomBar.backgroundColor = .systemBackground
        view.addSubview(bottomBar)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Back Button (stub – navigation not supported in SFSafariViewController)
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.addTarget(self, action: #selector(stubAction), for: .touchUpInside)
        backButton.isEnabled = false
        bottomBar.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor)
        ])
        
        // Forward Button (stub)
        forwardButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        forwardButton.addTarget(self, action: #selector(stubAction), for: .touchUpInside)
        forwardButton.isEnabled = false
        bottomBar.addSubview(forwardButton)
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            forwardButton.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 32),
            forwardButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor)
        ])
        
        // Reload Button (stub)
        reloadButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        reloadButton.addTarget(self, action: #selector(stubAction), for: .touchUpInside)
        bottomBar.addSubview(reloadButton)
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            reloadButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            reloadButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor)
        ])
        
        // Hide default navigation bars after adding custom ones
        if #available(iOS 11.0, *) {
            navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            navigationController?.isNavigationBarHidden = true
        }
        
        // Set delegate if needed for future UI updates (not implemented here)
        delegate = self
    }
    
    // MARK: - Button Actions
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    // Stub actions – real back/forward/reload functionality is not available in SFSafariViewController.
    @objc private func stubAction() {
        // Optionally show an alert explaining limitations or simply do nothing.
    }
}

// Extend to conform to the SFSafariViewControllerDelegate if later needed for state updates
extension CustomSafariViewController: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        // Update custom UI button states if applicable
    }
}

// MARK: - Link History Model & Manager
struct LinkHistoryItem: Identifiable, Codable {
    let id = UUID()
    let url: URL
    let title: String
    let timestamp: Date
}

final class LinkHistoryManager: ObservableObject {
    static let shared = LinkHistoryManager()
    private let historyKey = "linkHistory"
    
    @Published var history: [LinkHistoryItem] = []
    
    private init() {
        loadHistory()
    }
    
    func addLink(url: URL, title: String) {
        let newItem = LinkHistoryItem(url: url, title: title, timestamp: Date())
        history.insert(newItem, at: 0)
        saveHistory()
    }
    
    func clearHistory() {
        history = []
        saveHistory()
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([LinkHistoryItem].self, from: data) {
            history = decoded
        }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
}

// MARK: - Link History View
struct LinkHistoryView: View {
    @ObservedObject var historyManager = LinkHistoryManager.shared
    @Environment(\.dismiss) var dismiss  // Using dismiss action
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Recently Visited")
                            .font(.title2)
                            .fontWeight(.bold)) {
                    ForEach(historyManager.history) { item in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.headline)
                            Text(item.url.absoluteString)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Link History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear all") {
                        historyManager.clearHistory()
                    }
                    .foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleNewsListWithHistoryManagementView()
            .previewDevice("iPad Pro (11-inch) (4th generation)")
    }
}
