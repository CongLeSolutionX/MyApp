//
//  MVVM_C_Demo.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//

import UIKit
import Combine // Often used with MVVM, but not strictly required for the pattern itself

// MARK: - Coordinator Protocol

// Defines the basic interface for all coordinators
protocol Coordinator: AnyObject {
    // Each coordinator has its own navigation controller (or sometimes a parent passes one down)
    var navigationController: UINavigationController { get set }
    // Stores child coordinators. A coordinator start other coordinators, e.g., for sub-flows.
    var childCoordinators: [Coordinator] { get set }
    
    // Method to kick off the coordinator's flow
    func start()
    
    // Optional: To inform a parent coordinator that a child flow has finished
    // Often used with a delegate pattern: `var parentCoordinator: ParentCoordinatorDelegate?`
    func didFinish() // This coordinator's own flow finished
    
    // Helper to remove child coordinators from the list when they finish
    func childDidFinish(_ child: Coordinator?)
}

// Default implementation for child cleanup
extension Coordinator {
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
    
    // Default didFinish (can be overridden)
    func didFinish() {
        // Default implementation does nothing, often overridden to notify parent
        print("\(type(of: self)) finished.")
    }
}

// MARK: - App Coordinator

// The main coordinator, responsible for setting up the initial view hierarchy and managing major application flows.
class AppCoordinator: Coordinator, AppCoordinatorDelegate {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    // Weak reference to the window to manage the root view controller
    // In SceneDelegate based apps, the window is readily available.
    private weak var window: UIWindow?

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController() // Create the main navigation stack
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    func start() {
        print("AppCoordinator starting...")
        // Decide initial flow (e.g., onboarding, auth, or main app)
        // For this example, directly start the main "List" flow.
        showListFlow()
    }
    
    func showListFlow() {
        // Create and start the ListCoordinator
        let listCoordinator = ListCoordinator(navigationController: navigationController)
        listCoordinator.parentCoordinator = self // Set the parent delegate
        childCoordinators.append(listCoordinator) // Keep track of the child
        listCoordinator.start() // Kick off the list flow
    }
    
    // This function would be called by a child coordinator (like ListCoordinator)
    // when its entire flow is complete and should be removed.
    func listCoordinatorDidFinish(_ child: Coordinator?) {
        print("AppCoordinator notified that ListCoordinator finished.")
        childDidFinish(child)
        // Here you might decide to show another flow, like login,
        // but for this example, we do nothing further.
    }
}

// MARK: - List Flow (Coordinator, ViewModel, ViewController)

// --- Delegate Protocol for ListViewModel -> ListCoordinator communication ---
protocol ListViewModelCoordinatorDelegate: AnyObject {
    func listViewModelDidRequestShowDetail(_ viewModel: ListViewModel, data: String)
    func listViewModelDidFinish(_ viewModel: ListViewModel) // Optional: If the list itself could "finish"
}

// --- List ViewModel ---
class ListViewModel {
    weak var coordinatorDelegate: ListViewModelCoordinatorDelegate?
    
    let title = "List Screen"
    let detailButtonTitle = "Show Detail"
    let listData = "Some data from List" // Example data to pass

    func userDidTapDetailButton() {
        print("ListViewModel: Detail button tapped. Requesting navigation...")
        // Ask the coordinator to navigate
        coordinatorDelegate?.listViewModelDidRequestShowDetail(self, data: listData)
    }
    
    // Call this if the list screen itself could finish its flow
    func finishListFlow() {
        coordinatorDelegate?.listViewModelDidFinish(self)
    }
}

// --- List ViewController ---
class ListViewController: UIViewController {
    let viewModel: ListViewModel
    
    // UI Elements (programmatic for simplicity)
    private let detailButton = UIButton(type: .system)

    init(viewModel: ListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = viewModel.title // Set navigation bar title
        print("ListViewController initialized with ViewModel.")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray5
        setupUI()
        print("ListViewController viewDidLoad.")
    }

