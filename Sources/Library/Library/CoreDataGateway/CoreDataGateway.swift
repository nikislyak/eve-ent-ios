//
//  CoreDataGateway.swift
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
    func edit(existing managed: ManagedEntity)
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

public class CoreDataGateway {
    private let childContext: NSManagedObjectContext
    private let parentContext: NSManagedObjectContext
    private let container: NSPersistentContainer
    
    public init(childContext: NSManagedObjectContext, container: NSPersistentContainer) {
        self.childContext = childContext
        self.container = container
        self.parentContext = container.newBackgroundContext()
        
        self.childContext.parent = self.parentContext
    }
    
    public func getAll<T: NSManagedObjectConvertible>() -> AnyPublisher<[T], Error> {
        GetAll(
            childContext: childContext,
            parentContext: parentContext
        )
        .perform()
    }
    
    public func getAll<T: NSManagedObjectConvertible>(using predicate: NSPredicate) -> AnyPublisher<[T], Error> {
        GetUsingPredicate(
            childContext: childContext,
            parentContext: parentContext
        )
        .perform(with: predicate)
    }
    
    public func get<T: NSManagedObjectConvertible>(byID id: T.ID) -> AnyPublisher<T?, Error> {
        GetByID(
            childContext: childContext,
            parentContext: parentContext
        )
        .perform(with: id)
    }
    
    public func listenUpdates<T: NSManagedObjectConvertible>(byID id: T.ID) -> AnyPublisher<T?, Error> {
        ListenUpdatesByID(
            childContext: childContext,
            parentContext: parentContext
        )
        .perform(with: id)
    }
    
    public func listenAll<T: NSManagedObjectConvertible>() -> AnyPublisher<[T], Error> {
        ListenAll(
            childContext: childContext,
            parentContext: parentContext
        )
        .perform()
    }

    public func save<T: NSManagedObjectConvertible>(_ plain: T, shouldEditExisting: Bool = true) -> AnyPublisher<Void, Error> {
        Save(
            childContext: childContext,
            parentContext: parentContext
        )
        .perform(with: plain, shouldEditExisting: shouldEditExisting)
    }
    
    public func save<T: NSManagedObjectConvertible>(_ plains: [T], shouldEditExisting: Bool = true) -> AnyPublisher<Void, Error> {
        SaveMany(
            childContext: childContext,
            parentContext: parentContext
        )
        .perform(with: plains, shouldEditExisting: shouldEditExisting)
    }
    
    public func delete<T: NSManagedObjectConvertible>(_ plainType: T.Type, byID id: T.ID) -> AnyPublisher<Void, Error> {
        DeleteByID<T>(
            childContext: childContext,
            parentContext: parentContext
        )
        .perform(with: id)
    }
    
    public func deleteAll<T: NSManagedObjectConvertible>(ofType plainType: T.Type) -> AnyPublisher<Void, Error> {
        DeleteAll<T>(
            childContext: childContext,
            parentContext: parentContext
        )
        .perform()
    }
    
    public func delete<T: NSManagedObjectConvertible>(_ plainType: T.Type, byIDs ids: [T.ID]) -> AnyPublisher<Void, Error> {
        DeleteMany<T>(
            childContext: childContext,
            parentContext: parentContext
        )
        .perform(with: ids)
    }
}
