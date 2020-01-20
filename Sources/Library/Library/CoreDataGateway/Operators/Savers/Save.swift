//
//  Save.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 20.01.2020.
//

import Foundation
import CoreData
import Combine

struct Save<T: NSManagedObjectConvertible> {
    let childContext: NSManagedObjectContext
    let parentContext: NSManagedObjectContext
    
    func perform(with plain: T, shouldEditExisting: Bool = true) -> AnyPublisher<Void, Error> {
        performWritingBackgroundTask(
            on: childContext,
            pushingChangesTo: parentContext
        ) { context in
            let existing = try context.fetch(makeFetchRequest(for: T.self, byID: plain.id))
            
            let existingDict = Dictionary(removingDuplicatesFrom: existing)
            
            if shouldEditExisting {
                existingDict[plain.id].map(plain.edit)
            }
            
            if existingDict[plain.id] == nil {
                _ = plain.createManaged(insertingIn: context)
            }
        }
    }
}
