//
//  NavigationViewInSwiftUI.swift
//  MyApp
//
//  Created by Cong Le on 11/28/24.
//

import SwiftUI


// MARK: - Navigation View Wrapper
#Preview("Navigation View Wrapper") {
    NavigationView {
        ScrollView {
            RoundedRectangle(cornerRadius: 30)
                .frame(height: 1000)
                .padding()
        }
    }
}

// MARK: - Navigation Title
#Preview("Navigation Title") {
    NavigationView {
        ScrollView {
            // ...
        }
        .navigationTitle("Today")
    }
}

// MARK: - Navigation Bar Item
#Preview() {
    NavigationView {
        ScrollView {
            // ...
        }
        .navigationBarItems(trailing: Image(systemName: "person.crop.circle"))
    }
}

// MARK: - Navigation Link
#Preview("Navigation Link") {
    NavigationLink(destination: Text("New View")) { // link to new SwiftUI view when clicked on Text view
        RoundedRectangle(cornerRadius: 30)
            .frame(height: 1000)
            .padding()
    }
}
