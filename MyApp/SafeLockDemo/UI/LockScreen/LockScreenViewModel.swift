//
//  LockScreenViewModel.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
// Source: https://github.com/cp-divyesh-v/SafeLock/

import SwiftUI

@Observable class LockScreenViewModel {
    let passcodeLength: Int = 4
    var passcode = ""
    var hideNumberPad: Bool = true

    var authenticator: Authenticator

    init(authenticator: Authenticator) {
        self.authenticator = authenticator
    }

    func verifyPasscode(){
        guard passcode.count == passcodeLength else{ return }

        authenticator.verifyPin(pin: passcode)
    }

    func onAddValue(_ value: Int) {
        if passcode.count < passcodeLength {
            passcode += "\(value)"
        }
    }

    func onRemoveValue() {
        if !passcode.isEmpty{
            passcode.removeLast()
        }
    }

    func onDissmis() {
        withAnimation {
            hideNumberPad = true
        }
    }

    func showNumPad() {
        withAnimation {
            hideNumberPad = false
        }
    }
}
