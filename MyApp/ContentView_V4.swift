//
//  ContentView_V4.swift
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

// --- Protocol Definition ---
protocol Counter {
    func increment() -> Int
    func reset() -> Int // Return new count after reset
    func getCurrentCount() -> Int
}

// --- Concrete Implementation ---
class SingleCounter: Counter {
    // Private state, only accessible via protocol methods
    private var currentCount: Int = 0 {
        didSet { print("⏱️ Counter Service: State changed to \(currentCount)") }
    }
    
    init() { print("   -> SingleCounter Service Initialized") }
    deinit { print("   -> SingleCounter Service Deinitialized") }
    
    // --- Protocol Methods ---
    func increment() -> Int {
        // Basic logic, could be more complex (e.g., network fetch, calculation)
        currentCount += 1
        return currentCount
    }
    
    func reset() -> Int {
        currentCount = 0
        return currentCount
    }
    
    func getCurrentCount() -> Int {
        // Return current state without modifying it
        return currentCount
    }
}

// MARK: - Dependency 2: Settings Service

// --- Protocol Definition ---
protocol SettingsManaging {
    var isDarkModeEnabled: Bool { get set }
    var username: String { get set }
    func clearAllSettings() // Added for potential testing/reset
}

// --- Concrete Implementation using UserDefaults ---
class UserDefaultsSettingsService: SettingsManaging {
    private let userDefaults: UserDefaults
    // Use explicit keys to avoid collisions and improve clarity
    private let darkModeKey = "settings_isDarkModeEnabled"
    private let usernameKey = "settings_username"
    
    // Allow injecting UserDefaults instance for testability
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        print("   -> UserDefaultsSettingsService Initialized (Using \(userDefaults == .standard ? "Standard" : "Custom") UserDefaults)")
    }
    
    deinit { print("   -> UserDefaultsSettingsService Deinitialized") }
    
    // --- Protocol Properties ---
    var isDarkModeEnabled: Bool {
        get {
            let value = userDefaults.bool(forKey: darkModeKey)
            print("⚙️ Settings Service: Getting Dark Mode = \(value)")
            return value
        }
        set {
            // Only print/save if the value actually changes
            if userDefaults.bool(forKey: darkModeKey) != newValue {
                print("⚙️ Settings Service: Setting Dark Mode = \(newValue)")
                userDefaults.set(newValue, forKey: darkModeKey)
            } else {
                print("⚙️ Settings Service: Dark Mode value unchanged (\(newValue)), skipping save.")
            }
        }
    }
    
    var username: String {
        get {
            // Provide a default "Guest" value if nothing is stored
            let value = userDefaults.string(forKey: usernameKey) ?? "Guest"
            print("⚙️ Settings Service: Getting Username = '\(value)'")
            return value
        }
        set {
            // **Input Validation:** Trim whitespace and ensure not empty.
            let trimmedValue = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let valueToSave = trimmedValue.isEmpty ? "Guest" : trimmedValue // Fallback to "Guest" if empty
            
            // Only print/save if the validated value actually changes
            if userDefaults.string(forKey: usernameKey) != valueToSave {
                print("⚙️ Settings Service: Setting Username = '\(valueToSave)' (Original input: '\(newValue)')")
                userDefaults.set(valueToSave, forKey: usernameKey)
            } else {
                print("⚙️ Settings Service: Username value unchanged ('\(valueToSave)'), skipping save.")
            }
        }
    }
    
    // --- Additional Utility Method ---
    func clearAllSettings() {
        print("⚙️ Settings Service: Clearing all stored settings under managed keys...")
        userDefaults.removeObject(forKey: darkModeKey)
        userDefaults.removeObject(forKey: usernameKey)
        // Ensure UserDefaults persists the removal immediately if needed
        // userDefaults.synchronize() // Usually not necessary, system handles it
    }
}

// MARK: - Dependency Provider Module

struct AppModule {
    @MainActor
    static func inject() {
        print("--- AppModule Injecting Dependencies ---")
        // Create and register the counter service
        @Provider var counter: Counter = SingleCounter()
        // Create and register the settings service (using standard UserDefaults by default)
        @Provider var settings: SettingsManaging = UserDefaultsSettingsService()
        // Add more providers here for other dependencies...
        print("--- AppModule Injection Complete ---")
    }
}

