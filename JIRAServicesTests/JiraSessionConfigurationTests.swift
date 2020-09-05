//
//  JiraSessionConfigurationTests.swift
//  JIRAServicesTests
//
//  Created by Benjamin Johnson on 23/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import XCTest
@testable import JiraKit

class JiraSessionConfigurationTests: XCTestCase {

    func testInit() {
        let siteURL = URL(string: "test.com")!
        let configuration = JiraSessionConfiguration(siteURL: siteURL, username: "testusername", password: "testpassword")
        
        XCTAssertEqual(configuration.siteURL, siteURL)
        XCTAssertEqual(configuration.username, "testusername")
        XCTAssertEqual(configuration.password, "testpassword")
    }
}
