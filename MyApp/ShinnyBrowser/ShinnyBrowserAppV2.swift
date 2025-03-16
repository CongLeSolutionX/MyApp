//
//  ShinnyBrowserAppV2.swift
//  MyApp
//  Version: 2.0
//
//
//
//  Created by Cong Le on 3/15/25.
//

import UIKit
import WebKit
import Combine

// MARK: - Protocols

protocol BrowserViewDelegate: AnyObject {
    func didTapBackButton()
    func didTapForwardButton()
    func didTapReloadButton()
    func didRequestShare(for url: URL)
    func didRequestAddToFavorites(for url: URL)
    func didRequestToggleContentMode(for url: URL, newMode: WKWebpagePreferences.ContentMode)
    func didRequestShowFavorites() // Added for Favorites
    func didRequestShowHistory()   // Added for History
}

// MARK: - Enums for Error Handling and Settings
enum BrowserError: Error, LocalizedError {
    case networkError(underlyingError: Error)
    case invalidURLError
    case serverError(statusCode: Int)
    case loadingError(underlyingError: Error)
    case downloadError(underlyingError: Error)
    case unknownError

    var errorDescription: String? {
        switch self {
        case .networkError(let underlyingError):
            return "Network error: \(underlyingError.localizedDescription)"
        case .invalidURLError:
            return "Invalid URL."
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"
        case .loadingError(let underlyingError):
            return "Loading error: \(underlyingError.localizedDescription)"
        case .downloadError(let underlyingError):
            return "Download error: \(underlyingError.localizedDescription)"
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}

enum BrowserSetting: String {
    case defaultSearchEngine
    case contentBlockingEnabled
    // Add other settings as needed
}

// MARK: - Data Structures for Favorites, History and Tabs
struct Favorite: Codable, Identifiable { // Added Identifiable
    var id = UUID() // For Identifiable
    let url: String
    let title: String
}

struct HistoryEntry: Codable, Identifiable { // Added Identifiable
    var id = UUID()  // For Identifiable
    let url: String
    let title: String
    let timestamp: Date
}

class Tab: Identifiable {  // Changed to class for reference semantics
    let id = UUID()
    var webView: WKWebView
    var url: String?
    var title: String?
    var thumbnail: UIImage?

    init(webView: WKWebView, url: String? = nil, title: String? = nil) {
        self.webView = webView
        self.url = url
        self.title = title
    }
}

// MARK: - Download Management

enum DownloadStatus {
    case queued
    case downloading
    case paused
    case completed
    case failed
    case cancelled
}

class Download {
    let url: URL
    var destinationURL: URL?
    var progress: Double = 0.0
    var status: DownloadStatus = .queued
    var task: URLSessionDownloadTask?

    init(url: URL) {
        self.url = url
    }
}

class DownloadManager: NSObject, URLSessionDownloadDelegate {
    static let shared = DownloadManager() // Singleton

    @Published var downloads: [Download] = []  // Now @Published
    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "tech.CongLeSolutionX.ShinnyBrowser.backgroundDownload")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    func startDownload(url: URL) {
        let download = Download(url: url)
        downloads.append(download)
        download.task = urlSession.downloadTask(with: url)
        download.task?.resume()
        download.status = .downloading
    }
    
    // MARK: - URLSessionDownloadDelegate
      func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
          guard let download = downloads.first(where: { $0.task == downloadTask }) else { return }

          let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
          let destinationURL = documentsPath.appendingPathComponent(downloadTask.originalRequest?.url?.lastPathComponent ?? "downloadedFile")

          do {
              try FileManager.default.moveItem(at: location, to: destinationURL)
              download.destinationURL = destinationURL
              download.status = .completed
          } catch {
              download.status = .failed
              print("Error moving downloaded file: \(error)")
          }
      }

      func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            guard let download = downloads.first(where: { $0.task == downloadTask }) else { return }
            download.progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        }

    // Add pause, resume, cancel methods as needed, updating the Download object's status.
}

// MARK: - ViewModel

class BrowserViewModel {
    
    // MARK: - Properties
    @Published var urlString: String = ""
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var estimatedProgress: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var currentContentMode: WKWebpagePreferences.ContentMode = .recommended
    @Published var browserError: BrowserError?  // Error handling
    @Published var favorites: [Favorite] = [] // Favorites
    @Published var history: [HistoryEntry] = [] // History
    @Published var tabs: [Tab] = []          // Tabs
    @Published var currentTabIndex: Int = 0   // Tabs
    
