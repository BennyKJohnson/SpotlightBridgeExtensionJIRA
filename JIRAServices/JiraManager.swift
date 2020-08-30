//
//  JiraManager.swift
//  JIRAServices
//
//  Created by Benjamin Johnson on 26/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation

public class JiraManager {
    
    let dataStore: JiraStore
    
    let session: JiraSession
    
    var hasIssues: Bool = false
    
    var isSyncingIssues: Bool = false
    
    init(configuration: JiraSessionConfiguration, store: JiraStore) {
        self.dataStore = store
        session = JiraSession(configuration: configuration)
    }
    
    public convenience init(configuration: JiraSessionConfiguration) {
        self.init(configuration: configuration, store: JiraStore.defaultStore)
    }
    
    
    func save(issues: [JIRAIssue]) {
        for issue in issues {
            dataStore.createOrUpdate(issue: issue)
        }
        
        try! dataStore.save()
    }
    
    public func queryIssues(userQueryString: String, completionHandler: @escaping ([JIRAIssue]) -> ()) {
        if (!hasIssues && !isSyncingIssues) {
                fetchIssues { (issues) in
                    self.hasIssues = true
                    self.queryIssuesFromDataStore(userQueryString: userQueryString, completionHandler: completionHandler)
                }
                return
          //  }
        }
        
        self.queryIssuesFromDataStore(userQueryString: userQueryString, completionHandler: completionHandler)
    }
    
    func queryIssuesFromDataStore(userQueryString: String, completionHandler: @escaping ([JIRAIssue]) -> ()) {
        if (userQueryString.isEmpty) {
            completionHandler([])
            return
        }
        
        if (isSyncingIssues) {
            print("Won't perform query because syncing issues")
            completionHandler([])
            return
        }
        
        let keyPredicate = NSPredicate(format: "key CONTAINS[cd] %@", userQueryString)
        let results = try! dataStore.fetch(predicate: keyPredicate, sortDescriptors: [NSSortDescriptor(key: "key", ascending: true)])
        
        completionHandler(results)
    }
    
    func fetchIssues(completionHandler: @escaping ([JIRAIssue]) -> ()) {
        isSyncingIssues = true
        session.fetchIssues { (result) in
            switch result {
            case .success(let issues):
                self.save(issues: issues)
                print("Finished saving issues")

                self.isSyncingIssues = false
                completionHandler(issues)
            case .failure(let error):
                print("FAILED retrieving issues \(error)")
                self.isSyncingIssues = false
            }
        }
    }
}
