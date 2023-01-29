//
//  VUKollageBackground.swift
//  Kollage
//
//  Created by Venkateswaran Venkatakrishnan on 1/29/23.
//  Copyright © 2023 Venky UL. All rights reserved.
//

import Cocoa

class VUKollageBackground: NSView {
    
    var backgroundImage: NSImage?
    var backgroundColor: NSColor = NSColor.white
    
    var imageView: NSImageView?
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect)
        
    }
    
    
    func setBackground(image: NSImage) {
        
        self.backgroundImage = image
        self.imageView = NSImageView(image: image)
        
        if let imageView = self.imageView {
            imageView.frame.size = self.frame.size
            self.addSubview(imageView)
            self.needsDisplay = true
        }
        
    }
    
    func clearBackgroundImage() {
        
        self.backgroundImage = nil
        self.imageView?.removeFromSuperview()
    }
    
  
    func setBackground(color: NSColor) {
        
        self.backgroundColor = color
        self.clearBackgroundImage()
        
        
    
        self.needsDisplay = true
    }
    
    override func viewWillDraw() {
        
        self.wantsLayer = true
        
        self.layer?.backgroundColor = self.backgroundColor.cgColor
        
    }
    
    func getImage() -> NSImage {
        
        return NSImage.swatchWithColor(color: self.backgroundColor, size: self.frame.size)
       
    }
}



