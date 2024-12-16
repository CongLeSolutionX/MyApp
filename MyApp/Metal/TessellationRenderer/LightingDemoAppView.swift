//
//  LightingDemoAppView.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
// Source: https://github.com/dehesa/sample-metal


import SwiftUI
import Metal

struct LightingDemoAppView: View {
    
    @State private var tessellationType: TessellationType = .triangle
    @State private var isWireframe: Bool = true
    @State private var edgeFactor: Float = 2
    @State private var insideFactor: Float = 2
    
    var body: some View {
        HStack(alignment: .top) {
            TessellationMetalView(patchType: self.tessellationType.metalType, edgeFactor: self.edgeFactor, insideFactor: self.insideFactor, isWireframe: self.isWireframe)
                .frame(minWidth: 200, minHeight: 200)
            
            VStack(alignment: .leading, spacing: 16) {
                Picker("Tesselation Type", selection: self.$tessellationType) {
                    ForEach(TessellationType.allCases) {
                        Text($0.description)
                    }
                }.pickerStyle(.segmented)
                    .labelsHidden()
                
                Toggle("Wireframe", isOn: self.$isWireframe)
                    #if os(macOS)
                    .toggleStyle(.checkbox)
                    #endif
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Edge  \(self.edgeFactor.formatted(.number.factor))")
                    Slider(value: self.$edgeFactor, in: 2...Float(TessellationMetalView.maxTessellationFactor))
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Inside  \(self.insideFactor.formatted(.number.factor))")
                    Slider(value: self.$insideFactor, in: 2...Float(TessellationMetalView.maxTessellationFactor))
                        .labelsHidden()
                }
            }.padding()
                .frame(width: 250)
        }
    }
}

// MARK: - TessellationType
enum TessellationType: Identifiable, CustomStringConvertible, CaseIterable {
    case triangle
    case quad
    
    var id: Self {
        self
    }
    
    var description: String {
        switch self {
        case .triangle: "Triangle"
        case .quad: "Quad"
        }
    }
    
    var metalType: MTLPatchType {
        switch self {
        case .triangle: .triangle
        case .quad: .quad
        }
    }
}

// MARK: - FloatingPointFormatStyle
extension FloatingPointFormatStyle<Float> {
    var factor: Self {
        .number.precision(.fractionLength(0...1)).locale(Locale(identifier: "en_US"))
    }
}
