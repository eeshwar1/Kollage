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
        
        buttonDragMode.title = "Drag Contents"
        
        for item in 1...5 {
            
            let newImageView =  VUDraggableImageView(frame: NSRect(x: 20 + 20 * item, y: 20 + 20 * item, width: 200, height: 200))
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
            buttonDragMode.title = "Drag Frame"
        }
        else
        {
            dragMode = .contents
            buttonDragMode.title = "Drag Contents"
        }
        
        for view in kollageCanvas.subviews {
            
            if let draggingView = view as? VUDraggableImageView {
                draggingView.draggingType = dragMode
            }
        }
    }


}

