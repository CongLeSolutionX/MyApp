//
//  MyMPSGraph.swift
//  MyApp
//
//  Created by Cong Le on 11/23/24.
//

/*
Abstract:
MyMPSGraph file inherits from MPSGraph and adds a custom GeLU method.
*/

import Foundation
import MetalPerformanceShadersGraph

/// Creating the Graph with GeLU method.
class CustomMPSGraph: MPSGraph {

    // Creating a GeLU op
    func geLU(tensor: MPSGraphTensor) -> MPSGraphTensor {

        // Create constants needed.
        let ones = constant(1.0, shape: [1], dataType: .float32)
        let half = constant(0.5, shape: [1], dataType: .float32)

        // Create unary math ops.
        let sqrt = squareRoot(with: half, name: nil)

        // Create binary math ops.
        let multiply = multiplication(sqrt, tensor, name: nil)

        let multiply2 = multiplication(half, tensor, name: nil)

        let erfValue = erf(with: multiply, name: nil)

        let add = addition(erfValue, ones, name: nil)

        // Return final tensor.
        return multiplication(multiply2, add, name: nil)

    }
}
