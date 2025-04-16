////
////  ContentView.swift
////  MyApp
////
////  Created by Cong Le on 8/19/24.
////
////
////import SwiftUI
////
////// Step 2: Use in SwiftUI view
////struct ContentView: View {
////    var body: some View {
////        UIKitViewControllerWrapper()
////            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
////    }
////}
////
////// Before iOS 17, use this syntax for preview UIKit view controller
////struct UIKitViewControllerWrapper_Previews: PreviewProvider {
////    static var previews: some View {
////        UIKitViewControllerWrapper()
////    }
////}
////
////// After iOS 17, we can use this syntax for preview:
////#Preview {
////    ContentView()
////}
//
//
//import Foundation
//import SwiftUI
//
//// MARK: - Core Dependency Injection System (@MainActor Safe)
//
///**
// A singleton actor responsible for registering and resolving dependencies.
// Marked with @MainActor to ensure thread-safe access to the shared dependency list
// when used from UI or other MainActor-isolated contexts.
// */
//@MainActor
//struct DependenciesInjector {
//    /// The dictionary storing registered dependency instances, keyed by their type name.
//    private var dependencyList: [String: Any] = [:]
//
//    /// The shared singleton instance of the injector.
//    static var shared = DependenciesInjector()
//
//    /// Private initializer to enforce the singleton pattern.
//    private init() {
//        print("DependenciesInjector Initialized")
//    }
//
//    /**
//     Resolves and returns a previously registered dependency instance of the specified type.
//
//     - Throws: `fatalError` if no provider is registered for the requested type `T`.
//     - Returns: An instance of the requested type `T`.
//     */
//    func resolve<T>() -> T {
//        let key = String(describing: T.self)
//        guard let dependency = dependencyList[key] as? T else {
//            fatalError("❌ No provider registered for type \(key)")
//        }
//        print("✅ Resolved dependency for type: \(key)")
//        return dependency
//    }
//
//    /**
//     Registers a dependency instance with the injector.
//
//     If a dependency for the same type already exists, it will be overwritten.
//
//     - Parameter dependency: The dependency instance to register.
//     */
//    mutating func register<T>(dependency: T) {
//        let key = String(describing: T.self)
//        print("🔵 Registering dependency for type: \(key)")
//        dependencyList[key] = dependency
//    }
//}
//
///**
// A property wrapper that automatically resolves a dependency using the shared `DependenciesInjector`.
//
// Use this wrapper for properties that need an instance provided by the DI container.
// Ensures that the resolution happens on the MainActor.
// */
//@MainActor
//@propertyWrapper struct Inject<T> {
//    /// The resolved dependency instance.
//    var wrappedValue: T
//
//    /**
//     Initializes the wrapper and resolves the dependency immediately.
//     */
//    init() {
//        self.wrappedValue = DependenciesInjector.shared.resolve()
//        print("🔹 @Inject initialized for type: \(String(describing: T.self))")
//    }
//}
//
///**
// A property wrapper that automatically registers the wrapped value as a dependency
// with the shared `DependenciesInjector` upon initialization.
//
// Use this wrapper within your dependency provider modules (e.g., AppModule)
// to register instances that should be injectable elsewhere.
// Ensures that the registration happens on the MainActor.
// */
//@MainActor
//@propertyWrapper struct Provider<T> {
//    /// The dependency instance being provided.
//    var wrappedValue: T
//
//    /**
//     Initializes the wrapper with the dependency instance and registers it immediately.
//     - Parameter wrappedValue: The concrete instance to register.
//     */
//    init(wrappedValue: T) {
//        self.wrappedValue = wrappedValue
//        print("🔸 @Provider initialized for type: \(String(describing: T.self))")
//        // Use a temporary mutable copy to call the mutating register function
//        var mutableInjector = DependenciesInjector.shared
//        mutableInjector.register(dependency: wrappedValue)
//        // Assign the potentially modified injector back to the shared instance
//        // This ensures the registration persists in the singleton.
//        DependenciesInjector.shared = mutableInjector
//    }
//}
//
//// MARK: - Example Dependency: Counter
//
///**
// Protocol defining the contract for a counter dependency.
// This follows the Dependency Inversion Principle (DIP).
// */
//protocol Counter {
//    /// Increments the counter and returns the new value.
//    func increment() -> Int
//    /// Resets the counter to zero.
//    func reset()
//    /// Gets the current count without incrementing.
//    func getCurrentCount() -> Int
//}
//
///**
// A concrete implementation of the `Counter` protocol.
// */
//class SingleCounter: Counter {
//    private var currentCount: Int = 0 {
//        didSet {
//             print("⏱️ Counter changed to: \(currentCount)")
//        }
//    }
//
//    init() {
//        print("SingleCounter Initialized")
//    }
//
//    func increment() -> Int {
//        currentCount += 1
//        return currentCount
//    }
//
//    func reset() {
//        currentCount = 0
//    }
//
//    func getCurrentCount() -> Int {
//        return currentCount
//    }
//
//    deinit {
//        print("SingleCounter Deinitialized")
//    }
//}
//
//// MARK: - Dependency Provider Module
//
///**
// A module responsible for providing and registering all necessary dependencies for the app.
// */
//struct AppModule {
//    /**
//     Static function to trigger the registration of all dependencies defined within this module.
//      Marked @MainActor to ensure providers are initialized and registered safely.
//     */
//    @MainActor
//    static func inject() {
//        print("--- AppModule Injecting Dependencies ---")
//        // The initialization of this @Provider wrapper automatically registers
//        // the SingleCounter instance as the implementation for the Counter protocol.
//        @Provider var counter: Counter = SingleCounter()
//        // Add other dependencies here using @Provider
//        // e.g., @Provider var networkService: NetworkService = RealNetworkService()
//        print("--- AppModule Injection Complete ---")
//    }
//}
//
//// MARK: - Example ViewModel (Consumer)
//
///**
// An example ViewModel demonstrating how to inject and use a dependency.
// */
//class MainViewModel: ObservableObject {
//    // @Inject automatically resolves the Counter dependency provided by AppModule.
//    @Inject var counter: Counter
//
//    // @Published property to drive UI updates.
//    @Published var count: Int = 0
//
//    init() {
//        print("MainViewModel Initializing")
//        // Initialize count with the current value from the injected counter
//        // This ensures the UI starts with the correct state if the counter wasn't 0.
//        // Accessing 'counter' here is safe because both init and @Inject are @MainActor.
//        self.count = counter.getCurrentCount()
//        print("MainViewModel Initialized with count: \(self.count)")
//    }
//
//    /**
//     Increments the counter via the injected dependency and updates the published count.
//     This method can be safely called from the View (@Published updates are main-thread safe).
//     */
//    func increment() {
//        // Accessing 'counter' here is safe because ViewModel is typically used
//        // from SwiftUI views, which operate on the main thread.
//        count = counter.increment()
//        print("ViewModel incremented count to: \(count)")
//    }
//
//    /**
//     Handles cleanup. Specifically, resets the counter state.
//     Because `deinit` is nonisolated and `counter` is @MainActor-isolated,
//     we must dispatch synchronously to the main queue to safely access `counter`.
//     */
//    deinit {
//        print("MainViewModel Deinitializing - Attempting to reset counter")
//        // Safely access the @MainActor isolated 'counter' property from nonisolated deinit
//        DispatchQueue.main.sync {
//            print("   Dispatching to main thread for reset...")
//            counter.reset()
//            print("   Counter reset executed on main thread.")
//       }
//        print("MainViewModel Deinitialized")
//    }
//}
//
//// MARK: - Example SwiftUI View (UI Layer)
//
///**
// A simple SwiftUI view demonstrating the usage of the `MainViewModel`.
// */
//struct ContentView: View {
//    // @StateObject ensures the ViewModel lifecycle is tied to the View's lifecycle
//    // and the instance is created only once.
//    // The creation of MainViewModel triggers the @Inject property wrapper inside it.
//    @StateObject private var viewModel: MainViewModel = MainViewModel()
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Automatic Dependency Injection")
//                .font(.headline)
//
//            Text("Count: \(viewModel.count)")
//                .font(.largeTitle)
//                .padding()
//                .background(Color.blue.opacity(0.1))
//                .cornerRadius(8)
//
//            Button {
//                viewModel.increment()
//            } label: {
//                Text("Increment")
//                    .padding(.horizontal)
//            }
//            .buttonStyle(.borderedProminent)
//            .tint(.green)
//        }
//        .padding()
//        .onAppear {
//            print("ContentView Appeared")
//        }
//        .onDisappear {
//            print("ContentView Disappeared")
//        }
//    }
//}
//
//// MARK: - Application Entry Point
//
///**
// The main application structure.
// */
//@main
//struct DependencyInjectorApp: App {
//    /**
//     Initializes the application and triggers the dependency injection process.
//     */
//    init() {
//        print(">>> DependencyInjectorApp Initializing <<<")
//        // Call the static inject function from our module to register all dependencies.
//        // This needs to happen before any ViewModel tries to @Inject a dependency.
//        AppModule.inject()
//        print(">>> DependencyInjectorApp Initialization Complete<<<")
//    }
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    // For the preview, we need to ensure dependencies are injected as well.
//    // Since AppModule.inject() should ideally run only once,
//    // we can manually set up for the preview if needed, or rely on the app init.
//    // A cleaner preview setup might involve a dedicated preview injector setup.
//    // For simplicity here, we assume the AppModule setup works for previews too,
//    // though calling it multiple times might re-register dependencies if not handled carefully.
//    // A simple check could prevent re-registration if DependenciesInjector keeps track.
//    struct PreviewWrapper: View {
//        init() {
//            AppModule.inject() // Ensure injection happens for preview
//        }
//        var body: some View {
//            ContentView()
//        }
//    }
//    return PreviewWrapper()
//}
//
