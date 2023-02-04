//
//  VUKollageEasel.swift
//  Kollage
//
//  Created by Venkateswaran Venkatakrishnan on 2/4/23.
//  Copyright © 2023 Venky UL. All rights reserved.
//

import Cocoa

class VUKollageEasel: NSView {
    
    var kollageCanvas: VUKollageCanvas?
    var kollageBackground: VUKollageBackground?
    
    @IBInspectable var radius : CGFloat = 0.0
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)
        
        let path = NSBezierPath(roundedRect: bounds, xRadius: radius, yRadius: radius)
        
        NSColor.windowBackgroundColor.setFill()
        
        path.fill()
    
        
    }
    
}
