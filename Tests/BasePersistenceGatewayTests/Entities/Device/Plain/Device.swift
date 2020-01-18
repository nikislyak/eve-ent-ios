//
//  Device.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 19.01.2020.
//

import Foundation
import CoreData
@testable import Eve_Ent

public struct Device: NSManagedObjectConvertible, Hashable {
    public typealias ManagedEntity = DeviceDTO
    
    public let id: Int64
    
    public let name: String
    
    public func createManaged(insertingIn context: NSManagedObjectContext) -> DeviceDTO {
        let device = DeviceDTO(moc: context)
        
        device?.id = id
        device?.name = name
        
        return device!
    }
    
    public func edit(existing managed: DeviceDTO) {
        managed.id = id
        managed.name = name
    }
}

extension DeviceDTO: PlainEntityConvertible {
    public var plain: Device {
        .init(
            id: id,
            name: name
        )
    }
}
