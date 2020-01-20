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
    
    func perform(with id: T.ID) -> AnyPublisher<T, Error> {
        NotificationCenter
            .default
            .publisher(for: .NSManagedObjectContextDidSave, object: parentContext)
            .map { notification in
                let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<T.ManagedEntity>
                
                return updatedObjects?
                    .first { $0.id == id }
                    .map { $0.plain }
            }
            .setFailureType(to: Error.self)
            .prepend(
                GetByID(
                    childContext: childContext,
                    parentContext: parentContext
                )
                .perform(with: id)
            )
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
