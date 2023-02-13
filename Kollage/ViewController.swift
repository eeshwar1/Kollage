//
//  ViewController.swift
//  Kollage
//
//  Created by Venky Venkatakrishnan on 9/9/19.
//  Copyright © 2019 Venky UL. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSFontChanging {
    
    @IBOutlet weak var kollageEasel: VUKollageEasel!
    
    @IBOutlet weak var canvasSizeButton: NSPopUpButton!
    @IBOutlet weak var backgroundColorWell: NSColorWell!
    
    // Image Controls
    @IBOutlet weak var effectsButton: NSPopUpButton!
    @IBOutlet weak var rotateSlider: NSSlider!
    @IBOutlet weak var labelRotationAngle: NSTextField!
    
    @IBOutlet weak var resizeSlider: NSSlider!
    @IBOutlet weak var labelSizeFactor: NSTextField!
  
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    @IBOutlet weak var labelStatus: NSTextField!
    
    @IBOutlet weak var gridView: NSView!
    
    var imageViews: [VUDraggableImageView] = []
    
    var dragMode: DraggingType = .contents
    
    let itemWidth: CGFloat = 200
    let itemHeight: CGFloat = 100
    
    var center = NSPoint.zero
    
    override func viewWillAppear() {
        
      
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupView()
        
        disableImageControls()
      
        self.kollageEasel.vc = self
        
        spinner.isHidden = true
        labelStatus.stringValue = "Ready"
        
        backgroundColorWell.color = self.kollageEasel.getBackgroundColor()
        
    }
    
    
    func setupView() {
        
        let bounds = self.view.bounds
        let origin = bounds.origin
        
        center = NSPoint(x: origin.x + bounds.width / 4, y: origin.y + bounds.height / 4)
        
        
    }
    
//    override func keyDown(with event: NSEvent) {
//
//       // kollageCanvas.keyDown(with: event)
//
//    }
    
