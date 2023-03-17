//
//  VUDraggableImageView.swift
//  Kollage
//
//  Created by Venky Venkatakrishnan on 9/22/19.
//  Copyright © 2019 Venky UL. All rights reserved.
//

import Cocoa

enum DraggingType {
    
    case frame
    case contents
    
}

struct ImageViewAttributes {
    
    var sizefactor: CGFloat
    var angle: CGFloat
    
    var border: Bool
    var borderColor: NSColor
    var borderWidthRatio: Int
    
    var shadow: Bool
    var shadowColor: NSColor
    var shadowType: ShadowType
    
}

class VUDraggableImageView: VUDraggableResizableView {
    
    var imageView = NSImageView()
    
    var firstMouseDownPoint: NSPoint = NSZeroPoint
    
    var draggingType: DraggingType = .frame
    
    var canvas: VUKollageCanvas?
    
   
    var sizeFactor: Double = 1.0
    var rotationAngle: Double = 0.0
    
    var enableShadow: Bool = true
    var shadowColor: NSColor = .black
    var shadowType: ShadowType = .RightTop
    
    var enableBorder: Bool = false
    var borderColor: NSColor = .white
    var borderWidthRatio: CGFloat = 0.0
    
    var imageData: Data?
    
    var topConstraint: NSLayoutConstraint = NSLayoutConstraint()
    var bottomConstraint: NSLayoutConstraint = NSLayoutConstraint()
    var leftConstraint: NSLayoutConstraint = NSLayoutConstraint()
    var rightConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    var attributes: ImageViewAttributes {
        
        get {
            
            return ImageViewAttributes(
                
                sizefactor: self.sizeFactor,
                angle: self.frameCenterRotation,
               
                border: self.enableBorder,
                borderColor: self.borderColor,
                borderWidthRatio: Int(self.borderWidthRatio * 100),
                
                shadow: self.enableShadow,
                shadowColor: self.shadowColor,
                shadowType: self.shadowType
            )
        }
    }
    
   
    var image: NSImage?
     {

        didSet {

            if let _image = image {
                
                self.imageView.image = _image
                self.needsDisplay = true
                
            }
        }
    }
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect)
        
        self.wantsLayer = true
 
        self.addSubview(self.imageView)
        configureImageView()
        
        
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        self.wantsLayer = true
        
        if let imageView = NSImageView(coder: coder) {
            
            self.imageView = imageView
            self.addSubview(self.imageView)

            configureImageView()
        }
        
        
    }
    
    func configureImageView()
    {
        self.wantsLayer = true
        
        addConstraints()
    
        self.configureShadow()
        
    }
    
    func addConstraints() {
        
        
        let dimension = CGFloat.maximum(self.frame.height, self.frame.height)

        let borderWidth = dimension * self.borderWidthRatio
        let marginWidth = borderWidth + selectionMarkLineWidth
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let centerYConstraint: NSLayoutConstraint = NSLayoutConstraint(item: self.imageView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let centerXConstraint: NSLayoutConstraint = NSLayoutConstraint(item: self.imageView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        
        let leftConstraint: NSLayoutConstraint = NSLayoutConstraint(item: self.imageView, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: marginWidth)
        let rightConstraint: NSLayoutConstraint = NSLayoutConstraint(item: self.imageView, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: marginWidth)
        
        let topConstraint: NSLayoutConstraint = NSLayoutConstraint(item: self.imageView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: marginWidth)
        
        let bottomConstraint: NSLayoutConstraint = NSLayoutConstraint(item: self.imageView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: marginWidth)
        
        bottomConstraint.priority = .dragThatCanResizeWindow
        rightConstraint.priority = .dragThatCanResizeWindow
        
        self.addConstraint(centerXConstraint)
        self.addConstraint(centerYConstraint)
        self.addConstraint(leftConstraint)
        self.addConstraint(rightConstraint)
        self.addConstraint(topConstraint)
        self.addConstraint(bottomConstraint)
        
        self.topConstraint = topConstraint
        self.bottomConstraint = bottomConstraint
        self.leftConstraint = leftConstraint
        self.rightConstraint = rightConstraint
        
    }

    func configureShadow() {
        
        if self.enableShadow {
            
            self.shadow = NSShadow()
            self.layer?.shadowOpacity = 0.7
            self.layer?.shadowColor = self.shadowColor.cgColor
            self.layer?.shadowOffset = self.getShadowOffset()
            self.layer?.shadowRadius = 6.0
            
        } else {
            
            self.shadow = nil
        }
        
        
    }
    
    func getShadowOffset() -> NSSize {
        
        var xOffset: CGFloat = 0.0
        var yOffset: CGFloat = 0.0
        
        switch self.shadowType {
            
        case .RightTop:
            xOffset = 10
            yOffset = 10
        case .RightBottom:
            xOffset = 10
            yOffset = -10
        case .LeftTop:
            xOffset = -10
            yOffset = 10
        case .LeftBottom:
            xOffset = -10
            yOffset = -10
        case .None:
            break
            
        }
        
        return NSMakeSize(xOffset, yOffset)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)
        
        if self.enableBorder {
            self.borderColor.set()
            
            self.bounds.insetBy(dx: selectionMarkLineWidth, dy: selectionMarkLineWidth).fill()
        }

        
    }
    
    
    func setImage(image: NSImage) {
        
        self.imageData = image.tiffRepresentation
      
        self.image = image

        self.setImageFrame()
        
    }
    
    func setImageFrame() {
        
    
        if let image = self.image {
            
            let maxDimension: CGFloat = CGFloat.maximum(self.frame.height, self.frame.width)
            
            let imageSize = image.aspectFitSizeForMaxDimension(maxDimension)
            
            let borderWidth = self.borderWidthRatio * CGFloat.maximum(imageSize.width, imageSize.height)
            
            self.frame.size = NSSize(width: imageSize.width + 2 * borderWidth + 2 * selectionMarkLineWidth,
                                     height: imageSize.height + 2 * borderWidth + 2 * selectionMarkLineWidth)
            
            self.imageView.image = image
            
            needsDisplay = true
        }
       
        
    }
    
    func setShadow(enabled: Bool) {
        
        self.enableShadow = enabled
        self.configureShadow()
        self.needsDisplay = true
    }
    
    func setShadowColor(color: NSColor) {
        
        self.shadowColor = color
        self.configureShadow()
        self.needsDisplay = true
    }
    
    func setShadowType(type: ShadowType) {
    
        self.shadowType = type
        self.configureShadow()
        self.needsDisplay = true
    }
    
    func setBorder(enabled: Bool) {
        
        self.enableBorder = enabled
        
        configureBorder()
       
    }
    
    func setBorderColor(color: NSColor) {
        
        self.borderColor = color
      
        self.needsDisplay = true
    }

    
    func setBorderWidth(percent: CGFloat) {
        
        self.borderWidthRatio = percent/100
        
        configureBorder()

        
    }
    
    func configureBorder() {
    
        if let _ = self.image {
            
           var borderWidth = 0.0
            
           if self.enableBorder {
                
                let dimension = CGFloat.maximum(self.frame.height, self.frame.width)
                borderWidth = dimension * self.borderWidthRatio
                
            }
            
            let marginWidth = borderWidth + selectionMarkLineWidth
            
            self.topConstraint.constant =  marginWidth
            self.bottomConstraint.constant = marginWidth
            self.leftConstraint.constant = marginWidth
            self.rightConstraint.constant = marginWidth
            
            self.needsDisplay = true
            
            
        }
        
    }

    func getImage() -> NSImage? {
        
        guard let image = self.image else { return nil }
        
        var borderWidth = CGFloat.maximum(self.frame.width, self.frame.height) * self.borderWidthRatio
        
        if let _ = self.image {
            
            borderWidth = CGFloat.maximum(imageView.frame.width, imageView.frame.height) * self.borderWidthRatio
        }
        
        return image.withBorder(color: borderColor, width: borderWidth)
            
        
    }
    
    func getShadow() -> (image: NSImage, position: NSPoint)? {
        
        guard self.enableShadow else { return nil }
            
        let shadowSize = NSSize(width: self.frame.size.width + 20, height: self.frame.size.height + 20)
        let baseShadow = NSImage.swatchWithColor(color: self.shadowColor, size: shadowSize)
        
        let rotShadow = baseShadow.rotated(by: imageView.frameCenterRotation).applyGaussianBlur()
        
        let shadow = rotShadow.resize(withSize: self.frame.size)!
        
        let shadowPosition = NSPoint(x: self.frame.origin.x + 20, y: self.frame.origin.y + 20)
        
        return (image: shadow, position: shadowPosition)
        
    }
        
    func select() {
        
        self.selected = true
    }

    func unselect() {
        
        self.selected = false
    }
    
    // MARK: Reordering in Z Index
    
    @objc func sendToBack(_ sender: NSMenuItem) {
        
        self.superview?.sendSubviewToBack(self)
        
    }
    
    @objc func bringToFront(_ sender: NSMenuItem) {
        
        self.superview?.bringSubviewToFront(self)
        
    }
    
    @objc func sendBackward(_ sender: NSMenuItem) {

        self.superview?.sendSubviewBackward(self)
        
    }
    
    @objc func bringForward(_ sender: NSMenuItem) {
        
        self.superview?.bringSubviewForward(self)
        
    }
    
    override func rightMouseDown(with event: NSEvent) {
        
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(withTitle: "Bring to Front", action: #selector(bringToFront(_:)), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Bring Forward", action: #selector(bringForward(_:)), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Send Backward", action: #selector(sendBackward(_:)), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Send to Back", action: #selector(sendToBack(_:)), keyEquivalent: "").target = self
      
        self.menu = menu
        
        let eventLocation = event.locationInWindow
        menu.popUp(positioning: nil, at: self.convert(eventLocation, from: nil), in: self)
        
    }
   
    // MARK: Drag and Drop
    
    var nonURLTypes: Set<NSPasteboard.PasteboardType>  { return [NSPasteboard.PasteboardType.tiff, NSPasteboard.PasteboardType.png, .fileURL]}
    
    var acceptableTypes: Set<NSPasteboard.PasteboardType> { if #available(macOS 10.13, *) {
        return nonURLTypes.union([NSPasteboard.PasteboardType.URL])
    } else {
        return nonURLTypes
    }
        
    }
    
    func setup() {
        registerForDraggedTypes(Array(acceptableTypes))
    }
    
    
    let filteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes:NSImage.imageTypes]
    
    func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        var canAccept = false
        
        //2.
        let pasteBoard = draggingInfo.draggingPasteboard
        
        //3.
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
            needsDisplay = true
        }
    }

    
    override func updateTrackingAreas() {
        
        super.updateTrackingAreas()
        
        trackingAreas.forEach({ removeTrackingArea($0) })
        
        addTrackingArea(NSTrackingArea(rect: self.bounds,
                                       options: [.mouseMoved,
                                                 .mouseEnteredAndExited,
                                                 .activeAlways],
                                       owner: self))
    }
    
    
    // MARK: Mouse events
    override func mouseExited(with event: NSEvent) {
        NSCursor.arrow.set()
    }
    
    
    override func mouseUp(with event: NSEvent) {
        
        super.mouseUp(with: event)
    
        let unselectOther = event.modifierFlags.contains(.shift)
        
        self.canvas?.selectView(self, unselectOther: !unselectOther)
        
        
    }
    
   
    // MARK: Keyboard events
    override func keyDown(with event: NSEvent) {
        
        if event.keyCode == 51 {
            
            self.removeFromSuperview()
        }
        
    }
    
    override var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
    
        
    private func repositionView() {
        
        guard let superView = superview else {
            print("returning from reposition")
            
            return }
        
        if self.frame.minX < superView.frame.minX {
            self.frame.origin.x = superView.frame.minX
        }
        if self.frame.minY < superView.frame.minY {
            self.frame.origin.y = superView.frame.minY
        }
        
        if self.frame.maxX > superView.frame.maxX {
            self.frame.origin.x = superView.frame.maxX - self.frame.size.width
        }
        if self.frame.maxY > superView.frame.maxY {
            self.frame.origin.y = superView.frame.maxY - self.frame.size.height
        }
    }
    
    
    func scale(factor: Double) {
        
        if let image = self.image {
            
            let borderWidth = image.size.width * self.borderWidthRatio
            
            let maxDimension = image.size.width > image.size.height ? image.size.width : image.size.height
            
            let constrainedSize = image.aspectFitSizeForMaxDimension(maxDimension * factor)
            
            self.setFrameSize(.init(width: constrainedSize.width + 2 * borderWidth, height: constrainedSize.height + 2 * borderWidth))
        }
      
    }
    
    
    func rotate(angle: Double) {
        
        self.frameCenterRotation = angle
        
    }
    
    // MARK: Filters
    
    func applyEffect(effect: String) {
        
        if let imageData = self.imageData, let image = NSImage(data: imageData) {
    
            self.image = image.withEffect(effect: effect)
            
        }
        
    }
    
    func removeFilter() {
        
        if let imageData = self.imageData, let image = NSImage(data: imageData) {
            
            self.image = image
            
        }
        
        
    }
}

// MARK: - NSDraggingSource

extension VUDraggableImageView: NSDraggingSource {
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .generic
    }
    
   
}

// MARK: - NSPasteboardItemDataProvider

extension VUDraggableImageView: NSPasteboardItemDataProvider {
    
    func pasteboard(_ pasteboard: NSPasteboard?, item: NSPasteboardItem, provideDataForType type: NSPasteboard.PasteboardType) {
        
        if let pasteboard = pasteboard, type == NSPasteboard.PasteboardType(kUTTypeTIFF as String), let image = self.image {
            let tiffData  = image.tiffRepresentation
            pasteboard.setData(tiffData, forType: type)
        }
    }
    
}
