//
//  ContentView_V3.swift
//  MyApp
//
//  Created by Cong Le on 4/16/25.
//

import Foundation
import SwiftUI
import Combine // Needed for debounce

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

    /// Private initializer to enforce the singleton pattern.
    private init() {
        print("🔧 DependenciesInjector Initialized (Singleton)")
    }

    /// Resolves and returns a previously registered dependency instance.
    func resolve<T>() -> T {
        let key = String(describing: T.self)
        guard let dependency = dependencyList[key] as? T else {
            fatalError("""
            ❌ Dependency Resolution Error: No provider registered for type '\(key)'.
               Ensure a @Provider exists in AppModule and AppModule.inject() was called.
            """)
        }
        print("✅ Resolved dependency for type: \(key)")
        return dependency
    }

    /// Registers a dependency instance. Overwrites and warns if the type exists.
    mutating func register<T>(dependency: T) {
        let key = String(describing: T.self)
        if dependencyList[key] != nil {
            print("⚠️ Overwriting previously registered dependency for type: \(key)")
        }
        print("🔵 Registering dependency for type: \(key)")
        dependencyList[key] = dependency
    }

    /// Resets the injector (useful for testing or previews).
    static func resetForTesting() {
        print("⚠️ Resetting DependenciesInjector for testing/preview.")
        shared = DependenciesInjector()
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
        var mutableInjector = DependenciesInjector.shared // Must mutate a copy
        mutableInjector.register(dependency: wrappedValue)
        DependenciesInjector.shared = mutableInjector // Persist changes
    }
}

// MARK: - Dependency 1: Counter Service

protocol Counter {
    func increment() -> Int
    func reset() -> Int // Return new count after reset
    func getCurrentCount() -> Int
}

class SingleCounter: Counter {
    private var currentCount: Int = 0 {
        didSet { print("⏱️ Counter Service: State changed to \(currentCount)") }
    }

    init() { print("   -> SingleCounter Service Initialized") }
    deinit { print("   -> SingleCounter Service Deinitialized") }

    func increment() -> Int {
        currentCount += 1
        return currentCount
    }

    func reset() -> Int {
        currentCount = 0
        return currentCount
    }

    func getCurrentCount() -> Int {
        return currentCount
    }
}

// MARK: - Dependency 2: Settings Service

protocol SettingsManaging {
    var isDarkModeEnabled: Bool { get set }
    var username: String { get set }
    func clearAllSettings() // Added for potential testing/reset
}

class UserDefaultsSettingsService: SettingsManaging {
    private let userDefaults: UserDefaults
    private let darkModeKey = "settings_isDarkModeEnabled" // More specific keys
    private let usernameKey = "settings_username"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        print("   -> UserDefaultsSettingsService Initialized (Using \(userDefaults == .standard ? "Standard" : "Custom") UserDefaults)")
    }
    deinit { print("   -> UserDefaultsSettingsService Deinitialized") }

    var isDarkModeEnabled: Bool {
        get {
            let value = userDefaults.bool(forKey: darkModeKey)
            print("⚙️ Settings Service: Getting Dark Mode = \(value)")
            return value
        }
        set {
            print("⚙️ Settings Service: Setting Dark Mode = \(newValue)")
            userDefaults.set(newValue, forKey: darkModeKey)
        }
    }

    var username: String {
        get {
            let value = userDefaults.string(forKey: usernameKey) ?? "Guest"
            print("⚙️ Settings Service: Getting Username = '\(value)'")
            return value
        }
        set {
            // Basic validation: Trim whitespace, default to "Guest" if empty after trimming
            let trimmedValue = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let valueToSave = trimmedValue.isEmpty ? "Guest" : trimmedValue
            print("⚙️ Settings Service: Setting Username = '\(valueToSave)' (Original: '\(newValue)')")
            userDefaults.set(valueToSave, forKey: usernameKey)
        }
    }
    
    func clearAllSettings() {
        print("⚙️ Settings Service: Clearing all stored settings...")
        userDefaults.removeObject(forKey: darkModeKey)
        userDefaults.removeObject(forKey: usernameKey)
    }
}

// MARK: - Dependency Provider Module

struct AppModule {
    @MainActor
    static func inject() {
        print("--- AppModule Injecting Dependencies ---")
        @Provider var counter: Counter = SingleCounter()
        // Allow injecting specific UserDefaults for testing/previews if needed later
        @Provider var settings: SettingsManaging = UserDefaultsSettingsService()
        print("--- AppModule Injection Complete ---")
    }
}

// MARK: - Example ViewModel (Consumer)

@MainActor // Ensure ViewModel runs on the main actor for UI safety
class MainViewModel: ObservableObject {
    // --- Injected Dependencies ---
    @Inject private var counter: Counter
    @Inject private var settings: SettingsManaging

