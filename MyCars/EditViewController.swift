//
//  EditViewController.swift
//  MyCars
/**
 1. Instead of a massive ViewController with heaps of delegate methods, all UITextField, UIPickerView and validations in this class are solved in reactive programming, which declartively handles the event/data streams using RxSwift.
 2. By following MVVM design pattern, the validation rules are put into viewModel (EditFormVM) completely seperated from this view controller
 **/
//
//  Created by Coroma Consulting on 4/8/18.
//  Copyright © 2018 hectorhuang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditViewController: UIViewController {

    @IBOutlet weak var yearPicker: UIPickerView!
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var commentsTextBox: UITextView!
    @IBOutlet weak var brandValidationLabel: UILabel!
    @IBOutlet weak var modelValidationLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var hintTableView: UITableView!
    @IBOutlet weak var hintTableHeight: NSLayoutConstraint!
    
    let pickerStartYear = 1970
    private var selectedYear: Int?
    var currentCar:Car?
    
    var viewModel = EditFormVM()
    let disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        yearPicker.selectRow(selectedYear!-pickerStartYear, inComponent: 0, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Edit"
        
        if let car = currentCar {
            prefillForm(car: car)
        } else {
            selectedYear = pickerStartYear
        }
        // set up datasource of year UIPickerView
        Observable.just(getPickerData())
            .bind(to: yearPicker.rx.itemTitles) { _, item in
                return "\(item)"
            }
            .disposed(by: disposeBag)
        
        hintTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        hintTableView.rowHeight = 25
        bindViewToViewModel()
        bindViewModelToView()
        
        // enable tapping elsewhere to dismiss keyboard of text view input
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditViewController.formTapAction(_:)))
        formView.addGestureRecognizer(tapGesture)
    }
    
    @objc func formTapAction(_ sender:UITapGestureRecognizer){
        commentsTextBox.endEditing(true)
    }
    
    // set up years dataset from 1970 to this year
    func getPickerData() -> [Int] {
        var years: [Int] = [Int]()
        let date = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: date)
        for year in pickerStartYear...currentYear {
            years.append(year)
        }
        return years
    }
    
    fileprivate func prefillForm(car: Car) {
        selectedYear = car.year
        brandTextField.text = car.brand
        modelTextField.text = car.model
        if let comments = car.comments {
            commentsTextBox.text = comments
        }
    }
    
    fileprivate func bindViewToViewModel() {
        // bind year piker view to the state year of view model
        yearPicker.rx.modelSelected(Int.self)
            .subscribe(onNext: { [unowned self] (year) in
                self.viewModel.year.value = year[0]
            })
            .disposed(by: disposeBag)
        
        // bind brand text field to the state brand of view model
        brandTextField.rx.text
            .orEmpty
            .bind(to: viewModel.brand)
            .disposed(by: disposeBag)
        
        // bind model text field to the state model of view model
        modelTextField.rx.text
            .orEmpty
            .bind(to: viewModel.model)
            .disposed(by: disposeBag)
        
        // bind comments text view to the state comments of view model
        commentsTextBox.rx.text
            .orEmpty
            .bind(to: viewModel.comments)
            .disposed(by: disposeBag)
    }
    
    fileprivate func bindViewModelToView() {
        // bind validBrand state of view model to brand validation label and hint table as soon as user begins to edit
        brandTextField.rx.controlEvent([.editingDidBegin])
            .asObservable()
            .subscribe(onNext: { [unowned self] in
                self.viewModel.validBrand
                    .bind(to: self.brandValidationLabel.rx.isHidden)
                    .disposed(by: self.disposeBag)
                self.viewModel.brandHints
                    .bind(to: self.hintTableView.rx.items(cellIdentifier: "Cell")) {
                        (index, hint, cell) in
                        cell.textLabel?.text = hint
                    }
                    .disposed(by: self.disposeBag)
                self.viewModel.brandHints
                    .map { hints in
                        return hints.isEmpty
                    }
                    .bind(to: self.hintTableView.rx.isHidden)
                    .disposed(by: self.disposeBag)
                self.viewModel.brandHints
                    .map { hints in
                        return CGFloat(hints.count * 25)
                    }
                    .bind(to: self.hintTableHeight.rx.constant)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        // bind validModel state of view model to model validation label as soon as user begins to edit
        modelTextField.rx.controlEvent([.editingDidBegin])
            .asObservable()
            .subscribe(onNext: { [unowned self] in
                self.viewModel.validModel
                    .bind(to: self.modelValidationLabel.rx.isHidden)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        // bind isValid(everything) state of view model to enabled state of done button
        viewModel.isValid
            .bind(to: doneButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    @IBAction func CancelButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func DoneButtonPressed(_ sender: UIButton) {
        var alertController: UIAlertController
        var okAction: UIAlertAction
        // update car info to local database if it is editing the existing car
        if let car = currentCar {
            // if update success, go back to home screen
            if viewModel.updateCar(carId: car.objectId!) {
                alertController = UIAlertController(title: "Car Updated", message: "Congrats! \(viewModel.brand.value) has been updated in your car list", preferredStyle: .alert)
                okAction = UIAlertAction(title: "OK", style: .default) { action in
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                alertController = UIAlertController(title: nil, message: "Fail to update car", preferredStyle: .alert)
                okAction = UIAlertAction(title: "OK", style: .default)
            }
        } else {
            // save new car info to local database, if success, go back to home screen
            if viewModel.saveCar() {
                alertController = UIAlertController(title: "Car Added", message: "Congrats! \(viewModel.brand.value) has been added to your car list", preferredStyle: .alert)
                okAction = UIAlertAction(title: "OK", style: .default) { action in
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                alertController = UIAlertController(title: nil, message: "Fail to add car", preferredStyle: .alert)
                okAction = UIAlertAction(title: "OK", style: .default)
            }
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
