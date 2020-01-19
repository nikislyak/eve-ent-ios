//
//  DeleteAll.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 20.01.2020.
//

import Foundation
import CoreData
import Combine

struct DeleteAll<T: NSManagedObjectConvertible> {
    let childContext: NSManagedObjectContext
    let parentContext: NSManagedObjectContext
    
    func perform() -> AnyPublisher<Void, Error> {
        performWritingBackgroundTask(
            on: childContext,
            pushingChangesTo: parentContext
        ) { context in
            let existing = try context.fetch(NSFetchRequest<T.ManagedEntity>(entityName: T.ManagedEntity.name))
            
            existing.forEach(context.delete)
        }
    }
}