    // --- Published Properties for UI Binding ---
    @Published var count: Int = 0
    @Published var isDarkModeEnabled: Bool = false {
        didSet { if oldValue != isDarkModeEnabled { persistDarkModeSetting() } }
    }
    @Published var username: String = "" {
         // Trigger Combine pipeline on change, don't save directly here
        didSet { if oldValue != username { usernameSubject.send(username) } }
    }
    @Published private(set) var isSavingUsername: Bool = false // Read-only for the view

    // --- Combine Setup for Debouncing ---
    private var cancellables = Set<AnyCancellable>()
    private let usernameSubject = PassthroughSubject<String, Never>()
    private let debounceInterval: TimeInterval = 0.8 // Seconds to wait after typing stops

    init() {
        print("🔄 MainViewModel Initializing...")
        // Initialize state from injected services
        self.count = counter.getCurrentCount()
        self.isDarkModeEnabled = settings.isDarkModeEnabled
        self.username = settings.username // Initial load

        setupUsernameDebouncer() // Setup Combine pipeline

        print("🔄 MainViewModel Initialization Complete (Initial State: Count=\(count), DarkMode=\(isDarkModeEnabled), User='\(username)')")
    }

    private func setupUsernameDebouncer() {
        usernameSubject
            .debounce(for: .seconds(debounceInterval), scheduler: RunLoop.main) // Wait on main thread
            .removeDuplicates() // Only save if the value actually changed after debouncing
            .sink { [weak self] debouncedUsername in
                 print("ViewModel: Debounced username received: '\(debouncedUsername)'")
                 self?.persistUsername(name: debouncedUsername)
            }
            .store(in: &cancellables)
            print("⚡️ Username debouncer pipeline configured (\(debounceInterval)s interval)")
    }

    // --- Actions Triggered by UI ---

    func incrementCounter() {
        print("ViewModel ACTION: incrementCounter")
        count = counter.increment()
    }

    func resetCounter() {
        print("ViewModel ACTION: resetCounter")
        count = counter.reset()
    }
    
    // --- Persistence Logic --- (Called by Combine or direct actions)

    private func persistDarkModeSetting() {
        print("ViewModel: Persisting Dark Mode = \(isDarkModeEnabled)")
        settings.isDarkModeEnabled = isDarkModeEnabled
    }

    private func persistUsername(name: String) {
         let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
         
         // Prevent saving if empty after trimming (service also has fallback)
         guard !trimmedName.isEmpty else {
             print("ViewModel: Username is empty after trimming, not saving.")
             // Optionally reset the UI field back to the last valid saved name?
             // self.username = settings.username // Reset UI to last known good value
             return
         }

        print("ViewModel: Attempting to persist Username = '\(trimmedName)'")
        isSavingUsername = true // Show indicator
        
        // Simulate a tiny delay for visual feedback of the indicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
           
            self.settings.username = trimmedName // Perform the actual save
           
            // Important: Update the @Published var *if* the service modified the value (e.g. "Guest" fallback)
            // This ensures UI consistency if the service layer changes the input.
             let actualSavedUsername = self.settings.username
             if self.username != actualSavedUsername {
                 print("ViewModel: Service layer modified username ('\(trimmedName)' -> '\(actualSavedUsername)'). Updating UI.")
                  self.username = actualSavedUsername // Sync UI with what was actually saved
             }
            
            self.isSavingUsername = false // Hide indicator
            print("ViewModel: Username persistence complete. Indicator hidden.")
        }
    }

    // --- Cleanup ---
    deinit {
        print("🗑️ MainViewModel Deinitializing...")
        cancellables.forEach { $0.cancel() } // Cancel Combine subscriptions
         print("   - Combine subscriptions cancelled.")
        // Counter reset is not typically needed here unless it holds temporary session state.
        // Settings persistence happens via actions/Combine.
        print("🗑️ MainViewModel Deinitialized")
    }
}

// MARK: - Example SwiftUI View (UI Layer)

struct ContentView: View {
    // Creates and owns the ViewModel instance. DI occurs in ViewModel's init.
    @StateObject private var viewModel = MainViewModel()
    
    // Optional: Inject UserDefaults for previews if needed
    // @Environment(\.userDefaults) var userDefaults

