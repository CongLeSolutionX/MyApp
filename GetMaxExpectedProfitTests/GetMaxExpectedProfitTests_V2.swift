////
////  GetMaxExpectedProfitTests_V2.swift
////  MyApp
////
////  Created by Cong Le on 4/26/25.
////
//@testable import MyApp
//import XCTest

//final class GetMaxExpectedProfitTests: XCTestCase {
//
//    let accuracy: Float = 1e-8 // Adjusted accuracy for Float comparison might need tuning
//
//    // MARK: - Trivial and Edge Cases
//
//    func testNIsZero() {
//        XCTAssertEqual(getMaxExpectedProfit(0, [], 10, 0.1), 0.0, accuracy: accuracy)
//    }
//
//    func testNIsOne_Collect() {
//        XCTAssertEqual(getMaxExpectedProfit(1, [100], 10, 0.1), 90.0, accuracy: accuracy)
//    }
//
//    func testNIsOne_DoNotCollect_CostTooHigh() {
//        XCTAssertEqual(getMaxExpectedProfit(1, [5], 10, 0.1), 0.0, accuracy: accuracy)
//    }
//
//    // CORRECTED EXPECTED VALUE
//    func testNIsOne_DoNotCollect_SIsHigh() {
//        // DP logic with threshold T0=10 makes collecting optimal (Profit=11-10=1)
//        // Original test incorrectly assumed DP would wait, yielding 0.
//        let expectedProfit: Float = 1.0
//        XCTAssertEqual(getMaxExpectedProfit(1, [11], 10, 0.9), expectedProfit, accuracy: accuracy, "DP threshold T0=10, potential=11 > T0, should collect. Profit=1. Original expected value 0.0 was incorrect.")
//    }
//
//    func testSIsZero_NoRisk() {
//        // Manual trace (corrected): T2=5, T1=5, T0=5.
//        // D0: P=3<5->Wait, E1=3. D1: P=3+3=6>=5->Collect, Profit=6-5=1, E2=0. D2: P=0+10=10>=5->Collect, Profit=10-5=5, E3=0. Total=1+5=6.
//        // Let's re-re-trace S=0. f(i,E)=max(E+Vi-C+f(i+1,0), f(i+1, E+Vi)). C=5. V=[3,3,10].
//        // f(3,E)=max(0, E-5).
//        // f(2,E)=max(E+10-5+f(3,0), f(3,E+10)) = max(E+5+0, max(0, E+10-5)) = max(E+5, max(0,E+5)) = E+5.
//        // f(1,E)=max(E+3-5+f(2,0), f(2,E+3)) = max(E-2+(0+5), (E+3)+5) = max(E+3, E+8) = E+8.
//        // f(0,E)=max(E+3-5+f(1,0), f(1,E+3)) = max(E-2+(0+8), (E+3)+8) = max(E+6, E+11) = E+11.
//        // Value = f(0,0) = 11. (Previous manual trace was wrong again).
//        XCTAssertEqual(getMaxExpectedProfit(3, [3, 3, 10], 5, 0.0), 11.0, accuracy: accuracy)
//    }
//
//    func testSIsOne_GuaranteedLoss() {
//        XCTAssertEqual(getMaxExpectedProfit(3, [100, 100, 100], 10, 1.0), 270.0, accuracy: accuracy)
//    }
//
//    func testCIsZero_FreeCollection() {
//        XCTAssertEqual(getMaxExpectedProfit(3, [10, 10, 10], 0, 0.5), 30.0, accuracy: accuracy)
//    }
//
//    func testCIsVeryHigh_NeverCollect() {
//        XCTAssertEqual(getMaxExpectedProfit(3, [100, 100, 100], 1000, 0.1), 0.0, accuracy: accuracy)
//    }
//
//    func testVAllZero() {
//        XCTAssertEqual(getMaxExpectedProfit(3, [0, 0, 0], 10, 0.1), 0.0, accuracy: accuracy)
//    }
//
//    // MARK: - Tests Reflecting Problem-Solving Journey
//
//    // CORRECTED EXPECTED VALUE
//    func testScenario_SimpleGreedyFails() {
//        // Input: N=1, V=[11], C=10, S=0.9
//        // Same as testNIsOne_DoNotCollect_SIsHigh. DP yields 1.0.
//        let expectedProfit: Float = 1.0
//        XCTAssertEqual(getMaxExpectedProfit(1, [11], 10, 0.9), expectedProfit, accuracy: accuracy, "DP threshold T0=10, potential=11 > T0, should collect. Profit=1. Original expected value 0.0 was incorrect.")
//    }
//
//    // FAILURE EXPECTED - Indicates potential flaw in main function logic vs Official Answer
//    func testScenario_CsThresholdFails_ComplexInteraction() {
//        // Input: N=3, V=[10, 10, 100], C=12, S=0.5 (Same as Sample Case 4)
//        // Code is producing 95.5, which matches the suboptimal C/S threshold result.
//        // Official optimal answer is 97.0. Leave test as is to flag the discrepancy.
//         XCTAssertEqual(getMaxExpectedProfit(3, [10, 10, 100], 12, 0.5), 97.0, accuracy: accuracy, "Code currently yields 95.5 (matches suboptimal C/S threshold), but 97.0 is expected optimal. Flags potential implementation issue.")
//     }
//
//    // MARK: - Official Sample Cases (EXPECTED TO FAIL until main function is fixed)
//
//    func testSampleCase1() {
//        // N = 3, V = [10, 10, 10], C = 10, S = 0.5
//        // Expected: 17.5 (Code currently yields 7.5)
//        XCTAssertEqual(getMaxExpectedProfit(3, [10, 10, 10], 10, 0.5), 17.5, accuracy: accuracy, "Code currently yields 7.5 - Flags potential implementation issue")
//    }
//
//    func testSampleCase2() {
//        // N = 3, V = [10, 10, 10], C = 12, S = 0.5
//        // Expected: 14.0 (Code currently yields 5.5)
//        XCTAssertEqual(getMaxExpectedProfit(3, [10, 10, 10], 12, 0.5), 14.0, accuracy: accuracy, "Code currently yields 5.5 - Flags potential implementation issue")
//    }
//
//    func testSampleCase3() {
//        // N = 3, V = [10, 10, 100], C = 10, S = 0.5
//        // Expected: 100.0 (Code currently yields 97.5)
//        XCTAssertEqual(getMaxExpectedProfit(3, [10, 10, 100], 10, 0.5), 100.0, accuracy: accuracy, "Code currently yields 97.5 - Flags potential implementation issue")
//    }
//
//    func testSampleCase4() {
//        // N = 3, V = [10, 10, 100], C = 12, S = 0.5
//        // Expected: 97.0 (Code currently yields 95.5)
//        XCTAssertEqual(getMaxExpectedProfit(3, [10, 10, 100], 12, 0.5), 97.0, accuracy: accuracy, "Code currently yields 95.5 - Flags potential implementation issue")
//    }
//
//    // MARK: - Potential Precision Stress Test
//
//    func testLongSequenceSmallProbability() {
//         let n = 50
//         let v = Array(repeating: 5, count: n)
//         let c = 10
//         let s: Float = 0.01
//         let result = getMaxExpectedProfit(n, v, c, s)
//         let maxPossible = Float(n * 5 - c) // Profit if S=0
//         XCTAssertTrue(result >= 0 && result <= maxPossible, "Result plausibility check")
//         XCTAssertLessThan(result, maxPossible, "Profit should be less than S=0 case due to risk")
//    }
//}
