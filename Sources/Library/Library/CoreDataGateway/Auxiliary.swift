//
//  Auxiliary.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 20.01.2020.
//

import Foundation
import CoreData
import Combine

/// Reads data from child context through parent context.
/// - Parameters:
///   - childContext: Child context from which data will be read. You must assign parent context to this one manually.
///   - parentContext: Parent context from which data will be read.
///   - exec: Child context getter closure.
func performReadingBackgroundTask<T>(
    on childContext: NSManagedObjectContext,
    receivingFrom parentContext: NSManagedObjectContext,
    _ exec: @escaping (NSManagedObjectContext) throws -> T
) -> AnyPublisher<T, Error> {
    Deferred {
        Future { promise in
            childContext.perform {
                promise(Result {
                    try exec(childContext)
                })
            }
        }
    }
    .eraseToAnyPublisher()
}

/// Applies changes to child context and saves parent context.
/// - Parameters:
///   - childContext: Child context that changes should be applied to. You must assign parent context to this one manually.
///   - parentContext: Parent context that will be saved.
///   - exec: Child context mutating closure.
func performWritingBackgroundTask(
    on childContext: NSManagedObjectContext,
    pushingChangesTo parentContext: NSManagedObjectContext,
    _ exec: @escaping (NSManagedObjectContext) throws -> Void
) -> AnyPublisher<Void, Error> {
    Deferred {
        Future { promise in
            childContext.perform {
                do {
                    try exec(childContext)
                    
                    if childContext.hasChanges {
                        try childContext.save()
                    }
                } catch {
                    promise(.failure(error))
                }
                
                parentContext.perform {
                    promise(Result {
                        if parentContext.hasChanges {
                            try parentContext.save()
                        }
                    })
                }
            }
        }
    }
    .eraseToAnyPublisher()
}

func makeFetchRequest<T: NSManagedObjectConvertible>(for plainType: T.Type, byID id: T.ID) -> NSFetchRequest<T.ManagedEntity> {
    let req = NSFetchRequest<T.ManagedEntity>(entityName: T.ManagedEntity.name)
    
    req.predicate = NSPredicate(format: "id == \(T.ManagedEntity.ID.placeholder)", argumentArray: [id])
    
    return req
}

func makeFetchRequest<T: NSManagedObjectConvertible>(for plainType: T.Type, byIDs ids: [T.ID]) -> NSFetchRequest<T.ManagedEntity> {
    let req = NSFetchRequest<T.ManagedEntity>(entityName: T.ManagedEntity.name)
    
    req.predicate = NSPredicate(format: "id IN %@", ids)
    
    return req
}

extension Dictionary {
    init<S: Sequence>(removingDuplicatesFrom sequence: S) where S.Element: Identifiable, Key == S.Element.ID, Value == S.Element {
        self = .init(sequence.map { ($0.id, $0) }) { first, _ in first }
    }
}
