//
//  VUKollageEasel.swift
//  Kollage
//
//  Created by Venkateswaran Venkatakrishnan on 2/4/23.
//  Copyright © 2023 Venky UL. All rights reserved.
//

import Cocoa

class VUKollageEasel: NSView {
    
    var kollageCanvas: VUKollageCanvas = VUKollageCanvas(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
    var kollageBackground: VUKollageBackground = VUKollageBackground(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
    
    var vc: ViewController? {
        
        didSet {
            
            self.kollageCanvas.vc = vc
        }
    }
    
    @IBInspectable var radius : CGFloat = 0.0
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect)
        
        setupSubViews()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
        
    }

    func setupSubViews() {
        
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
        //self.setCanvasSize(size: .init(width: 100, height: 100))
        self.addSubview(kollageBackground)
        self.addSubview(kollageCanvas)
        
        setupConstraints(view: kollageBackground)
        setupConstraints(view: kollageCanvas)
        
        
    }
    
    func setupConstraints(view: NSView) {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let centerYConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let centerXConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        
        let leftConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 5)
        let rightConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: self, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 5)
        
        let topConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 5)
        
        let bottomConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 5)
    
        centerXConstraint.priority = .defaultHigh
        centerYConstraint.priority = .defaultHigh
        bottomConstraint.priority = .defaultLow
        rightConstraint.priority = .defaultLow
        topConstraint.priority = .defaultLow
        leftConstraint.priority = .defaultLow
        
        self.addConstraint(centerXConstraint)
        self.addConstraint(centerYConstraint)
        self.addConstraint(leftConstraint)
        self.addConstraint(rightConstraint)
        self.addConstraint(topConstraint)
        self.addConstraint(bottomConstraint)
    }
    
    
    func setCanvasSize(size: NSSize) {
        
        print("Setting canvas size...")
        
        self.kollageBackground.frame.size = .init(width: size.width, height: size.height)
        self.kollageCanvas.frame.size = .init(width: size.width, height: size.height)
        
        print("\(self.kollageCanvas.frame.size)")
        self.kollageBackground.needsDisplay = true
        self.kollageCanvas.needsDisplay = true
    }
    
    func createKollage() -> NSImage  {
        
        
        let canvas = self.kollageCanvas
        
        var kollage = NSImage(size: canvas.frame.size)

        let backgroundView = self.kollageBackground

        if let backgroundImage = backgroundView.backgroundImage {

            kollage = backgroundImage.resize(withSize: self.kollageCanvas.frame.size) ?? NSImage()
        } else {

            kollage = backgroundView.getImage()
        }

       
        for view in canvas.subviews
        {

            if let imageView = view as? VUDraggableImageView {

                if let image = imageView.image {


                    let rotImage = image.rotated(by: imageView.frameCenterRotation)
                    let resizedImage = rotImage.resize(withSize: imageView.frame.size)
                    kollage = kollage.addImage(image: resizedImage ?? NSImage(), position: imageView.frame.origin)
                }

            }

        }

        return kollage
        
    }
    
    func changeFont(_ sender: NSFontManager?) {
        
        guard let fontManager = sender else {
            return
        }
        
        let newFont = fontManager.convert(NSFont.systemFont(ofSize: 14))
        
        kollageCanvas.changeFont(newFont)
            
        
    }
    
    func addImages(_ urls: [URL]) {
        
        self.kollageCanvas.addImages(urls)
        
    }
    
    func scaleSelectedView(factor: Double) {
        
        let canvas = self.kollageCanvas
            
        if let imageView = canvas.selectedView as? VUDraggableImageView {
            
            imageView.scale(factor: factor)
            
        } else if let textView = canvas.selectedView as? VUDraggableTextView {
            
            textView.scale(factor: factor)
        }
            
        
    }
    
    func rotateSelectedView(angle: Double) {
        
        let canvas = self.kollageCanvas
        
        if let imageView = canvas.selectedView as? VUDraggableImageView {
            
            imageView.rotate(angle: angle)
        } else if let textView = canvas.selectedView as? VUDraggableTextView {
            
            
            textView.rotate(byDegrees: angle)
        }
    }
}
