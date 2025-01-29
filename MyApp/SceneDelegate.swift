//
//  SceneDelegate.swift
//  MyApp
//
//  Created by Cong Le on 11/22/24.
//
//
//  SceneDelegate.swift

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: - UIWindowSceneDelegate Methods

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("[SceneDelegate] sceneWillConnectTo")

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.sceneWillConnectToScene() // Inform AppDelegate

            // Example data from AppDelegate
            let dataFromAppDelegate = appDelegate.getAppData()

            if let windowScene = scene as? UIWindowScene {
                let window = UIWindow(windowScene: windowScene)
                let contentView = ContentView()

                // Set the root view controller to the SwiftUI view
                window.rootViewController = UIHostingController(rootView: contentView)
                self.window = window
                window.makeKeyAndVisible()

                // You might want to pass data to ContentView here if needed
                // One way could be using EnvironmentObject or similar state management
                // For simplicity, ContentView is fetching data in .onAppear() in this example
            }
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("[SceneDelegate] sceneDidBecomeActive")
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.sceneDidBecomeActive() // Inform AppDelegate
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        print("[SceneDelegate] sceneWillResignActive")
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.sceneWillResignActive() // Inform AppDelegate
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("[SceneDelegate] sceneDidEnterBackground")
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.sceneDidEnterBackground() // Inform AppDelegate
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("[SceneDelegate] sceneWillEnterForeground")
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.sceneWillEnterForeground() // Inform AppDelegate
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        print("[SceneDelegate] sceneDidDisconnect")
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.sceneDidDisconnect() // Inform AppDelegate
        }
    }
}
