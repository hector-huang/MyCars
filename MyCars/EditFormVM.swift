//
//  EditFormVM.swift
//  MyCars
//
//  Created by Coroma Consulting on 5/8/18.
//  Copyright © 2018 hectorhuang. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

class EditFormVM {
    let carBrands = ["Ford", "Mazda", "Toyota", "Honda", "Holden", "Jeep", "Audi", "Hyundai", "Lexus", "Ferrari", "Buick", "Cadillac", "Lamborghini", "Benz", "Nissan", "Suzuki", "Tesla", "Volkswagen", "Volvo", "Subaru", "Maserati", "Kia", "Fiat", "BMW", "Mini"]
    var year = Variable<Int>(1970)
    var brand = Variable<String>("")
    var model = Variable<String>("")
    var comments = Variable<String>("")
    
    var validYear: Observable<Bool> {
        let date = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: date)
        return year.asObservable().map { $0 >= 1970 && $0 <= currentYear }
    }
    
    var validBrand: Observable<Bool> {
        return brand.asObservable().map { self.carBrands.contains($0) }
    }
    
    var validModel: Observable<Bool> {
        return model.asObservable().map { !$0.isEmpty }
    }
    
    // flag that implies if the whole form is valid
    var isValid: Observable<Bool> {
        return Observable
            .combineLatest([validYear,
                            validBrand,
                            validModel]) { (values) -> Bool in
                                return values.reduce(true, { $0 && $1 } )
        }
    }
    
    var brandHints: Observable<[String]> {
        return brand.asObservable().map { self.getHints(brandInput: $0) }
    }
    
    fileprivate func getHints(brandInput: String) -> [String] {
        var hints = [String]()
        if !carBrands.contains(brandInput) {
            for brand in carBrands {
                if brand.first == brandInput.uppercased().first {
                    hints.append(brand)
                }
            }
        }
        return hints
    }
    
    func saveCar() -> Bool {
        let car = Car(year: year.value, brand: brand.value, model: model.value)
        car.comments = comments.value
        return DatabaseManager.shared.save(car: car)
    }
    
    func updateCar(carId: NSManagedObjectID) -> Bool {
        let car = Car(objectId: carId, year: year.value, brand: brand.value, model: model.value)
        car.comments = comments.value
        return DatabaseManager.shared.update(car: car)
    }
    
}
