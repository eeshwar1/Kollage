//
//  ViewController.swift
//  Kollage
//
//  Created by Venky Venkatakrishnan on 9/9/19.
//  Copyright © 2019 Venky UL. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSFontChanging {
    
    
    @IBOutlet weak var kollageBackground: VUKollageBackground!
    @IBOutlet weak var kollageCanvas: NSView!
    
    @IBOutlet weak var rotateSlider: NSSlider!
    @IBOutlet weak var resizeSlider: NSSlider!
    
    @IBOutlet weak var completeImage: NSImageView!
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    @IBOutlet weak var labelStatus: NSTextField!
    
    @IBOutlet weak var gridView: NSView!
    
    var imageViews: [VUDraggableImageView] = []
    
    var dragMode: DraggingType = .contents
    
    let itemWidth: CGFloat = 200
    let itemHeight: CGFloat = 100
    
    var center = NSPoint.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        self.resizeSlider.isEnabled = false
        self.rotateSlider.isEnabled = false
        
        if let canvas = self.kollageCanvas as? VUKollageCanvas {
            
            canvas.vc = self
        }
        
        spinner.isHidden = true
        completeImage.isHidden = true
        labelStatus.stringValue = "Ready"
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
    
    //    func setupGridView()
    //    {
    //        // print("Setup Grid View")
    //
    //        let storyboard = NSStoryboard(name: "Main", bundle: Bundle.main)
    //        let gridController = storyboard.instantiateController(withIdentifier: "KollageGridController") as! KollageGridController
    //
    //        self.addChild(gridController)
    //        gridController.view.frame = self.gridView.frame
    //
    //        self.gridView.addSubview(gridController.view)
    //
    //    }
    
    
    
    // MARK: - Actions
    
    @IBAction func addText(_ sender: NSButton) {
        
        if let canvas = kollageCanvas as? VUKollageCanvas {
            canvas.addText()
        }
    }
    
    @IBAction func selectFont(_ sender: NSButton) {
        
        print("select font")
        
        NSFontManager.shared.setSelectedAttributes([NSAttributedString.Key.foregroundColor.rawValue: NSColor.red], isMultiple: false)
        
        NSFontManager.shared.orderFrontFontPanel(nil)
    }
    
    func changeFont(_ sender: NSFontManager?) {
        
        guard let fontManager = sender else {
            return
        }
        
        
        let newFont = fontManager.convert(NSFont.systemFont(ofSize: 14))
        
        if let canvas = self.kollageCanvas as? VUKollageCanvas {
            
            canvas.changeFont(newFont)
        }
    }
    
    @IBAction func setAsBackground(_ sender: NSButton) {
        
        if let canvas = self.kollageCanvas as? VUKollageCanvas {
            
            if let imageView = canvas.selectedView as? VUDraggableImageView, let image = imageView.image {
                
                self.kollageBackground.setBackground(image: image)
                imageView.removeFromSuperview()
                
            }
        }
        
        
    }
    
    
    @IBAction func sizeSliderChanged(_ sender: NSSlider) {
        
        
        if let canvas = self.kollageCanvas as? VUKollageCanvas {
            
            if let imageView = canvas.selectedView as? VUDraggableImageView {
                
                imageView.scale(factor: sender.doubleValue)
                
            } else if let textView = canvas.selectedView as? VUDraggableTextView {
                
                textView.scale(factor: sender.doubleValue)
            }
            
        }
        
        
    }
    
    @IBAction func rotationSliderChanged(_ sender: NSSlider) {
        
        
        if let canvas = self.kollageCanvas as? VUKollageCanvas {
            
            if let imageView = canvas.selectedView as? VUDraggableImageView {
                
                imageView.rotate(angle: sender.doubleValue)
            } else if let textView = canvas.selectedView as? VUDraggableTextView {
                
                
                textView.rotate(byDegrees: sender.doubleValue)
            }
            
            
        }
        
    }

        
    @IBAction func exportImage(_ sender: NSButton) {
    
                
        let kollage = self.createKollage()
        
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "Kollage.png"
        savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
        
            
        let result = savePanel.runModal()
        if result.rawValue == NSApplication.ModalResponse.OK.rawValue  {
                
            if let fileUrl = savePanel.url {
            
                self.spinner.isHidden = false
                self.spinner.startAnimation(nil)
                self.labelStatus.stringValue = "Exporting..."
                if kollage.pngWrite(to: fileUrl, options: .withoutOverwriting) {
                    
                    print("File saved")
                    
                } else {
                    
                    print("Error saving kollage")
                }
                    self.spinner.stopAnimation(nil)
                    self.spinner.isHidden = true
                    self.completeImage.isHidden = false
                    self.labelStatus.stringValue = "Ready"
                }
            }
        
        
    }
    
    @IBAction func backgroundColorChanged(_ sender: NSColorWell) {
        
        self.kollageBackground.setBackground(color: sender.color)
        
    }
    
    @IBAction func pickBackgroundImage(_ sender: NSButton) {
        
        print("Pick background image")
        
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.allowedFileTypes = ["png", "jpg", "jpeg", "gif"]
        
        let response = openPanel.runModal()
        
        if response == .OK {
            
            if let url =  openPanel.url {
                
                self.kollageBackground.setBackground(image: NSImage(contentsOf: url) ?? NSImage())
            }
        }
        
    }
    
    @IBAction func addImages(_ sender: NSButton) {
        
        print("Pick background image")
        
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = false
        openPanel.allowedFileTypes = ["png", "jpg", "jpeg", "gif"]
        
        let response = openPanel.runModal()
        
        if response == .OK {
                            
            if let canvas = kollageCanvas as? VUKollageCanvas {
                
                canvas.addImages(openPanel.urls)
            }
            
        }
        
    }
    
    func createKollage() -> NSImage {
        
        var kollage = NSImage()
        
        if let canvas = self.kollageCanvas as? VUKollageCanvas {
            
            kollage = NSImage(size: canvas.frame.size)
            
            if let backgroundView = self.kollageBackground {
                
                if let backgroundImage = backgroundView.backgroundImage {
                    
                    kollage = backgroundImage.resize(withSize: canvas.frame.size) ?? NSImage()
                } else {
                    
                    kollage = backgroundView.getImage()
                }
                
            } else {
                
                kollage = NSImage()
            }
            
            for view in canvas.subviews
            {
                if let imageView = view as? VUDraggableImageView {
                    
                    if let image = imageView.image {
                        
                        let rotImage = image.rotated(by: imageView.frameCenterRotation)
                        let resizedImage = rotImage.resize(withSize: imageView.frame.size)
                        kollage = kollage.addImage(image: resizedImage ?? NSImage(), position: imageView.frame.origin)
                    }
                    
                }
                
            }
            
        }
        
        return kollage
        
    }
    
    func enableImageControls() {
        
        self.resizeSlider.isEnabled = true
        self.rotateSlider.isEnabled = true
    }
    
    
}
