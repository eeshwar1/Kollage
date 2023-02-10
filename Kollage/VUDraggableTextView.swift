import Cocoa

class VUDraggableTextView: DraggableResizableView {
    
    var canvas: VUKollageCanvas?
    
    var textField: NSTextField?
    
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

        setupTextField()
        
        self.frame.size = self.fittingSize
    }
    
    func setupTextField() {
        
        let textField = NSTextField(labelWithAttributedString:  NSAttributedString(string: "Hello World"))

        
        textField.frame.size = self.frame.size
        textField.sizeToFit()
        
        self.textField = textField
        
        self.addSubview(self.textField!)
        
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
    
    func setText(text: String) {
        
        if let textField = self.textField {
            
            textField.stringValue = text
        }
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
        
        self.textField?.font = font
        self.textField?.sizeToFit()
        self.frame.size = self.fittingSize
        
    }
    
    override func mouseUp(with event: NSEvent) {
                
        selected = true
        self.canvas?.selectView(self)
      
        
    }
    
    @objc func sendToBack(_ sender: NSMenuItem) {
        
        print("Send to back")
        self.superview?.sendSubviewToBack(self)
        
    }
    
    @objc func bringToFront(_ sender: NSMenuItem) {
        
        print("Bring to front")
        self.superview?.bringSubviewToFront(self)
        
    }
    
    override func rightMouseDown(with event: NSEvent) {
        
        // print("right click")
        
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(withTitle: "Send to Back", action: #selector(sendToBack(_:)), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Bring to Front", action: #selector(bringToFront(_:)), keyEquivalent: "").target = self
        self.menu = menu
        
        let eventLocation = event.locationInWindow
        menu.popUp(positioning: nil, at: self.convert(eventLocation, from: nil), in: self)
        
    }
    
    override func keyDown(with event: NSEvent) {
        
        if event.keyCode == 51 {
        
            self.removeFromSuperview()
            
        } else {
            
            self.textField?.keyDown(with: event)
            
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


