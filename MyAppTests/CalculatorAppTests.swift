//
//  CalculatorAppTests.swift
//  MyApp
//
//  Created by Cong Le on 11/17/24.
//

// CalculatorAppTests.swift
import XCTest
@testable import MyApp

class CalculatorAppTests: XCTestCase {

    var calculator: Calculator!

    override func setUpWithError() throws {
        // Initialize Calculator before each test
        calculator = Calculator()
    }

    override func tearDownWithError() throws {
        // Deallocate Calculator after each test
        calculator = nil
    }

    func testAddition() throws {
        let result = calculator.add(2, 3)
        XCTAssertEqual(result, 5, "Addition result should be 5")
    }

    func testSubtraction() throws {
        let result = calculator.subtract(5, 3)
        XCTAssertEqual(result, 2, "Subtraction result should be 2")
    }

    func testMultiplication() throws {
        let result = calculator.multiply(4, 3)
        XCTAssertEqual(result, 12, "Multiplication result should be 12")
    }

    func testDivision() throws {
        let result = try calculator.divide(10, 2)
        XCTAssertEqual(result, 5, "Division result should be 5")
    }

    func testDivisionByZero() throws {
        XCTAssertThrowsError(try calculator.divide(10, 0)) { error in
            XCTAssertEqual(error as? CalculatorError, CalculatorError.divisionByZero)
        }
    }

    func testAdditionPerformance() throws {
        self.measure {
            _ = calculator.add(1000, 2000)
        }
    }
}
