//
//  JiraStatusLabel.swift
//  JIRASpotlightBridgeExtension
//
//  Created by Benjamin Johnson on 6/9/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Cocoa

class JiraStatusLabel: NSTextField {
    
    override func layout() {
        super.layout()
        
        self.layer?.cornerRadius = 5
        self.layer?.backgroundColor = NSColor.blue.cgColor
        

    }
}
