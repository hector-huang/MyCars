//
//  ViewController.swift
//  MyCars
//
//  Created by Coroma Consulting on 4/8/18.
//  Copyright © 2018 hectorhuang. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var cars: [NSManagedObject]?
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var carsTable: UITableView!
    
    @IBAction func addButtonPress(_ sender: UIButton) {
        let editViewController = EditViewController()
        navigationController?.pushViewController(editViewController, animated: true)
    }
    
    // Core data request is put in this method for refreshing the car list when poping back from other screens, as viewDidLoad won't be called if this view already exist in navigation stack
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cars")
        fetchRequest.returnsObjectsAsFaults = false
        
        // Initialize Asynchronous Fetch Request in order not to block UI updates on main thread
        let asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { result in
            DispatchQueue.main.async {
                if let finalResult = result.finalResult {
                    self.cars = finalResult as? [NSManagedObject]
                    self.carsTable.reloadData()
                }
            }
        }
        
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            try context.execute(asyncFetchRequest)
        } catch {
            let alertController = UIAlertController(title: nil, message: "Failed to read user data", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        carsTable.dataSource = self
        carsTable.delegate = self
        
        setupAddButton()
        self.title = "My Cars"
    }
    
    fileprivate func setupAddButton() {
        addButton.layer.borderWidth = 1
        addButton.layer.cornerRadius = 2.5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = cars {
            return data.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nib = Bundle.main.loadNibNamed("CarTableCell", owner: self, options: nil)
        let cell = nib?.first as! CarTableCell
        
        if let data = cars {
            cell.carInfoLabel.text = "\(String(data[indexPath.row].value(forKey:"year") as! Int)) \(data[indexPath.row].value(forKey:"brand") as! String) \(data[indexPath.row].value(forKey:"model") as! String)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let data = cars {
            let detailsViewController = DetailsViewController()
            detailsViewController.car = Car(objectId: data[indexPath.row].objectID, year: data[indexPath.row].value(forKey:"year") as! Int, brand: data[indexPath.row].value(forKey:"brand") as! String, model: data[indexPath.row].value(forKey:"model") as! String)
            if let comments = data[indexPath.row].value(forKey:"comments") as? String {
                detailsViewController.car.comments = comments
            }
            navigationController?.pushViewController(detailsViewController, animated: true)
        }
    }

}

