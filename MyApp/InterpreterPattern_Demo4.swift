//
//  InterpreterPattern_Demo4.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//

//
//  InterpreterPattern_Demo3_Optimized.swift
//  MyApp
//
//  Created by Cong Le on 4/28/25.
//

import SwiftUI
import Foundation

// MARK: - Interpreter Pattern Logic (Unchanged from previous functional version)
// ... (Keep the ExpressionContext, ArithmeticExpression, NumberExpression,
//      VariableExpression, BinaryOperationExpression, AdditionExpression,
//      SubtractionExpression, MultiplicationExpression, DivisionExpression
//      classes exactly as they were in the previous "Functional Calculator" response) ...
// 1. Context
class ExpressionContext {
    private var variables: [String: Double] = [:]
    func lookup(name: String) -> Double? { return variables[name] }
    func assign(name: String, value: Double) { variables[name] = value }
}

// 2. AbstractExpression Protocol
protocol ArithmeticExpression {
    func interpret(context: ExpressionContext) -> Double?
    func description() -> String
}

// 3. Terminal Expressions
class NumberExpression: ArithmeticExpression {
    let value: Double // Make public for potential inspection
    init(_ value: Double) { self.value = value }
    func interpret(context: ExpressionContext) -> Double? { return value }
    func description() -> String { return formatNumberForInterpreter(value) } // Use helper
}

class VariableExpression: ArithmeticExpression {
    private let name: String
    init(_ name: String) { self.name = name }
    func interpret(context: ExpressionContext) -> Double? { context.lookup(name: name) }
    func description() -> String { return name }
}

// 4. NonTerminal Expressions
// Base class for binary operations
class BinaryOperationExpression: ArithmeticExpression {
    let leftOperand: ArithmeticExpression
    let rightOperand: ArithmeticExpression
    let operatorSymbol: String

    init(left: ArithmeticExpression, right: ArithmeticExpression, symbol: String) {
        self.leftOperand = left
        self.rightOperand = right
        self.operatorSymbol = symbol
    }

    func interpret(context: ExpressionContext) -> Double? {
        guard let leftValue = leftOperand.interpret(context: context),
              let rightValue = rightOperand.interpret(context: context) else {
            print("[Interpret Error] Operand interpretation failed for \(operatorSymbol)")
            return nil
        }
        // Specific error check before performing
        if operatorSymbol == "/" && abs(rightValue) < 1e-15 { // Check for near-zero denominator
            print("[Interpret Error] Division by zero.")
            return Double.nan // Indicate error with NaN
        }
        return performOperation(leftValue, rightValue)
    }

    // To be overridden
    func performOperation(_ left: Double, _ right: Double) -> Double? {
        fatalError("performOperation must be overridden")
    }

    func description() -> String {
        // Ensure operands are described correctly, handle nested parens if needed
        let leftDesc = (leftOperand as? BinaryOperationExpression != nil) ? "(\(leftOperand.description()))" : leftOperand.description()
        let rightDesc = (rightOperand as? BinaryOperationExpression != nil) ? "(\(rightOperand.description()))" : rightOperand.description()
        return "\(leftDesc) \(operatorSymbol) \(rightDesc)"
    }
}

// Concrete Binary Operations
class AdditionExpression: BinaryOperationExpression {
    init(left: ArithmeticExpression, right: ArithmeticExpression) { super.init(left: left, right: right, symbol: "+") }
    override func performOperation(_ left: Double, _ right: Double) -> Double? { return left + right }
}

class SubtractionExpression: BinaryOperationExpression {
    init(left: ArithmeticExpression, right: ArithmeticExpression) { super.init(left: left, right: right, symbol: "-") }
    override func performOperation(_ left: Double, _ right: Double) -> Double? { return left - right }
}

class MultiplicationExpression: BinaryOperationExpression {
    init(left: ArithmeticExpression, right: ArithmeticExpression) { super.init(left: left, right: right, symbol: "*") }
    override func performOperation(_ left: Double, _ right: Double) -> Double? { return left * right }
}

