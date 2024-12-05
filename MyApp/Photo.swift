//
//  Photo.swift
//  MyApp
//
//  Created by Cong Le on 12/4/24.
//

import Foundation

struct Photo: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let imageData: Data
}
