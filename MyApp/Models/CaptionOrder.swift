//
//  CaptionOrder.swift
//  MyApp
//
//  Created by Cong Le on 11/13/24.
//


import ContactsUI

enum CaptionOrder: String, Identifiable, CaseIterable, Codable {
    case email = "Email address"
    case phone = "Phone number"
    case defaultText = "Default"
    
    var id: Self { self }
}

extension CaptionOrder {
    @available(iOS 18.0, *)
    var bottomCaption: ContactAccessButton.Caption {
        switch self {
        case .email: .email
        case .phone: .phone
        case .defaultText: .defaultText
        }
    }
}
