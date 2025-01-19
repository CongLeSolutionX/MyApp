//
//  ImageFile.swift
//  MyApp
//
//  Created by Cong Le on 1/19/25.
//

import SwiftUI

struct ImageFile: Transferable {
    var image: UIImage
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { transferable in
            transferable.image.pngData()!
        }
    }
}
