//
//  Attribute.swift
//  JIRASpotlightBridgeExtension
//
//  Created by Benjamin Johnson on 5/9/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation

enum AttributeType {
    case text
    case avartar(url: URL)
    case status
}

struct Attribute {
    let key: String
    let value: String
    let type: AttributeType
    
    init(key: String, value: String, type: AttributeType = .text) {
        self.key = key
        self.value = value
        self.type = type
    }
}