    var body: some View {
        NavigationView {
            Form {
                // --- Counter Section ---
                Section("Counter") {
                    HStack {
                        Text("Current Count:")
                            .font(Font.body.monospacedDigit()) // Ensure digits align well
                        Spacer()
                        Text("\(viewModel.count)")
                            .font(.title2.weight(.semibold).monospacedDigit())
                            .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                            .background(Color.accentColor.opacity(0.15))
                            .clipShape(Capsule())
                            .animation(.spring(), value: viewModel.count) // Animate count changes
                    }

                    HStack { // Buttons side-by-side
                         Button {
                             viewModel.incrementCounter()
                         } label: {
                             Label("Increment", systemImage: "plus")
                                 .frame(maxWidth: .infinity)
                         }
                         .buttonStyle(.borderedProminent)
                         .tint(.green)

                         Button(role: .destructive) { // Use role for Reset
                             viewModel.resetCounter()
                         } label: {
                             Label("Reset", systemImage: "arrow.counterclockwise")
                                 .frame(maxWidth: .infinity)
                         }
                         .buttonStyle(.bordered) // Less prominent style for reset
                     }
                }

                // --- Settings Section ---
                Section("Settings") {
                    // Username TextField with Saving Indicator
                    HStack {
                       Label("Username:", systemImage: "person.fill")
                       
                       TextField("Enter username", text: $viewModel.username)
                            .multilineTextAlignment(.trailing)
                            .submitLabel(.done)
                            .autocorrectionDisabled() // Often desired for usernames
                            .textInputAutocapitalization(.never) // Often desired

                        // Saving Indicator
                        if viewModel.isSavingUsername {
                            ProgressView()
                                .scaleEffect(0.7) // Make spinner smaller
                                .padding(.leading, 4)
                                .transition(.scale.combined(with: .opacity)) // Animate appearance
                       } else {
                           // Placeholder to prevent layout shifts when ProgressView appears/disappears
                           Color.clear.frame(width: 20, height: 20) // Adjust size based on ProgressView
                       }
                    }
                    .animation(.easeInOut(duration: 0.2), value: viewModel.isSavingUsername) // Animate indicator visibility

                    // Dark Mode Toggle
                    Toggle(isOn: $viewModel.isDarkModeEnabled) {
                        Label("Enable Dark Mode", systemImage: viewModel.isDarkModeEnabled ? "moon.stars.fill" : "sun.max.fill")
                            .foregroundColor(viewModel.isDarkModeEnabled ? .yellow : .orange)
                    }
                    .tint(viewModel.isDarkModeEnabled ? .indigo : .blue) // Change toggle color based on state
                }

                // --- Display Current Settings (For Debug/Confirmation) ---
                Section("Stored State (Read-Only)") {
                    HStack {
                         Text("Saved Username:")
                         Spacer()
                         Text(viewModel.username) // Reflects the debounced, saved value
                     }
                     HStack {
                         Text("Dark Mode Setting:")
                         Spacer()
                         Text(viewModel.isDarkModeEnabled ? "On" : "Off")
                     }
                }
                .foregroundColor(.secondary)
                .font(.footnote)

            }
            .navigationTitle("Enhanced ADI App")
            .toolbar { // Add toolbar items if needed
                ToolbarItem(placement: .navigationBarTrailing) {
                     // Example: Button to potentially clear settings (add method to VM if needed)
                     // Button("Clear", role: .destructive) { viewModel.clearSettings() }
                }
            }
            // APPLY THE DARK MODE PREFERENCE TO THE VIEW HIERARCHY
            .preferredColorScheme(viewModel.isDarkModeEnabled ? .dark : .light)
            .animation(.easeInOut, value: viewModel.isDarkModeEnabled) // Animate theme change
            .onAppear { print("🖼️ ContentView Appeared") }
            .onDisappear { print("🖼️ ContentView Disappeared") }
        }
        // Inject specific UserDefaults for Previews/Testing if necessary
        // .environment(\.userDefaults, UserDefaults(suiteName: "previewDefaults"))
        // .environmentObject(configureMockViewModel()) // Alternative for testing
    }
}

// MARK: - Application Entry Point

@main
struct DependencyInjectorApp: App {
    init() {
        print("🚀>>> App Starting - Injecting Dependencies <<<🚀")
        AppModule.inject()
        print("🚀>>> App Initialization Complete <<<🚀")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Preview

#Preview {
    // Helper struct for clean preview setup
    struct ContentView_Preview: View {
        init() {
            print("\n--- Preview Setup ---")
            DependenciesInjector.resetForTesting() // Ensure clean slate
            // You could inject mock services here for previews if needed:
            // var inj = DependenciesInjector.shared
            // inj.register(dependency: MockCounterService()) // Example
            // DependenciesInjector.shared = inj
             // For this preview, using the real services is fine
             AppModule.inject()
             print("--- Preview Setup Complete ---\n")
        }
        
        var body: some View {
            ContentView()
                 // Example of providing specific UserDefaults for preview
                // .environment(\.userDefaults, UserDefaults(suiteName: "MyPreviewSuite"))
        }
    }

    return ContentView_Preview()
}

// MARK: - Environment Key for UserDefaults (Optional but good practice)

struct UserDefaultsKey: EnvironmentKey {
    static let defaultValue: UserDefaults = .standard
}

extension EnvironmentValues {
    var userDefaults: UserDefaults {
        get { self[UserDefaultsKey.self] }
        set { self[UserDefaultsKey.self] = newValue }
    }
}