// MARK: - Example ViewModel (Consumer)

@MainActor // Ensure ViewModel runs on the main actor for UI safety
class MainViewModel: ObservableObject {
    // --- Injected Dependencies (resolved automatically) ---
    @Inject private var counter: Counter
    @Inject private var settings: SettingsManaging
    
    // --- Published Properties for UI Binding ---
    @Published var count: Int = 0
    @Published var isDarkModeEnabled: Bool = false {
        // Persist change *only if* the new value is different
        didSet { if oldValue != isDarkModeEnabled { persistDarkModeSetting() } }
    }
    @Published var username: String = "" {
        // Use Combine pipeline for debounced saving, don't save directly here
        didSet { if oldValue != username { usernameSubject.send(username) } }
    }
    // Read-only property for the view to observe saving state
    @Published private(set) var isSavingUsername: Bool = false
    
    // --- Combine Setup for Debouncing ---
    private var cancellables = Set<AnyCancellable>()
    // Subject to push username changes into the Combine pipeline
    private let usernameSubject = PassthroughSubject<String, Never>()
    private let debounceInterval: TimeInterval = 0.8 // Wait 0.8 seconds after typing stops
    
    init() {
        print("🔄 MainViewModel Initializing...")
        // Initialize state from injected services ONCE during init
        self.count = counter.getCurrentCount()
        self.isDarkModeEnabled = settings.isDarkModeEnabled
        self.username = settings.username // Load initial username
        
        // Set up the Combine pipeline for handling username changes
        setupUsernameDebouncer()
        
        print("🔄 MainViewModel Initialization Complete (Initial State: Count=\(count), DarkMode=\(isDarkModeEnabled), User='\(username)')")
    }
    
    /// Configures the Combine pipeline to debounce username input and trigger persistence.
    private func setupUsernameDebouncer() {
        usernameSubject
        // Wait for the specified interval after the last value was published
            .debounce(for: .seconds(debounceInterval), scheduler: RunLoop.main) // Debounce on main thread
        // Only proceed if the value actually changed after debouncing
            .removeDuplicates()
        // Trigger the persistence logic when a debounced value arrives
            .sink { [weak self] debouncedUsername in
                print("ViewModel: Debounced username received: '\(debouncedUsername)'")
                self?.persistUsername(name: debouncedUsername)
            }
        // Store the subscription to keep it alive
            .store(in: &cancellables)
        print("⚡️ Username debouncer pipeline configured (\(debounceInterval)s interval)")
    }
    
    // --- UI Action Methods ---
    
    /// Called by the Increment button in the View.
    func incrementCounter() {
        print("ViewModel ACTION: incrementCounter")
        count = counter.increment() // Update state using the service
    }
    
    /// Called by the Reset button in the View.
    func resetCounter() {
        print("ViewModel ACTION: resetCounter")
        count = counter.reset() // Update state using the service
    }
    
    // --- Persistence Logic (Triggered by Combine or didSet) ---
    
    /// Persists the dark mode setting using the injected service.
    private func persistDarkModeSetting() {
        print("ViewModel: Persisting Dark Mode = \(isDarkModeEnabled)")
        settings.isDarkModeEnabled = isDarkModeEnabled
    }
    
