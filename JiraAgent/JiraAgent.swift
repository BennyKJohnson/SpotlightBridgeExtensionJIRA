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
    
    let preferences: JiraBridgePreferences
    
    let dataStore: JiraStore
    
    let session: JiraSession
    
    init(configuration: JiraSessionConfiguration, dataStore: JiraStore = JiraStore.defaultStore) {
        self.preferences = JiraBridgePreferences()
        self.session = JiraSession(configuration: configuration)
        self.dataStore = dataStore
        
        self.syncCoordinator = JiraSyncCoordinator(session: self.session, store: self.dataStore)
        self.syncCoordinator.onlySyncUserAssignee = self.preferences.searchableIssues == .userAssigned
    }
    
    func start() {
        setupListener()
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
    
    func queryIssuesFromDataStore(userQueryString: String, completionHandler: @escaping ([JIRAIssue]) -> ()) {
        if (userQueryString.isEmpty) {
            completionHandler([])
            return
        }
        
        if (self.syncCoordinator.isSyncingIssues) {
            print("Won't perform query because syncing issues")
            completionHandler([])
            return
        }
        
        let keyPredicate = NSPredicate(format: "key CONTAINS[cd] %@", userQueryString)
        let results = try! dataStore.fetch(predicate: keyPredicate, sortDescriptors: [NSSortDescriptor(key: "key", ascending: true)])
        
        completionHandler(results)
    }
    
    func queryIssueSuggestions(userQueryString: String, completionHandler: @escaping ([JIRAIssue]) -> ()) {
        if (userQueryString.isEmpty) {
            completionHandler([])
            return
        }
        
        session.queryIssueSuggestions(query: userQueryString) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let issues):
                print(issues)
                
                completionHandler(issues)
            }
        }
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
    
    func fetchIssueDetails(issueKey: String, completionHandler: @escaping (Data?, Error?) -> ()) {
        session.fetchIssueDetails(issueKey: issueKey) { (result) in
            switch result {
            case .success(let issue):
                let encoder = JSONEncoder()
                let encodedIssue = try! encoder.encode(issue)
                completionHandler(encodedIssue, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    func queryIssues(userQueryString: String, completionHandler: @escaping ([Data]?, Error?) -> ()) {
        self.queryIssueSuggestions(userQueryString: userQueryString) { (issues) in
            let encodedIssues = try! self.encodeIssues(issues: issues)
            completionHandler(encodedIssues, nil)
        }
    }
    
    func encodeIssues(issues: [JIRAIssue]) throws -> [Data] {
        let encoder = JSONEncoder()
        return try issues.map({ (issue) -> Data in
            return try encoder.encode(issue)
        })
    }
}
