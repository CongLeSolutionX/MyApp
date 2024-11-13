//
//  MainView.swift
//  MyApp
//
//  Created by Cong Le on 11/13/24.
//

import SwiftUI

struct MainView: View {
    @Environment(ContactStoreManager.self) private var storeManager
    
    var body: some View {
        VStack {
            switch storeManager.authorizationStatus {
            case .authorized:  FullAccessList()
            case .limited: LimitedAccessTab()
            case .restricted, .denied: AppSettingsLink()
            case .notDetermined: RequestAccessButton()
            @unknown default:
                fatalError("An unknown error occurred.")
            }
        }
        .onAppear {
            storeManager.fetchAuthorizationStatus()
        }
    }
}

#Preview {
    MainView()
        .environment(ContactStoreManager())
}
