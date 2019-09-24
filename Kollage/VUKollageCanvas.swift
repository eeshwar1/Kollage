//
//  VUKollageCanvas.swift
//  Kollage
//
//  Created by Venky Venkatakrishnan on 9/22/19.
//  Copyright © 2019 Venky UL. All rights reserved.
//

import Cocoa

class VUKollageCanvas: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSColor.red.set()
        
        dirtyRect.fill()
        // Drawing code here.
    }
    
}
