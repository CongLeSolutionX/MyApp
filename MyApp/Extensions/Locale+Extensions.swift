//
//  Locale+Extensions.swift
//  MyApp
//
//  Created by Cong Le on 3/26/25.
//

/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Extended Locale values used to define custom locale identifiers.
*/

import Foundation

extension Locale {
    static var italian: Locale {
        .init(identifier: "it_IT")
    }
    static var vietnamese: Locale {
        .init(identifier: "vi_VN")
    }
}
