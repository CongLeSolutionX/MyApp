//
//  AppDelegate.swift
//  MyApp
//
//  Created by Cong Le on 1/29/25.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {


    // Example app-level data
    var appData: String = "Initial Data from AppDelegate"

    // MARK: - UIApplicationDelegate Methods

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        printLog("[AppDelegate] didFinishLaunchingWithOptions")
        appData = "Data updated after launch"
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        printLog("[AppDelegate] applicationDidBecomeActive")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        printLog("[AppDelegate] applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        printLog("[AppDelegate] applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        printLog("[AppDelegate] applicationWillEnterForeground")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        printLog("[AppDelegate] applicationWillTerminate")
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        URLCache.shared.removeAllCachedResponses()
        printLog("[AppDelegate] applicationDidReceiveMemoryWarning")
    }

    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        printLog("[AppDelegate] Configuring scene session")
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // MARK: - Scene Delegate Notification Methods (Example - Consider SceneDelegate if needed)

    // Note: In SwiftUI with Scene-based apps, SceneDelegate handles much of this.
    // These methods in AppDelegate are more for app-level notifications.
//    func sceneWillConnectToScene() {
//        printLog("[AppDelegate] Notification: Scene will connect - App Level")
//    }
//
//    func sceneDidBecomeActive() {
//        printLog("[AppDelegate] Notification: Scene did become active - App Level")
//    }
//
//    func sceneWillResignActive() {
//        printLog("[AppDelegate] Notification: Scene will resign active - App Level")
//    }
//
//    func sceneDidEnterBackground() {
//        printLog("[AppDelegate] Notification: Scene did enter background - App Level")
//    }
//
//    func sceneWillEnterForeground() {
//        printLog("[AppDelegate] Notification: Scene will enter foreground - App Level")
//    }
//
//    func sceneDidDisconnect() {
//        printLog("[AppDelegate] Notification: Scene did disconnect - App Level")
//    }
//
//    // MARK: - Data Accessor for App Data (Observable with @Published if needed in SwiftUI)
//
//    func getAppData() -> String {
//        return appData ?? "No App Data Available"
//    }
}
