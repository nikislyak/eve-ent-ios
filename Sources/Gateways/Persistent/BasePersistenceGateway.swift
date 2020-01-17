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

public protocol PlainEntityConvertible: NSManagedObject {
    associatedtype PlainEntity: NSManagedObjectConvertible where PlainEntity.ManagedEntity == Self
    
    var plain: PlainEntity { get }
}

extension PlainEntityConvertible {
    static var name: String {
        String(describing: self)
    }
}

public protocol NSManagedObjectConvertible {
    associatedtype ManagedEntity: PlainEntityConvertible where ManagedEntity.PlainEntity == Self
    
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

extension NSPersistentContainer {
    func performReadingBackgroundTask<T>(_ exec: @escaping (NSManagedObjectContext) throws -> T) -> AnyPublisher<T, Error> {
        Deferred {
            Future { promise in
                self.performBackgroundTask { context in
                    do {
                        promise(.success(try exec(context)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func performWritingBackgroundTask(_ exec: @escaping (NSManagedObjectContext) throws -> Void) -> AnyPublisher<Void, Error> {
        Deferred {
            Future { promise in
                self.performBackgroundTask { context in
                    do {
                        try exec(context)
                        
                        if context.hasChanges {
                            try context.save()
                        }
                        
                        promise(.success(()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

class BasePersistenceGateway {
    private let context: NSManagedObjectContext
    private let container: NSPersistentContainer
    
    init(backgroundContext context: NSManagedObjectContext, container: NSPersistentContainer) {
        self.context = context
        self.container = container
    }
    
    func get<T: NSManagedObjectConvertible>(allOfType plainType: T.Type) -> AnyPublisher<[T], Error> {
        container.performReadingBackgroundTask { context in
            try context
                .fetch(NSFetchRequest<T.ManagedEntity>(entityName: T.ManagedEntity.name))
                .map { $0.plain }
        }
    }
    
    func get<T: NSManagedObjectConvertible>(allOfType plainType: T.Type, using predicate: NSPredicate) -> AnyPublisher<[T], Error> {
        container.performReadingBackgroundTask { context in
            let req = NSFetchRequest<T.ManagedEntity>(entityName: T.ManagedEntity.name)
            
            req.predicate = predicate
            
            return try context
                .fetch(req)
                .map { $0.plain }
        }
    }
    
    func get<T: NSManagedObjectConvertible & Identifiable>(
        byId id: T.ID
    ) -> AnyPublisher<T?, Error> where T.ID: CVarArg & PredicatePlaceholderProvider {
        container.performReadingBackgroundTask { context in
            let req = NSFetchRequest<T.ManagedEntity>(entityName: T.ManagedEntity.name)
            
            req.predicate = NSPredicate(format: "id == \(T.ID.placeholder)", id)
            
            return try context.fetch(req).first?.plain
        }
    }

    func save<T: NSManagedObjectConvertible>(_ plain: T) -> AnyPublisher<Void, Error> {
        container.performWritingBackgroundTask { context in
            _ = plain.createManaged(insertingIn: context)
        }
    }
    
    func save<T: NSManagedObjectConvertible>(_ plains: [T]) -> AnyPublisher<Void, Error> {
        container.performWritingBackgroundTask { context in
            plains.forEach { plain in
                _ = plain.createManaged(insertingIn: context)
            }
        }
    }
}
