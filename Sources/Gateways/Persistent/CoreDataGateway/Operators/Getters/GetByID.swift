//
//  GetByID.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 20.01.2020.
//

import Foundation
import CoreData
import Combine

struct GetByID<T: NSManagedObjectConvertible> {
    let childContext: NSManagedObjectContext
    let parentContext: NSManagedObjectContext
    
    func perform(with id: T.ID) -> AnyPublisher<T?, Error> {
        performReadingBackgroundTask(
            on: childContext,
            receivingFrom: parentContext
        ) { context in
            try context.fetch(makeFetchRequest(for: T.self, byID: id)).first?.plain
        }
    }
}
