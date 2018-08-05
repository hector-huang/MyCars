//
//  DetailsViewController.swift
//  MyCars
//
//  Created by Coroma Consulting on 5/8/18.
//  Copyright © 2018 hectorhuang. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var commentsLabel: UITextView!
    
    var car: Car!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.title = "Details"
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yearLabel.text = String(car.year)
        brandLabel.text = car.brand
        modelLabel.text = car.model
        if let comments = car.comments {
            commentsLabel.sizeToFit()
            commentsLabel.text = comments
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // in order to set the text of back button to car info in next screen
        self.title = "\(car.brand) \(car.model)"
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        let editViewController = EditViewController()
        editViewController.currentCar = car
        navigationController?.pushViewController(editViewController, animated: true)
    }
}
