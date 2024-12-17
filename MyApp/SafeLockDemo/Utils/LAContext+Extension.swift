//
//  LAContext+Extension.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
// Source: https://github.com/cp-divyesh-v/SafeLock/blob/main/SafeLock/Utils/LAContext%2BExtension.swift
// Article: https://canopas.com/implement-face-id-authentication-in-the-ios-app-2f1160aadf1f

import LocalAuthentication

extension LAContext {
    enum BiometricType: String {
        case none
        case touchID
        case faceID
        case opticID
    }

    var biometricType: BiometricType {
        var error: NSError?

        guard self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        if #available(iOS 11.0, *) {
            switch self.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            default:
                if #available(iOS 17.0, *) {
                    if self.biometryType == .opticID {
                        return .opticID
                    } else {
                        return .none
                    }
                }
            }
        }
        return self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
    }
}
