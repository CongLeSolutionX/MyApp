//
//  SlideToConfirmDemoView.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI

struct SlideToConfirmDemoView: View {
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Usage:")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                    
                    Text(
                    """
                    **SlideToConfirm(config) {**
                      // Swiped
                    **}**
                    """
                    )
                    .monospaced()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(15)
                    .background(.gray.opacity(0.15), in: .rect(cornerRadius: 10))
                }
                
                Spacer()
                
                let config = SlideToConfirmView.Config(
                    idleText: "Swipe to Pay",
                    onSwipeText: "Confirms Payment",
                    confirmationText: "Success!",
                    tint: .green,
                    foregorundColor: .white
                )
                
                SlideToConfirmView(config: config) {
                    print("Swiped!")
                }
            }
            .padding(15)
            .navigationTitle("Slide to Confirm")
        }
    }
}

// MARK: - Preview
#Preview {
    SlideToConfirmDemoView()
}
