//
//  AppDelegate.swift
//  MyApp
//
//  Created by Cong Le on 3/15/25.
//

import UIKit
    import CoreData

    class AppDelegate: UIResponder, UIApplicationDelegate {

        lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "YourDataModelName") // Replace with your model name
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()

        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            // Override point for customization after application launch.
            return true
        }

        // ... other AppDelegate methods if needed ...
    }
 
