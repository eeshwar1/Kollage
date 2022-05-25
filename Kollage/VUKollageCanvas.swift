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
    
    enum Appearance {
      static let lineWidth: CGFloat = 10.0
    }
    
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
      // else if let types = pasteBoard.types, nonURLTypes.intersection(types).count > 0
      
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
      
      //2.
      let point = convert(draggingInfo.draggingLocation, from: nil)
      //3.
      if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:filteringOptions) as? [URL], urls.count > 0 {
        delegate?.processImageURLs(urls, center: point)
        return true
      }
      else if let image = NSImage(pasteboard: pasteBoard) {
        delegate?.processImage(image, center: point)
        return true
      }
    
      return false
      
    }
    
    
}
