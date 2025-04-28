//
//  InterpreterPattern_Demo.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//

import Foundation

// MARK: - Introduction: Interpreter Pattern Concept
/*
 * The Interpreter design pattern defines a grammatical representation for a language
 * and provides an interpreter to evaluate sentences in that language.
 * It's a BEHAVIORAL pattern.
 *
 * Core Idea: Use a class hierarchy to represent grammar rules. Each rule or symbol
 * is a class. Sentences become Abstract Syntax Trees (ASTs) of these class instances.
 *
 * Components:
 * 1.  AbstractExpression: Protocol/Interface for interpretation.
 * 2.  TerminalExpression: Leaf nodes of the AST (variables, constants).
 * 3.  NonTerminalExpression: Internal nodes of the AST (operations, rules).
 * 4.  Context: Global information needed during interpretation (e.g., variable values).
 * 5.  Client: Builds the AST and triggers interpretation. (Parser often builds the AST).
 */

// MARK: - 1. Context
/// Contains global information (like variable values) needed by the interpreter.
class ExpressionContext {
    private var variables: [String: Int] = [:] // Simple context storing Int variables

    /// Looks up the value of a variable by name.
    func lookup(name: String) -> Int? {
        return variables[name]
    }

    /// Assigns a value to a variable name.
    func assign(name: String, value: Int) {
        print("[Context] Assigning \(value) to variable '\(name)'")
        variables[name] = value
    }

    /// Helper to print current context state
    func printState() {
        print("[Context] Current State: \(variables)")
    }
}

// MARK: - 2. AbstractExpression (Protocol)
/// Declares the `interpret` operation common to all nodes in the AST.
/// Represents the abstract concept of an expression that can be evaluated.
protocol ArithmeticExpression {
    /// Evaluates (interprets) the expression within a given context.
    /// Returns the result of the interpretation (an Int in this case) or nil if interpretation fails.
    func interpret(context: ExpressionContext) -> Int?

    /// Optional: A way to represent the expression structure as a string for debugging/visualization.
    func description() -> String
}

// MARK: - 3. Terminal Expressions
/// Represents leaf nodes in the AST - the basic elements of the language.

/// Represents a constant integer value.
class NumberExpression: ArithmeticExpression {
    private let value: Int

    init(_ value: Int) {
        self.value = value
        // print("[AST Node Created] Number: \(value)")
    }

    func interpret(context: ExpressionContext) -> Int? {
        // A number just evaluates to itself.
        // print("[Interpret] NumberExpression returning \(value)")
        return value
    }

    func description() -> String {
        return "\(value)"
    }
}

/// Represents a variable that needs to be looked up in the context.
class VariableExpression: ArithmeticExpression {
    private let name: String

    init(_ name: String) {
        self.name = name
        // print("[AST Node Created] Variable: \(name)")
    }

    func interpret(context: ExpressionContext) -> Int? {
        // Look up the variable's value in the context.
        guard let value = context.lookup(name: name) else {
            print("[Interpret Error] Variable '\(name)' not found in context.")
            return nil // Indicate failure
        }
        // print("[Interpret] VariableExpression '\(name)' returning \(value)")
        return value
    }

    func description() -> String {
        return name
    }
}

// MARK: - 4. NonTerminal Expressions
/// Represents internal nodes in the AST - operations or rules that combine other expressions.

/// Abstract base for binary operations (optional, but can reduce code duplication).
class BinaryOperationExpression: ArithmeticExpression {
    let leftOperand: ArithmeticExpression
    let rightOperand: ArithmeticExpression
    let operatorSymbol: String // For description

    init(left: ArithmeticExpression, right: ArithmeticExpression, symbol: String) {
        self.leftOperand = left
        self.rightOperand = right
        self.operatorSymbol = symbol
        // print("[AST Node Created] Binary Operation: \(symbol)")
    }

    // This needs to be implemented by concrete subclasses
    func interpret(context: ExpressionContext) -> Int? {
        fatalError("interpret(context:) must be overridden by subclasses")
    }

    func description() -> String {
        // Parenthesize to show structure clearly
        return "(\(leftOperand.description()) \(operatorSymbol) \(rightOperand.description()))"
    }
}

/// Represents an addition operation.
class AdditionExpression: BinaryOperationExpression {
    init(left: ArithmeticExpression, right: ArithmeticExpression) {
        super.init(left: left, right: right, symbol: "+")
    }

    override func interpret(context: ExpressionContext) -> Int? {
        // print("[Interpret] Evaluating Addition...")
        // Recursively interpret the left and right children
        guard let leftValue = leftOperand.interpret(context: context) else {
            print("[Interpret Error] Left operand of '+' failed.")
            return nil
        }
        guard let rightValue = rightOperand.interpret(context: context) else {
            print("[Interpret Error] Right operand of '+' failed.")
            return nil
        }

        let result = leftValue + rightValue
        // print("[Interpret] Addition \(leftValue) + \(rightValue) = \(result)")
        return result
    }
}

/// Represents a subtraction operation.
class SubtractionExpression: BinaryOperationExpression {
    init(left: ArithmeticExpression, right: ArithmeticExpression) {
        super.init(left: left, right: right, symbol: "-")
    }

    override func interpret(context: ExpressionContext) -> Int? {
        // print("[Interpret] Evaluating Subtraction...")
        guard let leftValue = leftOperand.interpret(context: context) else {
            print("[Interpret Error] Left operand of '-' failed.")
            return nil
        }
        guard let rightValue = rightOperand.interpret(context: context) else {
            print("[Interpret Error] Right operand of '-' failed.")
            return nil
        }

        let result = leftValue - rightValue
        // print("[Interpret] Subtraction \(leftValue) - \(rightValue) = \(result)")
        return result
    }
}

