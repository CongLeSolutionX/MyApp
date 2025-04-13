//
//  TransactionView.swift
//  MyApp
//
//  Created by Cong Le on 4/12/25.
//

import SwiftUI

// MARK: - Custom Transaction Key (iOS 17+)
#if swift(>=5.9) // Check for Swift version supporting TransactionKey properly
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
private struct LogChangeKey: TransactionKey {
    static var defaultValue: Bool = false // Default: don't log
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension Transaction {
    // Convenience accessor for the custom key
    var logChange: Bool {
        get { self[LogChangeKey.self] }
        set { self[LogChangeKey.self] = newValue }
    }
}
#endif // swift(>=5.9)

// MARK: - Main View
struct TransactionExampleView: View {
    @State private var isAnimating: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {

                // --- Section Title ---
                Text("SwiftUI Transactions")
                    .font(.largeTitle)
                    .padding(.bottom)

                // --- Example 1: withAnimation ---
                VStack(alignment: .leading) {
                    Text("1. `withAnimation` Global Function")
                        .font(.headline)
                    Text("Wraps state change. Creates a transaction with the specified animation.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.blue)
                        .frame(width: isAnimating ? 200 : 100, height: 50)
                        .overlay(Text("Bounces").foregroundStyle(.white))
                    Button("Trigger `withAnimation`") {
                        // Creates a transaction containing a bouncy spring animation
                        withAnimation(.bouncy(duration: 0.8)) {
                            isAnimating.toggle()
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                // --- Example 2: .animation modifier ---
                VStack(alignment: .leading) {
                    Text("2. `.animation(_:value:)` Modifier")
                        .font(.headline)
                    Text("Attaches animation triggered *by* a specific value change. Implicitly uses a transaction.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.green)
                        .frame(width: 100, height: 50)
                        .overlay(Text("Slides").foregroundStyle(.white))
                        .offset(x: isAnimating ? 100 : -100)
                        // The animation (and transaction) is defined here, tied to 'isAnimating'
                        .animation(.easeInOut(duration: 1.0), value: isAnimating)
                     Button("Trigger `.animation`") {
                         // No need for withAnimation هنا - the modifier handles it
                         isAnimating.toggle()
                     }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                // --- Example 3: withTransaction ---
                VStack(alignment: .leading) {
                    Text("3. `withTransaction` Global Function")
                        .font(.headline)
                    Text("Explicitly create and use a transaction for state changes.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.orange)
                        .frame(width: 100, height: 50)
                        .overlay(Text("Rotates Smoothly").foregroundStyle(.white).font(.caption))
                        .rotationEffect(.degrees(isAnimating ? 180 : 0))
                     Button("Trigger `withTransaction`") {
                         // Manually create a transaction with a specific animation
                         let customTransaction = Transaction(animation: .smooth(duration: 1.5))
                         // Can also set other properties like:
                         // customTransaction.disablesAnimations = false
                         // customTransaction.isContinuous = false // etc.

                         withTransaction(customTransaction) {
                             isAnimating.toggle()
                         }
                     }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                // --- Example 4: .transaction modifier ---
                VStack(alignment: .leading) {
                    Text("4. `.transaction` Modifier")
                        .font(.headline)
                    Text("Inspects and modifies the transaction flowing through the view. Reacts to *other* triggers.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.purple)
                        .frame(width: 100, height: 50)
                        .overlay(Text("Delayed Fade").foregroundStyle(.white))
                    .opacity(isAnimating ? 0.2 : 1.0)
                        // Intercept the transaction caused by ANY trigger affecting `isAnimating`
                        .transaction { transactionInOut in
                            // Check if there *is* an animation specified further up
                            if let existingAnimation = transactionInOut.animation {
                                // Modify it - add delay ONLY via this modifier
                                transactionInOut.animation = existingAnimation.delay(0.5)
                                print("Transaction modifier added delay")
                            } else {
                                print("Transaction modifier found no animation to modify")
                            }
                            // You could also completely replace it:
                            // transactionInOut.animation = .interactiveSpring()
                            // Or disable it:
                            // transactionInOut.disablesAnimations = true
                        }
                     Text("(Try triggering with other buttons)")
                       .font(.footnote).foregroundStyle(.secondary)

                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // --- Example 5: Custom Transaction Key (iOS 17+) ---
                #if swift(>=5.9)
                if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
                    Divider()
                    VStack(alignment: .leading) {
                        Text("5. Custom `TransactionKey` (iOS 17+)")
                            .font(.headline)
                        Text("Pass custom data via the transaction.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.red)
                            .frame(width: 100, height: 50)
                            .overlay(Text("Logs Change").foregroundStyle(.white))
                            .hueRotation(.degrees(isAnimating ? 90 : 0))
                             // Use the transaction modifier to *read* the custom key
                            .transaction { transactionInOut in
                                if transactionInOut.logChange {
                                    // Only prints when triggered by the specific button below
                                    print("--> Custom Transaction: Logging this change!")
                                }
                            }
                         Button("Trigger with Custom Key") {
                             // Option 1: Use withTransaction(keyPath:value:body)
                             withTransaction(\.logChange, true) {
                                 // Can combine with withAnimation
                                 withAnimation(.spring) {
                                    isAnimating.toggle()
                                 }
                             }

                             // Option 2: Create transaction manually
                             /*
                             var loggingTransaction = Transaction(animation: .spring)
                             loggingTransaction.logChange = true
                             withTransaction(loggingTransaction) {
                                 isAnimating.toggle()
                             }
                              */
                         }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                #endif // swift(>=5.9)

            }
            .padding()
        }
    }
}

// MARK: - Preview
struct TransactionExampleView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionExampleView()
    }
}
