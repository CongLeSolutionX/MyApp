//
//  ContentView_V2.swift
//  MyApp
//
//  Created by Cong Le on 4/16/25.
//

import Foundation
import SwiftUI
import Combine // Needed for debounce if we use it

// MARK: - Core Dependency Injection System (@MainActor Safe)

/**
 A singleton actor responsible for registering and resolving dependencies.
 Marked with @MainActor to ensure thread-safe access to the shared dependency list
 when used from UI or other MainActor-isolated contexts.
 */
@MainActor
struct DependenciesInjector {
    /// The dictionary storing registered dependency instances, keyed by their type name.
    private var dependencyList: [String: Any] = [:]

    /// The shared singleton instance of the injector.
    static var shared = DependenciesInjector()

    /// Private initializer to enforce the singleton pattern. Hides the default public one.
    private init() {
        print("🔧 DependenciesInjector Initialized (Singleton)")
    }

    /**
     Resolves and returns a previously registered dependency instance of the specified type.

     - Throws: `fatalError` if no provider is registered for the requested type `T`.
     - Returns: An instance of the requested type `T`.
     */
    func resolve<T>() -> T {
        let key = String(describing: T.self)
        guard let dependency = dependencyList[key] as? T else {
            // Provide a more descriptive error message
            fatalError("""
            ❌ Dependency Resolution Error:
               No provider registered for type '\(key)'.
               Ensure a @Provider for this type exists in your AppModule
               and AppModule.inject() was called before resolution.
            """)
        }
        print("✅ Resolved dependency for type: \(key)")
        return dependency
    }

    /**
     Registers a dependency instance with the injector.

     If a dependency for the same type already exists, it will be overwritten,
     and a warning will be printed to the console.

     - Parameter dependency: The dependency instance to register.
     */
    mutating func register<T>(dependency: T) {
        let key = String(describing: T.self)
        if dependencyList[key] != nil {
            print("⚠️ Overwriting previously registered dependency for type: \(key)")
        }
        print("🔵 Registering dependency for type: \(key)")
        dependencyList[key] = dependency
    }

    /// DEVELOPMENT ONLY: Helper to reset the injector (useful for testing or previews)
    static func resetForTesting() {
        print("⚠️ Resetting DependenciesInjector for testing/preview.")
        shared = DependenciesInjector() // Create a fresh instance
    }
}

// MARK: - Property Wrappers (@Inject & @Provider)

@MainActor
@propertyWrapper struct Inject<T> {
    var wrappedValue: T

    init() {
        self.wrappedValue = DependenciesInjector.shared.resolve()
        print("🔹 @Inject initialized for type: \(String(describing: T.self))")
    }
}

@MainActor
@propertyWrapper struct Provider<T> {
    var wrappedValue: T

    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        print("🔸 @Provider attempting registration for type: \(String(describing: T.self))")
        // Use a temporary mutable copy to call the mutating register function
        var mutableInjector = DependenciesInjector.shared
        mutableInjector.register(dependency: wrappedValue)
        // Persist the change back to the static shared instance
        DependenciesInjector.shared = mutableInjector
    }
}

// MARK: - Example Dependency 1: Counter

protocol Counter {
    func increment() -> Int
    func reset()
    func getCurrentCount() -> Int
}

class SingleCounter: Counter {
    private var currentCount: Int = 0 {
        didSet {
             print("⏱️ Counter state changed to: \(currentCount)")
        }
    }

    init() {
        print("   -> SingleCounter Service Initialized")
    }
    deinit {
        print("   -> SingleCounter Service Deinitialized")
    }

    func increment() -> Int {
        currentCount += 1
        return currentCount
    }

    func reset() {
        currentCount = 0
    }

    func getCurrentCount() -> Int {
        return currentCount
    }
}

// MARK: - Example Dependency 2: Settings Service

protocol SettingsManaging {
    var isDarkModeEnabled: Bool { get set }
    var username: String { get set }
    
    // Optional: Publisher for real-time updates if needed elsewhere
    // var settingsChangedPublisher: AnyPublisher<Void, Never> { get }
}

