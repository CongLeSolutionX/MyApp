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
import CoreData

// MARK: - Protocols

protocol BrowserViewDelegate: AnyObject {
    func didTapBackButton()
    func didTapForwardButton()
    func didTapReloadButton()
    func didRequestShare(for url: URL)
    func didRequestAddToFavorites(for url: URL)
    func didRequestToggleContentMode(for url: URL, newMode: WKWebpagePreferences.ContentMode)
    func didRequestShowHistory() // New: Request to show history
}

// MARK: - HistoryEntry (Core Data)

//  HistoryEntry is now a Core Data managed object.
class HistoryEntry: NSManagedObject {
    @NSManaged var url: String
    @NSManaged var title: String? // Optional title
    @NSManaged var timestamp: Date
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
    @Published var history: [HistoryEntry] = [] // History entries
    
    private var contentModeToRequestForHost: [String: WKWebpagePreferences.ContentMode] = [:]
    var cancellables: Set<AnyCancellable> = []
    weak var delegate: BrowserViewDelegate?
    
    private let urlKey = "LastCommittedURLString" // UserDefaults key
    
    private let webView: WKWebView
    
    // Core Data context
    let managedObjectContext: NSManagedObjectContext
    
    // MARK: - Initializers
    
    init(webView: WKWebView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration()), managedObjectContext: NSManagedObjectContext) {
        self.webView = webView
        self.managedObjectContext = managedObjectContext
        
        // Configure WKWebView (once, in init)
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
        // Observe WKWebView properties and update @Published properties.
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
    
    func showHistory() {
        delegate?.didRequestShowHistory()
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
    
    func addHistoryEntry(url: URL, title: String?) {
        let newEntry = HistoryEntry(context: managedObjectContext)
        newEntry.url = url.absoluteString
        newEntry.title = title ?? url.host  // Use URL host as default title
        newEntry.timestamp = Date()
        
        history.append(newEntry)
        saveHistory()
    }
    
    private func saveHistory() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to save history: \(error)")
        }
    }
    
    private func loadHistory() {
        let fetchRequest = HistoryEntry.fetchRequest() // Use the static method
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            history = try managedObjectContext.fetch(fetchRequest)
        } catch {
            print("Failed to load history: \(error)")
            history = []
        }
    }
    
    func clearHistory() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = HistoryEntry.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedObjectContext.execute(deleteRequest)
            history = [] // Clear the in-memory array
            saveHistory() // Persist the deletion
        } catch {
            print("Failed to clear history: \(error)")
        }
    }
    
    // MARK: - WebView Delegate Forwarding
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let urlString = webView.url?.absoluteString {
            UserDefaults.standard.set(urlString, forKey: urlKey)
        }
        
        // Add history entry *after* successful navigation.
        if let url = webView.url {
            addHistoryEntry(url: url, title: webView.title) // Capture the title
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

// MARK: - ShinnyBrowserViewController

class ShinnyBrowserViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var forwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        button.isEnabled = false
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
    
    private lazy var viewModel: BrowserViewModel = {
        // Pass the managed object context from the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let vm = BrowserViewModel(webView: webView, managedObjectContext: context)
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
        view.addSubview(urlView)
        urlView.addSubview(backButton)
        urlView.addSubview(forwardButton)
        urlView.addSubview(urlField)
        urlView.addSubview(refreshButton)
        urlView.addSubview(showMoreButton)
        view.addSubview(webViewContainer)
        webViewContainer.addSubview(webView)
        view.addSubview(progressBar)
        
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
            .assign(to: \.isHidden, on: progressBar)
            .store(in: &viewModel.cancellables)
    }
    
    // MARK: - Constraints Setup
    
    private func setupConstraints() {
        progressBarWidthConstraint = progressBar.widthAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            urlView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            urlView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            urlView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            urlView.heightAnchor.constraint(equalToConstant: 44),
            
            backButton.leadingAnchor.constraint(equalTo: urlView.leadingAnchor, constant: 8),
            backButton.centerYAnchor.constraint(equalTo: urlView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            forwardButton.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            forwardButton.centerYAnchor.constraint(equalTo: urlView.centerYAnchor),
            forwardButton.widthAnchor.constraint(equalToConstant: 44),
            forwardButton.heightAnchor.constraint(equalToConstant: 44),
            
            urlField.leadingAnchor.constraint(equalTo: forwardButton.trailingAnchor, constant: 8),
            urlField.centerYAnchor.constraint(equalTo: urlView.centerYAnchor),
            urlField.trailingAnchor.constraint(equalTo: refreshButton.leadingAnchor, constant: -8),
            
            refreshButton.trailingAnchor.constraint(equalTo: showMoreButton.leadingAnchor, constant: -8),
            refreshButton.centerYAnchor.constraint(equalTo: urlView.centerYAnchor),
            refreshButton.widthAnchor.constraint(equalToConstant: 44),
            refreshButton.heightAnchor.constraint(equalToConstant: 44),
            
            showMoreButton.trailingAnchor.constraint(equalTo: urlView.trailingAnchor, constant: -8),
            showMoreButton.centerYAnchor.constraint(equalTo: urlView.centerYAnchor),
            showMoreButton.widthAnchor.constraint(equalToConstant: 44),
            showMoreButton.heightAnchor.constraint(equalToConstant: 44),
            
            webViewContainer.topAnchor.constraint(equalTo: urlView.bottomAnchor),
            webViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webViewContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor),
            webView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor),
            
            progressBar.topAnchor.constraint(equalTo: urlView.bottomAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBarWidthConstraint,
            progressBar.heightAnchor.constraint(equalToConstant: 2),
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
        
        // History action
        let showHistoryAction = UIAlertAction(title: "Show History", style: .default) { [weak self] _ in
            self?.viewModel.showHistory()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(shareAction)
        alertController.addAction(addToFavoritesAction)
        alertController.addAction(loadStartPageAction)
        alertController.addAction(toggleContentAction)
        alertController.addAction(showHistoryAction) // Add history action
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
        //Update UI for back button
    }
    
    func didTapForwardButton() {
        //Update UI for forward button
    }
    
    func didTapReloadButton() {
        //Update UI for reload button
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
        print("Add to Favorites: \(url.absoluteString)") // Replace with saving logic
    }
    
    func didRequestShowHistory() {
        let historyVC = HistoryViewController(viewModel: viewModel)
        let navController = UINavigationController(rootViewController: historyVC) // Embed in navigation controller
        present(navController, animated: true)
    }
}


// MARK: - HistoryViewController

class HistoryViewController: UIViewController {
    
    private let viewModel: BrowserViewModel
    private var history: [HistoryEntry] = [] // Local copy for display
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell") // Register cell
        return tableView
    }()
    
    init(viewModel: BrowserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings() // Bind to ViewModel's history
        loadHistory()
        
        // Add a Clear History button to the navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearHistoryTapped))
        title = "Browsing History" // Set the title
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.$history
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedHistory in
                self?.history = updatedHistory // Update local copy
                self?.tableView.reloadData()
            }
            .store(in: &viewModel.cancellables)
    }
    
    private func loadHistory() {
        history = viewModel.history // Load initial history
        tableView.reloadData()
    }
    
    @objc private func clearHistoryTapped() {
        // Confirmation alert before clearing
        let alert = UIAlertController(title: "Clear History", message: "Are you sure you want to clear your browsing history?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { [weak self] _ in
            self?.viewModel.clearHistory()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        let entry = history[indexPath.row]
        cell.textLabel?.text = entry.title ?? entry.url // Display title or URL
        
        // Format and display the timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        cell.detailTextLabel?.text = dateFormatter.string(from: entry.timestamp)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = history[indexPath.row]
        if let url = URL(string: entry.url) {
            viewModel.loadURL(string: entry.url)  // Use the ViewModel to load
        }
        dismiss(animated: true) // Dismiss the history view
    }
}
