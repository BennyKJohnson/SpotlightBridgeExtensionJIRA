//
//  CoreDataManager.swift
//  JIRAServices
//
//  Created by Benjamin Johnson on 25/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
        
    let modelName: String = "JiraModel"
    
    static let shared = CoreDataManager()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle(for: type(of: self)).url(forResource: "JiraModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
   
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: self.modelName, managedObjectModel: self.managedObjectModel);
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    lazy var mockPersistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName, managedObjectModel: self.managedObjectModel);
        
        let storeDescriptipn = NSPersistentStoreDescription()
        storeDescriptipn.type = NSInMemoryStoreType
        storeDescriptipn.shouldAddStoreAsynchronously = false
        
        container.persistentStoreDescriptions = [storeDescriptipn]
        container.loadPersistentStores(completionHandler: { (description, error) in
            precondition(description.type == NSInMemoryStoreType)
            
            // Check if creating container wrong
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        })
        
        return container
    }()
    
}
