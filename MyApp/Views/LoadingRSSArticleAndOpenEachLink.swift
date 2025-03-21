//
//  FullRSSAndWebViewImplementation.swift
//  MyApp
//
//  Created by Cong Le on 3/20/25.
//

//

import SwiftUI
@preconcurrency import WebKit
import UIKit

// MARK: - Data Model

struct RSSItem: Identifiable {
    let id = UUID()
    var title: String
    var link: String
    var pubDate: Date?
    var itemDescription: String
    var imageURL: String?
}

// MARK: - RSS Parser

final class RSSParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var currentTitle = ""
    private var currentLink = ""
    private var currentPubDate = ""
    private var currentDescription = ""
    private var currentImageURL = ""
    
    private var items: [RSSItem] = []
    private var inItem = false
    private var inImage = false
    private var parseError: Error?
    
    private static let dateFormats: [String] = [
        "EEE, dd MMM yyyy HH:mm:ss Z",
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
        "yyyy-MM-dd'T'HH:mm:ssZ"
    ]
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    func parse(data: Data) -> (items: [RSSItem], error: Error?) {
        items = []
        parseError = nil
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return (items, parseError)
    }
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        if elementName == "item" {
            inItem = true
            currentTitle = ""
            currentLink = ""
            currentPubDate = ""
            currentDescription = ""
            currentImageURL = ""
        }
        // Handle image elements
        if inItem, ["media:content", "enclosure", "image"].contains(elementName) {
            let key = (elementName == "image") ? "href" : "url"
            if let urlString = attributeDict[key] {
                if elementName == "enclosure", let type = attributeDict["type"], !type.hasPrefix("image") {
                    // Skip non-image enclosure
                } else {
                    currentImageURL = urlString
                    inImage = true
                }
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard inItem else { return }
        switch currentElement {
        case "title":       currentTitle += string
        case "link":        currentLink += string
        case "pubDate":     currentPubDate += string
        case "description": currentDescription += string
        default: break
        }
    }
    
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        if elementName == "item" {
            inItem = false
            let trimmedPubDate = currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines)
            var parsedDate: Date?
            for format in RSSParser.dateFormats {
                RSSParser.dateFormatter.dateFormat = format
                if let date = RSSParser.dateFormatter.date(from: trimmedPubDate) {
                    parsedDate = date
                    break
                }
            }
            let newItem = RSSItem(
                title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                link: currentLink.trimmingCharacters(in: .whitespacesAndNewlines),
                pubDate: parsedDate,
                itemDescription: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                imageURL: currentImageURL.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            items.append(newItem)
        }
        
        if ["media:content", "enclosure", "image"].contains(elementName) {
            inImage = false
        }
        currentElement = ""
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
        print("Parse error occurred: \(parseError)")
    }
    
    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        self.parseError = validationError
        print("Validation error occurred: \(validationError)")
    }
}

// MARK: - View Model

class RSSViewModel: ObservableObject {
    @Published var rssItems: [RSSItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let parser = RSSParser()
    
    func loadRSS(urlString: String = "https://www.law360.com/ip/rss") {
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            defer {
                DispatchQueue.main.async { self?.isLoading = false }
            }
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Error fetching RSS feed: \(error.localizedDescription)"
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    self?.errorMessage = "HTTP Error: \(httpResponse.statusCode)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { self?.errorMessage = "No data received" }
                return
            }
            
            let (parsedItems, parseError) = self?.parser.parse(data: data) ?? ([], nil)
            DispatchQueue.main.async {
                if let parseError = parseError {
                    self?.errorMessage = "Error parsing RSS: \(parseError.localizedDescription)"
                } else {
                    self?.rssItems = parsedItems
                    print(parsedItems)
                }
            }
        }.resume()
    }
}

// MARK: - Global Date Formatter

private let displayDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

// MARK: - SwiftUI Views

struct RSSAsyncImage: View {
    let urlString: String?
    let isCompact: Bool
    
    var body: some View {
        if let urlString = urlString,
           let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
                case .success(let image):
                    image.resizable().scaledToFill()
                        .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
                        .clipped()
                case .failure:
                    defaultPlaceholder
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            defaultPlaceholder
        }
    }
    
    private var defaultPlaceholder: some View {
        Image(systemName: "photo.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, minHeight: isCompact ? 100 : 200)
            .background(Color.secondary.opacity(0.3))
    }
}

struct TopicTag: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.purple.opacity(0.5))
            .cornerRadius(20)
    }
}

