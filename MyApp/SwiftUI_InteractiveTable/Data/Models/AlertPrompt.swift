//
//  AlertPrompt.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
// Source: https://github.com/cp-divyesh-v/TableExampleSwiftUI

import Foundation

public struct AlertPrompt: Identifiable {
    public var id: String = UUID().uuidString
    public let title: String
    public let message: String
    public var positiveBtnTitle: String?
    public var positiveBtnAction: (() -> Void)?
    public var negativeBtnTitle: String?
    public var negativeBtnAction: (() -> Void)?
    public var isPositiveBtnDestructive: Bool = false
    
    public init(
        title: String = "",
        message: String,
        positiveBtnTitle: String? = nil,
        positiveBtnAction: (() -> Void)? = nil,
        negativeBtnTitle: String? = nil,
        negativeBtnAction: (() -> Void)? = nil,
        isPositiveBtnDestructive: Bool = false
    ) {
        self.title = title
        self.message = message
        self.positiveBtnTitle = positiveBtnTitle
        self.positiveBtnAction = positiveBtnAction
        self.negativeBtnTitle = negativeBtnTitle
        self.negativeBtnAction = negativeBtnAction
        self.isPositiveBtnDestructive = isPositiveBtnDestructive
    }
}
