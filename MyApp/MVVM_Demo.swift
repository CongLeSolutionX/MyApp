//
//  MVVM_Demo.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//

import UIKit
import Combine // Crucial for data binding in this example

// MARK: - 1. Model
// Represents the raw data and potentially business logic.
// Independent of UI.

struct User: Identifiable, Equatable {
    let id: UUID
    let name: String
    let email: String
}

// MARK: - 2. Service Layer (Simulates Data Fetching)
// Often part of the Model layer or interacts closely with it.
// Handles tasks like network requests or database access.

protocol UserDataServiceProtocol {
    // Simulates fetching users asynchronously
    func fetchUsers() -> AnyPublisher<[User], Error>
}

// A mock implementation for demonstration purposes.
class MockUserDataService: UserDataServiceProtocol {
    func fetchUsers() -> AnyPublisher<[User], Error> {
        // Simulate network delay and potential failure
        Future<[User], Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
                // Simulate success/failure randomly
                if Bool.random() {
                    let mockUsers = [
                        User(id: UUID(), name: "Alice Smith", email: "alice@example.com"),
                        User(id: UUID(), name: "Bob Johnson", email: "bob.j@example.com"),
                        User(id: UUID(), name: "Charlie Brown", email: "charlie@example.com"),
                        User(id: UUID(), name: "Diana Prince", email: "diana@example.com")
                    ]
                    print("Mock Service: Successfully fetched users")
                    promise(.success(mockUsers))
                } else {
                    print("Mock Service: Failed to fetch users")
                    promise(.failure(URLError(.badServerResponse))) // Simulate a network error
                }
            }
        }
        .receive(on: DispatchQueue.main) // Ensure result is published on the main thread
        .eraseToAnyPublisher() // Type erasure
    }
}

// MARK: - 3. ViewModel
// Acts as the intermediary. Holds presentation logic and state.
// UI Independent (doesn't import UIKit directly for its core logic).

class UserListViewModel: ObservableObject { // ObservableObject for Combine integration

    // --- State (Published for View updates) ---
    @Published private(set) var userCellViewModels: [UserCellViewModel] = [] // Prepared data for the View
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil

    // --- Dependencies ---
    private let userDataService: UserDataServiceProtocol

    // --- Combine Cancellables ---
    private var cancellables = Set<AnyCancellable>()

    // --- Initialization ---
    init(userDataService: UserDataServiceProtocol = MockUserDataService()) { // Dependency Injection
        self.userDataService = userDataService
        print("UserListViewModel Initialized")
    }

    // --- Actions (Called by the View) ---
    func fetchUsers() {
        print("ViewModel: fetchUsers triggered")
        guard !isLoading else { return } // Prevent multiple simultaneous fetches

        isLoading = true
        errorMessage = nil // Clear previous errors
        userCellViewModels = [] // Clear previous data immediately for better UX

        userDataService.fetchUsers()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false // Stop loading indicator regardless of outcome
                switch completion {
                case .finished:
                    print("ViewModel: User fetch completed successfully.")
                case .failure(let error):
                    print("ViewModel: User fetch failed with error: \(error)")
                    self.errorMessage = "Failed to load users. Please try again. (\(error.localizedDescription))"
                }
            }, receiveValue: { [weak self] users in
                print("ViewModel: Received \(users.count) users from service.")
                guard let self = self else { return }
                // Transform Model `User` into `UserCellViewModel` for the View
                self.userCellViewModels = users.map { UserCellViewModel(user: $0) }
            })
            .store(in: &cancellables) // Store subscription to manage its lifecycle
    }

    func didSelectUser(at index: Int) {
        guard index < userCellViewModels.count else { return }
        let selectedUserVM = userCellViewModels[index]
        print("ViewModel: User selected - \(selectedUserVM.name) with email \(selectedUserVM.email)")
        // In a real app, this might trigger navigation, show details, etc.
        // This logic resides here, not in the View.
    }

    // --- Helper for Resetting State (Optional) ---
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - 3a. Cell ViewModel (Optional but good practice)
// Sometimes useful to have ViewModels specific to UI components like table cells.

struct UserCellViewModel: Identifiable {
    private let user: User

    var id: UUID { user.id } // Expose ID for list diffing/identification
    var name: String { user.name }
    var email: String { user.email }
    var initials: String { // Example of formatting logic
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: user.name) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return "?"
    }

    init(user: User) {
        self.user = user
    }
}

// MARK: - 4. View (UIViewController + Subviews)
// Displays data from the ViewModel. Sends user actions to the ViewModel.
// Should contain minimal logic, mostly related to UI setup and binding.

class UserListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // --- UI Elements ---
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let errorLabel = UILabel()
    private var refreshButton = UIButton(type: .system) // Example button interaction

    // --- ViewModel ---
    // Use 'lazy var' to allow self to be available for closure captures if needed,
    // or initialize directly if not needed. Direct init is fine here.
    private var viewModel: UserListViewModel = UserListViewModel() // Usually injected in real apps


    // --- Combine Cancellables ---
    private var cancellables = Set<AnyCancellable>()

    // --- Lifecycle ---
    override func viewDidLoad() {
        super.viewDidLoad()
        print("UserListViewController: viewDidLoad")
        setupUI()
        bindViewModel()

        // Initial data fetch (could also be in viewDidAppear)
        // viewModel.fetchUsers() // Moved to viewDidAppear for this example
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Fetch data when the view is actually visible
        if viewModel.userCellViewModels.isEmpty && !viewModel.isLoading {
             print("UserListViewController: viewDidAppear - Triggering initial fetch")
             viewModel.fetchUsers()
        }
    }

    // --- UI Setup ---
    private func setupUI() {
        print("UserListViewController: setupUI")
        title = "Users (MVVM)"
        view.backgroundColor = .systemBackground

        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: "UserCell")
        view.addSubview(tableView)

        // Activity Indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        // Error Label
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true // Initially hidden
        view.addSubview(errorLabel)

        // Refresh Button (as an example action)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.setTitle("Refresh Users", for: .normal)
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        view.addSubview(refreshButton)


        // Constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: refreshButton.topAnchor, constant: -10),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            refreshButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            refreshButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            refreshButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            refreshButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // --- ViewModel Binding (Using Combine) ---
    private func bindViewModel() {
        print("UserListViewController: bindViewModel")

        // 1. Bind loading state to activity indicator visibility
        viewModel.$isLoading
            .receive(on: DispatchQueue.main) // Ensure UI updates happen on the main thread
            .sink { [weak self] isLoading in
                print("Binding: isLoading changed to \(isLoading)")
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.errorLabel.isHidden = true // Hide error when loading starts
                } else {
                    self?.activityIndicator.stopAnimating()
                }
                // Optionally disable refresh button while loading
                 self?.refreshButton.isEnabled = !isLoading
            }
            .store(in: &cancellables)

        // 2. Bind error message to error label visibility and text
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                 print("Binding: errorMessage changed to \(errorMessage ?? "nil")")
                self?.errorLabel.text = errorMessage
                self?.errorLabel.isHidden = (errorMessage == nil)
                // Hide table view if there's an error (optional UX choice)
                self?.tableView.isHidden = (errorMessage != nil)
            }
            .store(in: &cancellables)

        // 3. Bind user data to table view
        viewModel.$userCellViewModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                print("Binding: userCellViewModels updated with \(users.count) items. Reloading table.")
                // Hide error when data is successfully loaded
                 if !users.isEmpty {
                    self?.errorLabel.isHidden = true
                    self?.tableView.isHidden = false
                 }
                self?.tableView.reloadData() // Reload table when users array changes
            }
            .store(in: &cancellables)
    }

    // --- Actions (Forwarded to ViewModel) ---
    @objc private func refreshButtonTapped() {
         print("UserListViewController: Refresh button tapped - Forwarding to ViewModel")
        // The View only knows *that* the button was tapped.
        // The ViewModel knows *what* to do when it's tapped.
        viewModel.fetchUsers()
    }


    // --- UITableViewDataSource ---
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.userCellViewModels.count
        print("TableViewDataSource: numberOfRowsInSection - Returning \(count)")
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserTableViewCell else {
            return UITableViewCell() // Should not happen if registered correctly
        }
        let cellViewModel = viewModel.userCellViewModels[indexPath.row]
        // Configure cell with data from the cell-specific ViewModel
        cell.configure(with: cellViewModel)
        print("TableViewDataSource: cellForRowAt \(indexPath.row) - Configuring cell for \(cellViewModel.name)")
        return cell
    }

    // --- UITableViewDelegate ---
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
         print("TableViewDelegate: didSelectRowAt \(indexPath.row) - Forwarding to ViewModel")
        // View tells the ViewModel *which* row was selected.
        viewModel.didSelectUser(at: indexPath.row)
    }
}


// MARK: - 4a. Custom TableViewCell (View Component)

class UserTableViewCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let initialsLabel = UILabel()
    private let initialsContainer = UIView()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCellUI() {
        // Basic UI setup for the cell labels
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        emailLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        emailLabel.textColor = .gray

        initialsLabel.font = UIFont.boldSystemFont(ofSize: 16)
        initialsLabel.textColor = .white
        initialsLabel.textAlignment = .center

        initialsContainer.backgroundColor = .systemGray
        initialsContainer.layer.cornerRadius = 20 // Make it circular
        initialsContainer.translatesAutoresizingMaskIntoConstraints = false
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        initialsContainer.addSubview(initialsLabel)


        let stackView = UIStackView(arrangedSubviews: [nameLabel, emailLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(initialsContainer)
        contentView.addSubview(stackView)


        NSLayoutConstraint.activate([
            initialsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            initialsContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            initialsContainer.widthAnchor.constraint(equalToConstant: 40),
            initialsContainer.heightAnchor.constraint(equalToConstant: 40),

            initialsLabel.centerXAnchor.constraint(equalTo: initialsContainer.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: initialsContainer.centerYAnchor),


            stackView.leadingAnchor.constraint(equalTo: initialsContainer.trailingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

        ])
    }

    // Method to configure the cell with a cell-specific ViewModel
    func configure(with viewModel: UserCellViewModel) {
        nameLabel.text = viewModel.name
        emailLabel.text = viewModel.email
        initialsLabel.text = viewModel.initials
        initialsContainer.backgroundColor = UIColor.randomColor() // Just for visual distinction
    }
}

// Helper extension for random color
extension UIColor {
    static func randomColor() -> UIColor {
        return UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 0.7 // Slightly transparent
        )
    }
}


// MARK: - How to Use
/*
 // In your SceneDelegate.swift or wherever you set up your initial UI:

 func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
     guard let windowScene = (scene as? UIWindowScene) else { return }

     let window = UIWindow(windowScene: windowScene)

     // Create the main ViewController
     let userListVC = UserListViewController()

     // Embed it in a Navigation Controller (optional, but common)
     let navigationController = UINavigationController(rootViewController: userListVC)

     window.rootViewController = navigationController // Set root view controller
     window.makeKeyAndVisible()
     self.window = window
 }

*/
