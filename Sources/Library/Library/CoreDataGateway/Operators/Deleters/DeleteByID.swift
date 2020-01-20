//
//  DeleteByID.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 20.01.2020.
//

import Foundation
import CoreData
import Combine

struct DeleteByID<T: NSManagedObjectConvertible> {
    let childContext: NSManagedObjectContext
    let parentContext: NSManagedObjectContext
    
    func perform(with id: T.ID) -> AnyPublisher<Void, Error> {
        performWritingBackgroundTask(
            on: childContext,
            pushingChangesTo: parentContext
        ) { context in
            let existing = try context.fetch(makeFetchRequest(for: T.self, byID: id))
            
            let existingDict = Dictionary(removingDuplicatesFrom: existing)
            
            existingDict[id].map(context.delete)
        }
    }
}
