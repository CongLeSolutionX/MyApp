//
//  ImageRemoverModel.swift
//  MyApp
//
//  Created by Cong Le on 1/19/25.
//


import SwiftUI
import PhotosUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

class ImageRemoverModel: ObservableObject{
    // MARK: Image Picker Properties
    @Published var showPicker: Bool = false
    @Published var pickedItem: PhotosPickerItem?{
        didSet{
            // MARK: Extracting Image
            extractImage()
        }
    }
    @Published var fetchedImage: UIImage?
    
    func extractImage(){
        if let pickedItem{
            Task{
                guard let imageData = try? await pickedItem.loadTransferable(type: Data.self) else{return}
                let image = UIImage(data: imageData)
                await MainActor.run(body: {
                    self.fetchedImage = image
                })
            }
        }
    }
    
    // MARK: Removing background using Person Segmentation(Vision)
    func removeBackground(){
        guard let image = fetchedImage?.cgImage else{return}
        // MARK: Request
        let request = VNGeneratePersonSegmentationRequest()
        // MARK: Set this to True only for Testing in Simulator
        // request.usesCPUOnly = true
        
        // MARK: Task Handler
        let task = VNImageRequestHandler(cgImage: image)
        do{
            try task.perform([request])
            
            // MARK: Result
            if let result = request.results?.first{
                let buffer = result.pixelBuffer
                maskWithOriginalImage(buffer: buffer)
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    // MARK: It will Give the Mask/Outline of the Person present in the Image
    // We Need to Mask it With The Original Image, In Order to Remove the Background
    func maskWithOriginalImage(buffer: CVPixelBuffer){
        guard let cgImage = fetchedImage?.cgImage else{return}
        let original = CIImage(cgImage: cgImage)
        let mask = CIImage(cvImageBuffer: buffer)
        
        // MARK: Scaling Properties of the Mask in order to fit perfectly
        let maskX = original.extent.width / mask.extent.width
        let maskY = original.extent.height / mask.extent.height
        
        let resizedMask = mask.transformed(by: CGAffineTransform(scaleX: maskX, y: maskY))
        
        // MARK: Filter Using Core Image
        let filter = CIFilter.blendWithMask()
        filter.inputImage = original
        filter.maskImage = resizedMask
        
        if let maskedImage = filter.outputImage{
            // MARK: Creating UIImage
            let context = CIContext()
            guard let image = context.createCGImage(maskedImage, from: maskedImage.extent) else{return}
            
            // This is Detected Person Image
            self.fetchedImage = UIImage(cgImage: image)
        }
    }
}

extension UIApplication{
    func screenSize()->CGSize{
        guard let window = connectedScenes.first as? UIWindowScene else{return .zero}
        return window.screen.bounds.size
    }
}
