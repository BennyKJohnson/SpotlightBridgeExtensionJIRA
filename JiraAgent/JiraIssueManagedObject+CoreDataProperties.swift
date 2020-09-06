//
//  JiraIssueManagedObject+CoreDataProperties.swift
//  JIRAServices
//
//  Created by Benjamin Johnson on 30/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//
//

import Foundation
import CoreData


extension JiraIssueManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<JiraIssueManagedObject> {
        return NSFetchRequest<JiraIssueManagedObject>(entityName: "JiraIssueManagedObject")
    }

    @NSManaged public var key: String?
    @NSManaged public var summary: String?
    @NSManaged public var assigneeName: String?
    @NSManaged public var issueDescription: String?
    @NSManaged public var timespent: Int64
    @NSManaged public var assigneeAvatarUrl: String?
    @NSManaged public var domain: String?
    @NSManaged public var status: String?

}
