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
    func didTapBackButton(in tab: Tab)
    func didTapForwardButton(in tab: Tab)
    func didTapReloadButton(in tab: Tab)
    func didRequestShare(for url: URL, in tab: Tab)
    func didRequestAddToFavorites(for url: URL, in tab: Tab)
    func didRequestToggleContentMode(for url: URL, newMode: WKWebpagePreferences.ContentMode, in tab: Tab)
    func didRequestNewTab(with url: URL?)
    func didRequestCloseTab(at index: Int)
    func didRequestSwitchTab(to index: Int)
}

// MARK: - Tab

class Tab {
    let id = UUID() // Unique identifier for each tab
    var webView: WKWebView
    var cancellables: Set<AnyCancellable> = []
    @Published var url: URL?
    @Published var title: String?
    @Published var thumbnail: UIImage?
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var estimatedProgress: Double = 0.0
    @Published var isLoading: Bool = false
    var contentModeToRequestForHost: [String: WKWebpagePreferences.ContentMode] = [:] //Per-tab content mode
    var currentContentMode: WKWebpagePreferences.ContentMode = .recommended
    
    init(webView: WKWebView) {
        self.webView = webView
    }
}

// MARK: - ViewModel

class BrowserViewModel {
    
    // MARK: - Properties
    @Published var tabs: [Tab] = []
    @Published var currentTabIndex: Int = 0 {
        didSet {
            // Ensure index is within bounds.
            if !tabs.isEmpty {
                currentTabIndex = max(0, min(currentTabIndex, tabs.count - 1))
            }
        }
    }
    
    var cancellables: Set<AnyCancellable> = []
    weak var delegate: BrowserViewDelegate?
    
    private let urlKey = "LastCommittedURLString" // UserDefaults key
    
    // MARK: - Initializers
    
    init() {
        // No longer creates a default WKWebView here.
        setupBindings()
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        // Tab-specific bindings are now in setupTabBindings(_:)
    }
    
