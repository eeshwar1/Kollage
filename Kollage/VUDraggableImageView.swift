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

class VUDraggableImageView: NSImageView {
    
    var firstMouseDownPoint: NSPoint = NSZeroPoint
    
    var draggingType: DraggingType = .frame
    
    var canvas: VUKollageCanvas?
    
    var borderColor: NSColor?
    var borderWidth: CGFloat = 0.0
    
    var sizeFactor: Double = 1.0
    var rotationAngle: Double = 0.0
    
    var imageData: Data?
    
    var selected: Bool = false {
        didSet {
            
            if selected {
                self.layer?.borderColor = NSColor.red.cgColor
                self.layer?.borderWidth = 3.0
            } else {
                
                self.layer?.borderWidth = 0.0
            }
            needsDisplay = true
        }
    }
    
    override var image: NSImage? {
        
        didSet {
            
            if let _image = image {
                
                let maxDimension: CGFloat =  CGFloat.maximum(self.frame.height, self.frame.width)
                self.frame.size = _image.sizeForMaxDimension(maxDimension)
                
                needsDisplay = true
                
            }
            
            
        }
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
        
        self.image = image
        self.imageData = image.tiffRepresentation
    }
    
    func configureImageView()
    {
        self.wantsLayer = true
        
        self.layer?.borderWidth = borderWidth
        
        if let color = self.borderColor {
            self.layer?.borderColor = color.cgColor
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
        
        // print("Send to back")
        self.superview?.sendSubviewToBack(self)
        
    }
    
    @objc func bringToFront(_ sender: NSMenuItem) {
        
        // print("Bring to front")
        self.superview?.bringSubviewToFront(self)
        
    }
    
    @objc func sendBackward(_ sender: NSMenuItem) {
        
        // print("Send Backward")
        self.superview?.sendSubviewBackward(self)
        
    }
    
    @objc func bringForward(_ sender: NSMenuItem) {
        
        // print("Bring forward")
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
        
        // print("mouseUp: \(unselectOther)")
            
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