    private var contentModeToRequestForHost: [String: WKWebpagePreferences.ContentMode] = [:]
    var cancellables: Set<AnyCancellable> = []
    weak var delegate: BrowserViewDelegate?
    
    private let urlKey = "LastCommittedURLString" // UserDefaults key
    private let contentModePreferencesKey = "ContentModePreferences"  // UserDefaults key for content mode
    private let favoritesKey = "FavoritesKey"   // UserDefaults key for Favorites
    private let historyKey = "HistoryKey"     // UserDefaults key for History
    
    private let webView: WKWebView
    private var privateModeConfiguration: WKWebViewConfiguration? // Private browsing

    // MARK: - Initializers
    
    init(webView: WKWebView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())) {
        self.webView = webView
        
        // Configure WKWebView (once, in init)
        let configuration = self.webView.configuration
        configuration.applicationNameForUserAgent = "Version/17.2 Safari/605.1.15" //Good Practice
        configuration.allowsInlineMediaPlayback = true //Good Practice
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true //Good Practice
        if #available(iOS 14.0, *) {
            let webpagePreferences = WKWebpagePreferences()
            webpagePreferences.preferredContentMode = .recommended
            configuration.defaultWebpagePreferences = webpagePreferences
        }
        
        loadContentModePreferences() // Load persisted content mode preferences.
        loadFavorites()              // Load favorites
        loadHistory()                // Load history
        setupBindings()
        addTab(url: nil)             // Start with one tab
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        // Observe WKWebView properties and update @Published properties.
        webView.publisher(for: \.url)
            .compactMap { $0?.absoluteString }
            .receive(on: DispatchQueue.main) // Ensure updates on main thread
            .assign(to: \.urlString, on: self)
            .store(in: &cancellables)

        webView.publisher(for: \.canGoBack)
            .receive(on: DispatchQueue.main)
            .assign(to: \.canGoBack, on: self)
            .store(in: &cancellables)

        webView.publisher(for: \.canGoForward)
            .receive(on: DispatchQueue.main)
            .assign(to: \.canGoForward, on: self)
            .store(in: &cancellables)

        webView.publisher(for: \.estimatedProgress)
            .receive(on: DispatchQueue.main)
            .assign(to: \.estimatedProgress, on: self)
            .store(in: &cancellables)

        webView.publisher(for: \.isLoading)
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        // Observe changes to the current tab's title
        $currentTabIndex
            .sink { [weak self] index in
                guard let self = self, self.tabs.indices.contains(index) else { return }
                
                // Cancel any previous title observation
                self.tabs[index].webView.publisher(for: \.title).sink { [weak self] newTitle in
                        self?.tabs[index].title = newTitle
                    }.store(in: &self.cancellables) // Reuse the cancellables
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods (Actions from View)
    
    func loadURL(string: String) {
        guard let url = validatedURL(from: string) else {
            browserError = .invalidURLError // Set the error
            return
        }
        
        let request = URLRequest(url: url)
        tabs[currentTabIndex].webView.load(request) // Load in the current tab
    }
    
    func goBack() {
        if tabs[currentTabIndex].webView.canGoBack {
            tabs[currentTabIndex].webView.goBack()
            delegate?.didTapBackButton()
        }
    }

    func goForward() {
        if tabs[currentTabIndex].webView.canGoForward {
            tabs[currentTabIndex].webView.goForward()
            delegate?.didTapForwardButton()
        }
    }
    
    func reload() {
        tabs[currentTabIndex].webView.reload()
        delegate?.didTapReloadButton()
    }

    func loadStartPage() {
        guard let startURL = Bundle.main.url(forResource: "UserAgent", withExtension: "html") else {
            // Handle missing start page (should not happen in a well-formed app)
            browserError = .loadingError(underlyingError: NSError(domain: "tech.CongLeSolutionX.ShinnyBrowser", code: 404, userInfo: [NSLocalizedDescriptionKey: "Start page not found."]))
            return
        }
        
        tabs[currentTabIndex].webView.loadFileURL(startURL, allowingReadAccessTo: startURL.deletingLastPathComponent()) // Load in the current tab
    }

    func shareCurrentPage() {
        guard let url = tabs[currentTabIndex].webView.url else { return }
        delegate?.didRequestShare(for: url)
    }
    
    func addToFavorites() {
        guard let url = tabs[currentTabIndex].webView.url, let title = tabs[currentTabIndex].webView.title else { return }
        let newFavorite = Favorite(url: url.absoluteString, title: title)
        favorites.append(newFavorite)
        saveFavorites()  // Persist the changes
        delegate?.didRequestAddToFavorites(for: url)
    }
    
    func removeFavorite(at index: Int) {
        guard favorites.indices.contains(index) else { return }
        favorites.remove(at: index)
        saveFavorites() // Persist after removal
    }
    
    private func saveFavorites() {
        if let encodedData = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encodedData, forKey: favoritesKey)
        }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decodedFavorites = try? JSONDecoder().decode([Favorite].self, from: data) {
            favorites = decodedFavorites
        }
    }
    
    func showFavorites() {
        delegate?.didRequestShowFavorites()
    }

    func toggleContentMode() {
            guard let url = tabs[currentTabIndex].webView.url, let host = url.host() else { return }

            // Cycle through content modes
            let nextMode: WKWebpagePreferences.ContentMode
            switch currentContentMode {
            case .recommended:
                nextMode = .mobile
            case .mobile:
                nextMode = .desktop
            case .desktop:
                nextMode = .recommended
            @unknown default:
                nextMode = .recommended
            }

            contentModeToRequestForHost[host] = nextMode
            currentContentMode = nextMode  // Update the stored mode immediately
            saveContentModePreferences() // Persist the content mode change
            tabs[currentTabIndex].webView.reloadFromOrigin()
            delegate?.didRequestToggleContentMode(for: url, newMode: nextMode)
        }
    
    // MARK: - URL Handling

    func validatedURL(from input: String) -> URL? {
        // Improved URL validation and formatting.
        var text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if it's a search query or a URL
           if let url = URL(string: text), url.scheme != nil {
               return url // Already a valid URL
           } else {
               // Check if we should perform a search
               if !text.lowercased().hasPrefix("http://") && !text.lowercased().hasPrefix("https://") {
                   if let searchURL = performSearch(query: text) {
                       return searchURL // Return the search URL
                   }
               }

               // Try prepending "https://"
               if !text.lowercased().hasPrefix("http://") && !text.lowercased().hasPrefix("https://") {
                   text = "https://" + text
               }
               return URL(string: text)
           }
    }
    
    func loadLastVisitedPage() {
        // Load the last visited URL from UserDefaults.
        if let lastURLString = UserDefaults.standard.string(forKey: urlKey),
           let lastURL = URL(string: lastURLString) {
            urlString = lastURLString // Update the urlField.
            tabs[currentTabIndex].webView.load(URLRequest(url: lastURL))  // Load into the current tab
        } else {
            loadStartPage() // Load a default page if no saved URL.
        }
    }
    
    // MARK: - Content Mode Persistence
      private func saveContentModePreferences() {
          // Convert ContentMode enum to raw values (Int) for storage.
          let rawPreferences = contentModeToRequestForHost.mapValues { $0.rawValue }
          UserDefaults.standard.set(rawPreferences, forKey: contentModePreferencesKey)
      }

      private func loadContentModePreferences() {
        if let rawPreferences = UserDefaults.standard.dictionary(forKey: contentModePreferencesKey) as? [String: Int] {
              // Convert raw values back to ContentMode enum.
              contentModeToRequestForHost = rawPreferences.compactMapValues { WKWebpagePreferences.ContentMode(rawValue: $0) }
          }
      }
    
    // MARK: - History
    
    func addHistoryEntry(url: URL, title: String) {
        let newEntry = HistoryEntry(url: url.absoluteString, title: title, timestamp: Date())
        history.append(newEntry)
        saveHistory()  // Persist the new entry
    }
    
    func removeHistoryEntry(at index: Int) {
        guard history.indices.contains(index) else { return }
        history.remove(at: index)
        saveHistory() // Persist after removal
    }
    
    func clearHistory() {
            history.removeAll()
            saveHistory()
        }
    
    private func saveHistory() {
        if let encodedData = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encodedData, forKey: historyKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decodedHistory = try? JSONDecoder().decode([HistoryEntry].self, from: data) {
            history = decodedHistory
        }
    }
    
    func showHistory() {
        delegate?.didRequestShowHistory()
    }

    // MARK: - Tabs
    
    func addTab(url: URL?) {
        let newWebView = createWebView() // Create a new WKWebView
        let newTab = Tab(webView: newWebView)
        tabs.append(newTab)
        currentTabIndex = tabs.count - 1 // Switch to the new tab
        
        if let url = url {
            newTab.webView.load(URLRequest(url: url))
        } else {
            loadStartPage() // Load start page for new tabs
        }
    }

    func closeTab(at index: Int) {
        guard tabs.indices.contains(index) else { return }

        // If closing the current tab, switch to another tab if available
        if index == currentTabIndex && tabs.count > 1 {
            let newIndex = (index > 0) ? index - 1 : 1
            switchTab(to: newIndex)
        }
        
        tabs[index].webView.stopLoading()          // Stop loading
        tabs[index].webView.navigationDelegate = nil  // Remove delegate
        tabs[index].webView.removeFromSuperview()    // Remove from UI *before* deinit
        tabs.remove(at: index)

        // Adjust currentTabIndex if necessary
        if currentTabIndex >= tabs.count {
            currentTabIndex = max(0, tabs.count - 1)
        }
    }

    func switchTab(to index: Int) {
        guard tabs.indices.contains(index) else { return }
        currentTabIndex = index
        // The ViewController will handle updating the displayed web view
    }
    
    // MARK: - Private Browsing
       func enablePrivateMode() {
           if privateModeConfiguration == nil {
               let config = WKWebViewConfiguration()
               config.processPool = WKProcessPool() // Isolated process pool
               // Other private mode configurations (e.g., disabling caching)
               privateModeConfiguration = config
           }
       }

       func disablePrivateMode() {
           privateModeConfiguration = nil
       }

       func isPrivateModeEnabled() -> Bool {
           return privateModeConfiguration != nil
       }
    
    // MARK: - Search
    
    func performSearch(query: String) -> URL? {
        guard let searchEngine = UserDefaults.standard.string(forKey: BrowserSetting.defaultSearchEngine.rawValue) else {
            // Fallback to a default search engine if none is set
            return URL(string: "https://www.google.com/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        switch searchEngine {
        case "Google":
            return URL(string: "https://www.google.com/search?q=\(encodedQuery)")
        case "DuckDuckGo":
            return URL(string: "https://duckduckgo.com/?q=\(encodedQuery)")
        case "Bing":
            return URL(string: "https://www.bing.com/search?q=\(encodedQuery)")
        // Add more search engines as needed
        default:
            return URL(string: "https://www.google.com/search?q=\(encodedQuery)")
        }
    }
    
    // MARK: - Helper function to create WKWebView
    private func createWebView() -> WKWebView {
            let configuration: WKWebViewConfiguration
            if isPrivateModeEnabled() {
                configuration = privateModeConfiguration!
            } else {
                configuration = WKWebViewConfiguration()
                configuration.applicationNameForUserAgent = "Version/17.2 Safari/605.1.15" // Good Practice
                configuration.allowsInlineMediaPlayback = true // Good Practice
                configuration.defaultWebpagePreferences.allowsContentJavaScript = true // Good Practice
                if #available(iOS 14.0, *) {
                    let webpagePreferences = WKWebpagePreferences()
                    webpagePreferences.preferredContentMode = .recommended
                    configuration.defaultWebpagePreferences = webpagePreferences
                }
            }
            
            let webView = WKWebView(frame: .zero, configuration: configuration)
            webView.navigationDelegate = delegate as? WKNavigationDelegate // Delegate forwarding
            return webView
        }
    
    // MARK: - WebView Delegate Forwarding
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // Save the last committed URL to UserDefaults.
        if let urlString = webView.url?.absoluteString {
            UserDefaults.standard.set(urlString, forKey: urlKey)
        }
        
        if let url = webView.url, let title = webView.title {
                addHistoryEntry(url: url, title: title)  // Add to history
            }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
           let preferences = WKWebpagePreferences()
           if #available(iOS 14.0, *) {
               // Apply custom content mode if set for this host.
               if let host = navigationAction.request.url?.host(),
                  let requestedMode = contentModeToRequestForHost[host] {
                   preferences.preferredContentMode = requestedMode
                   currentContentMode = requestedMode // Update current mode
               } else {
                   preferences.preferredContentMode = currentContentMode // Use the current mode.
               }
           }
        
        // Check for downloads
