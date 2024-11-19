//
//  Filterscreen.swift
//  MyApp
//
//  Created by Cong Le on 11/18/24.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct SepiaFilterView: View {
    var image: Image
    
    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .overlay(
                Image(uiImage: applySepiaFilter(to: image.asUIImage() ?? UIImage()))
                    .resizable()
                    .scaledToFit()
            )
    }

    func applySepiaFilter(to inputImage: UIImage) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.sepiaTone()
        filter.inputImage = CIImage(image: inputImage)
        filter.intensity = 1.0

        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return inputImage // Return original image if filter fails
        }

        return UIImage(cgImage: cgImage)
    }
}

extension Image {
    func asUIImage() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

#Preview {
   
    SepiaFilterView(image: Image(systemName: "house"))
}
