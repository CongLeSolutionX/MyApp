//
//  SwiftUIFoundationsCoreImprovements.swift
//  MyApp
//
//  Created by Cong Le on 4/1/25.
//
import SwiftUI

// --- Color Mixing ---

struct ColorMixingExample: View {
    var body: some View {
        VStack {
            Text("Mixing Red and Purple")
                .font(.headline)
            HStack {
                Color.red
                Color.red.mix(with: .purple, by: 0.2)
                Color.red.mix(with: .purple, by: 0.5) // Equal mix
                Color.red.mix(with: .purple, by: 0.8)
                Color.purple
            }
            .frame(height: 100)
        }
        .padding()
    }
}

#Preview("Color Mixing") {
    ColorMixingExample()
}

// --- Shader Precompilation ---

// Placeholder - Assume ShaderLibrary.myCoolEffect() returns a Shader
struct ShaderLibraryPlaceholder {
    static func myCoolEffect() -> Shader {
        // In reality, this would load/create a Metal shader
        return Shader(function: .init(library: .default, name: "passthrough"), arguments: [])
    }
}

struct ShaderPrecompileView: View {
    var body: some View {
        Image(systemName: "music.note")
            .font(.system(size: 100))
            .foregroundStyle(.blue)
             // Example of applying a (placeholder) shader effect
             // .layerEffect(ShaderLibraryPlaceholder.myCoolEffect(), maxSampleOffset: .zero)
            .padding()
             // Precompile the shader when the view appears
            .task {
                 do {
                     // Get the shader instance
                     let coolShader = ShaderLibraryPlaceholder.myCoolEffect()
                     print("Attempting to precompile shader...")
                     // Compile it for layer effect usage
                     try await coolShader.compile(as: .layerEffect)
                     print("Shader precompiled successfully.")
                 } catch {
                     print("Failed to precompile shader: \(error)")
                 }
             }
    }
}

#Preview("Shader Precompile (Conceptual)") {
    ShaderPrecompileView()
}