//        if let response = navigationAction.response as? HTTPURLResponse,
//           let contentDisposition = response.allHeaderFields["Content-Disposition"] as? String,
//           contentDisposition.contains("attachment") {
//            
//            // It's a download!
//            if let url = navigationAction.request.url {
//                DownloadManager.shared.startDownload(url: url)
//            }
//            decisionHandler(.cancel, preferences) // Cancel the navigation
//            return
//        }
//           decisionHandler(.allow, preferences)
       }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled {
            browserError = .networkError(underlyingError: error)  // Set the error
            print("WebView failed to load: \(error.localizedDescription)")
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled {
            browserError = .loadingError(underlyingError: error)   // Set the error
            print("WebView failed provisional navigation: \(error.localizedDescription)")
        }
    }
    
    // Handle target="_blank" links (open in new tab)
     func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
         if navigationAction.targetFrame == nil {
             // Open in a new tab
             addTab(url: navigationAction.request.url)
             return nil // We're handling the navigation
         }
         return nil // Let the default behavior occur
     }
}

// MARK: - ShinnyBrowserViewController

class ShinnyBrowserViewController: UIViewController {

    // MARK: - UI Elements

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        button.isEnabled = false // Initially disabled
        return button
    }()

    private lazy var forwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        button.isEnabled = false  // Initially disabled
        return button
    }()

    private lazy var urlView: UIView = {  // Container for URL field and buttons
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6 // Match the background
        return view
    }()

    private lazy var urlField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.placeholder = "Enter URL or Search"
        textField.delegate = self
        textField.returnKeyType = .go
        textField.clearButtonMode = .whileEditing // Good UX practice
        return textField
    }()

    private lazy var refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let refreshImage = UIImage(systemName: "arrow.clockwise")
        button.setImage(refreshImage, for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(reload), for: .touchUpInside)
        return button
    }()
    
    private lazy var showMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(showMore), for: .touchUpInside)
        return button
    }()

    private lazy var webViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var progressBar: UIView = { // Use a plain UIView for custom drawing
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBlue // Progress color
        view.isHidden = true // Initially hidden
        return view
    }()
    
    private var progressBarWidthConstraint: NSLayoutConstraint! // Constraint for progress bar width

    private lazy var webView: WKWebView = {  // Will be replaced by tab management
        let webView = WKWebView() // Now simpler
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private lazy var tabStackView: UIStackView = {  // For tabbed browsing
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually // Or another distribution as needed
        stackView.spacing = 8
        stackView.isHidden = true
        return stackView
    }()
    
    private lazy var addTabButton: UIButton = { // Button to add a new tab
         let button = UIButton(type: .system)
         button.translatesAutoresizingMaskIntoConstraints = false
         button.setImage(UIImage(systemName: "plus"), for: .normal)
         button.addTarget(self, action: #selector(addNewTab), for: .touchUpInside)
         return button
     }()

    private lazy var viewModel: BrowserViewModel = {
        let vm = BrowserViewModel(webView: webView)
        vm.delegate = self  // Set the delegate
        return vm
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self // Important for WKNavigationDelegate methods
        setupUI()
        setupConstraints()
        setupBindings() // Call setupBindings here
        viewModel.loadLastVisitedPage() // Or loadStartPage() if no last page
        updateUIForCurrentTab() // Display the initial tab
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(urlView)
        urlView.addSubview(backButton)
        urlView.addSubview(forwardButton)
        urlView.addSubview(urlField)
        urlView.addSubview(refreshButton)
        urlView.addSubview(showMoreButton)
        
        view.addSubview(tabStackView)  // Add the tab stack view
        tabStackView.addArrangedSubview(addTabButton) // Add tab button initially
        view.addSubview(webViewContainer)
//        webViewContainer.addSubview(webView) // Removed: Now managed by tabs
        view.addSubview(progressBar) // Add the progress bar to the main view
        
    }
    
    private func setupBindings() {
        //Bind UI elements to the ViewModel
        viewModel.$urlString
            .receive(on: RunLoop.main)
            .sink { [weak self] urlString in
                self?.urlField.text = urlString // Update urlField
            }
            .store(in: &viewModel.cancellables)

        viewModel.$canGoBack
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: backButton)
            .store(in: &viewModel.cancellables)

        viewModel.$canGoForward
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: forwardButton)
            .store(in: &viewModel.cancellables)

        viewModel.$estimatedProgress
            .receive(on: RunLoop.main)
            .sink { [weak self] progress in
                self?.updateProgressBar(progress: progress)
            }
            .store(in: &viewModel.cancellables)

        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .map { !$0 }
            .assign(to: \.isHidden, on: progressBar)
            .store(in: &viewModel.cancellables)
        
        // Error handling
        viewModel.$browserError
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showError(error)
                }
            }
            .store(in: &viewModel.cancellables)
        
        // Tabs
        viewModel.$tabs
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateTabUI() // Refresh tab UI when tabs change
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.$currentTabIndex
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateUIForCurrentTab() // Update UI when current tab changes
            }
            .store(in: &viewModel.cancellables)
    }

    // MARK: - Constraints Setup

    private func setupConstraints() {
        // Progress bar width constraint (initially zero)
        progressBarWidthConstraint = progressBar.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            // URL View
            urlView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            urlView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            urlView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            urlView.heightAnchor.constraint(equalToConstant: 44), // Standard height

            // Back Button
            backButton.leadingAnchor.constraint(equalTo: urlView.leadingAnchor, constant: 8),
            backButton.centerYAnchor.constraint(equalTo: urlView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            // Forward Button
            forwardButton.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            forwardButton.centerYAnchor.constraint(equalTo: urlView.centerYAnchor),
            forwardButton.widthAnchor.constraint(equalToConstant: 44),
            forwardButton.heightAnchor.constraint(equalToConstant: 44),

            // URL Field
            urlField.leadingAnchor.constraint(equalTo: forwardButton.trailingAnchor, constant: 8),
            urlField.centerYAnchor.constraint(equalTo: urlView.centerYAnchor),
            urlField.trailingAnchor.constraint(equalTo: refreshButton.leadingAnchor, constant: -8),

            // Refresh Button
            refreshButton.trailingAnchor.constraint(equalTo: showMoreButton.leadingAnchor, constant: -8),
            refreshButton.centerYAnchor.constraint(equalTo: urlView.centerYAnchor),
            refreshButton.widthAnchor.constraint(equalToConstant: 44),
            refreshButton.heightAnchor.constraint(equalToConstant: 44),

            // Show More Button
            showMoreButton.trailingAnchor.constraint(equalTo: urlView.trailingAnchor, constant: -8),
            showMoreButton.centerYAnchor.constraint(equalTo: urlView.centerYAnchor),
            showMoreButton.widthAnchor.constraint(equalToConstant: 44),
            showMoreButton.heightAnchor.constraint(equalToConstant: 44),

            // Web View Container
            webViewContainer.topAnchor.constraint(equalTo: urlView.bottomAnchor),
            webViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webViewContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // Progress Bar (anchored to top of urlView)
            progressBar.topAnchor.constraint(equalTo: urlView.bottomAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBarWidthConstraint, // Use the constraint
            progressBar.heightAnchor.constraint(equalToConstant: 2), // Fixed height
            
            // Tab Stack View
            tabStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tabStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabStackView.heightAnchor.constraint(equalToConstant: 44),  // Same height as urlView
        ])
    }
    
    // MARK: - Progress Bar

    private func updateProgressBar(progress: Double) {
//        progressBarWidthConstraint.constant = view.frame.width * CGFloat
        
        if progress >= 1.0 {
            // Animate hiding the progress bar
            UIView.animate(withDuration: 0.2, animations: {
                self.progressBar.alpha = 0.0
            }) { _ in
                // Reset constraint after animation for next load
                self.progressBarWidthConstraint.constant = 0
                self.progressBar.alpha = 1.0 // Reset alpha
            }
        }
    }

    // MARK: - Actions
    @objc private func goBack() {
        viewModel.goBack()
    }

    @objc private func goForward() {
        viewModel.goForward()
    }

    @objc private func reload() {
        viewModel.reload()
    }
    
    @objc private func showMore() {
        // Create action sheet options.
        let shareAction = UIAlertAction(title: "Share", style: .default) { [weak self] _ in
            self?.viewModel.shareCurrentPage()
        }
        let addToFavoritesAction = UIAlertAction(title: "Add to Favorites", style: .default) { [weak self] _ in
            self?.viewModel.addToFavorites()
        }
        let loadStartPageAction = UIAlertAction(title: "Load Start Page", style: .default) { [weak self] _ in
            self?.viewModel.loadStartPage()
        }
        
        let toggleContentAction = UIAlertAction(title: "Toggle Content", style: .default) {[weak self] _ in
            self?.viewModel.toggleContentMode()
        }
        
        let showFavoritesAction = UIAlertAction(title: "Show Favorites", style: .default) { [weak self] _ in
            self?.viewModel.showFavorites()
        }

        let showHistoryAction = UIAlertAction(title: "Show History", style: .default) { [weak self] _ in
            self?.viewModel.showHistory()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        // Add actions to the alert controller.
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(shareAction)
        alertController.addAction(addToFavoritesAction)
        alertController.addAction(loadStartPageAction)
        alertController.addAction(toggleContentAction)
        alertController.addAction(showFavoritesAction) // Added Show Favorites
        alertController.addAction(showHistoryAction)   // Added Show History
        alertController.addAction(cancelAction)
        
        // iPad-specific presentation.
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = showMoreButton // Anchor to the button
            popoverController.sourceRect = showMoreButton.bounds // Show from the button
            popoverController.permittedArrowDirections = [.up, .down] // Allow arrows
        }

        present(alertController, animated: true)
    }
    
    // MARK: - Error Handling
     func showError(_ error: BrowserError) {
         let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
         alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         present(alertController, animated: true)
     }
    
    // MARK: - Tab Management
    
    @objc private func addNewTab() {
        viewModel.addTab(url: nil) // Add a new tab with no URL (loads start page)
    }

    private func updateTabUI() {
        // Remove all existing tab buttons
        for subview in tabStackView.arrangedSubviews {
            if subview != addTabButton { // Keep the addTabButton
                tabStackView.removeArrangedSubview(subview)
                subview.removeFromSuperview()
            }
        }

        // Add buttons for each tab
        for (index, tab) in viewModel.tabs.enumerated() {
            let button = UIButton(type: .system)
            
            // Use tab's title if available, otherwise use URL or "New Tab"
            let title = tab.title ?? tab.url ?? "New Tab"
            button.setTitle(title, for: .normal)
            
            button.tag = index
            button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)

            // Add a close button to each tab
            let closeButton = UIButton(type: .system)
            closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            closeButton.tag = index  // Important: Tag with the index for removal
            closeButton.addTarget(self, action: #selector(closeTabTapped(_:)), for: .touchUpInside)

            // Create a horizontal stack view for tab title and close button
            let tabStack = UIStackView(arrangedSubviews: [button, closeButton])
            tabStack.axis = .horizontal
            tabStack.spacing = 4

            tabStackView.insertArrangedSubview(tabStack, at: index) // Insert *before* addTabButton
        }
    }

    @objc private func tabTapped(_ sender: UIButton) {
        viewModel.switchTab(to: sender.tag)
    }
    
    @objc private func closeTabTapped(_ sender: UIButton) {
        viewModel.closeTab(at: sender.tag)
    }

    private func updateUIForCurrentTab() {
        // Remove the currently displayed web view (if any)
        for subview in webViewContainer.subviews {
            subview.removeFromSuperview()
        }

        guard viewModel.tabs.indices.contains(viewModel.currentTabIndex) else { return }

        let currentTab = viewModel.tabs[viewModel.currentTabIndex]
        
        // Add constraints to pin webview inside the container view
        webViewContainer.addSubview(currentTab.webView)
        currentTab.webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentTab.webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor),
            currentTab.webView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor),
            currentTab.webView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor),
            currentTab.webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor)
        ])

        // Update the URL field with the current tab's URL
        urlField.text = currentTab.webView.url?.absoluteString
    }
}

