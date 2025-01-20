//
//  Image.swift
//  MyApp
//
//  Created by Cong Le on 1/19/25.
//

import SwiftUI

struct ImageModel: Identifiable {
    var id: UUID = .init()
    var image: String
}

var images: [ImageModel] = (1...8).compactMap({ ImageModel(image: "Profile \($0)") })
