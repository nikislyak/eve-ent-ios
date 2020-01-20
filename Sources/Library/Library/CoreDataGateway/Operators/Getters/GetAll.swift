//
//  GetAll.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 20.01.2020.
//

import Foundation
import CoreData
import Combine

struct GetAll<T: NSManagedObjectConvertible> {
    let childContext: NSManagedObjectContext
    let parentContext: NSManagedObjectContext
    
    func perform() -> AnyPublisher<[T], Error> {
        performReadingBackgroundTask(
            on: childContext,
            receivingFrom: parentContext
        ) { context in
            try context
                .fetch(NSFetchRequest<T.ManagedEntity>(entityName: T.ManagedEntity.name))
                .map { $0.plain }
        }
    }
}