// MARK: - UITextFieldDelegate

extension ShinnyBrowserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            viewModel.loadURL(string: text)
        }
        textField.resignFirstResponder() // Hide keyboard
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        guard let enteredText = textField.text?.lowercased() else { return }
        
        // Compare the entered text with the *current* webView's URL.
        if let currentURLString = viewModel.tabs[viewModel.currentTabIndex].webView.url?.absoluteString.lowercased() {
            if enteredText == currentURLString {
                return // Do nothing if they are the same
            }
        }
        // If different (or no current URL), proceed with loading.
        viewModel.loadURL(string: enteredText)
    }
}

// MARK: - WKNavigationDelegate

extension ShinnyBrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        viewModel.webView(webView, didCommit: navigation)
        
        // Update the URL field *only* on didCommit.  This handles redirects.
        if let currentURLString = webView.url?.absoluteString {
            urlField.text = currentURLString
        }
    }

    private func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        viewModel.webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        viewModel.webView(webView, didFail: navigation, withError: error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        viewModel.webView(webView, didFailProvisionalNavigation: navigation, withError: error)
    }
    
    // Handle target="_blank"
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        return viewModel.webView(webView, createWebViewWith: configuration, for: navigationAction, windowFeatures: windowFeatures)
    }
}

// MARK: - BrowserViewDelegate

