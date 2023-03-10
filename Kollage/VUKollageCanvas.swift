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
    
    @IBInspectable var radius : CGFloat = 0.0
    
    var delegate: DestinationViewDelegate?
    
    var selectedViews: [NSView] = []
    
    var background: NSImageView?
    
    var vc: ViewController?
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        
    }
    override func awakeFromNib() {
        setup()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)
        
        let path = NSBezierPath(rect: dirtyRect)
        NSColor.black.set()
    
        path.stroke()
        
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
    
    func viewSelected() -> Bool {
        
        return self.selectedViews.count > 0
        
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
    
    func addImages(_ urls: [URL]) {
        
        
        let point = NSPoint(x: self.frame.minX, y: self.frame.minY).addRandomNoise(Appearance.randomNoise)
        
        processImageURLs(urls, center: point)
        
    }
    
    func processImageURLs(_ urls: [URL], center: NSPoint) {
        
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
        
        let imageView = VUDraggableImageView(frame:NSRect(x: center.x - constrainedSize.width/2, y: center.y - constrainedSize.height/2, width: constrainedSize.width, height: constrainedSize.height))
        
        imageView.sizeFactor = constrainedSize.width/image.size.width
        
        imageView.setImage(image: image)
        imageView.canvas = self
        
        self.addSubview(imageView)
        
        let imageRotation = 0.0
        
        imageView.frameCenterRotation = imageRotation
        imageView.rotationAngle = 0.0
    }
    
    // MARK: Selection
    func selectAllViews() {
        
        for view in self.subviews {
            
            selectView(view)
            
        }
        
    }
    
    func unselectAllViews() {
        
        for view in self.selectedViews {
            
           unselectView(view)
            
        }
        
    }
    
    func unselectView(_ view: NSView) {
        
        if let index = self.selectedViews.firstIndex(of: view) {
    
            self.selectedViews.remove(at: index)
        }
        
        if let imageView = view as? VUDraggableImageView {
            
            imageView.unselect()
            
            if let vc = self.vc {
                
                if self.selectedViews.count == 0 {
                    
                    vc.disableImageControls()
                }
            }
            
        }
        else if let textView = view as? VUDraggableTextView {
            textView.unselect()
        }
   
        
    }
    
    func selectView(_ view: NSView, unselectOther: Bool = false) {
        
        
        self.selectedViews.append(view)
        
        if let view = view as? VUDraggableImageView {
            
            view.select()
            
            if let vc = self.vc {
                
                if self.selectedViews.count >= 1 {
                    
                    vc.enableImageControls(attributes: view.attributes)
                    
                } else {
                    
                    vc.disableImageControls()
                }
                
            }
            
        }
        else if let view = view as? VUDraggableTextView {
            view.select()
        }
        
        if unselectOther {
            
            for subView in self.selectedViews {
                
                if subView != view {
                    unselectView(subView)
                }
                
            }
            
        }
        
        
    }
    
    @objc func selectAllItems(_ sender: NSMenuItem) {
        
        self.selectAllViews()
    }
    
    @objc func selectNone(_ sender: NSMenuItem) {
        
        self.unselectAllViews()
    }
    
    override func mouseUp(with event: NSEvent) {
        
        
        self.unselectAllViews()
        
        
    }
    
    // Mark: First Responder
    
    override var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
    
    // MARK: Keyboard
    
    override func keyDown(with event: NSEvent) {
        
        for (_, view) in selectedViews.enumerated() {
            
            view.keyDown(with: event)
        }
        
        
    }
    
    func addText(attributedText: NSAttributedString) {
        
        let center = NSPoint(x: self.frame.minX, y: self.frame.minY).addRandomNoise(Appearance.randomNoise)
        
        let textView = VUDraggableTextView(location: center, attributedText: attributedText)
        
        self.addSubview(textView)
        textView.canvas = self
        
        needsDisplay = true
    }
    
    
    func changeFont(_ font: NSFont) {

        for (_, view) in selectedViews.enumerated() {

            if let textView = view as? VUDraggableTextView {
                textView.changeFont(font)
            }
        }


    }
    
    func setAsBackground(_ imageView: NSImageView) {
        
        
        if let image = imageView.image {
            
            self.background = NSImageView(image: image)
            
            let maxDimension: CGFloat =  CGFloat.maximum(self.frame.height, self.frame.width)
            
            self.background?.frame.size = image.sizeForMaxDimension(maxDimension)
            
            
        }
        
        self.subviews.insert(self.background!, at: 0)
        imageView.removeFromSuperview()
        
    }
    
    override func rightMouseDown(with event: NSEvent) {
        
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(withTitle: "Add Images...", action: #selector(addPhotos(_:)), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Select All", action: #selector(selectAllItems(_:)), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Select None", action: #selector(selectNone(_:)), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Clear", action: #selector(clearCanvas(_:)), keyEquivalent: "").target = self
        
        if (self.subviews.count == 0) {
            menu.item(withTitle: "Clear")?.isEnabled = false
            menu.item(withTitle: "Select All")?.isEnabled = false
            menu.item(withTitle: "Select None")?.isEnabled = false
            
        }
       
        if (self.selectedViews.count == 0) {
            menu.item(withTitle: "Select None")?.isEnabled = false
        }
        self.menu = menu
        
        let eventLocation = event.locationInWindow
        menu.popUp(positioning: nil, at: self.convert(eventLocation, from: nil), in: self)
        
    }
    
    @objc func addPhotos(_ sender: NSMenuItem) {
        
        if let vc = self.vc {
            vc.addPhotos()
        }
    }
   
    @objc func clearCanvas(_ sender: NSMenuItem) {
        
        let clearConfirmation = NSAlert()
        
        clearConfirmation.messageText = "Clear Canvas"
        clearConfirmation.informativeText = "Do you really want to clear the canvas?"
        clearConfirmation.addButton(withTitle: "Yes")
        clearConfirmation.addButton(withTitle: "No")
        clearConfirmation.alertStyle = .warning
        
        if clearConfirmation.runModal() == .alertFirstButtonReturn {
            self.subviews.removeAll()
            self.vc?.disableImageControls()
        }
        
        
    }
   
    
    
    func applyEffect(effect: String) {
        
        for (_, view) in selectedViews.enumerated() {
            
            if let imageView = view as? VUDraggableImageView {
                imageView.applyEffect(effect: effect)
                
            }
        }
        
        
    }
    
    func removeFilter() {
        
        for (_, view) in selectedViews.enumerated() {
            
            if let imageView = view as? VUDraggableImageView {
                imageView.removeFilter()
            }
        }
        
    }
    
    func setShadowColor(color: NSColor) {
        
        for (_, view) in selectedViews.enumerated() {
            
            if let imageView = view as? VUDraggableImageView {
                imageView.setShadowColor(color: color)
            }
        }
        
    }
   
}


