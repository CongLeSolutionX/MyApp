//
//  AwardStars.swift
//  MyApp
//
//  Created by Cong Le on 12/13/24.
//


import SwiftUI

struct LLMProviderRatingStars: View {
  var stars: Int = 3

  var body: some View {
    Canvas { gContext, size in
      guard let starSymbol = gContext.resolveSymbol(id: 0) else {
        return
      }
      let centerOffset = (size.width - (20 * Double(stars))) / 2.0
      gContext.translateBy(x: centerOffset, y: size.height / 2.0)
      for star in 0..<stars {
        let starXPosition = Double(star) * 20.0
        let point = CGPoint(x: starXPosition + 8, y: 0)
        gContext.draw(starSymbol, at: point, anchor: .leading)
      }
    } symbols: {
      Image(systemName: "star.fill")
        .resizable()
        .frame(width: 15, height: 15)
        .tag(0)
    }
  }
}

#Preview {
  LLMProviderRatingStars()
}
