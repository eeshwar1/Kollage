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
    
    var editMode = false
    
    var textView: VUDraggableTextView?
    
    var vc: ViewController?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        textField.stringValue = "Hello"
        
        print("Edit mode: \(self.editMode.description)")
        
       
        
    }
    
    override func viewWillAppear() {
        
        if editMode {
            
            print("Edit mode")
            
            if let textView = self.textView {
                
                textField.stringValue = textView.getText().string
            }
        }
    }
    
    @IBAction func dismissAddTextWindow(_ sender: NSButton) {
        
        let application = NSApplication.shared
        application.stopModal()
        
        if editMode {
            
            if let textView = self.textView {
                
                let attributedString = NSAttributedString(string: textField.stringValue, attributes: [NSAttributedString.Key.font: NSFont(name: "menlo", size: 20) as Any])
                
                textView.setText(text: attributedString )
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
        
        NSFontManager.shared.orderFrontFontPanel(nil)
        
    }
    
}
