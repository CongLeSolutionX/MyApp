//
//  ContentView.swift
//  MyApp
//
//  Created by Cong Le on 8/19/24.
//

import SwiftUI
//
//// Step 2: Use in SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        UIKitViewControllerWrapper()
//            .edgesIgnoringSafeArea(.all) /// Ignore safe area to extend the background color to the entire screen
//    }
//}
//
//// Before iOS 17, use this syntax for preview UIKit view controller
//struct UIKitViewControllerWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        UIKitViewControllerWrapper()
//    }
//}
//
//// After iOS 17, we can use this syntax for preview:
//#Preview {
//    ContentView()
//}

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var number1: String = ""
    @State private var number2: String = ""
    @State private var result: String = ""
    @State private var errorMessage: String = ""
    
    let calculator = Calculator()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Simple Calculator")
                .font(.largeTitle)
                .padding()
            
            TextField("Enter first number", text: $number1)
                .keyboardType(.decimalPad)
                .padding()
                .border(Color.gray)
                .padding([.leading, .trailing], 20)
            
            TextField("Enter second number", text: $number2)
                .keyboardType(.decimalPad)
                .padding()
                .border(Color.gray)
                .padding([.leading, .trailing], 20)
            
            HStack(spacing: 20) {
                Button("Add") {
                    calculate(operation: "add")
                }
                Button("Subtract") {
                    calculate(operation: "subtract")
                }
            }
            
            HStack(spacing: 20) {
                Button("Multiply") {
                    calculate(operation: "multiply")
                }
                Button("Divide") {
                    calculate(operation: "divide")
                }
            }
            
            if !result.isEmpty {
                Text("Result: \(result)")
                    .font(.title)
                    .padding()
            }
            
            if !errorMessage.isEmpty {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        }
    }
    
    func calculate(operation: String) {
        errorMessage = ""
        result = ""
        
        guard let a = Double(number1), let b = Double(number2) else {
            errorMessage = "Please enter valid numbers."
            return
        }
        
        do {
            let res: Double
            switch operation {
            case "add":
                res = calculator.add(a, b)
            case "subtract":
                res = calculator.subtract(a, b)
            case "multiply":
                res = calculator.multiply(a, b)
            case "divide":
                res = try calculator.divide(a, b)
            default:
                res = 0
            }
            result = String(res)
        } catch CalculatorError.divisionByZero {
            errorMessage = "Cannot divide by zero."
        } catch {
            errorMessage = "An unexpected error occurred."
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