class UserDefaultsSettingsService: SettingsManaging {
    private let userDefaults: UserDefaults
    private let darkModeKey = "isDarkModeEnabled"
    private let usernameKey = "username"

    // // Optional: Subject for publisher
    // private let settingsChangedSubject = PassthroughSubject<Void, Never>()
    // var settingsChangedPublisher: AnyPublisher<Void, Never> {
    //     settingsChangedSubject.eraseToAnyPublisher()
    // }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        print("   -> UserDefaultsSettingsService Initialized")
    }
    deinit {
         print("   -> UserDefaultsSettingsService Deinitialized")
    }

    var isDarkModeEnabled: Bool {
        get {
            let value = userDefaults.bool(forKey: darkModeKey) // Defaults to false if not set
            print("⚙️ SettingsService: Getting Dark Mode = \(value)")
            return value
        }
        set {
            print("⚙️ SettingsService: Setting Dark Mode = \(newValue)")
            userDefaults.set(newValue, forKey: darkModeKey)
            // // Optional: Notify subscribers
            // settingsChangedSubject.send()
        }
    }

    var username: String {
        get {
            let value = userDefaults.string(forKey: usernameKey) ?? "Guest" // Default value
            print("⚙️ SettingsService: Getting Username = \(value)")
            return value
        }
        set {
            print("⚙️ SettingsService: Setting Username = \(newValue)")
            userDefaults.set(newValue, forKey: usernameKey)
            // // Optional: Notify subscribers
            // settingsChangedSubject.send()
        }
    }
}

// MARK: - Dependency Provider Module

struct AppModule {
    @MainActor
    static func inject() {
        print("--- AppModule Injecting Dependencies ---")
        
        // Register Counter Dependency
        @Provider var counter: Counter = SingleCounter()
        
        // Register Settings Dependency
        @Provider var settings: SettingsManaging = UserDefaultsSettingsService()
        
        // Add other dependencies here...
        
        print("--- AppModule Injection Complete ---")
    }
}

// MARK: - Example ViewModel (Consumer)

class MainViewModel: ObservableObject {
    // --- Injected Dependencies ---
    @Inject var counter: Counter
    @Inject var settings: SettingsManaging

    // --- Published Properties for UI Binding ---
    @Published var count: Int = 0
    @Published var isDarkModeEnabled: Bool = false {
        // When the UI binding changes this value, persist it via the service.
        didSet {
            if oldValue != isDarkModeEnabled { // Avoid unnecessary saves if value didn't actually change
                 persistDarkModeSetting()
             }
        }
    }
    @Published var username: String = "" {
        // Similar persistence pattern for username
         didSet {
             if oldValue != username {
                 persistUsername()
             }
         }
    }
    
    // --- Cancellables for potential future Combine usage ---
    // private var cancellables = Set<AnyCancellable>()

    init() {
        print("🔄 MainViewModel Initializing")
        // Initialize state from injected services (@MainActor context is safe)
        self.count = counter.getCurrentCount()
        self.isDarkModeEnabled = settings.isDarkModeEnabled
        self.username = settings.username
        
        // ------ Optional: Subscribe to settings changes ------
        // If the SettingsService had a publisher, you could subscribe here
        // to update the @Published properties if settings change externally.
        // settings.settingsChangedPublisher
        //     .receive(on: DispatchQueue.main) // Ensure updates on main thread
        //     .sink { [weak self] in
        //         print("ViewModel reacting to external settings change")
        //         self?.loadSettings()
        //     }
        //     .store(in: &cancellables)
        // ----------------------------------------------------
        
        print("🔄 MainViewModel Initialized (Count: \(count), DarkMode: \(isDarkModeEnabled), User: '\(username)')")
    }

    // --- Actions Triggered by UI ---

    func incrementCounter() {
        print("ViewModel: incrementCounter called")
        count = counter.increment() // Update published state from service
    }

    // These persistence methods are called automatically when @Published vars change (via didSet)
    private func persistDarkModeSetting() {
        print("ViewModel: Persisting Dark Mode = \(isDarkModeEnabled)")
        settings.isDarkModeEnabled = isDarkModeEnabled // Save the current state
    }