class DivisionExpression: BinaryOperationExpression {
    init(left: ArithmeticExpression, right: ArithmeticExpression) { super.init(left: left, right: right, symbol: "/") }
    override func performOperation(_ left: Double, _ right: Double) -> Double? {
        guard abs(right) >= 1e-15 else { return Double.nan } // Guard again just in case, return NaN
        return left / right
    }
}

// Helper function for consistent number formatting within Interpreter logs/descriptions
func formatNumberForInterpreter(_ number: Double) -> String {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 8 // Or more for internal precision
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = "" // No separators internally
    return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
}

// MARK: - ViewModel Enhancements

// Enum for Binary Operators (improves type safety and clarity)
enum BinaryOperatorType: String {
    case add = "+"
    case subtract = "-"
    case multiply = "*"
    case divide = "/"

    // Function to create the corresponding Expression Node
    var expressionCreator: (ArithmeticExpression, ArithmeticExpression) -> ArithmeticExpression {
        switch self {
        case .add: return AdditionExpression.init
        case .subtract: return SubtractionExpression.init
        case .multiply: return MultiplicationExpression.init
        case .divide: return DivisionExpression.init
        }
    }
}

// Enhanced ViewModel
@MainActor
class CalculatorViewModel: ObservableObject {

    // --- State Properties ---
    @Published var displayValue: String = "0"    // What the user sees
    @Published var memoryValue: Double = 0.0      // Memory store
    @Published var isMemorySet: Bool = false      // Flag for MR button state visual cue (optional)
    @Published var hasError: Bool = false         // Indicates an error state
    @Published var currentOperatorSymbol: String? // Display current active operator (optional UI feature)

    private var currentInputString: String = "0"  // Number string currently being entered/modified
    private var previousExpression: ArithmeticExpression? = nil // Left operand / Intermediate result as AST
    private var pendingBinaryOperationType: BinaryOperatorType? = nil // The pending operation type
    private var expectingNewNumber: Bool = true   // Start new number vs. append. True initially.
    private var hasDecimal: Bool = false          // Track decimal point in currentInputString

    private let context = ExpressionContext()     // Interpreter context (remains unused for this calculator)
    private let maximumInputDigits = 12          // Limit input length

