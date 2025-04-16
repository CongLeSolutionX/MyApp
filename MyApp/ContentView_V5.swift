//
//  ContentView_V5.swift
//  MyApp
//
//  Created by Cong Le on 4/16/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - App Icon Enum (New)
// Represents possible app icons a user might select.
// RawValue String matches asset catalog names (if implementing actual icon changing)
// CaseIterable allows easy iteration (e.g., in a Picker)
enum AppIcon: String, CaseIterable, Identifiable {
    case classic = "AppIcon" // Default
    case dark = "AppIcon-Dark"
    case light = "AppIcon-Light"
    case vintage = "AppIcon-Vintage"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .classic: return "Classic Blue"
        case .dark: return "Midnight Dark"
        case .light: return "Arctic Light"
        case .vintage: return "Retro Vibes"
        }
    }
    
    // Helper to get icon name for display in UI
    var iconName: String {
        switch self {
        case .classic: return "paintbrush.fill"
        case .dark: return "moon.fill"
        case .light: return "sun.max.fill"
        case .vintage: return "film.fill"
        }
    }
}

// MARK: - Updated SettingsManaging Protocol
protocol SettingsManaging {
    var isDarkModeEnabled: Bool { get set }
    var username: String { get set }
    // --- New Requirements ---
    var notificationsEnabled: Bool { get set }
    var selectedAppIcon: AppIcon { get set }
    func resetAllSettings() // Renamed for clarity
}

// MARK: - Updated UserDefaultsSettingsService Implementation
class UserDefaultsSettingsService: SettingsManaging {
    private let userDefaults: UserDefaults
    private let darkModeKey = "settings_isDarkModeEnabled"
    private let usernameKey = "settings_username"
    // --- New Keys ---
    private let notificationsKey = "settings_notificationsEnabled"
    private let appIconKey = "settings_appIcon"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        // **Register Defaults:** Set initial default values if none exist.
        // This ensures the service returns *something* meaningful on first launch.
        userDefaults.register(defaults: [
            darkModeKey: false, // Default to light mode
            usernameKey: "Guest", // Default username
            notificationsKey: true, // Default to notifications enabled
            appIconKey: AppIcon.classic.rawValue // Default to classic icon
        ])
        print("   -> UserDefaultsSettingsService Initialized (Defaults Registered)")
    }
    
    deinit { print("   -> UserDefaultsSettingsService Deinitialized") }
    
    // --- Protocol Properties (Existing) ---
    var isDarkModeEnabled: Bool {
        get { userDefaults.bool(forKey: darkModeKey) }
        set { save(value: newValue, forKey: darkModeKey, description: "Dark Mode") }
    }
    
    var username: String {
        get { userDefaults.string(forKey: usernameKey) ?? AppIcon.classic.rawValue /* Default fallback */ }
        set {
            let trimmedValue = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let valueToSave = trimmedValue.isEmpty ? "Guest" : trimmedValue
            save(value: valueToSave, forKey: usernameKey, description: "Username")
        }
    }
    
    // --- Protocol Properties (New) ---
    var notificationsEnabled: Bool {
        get { userDefaults.bool(forKey: notificationsKey) }
        set { save(value: newValue, forKey: notificationsKey, description: "Notifications") }
    }
    
    var selectedAppIcon: AppIcon {
        get {
            // Get the raw string value, default to classic if invalid/missing
            let rawValue = userDefaults.string(forKey: appIconKey) ?? AppIcon.classic.rawValue
            // Attempt to create the Enum case from the raw value
            return AppIcon(rawValue: rawValue) ?? .classic // Fallback to classic
        }
        set {
            // Save the raw string value of the Enum case
            save(value: newValue.rawValue, forKey: appIconKey, description: "App Icon")
            // **Placeholder:** In a real app, you'd trigger the UIApplication.shared.setAlternateIconName here
            print("   -> (Placeholder) Would attempt to set alternate app icon to: \(newValue.rawValue)")
            // Handle potential errors from setAlternateIconName if implementing
        }
    }
    
    // --- Protocol Methods ---
    func resetAllSettings() {
        print("⚙️ Settings Service: Resetting All Settings to Defaults...")
        // Remove the keys, letting the registered defaults take over next time they're read
        userDefaults.removeObject(forKey: darkModeKey)
        userDefaults.removeObject(forKey: usernameKey)
        userDefaults.removeObject(forKey: notificationsKey)
        userDefaults.removeObject(forKey: appIconKey)
        print("   -> Settings Reset Complete.")
        // Note: isDarkModeEnabled, username etc. will now return the registered defaults
    }
    
    // --- Private Helper ---
    // Generic helper to avoid redundant save logic and logging
    private func save<T>(value: T, forKey key: String, description: String) {
        // Check if the value is actually different before saving
        // Use `object(forKey:)` for comparison as types might differ slightly (e.g., String vs Optional<String>)
        if let currentValue = userDefaults.object(forKey: key) as? T, currentValue == value {
            print("⚙️ Settings Service: \(description) value unchanged ('\(value)'), skipping save.")
        } else {
            print("⚙️ Settings Service: Setting \(description) = \(value)")
            userDefaults.set(value, forKey: key)
        }
    }
}


