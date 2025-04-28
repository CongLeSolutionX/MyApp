//
//  UIKitViewControllerWrapper.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
import UIKit

// Step 1a: UIViewControllerRepresentable implementation
struct UIKitViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyUIKitViewController
    
    // Step 1b: Required methods implementation
    func makeUIViewController(context: Context) -> MyUIKitViewController {
        // Step 1c: Instantiate and return the UIKit view controller
        return MyUIKitViewController()
    }
    
    func updateUIViewController(_ uiViewController: MyUIKitViewController, context: Context) {
        // Update the view controller if needed
    }
}

// Example UIKit view controller
class MyUIKitViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        // Additional setup
        
        runInterpreterPattern_Demo()
    }
    
    func runInterpreterPattern_Demo(){
        print("--- Interpreter Pattern Demo ---")
        print("-------------------------------\n")

        // --- Setup Context ---
        let context = ExpressionContext()
        context.assign(name: "w", value: 5)
        context.assign(name: "x", value: 10)
        context.assign(name: "y", value: 4)
        context.assign(name: "z", value: 2)
        context.printState()
        print("\n--- Building & Interpreting ASTs ---")

        // --- Example 1: Simple Expression "x + 5" ---
        print("\nExample 1: Simple Expression")
        // AST representing: x + 5
        let expression1: ArithmeticExpression = AdditionExpression(
            left: VariableExpression("x"),
            right: NumberExpression(5)
        )
        print("  Building AST for expression: \(expression1.description())")
        print("  Interpreting...")
        if let result1 = expression1.interpret(context: context) {
            // Expected: 10 + 5 = 15
            print("  ✅ Result for \(expression1.description()): \(result1)\n")
        } else {
            print("  ❌ Interpretation failed for \(expression1.description())\n")
        }

        // --- Example 2: More Complex Expression "(w * x) - (y + z)" ---
        print("Example 2: Complex Expression")
        // AST representing: (w * x) - (y + z)
        // This demonstrates nesting of NonTerminalExpressions
        let expression2: ArithmeticExpression = SubtractionExpression(
            left: MultiplicationExpression( // Left operand of '-' is w * x
                left: VariableExpression("w"),
                right: VariableExpression("x")
            ),
            right: AdditionExpression( // Right operand of '-' is y + z
                left: VariableExpression("y"),
                right: VariableExpression("z")
            )
        )
        print("  Building AST for expression: \(expression2.description())")
        print("  Interpreting...")
        if let result2 = expression2.interpret(context: context) {
            // Expected: (5 * 10) - (4 + 2) = 50 - 6 = 44
            print("  ✅ Result for \(expression2.description()): \(result2)\n")
        } else {
            print("  ❌ Interpretation failed for \(expression2.description())\n")
        }

        // --- Example 3: Expression with undefined variable "y + unknown" ---
        print("Example 3: Expression with Undefined Variable")
        // AST representing: y + unknown
        let expression3: ArithmeticExpression = AdditionExpression(
            left: VariableExpression("y"),
            right: VariableExpression("unknown") // This variable is not in the context
        )
        print("  Building AST for expression: \(expression3.description())")
        print("  Interpreting...")
        if let result3 = expression3.interpret(context: context) {
            // This branch should not be hit
            print("  ✅ Result for \(expression3.description()): \(result3)\n")
        } else {
            // Expected: Error message and nil result
            print("  ✅ Interpretation correctly failed (as expected) for \(expression3.description()) due to missing variable.\n")
        }

        // --- Example 4: Constant Expression "100 - 25" ---
        print("Example 4: Constant Expression")
        // AST representing: 100 - 25
        let expression4: ArithmeticExpression = SubtractionExpression(
            left: NumberExpression(100),
            right: NumberExpression(25)
        )
        print("  Building AST for expression: \(expression4.description())")
        print("  Interpreting...")
        if let result4 = expression4.interpret(context: context) {
            // Expected: 100 - 25 = 75
            print("  ✅ Result for \(expression4.description()): \(result4)\n")
        } else {
            print("  ❌ Interpretation failed for \(expression4.description())\n")
        }

        print("-------------------------------")
        print("--- End of Interpreter Demo ---")

    }
}
