//
//  MetalViewController.swift
//  MyApp
//
//  Created by Cong Le on 11/23/24.
//

/*
Source: https://developer.apple.com/documentation/metalperformanceshadersgraph/adding_custom_functions_to_a_shader_graphs
Abstract:
A minimal view controller to execute the tensor function on launch.
*/

import UIKit
import Foundation
import Metal
import MetalPerformanceShaders
import MetalPerformanceShadersGraph

class MetalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Hello from MetalViewController")

        // Custom neuron graph.
        // Create an MPSGraph object.
        let graph = CustomMPSGraph()

        // Create placeholder showcasing input to the graph.
        let inputTensor = graph.placeholder(shape: nil,
                                            dataType: .float32,
                                            name: nil)

        // Call the function to write out a custom neuron graph.
        let geLU = graph.geLU(tensor: inputTensor)

        let device = MTLCreateSystemDefaultDevice()!
        let inputData = MPSNDArray(device: device, scalar: 2.0)

        // Provide input data.
        let inputs = MPSGraphTensorData(inputData)

        // Execute the graph.
        let results = graph.run(feeds: [inputTensor: inputs],
                                targetTensors: [geLU],
                                targetOperations: nil)

        let result = results[geLU]

        let outputNDArray = result?.mpsndarray()

        var outputValues: [Float32] = [-22.0]

        print(outputValues)
        outputNDArray?.readBytes(&outputValues, strideBytes: nil)
        print(outputValues)
    }
}