// MARK: - Settings Detail ViewModel

@MainActor
class SettingsDetailViewModel: ObservableObject {
    // --- Injected Dependency ---
    // Uses the *same* shared instance of SettingsManaging as MainViewModel
    @Inject private var settings: SettingsManaging
    
    // --- Published Properties for UI Binding ---
    @Published var username: String = "" {
        didSet { if oldValue != username { usernameSubject.send(username) } }
    }
    @Published var notificationsEnabled: Bool = false {
        didSet { if oldValue != notificationsEnabled { persistNotificationsSetting() } }
    }
    @Published var selectedAppIcon: AppIcon = .classic {
        didSet { if oldValue != selectedAppIcon { persistAppIconSetting() } }
    }
    
    // State for UI feedback (e.g., loading indicator, confirmation)
    @Published private(set) var isSavingUsername: Bool = false
    @Published var showResetConfirmation: Bool = false // For the alert dialog
    
    // --- Combine Setup for Debouncing Username ---
    private var cancellables = Set<AnyCancellable>()
    private let usernameSubject = PassthroughSubject<String, Never>()
    private let debounceInterval: TimeInterval = 0.8
    
    init() {
        print("🔄 SettingsDetailViewModel Initializing...")
        // Load initial state directly from the shared settings service
        loadCurrentSettings()
        setupUsernameDebouncer()
        print("🔄 SettingsDetailViewModel Initialization Complete")
    }
    
    /// Loads the current settings from the service into the @Published properties.
    private func loadCurrentSettings() {
        print("ViewModel (Detail): Loading settings from service...")
        self.username = settings.username
        self.notificationsEnabled = settings.notificationsEnabled
        self.selectedAppIcon = settings.selectedAppIcon
        print("   -> Loaded: User='\(username)', Notifications=\(notificationsEnabled), Icon=\(selectedAppIcon.displayName)")
    }
    
    /// Configures the Combine pipeline for username debouncing.
    private func setupUsernameDebouncer() {
        usernameSubject
            .debounce(for: .seconds(debounceInterval), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] debouncedUsername in
                print("ViewModel (Detail): Debounced username received: '\(debouncedUsername)'")
                self?.persistUsername(name: debouncedUsername)
            }
            .store(in: &cancellables)
        print("⚡️ Username debouncer pipeline configured (Detail VM)")
    }
    
    // --- Persistence Methods (called by Combine or didSet) ---
    
    private func persistUsername(name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            print("ViewModel (Detail): Username is empty after trimming, not saving.")
            // Optionally reset UI field?
            // self.username = settings.username
            return
        }
        
        print("ViewModel (Detail): Attempting to persist Username = '\(trimmedName)'")
        isSavingUsername = true
        
        // Simulate delay (optional)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self = self else { return }
            self.settings.username = trimmedName // Save using the service
            
            // Update UI if service modified the value
            let actualSavedUsername = self.settings.username
            if self.username != actualSavedUsername {
                print("ViewModel (Detail): Service layer modified username. Updating UI.")
                self.username = actualSavedUsername // Sync UI without re-triggering debounce
            }
            
            self.isSavingUsername = false
            print("ViewModel (Detail): Username persistence complete.")
        }
    }
    
    private func persistNotificationsSetting() {
        print("ViewModel (Detail): Persisting Notifications = \(notificationsEnabled)")
        settings.notificationsEnabled = notificationsEnabled
    }
    
    private func persistAppIconSetting() {
        print("ViewModel (Detail): Persisting App Icon = \(selectedAppIcon.displayName)")
        settings.selectedAppIcon = selectedAppIcon
        // Actual icon changing logic would be triggered by the service `didSet`
    }
    
    // --- Action Methods ---
    
    /// Triggers the confirmation dialog for resetting settings.
    func requestResetConfirmation() {
        print("ViewModel (Detail): ACTION - Request Reset Confirmation")
        showResetConfirmation = true
    }
    
    /// Performs the reset action after confirmation.
    func performResetAllSettings() {
        print("ViewModel (Detail): ACTION - Perform Reset All Settings")
        settings.resetAllSettings()
        // **Crucial:** Reload settings into the ViewModel to reflect the reset state in the UI
        loadCurrentSettings()
        print("   -> Settings reset and ViewModel reloaded.")
    }
    
    // --- Cleanup ---
    deinit {
        print("🗑️ SettingsDetailViewModel Deinitializing...")
        cancellables.forEach { $0.cancel() }
        print("   - Combine subscriptions cancelled (Detail VM).")
        print("🗑️ SettingsDetailViewModel Deinitialized")
    }
}

