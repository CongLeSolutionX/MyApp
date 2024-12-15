//
//  AwardInformation.swift
//  MyApp
//
//  Created by Cong Le on 12/13/24.
//


import SwiftUI

struct LLMProviderInformation {
  public var imageName: String
  public var title: String
  public var description: String
  public var activatedLLMProvider: Bool
  public var ratingStars: Int = 3
}

extension LLMProviderInformation: Hashable {
  static func == (lhs: LLMProviderInformation, rhs: LLMProviderInformation) -> Bool {
    if lhs.title == rhs.title && lhs.description == rhs.description && lhs.activatedLLMProvider == rhs.activatedLLMProvider {
      return true
    }

    return false
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(title)
    hasher.combine(description)
    hasher.combine(activatedLLMProvider)
    hasher.combine(ratingStars)
  }
}

extension LLMProviderInformation: Identifiable {
  public var id: Int {
    self.hashValue
  }
}
