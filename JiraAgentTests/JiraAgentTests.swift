//
//  JiraAgentTests.swift
//  JiraAgentTests
//
//  Created by Benjamin Johnson on 5/9/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import XCTest
@testable import JiraKit

class JiraAgentTests: XCTestCase {
    
    let configuration = JiraSessionConfiguration(siteURL: URL(string: "http://test.jira.com")!, username: "username", password: "password")
    
    var dataStore: JiraStore!
    
    var agent: JiraAgent!
    
    override func setUp() {
        let coreDataManager = CoreDataManager.shared        
        dataStore = JiraStore(container: coreDataManager.mockPersistantContainer)
        agent = JiraAgent(configuration: configuration, dataStore: dataStore)
    }
    
    func testInit() {
        let newAgent = JiraAgent(configuration: configuration, dataStore: dataStore)

        XCTAssertNotNil(newAgent)
        XCTAssertNotNil(newAgent.session)
        XCTAssertNotNil(newAgent.preferences)
        XCTAssertNotNil(newAgent.syncCoordinator)
        XCTAssertEqual(newAgent.syncCoordinator.session, newAgent.session)
    }

    func testSetupListener() {
        agent.setupListener()
        XCTAssertNotNil(agent.listener)
    }

    func testListenerShouldAcceptNewConnection() {
        agent.setupListener()
        let newConnection = NSXPCConnection(machServiceName: "Test", options: [])

        let result = agent.listener(agent.listener!, shouldAcceptNewConnection: newConnection)
        XCTAssertTrue(result)
    }

}