/// Represents a multiplication operation.
class MultiplicationExpression: BinaryOperationExpression {
    init(left: ArithmeticExpression, right: ArithmeticExpression) {
        super.init(left: left, right: right, symbol: "*")
    }

    override func interpret(context: ExpressionContext) -> Int? {
        // print("[Interpret] Evaluating Multiplication...")
        guard let leftValue = leftOperand.interpret(context: context) else {
            print("[Interpret Error] Left operand of '*' failed.")
            return nil
        }
        guard let rightValue = rightOperand.interpret(context: context) else {
            print("[Interpret Error] Right operand of '*' failed.")
            return nil
        }

        let result = leftValue * rightValue
        // print("[Interpret] Multiplication \(leftValue) * \(rightValue) = \(result)")
        return result
    }
}

// MARK: - 5. Client Usage (Demonstration)
//print("--- Interpreter Pattern Demo ---")
//print("-------------------------------\n")
//
//// --- Setup Context ---
//let context = ExpressionContext()
//context.assign(name: "w", value: 5)
//context.assign(name: "x", value: 10)
//context.assign(name: "y", value: 4)
//context.assign(name: "z", value: 2)
//context.printState()
//print("\n--- Building & Interpreting ASTs ---")
//
//// --- Example 1: Simple Expression "x + 5" ---
//print("\nExample 1: Simple Expression")
//// AST representing: x + 5
//let expression1: ArithmeticExpression = AdditionExpression(
//    left: VariableExpression("x"),
//    right: NumberExpression(5)
//)
//print("  Building AST for expression: \(expression1.description())")
//print("  Interpreting...")
//if let result1 = expression1.interpret(context: context) {
//    // Expected: 10 + 5 = 15
//    print("  ✅ Result for \(expression1.description()): \(result1)\n")
//} else {
//    print("  ❌ Interpretation failed for \(expression1.description())\n")
//}
//
//// --- Example 2: More Complex Expression "(w * x) - (y + z)" ---
//print("Example 2: Complex Expression")
//// AST representing: (w * x) - (y + z)
//// This demonstrates nesting of NonTerminalExpressions
//let expression2: ArithmeticExpression = SubtractionExpression(
//    left: MultiplicationExpression( // Left operand of '-' is w * x
//        left: VariableExpression("w"),
//        right: VariableExpression("x")
//    ),
//    right: AdditionExpression( // Right operand of '-' is y + z
//        left: VariableExpression("y"),
//        right: VariableExpression("z")
//    )
//)
//print("  Building AST for expression: \(expression2.description())")
//print("  Interpreting...")
//if let result2 = expression2.interpret(context: context) {
//    // Expected: (5 * 10) - (4 + 2) = 50 - 6 = 44
//    print("  ✅ Result for \(expression2.description()): \(result2)\n")
//} else {
//    print("  ❌ Interpretation failed for \(expression2.description())\n")
//}
//
//// --- Example 3: Expression with undefined variable "y + unknown" ---
//print("Example 3: Expression with Undefined Variable")
//// AST representing: y + unknown
//let expression3: ArithmeticExpression = AdditionExpression(
//    left: VariableExpression("y"),
//    right: VariableExpression("unknown") // This variable is not in the context
//)
//print("  Building AST for expression: \(expression3.description())")
//print("  Interpreting...")
//if let result3 = expression3.interpret(context: context) {
//    // This branch should not be hit
//    print("  ✅ Result for \(expression3.description()): \(result3)\n")
//} else {
//    // Expected: Error message and nil result
//    print("  ✅ Interpretation correctly failed (as expected) for \(expression3.description()) due to missing variable.\n")
//}
//
//// --- Example 4: Constant Expression "100 - 25" ---
//print("Example 4: Constant Expression")
//// AST representing: 100 - 25
//let expression4: ArithmeticExpression = SubtractionExpression(
//    left: NumberExpression(100),
//    right: NumberExpression(25)
//)
//print("  Building AST for expression: \(expression4.description())")
//print("  Interpreting...")
//if let result4 = expression4.interpret(context: context) {
//    // Expected: 100 - 25 = 75
//    print("  ✅ Result for \(expression4.description()): \(result4)\n")
//} else {
//    print("  ❌ Interpretation failed for \(expression4.description())\n")
//}
//
//print("-------------------------------")
//print("--- End of Interpreter Demo ---")

// MARK: - Conclusion / Recap
/*
 * This example demonstrates:
 * - How different expression types (Number, Variable, Add, Subtract, Multiply) subclass
 *   or conform to a common `ArithmeticExpression` protocol.
 * - How `TerminalExpression` (Number, Variable) provide base values or look them up.
 * - How `NonTerminalExpression` (Add, Subtract, Multiply) recursively call `interpret`
 *   on their children and combine the results.
 * - The role of the `Context` in providing external state (variable values).
 * - How the `Client` (this demo code) manually constructs an AST and initiates interpretation.
 *   (In a real scenario, a parser would typically generate the AST from a string).
 *
 * Potential improvements/extensions:
 * - Add more operations (division, modulo, unary minus).
 * - Support different data types (e.g., Float, Bool).
 * - Implement an actual parser to build the AST from a string input.
 * - Add more error handling and reporting.
 */
