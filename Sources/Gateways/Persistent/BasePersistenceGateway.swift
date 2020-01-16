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

protocol NSManagedObjectConvertible {
    associatedtype ManagedEntity: PlainEntityConvertible where ManagedEntity.PlainEntity == Self
    
    func configure(new managed: ManagedEntity)
}

extension PlainEntityConvertible {
    public init?(context: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: context) else {
            return nil
        }
        
        self.init(entity: entity, insertInto: context)
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
                .fetch(NSFetchRequest(entityName: T.ManagedEntity.name))
                .compactMap { ($0 as? T.ManagedEntity)?.plain }
        }
    }
    
    func save<T: NSManagedObjectConvertible>(_ plain: T) -> AnyPublisher<Void, Error> {
        container.performWritingBackgroundTask { context in
            T.ManagedEntity(context: context).map(plain.configure)
        }
    }
    
    func save<T: NSManagedObjectConvertible>(_ plains: [T]) -> AnyPublisher<Void, Error> {
        container.performWritingBackgroundTask { context in
            plains.forEach { plain in
                T.ManagedEntity(context: context).map(plain.configure)
            }
        }
    }
}
