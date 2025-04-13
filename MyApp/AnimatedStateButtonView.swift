//
//  AnimatedStateButtonView.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI

enum TransactionState: String {
    case idle = "Click to pay"
    case analyzing = "Analyzing Transaction"
    case processing = "Processing Transaction"
    case completed = "Transaction Completed"
    case failed = "Transaction Failed"
    
    var color: Color {
        switch self {
        case .idle:
            return .black
        case .analyzing:
            return .blue
        case .processing:
            return Color(red: 0.8, green: 0.35, blue: 0.2)
        case .completed:
            return .green
        case .failed:
            return .red
        }
    }

    var image: String? {
        switch self {
        case .idle: "apple.logo"
        case .analyzing: nil
        case .processing: nil
        case .completed: "checkmark.circle.fill"
        case .failed: "xmark.circle.fill"
        }
    }
}

struct AnimatedStateButtonView: View {
    @State private var transactionState: TransactionState = .idle
    var body: some View {
        NavigationStack {
            //List {
            VStack(alignment: .leading, spacing: 8) {
                Text("Usage")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Text(
                    """
                    **AnimatedButton(config, shape) {**
                       // Async...
                    **}**
                    """
                )
                .monospaced()
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background, in: .rect(cornerRadius: 10))
                
                Text("Preview")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.top, 25)
                
                let config = AnimatedButton.Config(
                    title: transactionState.rawValue,
                    foregroundColor: .white,
                    background: transactionState.color,
                    symbolImage: transactionState.image
                )
                
                AnimatedButton(config: config) {
                    transactionState = .analyzing
                    try? await Task.sleep(for: .seconds(3))
                    transactionState = .processing
                    try? await Task.sleep(for: .seconds(3))
                    transactionState = .failed
                    try? await Task.sleep(for: .seconds(1))
                    transactionState = .idle
                }
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity)
                .background(.background, in: .rect(cornerRadius: 10))
                
                Spacer(minLength: 0)
            }
            .padding(15)
            .navigationTitle("Custom Button")
            .background(.ultraThinMaterial)
        }
    }
}

// MARK: - Preview
#Preview {
    AnimatedStateButtonView()
}
