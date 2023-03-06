import Cocoa

class VUDraggableTextView: VUDraggableResizableView {
    
    var canvas: VUKollageCanvas?
    
    var textField: NSTextField = NSTextField()
    
    var minimumWidth: CGFloat = 200
    var minimumHeight: CGFloat = 50
    
    override var acceptsFirstResponder: Bool { return true }
    
    override var canBecomeKeyView: Bool { return true }
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect)
        
        setupView()
    }

    init(location: NSPoint, text: String) {
        
        super.init(frame: NSRect(x: location.x, y: location.y, width: 100, height: 100))
        
        let attributedString = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: NSFont(name: "menlo", size: 15) as Any])
    
        self.textField.attributedStringValue = attributedString
        
        setupView()
        
        self.frame.size = self.fittingSize

    }
    
    func setupView() {
        
        self.layer?.borderWidth = 1.0
        
        self.layer?.borderColor = .black
        
        let recognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(rotateAction))
        
        self.addGestureRecognizer(recognizer)

        setupTextField()
        
    
    }
    
    func setupTextField() {
    
        self.textField.sizeToFit()
        self.textField.isEditable = false
        self.textField.isBordered = false
        self.addSubview(self.textField)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let centerYConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let centerXConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        
        let leftConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 20)
        
        let rightConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 20)
        
        let topConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 20)
        
        let bottomConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 20)
        
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
    
    func getText() -> NSAttributedString {
        
        return self.textField.attributedStringValue
    }
    
    func setText(text: NSAttributedString)  {
        
        let attributedString = NSMutableAttributedString(string: self.textField.attributedStringValue.string)
        
        attributedString.setAttributedString(text)
        
        self.textField.attributedStringValue = attributedString
        
        self.textField.sizeToFit()
        self.frame.size = self.fittingSize
        
        self.needsDisplay =  true
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
        
        let unselectOther = event.modifierFlags.contains(.shift)
        
        self.canvas?.selectView(self, unselectOther: !unselectOther)

        
    }
    
    override func mouseDown(with event: NSEvent) {
        
        if (event.clickCount == 2) {
            
            print("Double Click")
            
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            let textWindowController = storyboard.instantiateController(withIdentifier: "Text Window Controller") as! NSWindowController
            
            if let textVC = textWindowController.contentViewController as? TextViewController {
                print("Setting text field values in VC")
                textVC.editMode = true
                textVC.textView = self
            }
            
            if let textWindow = textWindowController.window {
                
                let application = NSApplication.shared
                application.runModal(for: textWindow)
                
                textWindow.close()
            }
            
        }
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