extension ShinnyBrowserViewController: BrowserViewDelegate {
    func didRequestToggleContentMode(for url: URL, newMode: WKWebpagePreferences.ContentMode) {
        // Update UI or provide feedback to the user if needed
        print("Requested content mode \(newMode) for \(url.absoluteString)")
    }
    
    func didTapBackButton() {
        //Update UI to show the back button
    }
    
    func didTapForwardButton() {
        //Update UI to show the forward button
    }
    
    func didTapReloadButton() {
        //Update UI to show the reload button
    }
    
    func didRequestShare(for url: URL) {
         // Handle the share action, e.g., present a UIActivityViewController.
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
           
        // For iPad, present as a popover.
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view // Or a relevant button
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
           
        present(activityViewController, animated: true)
    }
    
    func didRequestAddToFavorites(for url: URL) {
        // Handle adding to favorites.
        // You would typically save the URL to persistent storage (UserDefaults, Core Data, etc.)
        print("Add to Favorites: \(url.absoluteString)") // Replace with actual saving logic
    }
    
    func didRequestShowFavorites() {
        let favoritesVC = FavoritesViewController(viewModel: viewModel)
        present(favoritesVC, animated: true)
    }

    func didRequestShowHistory() {
        let historyVC = HistoryViewController(viewModel: viewModel)
        present(historyVC, animated: true)
    }
}

