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
    var shadow: Bool
    var border: Bool
    var borderColor: NSColor
    var borderWidthRatio: Int
    
}

class VUDraggableImageView: NSImageView {
    
    var firstMouseDownPoint: NSPoint = NSZeroPoint
    
    var draggingType: DraggingType = .frame
    
    var canvas: VUKollageCanvas?
    
    var borderColor: NSColor = .white
    var borderWidthRatio: CGFloat = 0.10
    
    var shadowColor: NSColor = .black
    
    var sizeFactor: Double = 1.0
    var rotationAngle: Double = 0.0
    
    var enableShadow: Bool = true
    
    var enableBorder: Bool = true
    
    var borderAdded: Bool = false
    
    var imageData: Data?
    
    
    var attributes: ImageViewAttributes {
        
        get {
            
            return ImageViewAttributes(
                
                sizefactor: self.sizeFactor,
                angle: self.frameCenterRotation,
                shadow: self.enableShadow,
                border: self.enableBorder,
                borderColor: self.borderColor,
                borderWidthRatio: Int(self.borderWidthRatio * 100)
            )
        }
    }
    
    var selected: Bool = false {
        
        didSet {
            
            needsDisplay = true
            
        }
    }
    
    override var image: NSImage? {
        
        didSet {
            
            if let _image = image {
                
                let maxDimension: CGFloat =  CGFloat.maximum(self.frame.height, self.frame.width)
                
                let imageSize = _image.sizeForMaxDimension(maxDimension)
                
                self.frame.size = imageSize
                
                needsDisplay = true
                
            }
            
            
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)
        
        if selected {
            
            drawSelectionMarks()
            
        }
        
    }
    
    func drawSelectionMarks() {
        
        NSColor.controlAccentColor.setStroke()
        
        let handlesPath = NSBezierPath()
        
        handlesPath.move(to: NSPoint(x: self.bounds.minX, y: self.bounds.minY + 50))
        handlesPath.line(to: NSPoint(x: self.bounds.minX, y: self.bounds.minY))
        handlesPath.line(to: NSPoint(x: self.bounds.minX + 50, y: self.bounds.minY))
        
        handlesPath.move(to: NSPoint(x: self.bounds.maxX - 50, y: self.bounds.minY))
        handlesPath.line(to: NSPoint(x: self.bounds.maxX, y: self.bounds.minY))
        handlesPath.line(to: NSPoint(x: self.bounds.maxX, y: self.bounds.minY + 50))
        
        handlesPath.move(to: NSPoint(x: self.bounds.maxX, y: self.bounds.maxY - 50))
        handlesPath.line(to: NSPoint(x: self.bounds.maxX, y: self.bounds.maxY))
        handlesPath.line(to: NSPoint(x: self.bounds.maxX - 50, y: self.bounds.maxY))
        
        handlesPath.move(to: NSPoint(x: self.bounds.minX + 50, y: self.bounds.maxY))
        handlesPath.line(to: NSPoint(x: self.bounds.minX, y: self.bounds.maxY))
        handlesPath.line(to: NSPoint(x: self.bounds.minX, y: self.bounds.maxY - 50))
        
        handlesPath.lineWidth = 10.0
        handlesPath.stroke()
        
    }
    
    private let resizableArea: CGFloat = 5
    
