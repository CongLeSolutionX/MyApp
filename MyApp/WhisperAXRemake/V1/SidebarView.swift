////
////  SidebarView.swift
////  MyApp
////
////  Created by Cong Le on 4/18/25.
////
//
//// SidebarView.swift
//import SwiftUI
//
//struct SidebarView: View {
//    @EnvironmentObject var viewModel: ContentViewModel
//    @EnvironmentObject var settings: AppSettings
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            ModelSelectorView() // Uses viewModel, settings
//                .padding(.bottom)
//
//            ComputeUnitsView() // Uses viewModel, settings
//                .padding(.bottom)
//
//            TabSelectionView() // Uses viewModel
//
//            Spacer()
//
//            AppInfoView() // Uses viewModel
//        }
//        .padding()
//    }
//}
