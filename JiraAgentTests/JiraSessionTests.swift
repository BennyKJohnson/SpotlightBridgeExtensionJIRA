//
//  JiraSessionTests.swift
//  JIRAServicesTests
//
//  Created by Benjamin Johnson on 23/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import XCTest
@testable import JiraKit

class JiraSessionTests: XCTestCase {
    var testConfiguration: JiraSessionConfiguration!
    var session: JiraSession!
    
    override func setUp() {
        let siteURL = URL(string: "http://test.jira.com")!
        testConfiguration = JiraSessionConfiguration(siteURL: siteURL, username: "username", password: "password")
        session = JiraSession(configuration: testConfiguration)
    }
    
    func testInit() {
        let siteURL = URL(string: "test.com")!
        let configuration = JiraSessionConfiguration(siteURL: siteURL, username: "username", password: "password")
        let session = JiraSession(configuration: configuration)
        
        XCTAssertEqual(session.configuration, configuration)
    }
    
    func testUrlSessionConfiguration() {
        let siteURL = URL(string: "test.jira.com")!
        let configuration = JiraSessionConfiguration(siteURL: siteURL, username: "username", password: "password")
        
        let urlSessionConfiguration = JiraSession.urlSessionConfiguration(for: configuration)
        let headers = urlSessionConfiguration.httpAdditionalHeaders
        let authenticationHeader = headers?["Authorization"] as? String
        XCTAssertNotNil(authenticationHeader)
        XCTAssertTrue(authenticationHeader!.starts(with: "Basic "))
        
        let authenticationBase64Encoded = String(authenticationHeader!.split(separator: " ")[1])
        let decodedData = Data(base64Encoded: authenticationBase64Encoded)!
        let decodedAuthentication = String(data: decodedData, encoding: .utf8)
        XCTAssertEqual(decodedAuthentication, "username:password")
    }
}
