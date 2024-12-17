//
//  PasscodeView.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
// Source: https://github.com/cp-divyesh-v/SafeLock/

import SwiftUI

struct LockScreenView: View {
    
    @State var viewModel: LockScreenViewModel
    
    var body: some View {
        VStack(spacing: 48){
            VStack(spacing: 24){
                Text("Enter Passcode")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                
                Text("Please enter your \(viewModel.passcodeLength)-digit pin to securely access your account.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            } .padding(.top)
            
            PasscodeIndicatorView(
                passcode: $viewModel.passcode,
                passcodeLength: viewModel.passcodeLength
            )
            
            Spacer()
            
            if !viewModel.hideNumberPad {
                NumberPadView(
                    onAdd: viewModel.onAddValue,
                    onRemoveLast: viewModel.onRemoveValue,
                    onDissmis: viewModel.onDissmis
                )
            } else {
                HStack(spacing: 20) {
                    if !viewModel.authenticator.isBiometricLocked {
                        if viewModel.authenticator.biometryType == .faceID {
                            Button(action: {
                                viewModel.authenticator.unlockWithFaceId()
                            }, label: {
                                Image(systemName: "faceid")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40)
                            })
                        }
                        
                        
                        if viewModel.authenticator.biometryType == .touchID {
                            Button(action: {
                                viewModel.authenticator.unlockWithFaceId()
                            }, label: {
                                Image(systemName: "touchid")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40)
                            })
                        }
                    }
                    
                    Button {
                        viewModel.showNumPad()
                    } label:{
                        Image(systemName: "keyboard")
                            .font(.title)
                            .padding(.vertical,16)
                            .contentShape(.rect)
                    }
                }
            }
        }
        .onChange(of: viewModel.passcode, { (_, _) in
            viewModel.verifyPasscode()
        })
        .onChange(of: viewModel.authenticator.isBiometricLocked) { oldValue, newValue in
            if newValue {
                viewModel.showNumPad()
            }
        }
    }
}

//MARK: - Preview
#Preview {
    LockScreenView(
        viewModel: LockScreenViewModel(
            authenticator: Authenticator()
        )
    )
}
