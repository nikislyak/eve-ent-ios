//
//  CoreDataFactory.swift
//  Data
//
//  Created by Nikita Kislyakov on 21.01.2020.
//

import Foundation
import CoreData

public protocol CoreDataFactory {
    func makeManagedObjectModel() -> NSManagedObjectModel
    func makeChildManagedObjectContext() -> NSManagedObjectContext
    func makePersistentContainer() -> NSPersistentContainer
}
