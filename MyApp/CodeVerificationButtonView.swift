//
//  CodeVerificationButtonView.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI

struct CodeVerificationButtonView: View {
    @State private var code: String = ""
    @State private var type: CodeType = .six
    @State private var style: TextFieldStyle = .roundedBorder
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Code Length")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                        
                        Picker("", selection: $type) {
                            ForEach(CodeType.allCases, id: \.rawValue) {
                                Text($0.stringValue)
                                    .tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(15)
                    .background(.background, in: .rect(cornerRadius: 10))
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Style")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                        
                        Picker("", selection: $style) {
                            ForEach(TextFieldStyle.allCases, id: \.rawValue) {
                                Text($0.rawValue)
                                    .tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(15)
                    .background(.background, in: .rect(cornerRadius: 10))
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Usage")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                        
                        Text(
                        """
                        VerificationCodeField {
                           /// Validation
                        }
                        """
                        )
                        .foregroundStyle(.primary.opacity(0.8))
                        .monospaced()
                        .kerning(1.1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(15)
                        .background(.background, in: .rect(cornerRadius: 10))
                    }
                    
                    VerificationField(type: type, style: style, value: $code) { result in
                        if result.count < type.rawValue {
                            return .typing
                        } else if result == (type == .four ? "1235" : "451245") {
                            return .valid
                        } else {
                            return .invalid
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
                .padding(15)
            }
            .navigationTitle("Verification Field")
            .navigationBarTitleDisplayMode(.inline)
            .background(.primary.opacity(0.06))
            .onChange(of: type) { oldValue, newValue in
                code = ""
            }
        }
    }
}

// MARK: - Preview
#Preview {
    CodeVerificationButtonView()
}
