//
//  NSImage+Extension.swift
//  Kollage
//
//  Created by Venkateswaran Venkatakrishnan on 1/28/23.
//  Copyright © 2023 Venky UL. All rights reserved.
//

import Foundation
import Cocoa
import Quartz


extension NSImage {
    
    
    /**
     Tint image with supplied color
     
     - parameter color: color to use as tint
     
     - returns: tinted image
     */
    func tintedImageWithColor(_ color: NSColor) -> NSImage {
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        color.drawSwatch(in: NSRect(x: 0, y: 0, width: size.width, height: size.height))
        draw(at: NSZeroPoint, from: NSZeroRect, operation: .destinationIn, fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
    
    /**
     Derives new size for an image constrained to a maximum dimension while keeping AR constant
     
     - parameter maxDimension: maximum horizontal or vertical dimension for new size
     
     - returns: new size
     */
    func aspectFitSizeForMaxDimension(_ maxDimension: CGFloat) -> NSSize {
        var width =  size.width
        var height = size.height
        if size.width > maxDimension || size.height > maxDimension {
            let aspectRatio = size.width/size.height
            width = aspectRatio > 0 ? maxDimension : maxDimension*aspectRatio
            height = aspectRatio < 0 ? maxDimension : maxDimension/aspectRatio
        }
        return NSSize(width: width, height: height)
    }
    
    
    func sizeForMaxDimension(_ maxDimension: CGFloat) -> NSSize {
        
        
        let aspectRatio = self.size.width/self.size.height
        
        let width = aspectRatio > 0 ? maxDimension: maxDimension * aspectRatio
        let height = aspectRatio < 0 ? maxDimension: maxDimension/aspectRatio
        
        return NSSize(width: width, height: height)
    }
    
    
    class func swatchWithColor(color: NSColor, size: NSSize) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        color.drawSwatch(in: NSRect(origin: .zero, size: size))
        image.unlockFocus()
        return image
    }
    
    
    func resize(toPercentage percent: Double) -> NSImage? {
        
        
        let targetSize = NSSize(width: (self.size.width * percent)/100,
                                height: (self.size.height * percent)/100)
        
        return resize(withSize: targetSize)
    }
    
    func resize(withSize targetSize: NSSize) -> NSImage? {
        let frame = NSRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        guard let representation = self.bestRepresentation(for: frame, context: nil, hints: nil) else {
            return nil
        }
        let image = NSImage(size: targetSize, flipped: false, drawingHandler: { (_) -> Bool in
            return representation.draw(in: frame)
        })
        
        return image
    }
    
    func addTextToImage(drawText text: String) -> NSImage {
        
        let targetImage = NSImage(size: self.size, flipped: false) { (dstRect: CGRect) -> Bool in
            
            self.draw(in: dstRect)
            let textColor = NSColor.black
            let textFont = NSFont(name: "Snell Roundhand", size: 64)! //Helvetica Bold
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.center
            
            let textFontAttributes = [
                NSAttributedString.Key.font: textFont,
                NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
            
            let textOrigin = CGPoint(x: self.size.height/3, y: -self.size.width/4)
            let rect = CGRect(origin: textOrigin, size: self.size)
            text.draw(in: rect, withAttributes: textFontAttributes)
            return true
        }
        return targetImage
    }
    
    
    func addImage(image: NSImage) -> NSImage {
        
        
        let newImage = NSImage(size: self.size)
        
        let background = self
        let overlay = image
        
        newImage.lockFocus()
        
        var imageRect: CGRect = .zero
        imageRect.size = newImage.size
        
        
        var newImageRect: CGRect = .zero
        newImageRect.size = newImage.size
        
        background.draw(in: imageRect)
        
        var newSmallRect: CGRect = .zero
        newSmallRect.size = image.size
        newSmallRect.origin = NSPoint(x: newImageRect.midX - newSmallRect.width/2, y: newImageRect.midY - newSmallRect.height/2)
        
        overlay.draw(in: newSmallRect)
        
        newImage.unlockFocus()
        
        return newImage
        
        
    }
    
    func addImage(image: NSImage, position: NSPoint) -> NSImage {
        
        
        let newImage = NSImage(size: self.size)
        
        let background = self
        let overlay = image
        
        newImage.lockFocus()
        
        var imageRect: CGRect = .zero
        imageRect.size = newImage.size
        
        
        var newImageRect: CGRect = .zero
        newImageRect.size = newImage.size
        
        background.draw(in: imageRect)
        
        var newSmallRect: CGRect = .zero
        newSmallRect.size = image.size
 
        newSmallRect.origin = position
        
        overlay.draw(in: newSmallRect)
        
        newImage.unlockFocus()
        
        return newImage
        
        
    }
    
    
    
    func rotated(by degrees: CGFloat) -> NSImage {
        
        let sinDegrees = abs(sin(degrees * CGFloat.pi / 180.0))
        let cosDegrees = abs(cos(degrees * CGFloat.pi / 180.0))
        
        let newSize = CGSize(width: size.height * sinDegrees + size.width * cosDegrees,
                             height: size.width * sinDegrees + size.height * cosDegrees)
        
        
        let imageBounds = NSRect(x: (newSize.width - size.width) / 2,
                                 y: (newSize.height - size.height) / 2,
                                 width: size.width, height: size.height)
        
        let otherTransform = NSAffineTransform()
        otherTransform.translateX(by: newSize.width / 2, yBy: newSize.height / 2)
        otherTransform.rotate(byDegrees: degrees)
        otherTransform.translateX(by: -newSize.width / 2, yBy: -newSize.height / 2)
        
        let rotatedImage = NSImage(size: newSize)
        rotatedImage.lockFocus()
        otherTransform.concat()
        draw(in: imageBounds, from: CGRect.zero, operation: NSCompositingOperation.copy, fraction: 1.0)
        rotatedImage.unlockFocus()
        
        return rotatedImage
    }
    
    
    var pngData: Data? {
        
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        
        // let imageProps = [NSImageCompressionFactor: 0.9] // Tiff/Jpeg
        
        let imageProps = [NSBitmapImageRep.PropertyKey.interlaced: NSNumber(value: true)] // PNG
        return bitmapImage.representation(using: .png, properties: imageProps)
        
        
    }
    
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}
