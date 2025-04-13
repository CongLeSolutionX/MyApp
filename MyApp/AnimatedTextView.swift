//
//  AnimatedTextView.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI

struct KeyPadValue {
    var stringValue: String = ""
    var stackViews: [Number] = []
    
    init(stringValue: String = "") {
        self.stringValue = stringValue
        
        for char in stringValue {
            stackViews.append(.init(value: String(char)))
        }
        
        updateCommas()
    }
    
    struct Number: Identifiable {
        var id: String = UUID().uuidString
        var value: String = ""
        var isComma: Bool = false
        /// Used for matched geometry effect
        var commaID: Int = 0
    }
    
    mutating func append(_ number: Int) {
        /// Limiting the maximum length and avoiding adding a zero as the first value
        guard !isExceedingMaxLength && (number == 0 ? !stringValue.isEmpty : true) else { return }
        
        stringValue.append(String(number))
        stackViews.append(.init(value: String(number)))
        
        updateCommas()
    }
    
    mutating func removeLast() {
        guard !stringValue.isEmpty else { return }
        
        stringValue.removeLast()
        stackViews.removeLast()
        
        updateCommas()
    }
    
    mutating func updateCommas() {
        guard let number = Int(stringValue) else { return }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: localeFormat)
        
        if let formattedNumber = formatter.string(from: .init(value: number)) {
            /// Removing Previous Commas
            stackViews.removeAll(where: \.isComma)
            
            let stackWithCommas = formattedNumber.compactMap {
                let value = String($0)
                
                return Number(value: value, isComma: value == ",")
            }
            
            let onlyCommaArray = stackWithCommas.filter(\.isComma)
            
            /// Adding Commas to actual stack view without modifying other stack view ids
            for index in stackWithCommas.indices {
                let number = stackWithCommas[index]
                let commaIndex = onlyCommaArray.firstIndex(where: { $0.id == number.id }) ?? 0
                
                if number.isComma {
                    stackViews.insert(
                        .init(value: ",", isComma: true, commaID: commaIndex),
                        at: index
                    )
                }
            }
        }
    }
    
    /// Other Computed Properties
    var isEmpty: Bool {
        stringValue.isEmpty
    }
    
    var isExceedingMaxLength: Bool {
        /// Im only setting the max length to 9, but you can change this as per your needs!
        stringValue.count >= 9
    }
    
    var intValue: Int {
        Int(stringValue) ?? 0
    }
    
    var localeFormat: String {
        /// Update this as per your needs!
        "en_US"
    }
}

/// This is a resuable Example
struct AnimatedTextView: View {
    @Binding var value: KeyPadValue
    @Namespace private var animation
    var body: some View {
        Group {
            Text(value.isEmpty ? "0" : "")
                .frame(width: value.isEmpty ? nil : 0)
                .contentTransition(.numericText())
                .padding(.leading, 3)
            
            ForEach(value.stackViews) { number in
                Group {
                    if number.isComma {
                        Text(",")
                            .contentTransition(.interpolate)
                            .matchedGeometryEffect(id: number.commaID, in: animation)
                    } else {
                        Text(number.value)
                            .contentTransition(.interpolate)
                            .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AnimatedTextView(value: .constant(KeyPadValue(stringValue: "100")))
}
