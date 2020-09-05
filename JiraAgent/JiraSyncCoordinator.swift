//
//  JiraManager.swift
//  JIRAServices
//
//  Created by Benjamin Johnson on 26/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation
import JiraKit
import os

public class JiraSyncCoordinator {
    
    let dataStore: JiraStore
    
    var hasIssues: Bool = false
    
    var isSyncingIssues: Bool = false
    
    let session: JiraSession
    
    var updateActivity: NSBackgroundActivityScheduler?
    
    var updateInterval: TimeInterval = 5 * 60
    
    init(configuration: JiraSessionConfiguration, store: JiraStore) {
        self.dataStore = store
        self.hasIssues = true
        self.session = JiraSession(configuration: configuration)
    }
    
    public convenience init(configuration: JiraSessionConfiguration) {
        self.init(configuration: configuration, store: JiraStore.defaultStore)
    }
    
    func setupBackgroundActivityScheduler(updateInterval: TimeInterval) -> NSBackgroundActivityScheduler {
        let updateActivity = NSBackgroundActivityScheduler(identifier: "com.benjamin.jiraagent.updateissues")
        updateActivity.repeats = true
        updateActivity.interval = updateInterval
        
        return updateActivity
    }
    
    func scheduleUpdateActivity() {
        os_log(.debug, "Scheduling background activity with interval %d", updateInterval);
        updateActivity = setupBackgroundActivityScheduler(updateInterval: updateInterval)
        updateActivity!.schedule { (completion) in
            self.updateIssues {
                completion(.finished)
            }
        }
    }
    
    public func queryIssues(userQueryString: String, completionHandler: @escaping ([JIRAIssue]) -> ()) {
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
    
    func updateIssues(completionHandler: @escaping () -> ()) {
        print("Updating Issues")
        isSyncingIssues = true
        session.fetchIssues { (result) in
            switch result {
            case .success(let issues):
                self.dataStore.createOrUpdate(issues: issues)
                print("Finished saving issues")

                self.isSyncingIssues = false
                completionHandler()
            case .failure(let error):
                print("FAILED retrieving issues \(error)")
                self.isSyncingIssues = false
            }
        }
    }
}
