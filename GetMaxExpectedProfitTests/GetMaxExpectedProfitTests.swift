//
//  GetMaxExpectedProfitTests.swift
//  GetMaxExpectedProfitTests
//
//  Created by Cong Le on 4/26/25.
//

@testable import MyApp
import XCTest

// Assuming the function 'getMaxExpectedProfit' is accessible,
// either in the same module or imported.
// If it's in another file like 'Solution.swift', ensure it's part of the test target.
final class GetMaxExpectedProfitTests: XCTestCase {
  
        // Define a suitable accuracy for comparing floating-point results
        // Should be looser than the internal epsilon (1e-11) to account for minor variations,
        // but tight enough based on problem constraints (e.g., 8 decimal places -> 1e-9 or 1e-8)
        let accuracy: Float = 1e-8

        // MARK: - Trivial and Edge Cases

        func testNIsZero() {
            // If there are no days, profit must be 0.
            XCTAssertEqual(getMaxExpectedProfit(0, [], 10, 0.1), 0.0, accuracy: accuracy)
        }

        func testNIsOne_Collect() {
            // One day, value > cost. Should collect.
            XCTAssertEqual(getMaxExpectedProfit(1, [100], 10, 0.1), 90.0, accuracy: accuracy)
        }

        func testNIsOne_DoNotCollect_CostTooHigh() {
            // One day, value < cost. Should not collect, final E=0.
            XCTAssertEqual(getMaxExpectedProfit(1, [5], 10, 0.1), 0.0, accuracy: accuracy)
        }

        func testNIsOne_DoNotCollect_SIsHigh() {
            // One day, value > cost, but high S makes waiting risky.
            // Threshold analysis: Find v where (v-C) + f(1,0) = f(1, (1-S)v)
            // (v-10) + 0 = max(0, (1-0.9)*v - 10) = max(0, 0.1v - 10)
            // Threshold T0 = 100. Since V[0]=11 < T0, we don't collect.
            // E1 = (1-0.9)*11 = 1.1. Final Profit = max(0, 1.1 - 10) = 0.
            XCTAssertEqual(getMaxExpectedProfit(1, [11], 10, 0.9), 0.0, accuracy: accuracy, "Test reflects Simple Greedy failure: Collect profit=1 -> Incorrect")
        }

        func testSIsZero_NoRisk() {
            // No risk, collect only when accumulated value maximizes profit vs cost.
            // N=3, V=[3, 3, 10], C=5, S=0.
            // Day 0: P=3. T0? Balance(v)=(v-5)+f(1,0) - f(1,v). Need T1, T2.
            // T2: (v-5)+f(3,0) = f(3,v) -> v-5 = max(0,v-5) -> T2=5.
            // T1: (v-5)+f(2,0)=f(2,(1-0)v). f(2,0)=max(0,0+V[2]-5)=max(0,10-5)=5. f(2,v)=max((v+V[2]-5)+f(3,0), f(3,v)) = max(v+10-5, max(0,v-5)) = max(v+5, max(0,v-5)).
            // Eq: (v-5)+5 = max(v+5, max(0, v-5)). v = max(v+5, max(0, v-5)). Always false. Implies never collect?
            // Let's rethink for S=0: f(i,E)=max((E+Vi-C)+f(i+1,0), f(i+1, E+Vi)).
            // f(3,E)=max(0,E-5).
            // f(2,E)=max((E+10-5)+f(3,0), f(3,E+10)) = max(E+5+max(0,-5), max(0, E+10-5)) = max(E+5, max(0,E+5)) = E+5.
            // f(1,E)=max((E+3-5)+f(2,0), f(2,E+3)) = max(E-2+f(2,0), (E+3)+5) = max(E-2+(0+5), E+8) = max(E+3, E+8) = E+8.
            // f(0,E)=max((E+3-5)+f(1,0), f(1,E+3)) = max(E-2+f(1,0), (E+3)+8) = max(E-2+(0+8), E+11) = max(E+6, E+11) = E+11.
            // Final profit f(0,0) = 11.
            XCTAssertEqual(getMaxExpectedProfit(3, [3, 3, 10], 5, 0.0), 11.0, accuracy: accuracy)
        }

        func testSIsOne_GuaranteedLoss() {
            // Must collect immediately if profitable, as waiting guarantees loss.
            // N=3, V=[100, 100, 100], C=10, S=1.0
            // Day 0: P=100. Threshold T0? Eq: (v-10)+f(1,0)=f(1,0*v)=f(1,0). -> v-10=0 -> v=10. T0=10. Collect (100 > 10). Profit=90, E=0.
            // Day 1: P=100. T1? Eq: (v-10)+f(2,0)=f(2,0*v)=f(2,0). -> v=10. T1=10. Collect (100 > 10). Profit=90, E=0.
            // Day 2: P=100. T2? Eq: (v-10)+f(3,0)=f(3,0*v)=f(3,0). -> v=10. T2=10. Collect (100 > 10). Profit=90, E=0. Total = 270.
            XCTAssertEqual(getMaxExpectedProfit(3, [100, 100, 100], 10, 1.0), 270.0, accuracy: accuracy)
        }

