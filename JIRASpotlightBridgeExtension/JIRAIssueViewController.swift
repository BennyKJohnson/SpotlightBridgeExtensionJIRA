//
//  JIRAIssueViewController.swift
//  JIRASpotlightBridgeExtension
//
//  Created by Benjamin Johnson on 13/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Cocoa
import SpotlightBridge

class JIRAIssueViewController: SPBPreviewController {
    
    static let shared = JIRAIssueViewController()

    @IBOutlet weak var titleLabel: NSTextField!
    
    @IBOutlet weak var descriptionLabel: NSTextField!
    
    @IBOutlet weak var loggedTimeLabel: NSTextField!
    
    let timeFormatter: DateComponentsFormatter
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    init() {
        let bundle = Bundle.primary()
        timeFormatter = DateComponentsFormatter()
        timeFormatter.unitsStyle = .abbreviated
        timeFormatter.allowedUnits = [ .hour, .minute, .second]
        timeFormatter.zeroFormattingBehavior = [.dropAll]
        super.init(nibName: "JIRAIssueViewController", bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func display(_ result: SPBSearchResult) {
        let issueSearchResult = result as! SPBJIRASearchResult
        let issue = issueSearchResult.issue
        self.titleLabel.stringValue = issue.title
        self.descriptionLabel.stringValue = issue.description ?? ""
        if let timeSpent = issue.timeSpent {
            self.loggedTimeLabel.stringValue = timeFormatter.string(from: timeSpent) ?? "No time"
        }
    }
}
