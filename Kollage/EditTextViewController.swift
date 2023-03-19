//
//  EditTextViewController.swift
//  Kollage
//
//  Created by Venkateswaran Venkatakrishnan on 3/5/23.
//  Copyright © 2023 Venky UL. All rights reserved.
//

import Cocoa

class EditTextViewController: NSViewController {
    
    @IBOutlet weak var textField: NSTextField!
    
    var vc: ViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func dismissAddTextWindow(_ sender: NSButton) {
        
        let application = NSApplication.shared
        application.stopModal()
        
        if let vc = self.vc {
            
            vc.processAddText(text: textField.stringValue)
        }
    }
    
    @IBAction func cancelAddText(_ sender: NSButton) {
        
        let application = NSApplication.shared
        application.stopModal()
        
    }
    
    
}
