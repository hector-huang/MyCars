//
//  DetailsViewControllerTests.swift
//  MyCarsTests
//
//  Created by Coroma Consulting on 5/8/18.
//  Copyright © 2018 hectorhuang. All rights reserved.
//

import XCTest

class DetailsViewControllerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // test if UI is rendered properly according to the prefilled car info
    func testDetailsViewControllerPrefill() {
        let detailsViewController = DetailsViewController(nibName: "DetailsViewController", bundle: nil)
        detailsViewController.loadView()
        detailsViewController.car = Car(year: 1992, brand: "Mazda", model: "ss")
        detailsViewController.car.comments = "test1234"
        detailsViewController.viewDidLoad()
        
        XCTAssertEqual(detailsViewController.yearLabel.text, "1992")
        XCTAssertEqual(detailsViewController.brandLabel.text, "Mazda")
        XCTAssertEqual(detailsViewController.modelLabel.text, "ss")
        XCTAssertEqual(detailsViewController.commentsLabel.text, "test1234")
        XCTAssertEqual(detailsViewController.title, "Details")
    }
}
