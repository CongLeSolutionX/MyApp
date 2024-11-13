//
//  LimitedAccessTab.swift
//  MyApp
//
//  Created by Cong Le on 11/13/24.
//


import SwiftUI

struct LimitedAccessTab: View {
    @Environment(ContactStoreManager.self) private var storeManager
    @State private var model = IgnoreItemModel()
    
    var body: some View {
        TabView {
            SearchList()
                .tabItem {
                    Text("Contact List")
                }
            
            IgnoreList()
                .tabItem {
                    Text("Ignore List")
                }
        }
        .environment(model)
    }
}

#Preview {
    LimitedAccessTab()
        .environment(ContactStoreManager())
        .environment(IgnoreItemModel())
}
