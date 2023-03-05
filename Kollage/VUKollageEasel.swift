//
//  VUKollageEasel.swift
//  Kollage
//
//  Created by Venkateswaran Venkatakrishnan on 2/4/23.
//  Copyright © 2023 Venky UL. All rights reserved.
//

import Cocoa

class VUKollageEasel: NSView {
    
    var scrollView: NSScrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 1024, height:768))
    
    var clipView: NSClipView = NSClipView()
    
    var documentView: NSView = NSView(frame: NSRect(x: 0, y: 0, width: 1200, height:1200))

    var kollageCanvas: VUKollageCanvas = VUKollageCanvas(frame: NSRect(x: 0, y: 0, width: 1024, height: 768))
    
    var kollageBackground: VUKollageBackground = VUKollageBackground(frame: NSRect(x: 0, y: 0, width: 1024, height: 768))
    
    var canvasSize = NSSize(width: 800, height: 600)
    
    var enableShadow = true

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
        
        
        self.documentView.wantsLayer = true
        self.documentView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
        scrollView.autohidesScrollers = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.rulersVisible = true
        scrollView.allowsMagnification = true
        scrollView.magnification = 1.0
        scrollView.maxMagnification = 5.0
        scrollView.minMagnification = 0.25
        
        
        let horizontalRuler = NSRulerView(scrollView: scrollView, orientation: .horizontalRuler)
        
        horizontalRuler.originOffset = 200
        let verticalRuler = NSRulerView(scrollView: scrollView, orientation: .verticalRuler)
        
        verticalRuler.originOffset = 200
        
        scrollView.horizontalRulerView = horizontalRuler
        scrollView.verticalRulerView = verticalRuler
        scrollView.hasVerticalRuler = true
        scrollView.hasHorizontalRuler = true
        scrollView.rulersVisible = true
        
        self.addSubview(scrollView)
        
        setupConstraints(view: scrollView, parentView: self)

        scrollView.documentView = documentView
        
        self.documentView.addSubview(kollageBackground)
        self.documentView.addSubview(kollageCanvas)
        
        kollageBackground.layer?.shadowColor = NSColor.black.cgColor
        kollageBackground.layer?.shadowOffset = .init(width: 50, height: 50)
        
        kollageBackground.frame = NSRect(x: documentView.frame.midX - canvasSize.width/2, y: documentView.frame.midY - canvasSize.height/2, width: canvasSize.width, height: canvasSize.height)
        kollageBackground.needsDisplay = true
        kollageCanvas.frame = NSRect(x: documentView.frame.midX - canvasSize.width/2, y: documentView.frame.midY - canvasSize.height/2, width: canvasSize.width, height: canvasSize.height)
        kollageCanvas.needsDisplay =  true
        
        zoomToFit()
    }
    
    func setupConstraints(view: NSView, parentView: NSView) {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let centerYConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let centerXConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        
        let leftConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentView, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 5)
        let rightConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: parentView, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 5)
        
        let topConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 5)
        
        let bottomConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: parentView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 5)
    
        centerXConstraint.priority = .defaultHigh
        centerYConstraint.priority = .defaultHigh
        bottomConstraint.priority = .defaultLow
        rightConstraint.priority = .defaultLow
        topConstraint.priority = .defaultLow
        leftConstraint.priority = .defaultLow
        
        parentView.addConstraint(centerXConstraint)
        parentView.addConstraint(centerYConstraint)
        parentView.addConstraint(leftConstraint)
        parentView.addConstraint(rightConstraint)
        parentView.addConstraint(topConstraint)
        parentView.addConstraint(bottomConstraint)
    }
    
    
    func setCanvasSize(size: NSSize) {
        
        self.canvasSize = size
        
        self.kollageBackground.frame = NSRect(x: documentView.frame.midX - size.width/2, y: documentView.frame.midY - size.height/2, width: size.width, height: size.height)
        self.kollageCanvas.frame = NSRect(x: documentView.frame.midX - size.width/2, y: documentView.frame.midY - size.height/2, width: size.width, height: size.height)
        
        self.kollageBackground.needsDisplay = true
        self.kollageCanvas.needsDisplay = true
        
        self.scrollView.contentView.scroll(to: .zero)
    }
    
    func setBackground(color: NSColor) {
        
        self.kollageBackground.setBackground(color: color)
        
    }
    
    func setShadowColor(color: NSColor) {
        
        self.kollageCanvas.setShadowColor(color: color)
        
    }
    
    
    func getBackgroundColor () -> NSColor {
        
        return self.kollageBackground.backgroundColor
    }
    func createKollage() -> NSImage  {
        
        
        let canvas = self.kollageCanvas
        
        var kollage = NSImage(size: self.canvasSize)

        let backgroundView = self.kollageBackground

        if let backgroundImage = backgroundView.backgroundImage {

            kollage = backgroundImage.resize(withSize: self.canvasSize) ?? NSImage()
        } else {

            kollage = backgroundView.getImage()
        }
       
        for view in canvas.subviews
        {

            if let imageView = view as? VUDraggableImageView {

                if let image = imageView.getImage() {

                    let rotImage = image.rotated(by: imageView.frameCenterRotation)
                    let resizedImage = rotImage.resize(withSize: imageView.frame.size)
               
                    if let shadow =  imageView.getShadow() {
                        
                        kollage = kollage.addImageAlpha(image: shadow.image, position: shadow.position, alpha: 0.7)
                    }
                    
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
    
    func addText(text: String) {
        
        
        self.kollageCanvas.addText(text: text)
        
    }
    func scaleSelectedView(factor: Double) {
        
        let canvas = self.kollageCanvas
            
    
        for (_, view) in canvas.selectedViews.enumerated() {
            
            if let imageView = view as? VUDraggableImageView {
                
                imageView.scale(factor: factor)
                
            } else if let textView = view as? VUDraggableTextView {
                
                textView.scale(factor: factor)
            }
            
        }
        
    }
    
    func rotateSelectedView(angle: Double) {
        
        let canvas = self.kollageCanvas
        
        for (_, view) in canvas.selectedViews.enumerated() {
            
            if let imageView = view as? VUDraggableImageView {
                
                imageView.rotate(angle: angle)
            } else if let textView = view as? VUDraggableTextView {
                
                textView.rotate(byDegrees: angle)
            }
            
        }
        
    }
    
    func zoomIn() {
        
        self.scrollView.magnification += 0.25
    }
    
    func zoomOut() {
        
        self.scrollView.magnification -= 0.25
    }
    
    func zoomToFit() {
        
        self.scrollView.magnify(toFit: self.kollageCanvas.frame)
    }
    
    func selectAllViews() {
        
        self.kollageCanvas.selectAllViews()
    }
    
    func unselectAllViews() {
        
        self.kollageCanvas.unselectAllViews()
    }
    
    func applyEffect(effect: String) {
        
        self.kollageCanvas.applyEffect(effect: effect)
    }
    
    func removeFilter() {
        
        self.kollageCanvas.removeFilter()
    }
    
    func hasItemsSelected() -> Bool {
        
        return self.kollageCanvas.selectedViews.count > 0
    }
    
    func setBorder(enabled: Bool) {
        
        let canvas = self.kollageCanvas
        
        let views = canvas.selectedViews.count > 0 ? canvas.selectedViews : canvas.subviews

        for (_, view) in views.enumerated() {
            
            if let imageView = view as? VUDraggableImageView {
                
                imageView.setBorder(enabled: enabled)
            }
            
        }
    
    }
    
    func setBorderColor(color: NSColor) {
        
        let canvas = self.kollageCanvas
        
        let views = canvas.selectedViews.count > 0 ? canvas.selectedViews : canvas.subviews
        
   
        for (_, view) in views.enumerated() {
            
            if let imageView = view as? VUDraggableImageView {
                
                imageView.setBorderColor(color: color)
            }
            
        }
        
        
    }
    
    func setBorderWidth(width: CGFloat) {
        
        let canvas = self.kollageCanvas
        
        let views = canvas.selectedViews.count > 0 ? canvas.selectedViews : canvas.subviews
        
        
        for (_, view) in views.enumerated() {
                
                if let imageView = view as? VUDraggableImageView {
                    
                    imageView.setBorderWidth(percent: width)

                }
                
        }
        
    }
    
    func setShadow(enabled: Bool) {
        
        self.enableShadow = enabled
        
        let canvas = self.kollageCanvas
        
        let views = canvas.selectedViews.count > 0 ? canvas.selectedViews : canvas.subviews
    
            
        for (_, view) in views.enumerated() {
            
            if let imageView = view as? VUDraggableImageView {
                
                imageView.setShadow(enabled: self.enableShadow)
            }
            
        }
     
        
    }
}


