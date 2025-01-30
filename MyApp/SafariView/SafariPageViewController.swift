//
//  SafariPageViewController.swift
//  MyApp
//
//  Created by Cong Le on 1/29/25.
//


import UIKit

protocol SafariPageViewControllerNavigationDelegate: AnyObject {
    func safariPageViewControllerDidRequestToggle(_ safariPageViewController: SafariPageViewController)
}

class SafariPageViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var navigationDelegate: SafariPageViewControllerNavigationDelegate?

    private var safariViewControllers: [SafariViewController] = []
    private var currentIndex: Int = 0
    
    private let urlStrings = [
        "https://www.apple.com",
        "https://www.google.com",
        "https://www.github.com"
    ]
    
    // Toggle callback
    var toggleViewCallback: (() -> Void)?
    
    private lazy var pageViewController: UIPageViewController = {
        let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageVC.dataSource = self
        pageVC.delegate = self
        
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        return pageVC
    }()
    
    // MARK: - Initializers
    
    init(toggleViewCallback: (() -> Void)? = nil) {
        self.toggleViewCallback = toggleViewCallback
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        loadInitialPages()
        //configureNavigationBar()
        configureNavigationBarWithCoordinator()
    }
    
    private func setupPageViewController() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        pageViewController.didMove(toParent: self)
    }
    
    private func loadInitialPages() {
        safariViewControllers = urlStrings.enumerated().map { index, urlString in
            let safariWebVC = SafariViewController(urlString: urlString, pageIndex: index)
            return safariWebVC
        }
        if let firstViewController = safariViewControllers.first {
            pageViewController.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    //MARK: - Navbar config
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Toggle View", style: .plain, target: self, action: #selector(toggleViewButtonTapped)) // Set up the ToggleBarButton
    }
    
    //Add View toggle action
    @objc private func toggleViewButtonTapped() {
        printLog("[SafariPageViewController] toggleViewButtonTapped()")
        toggleViewCallback?() // invoking the callback method passed from the UIKitWrapper.
    }
    
    // MARK: - Navigation configuration for coordinator
    
    // Update navigation bar configuration
     private func configureNavigationBarWithCoordinator() {
         navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Toggle to SwiftUI View", style: .plain, target: self, action: #selector(toggleViewButtonTappedForCoordinator))
     }
    
    @objc private func toggleViewButtonTappedForCoordinator() {
          printLog("[SafariPageViewController] Toggle to SwiftUI View Button Tapped")
          navigationDelegate?.safariPageViewControllerDidRequestToggle(self)
      }
}

// MARK: - UIPageViewControllerDataSource
extension SafariPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let safariVC = viewController as? SafariViewController else { return nil }
        let index = safariVC.pageIndex
        let previousIndex = index - 1
        guard previousIndex >= 0 else { return nil }
        return safariViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let safariVC = viewController as? SafariViewController else { return nil }
        let index = safariVC.pageIndex
        let nextIndex = index + 1
        guard nextIndex < safariViewControllers.count else { return nil }
        return safariViewControllers[nextIndex]
    }
}

// MARK: - UIPageViewControllerDataSource
extension SafariPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if completed, let currentViewController = pageViewController.viewControllers?.first as? SafariViewController {
            currentIndex = currentViewController.pageIndex
            // Additional logic if needed
        }
    }
}
