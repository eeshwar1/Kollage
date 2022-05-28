//
//  ViewController.swift
//  Kollage
//
//  Created by Venky Venkatakrishnan on 9/9/19.
//  Copyright © 2019 Venky UL. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSFontChanging {
    
  
    @IBOutlet weak var kollageCanvas: NSView!
    
    @IBOutlet weak var buttonDragMode: NSButton!
    
    @IBOutlet weak var gridView: NSView!
    
    var imageViews: [VUDraggableImageView] = []
    
    var dragMode: DraggingType = .contents
    
    let itemWidth: CGFloat = 200
    let itemHeight: CGFloat = 100
    
    var center = NSPoint.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()

        setupGridView()
        
    }

    
    func setupView() {
        
        
        let bounds = self.view.bounds
        let origin = bounds.origin
        
        center = NSPoint(x: origin.x + bounds.width / 4, y: origin.y + bounds.height / 4)
        

    }
    
    override func keyDown(with event: NSEvent) {

        kollageCanvas.keyDown(with: event)

    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        return true
    }

    override var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
    
//    func addImages() {
//
//
//        for _ in 1...10 {
//
//                   let newCenter = center.addRandomNoise(100)
//                   let newImageView =  VUDraggableImageView(frame: NSRect(x: newCenter.x, y: newCenter.y, width: itemWidth, height: itemHeight))
//                   newImageView.image = NSImage(named: "Pookkalam") ?? NSImage()
//                    newImageView.draggingType = .frame
//
//                   kollageCanvas.addSubview(newImageView)
//
//               }
//    }
    
    func setupGridView()
    {
        // print("Setup Grid View")
        
        let storyboard = NSStoryboard(name: "Main", bundle: Bundle.main)
        let gridController = storyboard.instantiateController(withIdentifier: "KollageGridController") as! KollageGridController
        
        self.addChild(gridController)
        gridController.view.frame = self.gridView.frame
        
        self.gridView.addSubview(gridController.view)
   
    }
    
   
    
    // MARK: - Actions
    
    @IBAction func addText(_ sender: NSButton) {
       
        if let canvas = kollageCanvas as? VUKollageCanvas {
            canvas.addText()
        }
    }
    
    @IBAction func selectFont(_ sender: NSButton) {
       
        print("select font")
        
        NSFontManager.shared.orderFrontFontPanel(nil)
    }
    
    func changeFont(_ sender: NSFontManager?) {
    
        guard let fontManager = sender else {
            return
        }
        let newFont = fontManager.convert(NSFont.systemFont(ofSize: 14))
        
        print("New font: \(String(describing: newFont.displayName))")
        
        if let canvas = self.kollageCanvas as? VUKollageCanvas {
            
            canvas.changeFont(newFont)
        }
    }
   

}



