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

protocol PlainEntityConvertible: NSManagedObject {
    associatedtype PlainEntity: NSManagedObjectConvertible where PlainEntity.ManagedEntity == Self
    
    var plain: PlainEntity { get }
}

extension PlainEntityConvertible {
    static var name: String {
        String(describing: self)
    }
}

protocol NSManagedObjectConvertible: Identifiable where ID == UInt64 {
    associatedtype ManagedEntity: PlainEntityConvertible where ManagedEntity.PlainEntity == Self
    
    func configure(new managed: ManagedEntity)
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
    
    init(_ context: NSManagedObjectContext, _ container: NSPersistentContainer) {
        self.context = context
        self.container = container
    }
    
    func get<T: NSManagedObjectConvertible>(all plainType: T.Type) -> AnyPublisher<[T], Error> {
        container.performReadingBackgroundTask { context in
            try context
                .fetch(NSFetchRequest(entityName: T.ManagedEntity.name))
                .compactMap { ($0 as? T.ManagedEntity)?.plain }
        }
    }
    
    func save<T: NSManagedObjectConvertible>(_ plain: T) -> AnyPublisher<Void, Error> {
        container.performWritingBackgroundTask { context in
            plain.configure(new: T.ManagedEntity(context: context))
        }
    }
    
//    func save<T: NSManagedObjectConvertible>(_ plains: [T]) -> AnyPublisher<Void, Error> {
//        
//    }
}
