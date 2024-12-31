//
//  UIImage+Util.swift
//  MyApp
//
//  Created by Cong Le on 12/30/24.
//


import AVFoundation
import Foundation
import UIKit

extension UIImage
{
    class func imageOfSymbol(_ symbol: String, _ font: UIFont) -> UIImage
    {
        let
        length = font.pointSize * 2,
        size   = CGSize(width: length, height: length),
        rect   = CGRect(origin: CGPoint.zero, size: size)
        
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()

        // Fill the background with white.
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(rect)
        
        // Draw the character with black.
        let nsString = NSString(string: symbol)
        nsString.draw(at: rect.origin, withAttributes: convertToOptionalNSAttributedStringKeyDictionary([
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): font,
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.black
            ]))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func imageConstrainedToMaxSize(_ maxSize: CGSize) -> UIImage
    {
        let isTooBig =
            size.width  > maxSize.width ||
            size.height > maxSize.height
        if isTooBig
        {
            let
            maxRect       = CGRect(origin: CGPoint.zero, size: maxSize),
            scaledRect    = AVMakeRect(aspectRatio: self.size, insideRect: maxRect),
            scaledSize    = scaledRect.size,
            targetRect    = CGRect(origin: CGPoint.zero, size: scaledSize),
            width         = Int(scaledSize.width),
            height        = Int(scaledSize.height),
            cgImage       = self.cgImage,
            bitsPerComp   = cgImage?.bitsPerComponent,
            compsPerPixel = 4, // RGBA
            bytesPerRow   = width * compsPerPixel,
            colorSpace    = cgImage?.colorSpace,
            bitmapInfo    = cgImage?.bitmapInfo,
            context       = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: bitsPerComp!,
                bytesPerRow: bytesPerRow,
                space: colorSpace!,
                bitmapInfo: (bitmapInfo?.rawValue)!)
        
            if context != nil
            {
                context!.interpolationQuality = CGInterpolationQuality.low
                context?.draw(cgImage!, in: targetRect)
                if let scaledCGImage = context?.makeImage()
                {
                    return UIImage(cgImage: scaledCGImage)
                }
            }
        }
        return self
    }
    
    func imageRotatedToPortraitOrientation() -> UIImage
    {
        let mustRotate = self.imageOrientation != .up
        if mustRotate
        {
            let rotatedSize = CGSize(width: size.height, height: size.width)
            UIGraphicsBeginImageContext(rotatedSize)
            if let context = UIGraphicsGetCurrentContext()
            {
                // Perform the rotation and scale transforms around the image's center.
                context.translateBy(x: rotatedSize.width/2, y: rotatedSize.height/2)
                
                // Rotate the image upright.
                let
                degrees = self.degreesToRotate(),
                radians = degrees * M_PI / 180.0
                context.rotate(by: CGFloat(radians))
                
                // Flip the image on the Y axis.
                context.scaleBy(x: 1.0, y: -1.0)
                
                let
                targetOrigin = CGPoint(x: -size.width/2, y: -size.height/2),
                targetRect   = CGRect(origin: targetOrigin, size: self.size)
                
                context.draw(self.cgImage!, in: targetRect)
                let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                
                return rotatedImage
            }
        }
        return self
    }
    
    fileprivate func degreesToRotate() -> Double
    {
        switch self.imageOrientation
        {
        case .right: return  90
        case .down:  return 180
        case .left:  return -90
        default:     return   0
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}


//extension UIImage {
//
//    class func imageOfSymbol(_ symbol: String, _ font: UIFont) -> UIImage {
//        let length = font.pointSize * 2
//        let size = CGSize(width: length, height: length)
//        let rect = CGRect(origin: .zero, size: size)
//
//        UIGraphicsBeginImageContextWithOptions(size, false, 0) // Use options variant
//        defer { UIGraphicsEndImageContext() } // Ensure context is ended
//
//        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
//
//        context.setFillColor(UIColor.white.cgColor)
//        context.fill(rect)
//
//        let nsString = NSString(string: symbol)
//            nsString.draw(at: .zero, withAttributes: [.font: font, .foregroundColor: UIColor.black])
//
//        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
//        return image
//    }
//
//
//
//    func imageConstrainedToMaxSize(_ maxSize: CGSize) -> UIImage {
//        let isTooBig = size.width > maxSize.width || size.height > maxSize.height
//        guard isTooBig else { return self }
//
//        let maxRect = CGRect(origin: .zero, size: maxSize)
//        let scaledRect = AVMakeRect(aspectRatio: size, insideRect: maxRect)
//        let scaledSize = scaledRect.size
//
//        let renderer = UIGraphicsImageRenderer(size: scaledSize) // Use renderer
//        let resizedImage = renderer.image { context in
//            draw(in: CGRect(origin: .zero, size: scaledSize))
//        }
//        return resizedImage
//    }
//
//
//
//    func imageRotatedToPortraitOrientation() -> UIImage {
//        guard imageOrientation != .up else { return self }
//
//        UIGraphicsBeginImageContextWithOptions(size, false, scale)
//        defer { UIGraphicsEndImageContext() }
//
//        guard let context = UIGraphicsGetCurrentContext() else { return self }
//
//        let rotatedSize = CGSize(width: size.height, height: size.width) // Fix rotated size
//
//        context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
//        let degrees = self.degreesToRotate()
//        let radians = degrees * .pi / 180
//        context.rotate(by: CGFloat(radians))
//        context.scaleBy(x: 1.0, y: -1.0)
//
//        let targetOrigin = CGPoint(x: -size.width / 2, y: -size.height / 2) // Use current size
//        let targetRect = CGRect(origin: targetOrigin, size: size)
//
//        guard let cgImage = self.cgImage else { return self }
//
//        context.draw(cgImage, in: targetRect)
//
//        guard let rotatedImage = UIGraphicsGetImageFromCurrentImageContext() else { return self } // Safe unwrap
//
//        return rotatedImage
//    }
//
//    private func degreesToRotate() -> Double { // Make private
//        switch imageOrientation {
//        case .right: return  90
//        case .down: return 180
//        case .left: return -90
//        default: return 0
//        }
//    }
//}