struct TabBarButton: View {
    let iconName: String
    let label: String
    var isActive: Bool = false
    var body: some View {
        Button(action: {}) {
            VStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(isActive ? .pink : .gray)
                Text(label)
                    .font(.caption)
                    .foregroundColor(isActive ? .pink : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct RSSItemView: View {
    let item: RSSItem
    var isCompact: Bool
    var showImage = true
    
    var body: some View {
        NavigationLink(destination: WebViewControllerWrapper(urlString: item.link)) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading) {
                    if showImage {
                        RSSAsyncImage(urlString: item.imageURL, isCompact: isCompact)
                    }
                    if !isCompact {
                        Text(item.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 2)
                    }
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                        if let pubDate = item.pubDate {
                            Text(displayDateFormatter.string(from: pubDate))
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                            Text("No date available")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 1)
                    Text(item.itemDescription)
                        .font(isCompact ? .caption : .body)
                        .foregroundColor(.gray)
                        .lineLimit(isCompact ? 2 : 4)
                        .padding(.top, isCompact ? 1 : 2)
                    if !isCompact {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                TopicTag(title: "Law")
                                TopicTag(title: "IP")
                                TopicTag(title: "Legal")
                                Button(action: {}) {
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 25).fill(Color.black))
                
                Button(action: {}) {
                    Image(systemName: "bookmark")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .padding(10)
            }
            .padding(.horizontal)
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct ForYouView: View {
    @State private var searchText = ""
    @State private var isCompactView = false
    @StateObject private var rssViewModel = RSSViewModel()
    @State private var isShowingAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        headerView
                        filterBar
                        updatesNotification
                        rssContentView
                    }
                    .padding(.top)
                }
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .navigationBarHidden(true)
                .alert(isPresented: $isShowingAlert) {
                    Alert(title: Text("Error"),
                          message: Text(rssViewModel.errorMessage ?? "Unknown error"),
                          dismissButton: .default(Text("OK")))
                }
                if rssViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            VStack {
                Spacer()
                HStack {
                    TabBarButton(iconName: "waveform.path.ecg", label: "For you", isActive: true)
                    TabBarButton(iconName: "book", label: "Episodes")
                    TabBarButton(iconName: "bookmark", label: "Saved")
                    TabBarButton(iconName: "number", label: "Interests")
                }
                .padding()
                .background(Color.black)
                .frame(maxWidth: .infinity)
                .border(Color.gray.opacity(0.3), width: 1)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear { rssViewModel.loadRSS() }
        .onChange(of: rssViewModel.errorMessage) { _, newValue in
            isShowingAlert = newValue != nil
        }
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            Text("For You")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            Image(systemName: "person.circle")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }
    
    private var filterBar: some View {
        HStack {
            Button(action: {
                rssViewModel.rssItems.sort {
                    ($0.pubDate ?? Date.distantPast) > ($1.pubDate ?? Date.distantPast)
                }
            }) {
                HStack {
                    Text("Newest first")
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(20)
            Spacer()
            Button(action: { isCompactView.toggle() }) {
                Image(systemName: isCompactView ? "rectangle.grid.1x2.fill" : "rectangle.grid.1x2")
            }
            .foregroundColor(.gray)
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }
    
    private var updatesNotification: some View {
        HStack {
            Image(systemName: "3.circle.fill")
                .foregroundColor(.red)
            Text("updates since you last visit")
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            Button(action: {}) {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }
    
    private var rssContentView: some View {
        Group {
            if let errorMessage = rssViewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ForEach(rssViewModel.rssItems) { item in
                    RSSItemView(item: item, isCompact: isCompactView)
                }
            }
        }
    }
}

// MARK: - Web View Controller (UIKit Implementation)

class AnotherCustomWebViewController: UIViewController, WKUIDelegate {
    lazy var webView: WKWebView! = {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        let wv = WKWebView(frame: .zero, configuration: configuration)
        wv.navigationDelegate = self
        wv.uiDelegate = self
        return wv
    }()
    lazy var progressView: UIProgressView! = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.trackTintColor = .clear
        pv.progressTintColor = .systemBlue
        return pv
    }()
    
    lazy var toolbar: UIToolbar! = {
        let tb = UIToolbar()
        tb.isTranslucent = false
        tb.barStyle = .default
        return tb
    }()
    
    lazy var backButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
        btn.isEnabled = false
        return btn
    }()
    
    lazy var forwardButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(
            image: UIImage(systemName: "arrow.right"),
            style: .plain,
            target: self,
            action: #selector(goForward)
        )
        btn.isEnabled = false
        return btn
    }()
    
    lazy var reloadButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(reloadPage)
        )
        return btn
    }()
    
    lazy var shareButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareTapped)
        )
        return btn
    }()
    
