import Cocoa

class VUDraggableTextView: DraggableResizableView {
    
    var canvas: VUKollageCanvas?
    
    var textField: NSTextField = NSTextField()
    
    var minimumWidth: CGFloat = 200
    var minimumHeight: CGFloat = 50
    
    override var acceptsFirstResponder: Bool { return true }
    
    override var canBecomeKeyView: Bool { return true }
    
    var selected: Bool = false {
         didSet {
             
             if selected {
                 self.layer?.borderColor = .init(red: 0, green: 255, blue: 0, alpha: 1.0)
                 self.layer?.borderWidth = 2.0
             } else {
                 
                 self.layer?.borderWidth = 0.0
             }
             needsDisplay = true
         }
     }
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect)
        
        self.layer?.borderWidth = 2.0
        
       
        let recognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(rotateAction))
        
        self.addGestureRecognizer(recognizer)
        
        self.textField.stringValue = "Sample Text"

        setupTextField()
        
        self.frame.size = self.fittingSize
    }
    
    init(text: String) {
        
        super.init(frame: NSRect(x: 0, y: 0, width: 200, height: 200))
        
        self.textField.stringValue = text
        
        setupTextField()
    }
    
    func setupTextField() {
    
        self.addSubview(self.textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let centerYConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let centerXConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        
        let leftConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: self, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 20)
        let rightConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: self, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 20)
        
        let topConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: self, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 10)
        
        let bottomConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 10)
        
        bottomConstraint.priority = .dragThatCanResizeWindow
        rightConstraint.priority = .dragThatCanResizeWindow
        
        self.addConstraint(centerXConstraint)
        self.addConstraint(centerYConstraint)
        self.addConstraint(leftConstraint)
        self.addConstraint(rightConstraint)
        self.addConstraint(topConstraint)
        self.addConstraint(bottomConstraint)
        
        
    }
    
    
    @objc func rotateAction(gestureRecognizer: NSRotationGestureRecognizer) {
        
        print("Rotated")
    }
    
    required init?(coder decoder: NSCoder) {
        
        super.init(coder: decoder)
    }
    
    func select() {
        
        self.selected = true
    }
    
    func unselect() {
        
        self.selected = false
    }
 
    func changeFont(_ font: NSFont) {
        
        self.textField.font = font
        self.textField.sizeToFit()
        self.frame.size = self.fittingSize
        
    }
    
    override func mouseUp(with event: NSEvent) {
                
        selected = true
        self.canvas?.selectView(self)
      
        
    }
    
    @objc func sendToBack(_ sender: NSMenuItem) {
        
   
        self.superview?.sendSubviewToBack(self)
        
    }
    
    @objc func bringToFront(_ sender: NSMenuItem) {
        
        self.superview?.bringSubviewToFront(self)
        
    }
    
    @objc func sendBackward(_ sender: NSMenuItem) {
        
        self.superview?.sendSubviewBackward(self)
        
    }
    
    @objc func bringForward(_ sender: NSMenuItem) {
        
        
        self.superview?.bringSubviewForward(self)
        
    }
    
    override func rightMouseDown(with event: NSEvent) {
        
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(withTitle: "Bring to Front", action: #selector(bringToFront(_:)), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Bring Forward", action: #selector(bringForward(_:)), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Send Backward", action: #selector(sendBackward(_:)), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Send to Back", action: #selector(sendToBack(_:)), keyEquivalent: "").target = self
      
        self.menu = menu
        
        let eventLocation = event.locationInWindow
        menu.popUp(positioning: nil, at: self.convert(eventLocation, from: nil), in: self)
        
    }
    
    override func keyDown(with event: NSEvent) {
        
        if event.keyCode == 51 {
        
            self.removeFromSuperview()
            
        } else {
            
            self.textField.keyDown(with: event)
            
        }
    }
    
    func scale(factor: Double) {
        
        
        let width = self.frame.width
        let height = self.frame.height
        
        var newWidth = width * factor
        var newHeight = height * factor
        
        newWidth = newWidth < minimumWidth ? minimumWidth: newWidth
        newHeight = newHeight < minimumHeight ? minimumHeight: newHeight
        
        self.setFrameSize(.init(width:  newWidth, height: newHeight))
        
        print("Scale: \(factor) (\(width), \(height)) -> (\(newWidth), \(newHeight))")
        
        
    }
    
    override func rotate(byDegrees angle: CGFloat) {
        
        self.frameCenterRotation = angle
        
        
    }

    
}


