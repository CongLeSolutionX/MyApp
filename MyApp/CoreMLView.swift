//
//  CoreMLView.swift
//  MyApp
//
//  Created by Cong Le on 3/24/25.
//

import CoreML
import Vision
import NaturalLanguage
import Combine
import UIKit // For UIImage

// MARK: - Error Handling

enum CoreMLError: Error {
    case modelLoadingError(String)
    case predictionError(String)
    case imageConversionError(String)
    case modelUpdateError(String)
    case featureProviderError(String)
    case batchProviderError(String)
}

// MARK: - Model Configuration and Loading

/// Loads a compiled Core ML model asynchronously.
///
/// - Parameters:
///   - modelName: The name of the model file (without the .mlmodelc extension).
///   - configuration: The configuration for the MLModel.
/// - Returns: An MLModel instance.
/// - Throws: A CoreMLError if the model fails to load.
func loadModel(modelName: String, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> MLModel {
    guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc") else {
        throw CoreMLError.modelLoadingError("Could not find model URL for \(modelName).mlmodelc")
    }

    do {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return model
    } catch {
        throw CoreMLError.modelLoadingError("Error loading model: \(error)")
    }
}

// MARK: - Feature Providers

// A simple feature provider for image classification.  Assumes input is named "image".
class ImageFeatureProvider: MLFeatureProvider {
    var featureNames: Set<String> {
        return ["image"] // Replace "image" with your model's input name if different.
    }

    let image: CVPixelBuffer

    init(image: CVPixelBuffer) {
        self.image = image
    }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "image" {
            return MLFeatureValue(pixelBuffer: image)
        }
        return nil
    }
}

// A feature provider for text input (e.g., for sentiment analysis).  Assumes input is "text".
class TextFeatureProvider: MLFeatureProvider {
    var featureNames: Set<String> {
        return ["text"]  // Replace 'text' if your input name is different.
    }
    
    let text: String
    
    init(text: String) {
        self.text = text
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "text" {
            return MLFeatureValue(string: text)
        }
        return nil
    }
}

// MARK: - Batch Provider

// Example batch provider for images.  In a real app, you'd likely generate this dynamically.
class ImageBatchProvider: MLBatchProvider {
    let featureProviders: [MLFeatureProvider]

    init(featureProviders: [MLFeatureProvider]) {
        self.featureProviders = featureProviders
    }
    
    var count: Int {
        return featureProviders.count
    }

    func features(at index: Int) -> MLFeatureProvider {
        return featureProviders[index]
    }
}

// MARK: - Prediction

/// Performs a prediction using the provided model and feature provider.
///
/// - Parameters:
///   - model: The loaded MLModel.
///   - featureProvider: The MLFeatureProvider supplying the input.
/// - Returns: An MLFeatureProvider representing the prediction output.
/// - Throws: A CoreMLError if the prediction fails.
func predict(model: MLModel, featureProvider: MLFeatureProvider) async throws -> MLFeatureProvider {
    do {
        let prediction = try await model.prediction(from: featureProvider)
        return prediction
    } catch {
        throw CoreMLError.predictionError("Prediction failed: \(error)")
    }
}

/// Performs batch prediction.

func batchPredict(model: MLModel, batchProvider: MLBatchProvider) async throws -> MLBatchProvider {
    do {
        let predictions = try await model.predictions(from: batchProvider)
        return predictions
    } catch {
        throw CoreMLError.predictionError("Batch prediction failed: \(error)")
    }
}


// MARK: - Image Processing Helpers (using Vision)

/// Converts a UIImage to a CVPixelBuffer.
///
/// - Parameter image: The UIImage to convert.
/// - Returns: A CVPixelBuffer, or nil if the conversion fails.
func convertUIImageToCVPixelBuffer(image: UIImage) -> CVPixelBuffer? {
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                 kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
    var pixelBuffer : CVPixelBuffer?
    let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                     Int(image.size.width),
                                     Int(image.size.height),
                                     kCVPixelFormatType_32ARGB,
                                     attrs,
                                     &pixelBuffer)

    guard let unwrappedPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
        return nil
    }

    CVPixelBufferLockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    let pixelData = CVPixelBufferGetBaseAddress(unwrappedPixelBuffer)

    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(data: pixelData,
                                    width: Int(image.size.width),
                                    height: Int(image.size.height),
                                    bitsPerComponent: 8,
                                    bytesPerRow: CVPixelBufferGetBytesPerRow(unwrappedPixelBuffer),
                                    space: rgbColorSpace,
                                    bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
        return nil
    }

    context.translateBy(x: 0, y: image.size.height)
    context.scaleBy(x: 1.0, y: -1.0)

    UIGraphicsPushContext(context)
    image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
    UIGraphicsPopContext()
    CVPixelBufferUnlockBaseAddress(unwrappedPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

    return unwrappedPixelBuffer
}


