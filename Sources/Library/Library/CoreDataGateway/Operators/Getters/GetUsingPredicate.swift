//
//  GetUsingPredicate.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 20.01.2020.
//

import Foundation
import CoreData
import Combine

struct GetUsingPredicate<T: NSManagedObjectConvertible> {
    let childContext: NSManagedObjectContext
    let parentContext: NSManagedObjectContext
    
    func perform(with predicate: NSPredicate) -> AnyPublisher<[T], Error> {
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
}
