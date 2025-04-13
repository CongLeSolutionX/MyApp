//
//  PaymentCardContentView.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI

/// Card Model
struct Card: Hashable {
    var name: String = ""
    var number: String = ""
    var cvv: String = ""
    var month: String = ""
    var year: String = ""
    
    var rawCardNumber: String {
        number.replacingOccurrences(of: " ", with: "")
    }
}

/// Active TextField
enum ActiveField {
    case none
    case number
    case name
    case month
    case year
    case cvv
}

struct PaymentCardContentView: View {
    /// View Properties
    @State private var card: Card = .init()
    /// For some reason, the focusState is not animating properly. Not only that, but it’s also having improper animations for the matched geometry effect
    @FocusState private var activeField: ActiveField?
    @State private var animateField: ActiveField?
    /// Final Effect (Highlighting active field in the card with matched geometry effect)
    @Namespace private var animation
    var body: some View {
        VStack(spacing: 15) {
            /// Let's now build the card view
            ZStack {
                /// Simple mesh gradient
                if animateField != .cvv {
                    MeshGradient(
                        width: 3,
                        height: 3,
                        points: [
                            .init(0, 0), .init(0.5, 0), .init(1, 0),
                            .init(0, 0.5), .init(0.9, 0.6), .init(1, 0.5),
                            .init(0, 1), .init(0.5, 1), .init(1, 1)
                        ],
                        colors: [
                            .red, .red, .pink,
                            .pink, .orange, .red,
                            .red, .orange, .red
                        ]
                    )
                    .clipShape(.rect(cornerRadius: 25))
                    .overlay {
                        CardFrontView()
                    }
                    .transition(.flip)
                } else {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.red.mix(with: .blue, by: 0.2))
                        .overlay {
                            CardBackView()
                        }
                        .frame(height: 200)
                        .transition(.reverseFlip)
                }
            }
            .frame(height: 200)
            
            /// TextFields
            CustomTextField(title: "Card Number", hint: "", value: $card.number) {
                /// Limiting the number of digits to a maximum of 16 and adding a space for each four-digit group
                /// 16 digits + 3 space
                card.number = String(card.number.group(" ", count: 4).prefix(19))
            }
            .keyboardType(.numberPad)
            .focused($activeField, equals: .number)
            
            CustomTextField(title: "Card Name", hint: "", value: $card.name) {
                /// You can even add more validations as per your requirements
            }
            .autocorrectionDisabled()
            .keyboardType(.alphabet)
            .focused($activeField, equals: .name)
            
            HStack(spacing: 10) {
                /// Limiting Month and year to max length of 2 and cvv to 3
                /// You can even add more validations as per your requirements
                CustomTextField(title: "Month", hint: "", value: $card.month) {
                    card.month = String(card.month.prefix(2))
                    /// Let's shift to year when it have 2 digits
                    if card.month.count == 2 {
                        activeField = .year
                    }
                }
                .focused($activeField, equals: .month)
                
                CustomTextField(title: "Year", hint: "", value: $card.year) {
                    card.year = String(card.year.prefix(2))
                }
                .focused($activeField, equals: .year)
                
                CustomTextField(title: "CVV", hint: "", value: $card.cvv) {
                    card.cvv = String(card.cvv.prefix(3))
                }
                .focused($activeField, equals: .cvv)
            }
            .keyboardType(.numberPad)
            
            Spacer(minLength: 0)
        }
        .padding()
        .onChange(of: activeField) { oldValue, newValue in
            withAnimation(.snappy) {
                animateField = newValue
            }
        }
        /// Close Button
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    activeField = nil
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    /// Card Front View
    @ViewBuilder
    func CardFrontView() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 4) {
                Text("CARD NUMBER")
                    .font(.caption)
                
                /// Let’s display a temporary 16-digit * that will be replaced with the actual value as you type
                Text(String(card.rawCardNumber.dummyText("*", count: 16).prefix(16)).group(" ", count: 4))
                    .font(.title2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(AnimatedRing(animateField == .number))
            .frame(maxHeight: .infinity)
            
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CARD HOLDER")
                        .font(.caption)
                    
                    Text(card.name.isEmpty ? "YOUR NAME" : card.name)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(AnimatedRing(animateField == .name))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("EXPIRES")
                        .font(.caption)
                    
                    HStack(spacing: 4) {
                        Text(String(card.month.prefix(2)).dummyText("M", count: 2))
                        Text("/")
                        Text(String(card.year.prefix(2)).dummyText("Y", count: 2))
                    }
                }
                .padding(10)
                .background(AnimatedRing(animateField == .month || animateField == .year))
            }
        }
        .foregroundStyle(.white)
        .monospaced()
        .contentTransition(.numericText())
        .animation(.snappy, value: card)
        .padding(15)
    }
    
    /// Card Back View
    @ViewBuilder
    func CardBackView() -> some View {
        VStack(spacing: 15) {
            Rectangle()
                .fill(.black)
                .frame(height: 45)
                .padding(.horizontal, -15)
                .padding(.top, 10)
            
            VStack(alignment: .trailing, spacing: 6) {
                Text("CVV")
                    .font(.caption)
                    .padding(.trailing, 10)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white)
                    .frame(height: 45)
                    .overlay(alignment: .trailing) {
                        Text(String(card.cvv.prefix(3)).dummyText("*", count: 3))
                            .foregroundStyle(.black)
                            .padding(.trailing, 15)
                    }
            }
            .foregroundStyle(.white)
            .monospaced()
            
            Spacer(minLength: 0)
        }
        .padding(15)
        .contentTransition(.numericText())
        .animation(.snappy, value: card)
    }
    
    @ViewBuilder
    func AnimatedRing(_ status: Bool) -> some View {
        if status {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.white, lineWidth: 1.5)
                .matchedGeometryEffect(id: "RING", in: animation)
        }
    }
}

/// Custom Sectioned TextField
struct CustomTextField: View {
    var title: String
    var hint: String
    @Binding var value: String
    var onChange: () -> ()
    /// View Properties
    @FocusState private var isActive: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.gray)
            
            TextField(hint, text: $value)
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .contentShape(.rect)
                .background {
                    /// Changing Stroke Color when Active
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isActive ? .blue : .gray.opacity(0.5), lineWidth: 1.5)
                        .animation(.snappy, value: isActive)
                }
                .focused($isActive)
        }
        .onChange(of: value) { oldValue, newValue in
            onChange()
        }
    }
}

#Preview {
    PaymentCardContentView()
}

extension String {
    func group(_ character: Character, count: Int) -> String {
        var modifiedString = self.replacingOccurrences(of: String(character), with: "")
        
        for index in 0..<modifiedString.count {
            if index % count == 0 && index != 0 {
                let groupCharactersCount = modifiedString.count(where: { $0 == character })
                let stringIndex = modifiedString.index(modifiedString.startIndex, offsetBy: index + groupCharactersCount)
                modifiedString.insert(character, at: stringIndex)
            }
        }
        
        return modifiedString
    }
    
    func dummyText(_ character: Character, count: Int) -> String {
        var tempText = self.replacingOccurrences(of: String(character), with: "")
        let remaining = min(max(count - tempText.count, 0), count)
        
        if remaining > 0 {
            tempText.append(String(repeating: character, count: remaining))
        }
        
        return tempText
    }
}