    private func setupTabBindings(for tab: Tab) {
        // Observe WKWebView properties for the given tab.
        tab.$url
            .compactMap { $0?.absoluteString }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] urlString in
                // Potentially update a UI element showing the current URL
                // Example: self?.updateURLField(urlString)
            }
            .store(in: &cancellables)
        
        tab.$canGoBack
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canGoBack in
                //Enable or disable UI
            }
            .store(in: &cancellables)
        
        tab.$canGoForward
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canGoForward in
                //Enable of disable UI
            }
            .store(in: &cancellables)
        
        tab.$title
            .receive(on: DispatchQueue.main)
            .sink{[weak self] title in
                //Update UI
            }
            .store(in: &cancellables)
        
        tab.$estimatedProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.delegate?.didRequestUpdateProgress(progress, in: tab) // Delegate call
            }
            .store(in: &cancellables)
        
        tab.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.delegate?.didRequestUpdateLoadingState(!isLoading, in: tab) // Delegate call
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Public Methods (Actions from View)
    
    func loadURL(string: String, in tab: Tab) {
        guard let url = validatedURL(from: string) else {
            // Handle invalid URL
            if let url = URL(string: "google.com") {
                delegate?.didRequestToggleContentMode(for: url, newMode: .recommended, in: tab)
                return
            }
            return
        }
        
        let request = URLRequest(url: url)
        tab.webView.load(request)
    }
    
    func goBack(in tab: Tab) {
        if tab.webView.canGoBack {
            tab.webView.goBack()
            delegate?.didTapBackButton(in: tab)
        }
    }
    
    func goForward(in tab: Tab) {
        if tab.webView.canGoForward {
            tab.webView.goForward()
            delegate?.didTapForwardButton(in: tab)
        }
    }
    
    func reload(in tab: Tab) {
        tab.webView.reload()
        delegate?.didTapReloadButton(in: tab)
    }
    
    func loadStartPage(in tab: Tab) {
        guard let startURL = Bundle.main.url(forResource: "UserAgent", withExtension: "html") else {
            // Handle missing start page
            return
        }
        
        tab.webView.loadFileURL(startURL, allowingReadAccessTo: startURL.deletingLastPathComponent())
    }
    
    func shareCurrentPage(in tab: Tab) {
        guard let url = tab.webView.url else { return }
        delegate?.didRequestShare(for: url, in: tab)
    }
    
    func addToFavorites(in tab: Tab) {
        guard let url = tab.webView.url else { return }
        delegate?.didRequestAddToFavorites(for: url, in: tab)
    }
    
    func toggleContentMode(in tab: Tab) {
        guard let url = tab.webView.url, let host = url.host() else { return }
        
        // Cycle through content modes
        let nextMode: WKWebpagePreferences.ContentMode
        switch tab.currentContentMode {
        case .recommended:
            nextMode = .mobile
        case .mobile:
            nextMode = .desktop
        case .desktop:
            nextMode = .recommended
        @unknown default:
            nextMode = .recommended
        }
        
        tab.contentModeToRequestForHost[host] = nextMode
        tab.currentContentMode = nextMode
        tab.webView.reloadFromOrigin()
        delegate?.didRequestToggleContentMode(for: url, newMode: nextMode, in: tab)
    }
    
    // MARK: - Tab Management
    
    func addTab(url: URL? = nil) {
        let config = WKWebViewConfiguration()
        config.applicationNameForUserAgent = "Version/17.2 Safari/605.1.15"
        config.allowsInlineMediaPlayback = true
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        
        if #available(iOS 14.0, *) {
            let webpagePreferences = WKWebpagePreferences()
            webpagePreferences.preferredContentMode = .recommended
            config.defaultWebpagePreferences = webpagePreferences
        }
        
        let newWebView = WKWebView(frame: .zero, configuration: config)
        let newTab = Tab(webView: newWebView)
        
        // Set up KVO for the new tab
        setupTabBindings(for: newTab)
        
        // Add the new tab to the tabs array
        tabs.append(newTab)
        
        // Switch to the newly created tab
        currentTabIndex = tabs.count - 1
        
        delegate?.didRequestNewTab(with: url)  // Notify the delegate
        
        // Load the URL if provided
        if let url = url {
            newWebView.load(URLRequest(url: url))
        } else {
            // Load the start page if no URL
            loadStartPage(in: newTab)
        }
    }
    
    func closeTab(at index: Int) {
        guard index >= 0 && index < tabs.count else { return }
        
        //Remove KVO before removing tab
        let tabToRemove = tabs[index]
        tabToRemove.webView.stopLoading() //Good practice
        
        //Clean up KVO observer
        tabToRemove.webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.url))
        tabToRemove.webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
        tabToRemove.webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward))
        tabToRemove.webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        tabToRemove.webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.isLoading))
        
        tabs.remove(at: index)
        
        // If the closed tab was the current tab, update the currentTabIndex.
        if currentTabIndex >= index {
            currentTabIndex = max(0, min(currentTabIndex - 1, tabs.count - 1))
        }
        
        delegate?.didRequestCloseTab(at: index)  // Notify the delegate
    }
    
    func switchTab(to index: Int) {
        guard index >= 0 && index < tabs.count else { return }
        currentTabIndex = index
        delegate?.didRequestSwitchTab(to: index) //Notify the delegate
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
    
    func loadLastVisitedPage(in tab: Tab) {
        // Load the last visited URL from UserDefaults.
        if let lastURLString = UserDefaults.standard.string(forKey: urlKey),
           let lastURL = URL(string: lastURLString) {
            tab.url = lastURL
            tab.webView.load(URLRequest(url: lastURL))
        } else {
            loadStartPage(in: tab) // Load a default page if no saved URL.
        }
    }
    
    
    // MARK: - WebView Delegate Forwarding
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!, in tab: Tab) {
        // Save the last committed URL to UserDefaults.
        if let urlString = webView.url?.absoluteString {
            UserDefaults.standard.set(urlString, forKey: urlKey)
        }
        //Update properties
        tab.url = webView.url
        tab.title = webView.title
        tab.canGoBack = webView.canGoBack
        tab.canGoForward = webView.canGoForward
        tab.estimatedProgress = webView.estimatedProgress
        tab.isLoading = webView.isLoading
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void, in tab: Tab) {
        let preferences = WKWebpagePreferences()
        if #available(iOS 14.0, *) {
            if let host = navigationAction.request.url?.host(),
               let requestedMode = tab.contentModeToRequestForHost[host] {
                preferences.preferredContentMode = requestedMode
                tab.currentContentMode = requestedMode // Update current mode
            } else {
                preferences.preferredContentMode = tab.currentContentMode // Use the current mode.
            }
        }
        decisionHandler(.allow, preferences)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error, in tab: Tab) {
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled {
            print("WebView failed to load: \(error.localizedDescription)")
            //Update UI. Show error
        }
        tab.isLoading = false
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error, in tab: Tab) {
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled {
            print("WebView failed provisional navigation: \(error.localizedDescription)")
            //Update UI, Show error
        }
        tab.isLoading = false
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
    
    private lazy var addTabButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(addNewTab), for: .touchUpInside)
        return button
    }()
    
    private lazy var webViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tabCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 40) // Tab size
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemGray6
        collectionView.register(TabCollectionViewCell.self, forCellWithReuseIdentifier: TabCollectionViewCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var progressBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBlue
        view.isHidden = true
        return view
    }()
    
    private var progressBarWidthConstraint: NSLayoutConstraint!
    
    private var currentWebView: WKWebView?  // Keep track of the currently displayed WKWebView
    
    private lazy var viewModel: BrowserViewModel = {
        let vm = BrowserViewModel()
        vm.delegate = self
        return vm
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupBindings()
        viewModel.addTab() // Start with one tab
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
        urlView.addSubview(addTabButton)
        
        view.addSubview(tabCollectionView)
        view.addSubview(webViewContainer)
        view.addSubview(progressBar)
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
            showMoreButton.trailingAnchor.constraint(equalTo: addTabButton.leadingAnchor, constant: -8),
            showMoreButton.centerYAnchor.constraint(equalTo: urlView.centerYAnchor),
            showMoreButton.widthAnchor.constraint(equalToConstant: 44),
            showMoreButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Add Tab Button
            addTabButton.trailingAnchor.constraint(equalTo: urlView.trailingAnchor, constant: -8),
            addTabButton.centerYAnchor.constraint(equalTo: urlView.centerYAnchor),
            addTabButton.widthAnchor.constraint(equalToConstant: 44),
            addTabButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Tab Collection View
            tabCollectionView.topAnchor.constraint(equalTo: urlView.bottomAnchor),
            tabCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabCollectionView.heightAnchor.constraint(equalToConstant: 48), // Tab bar height
            
            // Web View Container
            webViewContainer.topAnchor.constraint(equalTo: tabCollectionView.bottomAnchor),
            webViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webViewContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Progress Bar (anchored to top of webViewContainer)
            progressBar.topAnchor.constraint(equalTo: tabCollectionView.bottomAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBarWidthConstraint,
            progressBar.heightAnchor.constraint(equalToConstant: 2),
        ])
    }
    
    private func setupBindings() {
        viewModel.$currentTabIndex
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.displayCurrentTab()
            }
            .store(in: &viewModel.cancellables)
        
        // No need to bind urlString, canGoBack, canGoForward, estimatedProgress, isLoading here.
        // They are now handled per-tab in the ViewModel's setupTabBindings.
    }
    
    // MARK: - Tab Management
    
    private func displayCurrentTab() {
        // Remove the previously displayed WKWebView (if any)
        currentWebView?.removeFromSuperview()
        currentWebView = nil
        
        guard viewModel.tabs.indices.contains(viewModel.currentTabIndex) else {
            return // No tab to display
        }
        let currentTab = viewModel.tabs[viewModel.currentTabIndex]
        let webView = currentTab.webView
        
        // Add the new WKWebView to the container
        webView.navigationDelegate = self // Make sure the delegate is set
        webViewContainer.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor),
            webView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor),
        ])
        
        currentWebView = webView // Keep track of the current WKWebView
        
        //Update UI element base on current Tab
        urlField.text = currentTab.url?.absoluteString ?? ""
        backButton.isEnabled = currentTab.canGoBack
        forwardButton.isEnabled = currentTab.canGoForward
        updateProgressBar(progress: currentTab.estimatedProgress)
        progressBar.isHidden = !currentTab.isLoading
        
        tabCollectionView.reloadData() // Refresh tab UI
        tabCollectionView.selectItem(at: IndexPath(item: viewModel.currentTabIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally) //Highlight current tab
    }
    
    // MARK: - Actions
    
    @objc private func addNewTab() {
        viewModel.addTab()
    }
    
    @objc private func goBack() {
        guard let currentTab = currentWebViewTab else { return }
        viewModel.goBack(in: currentTab)
    }
    
    @objc private func goForward() {
        guard let currentTab = currentWebViewTab else { return }
        viewModel.goForward(in: currentTab)
    }
    
    @objc private func reload() {
        guard let currentTab = currentWebViewTab else { return }
        viewModel.reload(in: currentTab)
    }
    
    private var currentWebViewTab: Tab? {
        guard viewModel.tabs.indices.contains(viewModel.currentTabIndex) else {
            return nil
        }
        return viewModel.tabs[viewModel.currentTabIndex]
    }
    
    @objc private func showMore() {
        guard let currentTab = currentWebViewTab else { return }
        
        let shareAction = UIAlertAction(title: "Share", style: .default) { [weak self, weak currentTab] _ in
            guard let tab = currentTab else { return }
            self?.viewModel.shareCurrentPage(in: tab)
        }
        let addToFavoritesAction = UIAlertAction(title: "Add to Favorites", style: .default) { [weak self, weak currentTab] _ in
            guard let tab = currentTab else { return }
            self?.viewModel.addToFavorites(in: tab)
        }
        let loadStartPageAction = UIAlertAction(title: "Load Start Page", style: .default) { [weak self, weak currentTab] _ in
            guard let tab = currentTab else { return }
            self?.viewModel.loadStartPage(in: tab)
        }
        let toggleContentAction = UIAlertAction(title: "Toggle Content", style: .default) { [weak self, weak currentTab] _ in
            guard let tab = currentTab else { return }
            self?.viewModel.toggleContentMode(in: tab)
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
}

// MARK: - UITextFieldDelegate

extension ShinnyBrowserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let currentTab = currentWebViewTab, let text = textField.text else {
            textField.resignFirstResponder()
            return true
        }
        viewModel.loadURL(string: text, in: currentTab)
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        guard let currentTab = currentWebViewTab, var urlString = textField.text?.lowercased() else {
            return
        }
        
        if !urlString.contains("://") {
            if urlString.contains("localhost") || urlString.contains("127.0.0.1") {
                urlString = "http://" + urlString
            } else {
                urlString = "https://" + urlString
            }
        }
        
        if currentTab.webView.url?.absoluteString == urlString {
            return
        }
        
        if let targetURL = URL(string: urlString) {
            currentTab.webView.load(URLRequest(url: targetURL))
        }
    }
}

