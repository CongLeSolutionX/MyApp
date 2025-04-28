////
////  InterpreterPattern_Demo2.swift
////  MyApp
////
////  Created by Cong Le on 4/28/25.
////
//
//import SwiftUI
//import Foundation // Needed for basic types and potentially NSExpression later if we switch strategies
//
//// MARK: - Interpreter Pattern Logic (Slightly adapted for clarity)
//
//// 1. Context (Remains mostly the same, but unused in this specific UI)
//class ExpressionContext {
//    private var variables: [String: Int] = [:]
//
//    func lookup(name: String) -> Int? {
//        return variables[name]
//    }
//
//    func assign(name: String, value: Int) {
//        print("[Context] Assigning \(value) to variable '\(name)'") // Keep for logging if needed
//        variables[name] = value
//    }
//}
//
//// 2. AbstractExpression Protocol
//protocol ArithmeticExpression {
//    func interpret(context: ExpressionContext) -> Int?
//    func description() -> String
//}
//
//// 3. Terminal Expressions
//class NumberExpression: ArithmeticExpression {
//    private let value: Int
//    init(_ value: Int) { self.value = value }
//    func interpret(context: ExpressionContext) -> Int? { return value }
//    func description() -> String { return "\(value)" }
//}
//
//// VariableExpression remains for pattern completeness, but unused in UI
//class VariableExpression: ArithmeticExpression {
//    private let name: String
//    init(_ name: String) { self.name = name }
//    func interpret(context: ExpressionContext) -> Int? {
//        guard let value = context.lookup(name: name) else {
//            print("[Interpret Error] Variable '\(name)' not found in context.")
//            return nil
//        }
//        return value
//    }
//    func description() -> String { return name }
//}
//
//// 4. NonTerminal Expressions (Binary Operations)
//// Base class for convenience
//class BinaryOperationExpression: ArithmeticExpression {
//    let leftOperand: ArithmeticExpression
//    let rightOperand: ArithmeticExpression
//    let operatorSymbol: String
//
//    init(left: ArithmeticExpression, right: ArithmeticExpression, symbol: String) {
//        self.leftOperand = left
//        self.rightOperand = right
//        self.operatorSymbol = symbol
//    }
//
//    // To be overridden
//    func interpret(context: ExpressionContext) -> Int? {
//        guard let leftValue = leftOperand.interpret(context: context),
//              let rightValue = rightOperand.interpret(context: context) else {
//            print("[Interpret Error] Operand interpretation failed for \(operatorSymbol)")
//            return nil
//        }
//        return performOperation(leftValue, rightValue)
//    }
//
//    // Template method for subclasses
//    func performOperation(_ left: Int, _ right: Int) -> Int? {
//        fatalError("performOperation must be overridden by subclasses")
//    }
//
//    func description() -> String {
//        return "(\(leftOperand.description()) \(operatorSymbol) \(rightOperand.description()))"
//    }
//}
//
//class AdditionExpression: BinaryOperationExpression {
//    init(left: ArithmeticExpression, right: ArithmeticExpression) { super.init(left: left, right: right, symbol: "+") }
//    override func performOperation(_ left: Int, _ right: Int) -> Int? { return left + right }
//}
//
//class SubtractionExpression: BinaryOperationExpression {
//    init(left: ArithmeticExpression, right: ArithmeticExpression) { super.init(left: left, right: right, symbol: "-") }
//    override func performOperation(_ left: Int, _ right: Int) -> Int? { return left - right }
//}
//
//class MultiplicationExpression: BinaryOperationExpression {
//    init(left: ArithmeticExpression, right: ArithmeticExpression) { super.init(left: left, right: right, symbol: "*") }
//    override func performOperation(_ left: Int, _ right: Int) -> Int? { return left * right }
//}
//
//// Division (Optional addition, requires handling division by zero)
//class DivisionExpression: BinaryOperationExpression {
//    init(left: ArithmeticExpression, right: ArithmeticExpression) { super.init(left: left, right: right, symbol: "/") }
//    override func performOperation(_ left: Int, _ right: Int) -> Int? {
//        guard right != 0 else {
//            print("[Interpret Error] Division by zero.")
//            return nil // Indicate error
//        }
//        return left / right // Integer division
//    }
//}
//
//// MARK: - SwiftUI Calculator UI & ViewModel
//
//// ViewModel to manage calculator state and logic
//class CalculatorViewModel: ObservableObject {
//
//    @Published var displayValue: String = "0" // What the user sees
//
//    private var currentNumberString: String = "0" // Number currently being typed
//    private var previousExpression: ArithmeticExpression? = nil // AST built so far (left operand)
//    private var pendingBinaryOperation: ((ArithmeticExpression, ArithmeticExpression) -> ArithmeticExpression)? = nil // Function to create the next operation node
//    private var expectingNewNumber: Bool = false // Flag after an operator is pressed
//
//    private let context = ExpressionContext() // Context for interpretation
//
//    // Button actions mapped to functions
//    func buttonPressed(label: String) {
//        switch label {
//        case "0"..."9":
//            handleDigit(label)
//        case "+", "-", "*", "/":
//            handleOperator(label)
//        case "=":
//            handleEquals()
//        case "C":
//            handleClear()
//        default:
//            break // Ignore other potential labels
//        }
//    }
//
//    // --- Action Handlers ---
//
//    private func handleDigit(_ digit: String) {
//        if expectingNewNumber {
//            currentNumberString = digit
//            expectingNewNumber = false
//        } else {
//            // Prevent leading zeros unless it's the only digit
//            if currentNumberString == "0" {
//                currentNumberString = digit
//            } else {
//                currentNumberString += digit
//            }
//        }
//        displayValue = currentNumberString
//    }
//
//    private func handleOperator(_ opSymbol: String) {
//        // Finalize the previous operation if one is pending
//        // This implements left-to-right evaluation
//        performPendingOperation()
//
//        // Store the current number as the left operand for the *next* operation
//        if let number = Int(currentNumberString) {
//             previousExpression = NumberExpression(number) // Store the current number expression
//        } else {
//             // Handle potential error state if currentNumberString isn't a valid Int
//             print("Error: Could not parse current number string '\(currentNumberString)'")
//             handleClear() // Reset on error
//             displayValue = "Error"
//             return
//         }
//
//        // Store the *function* that creates the specific operation expression
//        switch opSymbol {
//        case "+": pendingBinaryOperation = AdditionExpression.init
//        case "-": pendingBinaryOperation = SubtractionExpression.init
//        case "*": pendingBinaryOperation = MultiplicationExpression.init
//        case "/": pendingBinaryOperation = DivisionExpression.init
//        default: break
//        }
//
//        expectingNewNumber = true // Next digit input starts a new number
//        // Don't update displayValue until equals or another number is entered
//    }
//
//    private func handleEquals() {
//        performPendingOperation() // Perform the last pending operation
//        
//        // Interpret the final expression tree
//        if let finalExpr = previousExpression {
//            print("[Interpret] Evaluating Final AST: \(finalExpr.description())")
//            if let result = finalExpr.interpret(context: context) {
//                displayValue = "\(result)"
//                 // Prepare for new calculation, keeping result as starting point
//                 currentNumberString = "\(result)"
//                 previousExpression = NumberExpression(result) // Result becomes the start of a new chain
//                 pendingBinaryOperation = nil
//                 expectingNewNumber = true // Allows starting new sequence or chaining operators directly
//             } else {
//                displayValue = "Error" // Interpretation failed (e.g., div by zero)
//                resetCalculationState()
//            }
//        } else {
//             // If equals is pressed without an operation chain, just keep the current number
//             displayValue = currentNumberString
//             // Ensure state allows starting fresh or continuing
//             if let number = Int(currentNumberString) {
//                previousExpression = NumberExpression(number)
//             }
//             pendingBinaryOperation = nil
//             expectingNewNumber = true
//        }
//        // No 'expectingNewNumber = false' here, pressing equals finalizes the sequence
//    }
//    
//    private func handleClear() {
//        displayValue = "0"
//        resetCalculationState()
//     }
//     
//     // --- Helper Methods ---
//     
//     // Resets the state involved in building the expression tree
//     private func resetCalculationState() {
//         currentNumberString = "0"
//         previousExpression = nil
//         pendingBinaryOperation = nil
//         expectingNewNumber = false
//     }
//
//    // Performs the currently pending binary operation
//    private func performPendingOperation() {
//        // Ensure we have a left operand (previous expression), a pending operation, and a valid current number
//        guard let prevExpr = previousExpression,
//              let operation = pendingBinaryOperation,
//              let currentNum = Int(currentNumberString) else {
//
//            // If no operation is pending, the current number becomes the baseline expression
//            if pendingBinaryOperation == nil, let currentVal = Int(currentNumberString) {
//                 previousExpression = NumberExpression(currentVal)
//             }
//             // Otherwise, not enough info to perform operation yet, so just return.
//             return
//        }
//
//        // Create the right operand expression
//        let rightExpr = NumberExpression(currentNum)
//
//        // Create the new expression node using the stored function
//        let newExpression = operation(prevExpr, rightExpr)
//        
//        print("[AST Build] Created node: \(newExpression.description())")
//
//        // The result of this operation becomes the new 'previousExpression' for chaining
//        self.previousExpression = newExpression
//
//        // Clear the pending operation as it's been performed
//        self.pendingBinaryOperation = nil
//        // Don't reset currentNumberString here, it might be needed if user hits = immediately
//        // The result isn't necessarily displayed until '=' is pressed
//    }
//}
//
//// --- SwiftUI View Components ---
//
//// Custom Button Style for Calculator Buttons
//struct CalculatorButtonStyle: ButtonStyle {
//    var backgroundColor: Color = .gray.opacity(0.8)
//    var foregroundColor: Color = .white
//    var isWide: Bool = false // For '0' button
//
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.system(size: 32, weight: .medium))
//            .frame(maxWidth: isWide ? .infinity : 64, maxHeight: 64) // Square buttons, wide option
//            .padding(.horizontal, isWide ? 30 : 0) // Adjust padding for wide button text
//            .background(backgroundColor)
//            .foregroundColor(foregroundColor)
//            .cornerRadius(32) // Make them circular/rounded
//            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Press effect
//            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
//    }
//}
//
//// Main Calculator View
//struct ContentView: View {
//    @StateObject private var viewModel = CalculatorViewModel()
//
//    // Define button layout
//    let buttons: [[String]] = [
//        ["C", "+/-", "%", "/"], // Note: +/- and % are not implemented in ViewModel logic yet
//        ["7", "8", "9", "*"],
//        ["4", "5", "6", "-"],
//        ["1", "2", "3", "+"],
//        ["0", ".", "="] // Note: '.' (decimal) is not implemented yet
//    ]
//
//    var body: some View {
//        ZStack {
//            // Background
//            Color.black.edgesIgnoringSafeArea(.all)
//
//            VStack(spacing: 12) {
//                Spacer() // Push content down
//
//                // Display
//                HStack {
//                    Spacer() // Push text to the right
//                    Text(viewModel.displayValue)
//                        .font(.system(size: 80))
//                        .foregroundColor(.white)
//                        .lineLimit(1)
//                        .minimumScaleFactor(0.5) // Allow shrinking if too long
//                        .padding(.horizontal, 20)
//                }
//
//                // Buttons Grid
//                ForEach(buttons, id: \.self) { row in
//                    HStack(spacing: 12) {
//                        ForEach(row, id: \.self) { label in
//                            Button(action: {
//                                viewModel.buttonPressed(label: label)
//                            }) {
//                                // Label content (Text usually)
//                                Text(label)
//                                    // Style based on label type
//                                    .applyButtonStyle(label: label)
//                            }
//                        }
//                    }
//                }
//                .padding(.bottom)
//            }
//        }
//    }
//}
//
//// Helper extension to apply styles conditionally
//// (Makes the view code cleaner)
//extension Text {
//    @ViewBuilder
//    func applyButtonStyle(label: String) -> some View {
//        let isZero = (label == "0")
//        let isOperator = ["/", "*", "-", "+", "="].contains(label)
//        let isUtility = ["C", "+/-", "%"].contains(label) // Top row buttons
//
//        // Determine colors
//        let bgColor: Color = isOperator ? .orange : (isUtility ? .gray : .gray.opacity(0.8))
//        let fgColor: Color = isUtility ? .black : .white
//
//        // Apply the style
//        self.buttonStyle(CalculatorButtonStyle(backgroundColor: bgColor, foregroundColor: fgColor, isWide: isZero))
//    }
//}
//
//#Preview("ContentView") {
//    ContentView()
//}
//// MARK: - App Entry Point
////@main
////struct CalculatorApp: App {
////    var body: some Scene {
////        WindowGroup {
////            ContentView()
////        }
////    }
////}
