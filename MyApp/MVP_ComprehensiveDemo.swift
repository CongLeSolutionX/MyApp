//
//  MVP_ComprehensiveDemo.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//

import Foundation
// UIKit import is not strictly needed for the core logic demonstration,
// but helps visualize where UIViewController/UI elements would fit.
// If running in a non-iOS environment (like command line), comment it out.
import UIKit // Or remove if not available/needed for execution context

//print("--- MVP Pattern Demonstration ---")

// MARK: - 1. Model Layer

// Data structure
struct User {
    let id: String
    let name: String
    let email: String
}

// Protocol for data/business logic services
protocol UserServiceProtocol {
    // Simulates fetching a user asynchronously
    func fetchUser(completion: @escaping (Result<User, Error>) -> Void)
}

// Concrete implementation of the user service (e.g., network calls, database access)
class RealUserService: UserServiceProtocol {
    // Simulate potential errors
    enum FetchError: Error, LocalizedError {
        case networkUnavailable
        case userNotFound
        var errorDescription: String? {
            switch self {
            case .networkUnavailable: return "Could not connect to the network."
            case .userNotFound: return "The requested user was not found."
            }
        }
    }

    // Simulate fetching data, sometimes succeeding, sometimes failing
    func fetchUser(completion: @escaping (Result<User, Error>) -> Void) {
        print("[Model - RealUserService]: Request received to fetch user.")
        // Simulate async network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let shouldSucceed = Bool.random() // Randomly succeed or fail

            if shouldSucceed {
                print("[Model - RealUserService]: Fetch successful. Returning user data.")
                let fetchedUser = User(id: UUID().uuidString, name: "Jane Doe", email: "jane.doe@example.com")
                completion(.success(fetchedUser))
            } else {
                let errorType = Bool.random() ? FetchError.networkUnavailable : FetchError.userNotFound
                print("[Model - RealUserService]: Fetch failed. Returning error: \(errorType.localizedDescription)")
                completion(.failure(errorType))
            }
        }
    }
}

// MARK: - 2. Protocols (Contracts)

// Defines the display logic capabilities the VIEW must implement.
// The Presenter will talk to the View ONLY through this protocol.
// `AnyObject` constraint allows using `weak` references to prevent retain cycles.
protocol UserViewProtocol: AnyObject {
    func displayUserDetails(name: String, email: String)
    func displayLoading(_ isLoading: Bool)
    func displayError(title: String, message: String)
    func clearUserDetails()
}

// Defines the actions/events the PRESENTER can handle, usually triggered by the View.
protocol UserPresenterProtocol: AnyObject {
    init(view: UserViewProtocol, userService: UserServiceProtocol) // Dependency Injection
    func viewDidLoad() // Lifecycle event from View
    func refreshButtonTapped() // User interaction event from View
}

// MARK: - 3. Presenter Layer

class UserPresenter: UserPresenterProtocol {
    // Weak reference to the View to avoid retain cycles.
    // The Presenter doesn't own the View.
    private weak var view: UserViewProtocol?
    // Strong reference to the Model service it needs to interact with.
    private let userService: UserServiceProtocol

    // Dependencies (View Protocol and Service Protocol) are injected.
    // This makes the Presenter testable, as mocks can be injected.
    required init(view: UserViewProtocol, userService: UserServiceProtocol) {
        self.view = view
        self.userService = userService
        print("[Presenter]: Initialized with View and UserService.")
    }

    // --- UserPresenterProtocol Implementation ---

    func viewDidLoad() {
        print("[Presenter]: Received viewDidLoad event from View.")
        loadUserData() // Initial data load when the view is ready
    }

    func refreshButtonTapped() {
        print("[Presenter]: Received refreshButtonTapped event from View.")
        loadUserData() // Reload data on user request
    }

    // --- Private Helper Methods ---

    private func loadUserData() {
        print("[Presenter]: Starting user data load process...")
        // 1. Tell the View to show a loading indicator
        view?.displayLoading(true)
        // 2. Clear previous details/errors (optional, depends on desired UX)
        view?.clearUserDetails()

        // 3. Ask the Model (UserService) to fetch data asynchronously
        userService.fetchUser { [weak self] result in
            // Ensure 'self' (Presenter) and 'view' are still valid after async operation
            guard let self = self, let view = self.view else {
                print("[Presenter]: Self or View is nil after async operation. Aborting update.")
                return
            }

            print("[Presenter]: Received result from UserService.")
            // 4. Tell the View to hide the loading indicator regardless of outcome
            view.displayLoading(false)

            // 5. Process the result from the Model
            switch result {
            case .success(let user):
                print("[Presenter]: Data fetch succeeded. Formatting data for View.")
                // Presentation Logic: Format the raw User model data for display.
                let formattedName = "Name: \(user.name.capitalized)"
                let formattedEmail = "Email: \(user.email)"
                // Tell the View WHAT to display using the formatted data.
                view.displayUserDetails(name: formattedName, email: formattedEmail)

            case .failure(let error):
                print("[Presenter]: Data fetch failed. Formatting error for View.")
                // Presentation Logic: Create user-friendly error messages.
                let errorTitle = "Error Loading User"
                let errorMessage = error.localizedDescription // Use localized description from error
                // Tell the View to display the error.
                view.displayError(title: errorTitle, message: errorMessage)
            }
        }
    }
}

