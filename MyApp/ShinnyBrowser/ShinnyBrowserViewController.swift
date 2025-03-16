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
    func didRequestShowHistory()
    func didFailToLoadURL(with input: String)
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
    @Published var history: [HistoryItem] = []
    
    private var contentModeToRequestForHost: [String: WKWebpagePreferences.ContentMode] = [:]
    var cancellables: Set<AnyCancellable> = []
    weak var delegate: BrowserViewDelegate?
    
    private let urlKey = "LastCommittedURLString"
    private let historyKey = "BrowserHistory"
    
    private var webView: WKWebView
    
    // MARK: - Initializers
    
    init(webView: WKWebView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())) {
        self.webView = webView
        
        // Configure WKWebView before initialization
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = "Version/17.2 Safari/605.1.15"
        configuration.allowsInlineMediaPlayback = true
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        
        if #available(iOS 14.0, *) {
            let webpagePreferences = WKWebpagePreferences()
            webpagePreferences.preferredContentMode = .recommended
            configuration.defaultWebpagePreferences = webpagePreferences
        }
        
        // Reinitialize webView with the configured configuration
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        
        setupBindings()
        loadHistory()
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
        
        webView.publisher(for: \.title)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                // Optionally handle title updates
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods (Actions from View)
    
    func loadURL(string: String) {
        guard let url = validatedURL(from: string) else {
            delegate?.didFailToLoadURL(with: string)
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
        guard let url = webView.url, let host = url.host else { return }
        
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
        delegate?.didRequestShowHistory()
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
            if let host = navigationAction.request.url?.host,
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

struct HistoryItem: Codable, Identifiable, Equatable {
    var id = UUID()
    let url: URL
    let title: String
    let visitDate: Date = Date()
    
    static func == (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
        return lhs.url == rhs.url
    }
}

// MARK: - Extensions

extension String {
    func toValidURL() -> URL? {
        var text = self.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let url = URL(string: text), url.scheme != nil {
            return url
        }
        
        if !text.lowercased().hasPrefix("http://") && !text.lowercased().hasPrefix("https://") {
            text = "https://" + text
        }
        
        return URL(string: text)
    }
}

// MARK: - ShinnyBrowserViewController

class ShinnyBrowserViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        button.isEnabled = false
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }()
    
    private lazy var forwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "arrow.forward"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        button.isEnabled = false
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
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
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return textField
    }()
    
    private lazy var refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let refreshImage = UIImage(systemName: "arrow.clockwise")
        button.setImage(refreshImage, for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(reload), for: .touchUpInside)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }()
    
    private lazy var showHistoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "clock"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(showHistoryTapped), for: .touchUpInside)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }()
    
    private lazy var webViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.isHidden = true
        return progress
    }()
    
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
        
        // Toolbar for bottom buttons
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let backButtonItem = UIBarButtonItem(customView: backButton)
        let forwardButtonItem = UIBarButtonItem(customView: forwardButton)
        let shareButtonItem = UIBarButtonItem(customView: shareButton)
        let refreshButtonItem = UIBarButtonItem(customView: refreshButton)
        let historyButtonItem = UIBarButtonItem(customView: showHistoryButton)
        
        toolbar.items = [backButtonItem, flexibleSpace, forwardButtonItem, flexibleSpace, shareButtonItem, flexibleSpace, refreshButtonItem, flexibleSpace, historyButtonItem]
        
        view.addSubview(urlView)
        urlView.addSubview(urlField)
        view.addSubview(webViewContainer)
        webViewContainer.addSubview(webView)
        view.addSubview(progressView)
        
        // Bind UI elements to the ViewModel
        viewModel.$urlString
                  .receive(on: RunLoop.main)
                  .sink { [weak self] newURLString in
                      self?.urlField.text = newURLString
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
            .assign(to: \.isHidden, on: progressView)
            .store(in: &viewModel.cancellables)
    }
    
    // MARK: - Constraints Setup
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // URL View
            urlView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            urlView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            urlView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            urlView.heightAnchor.constraint(equalToConstant: 44),
            
            // URL Field
            urlField.leadingAnchor.constraint(equalTo: urlView.leadingAnchor, constant: 8),
            urlField.trailingAnchor.constraint(equalTo: urlView.trailingAnchor, constant: -8),
            urlField.topAnchor.constraint(equalTo: urlView.topAnchor, constant: 4),
            urlField.bottomAnchor.constraint(equalTo: urlView.bottomAnchor, constant: -4),
            
            // Web View Container
            webViewContainer.topAnchor.constraint(equalTo: urlView.bottomAnchor),
            webViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webViewContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44),
            
            // WebView
            webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor),
            webView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor),
            
            // Progress View
            progressView.topAnchor.constraint(equalTo: urlView.bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2),
            
            // Toolbar
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    // MARK: - Progress Bar
    
    private func updateProgressBar(progress: Double) {
        progressView.progress = Float(progress)
        progressView.isHidden = progress >= 1.0
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
    
    @objc private func shareTapped() {
        viewModel.shareCurrentPage()
    }
    
    @objc private func showHistoryTapped() {
        viewModel.showHistory()
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
        guard let urlString = textField.text?.toValidURL()?.absoluteString else {
            return
        }
        
        if webView.url?.absoluteString == urlString {
            return
        }
        
        viewModel.loadURL(string: urlString)
    }
}

