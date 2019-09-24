//
//  VUDraggableImageView.swift
//  Kollage
//
//  Created by Venky Venkatakrishnan on 9/22/19.
//  Copyright © 2019 Venky UL. All rights reserved.
//

import Cocoa

class VUDraggableImageView: NSImageView {
    
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect)
       
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
      
    }
    
    override func mouseDown(with event: NSEvent) {
        
            let pasteboardItem =  NSPasteboardItem()
          pasteboardItem.setDataProvider(self, forTypes: [kUTTypeTIFF as NSPasteboard.PasteboardType])
          
          let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)
        
          draggingItem.setDraggingFrame(self.bounds, contents: snapshot())
          
          beginDraggingSession(with: [draggingItem], event: event, source: self)
        
    }
 
}



extension VUDraggableImageView: NSDraggingSource {
    
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .generic
    }
    
 
    
    
}

extension VUDraggableImageView: NSPasteboardItemDataProvider {
    
    func pasteboard(_ pasteboard: NSPasteboard?, item: NSPasteboardItem, provideDataForType type: NSPasteboard.PasteboardType) {
        
        if let pasteboard = pasteboard, type == NSPasteboard.PasteboardType(kUTTypeTIFF as String), let image = self.image {
            let tiffData  = image.tiffRepresentation
          pasteboard.setData(tiffData, forType: type)
        }
    }
    
    
    
}
