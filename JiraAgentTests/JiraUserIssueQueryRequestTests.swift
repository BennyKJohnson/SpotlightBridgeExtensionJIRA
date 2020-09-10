//
//  JiraUserIssueQueryRequest.swift
//  JIRAServicesTests
//
//  Created by Benjamin Johnson on 30/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import XCTest

class JiraUserIssueQueryRequestTests: XCTestCase {
    
    var request: JiraUserIssueQueryRequest!
    
    override func setUp() {
        self.request = JiraUserIssueQueryRequest()
    }

    func testMakingUrlRequestForFetchingUserJiraIssues() throws
    {
        let parameters = JiraUserIssueQueryRequestParameters(startAt: 50, onlyUserAssignee: true)
        
        let urlRequest = request.makeRequest(baseURL: URL(string: "http://test.jira.com/rest/api/latest")!, from: parameters)
        let expectedQuery = "startAt=50&jql=assignee=currentUser()"

        verifyHostAndPath(urlRequest: urlRequest)
        XCTAssertEqual(urlRequest.url?.query!.removingPercentEncoding, expectedQuery)
    }
    
    func testMakingURLRequestForFetchingJiraIssues() throws
    {
        let parameters = JiraUserIssueQueryRequestParameters(startAt: 50, onlyUserAssignee: false)
        let urlRequest = request.makeRequest(baseURL: URL(string: "http://test.jira.com/rest/api/latest")!, from: parameters)
        let expectedQuery = "startAt=50"
        
        verifyHostAndPath(urlRequest: urlRequest)
        XCTAssertEqual(urlRequest.url?.query!.removingPercentEncoding, expectedQuery)
    }
    
    func testMakingURLRequestForFetchingJiraIssuesWithMaxResults() throws {
        var parameters = JiraUserIssueQueryRequestParameters(startAt: 0, onlyUserAssignee: false)
        parameters.maxResults = 10
        
        let urlRequest = request.makeRequest(baseURL: URL(string: "http://test.jira.com/rest/api/latest")!, from: parameters)
        let expectedQuery = "startAt=0&maxResults=10"
        
        verifyHostAndPath(urlRequest: urlRequest)
        XCTAssertEqual(urlRequest.url?.query!.removingPercentEncoding, expectedQuery)
    }
    
    func testParseUserJiraIssuesResponse() throws {
        let testJSON = Bundle(for: type(of: self)).url(forResource: "JiraIssueQueryResponse", withExtension: "json")!
        let data = try Data(contentsOf: testJSON)
        
        let response = try request.parseResponse(data: data)
        
        XCTAssertEqual(response.startAt, 0)
        XCTAssertEqual(response.total, 6)
        XCTAssertEqual(response.maxResults, 50)
        XCTAssertEqual(response.issues.count, 2)
    }
    
    func verifyHostAndPath(urlRequest: URLRequest) {
        XCTAssertEqual(urlRequest.url?.host, "test.jira.com")
        XCTAssertEqual(urlRequest.url?.path, "/rest/api/latest/search")
    }

}
