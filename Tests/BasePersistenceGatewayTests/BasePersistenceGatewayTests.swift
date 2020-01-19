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

class CoreDataGatewayTests: XCTestCase {
    private lazy var coreDataFactory = TestCoreDataFactory()
    private lazy var infrastructureFactory = InfrastructureFactory(coreDataFactory: coreDataFactory)
    
    private var coreData: CoreDataGateway!

    override func setUp() {
        super.setUp()
        
        coreData = infrastructureFactory.makeCoreDataGateway()
    }

    override func tearDown() {
        coreData = nil
        
        super.tearDown()
    }
    
    func testSaveOne() {
        waiting("Test save one") { exp in
            self.coreData.save(testUsers[0], shouldEditExisting: true)
                .flatMap {
                    self.coreData.getAll()
                }
                .sink { (users: [User]) in
                    if users == [testUsers[0]] {
                        exp.fulfill()
                    } else {
                        XCTFail()
                    }
                }
        }
    }
    
    func testSaveMany() {
        waiting("Test save many") { exp in
            self.coreData.save([testUsers[0]], shouldEditExisting: true)
                .flatMap {
                    self.coreData.getAll()
                }
                .sink { (users: [User]) in
                    if users == [testUsers[0]] {
                        exp.fulfill()
                    } else {
                        XCTFail()
                    }
                }
        }
    }
    
    func testEditOne() {
        var editedUser = testUsers[0]
        
        editedUser.firstName = "Nikita"
        editedUser.lastName = "Kislyakov"
        
        waiting("Test edit one") { exp in
            self.coreData.save(testUsers[0], shouldEditExisting: true)
                .flatMap {
                    self.coreData.save(editedUser, shouldEditExisting: true)
                }
                .flatMap {
                    self.coreData.get(byID: editedUser.id)
                }
                .sink { (user: User?) in
                    if user == editedUser {
                        exp.fulfill()
                    } else {
                        XCTFail()
                    }
                }
        }
    }

    func testFetch() {
        waiting("Test fetching") { exp in
            save(testUsers)
                .flatMap {
                    self.coreData.getAll()
                }
                .sink { (array: [User]) in
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
            save(testUsers)
                .flatMap {
                    self.coreData.get(byID: testUsers[1].id)
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
            save(testDevices)
                .flatMap {
                    self.coreData.getAll()
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
            save(testUsers)
                .flatMap {
                    self.coreData.getAll(using: NSPredicate(format: "user.id == %d", testUsers[0].id))
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
            save(testDevices)
                .flatMap {
                    self.save(overwrittenDevices)
                }
                .flatMap {
                    self.coreData.getAll()
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
            save(testDevices)
                .flatMap {
                    self.save(overwrittenDevices, replace: false)
                }
                .flatMap {
                    self.coreData.getAll()
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
                
                let c = self.coreData.save(expectedUsers[recordedUsers.count])
                    .sink(
                        receiveCompletion: { _ in sem.signal() },
                        receiveValue: {}
                    )
                
                sem.wait()
            }
            
            return coreData
                .listenUpdates(byID: testUsers[0].id)
                .sink { (user: User) in
                    recordedUsers.append(user)
                    
                    if recordedUsers == expectedUsers {
                        exp.fulfill()
                    } else if recordedUsers.count == 3 {
                        XCTFail()
                    } else {
                        DispatchQueue.global().async {
                            let sem = DispatchSemaphore(value: 0)
                            
                            let c = self.coreData.save(expectedUsers[recordedUsers.count])
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
    
    func testDeleteAll() {
        waiting("Test delete all") { exp in
            save(testUsers)
                .flatMap {
                    self.coreData.deleteAll(ofType: User.self)
                }
                .flatMap {
                    self.coreData.getAll()
                }
                .sink { (users: [User]) in
                    if users.isEmpty {
                        exp.fulfill()
                    } else {
                        XCTFail()
                    }
                }
        }
    }

    private func save<T: NSManagedObjectConvertible>(_ data: [T], replace: Bool = true) -> AnyPublisher<Void, Error> {
        Just((data, replace))
            .setFailureType(to: Error.self)
            .flatMap(coreData.save)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}
