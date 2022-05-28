//
//  Helpers.swift
//  Kollage
//
//  Created by Venky Venkatakrishnan on 9/22/19.
//  Copyright © 2019 Venky UL. All rights reserved.
//

import Cocoa

extension NSView {
    
    func snapshot() -> NSImage {
    
        let pdfData = dataWithPDF(inside: bounds)
        let image = NSImage(data: pdfData)
        return image ?? NSImage()
    }
}

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
    
    
    func sizeForMaxDimention(_ maxDimension: CGFloat) -> NSSize {


        let aspectRatio = self.size.width/self.size.height

        let width = aspectRatio > 0 ? maxDimension: maxDimension * aspectRatio
        let height = aspectRatio < 0 ? maxDimension: maxDimension/aspectRatio

        return NSSize(width: width, height: height)
    }
}


extension NSPoint {
  /**
   Mutate an NSPoint with a random amount of noise bounded by maximumDelta
   
   - parameter maximumDelta: change range +/-
   
   - returns: mutated point
   */
  func addRandomNoise(_ maximumDelta: UInt32) -> NSPoint {
    
    var newCenter = self
    let range = 2 * maximumDelta
    let xdelta = arc4random_uniform(range)
    let ydelta = arc4random_uniform(range)
    newCenter.x += (CGFloat(xdelta) - CGFloat(maximumDelta))
    newCenter.y += (CGFloat(ydelta) - CGFloat(maximumDelta))
    
    return newCenter
      
  }
}

enum Appearance {
  static let maxStickerDimension: CGFloat = 150.0
  static let shadowOpacity: Float =  0.4
  static let shadowOffset: CGFloat = 4
  static let imageCompressionFactor = 1.0
  static let maxRotation: UInt32 = 12
  static let rotationOffset: CGFloat = 6
  static let randomNoise: UInt32 = 200
  static let numStars = 20
  static let maxStarSize: CGFloat = 30
  static let randonStarSizeChange: UInt32 = 25
  static let randomNoiseStar: UInt32 = 100
}

enum CornerBorderPosition {
    case topLeft, topRight, bottomRight, bottomLeft
    case top, left, right, bottom
    case none
}

extension NSView {

    func bringSubviewToFront(_ view: NSView) {
            var theView = view
            self.sortSubviews({(viewA,viewB,rawPointer) in
                let view = rawPointer?.load(as: NSView.self)

                switch view {
                case viewA:
                    return ComparisonResult.orderedDescending
                case viewB:
                    return ComparisonResult.orderedAscending
                default:
                    return ComparisonResult.orderedSame
                }
            }, context: &theView)
    }

}
