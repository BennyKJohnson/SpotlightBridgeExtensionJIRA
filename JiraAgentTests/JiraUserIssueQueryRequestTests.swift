//
//  JiraUserIssueQueryRequest.swift
//  JIRAServicesTests
//
//  Created by Benjamin Johnson on 30/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import XCTest

class JiraUserIssueQueryRequestTests: XCTestCase {

    func testMakingUrlRequestForFetchingUserJiraIssues() throws
    {
        let request = JiraUserIssueQueryRequest()
        let parameters = JiraUserIssueQueryRequestParameters(startAt: 50)
        
        let urlRequest = request.makeRequest(baseURL: URL(string: "http://test.jira.com/rest/api/latest")!, from: parameters)
        let expectedQuery = "jql=assignee=currentUser()&startAt=50"
        XCTAssertEqual(urlRequest.url?.host, "test.jira.com")
        XCTAssertEqual(urlRequest.url?.path, "/rest/api/latest/search")
        XCTAssertEqual(urlRequest.url?.query!.removingPercentEncoding, expectedQuery)
    }
    
    func testParseUserJiraIssuesResponse() throws {
        let testJSON = Bundle(for: type(of: self)).url(forResource: "JiraIssueQueryResponse", withExtension: "json")!
        let data = try Data(contentsOf: testJSON)
        
        let response = try JiraUserIssueQueryRequest().parseResponse(data: data)
        
        XCTAssertEqual(response.startAt, 0)
        XCTAssertEqual(response.total, 6)
        XCTAssertEqual(response.maxResults, 50)
        XCTAssertEqual(response.issues.count, 2)
    }
}
