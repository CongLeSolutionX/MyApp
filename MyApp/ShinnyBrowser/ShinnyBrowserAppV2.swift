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
@preconcurrency import WebKit
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
    func didUpdateProgress(_ progress: Double, in tab: Tab)
    func didUpdateLoadingState(_ isLoading: Bool, in tab: Tab)
}

// MARK: - Tab

class Tab {
    let id = UUID() // Unique identifier for each tab
    let webView: WKWebView
    var cancellables: Set<AnyCancellable> = []
    @Published var url: URL?
    @Published var title: String?
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var estimatedProgress: Double = 0.0
    @Published var isLoading: Bool = false
    var contentModeToRequestForHost: [String: WKWebpagePreferences.ContentMode] = [:] // Per-tab content mode
    var currentContentMode: WKWebpagePreferences.ContentMode = .recommended

    init(webView: WKWebView) {
        self.webView = webView

        // Set up Combine bindings
        setupBindings()
    }

    private func setupBindings() {
        // Observe webView properties and assign to @Published properties
        webView.publisher(for: \.url)
            .assign(to: \.url, on: self)
            .store(in: &cancellables)

        webView.publisher(for: \.canGoBack)
            .assign(to: \.canGoBack, on: self)
            .store(in: &cancellables)

        webView.publisher(for: \.canGoForward)
            .assign(to: \.canGoForward, on: self)
            .store(in: &cancellables)

        webView.publisher(for: \.title)
            .assign(to: \.title, on: self)
            .store(in: &cancellables)

        webView.publisher(for: \.estimatedProgress)
            .assign(to: \.estimatedProgress, on: self)
            .store(in: &cancellables)

        webView.publisher(for: \.isLoading)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }
}

// MARK: - ViewModel

class BrowserViewModel {
    // MARK: - Properties
    @Published var tabs: [Tab] = []
    @Published var currentTabIndex: Int = 0

    var cancellables: Set<AnyCancellable> = []
    weak var delegate: BrowserViewDelegate?

    private let urlKey = "LastCommittedURLString" // UserDefaults key

    // MARK: - Initializers

    init() {
        setupBindings()
    }

    // MARK: - Bindings

    private func setupBindings() {
        $currentTabIndex
            .sink { [weak self] index in
                self?.updateUIForCurrentTab()
            }
            .store(in: &cancellables)
    }

    private func updateUIForCurrentTab() {
        guard let tab = currentTab else { return }
        // Update delegate with current tab's state
        delegate?.didUpdateLoadingState(tab.isLoading, in: tab)
        delegate?.didUpdateProgress(tab.estimatedProgress, in: tab)
    }

    var currentTab: Tab? {
        guard tabs.indices.contains(currentTabIndex) else { return nil }
        return tabs[currentTabIndex]
    }

    // MARK: - Public Methods