    // --- Formatting ---
    private let displayFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 8     // Max decimals to display
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = true // e.g., 1,000,000
        formatter.groupingSeparator = Locale.current.groupingSeparator ?? ","
        formatter.decimalSeparator = Locale.current.decimalSeparator ?? "."
        formatter.notANumberSymbol = "Error"
        formatter.maximumIntegerDigits = 20 // Prevents excessively long integer parts before sci notation kicks in
        // formatter.usesSignificantDigits = false // uncomment if you prefer fixed fraction digits
        return formatter
    }()
    
    // Formatter for scientific notation when needed
    private let scientificFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.maximumFractionDigits = 6
        formatter.exponentSymbol = "e"
        formatter.decimalSeparator = Locale.current.decimalSeparator ?? "."
        formatter.notANumberSymbol = "Error"
        return formatter
    }()

    // --- Initialization ---
    init() {
        // Can configure formatters further based on locale if needed
    }

    // --- Button Actions ---
    func buttonPressed(label: String) {
        triggerHapticFeedback() // Add feedback for all presses

        switch label {
        // Digits & Decimal
        case "0"..."9": handleDigit(label)
        case ".": handleDecimal()

        // Operators
        case "+", "-", "*", "/": handleOperator(label)
        case "=": handleEquals()

        // Utilities
        case "AC": handleClearAC() // Renamed from C
        case "+/-": handleSignChange()
        case "%": handlePercentage()

        // Memory Functions
        case "mc": handleMemoryClear()
        case "mr": handleMemoryRecall()
        case "m+": handleMemoryAdd()
        case "m-": handleMemorySubtract()

        default: print("Button '\(label)' not implemented")
        }
    }

    // --- Action Handlers ---

    private func handleDigit(_ digit: String) {
        if hasError { resetErrorState() } // Clear error on new input

        // Input length limit check
        let currentDigits = currentInputString.filter { $0.isNumber }
        guard currentDigits.count < maximumInputDigits else { return }

        if expectingNewNumber {
            currentInputString = digit
            hasDecimal = false
            expectingNewNumber = !isZero(digit) // Stay expecting if first digit is 0
        } else {
            // Prevent multiple leading zeros unless it's just "0" or after decimal
            if currentInputString == "0" && !hasDecimal {
                 currentInputString = digit
            } else if currentInputString == "-0" && !hasDecimal {
                 currentInputString = "-" + digit
            } else {
                currentInputString += digit
            }
        }
        // Don't format display during pure input, show raw entry
        displayValue = currentInputString
        // If we just typed a digit, we are definitely not expecting a *new* number immediately after
        if currentInputString != "0" { // Special case: typing 0 doesn't end expectation
             expectingNewNumber = false
         }
    }

    private func handleDecimal() {
        if hasError { resetErrorState() }
        // Input length limit (consider decimal part)
        guard currentInputString.count < maximumInputDigits + (currentInputString.contains("-") ? 1 : 0) + 1 else { return }

        if expectingNewNumber {
            currentInputString = "0."
            hasDecimal = true
            expectingNewNumber = false
        } else if !hasDecimal {
            currentInputString += Locale.current.decimalSeparator ?? "."
            hasDecimal = true
            expectingNewNumber = false // Added decimal, clearly inputting
        }
        displayValue = currentInputString
    }
    
    private func handleOperator(_ opSymbol: String) {
        if hasError { return } // Don't allow operators after an error

        // Attempt Calculation: Try to perform any pending operation first
        // This uses the number currently *displayed* or just entered as the right operand.
        performPendingOperation()
        
        // Store the new operation type
        if let currentNumValue = parseInput(currentInputString) {
             // Only update previousExpression if parsing succeeded
             previousExpression = NumberExpression(currentNumValue)
         } else if previousExpression == nil {
             // If input is invalid AND there's no prior expression, it's likely an error state
              displayError()
              return
          }
        // If parsing failed BUT we have a previousExpression, we might be chaining operators
        // after a result. E.g., 5 + = * 2. Keep the previousExpression result.

        guard let opType = BinaryOperatorType(rawValue: opSymbol) else { return }
        pendingBinaryOperationType = opType
        currentOperatorSymbol = opSymbol // Update UI cue

        // Prepare for the next number
        expectingNewNumber = true
        hasDecimal = false // Reset for the next input
        // Display reflects the result of the previous operation (or the number just entered if it's the first op)
        if let number = previousExpression?.interpret(context: context) {
            displayValue = formatDisplay(value: number)
        }
    }

    private func handleEquals() {
        if hasError { return }
        
        performPendingOperation()

        // Final display after equals
         if let finalExpression = previousExpression, let result = finalExpression.interpret(context: context) {
             displayValue = formatDisplay(value: result)
             if result.isNaN { // Check if interpret flagged an error (e.g., div/0)
                 displayError()
             } else {
                 // Successfully calculated: store result as the new starting point
                 currentInputString = formatRawNumber(result) // Store unformatted result internally
                 previousExpression = NumberExpression(result) // Update AST
                 hasDecimal = currentInputString.contains(Locale.current.decimalSeparator ?? ".")
             }
         } else if !expectingNewNumber, let currentNumValue = parseInput(currentInputString) {
             // If equals is pressed with just a number entered (no pending op)
             displayValue = formatDisplay(value: currentNumValue)
             previousExpression = NumberExpression(currentNumValue)
             currentInputString = formatRawNumber(currentNumValue)
             hasDecimal = currentInputString.contains(Locale.current.decimalSeparator ?? ".")
         } else if previousExpression == nil {
             // Equals pressed with nothing meaningful entered or calculated yet
              // Keep display as 0 or current partial input. No operation.
             displayValue = formatDisplay(value: parseInput(currentInputString) ?? 0.0)
         }

        // Reset state after equals, ready for new calculation chain
        pendingBinaryOperationType = nil
        currentOperatorSymbol = nil
        expectingNewNumber = true // Must start a new number or use operator on result
    }

    private func handleClearAC() {
        // Full reset
        displayValue = "0"
        currentInputString = "0"
        previousExpression = nil
        pendingBinaryOperationType = nil
        currentOperatorSymbol = nil
        expectingNewNumber = true
        hasDecimal = false
        resetErrorState() // Clear any error indication
    }

    private func handleSignChange() {
        if hasError { return }

        // If an operation was just performed and we're expecting a new number,
        // apply the sign change to the *result* displayed.
        if expectingNewNumber, previousExpression != nil, let prevResult = previousExpression?.interpret(context: context) {
            let toggledValue = -prevResult
            displayValue = formatDisplay(value: toggledValue)
            currentInputString = formatRawNumber(toggledValue) // Update internal representation
            previousExpression = NumberExpression(toggledValue) // Update stored expression
            hasDecimal = currentInputString.contains(Locale.current.decimalSeparator ?? ".")
        }
        // Otherwise, apply to the number currently being entered.
        else if !expectingNewNumber {
            if currentInputString.starts(with: "-") {
                currentInputString.removeFirst()
            } else if currentInputString != "0" {
                currentInputString = "-" + currentInputString
            }
            displayValue = currentInputString // Show raw input during sign change
        }
        // If expecting number but no previous result (e.g., after AC), do nothing or toggle "0" (current behavior is fine).
    }

    private func handlePercentage() {
        if hasError { return }
        
        let valueToConvert: Double?
        
        // If expecting new number, apply to the last result if available
        if expectingNewNumber, let prevResult = previousExpression?.interpret(context: context) {
             valueToConvert = prevResult
         }
         // Otherwise, apply to the current input
         else {
             valueToConvert = parseInput(currentInputString)
         }

        guard let number = valueToConvert else {
             displayError()
             return
         }
        
        let percentageValue = number / 100.0
        displayValue = formatDisplay(value: percentageValue)
        currentInputString = formatRawNumber(percentageValue) // Update internal representation
        hasDecimal = currentInputString.contains(Locale.current.decimalSeparator ?? ".")
        
        // Make the percentage result the start of the next potential calculation
        previousExpression = NumberExpression(percentageValue)
        // Percentage usually finalizes the entry, ready for next operator or number
        expectingNewNumber = true
        pendingBinaryOperationType = nil // Clear pending op after %
        currentOperatorSymbol = nil
    }

    // --- Memory Handlers ---
    private func handleMemoryClear() {
        memoryValue = 0.0
        isMemorySet = false
        print("[Memory] Cleared")
    }

    private func handleMemoryRecall() {
        if hasError { resetErrorState() }
        
        currentInputString = formatRawNumber(memoryValue) // Use raw format internally
        displayValue = formatDisplay(value: memoryValue) // Format for display
        hasDecimal = currentInputString.contains(Locale.current.decimalSeparator ?? ".")
        expectingNewNumber = false // MR loads a number, ready to be used or modified
        print("[Memory] Recalled: \(memoryValue)")
    }

    private func handleMemoryAdd() {
        if hasError { return }
        guard let currentDisplayNum = parseDisplay(displayValue) else { return } // Use current display value
        
        memoryValue += currentDisplayNum
        isMemorySet = abs(memoryValue) > 1e-15
        // M+ usually doesn't interrupt the current calculation flow
        print("[Memory] Added \(currentDisplayNum). New Memory: \(memoryValue)")
    }

    private func handleMemorySubtract() {
        if hasError { return }
        guard let currentDisplayNum = parseDisplay(displayValue) else { return } // Use current display value

        memoryValue -= currentDisplayNum
        isMemorySet = abs(memoryValue) > 1e-15
         // M- usually doesn't interrupt the current calculation flow
        print("[Memory] Subtracted \(currentDisplayNum). New Memory: \(memoryValue)")
    }

    // --- Helper Methods ---

     private func performPendingOperation() {
         // Guard against missing components for the operation
         guard let pendingOpType = pendingBinaryOperationType,
               let leftExpr = previousExpression,
               let rightNum = parseInput(currentInputString)  // Use the most recent valid input
         else {
             // If no pending operation, or missing operands, do nothing.
             // Ensure the current number is stored if it's the start of a chain
             if pendingBinaryOperationType == nil, let currentVal = parseInput(currentInputString), !expectingNewNumber {
                 previousExpression = NumberExpression(currentVal)
             }
             return
         }

         let rightExpr = NumberExpression(rightNum)
         let operationCreator = pendingOpType.expressionCreator
         let newExpression = operationCreator(leftExpr, rightExpr)

         print("[AST Build] Evaluating intermediate: \(newExpression.description())")
         if let result = newExpression.interpret(context: context) {
             if result.isNaN { // Check for errors like division by zero from interpret
                 displayError()
                 // Clear state that led to error
                 previousExpression = nil
                 pendingBinaryOperationType = nil
                 currentOperatorSymbol = nil
                 expectingNewNumber = true
             } else {
                 // Success: Update the state with the result
                 previousExpression = NumberExpression(result) // Result becomes the new left operand AST
                 displayValue = formatDisplay(value: result)  // Display the intermediate result
                 currentInputString = formatRawNumber(result) // Store raw number internally for next step
                 hasDecimal = currentInputString.contains(Locale.current.decimalSeparator ?? ".")
                 // Keep pendingBinaryOperationType = nil (it was just consumed)
                 // Keep expectingNewNumber = true (ready for the next number)
             }
         } else {
             // Interpretation failed unexpectedly (should ideally return NaN now)
             print("[Interpret Error] Operation interpretation failed unexpectedly.")
             displayError()
             previousExpression = nil
             pendingBinaryOperationType = nil
             currentOperatorSymbol = nil
             expectingNewNumber = true
         }
        // Don't reset pendingBinaryOperationType here; it's reset *after* a successful operation or equals
        // currentOperatorSymbol = nil // Also reset after equals or next operator press
     }

    // Parses the internal currentInputString
    private func parseInput(_ input: String) -> Double? {
        // Replace locale-specific decimal separator for Double conversion if needed
        let standardInput = input.replacingOccurrences(of: Locale.current.decimalSeparator ?? ".", with: ".")
        return Double(standardInput)
    }

    // Parses the formatted displayValue (use cautiously)
    private func parseDisplay(_ display: String) -> Double? {
        // Remove grouping separators before parsing
        let cleanedDisplay = display.replacingOccurrences(of: Locale.current.groupingSeparator ?? ",", with: "")
        // Replace decimal separator for Double()
        let standardDisplay = cleanedDisplay.replacingOccurrences(of: Locale.current.decimalSeparator ?? ".", with: ".")
        // Handle potential scientific notation parsing if needed (Double initializer handles 'e' typically)
        return Double(standardDisplay)
    }

    // Formats a Double for display, handling scientific notation
    private func formatDisplay(value: Double?) -> String {
        guard let number = value, number.isFinite else {
            return displayFormatter.notANumberSymbol // Handles NaN, infinity
        }

        // Determine if scientific notation is needed
        let absoluteValue = abs(number)
        if absoluteValue > 999_999_999 || (absoluteValue < 0.000_000_01 && absoluteValue != 0) {
             return scientificFormatter.string(from: NSNumber(value: number)) ?? displayFormatter.notANumberSymbol
        } else {
            return displayFormatter.string(from: NSNumber(value: number)) ?? displayFormatter.notANumberSymbol
        }
    }
    
    // Formats a number for internal storage (avoids locale formatting issues)
    private func formatRawNumber(_ number: Double) -> String {
         // Uses a basic formatter without grouping, standard decimal point '.'
         let rawFormatter = NumberFormatter()
         rawFormatter.numberStyle = .decimal
         rawFormatter.maximumFractionDigits = 15 // More internal precision
         rawFormatter.minimumFractionDigits = 0
         rawFormatter.usesGroupingSeparator = false
         rawFormatter.decimalSeparator = "." // Ensure standard decimal point for internal use
         return rawFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
     }

    private func displayError() {
        displayValue = displayFormatter.notANumberSymbol
        hasError = true
        // Don't reset everything immediately, allow user to see the error.
        // Reset happens on next digit/clear press.
    }

    private func resetErrorState() {
        hasError = false
        // Optionally reset more state if needed when error is cleared by input
        // handleClearAC performs a full reset if user presses AC
    }

    private func isZero(_ str: String) -> Bool {
        // Basic check, could be enhanced for "-0", "0.0" etc. if needed
        return str == "0"
    }
    
    // --- Haptics ---
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    private func triggerHapticFeedback() {
        hapticGenerator.prepare()
        hapticGenerator.impactOccurred()
    }
}

