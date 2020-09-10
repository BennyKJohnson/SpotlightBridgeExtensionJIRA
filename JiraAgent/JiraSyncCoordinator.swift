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
    
    var onlySyncUserAssignee: Bool = false
    
    init(session: JiraSession, store: JiraStore) {
        self.dataStore = store
        self.hasIssues = true
        self.session = session
    }
    
    public convenience init(session: JiraSession) {
        self.init(session: session, store: JiraStore.defaultStore)
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
            self.updateIssues(onlyUserAssignee: self.onlySyncUserAssignee) {
                completion(.finished)
            }
        }
    }
    
    func updateIssues(onlyUserAssignee: Bool , completionHandler: @escaping () -> ()) {
        os_log("Syncing issues from Jira")
        isSyncingIssues = true
        session.fetchIssues(onlyUserAssignee: onlyUserAssignee) { (result) in
            switch result {
            case .success(let issues):
                self.dataStore.createOrUpdate(issues: issues)
                os_log("Finished Syncing issues from Jira")

                self.isSyncingIssues = false
                completionHandler()
            case .failure(let error):
                print("FAILED retrieving issues \(error)")
                self.isSyncingIssues = false
            }
        }
    }
}
