//
//  ShinnyBrowserViewController.swift
//  MyApp
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
    func didRequestShowHistory() // Added for showing history
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
    @Published var history: [HistoryItem] = [] // Add history tracking
    
    private var contentModeToRequestForHost: [String: WKWebpagePreferences.ContentMode] = [:]
    var cancellables: Set<AnyCancellable> = []
    weak var delegate: BrowserViewDelegate?
    
    private let urlKey = "LastCommittedURLString"
    private let historyKey = "BrowserHistory" // Key for UserDefaults
    
    private let webView: WKWebView
    
    // MARK: - Initializers
    
    init(webView: WKWebView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())) {
        self.webView = webView
        
        // Configure WKWebView
        let configuration = self.webView.configuration
        configuration.applicationNameForUserAgent = "Version/17.2 Safari/605.1.15"
        configuration.allowsInlineMediaPlayback = true
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        if #available(iOS 14.0, *) {
            let webpagePreferences = WKWebpagePreferences()
            webpagePreferences.preferredContentMode = .recommended
            configuration.defaultWebpagePreferences = webpagePreferences
        }
        
        setupBindings()
        loadHistory() // Load history on initialization
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        webView.publisher(for: \.url)
            .compactMap { $0?.absoluteString }
            .receive(on: DispatchQueue.main)
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
        guard let url = validatedURL(from: string) else {
            if let url = URL(string: "gogole.com") {
                delegate?.didRequestToggleContentMode(for: url, newMode: .recommended)
                return
            }
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
        currentContentMode = nextMode
        webView.reloadFromOrigin()
        delegate?.didRequestToggleContentMode(for: url, newMode: nextMode)
    }
    
    // MARK: - URL Handling
    
    func validatedURL(from input: String) -> URL? {
        var text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let url = URL(string: text), url.scheme != nil {
            return url
        }
        
        if !text.lowercased().hasPrefix("http://") && !text.lowercased().hasPrefix("https://") {
            text = "https://" + text
        }
        
        return URL(string: text)
    }
    
    func loadLastVisitedPage() {
        if let lastURLString = UserDefaults.standard.string(forKey: urlKey),
           let lastURL = URL(string: lastURLString) {
            urlString = lastURLString
            webView.load(URLRequest(url: lastURL))
        } else {
            loadStartPage()
        }
    }
    
    // MARK: - History Management
    
    func addToHistory(url: URL, title: String?) {
        let newItem = HistoryItem(url: url, title: title ?? url.absoluteString)
        // Check for duplicates before adding
        if !history.contains(where: { $0.url == url }) {
            history.insert(newItem, at: 0) // Newest at the top
            saveHistory()
        }
    }
    
    func clearHistory() {
        history.removeAll()
        saveHistory()
    }
    
    func saveHistory() {
        if let encodedData = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encodedData, forKey: historyKey)
        }
    }
    
    func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decodedHistory = try? JSONDecoder().decode([HistoryItem].self, from: data) {
            history = decodedHistory
        }
    }
    
    func showHistory() {
        delegate?.didRequestShowHistory() // Delegate call to show
    }
    
    // MARK: - WebView Delegate Forwarding
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let urlString = webView.url?.absoluteString {
            UserDefaults.standard.set(urlString, forKey: urlKey)
        }
        
        // Add to history when a page is loaded
        if let url = webView.url {
            addToHistory(url: url, title: webView.title)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        let preferences = WKWebpagePreferences()
        if #available(iOS 14.0, *) {
            if let host = navigationAction.request.url?.host(),
               let requestedMode = contentModeToRequestForHost[host] {
                preferences.preferredContentMode = requestedMode
                currentContentMode = requestedMode
            } else {
                preferences.preferredContentMode = currentContentMode
            }
        }
        decisionHandler(.allow, preferences)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled {
            print("WebView failed to load: \(error.localizedDescription)")
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled {
            print("WebView failed provisional navigation: \(error.localizedDescription)")
        }
    }
}

// MARK: - HistoryItem Struct

struct HistoryItem: Codable, Identifiable {
    var id = UUID()
    let url: URL
    let title: String
    let visitDate: Date = Date() // Add a timestamp
}

// MARK: - ShinnyBrowserViewController

class ShinnyBrowserViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "arrow.backward"), for: .normal) // Updated icon
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        button.isEnabled = false
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal) // Hug content
        return button
    }()
    
    private lazy var forwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "arrow.forward"), for: .normal) // Updated icon
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        button.isEnabled = false
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal) // Hug content
        return button
    }()
    
    private lazy var shareButton: UIButton = { // Added share button
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }()
    
    private lazy var urlView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
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
        textField.clearButtonMode = .whileEditing
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal) // Allow stretching
        return textField
    }()
    
    private lazy var refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let refreshImage = UIImage(systemName: "arrow.clockwise")
        button.setImage(refreshImage, for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(reload), for: .touchUpInside)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal) // Hug content
        return button
    }()
    
    private lazy var showMoreButton: UIButton = { // Changed to show history
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "clock"), for: .normal)  // Changed to clock icon
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(showHistoryTapped), for: .touchUpInside) // Show history action
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }()
    
    private lazy var webViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var progressBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBlue
        view.isHidden = true
        return view
    }()
    
    private var progressBarWidthConstraint: NSLayoutConstraint!
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    lazy var viewModel: BrowserViewModel = {
        let vm = BrowserViewModel(webView: webView)
        vm.delegate = self
        return vm
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        setupUI()
        setupConstraints()
        viewModel.loadLastVisitedPage()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // Toolbar for bottom buttons (More flexible and looks better)
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let backButtonItem = UIBarButtonItem(customView: backButton)
        let forwardButtonItem = UIBarButtonItem(customView: forwardButton)
        let shareButtonItem = UIBarButtonItem(customView: shareButton)
        let refreshButtonItem = UIBarButtonItem(customView: refreshButton)
        let historyButtonItem = UIBarButtonItem(customView: showMoreButton) // History
        
        toolbar.items = [backButtonItem, flexibleSpace, forwardButtonItem, flexibleSpace, shareButtonItem, flexibleSpace, refreshButtonItem, flexibleSpace, historyButtonItem]
        
        view.addSubview(urlView)
        urlView.addSubview(urlField)
        view.addSubview(webViewContainer)
        webViewContainer.addSubview(webView)
        view.addSubview(progressBar)
        
        // Bind UI elements to the ViewModel
        viewModel.$urlString
            .receive(on: RunLoop.main)
        
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
    }
    
    // MARK: - Constraints Setup
    
    private func setupConstraints() {
        progressBarWidthConstraint = progressBar.widthAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            // URL View
            urlView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            urlView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            urlView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            urlView.heightAnchor.constraint(equalToConstant: 44),
            
            // URL Field (Now simpler, spans the urlView)
            urlField.leadingAnchor.constraint(equalTo: urlView.leadingAnchor, constant: 8),
            urlField.trailingAnchor.constraint(equalTo: urlView.trailingAnchor, constant: -8),
            urlField.topAnchor.constraint(equalTo: urlView.topAnchor, constant: 4),
            urlField.bottomAnchor.constraint(equalTo: urlView.bottomAnchor, constant: -4),
            
            // Web View Container
            webViewContainer.topAnchor.constraint(equalTo: urlView.bottomAnchor),
            webViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webViewContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44), // Adjusted for toolbar
            
            // WebView
            webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor),
            webView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor),
            
            // Progress Bar
            progressBar.topAnchor.constraint(equalTo: urlView.bottomAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBarWidthConstraint,
            progressBar.heightAnchor.constraint(equalToConstant: 2),
            
            // Toolbar (Pinned to bottom)
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    // MARK: - Progress Bar
    
    private func updateProgressBar(progress: Double) {
        progressBarWidthConstraint.constant = view.frame.width * CGFloat(progress)
        
        if progress >= 1.0 {
            UIView.animate(withDuration: 0.2, animations: {
                self.progressBar.alpha = 0.0
            }) { _ in
                self.progressBarWidthConstraint.constant = 0
                self.progressBar.alpha = 1.0
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
    
    @objc private func shareTapped() { // Handle share button tap
        viewModel.shareCurrentPage()
    }
    
    @objc private func showHistoryTapped() {
        viewModel.showHistory()
    }
    
    @objc private func showMore() {
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
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(shareAction)
        alertController.addAction(addToFavoritesAction)
        alertController.addAction(loadStartPageAction)
        alertController.addAction(toggleContentAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = showMoreButton
            popoverController.sourceRect = showMoreButton.bounds
            popoverController.permittedArrowDirections = [.up, .down]
        }
        
        present(alertController, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension ShinnyBrowserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            viewModel.loadURL(string: text)
        }
        textField.resignFirstResponder()
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
        print("Requested content mode \(newMode) for \(url.absoluteString)")
    }
    
    func didTapBackButton() {
    }
    
    func didTapForwardButton() {
    }
    
    func didTapReloadButton() {
    }
    
    func didRequestShare(for url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
        
        present(activityViewController, animated: true)
    }
    
    func didRequestAddToFavorites(for url: URL) {
        print("Add to Favorites: \(url.absoluteString)")
    }
    
    func didRequestShowHistory() {
        let historyVC = HistoryViewController(history: viewModel.history) { [weak self] selectedURL in
            self?.viewModel.loadURL(string: selectedURL.absoluteString)
            historyVC.dismiss(animated: true, completion: nil) // Dismiss after loading
        }
        
        // Handle clearing history
        historyVC.onClearHistory = { [weak self] in
            self?.viewModel.clearHistory()
        }
        
        let navController = UINavigationController(rootViewController: historyVC)
        present(navController, animated: true, completion: nil)
    }
}

// MARK: - HistoryViewController

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BrowserViewDelegate {
    func didTapBackButton() {
        print(#function)
    }
    
    func didTapForwardButton() {
        print(#function)
    }
    
    func didTapReloadButton() {
        print(#function)
    }
    
    func didRequestShare(for url: URL) {
        print(#function)
    }
    
    func didRequestAddToFavorites(for url: URL) {
        print(#function)
    }
    
    func didRequestToggleContentMode(for url: URL, newMode: WKWebpagePreferences.ContentMode) {
        print(#function)
    }
    
    func didRequestShowHistory() {
        print(#function)
    }
    
    private let webView: WKWebView
    
    lazy var viewModel: BrowserViewModel = {
        let vm = BrowserViewModel(webView: webView)
        vm.delegate = self
        return vm
    }()
    
    
    private let history: [HistoryItem]
    private let onSelection: (URL) -> Void
    var onClearHistory: (() -> Void)?  // Closure for clearing
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: "HistoryCell") // Register cell
        return tableView
    }()
    
    init(history: [HistoryItem], onSelection: @escaping (URL) -> Void) {
        self.history = history
        self.onSelection = onSelection
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Link history"
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        // Add a "Clear All" button to the navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear all", style: .plain, target: self, action: #selector(clearHistoryTapped))
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func clearHistoryTapped() {
        onClearHistory?()  // Call the closure
        tableView.reloadData() // Refresh to show empty state
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.isEmpty ? 1 : history.count // Show 1 cell for "No history"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if history.isEmpty {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "No history"
            cell.textLabel?.textAlignment = .center
            cell.selectionStyle = .none // Prevent selection
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryTableViewCell else {
                return UITableViewCell() // Fallback, should not happen
            }
            let item = history[indexPath.row]
            cell.configure(with: item) // Configure the custom cell
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if !history.isEmpty {
            let selectedURL = history[indexPath.row].url
            onSelection(selectedURL)
        }
    }
    
    // Add swipe-to-delete functionality
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && !history.isEmpty{
            // Remove from history array
            viewModel.history.remove(at: indexPath.row)
            
            // Update UserDefaults
            viewModel.saveHistory()
            
            // Update table view
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - HistoryTableViewCell (Custom Cell)

class HistoryTableViewCell: UITableViewCell, BrowserViewDelegate {
    func didTapBackButton() {
        print(#function)
    }
    
    func didTapForwardButton() {
        print(#function)
    }
    
    func didTapReloadButton() {
        print(#function)
    }
    
    func didRequestShare(for url: URL) {
        print(#function)
    }
    
    func didRequestAddToFavorites(for url: URL) {
        print(#function)
    }
    
    func didRequestToggleContentMode(for url: URL, newMode: WKWebpagePreferences.ContentMode) {
        print(#function)
    }
    
    func didRequestShowHistory() {
        print(#function)
    }
    
    private let webView: WKWebView
    
    lazy var viewModel: BrowserViewModel = {
        let vm = BrowserViewModel(webView: webView)
        vm.delegate = self
        return vm
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 2 // Allow multiline titles
        return label
    }()
    
    private let urlLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textColor = .gray
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(urlLabel)
        contentView.addSubview(closeButton) // Add the close button
        
        // Constraints for labels and close button
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8), // Space from close button
            
            urlLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            urlLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            urlLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            urlLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 30), // Size for button
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside) // Add target
    }
    
    func configure(with item: HistoryItem) {
        titleLabel.text = item.title
        urlLabel.text = item.url.absoluteString
    }
    
    @objc private func closeButtonTapped() {
        guard let tableView = superview as? UITableView,
              let indexPath = tableView.indexPath(for: self) else { return }
        
        // Get the history item to be removed
        let itemToRemove = viewModel.history[indexPath.row]
        
        // Remove the item from the history array
        viewModel.history.removeAll { $0.id == itemToRemove.id }
        
        // Update UserDefaults
        viewModel.saveHistory()
        
        // Update the table view
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
