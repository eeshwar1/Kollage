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
    
   override var image: NSImage? {
        didSet {
            
            if let image = image {
                
                let maxDimension: CGFloat = 300
                self.frame.size = image.sizeForMaxDimention(maxDimension)
               
                needsDisplay = true
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
        self.layer?.borderWidth = 2
        self.layer?.borderColor = NSColor.gray.cgColor
        
        
    }
    override func mouseDown(with event: NSEvent) {
        
        if draggingType == .contents {
         let pasteboardItem =  NSPasteboardItem()
          pasteboardItem.setDataProvider(self, forTypes: [kUTTypeTIFF as NSPasteboard.PasteboardType])
          
          let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)
        
          draggingItem.setDraggingFrame(self.bounds, contents: snapshot())
          
          beginDraggingSession(with: [draggingItem], event: event, source: self)
        }
        else
        {
            firstMouseDownPoint = (self.window?.contentView?.convert(event.locationInWindow, to: self))!
        }
        
    }
 
    override func mouseDragged(with event: NSEvent) {
        
        if self.draggingType == .frame {
            let newPoint = (self.window?.contentView?.convert(event.locationInWindow, to: self))!
            let offset = NSPoint(x: newPoint.x - firstMouseDownPoint.x, y: newPoint.y - firstMouseDownPoint.y)
            
            let origin = self.frame.origin
            let size = self.frame.size
            
            self.frame = NSRect(x: origin.x + offset.x, y: origin.y + offset.y, width: size.width, height: size.height)
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
