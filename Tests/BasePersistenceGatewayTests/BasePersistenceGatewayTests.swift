//
//  BasePersistenceGatewayTests.swift
//  Eve-Ent
//
//  Created by Nikita Kislyakov on 14.01.2020.
//

import XCTest
import CoreData
import Combine
import Overture
@testable import Eve_Ent

let testDevices: [Device] = [
    Device(id: 0, name: "iPhone 8"),
    Device(id: 1, name: "iPhone 8 Plus"),
    Device(id: 2, name: "iPhone 11"),
    Device(id: 3, name: "iPhone 11 Pro"),
]

let testUsers: [User] = [
    User(id: 0, firstName: "Makaley", lastName: "Kalkin", devices: .init(arrayLiteral: testDevices[0], testDevices[3])),
    User(id: 1, firstName: "Makaley1", lastName: "Kalkin1", devices: .init(arrayLiteral: testDevices[1])),
    User(id: 2, firstName: "Makaley2", lastName: "Kalkin2", devices: .init(arrayLiteral: testDevices[2])),
]

final class TestCoreDataFactory: CoreDataFactory {
    private var momUrl: URL {
        Bundle(for: TestCoreDataFactory.self).url(forResource: "eve-ent-test-model", withExtension: "momd")!
    }
    
    private lazy var mom = NSManagedObjectModel(contentsOf: momUrl)!
    
    private lazy var moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
    private lazy var pc = with(NSPersistentContainer(name: "eve-ent-test-container", managedObjectModel: mom)) {
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
    
    func makeChildManagedObjectContext() -> NSManagedObjectContext {
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
                .Sequence(sequence: testUsers.map { ($0, true) })
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
                    self.gateway.get(allOfType: User.self)
                }
                .sink { array in
                    if array.sorted(by: \.id) == testUsers.sorted(by: \.id) {
                        exp.fulfill()
                    } else {
                        XCTFail()
                    }
                }
        }
    }
    
    func testFetchWithPredicate() {
        waiting("Test fetch with predicate") { exp in
            makeWriterPublisher(for: testUsers)
                .flatMap {
                    self.gateway.get(byId: testUsers[1].id)
                }
                .sink { (user: User?) in
                    if let user = user, testUsers[1].id == user.id {
                        exp.fulfill()
                    } else {
                        XCTFail()
                    }
                }
            }
    }
    
    func testFetchDevices() {
        waiting("Test fetch devices for user with id") { exp in
            makeWriterPublisher(for: testDevices)
                .flatMap {
                    self.gateway.get(allOfType: Device.self)
                }
                .sink { (devices: [Device]) in
                    if devices.sorted(by: \.id) == testDevices {
                        exp.fulfill()
                    } else {
                        XCTFail()
                    }
                }
        }
    }
    
    func testFetchDevicesForUserWithId() {
        waiting("Test fetch devices for user with id") { exp in
            makeWriterPublisher(for: testUsers)
                .flatMap {
                    self.gateway.get(allOfType: Device.self, using: NSPredicate(format: "user.id == %d", testUsers[0].id))
                }
                .sink { (devices: [Device]) in
                    if devices.sorted(by: \.id) == [testDevices[0], testDevices[3]] {
                        exp.fulfill()
                    } else {
                        XCTFail()
                    }
                }
        }
    }
    
    func testOverwriteWithReplacement() {
        let overwrittenDevices = testDevices.map { Device(id: $0.id, name: $0.name + "!") }
        
        waiting("Test overwrite with replacement") { exp in
            makeWriterPublisher(for: testDevices)
                .flatMap {
                    self.makeWriterPublisher(for: overwrittenDevices)
                }
                .flatMap {
                    self.gateway!.get(allOfType: Device.self)
                }
                .sink { (devices: [Device]) in
                    if devices.sorted(by: \.id) == overwrittenDevices {
                        exp.fulfill()
                    } else {
                        XCTFail()
                    }
                }
        }
    }
    
    func testOverwriteWithoutReplacement() {
        let overwrittenDevices = testDevices.map { Device(id: $0.id, name: $0.name + "!") }
        
        waiting("Test overwrite with replacement") { exp in
            makeWriterPublisher(for: testDevices)
                .flatMap {
                    self.makeWriterPublisher(for: overwrittenDevices, replace: false)
                }
                .flatMap {
                    self.gateway!.get(allOfType: Device.self)
                }
                .sink { (devices: [Device]) in
                    if devices.sorted(by: \.id) != overwrittenDevices {
                        exp.fulfill()
                    } else {
                        XCTFail()
                    }
                }
        }
    }
    
    func testListen() {
        let expectedUsers: [User] = [
            User(id: testUsers[0].id, firstName: testUsers[0].firstName, lastName: testUsers[0].lastName, devices: testUsers[0].devices),
            User(id: testUsers[0].id, firstName: testUsers[0].firstName + "!", lastName: testUsers[0].lastName, devices: testUsers[0].devices),
            User(id: testUsers[0].id, firstName: testUsers[0].firstName, lastName: testUsers[0].lastName + "!", devices: testUsers[0].devices),
        ]
        
        waiting("Test listen") { exp -> AnyCancellable in
            var recordedUsers: [User?] = []
            
            DispatchQueue.global().async {
                let sem = DispatchSemaphore(value: 0)
                
                let c = self.gateway.save(expectedUsers[recordedUsers.count])
                    .sink(
                        receiveCompletion: { _ in sem.signal() },
                        receiveValue: {}
                    )
                
                sem.wait()
            }
            
            return gateway
                .listenUpdates(byId: testUsers[0].id)
                .sink { (user: User) in
                    recordedUsers.append(user)
                    
                    if recordedUsers == expectedUsers {
                        exp.fulfill()
                    } else if recordedUsers.count == 3 {
                        XCTFail()
                    } else {
                        DispatchQueue.global().async {
                            let sem = DispatchSemaphore(value: 0)
                            
                            let c = self.gateway.save(expectedUsers[recordedUsers.count])
                                .sink(
                                    receiveCompletion: { _ in sem.signal() },
                                    receiveValue: {}
                                )
                            
                            sem.wait()
                        }
                    }
                }
        }
    }
    
    func waiting<T: Cancellable>(_ message: String? = nil, timeout: TimeInterval = 1, _ exec: (XCTestExpectation) -> T) -> Void {
        let exp = message == nil ? expectation(description: "") : expectation(description: message!)
        
        let something = exec(exp)
        
        waitForExpectations(timeout: timeout) {
            $0.map { _ in
                something.cancel()
            }
        }
    }

    private func makeWriterPublisher<T: NSManagedObjectConvertible>(for data: [T], replace: Bool = true) -> AnyPublisher<Void, Error> {
        Just((data, replace))
            .setFailureType(to: Error.self)
            .flatMap(gateway.save)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}
