//
//  ListenAll.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 20.01.2020.
//

import Foundation
import CoreData
import Combine

struct ListenAll<T: NSManagedObjectConvertible> {
    let childContext: NSManagedObjectContext
    let parentContext: NSManagedObjectContext
    
    func perform() -> AnyPublisher<[T], Error> {
        NotificationCenter
            .default
            .publisher(for: .NSManagedObjectContextDidSave, object: parentContext)
            .setFailureType(to: Error.self)
            .map { notification -> AnyPublisher<[T], Error> in
                if thereAreChanges(for: T.self, in: notification) {
                    return GetAll(
                        childContext: self.childContext,
                        parentContext: self.parentContext
                    )
                    .perform()
                }
                
                return Empty().eraseToAnyPublisher()
            }
            .switchToLatest()
            .prepend(
                GetAll(
                    childContext: childContext,
                    parentContext: parentContext
                )
                .perform()
            )
            .eraseToAnyPublisher()
    }
}

private func thereAreChanges<T: NSManagedObjectConvertible>(for type: T.Type, in notification: Notification) -> Bool {
    let insertedObjects = (notification.userInfo?[NSInsertedObjectsKey] as? NSSet)?.compactMap { $0 as? T.ManagedEntity }
    let updatedObjects = (notification.userInfo?[NSUpdatedObjectsKey] as? NSSet)?.compactMap { $0 as? T.ManagedEntity }
    let deletedObjects = (notification.userInfo?[NSDeletedObjectsKey] as? NSSet)?.compactMap { $0 as? T.ManagedEntity }
    
    guard
        let typedInsertedObjects = insertedObjects, typedInsertedObjects.isEmpty,
        let typedDeletedObjects = deletedObjects, typedDeletedObjects.isEmpty,
        let typedUpdatedObjects = updatedObjects, typedUpdatedObjects.isEmpty
    else {
        return true
    }
    
    return false
}
