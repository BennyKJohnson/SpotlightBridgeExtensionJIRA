//
//  JiraStore.swift
//  JIRAServices
//
//  Created by Benjamin Johnson on 25/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation

public class JiraStore {
    
    let context: NSManagedObjectContext
    
    private let entityName = "JiraIssueManagedObject"
    
    private let container: NSPersistentContainer!
    
    public static let defaultStore: JiraStore = JiraStore()
    
    init(container: NSPersistentContainer) {
        self.context = container.viewContext
        self.container = container
    }
    
    convenience init() {
        let coreDataManager = CoreDataManager()
        self.init(container: coreDataManager.persistentContainer)
    }
    
    @discardableResult public func insert(_ issue: JIRAIssue) -> JIRAIssue? {
        return JiraIssueManagedObject.insert(issue, with: context)
    }
    
    public func update(_ issue: JIRAIssue) {
        JiraIssueManagedObject.update(issue, with: context)
    }
    
    public func delete(_ issue: JIRAIssue) {
        JiraIssueManagedObject.delete(issue, with: context)
    }
    
    public func fetchAll() -> [JIRAIssue] {
        return JiraIssueManagedObject.fetchAll(from: context)
    }
    
    public func findIssue(key: String) -> JIRAIssue? {
        let predicate = NSPredicate(format: "key = %@", key);
        
        do {
            if let result = try fetch(predicate: predicate).first {
                return result;
            };
        } catch let error as NSError {
            NSLog("Error getting a match %@", error);
        }
        
        return nil;
    }
    
    public func save() throws {
        try context.save()
    }
    
    public func fetch(predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [JIRAIssue] {
        let request: NSFetchRequest<JiraIssueManagedObject> = JiraIssueManagedObject.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        let results = try context.fetch(request)
        return results.map({ (result) -> JIRAIssue in
            return result.toObject()
        })
    }
    
    public func createOrUpdate(issue: JIRAIssue)
    {
        if let existingIssue = findIssue(key: issue.key) {
            JiraIssueManagedObject.replace(issue, identifier: existingIssue.identifier!, with: context)
        } else {
            insert(issue)
        }
    }
}
