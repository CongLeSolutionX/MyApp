////
////  InterpreterPattern_Demo3.swift
////  MyApp
////
////  Created by Cong Le on 4/28/25.
////
//
//import SwiftUI
//import Foundation // Needed for Double, NumberFormatter
//
//// MARK: - Interpreter Pattern Logic (Updated for Double)
//
//// 1. Context (Remains unused in UI, kept for pattern structure)
//class ExpressionContext {
//    // Variables could store Doubles if needed
//    private var variables: [String: Double] = [:]
//
//    func lookup(name: String) -> Double? {
//        return variables[name]
//    }
//
//    func assign(name: String, value: Double) {
//        print("[Context] Assigning \(value) to variable '\(name)'")
//        variables[name] = value
//    }
//}
//
//// 2. AbstractExpression Protocol (Returns Double?)
//protocol ArithmeticExpression {
//    func interpret(context: ExpressionContext) -> Double?
//    func description() -> String
//}
//
//// 3. Terminal Expressions (Handles Double)
//class NumberExpression: ArithmeticExpression {
//    private let value: Double
//    init(_ value: Double) { self.value = value }
//    func interpret(context: ExpressionContext) -> Double? { return value }
//    func description() -> String {
//        // Basic formatting for description
//        return NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal)
//    }
//}
//
//// VariableExpression (Handles Double if used)
//class VariableExpression: ArithmeticExpression {
//    private let name: String
//    init(_ name: String) { self.name = name }
//    func interpret(context: ExpressionContext) -> Double? {
//        guard let value = context.lookup(name: name) else {
//            print("[Interpret Error] Variable '\(name)' not found in context.")
//            return nil
//        }
//        return value
//    }
//    func description() -> String { return name }
//}
//
//// 4. NonTerminal Expressions (Handles Double)
//// Base class modified slightly
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
//    func interpret(context: ExpressionContext) -> Double? {
//        guard let leftValue = leftOperand.interpret(context: context),
//              let rightValue = rightOperand.interpret(context: context) else {
//            print("[Interpret Error] Operand interpretation failed for \(operatorSymbol)")
//            return nil
//        }
//        // Check for specific errors like division by zero *before* performing
//        if operatorSymbol == "/" && rightValue == 0 {
//            print("[Interpret Error] Division by zero.")
//            return nil // Specific error handling
//        }
//        return performOperation(leftValue, rightValue)
//    }
//
//    // Template method for subclasses (takes and returns Double?)
//    func performOperation(_ left: Double, _ right: Double) -> Double? {
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
//    override func performOperation(_ left: Double, _ right: Double) -> Double? { return left + right }
//}
//
//class SubtractionExpression: BinaryOperationExpression {
//    init(left: ArithmeticExpression, right: ArithmeticExpression) { super.init(left: left, right: right, symbol: "-") }
//    override func performOperation(_ left: Double, _ right: Double) -> Double? { return left - right }
//}
//
//class MultiplicationExpression: BinaryOperationExpression {
//    init(left: ArithmeticExpression, right: ArithmeticExpression) { super.init(left: left, right: right, symbol: "*") }
//    override func performOperation(_ left: Double, _ right: Double) -> Double? { return left * right }
//}
//
//class DivisionExpression: BinaryOperationExpression {
//    init(left: ArithmeticExpression, right: ArithmeticExpression) { super.init(left: left, right: right, symbol: "/") }
//    override func performOperation(_ left: Double, _ right: Double) -> Double? {
//        // Guard already handled in base class interpret, but good practice
//        guard right != 0 else { return nil }
//        return left / right
//    }
//}
//
//// MARK: - SwiftUI Calculator UI & ViewModel (Enhanced)
//
//// ViewModel to manage calculator state and logic (Handles Double)
//@MainActor // Ensure UI updates are on the main thread
//class CalculatorViewModel: ObservableObject {
//
//    @Published var displayValue: String = "0" // What the user sees
//
//    private var currentNumberString: String = "0" // Number currently being typed (String to handle '.')
//    private var previousExpression: ArithmeticExpression? = nil // AST built so far
//    private var pendingBinaryOperationCreator: ((ArithmeticExpression, ArithmeticExpression) -> ArithmeticExpression)? = nil // Function to create the next operation node
//    private var expectingNewNumber: Bool = false // Flag after an operator or equals is pressed
//    private var hasDecimal: Bool = false // Track if the current number already has a decimal
//
//    private let context = ExpressionContext() // Context for interpretation
//
//    // Formatter for display
//    private let numberFormatter: NumberFormatter = {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        formatter.maximumFractionDigits = 8 // Limit display precision
//        formatter.notANumberSymbol = "Error" // Display for NaN
//        formatter.groupingSeparator = "" // Optional: remove thousands separators like ','
//        return formatter
//    }()
//
//    // Button actions mapped to functions
//    func buttonPressed(label: String) {
//        switch label {
//        case "0"..."9":
//            handleDigit(label)
//        case ".":
//            handleDecimal()
//        case "+", "-", "*", "/":
//            handleOperator(label)
//        case "=":
//            handleEquals()
//        case "C":
//            handleClear()
//        case "+/-":
//            handleSignChange()
//        case "%":
//            handlePercentage()
//        default:
//            print("Button '\(label)' not implemented") // Log unimplemented buttons
//        }
//    }
//
//    // --- Action Handlers ---
//
//    private func handleDigit(_ digit: String) {
//        // If an error state is showing, start fresh
//        if displayValue == numberFormatter.notANumberSymbol || displayValue == "Division by Zero" {
//            handleClear()
//        }
//        
//        if expectingNewNumber {
//            currentNumberString = digit
//            hasDecimal = false // Reset decimal flag for new number
//            expectingNewNumber = false
//        } else {
//            // Prevent leading zeros unless it's the only digit or after decimal
//            if currentNumberString == "0" && !hasDecimal {
//                 currentNumberString = digit
//            } else if currentNumberString == "-0" && !hasDecimal{ // Handle after +/- on 0
//                 currentNumberString = "-" + digit
//            }
//            else {
//                currentNumberString += digit
//            }
//        }
//        displayValue = currentNumberString // Show raw input temporarily
//    }
//
//    private func handleDecimal() {
//        // If an error state is showing, start fresh
//        if displayValue == numberFormatter.notANumberSymbol || displayValue == "Division by Zero" {
//            handleClear()
//        }
//        
//        // Start new number if needed (e.g., after operator)
//        if expectingNewNumber {
//            currentNumberString = "0."
//            hasDecimal = true
//            expectingNewNumber = false
//        } else if !hasDecimal { // Only add decimal if one doesn't exist
//            currentNumberString += "."
//            hasDecimal = true
//        }
//        displayValue = currentNumberString
//    }
//
//    private func handleOperator(_ opSymbol: String) {
//        // Allow chaining operators - finalize the previous one first
//        performPendingOperation()
//
//        // Store the current number string (parse it) as the left operand for the *next* operation
//        if let currentNumValue = Double(currentNumberString) {
//            previousExpression = NumberExpression(currentNumValue)
//        } else {
//             // Handle potential error state if currentNumberString isn't a valid Double
//             print("Error: Could not parse current number string '\(currentNumberString)' for operator.")
//             displayErrorMessage("Error")
//             return
//        }
//
//        // Store the *function* that creates the specific operation expression
//        switch opSymbol {
//        case "+": pendingBinaryOperationCreator = AdditionExpression.init
//        case "-": pendingBinaryOperationCreator = SubtractionExpression.init
//        case "*": pendingBinaryOperationCreator = MultiplicationExpression.init
//        case "/": pendingBinaryOperationCreator = DivisionExpression.init
//        default: break
//        }
//
//        expectingNewNumber = true // Next digit input starts a new number
//        hasDecimal = false // Reset decimal flag for the *next* number
//        // Don't update displayValue here; show the *result* of the previous op if available, or keep current num
//        if let prevResult = previousExpression?.interpret(context: context) {
//            displayValue = formatDisplay(value: prevResult)
//        }
//    }
//
//    private func handleEquals() {
//        performPendingOperation() // Perform the last pending operation
//
//        // Interpret the final expression tree
//        if let finalExpr = previousExpression {
//            print("[Interpret] Evaluating Final AST: \(finalExpr.description())")
//            if let result = finalExpr.interpret(context: context) {
//                 displayValue = formatDisplay(value: result)
//                 // Prepare for new calculation, keeping result as starting point
//                 currentNumberString = "\(result)" // Store raw result potentially
//                 previousExpression = NumberExpression(result) // Result becomes the start of a new chain
//                 pendingBinaryOperationCreator = nil
//                 expectingNewNumber = true // Allows starting new sequence or chaining operators
//                 hasDecimal = currentNumberString.contains(".") // Update decimal status based on result
//             } else {
//                 // Interpretation failed (e.g., div by zero handled in interpret now)
//                 displayErrorMessage(displayValue == "Division by Zero" ? "Division by Zero" : numberFormatter.notANumberSymbol) // Check if interpret set a specific error
//            }
//        } else {
//             // If equals is pressed without an operation chain, format the current number
//             if let currentNumValue = Double(currentNumberString) {
//                 displayValue = formatDisplay(value: currentNumValue)
//                 previousExpression = NumberExpression(currentNumValue) // Store it for potential chaining
//                 expectingNewNumber = true
//                 hasDecimal = currentNumberString.contains(".")
//             } else {
//                 displayErrorMessage("Error") // Parsing failed
//              }
//             pendingBinaryOperationCreator = nil
//        }
//    }
//
//    private func handleClear() {
//        displayValue = "0"
//        currentNumberString = "0"
//        previousExpression = nil
//        pendingBinaryOperationCreator = nil
//        expectingNewNumber = false
//        hasDecimal = false
//    }
//    
//    private func handleSignChange() {
//        if displayValue == numberFormatter.notANumberSymbol || displayValue == "Division by Zero" { return } // Don't toggle sign of error
//        
//        if currentNumberString.starts(with: "-") {
//            currentNumberString.removeFirst()
//        } else if currentNumberString != "0" { // Don't add '-' to just "0"
//            currentNumberString = "-" + currentNumberString
//        }
//        
//        // If expecting new number, apply change to 0 or last result for display continuity
//        if expectingNewNumber, let previousResult = previousExpression?.interpret(context: context) {
//            let toggledValue = -previousResult
//            currentNumberString = formatDisplay(value: toggledValue) // Update internal string too
//            previousExpression = NumberExpression(toggledValue) // Update the expression state
//            displayValue = currentNumberString // Display the toggled result
//        } else {
//             displayValue = currentNumberString // Display the modified current entry
//        }
//    }
//
//    private func handlePercentage() {
//        // Apply percentage only to the *current* number being displayed/entered
//        if displayValue == numberFormatter.notANumberSymbol || displayValue == "Division by Zero" { return }
//        
//        if let currentValue = Double(currentNumberString) {
//            let percentageValue = currentValue / 100.0
//            currentNumberString = formatDisplay(value: percentageValue) // Use formatter to avoid precision issues in string
//            displayValue = currentNumberString
//            hasDecimal = currentNumberString.contains(".") // Update decimal status
//            
//            // If a calculation was pending or just completed, make the percentage result
//            // the new starting point for the next operation or display.
//            previousExpression = NumberExpression(percentageValue)
//            expectingNewNumber = true // Ready for operator or new number
//
//        } else {
//             print("Error: Could not apply percentage to '\(currentNumberString)'")
//             displayErrorMessage("Error")
//        }
//    }
//
//    // --- Helper Methods ---
//    
//    // Performs the currently pending binary operation
//    private func performPendingOperation() {
//        // Ensure we have a left operand, a pending operation creator, and a valid current number (parse it)
//        guard let prevExpr = previousExpression,
//              let createOperation = pendingBinaryOperationCreator,
//              let currentNumValue = Double(currentNumberString) else {
//              // If no operation pending, ensure current number is potentially stored as previousExpression
//               if pendingBinaryOperationCreator == nil, let currentVal = Double(currentNumberString) {
//                   previousExpression = NumberExpression(currentVal)
//               }
//               return // Not enough info or nothing to do
//        }
//
//        // Create the right operand expression
//        let rightExpr = NumberExpression(currentNumValue)
//
//        // Create the new expression node using the stored creator function
//        let newExpression = createOperation(prevExpr, rightExpr)
//        print("[AST Build] Created node: \(newExpression.description())")
//
//        // Check for calculation errors during interpretation *before* updating state
//        if let result = newExpression.interpret(context: context) {
//            // Success: This becomes the new 'previousExpression' for chaining
//            self.previousExpression = NumberExpression(result) // Store the *result* expression
//             displayValue = formatDisplay(value: result) // Update display immediately with intermediate result
//             currentNumberString = formatDisplay(value: result) // Keep internal string sync'd
//             hasDecimal = currentNumberString.contains(".")
//        } else {
//             // Failure (e.g., division by zero): Display error and reset
//             print("[Interpret Error] Operation resulted in nil.")
//             displayErrorMessage("Division by Zero") // interpret handles div by zero specifically
//             // Don't update previousExpression on error
//             // Resetting pending op prevents further errors with the failed state
//             self.pendingBinaryOperationCreator = nil
//             expectingNewNumber = true // Allow starting fresh
//             return
//        }
//        
//        // Clear the pending operation creator as it's been conceptually 'used'
//        // by storing its *result* in previousExpression
//        self.pendingBinaryOperationCreator = nil
//        // Ready for the next number
//        expectingNewNumber = true
//     }
//
//    // Helper to format numbers for display
//    private func formatDisplay(value: Double?) -> String {
//        guard let value = value else { return numberFormatter.notANumberSymbol }
//
//        // Handle specific errors representation if needed
//        if value.isNaN { return numberFormatter.notANumberSymbol }
//        // Add explicit check for division by zero if interpret didn't catch it somehow (shouldn't happen with current logic)
//
//        return numberFormatter.string(from: NSNumber(value: value)) ?? numberFormatter.notANumberSymbol
//    }
//    
//    // Helper to display error messages and prepare for reset
//    private func displayErrorMessage(_ message: String) {
//        displayValue = message
//        // Resetting core state prevents cascading errors
//        previousExpression = nil
//        pendingBinaryOperationCreator = nil
//        expectingNewNumber = true // Allow user to start typing a new number immediately
//        hasDecimal = false
//        currentNumberString = "0" // Reset internal number string
//    }
//}
//
//// MARK: - SwiftUI View Components (Mostly Unchanged)
//
//// Custom Button Style
//struct CalculatorButtonStyle: ButtonStyle {
//    var backgroundColor: Color = .gray.opacity(0.8)
//    var foregroundColor: Color = .white
//    var isWide: Bool = false
//
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.system(size: 32, weight: .medium))
//            .frame(maxWidth: isWide ? .infinity : 64, maxHeight: 64, alignment: .center) // Ensure height consistency
//            .padding(.horizontal, isWide ? 25 : 0) // Adjust padding for wide button centering
//            .background(backgroundColor)
//            .foregroundColor(foregroundColor)
//            .clipShape(Capsule()) // Use Capsule for iOS standard look
//            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
//            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
//    }
//}
//
//// Main Calculator View
//struct ContentView: View {
//    @StateObject private var viewModel = CalculatorViewModel()
//
//    // Define button layout (ensure all symbols match ViewModel cases)
//    let buttons: [[String]] = [
//        ["C", "+/-", "%", "/"],
//        ["7", "8", "9", "*"],
//        ["4", "5", "6", "-"],
//        ["1", "2", "3", "+"],
//        ["0", ".", "="] // Ensure '.' is handled
//    ]
//
//    var body: some View {
//        ZStack {
//            Color.black.edgesIgnoringSafeArea(.all)
//
//            VStack(spacing: 12) {
//                Spacer()
//
//                // Display
//                HStack {
//                    Spacer()
//                    Text(viewModel.displayValue)
//                        .font(.system(size: 88, weight: .light)) // iOS calculator font style
//                        .foregroundColor(.white)
//                        .lineLimit(1)
//                        .minimumScaleFactor(0.3) // Allow more shrinking
//                        .padding(.horizontal, 20)
//                        .padding(.trailing, 5) // Slight adjust for alignment
//                }
//                .padding(.bottom, 10)
//
//                // Buttons Grid
//                ForEach(buttons, id: \.self) { row in
//                    HStack(spacing: 12) {
//                        ForEach(row, id: \.self) { label in
//                            Button {
//                                viewModel.buttonPressed(label: label)
//                            } label: {
//                                // Frame inside ButtonStyle will handle size
//                                Text(label)
//                            }
//                            // Apply style conditionally inside loop
//                            .applyButtonStyle(label: label)
//                        }
//                    }
//                }
//                .padding(.bottom)
//            }
//            .padding(.horizontal, 12) // Overall horizontal padding for the grid
//        }
//    }
//}
//
//// Helper extension for conditional button styling
//extension Button {
//    func applyButtonStyle(label: String) -> some View {
//        let isZero = (label == "0")
//        // Note: The warning "Initialization of immutable value 'isDigitOrDecimal' was never used"
//        // is technically true because the final 'else' covers this case implicitly.
//        // You can ignore this warning or add an explicit `else if isDigitOrDecimal` check
//        // if you prefer, but it won't affect the build error fix.
//        _ = (("0"..."9").contains(label) || label == ".")
//        let isOperator = ["/", "*", "-", "+", "="].contains(label)
//        let isTopUtility = ["C", "+/-", "%"].contains(label)
//
//        let bgColor: Color
//        let fgColor: Color
//
//        if isOperator {
//            bgColor = .orange
//            fgColor = .white
//        } else if isTopUtility {
//            bgColor = Color(.lightGray) // Lighter gray for top utilities
//            fgColor = .black
//        } else { // Digits and decimal implicitly includes isDigitOrDecimal
//            bgColor = Color(.darkGray).opacity(0.8) // Darker gray for numbers
//            fgColor = .white
//        }
//
//        // Use the ButtonStyle directly - this returns the View
//        return self.buttonStyle(CalculatorButtonStyle(backgroundColor: bgColor, foregroundColor: fgColor, isWide: isZero))
//    }
//}
//// MARK: - App Entry Point
//@main
//struct CalculatorAppFunctional: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
//
//#Preview("Functional Calculator") {
//     ContentView()
//}
