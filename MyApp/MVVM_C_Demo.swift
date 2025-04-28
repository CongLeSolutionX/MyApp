//
//  MVVM_C_Demo.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//
import SwiftUI
import UIKit // Needed for UIViewController, UINavigationController etc.
// No need to import Combine for this basic example, but you often would in a real app

// MARK: - Coordinator Protocol

// Defines the basic interface for all coordinators
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
    
    func start()
    func didFinish() // This coordinator's own flow finished
    func childDidFinish(_ child: Coordinator?)
}

// Default implementation for child cleanup and didFinish
extension Coordinator {
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                print("\(type(of: self)): Removed child coordinator - \(type(of: coordinator))")
                break
            }
        }
    }

    func didFinish() {
        print("\(type(of: self)) finished.")
        // Default does nothing - Often overridden to notify parent coordinator
    }
}

// MARK: - Coordinator Delegates (For Child -> Parent Communication)

// Protocol for ListCoordinator to talk back to AppCoordinator
protocol AppCoordinatorDelegate: AnyObject {
    func listCoordinatorDidFinish(_ child: Coordinator?)
}

// Protocol for ListViewModel to talk to its Coordinator (ListCoordinator)
protocol ListViewModelCoordinatorDelegate: AnyObject {
    func listViewModelDidRequestShowDetail(_ viewModel: ListViewModel, data: String)
     func listViewModelDidFinish(_ viewModel: ListViewModel) // Optional based on flow needs
}

// Protocol for DetailViewModel to talk to its Coordinator (ListCoordinator in this case)
protocol DetailViewModelCoordinatorDelegate: AnyObject {
    func detailViewModelDidFinish(_ viewModel: DetailViewModel)
}

// MARK: - App Coordinator (Manages the overall App Flow)

class AppCoordinator: Coordinator, AppCoordinatorDelegate {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    // Initialized with the root navigation controller provided by the hosting view
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        print("AppCoordinator: Initialized.")
    }

    func start() {
        print("AppCoordinator: start() called. Starting initial flow...")
        // For this example, we immediately start the list flow
        showListFlow()
    }
    
    func showListFlow() {
        print("AppCoordinator: Starting List Flow...")
        let listCoordinator = ListCoordinator(navigationController: navigationController)
        listCoordinator.parentCoordinator = self // Set self as the delegate
        childCoordinators.append(listCoordinator)
        listCoordinator.start()
    }
    
    // --- AppCoordinatorDelegate conformance ---
    // Called by ListCoordinator when it finishes its entire flow
    func listCoordinatorDidFinish(_ child: Coordinator?) {
        print("AppCoordinator: Notified that ListCoordinator finished.")
        self.childDidFinish(child)
        // Here you could decide what to do next, e.g., show login screen
        // For simplicity, we do nothing more.
    }

    // AppCoordinator itself usually doesn't "finish" unless the app is closing
    func didFinish() {
         print("AppCoordinator: didFinish() called (unlikely in standard flow).")
    }
}

// MARK: - List Flow (Coordinator, ViewModel, ViewController)

// --- List ViewModel ---
class ListViewModel {
    weak var coordinatorDelegate: ListViewModelCoordinatorDelegate?
    
    let title = "Items List"
    let detailButtonTitle = "Show Detail (Item #1)"
    let finishButtonTitle = "Finish List Flow (Example)"
    let listData = "Item #1 Data" // Example data

    func userDidTapDetailButton() {
        print("ListViewModel: Detail button tapped. Requesting navigation...")
        coordinatorDelegate?.listViewModelDidRequestShowDetail(self, data: listData)
    }
    
    func userDidTapFinishButton() {
        print("ListViewModel: Finish button tapped. Signaling flow finish...")
        coordinatorDelegate?.listViewModelDidFinish(self)
    }
    
    deinit { print("ListViewModel: Deinit") }
}

// --- List ViewController ---
class ListViewController: UIViewController {
    let viewModel: ListViewModel
    
    // UI Elements
    private let detailButton = UIButton(type: .system)
    private let finishButton = UIButton(type: .system) // Example for finishing flow

    init(viewModel: ListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = viewModel.title
        print("ListViewController: Initialized.")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // Changed for better visibility
        setupUI()
        print("ListViewController: viewDidLoad.")
    }

