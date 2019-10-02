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
