//
//  BasePersistenceGatewayTests.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 14.01.2020.
//

import XCTest
import CoreData
import Combine
@testable import Eve_Ent

extension UserDTO: PlainEntityConvertible {
    public var plain: TestUser {
        .init(id: id, firstName: firstName, lastName: lastName)
    }
}

public struct TestUser: NSManagedObjectConvertible, Equatable, Identifiable {
    public typealias ManagedEntity = UserDTO
    
    public let id: Int64
    
    public let firstName: String
    public let lastName: String
    
    public func configure(new managed: UserDTO) {
        managed.id = id
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
        waiting("Test saving") { ex in
            Publishers
                .Sequence(sequence: testUsers)
                .flatMap(gateway.save)
                .sink(
                    receiveCompletion: {
                        $0.error.map { XCTFail($0.localizedDescription) } ?? ex.fulfill()
                    },
                    receiveValue: {}
                )
        }
    }

    func testFetch() {
        waiting("Test fetching") { exp in
            makeWriterPublisher(for: testUsers)
                .flatMap {
                    self.gateway!.get(allOfType: TestUser.self)
                }
                .sink(
                    receiveCompletion: {
                        $0.error.map { XCTFail($0.localizedDescription) }
                    },
                    receiveValue: { array in
                        if array.sorted(by: { $0.id < $1.id }) == testUsers.sorted(by: { $0.id < $1.id }) {
                            exp.fulfill()
                        } else {
                            XCTFail()
                        }
                    }
                )
        }
    }
    
    func testFetchWithPredicate() {
        waiting("Test fetch with predicate") { exp in
            makeWriterPublisher(for: testUsers)
                .flatMap {
                    self.gateway!.get(byId: testUsers[1].id)
                }
                .sink(
                    receiveCompletion: {
                        $0.error.map { XCTFail($0.localizedDescription) }
                    },
                    receiveValue: { (user: TestUser?) in
                        if let user = user, testUsers[1].id == user.id {
                            exp.fulfill()
                        } else {
                            XCTFail()
                        }
                    }
                )
            }
    }
    
    func waiting<T: Cancellable>(_ message: String? = nil, timeout: TimeInterval = 500, _ exec: (XCTestExpectation) -> T) -> Void {
        let exp = message == nil ? expectation(description: "") : expectation(description: message!)
        
        let something = exec(exp)
        
        waitForExpectations(timeout: timeout) {
            $0.map {
                something.cancel()
                
                XCTFail($0.localizedDescription)
            }
        }
    }
    
    private func makeWriterPublisher<T: NSManagedObjectConvertible>(for data: [T]) -> AnyPublisher<Void, Error> {
        Publishers
            .Sequence(sequence: data)
            .flatMap(gateway.save)
            .collect()
            .map { _ in }
            .eraseToAnyPublisher()
    }
}
