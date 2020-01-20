//
//  ListenUpdatesByID.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 20.01.2020.
//

import Foundation
import CoreData
import Combine

struct ListenUpdatesByID<T: NSManagedObjectConvertible> {
    let childContext: NSManagedObjectContext
    let parentContext: NSManagedObjectContext
    
    func perform(with id: T.ID) -> AnyPublisher<T?, Error> {
        NotificationCenter
            .default
            .publisher(for: .NSManagedObjectContextDidSave, object: parentContext)
            .map { notification -> AnyPublisher<T?, Never> in
                let insertedObjects = (notification.userInfo?[NSInsertedObjectsKey] as? NSSet)?.compactMap { $0 as? T.ManagedEntity }
                let updatedObjects = (notification.userInfo?[NSUpdatedObjectsKey] as? NSSet)?.compactMap { $0 as? T.ManagedEntity }
                let deletedObjects = (notification.userInfo?[NSDeletedObjectsKey] as? NSSet)?.compactMap { $0 as? T.ManagedEntity }
                
                if let insertedObjects = insertedObjects,
                    let insertedObject = insertedObjects.first(where: { $0.id == id })?.plain {
                    return Just(insertedObject).eraseToAnyPublisher()
                }
                
                if let deletedObjects = deletedObjects,
                    deletedObjects.contains(where: { $0.id == id }) {
                    return Just(nil).eraseToAnyPublisher()
                }
                
                if let updatedObject = updatedObjects?.first(where: { $0.id == id })?.plain {
                    return Just(updatedObject).eraseToAnyPublisher()
                }
                
                return Empty().eraseToAnyPublisher()
            }
            .switchToLatest()
            .setFailureType(to: Error.self)
            .prepend(
                GetByID(
                    childContext: childContext,
                    parentContext: parentContext
                )
                .perform(with: id)
            )
            .eraseToAnyPublisher()
    }
}
