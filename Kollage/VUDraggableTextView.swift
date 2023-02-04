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
        
        let textField = NSTextField(labelWithAttributedString:  NSAttributedString(string: "Hello World"))

        
        textField.frame.size = self.frame.size
        textField.sizeToFit()
        
        let recognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(rotateAction))
        
        self.addGestureRecognizer(recognizer)

        self.textField = textField
        
        self.addSubview(self.textField!)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let centerYConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let centerXConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        
        let leftConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: self, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 20)
//        let rightConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: self, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 20)
        
        let topConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: self, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 10)
        
//        let bottomConstraint: NSLayoutConstraint = NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 10)
        
       // bottomConstraint.priority = .dragThatCanResizeWindow
       // rightConstraint.priority = .dragThatCanResizeWindow
        
        self.addConstraint(centerXConstraint)
        self.addConstraint(centerYConstraint)
        self.addConstraint(leftConstraint)
       // self.addConstraint(rightConstraint)
        self.addConstraint(topConstraint)
      //  self.addConstraint(bottomConstraint)
        
        self.frame.size = self.fittingSize
        
        
    }
    
    @objc func rotateAction(gestureRecognizer: NSRotationGestureRecognizer) {
        
        print("Rotated")
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        self.superview?.bringSubviewToFront(self)
        
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