    private func persistUsername() {
        print("ViewModel: Persisting Username = \(username)")
        settings.username = username // Save the current state
    }
    
//    // Optional: Method to manually reload settings if needed
//    func loadSettings() {
//        print("ViewModel: Reloading settings")
//        self.isDarkModeEnabled = settings.isDarkModeEnabled
//        self.username = settings.username
//    }

    // --- Cleanup ---
    deinit {
        print("🗑️ MainViewModel Deinitializing...")
        // Safely access the @MainActor isolated 'counter' property from nonisolated deinit
        DispatchQueue.main.sync { // Must sync to main thread
            print("   Dispatching to main thread for counter reset...")
            counter.reset()
            print("   -> Counter reset successfully on main thread.")
       }
       
        // Settings persistence happens automatically via @Published didSet,
        // so typically no extra saving is needed here unless there's complex logic.
       
        print("🗑️ MainViewModel Deinitialized")
    }
}

// MARK: - Example SwiftUI View (UI Layer)

struct ContentView: View {
    // Creates and owns the ViewModel instance. DI happens within ViewModel's init.
    @StateObject private var viewModel: MainViewModel = MainViewModel()

    var body: some View {
        NavigationView { // Add navigation for better structure
            Form { // Use Form for standard grouped controls
                
                // --- Counter Section ---
                Section("Counter") {
                    HStack {
                        Text("Current Count:")
                        Spacer()
                        Text("\(viewModel.count)")
                            .font(.title2.monospacedDigit())
                            .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                            .background(Color.blue.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    
                    Button {
                        viewModel.incrementCounter()
                    } label: {
                        Label("Increment Count", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity) // Make button wider
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
                
                // --- Settings Section ---
                Section("Settings") {
                    // Username TextField
                    HStack {
                       Text("Username:")
                       TextField("Enter username", text: $viewModel.username)
                            .multilineTextAlignment(.trailing)
                            .submitLabel(.done) // Indicate completion
                   }
                    
                    // Dark Mode Toggle
                    Toggle(isOn: $viewModel.isDarkModeEnabled) {
                        Label("Enable Dark Mode", systemImage: viewModel.isDarkModeEnabled ? "moon.fill" : "sun.max.fill")
                    }
                    .tint(.purple) // Customize toggle color
                }
                
                // --- Display Current Settings ---
                 Section("Current State Info") {
                     Text("Stored Username: \(viewModel.username)")
                     Text("Dark Mode Active: \(viewModel.isDarkModeEnabled ? "Yes" : "No")")
                 }
                 .foregroundColor(.gray) // Make info less prominent
                 .font(.footnote)

            }
            .navigationTitle("ADI Example")
             // Apply dark mode preference IF you want the whole app UI to change
             // .preferredColorScheme(viewModel.isDarkModeEnabled ? .dark : .light)
            .onAppear {
                 print("🖼️ ContentView Appeared")
            }
            .onDisappear {
                 print("🖼️ ContentView Disappeared")
            }
        }
    }
}

// MARK: - Application Entry Point

@main
struct DependencyInjectorApp: App {
    init() {
        print("🚀>>> DependencyInjectorApp Initializing <<<🚀")
        // Perform dependency registration ONCE at startup.
        AppModule.inject()
        print("🚀>>> DependencyInjectorApp Initialization Complete<<<🚀")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Preview

#Preview {
    // For the preview, we must ensure dependencies are available.
    // Create a helper struct to manage preview-specific setup.
    struct ContentView_Preview: View {
        init() {
            print("--- Preview Setup ---")
            // It's often best to reset the injector and re-inject for previews
            // to ensure a clean state each time the preview refreshes.
            DependenciesInjector.resetForTesting()
            AppModule.inject()
            print("--- Preview Setup Complete ---")
        }
        
        var body: some View {
            ContentView()
            // Optionally override UserDefaults for preview if needed:
            // .environment(\.userDefaults, UserDefaults(suiteName: "previewDefaults"))
        }
    }

    return ContentView_Preview()
}
