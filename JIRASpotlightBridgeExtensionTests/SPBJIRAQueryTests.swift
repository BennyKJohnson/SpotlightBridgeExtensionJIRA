//
//  SPBJIRAQueryTests.swift
//  JIRASpotlightBridgeExtensionTests
//
//  Created by Benjamin Johnson on 29/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import XCTest
import JIRAServices

class SPBJIRAQueryTests: XCTestCase {

    func testRankIssues() {
        let issue = JIRAIssue(key: "APP-100", title: "", description: nil, timeSpent: nil)
        let issue2 = JIRAIssue(key: "APP-1002", title: "", description: nil, timeSpent: nil)
        let issue3 = JIRAIssue(key: "APP-10022", title: "", description: nil, timeSpent: nil)
        
        let query = SPBJIRAQuery()
        let rankedIssues = query.rankIssues(userQueryString: "100", issues: [ issue3, issue, issue2,]).map { (issue) -> String in
            return issue.key
        }
        XCTAssertEqual(rankedIssues, ["APP-100", "APP-1002", "APP-10022"])
    }
    
    func testRankIssuesWithIssueIDQueryAndIssueWithLongProjectID()
    {
        let issue10022 = JIRAIssue(key: "APP-10022", title: "", description: nil, timeSpent: nil)
        let issue22 = JIRAIssue(key: "REALLYLONGPROJECTNAME-22", title: "", description: nil, timeSpent: nil)
        
        let query = SPBJIRAQuery()
        let rankedIssues = query.rankIssues(userQueryString: "22", issues: [ issue10022, issue22]).map { (issue) -> String in
            return issue.key
        }
        
        XCTAssertEqual(rankedIssues, ["REALLYLONGPROJECTNAME-22", "APP-10022"])
    }


}
