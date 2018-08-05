//
//  Car.swift
//  MyCars
//
//  Created by Coroma Consulting on 5/8/18.
//  Copyright © 2018 hectorhuang. All rights reserved.
//
import CoreData

class Car {
    
    var objectId: NSManagedObjectID?
    var year: Int
    var brand: String
    var model: String
    var comments: String?
    
    init(year: Int, brand: String, model: String) {
        self.year = year
        self.brand = brand
        self.model = model
    }
    
    convenience init(objectId: NSManagedObjectID, year: Int, brand: String, model: String) {
        self.init(year: year, brand: brand, model: model)
        self.objectId = objectId
    }
}
