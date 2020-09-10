//
//  JiraIssueSuggestionRequestTests.swift
//  JiraAgentTests
//
//  Created by Benjamin Johnson on 9/9/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import XCTest

class JiraIssueSuggestionRequestTests: XCTestCase {
    
    var request: JiraIssueSuggestionQueryRequest!

    override func setUp() {
        self.request = JiraIssueSuggestionQueryRequest()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testMakingURLRequest() throws
    {
        let parameters = JiraIssueSuggestionQueryRequestParameters(query: "myquery")
        let baseURL = URL(string: "http://test.jira.com/rest/api/latest")!
        let urlRequest = request.makeRequest(baseURL: baseURL, from: parameters)
        
        XCTAssertEqual(urlRequest.url?.host, "test.jira.com")
        XCTAssertEqual(urlRequest.url?.path, "/rest/api/latest/issue/picker")
        let expectedQuery = "query=myquery&currentJQL"
        
        XCTAssertEqual(urlRequest.url?.query!.removingPercentEncoding, expectedQuery)
    }
    
    func testParseResponse() throws
    {
        let testJSON = Bundle(for: type(of: self)).url(forResource: "JiraIssueSuggestionResponse", withExtension: "json")!
        let data = try Data(contentsOf: testJSON)
        let response = try request.parseResponse(data: data)
        
        let historySearch = response.historySearch
        XCTAssertNotNil(historySearch)
        XCTAssertEqual(historySearch?.id, "hs")
        XCTAssertEqual(historySearch?.issues.count, 1)
        
        let historySearchIssue = historySearch!.issues[0]
        XCTAssertEqual(historySearchIssue.key, "TEST-553")
        XCTAssertEqual(historySearchIssue.summary, "Flag for removal")


        let currentSearch = response.currentSearch
        XCTAssertNotNil(currentSearch)
        XCTAssertEqual(currentSearch?.id, "cs")
        XCTAssertEqual(currentSearch?.issues.count, 1)
        
        let currentSearchIssue = currentSearch!.issues[0]
        XCTAssertEqual(currentSearchIssue.key, "TEST-5")
        XCTAssertEqual(currentSearchIssue.summary, "Insert records")
    }
}
