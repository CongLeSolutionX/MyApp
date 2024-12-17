//
//  NumberPad.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
// Source: https://github.com/cp-divyesh-v/SafeLock/


import SwiftUI

struct NumberPadView: View {
    let onAdd: (_ value: Int) -> Void
    let onRemoveLast: () -> Void
    let onDissmis: () -> Void
    
    private let columns: [GridItem] = Array(repeating: .init(), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns){
            ForEach(1 ... 9, id: \.self){ index in
                Button {
                    onAdd(index)
                } label:{
                    Text("\(index)")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical,16)
                        .contentShape(.rect)
                }
            }
            Button {
                onRemoveLast()
            } label:{
                Image(systemName: "delete.backward")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical,16)
                    .contentShape(.rect)
            }
            Button {
                onAdd(0)
            } label:{
                Text("0")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical,16)
                    .contentShape(.rect)
            }
            Button {
                onDissmis()
            } label:{
                Image(systemName: "keyboard.chevron.compact.down")
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical,16)
                    .contentShape(.rect)
            }
        }
        .foregroundStyle(.primary)
    }
}

// MARK: - Preview
#Preview("Number Pad View") {
    NumberPadView(onAdd: { _ in }, onRemoveLast: { }, onDissmis: { })
}
