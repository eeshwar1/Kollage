//
//  ViewController.swift
//  Kollage
//
//  Created by Venky Venkatakrishnan on 9/9/19.
//  Copyright © 2019 Venky UL. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    enum Appearance {
      static let maxStickerDimension: CGFloat = 150.0
      static let shadowOpacity: Float =  0.4
      static let shadowOffset: CGFloat = 4
      static let imageCompressionFactor = 1.0
      static let maxRotation: UInt32 = 12
      static let rotationOffset: CGFloat = 6
      static let randomNoise: UInt32 = 200
      static let numStars = 20
      static let maxStarSize: CGFloat = 30
      static let randonStarSizeChange: UInt32 = 25
      static let randomNoiseStar: UInt32 = 100
    }
    
    
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
        
        // addImages()

        setupGridView()
        
        if let canvas = kollageCanvas as? VUKollageCanvas {
            
            canvas.delegate = self
        }
    }

    
    func setupView() {
        
        buttonDragMode.title = "Drag Frame"
        
        let bounds = self.view.bounds
        let origin = bounds.origin
        
        center = NSPoint(x: origin.x + bounds.width / 4, y: origin.y + bounds.height / 4)
    }
    
    func addImages() {
        
        
        for _ in 1...10 {
                   
                   let newCenter = center.addRandomNoise(100)
                   let newImageView =  VUDraggableImageView(frame: NSRect(x: newCenter.x, y: newCenter.y, width: itemWidth, height: itemHeight))
                   newImageView.image = NSImage(named: "Pookkalam") ?? NSImage()
                   newImageView.draggingType = .contents
                
                   kollageCanvas.addSubview(newImageView)
                   
               }
    }
    
    func setupGridView()
    {
        print("Setup Grid View")
        
        let storyboard = NSStoryboard(name: "Main", bundle: Bundle.main)
        let gridController = storyboard.instantiateController(withIdentifier: "KollageGridController") as! KollageGridController
        
        self.addChild(gridController)
        gridController.view.frame = self.gridView.frame
        
        
        self.gridView.addSubview(gridController.view)
        self.gridView = gridController.view
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

extension ViewController: DestinationViewDelegate {
    
    func processImageURLs(_ urls: [URL], center: NSPoint) {
         
        print("processImageURLs")
        
        for (index,url) in urls.enumerated() {
          
          //1.
          if let image = NSImage(contentsOf:url) {
            
            var newCenter = center
            //2.
            if index > 0 {
              newCenter = center.addRandomNoise(Appearance.randomNoise)
            }
            
            //3.
            processImage(image, center: newCenter)
          }
        }
        
    }
    
    func processImage(_ image: NSImage, center: NSPoint) {
        
        print("processImage")
        
        //2.
        let constrainedSize = image.aspectFitSizeForMaxDimension(Appearance.maxStickerDimension)
        
        //3.
        let subview = VUDraggableImageView(frame:NSRect(x: center.x - constrainedSize.width/2, y: center.y - constrainedSize.height/2, width: constrainedSize.width, height: constrainedSize.height))
        subview.draggingType = dragMode
        subview.image = image
        kollageCanvas.addSubview(subview)
        
        //4.
        let maxrotation = CGFloat(arc4random_uniform(Appearance.maxRotation)) - Appearance.rotationOffset
        subview.frameCenterRotation = maxrotation
    }
    
    func processAction(_ action: String, center: NSPoint) {
         
    }
    
    
    
}

extension NSImage {
  
  /**
   Tint image with supplied color
   
   - parameter color: color to use as tint
   
   - returns: tinted image
   */
  func tintedImageWithColor(_ color: NSColor) -> NSImage {
    let newImage = NSImage(size: size)
    newImage.lockFocus()
    color.drawSwatch(in: NSRect(x: 0, y: 0, width: size.width, height: size.height))
    draw(at: NSZeroPoint, from: NSZeroRect, operation: .destinationIn, fraction: 1.0)
    newImage.unlockFocus()
    return newImage
  }
  
  /**
   Derives new size for an image constrained to a maximum dimension while keeping AR constant
   
   - parameter maxDimension: maximum horizontal or vertical dimension for new size
   
   - returns: new size
   */
  func aspectFitSizeForMaxDimension(_ maxDimension: CGFloat) -> NSSize {
    var width =  size.width
    var height = size.height
    if size.width > maxDimension || size.height > maxDimension {
      let aspectRatio = size.width/size.height
      width = aspectRatio > 0 ? maxDimension : maxDimension*aspectRatio
      height = aspectRatio < 0 ? maxDimension : maxDimension/aspectRatio
    }
    return NSSize(width: width, height: height)
  }
}