// MARK: - FavoritesViewController
class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let viewModel: BrowserViewModel
    private let tableView = UITableView()

    init(viewModel: BrowserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Favorites"
        view.backgroundColor = .white
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FavoriteCell")

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add a close button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissFavorites))
    }
    
    @objc func dismissFavorites() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData() // Refresh the table view
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath)
        let favorite = viewModel.favorites[indexPath.row]
        cell.textLabel?.text = favorite.title
        cell.detailTextLabel?.text = favorite.url // Display URL as well
        return cell
    }
    
    // MARK: - UITableViewDelegate
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          let favorite = viewModel.favorites[indexPath.row]
          if URL(string: favorite.url) != nil {
              viewModel.loadURL(string: favorite.url) // Load the URL
              print(favorite.url)
          }
          dismiss(animated: true, completion: nil) // Dismiss after selection
      }
    
    // Swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.removeFavorite(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - HistoryViewController

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let viewModel: BrowserViewModel
    private let tableView = UITableView()

    init(viewModel: BrowserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "History"
        view.backgroundColor = .white

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell") // Different identifier

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Add a close button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissHistory))
    }

    @objc func dismissHistory() {
        dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData() // Refresh the table view
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.history.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        let historyEntry = viewModel.history[indexPath.row]
        cell.textLabel?.text = historyEntry.title
        
        // Format and display the timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        cell.detailTextLabel?.text = dateFormatter.string(from: historyEntry.timestamp)
        
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let historyEntry = viewModel.history[indexPath.row]
        if URL(string: historyEntry.url) != nil {
            viewModel.loadURL(string: historyEntry.url) // Load the URL
            print(historyEntry.url)
        }
        dismiss(animated: true, completion: nil)  // Dismiss after selection
    }
    
    // Optional: Swipe to delete (if you want to allow deleting history entries)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       if editingStyle == .delete {
           viewModel.removeHistoryEntry(at: indexPath.row)
           tableView.deleteRows(at: [indexPath], with: .fade)
       }
    }
}

// MARK: - DownloadsViewController (Example - Adapt as needed)

class DownloadsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let downloadManager = DownloadManager.shared
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Downloads"
        view.backgroundColor = .white

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DownloadCell")

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Add a close button (if presented modally)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissDownloads))
        
        setupBindings()
    }

    @objc func dismissDownloads() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupBindings() {
          // Observe changes in the downloads array
          downloadManager.$downloads
              .receive(on: DispatchQueue.main)
              .sink { [weak self] _ in
                  self?.tableView.reloadData()
              }
//              .store(in: &downloadManager.cancellables) // Use downloadManager's cancellables
      }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadManager.downloads.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadCell", for: indexPath)
        let download = downloadManager.downloads[indexPath.row]
        cell.textLabel?.text = download.url.lastPathComponent

        // Display progress
        cell.detailTextLabel?.text = "\(Int(download.progress * 100))% - \(download.status)"

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle selection (e.g., open the downloaded file)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
