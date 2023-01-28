//
//  VUKollageCanvas.swift
//  Kollage
//
//  Created by Venky Venkatakrishnan on 9/22/19.
//  Copyright © 2019 Venky UL. All rights reserved.
//

import Cocoa

protocol DestinationViewDelegate {
    
    func processImageURLs(_ urls: [URL], center: NSPoint)
    func processImage(_ image: NSImage, center: NSPoint)
    func processAction(_ action: String, center: NSPoint)
}

@IBDesignable class VUKollageCanvas: NSView {
    
    @IBInspectable var radius : CGFloat = 5.0
    
    var delegate: DestinationViewDelegate?
    
    var selectedView: NSView?
    
    var background: NSImageView?
    
    override func awakeFromNib() {
        setup()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)
        
        let path = NSBezierPath(roundedRect: bounds, xRadius: radius, yRadius: radius)
        NSColor.black.set()
        NSColor.white.setFill()
        path.fill()
        
    }
    
    
    var nonURLTypes: Set<NSPasteboard.PasteboardType>  { return [NSPasteboard.PasteboardType.tiff, NSPasteboard.PasteboardType.png, .fileURL]}
    
    var acceptableTypes: Set<NSPasteboard.PasteboardType> { if #available(macOS 10.13, *) {
        return nonURLTypes.union([NSPasteboard.PasteboardType.URL])
    } else {
        return    nonURLTypes
    }
        
    }
    
    func setup() {
        registerForDraggedTypes(Array(acceptableTypes))
    }
    
    
    let filteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes:NSImage.imageTypes]
    
    func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        var canAccept = false
        
        let pasteBoard = draggingInfo.draggingPasteboard
        
        if pasteBoard.canReadObject(forClasses: [NSURL.self], options: filteringOptions) {
            canAccept = true
        }
        
        else if let types = pasteBoard.types, nonURLTypes.intersection(types).count > 0 {
            
            canAccept = true
            
        }
        return canAccept
        
    }
    
    var isReceivingDrag = false {
        didSet {
            
            if isReceivingDrag {
                self.layer?.borderWidth = 2.0
                self.layer?.borderColor = .init(red: 0, green: 255, blue: 0, alpha: 1.0)
            } else {
                self.layer?.borderWidth = 0.0
                self.layer?.borderColor = .black
            }
            needsDisplay = true
        }
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = shouldAllowDrag(sender)
        isReceivingDrag = allow
        return allow ? .copy : NSDragOperation()
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let allow = shouldAllowDrag(sender)
        return allow
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        isReceivingDrag = false
        let pasteBoard = draggingInfo.draggingPasteboard
        
        let point = convert(draggingInfo.draggingLocation, from: nil)

        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:filteringOptions) as? [URL], urls.count > 0 {
            processImageURLs(urls, center: point)
            return true
        }
        else if let image = NSImage(pasteboard: pasteBoard) {
            processImage(image, center: point)
            return true
        }
        
        return false
        
    }
    
    func processImageURLs(_ urls: [URL], center: NSPoint) {
        
        // print("processImageURLs")
        
        for (index,url) in urls.enumerated() {
            
            if let image = NSImage(contentsOf:url) {
                
                var newCenter = center
        
                if index > 0 {
                    newCenter = center.addRandomNoise(Appearance.randomNoise)
                }
                
                processImage(image, center: newCenter)
            }
        }
        
    }
    
    func processImage(_ image: NSImage, center: NSPoint) {
        
    
        let constrainedSize = image.aspectFitSizeForMaxDimension(self.frame.height/2)
        
        
        let subview = VUDraggableImageView(frame:NSRect(x: center.x - constrainedSize.width/2, y: center.y - constrainedSize.height/2, width: constrainedSize.width, height: constrainedSize.height))
        
        subview.image = image
        subview.canvas = self
        self.addSubview(subview)
        
        let maxrotation = CGFloat(arc4random_uniform(Appearance.maxRotation)) - Appearance.rotationOffset
        subview.frameCenterRotation = maxrotation
    }
    
    func selectView(_ view: NSView) {
        
        self.selectedView = view
        
        if let view = view as? VUDraggableImageView {
            view.select()
        } else if let view = view as? VUDraggableTextView {
            view.select()
        }
        
        for cView in self.subviews {
            
            if let current_view = cView as? VUDraggableImageView, current_view != view {
                
                // print("Image View")
                current_view.unselect()
                
            } else {
                
                if let current_view = cView as? VUDraggableTextView, current_view != view {
                    
                    // print("Text View")
                    current_view.unselect()
                }
            }
            
        }
        
    }

    
    override var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        return true
    }
    
    
    override func keyDown(with event: NSEvent) {

        // print("KC Key Down: \(event.keyCode)")
        self.selectedView?.keyDown(with: event)

    }
    
    func addText() {
        
        let center = NSPoint(x: self.frame.origin.x + self.frame.width/2, y: self.frame.origin.y + self.frame.height/2)
        let textView = VUDraggableTextView(frame: NSRect(x: center.x, y: center.y, width: 200, height: 50))
        self.addSubview(textView)
        textView.canvas = self
        
        needsDisplay = true
    }

    func changeFont (_ font: NSFont) {
    
        if let textView = self.selectedView as? VUDraggableTextView {
            textView.changeFont(font)
        }
        
    }
    
    func setAsBackground(_ imageView: NSImageView) {
        
        
        if let image = imageView.image {
            self.background = NSImageView(image: image)
            self.background!.frame.size = NSSize(width: self.frame.width-10, height: self.frame.height-10)
        }
        
        
        self.subviews.insert(self.background!, at: 0)
        imageView.removeFromSuperview()
        
    }
}
