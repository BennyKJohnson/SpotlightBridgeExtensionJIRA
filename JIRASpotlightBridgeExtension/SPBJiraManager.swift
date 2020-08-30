//
//  JiraManager.swift
//  JIRASpotlightBridgeExtension
//
//  Created by Benjamin Johnson on 23/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation
import JIRAServices

class SPBJiraManager {
    
    static let shared = SPBJiraManager.defaultManager()
    
    let manager: JiraManager
    
    var issues: [JIRAIssue]?
    
    static func defaultManager() -> SPBJiraManager {
        guard let configurationURL = Bundle(identifier: "benjamin.spotlightbridge.JIRASpotlightBridgeExtension")?.url(forResource: "jiraconfig", withExtension: "json") else {
            fatalError("Failed to find jiraconfig.json in bundle")
        }
        
        let configuration = JiraSessionConfiguration.fromFile(for: configurationURL)!
        return SPBJiraManager(configuation: configuration)
    }
    
    init(configuation: JiraSessionConfiguration) {
        self.manager = JiraManager(configuration: configuation)
    }
    
    func findMatchingIssues(for query: String, completionHandler: @escaping ([JIRAIssue]) -> ()) {
        self.manager.queryIssues(userQueryString: query) {
            (issues) in
            completionHandler(issues)
        }
    }
}
