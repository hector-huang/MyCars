//
//  MyCarsTests.swift
//  MyCarsTests
//
//  Created by Coroma Consulting on 4/8/18.
//  Copyright © 2018 hectorhuang. All rights reserved.
//

import XCTest
@testable import MyCars

class MyCarsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // test if UI is rendered properly according to the prefilled car info
    func testEditViewControllerPrefill() {
        let editViewController = EditViewController(nibName: "EditViewController", bundle: nil)
        editViewController.loadView()
        editViewController.currentCar = Car(year: 1992, brand: "Mazda", model: "ss")
        editViewController.currentCar?.comments = "test1234"
        editViewController.viewDidLoad()
        
        XCTAssertEqual(editViewController.yearPicker.selectedRow(inComponent: 0), 0)
        XCTAssertEqual(editViewController.brandTextField.text, "Mazda")
        XCTAssertEqual(editViewController.modelTextField.text, "ss")
        XCTAssertEqual(editViewController.commentsTextBox.text, "test1234")
    }
    
    // test scenarios when the validation fails due to invalid brand, year, model, multiples.
    func testEditViewControllerInvalid() {
        let editViewController = EditViewController(nibName: "EditViewController", bundle: nil)
        editViewController.loadView()
        editViewController.viewDidLoad()
        
        editViewController.brandTextField.text = "Fordd"
        editViewController.modelTextField.text = "s"
        XCTAssertEqual(editViewController.doneButton.isEnabled, false)
        
        editViewController.brandTextField.text = "Ford"
        editViewController.modelTextField.text = ""
        XCTAssertEqual(editViewController.doneButton.isEnabled, false)
    }
    
    // test scenarios when the validation succeeds
    func testEditViewControllerValid() {
        let editViewController = EditViewController(nibName: "EditViewController", bundle: nil)
        editViewController.loadView()
        
        editViewController.brandTextField.text = "Ford"
        editViewController.modelTextField.text = "s"
        editViewController.viewDidLoad()
        
        XCTAssertEqual(editViewController.doneButton.isEnabled, true)
        
        editViewController.commentsTextBox.text = "test1234"
        XCTAssertEqual(editViewController.doneButton.isEnabled, true)
    }
}
