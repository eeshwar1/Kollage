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
        
    }
    
    override func viewWillAppear() {
        
        if editMode {
            
            self.view.window?.title = "Edit Text"
            if let textView = self.textView {
                
                textField.stringValue = textView.getText().string
                
                textPreview.attributedStringValue = textView.getText()
                
                
            }
            
            
        }
        
        let fontManager = NSFontManager.shared
        
        self.buttonFontFamily.removeAllItems()
        
        for (_, family) in fontManager.availableFontFamilies.enumerated() {
            
            self.buttonFontFamily.addItem(withTitle: family.description)
        }
        
        self.buttonFontFamily.selectItem(at: 4)
        
        if let selectedFamily = self.buttonFontFamily.selectedItem {
            
            print("Selected Font Family: \(selectedFamily.title)")
            populateTypeFaces(fontFamily: selectedFamily.title)
        }
        
        self.font =  NSFont(name: self.buttonFontFamily.title, size: 20) ?? NSFont.systemFont(ofSize: 20)
        
    }
    
    func populateTypeFaces(fontFamily: String) {
        
        let fontManager = NSFontManager.shared
        
        self.buttonTypeFace.removeAllItems()
        
        if let fonts = fontManager.availableMembers(ofFontFamily: fontFamily) {
             
            for (_, font) in fonts.enumerated() {
                
                self.buttonTypeFace.addItem(withTitle: "\(font[1])")
            }
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
            
            print("Selected Font Family: \(selectedFamily.title)")
            populateTypeFaces(fontFamily: selectedFamily.title)
            
            self.font =  NSFont(name: self.buttonFontFamily.title, size: 20) ?? NSFont.systemFont(ofSize: 20)
            
            
        }
        
    }
    
}

extension TextViewController:  NSTextFieldDelegate {
    
    func controlTextDidEndEditing(_ obj: Notification) {
        
        textPreview.attributedStringValue = textField.attributedStringValue
    }
    
    func controlTextDidChange(_ obj: Notification) {
        
        textPreview.attributedStringValue = textField.attributedStringValue
        
    }
}


