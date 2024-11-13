//
//  IgnoreItemType.swift
//  MyApp
//
//  Created by Cong Le on 11/13/24.
//


import Foundation

enum IgnoreItemType: String, Identifiable, CaseIterable, Codable {
    case email = "Email"
    case phone = "Phone number"
    
    var id: Self { self }
}
