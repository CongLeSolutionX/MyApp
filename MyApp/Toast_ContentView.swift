//
//  Toast_ContentView.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//

import SwiftUI

struct Toast_ContentView: View {
    @Environment(ToastsData.self) private var toastsData
    var body: some View {
        NavigationStack {
            List {
                Section("Custom") {
                    VStack(spacing: 25) {
                        HStack {
                            Button("Error") {
                                toastsData.add(.init { id in
                                    ToastView(id, tint: .red)
                                })
                            }
                            .tint(.red)
                            
                            Button("Success") {
                                toastsData.add(.init { id in
                                    ToastView(id, tint: .green)
                                })
                            }
                            .tint(.green)
                            
                            Button("Warning") {
                                toastsData.add(.init { id in
                                    ToastView(id, tint: .yellow)
                                })
                            }
                            .tint(.yellow)
                        }
                        
                        Button("Apple Like HUD") {
                            toastsData.add(.init { id in
                                HUDView(id)
                            })
                        }
                    }
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Toasts")
        }
    }
    
    /// YOUR CUSTOM TOAST VIEW
    @ViewBuilder
    func ToastView(_ id: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            let symbolImage = tint == .red ? "bolt.trianglebadge.exclamationmark" : tint == .green ? "bolt.ring.closed" : "bolt.heart"
            
            Image(systemName: symbolImage)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(tint)
            
            let title = tint == .red ? "Your Airpods Battery is low." : tint == .green ? "Airpods is fully charged." : "Optmized Airpods charging."
            
            Text(title)
                .font(.callout)
            
            Spacer(minLength: 0)
            
            Button {
                toastsData.delete(id)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
            }
        }
        .foregroundStyle(Color.primary)
        .padding([.vertical, .trailing], 12)
        .padding(.leading, 15)
        .background {
            Capsule()
                .fill(.background)
                /// Shadows
                .shadow(color: .black.opacity(0.06), radius: 3, x: -1, y: -3)
                .shadow(color: .black.opacity(0.06), radius: 2, x: 1, y: 3)
        }
        .padding(.horizontal, 25)
    }
    
    /// Apple Like HUD View
    @ViewBuilder
    func HUDView(_ id: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "airpods.pro")
            
            Text("iKieuTuiDo's Airpods")
                .font(.callout)
        }
        .foregroundStyle(Color.primary)
        .padding(.vertical, 12)
        .padding(.horizontal, 15)
        .background {
            Capsule()
                .fill(.background)
                /// Shadows
                .shadow(color: .black.opacity(0.06), radius: 3, x: -1, y: -3)
                .shadow(color: .black.opacity(0.06), radius: 2, x: 1, y: 3)
        }
    }
}


// MARK: - Preview
#Preview {
    RootView {
        Toast_ContentView()
    }
}
