//
//  ManagedObjectConvertible.swift
//  JIRAServices
//
//  Created by Benjamin Johnson on 25/8/20.
//  Copyright © 2020 Benjamin Johnson. All rights reserved.
//

import Foundation
import CoreData


/// An object that wants to be convertible in a managed object should implement the `ObjectConvertible` protocol.
protocol ObjectConvertible {
    var identifier: String? { get }
}

protocol ManagedObjectConvertible {
    associatedtype T
    
    var identifier: String? { get }
    
    static func insert(_ object: T, with context: NSManagedObjectContext) -> T?
    
    static func update(_ object: T, with context: NSManagedObjectContext)
    
    static func delete(_ object: T, with context: NSManagedObjectContext)
    
    static func fetchAll(from context: NSManagedObjectContext) -> [T]
    
    func from(object: T)

    func toObject() -> T
}

extension ManagedObjectConvertible where T: ObjectConvertible, Self: NSManagedObject {
    var identifier: String? {
        return objectID.uriRepresentation().absoluteString
    }
    
    static func insert(_ object: T, with context: NSManagedObjectContext) -> T? {
        guard object.identifier == nil else { return nil }
        
        let managedObject = Self(context: context)
        managedObject.from(object: object)
        
        return managedObject.toObject()
    }
    
    static func update(_ object: T, with context: NSManagedObjectContext) {
        guard let managedObject = get(object: object, with: context) else {
            return
        }
        
        managedObject.from(object: object)
    }
    
    static func delete(_ object: T, with context: NSManagedObjectContext) {
        guard let managedObject = get(object: object, with: context) else {
            return
        }
        
        context.delete(managedObject)
    }
    
    static func fetchAll(from context: NSManagedObjectContext) -> [T] {
        let request = NSFetchRequest<Self>(entityName: String(describing: self))
        request.returnsObjectsAsFaults = false
        
        do {
            let managedObjects = try context.fetch(request)
            return managedObjects.map { $0.toObject() }
        } catch {
            return [T]()
        }
    }
    
    static func replace(_ object: T, identifier:String, with context: NSManagedObjectContext) {
        guard let managedObject = get(identifier: identifier, with: context) else {
            return
        }
        
        managedObject.from(object: object)
    }
    
    private static func get(object: T, with context: NSManagedObjectContext) -> Self? {
        guard let identifier = object.identifier else {
            return nil
        }
    
        return self.get(identifier: identifier, with: context)
    }
    
    private static func get(identifier: String, with context: NSManagedObjectContext) -> Self? {
        guard let uri = URL(string: identifier),
        let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri) else
        {
            return nil
        }
        
        do {
            return try context.existingObject(with: objectID) as? Self
        } catch {
            return nil
        }
    }
}
