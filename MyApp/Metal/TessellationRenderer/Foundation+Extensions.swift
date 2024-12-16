//
//  Foundation+Extensions.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
// Source: https://github.com/dehesa/sample-metal

import Foundation


// Swift doesn't allow to extend a protocol with another protocol; however, we can do default implementation for a specific protocol.
extension NSObjectProtocol {
  @_transparent @discardableResult public func configure(_ block: (Self)->Void) -> Self {
    block(self)
    return self
  }
}