// MARK: - WKNavigationDelegate

extension ShinnyBrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard let tab = viewModel.tabs.first(where: { $0.webView == webView }) else { return }
        viewModel.webView(webView, didCommit: navigation, in: tab)
        urlField.text = webView.url?.absoluteString // Update the URL field
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        guard let tab = viewModel.tabs.first(where: { $0.webView == webView }) else {
            // If the webView doesn't belong to a tab, allow navigation without custom preferences.
            decisionHandler(.allow, WKWebpagePreferences())
            return
        }
        viewModel.webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler, in: tab)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        guard let tab = viewModel.tabs.first(where: { $0.webView == webView }) else { return }
        viewModel.webView(webView, didFail: navigation, withError: error, in: tab)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        guard let tab = viewModel.tabs.first(where: { $0.webView == webView }) else { return }
        viewModel.webView(webView, didFailProvisionalNavigation: navigation, withError: error, in: tab)
    }
}

// MARK: - BrowserViewDelegate
extension ShinnyBrowserViewController: BrowserViewDelegate {
    func didRequestUpdateLoadingState(_ isHidden: Bool, in tab: Tab) {
        if currentWebViewTab?.id == tab.id {
            progressBar.isHidden = isHidden
        }
    }
    
    func didRequestUpdateProgress(_ progress: Double, in tab: Tab) {
        if currentWebViewTab?.id == tab.id {
            updateProgressBar(progress: progress)
        }
    }
    
