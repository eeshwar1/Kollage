//
//  ViewController.swift
//  Kollage
//
//  Created by Venky Venkatakrishnan on 9/9/19.
//  Copyright © 2019 Venky UL. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var kollageCanvas: NSView!
    
    @IBOutlet weak var buttonDragMode: NSButton!
    
    var imageViews: [VUDraggableImageView] = []
    
    var dragMode: DraggingType = .contents

    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonDragMode.title = "Drag Frame"
        
        
        let itemWidth: CGFloat = 200
        let itemHeight: CGFloat = 100
        
        let bounds = self.view.bounds
        let origin = bounds.origin
        let center = NSPoint(x: origin.x + bounds.width / 4, y: origin.y + bounds.height / 4)
        
        for _ in 1...10 {
            
            let newCenter = center.addRandomNoise(100)
            let newImageView =  VUDraggableImageView(frame: NSRect(x: newCenter.x, y: newCenter.y, width: itemWidth, height: itemHeight))
            newImageView.image = NSImage(named: "Pookkalam") ?? NSImage()
            newImageView.draggingType = .contents
         
            kollageCanvas.addSubview(newImageView)
            
        }
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: - Actions
    
    @IBAction func buttondragModeClicked(_ sender: NSButton) {
        
        if dragMode == .contents
        {
            dragMode = .frame
            buttonDragMode.title = "Drag Contents"
        }
        else
        {
            dragMode = .contents
            buttonDragMode.title = "Drag Frame"
        }
        
        for view in kollageCanvas.subviews {
            
            if let draggingView = view as? VUDraggableImageView {
                draggingView.draggingType = dragMode
            }
        }
    }


}

