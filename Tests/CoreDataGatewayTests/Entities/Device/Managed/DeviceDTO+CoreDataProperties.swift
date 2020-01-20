//
//  DeviceDTO+CoreDataProperties.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 17.01.2020.
//
//

import Foundation
import CoreData


extension DeviceDTO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DeviceDTO> {
        return NSFetchRequest<DeviceDTO>(entityName: "DeviceDTO")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String
    @NSManaged public var user: UserDTO?

}
