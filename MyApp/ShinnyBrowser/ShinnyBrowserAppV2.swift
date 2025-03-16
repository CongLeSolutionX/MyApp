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

// MARK: - ViewModel

class BrowserViewModel {

    // MARK: - Properties
    @Published var urlString: String = ""
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var estimatedProgress: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var currentContentMode: WKWebpagePreferences.ContentMode = .recommended

    private var contentModeToRequestForHost: [String: WKWebpagePreferences.ContentMode] = [:]
    var cancellables: Set<AnyCancellable> = []
    weak var delegate: BrowserViewDelegate?
    
    private let urlKey = "LastCommittedURLString" // UserDefaults key

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
            // Handle invalid URL
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
            // Handle missing start page
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

        return URL(string: text)
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
        // Save the last committed URL to UserDefaults and update urlString.
        if let urlString = webView.url?.absoluteString {
            UserDefaults.standard.set(urlString, forKey: urlKey)
            self.urlString = urlString  // Directly update the @Published property
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
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled {
            // Handle errors
            print("WebView failed to load: \(error.localizedDescription)")
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        if nsError.code != NSURLErrorCancelled {
            // Handle errors
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
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self // Important for WKNavigationDelegate methods
        setupUI()
        setupConstraints()
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

            //Bind UI elements to the ViewModel
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
        ])
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

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        // Add actions to the alert controller.
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(shareAction)
        alertController.addAction(addToFavoritesAction)
        alertController.addAction(loadStartPageAction)
        alertController.addAction(toggleContentAction)
        alertController.addAction(cancelAction)
        
        // iPad-specific presentation.
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = showMoreButton // Anchor to the button
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
        guard let enteredText = textField.text, !enteredText.isEmpty else {
            // If the field is empty, reset to current URL
            urlField.text = webView.url?.absoluteString ?? ""
            return
        }
        
        // Normalize URLs for comparison
        let enteredURL = viewModel.validatedURL(from: enteredText)
        let currentWebURL = webView.url

        // Compare the normalized URLs
        if enteredURL?.absoluteString != currentWebURL?.absoluteString {
            // Only load if the URLs are different
            viewModel.loadURL(string: enteredText)
        }
        // If URLs are the same, do nothing (avoid reload)
    }
}

// MARK: - WKNavigationDelegate

extension ShinnyBrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        viewModel.webView(webView, didCommit: navigation)
        urlField.text = webView.url?.absoluteString // Update the URL field here
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
        // Update UI or provide feedback to the user
        print("Requested content mode \(newMode) for \(url.absoluteString)")
    }
    
    func didTapBackButton() {
        //Update UI
    }
    
    func didTapForwardButton() {
        //Update UI
    }
    
    func didTapReloadButton() {
        //Update UI
    }
    
    func didRequestShare(for url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
           
        // For iPad, present as a popover.
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
           
        present(activityViewController, animated: true)
    }
    
    func didRequestAddToFavorites(for url: URL) {
        // Handle adding to favorites.
        print("Add to Favorites: \(url.absoluteString)") // Replace with actual saving logic
    }
}
