//
//  AddTextViewController.swift
//  Kollage
//
//  Created by Venkateswaran Venkatakrishnan on 2/5/23.
//  Copyright © 2023 Venky UL. All rights reserved.
//

import Cocoa

class AddTextViewController: NSViewController {
    
    @IBOutlet weak var textField: NSTextField!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func dismissAddTextWindow(_ sender: NSButton) {
        
        let application = NSApplication.shared
        application.stopModal()
        print("Entered text is \(textField.stringValue)")
    }
    
    @IBAction func cancelAddText(_ sender: NSButton) {
        
        let application = NSApplication.shared
        application.stopModal()
        
    }
    
    @IBAction func testMenu(_ sender: Any) {
        
        print("from add text controller...")
    }
}
