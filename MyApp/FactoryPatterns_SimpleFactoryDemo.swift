//
//  FactoryPatternDemo.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//

// Product Protocol
protocol AlertView {
    func show(title: String, message: String)
}

// Concrete Products
struct SuccessAlert: AlertView {
    func show(title: String, message: String) {
        print("✅ SUCCESS: \(title) - \(message)")
        // In reality, present a styled success alert
    }
}

struct ErrorAlert: AlertView {
    func show(title: String, message: String) {
        print("❌ ERROR: \(title) - \(message)")
        // In reality, present a styled error alert
    }
}

// Alert Type Enum
enum AlertType {
    case success
    case error
}

// Simple Factory
struct AlertFactory {
    static func createAlert(type: AlertType) -> AlertView {
        switch type {
        case .success:
            return SuccessAlert()
        case .error:
            return ErrorAlert()
        }
    }
}
