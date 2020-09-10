//
//  SPBJIRAResult.swift
//  JIRASpotlightBridgeExtension
//
//  Created by Benjamin Johnson on 13/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import SpotlightBridge
import JiraKit
import Cocoa

protocol SPBJiraSearchResultUpdaterDelegate {
    
    func didUpdateResult(searchResult: SPBJIRASearchResult)
}

class SPBJIRASearchResult: SPBSearchResult {
    public var topHit: Bool = false
    
    var issue: JIRAIssue
    
    let issueUpdater: SPBJiraIssueUpdater
    
    var hasCompleteIssue: Bool = false
    
    var resultUpdaterDelegate: SPBJiraSearchResultUpdaterDelegate?
    
    init(issue: JIRAIssue, issueUpdater: SPBJiraIssueUpdater) {
        self.issue = issue
        self.issueUpdater = issueUpdater

        super.init(displayName: issue.key)
    }
    
    override func iconImage() -> NSImage {
        return Bundle.primary().image(forResource: "favicon.png")!
    }
    
    override func iconImageForApplication() -> NSImage {
        let appURL = NSWorkspace.shared.urlForApplication(toOpen: URL(string: "https://jira.atlassian.com")!)
        return NSWorkspace.shared.icon(forFile: appURL!.path)
    }
    
    override func isTopHit() -> Bool {
        return topHit;
    }
    
    override func score() -> Float {
        return 100
    }
    
    override func open(withSearch searchString: String) -> Bool {
        if let url = issue.url {
            NSWorkspace.shared.open(url)
        }
        
        return true
    }
    
    override func previewViewController() -> NSViewController {
        return JIRAIssueViewController.shared
    }
    
    func fetchIssueDetails() {
        self.issueUpdater.fetchIssueDetails(issue: issue) { (issue) in
            guard let issue = issue else {
                self.hasCompleteIssue = true
                return
            }
            
            self.issue = issue
            self.hasCompleteIssue = true
            
            self.resultUpdaterDelegate?.didUpdateResult(searchResult: self)
        }
    }
}
