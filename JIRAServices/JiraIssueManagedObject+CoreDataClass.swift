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

@objc(JiraIssueManagedObject)
public class JiraIssueManagedObject: NSManagedObject, ManagedObjectConvertible {
    typealias T = JIRAIssue
    static let entityName: String = "JiraIssueManagedObject"
    
    func from(object: JIRAIssue) {
        key = object.key
        summary = object.title
    }
    
    func toObject() -> JIRAIssue {
        return JIRAIssue(identifier: self.identifier!, key: self.key!, title: self.summary ?? "", description:  nil, timeSpent: nil)
    }
}