// MARK: - SwiftUI View Components (Updated for New Buttons & Layout)

// Button Style (Unchanged)
struct CalculatorButtonStyle: ButtonStyle {
    var backgroundColor: Color = .gray.opacity(0.8)
    var foregroundColor: Color = .white
    var isWide: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 30, weight: .medium)) // Slightly smaller font maybe
            .frame(maxWidth: isWide ? .infinity : 64, minHeight: 64, maxHeight: 64) // Ensure height
            .padding(.horizontal, isWide ? 20 : 0)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Main View (Updated Layout)
struct ContentView: View {
    @StateObject private var viewModel = CalculatorViewModel()

    // Define button layout with memory functions
    let buttons: [[String]] = [
        ["mc", "m+", "m-", "mr"],      // Memory row
        ["AC", "+/-", "%", "/"],      // Utilities row (AC instead of C)
        ["7", "8", "9", "*"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", ".", "="]
    ]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 12) {
                Spacer()

                // Display Area
                HStack {
                     // Optional: Display memory indicator ('M') if viewModel tells us
                     if viewModel.isMemorySet {
                         Text("M")
                             .font(.system(size: 18, weight: .bold))
                             .foregroundColor(.gray)
                             .padding(.leading, 25)
                     }
                     Spacer() // Pushes Display value to the right
                    Text(viewModel.displayValue)
                        .font(.system(size: 88, weight: .light))
                        .foregroundColor(viewModel.hasError ? .red : .white) // Error color
                        .lineLimit(1)
                        .minimumScaleFactor(0.2) // Allow significant shrinking
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 10)

                // Buttons Grid
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { label in
                            Button {
                                viewModel.buttonPressed(label: label)
                            } label: {
                                // ButtonStyle handles sizing based on 'isWide'
                                Text(label)
                            }
                            .applyConditionalButtonStyle(label: label, memoryActive: viewModel.isMemorySet)
                        }
                    }
                }
                .padding(.bottom)
            }
            .padding(.horizontal, 12)
        }
    }
}

