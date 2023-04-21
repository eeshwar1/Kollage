//
//  Helpers.swift
//  Kollage
//
//  Created by Venky Venkatakrishnan on 9/22/19.
//  Copyright © 2019 Venky UL. All rights reserved.
//

import Cocoa

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
  static let maxStickerDimension: CGFloat = 150
  static let shadowOpacity: Float =  0.4
  static let shadowOffset: CGFloat = 4
  static let imageCompressionFactor = 1.0
  static let maxRotation: UInt32 = 12
  static let rotationOffset: CGFloat = 6
  static let randomNoise: UInt32 = 100
}

enum CornerBorderPosition {
    case topLeft, topRight, bottomRight, bottomLeft
    case top, left, right, bottom
    case none
}

extension CGFloat {
    
    
    func toRadians() -> CGFloat {
        
        return (self * CGFloat.pi) / 180.0
        
    }
    
    func toDegrees() -> CGFloat {
        
        return (self * 180) / CGFloat.pi
        
    }
}
