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
        .init(id: 0, firstName: firstName, lastName: lastName)
    }
}

public struct TestUser: NSManagedObjectConvertible, Equatable, Identifiable {
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

final class TestCoreDataFactory: CoreDataFactory {
    private var momUrl: URL {
        Bundle.main.url(forResource: "eve-ent-model", withExtension: "momd")!
    }
    
    private lazy var mom = NSManagedObjectModel(contentsOf: momUrl)!
    
    private lazy var moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    private lazy var pc = with(NSPersistentContainer(name: "eve-ent-container", managedObjectModel: mom)) {
        $0.persistentStoreDescriptions = [
            NSPersistentStoreDescription()
                |> \.type .~ NSInMemoryStoreType
                |> \.shouldAddStoreAsynchronously .~ false
        ]
        
        $0.loadPersistentStores { desc, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func makeManagedObjectModel() -> NSManagedObjectModel {
        mom
    }
    
    func makeManagedObjectContext() -> NSManagedObjectContext {
        moc
    }
    
    func makePersistentContainer() -> NSPersistentContainer {
        pc
    }
}

class BasePersistenceGatewayTests: XCTestCase {
    private lazy var coreDataFactory = TestCoreDataFactory()
    private lazy var infrastructureFactory = InfrastructureFactory(coreDataFactory: coreDataFactory)
    
    private var gateway: BasePersistenceGateway!

    override func setUp() {
        super.setUp()
        
        gateway = infrastructureFactory.makeBasePersistenceGateway()
    }

    override func tearDown() {
        gateway = nil
        
        super.tearDown()
    }
    
    func testSave() {
        let ex = expectation(description: "Test saving")
        
        let cancellable = Publishers
            .Sequence(sequence: testUsers)
            .flatMap(gateway.save)
            .sink(
                receiveCompletion: {
                    $0.error.map { XCTFail($0.localizedDescription) } ?? ex.fulfill()
                },
                receiveValue: {}
            )
        
        waitForExpectations(timeout: 500)
    }

    func testFetch() {
        let ex = expectation(description: "Test fetching")
        
        let cancellable = Publishers
            .Sequence(sequence: testUsers)
            .flatMap(gateway.save)
            .collect()
            .map { [gateway] _ in
                gateway!.get(allOfType: TestUser.self)
            }
            .switchToLatest()
            .sink(
                receiveCompletion: {
                    $0.error.map { XCTFail($0.localizedDescription) }
                },
                receiveValue: { array in
                    if array == testUsers {
                        ex.fulfill()
                    } else {
                        XCTFail()
                    }
                }
            )
        
        waitForExpectations(timeout: 500)
    }
}
