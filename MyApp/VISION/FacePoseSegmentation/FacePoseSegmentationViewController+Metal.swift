//
//  FacePoseSegmentationViewController+Metal.swift
//  MyApp
//
//  Created by Cong Le on 12/7/24.
//
import MetalKit

extension FacePoseSegmentationViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Delegate method not implemented.
    }
    
    func draw(in view: MTKView) {
        // grab command buffer so we can encode instructions to GPU
        guard let commandBuffer = metalCommandQueue.makeCommandBuffer() else {
            print("Failed to grab the metal command buffer")
            return
        }
        
        // grab image
        guard let ciImage = currentCIImage else {
            print("Failed to grab curreent CI image")
            return
        }
        
        // ensure drawable is free and not tied in the previous drawing cycle
        guard let currentDrawable = view.currentDrawable else {
            print("Failed to grab current drawable from MTKView")
            return
        }
        
        // make sure the image is fullscreen
        /// 1. Approach by Xcode
        //let scaleFactor = min(view.bounds.width / ciImage.extent.width, view.bounds.height / ciImage.extent.height)
        //let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        
        /// 2. Approach by tutorial
        let drawSize = cameraView.drawableSize
        let scaleX = drawSize.width / ciImage.extent.width
        let scaleY = drawSize.height / ciImage.extent.height
        
        //let newImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        let newImage = ciImage.transformed(by: .init(scaleX: scaleX, y: scaleY))
        
        
        // render into the metal texture
        self.ciContext.render(
            newImage,
            to: currentDrawable.texture,
            commandBuffer: commandBuffer,
            bounds: newImage.extent,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )
        
        // register drawable to command buffer
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
}
