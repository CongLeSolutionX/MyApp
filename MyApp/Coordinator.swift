//
//  Coordinator.swift
//  MyApp
//
//  Created by Cong Le on 1/11/25.
//
import SwiftUI


// MARK: - Coordinator
protocol Coordinator: AnyObject {
    var navigationPath: NavigationPath { get set }
    func start()
    func push<T: Hashable>(_ page: T)
    func pop()
    func popToRoot()
}

extension Coordinator {
    func pop() {
        navigationPath.removeLast()
    }

    func popToRoot() {
        navigationPath = .init()
    }
}


// MARK: - AppCoordinator
class AppCoordinator: ObservableObject, Coordinator {
    @Published var navigationPath = NavigationPath()
    @Published var settingsCoordinator: SettingsCoordinator?
    
    // Computed property to provide a Binding to navigationPath
    var navigationBinding: Binding<NavigationPath> {
        Binding(
            get: { self.navigationPath },
            set: { self.navigationPath = $0 }
        )
    }
    
    func start() {
        // Start with the Home page
        push(AppPage.home)
    }
    
    func push<T: Hashable>(_ page: T) {
        navigationPath.append(page)
    }
    
    enum AppPage: Hashable {
        case home
        case settings
        case profile(userID: Int)
        case productDetail(product: Product)
        // Add other pages as needed
    }
    
    // Example functions to handle specific navigation actions
    func showSettings() {
        settingsCoordinator = SettingsCoordinator(navigationPath: navigationBinding)
        settingsCoordinator?.start()
    }
    
    func showProfile(for userID: Int) {
        push(AppPage.profile(userID: userID))
    }
    
    func showProductDetail(for productID: Int) {
        let product = Product(id: productID, name: "Sample Product")
        push(AppPage.productDetail(product: product))
    }
}


// MARK: - SettingsCoordinator
class SettingsCoordinator: ObservableObject, Coordinator {
    @Binding var navigationPath: NavigationPath
    
    init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
    }
    
    func start() {
        push(SettingsPage.main)
    }
    
    func push<T: Hashable>(_ page: T) {
        navigationPath.append(page)
    }
    
    enum SettingsPage: Hashable {
        case main
        case privacy
        case notifications
        // Add other settings pages as needed
    }
}


struct Product: Hashable {
    let id: Int
    let name: String
}

struct User: Hashable {
    let id: Int
    let name: String
}

// MARK: - AppContentView
struct AppContentView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        NavigationStack(path: $appCoordinator.navigationPath) {
            HomeView()
                .environmentObject(appCoordinator)
                .navigationDestination(for: AppCoordinator.AppPage.self) { page in
                    switch page {
                    case .home:
                        HomeView()
                    case .settings:
                        SettingsView()
                            .environmentObject(appCoordinator)
                    case .profile(let userID):
                        ProfileView(userID: userID)
                    case .productDetail(let product):
                        ProductDetailView(product: product)
                    }
                }
        }
        .onAppear {
            appCoordinator.start()
        }
        .onOpenURL { url in
            appCoordinator.handleDeepLink(url)
        }
    }
}

// MARK: - HomeView
struct HomeView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Home View")
                .font(.largeTitle)
            
            Button("Go to Settings") {
                appCoordinator.showSettings()
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Button("View Profile") {
                appCoordinator.showProfile(for: 42) // Example user ID
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Button("View Product Detail") {
                appCoordinator.showProductDetail(for: 101) // Example product ID
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - SettingsView
struct SettingsView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
            
            Button("Privacy Settings") {
                appCoordinator.settingsCoordinator?.push(SettingsCoordinator.SettingsPage.privacy)
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Button("Notification Settings") {
                appCoordinator.settingsCoordinator?.push(SettingsCoordinator.SettingsPage.notifications)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .navigationDestination(for: SettingsCoordinator.SettingsPage.self) { page in
            switch page {
            case .main:
                SettingsView()
            case .privacy:
                PrivacySettingsView()
            case .notifications:
                NotificationSettingsView()
            }
        }
        .padding()
    }
}

// MARK: - ProfileView
struct ProfileView: View {
    let userID: Int
    
    var body: some View {
        VStack {
            Text("Profile View")
                .font(.largeTitle)
            Text("User ID: \(userID)")
        }
        .padding()
    }
}

// MARK: - ProductDetailView
struct ProductDetailView: View {
    let product: Product
    
    var body: some View {
        VStack {
            Text("Product Detail")
                .font(.largeTitle)
            Text("Product ID: \(product.id)")
            Text("Product Name: \(product.name)")
        }
        .padding()
    }
}

// MARK: - PrivacySettingsView
struct PrivacySettingsView: View {
    var body: some View {
        VStack {
            Text("Privacy Settings")
                .font(.largeTitle)
            // Privacy settings content goes here
        }
        .padding()
    }
}

// MARK: - NotificationSettingsView
struct NotificationSettingsView: View {
    var body: some View {
        VStack {
            Text("Notification Settings")
                .font(.largeTitle)
            // Notification settings content goes here
        }
        .padding()
    }
}

//MARK: - PrimaryButtonStyle
struct PrimaryButtonStyle: ButtonStyle {
    var backgroundColor: Color = .blue
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

extension AppCoordinator {
    func handleDeepLink(_ url: URL) {
        // Parse the URL and determine the destination
        // For example, if the URL is myapp://product/101
        if url.host == "product", let idString = url.pathComponents.last, let productID = Int(idString) {
            showProductDetail(for: productID)
        }
        // Handle other deep link cases
    }
}
