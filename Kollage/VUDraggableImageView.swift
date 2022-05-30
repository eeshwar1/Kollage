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
    
   var selected: Bool = false {
        didSet {
            
            if selected {
                self.layer?.borderColor = .init(red: 0, green: 255, blue: 0, alpha: 1.0)
                self.layer?.borderWidth = 2.0
            } else {
                
                self.layer?.borderWidth = 0.0
            }
            needsDisplay = true
        }
    }
    
   override var image: NSImage? {
        didSet {
            
            if let _image = image {
               
                let maxDimension: CGFloat =  CGFloat.maximum(self.frame.size.height, self.frame.size.width)
                self.frame.size = _image.sizeForMaxDimention(maxDimension)
               
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
        configureImageView()
       
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        configureImageView()
    }
    
    func configureImageView()
    {
        self.wantsLayer = true
        self.layer?.borderWidth = 1
        self.layer?.borderColor = NSColor.gray.cgColor
        
    }

    
//    override func mouseDragged(with event: NSEvent) {
//
//        if self.draggingType == .frame {
//            let newPoint = (self.window?.contentView?.convert(event.locationInWindow, to: self))!
//            let offset = NSPoint(x: newPoint.x - firstMouseDownPoint.x, y: newPoint.y - firstMouseDownPoint.y)
//
//            let origin = self.frame.origin
//            let size = self.frame.size
//
//            self.frame = NSRect(x: origin.x + offset.x, y: origin.y + offset.y, width: size.width, height: size.height)
//        }
//    }

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
    
//    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
//      let allow = shouldAllowDrag(sender)
//      isReceivingDrag = allow
//      return allow ? .copy : NSDragOperation()
//    }
    
//    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
//      let allow = shouldAllowDrag(sender)
//      return allow
//    }
//
//
//    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
//
//      //1.
//      isReceivingDrag = false
//      let pasteBoard = draggingInfo.draggingPasteboard
//
//      if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:filteringOptions) as? [URL], urls.count > 0 {
//        processImageURLs(urls)
//        return true
//      }
//      else if let image = NSImage(pasteboard: pasteBoard) {
//        processImage(image)
//        return true
//      }
//
//      return false
//
//    }
    
    func processImageURLs(_ urls: [URL]) {
         
        
        for (_,url) in urls.enumerated() {
         
            if let image = NSImage(contentsOf:url) {
                processImage(image)
            }
          
        }
    
    }
    
    func processImage(_ image: NSImage) {
   
        
        self.image = image
   
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
        self.canvas?.selectView(self)
        self.superview?.bringSubviewToFront(self)
        
    }
    
    func select() {
        
        self.selected = true
    }
    
    
    func unselect() {
        
        self.selected = false
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
        
        // print("deltaX = \(deltaX) deltaY = \(deltaY)")
        
        switch cursorPosition {
        case .topLeft:
            if superView.frame.width / 3 ..< superView.frame.width ~= self.frame.size.width - deltaX,
               superView.frame.height / 3 ..< superView.frame.height ~= self.frame.size.height - deltaY,
               self.frame.origin.x + deltaX >= superView.frame.minX,
               self.frame.origin.y + self.frame.height - deltaY <= superView.frame.maxY {
                                
                self.frame.size.width -= deltaX
                
                self.frame.size.height -= deltaY
                
                self.frame.origin.x += deltaX
                
            }
        case .bottomLeft:
            if superView.frame.width / 3 ..< superView.frame.width ~= self.frame.size.width - deltaX,
               superView.frame.height / 3 ..< superView.frame.height ~= self.frame.size.height + deltaY,
               self.frame.origin.x + deltaX >= superView.frame.minX,
               self.frame.origin.y - deltaY >= superView.frame.minY {
                
                self.frame.origin.x += deltaX
                
                self.frame.origin.y -= deltaY
                
                self.frame.size.width -= deltaX
                
                self.frame.size.height += deltaY
                
            }
        case .topRight:
            if superView.frame.width / 3 ..< superView.frame.width ~= self.frame.size.width + deltaX,
               superView.frame.height / 3 ..< superView.frame.height ~= self.frame.size.height - deltaY,
               self.frame.origin.x + self.frame.width + deltaX <= superView.frame.maxX,
               self.frame.origin.y + self.frame.height - deltaY <= superView.frame.maxY {
                
                self.frame.size.width += deltaX
                
                self.frame.size.height -= deltaY
                
            }
        case  .bottomRight:
            if superView.frame.width / 3 ..< superView.frame.width ~= self.frame.size.width + deltaX,
               superView.frame.height / 3 ..< superView.frame.height ~= self.frame.size.height + deltaY,
               self.frame.origin.x + self.frame.width + deltaX <= superView.frame.maxX,
               self.frame.origin.y - deltaY >= superView.frame.minY {
                
                self.frame.origin.y -= deltaY
                
                self.frame.size.width += deltaX
                
                self.frame.size.height += deltaY
                
            }
        case .top:
            if superView.frame.height / 3 ..< superView.frame.height ~= self.frame.size.height - deltaY,
               self.frame.origin.y + self.frame.height - deltaY <= superView.frame.maxY {
                self.frame.size.height -= deltaY
            }
        case .bottom:
            if superView.frame.height / 3 ..< superView.frame.height ~= self.frame.size.height + deltaY,
               self.frame.origin.y - deltaY >= superView.frame.minY {
                self.frame.size.height += deltaY
                self.frame.origin.y -= deltaY
            }
        case .left:
            if superView.frame.width / 3 ..< superView.frame.width ~= self.frame.size.width - deltaX,
               self.frame.origin.x + deltaX >= superView.frame.minX {
                self.frame.size.width -= deltaX
                self.frame.origin.x += deltaX
            }
        case .right:
            if superView.frame.width / 3 ..< superView.frame.width ~= self.frame.size.width + deltaX,
               self.frame.origin.x + self.frame.size.width + deltaX <= superView.frame.maxX {
                self.frame.size.width += deltaX
            }
        case .none:
            self.frame.origin.x += deltaX
            self.frame.origin.y -= deltaY
        }
        
        self.repositionView()
        
    }
    
    override func keyDown(with event: NSEvent) {
        
        // print("Key Down: \(event.keyCode)")
        
        if event.keyCode == 51 {
            
            // print("delete")
            self.removeFromSuperview()
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
    
    func setAsBackground() {
        
        print("Fill background")
        
        if let canvas = self.canvas {
            
            canvas.setAsBackground(self)
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
