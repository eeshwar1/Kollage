//
//  KollageGridController.swift
//  Kollage
//
//  Created by Venky Venkatakrishnan on 11/10/19.
//  Copyright © 2019 Venky UL. All rights reserved.
//

import AppKit

class KollageGridController: NSViewController {
    
    @IBOutlet weak var labelTitle: NSTextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("View Loaded")
        
        labelTitle.stringValue = "Hello World"
        
    
    }
}
        