    /// Persists the username using the injected service, showing an indicator.
    /// Triggered by the Combine debouncer.
    private func persistUsername(name: String) {
        // **Perform validation here (as service also validates)**
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Don't proceed if the name becomes empty after trimming
        guard !trimmedName.isEmpty else {
            print("ViewModel: Username is empty after trimming, not saving.")
            // Optionally reset the UI field back to the last valid saved name?
            // self.username = settings.username // Reset UI to last known good value
            return
        }
        
        print("ViewModel: Attempting to persist Username = '\(trimmedName)'")
        // Update the UI to show the saving indicator
        isSavingUsername = true
        
        // Simulate a tiny delay for visual feedback (optional, good for UX)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self = self else { return }
            
            // Perform the actual save using the settings service
            self.settings.username = trimmedName
            
            // **Important:** Update the @Published var *if* the service modified the value
            // (e.g., due to its own validation rules or defaults like "Guest").
            // This ensures UI consistency if the persistence layer changes the input.
            let actualSavedUsername = self.settings.username
            if self.username != actualSavedUsername {
                print("ViewModel: Service layer modified username ('\(trimmedName)' -> '\(actualSavedUsername)'). Updating UI.")
                // Manually update the @Published property *without* triggering the subject again
                // This syncs the UI with what was actually saved.
                self.username = actualSavedUsername
            }
            
            // Hide the saving indicator
            self.isSavingUsername = false
            print("ViewModel: Username persistence complete. Saving indicator hidden.")
        }
    }
    
    // --- Cleanup ---
    deinit {
        print("🗑️ MainViewModel Deinitializing...")
        // Cancel all active Combine subscriptions to prevent memory leaks
        cancellables.forEach { $0.cancel() }
        print("   - Combine subscriptions cancelled.")
        print("🗑️ MainViewModel Deinitialized")
    }
}

// MARK: - Example SwiftUI View (UI Layer)

struct ContentView: View {
    // Creates and owns the ViewModel instance. DI occurs inside ViewModel's init.
    // @StateObject ensures the ViewModel persists across view updates.
    @StateObject private var viewModel = MainViewModel()
    
    // Optional: Inject UserDefaults for previews if needed using Environment
     @Environment(\.userDefaults) var userDefaults
    
    var body: some View {
        NavigationView {
            // Use Form for standard grouping and styling of controls
            Form {
                // --- Counter Section ---
                Section("Counter") {
                    HStack {
                        Label("Current Count:", systemImage: "number.circle")
                        Spacer()
                        // Display the count from the ViewModel
                        Text("\(viewModel.count)")
                            .font(.title2.weight(.semibold).monospacedDigit()) // Monospaced for consistent digit width
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.accentColor.opacity(0.15))
                            .clipShape(Capsule())
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.count) // Nice bounce animation
                    }
                    
                    // Buttons side-by-side in an HStack for better layout
                    HStack {
                        // Increment Button
                        Button {
                            viewModel.incrementCounter() // Call ViewModel action
                        } label: {
                            Label("Increment", systemImage: "plus")
                                .frame(maxWidth: .infinity) // Make buttons fill width equally
                        }
                        .buttonStyle(.borderedProminent) // Prominent style for primary action
                        .tint(.green)
                        
                        // Reset Button
                        Button(role: .destructive) { // Use semantic role for reset/destructive actions
                            viewModel.resetCounter() // Call ViewModel action
                        } label: {
                            Label("Reset", systemImage: "arrow.counterclockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered) // Less prominent style for secondary/destructive action
                    }
                }
                
                // --- Settings Section ---
                Section("Settings") {
                    // Username TextField with Saving Indicator
                    HStack {
                        Label("Username:", systemImage: "person.fill")
                        
                        // Bind TextField directly to the ViewModel's username property
                        TextField("Enter username", text: $viewModel.username)
                            .multilineTextAlignment(.trailing) // Align text to the right
                            .submitLabel(.done) // Keyboard return key says "Done"
                            .autocorrectionDisabled() // Often desired for usernames
                            .textInputAutocapitalization(.never) // Often desired
                        
                        // Saving Indicator - shown conditionally based on ViewModel state
                        if viewModel.isSavingUsername {
                            ProgressView() // Standard loading spinner
                                .scaleEffect(0.7) // Make it slightly smaller
                                .padding(.leading, 4)
                            // Smooth transition for appearance/disappearance
                                .transition(.scale(scale: 0.5, anchor: .center).combined(with: .opacity))
                        } else {
                            // **Layout Stability:** Add an invisible placeholder to prevent layout jumps
                            // when the ProgressView appears/disappears. Match its approximate size.
                            Color.clear.frame(width: 15, height: 15) // Adjust size as needed
                        }
                    }
                    // Animate the presence of the saving indicator smoothly
                    .animation(.easeInOut(duration: 0.2), value: viewModel.isSavingUsername)
                    
                    // Dark Mode Toggle
                    // Bind Toggle directly to the ViewModel's isDarkModeEnabled property
                    Toggle(isOn: $viewModel.isDarkModeEnabled) {
                        // Use dynamic icon and color based on state
                        Label("Enable Dark Mode", systemImage: viewModel.isDarkModeEnabled ? "moon.stars.fill" : "sun.max.fill")
                            .foregroundColor(viewModel.isDarkModeEnabled ? .indigo : .orange)
                    }
                    // Tint the toggle switch itself
                    .tint(viewModel.isDarkModeEnabled ? .purple : .blue)
                }
                
                // --- Display Current Settings (For Debug/Confirmation) ---
#if DEBUG // Only show this section in Debug builds
                Section("Stored State (Read-Only Debug)") {
                    HStack {
                        Text("Saved Username:")
                        Spacer()
                        // Reflects the potentially debounced/validated value from VM
                        Text(viewModel.username).foregroundColor(.gray)
                    }
                    HStack {
                        Text("Dark Mode Setting:")
                        Spacer()
                        Text(viewModel.isDarkModeEnabled ? "On" : "Off").foregroundColor(.gray)
                    }
                    HStack {
                        Text("Actual Count:")
                        Spacer()
                        Text("\(viewModel.count)").foregroundColor(.gray)
                    }
                }
                .font(.caption) // Make debug info less prominent
#endif
                
            }
            .navigationTitle("Enhanced ADI App")
            // Optional: Add toolbar items if needed
             .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button("Info", systemImage: "info.circle") {
                         print("Button info tapped!")
                     }
                 }
             }
            // **Apply the dark mode preference to the view hierarchy**
            .preferredColorScheme(viewModel.isDarkModeEnabled ? .dark : .light)
            // Animate the theme change transition
            .animation(.easeInOut, value: viewModel.isDarkModeEnabled)
            .onAppear { print("🖼️ ContentView Appeared") }
            .onDisappear { print("🖼️ ContentView Disappeared") }
        }
        // Optional: Inject specific UserDefaults for Previews/Testing if necessary
        // .environment(\.userDefaults, UserDefaults(suiteName: "previewDefaults"))
        // .environmentObject(configureMockViewModel()) // Alternative for testing with mock VM
    }
}

