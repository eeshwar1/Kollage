//
//  VUKollageBackground.swift
//  Kollage
//
//  Created by Venkateswaran Venkatakrishnan on 1/29/23.
//  Copyright © 2023 Venky UL. All rights reserved.
//

import Cocoa

enum ImageFit {
    case center
    case fit
    case stretch
    case tile
    
    init(name: String) {
        
        switch name.lowercased() {
            
        case "center":
            self = .center
        case "fit":
            self = .fit
        case "stretch":
            self = .stretch
        case "tile":
            self = .tile
        default:
            self = .fit
        }
    }
}
class VUKollageBackground: NSView {
    
    var backgroundImage: NSImage?
    var resizedBackgroundImage: NSImage?
    var backgroundImageOption: ImageFit = .fit
    
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
    
    func setBackground(image: NSImage, option: ImageFit ) {
        
        self.backgroundColor = .white
        
        self.clearBackgroundImage()
        
        self.backgroundImage = image
        
        self.setupBackgroundImage()
        
    }
    
    func setupBackgroundImage() {
        
        clearBackgroundImageView()
        
        guard let image = self.backgroundImage else { return }
      
        self.resizedBackgroundImage = image
        
        switch self.backgroundImageOption {
            
        case .tile:
            self.resizedBackgroundImage = image.tiledImage(size: self.frame.size)
        case .stretch:
            self.resizedBackgroundImage = image.stretchedImage(size: self.frame.size)
        case .center:
            self.resizedBackgroundImage = image
        case .fit:
            let maxDimension = self.frame.width > self.frame.height ? self.frame.width : self.frame.height
            self.resizedBackgroundImage = image.resize(withSize: image.sizeForMaxDimension(maxDimension)) ?? image
        }
        
        
        self.imageView = NSImageView(image: self.resizedBackgroundImage!)
        
        if let imageView = self.imageView {
            
            imageView.frame.size = self.frame.size
            self.addSubview(imageView)
            self.needsDisplay = true
            
        }
        
    }
    func resizeImageView() {
        
 
        if let _ = self.backgroundImage, let _ = self.imageView
        {
            self.setupBackgroundImage()
            
        }
    }
    
    func clearBackgroundImage() {
        
        if let _ = self.backgroundImage {
            
            self.backgroundImage = nil
            self.clearBackgroundImageView()
            
        }
    }
    
    func clearBackgroundImageView() {
        
        if let imageView = self.imageView {
            
            imageView.removeFromSuperview()
            self.needsDisplay = true
            
        }
        
    }
    
    func setBackground(color: NSColor) {
        
        self.clearBackgroundImage()
        self.backgroundColor = color
        self.needsDisplay = true
    }
    
    func setBackgroundImageOption(option: ImageFit) {
        
        self.backgroundImageOption = option
        self.setupBackgroundImage()
        
    }
    override func viewWillDraw() {
        
        self.wantsLayer = true
        
        self.layer?.backgroundColor = self.backgroundColor.cgColor
             
    }
    
    func getImage() -> NSImage {
        
        var background = NSImage()
        
        if let image = self.resizedBackgroundImage {

            background = image.resize(withSize: self.frame.size) ?? NSImage()
            
        } else {

            background  = NSImage.swatchWithColor(color: self.backgroundColor, size: self.frame.size)
        }
       
        return background
    }
}



