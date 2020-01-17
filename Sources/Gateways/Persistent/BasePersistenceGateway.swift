//
//  BasePersistenceGateway.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 22.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation
import Combine
import CoreData

public protocol PlainEntityConvertible: NSManagedObject, Identifiable {
    associatedtype PlainEntity: NSManagedObjectConvertible
        where PlainEntity.ManagedEntity == Self,
        PlainEntity.ID == ID,
        PlainEntity.ID: PredicatePlaceholderProvider
    
    var plain: PlainEntity { get }
}

extension PlainEntityConvertible {
    static var name: String {
        String(describing: self)
    }
}

public protocol NSManagedObjectConvertible: Identifiable {
    associatedtype ManagedEntity: PlainEntityConvertible
        where ManagedEntity.PlainEntity == Self,
        ManagedEntity.ID == ID
    
    func createManaged(insertingIn context: NSManagedObjectContext) -> ManagedEntity
}

extension PlainEntityConvertible {
    public init?(moc: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: moc) else {
            return nil
        }
        
        self.init(entity: entity, insertInto: moc)
    }
}

/// Reads data from child context through parent context.
/// - Parameters:
///   - childContext: Child context from which data will be read. You must assign parent context to this one manually.
///   - parentContext: Parent context from which data will be read.
///   - exec: Child context getter closure.
func performReadingBackgroundTask<T>(
    on childContext: NSManagedObjectContext,
    receivingFrom parentContext: NSManagedObjectContext,
    _ exec: @escaping (NSManagedObjectContext) throws -> T
) -> AnyPublisher<T, Error> {
    Deferred {
        Future { promise in
            childContext.perform {
                promise(Result {
                    try exec(childContext)
                })
            }
        }
    }
    .eraseToAnyPublisher()
}

/// Applies changes to child context and saves parent context.
/// - Parameters:
///   - childContext: Child context that changes should be applied to. You must assign parent context to this one manually.
///   - parentContext: Parent context that will be saved.
///   - exec: Child context mutating closure.
func performWritingBackgroundTask(
    on childContext: NSManagedObjectContext,
    pushingChangesTo parentContext: NSManagedObjectContext,
    _ exec: @escaping (NSManagedObjectContext) throws -> Void
) -> AnyPublisher<Void, Error> {
    Deferred {
        Future { promise in
            childContext.perform {
                do {
                    try exec(childContext)

                    if childContext.hasChanges {
                        try childContext.save()
                    }
                } catch {
                    promise(.failure(error))
                }
                
                parentContext.perform {
                    promise(Result {
                        if parentContext.hasChanges {
                            try parentContext.save()
                        }
                    })
                }
            }
        }
    }
    .eraseToAnyPublisher()
}

class BasePersistenceGateway {
    private let childContext: NSManagedObjectContext
    private let parentContext: NSManagedObjectContext
    private let container: NSPersistentContainer
    
    init(childContext: NSManagedObjectContext, container: NSPersistentContainer) {
        self.childContext = childContext
        self.container = container
        self.parentContext = container.newBackgroundContext()
        
        self.childContext.parent = self.parentContext
    }
    
    func get<T: NSManagedObjectConvertible>(allOfType plainType: T.Type) -> AnyPublisher<[T], Error> {
        performReadingBackgroundTask(
            on: childContext,
            receivingFrom: parentContext
        ) { context in
            try context
                .fetch(NSFetchRequest<T.ManagedEntity>(entityName: T.ManagedEntity.name))
                .map { $0.plain }
        }
    }
    
    func get<T: NSManagedObjectConvertible>(allOfType plainType: T.Type, using predicate: NSPredicate) -> AnyPublisher<[T], Error> {
        performReadingBackgroundTask(
            on: childContext,
            receivingFrom: parentContext
        ) { context in
            let req = NSFetchRequest<T.ManagedEntity>(entityName: T.ManagedEntity.name)
            
            req.predicate = predicate
            
            return try context
                .fetch(req)
                .map { $0.plain }
        }
    }
    
    func get<T: NSManagedObjectConvertible>(
        byId id: T.ID
    ) -> AnyPublisher<T?, Error> {
        performReadingBackgroundTask(
            on: childContext,
            receivingFrom: parentContext
        ) { context in
            let req = NSFetchRequest<T.ManagedEntity>(entityName: T.ManagedEntity.name)
            
            req.predicate = NSPredicate(format: "id == \(T.ManagedEntity.ID.placeholder)", argumentArray: [id])
            
            return try context.fetch(req).first?.plain
        }
    }
    
    func listen<T: NSManagedObjectConvertible>(
        byId id: T.ID
    ) -> AnyPublisher<T?, Never> {
        NotificationCenter
            .default
            .publisher(for: .NSManagedObjectContextDidSave, object: parentContext)
            .map { notification in
                let updatedObjects = notification.userInfo?[NSInsertedObjectsKey] as? NSSet
                
                return updatedObjects?
                    .compactMap { ($0 as? T.ManagedEntity)?.plain }
                    .first { $0.id == id }
            }
            .eraseToAnyPublisher()
    }

    func save<T: NSManagedObjectConvertible>(_ plain: T, shouldReplaceExisting: Bool = true) -> AnyPublisher<Void, Error> {
        performWritingBackgroundTask(
            on: childContext,
            pushingChangesTo: parentContext
        ) { context in
            let req = NSFetchRequest<T.ManagedEntity>(entityName: T.ManagedEntity.name)
            
            req.predicate = NSPredicate(format: "id == \(T.ManagedEntity.ID.placeholder)", argumentArray: [plain.id])
            
            let existing = try context.fetch(req)
            
            if shouldReplaceExisting {
                existing.forEach(context.delete)
                
                _ = plain.createManaged(insertingIn: context)
            }
        }
    }
    
    func save<T: NSManagedObjectConvertible>(_ plains: [T], shouldReplaceExisting: Bool = true) -> AnyPublisher<Void, Error> {
        performWritingBackgroundTask(
            on: childContext,
            pushingChangesTo: parentContext
        ) { context in
            let req = NSFetchRequest<T.ManagedEntity>(entityName: T.ManagedEntity.name)
            
            req.predicate = NSPredicate(format: "id IN %@", plains.map { $0.id })
            
            let existing = try context.fetch(req)
            
            if shouldReplaceExisting {
                existing.forEach(context.delete)
            }
            
            let plainsToInsert: [T]
            
            if shouldReplaceExisting {
                plainsToInsert = plains
            } else {
                plainsToInsert = plains
                    .filter { plain in
                        !existing
                            .map { $0.plain.id }
                            .contains(plain.id)
                    }
            }
            
            plainsToInsert.forEach { plain in
                _ = plain.createManaged(insertingIn: context)
            }
        }
    }
}