// MARK: - Settings Detail View (New Screen)

struct SettingsDetailView: View {
    // Create and own the ViewModel instance specific to this view
    @StateObject private var viewModel = SettingsDetailViewModel()
    
    // Access environment value if needed (e.g., presentation mode to dismiss)
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            // --- User Profile Section ---
            Section("Profile") {
                HStack {
                    Label("Username", systemImage: "person.crop.circle")
                    TextField("Enter username", text: $viewModel.username)
                        .multilineTextAlignment(.trailing)
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    // Saving Indicator
                    if viewModel.isSavingUsername {
                        ProgressView().scaleEffect(0.7).padding(.leading, 4)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Color.clear.frame(width: 15, height: 15) // Layout stability
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.isSavingUsername)
                
                // Could add more fields like Email, Profile Picture upload button etc.
                Button("Edit Profile Picture (Placeholder)") {
                    print("UI Action: Edit Profile Picture Tapped")
                    // Placeholder for action
                }
            }
            
            // --- Notifications Section ---
            Section { // Footer text provides context
                Toggle(isOn: $viewModel.notificationsEnabled) {
                    Label("Enable Push Notifications", systemImage: viewModel.notificationsEnabled ? "bell.badge.fill" : "bell.slash")
                        .foregroundColor(viewModel.notificationsEnabled ? .blue : .secondary)
                }
                .tint(.blue)
            } header: {
                Text("Notifications")
            } footer: {
                Text("Receive updates about new features and important announcements.")
                    .font(.caption) // Smaller text for footer
            }
            
            // --- Appearance Section ---
            Section("Appearance") {
                // App Icon Picker
                Picker(selection: $viewModel.selectedAppIcon) {
                    // Iterate over all possible AppIcon cases
                    ForEach(AppIcon.allCases) { icon in
                        Label {
                            Text(icon.displayName).tag(icon) // Use enum case as tag
                        } icon: {
                            Image(systemName: icon.iconName)
                                .foregroundColor(iconColor(for: icon)) // Dynamic color
                        }
                    }
                } label: {
                    Label("App Icon", systemImage: "app.badge")
                }
                // Optional a style like .inline or .menu if preferred
                // .pickerStyle(.inline)
                
                // Can add Dark Mode toggle here too, or rely on the main screen's toggle
                // Toggle("Enable Dark Mode", isOn: $viewModel.isDarkModeEnabled) // If managed here too
            }
            
            // --- Data Management Section ---
            Section("Data Management") {
                Button(role: .destructive) { // Destructive role for clarity
                    viewModel.requestResetConfirmation() // Trigger confirmation alert
                } label: {
                    Label("Reset All Settings", systemImage: "trash")
                        .foregroundColor(.red) // Emphasize destructive action
                }
                // Could add "Clear Cache", "Export Data" etc.
                Button("Clear Cache (Placeholder)") {
                    print("UI Action: Clear Cache Tapped")
                }
            }
            
            // --- About Section ---
            Section("About") {
                HStack {
                    Label("App Version", systemImage: "info.circle")
                    Spacer()
                    // Fetch version from Bundle - good practice
                    Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
                        .foregroundColor(.gray)
                }
                Link(destination: URL(string: "https://www.example.com/privacy")!) { // Replace with actual URL
                    Label("Privacy Policy", systemImage: "lock.shield")
                }
                Link(destination: URL(string: "https://www.example.com/terms")!) { // Replace with actual URL
                    Label("Terms of Service", systemImage: "doc.text")
                }
            }
        }
        .navigationTitle("Detailed Settings")
        .navigationBarTitleDisplayMode(.inline) // More compact title
        // Alert for reset confirmation, bound to ViewModel state
        .alert("Reset Settings?", isPresented: $viewModel.showResetConfirmation) {
            // Confirmation Actions
            Button("Reset", role: .destructive) {
                viewModel.performResetAllSettings()
            }
            Button("Cancel", role: .cancel) {} // No action needed for cancel
        } message: {
            Text("Are you sure you want to reset all settings to their defaults? This action cannot be undone.")
        }
        .onAppear {
            print("🖼️ SettingsDetailView Appeared")
            // Optional: Reload if settings could somehow change while view is hidden
            // viewModel.loadCurrentSettings()
        }
        .onDisappear { print("🖼️ SettingsDetailView Disappeared") }
    }
    
    // Helper for picker icon colors
    func iconColor(for icon: AppIcon) -> Color {
        switch icon {
        case .classic: return .blue
        case .dark: return .indigo
        case .light: return .orange
        case .vintage: return .brown
        }
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


// MARK: - Preview Provider for SettingsDetailView
#Preview("Settings Detail") { // Added label for clarity in preview list
    // Use the same setup helper pattern as ContentView
    struct SettingsDetailView_Preview: View {
        init() {
            print("\n--- Preview Setup (SettingsDetailView) ---")
            DependenciesInjector.resetForTesting() // CRITICAL: Reset DI state
            AppModule.inject() // Register dependencies needed by the ViewModel
            print("--- Preview Setup Complete ---\n")
        }
        
        var body: some View {
            // Embed in NavigationView for realistic preview context
            NavigationView {
                SettingsDetailView()
            }
            // You can force dark mode for previewing that state:
            // .preferredColorScheme(.dark)
        }
    }
    return SettingsDetailView_Preview()
}


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
    // @Environment(\.userDefaults) var userDefaults
    
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
                // Inside ContentView's body -> Form -> Section("Settings")
                
                Section("Settings") {
                    // Username TextField (Existing - Keep as is)
                    HStack {
                        Label("Username:", systemImage: "person.fill")
                        TextField("Enter username", text: $viewModel.username)
                            .multilineTextAlignment(.trailing)
                            .submitLabel(.done)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        if viewModel.isSavingUsername {
                            ProgressView().scaleEffect(0.7).padding(.leading, 4)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Color.clear.frame(width: 15, height: 15)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: viewModel.isSavingUsername)
                    
                    // Dark Mode Toggle (Existing - Keep as is)
                    Toggle(isOn: $viewModel.isDarkModeEnabled) {
                        Label("Enable Dark Mode", systemImage: viewModel.isDarkModeEnabled ? "moon.stars.fill" : "sun.max.fill")
                            .foregroundColor(viewModel.isDarkModeEnabled ? .indigo : .orange)
                    }
                    .tint(viewModel.isDarkModeEnabled ? .purple : .blue)
                    
                    // --- NEW: Navigation Link to Detail View ---
                    NavigationLink {
                        // Destination View: Create the detail view here.
                        // @StateObject inside SettingsDetailView will ensure its ViewModel is created
                        // when this view is navigated to.
                        SettingsDetailView()
                    } label: {
                        // How the link looks in the list
                        Label("Advanced Settings", systemImage: "gearshape.2.fill")
                    }
                    // --- End New Navigation Link ---
                }
                
                // Debug section (Keep as is)
#if DEBUG
                // ... (rest of debug section)
#endif
                //                Section("Settings") {
                //                    // Username TextField with Saving Indicator
                //                    HStack {
                //                        Label("Username:", systemImage: "person.fill")
                //
                //                        // Bind TextField directly to the ViewModel's username property
                //                        TextField("Enter username", text: $viewModel.username)
                //                            .multilineTextAlignment(.trailing) // Align text to the right
                //                            .submitLabel(.done) // Keyboard return key says "Done"
                //                            .autocorrectionDisabled() // Often desired for usernames
                //                            .textInputAutocapitalization(.never) // Often desired
                //
                //                        // Saving Indicator - shown conditionally based on ViewModel state
                //                        if viewModel.isSavingUsername {
                //                            ProgressView() // Standard loading spinner
                //                                .scaleEffect(0.7) // Make it slightly smaller
                //                                .padding(.leading, 4)
                //                                // Smooth transition for appearance/disappearance
                //                                .transition(.scale(scale: 0.5, anchor: .center).combined(with: .opacity))
                //                        } else {
                //                            // **Layout Stability:** Add an invisible placeholder to prevent layout jumps
                //                            // when the ProgressView appears/disappears. Match its approximate size.
                //                             Color.clear.frame(width: 15, height: 15) // Adjust size as needed
                //                        }
                //                    }
                //                     // Animate the presence of the saving indicator smoothly
                //                    .animation(.easeInOut(duration: 0.2), value: viewModel.isSavingUsername)
                //
                //                    // Dark Mode Toggle
                //                    // Bind Toggle directly to the ViewModel's isDarkModeEnabled property
                //                    Toggle(isOn: $viewModel.isDarkModeEnabled) {
                //                        // Use dynamic icon and color based on state
                //                        Label("Enable Dark Mode", systemImage: viewModel.isDarkModeEnabled ? "moon.stars.fill" : "sun.max.fill")
                //                            .foregroundColor(viewModel.isDarkModeEnabled ? .indigo : .orange)
                //                    }
                //                    // Tint the toggle switch itself
                //                    .tint(viewModel.isDarkModeEnabled ? .purple : .blue)
                //                }
                
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
            // .toolbar {
            //     ToolbarItem(placement: .navigationBarTrailing) {
            //         Button("Info", systemImage: "info.circle") { /* Show info */ }
            //     }
            // }
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

