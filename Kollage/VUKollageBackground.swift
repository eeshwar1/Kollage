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
    var resizedBackgroundImage: NSImage?
    var backgroundColor: NSColor = NSColor.white
    
    var imageView: NSImageView?
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        self.autoresizesSubviews = true
    }
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect)
        self.autoresizesSubviews = true
        
    }
    
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        
        resizeImageView()
        
    }
    
    func setBackground(image: NSImage) {
        
        self.backgroundColor = .white
        
        self.clearBackgroundImage()
        let maxDimension = self.frame.width > self.frame.height ? self.frame.width : self.frame.height
        
        self.backgroundImage = image
        self.resizedBackgroundImage = image.resize(withSize: image.sizeForMaxDimension(maxDimension))
        
        self.resizedBackgroundImage?.resizingMode = .tile
    
        
        self.imageView = NSImageView(image: self.resizedBackgroundImage ?? NSImage())
        
        if let imageView = self.imageView {
            
            imageView.frame.size = self.frame.size
            self.addSubview(imageView)
            self.needsDisplay = true
            
        }
        
    }
    
    func resizeImageView() {
        
        let maxDimension = self.frame.width > self.frame.height ? self.frame.width : self.frame.height
        
        if let image = self.backgroundImage, let _ = self.imageView
        {
            self.resizedBackgroundImage = image.resize(withSize: image.sizeForMaxDimension(maxDimension))
            
            self.imageView?.image = self.resizedBackgroundImage
            self.imageView?.frame.size = self.frame.size
            self.needsDisplay = true
            
        }
    }
    
    func clearBackgroundImage() {
        
        if let _ = self.backgroundImage, let imageView = self.imageView {
            self.backgroundImage = nil
            imageView.removeFromSuperview()
            self.needsDisplay = true
        }
    }
    
    func setBackground(color: NSColor) {
        
        self.clearBackgroundImage()
        self.backgroundColor = color
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



