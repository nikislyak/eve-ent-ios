//
//  User.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 19.01.2020.
//

import Foundation
import CoreData
import Overture
@testable import Eve_Ent

public struct User: NSManagedObjectConvertible, Hashable {
    public typealias ManagedEntity = UserDTO
    
    public let id: Int64
    
    public let firstName: String
    public let lastName: String
    public let devices: Set<Device>
    
    public func createManaged(insertingIn context: NSManagedObjectContext) -> UserDTO {
        let user = UserDTO(moc: context)
        
        user?.id = id
        user?.firstName = firstName
        user?.lastName = lastName
        
        user?.addToDevices(
            NSSet(
                array: .init(
                    devices.map { $0.createManaged(insertingIn: context) }
                )
            )
        )
        
        return user!
    }
    
    public func edit(existing managed: UserDTO) {
        managed.id = id
        managed.firstName = firstName
        managed.lastName = lastName
        
        let seq = managed.devices.compactMap { erased -> (DeviceDTO.ID, DeviceDTO)? in
            let dto = erased as? DeviceDTO
            
            return zip(dto?.id, dto)
        }
        
        let devicesDict = Dictionary(seq) { first, _ in first }
        
        devices.forEach { device in
            devicesDict[device.id].map(device.edit)
        }
    }
}

extension UserDTO: PlainEntityConvertible {
    public var plain: User {
        .init(
            id: id,
            firstName: firstName,
            lastName: lastName,
            devices: .init(devices.compactMap { ($0 as? DeviceDTO)?.plain })
        )
    }
}
