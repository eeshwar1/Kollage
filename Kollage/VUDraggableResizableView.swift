import Cocoa

enum ShadowType: String {
    
    case leftTop = "Left Top"
    case leftBottom = "Left Bottom"
    case rightTop = "Right Top"
    case rightBottom = "Right Bottom"
    case none = "None"
    
    init(name: String) {
        
        switch name.lowercased() {
            
        case "left top":
            self = .leftTop
        case "left bottom":
            self = .leftBottom
        case "right top":
            self = .rightTop
        case "right bottom":
            self = .rightBottom
        case "none":
            self = .none
        default:
            self = .none
        }
    }
    
    var description: String {
        
        return self.rawValue
    }
}

class VUDraggableResizableView: NSView {
    
    let resizableArea: CGFloat = 5
    
    var selected: Bool = false {
        
        didSet {
            
            needsDisplay = true
            
        }
    }
    var selectionMarkLineWidth: CGFloat = 5.0
    var selectionLineWidth: CGFloat = 2.0
    
    var cursorPosition: CornerBorderPosition = .none {
        didSet {
            switch self.cursorPosition {
            case .bottomRight, .topLeft:
                NSCursor(image:
                            NSImage(byReferencingFile: "/System/Library/Frameworks/WebKit.framework/Versions/Current/Frameworks/WebCore.framework/Resources/northWestSouthEastResizeCursor.png")!,
                         hotSpot: NSPoint(x: 8, y: 8)).set()
            case .bottomLeft, .topRight:
                NSCursor(image:
                            NSImage(byReferencingFile: "/System/Library/Frameworks/WebKit.framework/Versions/A/Frameworks/WebCore.framework/Versions/A/Resources/northEastSouthWestResizeCursor.png")!,
                         hotSpot: NSPoint(x: 8, y: 8)).set()
            case .top, .bottom:
                NSCursor.resizeUpDown.set()
            case .left, .right:
                NSCursor.resizeLeftRight.set()
            case .none:
                NSCursor.openHand.set()
            }
        }
    }
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect)
        
        self.frame = self.frame.insetBy(dx: -2, dy: -2)
        
        self.wantsLayer = true
        
    }
    
   
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        super.draw(dirtyRect)
        
        if selected {
            
            drawSelectionMarks()
            
        }
        
    }
    
    override func updateTrackingAreas() {
        
        super.updateTrackingAreas()
        
        trackingAreas.forEach({ removeTrackingArea($0) })

        addTrackingArea(NSTrackingArea(rect: self.bounds,
                                       options: [.mouseMoved,
                                                 .mouseEnteredAndExited,
                                                 .activeAlways],
                                       owner: self))
    }

    override func mouseExited(with event: NSEvent) {
        NSCursor.arrow.set()
    }
    
    override func mouseDown(with event: NSEvent) {
        
        let locationInView = convert(event.locationInWindow, from: nil)
        
        self.cursorPosition = self.cursorCornerBorderPosition(locationInView)
        
    }
    
    override func mouseUp(with event: NSEvent) {
        
        self.cursorPosition = .none
        self.selected = true
        
    }
    
    override func mouseMoved(with event: NSEvent) {
        
        let locationInView = convert(event.locationInWindow, from: nil)
        
        self.cursorPosition = self.cursorCornerBorderPosition(locationInView)
    }
    
    override func mouseDragged(with event: NSEvent) {
        
        guard let superView = superview else { print("returning")
            return }
        
        let deltaX = event.deltaX
        let deltaY = event.deltaY
        
        var frameWidth = self.frame.width
        var frameHeight = self.frame.height
        let aspectRatio = frameHeight/frameWidth
        
        switch cursorPosition {
        case .topLeft:
            if superView.frame.width / 3 ..< superView.frame.width ~= self.frame.size.width - deltaX,
               superView.frame.height / 3 ..< superView.frame.height ~= self.frame.size.height - deltaY,
               self.frame.origin.x + deltaX >= superView.frame.minX,
               self.frame.origin.y + self.frame.height - deltaY <= superView.frame.maxY {
                
                frameWidth -= deltaX
                
                frameHeight = aspectRatio * frameWidth
                
                self.frame.origin.x += deltaX
                
            }
        case .bottomLeft:
            if superView.frame.width / 3 ..< superView.frame.width ~= self.frame.size.width - deltaX,
               superView.frame.height / 3 ..< superView.frame.height ~= self.frame.size.height + deltaY,
               self.frame.origin.x + deltaX >= superView.frame.minX,
               self.frame.origin.y - deltaY >= superView.frame.minY {
                
                self.frame.origin.x += deltaX
                
                self.frame.origin.y -= deltaY
                
                frameWidth -= deltaX
                
                frameHeight = aspectRatio * frameWidth
                
            }
        case .topRight:
            if superView.frame.width / 3 ..< superView.frame.width ~= self.frame.size.width + deltaX,
               superView.frame.height / 3 ..< superView.frame.height ~= self.frame.size.height - deltaY,
               self.frame.origin.x + self.frame.width + deltaX <= superView.frame.maxX,
               self.frame.origin.y + self.frame.height - deltaY <= superView.frame.maxY {
                
                frameWidth += deltaX
                
                frameHeight = aspectRatio * frameWidth
                
            }
        case  .bottomRight:
            if superView.frame.width / 3 ..< superView.frame.width ~= self.frame.size.width + deltaX,
               superView.frame.height / 3 ..< superView.frame.height ~= self.frame.size.height + deltaY,
               self.frame.origin.x + self.frame.width + deltaX <= superView.frame.maxX,
               self.frame.origin.y - deltaY >= superView.frame.minY {
                
                self.frame.origin.y -= deltaY
                
                frameWidth += deltaX
                
                frameHeight = aspectRatio * frameWidth
                
            }
        case .top:
            if superView.frame.height / 3 ..< superView.frame.height ~= self.frame.size.height - deltaY,
               self.frame.origin.y + self.frame.height - deltaY <= superView.frame.maxY {
                frameHeight -= deltaY
                frameWidth = frameWidth / aspectRatio
            }
        case .bottom:
            if superView.frame.height / 3 ..< superView.frame.height ~= self.frame.size.height + deltaY,
               self.frame.origin.y - deltaY >= superView.frame.minY {
                frameHeight += deltaY
                frameWidth = frameWidth / aspectRatio
                self.frame.origin.y -= deltaY
            }
        case .left:
            if superView.frame.width / 3 ..< superView.frame.width ~= self.frame.size.width - deltaX,
               self.frame.origin.x + deltaX >= superView.frame.minX {
                frameWidth -= deltaX
                frameHeight = aspectRatio * frameWidth
                self.frame.origin.x += deltaX
            }
        case .right:
            if superView.frame.width / 3 ..< superView.frame.width ~= self.frame.size.width + deltaX,
               self.frame.origin.x + self.frame.size.width + deltaX <= superView.frame.maxX {
                frameWidth += deltaX
                frameHeight = aspectRatio * frameWidth
            }
        case .none:
            self.frame.origin.x += deltaX
            self.frame.origin.y -= deltaY
        }
        
        
        
        self.setFrameSize(.init(width: frameWidth, height: frameHeight))
    
        // TODO: Update Size slider here to reflect the new size of the frame
        
    }
    
    @discardableResult
    func cursorCornerBorderPosition(_ locationInView: CGPoint) -> CornerBorderPosition {
        
        if locationInView.x < resizableArea,
           locationInView.y < resizableArea {
            return .bottomLeft
        }
        if self.bounds.width - locationInView.x < resizableArea,
           locationInView.y < resizableArea {
            return .bottomRight
        }
        if locationInView.x < resizableArea,
           self.bounds.height - locationInView.y < resizableArea {
            return .topLeft
        }
        if self.bounds.height - locationInView.y < resizableArea,
           self.bounds.width - locationInView.x < resizableArea {
            return .topRight
        }
        if locationInView.x < resizableArea {
            return .left
        }
        if self.bounds.width - locationInView.x < resizableArea {
            return .right
        }
        if locationInView.y < resizableArea {
            return .bottom
        }
        if self.bounds.height - locationInView.y < resizableArea {
            return .top
        }
        
        return .none
    }
    
    private func repositionView() {
        
        guard let superView = superview else { return }
        
        if self.frame.minX < superView.frame.minX {
            self.frame.origin.x = superView.frame.minX
        }
        if self.frame.minY < superView.frame.minY {
            self.frame.origin.y = superView.frame.minY
        }
        
        if self.frame.maxX > superView.frame.maxX {
            self.frame.origin.x = superView.frame.maxX - self.frame.size.width
        }
        if self.frame.maxY > superView.frame.maxY {
            self.frame.origin.y = superView.frame.maxY - self.frame.size.height
        }
    }
    
    
    func drawSelectionMarks() {
        
        NSColor.controlAccentColor.setStroke()
        
        let boundaryPath = NSBezierPath.init(rect: self.bounds)
        boundaryPath.lineWidth = selectionLineWidth
        boundaryPath.stroke()
        
        let handlesPath = NSBezierPath()
        
        let rect = self.bounds
        
        let shorterDimension = CGFloat.minimum(rect.width, rect.height)
        let handleLength = shorterDimension / 5
        let halfHandleLength = handleLength / 2
        
        handlesPath.move(to: NSPoint(x: rect.minX, y: rect.minY + handleLength))
        handlesPath.line(to: NSPoint(x: rect.minX, y: rect.minY))
        handlesPath.line(to: NSPoint(x: rect.minX + handleLength, y: rect.minY))
        
        handlesPath.move(to: NSPoint(x: rect.midX - halfHandleLength, y: rect.minY))
        handlesPath.line(to: NSPoint(x: rect.midX + halfHandleLength, y: rect.minY))
        
        handlesPath.move(to: NSPoint(x: rect.maxX - handleLength, y: rect.minY))
        handlesPath.line(to: NSPoint(x: rect.maxX, y: rect.minY))
        handlesPath.line(to: NSPoint(x: rect.maxX, y: rect.minY + handleLength))
        
        handlesPath.move(to: NSPoint(x: rect.maxX, y: rect.midY - halfHandleLength))
        handlesPath.line(to: NSPoint(x: rect.maxX, y: rect.midY + halfHandleLength))
        
        handlesPath.move(to: NSPoint(x: rect.maxX, y: rect.maxY - handleLength))
        handlesPath.line(to: NSPoint(x: rect.maxX, y: rect.maxY))
        handlesPath.line(to: NSPoint(x: rect.maxX - handleLength, y: rect.maxY))
        
        handlesPath.move(to: NSPoint(x: rect.midX - halfHandleLength, y: rect.maxY))
        handlesPath.line(to: NSPoint(x: rect.midX + halfHandleLength, y: rect.maxY))
        
        handlesPath.move(to: NSPoint(x: rect.minX + handleLength, y: rect.maxY))
        handlesPath.line(to: NSPoint(x: rect.minX, y: rect.maxY))
        handlesPath.line(to: NSPoint(x: rect.minX, y: rect.maxY - handleLength))
        
        handlesPath.move(to: NSPoint(x: rect.minX, y: rect.midY - halfHandleLength))
        handlesPath.line(to: NSPoint(x: rect.minX, y: rect.midY + halfHandleLength))
        
        handlesPath.lineWidth = selectionMarkLineWidth
        handlesPath.stroke()
        
    }
}