    private func setupUI() {
        detailButton.setTitle(viewModel.detailButtonTitle, for: .normal)
        detailButton.addTarget(self, action: #selector(detailButtonTapped), for: .touchUpInside)
        
        finishButton.setTitle(viewModel.finishButtonTitle, for: .normal)
        finishButton.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [detailButton, finishButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func detailButtonTapped() {
        print("ListViewController: Detail button tapped, informing ViewModel.")
        viewModel.userDidTapDetailButton()
    }
    
     @objc private func finishButtonTapped() {
        print("ListViewController: Finish button tapped, informing ViewModel.")
        viewModel.userDidTapFinishButton()
    }
    
    deinit {
        print("ListViewController: Deinit")
    }
}

// --- List Coordinator ---
class ListCoordinator: Coordinator {
    weak var parentCoordinator: AppCoordinatorDelegate? // Delegate to talk back to AppCoordinator
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        print("ListCoordinator: Initialized.")
    }

    func start() {
        print("ListCoordinator: start() called.")
        // Create VM, set self as delegate
        let viewModel = ListViewModel()
        viewModel.coordinatorDelegate = self

        // Create VC, inject VM
        let viewController = ListViewController(viewModel: viewModel)

        // Present VC
        // Set as root if stack is empty, otherwise push
        if navigationController.viewControllers.isEmpty {
             print("ListCoordinator: Setting ListVC as root.")
             navigationController.setViewControllers([viewController], animated: false)
        } else {
             print("ListCoordinator: Pushing ListVC.")
            navigationController.pushViewController(viewController, animated: true)
        }
    }
    
    // Called when this entire flow should end
    func didFinish() {
        print("ListCoordinator: didFinish() called. Notifying parent.")
        parentCoordinator?.listCoordinatorDidFinish(self)
    }
    
    // --- Navigation Handling Methods ---
    func showDetailScreen(data: String) {
        print("ListCoordinator: Handling request to show Detail screen...")
        // In a complex app, you might start a DetailCoordinator.
        // Here, we manage DetailViewController directly.
        let detailViewModel = DetailViewModel(detailData: data)
        detailViewModel.coordinatorDelegate = self // ListCoordinator listens for Detail's finish

        let detailViewController = DetailViewController(viewModel: detailViewModel)
        print("ListCoordinator: Pushing DetailVC.")
        navigationController.pushViewController(detailViewController, animated: true)
    }
    
    // Called by self when Detail flow is done
    func detailFlowDidFinish() {
        print("ListCoordinator: Detail flow finished. Popping DetailVC.")
        navigationController.popViewController(animated: true)
        // If a child DetailCoordinator existed, call: self.childDidFinish(detailCoordinator)
    }
    
    deinit {
        print("ListCoordinator: Deinit")
    }
}

// --- ListCoordinator: Delegate Conformance ---

extension ListCoordinator: ListViewModelCoordinatorDelegate {
    func listViewModelDidRequestShowDetail(_ viewModel: ListViewModel, data: String) {
        showDetailScreen(data: data)
    }
    
    // Called when ListViewModel signals its flow should end
    func listViewModelDidFinish(_ viewModel: ListViewModel) {
        self.didFinish() // Signal self has finished, which notifies parent
    }
}

extension ListCoordinator: DetailViewModelCoordinatorDelegate {
    // Called when DetailViewModel signals it's done
    func detailViewModelDidFinish(_ viewModel: DetailViewModel) {
        self.detailFlowDidFinish() // Handle the finish of the detail screen
    }
}

// MARK: - Detail Flow (ViewModel, ViewController)

// --- Detail ViewModel ---
class DetailViewModel {
    weak var coordinatorDelegate: DetailViewModelCoordinatorDelegate?
    
    let title = "Item Detail"
    let closeButtonTitle = "Close Detail"
    let detailInfo: String

    init(detailData: String) {
        self.detailInfo = "Detail: \(detailData)\nTapped at: \(Date())"
        print("DetailViewModel: Initialized with data '\(detailData)'")
    }

    func userDidTapCloseButton() {
        print("DetailViewModel: Close button tapped. Signaling finish...")
        coordinatorDelegate?.detailViewModelDidFinish(self)
    }
    
    deinit {
        print("DetailViewModel: Deinit")
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
        print("DetailViewController: Initialized.")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemMint // Changed for visibility
        setupUI()
        print("DetailViewController: viewDidLoad.")
    }

    private func setupUI() {
        infoLabel.text = viewModel.detailInfo
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.textColor = .white
        
        closeButton.setTitle(viewModel.closeButtonTitle, for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = .systemBlue
        closeButton.layer.cornerRadius = 8
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [infoLabel, closeButton])
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc private func closeButtonTapped() {
        print("DetailViewController: Close button tapped, informing ViewModel.")
        viewModel.userDidTapCloseButton()
    }
    
    deinit {
        print("DetailViewController: Deinit")
    }
}

// MARK: - SwiftUI Host for UIKit Coordinator Flow

struct CoordinatorHostingView: UIViewControllerRepresentable {

    // Strong reference to keep the AppCoordinator alive for the duration of the view
    private var appCoordinator: AppCoordinator?
    private let navigationController: UINavigationController

    init() {
       print("CoordinatorHostingView: init.")
       // Create the root navigation controller ONCE
       self.navigationController = UINavigationController()
       // Create the AppCoordinator, passing the navigation controller
       self.appCoordinator = AppCoordinator(navigationController: self.navigationController)
    }

    // Creates the initial UIKit view controller (our UINavigationController)
    func makeUIViewController(context: Context) -> UINavigationController {
        print("CoordinatorHostingView: makeUIViewController (Creating and starting AppCoordinator).")
        // Start the AppCoordinator's flow
        appCoordinator?.start()
        return navigationController
    }

    // Updates the UIKit view controller when SwiftUI state changes (not needed here)
     func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
         // print("CoordinatorHostingView: updateUIViewController")
         // No external state changes to pass down in this simple example
     }

    // Creates coordinator instance used by SwiftUI internally (different from our MVVM-C Coordinator)
    func makeCoordinator() -> Coordinator {
        print("CoordinatorHostingView: makeCoordinator (SwiftUI internal).")
        return Coordinator() // Standard SwiftUI Coordinator class
    }
    
    // Standard SwiftUI Coordinator class (can be used for UIKit -> SwiftUI communication if needed)
    class Coordinator {
        init() {
            print("CoordinatorHostingView.Coordinator (SwiftUI internal): init")
        }
    }
}

// MARK: - SwiftUI App Entry Point

@main
struct MyApp: App {
    init() {
        print("MyApp: Initializing.")
    }
    
    var body: some Scene {
        WindowGroup {
            // Host the UIKit view hierarchy managed by the coordinator
            CoordinatorHostingView()
                .edgesIgnoringSafeArea(.all) // Let UIKit control the full screen
        }
    }
}
