//
//  ColorDetailSheet.swift
//  MyApp
//
//  Created by Cong Le on 4/18/25.
//

// MARK: - ColorDetailSheet.swift

import SwiftUI

struct ColorDetailSheet: View {
    let colorItem: ColorItem
    @Environment(\.dismiss) var dismiss
    @State private var showCopyAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                Rectangle()
                    .fill(colorItem.color)
                    .frame(height: 150)
                    .cornerRadius(12)

                GroupBox("Color Details") {
                    VStack(spacing: 6) {
                        Text("Name: \(colorItem.name)")
                        if let hex = ColorService.hexString(from: colorItem.color) {
                            Text("HEX: \(hex)")
                            Button("Copy HEX") {
                                UIPasteboard.general.string = hex
                                showCopyAlert = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Color Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Copied to clipboard!", isPresented: $showCopyAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}
