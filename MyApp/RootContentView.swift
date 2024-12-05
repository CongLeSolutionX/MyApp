//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI

struct RootContentView: View {
    var body: some View {
        
        let photoService = PhotoService()
        let photoRepository = PhotoRepository(photoService: photoService)
        let viewModel = PhotoViewModel(photoRepository: photoRepository)
        PhotoView(viewModel: viewModel)
            .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - Previews
// Before iOS 17, use this syntax for preview UIKit view controller
struct UIKitViewControllerWrapper_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerWrapper()
    }
}

// After iOS 17, we can use this syntax for preview:
#Preview("SwiftUI Content View") {
    RootContentView()
}