// MARK: - WKNavigationDelegate

extension ShinnyBrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        viewModel.webView(webView, didCommit: navigation)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
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
        // Additional actions if needed
    }
    
    func didTapForwardButton() {
        // Additional actions if needed
    }
    
    func didTapReloadButton() {
        // Additional actions if needed
    }
    
    func didRequestShare(for url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(activityViewController, animated: true)
    }
    
    func didRequestAddToFavorites(for url: URL) {
        print("Add to Favorites: \(url.absoluteString)")
        // Implement actual favorite addition logic here
    }
    
    func didRequestShowHistory() {
        let historyVC = HistoryViewController(history: viewModel.history) { [weak self] selectedURL in
            self?.viewModel.loadURL(string: selectedURL.absoluteString)
            historyVC.dismiss(animated: true, completion: nil)
        }
        
        historyVC.onClearHistory = { [weak self] in
            self?.viewModel.clearHistory()
        }
        
        let navController = UINavigationController(rootViewController: historyVC)
        present(navController, animated: true, completion: nil)
    }
    
    func didFailToLoadURL(with input: String) {
        let alert = UIAlertController(title: "Invalid URL", message: "The URL \"\(input)\" is invalid. Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - HistoryViewController

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let history: [HistoryItem]
    private let onSelection: (URL) -> Void
    var onClearHistory: (() -> Void)?
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.register(HistoryTableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        return table
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
        title = "History"
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        // Add a "Clear All" button to the navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearHistoryTapped))
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func clearHistoryTapped() {
        let alert = UIAlertController(title: "Clear History", message: "Are you sure you want to clear your browsing history?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { [weak self] _ in
            self?.onClearHistory?()
            self?.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return history.isEmpty ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryTableViewCell else {
            return UITableViewCell()
        }
        let item = history[indexPath.row]
        cell.configure(with: item)
        cell.delegate = self
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedURL = history[indexPath.row].url
        onSelection(selectedURL)
    }
    
    // Enable swipe-to-delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            onClearHistory?()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - HistoryTableViewCellDelegate

protocol HistoryTableViewCellDelegate: AnyObject {
    func historyTableViewCellDidRequestDelete(_ cell: HistoryTableViewCell)
}

// MARK: - HistoryTableViewCell

class HistoryTableViewCell: UITableViewCell {
    
    weak var delegate: HistoryTableViewCellDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 2
        return label
    }()
    
    private let urlLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textColor = .gray
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .systemRed
        button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return button
    }()
    
    // Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Setup UI
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(urlLabel)
        contentView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            
            // URL Label
            urlLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            urlLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            urlLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            urlLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Delete Button
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // Configure Cell
    func configure(with item: HistoryItem) {
        titleLabel.text = item.title
        urlLabel.text = item.url.absoluteString
    }
    
    // Delete Action
    @objc private func deleteTapped() {
        delegate?.historyTableViewCellDidRequestDelete(self)
    }
}

// MARK: - HistoryViewController Extension

extension HistoryViewController: HistoryTableViewCellDelegate {
    func historyTableViewCellDidRequestDelete(_ cell: HistoryTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        onClearHistory?()
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
