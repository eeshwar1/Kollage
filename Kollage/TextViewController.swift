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
                
                textField.attributedStringValue = textView.getText()
                
                textPreview.attributedStringValue = textView.getText()
            }
            
            
        }
        
        let fontManager = NSFontManager.shared
        
        for (_, family) in fontManager.availableFontFamilies.enumerated() {
            
            print("\(family.description)")
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
                
                let attributedText = textField.attributedStringValue
                
                textView.setText(attributedText: attributedText)
            }
                
            
        } else {
            
            if let vc = self.vc {
                
                vc.processAddText(attributedText: textField.attributedStringValue)
            
            }
        }
    }
    
    @IBAction func cancelAddText(_ sender: NSButton) {
        
        let application = NSApplication.shared
        application.stopModal()
        
    }
    
    @IBAction func selectFont(_ sender: NSButton) {
        
        if NSFontPanel.shared.isVisible {
            NSFontPanel.shared.orderOut(nil)
            return
        }
        
        NSFontPanel.shared.setPanelFont(self.font, isMultiple: false)
        NSFontPanel.shared.makeKeyAndOrderFront(nil)
        NSFontManager.shared.target = self
        
    }
    
    func changeFont(_ sender: NSFontManager?) {
        
        print("Change Font")
        guard let fontManager = sender else { return }
        
        let newFont = fontManager.convert(self.font)
        
        print("Font selected: \(String(describing: newFont.description))")
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


