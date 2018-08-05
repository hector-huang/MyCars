//
//  DatabaseManager.swift
//  MyCars
//
//  Created by Coroma Consulting on 5/8/18.
//  Copyright © 2018 hectorhuang. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DatabaseManager {
    static let shared = DatabaseManager()
    
    func save(car: Car) -> Bool {
        var context: NSManagedObjectContext
        if !isRunningUnitTests() {
            // in test environment, AppDelegate cannot be called
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            context = appDelegate.persistentContainer.viewContext
        } else {
            let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            do {
                try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
            } catch {
                print("Adding in-memory persistent store failed")
            }
            context = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = persistentStoreCoordinator
        }
        let entity = NSEntityDescription.entity(forEntityName: "Cars", in: context)
        let newCar = NSManagedObject(entity: entity!, insertInto: context)
        newCar.setValue(car.year, forKey: "year")
        newCar.setValue(car.brand, forKey: "brand")
        newCar.setValue(car.model, forKey: "model")
        if let comments = car.comments {
            newCar.setValue(comments, forKey: "comments")
        }
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    func update(car: Car) -> Bool {
        var context: NSManagedObjectContext
        if !isRunningUnitTests() {
            // in test environment, AppDelegate cannot be called
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            context = appDelegate.persistentContainer.viewContext
        } else {
            let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            do {
                try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
            } catch {
                print("Adding in-memory persistent store failed")
            }
            context = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = persistentStoreCoordinator
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cars")
        fetchRequest.predicate = NSPredicate(format: "SELF == %@", car.objectId!)
        do {
            let oldCarRecord = try context.fetch(fetchRequest) as! [NSManagedObject]
            if let oldCar = oldCarRecord.first {
                oldCar.setValue(car.year, forKey: "year")
                oldCar.setValue(car.brand, forKey: "brand")
                oldCar.setValue(car.model, forKey: "model")
                if let comments = car.comments {
                    oldCar.setValue(comments, forKey: "comments")
                }
            }
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    fileprivate func isRunningUnitTests() -> Bool {
        let env = ProcessInfo.processInfo.environment
        if let injectBundle = env["TEST_MODE"] {
            return injectBundle == "enable"
        }
        return false
    }
}
