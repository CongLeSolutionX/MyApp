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

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("didFinishLaunchingWithOptions")
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

