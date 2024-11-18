//
//  Calculator.swift
//  MyApp
//
//  Created by Cong Le on 11/17/24.
//

// Calculator.swift
import Foundation

enum CalculatorError: Error {
    case divisionByZero
}

class Calculator {
    func add(_ a: Double, _ b: Double) -> Double {
        return a + b
    }

    func subtract(_ a: Double, _ b: Double) -> Double {
        return a - b
    }

    func multiply(_ a: Double, _ b: Double) -> Double {
        return a * b
    }

    func divide(_ a: Double, _ b: Double) throws -> Double {
        if b == 0 {
            throw CalculatorError.divisionByZero
        }
        return a / b
    }
}
