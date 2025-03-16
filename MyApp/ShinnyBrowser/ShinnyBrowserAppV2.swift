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
}

// MARK: - Enums (for better organization)

enum SearchEngine: String, CaseIterable {
    case google = "https://www.google.com/search?q="
    case duckDuckGo = "https://duckduckgo.com/?q="
    case bing = "https://www.bing.com/search?q="
    case brave = "https://search.brave.com/search?q="
    case yahoo = "https://search.yahoo.com/search?p="
    case ecosia = "https://www.ecosia.org/search?q="
    case startpage = "https://www.startpage.com/do/search?query="
    // Tor is not directly a search engine, it's a network.  You'd use a search engine *within* Tor.
    // We can represent a common search engine used within Tor, like DuckDuckGo's onion address.
    case duckDuckGoOnion = "https://duckduckgogg42xjoc72x3sjasowoarfbgcmvfimaftt6twagswzczad.onion/?q=" // Corrected DDG Onion URL

    var urlPrefix: String { rawValue }

    //User-friendly names
    var displayName: String {
        switch self {
        case .google: return "Google"
        case .duckDuckGo: return "DuckDuckGo"
        case .bing: return "Bing"
        case .brave: return "Brave Search"
        case .yahoo: return "Yahoo Search"
        case .ecosia: return "Ecosia"
        case .startpage: return "Startpage"
        case .duckDuckGoOnion: return "DuckDuckGo (Onion)"
        }
    }
    
    // A helper to check if the engine requires special handling (like the onion address).
        var requiresSpecialHandling: Bool {
            switch self {
            case .duckDuckGoOnion:
                return true
            default:
                return false
            }
        }
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
    @Published var errorMessage: String? = nil // Error handling

    private var contentModeToRequestForHost: [String: WKWebpagePreferences.ContentMode] = [:]
    var cancellables: Set<AnyCancellable> = []
    weak var delegate: BrowserViewDelegate?
    
    private let urlKey = "LastCommittedURLString" // UserDefaults key
    let searchEngineKey = "DefaultSearchEngine"

    private let webView: WKWebView
    
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
        
