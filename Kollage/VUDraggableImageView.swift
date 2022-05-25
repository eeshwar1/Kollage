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
            
            if let _image = image {
               
                let maxDimension: CGFloat =  CGFloat.maximum(self.frame.size.height, self.frame.size.width)
                self.frame.size = _image.sizeForMaxDimention(maxDimension)
               
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
        self.layer?.borderWidth = 1
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
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
      let allow = shouldAllowDrag(sender)
      isReceivingDrag = allow
      return allow ? .copy : NSDragOperation()
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
      let allow = shouldAllowDrag(sender)
      return allow
    }
    
    
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
      
      //1.
      isReceivingDrag = false
      let pasteBoard = draggingInfo.draggingPasteboard
      
      if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:filteringOptions) as? [URL], urls.count > 0 {
        processImageURLs(urls)
        return true
      }
      else if let image = NSImage(pasteboard: pasteBoard) {
        processImage(image)
        return true
      }
    
      return false
      
    }
    
    func processImageURLs(_ urls: [URL]) {
         
        print("processImageURLs")
        
        for (_,url) in urls.enumerated() {
         
            if let image = NSImage(contentsOf:url) {
                processImage(image)
            }
          
        }
    
    }
    
    func processImage(_ image: NSImage) {
        
        print("processImage")
        
        self.image = image
   
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
