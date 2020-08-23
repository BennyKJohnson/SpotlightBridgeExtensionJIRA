//
//  SPBJIRAResult.swift
//  JIRASpotlightBridgeExtension
//
//  Created by Benjamin Johnson on 13/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import SpotlightBridge
import JIRAServices
import Cocoa

class SPBJIRASearchResult: SPBSearchResult {
    public var topHit: Bool = false
    
    let issue: JIRAIssue
    
    init(issue: JIRAIssue) {
        self.issue = issue

        super.init(displayName: issue.key)
    }
    
    override func iconImage() -> NSImage {
        return Bundle.primary().image(forResource: "favicon.png")!
    }
    
    override func iconImageForApplication() -> NSImage {
        return NSWorkspace.shared.icon(forFile: "/Applications/Safari.app")
    }
    
    override func isTopHit() -> Bool {
        return topHit;
    }
    
    override func score() -> Float {
        return 100
    }
    
    override func open(withSearch searchString: String) -> Bool {
        if let domain = issue.domain {
            NSWorkspace.shared.open(URL(string: "https://\(domain)/browse/\(issue.key)")!)
        }
        
        return true
    }
    
    override func previewViewController() -> NSViewController {
        return JIRAIssueViewController.shared
    }
}
