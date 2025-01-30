//
//  AppDelegate.swift
//  MyApp
//
//  Created by Cong Le on 1/29/25.
//


import UIKit

//@UIApplicationMain // No longer needed for SwiftUI apps with @main in MyApp.swift
class AppDelegate: UIResponder, UIApplicationDelegate {

    // Example app-level data
    var appData: String? = "Initial Data from AppDelegate"

    // MARK: - UIApplicationDelegate Methods

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("[AppDelegate] didFinishLaunchingWithOptions")
        appData = "Data updated after launch" // Update data after launch
        
        // Configure URLCache
        let memoryCapacity = 50 * 1024 * 1024 // 50 MB
        let diskCapacity = 200 * 1024 * 1024 // 200 MB
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "webViewCache")
        URLCache.shared = cache

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("[AppDelegate] applicationDidBecomeActive")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("[AppDelegate] applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("[AppDelegate] applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("[AppDelegate] applicationWillEnterForeground")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("[AppDelegate] applicationWillTerminate")
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        URLCache.shared.removeAllCachedResponses()
        print("[AppDelegate] applicationDidReceiveMemoryWarning")
    }

    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("[AppDelegate] Configuring scene session")
        // Create a new scene configuration.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // MARK: - Scene Delegate Notification Methods (Example of communication)

    func sceneWillConnectToScene() {
        print("[AppDelegate] Notification: Scene will connect")
    }

    func sceneDidBecomeActive() {
        print("[AppDelegate] Notification: Scene did become active")
    }

    func sceneWillResignActive() {
        print("[AppDelegate] Notification: Scene will resign active")
    }

    func sceneDidEnterBackground() {
        print("[AppDelegate] Notification: Scene did enter background")
    }

    func sceneWillEnterForeground() {
        print("[AppDelegate] Notification: Scene will enter foreground")
    }

    func sceneDidDisconnect() {
        print("[AppDelegate] Notification: Scene did disconnect")
    }

    // MARK: - Data Accessor for SceneDelegate (Example of data passing)
    func getAppData() -> String {
        return appData ?? "No App Data Available"
    }
}
