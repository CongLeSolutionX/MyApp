//
//  AppDelegate.swift
//  MyApp
//
//  Created by Cong Le on 11/22/24.
//


import UIKit

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - UIApplicationDelegate Methods
    
    /// Called when the app finishes launching, used here to set global app settings.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("didFinishLaunchingWithOptions")
        
        
        // Disable screen dimming and auto-lock to keep the app active during long operations.
        UIApplication.shared.isIdleTimerDisabled = true

        // Enable battery monitoring to allow the app to adapt its behavior based on battery level.
        UIDevice.current.isBatteryMonitoringEnabled = true

        // Store the app version and build version in UserDefaults for easy access elsewhere in the app.
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            UserDefaults.standard.set("\(appVersion) (\(buildVersion))", forKey: "app_version")
        }

        // Store the device's UUID in UserDefaults for identification purposes.
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            UserDefaults.standard.set(uuid, forKey: "uuid")
        }

        // Ensure UserDefaults changes are immediately saved.
        UserDefaults.standard.synchronize()
        
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
    }

    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("Configuring scene session")
        // Create a new scene configuration.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

