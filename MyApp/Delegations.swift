//
//  Delegations.swift
//  MyApp
//
//  Created by Cong Le on 10/31/24.
//

import SwiftUI

// MARK: - AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("didFinishLaunchingWithOptions()")
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive()")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive()")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground()")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground()")
    }
    
//    func applicationWillTerminate(_ application: UIApplication) {
//        print("applicationWillTerminate()")
//    }
}

// MARK: - SceneDelegate
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        print("scene(_:willConnectTo:options:)")
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let mainView = MainSwiftUIViewWithObjCInstance()
            window.rootViewController = UIHostingController(rootView: mainView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
//    func sceneDidDisconnect(_ scene: UIScene) {
//        print("sceneDidDisconnect()")
//    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("sceneDidBecomeActive()")
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        print("sceneWillResignActive()")
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("sceneWillEnterForeground()")
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("sceneDidEnterBackground()")
    }
}


// MARK: - Extensions for Suspended State Simulation
extension AppDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate()")
        print("App is Terminated")
    }
}

extension SceneDelegate {
    func sceneDidDisconnect(_ scene: UIScene) {
        print("sceneDidDisconnect()")
        print("App is Terminated")
    }
}