        func testCIsZero_FreeCollection() {
            // Always collect if value > 0, accumulation depends on S.
            // N=3, V=[10, 10, 10], C=0, S=0.5
            // Profit = 10 + 10 + 10 = 30. Since C=0, it's always better to collect than risk losing 50%.
            XCTAssertEqual(getMaxExpectedProfit(3, [10, 10, 10], 0, 0.5), 30.0, accuracy: accuracy)
        }

        func testCIsVeryHigh_NeverCollect() {
            // Cost is too high, profit should be 0.
            XCTAssertEqual(getMaxExpectedProfit(3, [100, 100, 100], 1000, 0.1), 0.0, accuracy: accuracy)
        }

        func testVAllZero() {
            // No value means no profit.
            XCTAssertEqual(getMaxExpectedProfit(3, [0, 0, 0], 10, 0.1), 0.0, accuracy: accuracy)
        }

        // MARK: - Tests Reflecting Problem-Solving Journey

        func testScenario_SimpleGreedyFails() {
            // Case from analysis: N=1, V=[11], C=10, S=0.9
            // Simple Greedy collects (P=11 > C=10), profit = 1.
            // Correct DP waits (T0=100), E1=1.1, final profit = max(0, 1.1-10) = 0.
            XCTAssertEqual(getMaxExpectedProfit(1, [11], 10, 0.9), 0.0, accuracy: accuracy, "Simple Greedy would incorrectly yield 1.0")
        }

         func testScenario_CsThresholdFails_ComplexInteraction() {
            // This test aims to replicate a scenario similar to Sample Case #4,
            // where the C/S threshold suggests collecting, but waiting yields better future value.
            // Requires specific V, C, S values known to cause this failure.
            // Using Sample Case 4 directly is the best way.
            // N=3, V=[10, 10, 100], C=12, S=0.5
            // C/S Threshold = 12 / 0.5 = 24.
            // Day 0: P=10. Don't collect (10 < 24). E1 = (1-0.5)*10 = 5.
            // Day 1: P=5+10=15. Don't collect (15 < 24). E2 = (1-0.5)*15 = 7.5.
            // Day 2: P=7.5+100=107.5. Collect (107.5 >= 24). Profit = 107.5 - 12 = 95.5. Total = 95.5.
            // Optimal (from problem statement) = 97.0
             XCTAssertEqual(getMaxExpectedProfit(3, [10, 10, 100], 12, 0.5), 97.0, accuracy: accuracy, "C/S Threshold Greedy would incorrectly yield 95.5")
         }

        // MARK: - Official Sample Cases

        func testSampleCase1() {
            // N = 3, V = [10, 10, 10], C = 10, S = 0.5
            // Expected: 17.5
            // Day 0: Wait (P=10). E1=5.
            // Day 1: Wait (P=5+10=15). E2=7.5.
            // Day 2: Collect (P=7.5+10=17.5). Profit=17.5-10 = 7.5. Total=7.5?? Incorrect manual. DP needed.
            XCTAssertEqual(getMaxExpectedProfit(3, [10, 10, 10], 10, 0.5), 17.5, accuracy: accuracy)
        }

        func testSampleCase2() {
            // N = 3, V = [10, 10, 10], C = 12, S = 0.5
            // Expected: 14.0
            XCTAssertEqual(getMaxExpectedProfit(3, [10, 10, 10], 12, 0.5), 14.0, accuracy: accuracy)
        }

        func testSampleCase3() {
            // N = 3, V = [10, 10, 100], C = 10, S = 0.5
            // Expected: 100.0
            XCTAssertEqual(getMaxExpectedProfit(3, [10, 10, 100], 10, 0.5), 100.0, accuracy: accuracy)
        }

        func testSampleCase4() {
            // N = 3, V = [10, 10, 100], C = 12, S = 0.5
            // Expected: 97.0 (This is the case that broke C/S threshold)
            XCTAssertEqual(getMaxExpectedProfit(3, [10, 10, 100], 12, 0.5), 97.0, accuracy: accuracy)
        }

        // MARK: - Potential Precision Stress Test (Difficult to get exact expected value)

        func testLongSequenceSmallProbability() {
             // A longer sequence where small differences due to S might accumulate.
             // Hard to calculate expected value manually, but check for non-crash / plausible result.
             let n = 50
             let v = Array(repeating: 5, count: n) // Constant small value
             let c = 10
             let s: Float = 0.01 // Small chance of theft
             // With S=0, E accumulates. E50 = 50*5 = 250. Profit = 250-10 = 240.
             // With small S, E accumulates slower. The expected value might be slightly less than 250.
             // Thresholds will likely be low. Expect profit slightly less than 240.
             let result = getMaxExpectedProfit(n, v, c, s)
             XCTAssertTrue(result >= 0 && result <= 240, "Result plausibility check")
             // We can't easily assert a precise value without an independent solver.
             // Example check: Slightly less than the S=0 case.
             XCTAssertLessThan(result, 240.0, "Profit should be less than S=0 case due to risk")
        }
    }

//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        // Any test you write for XCTest can be annotated as throws and async.
//        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
//        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
