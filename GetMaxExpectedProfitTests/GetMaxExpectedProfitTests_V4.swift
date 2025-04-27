////
////  GetMaxExpectedProfitTests_V4.swift
////  MyApp
////
////  Created by Cong Le on 4/27/25.
////
//@testable import MyApp
//import XCTest
//
//final class GetMaxExpectedProfitHiddenTests: XCTestCase {
//
//    // Problem specifies an absolute or relative error of at most 10^-6.
//    let accuracy: Float = 1e-6
//
//    // Helper to get expected value from the trusted function (for complex cases)
//    // NOTE: In a real scenario, these expected values would be pre-calculated and hardcoded.
//    private func getExpected(_ N: Int, _ V: [Int], _ C: Int, _ S: Float) -> Float {
//        return getMaxExpectedProfit(N, V, C, S) // Using the function itself as oracle
//    }
//
//    // MARK: - Constraint Boundary Tests (5 Cases)
//
//    // Hidden Test Case #5: Max N (Conceptual - real test is performance)
//    func testHiddenCase_MaxN_SimpleValues() {
//        let N = 4000 // Max N
//        let V = Array(repeating: 10, count: N)
//        let C = 5
//        let S: Float = 0.01 // Small theft chance over many days
//        let expectedProfit: Float = getExpected(N, V, C, S) // Calculation needed
//        XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC Max N")
//    }
//
//    // Hidden Test Case #6: Max V, Max C
//    func testHiddenCase_MaxV_MaxC() {
//        let N = 10
//        let V = Array(repeating: 1000, count: N) // Max V
//        let C = 1000 // Max C
//        let S: Float = 0.1
//        // Potentially collect if S is low enough? Thresholds near 1000.
//        let expectedProfit: Float = getExpected(N, V, C, S) // Calculation needed
//        XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC Max V, Max C")
//    }
//
//    // Hidden Test Case #7: Min C
//    func testHiddenCase_MinC() {
//        let N = 20
//        let V = (1...N).map { $0 * 2 } // Increasing values
//        let C = 1 // Min C
//        let S: Float = 0.05
//        // Likely to collect frequently as cost is minimal
//        let expectedProfit: Float = getExpected(N, V, C, S) // Calculation needed
//        XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC Min C")
//    }
//    
//    // Hidden Test Case #8: Max N, Max V, Max C, High S
//     func testHiddenCase_MaxN_MaxV_MaxC_HighS() {
//         let N = 4000 // Max N
//         let V = Array(repeating: 1000, count: N) // Max V
//         let C = 1000 // Max C
//         let S: Float = 0.8 // High theft chance
//         // Very risky to wait, might collect early despite high cost?
//         let expectedProfit: Float = getExpected(N, V, C, S) // Calculation needed
//         XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC Max N, Max V, Max C, High S")
//     }
//
//     // Hidden Test Case #9: N=1 (redundant with previous tests, but often included)
//     func testHiddenCase_N1_HighS() {
//         let N = 1
//         let V = [100]
//         let C = 10
//         let S: Float = 0.95 // Very High S
//         // T0 calc: (v-10) = max(0, (1-0.95)v - 10) => v-10 = max(0, 0.05v-10). Threshold ~200.
//         // P=100. Don't collect. E1 = 0.05*100 = 5. Final profit = max(0, 5-10)=0
//         let expectedProfit: Float = 0.0
//         XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC N=1 High S")
//     }
//
//
//    // MARK: - Logic Edge Case Tests (5 Cases)
//
//    // Hidden Test Case #10: All V = 0
//    func testHiddenCase_AllVZero() {
//        let N = 100
//        let V = Array(repeating: 0, count: N)
//        let C = 10
//        let S: Float = 0.1
//        let expectedProfit: Float = 0.0 // No value to collect
//        XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC All V Zero")
//    }
//
//    // Hidden Test Case #11: S nearly 0 (Precision/Logic boundary)
//    func testHiddenCase_SNearZero() {
//        let N = 50
//        let V = Array(repeating: 10, count: N)
//        let C = 5
//        let S: Float = 1e-9 // Very small, non-zero S
//        // Should be very close to S=0 case (where profit is N*V[0] - C = 50*10-5 = 495)
//        let expectedProfit: Float = getExpected(N, V, C, S) // Expect ~495
//        XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC S Near Zero")
//    }
//
//    // Hidden Test Case #12: S nearly 1 (Precision/Logic boundary)
//    func testHiddenCase_SNearOne() {
//        let N = 50
//        let V = Array(repeating: 10, count: N)
//        let C = 5
//        let S: Float = 0.9999999 // Very close to 1
//        // Should behave almost like S=1 (collect immediately if > C)
//        // Collect each day: Profit = N * (V[0] - C) = 50 * (10-5) = 250
//        let expectedProfit: Float = getExpected(N, V, C, S) // Expect ~250
//        XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC S Near One")
//    }
//
//    // Hidden Test Case #13: V oscillating High-Low
//    func testHiddenCase_VOscillating() {
//        let N = 10
//        let V = [100, 1, 100, 1, 100, 1, 100, 1, 100, 1]
//        let C = 50
//        let S: Float = 0.1
//        // Strategy depends on whether collecting low value is worth it to get high value later
//        let expectedProfit: Float = getExpected(N, V, C, S) // Calculation needed
//        XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC V Oscillating")
//    }
//
//    // Hidden Test Case #14: Sequence with many zeros
//    func testHiddenCase_ManyZeros() {
//        let N = 20
//        let V = [10,0,0,0,20,0,0,0,0,0,30,0,0,0,0,0,0,0,0,5]
//        let C = 8
//        let S: Float = 0.2
//        // Does accumulating through many zero-value days affect decision?
//        let expectedProfit: Float = getExpected(N, V, C, S) // Calculation needed
//        XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC Many Zeros")
//    }
//
//    // MARK: - DP/Threshold Logic Tests (5 Cases)
//
//    // Hidden Test Case #15: Late large value, High Risk
//     func testHiddenCase_LateLargeValue_HighRisk() {
//         let N = 20
//         let V = Array(repeating: 1, count: N - 1) + [1000] // Small values then huge one
//         let C = 5
//         let S: Float = 0.75 // High risk
//         // Is it worth risking accumulation for the final large value?
//         let expectedProfit: Float = getExpected(N, V, C, S) // Calculation needed
//         XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC Late Large V High Risk")
//     }
//
//    // Hidden Test Case #16: Decreasing values
//    func testHiddenCase_DecreasingV() {
//        let N = 10
//        let V = (1...N).map { (N + 1 - $0) * 10 } // [100, 90, ..., 10]
//        let C = 40
//        let S: Float = 0.1
//        // Collect early vs wait for diminishing returns?
//        let expectedProfit: Float = getExpected(N, V, C, S) // Calculation needed
//        XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC Decreasing V")
//    }
//
//    // Hidden Test Case #17: Values hover around Cost* (1/(1-S))?
//    func testHiddenCase_ValuesNearBreakEven() {
//        let N = 10
//        let C = 50
//        let S: Float = 0.2
//        let breakEvenApprox = Double(C) / (1.0 - Double(S)) // ~62.5 - threshold area?
//        let V = [60, 65, 61, 64, 60, 66, 59, 63, 62, 67] // Values around threshold estimate
//        // Test sensitivity of threshold calculation
//        let expectedProfit: Float = getExpected(N, V, C, S) // Calculation needed
//        XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC V Near Break Even")
//    }
//
//    // Hidden Test Case #18: Cost = Value scenario
//     func testHiddenCase_CostEqualsValue() {
//         let N = 10
//         let V = Array(repeating: 50, count: N)
//         let C = 50
//         let S: Float = 0.1
//         // If P=V=C, decision depends purely on future gain vs risk. Thresholds key.
//         let expectedProfit: Float = getExpected(N, V, C, S) // Calculation needed
//         XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC Cost = Value")
//     }
//
//     // Hidden Test Case #19: Build up large E then lose it
//     func testHiddenCase_BuildAndLose() {
//         let N = 10
//         let V = [100, 100, 100, 100, 100, 0, 0, 0, 0, 0] // Build value then nothing
//         let C = 600 // High Cost, forces accumulation
//         let S: Float = 0.1
//         // Accumulate E, but cost too high to collect early. Later E decays.
//         let expectedProfit: Float = getExpected(N, V, C, S) // Calculation needed, likely 0?
//         XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC Build and Lose")
//     }
//
//
//    // MARK: - Precision Stress Tests (5 Cases)
//
//    // Hidden Test Case #20: Long sequence tiny V, tiny C
//    func testHiddenCase_LongTinyV_TinyC() {
//        let N = 2000
//        let V = Array(repeating: 1, count: N)
//        let C = 1
//        let S: Float = 0.001
//        // Accumulation of many small values, potential precision loss?
//        let expectedProfit: Float = getExpected(N, V, C, S) // Calculation needed
//        XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC Long Tiny V/C")
//    }
//
//    // Hidden Test Case #21: Values very close to each other
//    func testHiddenCase_CloseValues() {
//        let N = 50
//        // Values differing by small amounts
//        let V = (1...N).map { 100 + Int(Double($0) * 0.01) }
//        let C = 90
//        let S: Float = 0.05
//        // Test if small differences in V register correctly in DP
//        let expectedProfit: Float = getExpected(N, V, C, S) // Calculation needed
//        XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC Close Values")
//    }
//
//    // Hidden Test Case #22: Near Epsilon logic boundary?
//     func testHiddenCase_NearEpsilon() {
//         let N = 2
//         // Attempt to engineer P near T such that (P >= T - eps) is true but (P > C + eps) is false or vice versa
//         // Example: Make threshold T = 10.000000000005, Potential P = 10.000000000000, Cost C = 9.999999999990
//         // This is extremely hard to engineer perfectly a priori. Needs specific V, C, S.
//         // Let's use a simpler case that MIGHT trigger edge cases.
//         let V = [1000, 1000]
//         let C = 1000
//         let S: Float = 0.000000001 // Very very low S
//         // Thresholds should be very close to C. Potential values will be C + E.
//         let expectedProfit: Float = getExpected(N, V, C, S) // Calculation needed
//         // The check P > C + eps might be important here if P is almost exactly C.
//         XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC Near Epsilon (Conceptual)")
//     }
//
//     // Hidden Test Case #23: Alternating S values (conceptual - S is fixed)
//     // Test suites sometimes vary parameters IF the problem allowed. S IS FIXED here.
//     // Instead: Test S = 0.5 boundary.
//     func testHiddenCase_S_Half() {
//         let N = 20
//         let V = (1...N).map { $0 * 5 }
//         let C = 20
//         let S: Float = 0.5
//         // S=0.5 is a common boundary value in probability.
//         let expectedProfit: Float = getExpected(N, V, C, S) // Calculation needed
//         XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC S=0.5")
//     }
//
//     // Hidden Test Case #24: Max N, S=0 (Performance/Logic Check)
//     func testHiddenCase_MaxN_SZero() {
//         let N = 4000
//         let V = Array(repeating: 10, count: N)
//         let C = 10 * N + 1 // Cost slightly higher than total possible value
//         let S: Float = 0.0
//         // With S=0, E = sum(V). If Sum(V) > C, profit > 0. Here Sum(V)=40000, C=40001.
//         let expectedProfit: Float = 0.0 // Should not collect as total value < cost
//         XCTAssertEqual(getMaxExpectedProfit(N, V, C, S), expectedProfit, accuracy: accuracy, "HC Max N S=0 High C")
//     }
//}
