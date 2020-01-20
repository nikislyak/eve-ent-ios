//
//  DeleteMany.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 20.01.2020.
//

import Foundation
import CoreData
import Combine

struct DeleteMany<T: NSManagedObjectConvertible> {
    let childContext: NSManagedObjectContext
    let parentContext: NSManagedObjectContext
    
    func perform(with ids: [T.ID]) -> AnyPublisher<Void, Error> {
        performWritingBackgroundTask(
            on: childContext,
            pushingChangesTo: parentContext
        ) { context in
            let existing = try context.fetch(makeFetchRequest(for: T.self, byIDs: ids))
            
            existing.forEach(context.delete)
        }
    }
}
