//
//  JiraManager.swift
//  JIRASpotlightBridgeExtension
//
//  Created by Benjamin Johnson on 23/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation
import JIRAServices

class SPBJiraManager {
    
    static let shared = SPBJiraManager.defaultManager()
    
    let session: JiraSession
    
    var issues: [JIRAIssue]?
    
    static func defaultManager() -> SPBJiraManager {
        guard let configurationURL = Bundle(identifier: "benjamin.spotlightbridge.JIRASpotlightBridgeExtension")?.url(forResource: "jiraconfig", withExtension: "json") else {
            fatalError("Failed to find jiraconfig.json in bundle")
        }
        
        let configuration = JiraSessionConfiguration.fromFile(for: configurationURL)!
        return SPBJiraManager(configuation: configuration)
    }
    
    init(configuation: JiraSessionConfiguration) {
        session = JiraSession(configuration: configuation)
    }
    
    func fetchIssues(completionHandler: @escaping ([JIRAIssue]) -> ()) {
        if let issues = issues {
            print(issues)
            completionHandler(issues)
            return
        }
        
        session.fetchIssues { (issues) in
            let sortedIssues = issues.sorted(by: { (issueA, issueB) -> Bool in
                return issueA.key.compare(issueB.key) == .orderedAscending
            })
            self.issues = sortedIssues
            completionHandler(sortedIssues)
        }
    }
    
    func findMatchingIssues(for query: String, completionHandler: @escaping ([JIRAIssue]) -> ()) {
        fetchIssues { (issues) in
            let filteredIssues = self.filter(query: query, issues: issues)
            completionHandler(filteredIssues)
        }
    }
    
    func filter(query: String, issues: [JIRAIssue]) -> [JIRAIssue] {
        return issues.filter { (issue) -> Bool in
            let issueKey = issue.key
            return issueKey.lowercased().starts(with: query.lowercased()) || issueKey.lowercased() == query.lowercased() || issueKey.contains(query)
        }
    }
    
}