// MARK: - 4. View Layer (Simulated UIViewController)

// This class simulates a UIViewController. In a real app, it would have
// IBOutlets connected to UI elements like UILabels, UIActivityIndicatorView, etc.
// It conforms to the `UserViewProtocol` to receive instructions from the Presenter.
class UserViewControllerSimulator: UserViewProtocol {

    // Simulates UI elements (normally IBOutlets)
    private var nameLabelText: String?
    private var emailLabelText: String?
    private var isLoadingIndicatorVisible: Bool = false
    private var errorAlertTitle: String?
    private var errorAlertMessage: String?

    // The View holds a strong reference to its Presenter.
    // presenter needs to be set *after* init or injected.
    var presenter: UserPresenterProtocol!

    // Simulates the ViewController's lifecycle method
    func simulateViewDidLoad() {
        print("\n[View - Simulator]: viewDidLoad simulated.")
        // ** CRITICAL STEP: Presenter Initialization / Injection **
        // In a real app, this might happen via storyboard segues, dependency injection frameworks, etc.
        // Here, we manually create it for demonstration. The View now has its Presenter.
        if presenter == nil { // Avoid creating if already injected
             let service = RealUserService() // Create the model service
             presenter = UserPresenter(view: self, userService: service) // Create Presenter, injecting self (as View) and service
             print("[View - Simulator]: Manually created and assigned Presenter.")
        } else {
            print("[View - Simulator]: Presenter was already assigned (likely injected).")
        }

        // Inform the presenter that the view is ready.
        presenter.viewDidLoad()
    }

    // Simulates a user tapping a refresh button
    func simulateRefreshButtonTap() {
        print("\n[View - Simulator]: Refresh button tapped (simulated).")
        presenter.refreshButtonTapped() // Forward the event to the presenter
    }

    // --- UserViewProtocol Implementation ---
    // These methods are CALLED BY THE PRESENTER to update the UI.
    // The View just executes these instructions blindly.

    func displayUserDetails(name: String, email: String) {
        print("[View - Simulator]: Updating UI - Displaying User Details:")
        print("  Name Label -> '\(name)'")
        print("  Email Label -> '\(email)'")
        self.nameLabelText = name
        self.emailLabelText = email
        // In real UIKit:
        // self.nameLabel.text = name
        // self.emailLabel.text = email
        // self.nameLabel.isHidden = false
        // self.emailLabel.isHidden = false
        // self.errorContainerView.isHidden = true
    }

    func displayLoading(_ isLoading: Bool) {
        print("[View - Simulator]: Updating UI - Loading Indicator Visible -> \(isLoading)")
        self.isLoadingIndicatorVisible = isLoading
        // In real UIKit:
        // if isLoading { self.activityIndicator.startAnimating() }
        // else { self.activityIndicator.stopAnimating() }
        // self.activityIndicator.isHidden = !isLoading
        // self.refreshButton.isEnabled = !isLoading // Example: Disable button while loading
    }

    func displayError(title: String, message: String) {
        print("[View - Simulator]: Updating UI - Displaying Error:")
        print("  Error Title -> '\(title)'")
        print("  Error Message -> '\(message)'")
        self.errorAlertTitle = title
        self.errorAlertMessage = message
        // In real UIKit:
        // self.nameLabel.isHidden = true
        // self.emailLabel.isHidden = true
        // self.errorLabel.text = "\(title): \(message)" // Or show an alert
        // self.errorContainerView.isHidden = false
        // let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // alert.addAction(UIAlertAction(title: "OK", style: .default))
        // self.present(alert, animated: true)
    }

     func clearUserDetails() {
        print("[View - Simulator]: Updating UI - Clearing previous details and errors.")
        self.nameLabelText = nil
        self.emailLabelText = nil
        self.errorAlertTitle = nil
        self.errorAlertMessage = nil
         // In real UIKit:
         // self.nameLabel.text = nil
         // self.emailLabel.text = nil
         // self.errorLabel.text = nil
         // self.nameLabel.isHidden = true
         // self.emailLabel.isHidden = true
         // self.errorContainerView.isHidden = true
     }
}

// MARK: - 5. Simulation Execution
//
//print("\n--- Running Simulation ---")
//
//// 1. Create an instance of our simulated View Controller
//let viewController = UserViewControllerSimulator()
//
//// 2. Simulate the `viewDidLoad` lifecycle event. This triggers presenter creation and the initial data load.
//viewController.simulateViewDidLoad()
//
//// Note: The fetchUser is async, so the following simulation might run before the first fetch completes.
//// We need to keep the playground/script running to see the async results.
//
//// 3. Simulate the user tapping the refresh button after a delay
//DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//    viewController.simulateRefreshButtonTap()
//}
//
//// Keep the execution context alive long enough for async operations to complete
//// In a Playground, this happens automatically. For command-line, you might need RunLoop handling.
//print("\n--- Simulation Triggered (Waiting for Async Results) ---")
//// In a real app, the RunLoop keeps the app alive. For simple scripts/playgrounds:
//if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil { // Basic check if not running in Test context
//    // Keep alive for a few seconds to see async results in basic scripts
//    RunLoop.main.run(until: Date(timeIntervalSinceNow: 5))
//    print("\n--- Simulation End ---")
//}
