//
//  UserDTO+CoreDataProperties.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 16.01.2020.
//
//

import Foundation
import CoreData


extension UserDTO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserDTO> {
        return NSFetchRequest<UserDTO>(entityName: "UserDTO")
    }

    @NSManaged public var firstName: String
    @NSManaged public var id: Int64
    @NSManaged public var lastName: String

}