    lazy var openInSafariButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(
            image: UIImage(systemName: "safari"),
            style: .plain,
            target: self,
            action: #selector(openInSafariTapped)
        )
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Load initial content (this could be an initial URL or simply a fallback)
        loadInitialContent()
        setupObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.bounds.width,
            height: view.bounds.height - view.safeAreaInsets.top - toolbar.frame.size.height
        )
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        setupNavigationBar()
        setupWebView()
        setupToolbar()
        setupProgressView()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        navigationItem.title = "Loading..."
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(menuTapped)
        )
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        let contentController = WKUserContentController()
        configuration.userContentController = contentController
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        view.addSubview(webView)
    }
    
    private func setupToolbar() {
        toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        toolbar.items = [
            backButton,
            .flexibleSpace(),
            forwardButton,
            .flexibleSpace(),
            reloadButton,
            .flexibleSpace(),
            shareButton,
            .flexibleSpace(),
            openInSafariButton
        ]
    }
    
    private func setupProgressView() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0.0
        progressView.isHidden = true
        view.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Content Loading
    
    private func loadInitialContent() {
        // Initial content can be a default URL. Here, we use a placeholder URL.
        loadRemoteURL(urlString: "https://www.google.com")
    }
    
    func loadURL(urlString: String) {
        // Dynamically load the given URL (i.e. from an RSS article)
        loadRemoteURL(urlString: urlString)
    }
    
    private func loadRemoteURL(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func menuTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Open in Safari", style: .default, handler: { _ in self.openInSafari() }))
        actionSheet.addAction(UIAlertAction(title: "Copy URL", style: .default, handler: { _ in
            if let urlString = self.webView.url?.absoluteString {
                UIPasteboard.general.string = urlString
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(actionSheet, animated: true)
    }
    
    @objc private func goBack() {
        if webView.canGoBack { webView.goBack() }
    }
    
    @objc private func goForward() {
        if webView.canGoForward { webView.goForward() }
    }
    
    @objc private func reloadPage() {
        webView.reload()
    }
    
    @objc private func openInSafariTapped() {
        openInSafari()
    }
    
    @objc private func shareTapped() {
        guard let url = webView.url else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.barButtonItem = shareButton
        }
        present(activityVC, animated: true)
    }
    
    private func openInSafari() {
        if let url = webView.url {
            UIApplication.shared.open(url)
        }
    }
    
    func injectJavaScript(script: String) {
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                print("JavaScript Injection Error: \(error)")
            } else {
                print("JavaScript executed. Result: \(result ?? "No Result")")
            }
        }
    }
    
    private func setupObservers() {
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            progressView.progress = Float(webView.estimatedProgress)
            progressView.isHidden = (webView.estimatedProgress >= 1.0)
        } else if keyPath == #keyPath(WKWebView.title) {
            navigationItem.title = webView.title
        } else if keyPath == #keyPath(WKWebView.canGoBack) {
            backButton.isEnabled = webView.canGoBack
        } else if keyPath == #keyPath(WKWebView.canGoForward) {
            forwardButton.isEnabled = webView.canGoForward
        }
    }
    
    deinit {
        if webView != nil {
            webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
            webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
            webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
            webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward))
        }
    }
}

extension AnotherCustomWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        if message.name == "jsHandler" {
            print("Received message from JS: \(message.body)")
        }
    }
}

extension AnotherCustomWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Example: Block navigation to a specific host if needed.
        if let host = navigationAction.request.url?.host, host.contains("example.com") {
            print("Navigation to example.com blocked.")
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Page loading started")
        progressView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Page loading finished")
    }
    
    func webView(_ webView: WKWebView,
                 didFail navigation: WKNavigation!,
                 withError error: Error) {
        print("Page loading failed: \(error)")
        progressView.isHidden = true
    }
    
    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        print("Provisional navigation failed: \(error)")
        progressView.isHidden = true
    }
}

// MARK: - SwiftUI Wrapper for WebViewController

struct WebViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = AnotherCustomWebViewController
    var urlString: String
    
    func makeUIViewController(context: Context) -> AnotherCustomWebViewController {
        let controller = AnotherCustomWebViewController()
        // Load the article URL dynamically when the view is created.
        controller.loadURL(urlString: urlString)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AnotherCustomWebViewController, context: Context) {
        // No dynamic updates are required here.
    }
}

// MARK: - Preview

struct CombinedView_Previews: PreviewProvider {
    static var previews: some View {
        ForYouView()
            .preferredColorScheme(.dark)
    }
}