// MARK: - Model Parameter Updates (Illustrative)

///  Illustrates how to *get* a model parameter.  *Setting* parameters typically requires
///  model update tasks, which are beyond the scope of this single-file example.
func getModelParameter(model: MLModel, parameterKey: MLParameterKey) throws -> Any? {
    do {
        let value = try model.parameterValue(for: parameterKey)
        return value
    } catch {
        throw CoreMLError.modelUpdateError("Failed to get parameter: \(error)")
    }
}

// MARK: - Putting it all together (Example Usages)

func runCoreMLExamples() async {
    
    // MARK: Image Classification Example
      do {
          // 1. Configuration: Use Neural Engine.
          let config = MLModelConfiguration()
          config.computeUnits = .all // Or .cpuAndNeuralEngine for iOS 14+

          // 2. Load the model.
          let imageModel = try await loadModel(modelName: "YourImageClassifier", configuration: config) // Replace with your compiled model name.

          // 3. Prepare the input (example - using a UIImage).
          guard let image = UIImage(named: "example_image.jpg"), // Replace with a real image!
                let pixelBuffer = convertUIImageToCVPixelBuffer(image: image) else {
              print("Error: Could not load or convert image.")
              return
          }
          let imageFeatureProvider = ImageFeatureProvider(image: pixelBuffer)

          // 4. Make a prediction.
          let imagePrediction = try await predict(model: imageModel, featureProvider: imageFeatureProvider)

          // 5. Process the prediction (example: get the top classification label).
          //    The output feature names depend on your model.  Inspect your model in Xcode.
          if let label = imagePrediction.featureValue(for: "classLabel")?.stringValue { // Replace "classLabel" if needed
              print("Image Classification Result: \(label)")
                // Access probabilities if your model provides them (e.g., "classLabelProbs")
              if let probabilities = imagePrediction.featureValue(for: "classLabelProbs")?.dictionaryValue {
                    for (className, probability) in probabilities {
                        if let probValue = probability as? Double {
                            print("\(className): \(probValue)")
                        }
                    }
                }
          } else {
              print("Could not get classification label.")
          }
          
          // Example of using parameterValue(for:)
          //  You need the correct MLParameterKey.  This varies BY MODEL.
          if let parameterValue = try? getModelParameter(model: imageModel, parameterKey: MLParameterKey.weights.scoped(to: "classifier")) {
              print("Example model parameter: \(parameterValue)")  // This will likely be an MLMultiArray.
          }


      } catch {
          print("Image classification error: \(error)")
      }
    
    
    // MARK: - Text Classification (Sentiment Analysis) Example
    do {
        // 1. Load the model (assuming you have a compiled sentiment analysis model)
        let textModel = try await loadModel(modelName: "YourSentimentClassifier") // Replace with your compiled model
        
        // 2. Prepare Input
        let inputText = "This is a fantastic product! I highly recommend it."
        let textFeatureProvider = TextFeatureProvider(text: inputText)
        
        // 3. Prediction
        let textPrediction = try await predict(model: textModel, featureProvider: textFeatureProvider)
        
        // 4. Result
        if let sentiment = textPrediction.featureValue(for: "label")?.stringValue { // Replace "label" if needed.
             print("Sentiment Analysis Result: \(sentiment)")  // e.g., "Positive", "Negative", "Neutral"
         }
    } catch {
        print("Text classification error: \(error)")
    }
    
    
    
    // MARK: - Batch Prediction Example (Illustrative)
    do {
        // Assume you have multiple UIImages to process:
        let images: [UIImage] = [ /* ... your images ... */ ]
        
        // Create feature providers for each image.
        var imageFeatureProviders: [MLFeatureProvider] = []
        for image in images {
            if let pixelBuffer = convertUIImageToCVPixelBuffer(image: image) {
                imageFeatureProviders.append(ImageFeatureProvider(image: pixelBuffer))
            }
        }

        // Create the batch provider.
        let batchProvider = ImageBatchProvider(featureProviders: imageFeatureProviders)

        // Load your image classification model (assuming it's named and compiled).
        let imageModel = try await loadModel(modelName: "YourImageClassifier")

        // Perform batch prediction.
        let batchPredictions = try await batchPredict(model: imageModel, batchProvider: batchProvider)

        // Process the batch results. The `batchPredictions` object is an MLBatchProvider.
        for i in 0..<batchPredictions.count {
            let prediction = batchPredictions.features(at: i)
           if let label = prediction.featureValue(for: "classLabel")?.stringValue {
                print("Image \(i+1) Classification: \(label)")
            }
        }

    } catch {
        print("Batch prediction error: \(error)")
    }
}

// MARK: - Call the Example Function (from an async context)
// In a real iOS app, you would call this from a button tap, view load, etc.,
//  within an async context (e.g., a Task).  This is just a simple example.
//
//Task {
//  await runCoreMLExamples()
//}
