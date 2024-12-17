//
//  SafeLockDemoView.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
// Source: https://github.com/cp-divyesh-v/SafeLock/

import SwiftUI

struct SafeLockDemoView: View {
    
    @State var authenticator: Authenticator

    @State var isSuccessDialogHidden: Bool = false

    var body: some View {
        VStack {
            if authenticator.isAuthenticated {
                VStack(spacing: 20) {
                    Text("Login Success")
                        .font(.title)
                        .foregroundStyle(Color.green)
                        .opacity(isSuccessDialogHidden ? 0 : 1)
                        .onAppear {
                            Task {
                                do {
                                    try await Task.sleep(nanoseconds: 2_000_000_000) // Sleep for 2 seconds
                                    isSuccessDialogHidden = true
                                } catch {
                                    // handle the error if needed
                                    print("Failed to sleep: \(error)")
                                }
                            }
                        }

                    Text("Hey DK Good to see you!")

                    Button("Log Out") {
                        authenticator.logOut()
                    }

                    Button("Reset") {
                        authenticator.onResetPin()
                    }
                }
            }
            else{
                LockScreenView(viewModel: LockScreenViewModel(authenticator: authenticator))
            }
        }
        .padding()
    }
}
// MARK: - Preview
#Preview {
    SafeLockDemoView(authenticator: .init())
    // or
    // SafeLockDemoView(authenticator: Authenticator())
}
