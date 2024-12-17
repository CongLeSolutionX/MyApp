//
//  Authenticator.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
// Source: https://github.com/cp-divyesh-v/SafeLock/

import Foundation
import LocalAuthentication

@Observable class Authenticator {
    private let userDefaultPasscodeKey: String = "passcode"
    private let userDefaultSecretKey: String = "secret_key"
    private let maxFailedAttemptAllowed: Int = 3
    
    var isAuthenticated: Bool = false
    var isLoading: Bool = false
    var biometryType: LAContext.BiometricType
    
    var isPassCodeSet: Bool = false
    var isBiometricLocked: Bool = false
    
    private var failedAttempt: Int = 0
    private let context = LAContext()
    private let userDefault: UserDefaults = .standard
    
    
    init() {
        context.touchIDAuthenticationAllowableReuseDuration = 10
        context.localizedFallbackTitle = ""
        self.isPassCodeSet = !context.isCredentialSet(.applicationPassword)
        self.biometryType = context.biometricType
        
        if userDefault.value(forKey: userDefaultPasscodeKey) == nil {
            setPasscodeWith("0000")
        }
    }
    
    
    func logOut() {
        isAuthenticated = false
        resetFailCount()
    }
    
    func setPasscodeWith(_ code: String) {
        guard isBiometricAvailable() else { return }
        
        //Use key that can be recoverable, i am using random string to demonstrate
        let key = UUID().uuidString
        let encryptedPasscode = AESEncryptionManager.encrypt(plainText: code, key: key)
        userDefault.setValue(encryptedPasscode, forKey: userDefaultPasscodeKey)
        userDefault.setValue(key, forKey: userDefaultSecretKey)
    }
    
    func unlockWithFaceId() {
        authenticate()
    }
    
    private func authenticate() {
        
        guard isBiometricAvailable() && !isBiometricLocked else { return }
        isLoading = true
        var error: NSError?
        
        
        
        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We need to unlock your data."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                guard let self else { return }
                // authentication has now completed
                if success {
                    let passcode = self.decryptUserPasscode()
                    self.isAuthenticated = passcode != nil
                    // authenticated successfully
                } else {
                    // there was a problem fallback to alternative like in app
                    self.failedAttempt += 1
                    self.isBiometricLocked = self.failedAttempt >= self.maxFailedAttemptAllowed
                }
                self.isLoading = false
            }
        } else {
            
            if let error = error {
                handleLaError(error: error)
            } else {
                
            }
        }
    }
    
    private func isBiometricAvailable() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    private func handleLaError(error: NSError) {
        if let error = (error as? LAError) {
            var errorMessage: String {
                switch error.code {
                case .biometryNotAvailable:
                    return "Your device does not supported biometric"
                case .biometryNotEnrolled:
                    return "Biometric lock is not set please set it first."
                case .biometryLockout:
                    return "Biometric is locked try entering passcode manually."
                default:
                    return "Unidentified error"
                }
            }
            print("\(errorMessage)")
        }
    }
    
    func decryptUserPasscode() -> String? {
        guard let encryptedPasscode = userDefault.value(forKey: userDefaultPasscodeKey) as? String else { return nil }
        var passcode: String?
        if let key = userDefault.value(forKey: userDefaultSecretKey) as? String {
            passcode = AESEncryptionManager.decrypt(encryptedText: encryptedPasscode, key: key)
        }
        
        return passcode
    }
    
    func verifyPin(pin: String) {
        guard let passcode = decryptUserPasscode() else {
            isAuthenticated = false
            return
        }
        isAuthenticated = passcode == pin
        resetFailCount()
    }
    
    func onResetPin() {
        userDefault.removeObject(forKey: userDefaultPasscodeKey)
        userDefault.removeObject(forKey: userDefaultSecretKey)
        resetFailCount()
    }
    
    func resetFailCount() {
        failedAttempt = 0
        isBiometricLocked = false
    }
}
