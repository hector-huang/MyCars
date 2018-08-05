//
//  DatabaseManagerTests.swift
//  MyCarsTests
//
//  Created by Coroma Consulting on 5/8/18.
//  Copyright © 2018 hectorhuang. All rights reserved.
//

import XCTest
import UIKit
import CoreData

class DatabaseManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSaveCar() {
        let newCar = Car(year: 1992, brand: "Ford", model: "abc")
        XCTAssertEqual(DatabaseManager.shared.save(car: newCar), true)
    }
    
    func testUpdateCar() {
        let newCar = Car(year: 1992, brand: "Ford", model: "abc")
        if DatabaseManager.shared.save(car: newCar) {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cars")
            do {
                let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
                let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
                do {
                    try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
                } catch {
                    print("Adding in-memory persistent store failed")
                }
                let context = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
                context.persistentStoreCoordinator = persistentStoreCoordinator
                let oldCarRecord = try context.fetch(fetchRequest) as! [NSManagedObject]
                if let objectId = oldCarRecord.first?.objectID {
                    XCTAssertEqual(DatabaseManager.shared.update(car: Car(objectId: objectId, year: 1993, brand: "BMW", model: "EDF")), true)
                }
            } catch {}
        }
    }
}
