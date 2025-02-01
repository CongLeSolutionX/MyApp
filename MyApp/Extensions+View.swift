//
//  Extensions+View.swift
//  MyApp
//
//  Created by Cong Le on 2/1/25.
//


import SwiftUI

extension View{
    // MARK: Safe Area Value
    func safeArea()->UIEdgeInsets{
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else{return .zero}
        guard let safeArea = window.windows.first?.safeAreaInsets else{return .zero}
        
        return safeArea
    }
}
