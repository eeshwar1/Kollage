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
            }
            
            
        }
        
        let fontManager = NSFontManager.shared
        
        self.buttonFontFamily.removeAllItems()
        
        for (_, family) in fontManager.availableFontFamilies.enumerated() {
            
            self.buttonFontFamily.addItem(withTitle: family.description)
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
    }
    @IBAction func dismissAddTextWindow(_ sender: NSButton) {
        
        let application = NSApplication.shared
        application.stopModal()
        
        if editMode {
            
            if let textView = self.textView {
                
                let attributedText = NSAttributedString(string: textField.stringValue, attributes: [NSAttributedString.Key.font: self.font])
                
                textView.setText(attributedText: attributedText)
            }
                
            
        } else {
            
            if let vc = self.vc {
                
                let attributedText = NSAttributedString(string: textField.stringValue, attributes: [NSAttributedString.Key.font: self.font])
                
                vc.processAddText(attributedText: attributedText)
            
            }
        }
    }
    
    @IBAction func cancelAddText(_ sender: NSButton) {
        
        let application = NSApplication.shared
        application.stopModal()
        
    }
    
    
    @IBAction func fontFamilyChanged(_ sender: NSPopUpButton) {
        
        
        if let selectedFamily = self.buttonFontFamily.selectedItem {
            
            
            self.font =  NSFont(name: selectedFamily.title, size: 20) ?? NSFont.systemFont(ofSize: 20)
            
            populateTypeFaces(fontFamily: selectedFamily.title)
            
            let attributedString = NSMutableAttributedString(string: self.textField.stringValue)
            
            attributedString.setAttributes([.font: self.font], range: NSRange(0..<attributedString.length))
            
            self.textPreview.attributedStringValue = attributedString
            
            
        }
        
    }
    
    @IBAction func typeFaceChanged(_ sender: NSPopUpButton) {
        
        if let selectedTypeFace = self.buttonTypeFace.selectedItem, let selectedFamily = self.buttonFontFamily.selectedItem {
            
            print("Before Type Face change: \(self.font.fontDescriptor)")
            
            let fontDescriptor = self.font.fontDescriptor.withFamily(selectedFamily.title).withFace(selectedTypeFace.title)
    
            print("fontDescriptor description: \(fontDescriptor.description)")
            print("fontDescriptor fontAttributes: \(fontDescriptor.fontAttributes)")
            
            self.font = NSFont(descriptor: fontDescriptor, size: 20) ?? NSFont.systemFont(ofSize: 20)
            
            let attributedString = NSMutableAttributedString(string: self.textField.stringValue)
            
            attributedString.setAttributes([.font: self.font], range: NSRange(0..<attributedString.length))
            
            self.textPreview.attributedStringValue = attributedString
            
            print("After Type Face change: \(self.font.fontDescriptor)")
            
            
        }
        
    }
    
    func fontSizeChanged() {
        
        
    }
    
    func setTextPreview() {
        
        let attributedString = NSMutableAttributedString(string: self.textField.stringValue)
        
        attributedString.setAttributes([.font: self.font], range: NSRange(0..<attributedString.length))
        
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