    private func setupUI() {
        detailButton.setTitle(viewModel.detailButtonTitle, for: .normal)
        detailButton.addTarget(self, action: #selector(detailButtonTapped), for: .touchUpInside)
        
        detailButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detailButton)
        
        NSLayoutConstraint.activate([
            detailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            detailButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func detailButtonTapped() {
        print("ListViewController: Detail button tapped, informing ViewModel.")
        viewModel.userDidTapDetailButton()
    }
    
    deinit {
        print("ListViewController deinit")
    }
}

// --- List Coordinator ---
protocol AppCoordinatorDelegate: AnyObject {
    func listCoordinatorDidFinish(_ child: Coordinator?)
}

class ListCoordinator: Coordinator {
    weak var parentCoordinator: AppCoordinatorDelegate? // Delegate to notify parent
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        print("ListCoordinator initialized.")
    }

    func start() {
        print("ListCoordinator starting...")
        // 1. Create ViewModel
        let viewModel = ListViewModel()
        viewModel.coordinatorDelegate = self // ViewModel communicates back to this coordinator

        // 2. Create ViewController and Inject ViewModel
        let viewController = ListViewController(viewModel: viewModel)

        // 3. Push onto navigation stack
        // Make it the root if it's the first one, otherwise push.
        if navigationController.viewControllers.isEmpty {
             navigationController.setViewControllers([viewController], animated: false)
        } else {
            navigationController.pushViewController(viewController, animated: true)
        }
    }
    
    // Called when the list coordinator's own flow is done.
    func didFinish() {
        print("ListCoordinator signaling it has finished.")
        parentCoordinator?.listCoordinatorDidFinish(self)
    }
    
    // --- Navigation Handling ---
    
    func showDetailScreen(data: String) {
        print("ListCoordinator: Handling request to show Detail screen.")
        // Create and start the Detail flow (In this simple case, directly managing Detail VC)
        // If Detail had its own complex flow, we'd create a DetailCoordinator here.
        
        // 1. Create Detail ViewModel
        let detailViewModel = DetailViewModel(detailData: data)
        detailViewModel.coordinatorDelegate = self // Listen for finish signals from DetailViewModel

        // 2. Create Detail ViewController
        let detailViewController = DetailViewController(viewModel: detailViewModel)
        
        // 3. Push the Detail ViewController
        navigationController.pushViewController(detailViewController, animated: true)
    }
    
    // Called by DetailViewModel when it's done
    func detailDidFinish() {
        print("ListCoordinator: Detail screen finished, popping it.")
        // Pop the DetailViewController off the stack
        navigationController.popViewController(animated: true)
        // If Detail flow was managed by a DetailCoordinator, we would call `childDidFinish(detailCoordinator)` here.
    }
    
    deinit {
        print("ListCoordinator deinit")
    }
}

// Implement the delegate method for ListViewModel
extension ListCoordinator: ListViewModelCoordinatorDelegate {
    func listViewModelDidRequestShowDetail(_ viewModel: ListViewModel, data: String) {
        showDetailScreen(data: data)
    }
    
    func listViewModelDidFinish(_ viewModel: ListViewModel) {
        // This example doesn't explicitly finish the list flow,
        // but if it did (e.g., user logs out from here), we'd call:
         didFinish()
    }
}


// MARK: - Detail Flow (ViewModel, ViewController) - Managed by ListCoordinator here

// --- Delegate Protocol for DetailViewModel -> ListCoordinator communication ---
protocol DetailViewModelCoordinatorDelegate: AnyObject {
    func detailViewModelDidFinish(_ viewModel: DetailViewModel)
}

// --- Detail ViewModel ---
class DetailViewModel {
    weak var coordinatorDelegate: DetailViewModelCoordinatorDelegate?
    
    let title = "Detail Screen"
    let closeButtonTitle = "Close Detail"
    let detailInfo: String

    init(detailData: String) {
        self.detailInfo = "Received data: \(detailData)"
        print("DetailViewModel initialized with data: \(detailData)")
    }

    func userDidTapCloseButton() {
        print("DetailViewModel: Close button tapped. Signaling finish...")
        // Ask the coordinator (ListCoordinator in this case) to finish this flow
        coordinatorDelegate?.detailViewModelDidFinish(self)
    }
    
    deinit {
        print("DetailViewModel deinit")
    }
}

// --- Detail ViewController ---
class DetailViewController: UIViewController {
    let viewModel: DetailViewModel

    // UI Elements
    private let infoLabel = UILabel()
    private let closeButton = UIButton(type: .system)

    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = viewModel.title
        print("DetailViewController initialized.")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray3
        setupUI()
        print("DetailViewController viewDidLoad.")
    }

    private func setupUI() {
        infoLabel.text = viewModel.detailInfo
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        
        closeButton.setTitle(viewModel.closeButtonTitle, for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoLabel)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 40)
        ])
    }

    @objc private func closeButtonTapped() {
        print("DetailViewController: Close button tapped, informing ViewModel.")
        viewModel.userDidTapCloseButton()
    }
    
    deinit {
        print("DetailViewController deinit")
    }
}

// --- Detail flow needs to communicate back to its manager (ListCoordinator) ---
// Implement the delegate method within the coordinator that manages the Detail flow.
extension ListCoordinator: DetailViewModelCoordinatorDelegate {
    func detailViewModelDidFinish(_ viewModel: DetailViewModel) {
        self.detailDidFinish() // Call the ListCoordinator's own cleanup method
    }
}


// MARK: - SceneDelegate (or AppDelegate) Setup

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator? // Keep a strong reference to the AppCoordinator

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        print("SceneDelegate: willConnectTo...")
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // Create the AppCoordinator and kick things off
        appCoordinator = AppCoordinator(window: window)
        appCoordinator?.start() // Start the main application flow
    }

    // Other SceneDelegate methods...
}
