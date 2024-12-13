//
//  VertexMetalContentView.swift
//  MyApp
//
//  Created by Cong Le on 12/13/24.
//


import SwiftUI

struct VertexMetalContentView: View {
  var body: some View {
    VStack {
      VertexMetalView()
        .border(Color.black, width: 2)
    }
    .padding()
  }
}
// MARK: - Preview
#Preview("Vertex Metal Content View") {
    VertexMetalContentView()
}
