//
//  SystemTrayContentView.swift
//  MyApp
//
//  Created by Cong Le on 4/13/25.
//


import SwiftUI

enum CurrentView {
    case actions
    case periods
    case keypad
}

struct SystemTrayContentView: View {
    /// View Properties
    @State private var show: Bool = false
    var body: some View {
        NavigationStack {
            List {
                Section("Usage") {
                    Text(
                       """
                       **.systemTrayView(show: $show) {**
                          /// ANIMATED VIEW
                       **}**
                       """
                    )
                    .monospaced()
                }
                
                Button("Show Tray Sheet") {
                    show.toggle()
                }
            }
            .navigationTitle("Tray")
        }
        .systemTrayView($show) {
            TrayView()
        }
    }
}

struct TrayView: View {
    @State private var currentView: CurrentView = .actions
    @State private var selectedAction: Action?
    @State private var selectedPeriod: Period?
    @State private var duration: String = ""
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                switch currentView {
                case .actions: View1()
                        .transition(
                            .blurReplace(.upUp)
                        )
                case .periods: View2()
                        .transition(
                            .blurReplace(.downUp)
                        )
                case .keypad: View3()
                        .transition(.blurReplace(.upUp))
                }
            }
            .compositingGroup()
            
            /// Continue Button
            Button {
                if currentView == .actions {
                    withAnimation(.bouncy) {
                        currentView = .periods
                    }
                } else {
                    print("Subscribe")
                }
            } label: {
                Text(currentView == .actions ? "Continue" : "Subscribe")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .foregroundStyle(.white)
                    .background(.blue, in: .capsule)
            }
            .disabledWithOpacity(currentView == .actions ? selectedAction == nil : false)
            .disabledWithOpacity(currentView == .periods ? selectedPeriod == nil : false)
            .disabledWithOpacity(currentView == .keypad ? duration.isEmpty : false)
            .padding(.top, 15)
        }
        .padding(20)
    }
    
    /// View 1
    @ViewBuilder
    func View1() -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Choose Subscription")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer(minLength: 0)
                
                Button {
                    /// Dismissing Sheet
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(Color.gray, Color.primary.opacity(0.1))
                }
            }
            .padding(.bottom, 10)
            
            /// Custom Checkbox Menu
            ForEach(actions) { action in
                let isSelected: Bool = selectedAction?.id == action.id
                
                HStack(spacing: 10) {
                    Image(systemName: action.image)
                        .font(.title)
                        .frame(width: 40)
                    
                    Text(action.title)
                        .fontWeight(.semibold)
                    
                    Spacer(minLength: 0)
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle.fill")
                        .font(.title)
                        .contentTransition(.symbolEffect)
                        .foregroundStyle(isSelected ? Color.blue : Color.gray.opacity(0.2))
                }
                .padding(.vertical, 6)
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation(.snappy) {
                        selectedAction = isSelected ? nil : action
                    }
                }
            }
        }
    }
    
    /// View 2
    @ViewBuilder
    func View2() -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Choose Period")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer(minLength: 0)
                
                Button {
                    withAnimation(.bouncy) {
                        currentView = .actions
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(Color.gray, Color.primary.opacity(0.1))
                }
            }
            .padding(.bottom, 25)
            
            Text("Choose the period you want\nto get subscribed.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .padding(.bottom, 20)
            
            /// Grid Box View
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 15) {
                ForEach(periods) { period in
                    let isSelected = selectedPeriod?.id == period.id
                    
                    VStack(spacing: 6) {
                        Text(period.title)
                            .font(period.value == 0 ? .title3 : .title2)
                            .fontWeight(.semibold)
                        
                        if period.value != 0 {
                            Text(period.value == 1 ? "Month" : "Months")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill((isSelected ? Color.blue : Color.gray).opacity(isSelected ? 0.2 : 0.1))
                    }
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.snappy) {
                            if period.value == 0 {
                                /// Go To Custom Keypad View (View 3)
                                currentView = .keypad
                            } else {
                                selectedPeriod = isSelected ? nil : period
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// View 3
    @ViewBuilder
    func View3() -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Custom Duration")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer(minLength: 0)
                
                Button {
                    withAnimation(.bouncy) {
                        currentView = .periods
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(Color.gray, Color.primary.opacity(0.1))
                }
            }
            .padding(.bottom, 10)
            
            VStack(spacing: 6) {
                Text(duration.isEmpty ? "0" : duration)
                    .font(.system(size: 60, weight: .black))
                    .contentTransition(.numericText())
                
                Text("Days")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .padding(.vertical, 20)
            
            /// Custom Keypad View
            LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 15) {
                ForEach(keypadValues) { keyValue in
                    if keyValue.value == 0 {
                        Spacer()
                    }
                    
                    Group {
                        if keyValue.isBack {
                            Image(systemName: keyValue.title)
                        } else {
                            Text(keyValue.title)
                        }
                    }
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.snappy) {
                            if keyValue.isBack {
                                if !duration.isEmpty {
                                    duration.removeLast()
                                }
                            } else {
                                duration.append(keyValue.title)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, -15)
        }
    }
}
// MARK: - Extension
extension View {
    func disabledWithOpacity(_ status: Bool) -> some View {
        self
            .disabled(status)
            .opacity(status ? 0.5 : 1)
    }
}

// MARK: - Preview
#Preview {
    SystemTrayContentView()
}
