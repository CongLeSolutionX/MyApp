//
//  FoundationExtensions.swift
//  MyApp
//
//  Created by Cong Le on 3/14/25.
//

/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Extensions on Foundation types.
*/

import Foundation

extension URL {
    /// A unique output location to write a movie.
    static var movieFileURL: URL {
        URL.temporaryDirectory.appending(component: UUID().uuidString).appendingPathExtension(for: .quickTimeMovie)
    }
}
