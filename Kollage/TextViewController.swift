//
//  TextViewController.swift
//  Kollage
//
//  Created by Venkateswaran Venkatakrishnan on 2/5/23.
//  Copyright © 2023 Venky UL. All rights reserved.
//

import Cocoa

class TextViewController: NSViewController, NSFontChanging {
    
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var textPreview: NSTextField!
    
    @IBOutlet weak var buttonFontFamily: NSPopUpButton!
    @IBOutlet weak var buttonTypeFace: NSPopUpButton!
    
    @IBOutlet weak var textFontSize: NSTextField!
    
    @IBOutlet weak var fontColorWell: NSColorWell!
    
    var editMode = false
    
    var textView: VUDraggableTextView?

    var font = NSFont.systemFont(ofSize: 15)
    
    override var acceptsFirstResponder: Bool {
        get {
            
            return true
        }
    }
    
    var vc: ViewController?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        textField.delegate = self
        textFontSize.delegate = self
        
    }
    
    override func viewWillAppear() {
        
        if editMode {
            
            self.view.window?.title = "Edit Text"
            if let textView = self.textView {
                
                let attributedText = textView.getText()
                
                textField.stringValue = attributedText.string
                
                textPreview.attributedStringValue = attributedText
                
                attributedText.enumerateAttribute(.font, in: NSRange(0..<attributedText.length)) {
                    
                    value, range, stop in
                    
                    if let font = value as? NSFont {
                        
                        self.font = font
                        
                        print("From attributed text: \(String(describing: self.font.fontName))")
                    }
                  
                }
                
                attributedText.enumerateAttribute(.foregroundColor, in: NSRange(0..<attributedText.length)) {
                    
                    value, range, stop in
                    
                    if let color = value as? NSColor {
                        
                        self.fontColorWell.color = color
                        
                    }
                  
                }
            }
            
            
        }
        
        let fontManager = NSFontManager.shared
        
        self.buttonFontFamily.removeAllItems()
        
        for (_, family) in fontManager.availableFontFamilies.enumerated() {
            
            self.buttonFontFamily.addItem(withTitle: family.description)
            
            if let item = self.buttonFontFamily.item(withTitle: family.description) {
                
                let attributedString = NSMutableAttributedString(string: item.title)
                
                attributedString.setAttributes([.font: NSFont(name: family.description, size: 14) ?? NSFont.menuFont(ofSize: 14)], range: NSRange(0..<attributedString.length))
                
                item.attributedTitle = attributedString
                
            }
        }
        
    
        if editMode {
            
            if let fontFamily = self.font.familyName {

                self.buttonFontFamily.selectItem(withTitle: fontFamily)
                populateTypeFaces(fontFamily: fontFamily)
            }
            
            // Determine Font Type Face - this is almost a hack as there is no direct way to determine the type face from the font
            
            let nameParts = self.font.fontName.split(separator: "-")
            
            if nameParts.count > 1 {
                
                let typeFace = String(nameParts[nameParts.count - 1])
                print("determined type face is \(typeFace)")
                
                
                self.buttonTypeFace.selectItem(withTitle: typeFace)
                
                if let _  = self.buttonTypeFace.selectedItem {
                    // we were able to select an item
                }
                else {
                    self.buttonTypeFace.selectItem(at: 0)
                }
                
            } else {
                
                self.buttonTypeFace.selectItem(at: 0)
            }
            
            self.textFontSize.floatValue = Float(self.font.pointSize)
                    
            
        } else {
            
            self.buttonFontFamily.selectItem(at: 0)
            
            self.font =  NSFont(name: self.buttonFontFamily.title, size: 20) ?? NSFont.systemFont(ofSize: 20)
            
            if let selectedFamily = self.buttonFontFamily.selectedItem {

                // print("Selected Font Family: \(selectedFamily.title)")
                populateTypeFaces(fontFamily: selectedFamily.title)
            }
           
            self.textFontSize.floatValue = 20.0
            
        }
        
        
       
        
    }
    
    func populateTypeFaces(fontFamily: String) {
        
        let fontManager = NSFontManager.shared
        
        self.buttonTypeFace.removeAllItems()
        
        if let fonts = fontManager.availableMembers(ofFontFamily: fontFamily) {
             
            for (_, font) in fonts.enumerated() {
                
                self.buttonTypeFace.addItem(withTitle: "\(font[1])")
            }
            
            self.buttonTypeFace.selectItem(at: 0)
        }
        
    }
    override func viewWillDisappear() {
        
        // Hide the font panel if it is shown
        if NSFontPanel.shared.isVisible {
            NSFontPanel.shared.orderOut(nil)
            return
        }
        
        // Hide the Color panel if it is shown
        if NSColorPanel.shared.isVisible {
            
            NSColorPanel.shared.orderOut(nil)
        }
    }
    @IBAction func dismissAddTextWindow(_ sender: NSButton) {
        
        let application = NSApplication.shared
        application.stopModal()
        
        if editMode {
            
            if let textView = self.textView {
                
                textView.setText(attributedText: self.getAttributedString())
            }
                
            
        } else {
            
            if let vc = self.vc {
                
                vc.processAddText(attributedText: self.getAttributedString())
            
            }
        }
    }
    
    func getAttributedString() -> NSAttributedString {
        
        let attributedText = NSAttributedString(string: textField.stringValue, attributes: [NSAttributedString.Key.font: self.font, NSAttributedString.Key.foregroundColor: self.fontColorWell.color])
        
        return attributedText
    }
    
    @IBAction func cancelAddText(_ sender: NSButton) {
        
        let application = NSApplication.shared
        application.stopModal()
        
    }
    
    
    @IBAction func fontFamilyChanged(_ sender: NSPopUpButton) {
        
        
        if let selectedFamily = self.buttonFontFamily.selectedItem {
            
            
            let fontSize = CGFloat(self.textFontSize.floatValue)

            self.font =  NSFont(name: selectedFamily.title, size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
            
            populateTypeFaces(fontFamily: selectedFamily.title)
            
            setTextPreview()
            
            
        }
        
    }
    
    @IBAction func typeFaceChanged(_ sender: NSPopUpButton) {
        
        if let selectedTypeFace = self.buttonTypeFace.selectedItem, let selectedFamily = self.buttonFontFamily.selectedItem {
            
//            print("Before Type Face change: \(self.font.fontDescriptor)")
            
            let fontDescriptor = self.font.fontDescriptor.withFamily(selectedFamily.title).withFace(selectedTypeFace.title)
    
//            print("fontDescriptor description: \(fontDescriptor.description)")
//            print("fontDescriptor fontAttributes: \(fontDescriptor.fontAttributes)")
            
            let fontSize = CGFloat(self.textFontSize.floatValue)

            self.font = NSFont(descriptor: fontDescriptor, size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
            
            setTextPreview()
            
//            print("After Type Face change: \(self.font.fontDescriptor)")
            
            
        }
        
    }
    
    @IBAction func fontColorChanged(_ sender: NSColorWell) {
        
        
       setTextPreview()
        
    }
    
    func setTextPreview() {
        
        let attributedString = NSMutableAttributedString(string: self.textField.stringValue)
        
        attributedString.setAttributes([.font: self.font, NSAttributedString.Key.foregroundColor: self.fontColorWell.color ], range: NSRange(0..<attributedString.length))
        
        textPreview.attributedStringValue = attributedString
        
    }
}

extension TextViewController:  NSTextFieldDelegate {
    
    func controlTextDidEndEditing(_ obj: Notification) {
    
        if let textField =  obj.object as? NSTextField,
           textField == self.textFontSize {
            
            let fontDescriptor = self.font.fontDescriptor
            let fontSize = CGFloat(self.textFontSize.floatValue)
            
            self.font = NSFont(descriptor: fontDescriptor, size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
        }
        
        setTextPreview()
        
    }
    
    func controlTextDidChange(_ obj: Notification) {
        
        if let textField =  obj.object as? NSTextField,
           textField == self.textFontSize {
            
            let fontDescriptor = self.font.fontDescriptor
            let fontSize = CGFloat(self.textFontSize.floatValue)
            
            self.font = NSFont(descriptor: fontDescriptor, size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
        }
        
        setTextPreview()
        
    }
}


