//
//  JiraIssueManagedObject+CoreDataProperties.swift
//  JIRAServices
//
//  Created by Benjamin Johnson on 25/8/20.
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

}
