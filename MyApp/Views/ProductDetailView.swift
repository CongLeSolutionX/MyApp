//
//  ProductDetailView.swift
//  MyApp
//
//  Created by Cong Le on 1/15/25.
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product

    var body: some View {
        VStack {
            Text("Product Detail")
                .font(.largeTitle)
            Text("Product ID: \(product.id)")
            Text("Product Name: \(product.name)")
        }
        .padding()
    }
}
