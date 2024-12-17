//
//  Taks+Extension.swift
//  MyApp
//
//  Created by Cong Le on 12/16/24.
//
// Source: https://github.com/cp-divyesh-v/SafeLock/blob/main/SafeLock/Utils/Taks%2BExtension.swift

import Foundation
extension Task where Success == Never, Failure == Never {
    /// Suspends the current task for at least the given number of seconds.
    ///
    /// This method provides an asynchronous way to pause the execution of the current task
    /// for a specified duration measured in seconds. It internally utilizes
    /// `Task.sleep(nanoseconds:)` to perform the suspension. If the task is canceled before
    /// or during the sleep, this function catches and ignores the `CancellationError`,
    /// allowing the task to proceed without interruption.
    ///
    /// - Parameter seconds: The number of seconds to suspend execution.
    ///   Must be a non-negative value. If a negative value is provided, the method
    ///   returns immediately without suspending.
    ///
    /// - Important: This method ignores any errors thrown by `Task.sleep(nanoseconds:)`,
    /// including cancellations. If you need to handle cancellations or other errors,
    /// consider using `try await Task.sleep(nanoseconds:)` directly and handle the errors
    /// appropriately in your code.
    ///
    /// - Note: The actual suspension time might be slightly longer due to system scheduling
    /// and other factors. This method guarantees to suspend for at least the specified duration.
    ///
    /// - SeeAlso:
    ///   - `Task.sleep(nanoseconds:)`
    ///   - [Swift Concurrency documentation](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
    static func sleep(seconds: TimeInterval) async {
        guard seconds > 0 else { return }
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