// MARK: - Application Entry Point

@main
struct DependencyInjectorApp: App {
    init() {
        print("🚀>>> App Starting - Injecting Dependencies <<<🚀")
        // Inject all dependencies defined in AppModule when the app starts
        AppModule.inject()
        print("🚀>>> App Initialization Complete <<<🚀")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView() // The main view of the app
        }
    }
}

// MARK: - Environment Key for UserDefaults (Optional but good practice for previews/testing)

private struct UserDefaultsKey: EnvironmentKey {
    static let defaultValue: UserDefaults = .standard
}

extension EnvironmentValues {
    var userDefaults: UserDefaults {
        get { self[UserDefaultsKey.self] }
        set { self[UserDefaultsKey.self] = newValue }
    }
}

// MARK: - SwiftUI Preview Provider

#Preview {
    // Helper struct for clean preview setup, ensuring DI reset for each preview refresh
    struct ContentView_Preview: View {
        init() {
            print("\n--- Preview Setup ---")
            // **Crucial for Previews:** Reset the injector to avoid stale state
            DependenciesInjector.resetForTesting()
            
            // Option 1: Inject real dependencies for preview (simple cases)
            AppModule.inject()
            
            // Option 2: Inject mock dependencies for controlled preview state (more complex cases)
            // DependencyContainer.register(dependency: MockCounterService(initialCount: 5))
            // DependencyContainer.register(dependency: MockSettingsService(darkMode: true, username: "PreviewUser"))
            
            print("--- Preview Setup Complete ---\n")
        }
        
        var body: some View {
            ContentView()
            // Example: Provide specific UserDefaults ONLY for this preview run
            // .environment(\.userDefaults, UserDefaults(suiteName: "MyUniquePreviewSuite"))
            // Optional: Provide a specifically configured ViewModel for previews
            // .environmentObject(MainViewModel(mockCounter: ..., mockSettings: ...)) // If VM init supports mocks
        }
    }
    
    // Return the helper struct instance for the preview canvas
    return ContentView_Preview()
}