    func didRequestToggleContentMode(for url: URL, newMode: WKWebpagePreferences.ContentMode, in tab: Tab) {
        print("Requested content mode \(newMode) for \(url.absoluteString) in tab \(tab.id)")
    }
    
    func didTapBackButton(in tab: Tab) {
        if currentWebViewTab?.id == tab.id {
            backButton.isEnabled = tab.canGoBack
        }
    }
    
    func didTapForwardButton(in tab: Tab) {
        if currentWebViewTab?.id == tab.id {
            forwardButton.isEnabled = tab.canGoForward
        }
    }
    
    func didTapReloadButton(in tab: Tab) {
        //No UI update
    }
    
    func didRequestShare(for url: URL, in tab: Tab) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
        present(activityViewController, animated: true)
    }
    
    func didRequestAddToFavorites(for url: URL, in tab: Tab) {
        print("Add to Favorites: \(url.absoluteString) in tab \(tab.id)")
    }
    
    func didRequestNewTab(with url: URL?) {
        tabCollectionView.reloadData()
        tabCollectionView.selectItem(at: IndexPath(item: viewModel.currentTabIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        displayCurrentTab() // Display immediately
    }
    
    func didRequestCloseTab(at index: Int) {
        tabCollectionView.reloadData()
        // If there are no tabs left, don't try to select one.
        if !viewModel.tabs.isEmpty {
            tabCollectionView.selectItem(at: IndexPath(item: viewModel.currentTabIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        }
        displayCurrentTab() // Display immediately
    }
    
    func didRequestSwitchTab(to index: Int) {
        displayCurrentTab() // Display immediately
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension ShinnyBrowserViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.tabs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabCollectionViewCell.reuseIdentifier, for: indexPath) as! TabCollectionViewCell
        let tab = viewModel.tabs[indexPath.item]
        cell.configure(with: tab, isSelected: indexPath.item == viewModel.currentTabIndex)
        
        // Set up close button action
        cell.closeButtonAction = { [weak self] in
            self?.viewModel.closeTab(at: indexPath.item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.switchTab(to: indexPath.item)
    }
}

// MARK: - TabCollectionViewCell

class TabCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "TabCell"
    
    var closeButtonAction: (() -> Void)? // Closure for close button tap
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail // Prevent long titles from overflowing
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .gray // Close button color
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(closeButton)
        contentView.backgroundColor = .lightGray // Default background
        contentView.layer.cornerRadius = 8 // Rounded corners
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            closeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 20), // Close button size
            closeButton.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    func configure(with tab: Tab, isSelected: Bool) {
        titleLabel.text = tab.title ?? "New Tab"
        
        // Update appearance based on selection
        if isSelected {
            contentView.backgroundColor = .white // Highlight selected tab
            titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        } else {
            contentView.backgroundColor = .lightGray
            titleLabel.font = UIFont.systemFont(ofSize: 14)
        }
        
        //Subscribe to title updates
        tab.$title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newTitle in
                self?.titleLabel.text = newTitle ?? "New Tab"
            }
            .store(in: &tab.cancellables)
    }
    
    @objc private func closeButtonTapped() {
        closeButtonAction?() // Call the closure when button is tapped
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil // Reset text
        closeButtonAction = nil // Reset closure
        //Cancel observation
    }
}

// MARK: - Extensions (Optional - for cleaner code)
// You can further organize your code by creating extensions for specific
// functionalities. This improves readability and maintainability.

// Example: Extension for URL loading related methods
private extension BrowserViewModel {
    func loadURLRequest(_ request: URLRequest, in tab: Tab) {
        tab.webView.load(request)
    }
}
