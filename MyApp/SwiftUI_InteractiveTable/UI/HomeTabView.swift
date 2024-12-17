//
//  HomeTabView.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
//
import SwiftUI


struct HomeTabView: View {
    
    @State var viewModel: HomeTabViewModel
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            TableTypeListView(viewModel: TableTypeListViewModel())
                .tabItem {
                    Label("Grade History", systemImage: "book")
                }
                .tag(0)
            StudentsListView(viewModel: StudentsListViewModel())
                .tabItem {
                    Label("Students", systemImage: "person.3")
                }
                .tag(1)
        }
    }
}

//MARK: - Preview
#Preview("Home Tab View") {
    HomeTabView(viewModel: HomeTabViewModel())
}
