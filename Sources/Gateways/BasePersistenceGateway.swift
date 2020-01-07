//
//  BasePersistenceGateway.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 22.11.2019.
//  Copyright © 2019 Nikita Kislyakov. All rights reserved.
//

import Foundation
import Combine
import CoreData

protocol PlainEntityConvertible: NSManagedObject {
    associatedtype PlainEntity: Identifiable, NSManagedObjectConvertible where PlainEntity.ManagedEntity == Self
    
    static var name: String { get }
    
    var value: PlainEntity { get }
}

extension PlainEntityConvertible {
    static var name: String {
        String(describing: type(of: self))
    }
}

protocol NSManagedObjectConvertible {
    associatedtype ManagedEntity: Identifiable, PlainEntityConvertible where ManagedEntity.PlainEntity == Self
    
    var value: ManagedEntity { get }
}

class BasePersistenceGateway {
    private let context: NSManagedObjectContext
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
    }
    
    func get<T: PlainEntityConvertible>(all managed: T.Type) -> AnyPublisher<[T.PlainEntity], Error> {
        Just(NSFetchRequest(entityName: T.name))
            .tryMap(context.fetch)
            .map { $0.compactMap { ($0 as? T)?.value } }
            .eraseToAnyPublisher()
    }
    
    func save<T: NSManagedObjectConvertible>(_ plain: T) -> AnyPublisher<Void, Error> {
        Just(context.insert(plain.value))
            .tryMap(context.save)
            .eraseToAnyPublisher()
    }
    
//    func save<T: NSManagedObjectConvertible>(_ plains: [T]) -> AnyPublisher<Void, Error> {
//        
//    }
}
