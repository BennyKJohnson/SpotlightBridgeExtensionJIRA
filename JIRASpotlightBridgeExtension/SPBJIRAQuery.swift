//
//  SPBJIRAQuery.swift
//  JIRASpotlightBridgeExtension
//
//  Created by Benjamin Johnson on 13/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation
import SpotlightBridge
import JiraKit

@objc public class SPBJIRAQuery: SPBQuery {
    
    var completionHandler:((SPBResponse?) -> Void)?
    
    public override func perform(_ userQueryString: String!, withCompletionHandler completionHandler: ((SPBResponse?) -> Void)!) {
        self.completionHandler = completionHandler
        SPBJiraManager.shared.findMatchingIssues(for: userQueryString, completionHandler: self.handleResponse)
    }
    
    func handleResponse(issues: [JIRAIssue]) {
        let rankedIssues = self.rankIssues(userQueryString: userQueryString, issues: issues)
        let results = self.searchResults(for: rankedIssues)
        
        if (results.isEmpty) {
            completionHandler!(nil)
            return
        }
        
        completionHandler!(self.response(for: results))
    }
    
    func rankIssues(userQueryString:String, issues: [JIRAIssue]) -> [JIRAIssue] {
        if (self.queryLooksLikeIssueId(query: userQueryString)) {
            // Only compare the string distance of issue id
            return issues.sorted(by: { (issueA, issueB) -> Bool in
                userQueryString.distance(between: issueA.issueID) > userQueryString.distance(between: issueB.issueID)
            })
        } else {
            return issues
        }
    }
    
    func queryLooksLikeIssueId(query: String) -> Bool {
        return Int(query) != nil
    }
    
    func response(for results: [SPBJIRASearchResult]) -> SPBResponse {
        if (results.count == 1) {
            results.first!.topHit = true
        }
        
        let resultSection = SPBResultSection(title: "JIRA")
        
        resultSection.bundleIdentifier = "com.apple.calculator"
        resultSection.results = results
        
        let response = SPBResponse()
        response.sections = [resultSection]
        response.topHitIsIn = true
        
        return response
    }
    
    func searchResults(for issues: [JIRAIssue]) -> [SPBJIRASearchResult] {
        return issues.map { (issue) -> SPBJIRASearchResult in
            return SPBJIRASearchResult(issue: issue, issueUpdater: SPBJiraManager.shared)
        }
    }
}

