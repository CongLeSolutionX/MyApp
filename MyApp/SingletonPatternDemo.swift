//
//  SingletonPatternDemo.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//

import Foundation // Often needed, e.g., for DispatchQueue

// Example: A Singleton class to manage app settings
final class SettingsManager {

    // 1. The static, shared instance.
    // 'let' ensures it's assigned only once.
    // Static properties are lazily initialized by default in Swift,
    // and this initialization is guaranteed to be thread-safe.
    static let shared = SettingsManager()

    // Example properties managed by the singleton
    var username: String?
    private var volumeLevel: Float = 0.5

    // Use a private queue for thread-safe access to mutable properties
    private let concurrentQueue = DispatchQueue(label: "com.yourapp.settingsManagerQueue", attributes: .concurrent)

    // 2. The private initializer prevents creating other instances.
    private init() {
        // Initialization code here, e.g., load settings from UserDefaults
        print("SettingsManager initialized.")
        loadSettings() // Example private method call
    }

    // Public methods to access or modify settings safely
    func getVolumeLevel() -> Float {
        var volume: Float = 0
        concurrentQueue.sync { // Read with sync
            volume = self.volumeLevel
        }
        return volume
    }

    func setVolumeLevel(_ level: Float) {
        concurrentQueue.async(flags: .barrier) { // Write with async barrier
            self.volumeLevel = max(0.0, min(1.0, level)) // Clamp between 0 and 1
            // Optionally save settings here
             print("Volume level set to: \(self.volumeLevel)")
            // self.saveSettings()
        }
    }

    // Example private helper methods
    private func loadSettings() {
        // Load settings from persistent storage (e.g., UserDefaults)
        self.username = UserDefaults.standard.string(forKey: "username")
        self.volumeLevel = UserDefaults.standard.float(forKey: "volumeLevel")
        if UserDefaults.standard.object(forKey: "volumeLevel") == nil { // Check if key exists
             self.volumeLevel = 5 // Default value
        }
         print("Settings loaded: Username=\(username ?? "nil"), Volume=\(volumeLevel)")
    }

    func saveSettings() {
         concurrentQueue.async(flags: .barrier) {
            UserDefaults.standard.set(self.username, forKey: "username")
            UserDefaults.standard.set(self.volumeLevel, forKey: "volumeLevel")
            print("Settings saved.")
        }
    }
}
