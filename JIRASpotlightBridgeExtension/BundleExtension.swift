//
//  BundleExtension.swift
//  JIRASpotlightBridgeExtension
//
//  Created by Benjamin Johnson on 13/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation


extension Bundle {
    class func primary() -> Bundle {
        return Bundle(identifier: "benjamin.spotlightbridge.JIRASpotlightBridgeExtension")!
    }
    
}
