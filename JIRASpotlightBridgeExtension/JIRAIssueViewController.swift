//
//  JIRAIssueViewController.swift
//  JIRASpotlightBridgeExtension
//
//  Created by Benjamin Johnson on 13/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Cocoa
import SpotlightBridge
import JiraKit

class JIRAIssueViewController: SPBPreviewController {
    
    static let shared = JIRAIssueViewController()

    @IBOutlet weak var titleLabel: NSTextField!
    
    @IBOutlet weak var descriptionLabel: NSTextField!
    
    @IBOutlet weak var loggedTimeLabel: NSTextField!
    
    @IBOutlet weak var attributesView: NSStackView!
    
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
        self.descriptionLabel.stringValue = issue.issueDescription ?? ""
        
        self.attributesView.setViews(createAttributesRows(issue: issue), in: .center)
    }
    
    func createAttributesRows(issue: JIRAIssue) -> [NSView] {
        let attributes = getAttributes(issue: issue)
        let attributeRows = attributes.map { (attribute) -> NSView in
            return createAttributeRow(attribute: attribute)
        }

        return attributeRows
    }
    
    func getAttributes(issue: JIRAIssue) -> [Attribute] {
        var attributes: [Attribute] = []
        if let timeSpent = issue.timeSpent, let formattedTime = timeFormatter.string(from: timeSpent)  {
            attributes.append(Attribute(key: "Logged Time", value: formattedTime))
        }
        
        if let assignee = issue.assignee {
            if let avartarUrl = assignee.avatarURL {
                attributes.append(Attribute(key: "Assignee", value: assignee.name, type: .avartar(url: avartarUrl)))
            } else {
                attributes.append(Attribute(key: "Assignee", value: assignee.name))
            }
        }

        return attributes
    }
    
    func createAttributeRow(attribute: Attribute) -> NSView {
        let labelTextField = NSTextField(labelWithString: attribute.key)
        labelTextField.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
        labelTextField.alignment = .right
        let valueTextField = NSTextField(labelWithString: attribute.value)

        var stackView: NSStackView
        switch attribute.type {
        case .avartar(let url):
            if let avartar = NSImage(contentsOf: url) {
                let avartarStackView = NSStackView(views: [createAvartarView(avartar: avartar), valueTextField])
                stackView = NSStackView(views: [labelTextField, avartarStackView])
            } else {
                stackView = NSStackView(views: [labelTextField, valueTextField])
            }
            
        case .text:
            stackView = NSStackView(views: [labelTextField, valueTextField])
        }
        
        stackView.orientation = .horizontal
        
        return stackView
    }
    
    func createAvartarView(avartar: NSImage) -> CircularImageView {
        let avartarView = CircularImageView(image: avartar)
        avartarView.widthAnchor.constraint(equalToConstant: 18.0).isActive = true
        avartarView.heightAnchor.constraint(equalToConstant: 18.0).isActive = true
        
        return avartarView
    }
}
