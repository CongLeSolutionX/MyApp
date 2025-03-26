//
//  BookshelfApp.swift
//  MyApp
//
//  Created by Cong Le on 3/26/25.
//

/// Note: This app is inspirated by the Apple's sample app at this link: https://developer.apple.com/documentation/swiftui/bringing_multiple_windows_to_your_swiftui_app

/*
Abstract:
The main app, which creates a scene, containing a window group, displaying
 a reading list view with data populated by the reading list data model.
*/

import SwiftUI

@main
struct BookshelfApp: App {
    private var dataModel = ReadingListModel()

    var body: some Scene {
        WindowGroup("Reading List") {
            ReadingList(model: dataModel)
        }
        .commands {
            SidebarCommands()
        }
        #if os(macOS)
        WindowGroup("Book Details", for: Book.ID.self) { $bookId in
            BookDetailWindow(dataModel: dataModel, bookId: $bookId)
        }
        .commandsRemoved()
        
        Window("Reading Activity", id: "activity") {
            ReadingActivityList(activity: dataModel.activity)
                .frame(minWidth: 640, minHeight: 480)
        }
        .keyboardShortcut("1")
        .defaultPosition(.topTrailing)
        .defaultSize(width: 800, height: 600)
        #endif
    }
}
