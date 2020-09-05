//
//  CircularImageView.swift
//  JIRASpotlightBridgeExtension
//
//  Created by Benjamin Johnson on 30/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Cocoa

class CircularImageView: NSImageView {
    override func layout() {
        super.layout()
        self.layer?.cornerRadius = self.frame.size.height / 2
    }
}