    func loadURL(string: String, in tab: Tab) {
        guard let url = validatedURL(from: string) else {
            // Handle invalid URL (e.g., perform a search)
            let searchQuery = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let searchURLString = "https://www.google.com/search?q=\(searchQuery)"
            if let searchURL = URL(string: searchURLString) {
                tab.webView.load(URLRequest(url: searchURL))
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
        guard let url = tab.webView.url, let host = url.host else { return }

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

        // Observe tab properties
        newTab.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.delegate?.didUpdateLoadingState(isLoading, in: newTab)
            }
            .store(in: &newTab.cancellables)

        newTab.$estimatedProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.delegate?.didUpdateProgress(progress, in: newTab)
            }
            .store(in: &newTab.cancellables)

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

        let tabToRemove = tabs[index]
        tabToRemove.webView.stopLoading()

        // Cancel subscriptions
        tabToRemove.cancellables.forEach { $0.cancel() }
        tabToRemove.cancellables.removeAll()

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
        delegate?.didRequestSwitchTab(to: index) // Notify the delegate
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

    // MARK: - WebView Delegate Forwarding

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void, in tab: Tab) {
        let preferences = WKWebpagePreferences()
        if #available(iOS 14.0, *) {
            if let host = navigationAction.request.url?.host,
               let requestedMode = tab.contentModeToRequestForHost[host] {
                preferences.preferredContentMode = requestedMode
                tab.currentContentMode = requestedMode // Update current mode
            } else {
                preferences.preferredContentMode = tab.currentContentMode // Use the current mode.
            }
        }
        decisionHandler(.allow, preferences)
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
            webViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Progress Bar (anchored to top of webViewContainer)
            progressBar.topAnchor.constraint(equalTo: tabCollectionView.bottomAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBarWidthConstraint,
            progressBar.heightAnchor.constraint(equalToConstant: 2),
        ])
    }

    private func setupBindings() {
        // Bindings for current tab
        viewModel.$currentTabIndex
            .sink { [weak self] _ in
                self?.displayCurrentTab()
            }
            .store(in: &viewModel.cancellables)
    }

    // MARK: - Tab Management

    private func displayCurrentTab() {
        // Remove the previously displayed WKWebView (if any)
        currentWebView?.removeFromSuperview()
        currentWebView = nil

        guard let currentTab = viewModel.currentTab else {
            return // No tab to display
        }
        let webView = currentTab.webView

        // Set navigation delegate
        webView.navigationDelegate = self

        // Add the new WKWebView to the container
        webViewContainer.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor),
            webView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor),
        ])

        currentWebView = webView // Keep track of the current WKWebView

        // Update UI elements based on current Tab
        urlField.text = currentTab.url?.absoluteString ?? ""
        backButton.isEnabled = currentTab.canGoBack
        forwardButton.isEnabled = currentTab.canGoForward
        updateProgressBar(progress: currentTab.estimatedProgress)
        progressBar.isHidden = !currentTab.isLoading

        tabCollectionView.reloadData() // Refresh tab UI
        tabCollectionView.selectItem(at: IndexPath(item: viewModel.currentTabIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }

    // MARK: - Actions

    @objc private func addNewTab() {
        viewModel.addTab()
    }

    @objc private func goBack() {
        guard let currentTab = viewModel.currentTab else { return }
        viewModel.goBack(in: currentTab)
    }

    @objc private func goForward() {
        guard let currentTab = viewModel.currentTab else { return }
        viewModel.goForward(in: currentTab)
    }

    @objc private func reload() {
        guard let currentTab = viewModel.currentTab else { return }
        viewModel.reload(in: currentTab)
    }

    @objc private func showMore() {
        guard let currentTab = viewModel.currentTab else { return }

        let shareAction = UIAlertAction(title: "Share", style: .default) { [weak self] _ in
            self?.viewModel.shareCurrentPage(in: currentTab)
        }
        let addToFavoritesAction = UIAlertAction(title: "Add to Favorites", style: .default) { [weak self] _ in
            self?.viewModel.addToFavorites(in: currentTab)
        }
        let loadStartPageAction = UIAlertAction(title: "Load Start Page", style: .default) { [weak self] _ in
            self?.viewModel.loadStartPage(in: currentTab)
        }
        let toggleContentAction = UIAlertAction(title: "Toggle Content Mode", style: .default) { [weak self] _ in
            self?.viewModel.toggleContentMode(in: currentTab)
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
        }

        present(alertController, animated: true)
    }

    // MARK: - Progress Bar

    private func updateProgressBar(progress: Double) {
        progressBarWidthConstraint.constant = view.frame.width * CGFloat(progress)
        progressBar.isHidden = progress >= 1.0 || progress <= 0.0
    }
}

// MARK: - UITextFieldDelegate

extension ShinnyBrowserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let currentTab = viewModel.currentTab, let text = textField.text else {
            textField.resignFirstResponder()
            return true
        }
        viewModel.loadURL(string: text, in: currentTab)
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - WKNavigationDelegate

extension ShinnyBrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // No action needed; Tab class handles updating properties through Combine
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let currentTab = viewModel.currentTab else {
            decisionHandler(.allow)
            return
        }
        viewModel.webView(webView, decidePolicyFor: navigationAction, decisionHandler: { policy, _ in
            decisionHandler(policy)
        }, in: currentTab)
    }
}

// MARK: - BrowserViewDelegate

extension ShinnyBrowserViewController: BrowserViewDelegate {
    func didUpdateLoadingState(_ isLoading: Bool, in tab: Tab) {
        if viewModel.currentTab?.id == tab.id {
            progressBar.isHidden = !isLoading
        }
    }

    func didUpdateProgress(_ progress: Double, in tab: Tab) {
        if viewModel.currentTab?.id == tab.id {
            updateProgressBar(progress: progress)
        }
    }

    func didRequestToggleContentMode(for url: URL, newMode: WKWebpagePreferences.ContentMode, in tab: Tab) {
        print("Requested content mode \(newMode) for \(url.absoluteString) in tab \(tab.id)")
    }

    func didTapBackButton(in tab: Tab) {
        // Handle back button UI update if needed
    }

    func didTapForwardButton(in tab: Tab) {
        // Handle forward button UI update if needed
    }

    func didTapReloadButton(in tab: Tab) {
        // Handle reload button UI update if needed
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
        let isSelected = indexPath.item == viewModel.currentTabIndex
        cell.configure(with: tab, isSelected: isSelected)

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
    var cancellable: AnyCancellable?

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

        // Subscribe to title updates
        cancellable = tab.$title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newTitle in
                self?.titleLabel.text = newTitle ?? "New Tab"
            }
    }

    @objc private func closeButtonTapped() {
        closeButtonAction?() // Call the closure when button is tapped
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil // Reset text
        closeButtonAction = nil // Reset closure
        cancellable?.cancel()
        cancellable = nil
    }
}

// MARK: - Extensions

extension ShinnyBrowserViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Script message received: \(message.name)")
    }
}
