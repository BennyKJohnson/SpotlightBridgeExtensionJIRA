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
    
    var searchResult: SPBJIRASearchResult?
    
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
        clearPreviousSearchResultDelegate()
        
        let issueSearchResult = result as! SPBJIRASearchResult
        issueSearchResult.resultUpdaterDelegate = self
        
        display(issue: issueSearchResult.issue)
    
        if !issueSearchResult.hasCompleteIssue {
            issueSearchResult.fetchIssueDetails()
        }
    }
    
    func clearPreviousSearchResultDelegate() {
        if let searchResult = searchResult {
            searchResult.resultUpdaterDelegate = nil
        }
    }
    
    func display(issue: JIRAIssue) {
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
        
        
        if let status = issue.status {
            attributes.append(Attribute(key: "Status", value: status , type: .status))
        }
        
        if let assignee = issue.assignee {
            if let avartarUrl = assignee.avatarURL {
                attributes.append(Attribute(key: "Assignee", value: assignee.name, type: .avartar(url: avartarUrl)))
            } else {
                attributes.append(Attribute(key: "Assignee", value: assignee.name))
            }
        }
        
        if let timeSpent = issue.timeSpent, timeSpent > 0, var formattedTime = timeFormatter.string(from: timeSpent)  {
            // Remove trailing period if present, not sure if this is a bug or poor configuration of the time formatter
            if let lastChar = formattedTime.last, lastChar == "." {
                formattedTime.removeLast()
            }
            attributes.append(Attribute(key: "Logged Time", value: formattedTime))
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
        case .status:
            let statusLabel = setupStatusLabel(text: attribute.value)
            stackView = NSStackView(views: [labelTextField, statusLabel])
        }
        
        stackView.orientation = .horizontal
        
        return stackView
    }
    
    
    func setupStatusLabel(text: String) -> NSTextField {
        let statusLabel = JiraStatusLabel(labelWithString: text)
        statusLabel.wantsLayer = true
        statusLabel.textColor = NSColor.white
        
        let placeholderAttributes: [NSAttributedString.Key: AnyObject] = [
            NSAttributedString.Key.foregroundColor: NSColor.white,
            NSAttributedString.Key.baselineOffset: NSNumber(value: 4.0)
        ]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 24.0
        paragraphStyle.maximumLineHeight = 24.0
        
        let placeholderAttributedString = NSMutableAttributedString(string: text, attributes: placeholderAttributes)
        placeholderAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0,length: placeholderAttributedString.length))
        statusLabel.attributedStringValue = placeholderAttributedString
        
        statusLabel.heightAnchor.constraint(equalToConstant: 30.0)
        statusLabel.backgroundColor = NSColor.blue
        statusLabel.alignment = .center
        return statusLabel
    }
    
    func createAvartarView(avartar: NSImage) -> CircularImageView {
        let avartarView = CircularImageView(image: avartar)
        avartarView.widthAnchor.constraint(equalToConstant: 18.0).isActive = true
        avartarView.heightAnchor.constraint(equalToConstant: 18.0).isActive = true
        
        return avartarView
    }
}

extension JIRAIssueViewController: SPBJiraSearchResultUpdaterDelegate {
    
    func didUpdateResult(searchResult: SPBJIRASearchResult) {
        DispatchQueue.main.async {
            self.display(issue: searchResult.issue)
        }
    }

}
