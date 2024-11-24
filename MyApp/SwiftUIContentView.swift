//
//  SwiftUIContentView.swift
//  MyApp
//
//  Created by Cong Le on 11/16/24.
//

import SwiftUI

struct SwiftUIContentView: View {
    var body: some View {
        UIKitViewControllerWrapper()
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    SwiftUIContentView()
}
