//
//  NSView+Extension.swift
//  Kollage
//
//  Created by Venkateswaran Venkatakrishnan on 1/28/23.
//  Copyright © 2023 Venky UL. All rights reserved.
//

import Cocoa

extension NSView {
    
    func snapshot() -> NSImage {
    
        let pdfData = dataWithPDF(inside: bounds)
        let image = NSImage(data: pdfData)
        return image ?? NSImage()
    }
    
    
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
