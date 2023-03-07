//
//  TextViewController.swift
//  Kollage
//
//  Created by Venkateswaran Venkatakrishnan on 2/5/23.
//  Copyright © 2023 Venky UL. All rights reserved.
//

import Cocoa

class TextViewController: NSViewController {
    
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var textPreview: NSTextField!
    
    var editMode = false
    
    var textView: VUDraggableTextView?
    
    var vc: ViewController?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("Edit mode: \(self.editMode.description)")
        
        textField.delegate = self
        
       
    }
    
    override func viewWillAppear() {
        
        if editMode {
            
            print("Edit mode")
            
            self.view.window?.title = "Edit Text"
            if let textView = self.textView {
                
                textField.stringValue = textView.getText().string
                
                textPreview.attributedStringValue = textView.getText()
            }
        }
    }
    
    @IBAction func dismissAddTextWindow(_ sender: NSButton) {
        
        let application = NSApplication.shared
        application.stopModal()
        
        if editMode {
            
            if let textView = self.textView {
                
                let attributedString = NSAttributedString(string: textField.stringValue, attributes: [NSAttributedString.Key.font: NSFont(name: "menlo", size: 20) as Any])
                
                textView.setText(text: attributedString)
            }
                
            
        } else {
            
            if let vc = self.vc {
                
                 
                vc.processAddText(text: textField.stringValue)
            
                
            }
        }
    }
    
    @IBAction func cancelAddText(_ sender: NSButton) {
        
        let application = NSApplication.shared
        application.stopModal()
        
    }
    
    @IBAction func selectFont(_ sender: NSButton) {
        
        print("select font")
        
        NSFontManager.shared.setSelectedAttributes([NSAttributedString.Key.foregroundColor.rawValue: NSColor.red], isMultiple: false)
        
        NSFontManager.shared.orderFrontFontPanel(self)
        
        if let selectedFont = NSFontManager.shared.selectedFont {
            
            print("\(String(describing: selectedFont.familyName))")
        }
        
       
    }
    
    @IBAction func textFieldChanged(_ sender: NSTextField) {
        
        
    }
    
}

extension TextViewController:  NSTextFieldDelegate {
    
    func controlTextDidEndEditing(_ obj: Notification) {
        
        textPreview.attributedStringValue = NSAttributedString(string: textField.stringValue, attributes: [NSAttributedString.Key.font: NSFont(name: "menlo", size: 20) as Any])
        
    }
    
    func controlTextDidChange(_ obj: Notification) {
        
        textPreview.attributedStringValue = NSAttributedString(string: textField.stringValue, attributes: [NSAttributedString.Key.font: NSFont(name: "menlo", size: 20) as Any])
        
    }
}
