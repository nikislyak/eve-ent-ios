//
//  UserDTO+CoreDataProperties.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 17.01.2020.
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
    @NSManaged public var devices: NSSet

}

// MARK: Generated accessors for devices
extension UserDTO {

    @objc(addDevicesObject:)
    @NSManaged public func addToDevices(_ value: DeviceDTO)

    @objc(removeDevicesObject:)
    @NSManaged public func removeFromDevices(_ value: DeviceDTO)

    @objc(addDevices:)
    @NSManaged public func addToDevices(_ values: NSSet)

    @objc(removeDevices:)
    @NSManaged public func removeFromDevices(_ values: NSSet)

}
