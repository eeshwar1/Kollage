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
