//
//  JiraIssueTests.swift
//  JIRAServicesTests
//
//  Created by Benjamin Johnson on 5/9/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import XCTest
import JiraKit
class JiraIssueTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInternalEncode() throws {
        let encoder = JSONEncoder()
        let issue = JIRAIssue(key: "Key-123", title: "My title", description: "My description", timeSpent: 60)
        let data = try encoder.encode(issue)
        let string = String(data: data, encoding: .utf8)!
        
        let expectedJSONString = "{\"title\":\"My title\",\"key\":\"Key-123\",\"issueDescription\":\"My description\",\"timeSpent\":60}"
        XCTAssertEqual(string, expectedJSONString)
        print(string)
    }
    
    func testInternalDecode() throws {
        let decoder = JSONDecoder()
        decoder.context = DecodingContext()
        let jsonString = "{\"title\":\"My title\",\"key\":\"Key-123\",\"issueDescription\":\"My description\",\"timeSpent\":60}"
        let jsonData = jsonString.data(using: .utf8)!
        let issue = try decoder.decode(JIRAIssue.self, from: jsonData)
        
        XCTAssertEqual(issue.title, "My title")
        XCTAssertEqual(issue.key, "Key-123")
        XCTAssertEqual(issue.issueDescription, "My description")
        XCTAssertEqual(issue.timeSpent, 60)
        
    }

}
