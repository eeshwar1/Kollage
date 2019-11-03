//
//  VUKollageCanvas.swift
//  Kollage
//
//  Created by Venky Venkatakrishnan on 9/22/19.
//  Copyright © 2019 Venky UL. All rights reserved.
//

import Cocoa

@IBDesignable class VUKollageCanvas: NSView {

    @IBInspectable var radius : CGFloat = 5.0
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)
        
        let path = NSBezierPath(roundedRect: bounds, xRadius: radius, yRadius: radius)
               NSColor.black.set()
        NSColor.white.setFill()
        path.fill()
    }
    
}
