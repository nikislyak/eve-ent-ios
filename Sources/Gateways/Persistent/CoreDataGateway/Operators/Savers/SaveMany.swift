//
//  SaveMany.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 20.01.2020.
//

import Foundation
import CoreData
import Combine

struct SaveMany<T: NSManagedObjectConvertible> {
    let childContext: NSManagedObjectContext
    let parentContext: NSManagedObjectContext
    
    func perform(with plains: [T], shouldEditExisting: Bool = true) -> AnyPublisher<Void, Error> {
        performWritingBackgroundTask(
            on: childContext,
            pushingChangesTo: parentContext
        ) { context in
            let existing = try context.fetch(makeFetchRequest(for: T.self, byIDs: plains.map { $0.id }))
            
            let existingDict = Dictionary(removingDuplicatesFrom: existing)
            let plainsDict = Dictionary(removingDuplicatesFrom: plains)
            
            if shouldEditExisting {
                existing.forEach { managed in
                    plainsDict[managed.id]?.edit(existing: managed)
                }
            }
            
            plainsDict.values.forEach { plain in
                if existingDict[plain.id] == nil {
                    _ = plain.createManaged(insertingIn: context)
                }
            }
        }
    }
}