        setupBindings()
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
    }
    

    // MARK: - Public Methods (Actions from View)
    
    func loadURL(string: String) {
        errorMessage = nil // Clear any previous error
        guard let url = validatedURL(from: string) else {
            errorMessage = "Invalid URL or search term." // Set error message
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func goBack() {
        if webView.canGoBack {
            webView.goBack()
            delegate?.didTapBackButton()
        }
    }

    func goForward() {
        if webView.canGoForward {
            webView.goForward()
            delegate?.didTapForwardButton()
        }
    }
    
    func reload() {
        webView.reload()
        delegate?.didTapReloadButton()
    }

    func loadStartPage() {
        guard let startURL = Bundle.main.url(forResource: "UserAgent", withExtension: "html") else {
            errorMessage = "Could not load start page." // Set error message
            return
        }
        
        webView.loadFileURL(startURL, allowingReadAccessTo: startURL.deletingLastPathComponent())
    }

    func shareCurrentPage() {
        guard let url = webView.url else { return }
        delegate?.didRequestShare(for: url)
    }
    
    func addToFavorites() {
        guard let url = webView.url else { return }
        delegate?.didRequestAddToFavorites(for: url)
    }

    func toggleContentMode() {
            guard let url = webView.url, let host = url.host() else { return }

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
            webView.reloadFromOrigin()
            delegate?.didRequestToggleContentMode(for: url, newMode: nextMode)
        }
    
    // MARK: - URL Handling

    func validatedURL(from input: String) -> URL? {
        // Improved URL validation and formatting.
        var text = input.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check if the input is already a valid URL
        if let url = URL(string: text), url.scheme != nil {
            return url
        }

        // If scheme is missing, try prepending "https://"
        if !text.lowercased().hasPrefix("http://") && !text.lowercased().hasPrefix("https://") {
            text = "https://" + text
        }
        
        // Try creating a URL again.  If it still fails, it's not a valid URL.
        if let url = URL(string: text) {
            return url
        }

        // If not a valid URL, treat it as a search query
        return constructSearchURL(from: input)
    }
    
    private func constructSearchURL(from query: String) -> URL? {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Load the user's preferred search engine from UserDefaults, default to Google.
        let searchEngineString = UserDefaults.standard.string(forKey: searchEngineKey) ?? SearchEngine.google.rawValue
        let searchEngine = SearchEngine(rawValue: searchEngineString) ?? .google
        
        // Check if the selected engine requires special handling
        if searchEngine.requiresSpecialHandling {
            if searchEngine == .duckDuckGoOnion {
                //  For .onion addresses, we *must* load it directly if the user selects it
                //  (assuming the user has a Tor-enabled setup).  A normal browser won't open it.
                return URL(string: searchEngine.urlPrefix + encodedQuery)
            }
        }

        return URL(string: searchEngine.urlPrefix + encodedQuery)
    }
    
    func loadLastVisitedPage() {
        // Load the last visited URL from UserDefaults.
        if let lastURLString = UserDefaults.standard.string(forKey: urlKey),
           let lastURL = URL(string: lastURLString) {
            urlString = lastURLString // Update the urlField.
            webView.load(URLRequest(url: lastURL))
        } else {
            loadStartPage() // Load a default page if no saved URL.
        }
    }
    
    // MARK: - WebView Delegate Forwarding
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // Save the last committed URL to UserDefaults.
        if let urlString = webView.url?.absoluteString {
            UserDefaults.standard.set(urlString, forKey: urlKey)
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
           decisionHandler(.allow, preferences)
       }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleWebViewError(error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleWebViewError(error)
    }

    private func handleWebViewError(_ error: Error) {
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled {
            errorMessage = "Failed to load: \(error.localizedDescription)"  // More user-friendly message
            // Special handling for .onion addresses (if not using a Tor-enabled browser/setup)
            if let failingURL = (error as? URLError)?.failingURL,
               failingURL.absoluteString.contains(".onion") && !webView.url!.absoluteString.contains(".onion") {
                errorMessage = "Cannot load .onion addresses without a Tor-enabled connection."
            }
        }
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
        textField.autocapitalizationType = .none // For URLs and search terms
        textField.keyboardType = .webSearch   // More appropriate keyboard
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

    private lazy var webView: WKWebView = {
        let webView = WKWebView() // Now simpler
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    private lazy var viewModel: BrowserViewModel = {
        let vm = BrowserViewModel(webView: webView)
        vm.delegate = self  // Set the delegate
        return vm
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        label.textAlignment = .center
        label.numberOfLines = 0  // Allow multiple lines for longer error messages
        label.isHidden = true // Initially hidden
        return label
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self // Important for WKNavigationDelegate methods
        setupUI()
        setupConstraints()
        bindViewModel()
        viewModel.loadLastVisitedPage() // Or loadStartPage() if no last page
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
        view.addSubview(webViewContainer)
        webViewContainer.addSubview(webView)
        view.addSubview(progressBar) // Add the progress bar to the main view
        webViewContainer.addSubview(errorLabel) // Add the error label

        //Bind UI elements to the ViewModel
        viewModel.$urlString
            .receive(on: RunLoop.main)
            .sink { [weak self] newURLString in
                self?.urlField.text = newURLString
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
            
            // WebView
            webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor),
            webView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor),

            // Progress Bar (anchored to top of webViewContainer)
            progressBar.topAnchor.constraint(equalTo: urlView.bottomAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBarWidthConstraint, // Use the constraint
            progressBar.heightAnchor.constraint(equalToConstant: 2), // Fixed height

            // Error Label Constraints
            errorLabel.centerXAnchor.constraint(equalTo: webViewContainer.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: webViewContainer.centerYAnchor),
            errorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: webViewContainer.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: webViewContainer.trailingAnchor, constant: -20),
        ])
    }

     // MARK: - ViewModel Binding

    private func bindViewModel() {
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

        viewModel.$errorMessage
            .receive(on: RunLoop.main)
            .sink { [weak self] errorMessage in
                self?.errorLabel.text = errorMessage
                self?.errorLabel.isHidden = errorMessage == nil  // Show/hide based on error
            }
            .store(in: &viewModel.cancellables)
    }
    
    // MARK: - Progress Bar

    private func updateProgressBar(progress: Double) {
        progressBarWidthConstraint.constant = view.frame.width * CGFloat(progress)
        
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

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { [weak self] _ in
            self?.showSettings()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        // Add actions to the alert controller.
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(shareAction)
        alertController.addAction(addToFavoritesAction)
        alertController.addAction(loadStartPageAction)
        alertController.addAction(toggleContentAction)
        alertController.addAction(settingsAction) // Add settings action
        alertController.addAction(cancelAction)
        
        // iPad-specific presentation.
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = showMoreButton // Anchor to the button
            popoverController.sourceRect = showMoreButton.bounds // Show from the button
            popoverController.permittedArrowDirections = [.up, .down] // Allow arrows
        }

        present(alertController, animated: true)
    }

    private func showSettings() {
        let settingsVC = SettingsViewController(viewModel: viewModel)
        present(settingsVC, animated: true)
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
        guard var urlString = textField.text?.lowercased() else {
            return
        }

        if !urlString.contains("://") {
            if urlString.contains("localhost") || urlString.contains("127.0.0.1") {
                urlString = "http://" + urlString
            } else {
                urlString = "https://" + urlString
            }
        }

        if webView.url?.absoluteString == urlString {
            return
        }

        if let targetURL = URL(string: urlString) {
            webView.load(URLRequest(url: targetURL))
        } else {
            //If it is not URL, search
            if let searchURL = viewModel.validatedURL(from: urlString) {
                webView.load(URLRequest(url: searchURL))
            }
        }
    }
}

// MARK: - WKNavigationDelegate

extension ShinnyBrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        viewModel.webView(webView, didCommit: navigation)
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
}

// MARK: - Settings View Controller

class SettingsViewController: UIViewController {
    
    private let viewModel: BrowserViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var searchEnginePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    private lazy var searchEngineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Default Search Engine:"
        return label
    }()
    
    // MARK: - Init
    init(viewModel: BrowserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCurrentSettings()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        title = "Settings"
        
        view.addSubview(searchEngineLabel)
        view.addSubview(searchEnginePicker)

        NSLayoutConstraint.activate([
            searchEngineLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchEngineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchEngineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            searchEnginePicker.topAnchor.constraint(equalTo: searchEngineLabel.bottomAnchor, constant: 8),
            searchEnginePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchEnginePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func loadCurrentSettings() {
        let currentEngineString = UserDefaults.standard.string(forKey: viewModel.searchEngineKey) ?? SearchEngine.google.rawValue
        let currentEngine = SearchEngine(rawValue: currentEngineString) ?? .google
        
        // Find the index of the current search engine and select it
        if let index = SearchEngine.allCases.firstIndex(of: currentEngine) {
            searchEnginePicker.selectRow(index, inComponent: 0, animated: false)
        }
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension SettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SearchEngine.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return SearchEngine.allCases[row].displayName
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedEngine = SearchEngine.allCases[row]
        UserDefaults.standard.set(selectedEngine.rawValue, forKey: viewModel.searchEngineKey)
    }
}
