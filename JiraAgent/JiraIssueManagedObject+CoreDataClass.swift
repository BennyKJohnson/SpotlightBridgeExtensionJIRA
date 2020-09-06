//
//  JiraIssueManagedObject+CoreDataClass.swift
//  JIRAServices
//
//  Created by Benjamin Johnson on 25/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//
//

import Foundation
import CoreData
import JiraKit

@objc(JiraIssueManagedObject)
public class JiraIssueManagedObject: NSManagedObject, ManagedObjectConvertible {
    typealias T = JIRAIssue
    static let entityName: String = "JiraIssueManagedObject"
    
    func from(object: JIRAIssue) {
        key = object.key
        summary = object.title
        assigneeName = object.assignee?.name
        assigneeAvatarUrl = object.assignee?.avatarURL?.absoluteString
        issueDescription = object.issueDescription
        if let objectTimeSpent = object.timeSpent {
            timespent = Int64(objectTimeSpent)
        }
        
        domain = object.domain
        status = object.status
    }
    
    func toObject() -> JIRAIssue {
        let issue = JIRAIssue(identifier: self.identifier!, key: self.key!, title: self.summary ?? "", description:  issueDescription, timeSpent: Double(self.timespent), domain: self.domain)
        
        if let assigneeName = assigneeName {
            let url: URL?
            if let assigneeAvatarUrl = assigneeAvatarUrl {
                url = URL(string: assigneeAvatarUrl)
            } else {
                url = nil
            }
            issue.assignee = JiraAssignee(name: assigneeName, avatarURL: url)
        }
        
        issue.status = status
        
        return issue
    }
}
