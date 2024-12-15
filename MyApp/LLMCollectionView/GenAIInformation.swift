//
//  AwardInformation.swift
//  MyApp
//
//  Created by Cong Le on 12/13/24.
//


import SwiftUI

struct GenAIInformation {
  public var imageName: String
  public var title: String
  public var description: String
  public var activatedGenerativeModel: Bool
  public var ratingStars: Int = 3
}

extension GenAIInformation: Hashable {
  static func == (lhs: GenAIInformation, rhs: GenAIInformation) -> Bool {
    if lhs.title == rhs.title && lhs.description == rhs.description && lhs.activatedGenerativeModel == rhs.activatedGenerativeModel {
      return true
    }

    return false
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(title)
    hasher.combine(description)
    hasher.combine(activatedGenerativeModel)
    hasher.combine(ratingStars)
  }
}

extension GenAIInformation: Identifiable {
  public var id: Int {
    self.hashValue
  }
}
