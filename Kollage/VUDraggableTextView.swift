import Cocoa

class VUDraggableTextView: DraggableResizableView {
    
    var canvas: VUKollageCanvas?
    
    var textField: NSTextField?
    
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
        
        let textField = NSTextField(labelWithAttributedString: NSAttributedString(string: "Hello World"))
        
        self.textField = textField
        self.addSubview(self.textField!)
        
        
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
    }
    
    override func mouseUp(with event: NSEvent) {
                
        selected = true
        self.canvas?.selectView(self)
        self.superview?.bringSubviewToFront(self)
        
    }
    
    

}


