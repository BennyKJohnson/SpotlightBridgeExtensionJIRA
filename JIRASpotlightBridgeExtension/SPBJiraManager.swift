//
//  JiraManager.swift
//  JIRASpotlightBridgeExtension
//
//  Created by Benjamin Johnson on 23/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation
import JiraKit

class SPBJiraManager {
    
    static let shared = SPBJiraManager.defaultManager()
    
    let connection: NSXPCConnection
    
    var service: JiraServiceProtocol!
    
    static func defaultManager() -> SPBJiraManager {
        guard let configurationURL = Bundle(identifier: "benjamin.spotlightbridge.JIRASpotlightBridgeExtension")?.url(forResource: "jiraconfig", withExtension: "json") else {
            fatalError("Failed to find jiraconfig.json in bundle")
        }
        
        let configuration = JiraSessionConfiguration.fromFile(for: configurationURL)!
        return SPBJiraManager(configuation: configuration)
    }
    
    init(configuation: JiraSessionConfiguration) {
        connection = NSXPCConnection(machServiceName: "com.benjamin.jiraagentXPC", options: [])
        connection.remoteObjectInterface = NSXPCInterface(with: JiraServiceProtocol.self)
        connection.remoteObjectProxyWithErrorHandler(self.handleConnectionError)
    }
    
    func handleConnectionError(error: Error) {
        print("XPC Error occured \(error)")
    }
    
    func setupConnection() {
        connection.resume()

        guard let service = self.connection.remoteObjectProxy as? JiraServiceProtocol else {
            print("Failed to recognise remote object proxy type")
            return
        }
        
        self.service = service
    }
    
    func findMatchingIssues(for query: String, completionHandler: @escaping ([JIRAIssue]) -> ()) {
        if service == nil {
            setupConnection()
        }
        
        service.queryIssues(userQueryString: query) { (results, error) in
            if let results = results {
                print("Received \(results.count) results from JiraAgent")
                let decoder = JSONDecoder()
                decoder.context = DecodingContext()
                
                let issues = results.map({(issueData) in
                    return   try! decoder.decode(JIRAIssue.self, from: issueData)
                })
                
                completionHandler(issues)
            } else if let error = error {
                print("Something went wrong querying issues \(error)")
            }
            
        }
    }
}
