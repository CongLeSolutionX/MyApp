//
//  MainView.swift
//  MyApp
//
//  Created by Cong Le on 10/7/24.
//


import SwiftUI

struct MainView: View {
    var body: some View {
        AssistantView(viewModel: AssistantViewModel())
    }
}

#Preview {
    MainView()
}