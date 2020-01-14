//
//  BasePersistenceGatewayTests.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 14.01.2020.
//

import XCTest
import CoreData
import Tagged
import Combine
@testable import Eve_Ent

extension UserDTO: PlainEntityConvertible {
    public var plain: TestUser {
        .init(id: 0, firstName: firstName ?? "", lastName: lastName ?? "")
    }
}

public struct TestUser: NSManagedObjectConvertible, Equatable {
    public typealias ManagedEntity = UserDTO
    
    public let id: UInt64
    
    public let firstName: String
    public let lastName: String
    
    public func configure(new managed: UserDTO) {
        managed.firstName = firstName
        managed.lastName = lastName
    }
}

let testUsers: [TestUser] = [
    TestUser(id: 0, firstName: "Makaley", lastName: "Kalkin"),
    TestUser(id: 1, firstName: "Makaley1", lastName: "Kalkin1"),
    TestUser(id: 2, firstName: "Makaley2", lastName: "Kalkin2"),
]

class BasePersistenceGatewayTests: XCTestCase {
    private let infrastructureFactory = InfrastructureFactory()
    
    lazy var gateway: BasePersistenceGateway = .init(infrastructureFactory.makeMOC(), infrastructureFactory.makePersistentContainer())

    override func setUp() {}

    override func tearDown() {}
    
    func testSave() {
        _ = Publishers
            .Sequence(sequence: testUsers)
            .flatMap(gateway.save)
            .collect()
            .sink(
                receiveCompletion: { XCTAssert($0.error == nil) },
                receiveValue: { _ in }
            )
    }

    func testFetch() {
        let users = gateway.get(all: TestUser.self)
        
        let ex = XCTestExpectation()
        
        _ = users
            .sink(
                receiveCompletion: {
                    $0.error.map { _ in
                        XCTFail()
                    }
                },
                receiveValue: { array in
                    if array == testUsers {
                        XCTAssertEqual(array, testUsers)
                        ex.fulfill()
                    } else {
                        XCTFail()
                    }
                }
        )
    }
}
