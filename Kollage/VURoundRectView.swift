//
//  VURoundRectView.swift
//  Kollage
//
//  Created by Venky Venkatakrishnan on 9/15/19.
//  Copyright © 2019 Venky UL. All rights reserved.
//

import Cocoa

@IBDesignable class VURoundedRectView: NSView {
    
    @IBInspectable var radius : CGFloat = 10.0
    
    override func draw(_ dirtyRect: NSRect) {
        
        let path = NSBezierPath(roundedRect: bounds, xRadius: radius, yRadius: radius)
        NSColor.black.set()
        path.lineWidth = 1.0
        path.stroke()
    }
}

