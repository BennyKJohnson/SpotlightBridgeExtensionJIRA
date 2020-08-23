//
//  SPBJIRAQuery.swift
//  JIRASpotlightBridgeExtension
//
//  Created by Benjamin Johnson on 13/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation
import SpotlightBridge
import JIRAServices

@objc public class SPBJIRAQuery: SPBQuery {
    
    public override func perform(_ userQueryString: String!, withCompletionHandler completionHandler: ((SPBResponse?) -> Void)!) {
        SPBJiraManager.shared.findMatchingIssues(for: userQueryString) { (issues) in
            let results = self.searchResults(for: issues)
            if (results.isEmpty) {
                completionHandler(nil)
                return
            }

            completionHandler(self.response(for: results))
        }
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
            return SPBJIRASearchResult(issue: issue)
        }
    }
}

