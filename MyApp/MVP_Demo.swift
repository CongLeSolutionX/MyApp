//
//  MVP_Demo.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//
import Foundation
import UIKit

// --------------------
// MARK: - Protocols (Contracts)
// --------------------
protocol UserViewProtocol: AnyObject { // Use AnyObject for class-bound protocols often needed for weak refs
    func displayUserName(_ name: String)
    func displayLoading(_ isLoading: Bool)
    func displayError(_ message: String)
}

protocol UserPresenterProtocol: AnyObject {
    func viewDidLoad() // Event from View
    func refreshButtonTapped() // Event from View
}

protocol UserServiceProtocol {
    func fetchUser(completion: @escaping (Result<User, Error>) -> Void)
}

// --------------------
// MARK: - Model
// --------------------
struct User {
    let id: String
    let name: String
    // ... other properties
}

// Concrete Model Service (could be Network Manager, DB Manager etc.)
class RealUserService: UserServiceProtocol {
    func fetchUser(completion: @escaping (Result<User, Error>) -> Void) {
        // ... actual network/data fetching logic ...
        // Simulate async call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Simulate success/failure
            let shouldSucceed = Bool.random()
            if shouldSucceed {
                 let fetchedUser = User(id: "123", name: "Alice")
                 completion(.success(fetchedUser))
            } else {
                 enum FetchError: Error { case networkError }
                 completion(.failure(FetchError.networkError))
            }
        }
    }
}


// --------------------
// MARK: - Presenter
// --------------------
class UserPresenter: UserPresenterProtocol {
    // Weak reference to avoid retain cycles if View holds strong ref to Presenter
    private weak var view: UserViewProtocol?
    private let userService: UserServiceProtocol

    init(view: UserViewProtocol, userService: UserServiceProtocol) {
        self.view = view
        self.userService = userService
    }

    func viewDidLoad() {
        loadUserData()
    }

    func refreshButtonTapped() {
         loadUserData()
    }

    private func loadUserData() {
        view?.displayLoading(true) // Tell View to show loading indicator
        userService.fetchUser { [weak self] result in
            // Ensure view and self are still valid (important for async)
            guard let self = self, let view = self.view else { return }

            view.displayLoading(false) // Tell View to hide loading indicator

            switch result {
            case .success(let user):
                // Presentation Logic: Format data for the view
                let formattedName = "User: \(user.name.uppercased())" // Example formatting
                view.displayUserName(formattedName) // Tell View what to display
            case .failure(let error):
                 // Presentation Logic: Format error for the view
                view.displayError("Failed to load user: \(error.localizedDescription)") // Tell View to show error
            }
        }
    }
}

// --------------------
// MARK: - View (UIViewController)
// --------------------
// Assume this ViewController is set up in Storyboard/XIB with outlets connected
class UserViewController: UIViewController, UserViewProtocol {

    // IBOutlet connections (example)
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!

    // Presenter instance (injected)
    var presenter: UserPresenterProtocol! // Usually injected via Initializer or Property

    override func viewDidLoad() {
        super.viewDidLoad()
        // Crucially: Instantiate the presenter here or have it injected.
        // This setup can vary (dependency injection framework, manual init)
        // Example: Assuming presenter is injected *before* viewDidLoad
        if presenter == nil {
             // Simple manual setup (better ways exist)
             presenter = UserPresenter(view: self, userService: RealUserService())
             print("Warning: Presenter manually created. Consider dependency injection.")
        }

        presenter.viewDidLoad() // Inform Presenter that view is ready
        errorLabel.isHidden = true // Initial UI state
    }

    // --- IBAction ---
    @IBAction func refreshButtonAction(_ sender: UIButton) {
        presenter.refreshButtonTapped() // Forward event to presenter
    }

    // --- UserViewProtocol Implementation ---
    func displayUserName(_ name: String) {
        nameLabel.text = name
        nameLabel.isHidden = false
        errorLabel.isHidden = true
    }

    func displayLoading(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
            loadingIndicator.isHidden = false
            refreshButton.isEnabled = false // Disable button while loading
            nameLabel.isHidden = true
            errorLabel.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
            refreshButton.isEnabled = true // Re-enable button
        }
    }

    func displayError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        nameLabel.isHidden = true
    }
}