    private var cursorPosition: CornerBorderPosition = .none {
        didSet {
            switch self.cursorPosition {
            case .bottomRight, .topLeft:
                NSCursor(image:
                            NSImage(byReferencingFile: "/System/Library/Frameworks/WebKit.framework/Versions/Current/Frameworks/WebCore.framework/Resources/northWestSouthEastResizeCursor.png")!,
                         hotSpot: NSPoint(x: 8, y: 8)).set()
            case .bottomLeft, .topRight:
                NSCursor(image:
                            NSImage(byReferencingFile: "/System/Library/Frameworks/WebKit.framework/Versions/A/Frameworks/WebCore.framework/Versions/A/Resources/northEastSouthWestResizeCursor.png")!,
                         hotSpot: NSPoint(x: 8, y: 8)).set()
            case .top, .bottom:
                NSCursor.resizeUpDown.set()
            case .left, .right:
                NSCursor.resizeLeftRight.set()
            case .none:
                NSCursor.openHand.set()
            }
        }
    }
    
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect)
        
        self.wantsLayer = true
        
     
        configureImageView()
        
        
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        self.wantsLayer = true

        configureImageView()
        
    }
    
    
    func setImage(image: NSImage) {
        
        self.imageData = image.tiffRepresentation
        
        setBorderedImage()
        
    }
    
    func configureImageView()
    {
        self.wantsLayer = true

    
        self.configureShadow()
        
        
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
    
    func configureShadow() {
        
        if self.enableShadow {
            
            self.shadow = NSShadow()
            self.layer?.shadowOpacity = 1.0
            self.layer?.shadowColor = self.shadowColor.cgColor
            self.layer?.shadowOffset = NSMakeSize(10, 10)
            self.layer?.shadowRadius = 6.0
            
        } else {
            
            self.shadow = nil
        }
        
        
    }
    
    func setBorder(enabled: Bool) {
        
        self.enableBorder = enabled
        
        setBorderedImage()
        
        
    }
    
    func setBorderColor(color: NSColor) {
        
        self.borderColor = color
        
        self.setBorderedImage()
        
    }

    func setBorderWidth(percent: CGFloat) {
        
        self.borderWidthRatio = percent/100
        
        self.setBorderedImage()
        
        
    }
    
    func setBorderedImage() {
        
        if let data = self.imageData, let image = NSImage(data: data) {
            
            if self.enableBorder {
                
                let borderWidth = image.size.width * self.borderWidthRatio
                self.image = image.withBorder(color: borderColor, width: borderWidth)
                
            } else {
                
                self.image = image
            }
            
            self.needsDisplay = true
        }
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
    
    override func mouseDown(with event: NSEvent) {
        
        let locationInView = convert(event.locationInWindow, from: nil)
        
        self.cursorPosition = self.cursorCornerBorderPosition(locationInView)
        
        
    }
    
    override func mouseUp(with event: NSEvent) {
        
        self.cursorPosition = .none
        selected = true
    
        let unselectOther = event.modifierFlags.contains(.shift)
        
            
        self.canvas?.selectView(self, unselectOther: !unselectOther)
        
        
    }
    
    override func mouseMoved(with event: NSEvent) {
        
        let locationInView = convert(event.locationInWindow, from: nil)
        
        self.cursorPosition = self.cursorCornerBorderPosition(locationInView)
    }
    
    override func mouseDragged(with event: NSEvent) {
        
        guard let superView = superview else { print("returning")
            return }
        
        let deltaX = event.deltaX
        let deltaY = event.deltaY
        
        var frameWidth = self.frame.width
        var frameHeight = self.frame.height
        let aspectRatio = frameHeight/frameWidth
        
        switch cursorPosition {
        case .topLeft:
            if superView.frame.width / 3 ..< superView.frame.width ~= self.frame.size.width - deltaX,
               superView.frame.height / 3 ..< superView.frame.height ~= self.frame.size.height - deltaY,
               self.frame.origin.x + deltaX >= superView.frame.minX,
               self.frame.origin.y + self.frame.height - deltaY <= superView.frame.maxY {
                
                frameWidth -= deltaX
                
                // frameHeight -= deltaY
                frameHeight = aspectRatio * frameWidth
                
                self.frame.origin.x += deltaX
                
            }
        case .bottomLeft:
            if superView.frame.width / 3 ..< superView.frame.width ~= self.frame.size.width - deltaX,
               superView.frame.height / 3 ..< superView.frame.height ~= self.frame.size.height + deltaY,
               self.frame.origin.x + deltaX >= superView.frame.minX,
               self.frame.origin.y - deltaY >= superView.frame.minY {
                
                self.frame.origin.x += deltaX
                
                self.frame.origin.y -= deltaY
                
                frameWidth -= deltaX
                
                //frameHeight += deltaY
                frameHeight = aspectRatio * frameWidth
                
            }
        case .topRight:
            if superView.frame.width / 3 ..< superView.frame.width ~= self.frame.size.width + deltaX,
               superView.frame.height / 3 ..< superView.frame.height ~= self.frame.size.height - deltaY,
               self.frame.origin.x + self.frame.width + deltaX <= superView.frame.maxX,
               self.frame.origin.y + self.frame.height - deltaY <= superView.frame.maxY {
                
                frameWidth += deltaX
                
                // frameHeight -= deltaY
                frameHeight = aspectRatio * frameWidth
                
            }
        case  .bottomRight:
            if superView.frame.width / 3 ..< superView.frame.width ~= self.frame.size.width + deltaX,
               superView.frame.height / 3 ..< superView.frame.height ~= self.frame.size.height + deltaY,
               self.frame.origin.x + self.frame.width + deltaX <= superView.frame.maxX,
               self.frame.origin.y - deltaY >= superView.frame.minY {
                
                self.frame.origin.y -= deltaY
                
                frameWidth += deltaX
                
                // frameHeight += deltaY
                frameHeight = aspectRatio * frameWidth
                
            }
        case .top:
            if superView.frame.height / 3 ..< superView.frame.height ~= self.frame.size.height - deltaY,
               self.frame.origin.y + self.frame.height - deltaY <= superView.frame.maxY {
                frameHeight -= deltaY
                frameWidth = frameWidth / aspectRatio
            }
        case .bottom:
            if superView.frame.height / 3 ..< superView.frame.height ~= self.frame.size.height + deltaY,
               self.frame.origin.y - deltaY >= superView.frame.minY {
                frameHeight += deltaY
                frameWidth = frameWidth / aspectRatio
                self.frame.origin.y -= deltaY
            }
        case .left:
            if superView.frame.width / 3 ..< superView.frame.width ~= self.frame.size.width - deltaX,
               self.frame.origin.x + deltaX >= superView.frame.minX {
                frameWidth -= deltaX
                frameHeight = aspectRatio * frameWidth
                self.frame.origin.x += deltaX
            }
        case .right:
            if superView.frame.width / 3 ..< superView.frame.width ~= self.frame.size.width + deltaX,
               self.frame.origin.x + self.frame.size.width + deltaX <= superView.frame.maxX {
                frameWidth += deltaX
                frameHeight = aspectRatio * frameWidth
            }
        case .none:
            self.frame.origin.x += deltaX
            self.frame.origin.y -= deltaY
        }
        
        
        
        //        print("delta: (\(event.deltaX), \(event.deltaY), frame: \(frameWidth) * \(frameHeight)")
        //
        
        self.setFrameSize(.init(width: frameWidth, height: frameHeight))
        //self.repositionView()
        
        // TODO: Update Size slider here to reflect the new size of the frame
        
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
    
    @discardableResult
    func cursorCornerBorderPosition(_ locationInView: CGPoint) -> CornerBorderPosition {
        
        if locationInView.x < resizableArea,
           locationInView.y < resizableArea {
            return .bottomLeft
        }
        if self.bounds.width - locationInView.x < resizableArea,
           locationInView.y < resizableArea {
            return .bottomRight
        }
        if locationInView.x < resizableArea,
           self.bounds.height - locationInView.y < resizableArea {
            return .topLeft
        }
        if self.bounds.height - locationInView.y < resizableArea,
           self.bounds.width - locationInView.x < resizableArea {
            return .topRight
        }
        if locationInView.x < resizableArea {
            return .left
        }
        if self.bounds.width - locationInView.x < resizableArea {
            return .right
        }
        if locationInView.y < resizableArea {
            return .bottom
        }
        if self.bounds.height - locationInView.y < resizableArea {
            return .top
        }
        
        return .none
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
            
            let maxDimension = image.size.width > image.size.height ? image.size.width : image.size.height
            
            let constrainedSize = image.aspectFitSizeForMaxDimension(maxDimension * factor)
            
            self.setFrameSize(.init(width:  constrainedSize.width, height: constrainedSize.height))
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
        
        if let imageData = self.imageData {
            
            
            self.image = NSImage(data: imageData)
            
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