//    override func performKeyEquivalent(with event: NSEvent) -> Bool {
//        return true
//    }
    
    override var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
    
    
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
        
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let addTextWindowController = storyboard.instantiateController(withIdentifier: "Add Text Window Controller") as! NSWindowController
        
        if let addTextWindow = addTextWindowController.window {
            let application = NSApplication.shared
            application.runModal(for: addTextWindow)
            
            addTextWindow.close()
        }
        
        
        
    }
    
    @IBAction func selectFont(_ sender: NSButton) {
        
        print("select font")
        
        NSFontManager.shared.setSelectedAttributes([NSAttributedString.Key.foregroundColor.rawValue: NSColor.red], isMultiple: false)
        
        NSFontManager.shared.orderFrontFontPanel(nil)
    }
    
    // MARK: Actions
    
    @IBAction func canvasSizeChanged(_ sender: NSPopUpButton) {
        
        let selectedItem  = sender.itemArray[sender.indexOfSelectedItem].title
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        // print("Canvas size changed to \(selectedItem)")
        
        if selectedItem == "800x600" {
            width = 800
            height = 600
        } else if selectedItem == "1024x768" {
            
            width =  1024
            height = 768
        } else {
            
            width = 500
            height = 500
            
        }
        
        self.kollageEasel.setCanvasSize(size: .init(width: width, height: height))
        
    
    }
    
    @IBAction func imageEffectChanged(_ sender: NSPopUpButton) {
        
        guard self.kollageEasel.hasItemsSelected() else { return }
        
        let selectedItem  = sender.itemArray[sender.indexOfSelectedItem].title
            
        DispatchQueue.main.async {
            
            self.kollageEasel.applyEffect(effect: selectedItem)
            
            self.labelStatus.stringValue = "Ready"
            self.labelStatus.textColor = NSColor.textColor
                
            
            self.spinner.stopAnimation(nil)
            self.spinner.isHidden = true
            
        }
        
        self.spinner.isHidden = false
        self.spinner.startAnimation(nil)
        self.labelStatus.stringValue = "Applying effects..."
        
        
        
    }
    
    
    @IBAction func sizeSliderChanged(_ sender: NSSlider) {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        
        self.kollageEasel.scaleSelectedView(factor: sender.doubleValue)
        self.labelSizeFactor.stringValue = numberFormatter.string(from: NSNumber(value:sender.doubleValue))!
    
    }
    
    @IBAction func rotationSliderChanged(_ sender: NSSlider) {
        
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        
        self.kollageEasel.rotateSelectedView(angle: sender.doubleValue)
        self.labelRotationAngle.stringValue = numberFormatter.string(from: NSNumber(value:sender.doubleValue))!
        
    }

        
    @IBAction func exportKollage(_ sender: NSButton)  {
            
            
        if self.kollageEasel.kollageCanvas.subviews.count > 0 {
            
            let savePanel = NSSavePanel()
            savePanel.canCreateDirectories = true
            savePanel.showsTagField = false
            savePanel.nameFieldStringValue = "Kollage.png"
            savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
            
            
            let result = savePanel.runModal()
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue  {
                
                if let fileUrl = savePanel.url {
                    
                    
                    DispatchQueue.main.async {
                        let kollage = self.kollageEasel.createKollage()
                        
                        if kollage.pngWrite(to: fileUrl, options: .atomic) {
                            
                            self.labelStatus.stringValue = "Kollage exported successfully"
                            self.labelStatus.textColor = NSColor.textColor
                            
                        } else {
                            
                            self.labelStatus.stringValue = "Error saving kollage"
                            self.labelStatus.textColor = .red
                        }
                        self.spinner.stopAnimation(nil)
                        self.spinner.isHidden = true
                        
                    }
                    
                    
                    self.spinner.isHidden = false
                    self.spinner.startAnimation(nil)
                    self.labelStatus.stringValue = "Exporting..."
                    
                    
                }
            }
            
        } else {
            
            self.labelStatus.stringValue = "Nothing to export"
        }
            
        
    }
    
    @IBAction func backgroundColorChanged(_ sender: NSColorWell) {
        
        self.kollageEasel.setBackground(color: sender.color)
        
    }
    
    @IBAction func pickBackgroundImage(_ sender: NSButton) {
   
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.allowedFileTypes = ["png", "jpg", "jpeg", "gif"]
        
        let response = openPanel.runModal()
        
        if response == .OK {
            
            if let url =  openPanel.url {
                
                self.kollageEasel.kollageBackground.setBackground(image: NSImage(contentsOf: url) ?? NSImage())
            }
        }
        
    }
    
    @IBAction func addImages(_ sender: Any) {
        
       addPhotos()
        
    }
    
   
    
    func addPhotos() {
        
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = false
        openPanel.allowedFileTypes = ["png", "jpg", "jpeg", "gif"]
        
        let response = openPanel.runModal()
        
        if response == .OK {
                            
            self.kollageEasel.addImages(openPanel.urls)
            
        }
    }
    
    func enableImageControls(factor: Double, angle: Double) {
        
        self.resizeSlider.isEnabled = true
        self.resizeSlider.doubleValue = factor
        self.labelSizeFactor.doubleValue = factor
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        
        self.labelSizeFactor.stringValue = numberFormatter.string(from: NSNumber(value: factor))!
        
        self.rotateSlider.isEnabled = true
        self.rotateSlider.doubleValue = angle
        self.labelRotationAngle.doubleValue = angle
        
        self.labelRotationAngle.stringValue = numberFormatter.string(from: NSNumber(value: angle))!
        
        self.effectsButton.isEnabled = true
    }
    
    func disableImageControls() {
        
        self.resizeSlider.isEnabled = false
        self.resizeSlider.doubleValue = 0
        self.labelSizeFactor.doubleValue = 0
        
        self.labelSizeFactor.stringValue = ""
        
        self.rotateSlider.isEnabled = false
        self.rotateSlider.doubleValue = 0
        self.labelRotationAngle.doubleValue = 0
        
        self.labelRotationAngle.stringValue = ""
        
        self.effectsButton.isEnabled = false
    }
    
    func setStatus(message: String) {
        
        self.labelStatus.stringValue = message
    }
    @IBAction func canvasZoomIn(_ sender: Any) {
        
        self.kollageEasel.zoomIn()
        
        
    }
    
    @IBAction func canvasZoomOut(_ sender: Any) {
        
        self.kollageEasel.zoomOut()
        
    }
    
    @IBAction func canvasZoomToFit(_ sender: Any) {
        
        self.kollageEasel.zoomToFit()
    
        
    }
    
    @IBAction override func selectAll(_ sender: (Any)?) {
        
        
        self.kollageEasel.selectAllViews()
        
    }
    
    @IBAction func selectNone(_ sender: Any) {
        
        self.kollageEasel.unselectAllViews()
        
    }
    
    
}
