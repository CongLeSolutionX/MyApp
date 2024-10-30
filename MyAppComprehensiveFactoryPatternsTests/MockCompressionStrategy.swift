//
//  MockCompressionStrategy.swift
//  MyApp
//
//  Created by Cong Le on 10/29/24.
//

import UIKit
@testable import MyApp // Replace with your module name


/// Mock Compression Strategy for Testing
class MockCompressionStrategy: ImageCompressionStrategy {
    var shouldReturnData: Bool = true
    var compressedData: Data?
    
    func compress(image: UIImage) -> Data? {
        return shouldReturnData ? compressedData : nil
    }
}

/// Mock Data Validator for Testing
class MockDataValidator: DataValidator {
    var shouldValidate: Bool = true
    
    func validate(data: String) -> Bool {
        return shouldValidate
    }
}
