//
//  ThumbnailImage.swift
//  MyApp
//
//  Created by Cong Le on 11/13/24.
//

import SwiftUI

struct ThumbnailImage: View {
    let image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .frame(width: 40, height: 40)
            .clipShape(Circle())
    }
}

#Preview {
    ThumbnailImage(image: UIImage())
}
