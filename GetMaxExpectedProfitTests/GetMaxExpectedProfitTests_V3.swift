////
////  GetMaxExpectedProfitTests_V3.swift
////  MyApp
////
////  Created by Cong Le on 4/26/25.
////
//@testable import MyApp
//import XCTest
//final class GetMaxExpectedProfitOfficialTests: XCTestCase {
//
//    // The problem specifies an absolute or relative error of at most 10^-6.
//    // Float accuracy in Swift is roughly 1.19e-7 (`ulpOfOne`), so 1e-6 is a safe choice.
//    let accuracy: Float = 1e-6
//
//    // MARK: - Official Sample Cases from Meta Platform Image
//
//    func testSampleCase1_Meta() {
//        // Inputs from image:
//        let N = 5
//        let V = [10, 2, 8, 6, 4]
//        let C = 5
//        let S: Float = 0.0
//        // Expected Output from image:
//        let expectedProfit: Float = 25.00000000
//
//        // Assertion
//        XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "Sample Case 1 Failed")
//    }
//
//    func testSampleCase2_Meta() {
//        // Inputs from image:
//        let N = 5
//        let V = [10, 2, 8, 6, 4]
//        let C = 5
//        let S: Float = 1.0
//        // Expected Output from image:
//        let expectedProfit: Float = 9.00000000
//
//        // Assertion
//        XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "Sample Case 2 Failed")
//    }
//
//    func testSampleCase3_Meta() {
//        // Inputs from image:
//        let N = 5
//        let V = [10, 2, 8, 6, 4]
//        let C = 3
//        let S: Float = 0.5
//        // Expected Output from image:
//        let expectedProfit: Float = 17.00000000
//
//        // Assertion
//        XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "Sample Case 3 Failed")
//    }
//
//    func testSampleCase4_Meta() {
//        // Inputs from image:
//        let N = 5
//        let V = [10, 2, 8, 6, 4]
//        let C = 3
//        let S: Float = 0.15
//        // Expected Output from image:
//        let expectedProfit: Float = 20.10825000 // Note: Using Float as the result type
//
//        // Assertion
//        XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "Sample Case 4 Failed")
//    }
//
//}