// Helper extension for conditional button styling (Updated)
extension Button {
    // Pass memory state for potential MR button styling
    func applyConditionalButtonStyle(label: String, memoryActive: Bool) -> some View {
        let isZero = (label == "0")
        let isDigit = ("0"..."9").contains(label)
        let isDecimal = (label == ".")
        let isBasicOperator = ["/", "*", "-", "+", "="].contains(label)
        let isTopUtility = ["AC", "+/-", "%"].contains(label)
        let isMemoryControl = ["mc", "m+", "m-", "mr"].contains(label)

        var bgColor: Color
        var fgColor: Color = .white // Default foreground

        if isBasicOperator {
            bgColor = .orange
        } else if isTopUtility {
            bgColor = Color(.lightGray)
            fgColor = .black
        } else if isDigit || isDecimal {
             bgColor = Color(.darkGray).opacity(0.8)
        } else if isMemoryControl {
            // Slightly different color for memory buttons
            bgColor = Color(white: 0.4) // Darker gray for memory
            // Optionally highlight MR when memory is set
             if label == "mr" && memoryActive {
                 // Maybe slightly lighter or different color? Keep consistent for now.
                 // bgColor = Color(white: 0.5)
             }
        }
        else { // Default catch-all (shouldn't be hit with current layout)
            bgColor = Color(.darkGray).opacity(0.8)
        }

        return self.buttonStyle(CalculatorButtonStyle(backgroundColor: bgColor, foregroundColor: fgColor, isWide: isZero))
    }
}

// MARK: - App Entry Point
@main
struct CalculatorAppOptimized: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Preview
#Preview("Optimized Calculator") {
     ContentView()
}
