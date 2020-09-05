//
//  JiraAgent.swift
//  JiraAgent
//
//  Created by Benjamin Johnson on 5/9/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation
import JiraKit

@objc class JiraAgent: NSObject {
    
    var listener: NSXPCListener?
    
    let syncCoordinator: JiraSyncCoordinator
    
    init(configuration: JiraSessionConfiguration) {
        self.syncCoordinator = JiraSyncCoordinator(configuration: configuration)
    }
    
    func start() {
        setupListener()
        self.syncCoordinator.scheduleUpdateActivity()
    }
    
    func setupListener() {
        guard listener == nil else {
            return
        }
        
        let listener = NSXPCListener(machServiceName: "com.benjamin.jiraagentXPC")
        listener.delegate =  self
        listener.resume()
        
        self.listener = listener
    }
}

extension JiraAgent : NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
    
        newConnection.exportedInterface = NSXPCInterface(with: JiraServiceProtocol.self)
        newConnection.exportedObject = self
        
        newConnection.resume()
        return true
    }
}

extension JiraAgent : JiraServiceProtocol {
    
    func queryIssues(userQueryString: String, completionHandler: @escaping ([Data]?, Error?) -> ()) {
        self.syncCoordinator.queryIssuesFromDataStore(userQueryString: userQueryString) { (issues) in
            let encoder = JSONEncoder()
            let encodedIssues = try! issues.map({ (issue) -> Data in
                return try encoder.encode(issue)
            })

            completionHandler(encodedIssues, nil)
        }
        
    }
}
