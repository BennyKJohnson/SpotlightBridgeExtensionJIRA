//
//  JiraStore.swift
//  JIRAServices
//
//  Created by Benjamin Johnson on 25/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation
import CoreData
import JiraKit

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
    
    public func createOrUpdate(issues: [JIRAIssue]) {
        do {
            try deleteExisting(issues: issues)
        } catch {
            print(error)
        }

        for issue in issues {
            self.insert(issue)
        }
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error: \(error) could not save core data context")
            }
        } else {
            print("No changes to context")
        }
    }
    
    func deleteExisting(issues: [JIRAIssue]) throws  {
        let issueKeys = issues.map { (issue) -> String in
            return issue.key
        };
        
        let matchingRequest: NSFetchRequest<NSFetchRequestResult> = JiraIssueManagedObject.fetchRequest()
        matchingRequest.predicate = NSPredicate(format: "key in %@", issueKeys)
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        var deleteError: Error?
        context.performAndWait {
            do {
                let batchDeleteResult = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    print("Deleted \(deletedObjectIDs.count) existing issues")
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
                                                        into: [self.context])
                }
            } catch {
                print("Could not batch delete existing records")
                print(error)
                deleteError = error
            }
        }
        
        if let deleteError = deleteError {
            throw deleteError
        }
    }
}
