//
//  MVVM_Demo_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//

import SwiftUI
import UIKit
import Combine // Crucial for data binding in this example

// MARK: - 1. Model
struct User: Identifiable, Equatable {
    let id: UUID
    let name: String
    let email: String
}

// MARK: - 2. Service Layer
protocol UserDataServiceProtocol {
    func fetchUsers() -> AnyPublisher<[User], Error>
}

class MockUserDataService: UserDataServiceProtocol {
    func fetchUsers() -> AnyPublisher<[User], Error> {
        Future<[User], Error> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
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
                    promise(.failure(URLError(.badServerResponse)))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

// MARK: - 3. ViewModel
class UserListViewModel: ObservableObject {
    @Published private(set) var userCellViewModels: [UserCellViewModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil

    private let userDataService: UserDataServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(userDataService: UserDataServiceProtocol = MockUserDataService()) {
        self.userDataService = userDataService
        print("UserListViewModel Initialized")
    }

    func fetchUsers() {
        print("ViewModel: fetchUsers triggered")
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        userCellViewModels = []

        userDataService.fetchUsers()
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
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
                self.userCellViewModels = users.map { UserCellViewModel(user: $0) }
            })
            .store(in: &cancellables)
    }

    func didSelectUser(at index: Int) {
        guard index < userCellViewModels.count else { return }
        let selectedUserVM = userCellViewModels[index]
        print("ViewModel: User selected - \(selectedUserVM.name) with email \(selectedUserVM.email)")
    }

    func clearError() {
        errorMessage = nil
    }
}

// MARK: - 3a. Cell ViewModel
struct UserCellViewModel: Identifiable {
    private let user: User
    var id: UUID { user.id }
    var name: String { user.name }
    var email: String { user.email }
    var initials: String {
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
class UserListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let errorLabel = UILabel()
    private var refreshButton = UIButton(type: .system)
    private var viewModel: UserListViewModel = UserListViewModel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("UserListViewController: viewDidLoad")
        setupUI()
        bindViewModel()
    }

     override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.userCellViewModels.isEmpty && !viewModel.isLoading {
             print("UserListViewController: viewDidAppear - Triggering initial fetch")
             viewModel.fetchUsers()
        }
    }

    private func setupUI() {
        print("UserListViewController: setupUI")
        title = "Users (MVVM + UIKit)" // Updated title for clarity
        view.backgroundColor = .systemBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: "UserCell")
        view.addSubview(tableView)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        view.addSubview(errorLabel)

        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.setTitle("Refresh Users", for: .normal)
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        view.addSubview(refreshButton)

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

    private func bindViewModel() {
        print("UserListViewController: bindViewModel")

        viewModel.$isLoading
           .receive(on: DispatchQueue.main)
           .sink { [weak self] isLoading in
                print("Binding: isLoading changed to \(isLoading)")
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.errorLabel.isHidden = true
                } else {
                    self?.activityIndicator.stopAnimating()
                }
                 self?.refreshButton.isEnabled = !isLoading
            }
           .store(in: &cancellables)

        viewModel.$errorMessage
           .receive(on: DispatchQueue.main)
           .sink { [weak self] errorMessage in
                 print("Binding: errorMessage changed to \(errorMessage ?? "nil")")
                self?.errorLabel.text = errorMessage
                self?.errorLabel.isHidden = (errorMessage == nil)
                self?.tableView.isHidden = (errorMessage != nil)
            }
           .store(in: &cancellables)

        viewModel.$userCellViewModels
           .receive(on: DispatchQueue.main)
           .sink { [weak self] users in
                print("Binding: userCellViewModels updated with \(users.count) items. Reloading table.")
                if !users.isEmpty {
                    self?.errorLabel.isHidden = true
                    self?.tableView.isHidden = false
                 }
                self?.tableView.reloadData()
            }
           .store(in: &cancellables)
    }

    @objc private func refreshButtonTapped() {
         print("UserListViewController: Refresh button tapped - Forwarding to ViewModel")
        viewModel.fetchUsers()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.userCellViewModels.count
        print("TableViewDataSource: numberOfRowsInSection - Returning \(count)")
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        let cellViewModel = viewModel.userCellViewModels[indexPath.row]
        cell.configure(with: cellViewModel)
        print("TableViewDataSource: cellForRowAt \(indexPath.row) - Configuring cell for \(cellViewModel.name)")
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
         print("TableViewDelegate: didSelectRowAt \(indexPath.row) - Forwarding to ViewModel")
        viewModel.didSelectUser(at: indexPath.row)
    }
}

// MARK: - 4a. Custom TableViewCell
class UserTableViewCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let initialsLabel = UILabel()
    private let initialsContainer = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupCellUI() {
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        emailLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        emailLabel.textColor = .gray
        initialsLabel.font = UIFont.boldSystemFont(ofSize: 16)
        initialsLabel.textColor = .white
        initialsLabel.textAlignment = .center
        initialsContainer.backgroundColor = .systemGray
        initialsContainer.layer.cornerRadius = 20
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

    func configure(with viewModel: UserCellViewModel) {
        nameLabel.text = viewModel.name
        emailLabel.text = viewModel.email
        initialsLabel.text = viewModel.initials
        initialsContainer.backgroundColor = UIColor.randomColor()
    }
}

// MARK: - 5. SwiftUI App Entry Point & Representable Wrapper

// Wrapper struct to use the UIKit ViewController in SwiftUI
struct UserListViewControllerRepresentable: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UINavigationController {
        let userListVC = UserListViewController()
        let navigationController = UINavigationController(rootViewController: userListVC)
         print("UIViewControllerRepresentable: Created UINavigationController with UserListViewController")
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
         print("UIViewControllerRepresentable: updateUIViewController called (no action)")
        // No update needed for this example
    }
}

// Main App Structure (SwiftUI)
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            // Use the representable to display the UIKit view
            UserListViewControllerRepresentable()
        }
    }
}

// MARK: - Helper Extension
extension UIColor {
    static func randomColor() -> UIColor {
        return UIColor( red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 0.7 )
    }
}
