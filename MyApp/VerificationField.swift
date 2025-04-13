//
//  VerificationField.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI

/// Properties
enum CodeType: Int, CaseIterable {
    case four = 4
    case six = 6
    
    var stringValue: String {
        "\(rawValue) Digit"
    }
}

enum TypingState {
    case typing
    case valid
    case invalid
}

enum TextFieldStyle: String, CaseIterable {
    case roundedBorder = "Rounded Border"
    case underlined = "Underlined"
}

struct VerificationField: View {
    var type: CodeType
    var style: TextFieldStyle = .roundedBorder
    @Binding var value: String
    /// We can use this to validate the typed code!
    var onChange: (String) async -> TypingState
    /// View Properties
    @State private var state: TypingState = .typing
    @State private var invalidTrigger: Bool = false
    @FocusState private var isActive: Bool
    @State private var attachmentAnchor: UnitPoint = .center
    @State private var showPastePopOver: Bool = false
    var body: some View {
        HStack(spacing: style == .roundedBorder ? 6 : 10) {
            ForEach(0..<type.rawValue, id: \.self) { index in
                CharacterView(index)
                    .overlay {
                        GeometryReader {
                            let frame = $0.frame(in: .named("VIEW"))
                            
                            Color.clear
                                .contentShape(.rect)
                                .simultaneousGesture(
                                    LongPressGesture(minimumDuration: 0.2)
                                        .onEnded { _ in
                                            let totalSize = frame.width * CGFloat(type.rawValue)
                                            let totalSpacing = CGFloat(type.rawValue - 1) * (style == .roundedBorder ? 6 : 10)
                                            let maxWidth = totalSize + totalSpacing
                                            
                                            let progress = frame.midX / maxWidth
                                            attachmentAnchor = .init(x: progress, y: 0)
                                            
                                            showPastePopOver = true
                                        }
                                )
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: value)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .compositingGroup()
        /// Invalid Phase Animator
        .phaseAnimator([0, 10, -10, 10, -5, 5, 0], trigger: invalidTrigger, content: { content, offset in
            content
                .offset(x: offset)
        }, animation: { _ in
                .linear(duration: 0.06)
        })
        .background {
            TextField("", text: $value)
                .focused($isActive)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .mask(alignment: .trailing) {
                    Rectangle()
                        .frame(width: 1, height: 1)
                        .opacity(0.01)
                }
                .allowsHitTesting(false)
        }
        .contentShape(.rect)
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    isActive = true
                }
        )
        .popover(isPresented: $showPastePopOver, attachmentAnchor: .point(attachmentAnchor), arrowEdge: .bottom) {
            HStack(spacing: 10) {
                PasteButton(payloadType: String.self) { texts in
                    if let firstText = texts.first {
                        let characterSet = CharacterSet.decimalDigits
                        if firstText.rangeOfCharacter(from: characterSet.inverted) == nil && firstText.count == type.rawValue {
                            value = firstText
                        }
                    }
                    
                    showPastePopOver = false
                }
                .labelStyle(.titleOnly)
                .tint(Color.primary)
            }
            .padding(5)
            .presentationBackground(.ultraThinMaterial)
            .presentationCompactAdaptation(.popover)
        }
        .onChange(of: value) { oldValue, newValue in
            /// Limiting Text Length
            value = String(newValue.prefix(type.rawValue))
            Task { @MainActor in
                /// For Validation Check
                state = await onChange(value)
                if state == .invalid {
                    invalidTrigger.toggle()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    isActive = false
                }
                .tint(Color.primary)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .coordinateSpace(.named("VIEW"))
    }
    
    /// Individual Character View
    @ViewBuilder
    func CharacterView(_ index: Int) -> some View {
        Group {
            if style == .roundedBorder {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor(index), lineWidth: 1.2)
            } else {
                Rectangle()
                    .fill(borderColor(index))
                    .frame(height: 1)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .frame(width: style == .roundedBorder ? 50 : 40, height: 50)
        .overlay {
            /// Character
            let stringValue = string(index)
            
            if stringValue != "" {
                Text(stringValue)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .transition(.blurReplace)
            }
        }
    }
    
    func string(_ index: Int) -> String {
        if value.count > index {
            let startIndex = value.startIndex
            let stringIndex = value.index(startIndex, offsetBy: index)
            
            return String(value[stringIndex])
        }
        
        return ""
    }
    
    func borderColor(_ index: Int) -> Color {
        switch state {
        /// Let's Highlight active field when the keyboard is active
        case .typing: value.count == index && isActive ? Color.primary : .gray
        case .valid: .green
        case .invalid: .red
        }
    }
}
// MARK: - Preview
#Preview("VerificationField") {
    @Previewable @State var code: String = ""
    @Previewable @State var type: CodeType = .six
    @Previewable @State var style: TextFieldStyle = .roundedBorder
    
    VerificationField(type: type, style: style, value: $code) { result in
        if result.count < type.rawValue {
            return .typing
        } else if result == (type == .four ? "1235" : "451245") {
            return .valid
        } else {
            return .invalid
        }
    }
    .onChange(of: type) { oldValue, newValue in
        code = ""
    }
    
    
}
